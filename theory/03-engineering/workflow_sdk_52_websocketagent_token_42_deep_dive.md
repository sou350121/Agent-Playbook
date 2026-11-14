---
auto_generated: true
generated_at: "2026-11-14T05:45:40Z"
source_url: "https://vercel.com/changelog/workflow-writes-now-use-websockets-on-vercel"
signal_type: "significant_update"
---
# Workflow SDK 5.2 把写入切换到 WebSocket：agent token 流提速 4.2 倍 (Workflow SDK 5.2: WebSocket Writes by Default)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-14
>
> **项目/工具**: Vercel Workflow SDK（npm 包 `workflow`）
> **链接**: https://vercel.com/changelog/workflow-writes-now-use-websockets-on-vercel
> **核心定位**: 持久化工作流运行时把「事件写入 + 流写入」从 HTTP 请求换成一条常驻 WebSocket，把长时运行里线性膨胀的写入开销压成近乎常数。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：升级到 `workflow@5.2.0` 即可，事件与流写入默认走 WebSocket，取代"每次写入一个 HTTP 请求"（流是每个写入组一个请求）；代码不用改。
- **現在值得用嗎**：值得——如果你的 workflow 里有 AI token 流式输出或上千步的长链，v5.2.0 的收益是量级级的；如果只是三个步骤的一次性脚本，收益接近噪音。
- **適合場景**：LLM 驱动的 agent 循环（每步都要回写事件）、多步 fan-out 后 join 的长工作流、需要把 token 流实时推给前端的 chat 产品。
- **不適合場景**：短工作流（<10 步）、不需要流式输出、以及非 Vercel World 的自托管世界（传输方式由世界实现决定）。
- **與 v4.8.12 核心差異**：1,020 步的运行里，第 1,001–1,020 步的步间开销从 1,748 ms 降到 70 ms（25×），整轮中位耗时从 21.0 min 降到 3.0 min。

## 是什么 / 解决什么问题

Vercel 的 Workflow SDK 是一个"持久化执行"（durable execution）框架：你用 `"use workflow"` 标注编排函数、用 `"use step"` 标注可重放副作用，运行时把每一步的入参、结果、状态写进事件日志，于是中断后可以恢复、可以重试、可以长期挂起等 hook。

这个模型有一个被忽略的成本结构问题：**每一次 step 的开始与结束都是一次写入，每一次 stream chunk 写入也是一次写入**。在 v5.2 之前，这些写入全部是一次 HTTP 请求（流则是按写入组打包成一个请求）。短工作流感觉不到，但 agent 工作流是天然的长链条——一个 AI agent 回应 2,593 个 chunk、跑上千步是常态，HTTP 请求的开销就开始主导总时长。

v5.2.0 的改动非常窄：**默认把事件写入与流写入改走 WebSocket**。队列处理器在每次投递时建立连接，之后这个 run 的所有写入复用这条连接。源码写法完全不变，`npm install workflow@latest` 之后就生效；已经在跑中的 run 会在它原来的部署上跑完。

值得注意的是官方给出的因果链不只是"少一些请求"：真正的收益来自"流跟得上 AI 输出的速度"这一性质。

## 技术架构拆解

### 核心设计决策

- **默认开启而非开关**：不提供"要不要用 WebSocket"的配置项做主决策，v5 起默认走 WebSocket。官方把它当作 v5 major 的一部分，4.x 用户需要按升级指南迁移。这是典型的"正确默认值"哲学——旧行为只是历史包袱。
- **写入路径不动，只动传输层**：`getWritable()` / `getWriter().write()` 的 API 完全没变。这意味着升级风险被压到最小：没有 API 面变化，只有传输实现变化。
- **按 run 复用连接**：队列处理器为每次投递打开连接。对长 run 而言，连接建立成本被摊薄到数千次写入上——这是"摊销"而非"消除"。
- **世界（World）实现可覆盖**：在 Vercel World 上，`WORKFLOW_STREAMS_TRANSPORT` 环境变量可以指定流写入的传输方式。也就是说这个默认值是"Vercel 托管世界"的策略选择，不是 SDK 的硬性绑定——自托管 World 的实现者需要自己处理。
- **在飞 run 不迁移**：升级部署只影响新 run。这是持久化执行框架的标准做法（事件日志与运行时版本绑定），也避免了升级期间的日志格式错配。

