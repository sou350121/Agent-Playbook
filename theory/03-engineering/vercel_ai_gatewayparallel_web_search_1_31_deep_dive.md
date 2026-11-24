---
auto_generated: true
generated_at: "2026-11-24T03:30:55Z"
source_url: "https://vercel.com/changelog/parallel-web-search-is-free-on-ai-gateway-and-eve-through-january-31"
signal_type: "blog_post"
---
# Vercel AI Gateway 把网络搜索变成「托管基础设施」 (When Web Search Becomes a Gateway Primitive)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-24
>
> **项目/工具**: Vercel AI Gateway — Parallel Web Search
> **链接**: https://vercel.com/changelog/parallel-web-search-is-free-on-ai-gateway-and-eve-through-january-31
> **核心定位**: 检索层从「每个 agent 自己接一家搜索 API」变成网关侧的统一内置工具，且 Parallel fast 模式在 2027-01-31 前免费

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AI Gateway 新增 `parallelSearch` 内置工具，任何模型都能用同一套检索能力；Parallel 同时成为 eve agent 的默认 web search。
- **現在值得用嗎**：看你是否已经把模型调用收敛到 AI Gateway。如果是——立刻用，fast 模式免费到 2027-01-31；如果不是——为一个搜索工具换网关，不值得。
- **適合場景**：AI SDK / eve 上跑的 agent、需要"多模型共用一套检索行为"的产品、想省掉自己维护搜索管道与 API key 轮转的团队。
- **不適合場景**：需要深度抓取全文或自建爬虫管线的场景（fast 模式只返回链接 + 短摘录）；对数据驻留 / 供应商有硬性本地化要求的团队。
- **與前版/競品核心差異**：以前 gateway 只是模型路由层，检索要么自己接 SDK、要么用各家 native search；现在检索成了 gateway 的一等公民，跨模型统一。

## 是什么 / 解决什么问题

Agent 的"能用"和"可信"之间隔着检索层。过去两年最常见的工程做法是：模型调用走一层网关，检索自己另接一家搜索 API（Perplexity / Exa / Tavily / Brave），然后在 prompt 里拼上下文。结果就是两套 key、两套计费、两套限流、两套失败重试逻辑，而且换模型时检索行为不一致。

Vercel AI Gateway 这次把 Parallel 的 web search 变成 gateway 自带工具：`gateway.tools.parallelSearch({ mode: 'fast' })`。按官方 changelog 的说法——「The tool works with any AI Gateway model, with no separate Parallel API key. Parallel finds relevant web pages and returns links with short excerpts. You can filter results by website or publication date.」

同时 Parallel fast 模式被设为 **eve**（Vercel 的 agent 产品）的默认搜索：eve 内置的 `web_search` 工具在模型经由 AI Gateway 服务时，会自动走 Parallel fast 模式。

商业动作也值得注意：**fast 模式到 2027 年 1 月 31 日免费**，且默认开启 Zero Data Retention（ZDR）。其他模式按标准价计费。这不是技术突破，但它明显是一次"用免费额度换标准位"的卡位——目标是让检索调用习惯沉淀在 gateway 上。

## 技术架构拆解

### 核心设计决策

- **工具进网关，而非进 SDK 客户端**：搜索被定义成 `gateway.tools.*`，与模型解耦。同一份 prompt 换 `openai/gpt-5.6-terra` 或 `zai/glm-5.3-flash`，检索行为不变。这解决了"换模型就得重新调检索参数"的老问题。
- **默认 ZDR**：官方明确 fast 模式默认关闭数据留存。对企业 agent 来说是硬门槛，先满足合规再谈功能。
- **检索供应商做成可插拔家族**：从网关文档看，跨模型可用的搜索工具已不止 Parallel，还包括 Perplexity、Exa、Tako、Browserbase、DeepSeek Search，另有 Anthropic / OpenAI / Google / SpaceXAI 的 native search。Parallel 是"默认位"，不是唯一选项。
- **分层检索模式**：Parallel 工具接受 `mode` 参数，文档示例列出 `'turbo' | 'fast' | 'basic' | 'advanced'`。免费只覆盖 fast —— 也就是说 Vercel 免费送的是"够用层"，把高质量层留在付费区。这是很克制的产品分层。
- **结果形态刻意保守**：返回"links with short excerpts"，不是全文。这是刻意的体积/延迟取舍——网关不希望把上下文预算吃在检索上。

### 与前版/竞品的关键差异

| 维度 | 自建检索管道（常见做法） | AI Gateway + Parallel |
|------|------------------------|----------------------|
| API Key | 搜索 & 模型各一套 | 只需 Gateway 凭据 |
| 跨模型一致性 | 换模型需重调检索参数 | 工具定义不变，行为一致 |
| 计费 | 两处对账 | 统一在 Gateway 账单（fast 模式当前免费） |
| 数据留存 | 取决于搜索供应商策略 | fast 模式默认 ZDR |
| 结果内容 | 自己决定抓全文与否 | links + short excerpts，全文需另接 fetch |
| 结果过滤 | 视供应商而定 | 支持按站点、发布日期过滤 |
| 供应商锁定 | 直接锁在搜索供应商 | 锁在 Gateway，但可在 Parallel/Exa/Tako 等间切换 |

