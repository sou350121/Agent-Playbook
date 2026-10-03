---
auto_generated: true
generated_at: "2026-10-03T05:45:45Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/add-secure-web-search-to-claude-desktop-with-amazon-bedrock-agentcore/"
signal_type: "blog_post"
---
# 用 Bedrock AgentCore Gateway 给 Claude Desktop 接安全 Web Search (Add Secure Web Search to Claude Desktop with Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-03
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway + Web Search（托管 MCP 连接器）
> **链接**: https://aws.amazon.com/blogs/machine-learning/add-secure-web-search-to-claude-desktop-with-amazon-bedrock-agentcore/
> **核心定位**: 用 JWT 入站鉴权（IAM Identity Center → Cognito → JWT）把"托管 Web Search"作为一个 MCP 工具接进 Claude Desktop，让桌面 Agent 在不引入第三方 API key、不把查询送出 AWS 边界的前提下获得实时联网能力

## ⚡ 快速判断（30 秒读完这段就够了 / 快速判斷）

- **一句話定位**：这篇文章不是发布新模型，而是给出一套"企业级 MCP 工具鉴权"的完整落地范式——用 AWS 原生身份链把 Web Search 接进 Claude Desktop。
- **現在值得用嗎**：看場景。若你在 AWS 上、且用 IAM Identity Center 做 SSO，这是一条几乎零外部依赖的联网方案；否则配置成本不低。
- **適合場景**：企业内已用 AWS IAM Identity Center + Claude Desktop on Bedrock；需要"查询不出企业边界"的合规型联网检索。
- **不適合場景**：个人开发者 / 非 AWS 身份体系 / 只在少数区域（us-east-1、eu-west-1、ap-northeast-1）之外部署。
- **與「自己接第三方搜索 API」核心差異**：无需管理外部 API key，查询流量全留在 AWS 基础设施内，鉴权复用企业既有 SSO 治理。

## 是什么 / 解决什么问题

Claude Desktop 挂到 Amazon Bedrock 上之后，有一个明显的短板：**没有内置 Web Search**，回答被限制在模型的训练知识截止点。一旦用户需要"最新文档更新、实时价格、天气"这类时效性信息，模型自己检索不到。

AWS 的解法不是给模型加一个搜索按钮，而是通过 **Bedrock AgentCore Gateway** 把 **Web Search** 作为一个工具接进来。Web Search 本身是 AWS 托管的、**兼容 MCP（Model Context Protocol）** 的联网检索能力，背后是一个覆盖"数百亿文档"的 Amazon web index。关键在于：**所有查询流量都留在 AWS 基础设施内，不需要管理外部 API key，查询不出你的边界**。

Claude Desktop 端则用"**托管 MCP servers（managed MCP servers）**"这个能力，去连接一个开启了 Web Search target 的 AgentCore Gateway。整篇博客的核心，其实是**鉴权怎么收口**：它演示了用 **JWT 入站鉴权（inbound authentication）** 来保护这条通信链。

这篇文章的意义不在"又一个搜索工具"，而在于它把企业 Agent 落地时最痛的一环——**工具鉴权如何复用既有身份治理**——讲成了一条可复制的链路。

## 技术架构拆解

### 核心设计决策

- **托管 MCP server 而非自建**：Claude Desktop 通过 managed MCP servers 连接 AgentCore Gateway，省去自建 MCP server、维护进程与凭据的负担。
- **JWT 入站鉴权（CUSTOM_JWT）**：Gateway 的 inbound auth type 设为 JWT，由 Cognito 签发 token、Gateway 逐请求校验，鉴权点集中在网关层。
- **复用企业 SSO，而非新建身份**：以 AWS IAM Identity Center 作为鉴权源，Claude Desktop on Bedrock 走"可信的、企业管理的身份流"，与企业既有身份治理对齐，**不需要单独的凭据或第三方 IdP**。
- **Cognito 作联邦层**：IAM Identity Center 负责用户认证（走 SAML），Amazon Cognito 作为 federation layer 用 OAuth 2.0 authorization code grant 签发 JWT，Gateway 校验之。**整条鉴权链不离开 AWS**。
- **Web Search 作为 managed connector**：以 `credentialProviderType: GATEWAY_IAM_ROLE` 挂载，工具凭据由 Gateway 的 IAM Role 提供，无需另配第三方密钥。
- **模型自动调用**：Claude Desktop 通过 MCP `tools/list` 发现 `WebSearchTool`，当模型需要实时信息时**自动调用**（而非用户手动触发）。

