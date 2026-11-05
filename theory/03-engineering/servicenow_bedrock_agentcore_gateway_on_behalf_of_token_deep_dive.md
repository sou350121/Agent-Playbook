---
auto_generated: true
generated_at: "2026-11-05T05:45:42Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/servicenow-on-behalf-of-token-exchange-with-bedrock-agentcore-gateway/"
signal_type: "blog_post"
---
# ServiceNow 的 Agent 身份委派实战：Bedrock AgentCore Gateway 原生 OBO Token 交换 (ServiceNow On-Behalf-Of Token Exchange with Bedrock AgentCore Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-05
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway（配合 Microsoft Entra ID 与 ServiceNow REST API）
> **链接**: https://aws.amazon.com/blogs/machine-learning/servicenow-on-behalf-of-token-exchange-with-bedrock-agentcore-gateway/
> **核心定位**: 官方参考实现——让 AI agent 在调用企业 API 时保留「原始用户身份」，用网关层原生 OBO（on-behalf-of）令牌交换取代自建 Lambda 拦截器

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：AgentCore Gateway 新增原生 OBO token 交换能力，agent 代用户访问 ServiceNow 等受 OAuth 保护的 API 时，下游看到的是「那个用户」而不是「那个应用」。
- **现在值得用吗**：看场景——如果你已经在 AWS 上跑 agent，且企业 IdP 是 Entra ID，这是目前最少自定义代码的路径；否则配套成本不低。
- **适合场景**：企业内部 IT/工单类 agent（ServiceNow、Jira 类系统）、需要审计留痕与最小权限的 agent 工作流、多租户 SaaS 的 agent 集成层。
- **不适合场景**：个人开发者玩具项目、IdP 非 Entra 且不支持标准 OBO、对每请求多一跳 token 端点延迟敏感的低延迟场景。
- **与旧做法的核心差异**：以前要在 agent 与下游 API 之间塞一个 Lambda 做 token 交换并自己维护；现在在 gateway target 上配两个字段（scope + `requested_token_use:on_behalf_of`）即可，网关每次请求自动交换。

## 是什么 / 解决什么问题

所有让 agent「代替人做事」的系统都会撞上同一堵墙：**身份在调用链上丢失了**。

用户在前端点击「帮我查一下我的未结工单」，agent 拿着自己的服务账号去调 ServiceNow Table API。ServiceNow 看到的是 `ServiceNowAgent` 这个应用，不是张三。后果有三条，AWS 官方博客说得很直白：

- **审计链断裂**：记录里只有应用身份，追不到「谁触发的」。
- **绕过用户级访问控制**：接口层权限变成「应用能看什么」，而不是「张三能看什么」。
- **违反最小权限原则**：agent 拿到了远超当前用户所需的权限面。

传统解法是自己写一层 token 交换——常见形态是 AWS Lambda 拦截器，拿到入站 JWT，调 IdP 的 token endpoint 换票，再转发给下游。这条路径能跑通，但它是**你必须自己维护的身份中间件**：token 缓存、错误重试、claim 映射、IdP 版本变更适配，全是长期负债。

这次 AWS 的变化是把这个交换**下沉到 AgentCore Gateway 的原生能力**。博客的结论句写得很明确：「native OBO support in AgentCore Gateway removes the need for custom AWS Lambda interceptors to perform token exchanges.」

注意一个硬约束：**必须使用 MCP version 2025-11-25 创建的 gateway**。「You can't turn on native OBO for gateways created with earlier MCP versions.」——已有旧版 gateway 的人无法原地开启，需要重建。

## 技术架构拆解

### 核心设计决策

