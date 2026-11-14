---
auto_generated: true
generated_at: "2026-11-14T06:45:45Z"
source_url: "https://vercel.com/changelog/workflow-writes-now-use-websockets-on-vercel"
signal_type: "significant_update"
---
# Workflow SDK 5.2：事件与流写入默认改走 WebSocket，agent token 流快 4.2 倍 (Workflow SDK 5.2 Moves Event and Stream Writes onto WebSockets)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-14
>
> **项目/工具**: Vercel Workflow SDK (`workflow` npm 包)
> **链接**: https://vercel.com/changelog/workflow-writes-now-use-websockets-on-vercel
> **核心定位**: 持久化工作流运行时的传输层重写——把"每次写入一个 HTTP 请求"换成一条 WebSocket，让 streaming agent 的输出不再被 HTTP 往返拖成慢动作。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Workflow SDK 把事件写入（step 开始/完成）和流写入（`getWritable()` 的 chunk）默认改走 WebSocket，升级到 `workflow@5.2.0` 即可，业务代码零改动。
- **現在值得用嗎**：**是**——只要你用 Workflow SDK 跑 AI token streaming，或单条 workflow 有上百个 step。
- **適合場景**：AI agent token 流式输出、多步骤长跑（100+ steps）、批量 chunk 写入的下游消费。
- **不適合場景**：短小的 3-5 步 serverless 任务——收益存在但绝对值只有几十到几百毫秒；自托管 World 未实现 batch API / 自定义存储的团队收益会打折。
- **與 v4.8.12 核心差異**：不只是"变快"，而是 v5 整体把"每次进展都回到队列"的模型改成"单次调用内联执行多个 step"，WebSocket 是这条路线上的最后一公里。

## 是什么 / 解决什么问题

Workflow SDK 是一个"带持久化 event log 的 workflow 运行时"：你写 `"use workflow"` / `"use step"`，运行时负责把每个 step 的输入输出写进事件日志，崩溃后从日志重放恢复。这个模型的代价在 v4 里非常直接——**每推进一次、每写一段流，就是一次 HTTP 往返**。v4 的事件推进被大量委托给队列：执行一个 step，交还队列，再由一次新的 invocation 捡起下一个 step。

对普通后台任务这还能接受。但一旦工作负载变成 **AI agent 的 token stream**，问题立刻显现：官方 benchmark 里，一段 2,593 个 chunk、录制时长 52.4 秒的 agent 响应，在 v4.8.12 上要 **226.1 秒**才到达 reader——writer step 大约每秒只能处理 12 个 chunk，比真实生成速度慢 4 倍多。

5.2.0 的改动本身很小：event write 和 stream write 默认走 WebSocket，取代"每次写入一个 HTTP 请求 / 每组写入一个 HTTP 请求"。但它是 v5 一系列结构优化里的最后一环，所以联合效果远大于单点改动。

## 技术架构拆解

### 核心设计决策

- **WebSocket 而不是 batch HTTP**：多个 chunk 在连接打开后一次性走长连接，队首阻塞从"每个 chunk"变成"每个连接"。官方说队列处理器会为每次投递打开连接（"The queue handler opens the connection for every delivery"），意味着连接不是全局共享池，而是 per-delivery——换来的是不必在写入时做连接管理。
- **零 API 变更**：`getWritable().getWriter()` 用法完全不变。这是刻意选择——传输层可替换，用户不用改代码。
- **默认开启、旧 run 不受影响**：部署升级后**新**的 run 走 WebSocket；进行中的 run 在自己启动的部署上跑完。这是典型的"按部署切面"的 rollout 策略。
- **v5 的内联执行模型**：一次 invocation 内联执行多个 step（并行），只在等 hook、等 wait、或接近函数超时时才回队列。这让 step-to-step 开销从"随 event log 增长"变成"基本平坦"——1020 步的 run，v4 在 1,001–1,020 步区间还有 1,748 ms 间隔，v5.2.0 只要 70 ms。
- **持续性优化叠加**：step 创建折叠进 step 执行、replay 不再下载 step 输入（去掉随 run 长度二次增长的那部分）、hook resume 从两次往返变一次、suspend 的写入合并成一次 durable write、并发写入者不再抢日志位置、payload 压缩后再加密（AI token 流平均小约 80%）。

