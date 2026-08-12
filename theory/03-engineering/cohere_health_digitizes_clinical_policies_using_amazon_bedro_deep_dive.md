---
auto_generated: true
generated_at: "2026-08-12T06:50:07Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/how-cohere-health-digitizes-clinical-policies-using-amazon-bedrock-agentcore/"
signal_type: "significant_update"
---
# Cohere Health 在 Amazon Bedrock AgentCore 上构建多租户 AI Agent 系统 (Cohere Health Digitizes Clinical Policies Using Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-12
>
> **项目/工具**: Amazon Bedrock AgentCore + Cohere Policy Studio
> **链接**: https://aws.amazon.com/blogs/machine-learning/how-cohere-health-digitizes-clinical-policies-using-amazon-bedrock-agentcore/
> **核心定位**: AWS 推出 AgentCore 托管运行时，Cohere Health 用它构建了多租户临床政策数字化 Agent 系统，将政策数字化时间缩短 30%，部署周期从 3-4 个月压缩到 2-6 周。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Amazon Bedrock AgentCore 是一套托管的 AI Agent 运行时基础设施（Runtime + Gateway + Memory），Cohere Health 基于它构建了多租户临床政策数字化平台 Policy Studio，解决了医疗行业 prior authorization 流程中政策文档难以结构化的瓶颈。
- **現在值得用嗎**：看场景——如果你需要在 AWS 上部署多租户、多会话隔离的 AI Agent 系统，AgentCore 提供了开箱即用的微 VM 隔离和 MCP/A2A 协议支持；如果是单租户或轻量场景，直接自建更灵活。
- **適合場景**：医疗/金融等需要严格租户隔离的 AI Agent 部署；需要快速迭代 Agent 技能（Skills）的团队；已有 AWS 基础设施、希望减少 Agent 运维负担的组织。
- **不適合場景**：非 AWS 环境；不需要多租户隔离的轻量 Agent；对延迟极度敏感的场景（微 VM 冷启动有额外开销）。
- **與傳統自建 Agent 平台核心差異**：AgentCore 把会话隔离、工具网关、记忆管理、身份认证打包为托管服务，团队只需关注 Agent 业务逻辑（Skills），无需自建 DevOps 管道。

## 是什么 / 解决什么问题

### 背景痛点：临床政策数字化瓶颈

Prior authorization（预先授权）是健康保险公司在覆盖特定医疗服务或药物前要求的审批流程。这个流程的核心——临床政策——被困在静态、非结构化的文档和 PDF 中，难以自动化。政策内容因临床领域、地理区域、业务线和健康计划而异，并随医学和技术进步不断演变。

历史上，健康计划缺乏系统化的方法来管理、分析和优化这些政策。CMS（美国医疗保险和医疗补助服务中心）要求健康计划在 **2027 年 1 月前**支持基于 API 的电子预先授权；AHIP（美国健康保险计划协会）要求实现 **80% 的电子预先授权实时审批率**。技术挑战在于：系统需要摄入多种输入格式，并为不同下游消费者产生不同的策略表示，每个都有独立的反馈循环。

### Cohere 的解决方案

Cohere Health 构建了 **Cohere Policy Studio**，基于 Amazon Bedrock AgentCore 的多租户 Agent 架构，将临床政策数字化为结构化、机器可读的数据。核心思路是：

1. **AgentCore Runtime** 提供微 VM 级别的会话隔离，确保不同租户数据严格分离
2. **AgentCore Gateway** 统一管理工具访问（Lambda 函数、内部 API），通过 MCP 协议暴露
3. **AgentCore Memory** 提供会话级记忆，支持分析师反馈循环
4. **Agent Skills**（agentskills.io 开放标准）将领域知识模块化，临床政策专家可直接编写和迭代技能，无需重建 Agent 基础设施

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|---------|------|
| 微 VM 会话隔离 | 医疗数据需要严格的租户隔离，每个会话的 CPU/内存/文件系统完全独立，会话结束后微 VM 终止并清理内存 |
| 双层部署架构（Base Image + Config） | 共享运行时环境与团队特定配置分离，新 Agent 部署只需最小 Dockerfile |
| Gateway 统一工具接入 | 多个团队维护不同工具集，Gateway 提供单一认证端点，新增工具无需重新部署 Agent |
| Skills 模块化 | 领域知识与基础设施解耦，临床专家可直接编写技能定义，CI/CD 自动打包部署 |
| 双版本控制（Git + S3） | Git 追踪能力变更，S3 对象版本提供不可变部署历史和回滚能力 |