- **三个 OAuth 应用注册，职责分离**。Entra 里注册两个：`ServiceNowAgent`（代表 agent 本身）和 `ServiceNow API Connector`（代表下游 API 的资源侧）。用户在 Entra 里作为第三个主体，通过 consent 参与。这种分离让「agent 能做什么」与「ServiceNow 暴露什么 scope」成为两个独立可治理的对象。
- **Audience 不匹配是核心矛盾，OBO 是桥**。agent 持有的 JWT，`aud` 是自己的 client ID（例如 `3ff88e17-...`）；ServiceNow 期望的 `aud` 是 API connector 的 client ID（例如 `5d4a7a11-...`）。OBO 流程发一个新票完成这个换位，同时**保留原始用户 claim**。
- **交换发生在 gateway target 层，不是全局层**。每个 target 单独配置 outbound auth。这意味着同一个 gateway 可以同时挂「用 OBO 的 ServiceNow target」和「用 client credentials 的公共 API target」，权限粒度按 target 切分。
- **Claim 映射交给下游做**。博客要求把 `preferred_username` 映射到 ServiceNow 的 Email 字段。这意味着**标识契约是 email**——一个部署时容易忽略、运行时很难调试的隐式依赖。
- **建议映射 `uti` → `jti`**。Entra 签发的 token 用内部 claim `uti`，语义等价于 JTI。博客建议把它映射成 `jti` 以获得 replay protection 与 denylisting 能力。这是一个安全加固点，并非必须项，但值得记下。
- **与 Guardrails 的搭配是「生产额外项」**。原文措辞是「In production, you can additionally pair identity propagation with Amazon Bedrock Guardrails」——也就是说这篇 reference 本身**没有**包含内容安全层。

### 与前版/竞品的关键差异

| 维度 | 自建 Lambda 拦截器（旧做法） | AgentCore Gateway 原生 OBO（现在） |
|------|--------------------------|--------------------------------|
| token 交换位置 | 自写 Lambda，agent 与 API 之间 | Gateway target 配置，平台执行 |
| 需要维护的代码 | 交换逻辑、缓存、重试、claim 映射 | 无自定义代码 |
| 配置量 | 函数部署 + IAM + 网关路由 | scope 一个字段 + `requested_token_use` 一个自定义参数 |
| 身份传导 | 需自行保证 claim 不被丢弃 | 平台保证原始用户 claim 保留 |
| 可观测性 | 需自建日志与追踪 | 依赖 AgentCore 侧观测能力（本文未展开） |
| 版本门槛 | 无 | 必须 MCP 2025-11-25 创建的 gateway |
| 适用范围 | 任意 REST API | 任意 OAuth 保护的 REST API（博客称可推广） |

### 架构 / 信息流

```
[用户] --(1) 登录取 JWT，aud=AgentClientID--> [AI Agent 应用]
                                                    |
                                                    | (2) 带 JWT 调 MCP server
                                                    v
                                        [AgentCore Gateway]
                                         inbound: 验证 aud=AgentClientID
                                                    |
                                                    | (3) OBO 交换请求
                                                    |     + client credentials
                                                    |     + scope: api://<SNConnector>/user_impersonation
                                                    |     + requested_token_use: on_behalf_of
                                                    v
                                          [Microsoft Entra ID]
                                          校验用户已 consent 委派
                                                    |
                                                    | (4) 新票 aud=ServiceNowConnectorClientID
                                                    |     原始用户 claims 保留
                                                    v
                                        [AgentCore Gateway]
                                                    |
                                                    | (5) 携新票转发
                                                    v
                                        [ServiceNow REST API]
                                         preferred_username -> Email 映射
                                         按该用户权限执行 Table API
```

关键点：**agent 自己从不知道交换后的票长什么样**。交换对 agent 完全透明，agent 只需持有自己的票。这大幅降低了 agent 侧 SDK 的复杂度，但也意味着**调试时 agent 日志里看不到下游真实身份**——排障要下沉到 gateway 与 IdP 两侧。

## 实用评估

### 什么场景值得用