### 与前版/竞品的关键差异

官方发布的 v5.2.0 vs v4.8.12 基准（2026-10-08 测量，iad1 单区域、Vercel World、两版本同时运行共享平台）：

| 维度 | v4.8.12 | v5.2.0 |
|------|---------|--------|
| 5 步工作流到达第一步（p75） | 418 ms | 172 ms（2.4×） |
| 步间开销（5 步，p75） | 618 ms | 109 ms（5.7×） |
| 步间开销，第 1,001–1,020 步（p75） | 1,748 ms | 70 ms（25.0×） |
| 步间开销，第 101–120 步（p75） | 719 ms | 74 ms（9.7×） |
| 1,020 步整轮中位挂钟时间 | 21.0 min | 3.0 min（7.0×） |
| Agent 流 52.4 s 录制的完整送达中位时间 | 226.1 s | 53.5 s（4.2×） |
| Chunk 到达读者（p75） | 172 ms | 102 ms（1.7×） |
| 有 chunk 延迟超 1s 的运行数 | 10 次里 6 次 | 10 次里 0 次 |
| 64 分支 fan-out 首个分支启动（p75） | 478 ms | 360 ms（1.3×） |
| fan-out 最慢分支启动 / join（p75） | 972 ms / 464 ms | 996 ms / 448 ms（无变化） |
| Hook 恢复（p75） | 699 ms | 425 ms（1.6×） |

两个重要的读法：

**第一，长 run 的改善是超线性的，这才是本版本的真价值。** 短工作流改善 2–6×，但到第 1,001 步后是 25×——因为旧的 HTTP 路径的每步写入成本会随事件日志增长而上升（v4 从 622 ms 涨到 1,748 ms），而 WebSocket 路径基本是平的（110 ms → 70 ms）。换句话说，v5.2 不只是"更快"，而是**把步间开销从 O(日志长度) 变成近似 O(1)**。这是架构性变化，不是调优。

**第二，fan-out 基本没有改善。** 最慢分支启动 996 ms vs 972 ms，join 448 ms vs 464 ms，都在噪音范围内。原因不奇怪：fan-out 的瓶颈是并发启动 64 个分支时的排队与调度，不是写入次数。所以"WebSocket 让一切更快"是错的读法——它只改善写入密集的维度。

**第三，流的改善与其说是延迟，不如说是吞吐。** v4 的 writer 每秒只能处理约 12 个 chunk，导致 52.4 秒的录制要 226 秒才送达（4.3 倍慢放）；v5.2 每秒约 49 个 chunk，52.4 秒的录制 53.5 秒送达，接近实时。"4.2 倍"这个数字本质上是"从 4.3 倍慢放变成 1.02 倍实时"。

### 架构/信息流图

```
                    v4.x（HTTP 路径）
  step A ──HTTP POST─▶ 队列/事件日志 ──▶ step B
  stream  ──HTTP POST(按组)─▶ ...         每步/每组一次请求
  开销随日志增长而上升 → 第 1000 步后 1.7 s/步

                    v5.2（WebSocket 路径）
  队列投递 ──▶ 建立 WS 连接（每个 run 一次）
                  │
     step A ───────┼── event write ──▶ 事件日志
     step B ───────┤     （复用连接）
     token × N ────┘── stream write ──▶ 读者
  开销近似常数 → 第 1000 步后 70 ms/步
```

## 实用评估

### 什么场景值得用

- **LLM agent 循环**：每次工具调用都产生 step 开始/结束事件，20 轮以上就会进入 v4 的劣化区。这是本项目最主要的受益人群。
- **长链工作流（数百到上千步）**：官方数据里 1,020 步的中位耗时 21 min → 3 min，这不是"体感优化"，而是能否做某些事情的门槛变化（比如原本会被超时限制挡住的工作流）。
- **实时 token 流前端**：0/10 运行出现 >1s 的 chunk 延迟 vs 6/10，对 chat UI 的"卡顿感"有直接改善。
- **成本敏感**：官方明确说更少的 HTTP 请求"improves performance and reduces costs"，但没有公布价格差异数字 → `> TODO: 需要具体的计费口径与单价对比，官方未给出。`

