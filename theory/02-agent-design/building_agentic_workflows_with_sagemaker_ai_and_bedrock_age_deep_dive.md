---
auto_generated: true
generated_at: "2026-08-15T05:49:38Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/building-agentic-workflows-with-sagemaker-ai-and-bedrock-agentcore/"
signal_type: "blog_post"
---
# 用 SageMaker AI + Bedrock AgentCore 构建多模型 Agent 工作流 (Building Agentic Workflows with SageMaker AI and Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-15
>
> **项目/工具**: Amazon SageMaker AI + Amazon Bedrock AgentCore Runtime + Strands Agents
> **链接**: https://aws.amazon.com/blogs/machine-learning/building-agentic-workflows-with-sagemaker-ai-and-bedrock-agentcore/
> **核心定位**: AWS 官方参考架构，演示如何在同一个 AgentCore 容器内混合托管模型（Bedrock Claude）与自部署模型（SageMaker vLLM），并解决跨模型 token 可观测性难题。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：一套 AWS 原生架构，让你在同一 Agent 工作流中混用 Bedrock 托管模型和自己部署的开源模型（如 Qwen 3.5），同时保持完整的 token 级可观测性。
- **現在值得用嗎**：是——如果你已经在 AWS 上运行 Agent 工作流且需要成本控制或数据驻留。
- **適合場景**：混合模型策略（低成本路由+高性能推理）、需要自部署微调模型、对 token 成本/延迟有监控需求的生产环境。
- **不適合場景**：非 AWS 用户、不需要自部署模型的场景（直接用 Bedrock 更简单）、对延迟极度敏感的场景（SageMaker 实时端点有冷启动开销）。
- **與純 Bedrock 方案核心差異**：Bedrock 开箱即用但只能用它支持的模型；本方案允许任意 vLLM 可承载的开源模型进入 Agent 工作流，代价是需要手动处理认证和可观测性。

## 是什么 / 解决什么问题

在构建 AI Agent 工作流时，一个常见痛点是：**托管模型和自部署模型很难无缝混用**。Bedrock 提供了开箱即用的 Claude/Nova 等模型，但当你需要运行自己的微调模型、需要数据驻留、或需要成本优化时，你不得不引入 SageMaker 端点。问题是，这两个世界的 API、认证、可观测性完全不同——你的 Agent 框架需要为不同模型写不同的调用逻辑，而且自部署模型的 token 消耗在监控系统中完全不可见。

AWS 这篇博客文章给出的参考架构解决了三个具体问题：

1. **统一入口**：通过 Bedrock AgentCore Runtime 作为统一容器，让 Claude（Bedrock）和 Qwen 3.5（SageMaker）在同一个 Agent 工作流中协作。
2. **透明认证**：用 httpx.Auth 子类实现 SageMaker 端点 bearer token 的自动刷新，解决长会话中 token 过期的问题。
3. **完整可观测性**：通过自定义 OpenTelemetry span，让 SageMaker 端点的 token 消耗在 AgentCore 的追踪系统中与 Bedrock 调用同等可见。

这不仅仅是一个教程——它揭示了一个重要的架构趋势：**Agent 框架正在从"单一模型提供者"向"多模型路由层"演进**。Strands Agents 的 "agents as tools" 模式让每个子 Agent 可以独立选择最合适的模型，而 Orchestrator 负责路由。

## 技术架构拆解

### 核心设计决策

| 决策点 | 方案 | 理由 |
|--------|------|------|
| 编排模型 | Claude Haiku 4.5 on Bedrock (Global cross-Region) | 低延迟意图分类 + 路由，Haiku 性价比最优 |
| 预算 Agent | Claude Sonnet 4.6 on Bedrock | 需要结构化输出（Pydantic），Sonnet 在结构化任务上表现更好 |
| 金融分析 Agent | Qwen 3.5 9B on SageMaker AI (vLLM) | 工具调用 + 领域分析，开源模型足够胜任且成本更低 |
| 部署容器 | Bedrock AgentCore Runtime | 统一管理生命周期、自动 OpenTelemetry 注入 |
| 多 Agent 模式 | Strands "agents as tools" | 每次调用创建新鲜 Agent 实例，避免并发冲突 |

### 与前版/竞品的关键差异