### 与前版/竞品的关键差异

| 维度 | 自接第三方搜索 API | 本方案（AgentCore Web Search） |
|------|------------|------------|
| 凭据管理 | 需自管外部 API key | 无需外部 key，用 Gateway IAM Role |
| 鉴权链 | 各自实现 | IAM Identity Center → Cognito → JWT 收口 |
| 流量边界 | 查询发往第三方 | 查询流量留在 AWS 基础设施内 |
| 协议 | 各 API 各异 | MCP 兼容（`supportedVersions: 2025-03-26`） |
| 身份治理 | 与 SSO 脱节 | 复用企业 SSO / SAML 治理 |
| 可用区域 | 通常全球 | 仅 us-east-1 / eu-west-1 / ap-northeast-1 |

### 架构/信息流图

```text
用户 (SSO 登录)
    │
    ▼
AWS IAM Identity Center ──(SAML)──▶ Amazon Cognito (federation layer)
    │                                     │  OAuth 2.0 authorization code
    │                                     │  签发 JWT
    │                                     ▼
    │                          Claude Desktop  (Bring your own client)
    │                               │  Streamable HTTP + OAuth
    │                               ▼
    └────────────────────▶ Bedrock AgentCore Gateway
                                   │  inbound auth = CUSTOM_JWT
                                   │  (discoveryUrl + allowedClients 校验)
                                   ▼
                          Target: web-search.v1  (managed connector)
                                   │  credentialProvider = GATEWAY_IAM_ROLE
                                   ▼
                          Amazon web index (数百亿文档)
                                   │
                                   ▼
                          结果 → 回到 Claude Desktop 响应
```

## 实用评估

### 什么场景值得用

- **已在 AWS 用 IAM Identity Center 做 SSO 的企业**：这套方案直接对齐既有身份治理，配置路径最短，无需引入第三方 IdP。
- **合规 / 数据边界敏感场景**：因为"查询流量留在 AWS 内、无外部 API key"，对不想让检索请求出边界的团队有吸引力。
- **希望复用托管能力的团队**：Web Search 是 fully managed 的 MCP 兼容能力，几乎不用自建检索后端。

### 什么场景不值得用

- **个人开发者 / 非 AWS 身份体系**：方案强依赖 IAM Identity Center + Cognito + Organizations 管理账户，个人场景下这套链路过重。
- **区域受限的部署**：Web Search 当前仅支持 **us-east-1、eu-west-1、ap-northeast-1** 三个区域，Gateway 必须建在支持区域内，其他区域用户无法直接用。
- **需要轻量即插即用的场景**：整条链要建 Cognito user pool、SAML 应用、identity provider、app client、gateway、target，配置步骤多。
- **对检索质量有强自定义需求的场景**：用的是 Amazon web index（"数百亿文档"），检索排序/来源策略由 AWS 决定，博客未提供自定义索引的细节（`> TODO: 是否有自定义索引或来源过滤能力待确认`）。

### 迁移成本

从"自建/第三方搜索工具"迁到本方案，主要是**身份链搭建**的工作量：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| Cognito user pool / domain | 低 | 一条 `create-user-pool` + `create-user-pool-domain` |
| IAM Identity Center SAML 应用 | 中 | 在管理账户手工建 SAML app、配属性映射、分配用户/组 |
| SAML IdP 接入 Cognito | 低 | `create-identity-provider` 导入 metadata XML |
| Cognito app client | 低 | 生成 client secret，配 callback `http://localhost:53280/callback` |
| Gateway + Web Search target | 中 | 跑一段 boto3 脚本，等 Gateway READY（最长约 10 分钟） |
| Claude Desktop 连接器 | 低 | 填 URL / Client ID / Secret / Authorization Server / Scope |

