---
auto_generated: true
generated_at: "2026-09-19T05:45:33Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/migrating-multi-model-ai-agents-to-amazon-bedrock-agentcore-runtime/"
signal_type: "blog_post"
---
# 把多模型 Agent 从自管 ECS 迁到 Bedrock AgentCore Runtime (Migrating Multi-Model AI Agents to Amazon Bedrock AgentCore Runtime)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-19
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime
> **链接**: https://aws.amazon.com/blogs/machine-learning/migrating-multi-model-ai-agents-to-amazon-bedrock-agentcore-runtime/
> **核心定位**: 用一个 decorator 模式把「三模型编排 + 向量检索」的 Agent 从自管 ECS/Fargate 迁到托管 runtime，把容器生命周期、扩缩容、身份、可观测性交给平台，核心 Agent 逻辑零改动

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：AgentCore Runtime 是 AWS 的托管 Agent 部署层，这次演示的是「BYO agent（自带框架）」迁移路径——同一个 `healthcare_agentcore.py`，加一层装饰器就上托管 runtime。
- **現在值得用嗎**：看场景。如果你已经在 AWS 上、且团队不想再维护 ECS task definition / autoscaling / IAM per-service / CloudWatch 这套运维，值得试；如果你需要精细控制网络和扩缩容行为，留在 ECS 更合适。
- **適合場景**：多模型编排 + 向量检索这类「逻辑复杂但基础设施同质」的 Agent；已有 AWS 基础设施、想减少运维面的团队。
- **不適合場景**：对容器网络/扩缩容有强自定义需求的团队；非 AWS 栈；把本文当生产医疗方案用（官方明确标注这只是 sample implementation）。
- **與自管 ECS 部署核心差異**：部署从「Docker build + ECR push + ECS service update」多步流程，压缩成一条 `agentcore deploy`；运行时自动接管容器编排、会话级扩缩容、IAM 身份集成与内建 tracing/logging。

## 是什么 / 解决什么问题

多模型 Agent 应用的运维复杂度正在成为负担。团队要同时处理容器编排、扩缩容策略、身份体系和可观测性——而且每多接入一个模型后端，这部分负担就叠加一次。官方给出的判断很直白：**团队经常在基础设施上花的时间比在 Agent 逻辑开发上还多**。

这篇 AWS 博客的出发点是一个具体的迁移场景。此前的文章（《Agentic AI with multi-model framework using Hugging Face smolagents on AWS》）搭了一个医疗 AI Agent，跑在自管的 Amazon ECS + AWS Fargate 上，用 Hugging Face smolagents 做三模型编排 + 向量增强的知识检索。问题是：这套自管方案的容器编排、扩缩容、身份、可观测性全部由用户自己配置。

本次更新的核心，是把**同一个 Agent 逻辑**迁到 Amazon Bedrock AgentCore Runtime。AgentCore Runtime 是 AgentCore 平台的托管部署能力，负责容器生命周期、扩缩容、身份、可观测性。迁移的做法是引入一层 decorator（装饰器）模式包裹 Agent 逻辑——**装饰器和 return 之间的 Agent 代码保持不变**。

值得注意的是「model-agnostic」的演示意图：上一版自带方案用的是 Claude 3.5 Sonnet V2，本文刻意换成 Llama 3.1 70B Instruct，官方说明这是「实现选择，不是硬性要求」，用来证明 runtime 与具体模型解耦。同理，框架也是可换的——本文用 smolagents 作为参考实现，但 AgentCore Runtime 支持任何 Agentic 框架。

## 技术架构拆解

### 核心设计决策

