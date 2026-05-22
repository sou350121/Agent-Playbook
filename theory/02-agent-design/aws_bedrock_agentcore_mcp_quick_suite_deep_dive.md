---
auto_generated: true
generated_at: "2026-05-22T11:03:58Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/integrating-aws-api-mcp-server-with-amazon-quick-suite-using-amazon-bedrock-agentcore-runtime/"
signal_type: "blog_post"
---
# AWS Bedrock AgentCore + MCP 集成 Quick Suite (AWS Bedrock AgentCore + MCP Integration with Amazon Quick)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-22
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime + AWS API MCP Server + Amazon Quick
> **链接**: https://aws.amazon.com/blogs/machine-learning/integrating-aws-api-mcp-server-with-amazon-quick-suite-using-amazon-bedrock-agentcore-runtime/
> **核心定位**: 通过 MCP 协议将 AWS API 暴露给 AI 助手，实现自然语言到 AWS CLI 命令的零代码转换

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**: AWS 官方推出的"自然语言 → AWS API"桥接方案，用 MCP 协议将 Amazon Quick（企业 AI 助手）与全部 AWS 服务打通，用户用自然语言提问即可执行 AWS CLI 命令
- **現在值得用嗎**: 是 — 如果你已经在用或计划用 Amazon Quick 作为企业内部 AI 助手，这是目前最原生的 AWS 集成路径
- **適合場景**: SRE/DevOps 日常运维查询（查 EC2 实例、S3 bucket、CloudWatch 日志）、安全审计、跨服务资源盘点
- **不適合場景**: 非 AWS 环境、需要复杂编排的多步骤操作、预算敏感的小型团队（最低 $292/月）
- **與競品核心差異**: 相比 LangChain/LangGraph 等通用 Agent 框架手动对接 AWS SDK，此方案通过 MCP 标准化了工具调用协议，AgentCore 托管了容器运行时和 JWT 认证，减少了约 70% 的胶水代码

## 是什么 / 解决什么问题

SRE 和 DevOps 工程师在管理大规模 AWS 基础设施时面临一个核心痛点：**上下文切换**。一次简单的故障排查可能需要同时打开 AWS Management Console、CLI 文档、CloudWatch Logs、IAM 策略编辑器等多个界面，手动将业务问题翻译成正确的 API 语法，跨服务链式调用，还要为每个新用例重复构建集成模式。

Amazon 的这个方案用三层架构解决该问题：

1. **Amazon Quick** — 企业级 AI 助手界面，用户在这里用自然语言提问
2. **Amazon Bedrock AgentCore Runtime** — 托管的 Agent 运行时，负责 JWT 认证、请求路由和安全边界
3. **AWS API MCP Server** — 基于 MCP 协议的适配器，将自然语言请求转换为 AWS CLI 命令

核心创新在于 **MCP 作为标准化集成层**。过去每个 AI Agent 对接 AWS 都需要手写 SDK 调用逻辑，现在通过 MCP 协议，一次配置即可让任意支持 MCP 的 AI 前端（Quick、自建 Chatbot、甚至 IDE 插件）直接调用全部 AWS API。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|---------|------|
| MCP 协议作为工具调用标准 | 一次实现，多前端复用；避免为每个 AI 前端重写集成逻辑 |
| AgentCore 托管容器运行时 | 用户无需自建服务器，AWS Marketplace 直接拉取预构建镜像 |
| Cognito JWT 认证而非 API Key | 企业级身份管理，支持 OAuth 2.0 client credentials flow，密钥轮换零停机 |
| AUTH_TYPE=no-auth 在 MCP Server 层 | 认证由 AgentCore Runtime 统一处理，MCP Server 信任网关已验证的调用者（类似 API Gateway 后的微服务） |
| Read/Write 双 OAuth Scope | 细粒度权限控制，Read 仅查询资源，Write 可修改配置，映射到 IAM 最小权限策略 |

### 七步请求流

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────────────┐
│  用户提问    │────▶│ Amazon Quick      │────▶│ Amazon Cognito       │
│ "Show EC2"  │     │ (意图解析+OAuth)   │     │ (JWT Token 签发)     │
└─────────────┘     └──────────────────┘     └──────────┬───────────┘
                                                        │ JWT Bearer
                                                        ▼
                                              ┌──────────────────────┐
                                              │ AgentCore Runtime     │
                                              │ (JWT 验证 + 路由)     │
                                              └──────────┬───────────┘
                                                         │
                                                         ▼
                                              ┌──────────────────────┐
                                              │ AWS API MCP Server   │
                                              │ (NL → AWS CLI 转换)  │
                                              └──────────┬───────────┘
                                                         │ IAM Role
                                                         ▼
                                              ┌──────────────────────┐
                                              │ AWS Services          │
                                              │ (EC2/S3/CloudWatch)  │
                                              └──────────┬───────────┘
                                                         │ 结果
                                                         ▼
                                              ┌──────────────────────┐
                                              │ Quick 界面返回        │
                                              │ (结构化可读输出)      │
                                              └──────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | 传统方案（手动 SDK 集成） | Bedrock AgentCore + MCP |
|------|------------------------|------------------------|
| 集成协议 | 手写代码，每个 Agent 框架独立实现 | MCP 标准协议，一次配置多端复用 |
| 认证机制 | 需要在应用层管理 AWS Credentials | Cognito JWT + AgentCore Identity 自动验证 |
| 部署方式 | 自建服务器/容器编排 | AWS Marketplace 一键拉取，AgentCore 托管 |
| 安全边界 | 应用层自行实现鉴权 | AgentCore Runtime 作为安全网关，JWT 验证在请求到达 MCP Server 前完成 |
| 审计追踪 | 需自行接入 CloudWatch | 原生 CloudWatch 审计日志 |
| 权限模型 | 硬编码 IAM Policy | Read/Write OAuth Scope 动态映射 IAM 角色 |
| 配置时间 | 数天到数周 | 30-45 分钟（手动部署） |

