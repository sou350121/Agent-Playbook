---
auto_generated: true
generated_at: "2026-11-20T12:01:16Z"
source_url: "https://vercel.com/blog/workflow-sdk-5"
signal_type: "significant_update"
---
# Vercel Workflow SDK 5：为 Agent 长跑工作负载重写的持久化引擎 (Workflow SDK 5: Built for Production)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-20
>
> **项目/工具**: Vercel Workflow SDK
> **链接**: https://vercel.com/blog/workflow-sdk-5
> **核心定位**: 一个把「普通 async JavaScript」变成跨崩溃/跨部署持久运行的 durable workflow 引擎，v5 针对 agent 与 harness 这类高事件密度、长时运行负载重写了运行时，并把运行事件日志做到全链路加密 + 区域化。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：durable workflow 引擎，v5 的核心是「为 agent 优化性能 + 安全 + 区域本地化」，而非加功能。
- **现在值得用吗**：看你是否在用 durable workflow 承载 agent loop —— 如果你的 agent 每次运行有上千个 step、还要跨区域服务用户，值得；如果只是简单定时任务，v4 也够。
- **适合场景**：长时运行 agent harness、需要跨部署 survive 的工作流、多区域部署、有敏感 payload 的 agent（模型上下文 / 凭据 / 工具返回）。
- **不适合场景**：单机短任务、无法接受托管密钥管理（需自建 World）、跨区域强一致状态迁移。
- **与 v4 核心差异**：每一步不再走两次 queue hop；事件日志重放改为增量式；AES-256-GCM 每 run 独立密钥全链路加密；基础设施下放到每个 Vercel Function region。

---

## 是什么 / 解决什么问题

Workflow SDK 的第一版目标是「写普通 async JavaScript，让 SDK 替你扛住崩溃、部署和长时间等待」。它在 `"use workflow"` 里可以 `await sleep("3d")`，进程换了一代仍能接着跑。官方给出的规模数据是：**超过 40 亿次 step、7 亿次 run**。

在这个规模上，Vercel 观察到两类载荷成熟起来：

1. **传统自动化** —— 搬数据、处理订单、协调后台任务、订阅管理、ETL 与数据管道；
2. **Agent 与 harness** —— agent 昂贵且长时运行，天然需要 durability。

第 2 类正是 v5 的靶心。blog 原文说得很直白：v4 里「每次 step 调用都要一次 queue hop 去启动、再一次去继续」，对慢速后台任务是可接受的，但对今天在写的 AI 负载就是纯延迟。Agent loop 和 harness 里可能有**数千个顺序事件、高吞吐 token stream、工具链、动态子 agent**，在这个量级下，每一步周围的网络与 CPU 开销就成了天花板。

所以 v5 的三条主轴是：**安全（加密）→ 溯源可视化（trace viewer）→ 性能（重写引擎）**，外加一条没有被标题强调但影响很大的变化：**工作流状态按区域落地**。

---

## 技术架构拆解

### 核心设计决策

- **事件溯源作为 durability 的唯一底座**：event log 存 step 的参数与返回值，崩溃或部署后靠重放恢复。这既是它强大的原因，也是它所有安全问题的源头——日志里会有客户敏感信息、模型上下文、凭据、工具调用结果。
- **加密放在 SDK 层，而不是存储层**：payload 在「离开你的代码之前」就加密，所以任何 Workflow SDK 后端（包括 Vercel 自己）**只能看到密文**。这是一条关键的设计取舍：牺牲服务端可读性，换取「托管方也不可信」的安全模型。
- **每 run 一把密钥**：AES-256-GCM，run 之间密钥隔离。在 Vercel 上，密钥从「创建该 run 的部署」作用域派生，因此**一个 run 只能解密自己的数据**；零配置、零代码改动。
- **可观测性与加密共存的方法**：names / timings / statuses 永远明文可见；要看 payload 就在 dashboard 或 CLI 里解密，解密发生在**你的浏览器或终端**，权限对齐项目环境变量，每次解密请求进团队审计日志。
- **内联执行多个 step**：v5 允许一次 invocation 内联执行多个 step（包括并行 step），直到遇到 wait / hook / 临近超时才 yield。这把 queue hop 从「每步两次」压成「一段一次」。
- **增量重放**：反序列化不再每次从头重放整个事件历史。
- **Stream 走 WebSocket**：在 Vercel World 上默认用 WebSocket 写 stream，避免 stream 落后于生产端。
- **区域即数据归属**：每个 run 有 home region，state / queue dispatch / streams 都在本区服务；`start()` 可显式传 `region` 把数据钉在某个区域（如 `fra1`）。

### 与前版/竞品的关键差异

