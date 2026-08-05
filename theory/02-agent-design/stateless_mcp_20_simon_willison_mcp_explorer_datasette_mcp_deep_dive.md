---
auto_generated: true
generated_at: "2026-08-05T03:33:10Z"
source_url: "https://simonwillison.net/2026/Jul/31/stateless-mcp/#atom-everything"
signal_type: "significant_update"
---
# Stateless MCP 2.0 重燃开发者兴趣：协议瘦身如何催生新工具生态

> 🔍 本文由 Moltbot 自动生成 | 2026-08-05
>
> **项目/工具**: MCP (Model Context Protocol) 2.0 规范 + Simon Willison 工具链 (mcp-explorer, datasette-mcp, llm-mcp-client)
> **链接**: https://simonwillison.net/2026/Jul/31/stateless-mcp/
> **核心定位**: MCP 2.0 将协议从有状态双向流改造为无状态请求/响应模型，大幅降低客户端和服务端实现复杂度，同时催生了 Simon Willison 的三款新工具

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：MCP 2.0 规范（2026-07-28）将协议核心从有状态会话模式改造为无状态请求/响应模式，是 MCP 自 2024 年 11 月发布以来最大的架构变革
- **現在值得用嗎**：是 — 如果你正在构建或集成 MCP 服务器/客户端，新规范显著降低实现复杂度，且所有 Tier 1 SDK 已同步更新
- **適合場景**：需要水平扩展的 MCP 服务器部署、轻量级客户端集成、网关层路由和审计
- **不適合場景**：严重依赖旧版 session ID 机制的遗留实现（需迁移）、需要 SSE 传输的旧客户端（已正式废弃）
- **與前版核心差異**：从「两次 HTTP 握手建立会话 → 带 Session ID 调用」变为「单次 HTTP 请求，所有元数据通过 HTTP Header + _meta 携带」

## 是什么 / 解决什么问题

MCP（Model Context Protocol）由 Anthropic 于 2024 年 11 月首次发布，旨在为 LLM Agent 框架提供标准化的工具暴露接口。2025 年全年经历了兴趣爆发式增长，Tier 1 SDK（TypeScript 和 Python）月下载量接近 5 亿次，总下载量均突破 10 亿大关。

然而，初版 MCP 的有状态协议核心成为了规模化部署的瓶颈。每次工具调用需要先发送 `initialize` 请求获取 `Mcp-Session-Id`，然后在后续请求中携带该 ID。这种设计带来了三个实际问题：

1. **服务端状态管理复杂**：需要维护 session 生命周期，在分布式部署中还需确保同一 session 的请求路由到同一后端实例
2. **客户端实现冗余**：每个客户端都要处理会话初始化、重试、连接恢复等状态逻辑
3. **网关层无法有效路由**：由于关键信息（方法名、工具名）嵌套在 JSON body 中，网关/WAF/速率限制器必须解析 JSON 才能做路由决策

MCP 2.0（规范版本 2026-07-28）的核心变革就是**彻底移除协议层会话**，将每个请求变为自描述的独立单元。任何请求都可以落在 round-robin 负载均衡器后的任意实例上，无需共享存储或会话亲和性。

Simon Willison 在这篇博客中坦诚地分享了他对 MCP 态度转变的心路历程——从 2025 年底认为 MCP 被 Skills（另一个 Anthropic 发明）和通用 Agent（带 shell/curl 访问权限）所超越，到如今因为 Stateless 改造而重新投入。他的核心论点很有说服力：**给 Agent 一个可访问互联网的 shell 环境充满风险，而 MCP 工具更容易审计和控制，简单到笔记本电脑上的小模型也能合理驱动它们。**

## 技术架构拆解

### 核心设计决策

| 设计决策 | 动机 | 效果 |
|---------|------|------|
| 移除 initialize/initialized 握手 | 减少每次会话的额外 RTT 和状态开销 | 工具调用从 2 次 HTTP 请求降为 1 次 |
| 移除 Mcp-Session-Id header | 消除服务端会话状态管理 | 任意请求可路由到任意后端实例 |
| 引入 MCP-Protocol-Version / Mcp-Method / Mcp-Name HTTP headers | 让网关层无需解析 JSON body 即可路由 | 支持标准 HTTP 网关/速率限制器/WAF 直接基于 Header 做决策 |
| clientInfo 移入 _meta 字段 | 在去状态化的同时保留客户端身份 | 每个请求自描述，服务端可审计 |
| 引入 server/discover RPC | 替代 initialize 的能力发现功能 | 可选调用，非强制握手 |
| Multi Round-Trip Requests (MRTR) | 替代服务端发起的采样/elicitation 流 | 消除持续双向流的需求 |
| List 响应携带 ttlMs + cacheScope | 减少客户端重复拉取 | 工具目录可缓存，上游 prompt 缓存稳定 |
| 正式废弃 DCR，转向 CIMD | 提升 OAuth 安全性 | 符合 RFC 规范，修复 CLI 客户端 redirect 问题 |

