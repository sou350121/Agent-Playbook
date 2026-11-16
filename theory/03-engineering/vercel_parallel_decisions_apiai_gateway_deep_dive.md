---
auto_generated: true
generated_at: "2026-11-16T03:31:06Z"
source_url: "https://vercel.com/changelog/parallel-decisions-now-available-on-ai-gateway-for-free"
signal_type: "blog_post"
---
# Vercel AI Gateway 开放 Parallel Decisions：把「路由与护栏」从生成调用里拆出来 (Parallel Decisions on Vercel AI Gateway: Decisions as a First-Class Modality)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-16
>
> **项目/工具**: Vercel AI Gateway × Parallel（Parallel Decisions Fast 模型）
> **链接**: https://vercel.com/changelog/parallel-decisions-now-available-on-ai-gateway-for-free
> **核心定位**: 在网关层提供「类型化判断（Decision）」能力——一次请求对同一份状态并行回答布尔 / 选择 / 打分三类问题，带实时网页证据与引用，2026-11-23 前免费

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Vercel AI Gateway 接入 Parallel 的 Decisions 模型，模型名 `parallel/parallel-decisions-fast`；它不回自由文本，而是返回 0–1 概率、选项、序数评分，并附上实时网页来源。
- **現在值得用嗎**：值得一试——但有一个前提：你的判断是「对状态提问」型（分类 / 路由 / 资格校验 / 声明核查），而不是开放生成型。
- **適合場景**：Agent 前置于生成的**路由决策**、准入 / 合规**门控**、CRM 记录富化、报价与融资信息的**事实核查**、基于量表的**评分 rubric**。
- **不適合場景**：需要长篇解释或逐字生成的任务；需要「每个答案精确映射到特定来源」的高审计场景（官方明确说引用作用于整个请求，而非逐条答案）；对价格敏感且已过免费期的长期大批量调用。
- **與前版核心差異**：以前把「该不该做 / 选哪个」硬塞进 Chat Completions 用生成伪造成打分；现在是网关上一个**独立 modality**（`/v1/decisions`），且多个问题共享同一次检索与上下文。

## 是什么 / 解决什么问题

Agent 工程里有一类调用长期被「借位」处理：**判断**。典型问题是——

- 这条线索该分给哪个销售团队？
- 这个请求是否触碰了策略边界？
- 这个客户是否符合优惠 / 资格条件？
- 这份声明里的数字，在今天的公开来源上还成立吗？

过去这些通常用一次 Chat Completion「让它输出 JSON」来凑：你在 prompt 里写清规则、要求返回 `{"choice": "billing"}`，然后自己解析。问题有三个：**成本**（为一个分类花掉一次完整生成的钱）、**延迟**（多轮往返，串行判断）、**可靠性**（模型可能输出解释、可能格式漂移、可能把「评分」写成一段议论文）。

Vercel 这次的做法是把 Decision 提升为 AI Gateway 的一等公民（官方文档原话：*"Decision models return choices, scores, and boolean probabilities instead of free-form text"*），并明确它与生成接口**互不兼容**：

> *"They are not supported through Chat Completions, Responses, or the Anthropic-compatible or Cohere-compatible endpoints."*

同时把此前叫「evaluation models」的能力统一改名为 Decision——`experimental_evaluate` 与 `gateway.evaluationModel()` 作为**已弃用别名**保留，请求与响应结构不变。这一改名本身就是信号：**评估/判断 与 生成 是两种不同的推理原语**，不该混在同一组端点里。

本次上架的具体模型是 Parallel 的 `parallel-decisions-fast`，它做的是「联网搜索 + 类型化回答」：针对公司、产品、政策等会变化的信息提问，返回概率与引用证据（来源 URL、可选标题、证据摘录）。**免费窗口到 2026-11-23**，无需单独的 Parallel 账号。

## 技术架构拆解

### 核心设计决策

- **一套状态、多个问题、一次往返**：官方文档说 *"Several questions can be answered in parallel within a single request, against the same state"*，并且不同题型可以共享同一个 state。这是整篇公告里最实的工程收益——把 N 次串行判断压成一次调用，检索与上下文只付一次。
- **三种强类型题型**（不是自由 JSON schema）：
  - `predicate`（原 boolean）：返回 0–1 的 yes 概率，用 criteria 定义 true/false 的含义；
  - `choice`：从你定义的命名选项里选一个，同时返回每个选项的概率；
  - `score`：沿有序量表打分（至少两个标签，从低到高），返回内插分数 + 每一档的概率。