注意最后一行——这既是优势也是新锁定：你把检索可替换性从"搜索供应商级"上移到了"网关级"。

### 架构/信息流图

```
  ┌──────────────┐
  │  AI SDK / eve │
  └──────┬───────┘
         │ generateText({ tools: { parallel_search } })
         ▼
  ┌──────────────────────────┐
  │     Vercel AI Gateway    │
  │  ┌────────────────────┐  │
  │  │ model routing      │  │──► OpenAI / Anthropic / ZAI / ...
  │  ├────────────────────┤  │
  │  │ tools.parallelSearch│──┼──► Parallel Search API (fast)
  │  ├────────────────────┤  │     ├─ 站点过滤
  │  │ other search tools │  │     └─ 发布日期过滤
  │  │ (Exa/Tako/Browserbase)│ │──► 各自后端
  │  └────────────────────┘  │
  │   ZDR 默认开启 (fast)     │
  └──────────────────────────┘
         │
         ▼
  links + short excerpts → 回到模型上下文
```

关键点：检索不再是模型的"外部依赖"，而是网关内部的同层能力。Agent 的作者只需要描述"我要查东西"，路由与合规由网关兜底。

## 实用评估

### 什么场景值得用

- **已经在用 AI SDK 的 agent**：一行工具注册即可接入，几乎没有迁移成本，且 fast 模式免费。
- **eve agent 用户**：什么都不用做。官方说明内置 `web_search` 在经 Gateway 服务的模型下自动走 Parallel fast。
- **多模型 A/B 的产品**：检索行为跨模型一致，benchmark 里少一个混淆变量。
- **合规敏感的企业 agent**：fast 模式默认 ZDR，比自行评估每家搜索供应商的数据政策轻得多。

### 什么场景不值得用

- **需要全文深读的检索**（论文精读、长文档比对）：只给 short excerpts，后续仍要自己做 fetch 与正文抽取。网关文档里虽然有 Browserbase Fetch / DeepSeek Fetch 用于"已知 URL 取正文"，但那是另一条链路。
- **需要搜索质量极致的场景**：免费的是 fast 层，官方示例里还存在 turbo / basic / advanced 等更高层模式，付费才有。如果你的产品卖点就是检索精度，别指望白嫖层。
- **数据必须境内或指定供应商**：网关是新增的一跳，链路更长，数据流经节点变多。
- **强依赖特定搜索能力的场景**：Parallel 支持按站点 / 发布日期过滤，但从 changelog 看并未承诺语义搜索、分面检索等高级特性。若你依赖 Exa 的 semantic / category 能力，应当显式切到 `exaSearch`。

### 迁移成本

小到可以忽略，前提是模型调用已经在 Gateway 上：

1. 在 tools 里注册 `gateway.tools.parallelSearch({ mode: 'fast' })`。
2. 删掉原来搜索供应商的 key 与重试逻辑。
3. 调整 prompt：以前可能期望检索工具返回正文，现在要接受"摘录 + 链接"，必要时追加一次取正文的步骤。

如果在自建网关或直连 OpenAI/Anthropic SDK，迁移成本就不是"改一行"，而是"换一层基础设施"，这时候只为一个搜索工具迁移不划算。

> TODO: 官方 changelog 未给出检索延迟、命中率或 fast 模式的速率限制数值，无法量化性能对比。

## 对你的意义

这条更新对"Agent + UI"方向的直接启发比技术细节更大：

- **接口设计信号**：把检索做成 `gateway.tools.*` 家族而非单个 SDK，是"能力标准化"的标准手法。你做 Agent 工具链时可以参考这个分层——工具声明在平台层、执行在供应商层、合规在路由层。
- **免费额度是侦察窗口**：到 2027-01-31 之前，fast 模式零成本。这段时间正好可以用来对比 Parallel fast 与自己现有检索方案在你的典型 query 上的表现差异，够用就留、不够用则切到 Exa/Tako 而不用换代码结构。
- **别被"默认"绑架**：Parallel 成为 eve 默认搜索，对 Vercel 生态用户是省事，但也意味着检索质量的上限被默认值框定。如果你的产品对检索质量敏感，显式指定模式比吃默认值更稳。

**建议**：如果你的 agent 已经在 AI Gateway 上跑，立即试用，把它当作当前检索方案的对照基线；如果没在 Gateway 上，跳过——这次更新的价值依附于"已经在网关里"这个前提。

## 关键代码/配置片段

官方 changelog 给出的接入方式（摘自 Vercel changelog 原文）：

```ts
import { gateway, generateText, stepCountIs } from 'ai';

const { text } = await generateText({
  model: 'openai/gpt-5.6-terra',
  prompt: 'What are the latest developments in AI this week?',
  tools: {
    parallel_search: gateway.tools.parallelSearch({ mode: 'fast' }),
  },
  stopWhen: stepCountIs(3),
});
```

Parallel Search 工具支持的 mode 取值（摘自 Vercel AI Gateway 模型页示例）：

```ts
gateway.tools.parallelSearch({
  mode: 'basic', // 'turbo' | 'fast' | 'basic' | 'advanced'
})
```

eve 侧无需额外配置：内置 `web_search` 工具在模型经 AI Gateway 服务时自动使用 Parallel fast。其他搜索配置见 eve 文档 built-in tools 的 `web_search` 一节。

---
[← Back to Deep Dives](./README.md)
