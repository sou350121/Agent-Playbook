---
auto_generated: true
generated_at: "2026-08-16T03:33:03Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/deploying-anthropic-claude-apps-gateway-for-aws-for-enterprise-workloads/"
signal_type: "significant_update"
---
# Claude Apps Gateway for AWS 企业部署指南 (Claude Apps Gateway for AWS — Enterprise Deployment Guide)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-16
>
> **项目/工具**: Claude Apps Gateway for AWS
> **链接**: https://aws.amazon.com/blogs/machine-learning/deploying-anthropic-claude-apps-gateway-for-aws-for-enterprise-workloads/
> **核心定位**: Anthropic 推出的自托管治理层，在 Claude Code / Claude Desktop 与 Amazon Bedrock 之间提供 SSO 认证、模型策略、用量遥测、路由容灾和预算管控五大能力，填补企业级 AI 编码工具部署的管控空白。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：一个容器 + 一个 YAML 配置，把 Claude Code/Desktop 从"开发者个人工具"变成"企业可管控的基础设施"。
- **現在值得用嗎**：是——如果你的团队已在 AWS 上部署 Claude Code/Desktop 且规模超过 10 人。小团队（<5 人）或不用 AWS 的场景跳过。
- **適合場景**：企业多团队分级模型访问、按人/组预算管控、SSO 集成、跨 Region 容灾。
- **不適合場景**：需要原生 Bedrock 功能（Knowledge Bases、Agents、Flows）的生产工作负载；非 AWS 云环境。
- **與前版核心差異**：从"发布即弃"的初始版本升级为生产级参考架构，新增 5 种部署模式、Spend Caps API、OpenTelemetry 遥测、跨 Provider 容灾。

## 是什么 / 解决什么问题

Claude Code 和 Claude Desktop 的普及让企业面临一个典型困境：开发者可以轻易在自己的机器上安装并直连 Anthropic API，但 IT 部门缺乏集中管控手段——谁在用、用了什么模型、花了多少钱、数据去了哪里，全部不可见。

Claude Apps Gateway 就是为了解决这个问题而生的。它部署在你的 VPC 内部，作为 Claude 客户端与后端推理服务（Amazon Bedrock 或 Claude Platform on AWS）之间的中间层。开发者运行同样的 `claude` 命令行工具，但所有请求必须经过 Gateway 的认证、策略检查和路由，平台团队则获得一个统一的控制面。

这个方案的核心设计哲学是**"零客户端改造"**——开发者不需要安装额外软件，不需要管理 API Key，不需要改变工作习惯。一切管控发生在服务端，对开发者透明。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 | 替代方案 |
|----------|------|----------|
| 与 Claude Code CLI 同二进制分发 | 零额外安装，开发者无感知 | 独立部署二进制（增加运维负担） |
| 状态存 RDS PostgreSQL，非 Task 本地 | 无状态容器 → 任意 Task 服务任意请求，无需 Sticky Session | 内存/本地存储（无法水平扩展） |
| OIDC 委托认证，不自建用户目录 | 复用企业现有 IdP，Offboarding 只需移除 IdP 用户 | 自建用户管理（重复造轮子） |
| 策略按声明顺序匹配，首个命中生效 | 简单可预测，类似 iptables 规则链 | 优先级/权重系统（复杂度飙升） |
| Spend Caps 在 Gateway 层内联拦截 | 实时熔断，不等月度账单 | 仅靠 AWS Budgets（滞后，无法事前阻止） |
| OTLP 遥测，默认仅 Metrics | 提供按人用量归因，不含源代码/提示词泄露风险 | 全量日志/Traces（安全与隐私隐患） |

### 与前版/竞品的关键差异