- **企业内部工单 / ITSM agent**：这是博客的原生场景。员工问「我的 P1 工单进展如何」，权限必须是员工本人的，不能是 agent 的。ServiceNow + Entra 组合在大型企业里占比很高。
- **需要合规审计的 agent 工作流**：金融、医疗、政企采购 agent 时，「下游能追溯到底层用户」几乎是硬性要求。OBO 把这条从「自建保证」变成「平台机制」。
- **已经有 Entra + AWS 双栈的组织**：这套方案的每一步都在既有基础设施里，边际成本最低。博客明说「No changes to the Entra configuration are needed beyond what you would set up for any standard OBO integration between two applications」。
- **多下游 API 的统一身份层**：博客称「The pattern can be applied to other REST APIs protected by OAuth」。把网关当成统一的身份换乘站，比每个下游各写一套交换代码更可持续。

### 什么场景不值得用

- **IdP 不是 Entra ID**。这篇 walkthrough 全程围绕 Entra 的 OBO 语义（`requested_token_use`、`user_impersonation` scope、`uti` claim）。换用 Okta/Auth0 理论上可行，但**具体参数名与 claim 语义需自行验证**，本文不提供对应配置。
- **旧版 gateway 用户**：MCP 版本不可原地升级，要重建 gateway 与 target。存量迁移成本需要单独评估。
- **对每请求延迟敏感到毫秒级的场景**：OBO 每个请求都要走一次 IdP token endpoint（除非网关内部缓存，**官方博客未说明缓存行为，待确认**）。高频 tool calling 的 agent 需要实测。
- **低价值的个人项目**：为了 demo 一套 OpenAPI tool 而上三套应用注册 + 一套 ServiceNow inbound integration，投入产出比很差。
- **需要「应用级统一身份」而非「用户级身份」的批处理 agent**：比如夜间跑的数据同步 agent，没有真实用户在环。这种场景用 client credentials 更合适，OBO 反而制造虚假的用户语义。

### 迁移成本

从自建 Lambda 拦截器迁到原生 OBO，按博客的步骤拆：

1. **Entra 侧**：确认已有两个应用注册（agent + API connector），确认 `user_impersonation` scope 已暴露，确认 agent 应用有对 connector 的 API permission。若已做标准 OBO 集成，本步约等于零。
2. **ServiceNow 侧**：配置 inbound integration（第三方 OIDC token）、OIDC provider（映射 `preferred_username` → Email、可选 `uti` → `jti`）、auth scope 限定到 Table API。**这部分工作量最实**，且需要 ServiceNow 管理员权限。
3. **Gateway 侧**：新建 outbound auth（Customized provider + JWT authorization grant）、**新建 MCP 2025-11-25 gateway**、建 target 并挂 Token exchange grant。
4. **拆除**：下线原 Lambda 拦截器及其 IAM 角色。

经验判断：Entra 侧与 gateway 侧是「配置活」，半天内可完成；ServiceNow 侧受制于企业内部审批流程，通常是关键路径。真正的隐性成本在**删旧 Lambda 的勇气**——两套并行期越久，身份语义越容易分裂。

## 对你的意义

对「Agent + UI」方向有一个容易被忽略的启发：**agent 产品的信任边界最终落在身份上，而不是在界面上**。

如果你的 agent 产品面向企业客户，identity propagation 会是最早被采购安全评审问到的问题之一，比 prompt injection 防御问得还早。这次 AWS 把 OBO 做成网关原语，意味着**你不需要在 agent 框架里发明身份层**——把身份问题交给基础设施，把精力留给编排与交互。这是正确的分层。

具体建议：

- **现在不用动手**。你的重点不在 ITSM 集成。
- **但要存一份架构心智**：当你的 agent 需要接企业内部系统（HR、工单、CRM）时，第一反应应该是「gateway 层做 OBO」，而不是「在 tool 函数里手动带 token」。
- **反直觉的一条**：agent 侧代码越简单越好。上面那段 Strands 示例 agent 只有二十来行，system prompt 里明确写「Never ask the user for credentials or instance details — the tool is pre-configured」。把配置全部推到基础设施，让 agent 只关心「意图 → tool 调用」，这是可维护 agent 的普遍形态，不限于身份议题。

