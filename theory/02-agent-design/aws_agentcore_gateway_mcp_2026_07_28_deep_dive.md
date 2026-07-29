---
auto_generated: true
generated_at: "2026-07-29T05:48:01Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/"
signal_type: "blog_post"
---
# AWS AgentCore Gateway 率先适配 MCP 2026-07-28 新规范 (AWS AgentCore Gateway Supports MCP 2026-07-28 Spec)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-29
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway
> **链接**: https://aws.amazon.com/blogs/machine-learning/how-agentcore-gateway-supports-the-mcp-2026-07-28-spec/
> **核心定位**: MCP 协议自发布以来最大规模修订（2026-07-28），将协议从有状态改为无状态；AWS AgentCore Gateway 是首个官方适配的云端 MCP 网关基础设施

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：MCP 2026-07-28 是协议史上最大改版，核心是将 MCP 从有状态（session-bound）改为无状态（stateless），使其能跑在标准 HTTP 基础设施上；AWS AgentCore Gateway 是首个官方适配的云端网关
- **現在值得用嗎**：是 — 如果你在用或计划用 MCP 做 Agent 工具集成，这是一个架构级升级，且升级是 opt-in、向后兼容的
- **適合場景**：多 Agent 共享 MCP 服务端点、企业级水平扩展、需要 OpenTelemetry 全链路追踪、需要标准化错误处理
- **不適合場景**：依赖旧版 session 机制传递应用状态的遗留系统（需改造）；不依赖 MCP 协议的直连 Agent 架构
- **與前版核心差異**：从 Mcp-Session-Id 绑定到每请求自包含；从 SSE 长连接到 Multi Round-Trip Requests；从隐式扩展到 governed extensions 体系

## 是什么 / 解决什么问题

MCP（Model Context Protocol）自 2025 年推出以来，已成为 AI Agent 工具集成的事实标准。然而，早期版本采用有状态的 Streamable HTTP 交互模式：每次连接需要 initialize/initialized 握手，服务端颁发 `Mcp-Session-Id`，后续请求必须携带该 ID。这种设计在单实例部署时运行良好，但在企业级水平扩展场景下暴露出根本性瓶颈 — 负载均衡器需要 sticky sessions，或者需要共享 session store。

2026-07-28 规范是 MCP 协议自发布以来最大、最显著的修订。它将 MCP 从有状态协议改造为无状态协议，使远程 MCP 服务端点本质上变成标准 HTTPS 端点，可以直接跑在普通 HTTP 基础设施上。

与此同时，该版本引入了受治理的扩展体系（governed extensions）、强化了 OAuth 2.0 / OIDC 授权对齐、建立了 feature lifecycle policy 以防止未来破坏性变更。AWS 在规范发布当天即宣布 AgentCore Gateway 支持新规范，体现了 MCP 在企业基础设施中的战略地位。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 旧版行为 | 2026-07-28 行为 | 动机 |
|----------|---------|----------------|------|
| 协议状态 | 有状态，需 initialize 握手 + Mcp-Session-Id | 无状态，每请求自包含 | 消除水平扩展的 sticky session 依赖 |
| 方法路由 | JSON-RPC body 内部，中间件需解析 body | Mcp-Method / Mcp-Name 标准 HTTP header | 让 LB/API Gateway/限流器在 HTTP 层路由 |
| 缓存机制 | 无，需维持 SSE 连接监听变更 | ttlMs + cacheScope 响应头 | 允许客户端缓存 tools/list 等结果 |
| 分布式追踪 | 非正式实践 | W3C Trace Context (traceparent/tracestate/baggage) 正式纳入 | 全链路 OpenTelemetry 集成 |
| 服务端→客户端交互 | SSE 长连接推送 | Multi Round-Trip Requests (MRTR) + requestState token | 无状态前提下的交互模式 |
| 扩展治理 | 非正式概念 | reverse-DNS ID + 独立仓库 + SEP Extensions Track | 避免新功能挤占核心规范 |
| 错误处理 | 几乎全部 HTTP 200 + body 内错误码 | 传输层用真实 HTTP 状态码，应用层留在 body | 分离传输/应用层，便于监控告警 |
| Schema 支持 | 部分 JSON Schema | 完整 JSON Schema 2020-12 (oneOf/anyOf/allOf/`ref/`defs) | 更精确的工具参数表达 |