| 维度 | v4 / 之前 | v5 |
|------|-----------|-----|
| 每 step 的 queue hop | 启动一次 + 继续一次，共 2 次 | 多个 step 可内联执行，显著减少 hop |
| 事件日志重放 | 全量历史重放，开销随日志大小线性增长 | 增量重放 |
| 加密 | 不是默认能力 | AES-256-GCM，每 run 独立密钥，SDK 层端到端 |
| 跨 run 写入 | 明文写入目标 run | 用目标 run 的公钥加密封装 |
| 数据保留控制 | 无细粒度选项 | `experimental_retention: 0` 完成后立即删除 payload |
| 区域 | 所有 run 都在 `iad1` | 每个 Vercel Function region 都有 Workflow 基础设施，run 有 home region |
| Stream 传输 | 轮询/非 WS 路径 | Vercel World 默认 WebSocket |
| Trace 视图 | 基础列表 | span 搜索、缩放、minimap、本地开发可检视 |
| Run 属性 | 无 | `Run attributes`，可附加可搜索上下文（如订单 ID） |

官方给出的基准（2026-10-08 测得，Vercel 生产环境 iad1，对照组 v4.8.12 vs v5.2.0，每步输入输出各 1 KB JSON）：

| 测量项 | v4.8.12 | v5.2.0 | 变化 |
|---|---|---|---|
| 第一步 p75 | 418 ms | 172 ms | 2.4× 快 |
| 步间 p75 | 618 ms | 109 ms | 5.7× 快 |
| 后期运行开销 p75 | 1,748 ms | 70 ms | 25× 低 |
| 1,020 步中位总时长 | 21.0 min | 3.0 min | 7× 快 |
| Resume p75 | 699 ms | 425 ms | 1.6× 快 |
| Stream 投递中位 | 226.1 s | 53.5 s | 4.2× 快 |
| Chunk 单跳 p75 | 172 ms | 102 ms | 1.7× 快 |
| 单 chunk 延迟 >1 s 的 run | 6 / 10 | 0 / 10 | 归零 |

Vercel 自己限定得很清楚：**这是单一 workload、单一区域、针对 Vercel World 的测量**，反映的是运行时开销，不是对任何应用的预测。写作时应当照搬这个限定语，而不是把它当成通用加速比。另外 compression 让 AI token stream 平均体积缩小约 **80%**。

### 架构/信息流图

```
你的代码 (deployment)
  workflow / step 调用
        │
        │ ① SDK 内加密 (AES-256-GCM, 每 run 独立 key)
        ▼
  ┌─────────────────────────────────┐
  │ World (存储 / 队列 / stream)     │
  │  - event log (仅密文)            │
  │  - queue  ── home region 内      │
  │  - streams (WebSocket 默认)      │
  └─────────────────────────────────┘
        │
        │ ② 当前 invocation 内联执行多个 step
        │    (并行 step / 合并持久化往返)
        ▼
  step 到达时在 deployment 内解密 → 业务逻辑

观测路径：
  dashboard / CLI ◄── 权限校验(同 env vars) ◄── 浏览器/终端本地解密 → audit log
```

---

## 实用评估

### 什么场景值得用

- **Agent harness / 长 agent loop**：当一次 run 有几百到上千 step、还要高吞吐 token stream 时，v4 的「每步两跳 queue」叠加会变成主要延迟来源；v5 的步间 p75 从 618 ms 降到 109 ms 在这个场景是数分钟级别的差别。
- **多区域产品**：v4 里所有 run 都钉在 `iad1`，其他区域跑 step 就要跨区请求记录进度；v5 让 run 就近落地，对亚洲用户的产品是实打实的改善。
- **payload 含敏感信息**：模型上下文、用户凭据、工具返回结果现在都以密文形式躺在事件日志里，托管方（包括 Vercel）看不到明文。对合规审查来说这是很好讲的一句话。
- **需要事后审计 agent 行为**：`Run attributes` + 重设计的 trace viewer（span 搜索、minimap）让「按订单 ID 找 run」这类查询变得可行。

### 什么场景不值得用

- **简单定时/短任务自动化**：1.6×–25× 的性能收益在几十毫秒的任务上感知不到，v4 完全够用，迁移反而引入风险。
- **坚持自建密钥管理且不写 custom World**：自托管加密需要实现 `getEncryptionKeyForRun()` 并在每次调用为同一个 run 返回**相同的 32 字节密钥**，否则重放无法解密。这是明确的运维负担。
- **要求跨区域状态强一致迁移**：blog 明确写了 state 是「pin 在 home region，failover 期间不迁移」。如果你的合规要求是「数据必须在区域 A，但计算可以飘」，这符合；如果你的期待是「state 跟着计算走」，不符合。
- **必须让托管方看到明文做深度调试**：加密是端到端的默认行为，payload 在服务端不可读，只能本地解密。
- **任务体量极小的团队**：`experimental_retention: 0` 这类能力仍是 experimental 前缀，意味着 API 可能变动，别把关键合规流程押在上面。