### 与前版/竞品的关键差异

| 维度 | v4.8.12 | v5.2.0 |
|------|---------|--------|
| 事件/流写入传输 | 每次写入（或每组）一个 HTTP 请求 | 默认单条 WebSocket |
| Agent 流（52.4s 录制）端到端 | 226.1 s（中位） | 53.5 s（中位），4.2× 快 |
| chunk 写入吞吐 | ~12 chunks/s | ~49 chunks/s |
| chunk trip time (p75) | 172 ms | 102 ms |
| 10 次 run 中有 chunk 延迟 >1s | 6 / 10 | 0 / 10 |
| 5 步 workflow TTFS (p75) | 418 ms | 172 ms |
| step-to-step (p75) | 618 ms | 109 ms |
| 1,020 步 run 的整体中位耗时 | 21.0 min | 3.0 min |
| 1,001–1,020 步的 step 间隔 (p75) | 1,748 ms | 70 ms |
| hook resume (p75) | 699 ms | 425 ms |
| 64 路 fan-out 首分支 (p75) | 478 ms | 360 ms |
| fan-out 的 join (p75) | 464 ms | 448 ms（基本无变化） |
| 计算成本（多小 step workflow） | — | 官方称最高省 80% |
| 存储成本 | — | 官方称最高省 70% |

数据来源：Vercel changelog 与 workflow-sdk.dev/docs/performance（v5.2.0 vs v4.8.12，2026-10-08 在 iad1、Vercel World 实测）。

值得点出的两个"没变"：**fan-out 的最慢分支启动时间（972 ms → 996 ms）和 join（464 → 448 ms）都没有改善**。也就是说 v5 优化的是"调用内推进"和"写入传输"，而不是"一次性排空大量并行分支"的调度——如果你的瓶颈是 64 路并行同时打满队列，这一版没有帮到你。

### 架构/信息流图

```
v4.x：每次进展都回队列
  invocation ──step 完成──► 队列 ──► 新 invocation ──step 完成──► 队列 …
      │每个 step_start / step_end / 每个 chunk 各一次 HTTP 写入
      ▼
   [ API / event log ]  ← O(surface) 次往返

v5.2：内联推进 + WebSocket 写入
  invocation ──[ 内联执行 step1..stepN（并行）]──┐
      │                                          │ 仅在 wait / hook / 超时 时回队列
      │  step_start / step_end  ┐
      │  stream chunks          ├─► 单条 WebSocket ─► [ API / event log ]
      │  （压缩后再加密）        ┘
      ▼
   VM 跨内联 step 存活：下一次迭代只追加新事件，不重建 sandbox、不重放全量日志
```

## 实用评估

### 什么场景值得用

- **AI agent 流式输出**：这是本次改动的靶心。v4 上 writer 每秒约 12 chunk 的瓶颈意味着"生成 52 秒、传输 226 秒"——用户看到的打字机效果其实是回放。v5.2.0 把端到端压到 53.5 秒，基本等于生成速度本身。
- **长 workflow**：step-to-step 开销不随 event log 增长，是 v4 最危险的非线性问题（越跑越慢）。1,020 步从 21 分钟降到 3 分钟，量级差别。
- **大量小 step 的组合式 pipeline**：官方称在同等工作负载下计算成本最高省 80%、存储最高省 70%，原因就是不再每个 step 来回打一次 API。
- **需要人审中断的 agent**：hook resume 的 p75 从 699 ms 降到 425 ms，等待审批的交互感会明显更紧凑。

### 什么场景不值得用