| 维度 | 之前（无 Gateway） | Claude Apps Gateway |
|------|-------------------|---------------------|
| 认证 | 每个开发者管理自己的 API Key | 统一 OIDC SSO，1 小时短 Token |
| 模型访问控制 | 无（开发者可调用任意模型） | 服务端强制，按 Group 分级 |
| 预算管控 | AWS Budgets 月度汇总（事后） | 实时内联拦截，按人/组/组织三级 |
| 用量归因 | 按 AWS Account 级别 | 按认证用户 ID + Email + Group |
| 路由容灾 | 单点，无自动切换 | 多上游声明式配置，自动 Failover |
| Offboarding | 需回收/轮换 API Key | 从 IdP 移除，1 小时内 Token 过期 |
| 部署复杂度 | 零（开发者自行安装） | 中等（Fargate + RDS + ALB + VPC） |

### 架构/信息流图

```
┌─────────────┐     /login (OAuth 2.0 Device Grant)     ┌──────────────┐
│  Developer   │ ──────────────────────────────────────> │              │
│  Machine     │                                        │  OIDC IdP    │
│  (Claude     │ <────────────────────────────────────── │  (Entra/     │
│   Code/      │        Bearer Token (1h TTL)           │   Okta/etc)  │
│   Desktop)   │                                        └──────────────┘
│              │
│              │     Inference Request + Bearer Token
└──────┬───────│ ──────────────────────────────────────> ┌──────────────┐
       │       │                                        │              │
       │       │ <────────────────────────────────────── │  Gateway     │
       │       │        Streaming Response               │  (Fargate)   │
       │       │                                        │              │
       │       │ ──────────────────────────────────────> │  RDS         │
       │       │        Auth State / Spend Counters     │  PostgreSQL  │
       │       │                                        └──────────────┘
       │       │
       │       │ ──────────────────────────────────────> ┌──────────────┐
       │       │        Route to upstream               │  Bedrock     │
       │       │ <────────────────────────────────────── │  / Claude    │
       │       │        Streaming Response              │  Platform    │
       │       │                                        └──────────────┘
       │       │
       │       │ ──────────────────────────────────────> ┌──────────────┐
       └───────┘        OTLP Metrics                    │  OTel        │
                                                        │  Collector   │
                                                        │  → CloudWatch│
                                                        └──────────────┘
```

### 五大能力详解

#### 1. 身份认证（SSO）

Gateway 不维护自己的用户目录。它完全委托给企业的 OIDC IdP（Microsoft Entra ID、Okta、Auth0、Keycloak、Cognito 等）。开发者运行 `/login` 后，通过浏览器完成 SSO 认证，Gateway 发放 1 小时有效期的 Bearer Token，后台静默刷新。

关键优势：Offboarding 只需从 IdP 移除用户，无需回收任何 API Key。Token 最长 1 小时后过期。

#### 2. 策略引擎（模型访问 + 工具权限）

策略按声明顺序评估，首个命中即生效。每个策略条目可配置：
- `availableModels`：该组可用的模型列表
- `enforceAvailableModels`：是否强制限制（默认 false）
- `permissions.allow/deny`：工具级权限（WebFetch、WebSearch、Read、Bash 等）
- `desktop: {}`：启用 Claude Desktop 客户端（必须显式声明）

策略变更 1 小时内传播到所有在线客户端，无需开发者操作。

#### 3. 遥测（按人用量归因）

客户端发射三个 OpenTelemetry 指标：
- `claude_code.token.usage` — Token 消耗
- `claude_code.cost.usage` — 估算成本
- `claude_code.active_time.total` — 活跃时间

通过 OTLP 转发到 CloudWatch、Datadog、Grafana 等后端。默认仅开启 Metrics（不含源代码和提示词内容）。

#### 4. 路由与容灾

支持多上游声明式配置，按顺序尝试。上游可以是：
- Amazon Bedrock（使用 ECS Task IAM Role，无需静态 Key）
- Claude Platform on AWS（使用 API Key）
- 跨 Region Bedrock（用于容灾）

自动 Failover 条件：上游不可用、限流（429）、超时。

#### 5. 预算管控（Spend Caps）

