---
auto_generated: true
generated_at: "2026-08-02T03:38:20Z"
source_url: "https://blog.modelcontextprotocol.io/posts/2026-07-28/"
signal_type: "significant_update"
---
# MCP 2026-07-28 规范：无状态核心与受控扩展系统 (The 2026-07-28 MCP Specification: Stateless Core & Controlled Extensions)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-02
>
> **项目/工具**: Model Context Protocol (MCP)
> **链接**: https://blog.modelcontextprotocol.io/posts/2026-07-28/
> **核心定位**: MCP 史上最大版本修订，将协议从双向有状态模型改造为无状态请求/响应模型，所有 MCP 客户端和服务器均需适配

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：MCP 2026-07-28 是协议诞生以来最重要的版本修订，核心变革是将整个协议从有状态双向流改造为无状态 HTTP 请求/响应模型。
- **現在值得用嗎**：是——如果你正在生产环境部署 MCP 服务器或构建 Agent 工具链，新规范解决了可扩展性和可靠性的根本瓶颈。
- **適合場景**：企业级 MCP 服务器集群部署、需要负载均衡的 Agent 工具网关、需要长期运行任务的 Agent 工作流
- **不適合場景**：仅做本地原型验证的场景（旧版仍可工作 12 个月过渡期）；依赖 legacy HTTP+SSE transport 的旧实现
- **與前版核心差異**：从「每个连接绑定一个 session」变为「每个请求自描述、可路由到任意实例」，与 REST API 的扩展模型对齐

## 是什么 / 解决什么问题

MCP（Model Context Protocol）是 Anthropic 于 2025 年初推出的开放标准，旨在统一 AI Agent 与外部工具/数据源之间的通信协议。截至 2026 年 7 月，Tier 1 SDK 月下载量接近 **5 亿次**，TypeScript 和 Python SDK 总下载量均突破 **10 亿次**。

然而，早期版本的 MCP 协议有一个根本性限制：**有状态的双向传输**。每个客户端连接需要建立 session（通过 `initialize/initialized` 握手），所有后续请求必须路由到同一个 server 实例。这意味着：

1. **无法用普通 round-robin 负载均衡**——需要 sticky session 或共享存储
2. **服务器水平扩展困难**——实例间需要状态同步
3. **连接中断后恢复复杂**——session 丢失意味着所有上下文丢失

2026-07-28 规范直接解决这些问题：**每个请求现在都是自描述的**，携带协议版本、客户端身份和能力信息。任何请求都可以落到 round-robin 负载均衡器后面的任意实例上，无需共享存储。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 旧版（2025-11 及之前） | 新版（2026-07-28） | 理由 |
|----------|----------------------|-------------------|------|
| Session 管理 | `initialize/initialized` 握手 + `Mcp-Session-Id` 头 | 移除，每个请求独立 | 支持水平扩展和负载均衡 |
| 请求自描述 | 依赖 session 上下文 | `_meta` 字段携带 clientInfo + 协议版本 | 任何请求可路由到任意实例 |
| HTTP 路由 | 需解析 JSON body | `Mcp-Method` 和 `Mcp-Name` 标准 HTTP 头 | 网关/WAF/限流器可直接基于 header 路由 |
| 缓存策略 | 无标准缓存机制 | `ttlMs` + `cacheScope` 字段 | 客户端可缓存工具目录，reconnect 后 prompt cache 保持稳定 |
| 双向流 | 需要持 open stream 做 server→client 请求 | Multi Round-Trip Requests (MRTR) | 移除持久连接需求，兼容无状态模型 |
| 扩展机制 | 实验性 core 内扩展 | 正式 Extensions Framework | 受控演进，Tasks/MCP Apps/EMA 作为扩展 |
| 授权安全 | DCR 为主 | RFC 9207 issuer 验证 + CIMD 替代 DCR | 修复授权服务器混淆漏洞，CLI/desktop 应用 OAuth 重定向问题 |
| 弃用政策 | 无明确窗口 | 12 个月最小过渡期 | 企业可计划升级而非被动响应 |

### 架构/信息流图