### 环境配置核心变量

| 环境变量 | 值 | 作用 |
|---------|-----|------|
| `AUTH_TYPE` | `no-auth` | MCP Server 层关闭认证，由 AgentCore 统一处理 |
| `AWS_API_MCP_TRANSPORT` | `streamable-http` | MCP 通信传输协议 |
| `AWS_API_MCP_STATELESS_HTTP` | `true` | 无状态 HTTP 模式，适配 streamable-http |
| `AWS_API_MCP_PORT` | `8000` | MCP Server 监听端口 |
| `AWS_API_MCP_HOST` | `0.0.0.0` | 绑定容器内所有网络接口 |
| `AWS_API_MCP_ALLOWED_ORIGINS` | `*` | 允许任意来源（AgentCore 环境内安全） |
| `AWS_API_MCP_ALLOWED_HOSTS` | `*` | 允许任意主机（容器网络边界内安全） |

## 实用评估

### 什么场景值得用

- **SRE 日常运维**: "Show me all running EC2 instances in us-east-1" — 直接得到结构化结果，无需记忆 CLI 语法
- **跨服务资源盘点**: 一次性查询 S3 buckets + EC2 instances + RDS 实例，无需切换 Console
- **安全审计**: 审计人员用自然语言查询 IAM 策略、安全组规则，降低安全合规门槛
- **容量规划**: "How many EC2 instances are running across all regions?" — 快速汇总
- **企业内部 AI 助手增强**: 已有 Amazon Quick 部署的团队，30 分钟即可激活 AWS 运维能力

### 什么场景不值得用

- **非 AWS 环境**: 该方案深度绑定 AWS 生态（Cognito、IAM、AgentCore），多云/混合云场景不适用
- **预算敏感的小团队**: 最低成本约 $292/月（Quick Enterprise $40/用户/月 + 基础设施费 $250/账户/月 + LLM 调用费），对 1-2 人团队不经济
- **复杂多步骤编排**: 当前方案聚焦单次查询转换，跨服务链式操作（如"停止所有未使用的 EC2 并创建快照"）需要额外开发 Quick Flows
- **需要离线运行**: 所有请求必须经过 AgentCore Runtime 和 Cognito 认证，无法离线使用
- **生产环境的 `ALLOWED_HOSTS=*`**: 教程中使用通配符仅适合测试，生产环境必须替换为具体域名

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|---------|--------|------|
| 从无到有 | 30-45 分钟 | 按教程手动部署：Cognito Pool → IAM Roles → AgentCore Agent → Quick Integration |
| 从自建 AWS Bot 迁移 | 1-2 天 | 需重写认证层为 Cognito JWT，将 SDK 调用替换为 MCP Server 容器 |
| 从 LangChain/LangGraph 迁移 | 2-3 天 | 需将自定义 AWS 工具链替换为 MCP 协议调用，调整 Agent Prompt |
| 从其他 MCP Client 接入 | 1-2 小时 | 仅需配置 endpoint URL + Cognito OAuth credentials |

## 对你的意义

这个方案对 **A-001 假设（MCP 成为 AI Agent 工具集成事实标准）** 是一个强有力的支持信号：

1. **AWS 作为最大云厂商正式采纳 MCP** — 这不是初创公司的实验，而是 AWS 官方推荐的集成模式
2. **MCP 作为"AWS API 的标准化前端"** — 意味着未来任何支持 MCP 的 Agent 框架都可以直接对接 AWS，无需 AWS 为每个框架写适配器
3. **AgentCore Runtime 的定位** — AWS 在构建自己的 "Agent 应用平台"，类似 Vercel 对前端应用的意义

**建议**: 如果你的团队重度使用 AWS，值得立即在测试环境部署体验。即使不采用 Amazon Quick 前端，AgentCore Runtime + MCP Server 的模式也可以作为自建 Agent 的参考架构。

## 关键代码/配置片段

### AgentCore Runtime Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRolePolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock-agentcore.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "YOUR_ACCOUNT_ID"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock-agentcore:*:YOUR_ACCOUNT_ID:*"
        }
      }
    }
  ]
}
```

### 示例 IAM 执行角色（只读模式）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetObject"],
      "Resource": ["arn:aws:s3:::*"]
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:DescribeInstances", "ec2:DescribeImages"],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:Region": "us-east-1"
        }
      }
    }
  ]
}
```

### Quick Agent Prompt

```
Create a conversational agent that allows users to execute AWS CLI commands 
using natural language. Translates user requests into appropriate AWS API 
calls through the aws-api-mcp connector.
```

### Cognito Discovery URL 格式

```
https://cognito-idp.{region}.amazonaws.com/{pool_id}/.well-known/openid-configuration
```

### Endpoint URL 编码

```bash
echo "YOUR_ARN" | sed 's/:/%3A/g; s/\//%2F/g'
# 输出用于 Quick Integration 的 URL-encoded ARN
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AWS 官方方案全面采用 MCP 协议，将 AWS API 通过 MCP Server 暴露给 AI Agent，标志着主流云厂商对 MCP 标准的正式采纳 |

---
[← Back to Deep Dives](./README.md)
