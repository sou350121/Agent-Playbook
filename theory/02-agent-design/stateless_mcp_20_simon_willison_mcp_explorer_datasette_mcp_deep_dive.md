---
auto_generated: true
generated_at: "2026-10-21T03:33:00Z"
source_url: "https://simonwillison.net/2026/Jul/31/stateless-mcp/#atom-everything"
signal_type: "significant_update"
---

# Stateless MCP 2.0：去掉「会话」之后，协议实现了什么 (Stateless MCP 2.0: What Removing Sessions Actually Bought Us)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-21
>
> **项目/工具**: MCP 2.0 规范（2026-07-28 版）+ Simon Willison 的 mcp-explorer / datasette-mcp / llm-mcp-client 工具链
> **链接**: https://simonwillison.net/2026/Jul/31/stateless-mcp/#atom-everything
> **核心定位**: MCP 协议最大的一次瘦身——把「先 initialize 拿 session id、再调工具」的两步握手压成一次 HTTP 请求，使客户端与服务端的实现复杂度、以及规模化部署的状态成本同时下降。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：MCP 从 stateful 会话模型转向 stateless 请求模型，一次 POST 就能调用工具。
- **現在值得用嗎**：是——如果你的 MCP 服务部署在无状态机群、serverless 或多副本负载均衡后面，收益立刻可观；单机 stdio 场景收益有限。
- **適合場景**：自建远程 MCP 服务、把 MCP 挂到 serverless/边缘、给弱模型暴露可审计工具集、快速探测第三方 MCP。
- **不適合場景**：依赖服务端会话上下文（长连接推送、订阅）的既有实现、以及尚未升级协议版本的客户端/服务端混搭部署。
- **與舊版 MCP（legacy stateful）核心差異**：不再需要 `Mcp-Session-Id` 与粘性路由，服务端不存会话状态。

## 是什么 / 解决什么问题

MCP 是 Anthropic 于 2024 年 11 月推出的「把工具暴露给 LLM agent 框架」的标准协议，2025 年经历了一次巨大的关注峰值，随后又被 Skills 抢走一部分风头——Simon Willison 的原话大意是：当 agent harness 有 shell 和 curl 时，MCP 能做的事大多能用更灵活的方式完成。

他回转的原因不是怀旧，而是两个现实判断：

1. **给 agent 一个能上网的 shell 环境风险很高**，而且需要足够强的模型才能有效驾驶那个环境；
2. **MCP 工具更易审计与控制**，并且简单到跑在笔记本上的小模型也能相对可靠地驱动。

而 stateless 规范进一步降低了写客户端和服务端的门槛——他本周就用它写了三个实现。这句话本身就是一个信号：**协议的设计成本，会直接决定工具生态的增长速度**。协议写好之后一周内出现三个新工具，比任何 adoption 曲线都更有说服力。

## 技术架构拆解

### 核心设计决策

- **单请求取代握手**：旧协议必须先 `initialize` 拿 `Mcp-Session-Id`，再带该 header 调 `tools/call`；新协议把协议版本、方法名、工具名放进 HTTP header，`clientInfo` 放进请求体的 `_meta`，一次请求完成。
- **状态从服务端移到请求里**：所有原本依赖会话的上下文（协议版本、客户端身份）变成自描述字段，服务端因此可以完全无状态。
- **与 HTTP 基础设施对齐**：无会话 → 无需粘性路由（sticky routing）→ 多副本负载均衡、serverless、CDN 前置都变得平凡。这是「更好的可伸缩 Web 应用适配」，Simon 明确点出的收益。
- **仍然保留 JSON-RPC 外壳**：`jsonrpc: "2.0"`、`id`、`method`、`params` 全部保留，迁移是「加 header + 挪 clientInfo」，不是重写协议。

### 与前版的关键差异

| 维度 | legacy MCP（stateful） | MCP 2.0（stateless） |
|------|----------------------|---------------------|
| 调用流程 | initialize → 拿 session id → tools/call | 单次 POST |
| 会话标识 | `Mcp-Session-Id` header | 无 |
| 协议版本声明 | initialize 参数 `protocolVersion` | `MCP-Protocol-Version` header |
| 工具定位 | 请求体 `params.name` | `Mcp-Method` + `Mcp-Name` header（体中也保留） |
| 客户端身份 | initialize 参数 `clientInfo` | 请求体 `_meta["io.modelcontextprotocol/clientInfo"]` |
| 服务端状态 | 必须维护 session 表 | 无状态 |
| 扩展性 | 需粘性路由 | 可任意负载均衡 |

