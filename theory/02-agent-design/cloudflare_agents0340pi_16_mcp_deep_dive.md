---
auto_generated: true
generated_at: "2026-11-27T12:41:50Z"
source_url: "https://github.com/cloudflare/agents/releases"
signal_type: "significant_update"
---
# Cloudflare Agents 0.34：让工具「停下来等人」，把 MCP 鉴权失败变成可编排状态 (Cloudflare Agents 0.34: Parkable Tools and MCP Re-Authorization as First-Class State)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-27
>
> **项目/工具**: Cloudflare Agents SDK（`agents` npm 包）+ Pi harness
> **链接**: https://github.com/cloudflare/agents/releases/tag/agents%400.34.0
> **核心定位**: 把「human-in-the-loop」从业务代码里的轮询/超时 hack，下沉为 agent runtime 原生语义：工具可挂起等待信号或截止时间，MCP 需要重新授权时抛结构化错误而非静默失败。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：`agents@0.34.0` 接入 Pi 1.6，工具可 `{ kind: "sleep", signals, until }` 挂起等待人/截止时间/子 session，同时 MCP 客户端把「需要用户重新登录」变成可捕获的 `MCPAuthorizationRequiredError`（释放于 2026-11-20；11-25 的 0.34.1 是 Pi 1.6.1 的补丁适配）
- **現在值得用嗎**：看场景——只有当你已在 Cloudflare Workers / Durable Objects 上跑长任务 agent，且确实有「等人审批 / 等外部信号」的环节，才值得现在升级
- **適合場景**：审批型 agent（部署、支付、工单提交前找人签字）、跨 session 协作（子 agent 完成后唤醒父工具）、MCP 多 server 需要 OAuth 重新授权的生产系统
- **不適合場景**：单次问答型 chatbot、纯本地跑 Python agent 的团队、无法接受「不能回滚」的保守发布流程
- **與前版的關鍵差異**：以前工具要么同步阻塞、要么自己写 sleep+轮询；现在挂起期间「不占用 invocation」，对象可以休眠甚至被驱逐，由 alarm 唤醒续跑

## 是什么 / 解决什么问题

Cloudflare Agents SDK 的目标是让 agent 跑在边缘的 Durable Object 上——即一个带 SQLite 的持久化对象。但长任务 agent 一直有个尴尬缝隙：**真正会「卡住」的时刻，往往不是模型思考，而是等人、等另一个 agent、等外部回调**。

旧范式下，开发者只有两个笨办法：一是让工具同步阻塞等待（对象被钉住、持续计费、超时后无从恢复）；二是在工具里自己写 `setTimeout` 轮询，把「等待」伪装成「计算」。两者都要求业务代码自己维护「我到底是第几次重试、信号有没有丢」。

0.34 的做法是把等待建模为**工具返回值的一种形态**。工具不再只有「成功 / 失败」两种结果，多了第三种：`{ kind: "sleep", signals, until }`——我这次不返回，等某个信号到达或截止时间到点，再把我跑一遍。这与 Pi（一个最小化、可扩展的 agent harness）1.6 的设计是对齐的同步升级。

第二块是 MCP 的**鉴权生命周期**。MCP 进入第二年（本周社区还在讨论 MCP 满两周年），server 侧的能力越来越复杂，token 过期、scope 不足（`403 insufficient_scope`）、refresh token 被撤销开始成为常态。老 SDK 的问题不是「不支持重授权」，而是**失败是静默的**——server 悄悄变 failed，agent 下一轮看到工具不见了，只能猜。

## 技术架构拆解

### 核心设计决策

- **把「等待」变成返回值而不是状态机**：工具 `execute()` 返回 park 对象后，Pi 记下 `signals` 与截止点；醒来时把同一个调用再跑一次，工具内部用 `api.readSignal()` 先检查信号是否已到（重入安全），到了就直接产出结果。这意味着**业务代码写的是幂等函数，而非回调链**。
- **等待期间不占 invocation**：release notes 明确写「a tool can park … without keeping the agent awake」，文档进一步说明「the call holds no invocation, so the object can hibernate or be evicted」。这是成本模型上的关键——不是「阻塞但省钱」，而是真的释放执行上下文。
- **信号投递走 `harness.signal()` 而非 `harness.pi().signal()`**：因为前者会**先调度 harness 的 wake 再把值交给 Pi**，即使对象在唤起的调用执行中崩溃，alarm 也会重启它。这是一个典型的「先记账再干活」的崩溃一致性设计。
- **等待可以发生在工具执行前**：`beforeTool` hook 也能 park（用于审批、限流、预算闸门）。但 hook 每次重开都会重跑，所以必须幂等——文档原话：「Pi runs that hook again each time it reopens, so the hook must be idempotent」。
- **MCP 失败从「静默」变成「显式状态 + 可操作句柄」**：需要重新授权时 `callTool()` / `readResource()` / `getPrompt()` 抛 `MCPAuthorizationRequiredError`，带 `authUrl`；server 进入 `authenticating` 并保存 `auth_url`，客户端通过 `getMcpServers()` 就能看到新链接。失败的 server **不再每次 wake 重试**，必须显式 `reconnectMcpServer(id)`。
- **错误细节不再泄漏给客户端**：`Lifecycle.fetch` 抛错时，HTTP 只回通用 500、WebSocket 以 1011 关闭且不带 error frame（完整堆栈仍写日志）。需要旧行为的话实现 `onFetchError()` 自行决定响应。