三级 Caps 体系：组织默认 → 组级覆盖 → 用户级覆盖。每个 Cap 独立作用于每个开发者（非团队共享池）。

Cap 基于列表价格从 Token 数估算，是**实时熔断器**而非发票。数据库不可用时默认 fail-open（允许推理继续），可配置 `fail_closed_on_error: true` 改为 fail-closed。

## 部署模式

Gateway 提供 5 种参考部署模式，从简单到复杂：

| 模式 | 适用场景 | 核心特征 |
|------|----------|----------|
| A: 单团队单 Region | 评估阶段 / 小型团队 | 最简部署，1 个 Bedrock 上游，组织级日 Cap |
| B: 多团队分级访问 | 中型企业，多团队 | 按 Group 差异化模型访问 + Spend Cap |
| C: 混合上游 | 需要 Bedrock + Claude Platform 双源 | Bedrock 为主，Claude Platform 为溢出容灾 |
| D: 开发工具 vs 生产分离 | 开发需治理，生产需原生功能 | Gateway 管开发者工具，直连 Bedrock 管生产 |
| E: 多 Account 共享服务 | 大型企业，多 BU | Gateway 在共享服务 Account，各 BU 独立 Bedrock Account |

### 模式 D 值得特别注意

这是最务实的混合架构：
- **开发者工具**（Claude Code/Desktop）→ 走 Gateway → 获得 SSO、策略、遥测、预算管控
- **生产工作负载**（Bedrock Knowledge Bases、Agents、Flows）→ 直连 Bedrock → 获得完整原生功能

Gateway 不代理原生 Bedrock 功能——这是设计选择，不是缺陷。生产负载需要独立配额和原生特性，不应与开发者工具共享基础设施。

## 实用评估

### 什么场景值得用

- **50+ 开发者使用 Claude Code 的企业**：SSO 集成 + 模型分级 + 预算管控的 ROI 极高
- **合规要求严格的行业**（金融、医疗、政府）：所有请求经过 VPC 内部署的 Gateway，数据不出 AWS 边界
- **多团队分级管理**： contractors 只能用 Haiku、engineers 可用 Opus、platform 团队无限制——一个 YAML 搞定
- **预算失控风险**：实时 Spend Cap 防止单个开发者月度花费失控（如 $500/人/月上限）

### 什么场景不值得用

- **< 10 人的小团队**：运维 Gateway 的复杂度（Fargate + RDS + ALB + VPC）超过收益
- **需要原生 Bedrock 功能的生产工作负载**：Knowledge Bases、Agents、Flows 不经过 Gateway 代理
- **非 AWS 环境**：Gateway 深度绑定 AWS 生态（Bedrock、IAM、RDS、ALB），在 GCP/Azure 上部署意义有限
- **只需要 API Key 管理**：如果只是不想让开发者持有 API Key，更简单的方案是内部代理或 API 网关

### 迁移成本

从"开发者直连 API"迁移到 Gateway 架构：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 部署基础设施（Fargate + RDS + ALB） | 2-4 小时 | 使用 AWS CDK 或 setup.sh 脚本 |
| 配置 OIDC IdP 集成 | 1-2 小时 | 在 Entra ID/Okta 创建应用，配置回调 |
| 编写策略 YAML | 1-3 小时 | 取决于团队数量和分级复杂度 |
| 分发 Managed Settings | 30 分钟 | 通过 MDM 或脚本推送 Gateway URL |
| 配置 OTel Collector | 1-2 小时 | CloudWatch/Datadog/Grafana 集成 |
| 开发者培训 | 30 分钟 | 主要是 `/login` 流程变化 |
| **总计** | **约 1-2 人日** | 首次部署，后续运维极低 |

## 对你的意义

Ken，这个工具对你关注 **Agent + UI** 方向有几个值得注意的信号：

