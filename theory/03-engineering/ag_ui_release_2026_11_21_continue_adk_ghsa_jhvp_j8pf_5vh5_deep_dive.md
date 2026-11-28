---
auto_generated: true
generated_at: "2026-11-28T05:45:46Z"
source_url: "https://github.com/ag-ui-protocol/ag-ui/releases/tag/release%2F2026-11-21"
signal_type: "significant_update"
---
# AG-UI 2026-11-21 发版：把「权限门」和「审批令牌」真正焊死在协议层 (Hardening Approvals and Gates in the AG-UI Protocol)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-28
>
> **项目/工具**: AG-UI Protocol（ag-ui-protocol/ag-ui）
> **链接**: https://github.com/ag-ui-protocol/ag-ui/releases/tag/release%2F2026-11-21
> **核心定位**: Agent ↔ 前端之间的开放协议；这次发版修掉两类「客户端能绕过服务端控制」的漏洞——Continue 模式绕过权限门、ADK 端点鉴权旁路（GHSA-jhvp-j8pf-5vh5）

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：AG-UI 用一次发版把「暂停 / 审批 / 继续」这条最容易被客户端玩弄的链路全部回收给服务端裁决。
- **现在值得用吗**：值得——但前提是你原本就在用 AG-UI 的 LangGraph / ADK / OpenAI Agents 适配器。纯 REST 自研前端可继续观望。
- **适合场景**：Agent 前端带「人工审批 / 权限门 / 中断后继续」流程的产品；多 worker 部署的审批审批系统。
- **不适合场景**：不需要 interrupt/approval 语义的简单问答型聊天 UI（升级收益几乎为零，却要承担全部 breaking change）。
- **与前版核心差异**：`forwardedProps.node_name`、`command.goto/update`、客户端 `state.headers` 这些「客户端指哪打哪」的入口被大幅关掉；continue 改变了输入就必须**重开一个 run** 让权限门重新评估。

## 是什么 / 解决什么问题

AG-UI 是 agent 后端（LangGraph、ADK、OpenAI Agents SDK 等）与前端 UI 之间的协议层。它的关键卖点之一是 **interrupt / approval**：agent 跑到需要人类授权的节点时暂停，前端渲染审批卡片，人点了"同意"，后端继续。

问题出在"继续"这件事上。此前的实现里，前端可以携带 `forwardedProps.node_name` 直接指定从哪个节点恢复、可以带 `command.goto`、`command.update` 改变运行路径，甚至在 continue 时写回 client state。对于一个带权限门（permission gate）的图来说，这意味着**权限门还没重新判断，客户端就已经把状态改了或者跳过了节点**。

这次 release 一次性封掉这类面：continue 只允许从 thread history 证明「最近一步真的跑过」的节点恢复；输入一旦变化，不再 resume，而是**开新 run**；client state 写入被取消并加上 input-schema 过滤。

另一条线是安全公告 GHSA-jhvp-j8pf-5vh5：`ag_ui_adk` 的 `add_adk_fastapi_endpoint()` 没有把 dependencies 转发到 `/agents/state` 和 `/capabilities`，导致这两条路由**绕过了端点注入的鉴权依赖**。0.14.0 修掉了这个旁路。

## 技术架构拆解

### 核心设计决策

- **「谁能决定下一个节点」收回服务端**：`forwardedProps.node_name` 只有在线程历史显示该节点确实在最近一步跑过时才被采纳；`command` 只接受 `resume`，`goto` / `update` 直接丢弃并告警。
- **「输入变了就重新过闸」**：continue 若会改变 input channel 的取值，不再 resume，而是发起新 run，让权限门对变更后的输入重新评估。这是本次最本质的一条——它把 continue 从"状态机跳转"改成了"带历史的重新进入"。
- **「客户端选项白名单」**：`forwardedProps` 里现在只有 `streamSubgraphs`、`durability` 能到达 `runs.stream`；`context`、`checkpoint`、`checkpointId` 等一律丢弃并告警。`durability` 改为由 agent 侧的 durability option 下发。
- **「批准令牌自证、单次有效、绑定 agent」**（OpenAI Agents 适配器）：paused tool call 用 HMAC 对 thread + call id + tool name + 规范化参数签名；resume 时只有"这个 server 自己暂停过的调用"才执行。审批 token 绑定发起暂停的 agent，消费时检查过期，并可接入 `consumed_tokens=` 共享存储以支持多 worker / 重启。
- **「不重复叠加 reducer 值」**：continue 原样前进时不再写 client state，避免 `operator.add` 这类 reducer channel 把值翻倍。

### 与前版/竞品的关键差异

| 维度 | 之前（≤ 0.0.47 / 0.0.47-py / 0.1.x） | 现在（0.0.48 / 0.14.0 / 0.2.0） |
|------|------------|------------|
| Continue 恢复节点 | 客户端可指定 node_name 跳节点 | 仅当 thread history 证明该节点最近跑过才采纳 |
| 输入变更 | 可在原 run 内 resume | 输入 channel 变化 → 起新 run，权限门重新评估 |
| forwardedProps | durability/context/checkpoint 等可透传并合并 | 白名单：仅 streamSubgraphs、durability |
| ADK 鉴权 | `/agents/state`、`/capabilities` 未转发 dependencies（旁路） | 已转发，缺失身份时 fail closed（401） |
| 客户端 state.headers | 覆盖 request headers（可冒充身份） | request headers 优先 |
| 审批 token | 可重放、无跨 agent 绑定 | HMAC 签名 + 绑定 agent + 消费时校验过期 |
| tool 结果流 | 失败/中断在 snapshot 里才可见 | 失败也广播 TOOL_CALL_RESULT（含 START/ARGS/END） |