### 与前版/竞品的关键差异

| 维度 | 之前（Pi 1.5 时代） | 现在（0.34 / Pi 1.6） |
|------|------------|------------|
| 工具等待人 | 业务代码阻塞或自写轮询 | 工具返回 `{ kind: "sleep", signals, until }`，runtime 负责唤醒 |
| 等待期资源占用 | 占用 invocation，对象无法休眠 | 挂起不占 invocation，对象可休眠/被驱逐，alarm 续跑 |
| 等待结果形状 | 自定义 | 信号状态统一为 `{ kind: "value", value }` 或 `{ kind: "expired" }` |
| 子 agent 协作 | 父工具轮询子 session | `submit()/continue()` 带 `notify`，子任务 settled 时唤醒父工具 |
| 用户中断 | abort 丢弃队列中的输入 | `submit(input, { onAbort: "keep" })` 保留下一条输入 |
| MCP 需重新授权 | 失败不明确，可能静默不可用 | 抛 `MCPAuthorizationRequiredError` + `authUrl`，状态变 `authenticating` |
| MCP server 故障 | 每次 wake 都可能重试 | 记住失败原因，须 `reconnectMcpServer(id)` 显式重连 |
| 错误响应 | 可能带堆栈/细节 | 通用 500 / WS 1011，可用 `onFetchError()` 定制 |
| 版本回滚 | 可回退到上一 Pi 小版本 | **不可回滚**：Pi 1.6 的会话格式 1.5 读不了，只能向前修 |

### 架构/信息流图

```
┌────────────────────── Durable Object (SQLite) ──────────────────────┐
│                                                                     │
│  ┌──────── Lifecycle ────────┐      ┌──────── PiHarness ────────┐   │
│  │ startup / alarm / job q   │◄────►│ Pi 1.6 (transcript,       │   │
│  │                           │ wake │ inbox, tools, retries,    │   │
│  └───────────────────────────┘      │ crash recovery)           │   │
│                                     └──────────┬────────────────┘   │
│                                                │                    │
│                            tool returns park   │                    │
│                     ┌──────────────────────────▼───────────────┐    │
│                     │ { kind:"sleep", signals, until }         │    │
│                     │  → 不占 invocation → 对象可休眠/被驱逐    │    │
│                     └──────────────────────────┬───────────────┘    │
└────────────────────────────────────────────────┼────────────────────┘
                                                 │
        用户答案 / 子 session settled / 截止时间到 │
                                                 ▼
                     harness.signal(taskId, Signal, key, payload)
                     （先调度 wake，再交付值 → 崩溃可续）
                                                 │
                                                 ▼
                     工具 execute() 重跑 → readSignal() 命中
                     ├─ kind:"value"   → 产出正常结果
                     └─ kind:"expired" → 走超时分支

   MCP 侧：
   callTool() ──403 insufficient_scope / 401 refresh 失败──►
     throw MCPAuthorizationRequiredError { authUrl }
     server → authenticating；客户端 getMcpServers() 看到 auth_url
     用户完成 OAuth 回调 → server → ready → 重试原请求
     （1 小时内同 scope 认证 3 次仍被挑战 → failed，须 reconnectMcpServer）
```

## 实用评估

### 什么场景值得用

- **审批闸门型 agent**：部署、付款、对外发信前的「找人签字」。文档给的 `beforeTool` park 用法就是为这类场景写的，比在业务层塞 `if not approved: return` 干净得多。
- **子 agent 编排**：父工具创建子 session、`submit(..., notify: { taskId, key })`、然后 park 在 `SubmissionSettled` 上。文档还强调子 session 由调用「拥有」，父被 abort 时子一起停、重跑时找到同一个子而不是新建——这是多数手写编排最容易漏的部分。
- **MCP 多 server 的长跑系统**：401/403 不再让工具默默消失，UI 可以稳定地拿到 `authUrl` 引导用户。对 Ken 那种「一个 agent 挂十几个 MCP server」的架构，这是真正省 debugging 时间的一块。
- **成本敏感的 serverless 部署**：挂起不占 invocation、对象可休眠，长等待（比如等人第二天审批）不再按「一直醒着」计费。

### 什么场景不值得用