**预估**：有 AWS 权限的团队约半天到一天可跑通（大部分时间在等 Gateway READY 与建 SAML 应用）。清理步骤博客也给了完整的一套 `delete-*` 命令。

## 对你的意义

对 Ken 的 AI 应用开发追踪，这篇的价值不在"搜索工具"本身，而在两个可迁移的信号：

1. **MCP 的企业级鉴权范式正在成型**。这篇展示了一种典型模式：**MCP 协议 + 网关层集中鉴权（JWT）+ 企业 IdP 联邦**。这直接指向 A-001（MCP 成为工具集成事实标准）——不仅是"协议统一"，还长出了配套的**鉴权/治理层**。做 Agent 工具集成时，"工具是 MCP，鉴权收口在网关"很可能成为默认架构。

2. **"工具凭据"上移到基础设施层**。Gateway 用 `GATEWAY_IAM_ROLE` 提供工具凭据，意味着工具不再各自持有密钥——这对你评估 Agent 安全（密钥管理、权限最小化）有直接参考价值。

**建议**：**观望为主，但把架构记下来**。除非你在 AWS + Identity Center 环境里做企业 Agent，否则不必立刻复现；但"网关集中鉴权 + 托管 MCP connector"这个模式，值得在你的 Agent 安全设计里去对照。

## 关键代码/配置片段

### Gateway 创建（JWT 入站鉴权 + 挂载 Web Search target）

以下为博客中 Python（boto3）脚本的核心片段，真实引用：

```python
response = gateway_client.create_gateway(
    name=GATEWAY_NAME,
    description="AgentCore gateway with managed Web Search connector",
    roleArn=f"arn:aws:iam::{ACCOUNT_ID}:role/{ROLE_NAME}",
    protocolType="MCP",
    protocolConfiguration={
        "mcp": {
            "supportedVersions": ["2025-03-26"],
        }
    },
    authorizerType="CUSTOM_JWT",
    authorizerConfiguration={
        "customJWTAuthorizer": {
            "discoveryUrl": COGNITO_DISCOVERY_URL,
            "allowedClients": [COGNITO_CLIENT_ID],
        }
    },
)
```

挂载托管 Web Search 连接器：

```python
gateway_client.create_gateway_target(
    gatewayIdentifier=gateway_id,
    name="web-search-tool",
    description="Managed Web Search connector",
    targetConfiguration={
        "mcp": {
            "connector": {
                "source": {"connectorId": "web-search"},
                "configurations": [{"name": "WebSearch", "parameterValues": {}}],
            }
        }
    },
    credentialProviderConfigurations=[
        {"credentialProviderType": "GATEWAY_IAM_ROLE"}
    ],
)
```

### 最小 IAM 权限（InvokeWebSearch）

```json
{
  "Sid": "InvokeWebSearch",
  "Effect": "Allow",
  "Action": "bedrock-agentcore:InvokeWebSearch",
  "Resource": "arn:aws:bedrock-agentcore:us-east-1:aws:tool/web-search.v1"
}
```

### Claude Desktop 连接器参数

| 字段 | 值 |
|------|-----|
| Transport | Streamable HTTP |
| URL | AgentCore Gateway 资源 URL |
| OAuth | Bring your own client |
| Authorization Server | `https://<domain>.auth.<region>.amazoncognito.com/oauth2/authorize` |
| Scope | `openid` |
| Callback host / port | `localhost` / `53280` |

> 注：以上配置的实际可用性取决于你的 AWS 账户权限与区域（仅 us-east-1 / eu-west-1 / ap-northeast-1）。来源：AWS Machine Learning Blog 官方博客（2026-10-01）。

---
[← Back to Deep Dives](./README.md)