- **只有 3-5 步的短任务**：绝对收益是百毫秒级。TTFS 从 418 → 172 ms 对用户几乎不可感知，为它做一次大版本升级不划算。
- **自托管 / 第三方 World**：多项优化都是**条件开启**的——batch write 需要 World 实现 batch API，replay 跳过 step 输入需要 `resolveData: 'skip-step-inputs'`，位置预分配需要新 spec。官方也明说"视情况而定，self-hosted 或第三方 World 也可能看到类似收益"，即**不保证**。
- **瓶颈在 fan-out 调度**：上表已显示 64 路并行的最慢分支与 join 没有改善。
- **刚上 v4、运行稳定、不着急**：v4 仍在接收稳定性修复（可装 `workflow@4`，文档在 `/v4/docs`），升级到 v5 是 major release，有迁移成本。
- **平台绑定风险**：benchmark 全在 Vercel 的 iad1、Vercel World，其他区域和其他 World 数字会不同——这是官方自己在方法论里写明的限制。

### 迁移成本

- 纯升级：`npm install workflow@latest`，流式代码原样可用。
- 从 4.x 到 5.x 是 **major release**，官方提供了迁移 skill：
  ```bash
  npx skills add https://github.com/vercel/workflow --skill migrating-workflow-v4-to-v5
  ```
- 官方建议"安装迁移 skill，然后让你的 agent 把 v4 应用迁到 v5"——这个措辞本身就是信号：v5 的迁移对他们自己的 agent 生态是充分前置条件。
- 不需要配置；`WORKFLOW_STREAMS_TRANSPORT` 可以覆盖流写入传输方式（在 Vercel World 上）。
- 建议先在流式输出路径做灰度：先升到 5.2.0 观察 chunk 延迟指标，再考虑是否开启 `WORKFLOW_SPEC_VERSION=6` 等运行时开关。

## 对你的意义

如果你在做 Agent + UI 方向的产品，（a）**这是"流式体验"从 demo 到能用的分界线**——v4 上 4.2 倍的传输滞后意味着你看到的"流式"用户端体验其实被基础设施限速了；（b）**event sourcing 型 workfow 的非线性开销**是个必须提前检查的坑：任何"带持久化日志 + 每步写日志"的架构都会遇到 v4 这种 O(log) 恶化，v5 的"内联执行 + delta 追加"是值得抄的设计。

具体建议：**如果你已在 Vercel Workflows 上跑 streaming agent，立即升级；如果只在做原型或短任务，等下一次需要长跑再升。** 不要为了 benchmark 数字升级一次 major version。

另外注意一个更宏观的信号：这次改动里默认开启的传输层变化，实质是"AI agent 的工作负载在倒逼 workflow 运行时重新设计传输层"。WebSocket 已经在这个场景胜过 HTTP+队列——这是 agent 基础设施正在成型的证据之一。

## 关键代码/配置片段

升级（changelog 原文）：

```bash
npm install workflow@latest
```

流式写入代码无需改动——一个写 burst chunk 的 step，在 WebSocket 打开后一次性发送（changelog 原文示例）：

```typescript
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

可调开关（来自官方文档，非 changelog 原文）：

```bash
# 在 Vercel World 上覆盖流写入传输方式
WORKFLOW_STREAMS_TRANSPORT=<value>

# 让新 run 使用上一版日志位置分配方案
WORKFLOW_SPEC_VERSION=6
```

> TODO: `WORKFLOW_STREAMS_TRANSPORT` 的合法取值与 `WORKFLOW_SPEC_VERSION` 各版本的确切语义，需查 `/docs/configuration/runtime-tuning` 与 `/docs/configuration/worlds`，本文未逐项核实。
>
> 待确认：官方 benchmark 页的 fan-out join 数据在不同 run 间有 ±数十毫秒波动（页面中 464 ms vs 官方 changelog 未提），比较单一路径时建议以自己 region 实测为准。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | 持久化 workflow + hook 人工审批 + 64 路 fan-out 的运行时优化，是多 agent 编排落到生产的基础设施条件；v5 把 hook resume 从两次往返压到一次，直接改善 agent 间的等待成本。 |

---
[← Back to Deep Dives](./README.md)