### 架构/信息流图

```
前端 (Client)                     协议层 (ag-ui-langgraph / ag_ui_adk)             Agent Graph
     |                                       |
     |-- run(...) forwardedProps ----------->|  白名单: streamSubgraphs, durability
     |                                       |  其余 -> 丢弃+warning
     |                                       |---- invoke graph (start run) --->  [node A]
     |<---- interrupt (gate) ----------------|                                    [gate ⏸]
     |                                       |
     |-- continue(command=resume, input?) -->|
     |                                       |  input 变了?
     |                                       |   ├─ 是 → 新 run（gate 重新评估）
     |                                       |   └─ 否 → 从 history 的最近节点恢复
     |                                       |         且不做 client state 写入
     |                                       |
     |   (tool 审批场景)                      |
     |-- resume(approval token) ------------>|  HMAC 验签 + agent 绑定 + 过期校验
     |                                       |  + consumed_tokens 共享存储
     |                                       |---- 仅执行 server 自己暂停的调用
```

## 实用评估

### 什么场景值得用

- **带人工审批的 Agent 产品**：凡是"agent 要动数据库 / 发消息 / 跑 shell 前要人点确认"的，本次改动直接堵住了客户端伪造参数、重放 approval、跨 agent 复用 token 三类真实攻击面。
- **多 worker 部署**：`ag-ui-openai-agents@0.2.0` 的 `consumed_tokens=` 共享存储是为横向扩展准备的——不接的话，重启或多进程会导致同一个审批被执行两次。
- **依赖权限门做数据边界的产品**：旧的 continue 语义（带 `goto` / 改输入）本身就是边界漏洞，不升级等于把门装在墙上但没装锁。

### 什么场景不值得用

- **纯问答型聊天 UI**：没有 interrupt / approval，升级只换来一堆需要复验的 breaking change。
- **自研协议栈**：如果没用这三个适配器（langgraph / adk / openai-agents），本次 release 与你无关，只值得把"客户端不可信的运行参数"这条原则抄进自己的实现。
- **依赖 `forwardedProps.config` 合并 `assistantConfig` 的老代码**：这个能力被直接移除，属于必须改代码的类型，不是配置开关能解决的。

### 迁移成本

- **小（1 天内）**：只用了 continue，但从不改节点/输入——升级后跑一遍流程验收即可。
- **中（1-3 天）**：用了 `command.goto/update` 或依赖 `forwardedProps.node_name` 跳节点。需要把这些"客户端编排"改成图内的条件边或服务端路由。
- **中大**：ADK 部署若原本没有注入鉴权依赖，升级后 `/agents/state`、`/capabilities` 会开始要求认证（fail closed 401），需要补齐依赖注入并在客户端带上凭据；同一 app 上所有调用必须传同一套 dependencies。
- **必须复验**：tool message id / TOOL_CALL_RESULT 时序变化，依赖 id 合并 snapshot 的前端要重测；`interrupted` 的 tool call 不再记成 failed。

## 对你的意义

如果你在用 AG-UI 搭 agent 前端（尤其带审批流），**建议立即规划升级**，理由是这次不修的东西是"客户端能绕过你的权限判断"，属于防御性维护而非功能债。

一个值得借鉴到自研系统的原则：**"改变输入必须重走过闸"**。很多自研 agent 系统把 resume 实现成"从上次中断的节点接着跑"，一旦中断后参数被改写，门形同虚设。AG-UI 的解法很干净——输入变了就不是 resume，而是新 run，把旧 run 的 checkpoint 当作历史而非权威状态。

另一个细节值得抄：审批令牌必须**签名覆盖参数**（HMAC over thread + call id + tool name + canonical args），并用共享的 consumed-tokens 存储做一次性消费。只绑定 token 本身、不绑定参数，等于允许"批准 A 调用、执行 B 参数"。

## 关键代码/配置片段

安装/固定版本（来自 release notes）：

```bash
npm install @ag-ui/langgraph@0.0.47   # 注意：TS 侧本次版本号为 0.0.47
pip install ag_ui_adk==0.14.0
pip install ag-ui-langgraph==0.0.48
pip install ag-ui-openai-agents==0.2.0
```

durability 改为 agent 侧选项（不再走客户端 `forwardedProps.durability`）：

```text
# 行为说明（release notes 原文语义）
# 旧: client -> forwardedProps.durability -> runs.stream
# 新: durability 作为 agent option 下发；客户端该字段被白名单剔除并告警
```

多 worker 审批存储（OpenAI Agents 适配器）：

```python
# 来自 release notes：需传入共享的 consumed_tokens store
# OpenAIAgentsAgent(..., consumed_tokens=<shared ConsumedTokens store>)
# add_openai_agents_fastapi_endpoint(..., consumed_tokens=<...>)
```

> TODO: 本次未抓取到 README/文档中 `ConsumedTokens` 的具体接口签名，落地前需核对官方文档。
> TODO: GHSA-jhvp-j8pf-5vh5 的 CVSS 评分与受影响版本区间需以 GitHub Security Advisory 页面为准。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持（间接） | AG-UI 与 MCP 分工明确：MCP 管工具接入，AG-UI 管 agent↔前端；本次把审批/中断语义硬化，是 agent 工具调用链路走向工程化的信号 |

---
[← Back to Deep Dives](./README.md)
