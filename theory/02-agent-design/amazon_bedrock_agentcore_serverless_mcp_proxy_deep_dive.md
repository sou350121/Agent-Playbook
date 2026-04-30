---
auto_generated: true
generated_at: "2026-04-30T03:32:35Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/run-custom-mcp-proxies-serverless-on-amazon-bedrock-agentcore-runtime/"
signal_type: "blog_post"
---
# Amazon Bedrock AgentCore 支持 Serverless MCP Proxy 部署 (Serverless MCP Proxy on Amazon Bedrock AgentCore Runtime)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-30
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime + MCP Proxy
> **链接**: https://aws.amazon.com/blogs/machine-learning/run-custom-mcp-proxies-serverless-on-amazon-bedrock-agentcore-runtime/
> **核心定位**: AWS 首次在 serverless 托管环境中原生支持 MCP 协议，允许企业在 MCP 协议层注入自定义治理逻辑（PII 脱敏、审计日志、访问控制），而无需修改上游 MCP 服务器或客户端。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：AWS 在 Bedrock AgentCore Runtime 上原生支持部署 MCP Proxy，让企业可以在 MCP 协议层注入自定义治理逻辑
- **現在值得用嗎**：是 — 如果你已经在 AWS 上运行 AI Agent 并需要通过 MCP 连接工具，这是目前最省心的企业级治理方案
- **適合場景**：企业级 MCP 工具集成（需要审计/合规/PII 脱敏）、混合环境 MCP 代理、已有自定义 MCP 过滤逻辑需复用
- **不適合場景**：非 AWS 环境、不需要自定义治理的简单 MCP 调用、对延迟极度敏感的场景（proxy 增加一跳）
- **與 Lambda Interceptor 核心差異**：Lambda Interceptor 绑定在 Gateway 请求路径上；MCP Proxy 是独立 MCP 服务器，可连接任意上游 MCP 端点（Gateway、自建服务器、第三方服务），更灵活但多一跳

## 是什么 / 解决什么问题

MCP（Model Context Protocol）已经成为 AI Agent 工具集成的事实标准协议。但在生产环境中，Agent 通过 MCP 调用工具时面临一个治理难题：如何在协议层注入自定义控制逻辑？

具体来说，企业需要：
- 在工具调用到达后端系统前，对输入参数做 PII（个人身份信息）脱敏或 tokenization
- 生成符合特定格式的审计日志（audit trail）
- 在协议层对敏感数据进行 redaction
- 对特定工具做细粒度的访问控制（哪些 Agent 可以调用哪些工具）

AWS 之前提供了 **Lambda Interceptor** 方案 — 在 AgentCore Gateway 的请求路径上挂载 Lambda 函数。但这个方案有两个局限：
1. 必须将自定义逻辑重构为 Lambda 函数，对于已有紧密耦合内部库或本地合规系统的组织来说迁移成本高
2. 绑定在 Gateway 上，无法用于非 Gateway 的 MCP 端点（自建 MCP 服务器、第三方 MCP 服务）

这次的 **Serverless MCP Proxy** 方案解决了这两个问题：它作为一个独立的 MCP 服务器运行在 AgentCore Runtime 上，可以连接任意上游 MCP 端点，同时保持自定义逻辑的自包含性。

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| Proxy 实现框架 | FastMCP (Python) | 动态发现上游工具并重新注册，无需预定义工具 schema |
| 部署方式 | AgentCore Runtime (serverless) | 自动扩缩容、内置 CloudWatch/OpenTelemetry 可观测性 |
| 认证模式 | IAM SigV4（默认）+ JWT/OAuth 2.0 | 覆盖 AWS 原生和跨云混合场景 |
| 代理模式 | 无状态（stateless） | 简化部署和扩缩容，每次请求独立处理 |
| 工具发现 | 启动时一次性 tools/list | 上游工具目录在运行时动态注册到本地 FastMCP |

### 三层架构

