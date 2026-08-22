---
auto_generated: true
generated_at: "2026-08-22T05:48:53Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/govern-ai-agent-tool-access-with-amazon-bedrock-agentcore-gateway/"
signal_type: "blog_post"
---
# Amazon Bedrock AgentCore Gateway：集中治理 Agent 工具访问权限 (Amazon Bedrock AgentCore Gateway: Centralized Governance for AI Agent Tool Access)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-22
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway
> **链接**: https://aws.amazon.com/blogs/machine-learning/govern-ai-agent-tool-access-with-amazon-bedrock-agentcore-gateway/
> **核心定位**: AWS 推出的托管式 Agent 网关服务，为 MCP 协议下的 AI Agent 工具调用提供统一安全入口、细粒度策略控制和全链路审计，解决企业部署 AI Agent 时"谁在访问什么、权限谁给的、凭证泄露怎么办"三大核心治理难题

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 为 AI Agent 的工具调用提供统一网关入口，集成认证、授权、审计、PII 过滤于一站，让企业不再靠手工管理 mcp.json 中的凭证
- **现在值得用吗**: 是 — 如果你的组织已有 10+ 用户在使用 Claude Code / Cursor / Kiro 等 MCP 客户端，且安全团队开始追问 Agent 权限问题
- **适合场景**: 企业级 MCP 部署治理、多团队 Agent 工具目录管理、合规审计需求（SOX/ISO 27001）、混合云 Agent 工具路由
- **不适合场景**: 个人开发者单用户场景（过度工程化）、非 AWS 云原生团队（深度绑定 AWS 生态）、需要跨云统一网关的场景
- **与竞品核心差异**: 相比 Kong Gateway + OPA 自建方案，AgentCore Gateway 提供托管式 MCP 原生支持 + Cedar 策略引擎 + Guardrails 集成的一体化体验，减少 3-4 个组件的运维负担

## 是什么 / 解决什么问题

当 AI Agent（Claude Code、Cursor、Kiro 等）通过 MCP 协议连接企业内部工具时，每个客户端都携带一份 `mcp.json` 配置文件，内含后端凭证和工具端点。一个 10 人团队连接 5 个内部 API，就意味着 50 组独立凭证被手工配置在各自的笔记本上——安全团队对这些凭证的存在、权限范围、泄露风险完全不可见。

AWS 将这个问题归纳为五种结构性故障模式：

| 故障模式 | 描述 | 典型表现 |
|---------|------|---------|
| **Credential Sprawl** | 凭证散落各处 | `mcp.json` 中明文存储生产数据库密码 |
| **Policy Drift** | 策略配置静默发散 | 10 个客户端 × 5 个 API = 50 处配置，一处变更需同步 50 次 |
| **Audit Gaps** | 审计盲区 | 无法回答"谁在何时调用了什么工具" |
| **Cost Opacity** | 成本无法归因 | 网关支出无法按团队/工具拆分 |
| **Shadow IT** | 影子集成 | 未经安全审查的 Agent 工具连接 |

传统的应对方式是"先建完整网关再放行 Agent 使用"，但这通常需要数月时间，而且往往构建的是错误的东西。AWS 提出的方案是**四阶段成熟度路径（Four-Scope Maturity Journey）**：每个阶段独立交付价值，只在下一个痛点出现时才推进到下一阶段。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 具体方案 | 理由 |
|---------|---------|------|
| **托管式 MCP 网关** | AgentCore Gateway 作为唯一入口 | 消除客户端直连后端，凭证不出 AWS |
| **Cedar 策略引擎** | 基于 Rust 的开源策略语言，RBAC + ABAC | 支持工具级和参数级细粒度控制，性能优于 OPA Rego |
| **渐进式成熟度** | 4 个 Scope 独立交付 | 避免"先建后跑"的长周期项目，Day 1 即可上线基础治理 |
| **原生 Guardrails 集成** | PII 过滤/Prompt 攻击检测内置于 Cedar 策略 | 无需额外部署 NeMo Guardrails 等独立组件 |
| **Dynamic Client Registration (DCR)** | 遵循 RFC 9728/8414，客户端自动注册 | 支持大规模客户端动态加入，无需手工维护 allowedClients |
| **OBO Token Exchange** | RFC 8693/7523 On-Behalf-Of 令牌交换 | 下游资源信任同一身份链时无需浏览器重定向完成 3LO |