1. **企业 AI 编码治理正在标准化**：Anthropic + AWS 联手推出的这个方案，标志着 AI 编码工具从"个人效率工具"正式进入"企业基础设施"阶段。如果你在做 Agent 相关的企业产品，治理层（SSO、策略、预算、遥测）将越来越成为采购决策的关键因素。

2. **Agent 工具权限模型参考**：Gateway 的 `permissions.allow/deny` 设计（按 Group 分级、工具级粒度、服务端强制）是一个很好的 Agent 权限控制参考模型。你如果设计 Agent Builder 产品，这个模式值得借鉴。

3. **Spend Caps 的启示**：按人实时预算管控 + 列表价格估算 + 实时熔断——这个模式可以迁移到任何 AI Agent 场景。如果你的 Agent 平台需要多租户计费，这个三级 Caps 体系（组织/组/用户）是一个成熟的设计模式。

**建议**：如果你的团队规模超过 10 人且使用 Claude Code，值得部署评估。如果只是个人使用，跳过。

## 关键代码/配置片段

### OIDC 配置（Microsoft Entra ID）

```yaml
oidc:
  issuer: https://login.microsoftonline.com/<tenant-id>/v2.0
  client_id: ${OIDC_CLIENT_ID}
  client_secret: ${OIDC_CLIENT_SECRET}
  allowed_email_domains: [company.com]
  groups_claim: roles
```

> ⚠️ 注意：Entra ID 默认不包含 Group/Role claims，需要显式配置 `groups_claim: roles`，否则所有用户只匹配 catch-all 策略。

### 策略配置（多团队分级）

```yaml
managed:
  policies:
    # 外包人员：仅 Haiku，禁止 Web 访问
    - match: { groups: [contractors] }
      cli:
        availableModels: [claude-sonnet-5, claude-haiku-4-5]
        enforceAvailableModels: true
      permissions:
        deny: ["WebFetch", "WebSearch"]

    # 工程师：完整模型 + 工具权限限制
    - match: { groups: [engineers] }
      cli:
        availableModels: [claude-opus-4-8, claude-sonnet-5, claude-haiku-4-5]
      permissions:
        allow: [Read, Grep, Bash, Edit]
        deny: ["Read(./.env)", "Read(./secrets/**)"]

    # 兜底策略：必须放在最后
    - match: {}
      cli:
        availableModels: [claude-haiku-4-5, claude-sonnet-5]
```

### 多上游路由（Bedrock + Claude Platform 容灾）

```yaml
upstreams:
  - name: bedrock-east
    provider: bedrock
    region: us-east-1
    auth: {}
  - name: bedrock-west
    provider: bedrock
    region: us-west-2
    auth: {}
  - name: claude-platform
    provider: anthropicAws
    region: us-east-1
    workspace_id: wrkspc_01ABCDEFGHIJKLMN
    auth:
      api_key: ${ANTHROPIC_AWS_API_KEY}
```

### Spend Caps API（三级管控）

```bash
# 组织默认：$500/人/月
curl -X POST https://<gateway>/v1/organizations/spend_limits \
  -H "x-api-key: $ADMIN_KEY" \
  -d '{"scope":{"type":"organization"},"amount":"50000","period":"monthly"}'

# 组级覆盖：外包人员 $10/天
curl -X POST https://<gateway>/v1/organizations/spend_limits \
  -H "x-api-key: $ADMIN_KEY" \
  -d '{"scope":{"type":"rbac_group","rbac_group_id":"contractors"},"amount":"1000","period":"daily"}'

# 用户级：即时关停某用户
curl -X POST https://<gateway>/v1/organizations/spend_limits \
  -H "x-api-key: $ADMIN_KEY" \
  -d '{"scope":{"type":"user","user_id":"<oidc-sub>"},"amount":"0","period":"daily"}'
```

### 遥测配置（仅 Metrics）

```yaml
telemetry:
  forward_to:
    - url: https://otel-collector.internal.example.com
      metrics: true
      logs: false
      traces: false
```

---
[← Back to Deep Dives](./README.md)
