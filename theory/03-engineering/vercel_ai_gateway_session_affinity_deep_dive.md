---
auto_generated: true
generated_at: "2026-10-19T06:45:48Z"
source_url: "https://vercel.com/changelog/ai-gateway-logs-now-show-session-affinity"
signal_type: "blog_post"
---
# 会话粘滞进入可观测时代：Vercel AI Gateway 会话视图 (Session Affinity Becomes Observable in Vercel AI Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-19
>
> **项目/工具**: Vercel AI Gateway（Logs / Sessions view）
> **链接**: https://vercel.com/changelog/ai-gateway-logs-now-show-session-affinity
> **核心定位**: 给「多轮 agent 会话被路由到哪个 provider、缓存命中多少」装上第一块仪表盘——把原本发生在网关内部的 session affinity 变成可逐轮检视的日志。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AI Gateway 的日志中新增 Sessions 视图，把同一段对话的多轮请求聚合为一个 session，并显示 session affinity 把每一轮路由到了哪个 provider、缓存命中率多少、路径如何切换。
- **现在值得用吗**：看你是否已经在用 AI Gateway 且按 token 付费——如果是，这是「零迁移成本的成本排查工具」；如果没在用 Gateway，不值得为它单独接入。
- **适合场景**：多轮 coding agent（Claude Code / Codex / Cursor 等）成本对账、排查「为什么缓存命中率掉了」、定位 provider 中途切换导致的延迟尖峰。
- **不适合场景**：单轮调用为主的场景（单轮 session 默认被隐藏）、需要细粒度 trace/span 级调试的团队（这只是日志聚合视图，不是分布式追踪）。
- **与典型请求日志的核心差异**：以前日志是按「请求」排列的平面列表，现在按「会话」聚合，并显式标出 provider 路径与跨轮缓存。

## 是什么 / 解决什么问题

Agent 应用的成本与延迟结构，在过去一年里发生了根本变化：单次请求只要几秒、几千 token；一段 coding agent 会话可能有几十上百轮，每轮都把整个上下文重新发一遍。真正决定账单的，不是单次调用单价，而是**这些轮次之间有多少被缓存、又有多少被 cache miss 重算**。

而这恰恰是最难看见的地方。当 AI Gateway 开启 session affinity（默认对 text/chat 请求生效）后，每一轮都会被送往服务上一轮的同一个 provider，好让该 provider 的 prompt cache 命中。但在此之前，用户在日志里只能看到一串按时间排序的请求：不知道哪些请求属于同一段对话、中间是否换过 provider、缓存到底在哪个节点断了。

Vercel 这次 changelog 的改动就是补上这个洞：AI Gateway logs 新增 **Sessions 视图**，把请求按会话分组，并显示 session affinity 如何路由每一轮。

官方描述的核心能力（来自 Vercel changelog）：

- 每一行显示运行该会话的 **coding agent 或应用**（如 Claude Code、Codex、Cursor），以及成本、模型、provider，和"输入中有多少在每一轮里被缓存"；
- 打开一个 session 可以看到 **cache hit rate、duration、path**；
- **path** 逐轮列出 model 与时序，并标明当前服务该会话的 provider，以及之前服务过的其他 provider；
- 可按 turns、client、model、provider、认证方式、成本过滤；单轮 session 在清除最小轮数过滤前默认隐藏。

## 技术架构拆解

### 核心设计决策

- **以 session 为主键而非 request**：日志的一级对象从「请求」变成「会话」。这不是 UI 花活，而是把计费与性能的真实单位对齐——agent 的成本单位天然是会话。
- **显式暴露 provider path**：官方原文："The path lists each turn with its model and timing, and names the provider serving the session along with any earlier ones." 中途换 provider 是缓存断崖的直接原因，把它写进路径里，等于把问题根因直接摆在用户面前。
- **session 归组双通道**：可以自己在每个请求的 `providerOptions.gateway` 里传相同 `sessionId`，或使用相同 `x-session-id` header；没有提供时，网关用「对话开头内容的指纹」自动归组，显示为 fingerprinted sessions。这意味着**默认就有数据**，但显式传 ID 才可靠。
- **默认开启 affinity**：text 和 chat 请求默认启用 session affinity，用户不需要 opt-in 才能享受缓存，但这也意味着"什么时候被路由走了"必须可观测——这正是本次更新的另一半。

### 与传统请求日志的差异

| 维度 | 传统请求日志 | AI Gateway Sessions 视图 |
|------|------------|------------------------|
| 一级对象 | 单个 request | 整个 conversation session |
| 归组方式 | 无 | sessionId / x-session-id / 对话指纹 |
| 路由可见性 | 只能逐条看 provider 字段 | 显式展示逐轮 provider path 与切换点 |
| 缓存可见性 | 单请求 cache token 数 | 跨轮 cache hit rate + duration |
| 客户端归因 | 需自行推断 | 直接标注 Claude Code / Codex / Cursor 等 |
| 单轮请求 | 同等展示 | 默认隐藏（可调整最小轮数） |

### 信息流图