### 迁移成本

官方称「保留相同开发者体验、没有重大 breaking change」，`pnpm add workflow@latest` + 读完 v5 upgrade docs 是基础动作。实际工作量估算：

- 只用官方 Vercel World + 标准 `use workflow` / `use step`：**接近零改动**，加密零配置生效。
- 自定义 World：需要实现 `getEncryptionKeyForRun()`，并保证密钥稳定（这是唯一需要写代码的点）。
- 多区域项目：默认按启动函数所在区域落地；如需钉区域，在 `start()` 传 `{ region: "fra1" }`，并**同时把应用部署到该区域**，否则 step 仍在原区域执行。
- 既有 v4 的历史 run：留在 `iad1`，不会自动迁移。

---

## 对你的意义

这条更新里最值得拿走的不是数字，而是**安全模型的表述方式**：「payload 在离开你的代码之前就被加密，所以后端只看到密文」。如果你在做 RAG 或者 agent 的工具调用记录、需要把 conversation / tool result 落到外部存储，这套思路可以原地借用——加密点放在 SDK / 客户端，而不是放在数据库服务商侧。

第二点是**durability 的成本曲线**。blog 里那句「agent 昂贵且长时运行，因此天然需要 durability」是判断依据：如果你的 agent 跑一次要 10 分钟、中间有 20 次 tool call，那它是 workflow，不是 request。反过来，如果你的 agent 是秒级单次调用，给它套 durable workflow 只是加了一层你不需要的复杂度。

第三点是这次更新和 **durable-harness** 的关系——它支持 Pi 与 OpenCode，并对 Claude Code / Codex 有 Vercel Sandbox 内的 experimental 集成。也就是说「给现成的 coding agent 套一层 durability」开始变成产品形态，而不是自己写。

**建议**：立即评估、谨慎迁移。理由：v5 的加密 + 区域化是真需求方向的改进，但如果你当前系统稳定、p75 开销不是瓶颈，等 v5 升级文档和 retention 语义稳定后再迁；若你正准备新建长跑 agent 架构，则直接以 v5 起步。

> 注：原文未披露 v5 在非 Vercel World（自托管）上的同等性能数据，性能数字仅代表 managed Vercel World。

---

## 关键代码/配置片段

基础 durable workflow（原样引用自 blog）：

```ts
// workflows/welcome-user.ts
import { sleep } from "workflow";

export async function welcomeUser(email) {
  "use workflow";

  const user = await createUser(email);

  await sendWelcomeEmail(user);

  // Survives crashes and deployments
  // while it waits
  await sleep("3d");

  await sendCheckInEmail(user);
}
```

零配置加密：应用代码不需要改动，只是 payload 在事件日志里变成密文。

```ts
// workflows/onboard-customer.ts
export async function onboardCustomer(
  customer: Customer,
) {
  "use workflow";

  // The customer record is stored
  // encrypted in the event log
  const account = await createAccount(customer);

  await sendWelcomeEmail(account.email);

  return account.id;
}

async function createAccount(
  customer: Customer,
) {
  "use step";

  // ...and arrives here decrypted,
  // inside your deployment
  return db.accounts.create(customer);
}
```

自托管 World 的密钥提供者（每个 run 必须返回同一把 32 字节密钥）：

```ts
// world.ts
import type { World } from "@workflow/world";

type RunKeyProvider =
  World["getEncryptionKeyForRun"];

export const getEncryptionKeyForRun:
  RunKeyProvider = async (run) => {
  const runId =
    typeof run === "string" ? run : run.runId;

  // Return the same 32 bytes for a run
  // every time, so replays can decrypt
  return keyStore.getRunKey(runId);
};
```

观测加密 payload：

```bash
# Payloads show as 🔒 Encrypted
npx workflow inspect run <run-id>

# Decrypts locally, if you have access
npx workflow inspect run <run-id> --decrypt
```

显式指定 run 的数据归属区域：

```ts
// Keep this customer's run data in Frankfurt
const run = await start(
  processOrder,
  [order],
  { region: "fra1" },
);
```

区域选择决定**数据存放**位置；step 仍在应用部署的区域执行，想让 step 也在该区域跑，就得把应用也部署过去。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | Vercel 用 40 亿 step / 7 亿 run 的实际负载证明「自动化」与「agent harness」两类工作流已规模化落地，并围绕它们重写运行时基础设施。 |

---
[← Back to Deep Dives](./README.md)