- **没有等待环节的 agent**：如果工具都是「调完即返回」，升级收益只有错误处理部分，改造量不划算。
- **不能接受不可回滚的发布流程**：这是本次最硬的限制——release notes 与官方文档都写明「Once a conversation runs on Pi 1.6, Pi 1.5 cannot run its tool calls or model requests, so a deployment cannot roll back past this release. Roll forward to fix a bad deploy instead」。如果你的灰度策略依赖「出事先回滚」，这次升级要么先补好 feature flag / 版本隔离，要么别急。
- **依赖错误详情做前端调试**：默认已改为通用 500，必须实现 `onFetchError()` 才能保留细节（官方建议只在本地开发时暴露）。
- **Pi 已是实验状态**：文档明说「pi-durable is experimental, and its API can change in minor releases」，`agents` 一次只支持一个 Pi minor。接口稳定性不适合把核心业务全押上去的团队。

### 迁移成本

按官方 Upgrading 清单，只有命中四类用法才需要改：Pi harness、`agents/models/pi-ai`、Pi tools、MCP client，以及依赖失败响应细节的逻辑。主要动作：

1. Pi 升到 `~1.6.0`（0.34.1 起为 `~1.6.1`）；park 工具返回值从 `{ sleep: { ... } }` 改为 `{ kind: "sleep", signals, until }`，信号状态读 `{ kind }` 判别。
2. 信号投递改走 `harness.signal()`；访问 root 前先 `harness.root()`（否则 `sessions.list()` 不含 root）。
3. MCP 侧捕获 `MCPAuthorizationRequiredError`，提供「重新连接」按钮调 `reconnectMcpServer(id)`。
4. 需要错误详情则实现 `onFetchError()`。

**一个隐蔽的坑（0.34.1 补丁点）**：返回旧形状的 park 工具**能编译通过，但结束时拿到空结果**。这是最坏的一种失败——静默。升级时建议 grep 所有返回 `{ sleep:` 的工具。

## 对你的意义

对 Agent-Playbook 这条线，这次更新是「A-001: MCP 成为工具集成事实标准」的又一个支撑信号：MCP 的争论焦点已经从「要不要用」转到「授权生命周期怎么管」。一个 SDK 愿意为 `insufficient_scope`、refresh 被撤销、1 小时三次认证上限这些边角写专门的错误类型和重连 API，说明 server 侧的鉴权复杂度已经进入主流工程视野——这对企业采购评估（身份、最小权限、可审计）是实质加分项。

对照 Ken 这边的基础设施：这批 cron 任务本质上是「本地版 Durable Object + 定时唤醒」，人类审批环节目前靠 Telegram/文件落盘实现。Pi 的 park + signal 模型其实给出了一个值得抄的抽象——**「等待」应该是一等返回值，而不是 setTimeout**。如果之后要重写 Clawd 的长任务编排（比如 VLA Weekly 那种「draft 完了等人审」的流程），这个「工具返回 park → 外部信号唤醒 → 幂等重跑」的形状比现在的脚本接力更不容易在崩溃时丢状态。

建议：**观望 + 局部试用**。不要在生产 Workers agent 上直接升级主分支，但如果有一个需要审批的 MCP 工具场景，值得开一个分支把 park/signal 跑通，主要目的是抄它的重入约定（`readSignal` 先查、再决定 park 还是返回），而不是抄 API。

## 关键代码/配置片段

以下均引自官方 release notes 与 `docs/agents/harnesses/pi.md`、`docs/agents/mcp-client.md`。

挂起等待人工答案（工具内）：

```ts
const answer = await api.readSignal(Answer, "answer", context);
if (answer?.kind === "value") {
  return { output: [{ type: "text", text: answer.value.text }] };
}
await showQuestion(api.taskId, args.question);
return { kind: "sleep", signals: [Answer.key("answer")] };

// 之后，在 agent 侧用展示问题时的 task id 投递信号
await this.harness.signal(taskId, Answer, "answer", { text: "Yes" });
```

0.34.1 起的新形状（注意与 0.34.0 的差异）：

```
Pi tools now park with { kind: "sleep", signals, until }
instead of { sleep: { ... } }
a signal's state is { kind: "value", value } or { kind: "expired" }
```

MCP 重新授权处理：

```ts
import { MCPAuthorizationRequiredError } from "agents/mcp/client";

try {
  return await this.mcp.callTool({ serverId, name: "deploy", arguments: {} });
} catch (error) {
  if (error instanceof MCPAuthorizationRequiredError) {
    return { needsAuthorization: true, authUrl: error.authUrl };
  }
  throw error;
}
```

重连失败的 server：

```ts
import { Agent, callable } from "agents";

class MyAgent extends Agent<Env> {
  @callable()
  async reconnectServer(id: string) {
    return this.reconnectMcpServer(id);
  }
}
```

> TODO: 0.34.0 的 `Upgrading` 段落在预抓取源中被截断，`PiHarness.dispose()` 释放 per-session state 的具体行为、以及 `onFetchError()` 的完整签名未取到原文，本文未展开。如需引用请以 GitHub release 页面为准。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | SDK 专门为 MCP 的 `insufficient_scope`、token refresh 失败、重授权次数上限建立错误类型与重连 API，说明 MCP 鉴权语义已成为 runtime 必须正确处理的协议级事务，而非可选项 |

---
[← Back to Deep Dives](./README.md)