```
┌─────────────┐     MCP Request      ┌──────────────────┐     MCP Request      ┌──────────────────┐
│  MCP Client │ ──────────────────→ │  MCP Proxy       │ ──────────────────→ │  Upstream MCP    │
│  (Agent)    │                     │  (AgentCore      │                     │  Server          │
│             │ ←────────────────── │   Runtime)       │ ←────────────────── │  (Gateway/Self-  │
└─────────────┘     MCP Response    │   Serverless)    │     MCP Response    │    hosted/3rd)   │
                                    └──────────────────┘                     └──────────────────┘
                                         │                                          │
                                    AgentCore Identity                      Credential Providers
                                    (IAM / JWT)                             (OAuth / API Keys)
```

**关键设计洞察**：Proxy 不定义任何工具。它在启动时向上游发送 `tools/list` 请求，拿到完整工具目录后，为每个工具在本地 FastMCP 注册一个同名 handler。这个 handler 只做一件事：把 `tools/call` 请求转发给上游并返回结果。

这意味着：
- 上游工具目录变化时，Proxy 需要重启才能发现新工具（这是当前实现的局限）
- Proxy 对客户端完全透明 — 客户端看到的工具目录和直接连接上游完全一致
- 自定义逻辑可以插入到 handler 函数中（转发前/转发后），实现输入过滤、输出脱敏、审计日志等

### 逐层认证模型

这是该方案最精妙的设计 — 每一层独立认证，形成清晰的信任边界：

| 层级 | 认证方式 | 权限粒度 |
|------|----------|----------|
| Agent → MCP Proxy | AgentCore Identity | 控制哪些 Agent/Principal 可以调用 Proxy |
| MCP Proxy → Upstream Server | IAM SigV4 或 JWT/OAuth 2.0 | `bedrock-agentcore:InvokeGateway` 或 `InvokeAgentRuntime`，限定到具体 Gateway/Server |
| Upstream Server → Tools | AgentCore Identity Credential Providers | OAuth 2.0 tokens / API Keys，自动轮换 |

这种分层认证意味着即使 Proxy 被攻破，攻击者也只能使用 Proxy 被授予的有限权限访问上游，不会越权。

### 与 Lambda Interceptor 对比

| 维度 | Lambda Interceptor | Serverless MCP Proxy |
|------|-------------------|---------------------|
| 部署位置 | Gateway 请求路径 | 独立 MCP 服务器（AgentCore Runtime） |
| 上游兼容性 | 仅 Gateway | Gateway / 自建 MCP Server / 第三方 MCP 服务 |
| 代码形态 | Lambda 函数 | 标准 Python MCP Server（FastMCP） |
| 已有逻辑复用 | 需重构为 Lambda | 可直接复用（标准 MCP Server 代码） |
| 延迟 | 更低（无额外网络跳） | 多一跳（Proxy → Upstream） |
| 混合环境支持 | 不支持 | 支持（JWT 模式 + 任意上游） |
| 工具发现 | Gateway 原生管理 | 启动时 tools/list 动态注册 |

## 实用评估

### 什么场景值得用

- **企业级 MCP 工具治理**：需要在 MCP 协议层做 PII 脱敏、审计日志、输入验证。AWS 官方提供了 tokenization 示例代码，在 `_make_tool_handler` 函数中扫描 kwargs 替换 PII 为 reversible tokens，响应返回前再 detokenize。
- **合规驱动的场景**：金融、医疗等行业需要在协议层留审计 trail。Proxy 可以在每次 `tools/call` 前后记录结构化日志到 CloudWatch。
- **混合环境**：上游 MCP 服务器不在 AWS 上（自建或第三方），但 Agent 运行在 AWS 上。JWT 认证模式支持这种跨环境场景。
- **已有自定义 MCP 过滤逻辑**：组织内部已有与合规系统耦合的 MCP 过滤代码，不想重构为 Lambda。直接部署为 Proxy 即可。

### 什么场景不值得用

- **简单 MCP 调用**：如果 Agent 只需要调用几个 MCP 工具，不需要自定义治理逻辑，直接用 AgentCore Gateway 更简单。
- **对延迟极度敏感**：Proxy 增加一跳网络延迟（虽然 serverless 本身延迟不高，但多一次 HTTP 往返）。
- **非 AWS 环境**：整个方案依赖 AgentCore Runtime 和 AgentCore Identity，离开 AWS 生态无法使用。
- **频繁变更工具目录**：Proxy 启动时一次性发现工具，上游新增工具需要重启 Proxy。如果工具目录频繁变化，这是个问题。