### 架构/信息流图

```
legacy（两步、有状态）
 client ──POST initialize──▶ server ── session id ──▶ client
 client ──POST tools/call [Mcp-Session-Id]──▶ server (必须路由到同一台)

MCP 2.0（一步、无状态）
 client ──POST /mcp──▶ [MCP-Protocol-Version, Mcp-Method, Mcp-Name] ──▶ 任意副本
                      body: jsonrpc + params + _meta.clientInfo
```

## 实用评估

### 什么场景值得用

- **远程 MCP 服务**：无状态意味着可以放在 serverless 函数、CDN 边缘、K8s 任意副本后面，不需要 session affinity，也不用为 session 做共享存储。
- **小模型驱动工具**：Simon 的观察是 MCP 的工具描述足够简单，笔记本上的小模型也能驱动——对做本地 agent 的人这是路线选择依据：与其给弱模型一个 shell，不如给它一组窄而清晰的 MCP 工具。
- **快速探测与调试**：`mcp-explorer` 以 `uvx` 直接运行，无需安装，给「这家的 MCP 到底暴露了什么工具」提供了一行命令的答案。

### 什么场景不值得用

- **依赖推送/订阅的集成**：原文明说的是「调用」路径变简单，长连接、服务端主动通知这类模型的替代方案未在预抓取材料中展开，**不应用 stateless 改造直接推定这些场景同等简化**。
- **未升级版本的双端混搭**：legacy 客户端打 stateless 服务端（或反之）会因握手/header 不匹配失败，升级应当整条链路一起做。
- **本地单进程 stdio 用途**：本来就没有多副本与路由问题，瘦身收益主要是代码简洁，不是能力提升。

### 迁移成本

- 客户端：去掉 initialize 步骤，改为在每次请求携带 `MCP-Protocol-Version`、`Mcp-Method`、`Mcp-Name`，并把 `clientInfo` 移入 `_meta`。
- 服务端：删除 session 管理、路由亲和依赖；保持 JSON-RPC 处理逻辑。
- 生态侧：SDK 与网关（含第三方代理）需同步支持新版本号 `2026-07-28`，这部分成本不在协议本身而在部署矩阵，属最大不确定性。

## 对你的意义

这条对 AI App 线是**结构性**的，不是工具级新闻。你追踪的 Agent + UI 方向里，MCP 一直是「工具接入层」；它从 stateful 变 stateless，直接改变了部署与安全的默认姿态：

1. **部署更便宜**：远程 MCP 不再需要会话基础设施，小团队也能横向扩；
2. **审计更容易**：`Mcp-Method` / `Mcp-Name` 进 header，网关层可以按方法名做策略、限流、日志，而不必解析 body——这对你关心的「评估与安全」是个明确抓手；
3. **与 Skills 的边界更清晰**：shell+curl = 强模型、高风险、高灵活；MCP = 弱模型、可审计、易约束。这条二分法值得作为你 agent 架构笔记里的一节固定下来。

**建议：立即试用。** 用 `uvx mcp-explorer list <url>` 花五分钟探一遍你在用的第三方 MCP，能立刻看出哪些服务还没升级协议版本。

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

对 `agentic-mermaid.dev` 的实测返回包含 `execute(code, timeoutMs?)`、`describe_sdk(family, detail?)`、`render_svg(source, options?)` 等工具——注意 `execute` 的描述是「Run JavaScript in an isolated sandbox」，即 MCP 也可以安全地包装一层沙箱执行，而不是直接给出 shell。

> TODO: 源材料未给出 datasette-mcp 与 llm-mcp-client 的具体接口与实现细节（预抓取被截断），两工具的功能边界待补。

---
## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 协议最大一次改动不是加功能而是降实现成本，并直接催生多个新工具实现，是标准走向事实化的典型信号。 |

---
[← Back to Deep Dives](./README.md)