跨领域看：这套模式与 VLA 侧的权限/安全隔离是同构的——**动作执行者与授权来源必须分离**。机器人不会因为「我想抓」就抓到，agent 也不该因为「我能调」就调到。

## 关键代码 / 配置片段

**Target 上的 token exchange 配置（两个关键字段）**

原文给出的配置项：

```
Scope:
  api://5d4a7a11-xxxx-xxxx-xxxx-xxxxxxxxxxxx/user_impersonation

Custom parameter (key-value pair):
  requested_token_use : on_behalf_of
```

原文对第二个字段的强调值得原样引用：「This parameter is critical. Without it, Entra doesn't perform the OBO exchange and the call to ServiceNow fails with an authentication error.」

**OpenAPI schema 摘录（最小可用形式）**

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "ServiceNow Incident API (Minimal)",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "https://devxxx.service-now.com/api/now/table",
      "variables": {
        "instance": { "default": "devxxx", "description": "Your ServiceNow instance name." }
      }
    }
  ],
  "paths": {
    "/incident": {
      "get": {
        "operationId": "getIncidents",
        "summary": "List incidents",
        "parameters": [
          { "name": "sysparm_limit", "in": "query", "schema": { "type": "integer", "default": 10 } },
          { "name": "sysparm_query", "in": "query", "schema": { "type": "string" } }
        ],
        "security": [{ "bearerAuth": [] }]
      }
    }
  },
  "components": {
    "securitySchemes": {
      "bearerAuth": { "type": "http", "scheme": "bearer", "bearerFormat": "JWT" }
    }
  }
}
```

**Strands agent 侧（全文照录，可见其「薄」）**

```python
import sys
import strands
from strands.models import BedrockModel
from strands.tools.mcp import MCPClient
from mcp.client.streamable_http import streamablehttp_client

token = sys.argv[1] if len(sys.argv) > 1 else sys.exit("Usage: python snow_agent.py <TOKEN>")
MCP_URL = "<GATEWAY_URL>"
mcp_client = MCPClient(lambda: streamablehttp_client(url=MCP_URL, headers={"Authorization": f"Bearer {token}"}))
agent = strands.Agent(
    model=BedrockModel(model_id="global.anthropic.claude-sonnet-4-6", streaming=False),
    system_prompt=(
        "You have a tool called 'target-snow___getIncidents'. "
        "When asked about incidents, call it immediately with no parameters. "
        "Never ask the user for credentials or instance details --- the tool is pre-configured."
    ),
    tools=[mcp_client],
)

while (user_input := input("\nYou: ")).lower() not in ("quit", "exit", "q"):
    print(f"\nAgent: {agent(user_input)}")
```

注意 tool 名的形态 `target-snow___getIncidents`——这是 gateway target 名与 operationId 拼接后的产物，是 MCP 网关把 REST API 暴露成 tool 时的一个实际细节。

**排障清单（原文 troubleshooting 原意）**

1. 交换后 token 的 `preferred_username` 是否映射到 ServiceNow 里真实存在的用户 email。
2. ServiceNow inbound integration 的 auth scope 是否放行了 agent 实际调用的接口。
3. Entra 里 agent 应用是否被授予了对 API connector 应用的 permission。

三个检查项分别对应「身份不存在」「权限不够」「委派未授权」——排障时按这个顺序走，最省时间。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 云厂商把企业 REST API 通过 MCP server 暴露，并把 MCP 版本号作为能力门槛（2025-11-25），说明 MCP 已成为集成层的事实接口；但它同时暴露了「版本碎片化」这一治理成本 |

---

*参考来源：[AWS Machine Learning Blog — ServiceNow on-behalf-of token exchange with Bedrock AgentCore Gateway](https://aws.amazon.com/blogs/machine-learning/servicenow-on-behalf-of-token-exchange-with-bedrock-agentcore-gateway/)*

[← Back to Deep Dives](./README.md)