- **Decorator 包裹而非框架绑定**：迁移不改核心逻辑，只在入口处套 `BedrockAgentCoreApp` 装饰器模式，做到「BYO agent」。这是整篇博客最关键的工程取舍——迁移成本被压到最低。
- **Runtime 接管四件事**：容器生命周期、会话级扩缩容（session-based scaling）、IAM 身份管理、内建 tracing/logging 可观测性。
- **Hugging Face Messages API 兼容**：三个模型后端统一实现 HF Messages API，无论选哪个模型服务，请求/响应格式一致。这是让「换个模型后端不影响编排层」的关键前提。
- **三后端分工索引**：不是所有查询都打给同一个模型，而是按任务类型路由。

### 三模型后端职责

| 后端 | 承载模型 | 定位 |
|------|---------|------|
| Amazon SageMaker AI | BioM-ELECTRA-Large-SQuAD2 | 专业生物医学查询，托管 endpoint + auto scaling |
| Amazon Bedrock | Llama 3.1 70B Instruct by Meta | 更广泛的医疗推理（serverless 访问 FM） |
| 容器化 model server | BioM-ELECTRA-Large-SQuAD2 | 自托管模型部署 + Hugging Face Hub 工具集成（可跑在 ECS/EKS/其他容器环境） |

### 与前版（自管 ECS/Fargate）的关键差异

| 维度 | 之前：ECS + Fargate（自管） | 现在：AgentCore Runtime（托管） |
|------|----------------------------|-------------------------------|
| 容器编排 | 用户定义 ECS task definition / service config | Runtime 自动接管 |
| 扩缩容 | 用户设 autoscaling policy | 会话级（session-based）自动扩缩容 |
| 身份 | 每个 service 单独配 IAM role | IAM 集成管理 |
| 可观测性 | 走 CloudWatch 自行搭 | 内建 tracing + logging |
| 部署动作 | Docker build → ECR push → ECS service update | 单条 `agentcore deploy` |
| 控制粒度 | 完全控制容器/网络/扩缩容 | 控制权让渡，换取零运维 |

### 架构/信息流图

```
客户端 Web UI
     │
     ▼
Amazon Bedrock AgentCore Runtime  ← 托管容器 + 内建 identity/observability
     │   (hosts healthcare agent container, smolagents + decorator)
     ▼
  TripleHealthcareAgent 编排
     ├──► SageMaker AI (BioM-ELECTRA)      ── 专业生医查询
     ├──► Bedrock (Llama 3.1 70B Instruct) ── 通用医疗推理
     └──► 容器化 model server (BioM-ELECTRA) ── 自托管 + 工具集成
     │
     └──► OpenSearch Service ── 向量相似度 + 上下文知识检索
```

## 实用评估

### 什么场景值得用

- **多模型 Agent + 想要瘦身运维**：当 Agent 逻辑复杂、但基础设施需求同质（就是容器 + 端点）时，把编排保留、把运维交出去收益最大。
- **已有 AWS 栈的团队**：IAM、Bedrock、SageMaker、OpenSearch、CloudWatch 都在 AWS 内，迁移是「同一云内换部署方式」，而不是跨云重构。
- **BYO Agent**：已经用 smolagents/Strands 等框架写好代码的团队，可以直接带代码进场，不需要为 runtime 重写。

### 什么场景不值得用

- **需要精细控制容器网络与扩缩容行为**：官方明确说 ECS + Fargate 「给你完全控制」，AgentCore Runtime 是给「偏好托管基础设施」的团队——这两类需求是互斥的。
- **非 AWS 栈 / 多云中立诉求**：整个方案深度绑定 AWS（IAM、Bedrock、SageMaker、OpenSearch）。
- **直接照搬到生产医疗场景**：原文明确标注「This solution is a sample implementation for demonstration purposes」，生产处理敏感查询需加 Amazon Bedrock Guardrails 做内容过滤与 grounding 校验。
- **需要明确的成本数字做决策**：本文未给出 AgentCore Runtime 的价格对比数据，`> TODO: 缺乏与 ECS/Fargate 自管方案的成本对比，迁移前需自行核算`。

### 迁移成本

从自管 ECS 迁移到 AgentCore Runtime，按原文步骤，需要：