### 架构/信息流图

```
旧版 (有状态):
  Agent --> [initialize 握手] --> MCP Server
  Agent --> [Mcp-Session-Id: xxx] --> MCP Server (必须路由到同一实例)
  Agent --> [Mcp-Session-Id: xxx] --> MCP Server (sticky session 依赖)

新版 (无状态):
  Agent --> [MCP-Protocol-Version + Mcp-Method + _meta] --> MCP Server (任意实例)
  Agent --> [MCP-Protocol-Version + Mcp-Method + basket_id] --> MCP Server (任意实例)
  
  每个请求自包含，可被标准 LB 负载均衡，无需 session 亲和性

多版本共存:
  Gateway supportedVersions: ["2025-11-25", "2026-07-28"]
  旧客户端 --> 请求 2025-11-25 --> 旧版行为
  新客户端 --> 请求 2026-07-28 --> 新版行为
  两者互不干扰，独立升级节奏
```

### AgentCore Gateway 在架构中的位置

```
                    ┌─────────────────────────────────────┐
                    │         Amazon Bedrock AgentCore      │
                    │                                     │
  Agent Framework   │   ┌───────────────────────────┐     │
  (LangChain/       │   │    AgentCore Gateway      │     │
   Custom Code)     │   │                           │     │
       │            │   │  - 多版本协议适配          │     │
       │  MCP Call  │──>│  - Lambda/API/MCP 聚合    │     │
       │            │   │  - IAM/OAuth 鉴权          │     │
       │            │   │  - 协议版本翻译 (跨版本)   │     │
       │            │   └───────────┬───────────────┘     │
       │            │               │                     │
       │            │    ┌──────────┼──────────┐          │
       │            │    ▼          ▼          ▼          │
       │            │  Lambda     REST API   MCP Server   │
       │            └─────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **多 Agent 共享 MCP 端点**：无状态协议意味着多个 Agent 实例可以共享同一个 MCP 服务端点，LB 自动分发请求，无需 sticky session 配置
- **企业级水平扩展**：MCP 服务端点可以像普通 HTTPS 服务一样水平扩展，配合标准 HTTP 基础设施（ALB/NLB/API Gateway）
- **全链路可观测性需求**：W3C Trace Context 正式纳入规范，Agent → MCP Client → Gateway → 下游服务的完整调用链可以渲染为统一的 OpenTelemetry span tree
- **渐进式升级场景**：Gateway 同时支持多个协议版本，新旧客户端可以共存，升级节奏完全自主控制
- **需要标准化错误监控**：传输层错误返回真实 HTTP 状态码（404/400），可以在 HTTP 层直接做监控告警，无需解析 JSON-RPC body

### 什么场景不值得用

- **不依赖 MCP 的直连架构**：如果 Agent 直接调用 LLM API 或自定义工具接口，不经过 MCP 协议层，此升级与你无关
- **重度依赖旧版 session 传递应用状态**：旧版中有些实现用 Mcp-Session-Id 隐式携带应用状态，新版要求显式传递 ID（如 basket_id 作为工具参数），需要代码改造
- **仅使用 stdio 传输的本地 Agent**：stdio 传输不受此变更影响，升级收益有限
- **对 MCP Extensions 无需求的简单场景**：governed extensions 体系对简单工具调用场景是过度设计

### 迁移成本

| 迁移项 | 估计工作量 | 说明 |
|--------|-----------|------|
| Gateway 配置更新 | 极低（单条 API 调用） | `UpdateGateway` 添加 2026-07-28 到 supportedVersions |
| 客户端 SDK 升级 | 低-中 | 需确认所用 SDK 已支持 2026-07-28；Tier 1 SDK 应在 RC 窗口期内完成 |
| 移除 session 依赖 | 中 | 审计代码中依赖 Mcp-Session-Id 传递应用状态的逻辑，改为显式参数传递 |
| 错误码审计 | 低 | 搜索代码中匹配 `-32002` 的路径，改为 `-32602` |
| 废弃功能清理 | 低-中 | Roots/Sampling/Logging 三个特性被 advisory deprecation，12 个月内仍可用，但新实现不应依赖 |
| elicitation/sampling 迁移 | 中 | 从 SSE 长连接模式迁移到 MRTR + requestState 模式 |

## 对你的意义

作为 Agent + UI 方向的开发者，这个变化对你的核心意义在于：**MCP 正在从"原型协议"进化为"企业级基础设施协议"**。

1. **MCP 作为 Agent 工具集成标准的地位进一步巩固** — AWS 作为最大云厂商第一时间适配，意味着 MCP 在企业基础设施中的接受度达到新高度。你的 Agent-Playbook 中 A-001 假设（MCP 成为 AI Agent 工具集成事实标准）获得强力支持。

2. **Agent 架构的可扩展性门槛降低** — 无状态 MCP 意味着你可以用标准 HTTP 基础设施（甚至 CDN）来部署 MCP 服务端点，不再需要为 session 亲和性做额外设计。这对多 Agent 协作场景尤其重要。

3. **可观测性成为一等公民** — W3C Trace Context 的正式纳入意味着 MCP 调用链可以无缝接入现有的 OpenTelemetry 基础设施。这对于生产级 Agent 系统的 debug 和性能优化至关重要。

**建议**：如果你的项目使用或计划使用 MCP，建议关注 SDK 升级进度，在测试环境先启用 2026-07-28 版本验证兼容性。不需要急于生产切换 — 多版本共存机制给了你充分的迁移窗口。

## 关键代码/配置片段

### 新请求格式（无状态）

```http
POST /mcp HTTP/1.1
MCP-Protocol-Version: 2026-07-28
Mcp-Method: tools/call
Mcp-Name: create_basket
Content-Type: application/json
Accept: application/json,text/event-stream