- **state 直接接受结构化对象/数组**，不必自己序列化成字符串（`ai 7.0.133+` 起数组被解释为有序 parts，传 JSON 数组需包一层 `{ messages }` 或放进 `json` part——这是容易踩的坑）。
- **显式弃用路径**：`/v1/evaluate` 仍然可用但已弃用，新集成走 `/v1/decisions`；旧 `TypeSafe` 客户端只需把 base URL 指向 `https://ai-gateway.vercel.sh/typesafe`，**无需重写请求**。
- **Decision Fallbacks（需显式开启）**：当 Choice/Score 置信度低、Boolean 概率落进不确定带、或复合条件命中时，用另一个模型**顺序重跑一次**。代价明确写在文档里：两阶段都计费，延迟相加。
- **引用粒度诚实**：*"They apply to the whole request, rather than mapping individual sources to each answer."* 这是必须知道的设计限制。

### 与前版/竞品的关键差异

| 维度 | Chat Completions 假装打分（前版做法） | AI Gateway Decision（现在） |
|------|----------------------------------|---------------------------|
| 输出契约 | 自由文本 + 你写的 JSON 约束 | 强类型：概率 / 选项+分布 / 序数分数 |
| 多问题 | 串行多次调用 | 同 state 一次请求并行回答 |
| 端点 | `/v1/chat/completions` | `/v1/decisions`（独立 modality，互不兼容） |
| 置信度 | 无（要自己二次判断） | 布尔给概率，choice/score 给每档概率 |
| 低置信兜底 | 自己写重试逻辑 | opt-in Decision Fallbacks，一次成功重跑 |
| 观测 | 混在普通调用里 | 进入 Gateway logs / spend budgets，与其他模型请求同口径 |
| 外部现实 | 依赖模型知识截止 | Parallel 模型联网检索，带 URL + 摘录 |

### 架构/信息流图

```
应用状态 (state: string | object | parts[])
        │
        ▼
POST /v1/decisions   (或 AI SDK: gateway.decisionModel(...) / experimental_decide)
   questions: [
     { name: "refund", type: "predicate", criteria: {true:..., false:...} },
     { name: "tier",   type: "choice",    choices: [billing, tech, other] },
     { name: "risk",   type: "score",     levels: [Low, Medium, High] }
   ]
        │  ← 一次检索 / 一次共享上下文
        ▼
   Gateway 路由 ──► parallel/parallel-decisions-fast
        │                │
        │                ├─ 联网检索（公司/产品/政策等变化信息）
        │                ├─ 返回: 概率 / 选项 / 分数
        │                └─ citations: [url, title?, excerpt]
        │
        ├─(可选) Decision Fallbacks: 低置信 → 另一模型重跑一次（两段计费）
        ▼
answers[] + 引用 + usage + Gateway 路由/成本元数据
        │
        ▼
应用侧策略（阈值 / 人工复核 / 写入 trace / A-B 实验）
```

## 实用评估

### 什么场景值得用

- **Agent 前置门控**：在一个生成请求之前，先并发跑「是否越界 / 该用哪个模型 / 是否命中某策略」三个 predicate，只有通过的请求才进入昂贵的生成。文档口径下这是数量级差别而不是百分比差别——一次 0–1 打分远轻于一次完整生成。
- **CRM 富化与线索路由**：把一条线索记录整体作为 state，同时问「行业分类（choice）」「是否企业级（predicate）」「意向强度（score）」，一次往返拿全。
- **声明/信息核查**：因为接入的是 Parallel 的联网检索模型，特别适合「这条报价/这条政策/这家公司现在还这样吗」这类**会过期**的问题——返回引用 URL 可直接进审计日志。
- **已有 TypeSafe 或 OpenAI 兼容栈的团队**：TypeSafe 换 base URL 即可；其他语言用 OpenAI SDK 指向 `https://ai-gateway.vercel.sh/v1` 打 `/v1/decisions`。

### 什么场景不值得用