1. 安装 AgentCore CLI：`npm install -g @aws/agentcore`
2. 创建 AgentCore 项目并加入 BYO agent（一条 `agentcore add agent` 命令）
3. 补 `pyproject.toml` 依赖清单与 `Dockerfile`（镜像需控制在 2 GB 限制内）
4. 跑 `agentcore deploy -y`

官方说明部署耗时约 10–15 分钟。**核心 Agent 代码零改动**——这是迁移成本的关键卖点。运行时的模型集成与向量检索组件（Bedrock、SageMaker、OpenSearch）与自管版本保持一致。

## 对你的意义

如果你在做 Agent + UI 方向，这篇的价值不在于「要不要立刻上 AgentCore」，而在于它示范了一种**托管 runtime 的接口设计范式**：

- **Decorator 作为托管层的接入契约**——`BedrockAgentCoreApp` + `@app.entrypoint` + `app.run()` 三步，把「你的代码」和「平台的运维」解耦。这个模式（入口函数 + 装饰器 + 由平台调用）本质上是 serverless 思路在 Agent 上的复刻，值得作为你自己封装部署层时的参考。
- **Messages API 兼容作为多后端解耦层**：三后端统一 HF Messages API 格式，意味着编排层不需要感知下游是 SageMaker 还是 Bedrock。这个「协议层统一」的思路，可以直接迁移到你自己的多 provider 抽象设计里。
- **判断建议**：如果你的项目已经在 AWS 上且运维面在扩大，**可以试用**——迁移路径便宜（逻辑不动），验证成本主要是 CLI 上手和一个 demo 容器。但先别把生产敏感场景压上去，等 Guardrails 那层补齐、以及拿到真实成本对比再说。

## 关键代码/配置片段

**接入契约（decorator 模式，来自源材料）**：

```python
from bedrock_agentcore.runtime import BedrockAgentCoreApp

app = BedrockAgentCoreApp()

@app.entrypoint
def healthcare_agent_entrypoint(payload):
    user_input = payload.get("prompt", "")
    model_type = payload.get("model_type", "sagemaker")
    # Your existing agent logic here
    agent = TripleHealthcareAgent(vector_store=vector_store)
    response = agent.run(user_input, model_type=model_type)
    return str(response)

if __name__ == "__main__":
    app.run()
```

**CLI 创建项目 + 加入 BYO agent（来自源材料）**：

```bash
npm install -g @aws/agentcore

agentcore create --project-name healthcareagent --no-agent --build Container \
  --language Python --protocol HTTP --model-provider Bedrock --memory none

agentcore add agent --name healthcare_agentcore --type byo --build Container \
  --language Python --protocol HTTP --network-mode PUBLIC \
  --code-location ./agent-code --entrypoint healthcare_agentcore.py \
  --framework Strands --model-provider Bedrock
```

> 注：`--framework` 只决定 CLI 模板，实际 Agent 代码用的是 Hugging Face smolagents，与模板选择无关。

**部署与调用（来自源材料）**：

```bash
agentcore deploy -y
agentcore invoke --prompt '{"prompt": "What are the side effects of metformin?", "model_type": "llama"}'
```

```python
import boto3, json

client = boto3.client('bedrock-agentcore', region_name='us-west-2')

payload = json.dumps({
    "prompt": "What are the side effects of metformin?",
    "model_type": "llama"
})

response = client.invoke_agent_runtime(
    agentRuntimeArn='<your-agent-runtime-arn>',
    contentType='application/json',
    accept='application/json',
    payload=payload.encode('utf-8')
)

result = response['response'].read().decode('utf-8')
print(result)
```

**清理资源（来自源材料）**：

```bash
agentcore remove all
agentcore deploy
aws sagemaker delete-endpoint --endpoint-name healthcare-agentcore-endpoint-1 --region us-west-2
aws opensearch delete-domain --domain-name healthcare-vector-store --region us-west-2
```

---
[← Back to Deep Dives](./README.md)
