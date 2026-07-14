---
auto_generated: true
generated_at: "2026-07-14T03:34:00Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/implement-on-behalf-of-token-exchange-for-multi-tenant-agents-with-amazon-bedrock-agentcore-gateway/"
signal_type: "blog_post"
---
# Bedrock AgentCore Gateway：OBO 令牌交换解决多租户 Agent 身份代理难题 (On-Behalf-Of Token Exchange for Multi-Tenant Agents with Amazon Bedrock AgentCore Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-14
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway + AgentCore Identity
> **链接**: https://aws.amazon.com/blogs/machine-learning/implement-on-behalf-of-token-exchange-for-multi-tenant-agents-with-amazon-bedrock-agentcore-gateway/
> **核心定位**: 基于 RFC 8693 的 OBO 令牌交换机制，让 Agent 在调用下游 API 时保留用户身份、实现租户级最小权限，无需在 Agent 代码中实现任何交换逻辑

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: AWS 在 Bedrock AgentCore Gateway 中原生集成了 OAuth 2.0 Token Exchange (RFC 8693)，解决多租户 Agent 场景中"谁的身份随请求一起旅行"的核心身份难题
- **现在值得用吗**: 是 — 如果你的 Agent 需要跨租户调用下游 API，这是目前最完整的托管方案之一；单租户场景则过度设计
- **适合场景**: 多租户 SaaS Agent、跨组织 API 调用、需要端到端审计追踪的企业级 Agent 部署
- **不适合场景**: 单租户 Agent（直接转发 token 即可）、非 AWS 基础设施且无 RFC 8693 兼容 IdP 的团队
- **与直接转发/服务账号模拟的核心差异**: OBO 在每个 hop 生成新的 audience-bound token，sub 保留原始用户身份，aud 绑定下游服务 — 直接转发做不到 audience 隔离，服务账号模拟丢失用户身份

## 是什么 / 解决什么问题

当 AI Agent 部署到多租户生产环境时，会面临一个精确的身份问题：**Agent 代表用户调用下游 API 时，请求携带的是谁的身份？**

AWS 官方博客明确列出了三种实现路径，其中只有一个是正确的：

| 方案 | 问题 |
|------|------|
| 服务账号模拟 (Service-account impersonation) | Agent 用自己的身份调用下游，在 header 中声明用户身份。每个下游系统必须无条件信任 Agent — 经典的 confused deputy 漏洞 |
| 直接用户 token 转发 (Direct user-token forwarding) | Agent 复用入站 token 调用下游。仅在入站 token 的 audience 恰好匹配下游 API 时有效 — 多租户场景下几乎从不成立 |
| **OBO 令牌交换 (On-Behalf-Of Token Exchange)** | Agent 的授权代理将入站 token 交换为新 token：sub 保留原始用户，aud 绑定下游服务，签名来自下游信任的授权服务器 |

OBO 是唯一同时满足三个条件的方案：端到端保留用户身份、在 audience 边界执行最小权限、下游 API 可独立验证 token 而无需信任 Agent。

但实现 RFC 8693 需要 Agent 运行时、授权服务器和下游 API 三方的协调。任何一环配置错误，安全状态都会静默退化。**Bedrock AgentCore Gateway + AgentCore Identity 的价值在于：把这个协调负担从应用代码中移除，变成基础设施层的透明操作。**

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| RFC 8693 原生支持 | 标准化协议，Auth0/Keycloak/Entra ID 等主流 IdP 均有兼容实现，避免供应商锁定 |
| Gateway 层透明交换 | Agent 代码只需获取一个入站 token 并调用工具，所有 exchange 由 Gateway 自动执行 |
| Audience Binding | 每个下游 token 的 aud 声明绑定单一服务，一个租户的 token 无法在另一个租户使用 |
| sub 声明端到端保留 | 跨所有 hop 保留原始调用者身份，授权决策基于 sub，审计/限流基于 actor (cid) |
| 双 grant type 支持 | RFC 8693 TOKEN_EXCHANGE（Okta/Auth0/Keycloak）+ JWT_AUTHORIZATION_GRANT（Entra ID），覆盖主流 IdP |
| VPC 私有连接 | 支持连接到 VPC 内的身份提供商，满足企业内网合规要求 |