- **需要解释的任务**。Decision 刻意不返回自由文本。如果你的下游需要「为什么这么判」的长文，你仍然得再发起生成调用，判断层收益只剩一半。
- **强逐条溯源审计**。引用作用于整个请求，不是每条答案各自的证据链。金融/医疗合规里要求「这句话对应这个文件第 N 段」的场景，这套设计不够。
- **只在免费期用**。2026-11-23 后按模型每 token 计费（文档提到**部分 decision 模型只按输入 token 计价**，需查模型页确认）；加上 fallback 会双倍计费 + 双段延迟，大批量调用前务必先算。
- **把概率当真理**。文档反复强调要先用代表性案例测「模型答案」和「应用动作」两件事、在试点里量化错误动作与人工复核量，再开自动执行。它不是确定性规则引擎。

### 迁移成本

- **从自建 JSON 打分迁移**：主要工作量不在 API，而在**阈值策略与评测集**——把 prompt 里的规则翻译成 criteria，把解析逻辑换成读 `answers[].probability`，再补一层「落在不确定带就转人工」。
- **接口层面**：AI SDK 需要 `ai 7.0.128+`（`experimental_decide`，更早叫 `experimental_evaluate`）；老 `/v1/evaluate` 调用按文档做字段改名即可（`state → input`、`questions` 对象 → 数组 + `name`、`boolean → predicate`、`criteria → choices/levels`）。
- **粗略估计**：一个中等复杂的判断型 Agent，改造加评测约 1–3 人日（不含业务阈值调参）。真正的成本是重建评测集。

## 对你的意义

如果你在搭 Agent 的路由层或安全护栏，这是一条明确的方向性信号：**判断正在从「生成的一种伪装」变成独立的基础设施原语**。短期建议——**现在就试，但只在非关键的旁路上试**：

1. 拿一个你已经用 JSON prompt 在做的分类点（例如「这条工具动态属于 Agent 框架 / UI 工具链 / RAG / LLMOps 哪一类」），改成 `choice` + `score` 双问题，对比两者的延迟、成本和与人工标注的一致率；
2. 把 `probability` 写进 trace，先只在概率 > 0.85 时自动执行，其余转人工——这是文档推荐的灰度方式；
3. **先确认免费期之后的价格再决定是否进生产**，别把免费当默认。

长期看，真正值得关注的是 Parallel 模型那条「联网检索 + 类型化回答」的组合：如果它能把「事实会不会过期」作为判断的一等输入，那么你手上那些依赖模型截止知识的核查类任务，就有了一个比「让 LLM 回忆 + 我再核一遍」更干净的替代方案。这一点目前只有厂商口径，缺少独立复现，标为 **待验证**。

## 关键代码/配置片段

以下均摘自官方 changelog 与文档（2026-11-13 公告）：

```
模型名: parallel/parallel-decisions-fast
免费期: 至 2026-11-23
端点:   POST /v1/decisions          （新）
        POST /v1/evaluate           （已弃用，仍可用）
        https://ai-gateway.vercel.sh/typesafe   （TypeSafe 兼容）
SDK:    AI SDK ai >= 7.0.128（experimental_decide）
```

题型对照（官方弃用映射表，节选）：

```
旧 /v1/evaluate              →  新 /v1/decisions
state: <任何 JSON>           →  state: string | object | parts[]
questions: { refund: {...} } →  questions: [{ name: 'refund', ... }]
boolean                      →  predicate
boolean criteria {true,false}→  predicate（criteria 写进 instructions）
choice criteria {billing: '…'} → choice choices [{value:'billing',description:'…'}]
score criteria ['Low','High']  → score levels [{label:'Low'},{label:'High'}]
answers: 以问题 ID 为键的对象   →  answers: 按问题顺序的数组（含 name）
providerMetadata             →  provider_metadata
```

启用 Decision Fallbacks 的位置（文档原文所述）：

```
- AI SDK decide:                     providerOptions.gateway.models
- HTTP:                              POST /v1/decisions 的 providerOptions.gateway.models
- TypeSafe-compatible API:           同上
触发条件: Choice/Score 低置信度、Boolean 概率落在不确定带、或复合条件命中
限制:    仅支持一个成功响应的 fallback 阶段；两段顺序执行，两段都计费
```

> TODO: 免费期后 `parallel-decisions-fast` 的具体单价与是否「仅按输入 token 计费」未在本次抓取的材料中给出，需查 AI Gateway 模型页确认后再写进成本模型。

---
[← Back to Deep Dives](./README.md)