### 架构信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Cohere Policy Studio                     │
│                  (Multi-Tenant Frontend)                     │
└──────────────────────┬──────────────────────────────────────┘
                       │ 用户请求（带身份认证）
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  AgentCore Identity                         │
│       (Okta / Entra ID / Cognito 身份验证)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐
   │ Tenant A │ │ Tenant B │ │ Tenant C │  ← 每个租户独立微 VM
   │ MicroVM  │ │ MicroVM  │ │ MicroVM  │     隔离 CPU/内存/FS
   └────┬─────┘ └────┬─────┘ └────┬─────┘
        │            │            │
        └────────────┼────────────┘
                     ▼
   ┌─────────────────────────────────┐
   │      AgentCore Gateway          │
   │  ┌───────────┬───────────────┐  │
   │  │ generic-  │ digitization- │  │  ← 工具按 target 分组
   │  │ tools     │ tools         │  │
   │  └───────────┴───────────────┘  │
   │         MCP Protocol            │
   └────────────┬────────────────────┘
                │ Lambda 函数路由
                ▼
   ┌─────────────────────────────────┐
   │         Tool Handlers           │
   │  fetch_skill → S3 (YAML)        │
   │  policy_api → Internal API      │
   └─────────────────────────────────┘

   ┌─────────────────────────────────┐
   │       AgentCore Memory          │
   │  (NO_MEMORY / AGENTCORE)        │  ← 会话记忆可配置
   └─────────────────────────────────┘

   ┌─────────────────────────────────┐
   │      Skill Definitions          │
   │  S3: skill/policy_ingestion/    │
   │         v1.2.3/skill.yaml       │
   │  (Git tag + S3 versioning)      │
   └─────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | 传统自建 Agent 平台 | Amazon Bedrock AgentCore |
|------|-------------------|------------------------|
| 会话隔离 | 需自建容器/进程隔离 | 微 VM 级别隔离，托管服务 |
| 多租户 | 需自行实现数据隔离 | 原生支持，每个会话独立身份 |
| 工具管理 | 手动配置 API 端点 | Gateway 统一管理，MCP 协议 |
| 记忆管理 | 自建数据库/缓存 | AgentCore Memory 托管 |
| 部署模型 | 全量重建或复杂编排 | Base Image + Config 双层模式 |
| 协议支持 | 需自行实现 | 原生 MCP + A2A |
| 执行时长 | 受限于自有基础设施 | 最长 8 小时 |
| 计费模式 | 按实例/预留 | 按实际消耗（I/O 等待不计费） |
| 可观测性 | 需集成第三方工具 | 内置 Agent 追踪（推理步骤 + 工具调用） |

## 实用评估

### 什么场景值得用

1. **医疗/金融等强监管行业的多租户 Agent 部署**
   - 理由：微 VM 隔离提供了确定性的安全保证——会话结束后整个环境终止并清理内存。对于处理 PHI（受保护健康信息）的场景，这是硬性要求。

2. **需要快速迭代 Agent 技能的团队**
   - 理由：Skills 框架将领域知识与基础设施解耦。Cohere Health 的临床政策专家可以直接编写 YAML 格式的技能定义，通过 CI/CD 自动部署到生产环境，无需重建 Agent 运行时。部署周期从 3-4 个月缩短到 2-6 周。

3. **已有 AWS 基础设施的组织**
   - 理由：AgentCore 与 ECR、S3、Lambda、IAM 等 AWS 服务深度集成。如果团队已经在 AWS 上运行，AgentCore 提供了最低的 Agent 部署摩擦。

4. **需要 MCP/A2A 协议支持的场景**
   - 理由：AgentCore 原生支持 MCP（Model Context Protocol）和 A2A（Agent-to-Agent）协议，便于与其他 Agent 系统和工具集成。

### 什么场景不值得用

1. **非 AWS 环境或多云场景**
   - AgentCore 是 AWS 专属服务，不支持跨云部署。如果团队使用 GCP/Azure 或混合云，需要考虑自建方案或其他框架（如 LangGraph + 自托管基础设施）。

2. **单租户轻量 Agent**
   - 微 VM 隔离和 Gateway 管理对于单用户、单租户的轻量 Agent 来说是过度工程。直接用 LangChain/LangGraph 自建更简单。

3. **对冷启动延迟极度敏感的场景**
   - 微 VM 需要冷启动时间（虽然 AWS 声称"instant"），如果应用需要在毫秒级响应，可能需要考虑预热的 Instance 模式而非微 VM。

4. **需要 GPU 加速的实时推理**
   - 微 VM 模式不支持 GPU。需要 GPU 的场景需使用 Instance 模式（EC2 基础设施），但这会牺牲部分托管便利性。

### 迁移成本

从自建 Agent 平台迁移到 AgentCore 的成本评估：