### 六组件架构

```
┌─────────────────────────────────────────────────────────────┐
│                     用户浏览器 (3-legged login)              │
└──────────────────────────┬──────────────────────────────────┘
                           │ authorization_code flow
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Provider 授权服务器 (Okta TravelBot Provider)               │
│  → 签发入站 JWT (aud: travelbot-provider)                    │
└──────────────────────────┬──────────────────────────────────┘
                           │ 入站 JWT (bearer)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  AgentCore Gateway                                          │
│  • 验证入站 JWT 签名 (JWKS)                                  │
│  • 路由 tool 调用到正确租户目标                               │
│  • 编排 OBO exchange                                         │
└──────────┬──────────────────────────────┬───────────────────┘
           │ RFC 8693 Token Exchange      │ RFC 8693 Token Exchange
           ▼                              ▼
┌─────────────────────┐        ┌─────────────────────┐
│ ACME 授权服务器      │        │ Globex 授权服务器    │
│ (mints OBO token)   │        │ (mints OBO token)   │
│ aud: api.acme-travel│        │ aud: api.globex-travel│
└──────────┬──────────┘        └──────────┬──────────┘
           │ OBO JWT                       │ OBO JWT
           ▼                               ▼
┌─────────────────────┐        ┌─────────────────────┐
│ API Gateway + Lambda │        │ API Gateway + Lambda │
│ JWT Authorizer →     │        │ JWT Authorizer →     │
│ DynamoDB (by sub)   │        │ DynamoDB (by sub)   │
└─────────────────────┘        └─────────────────────┘
```

### Token 声明转换详解

这是整个方案最核心的技术细节。每个 hop 中 JWT 声明的变化：

| 声明 | 入站 Token | OBO Token | 变化 |
|------|-----------|-----------|------|
| iss | Provider 授权服务器 | 租户授权服务器 | 重写 |
| aud | travelbot-provider | https://api.acme-travel.example | 重写 |
| sub | alice@acme-travel.example | alice@acme-travel.example | **保留** |
| cid | Provider client | Delegate client (AgentCore) | 重写 (actor) |
| scp | 入站 scope | 最小化 scope | 缩减 |

关键洞察：**sub 声明端到端保留**确保下游 API 始终知道原始用户是谁；**aud 声明每跳重写**确保 token 无法跨租户复用；**actor 声明记录代理者**让审计和限流可以区分"谁在代表谁操作"。

### 与竞品的 IdP 兼容性对比

| IdP | 支持的 Grant Type | 协议基础 | AgentCore 支持 |
|-----|------------------|---------|---------------|
| Okta (Custom AS) | TOKEN_EXCHANGE | RFC 8693 | ✅ 原生 |
| Auth0 | TOKEN_EXCHANGE (Custom Token Exchange) | RFC 8693 | ✅ 兼容 |
| Keycloak | TOKEN_EXCHANGE | RFC 8693 | ✅ 兼容 |
| Microsoft Entra ID | JWT_AUTHORIZATION_GRANT | RFC 7523 (jwt-bearer) | ✅ 原生 |
| AWS IAM Identity Center | Trusted Token Issuer | 自定义 | ⚠️ 不同请求格式 |
| Amazon Cognito | — | — | ⚠️ 需确认当前支持 |

适配不同 IdP 是**配置变更而非代码变更** — 通过 credential provider 的 `customParameters` map 设置 `subject_token_type`、`audience`、`actor-token` 和 `client authentication method`。

## 实用评估

### 什么场景值得用

- **多租户 SaaS Agent**: 一个 Agent 前端服务多个企业客户，每个客户有自己的下游 API 和授权策略。OBO 确保 Acme 用户的 token 无法访问 Globex 的数据
- **跨组织 API 调用**: Agent 需要代表用户调用第三方服务（如 CRM、ERP），OBO 提供端到端身份追溯
- **合规审计要求**: 金融/医疗等场景需要完整的审计链 — OBO 的 actor + sub 双声明设计让"谁代理谁"可追溯
- **企业内网部署**: AgentCore Identity 支持 VPC 私有连接，可对接企业内部 IdP

### 什么场景不值得用