### 协议对比：有状态 vs 无状态

**旧版（Legacy MCP）— 两次 HTTP 请求：**

```
POST /mcp HTTP/1.1
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-11-25",
    "capabilities": {},
    "clientInfo": {"name": "my-app", "version": "1.0"}
  }
}
→ 返回 Mcp-Session-Id: 1868a90c-3a3f-4f5b

POST /mcp HTTP/1.1
Mcp-Session-Id: 1868a90c-3a3f-4f5b
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {"name": "search", "arguments": {"q": "otters"}}
}
```

**新版（Stateless MCP）— 单次 HTTP 请求：**

```
POST /mcp HTTP/1.1
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: search
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "search",
    "arguments": {"q": "otters"},
    "_meta": {
      "io.modelcontextprotocol/clientInfo": {
        "name": "my-app",
        "version": "1.0"
      }
    }
  }
}
```

### 架构/信息流图

```
                    ┌─────────────────────────────────────────────┐
                    │              Load Balancer (Round-Robin)     │
                    └──────────────┬──────────────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
        ┌─────▼─────┐      ┌─────▼─────┐      ┌─────▼─────┐
        │  MCP Server│      │  MCP Server│      │  MCP Server│
        │  Instance A │      │  Instance B │      │  Instance C │
        │ (No State)  │      │ (No State)  │      │ (No State)  │
        └─────┬─────┘      └─────┬─────┘      └─────┬─────┘
              │                    │                    │
              └────────────────────┼────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │           MCP Client                │
                    │  Headers:                           │
                    │    MCP-Protocol-Version: 2026-07-28 │
                    │    Mcp-Method: tools/call           │
                    │    Mcp-Name: search                 │
                    │  Body: _meta carries clientInfo     │
                    └─────────────────────────────────────┘

  关键变化：每个请求自包含，无需 session 亲和性，
  网关可直接基于 Mcp-Method / Mcp-Name 做路由和审计
```

### 其他重要变更

| 变更项 | 状态 | 说明 |
|--------|------|------|
| Roots / Sampling / Logging | 已废弃（12 个月过渡期） | 新实现不应采用 |
| HTTP+SSE 传输 | 已废弃（12 个月过渡期） | 推荐使用 Streamable HTTP |
| Tasks | 从实验性核心移入扩展 | 变为 `io.modelcontextprotocol/tasks` 扩展 |
| 废弃政策 | 新引入 | 12 个月最短过渡窗口 |
| RFC 9207 iss 参数验证 | 强制 | 关闭授权服务器混淆漏洞 |

## 实用评估

### 什么场景值得用

- **需要水平扩展的 MCP 服务器**：无状态设计意味着你可以直接在前端加一个标准 round-robin 负载均衡器，无需 Redis 等共享存储来管理会话状态。AWS 的 Swami Sivasubramanian 在官方博客中明确表示，Amazon Bedrock AgentCore 已支持在标准可扩展基础设施上部署 MCP 服务器。
- **构建 MCP 客户端工具**：Simon Willison 在一周内用 Codex 辅助构建了三个 MCP 工具（mcp-explorer、datasette-mcp、llm-mcp-client），这本身就证明了新规范大幅降低了实现门槛。
- **网关层审计和路由**：`Mcp-Method` 和 `Mcp-Name` 作为 HTTP Header 暴露，使得 WAF、速率限制器、API 网关可以直接基于 Header 做决策，无需解析 JSON body。
- **小模型驱动 MCP 工具**：Simon 指出，MCP 工具的简单性使得笔记本电脑上的小模型也能合理驱动它们，而通用 Agent（需要 shell + curl）则要求更强的模型能力。

### 什么场景不值得用

