---
auto_generated: true
generated_at: "2026-11-20T14:01:07Z"
source_url: "https://vercel.com/blog/workflow-sdk-5"
signal_type: "significant_update"
---
# Vercel Workflow SDK 5：为 Agent 负载重写持久化执行引擎 (Vercel Workflow SDK 5: Durable Execution Rewritten for Agent Workloads)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-20
>
> **项目/工具**: Vercel Workflow SDK
> **链接**: https://vercel.com/blog/workflow-sdk-5
> **核心定位**: 一个「写普通 async JavaScript，SDK 帮你挺过崩溃、部署和长等待」的持久化工作流框架。v5 把引擎重写成「为 Agent 而生」的形态：默认端到端加密、全区域部署、把每步的队列跳转压掉——官方基准里长链路开销降了 25 倍。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Vercel 的 durable workflow 框架第 5 版，把重心从「传统后台自动化」挪到「Agent 与 harness」，用加密 + 区域化 + 低开销引擎解决 Agent 长链路执行的三个真痛点。
- **现在值得用吗**：看场景。如果你在 Vercel 上跑多步 Agent 或长流程自动化，v5 基本是「无脑升级」（无重大 breaking change）；如果不在 Vercel 上、或只需要简单定时任务，收益感知会很弱。
- **适合场景**：Agent 循环 / harness（几千个顺序事件、token 流、工具链、动态子 agent）、订单 / 订阅 / ETL 这类传统长流程、需要把敏感 payload 落盘但不能让平台看见明文的合规场景。
- **不适合场景**：单机小脚本、可以在几分钟内跑完的无状态任务、已经在用 Temporal / Inngest / Restate 并有成熟运维体系的团队。
- **与前版核心差异**：v4 → v5 的关键词是「不再是 iad1 单区域 + 每步两次队列跳转」，而是「全区域 + 增量重放 + WebSocket 流式 + AES-256-GCM 端到端加密」。

## 是什么 / 解决什么问题

Workflow SDK 的原始命题很朴素：**你写普通的 async 函数，加一行 `"use workflow"`，剩下的「崩溃恢复、部署不中断、睡三天再继续」交给 SDK。** 官方给出的规模数据是累计 40 亿个 step、7 亿次 run——已经不是一个玩具。

跑了一年之后，Vercel 观察到两类负载在真正增长：

1. **自动化**：搬数据、处理订单、协调后台任务、订阅管理、ETL 与数据管道；
2. **Agent 与 harness**：Agent 贵、跑得久，天然需要 durability。

第二类负载把 v4 架构的弱点全暴露了。Agent 循环动辄包含几千个顺序事件、高吞吐 token 流、工具链调用和动态子 agent——在 v4 里，**每一次 step 调用都要经过两次队列跳转（一次起 step，一次回主流程）**，网络与 CPU 开销直接变成上限。同时，事件日志要持久化 step 参数和返回值，而这些内容可能是客户 PII、模型上下文、凭据、工具调用结果——「持久化」和「不外泄」之间产生了尖锐矛盾。

v5 就是对着这两件事重写的：**安全（加密 + 留痕策略）**、**可靠性（区域隔离 + 运行时 bug 清剿）**、**性能（少跳转 + 增量重放 + WebSocket 流）**。

## 技术架构拆解

### 核心设计决策

- **加密下沉到 SDK，而不是平台**。加密发生在 payload 离开你的代码之前，用 AES-256-GCM、**每个 run 一把唯一密钥**。开启后，任何 Workflow 后端（包括 Vercel 自己）只看到密文；明文只在你的部署内或授权的可观测性工具里解密。
- **每 run 一把派生密钥，而不是全局一把**。在 Vercel 上无需配置：每 run 的密钥由「创建它的那次部署」作用域的密钥派生，因此**一个 run 只能解密自己的数据**。
- **跨 run 写入按目标 run 公钥加密**。恢复别的 run 的 hook、往另一个部署的 run 里启动、写入转发来的 stream——写入方可加密给目标 run，但**读不到目标 run 已有的 payload**。这是一个很干净的最小权限模型。
- **区域即 home 区域**。v4 里每个 run 的事件日志、队列、流都住在 iad1，哪怕项目部署在多区域，跑到别处的 step 也要跨区域回写进度。v5 把 Workflow 基础设施铺到每个 Vercel Function region，**每个 run 有自己的 home region**，状态、队列派发、流都在启动它的区域服务，热路径上没有跨区域往返。
- **增量重放而非全量重放**。v4 重放整段事件历史，开销随日志大小线性增长；v5 只重放必要部分。
- **流式默认走 WebSocket**。在 Vercel World 上，v5.2.0 默认用 WebSocket 写 stream——「durability 不应该让流式响应落后于生产者」。

### 与前版/竞品的关键差异