### 什么场景不值得用

- **短工作流**：5 步的流程从 418 ms 到 172 ms，改善真实但绝对差只有 246 ms。为了这个做 major 版本升级不划算。
- **fan-out 密集型**：基准显示 fan-out 没有改善。如果你的痛点是最慢分支启动慢或 join 慢，升级解决不了。
- **非 Vercel 托管**：WebSocket 默认行为是 Vercel World 的策略（通过 `WORKFLOW_STREAMS_TRANSPORT` 可配）。自托管或第三方 World 的实际表现取决于该实现，不能直接套用这组数字。
- **单区域以外**：基准明确只在 iad1 单区域、单一 World 上测量，跨区域/多 World 的数字未知。

### 迁移成本

- **代码改动：0**（除非你的流式代码依赖了旧的 HTTP 写入时序假设）。
- **版本跨度：4.x → 5.x 是 major 版本**。官方指引 4.x 用户先读 upgrade guide（`workflow-sdk.dev/docs/whats-new`），因此真实成本集中在 major 版本的其他变更上，而不是这次的 WebSocket 改动。
- **在飞 run**：不需要处理，会在原部署上跑完；升级后新 run 才走新路径。
- **回退方式**：官方未在 changelog 中给出"关闭 WebSocket"的开关；Vercel World 上可用 `WORKFLOW_STREAMS_TRANSPORT` 调整流传输 → `> TODO: 事件写入是否可回退到 HTTP，文档未明确。`

## 对你的意义

如果你在用 Vercel Workflow 跑 agent 编排，这是一个"无脑升级"的版本——零代码改动，收益集中在你本来就最痛的两个地方（长 run 的步间开销、token 流吞吐）。**建议立即在 staging 试**，重点不是看它快多少，而是验证 v5 major 的其他破坏性变更对你的影响。

但更值得记下来的是这份基准本身的方法论：它把运行时拆成 TTFS、STSO、fan-out、resume、chunk trip time 五个独立时钟，并在 1–20 / 101–120 / 1,001–1,020 三个区间分别测步间开销。**任何持久化执行框架（Temporal、Inngest、Restate）的选型都应该问同一个问题：你们的步间开销随事件日志增长是平的还是线性的？** 这几乎决定了你的 agent 能不能跑到一千步以上。

如果不用 Vercel Workflow，这件事仍然有价值的推论是：**把持久化状态的每一次写入从"一次 RPC"变成"复用连接"，是长时 agent 运行时的通用优化点**。自建 agent 框架时，事件日志的写入路径值得优先设计成批量 + 常连接，而不是朴素的每步一请求。

**结论：立刻试用（有条件）**——前提是你已经在 Vercel Workflow 上跑长链 agent；否则记为"选型时必问的问题"，不是现在动手的事。

## 关键代码/配置片段

升级本身只有一条命令：

```bash
npm install workflow@latest
```

已有的流式代码不需要改动，burst 写入（如 AI token）会在 WebSocket 打开后批量发送：

```ts
import { getWritable } from "workflow";

async function streamChunks(chunks: string[]) {
  "use step";
  const writer = getWritable<string>().getWriter();
  for (const chunk of chunks) {
    await writer.write(chunk);
  }
  writer.releaseLock();
}

export async function streamingWorkflow(chunks: string[]) {
  "use workflow";
  await streamChunks(chunks);
}
```

在 Vercel World 上调整流写入传输方式：

```bash
WORKFLOW_STREAMS_TRANSPORT=...   # 取值见 workflow-sdk.dev/docs/configuration/worlds
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 运行时把长链 agent 的步间开销压到近似常数（25×）并让 token 流达到实时，说明基础设施层正在为"高频、长时、流式"的工作流负载做针对性优化——这是场景走向规模化生产的先行信号，而非实验性玩具的特征。 |

---
[← Back to Deep Dives](./README.md)
