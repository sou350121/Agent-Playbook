---
auto_generated: true
generated_at: "2026-09-25T12:00:59Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/build-a-multi-account-ai-agent-with-agentcore-gateway-and-mcp/"
signal_type: "blog_post"
---
# 用 AgentCore Gateway + MCP 构建跨账户 AI Agent（Build a Multi-Account AI Agent with AgentCore Gateway and MCP）

> 🔍 本文由 Moltbot 自动生成 | 2026-09-25
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway + MCP 多账户参考架构
> **链接**: https://aws.amazon.com/blogs/machine-learning/build-a-multi-account-ai-agent-with-agentcore-gateway-and-mcp/
> **核心定位**: 用 AgentCore Gateway 充当统一 MCP 端点，把散落在多个 AWS 账户里的数据与工具聚合起来，让 agent 能跨账户推理，而数据始终不离开它的归属账户。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：一份可落地的多账户 agent 参考架构——数据留在各业务线（LOB）账户，平台账户集中托管 agent 与推理，Gateway 做唯一的 MCP 接入 + 鉴权 + 授权收敛点。
- **現在值得用嗎**：看场景。如果你的 agent 已经要跨越 2 个以上 AWS 账户、且合规上不允许复制数据，这套 pattern 直接可用；否则属于过度工程。
- **適合場景**：多账户企业（AWS Organizations）、需要跨 LOB 查数但数据不能集中、要把工具鉴权/审计/成本分账收敛到平台层。
- **不適合場景**：单账户小项目、数据可自由复制的场景、不使用 AWS/Bedrock 的团队、以及不愿意引入 Okta/Cognito 这类 OIDC IdP 的轻量原型。
- **與「直连各账户 MCP server」核心差異**：把 M×N 的凭证与策略矩阵收敛成「agent → Gateway → 各 LOB」的星型结构，鉴权与 Cedar 策略在 Gateway 层统一执行，而非散落在每个 agent 代码里。

## 是什么 / 解决什么问题

企业级 AI agent 的一个核心张力是：**agent 的价值来自它能看到多少数据，而数据治理的价值来自它被隔离得有多好**。业务线（Line of Business, LOB）团队坚持把数据留在自己的账户，理由充分——清晰的归属权、作用域隔离、独立的发布周期。但一个只能看到单一账户数据的 agent 价值有限；而一旦要接通分布式数据源，传统做法无非是复制数据，或者去纠缠跨账户 IAM。

AWS 这篇博客给出的答案是一个**三层、hub-and-spoke 的多账户架构**：

1. **平台账户（Platform account）**：agent 控制平面，托管 agent 与 LLM 推理（Amazon Bedrock）。
2. **LOB 账户**：把数据与工具封装成 MCP server，各自持有。
3. **AgentCore Gateway**：平台账户里的集成层，把所有 LOB 的 MCP server 注册为 target，对外只暴露一个 MCP 端点。

关键的设计承诺是：**源数据不复制、不迁移**。MCP server 只返回「这次工具调用产生的那一条结果」，而不是原始数据集；这条结果作为上下文流向平台账户参与推理，底层数据集从未离开归属账户。

这篇不是新功能发布，而是一份带完整代码与可运行仓库的参考架构（AWS 官方 sample: `sample-amazon-bedrock-agentcore-banking-mcp-multi-account`，用 CDK 在四个账户上 bootstrap）。它的价值在于把「企业 agent 的凭证与权限边界」这个最脏的问题，拆成了一套可复制的工程模式。

## 技术架构拆解

### 核心设计决策

- **Gateway 作为唯一 MCP 端点**：agent 只连平台账户的 Gateway，不直连任何 LOB。Gateway 用**语义搜索（semantic search）**做跨 LOB 的工具发现，并提供集中鉴权、细粒度授权与可观测性。
- **数据留在 LOB，只放行结果**：LOB MCP server 返回工具产出的具体结果，而非原始数据；返回结果作为推理上下文回传平台账户。
- **入站用 JWT、出站用 OAuth 2.0 M2M**：用户登录由 IdP（示例用 Okta）签发 JWT；agent 把用户 JWT 透传给 Gateway，Gateway 用 Cedar 策略按用户身份/角色/动作判定放行；放行后，Gateway 从 AgentCore Identity 取 M2M（client_credentials）凭证，附带在出站请求上转发给对应 LOB MCP server。
- **授权与内容安全在代码之外执行**：Policy in AgentCore（Cedar 语言，default-deny）与 Amazon Bedrock Guardrails 都在 Gateway 层执行，不侵入 agent 代码。
- **Runtime 层隔离**：MCP server 与 agent 都跑在 AgentCore Runtime——serverless、框架无关、会话隔离在专用 microVM、按用量计费、内置鉴权。
- **接入类型可扩展**：Gateway 除聚合 MCP server、充当 Inference Gateway 外，还支持 HTTP target（把 A2A 服务、AgentCore Runtime agent 拉进同一受治理端点，各占子路径）与原生 Managed Knowledge Base connector（新项目可直接挂 Bedrock Managed KB，省掉自己的检索基建）。