### 迁移成本

从 Lambda Interceptor 迁移到 MCP Proxy：
- **代码重构**：需要将 Lambda 函数逻辑提取为标准 Python MCP Server 代码（FastMCP），预计 1-2 天
- **部署流程**：需要配置 Docker + AgentCore CLI，比 Lambda 部署多一步容器化，预计 0.5-1 天
- **认证配置**：IAM 模式基本零成本（继承 Runtime 的 IAM Role）；JWT 模式需要配置 Cognito User Pool，预计 0.5 天

从零开始部署（按 AWS 文档）：
- 克隆 GitHub 仓库 → 配置 `deploy_config.json` → 运行 `setup_and_deploy.py`，全程约 30 分钟

## 对你的意义

这个方案对 Ken 的意义在于：

1. **MCP 企业级落地信号明确**：AWS 作为最大云厂商，在 serverless 托管环境中原生支持 MCP 协议 — 这是对 A-001 假设（MCP 成为 AI Agent 工具集成事实标准）的强力支持。如果 Ken 在 Agent + UI 方向做企业级产品，MCP 治理层是必须考虑的设计要素。

2. **Agent 安全评估的实践参考**：Ken 关注 Agent 安全评估。这个 Proxy 模式展示了如何在协议层实现 PII 脱敏、访问控制、审计日志 — 这些正是企业采购 Agent 工具时的"硬要求"。MEMORY.md 中的假设 "Agent 安全评估 Q2 成采购硬要求" 在这个方案中得到了验证。

3. **架构参考价值**：即使 Ken 不直接使用 AWS，这个 "Proxy 模式" 的架构思想（在协议层注入自定义逻辑，与上下游解耦）可以应用到任何 MCP 部署场景。

**建议**：观望为主。如果 Ken 的项目部署在 AWS 上且需要 MCP 治理，值得试用；否则，关注这个架构模式即可，不必急于迁移。

## 关键代码/配置片段

### 部署配置 (deploy_config.json)

```json
{
  "agent_name": "my-mcp-proxy",
  "gateway_endpoint": "https://<your-gateway>.gateway.bedrock-agentcore.<region>.amazonaws.com/mcp",
  "region": "us-east-1",
  "iam_role_name": "MCPProxyServerRole",
  "auth_mode": "iam"
}
```

### Proxy 核心逻辑 (main.py 简化版)

```python
def _make_tool_handler(tool_name: str):
    """Create a tool handler function that forwards calls to the gateway."""
    def handler(**kwargs) -> str:
        # --- Tokenize: scan kwargs for PII and replace with tokens ---
        result = _send_gateway_request(
            "tools/call", {"name": tool_name, "arguments": kwargs}
        )
        content = result.get("content", [])
        # --- Detokenize: reverse tokens in content before returning ---
        if content and isinstance(content, list):
            texts = [c.get("text", str(c)) for c in content if isinstance(c, dict)]
            return "\n".join(texts) if texts else json.dumps(result)
        return json.dumps(result)
    return handler
```

这是 AWS 官方示例代码，展示了在 Proxy 中注入 PII tokenization 的最小代码量 — 只需在 `_send_gateway_request` 调用前后各加一段处理逻辑。

### 部署命令

```bash
# 一键部署
python3 setup_and_deploy.py

# 或手动部署
cd agentcore_deploy
agentcore configure --name my_proxy --entrypoint mcp_proxy/main.py \
  --execution-role <role-arn> --protocol MCP --requirements-file requirements.txt
agentcore launch --agent my_proxy \
  --env GATEWAY_ENDPOINT=https://<gateway-url>/mcp \
  --env AUTH_MODE=iam
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AWS 在 serverless 托管环境中原生支持 MCP 协议，并围绕 MCP 构建企业级治理体系 — 这是 MCP 成为事实标准的最强信号之一 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 该方案直接面向企业 MCP 工具治理需求（PII 脱敏、审计、访问控制），说明企业级 MCP 集成已是 AWS 的产品优先级 |

---
[← Back to Deep Dives](./README.md)