| 迁移项 | 工作量 | 说明 |
|--------|--------|------|
| Agent 代码适配 | 低-中 | AgentCore 框架无关（支持 LangGraph/Strands/CrewAI），主要改动是集成 SDK |
| 工具迁移到 Gateway | 中 | 需要将现有 API/Lambda 重新注册到 Gateway target，配置 MCP 路由 |
| 记忆层迁移 | 低 | 用 AgentCore Memory 替换自建记忆存储，配置 NO_MEMORY/AGENTCORE 模式 |
| 部署管道改造 | 中 | 需要建立 Base Image + Config 双层 Docker 构建流程 |
| Skills 框架搭建 | 高 | 需要定义技能 YAML 格式、CI/CD 管道、版本控制策略 |
| 身份认证集成 | 低-中 | 如果已使用 Okta/Entra ID/Cognito，集成成本低 |

**总体估计**：一个中等规模的 Agent 团队（3-5 人），从自建平台迁移到 AgentCore 预计需要 **4-8 周**，包括基础设施改造和 Skills 框架搭建。

## 对你的意义

这个案例对 AI Agent 工程实践有几个重要启示：

1. **多租户 Agent 架构正在成为企业级刚需**。Cohere Health 的场景（多个健康计划、严格数据隔离）在企业 AI 部署中非常典型。AgentCore 提供的微 VM 隔离方案是一个值得参考的架构模式——即使你不直接使用 AgentCore，也可以借鉴其双层部署和 Skills 模块化思路。

2. **Skills 作为 Agent 的"插件系统"是一个重要趋势**。将领域知识从 Agent 基础设施中解耦，让领域专家（而非 ML 工程师）直接编写和迭代技能，这大幅提升了 Agent 系统的可扩展性。agentskills.io 作为开放标准值得持续关注。

3. **MCP 正在成为 Agent 工具集成的事实标准**。AgentCore Gateway 完全基于 MCP 协议暴露工具，这进一步验证了 MCP 在企业 Agent 架构中的核心地位。

4. **托管 Agent 运行时 vs 自建：权衡点在于规模**。Cohere Health 的案例表明，当需要服务多个租户、频繁迭代技能、且团队规模不足以支撑专职 Agent DevOps 时，托管方案（AgentCore）的 ROI 显著。

**建议**：如果你在 AWS 上部署多租户 Agent 系统，值得花半天时间评估 AgentCore 的适用性。重点关注微 VM 隔离是否能满足你的合规要求，以及 Skills 框架是否能适配你的领域知识管理模式。

## 关键代码/配置片段

### 双层部署架构：最小 Dockerfile

```dockerfile
FROM {account_id}.dkr.ecr.{aws_region}.amazonaws.com/cohere-agent:v1
COPY agent_config.yaml /app/src/agent_config.yaml
```

第一层镜像包含 LangChain Agent 框架和公共依赖；第二层仅拷贝团队特定的配置文件。

### Agent 配置示例

```yaml
# agent_config.yaml
mcp:
  gateway_url: {gateway_url}
  allowed_targets:
    - generic-tools      # AIP-maintained tools
    - digitization-tools # Project-specific tools
  auth_mode: "bearer_token"
```

### Gateway Lambda 工具路由

```python
# jobs/generic-tools-lambda/app.py
import json
from tools.fetch_skill import handler as fetch_skill_handler

TOOL_HANDLERS = {
    "fetch_skill": fetch_skill_handler
}

def lambda_handler(event, context):
    tool_name = context.client_context.custom.get('bedrockAgentCoreToolName', '')
    if '__' in tool_name:
        tool_name = tool_name.split('__', 1)[1]
    if tool_name not in TOOL_HANDLERS:
        return {"statusCode": 404, "body": json.dumps({"error": f"Tool {tool_name} not found"})}
    try:
        result = TOOL_HANDLERS[tool_name](event)
        return {"statusCode": 200, "body": json.dumps(result)}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
```

### 工具实现：从 S3 获取技能定义

```python
# tools/fetch_skill.py
import boto3, os

def handler(event: dict) -> dict:
    skill_id = event.get('skill_id')
    if not skill_id:
        return {"error": "skill_id required"}
    bucket = os.environ.get('SKILLS_BUCKET')
    prefix = os.environ.get('SKILLS_PREFIX')
    s3 = boto3.client('s3')
    response = s3.get_object(Bucket=bucket, Key=f"{prefix}/{skill_id}.yaml")
    return {"content": response['Body'].read().decode('utf-8')}
```

### 可观测性集成：Arize AI

技能部署后，通过 Arize AI 追踪生产环境的有效性指标。临床政策分析师对样本输出进行标注，捕捉自动化指标遗漏的错误。团队监控技能退化并据此优先优化工作。

---

## 量化结果

| 指标 | 改善 |
|------|------|
| 政策数字化时间 | 从 2h15m → 1h35m/政策（缩短 30%） |
| Agent 部署周期 | 从 3-4 个月 → 2-6 周 |
| 已数字化政策 | 数千份（持续扩展中） |
| 架构模式 | 单 Agent + 多 Skill（1 个主 Skill + 1 个子 Skill + 3 个参考注入） |

---
[← Back to Deep Dives](./README.md)