### 与前版/竞品的关键差异

| 维度 | 直连各账户 MCP server | 本架构（Gateway 聚合） |
|------|----------------------|----------------------|
| 接入复杂度 | agent 需管理 M×N 条连接与凭证 | agent 只连 1 个 Gateway 端点 |
| 工具发现 | 各 server 分散注册 | Gateway 统一 `tools/list` + 语义搜索 |
| 鉴权 | 凭证逻辑散落在 agent/各 server | 出站 M2M 凭证集中由 AgentCore Identity 管理 |
| 授权 | 各自为政 | Policy in AgentCore（Cedar）在 Gateway 层统一判定 |
| 新 LOB 上线 | 需改 agent 连接配置 | 只加一个 Gateway target，agent 下次 `tools/list` 自动发现 |
| 数据流动 | 易滑向复制/集中 | 只放行单次工具结果，源数据不动 |
| 审计/成本 | 分散难归集 | CloudTrail 集中审计、tag 驱动的 per-LOB 分账 |

### 架构/信息流图

```
 用户 ──登录──> Okta (OIDC) ──JWT──┐
                                    v
              React Webapp ──> CloudFront ──> FastAPI (ECS/Fargate)
                                              │  Guardrails: PII 脱敏(入/出)
                                              v
                        ┌──────────────────────────────────────┐
                        │        平台账户 (Platform)             │
                        │  Strands Agent @ AgentCore Runtime    │
                        │      │ 透传用户 JWT                    │
                        │      v                                │
                        │  AgentCore Gateway (唯一 MCP 端点)     │
                        │   ├─ 语义工具发现 (tools/list)         │
                        │   ├─ Policy in AgentCore (Cedar) 判定 │
                        │   └─ AgentCore Identity: 取 M2M token │
                        └───────┬───────────────┬──────────────┘
                     MCP/HTTP   │               │
                    (出站 M2M)  v               v
                   ┌────────────────┐   ┌────────────────┐
                   │ LOB: 零售银行   │   │ LOB: 借贷与财富 │
                   │ MCP server     │   │ MCP server     │
                   │ get_balance    │   │ get_credit_score│
                   │ get_profile    │   │ search_policies │
                   │  → DynamoDB    │   │  → DynamoDB +   │
                   │                │   │    Bedrock KB   │
                   └────────────────┘   └────────────────┘
                     数据留在各 LOB 账户，仅返回单次结果
```

## 实用评估

### 什么场景值得用

- **多账户、数据不可集中**：金融、医疗等合规场景，数据必须留在归属账户，但 agent 又要跨域推理。这套 pattern 直接命中。
- **平台/业务职责分离**：平台团队掌握 FM 选择、Guardrails、统一计费边界；LOB 团队保留对自己工具面的完全所有权——只要 MCP 工具接口不变，实现可以随便改而不影响平台 agent。
- **要把授权收敛成策略**：示例中的 Cedar 规则展示了清晰表达力：一条 `permit` 放行所有已认证用户调用只读工具（`get_balance`、`get_accounts`、`tools/list`、`initialize`），一条 `forbid` 无条件封禁破坏性操作（`delete_customer`）。default-deny 模型下，只有显式 permit 的动作才通过。
- **需要生产级治理闭环**：AgentCore Evaluations 支持在线评估（抽样约 10% 生产会话，用内置评估器 Tool Selection Accuracy / Correctness / Goal Success Rate 打分）；配合 OpenTelemetry，能在不新增埋点的情况下把「agent 把借贷查询路由到了错误 LOB」这类静默退化暴露出来。CI/CD 侧还可复用同一套评估器的 dataset 评估做门禁。

### 什么场景不值得用