{"jsonrpc":"2.0","id":1,"method":"tools/call",
 "params":{"name":"create_basket","arguments":{},
  "_meta":{"io.modelcontextprotocol/clientInfo":{"name":"my-app","version":"1.0"}}}}
```

### 响应格式（结构化结果信封）

```json
{
  "resultType": "complete",
  "content": [{"type": "text", "text": "Created basket bsk_a1b2c3"}],
  "structuredContent": {"basket_id": "bsk_a1b2c3"},
  "isError": false
}
```

### Multi Round-Trip Request（服务端→客户端交互）

```json
{
  "resultType": "input_required",
  "inputRequests": {
    "confirm": {
      "method": "elicitation/create",
      "params": {
        "mode": "form",
        "message": "Delete 3 files?",
        "requestedSchema": {
          "type": "object",
          "properties": {"confirm": {"type": "boolean"}},
          "required": ["confirm"]
        }
      }
    },
    "requestState": "eyJzdGVwIjoxLCJmaWxlcyI6WyJhIiwiYiIsImMiXX0="
  }
}
```

### AgentCore Gateway 升级配置

```bash
# 1. 读取当前配置
aws bedrock-agentcore-control get-gateway \
  --gateway-identifier <gateway-id>

# 2. 添加 2026-07-28（注意：supportedVersions 是完整替换，非追加）
aws bedrock-agentcore-control update-gateway \
  --name <gateway-name> \
  --role-arn <gateway-role-arn> \
  --protocol-type MCP \
  --authorizer-type <gateway-authorizer-type> \
  --gateway-identifier <gateway-id> \
  --protocol-configuration '{
    "mcp": {
      "supportedVersions": ["2025-11-25", "2026-07-28"]
    }
  }'

# 3. 验证新版本生效
curl -s https://<your-gateway-endpoint>/mcp \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json,text/event-stream" \
  -H "MCP-Protocol-Version: 2026-07-28" \
  -H "Mcp-Method: tools/list" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
```

### 错误处理对比

| 场景 | 旧版 (2025-*) | 新版 (2026-07-28) |
|------|-------------|-------------------|
| 未知方法 | HTTP 200 + JSON-RPC error body | HTTP 404 |
| 不支持的协议版本 | 因实现而异 | HTTP 400, code -32022 |
| Header 绑定字段缺失 | 因实现而异 | HTTP 400, code -32020 |
| 缺少必需客户端能力 | 不适用 | code -32021 |

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AWS 作为最大云厂商在规范发布当天即完成适配，MCP 的企业基础设施地位进一步巩固；无状态改造消除了规模化部署的最大障碍 |

---
[← Back to Deep Dives](./README.md)