### 四阶段成熟度对比

| 维度 | Scope 1: Connect | Scope 2: Control | Scope 3: Catalog | Scope 4: Harden |
|------|-----------------|-----------------|-----------------|----------------|
| **用户规模** | 1-20 试点 | 20-100 增长 | 100-1000 扩展 | 1000+ 企业级 |
| **认证方式** | M2M OAuth 2.0 + JWT | 用户级 SSO + DCR | 同上 + 资源发现 | 同上 |
| **授权粒度** | 粗粒度（认证即可） | 工具级 + 参数级 ABAC | 同上 + OPA 补充 | 同上 |
| **PII 保护** | 无 | Guardrails 内置 | Guardrails + OPA | Guardrails + OPA |
| **审计** | CloudWatch + CloudTrail | 全链路 OTel Span | 同上 + FinOps 归因 | 同上 + 治理仪表盘 |
| **工具注册** | 手工 CLI | 同上 | YAML 清单 + CI 自动化 | 同上 + 废弃工作流 |
| **跨环境** | AWS Lambda 为主 | 同上 | PrivateLink / Direct Connect / SaaS | 同上 |
| **高可用** | 单 Region | 单 Region | 单 Region | 多 Region 故障转移 |
| **网络** | 公网 | 公网 | 公网 + PrivateLink | 私有连接 + CloudFront |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AgentCore Gateway 架构 (Scope 2+)                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────────────────┐   │
│  │ MCP      │    │ MCP      │    │ MCP                          │   │
│  │ Client   │    │ Client   │    │ Client (IDE/Agent)           │   │
│  │ (Claude  │    │ (Cursor) │    │ (Kiro/Quick)                 │   │
│  │  Code)   │    │          │    │                              │   │
│  └────┬─────┘    └────┬─────┘    └──────────┬──────────────────┘   │
│       │               │                     │                       │
│       └───────────────┴─────────────────────┘                       │
│                          │                                          │
│               ┌──────────▼──────────┐                               │
│               │  AgentCore Gateway   │                               │
│               │  (MCP Protocol)      │                               │
│               └──────────┬──────────┘                               │
│                          │                                          │
│          ┌───────────────┼───────────────┐                         │
│          │               │               │                         │
│   ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐                  │
│   │ AgentCore   │ │ AgentCore   │ │ AgentCore   │                  │
│   │ Identity    │ │  Policy     │ │ Guardrails  │                  │
│   │ (AuthN +    │ │ (Cedar      │ │ (PII +      │                  │
│   │  Cred Mgmt) │ │  RBAC/ABAC) │ │  Content)   │                  │
│   └──────┬──────┘ └──────┬──────┘ └──────┬──────┘                  │
│          │               │               │                         │
│          └───────────────┼───────────────┘                         │
│                          │                                          │
│   ┌──────────────────────▼──────────────────────────────────────┐   │
│   │                   Request Interceptor Lambda               │   │
│   │              (OPA Rego + Structural Transforms)            │   │
│   └──────────────────────┬──────────────────────────────────────┘   │
│                          │                                          │
│          ┌───────────────┼───────────────┐                         │
│          │               │               │                         │
│   ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐                  │
│   │ AWS Lambda  │ │ On-Prem DB  │ │ SaaS API    │                  │
│   │ (Ticket     │ │ (via        │ │ (GitHub/    │                  │
│   │  Search)    │ │  PrivateLink│ │  Slack)     │                  │
│   └─────────────┘ │  /DC)       │ │ (NAT+OAuth) │                  │
│                   └─────────────┘ └─────────────┘                  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  CloudWatch Logs / CloudTrail / OTel Spans / Cost Explorer │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

### 请求处理流水线

