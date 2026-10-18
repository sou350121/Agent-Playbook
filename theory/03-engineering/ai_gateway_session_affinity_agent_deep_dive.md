---
auto_generated: true
generated_at: "2026-10-18T06:45:10Z"
source_url: "https://vercel.com/changelog/ai-gateway-logs-now-show-session-affinity"
signal_type: "blog_post"
---
# Vercel AI Gateway 会话亲和：把 Agent 运行成本变成可归因的会话账本 (Vercel AI Gateway Session Affinity: Session-Level Cost Attribution for Coding Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-18
>
> **项目/工具**: Vercel AI Gateway（日志 Sessions 视图 + Session Affinity 路由）
> **链接**: https://vercel.com/changelog/ai-gateway-logs-now-show-session-affinity
> **核心定位**: AI Gateway 的日志新增「Sessions 视图」，按会话（session）归并请求并展示亲和路由结果；会话亲和让同一会话的每次 turn 都打到缓存已热的 provider，从而把「缓存命中率」从不可见的黑盒变成能按 agent、按 cost 归因的指标

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：一个网关侧的可观测性 + 路由特性——请求被自动聚合成会话，每条会话带 cache hit rate、成本、模型/供应商路径；亲和路由默认开启，把同一会话继续交给上一个 provider，让 prompt cache 持续复用
- **现在值得用吗**：看场景——如果你已经在用 AI Gateway（或愿意把多 provider 调用收口到网关），这是零代码改动就能拿到的成本下降；如果你自研了路由层且已有自己的缓存亲和逻辑，短期收益有限
- **适合场景**：Claude Code / Codex / Cursor 这类高频多轮编码 agent；多 provider 容灾但怕缓存失效的项目；需要按 agent / 会话做成本核算的团队
- **不适合场景**：只用单一 provider 且直连（没有跨 provider 抖动，也就没有缓存丢失问题）；非文本请求（embeddings / 图像 / realtime 明确不在覆盖范围）；需要严格控制数据驻留而无法接受推测式会话指纹分组的场景
- **与之前核心差异**：此前 AI Gateway 日志是请求粒度的，你只能看到一堆 call；现在多了会话粒度 + 每条会话的缓存命中率与供应商切换路径——从「你花了多少钱」变成「你为哪一段 agent 运行花了多少钱、花在重复计算上多少」

## 是什么 / 解决什么问题

先说痛点。多轮 agent 会话里，**prompt 前缀是重复的**：system prompt、工具定义、历史对话，每一轮都要重新发一遍。各家 provider 的 prompt cache 就是为了省这笔钱——但缓存**挂在具体 provider 账号上**。当你的网关为了负载均衡或容灾，把第 5 轮发到了另一家 provider，那家的缓存是冷的，你按全价重新计费了整段 prompt。

官方文档把这个成本机制说得很直白：

> A provider's prompt cache lives on the provider account that served your request. When the next request in a conversation goes somewhere else, that cache is cold and you pay full price for the prompt again.

Session affinity 就是解决这个：网关把相关请求归成一个会话，记住上一轮是哪个 provider 服务的，下一轮优先发给它。**对文本和 chat 请求默认开启**，所以已有流量无需改代码即受益。

而这次 changelog 补的是**另一半**——可观测性。以前你只知道亲和路由「应该」省钱，但不知道实际省了多少。新增的 Sessions 视图里，每行是一个会话，列出：跑这个会话的编码 agent（Claude Code / Codex / Cursor 等）、成本、模型、供应商，以及**每一轮里有多少输入是命中缓存的**。点开还能看到 cache hit rate、时长，以及一条「路径」——每轮用的模型、耗时、服务的 provider 以及**之前换过哪些 provider**。这条路径其实就是「缓存被自己打冷了几次」的现场记录。

## 技术架构拆解

### 核心设计决策