```
Client (Claude Code / Codex / Cursor / 自建 app)
        │  每轮请求携带 sessionId 或 x-session-id
        ▼
┌──────────────────────────────────────────────┐
│ Vercel AI Gateway                            │
│                                              │
│  Session Grouping                            │
│   ├─ 显式 sessionId / x-session-id           │
│   └─ 无 ID → 对话开头指纹 → fingerprinted     │
│                                              │
│  Session Affinity（text/chat 默认开启）       │
│   └─ 第 N 轮 → 送往第 N-1 轮的同一 provider   │
│                       （该 provider 已有大部分  │
│                        prompt 在 cache 中）   │
│                                              │
│  Sessions View                               │
│   ├─ turn 1  [provider A] model, timing      │
│   ├─ turn 2  [provider A] cached %↑          │
│   └─ turn 3  [provider B] ← 切换点，cache ↓  │
└──────────────────────────────────────────────┘
        │
        ▼
成本对账 / 缓存回归排查 / provider 切换归因
```

## 实用评估

### 什么场景值得用

1. **agent 成本上账**：官方原话是每行显示「成本、模型、provider，以及每一轮输入中有多少被缓存」。对按 token 付费的团队来说，这比在账单页做减法靠谱得多——可以直接回答「这段会话为什么贵了 3 倍」。
2. **缓存回归排查**：如果你改了 prompt 前缀（例如把动态时间戳塞进 system prompt），缓存会整段失效。Sessions 视图里的 cache hit rate + per-turn path 可以让这类回归在成本暴涨前就被抓到。
3. **provider 路由归因**：session affinity 虽然默认开启，但一旦出现 failover 或多 provider 并行，会话就可能跨 provider。path 字段直接列出「谁服务了这一段、之前是谁」，这正是排查延迟尖峰的第一步。

### 什么场景不值得用

- **单轮为主的调用**：Sessions 视图默认隐藏单轮 session，说明其设计重心就是多轮 agent。短问答、批处理类任务基本拿不到额外信息。
- **需要 span 级调试**：这是日志聚合视图，不是 OpenTelemetry 那种分布式追踪。想看单次请求内部（检索、工具调用、模型调用的时序分解）还得自己埋点。
- **不用 AI Gateway 的团队**：这是托管网关的附加能力，自建网关（如 LiteLLM 自托管）需要自己做等价物。
- **数据合规要求日志不外流**：会话级日志意味着完整对话路径会进入 Vercel 侧，需先确认数据驻留策略。

### 迁移成本

- 已经用 AI Gateway：**零**。视图是日志页的新 tab，无需改代码即可看到按指纹分组的会话。
- 想获得可靠的归组：在每个请求里传 `sessionId` 或 `x-session-id` header。用 Vercel AI SDK 的话是 `providerOptions.gateway.sessionId`；自建 app 则是加一个 header，改动约几十行。
- 从其他网关迁移：属于独立话题，本次更新本身不构成迁移理由。

## 关键代码/配置片段

显式指定 session 组的两种方式（来自 Vercel changelog 原文描述）：

```http
# 方式一：请求头
x-session-id: <your-conversation-id>
```

```ts
// 方式二：AI SDK providerOptions
const result = await generateText({
  model: provider('anthropic/claude-...'),
  prompt,
  providerOptions: {
    gateway: {
      sessionId: conversationId, // 同一对话每一轮传同一个值
    },
  },
});
```

> TODO: providerOptions.gateway 的完整类型定义与支持的字段（如是否可同时传 provider 偏好）以上述 changelog 描述为准，具体 SDK 版本签名建议对照 `@ai-sdk/gateway` 当前版本 TypeScript 声明核实。

访问日志视图的入口（changelog 给出的链接形态）：
`AI Gateway → Logs → groupBy=sessions`，可叠加 turns / client / model / provider / auth / cost 过滤。

## 对你的意义

这条更新本身很小——一个日志视图。但它揭示的工程信号不小：**「缓存命中率」正在从模型侧的营销指标，变成应用侧的运维指标**。

对 Ken 的 AI 应用线，有三个直接含义：

1. **成本模型的单位要改**。团队里讨论 agent 成本时，如果还在用「每百万 token 多少钱」比较，会系统性低估多轮会话的开销差异。真正该比的是「每段会话的 cache-adjusted 成本」。这个视图给了现成的对照口径。
2. **prompt 结构的稳定性开始有观测价值**。凡是把时间戳、随机 ID、用户临时数据塞进 system prompt 前缀的做法，都会在 Sessions 视图里留下「cache hit rate 断崖」。这可以作为一条 prompt 规范去反推。
3. **跨领域连接点**：VLA 团队做 agent 后训练时，同样面对「长会话采样 → 成本爆炸」的问题。会话级缓存观测的思路（按会话聚合、把 provider 切换显式化）对自建推理队列同样有参考价值——即便你不用 Vercel。

建议：**观望但立刻用现有数据看一眼**。如果你已经在用 AI Gateway 跑 coding agent，花十分钟打开 Sessions 视图，按 cost 排序看 top 5 会话的 path，多半能发现一两个缓存断点。没有在用 Gateway 的话，不值得为此接入——但「会话级缓存命中率」这个指标应该单独纳入你的 agent 评估指标。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 网关开始把「会话级成本与缓存」作为一等公民暴露，说明多轮 agent 会话已成为主流工作负载形态，而非边角用例。 |

---
[← Back to Deep Dives](./README.md)