```
MCP Client → Gateway
  │
  ├─ Step 1: JWT 验证 (Cognito / IdP)
  │
  ├─ Step 2: AgentCore Policy (Cedar)
  │         ├─ RBAC: 基于 IdP group claims
  │         └─ ABAC: 基于参数 (如 context.input.environment == "staging")
  │
  ├─ Step 3: Request Interceptor Lambda
  │         └─ OPA Rego: 时间窗口/速率限制/变更工单检查
  │
  ├─ Step 4: Bedrock Guardrails
  │         ├─ PII 过滤 (EMAIL→ANONYMIZE, SSN→BLOCK)
  │         └─ Prompt 攻击检测 (HIGH strength)
  │
  ├─ Step 5: 目标工具执行
  │         ├─ 3LO Consent: 需要用户授权时发射 -32042 elicitation
  │         └─ OBO Token Exchange: 同身份链时无重定向
  │
  ├─ Step 6: Response Interceptor
  │         └─ 清理无意泄露的敏感数据
  │
  └─ Step 7: Guardrails (响应侧)
             └─ 最终内容安全检查

每个环节产出 OTel Span → aws/spans 日志组
```

## 实用评估

### 什么场景值得用

- **企业 MCP 治理刚需**: 当安全团队能明确回答"我们的 Agent 在访问什么"之前，AgentCore Gateway 提供了一条从 Day 1 开始治理的路径。Scope 1 只需 1 天即可上线基础 SSO + 审计。
- **合规审计驱动**: Cedar 策略的每个 Deny 决策都会产出包含 principal、action、resource、decision、matchedPolicy、reason 的 OTel Span 记录，直接满足 SOX/ISO 27001 对"谁在何时做了什么"的审计要求。
- **多团队工具目录**: Scope 3 的 YAML 清单 + CI 自动化消除了平台工程师的工具注册瓶颈。每个工具的成本通过 Cost Explorer Tag 归因到具体团队，FinOps 可闭环。
- **混合云 Agent 工具路由**: 通过 Gateway VPC Egress + PrivateLink/Direct Connect，Agent 可以透明地访问本地数据库、多云资源或 SaaS API，客户端无需感知目标位置。

### 什么场景不值得用

- **个人开发者/小团队 (<10 人)**: Scope 1 的最低配置也需要 Cognito User Pool + Gateway + Lambda Target 三个组件，对于单用户场景是明显的过度工程化。
- **非 AWS 原生团队**: 深度依赖 Cognito、CloudWatch、CloudTrail、Cost Explorer 等 AWS 托管服务。如果团队主力在 GCP 或 Azure，自建 Kong + OPA 方案可能更经济。
- **需要跨云统一网关**: AgentCore Gateway 是 AWS 托管服务，不支持管理非 AWS 环境中的 Agent 工具调用。跨云场景需要寻找独立方案。
- **对数据主权有严格要求**: Gateway 运行在 AWS 9 个 Region 之一，所有审计日志和策略评估数据流经 AWS 基础设施。某些司法管辖区可能不允许。

### 迁移成本

| 迁移阶段 | 工作内容 | 预估工时 |
|---------|---------|---------|
| Scope 1 (Day 1) | 创建 Cognito User Pool + 部署 Gateway + 注册 1 个 Lambda Target | 4-6 小时 |
| Scope 1 (Day 2-3) | 分发 mcp.json 通过 MDM + 端到端验证 | 2-3 小时 |
| Scope 2 (Week 1-2) | 部署 DCR Shim + 策略 LOG_ONLY 模式 + Guardrails 检测模式 | 2-3 天 |
| Scope 2 (Week 3+) | 策略切换 ENFORCE + Guardrails 主动拦截 + 用户 SSO 沟通 | 1-2 天 |
| Scope 3 (Week 1-4) | YAML 清单 Schema + CI Pipeline + OPA + Resources MCP + PrivateLink | 1-2 周 |
| Scope 4 (Week 4+) | CloudFront + ALB + 多 Region 故障转移 + 治理仪表盘 | 2-3 周 |

从现有分散的 mcp.json 迁移到 AgentCore Gateway，Scope 1+2 可在 1 周内完成基础治理上线，Scope 3+4 可按需渐进推进。

## 对你的意义

这个服务对 AI Agent 工程生态的意义在于：**它标志着 MCP 治理从"社区最佳实践"升级为"云厂商托管能力"**。

对于关注 Agent UI/工具链的你来说，几个值得注意的信号：

