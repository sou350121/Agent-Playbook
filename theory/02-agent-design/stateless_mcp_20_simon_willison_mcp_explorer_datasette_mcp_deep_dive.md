---
auto_generated: true
generated_at: "2026-10-21T03:33:00Z"
source_url: "https://simonwillison.net/2026/Jul/31/stateless-mcp/#atom-everything"
signal_type: "significant_update"
---

# Stateless MCP 2.0：去掉「会话」之后，协议真正换来了什么

> 🔍 本文由 Moltbot 自动生成 | 2026-10-21
>
> **项目/工具**: MCP 2026-07-28 规范（社区称 MCP 2.0）+ Simon Willison 的 mcp-explorer / datasette-mcp 工具链
> **链接**: https://simonwillison.net/2026/Jul/31/stateless-mcp/#atom-everything
> **核心定位**: MCP 协议自发布以来最大的一次改动——把「先 initialize 拿 session id，再调工具」的两步握手压成一次 HTTP 请求，客户端与服务端的实现复杂度、以及远程部署的状态成本同时下降。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：MCP 从有状态会话模型转向无状态请求模型，一次 POST 就能调用工具。
- **现在值得用吗**：看场景——远程 MCP 服务挂在 serverless、多副本负载均衡或 CDN 后面时收益立刻可观；单机 stdio 用途基本只是代码更简洁。
- **适合场景**：自建远程 MCP、把 MCP 放到边缘/serverless、给弱模型暴露可审计的窄工具集、快速探测第三方 MCP 暴露了什么。
- **不适合场景**：依赖服务端会话上下文（长连接、服务端主动推送）的既有实现；尚未升级协议版本的双端混搭部署。
- **与旧版 MCP（有状态）核心差异**：不再需要 `Mcp-Session-Id` 与粘性路由，服务端不保存任何会话状态。

## 是什么 / 解决什么问题

MCP 是 Anthropic 于 2024 年 11 月推出的标准，用于把工具暴露给 LLM agent 框架。2025 年它经历了巨大的关注峰值，随后一部分风头被 Skills 抢走——Simon Willison 的观察是：当 agent harness 已经拥有 shell 与 curl 时，MCP 能做的事大多可以用更灵活的方式完成。

他重新关注 MCP 不是怀旧，而是两个现实判断（来自原文）：

1. 给 agent 一个能上网的 shell 环境**风险很高**，而且需要足够强的模型才能有效驾驶那个环境；
2. MCP 工具**更易审计与控制**，并且简单到跑在笔记本上的小模型也能相对可靠地驱动。

无状态规范进一步降低了写客户端与服务端的门槛——他本周就用它写了三个实现。这件事本身就是信号：**协议的设计成本直接决定工具生态的增长速度**。一周内出现三个新实现，比任何 adoption 曲线都更能说明问题。

## 技术架构拆解

### 核心设计决策

- **单请求取代握手**：旧协议必须先 `initialize` 拿 `Mcp-Session-Id`，之后每次 `tools/call` 都带上这个 header；新协议把协议版本、方法名、工具名放进 HTTP header，`clientInfo` 放进请求体 `_meta`，一次请求完成。
- **状态从服务端搬进请求**：原本依赖会话的上下文（协议版本、客户端身份）变成自描述字段，服务端因此可以完全无状态。
- **与 HTTP 基础设施对齐**：无会话 → 无需粘性路由（sticky routing）→ 多副本负载均衡、serverless、CDN 前置都变得平凡。这是 Simon 明确点出的收益。
- **保留 JSON-RPC 外壳**：`jsonrpc: "2.0"`、`id`、`method`、`params` 全部保留。迁移是「加 header + 挪 clientInfo」，不是重写协议。

### 与前版的关键差异

| 维度 | legacy MCP（有状态） | MCP 2026-07-28（无状态） |
|------|---------------------|-------------------------|
| 调用流程 | initialize → 拿 session id → tools/call | 单次 POST |
| 会话标识 | `Mcp-Session-Id` header | 无 |
| 协议版本声明 | initialize 参数 `protocolVersion` | `MCP-Protocol-Version` header |
| 工具定位 | 请求体 `params.name` | `Mcp-Method` + `Mcp-Name` header（body 中也保留） |
| 客户端身份 | initialize 参数 `clientInfo` | 请求体 `_meta["io.modelcontextprotocol/clientInfo"]` |
| 服务端状态 | 必须维护 session 表 | 无状态 |
| 扩展性 | 需粘性路由 | 可任意负载均衡 |

### 架构/信息流图

```
legacy（两步、有状态）
 client ──POST initialize──▶ server ── session id ──▶ client
 client ──POST tools/call [Mcp-Session-Id]──▶ server（必须路由回同一台）

MCP 2.0（一步、无状态）
 client ──POST /mcp──▶ [MCP-Protocol-Version, Mcp-Method, Mcp-Name] ──▶ 任意副本
                      body: jsonrpc + params + _meta.clientInfo
```

## 实用评估

### 什么场景值得用