| 维度 | 纯 Bedrock 方案 | 本方案 (Bedrock + SageMaker) |
|------|-----------------|------------------------------|
| 模型选择 | 仅限 Bedrock 支持列表 | 任意 vLLM 可承载的开源模型 |
| 数据驻留 | 受 Bedrock 区域限制 | 可部署到指定 SageMaker 区域 |
| 成本结构 | 按 token 计费（固定价格） | SageMaker 端点按实例时长计费 + Bedrock 按 token |
| 可观测性 | 自动 token 追踪 | Bedrock 自动 + SageMaker 需手动 OTEL span |
| 部署复杂度 | 低（API 调用） | 中（需管理 vLLM 容器、端点、认证） |
| 冷启动延迟 | 几乎无 | SageMaker 端点有启动延迟（~1200s container startup） |
| 微调支持 | 有限（Bedrock Fine-tuning） | 完全自主（S3 上的自定义 checkpoint） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                    Bedrock AgentCore Runtime                     │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Orchestrator Agent (Claude Haiku 4.5)         │  │
│  │              Bedrock Model · Global cross-Region          │  │
│  │              职责: 意图分类 → 路由到子 Agent               │  │
│  └──────────┬──────────────────────────────┬─────────────────┘  │
│             │                              │                     │
│      ┌──────▼──────┐              ┌───────▼────────┐           │
│      │ Budget Agent │              │ Financial Agent │           │
│      │ Claude Sonnet │              │ Qwen 3.5 9B     │           │
│      │ 4.6 on Bedrock│              │ on SageMaker AI │           │
│      │ Pydantic 输出 │              │ Tool-calling    │           │
│      └──────────────┘              └───────┬────────┘           │
│                                           │                    │
│                              ┌────────────▼──────────┐         │
│                              │ SageMaker Real-time     │         │
│                              │ Endpoint (vLLM 0.22.1)  │         │
│                              │ ml.g6e.2xlarge (L40S)   │         │
│                              │ OpenAI-compatible API   │         │
│                              └────────────────────────┘         │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  OpenTelemetry Auto-Instrumentation                       │  │
│  │  ├── Bedrock calls → gen_ai.chat span (自动, 含 token)    │  │
│  │  └── SageMaker calls → gen_ai.chat span (手动, 需注入)     │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 关键技术细节

#### 1. SageMaker 认证：Bearer Token 自动刷新

SageMaker OpenAI-compatible API 需要 bearer token 认证，而 token 会过期。方案用 `httpx.Auth` 子类在每次请求时自动刷新：

```python
class SageMakerAuth(httpx.Auth):
    def __init__(self, region):
        self.region = region
    def auth_flow(self, request):
        request.headers["Authorization"] = f"Bearer {generate_token(region=self.region)}"
        yield request

strands_client = AsyncOpenAI(
    base_url=f"https://runtime.sagemaker.{REGION}.amazonaws.com/endpoints/{ENDPOINT_NAME}/openai/v1",
    api_key="sagemaker",
    http_client=httpx.AsyncClient(auth=SageMakerAuth(region=REGION)),
)
```

这个模式可以复用到任何需要动态认证的 OpenAI-compatible 端点。

#### 2. 可观测性缺口与修复

这是本文最有价值的技术洞察。Bedrock AgentCore 自动为 Bedrock 模型调用注入 OpenTelemetry span（含 token 计数），但对 SageMaker 端点完全不可见：

- **根因**：Strands 的 OTEL 集成只为 tool call 和 agent 生命周期事件发射 span，不为 OpenAIModel provider 发射 `gen_ai.chat` span。
- **修复**：手动包装 `gen_ai.chat` span，从 `result.metrics.accumulated_usage` 提取 token 数据。
- **关键依赖**：vLLM 默认在 streaming 模式下不返回 usage chunk，必须设置 `stream_options: {"include_usage": True}`。

```python
with tracer.start_as_current_span("gen_ai.chat", attributes={
    "gen_ai.system": "openai",
    "gen_ai.request.model": f"qwen3.5-9b ({SAGEMAKER_ENDPOINT_NAME})",
    "gen_ai.operation.name": "chat",
}) as span:
    result = fa_agent(query)
    usage = result.metrics.accumulated_usage
    span.set_attribute("gen_ai.usage.input_tokens", usage.get("inputTokens", 0))
    span.set_attribute("gen_ai.usage.output_tokens", usage.get("outputTokens", 0))
    span.set_attribute("gen_ai.usage.total_tokens", usage.get("totalTokens", 0))
```

#### 3. 部署配置

```python
agentcore_runtime.configure(
    entrypoint="main.py",
    auto_create_execution_role=True,
    auto_create_ecr=True,
    requirements_file="requirements.txt",
    region="ap-south-1",
    agent_name="personal_finance_agent",
)
```

AgentCore 自动处理 ECR 镜像构建、IAM 角色创建和容器部署。

## 实用评估

### 什么场景值得用