```
旧版（有状态）:
  Client ──[initialize/initialized]──→ Server (建立 session)
  Client ──[Mcp-Session-Id: xyz]──→ Server (同一实例)
  Client ──[Mcp-Session-Id: xyz]──→ Server (同一实例)
  ❌ 需要 sticky session 或共享存储

新版（无状态）:
  Client ──[POST /mcp + _meta + Mcp-Method + Mcp-Name]──→ [LB] ──→ Server Instance A
  Client ──[POST /mcp + _meta + Mcp-Method + Mcp-Name]──→ [LB] ──→ Server Instance B
  ✅ 每个请求自包含，round-robin 即可

MRTR（多轮次请求）:
  Client ──[tools/call: "book_flight"]──→ Server
  Server ──[resultType: "input_required", requests: [...]]──→ Client
  Client ──[retries with inputResponses: {...}]──→ Server
  Server ──[final result]──→ Client
  ✅ 无需持久双向流，交互确认在无状态模型下完成
```

### 关键变更详解

**1. 无 Session 请求格式**

新规范下的 HTTP 请求示例（来自官方文档）：

```http
POST /mcp HTTP/1.1
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: search

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

关键变化：`Mcp-Method` 和 `Mcp-Name` 作为标准 HTTP header，使网关、WAF、限流器无需解析 JSON body 即可路由和计量。

**2. 应用层状态 vs 传输层状态**

协议层移除 session 不意味着应用层不能携带状态。官方建议：如果服务器需要在多次调用间保持状态，从工具中显式 mint 一个 handle，让模型将其作为参数在工具间传递。官方原话：

> "We found this works better than session state hidden in the transport — the model can see the handle and thread it between tools."

这是一个重要的设计哲学转变：**状态显式化**，让 LLM 能看到和管理状态句柄，而非隐藏在传输层。

**3. 缓存友好的列表响应**

`tools/list`、`prompts/list`、`resources/list` 响应现在携带 `ttlMs` 和 `cacheScope` 字段。这对 Agent 系统意义重大：
- 客户端可以缓存工具目录，减少重复查询
- Reconnect 后 prompt cache 保持稳定（工具列表顺序确定性）
- 降低 LLM 调用的 token 消耗

**4. 授权安全加固**

| 变更 | 说明 |
|------|------|
| RFC 9207 issuer 验证 | 授权服务器必须返回 `iss` 参数，客户端在兑换 code 前必须验证——修复授权服务器混淆漏洞 |
| `application_type` 设置 | DCR 期间设置 `application_type`，解决 CLI/desktop 应用 localhost 重定向被拒问题 |
| 凭证绑定 issuer | 客户端凭证绑定到签发者，不可跨授权服务器复用 |
| DCR → CIMD | Dynamic Client Registration 正式弃用，转向 Client ID Metadata Documents |

**5. Tasks 扩展**

Tasks 从实验性 core 移入 `io.modelcontextprotocol/tasks` 扩展，提供：
- 基于轮询的 `tasks/get`
- 新增 `tasks/update`
- 变更通知从 HTTP GET 端点迁移到 `subscriptions/listen` 流

AWS 贡献的 Tasks 扩展支持可靠的长时间运行 Agent，这是企业级场景的关键能力。

**6. 弃用项**

以下组件被正式弃用（12 个月过渡期）：
- Roots、Sampling、Logging（仍可用，新实现不应采用）
- Legacy HTTP+SSE transport（一年过渡期）

### SDK 支持

所有四个 Tier 1 SDK 已同步更新：
- TypeScript SDK: https://github.com/modelcontextprotocol/typescript-sdk
- Python SDK: https://github.com/modelcontextprotocol/python-sdk
- Go SDK: https://github.com/modelcontextprotocol/go-sdk
- C# SDK: https://github.com/modelcontextprotocol/csharp-sdk

Rust SDK 在 beta 中支持新规范。

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| **企业级 MCP 服务器集群** | 无状态核心使 round-robin 负载均衡成为可能，无需 sticky session 或共享存储 |
| **Agent 工具网关/代理层** | `Mcp-Method`/`Mcp-Name` header 使网关可直接路由和计量，无需解析 JSON |
| **长时间运行的 Agent 工作流** | Tasks 扩展提供可靠的后台任务支持，适合审批、数据导入等异步场景 |
| **多租户 SaaS MCP 服务** | 授权加固（RFC 9207、CIMD）满足企业安全合规要求 |
| **边缘/Serverless 部署** | 无状态 + 冷启动友好，Cloudflare Workers / Netlify 等平台的 MCP 部署门槛大幅降低 |
| **需要工具缓存的 Agent** | 缓存友好的列表响应减少重复 token 消耗 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| **本地原型验证** | 旧版仍有 12 个月过渡期，原型阶段升级成本可能超过收益 |
| **高度依赖 legacy SSE transport 的现有实现** | 需要迁移到 Streamable HTTP，过渡期内仍可用但不再获得新功能 |
| **仅使用 Roots/Sampling/Logging 的简单场景** | 这些模块被弃用，新实现不应采用，但现有代码可继续工作 12 个月 |
| **对迁移成本敏感且无扩展需求的团队** | 如果当前部署规模小、无水平扩展需求，旧版已够用 |

### 迁移成本

| 迁移项 | 工作量估算 | 说明 |
|--------|-----------|------|
| **移除 session 管理代码** | 中等（1-3 天） | 移除 `initialize/initialized` 握手逻辑和 `Mcp-Session-Id` 处理 |
| **适配请求格式** | 低（0.5-1 天） | 在 `_meta` 中添加 clientInfo，添加 `Mcp-Method`/`Mcp-Name` header |
| **MRTR 适配** | 中等（2-5 天） | 如果使用了 elicitation/sampling，需要改造为多轮次请求模式 |
| **授权流程改造** | 中高（3-7 天） | DCR → CIMD 迁移，RFC 9207 issuer 验证集成 |
| **Tasks 迁移** | 低-中（1-3 天） | 如果使用了实验性 Tasks，迁移到扩展模块 |
| **SDK 版本升级** | 低（0.5-1 天） | 升级 SDK 到支持 2026-07-28 的版本 |

**总估算**：中等规模实现（使用 session + elicitation + 授权）约 **1-2 周**工作量。仅做基本工具调用的简单实现约 **1-2 天**。

Manufact 团队的案例：他们使用新 SDK v2（驱动 mcp-use 框架）将包大小减少了约 **83%**，同时速度提升了 **25%**，这得益于新的 client-server split 架构。

## 对你的意义

如果你正在构建或部署 AI Agent 工具链，这个规范修订是一个**重要的基础设施成熟信号**：

1. **MCP 正在从「开发者玩具」变成「生产级基础设施」**。Alex Salazar（Anthropic 合作伙伴 CEO）的评论很准确："The community has chosen to do the hard work rather than paper over the gaps."

2. **对你的 Agent-Playbook 意义**：MCP 作为 Agent 工具集成的开放标准，其无状态化使得 Agent 架构中的工具层可以像微服务一样水平扩展。这与 Agent 框架中 "tool calling" 的工程化趋势一致。

3. **建议**：
   - 如果你正在设计新的 Agent 工具集成层：**直接基于 2026-07-28 规范设计**
   - 如果你有现有 MCP 部署：**制定 3-6 个月迁移计划**，利用 12 个月过渡期
   - 关注 Tasks 扩展：长时间运行任务是企业 Agent 的关键能力缺口

## 关键代码/配置片段

### 新规范请求格式（官方示例）

```http
POST /mcp HTTP/1.1
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: search

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

### MRTR 交互确认流程

```
// 第一轮：工具调用需要用户确认
POST /mcp
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {"name": "delete_data", "arguments": {"table": "users"}}
}

// 响应：需要输入
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "resultType": "input_required",
    "requests": [
      {"type": "elicitation", "message": "确认删除 users 表？"}
    ]
  }
}

// 第二轮：客户端重试并附带回答
POST /mcp
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "delete_data",
    "arguments": {"table": "users"},
    "inputResponses": {"confirm_delete": true}
  }
}
```

> TODO: 官方完整迁移指南和 SDK 具体 API 变更细节需参考各 SDK 仓库的 migration notes。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 月下载量近 5 亿、四大 Tier 1 SDK 同步更新、AWS/Google/Microsoft/Cloudflare 等全生态支持，无状态化使 MCP 具备企业级可扩展性，进一步巩固其标准地位 |

---
[← Back to Deep Dives](./README.md)