| 维度 | v4.8.12 | v5.2.0 |
|------|---------|--------|
| 区域 | 所有 run 都在 iad1 | 每个 run 有 home region，可显式指定（如 `fra1`） |
| 每步队列跳转 | 起 step 一次 + 回主流程一次 | 一次调用内可内联执行多个 step（含并行），直到遇到 wait / hook / 超时临近 |
| 重放策略 | 全量事件历史重放 | 增量重放 |
| 流式传输 | 队列/网络写 | 默认 WebSocket（Vercel World） |
| Payload 加密 | 无（plaintext 落事件日志） | AES-256-GCM，每 run 唯一密钥，SDK 侧加密 |
| 可观测性 | 常规 trace | 重设计 trace viewer + run attributes（可按订单号等检索） |
| 数据留存控制 | 无 | `experimental_retention: 0`（run 完成/失败即删除 I/O 与流内容，元数据保留） |
| Breaking change | — | 「无重大 breaking change」，同一 DX |

几个硬数字（官方基准，2026-10-08 于 iad1 生产环境、Vercel World、每步 1 KB JSON 进出）：

- 第一步 p75：418 ms → 172 ms（2.4× 更快）
- 步间开销 p75：618 ms → 109 ms（5.7× 更快）
- 长跑尾段开销 p75（1,020 步基准的最终采样区间）：1,748 ms → 70 ms（**25× 更低**）
- 1,020 步全流程中位数：21.0 分钟 → 3.0 分钟（7× 更快）
- 恢复（resume）p75：699 ms → 425 ms（1.6×）
- 流式投递中位数（52.4 秒的 agent 响应重放）：226.1 秒 → 53.5 秒（4.2×）
- 延迟超 1 秒的 chunk：10 次中 6 次 → 0 次
- AI token 流经压缩后平均体积约减少 **80%**

官方明确声明这些数字是「单一负载、单区域、针对 Vercel World」的结果，是运行时开销的一个视角，不是对所有应用的预测。这个自觉的限定值得点赞——大多数 benchmark 博文不写这句。

### 架构/信息流图

```text
[ 你的代码 ]   "use workflow" / "use step"
      |
      | (输入/输出在离开代码前加密 AES-256-GCM，每 run 唯一密钥)
      v
+--------------------------------------------------+
|  World 接口层（存储进度 / 派发工作 / 交付流）      |
|  - Vercel World（托管）   - 自定义 World（自托管） |
+--------------------------------------------------+
      |   home region（启动它的函数所在区域，可显式指定）
      v
+-------------------+     +----------------------+
| 事件日志(密文)     | --> | 增量重放（只放必要片段）|
| 队列派发           |     | 一次调用内联多个 step   |
| 流（WebSocket）    |     | 遇到 wait/hook/超时让出 |
+-------------------+     +----------------------+
      |
      | (可选) 可观测性：名称/时长/状态明文可见；
      |         payload 显示 🔒 Encrypted，
      |         在本地浏览器/CLI 解密（走环境变量同级权限 + 审计日志）
      v
   npx workflow inspect run <run-id> --decrypt
```

一个容易被忽略但很关键的**边界**：`region` 选项决定的是「run 的**数据**落在哪」，**你的 step 仍然跑在你应用部署的区域**。想让 step 也执行在法兰克福，应用本身也得部署到那儿。另外，**v4 遗留 run 会永远留在 iad1**——这不是不兼容问题，但做区域合规规划时要知道存量数据不会迁移。Vercel Function failover 开启时，step 可以切到备用区域执行，**但 run 的状态始终钉在 home region，不会在 failover 期间迁移**。

## 实用评估

### 什么场景值得用

- **Agent 长链路**：几千个顺序事件、动态子 agent、工具调用密集的 harness。步间 618 ms → 109 ms 这类改进在 1,000+ 步的循环上是乘法效应，不是小数点的差别。
- **流式 Agent 响应**：v4 里 52.4 秒的响应要 226 秒才送完——这是用户能直接感知的体验灾难；v5 降到 53.5 秒，接近「不落后于生产者」。
- **合规敏感的落盘**：模型上下文、凭据、工具结果要进事件日志才能恢复，但又不能明文躺在第三方存储里。SDK 侧加密 + `experimental_retention: 0` 的组合，是目前少数能同时要「可恢复」和「不泄露」的方案。
- **多区域部署的产品**：用户在日本、欧洲、美国，靠「run 跟随请求所在区域」自然拿到低延迟，不需要自己写路由逻辑。

### 什么场景不值得用

- **单区域、短任务、无状态**：你的任务 30 秒内跑完、失败重跑一次就好，durability 的价值为负（多了事件日志和状态机的复杂度）。
- **已经在 Temporal / Inngest / Restate 上跑了很久的团队**：v5 的差异化主要在 Agent 场景的延迟和加密模型，但这不足以让一套成熟的、跨云的工作流运维体系重做迁移。
- **不在 Vercel 上**：加密和区域能力在 SDK 层是真能力（自托管 World 也能用 `getEncryptionKeyForRun()`），但**性能基准全部是针对 Vercel World 测的**，迁到自建后端后能保留多少需要自己验证。这是一个必须说清的局限。
- **需要精细的跨 run 状态救援**：加密模型是有代价的——写入方只能加密给目标 run，**不能读取目标 run 已有 payload**。如果你有「后台修复 / 审计日志全量读取」类需求，需要在可观测性侧的授权解密流程里绕一圈。