- **单账户或轻量原型**：这套架构的复杂度（多账户、CDK、OIDC IdP、M2M 凭证、Cedar 策略）对小项目是纯负担。直连 MCP server 更省事。
- **不使用 AWS/Bedrock 栈**：整篇强绑定 Amazon Bedrock AgentCore（Runtime / Gateway / Identity / Policy / Evaluations / Registry）+ Okta/Cognito/Entra 类 OIDC IdP。非 AWS 团队无法照搬。
- **需要 per-user 强隔离但 IdP 不支持 OBO**：示例本身就用 M2M 而非 OBO（on-behalf-of token exchange）——官方明确说明，是因为所用的 Okta developer 账户不支持 OBO 流。若你的工具必须做行级安全（row-level security）级别的按人鉴权，需自行评估 OBO 是否可用；M2M 模式下用户级授权只能在 Gateway 层完成。
- **默认公网模式直接上生产**：参考实现用的是 AgentCore Runtime 默认公网模式（HTTPS + OAuth 走公网）。官方明确这「适合开发、不适合生产」，生产需切到 VPC/ENI + PrivateLink 私有入口 + `allowedWorkloadConfiguration`。
- **依赖尚未 GA 的能力**：架构中引用的 AWS Agent Registry 标注为 **Preview**，评估/优化等能力成熟度需按官方文档核实（待确认）。

### 迁移成本

若从「agent 直连各账户 MCP server」迁到本架构，主要工作量在：

1. 把各 LOB 的 MCP server 用 FastMCP + AgentCore CLI 部署到 AgentCore Runtime，并配置 `customJWTAuthorizer`（指向 IdP 的 OIDC discovery URL + `allowedAudience`）。
2. 在平台账户创建 Gateway（CUSTOM_JWT 入站 + 语义搜索），为每个 LOB 注册 target 并挂上 OAuth 出站凭证 provider。
3. 给 agent 加上 JWT 透传（`requestHeaderAllowlist: ["Authorization"]`）与 Gateway MCP client 连接。
4. 用 CDK 或控制面 API 编排四账户资源。

官方提供了一键部署脚本（bootstrap CDK → 起资源 → 部署 MCP server 与 Gateway target → 起 ECS+CloudFront 的 React app）与逆序清理脚本 `./cleanup.sh`，从零试跑的成本不高；真正的工作量在把示例适配到你自己的 IdP、数据源与策略模型。

## 对你的意义

如果你在做的是 **Agent + UI / RAG / LLMOps** 方向，这篇的启发点不在「要不要用 AWS」，而在**它示范了一种把 agent 的鉴权、授权、审计、成本全部外移到接入层的工程范式**：

- **工具接入层正在变成治理层**。Gateway 承担的不只是转发，而是语义工具发现 + Cedar 授权 + Guardrails + 可观测性 + 审计的合集。这和你关注的「Agent Builder / 可视化编排」是同一命题的两面——编排的上游是「工具怎么被安全地接进来」。
- **default-deny + 显式策略**是 agent 安全评估里越来越主流的设计取向，值得纳入你的评估/安全模块参考。
- **评估与授权同源**：CI/CD 门禁用的评估器和生产在线监控用的是同一套（Tool Selection Accuracy / Correctness / Goal Success Rate），这个「gating = monitoring」的闭环思路对 LLMOps 很有借鉴价值。

**具体建议**：如果你手上没有多账户 AWS 的即时需求，**不必立即试用**——把它当作一份「agent 治理层参考实现」存档，重点读 Cedar 策略片段与 Evaluations 的在线评估设计；等真遇到跨账户/跨团队工具治理场景，再回来 clone 仓库试跑。

## 关键代码/配置片段

**1) LOB 侧：FastMCP server 同时包 DynamoDB 与 Bedrock Knowledge Bases 检索（节选自官方示例）**

```python
mcp = FastMCP("lending-wealth", host="0.0.0.0", stateless_http=True)

@mcp.tool()
def get_credit_score(customer_id: str) -> dict:
    """Get credit score and contributing factors for a customer."""
    table = dynamodb.Table("CreditScores")
    resp = table.get_item(Key={"customer_id": customer_id})
    item = resp.get("Item")
    if not item:
        return {"error": f"No credit score found for customer {customer_id}"}
    return item

@mcp.tool()
def search_lending_policies(query: str) -> str:
    """Search the bank's lending policy documents..."""
    resp = bedrock_agent_runtime.retrieve(
        knowledgeBaseId=KNOWLEDGE_BASE_ID,
        retrievalQuery={"text": query},
        retrievalConfiguration={"vectorSearchConfiguration": {"numberOfResults": 5}},
    )
    chunks = []
    for r in resp.get("retrievalResults", []):
        text = r.get("content", {}).get("text", "")
        source = r.get("location", {}).get("s3Location", {}).get("uri", "")
        if text:
            chunks.append({"text": text, "source": os.path.basename(source)})
    return json.dumps({"results": chunks}, default=str)
```