- **单租户 Agent**: 入站 audience 已匹配下游服务，直接转发 token 足够。引入 OBO 增加不必要的复杂度
- **非 AWS 基础设施 + 无 RFC 8693 IdP**: 如果团队使用不支持 token exchange 的旧版 IdP，集成成本会很高
- **简单 demo/原型**: 六组件架构（Provider AS + Gateway + Identity + 租户 AS + API Gateway + Lambda）对原型来说过重
- **需要跨云 Agent 身份**: 目前方案深度绑定 AWS 生态，多云场景需自行实现交换逻辑

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|---------|--------|------|
| 从服务账号模拟迁移 | 中等 | 需要配置 Provider AS + 租户 AS + credential provider + Gateway 路由规则 |
| 从直接 token 转发迁移 | 低-中 | 如果下游 API 已支持 JWT 验证，主要工作是添加 Gateway 层和 credential provider 配置 |
| 从零开始 | 中等 | 参考 aws-samples/sample-obo-flow-poc 仓库，Okta 端需配置 3 个 Custom AS |

### 实战陷阱

**陷阱 1: Okta Org AS 不支持自定义 audience**
- 必须使用 Okta Custom Authorization Server，内置 Org AS 不支持自定义 audience 或 scopes
- 影响: 配置错误会导致 exchange 失败，安全状态静默退化

**陷阱 2: 不同 IdP 的 grant type 不同**
- Okta/Auth0/Keycloak 使用 `TOKEN_EXCHANGE` (RFC 8693)
- Entra ID 使用 `JWT_AUTHORIZATION_GRANT` (RFC 7523)
- 影响: credential provider 配置必须匹配 IdP 的 grant type

**陷阱 3: Cognito 作为 provider IdP 的兼容性**
- Cognito user pools 可作为 provider IdP 认证入站 Agent 调用，但 grant type 支持需对照最新文档确认
- 影响: 如果使用 Cognito 做消费者端 OBO，可能存在兼容性问题

## 对你的意义

这个方案对 AI 应用开发者的核心意义在于：**多租户 Agent 的身份管理从"需要自己实现的安全难题"变成了"基础设施层的配置项"**。

具体建议：
- 如果你在构建面向企业客户的 Agent 产品（多租户 SaaS），**值得深入研究** — OBO 是目前最成熟的多租户 Agent 身份方案
- 如果你使用 Okta/Auth0/Keycloak 作为 IdP，**集成路径清晰** — RFC 8693 是通用标准，适配主要是配置工作
- 如果你的 Agent 目前只有单租户用户，**暂不需要** — 但值得了解，因为随着客户增长，身份问题迟早会出现

## 关键代码/配置片段

### RFC 8693 Token Exchange 请求（AgentCore → 租户授权服务器）

```json
{
  "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
  "subject_token": "<inbound JWT>",
  "subject_token_type": "urn:ietf:params:oauth:token-type:access_token",
  "audience": "https://api.acme-travel.example",
  "resource": "https://api.acme-travel.example"
}
```

### OBO Token 的 JWT 声明示例

```json
{
  "iss": "https://okta.com/o/acme-as",
  "aud": "https://api.acme-travel.example",
  "sub": "alice@acme-travel.example",
  "cid": "AgentCore Delegate Client ID",
  "scp": "bookings:read bookings:write",
  "authorized_scopes": "bookings:read bookings:write"
}
```

### Lambda 中的授权决策（基于 claims）

```python
# Lambda 函数从 OBO token 读取声明
def handler(event, context):
    claims = event["requestContext"]["authorizer"]["claims"]
    user_sub = claims["sub"]  # 原始用户身份
    scopes = claims.get("authorized_scopes", "").split()
    
    # 基于 sub 分区查询 — 用户只能读自己的记录
    response = dynamodb.query(
        TableName="bookings",
        KeyConditionExpression="user_id = :sub",
        ExpressionAttributeValues={":sub": user_sub}
    )
    
    # 写操作需要额外 scope 检查
    if event["httpMethod"] == "POST" and "bookings:write" not in scopes:
        return {"statusCode": 403}
    
    return {"statusCode": 200, "body": response["Items"]}
```

---
[← Back to Deep Dives](./README.md)