### 迁移成本

- **API 层**：官方说法是「无重大 breaking change」，`workflow` / `step` / `sleep` / `hook` / `start` 语义不变，升级路径主要是 `pnpm add workflow@latest` 加上读 v5 upgrade docs。估算是**按小时到按天**的量级，不是重写。
- **真正的迁移成本在语义层**：区域模型变了（v4 run 永远留 iad1）、留存策略是新的（`experimental_retention` 还是 experimental 前缀，别在合规承诺里当成 GA 能力）、加密开启后本地调试需要用 `--decrypt`。
- **Python 侧**：Python SDK 仍在 **beta**，能提供同样的 durable workflows / steps / sleeps / hooks，但不要在关键路径上把它当稳定件。

## 对你的意义

如果你在做 Agent 工程，这篇的真正信息量不在「Vercel 又快了多少」，而在**它承认了一个行业事实：Agent 的可靠性问题，本质上是「持久化执行」（durable execution）问题，不是 prompt 问题。**

过去一年「Agent harness」这个赛道一直在重造轮子：自己写检查点、自己写重试、自己写状态恢复。Workflow SDK 5 的路线是：**durability 应该是一个基础设施层，harness 只是它的消费者。** 这个判断你可以从它的产品结构里读出——同一个 World 底座现在同时供给 Workflow SDK、`WorkflowAgent`（AI SDK 里的 agent loop）、`fx`（原生 coding agent）、`durable-harness`（给 Pi / OpenCode 加持久化，Claude Code / Codex 是 experimental），以及 `eve`（durable sessions 原生跑在 Workflow SDK + Worlds 上）。

给你的具体建议：

- **立刻关注，不必立刻迁移**。如果你的 Agent 目前是「几十步以内、失败重跑可接受」，还不到痛点；一旦进入「千步、带工具链、流式输出」的区间，v5 的增量重放和 WebSocket 流是结构性优势。
- **加密模型值得抄作业**。即使你不用 Vercel，这套「每 run 唯一密钥 + 派生自部署作用域 + 跨 run 写按目标公钥加密 + 写方不可读」的最小权限设计，是 Agent 可观测性落地时最容易做错的一块（大多数团队直接把完整 tool 输入输出明文塞日志）。
- **盯 `experimental_retention` 转 GA 的时间点**。这是企业采购合规清单里的常见项——「run 结束后敏感数据必须删除」，能一句话回答的框架不多。

## 关键代码/配置片段

最基本的 durable workflow（源：官方 blog）：

```typescript
// workflows/welcome-user.ts
import { sleep } from "workflow";

export async function welcomeUser(email) {
  "use workflow";

  const user = await createUser(email);
  await sendWelcomeEmail(user);

  // Survives crashes and deployments while it waits
  await sleep("3d");

  await sendCheckInEmail(user);
}
```

加密在 Vercel 上是零配置的——应用逻辑不需要改：

```typescript
export async function onboardCustomer(customer: Customer) {
  "use workflow";

  // The customer record is stored encrypted in the event log
  const account = await createAccount(customer);
  await sendWelcomeEmail(account.email);
  return account.id;
}

async function createAccount(customer: Customer) {
  "use step";

  // ...and arrives here decrypted, inside your deployment
  return db.accounts.create(customer);
}
```

自托管 World 启用加密：为每个 run 提供**稳定的 32 字节密钥**（重放时必须返回同一把）：

```typescript
// world.ts
import type { World } from "@workflow/world";

type RunKeyProvider = World["getEncryptionKeyForRun"];

export const getEncryptionKeyForRun: RunKeyProvider = async (run) => {
  const runId = typeof run === "string" ? run : run.runId;
  // Return the same 32 bytes for a run every time, so replays can decrypt
  return keyStore.getRunKey(runId);
};
```

显式指定 run 数据所在区域：

```typescript
// Keep this customer's run data in Frankfurt
const run = await start(processOrder, [order], { region: "fra1" });
```

本地检查加密 payload：

```bash
# Payloads show as 🔒 Encrypted
npx workflow inspect run <run-id>

# Decrypts locally, if you have access
npx workflow inspect run <run-id> --decrypt
```

注意：上面的 TypeScript 片段摘自官方 blog，`World` 类型的包名与 `start()` 的完整签名请以 v5 upgrade docs（https://workflow-sdk.dev/docs/whats-new）为准。

> TODO: 自托管 World 上的实际性能保留比例待验证（官方基准仅覆盖 Vercel World）。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | 把 durability 下沉为 World 底座，供 WorkflowAgent / durable-harness / eve 等共享，说明「Agent 运行时」正在从框架内造轮子转向共享基础设施 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 官方称 40 亿 step / 7 亿 run 的两大负载形态中「自动化」与「Agent harness」并列，且加密与留存控制明显在朝企业合规需求对齐 |

---
[← Back to Deep Dives](./README.md)