- **会话识别有优先级链，不依赖单一信号**：网关按顺序查 6 个来源，取第一个命中的——`providerOptions.gateway.sessionId`（或 chat/responses/messages 顶层 `session_id` 字段）→ `x-session-id` header → `x-session-affinity` header → OpenAI 的 `prompt_cache_key` → `x-claude-code-session-id`（Claude Code 自动带）→ 对话指纹。这意味着**存量客户端大多不用改**，光是 Claude Code 自带 header 就能被识别。
- **无 ID 时用对话指纹兜底**：对首个 system/developer 消息、首个非 system 消息、以及工具集合（name + description + schema）做 SHA-256，混入 team ID。设计细节很讲究：每条消息最多取前 4096 字符；后续 turn 不改变指纹；工具**顺序无关**（同一工具集换个排列仍是同一会话）；指纹按团队隔离，两家团队跑同一个 agent 不会撞车。
- **pin 只重排、不扩权**：亲和路由在过滤之后执行，**只把已允许的 provider 提到前面**，绝不新增被 `order` 排除或被合规/零数据保留策略过滤掉的 provider。`sessionAffinity: false` 可以完全退回原排序。
- **pin 会过期，且在缓存过期前一点**：每次成功请求续期；pin 在 provider 缓存失效前不久过期，避免把一个「其实已经冷了」的 pin 当成热缓存。provider 挂了照常切下一个；如果请求在 provider 接受后失败，**该 pin 被移除**，下一轮重新选。
- **区分「会话 pin」与「凭证 pin」**：对显式 session ID 和 Claude Code 会话，pin 会连带绑定到**具体凭证**（因为每个账号有自己的缓存）；而指纹会话**只 pin provider、不 pin 凭证**——否则大量互不相关的用户会挤到同一个账号上。同理，`prompt_cache_key` 被当作「共享前缀标签」处理，也只 pin provider。
- **BYOK 不被亲和打穿**：pin 只在同一凭证组内重排，永远不会把系统凭证插到 BYOK 凭证前面（或反之）。

### 与「无会话亲和」的关键差异

| 维度 | 无亲和 / 纯自动路由 | 开启 Session Affinity |
|------|------------------|----------------------|
| provider 选择 | 按 `order` / `sort`（延迟、成本） | pin 的 provider 优先，其余沿用原策略 |
| 第 N 轮 prompt 计费 | 换家即冷缓存，按全价计 | 留在热缓存上，前缀部分读取缓存价 |
| 缓存命中率可见性 | 无（只能看总账单） | 每会话 cache hit rate + 逐轮路径 |
| 成本归因粒度 | 请求 / 模型 | 会话 / 编码 agent |
| 容灾行为 | 故障即切换 | 故障仍切换，且失败清除 pin |
| 合规过滤 | 先过滤再路由 | 亲和生效于过滤之后，不越权 |

### 架构/信息流图

```
客户端 (Claude Code / Codex / Cursor / 自研)
   │  headers: x-session-id / x-claude-code-session-id / prompt_cache_key
   ▼
┌──────────────── AI Gateway ────────────────┐
│ 1. 识别会话                                │
│    sessionId > x-session-id > x-session-   │
│    affinity > prompt_cache_key > claude-id │
│    > SHA-256 对话指纹                      │
│                                            │
│ 2. 应用合规/order/sort 过滤                │
│                                            │
│ 3. 提升 pin（仅在已允许 provider 内部）    │
│    → 转发 x-session-affinity 给 provider   │
│                                            │
│ 4. 成功则续期 pin / 失败则清除 pin         │
└────────────────────────────────────────────┘
   │
   ├─→ Logs · Sessions 视图
   │     每行: agent | cost | models | providers
   │            | cached input 占比
   │     详情: cache hit rate | duration | turn 路径
   ▼
Provider A (缓存热)   Provider B (缓存冷，仅容灾)
```

## 实用评估

### 什么场景值得用

- **长会话编码 agent**：Claude Code / Codex 这类一跑几十轮的场景，前缀重复量极大。留在同一 provider 上，每个 turn 的输入大部分从缓存读——这是最直接的省钱路径，而且默认开启、零代码。
- **多 provider 容灾**：你为了可用性配了多个 provider，但每次故障切换都会把整段 prompt 重新算一遍。亲和 + 失败清 pin 的设计正好让「平时省钱、故障时仍然能切」。
- **成本归因**：以前老板问「Claude Code 一个月烧了多少、其中多少是重复计算」，你只能说个总数。现在能按会话、按 agent、按 provider 列出来，还能看到被自己路由打冷的会话路径。