- **严重依赖 session ID 的遗留实现**：如果你的 MCP 服务器/客户端深度绑定了 `Mcp-Session-Id` 机制，迁移成本不低。官方提供了 12 个月过渡期，但需要主动规划。
- **需要服务端主动推送的场景**：MRTR 虽然替代了服务端发起的采样/elicitation 流，但交互模式从「推送」变为「轮询+重试」，对延迟敏感的场景可能需要评估。
- **仅需要简单 Skills 的场景**：如果你的 Agent 只需要执行预定义的脚本或命令序列，Anthropic 的 Skills 机制可能更轻量——这也是为什么 Simon 之前一度认为 MCP 被 Skills 超越。

### 迁移成本

| 迁移项 | 工作量 | 说明 |
|--------|--------|------|
| 移除 session 管理代码 | 中 | 删除 initialize/initialized 流程，将 clientInfo 移入 _meta |
| 更新 HTTP Header | 低 | 添加 `MCP-Protocol-Version`、`Mcp-Method`、`Mcp-Name` headers |
| 迁移到 Streamable HTTP | 中 | 如果当前使用 HTTP+SSE（已废弃），需迁移到 Streamable HTTP |
| 处理废弃的 Roots/Sampling/Logging | 中至高 | 取决于是否使用了这些已废弃的功能 |
| OAuth 授权流程更新 | 低 | 如果已使用标准 OAuth，主要是添加 RFC 9207 iss 验证 |

官方 SDK（TypeScript、Python、Go、C#）已全部更新到 2026-07-28 规范，并提供了详细的迁移说明。Rust SDK 也在 beta 中支持新规范。

## 对你的意义

MCP 2.0 的无状态化是协议走向生产级基础设施的关键一步。对 Ken 的 AI 应用开发方向（Agent + UI）有几个值得关注的信号：

1. **MCP 作为 Agent 工具集成标准的地位进一步巩固**。无状态设计消除了规模化部署的最大障碍，AWS 的背书（Bedrock AgentCore 支持）更是企业级采用的强力信号。这与假设 A-001（MCP 成为 AI Agent 工具集成事实标准）高度一致。

2. **Simon Willison 工具链的可复用性**。mcp-explorer 是一个通用的 MCP 服务器探测 CLI 工具，可以用 `uvx` 直接运行无需安装。如果 Ken 需要在项目中调试或测试 MCP 服务器，这是一个现成的好工具。datasette-mcp 则展示了如何将 SQL 数据库通过 MCP 暴露给 Agent——如果你的 RAG pipeline 需要数据库查询能力，这个模式值得参考。

3. **小模型 + MCP 的组合可能是一个被低估的方向**。Simon 提到小模型在笔记本上也能驱动 MCP 工具，这意味着不一定需要最强的推理模型来构建 Agent 应用。对于成本敏感的场景，这是一个值得探索的路径。

**建议**：立即关注 MCP 2.0 的 SDK 迁移指南，特别是如果你当前有基于 MCP 的项目。mcp-explorer 值得装来试玩，熟悉新协议的交互模式。

## 关键代码/配置片段

### mcp-explorer：零安装 MCP 探测

```bash
# 列出远程 MCP 服务器的所有工具
uvx mcp-explorer list https://agentic-mermaid.dev/mcp

# 查看某个工具的详细 JSON schema
uvx mcp-explorer inspect render_svg

# 直接调用工具并传递参数
uvx mcp-explorer call \
  https://agentic-mermaid.dev/mcp \
  render_svg \
  -a source 'graph TD; A-->B' \
  -a options '{"padding":24}'
```

### datasette-mcp：为 Datasette 实例添加 MCP 端点

```bash
# 安装插件后，任何 Datasette 实例自动获得 /-/mcp 端点
# 提供三个工具：list_databases(), get_database_schema(), execute_sql()
# 在 ChatGPT/Claude 中配置该端点，Agent 即可直接查询你的数据库
```

### llm-mcp-client：LLM CLI 的 MCP 集成

```bash
llm install llm-mcp-client
llm -T 'MCP("https://datasette.simonwillison.net/-/mcp")' 'count the notes'
# 输出: There are 151 notes.
```

### MCP 2.0 无状态请求格式（官方规范）

```
POST /mcp HTTP/1.1
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: search
Content-Type: application/json

{"jsonrpc":"2.0","id":1,"method":"tools/call",
 "params":{"name":"search","arguments":{"q":"otters"},
  "_meta":{"io.modelcontextprotocol/clientInfo":
    {"name":"my-app","version":"1.0"}}}}
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | MCP 2.0 无状态化消除了规模化部署的最大障碍，AWS Bedrock AgentCore 已原生支持；Tier 1 SDK 月下载量近 5 亿次，生态势头强劲 |

---
[← Back to Deep Dives](./README.md)