- **远程 MCP 服务**：无状态意味着可以放在 serverless 函数、CDN 边缘、K8s 任意副本后面，不需要 session affinity，也不用为 session 建共享存储。
- **弱模型驱动的工具层**：Simon 的核心论点是 MCP 工具描述足够简单，笔记本上的小模型也能驱动。对做本地 agent 的人是明确的路线依据：与其给弱模型一个 shell，不如给它一组窄而清晰的 MCP 工具。
- **快速探测与调试**：`mcp-explorer` 以 `uvx` 直接运行，无需安装，一行命令就能回答「这家的 MCP 到底暴露了哪些工具、参数长什么样」。

### 什么场景不值得用

- **依赖推送/订阅的集成**：原文讨论的是「调用」路径的简化。长连接、服务端主动通知这类模型在预抓取材料中没有展开，**不能把 stateless 改造直接推定为这些场景同样简化**。
- **未升级版本的双端混搭**：legacy 客户端打无状态服务端（或反过来）会因握手/header 不匹配失败，升级要整条链路一起做。SDK、代理、网关的支持情况是最大的不确定性。
- **本地单进程 stdio 用途**：本来就没有多副本与路由问题，瘦身的收益是代码简洁，不是能力提升——为此重写现有实现并不划算。

### 迁移成本

- **客户端**：删除 initialize 步骤；每次请求携带 `MCP-Protocol-Version`、`Mcp-Method`、`Mcp-Name`；`clientInfo` 移入 `_meta`。
- **服务端**：删除 session 管理与路由亲和依赖，保留 JSON-RPC 处理逻辑。
- **生态侧**：SDK 与第三方网关需同步支持 `2026-07-28` 版本号。这部分成本不在协议本身，而在部署矩阵。

估算：一个只做 `tools/list` + `tools/call` 的最小客户端，熟悉 HTTP 的人半天内可完成；带鉴权、重试、工具结果渲染的生产客户端，按 1–2 天估算（个人判断，非官方数据）。

## 对你的意义

这条对 AI App 线是**结构性**的，不是工具级新闻。你追踪的 Agent + UI 方向里，MCP 一直是「工具接入层」；它从有状态变无状态，直接改变了部署与安全的默认姿态：

1. **部署更便宜**：远程 MCP 不再需要会话基础设施，小团队也能横向扩。
2. **审计更容易**：`Mcp-Method` / `Mcp-Name` 进 header，网关层可以按方法名做策略、限流、日志，不必解析 body——这对你关心的「评估与安全」是明确抓手。
3. **与 Skills 的边界更清晰**：shell + curl = 强模型、高风险、高灵活；MCP = 弱模型、可审计、易约束。这条二分法值得作为 agent 架构笔记里的固定一节。

### Claude Code 视角

Claude Code 是远程 MCP 最直接的受益场景，也是最容易踩坑的场景：

- 在 Claude Code 中挂远程 MCP 走的是 HTTP transport；无状态规范下服务端不必再保证「同一会话打回同一副本」，你可以在前面挂普通的 L7 负载均衡，不必为 CC 单独配粘性会话。
- 团队成员共享一个远程 MCP 服务时，有状态版本的 session 表会随人数线性膨胀，且流式回连接经常在反代处断掉；无状态版本把这些运维负担一次性去掉。
- 但要先确认 CC 所用的 MCP 客户端实现已支持 `2026-07-28`——版本不匹配时的失败表现通常是握手直接 400，而不是降级，排查时先看协议版本 header。

**建议：立即试用（限定范围）。** 用 `uvx mcp-explorer list <url>` 花五分钟探一遍你在用的第三方 MCP，能立刻看出哪些服务还没升级协议版本。

## 关键代码/配置片段

legacy（两步握手，来自源文）：

```http
POST /mcp HTTP/1.1
Content-Type: application/json

{ "jsonrpc": "2.0", "id": 1, "method": "initialize",
  "params": { "protocolVersion": "2025-11-25", "capabilities": {},
              "clientInfo": { "name": "my-app", "version": "1.0" } } }
```

```http
POST /mcp HTTP/1.1
Mcp-Session-Id: 1868a90c-3a3f-4f5b
Content-Type: application/json

{ "jsonrpc": "2.0", "id": 2, "method": "tools/call",
  "params": { "name": "search", "arguments": { "q": "otters" } } }
```

MCP 2.0（一次请求）：

```http
POST /mcp HTTP/1.1
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: search
Content-Type: application/json

{ "jsonrpc": "2.0", "id": 1, "method": "tools/call",
  "params": { "name": "search", "arguments": { "q": "otters" },
              "_meta": { "io.modelcontextprotocol/clientInfo":
                         { "name": "my-app", "version": "1.0" } } } }
```

探索工具（无需安装）：

```sh
uvx mcp-explorer list https://agentic-mermaid.dev/mcp
```

对 `agentic-mermaid.dev` 的实测返回包含 `execute(code, timeoutMs?)`、`describe_sdk(family, detail?)`、`render_svg(source, options?)` 等工具。注意 `execute` 的描述是「Run JavaScript in an isolated sandbox」——即 MCP 也可以安全地包一层沙箱执行，而不是直接交出 shell。

> TODO: 源材料（预抓取）在 datasette-mcp 部分被截断，该工具的具体接口与设计取舍未确认，本文不作展开。

---
## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 协议最大一次改动不是加功能而是降实现成本，并直接催生多个新工具实现，是标准走向事实化的典型信号。 |

---
[← Back to Deep Dives](./README.md)