### 什么场景不值得用

- **单 provider 直连**：没有跨 provider 抖动，等于没有缓存丢失问题，亲和是空转。
- **非文本请求**：embeddings、图像、realtime 会话**不在覆盖范围**（官方明确说明这些没有 prompt 可暖）。
- **自研路由且已有会话粘性**：收益主要是可观测性，不是路由本身。
- **会话边界模糊的批处理**：官方提示，用模板化开场（比如统一 `"Begin the task."`）启动的脚本会让**不同对话共享同一指纹**；大量相似对话应显式传 session ID，否则归并出来的会话统计会失真。

> TODO: 官方 changelog 未给出具体的缓存折扣比例与成本节省幅度（不同 provider 的缓存计费策略不同），本文不做数字外推。

### 迁移成本

- **开启亲和**：默认已开，`Session affinity runs by default on text and chat requests`，基本为零。
- **提升会话识别准确度**：只需在每次调用带上稳定 ID——SDK 侧设 `providerOptions.gateway.sessionId`，或 HTTP 侧统一发 `x-session-id`。改动集中在一处客户端封装，估计半天内可完成并验证。
- **注意示例缺口**：官方文档中「Set sessionId in providerOptions.gateway on each call」与 header 用法处的代码块在抓取结果里未渲染出正文内容（`> TODO: 代码示例待从文档页面原文核对`），落地时请以文档站原文为准，不要照抄二手转述。

## 对你的意义

对你这条 AI 应用线，这不是「又一个网关功能」，而是**把 agent 运行成本从请求账变成会话账**。

你的关注点一直是 Agent + UI、RAG 工具链、LLMOps 生态。这个更新恰好落在 LLMOps 里最容易被忽略的一格：**评估与成本的可观测性**。它给出的不只是一个开关，而是一套可以借鉴的设计模式——「会话识别优先级链 + 指纹兜底 + pin 跟随缓存生命周期 + 失败即清 pin + 只在已允许集合内重排」。这套东西你自己写路由层时可以直接借用，即便不用 Vercel。

判断：**如果你手上的 agent 走多 provider，立即试用（改动几乎为零）；如果目前单 provider 直连，观望但记住这套模式**。尤其值得关注的是「按编码 agent 归并会话」这个切面——它把 cost 归到了具体的 agent 产品上，这对做 agent 选型和预算分配的人是真信息，而不是仪表盘装饰。

## 关键代码/配置片段

以下来自官方文档与 changelog 的真实表述（不含未渲染的示例正文）：

```text
# 会话 ID 识别优先级（AI Gateway 按序取第一个命中的）
1. providerOptions.gateway.sessionId   (或 chat/responses/messages 顶层 session_id 字段)
2. x-session-id header
3. x-session-affinity header
4. prompt_cache_key
5. x-claude-code-session-id header
6. 对话指纹 (SHA-256)
```

```text
# 指纹算法要点（无 session ID 时）
hash 输入:
  - 首个 system/developer 消息的前 4096 字符
  - 首个非 system/developer 消息的前 4096 字符
  - 工具集合 (name + description + schema)，顺序无关
  - team ID（团队隔离）
稳定性: 后续 turn / 工具结果 / 新用户消息 不改变指纹
```

```json
// 保留原有 provider 排序，禁用亲和提升
{
  "sessionAffinity": false
}
```

```text
# 亲和与其它设置的交互（官方表格）
compliance/zero-data-retention : 先过滤；被过滤掉的 provider 不会被 pin 提升
order                          : pin 的 provider 排在 order 之前
sort                           : pin 的 provider 排在 sort 赢家之前
provider health                : 从不提升被判定为 down 的 provider
BYOK credentials               : pin 只在本凭证组内重排，不跨系统/BYOK 边界
```

---
[← Back to Deep Dives](./README.md)