1. **MCP 企业化加速**: AWS 用四阶段成熟度模型为 MCP 部署定义了标准路径，这意味着 MCP 在企业场景的 adoption curve 将显著缩短。之前企业因为安全顾虑而延迟 Agent 部署的情况会得到缓解。

2. **Cedar 策略语言值得关注**: AWS 开源的 Cedar 策略引擎（Rust 实现）在 AgentCore Gateway 中作为核心授权引擎，支持 RBAC + ABAC + 参数级控制。它的性能特征和表达能力可能成为 Agent 工具授权的事实标准——值得对比 OPA Rego 做技术选型评估。

3. **OBO Token Exchange 模式**: 对于需要 Agent 代理用户身份访问下游 SaaS 的场景，OBO 模式消除了浏览器重定向的摩擦。这个模式在 Agent 身份链设计中具有普遍参考价值。

**建议**: 如果你的项目涉及企业级 Agent 部署或 MCP 工具链，值得花半天时间跑一遍 Scope 1 的 PoC。Cedar 策略语言值得单独学习——它可能成为 Agent 授权领域的重要基础设施。

## 关键代码/配置片段

### Gateway 创建（Scope 1）

```bash
aws bedrock-agentcore-control create-gateway \
  --name pilot-gateway \
  --role-arn arn:aws:iam::<account-id>:role/GatewayRole \
  --protocol-type MCP \
  --authorizer-type CUSTOM_JWT \
  --authorizer-configuration '{
    "customJWTAuthorizer": {
      "discoveryUrl": "https://cognito-idp.<region>.amazonaws.com/<pool-id>/.well-known/openid-configuration",
      "allowedClients": ["pilot-gateway-client"]
    }
  }'
```

### Cedar 策略：RBAC + 参数级 ABAC

```cedar
// 支付团队部署者只能部署到 staging
permit (
  principal,
  action == AgentCore::Action::"DeployCI___invoke",
  resource
) when {
  principal.hasTag("groups") &&
  principal.getTag("groups").contains("repo-payments-service") &&
  context.input.environment == "staging"
};

// 只读工具对所有认证用户开放
permit (
  principal,
  action in [
    AgentCore::Action::"TicketSearch___invoke",
    AgentCore::Action::"DocsSearch___invoke"
  ],
  resource
) when { principal.hasTag("groups") };
```

### OPA Rego 补充策略（Scope 3）

```rego
package mcp.tools

import rego.v1

default allow := false

allow if {
  input.tool == "db_write"
  clock := time.clock(time.now_ns())
  clock[0] >= 9
  clock[0] < 17
  weekday := time.weekday(time.now_ns())
  not weekday in {"Saturday", "Sunday"}
  input.claims.change_ticket_id != ""
}
```

### PII 过滤配置（Guardrails 集成）

```json
{
  "contentPolicyConfig": {
    "filtersConfig": [{ "type": "PROMPT_ATTACK", "inputStrength": "HIGH", "outputStrength": "NONE" }]
  },
  "sensitiveInformationPolicyConfig": {
    "piiEntitiesConfig": [
      { "type": "EMAIL", "action": "ANONYMIZE" },
      { "type": "US_SOCIAL_SECURITY_NUMBER", "action": "BLOCK" },
      { "type": "CREDIT_DEBIT_CARD_NUMBER", "action": "BLOCK" }
    ]
  }
}
```

### 3LO 授权 Elicitation（MCP Client 需处理）

```json
{
  "jsonrpc": "2.0", "id": 7,
  "error": {
    "code": -32042,
    "message": "authorization_required",
    "data": {
      "authorization_url": "https://oauth.example.com/auth?session_uri=urn:session:9f3a",
      "session_uri": "urn:session:9f3a"
    }
  }
}
```

### 工具注册 YAML 清单（Scope 3）

```yaml
# registry/tools/payment-refund.yaml
name: PaymentRefund
owner: payments-platform@example.com
target:
  type: lambda
  arn: arn:aws:lambda:us-west-2:<account-id>:function:payment-refund
access:
  allowed_groups: [finance-ops, senior-support]
  environments: [staging]
  risk_tier: high
```

---
[← Back to Deep Dives](./README.md)