- **混合模型成本优化**：简单查询路由到低成本模型（Haiku），复杂分析路由到高能力模型（Sonnet 或自部署 Qwen）。文中示例的金融分析用 Qwen 3.5 9B 即可胜任，无需调用更贵的模型。
- **数据驻留要求**：金融/医疗等行业要求数据不出特定区域。SageMaker 端点可以部署到指定区域，而 Bedrock 的模型可用性受区域限制。
- **需要运行微调模型**：将 S3 上的微调 checkpoint 指向 `SM_VLLM_MODEL`，认证层、OTEL span、AgentCore 部署全部不变。
- **A/B 测试**：在同一 SageMaker 端点上部署基础模型和微调模型变体，通过 OTEL span 中的 variant attribute 对比质量。

### 什么场景不值得用

- **非 AWS 环境**：整套方案深度绑定 AWS 服务（SageMaker + Bedrock + AgentCore + X-Ray + CloudWatch），迁移成本极高。
- **纯 Bedrock 用户**：如果 Bedrock 支持的模型列表已经满足需求，不需要引入 SageMaker 的额外复杂度。
- **低延迟敏感场景**：SageMaker 端点容器启动超时设置为 1200 秒，冷启动延迟不可忽视。
- **简单原型/POC**：对于快速验证，直接用 Bedrock API 或 LangChain 更简单。

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| 纯 Bedrock → 混合架构 | 中（2-3 天） | 需部署 SageMaker 端点、配置认证、编写 OTEL span |
| 已有 SageMaker → AgentCore | 低（1 天） | 端点已存在，主要工作是适配 Strands Agents 和部署到 AgentCore |
| 其他框架 → Strands + AgentCore | 高（1-2 周） | 需要重写 Agent 逻辑以适配 Strands 的 "agents as tools" 模式 |

## 对你的意义

这个架构对 Ken 的 AI 应用开发有两个直接启示：

1. **Agent 框架的多模型路由能力正在成为标配**。Strands 的 "agents as tools" 模式展示了 Agent 框架如何从"单一模型调用者"进化为"模型路由器"。如果你在用 LangGraph 或 AutoGen，值得评估它们是否也支持类似的混合模型策略。

2. **可观测性是 Agent 生产化的关键瓶颈**。本文揭示了一个典型问题：即使是最成熟的 Agent 框架（Strands），在跨模型调用时也会出现可观测性缺口。这验证了 AI 应用监控中一个趋势——**Agent 级别的 observability 工具链（而不仅是模型级别）正在成为刚需**。

**建议**：如果你的项目涉及自部署模型 + 托管模型的混合使用，这个参考架构值得深入研究。GitHub 仓库（`aws-samples/sagemaker-genai-hosting-examples`）提供了完整可复现代码，可以先在沙箱环境中验证。

## 关键代码/配置片段

### vLLM 部署配置

```python
env = {
    "SM_VLLM_MODEL": "Qwen/Qwen3.5-9B",
    "SM_VLLM_TENSOR_PARALLEL_SIZE": "1",
    "SM_VLLM_MAX_MODEL_LEN": "32768",
}
# 实例: ml.g6e.2xlarge = 1x L40S (48GB VRAM)
# 容器: vllm:0.22.1-gpu-py312-cu130-ubuntu22.04-sagemaker
```

### Strands Agent 构建（agents as tools 模式）

```python
qwen_model = OpenAIModel(
    client=strands_client,
    model_id="",
    params={
        "temperature": 0.7,
        "max_tokens": 4096,
        "stream_options": {"include_usage": True},  # 关键: 没有这个 token 计数为 0
    },
)

@tool
def financial_analysis_agent_tool(query: str) -> str:
    # 每次调用创建新实例，避免并发错误
    fresh = Agent(model=qwen_model, tools=[...], callback_handler=None)
    return str(fresh(query))

orchestrator = Agent(
    model=BedrockModel(model_id="global.anthropic.claude-haiku-4-5-20251001-v1:0"),
    tools=[budget_agent_tool, financial_analysis_agent_tool],
)
```

### 追踪示例输出

```json
{
    "name": "gen_ai.chat",
    "attributes": {
        "gen_ai.system": "openai",
        "gen_ai.request.model": "qwen3.5-9b (qwen35-9b-260612-082732)",
        "gen_ai.operation.name": "chat",
        "gen_ai.usage.input_tokens": 1391,
        "gen_ai.usage.output_tokens": 1432,
        "gen_ai.usage.total_tokens": 2823
    },
    "durationNano": 37237386894
}
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 本文展示了企业级多模型 Agent 工作流的完整生产架构，包括认证、可观测性、成本控制——这正是企业级工作流自动化的核心需求 |

---
[← Back to Deep Dives](./README.md)