**2) 部署 MCP server 到 AgentCore Runtime（AgentCore CLI）**

```bash
agentcore configure \
  --entrypoint server.py \
  --name lending_wealth_mcp \
  --protocol MCP \
  --disable-memory \
  --non-interactive \
  --authorizer-config '{
    "customJWTAuthorizer": {
      "discoveryUrl": "<OKTA_DISCOVERY_URL>",
      "allowedAudience": ["lobfederation"]
    }
  }'

agentcore deploy --auto-update-on-conflict \
  --env KNOWLEDGE_BASE_ID=<your-knowledge-base-id>
```

**3) 平台侧：Gateway 出站 OAuth 凭证 provider + target 注册（M2M / client_credentials）**

```python
resp = ctrl.create_oauth2_credential_provider(
    name="lobfederation-okta-m2m",
    credentialProviderVendor="CustomOauth2",
    oauth2ProviderConfigInput={
        "customOauth2ProviderConfig": {
            "oauthDiscovery": {
                "discoveryUrl": "https://<your-okta-domain>/oauth2/<auth-server-id>/.well-known/openid-configuration"
            },
            "clientId": "<M2M_CLIENT_ID>",
            "clientSecret": "<M2M_CLIENT_SECRET>",
            "clientAuthenticationMethod": "CLIENT_SECRET_BASIC",
        }
    },
)
cred_arn = resp["credentialProviderArn"]

ctrl.create_gateway_target(
    gatewayIdentifier=gateway_id,
    name="lending-wealth",
    targetConfiguration={
        "mcp": {"mcpServer": {
            "endpoint": f"https://bedrock-agentcore.{REGION}.amazonaws.com/runtimes/{encoded_runtime_arn}/invocations",
        }}
    },
    credentialProviderConfigurations=[{
        "credentialProviderType": "OAUTH",
        "credentialProvider": {"oauthCredentialProvider": {
            "providerArn": cred_arn,
            "scopes": ["lobfederation.invoke"],
            "grantType": "CLIENT_CREDENTIALS",
        }},
    }],
)
```

**4) Agent 入口透传用户 JWT 给 Gateway（让 Cedar 按用户身份判定）**

```python
@app.entrypoint
def invoke(payload, context=None):
    prompt = payload.get("prompt", "Hello")
    request_headers = context.request_headers if context else {}
    user_jwt = request_headers.get("Authorization", "")

    mcp_client = MCPClient(
        lambda: streamablehttp_client(url=GATEWAY_URL, headers={"Authorization": user_jwt})
    )
    with mcp_client:
        tools = mcp_client.list_tools_sync()
        agent = Agent(model=MODEL_ID, system_prompt=SYSTEM_PROMPT, tools=tools)
        result = agent(prompt)
```

**5) Policy in AgentCore 的 Cedar 策略（default-deny）**

```cedar
// Permit all authenticated users to invoke read-only tools
permit(
  principal is AgentCore::OAuthUser,
  action in [
    AgentCore::Action::"retail-banking___get_customer",
    AgentCore::Action::"retail-banking___get_accounts",
    AgentCore::Action::"retail-banking___get_balance",
    AgentCore::Action::"tools/list",
    AgentCore::Action::"initialize"
  ],
  resource
);

// Block destructive operations regardless of user
forbid(
  principal,
  action == AgentCore::Action::"retail-banking___delete_customer",
  resource
);
```

> 完整实现见官方仓库：https://github.com/aws-samples/sample-amazon-bedrock-agentcore-banking-mcp-multi-account
> 一处需注意的局限：示例以 OAuth audience 校验作为主要访问控制，官方建议生产环境叠加 `allowedWorkloadConfiguration`（把 Runtime 限定为只接受身份链中含该 Gateway 的请求），以降低绕过 Gateway 策略直连的风险。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AWS 把 MCP 作为跨账户工具集成的底层协议（MCP over Streamable HTTP、`tools/list` 发现、MCP 原生 target），并由 AgentCore Gateway 将其提升为企业级治理端点——一线云厂商的官方参考架构采用 MCP，是对该假设的强支持信号。 |

---
[← Back to Deep Dives](./README.md)
