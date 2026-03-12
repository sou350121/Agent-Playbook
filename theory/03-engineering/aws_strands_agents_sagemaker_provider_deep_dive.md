---
auto_generated: true
generated_at: "2026-03-12T05:46:44Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/building-custom-model-provider-for-strands-agents-with-llms-hosted-on-sagemaker-ai-endpoints/"
signal_type: "significant_update"
---
# AWS Strands Agents：自定义 SageMaker 模型 Provider (Custom Model Provider for Strands Agents with SageMaker)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-12
>
> **项目/工具**: AWS Strands Agents + SageMaker AI
> **链接**: https://aws.amazon.com/blogs/machine-learning/building-custom-model-provider-for-strands-agents-with-llms-hosted-on-sagemaker-ai-endpoints/
> **核心定位**: 解决 Strands Agents 与自定义 SageMaker 模型部署之间的响应格式不兼容问题，通过自定义解析器实现无缝集成

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句话定位**：为 Strands Agents 构建自定义模型解析器，桥接 SageMaker 自定义部署（SGLang/vLLM/TorchServe）与 Strands 期望的 Bedrock Messages API 格式
- **现在值得用吗**：是——如果你在 SageMaker 上部署了非 Bedrock 兼容格式的模型，同时想用 Strands Agents SDK 构建 Agent 应用
- **适合场景**：企业私有模型部署、合规要求高的场景、需要自定义推理框架（SGLang/vLLM）的优化部署
- **不适合场景**：直接使用 Bedrock 托管模型、简单的 OpenAI API 调用场景
- **与 Bedrock 原生集成核心差异**：Bedrock Mantle（2025 年 12 月起）支持 OpenAI 格式，但 SageMaker 自定义部署不保证兼容，需要手动桥接

## 是什么 / 解决什么问题

**背景痛点**：企业在 Amazon SageMaker 上部署自定义大语言模型时，通常使用 SGLang、vLLM 或 TorchServe 等推理框架来获得更大的控制权、优化成本并满足合规要求。这些框架通常返回 OpenAI 兼容格式的响应以确保广泛的生态系统支持。

**核心冲突**：Strands Agents SDK 期望模型响应符合 Bedrock Messages API 格式。当默认的 SageMakerAIModel 类尝试解析自定义端点返回的 OpenAI 格式响应时，会因为字段不匹配而导致解析失败，出现类似 `TypeError: 'NoneType' object is not subscriptable` 的错误。

**为什么 Bedrock Mantle 不能解决这个问题**：虽然 Amazon Bedrock Mantle 分布式推理引擎自 2025 年 12 月起支持 OpenAI 消息格式，但 SageMaker AI 的灵活性允许客户托管各种基础模型——其中一些需要特殊的提示和响应格式，不遵循标准 API。这在使用自定义推理框架时尤其常见。

**解决方案**：实现自定义模型解析器，扩展 SageMakerAIModel 类，将模型服务器的响应格式转换为 Strands 期望的格式，使组织能够在不牺牲与 Strands Agents SDK 兼容性的情况下利用首选的推理框架。

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 推理框架 | SGLang/vLLM/TorchServe | 提供更高的推理性能和自定义控制 |
| 部署方式 | SageMaker BYOC (Bring Your Own Container) | 完全控制容器环境和依赖 |
| 集成模式 | 扩展 SageMakerAIModel 类 | 保持 Strands SDK 的简洁接口，只自定义解析逻辑 |
| 响应转换 | 在 stream() 方法中实现 | 支持流式响应，符合 Agent 交互模式 |
| 容器构建 | awslabs/ml-container-creator | 自动化生成生产就绪的基础设施代码 |

### 三层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent Layer                              │
│              Strands Agent (应用层)                          │
│         使用自定义 Provider 进行对话式 AI                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Parser Layer                             │
│         Custom LlamaModelProvider 类                         │
│    扩展 SageMakerAIModel，处理 Llama 3.1 响应格式             │
│    核心方法：stream() → 转换 OpenAI 格式 → Bedrock 格式       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 Model Deployment Layer                      │
│      Llama 3.1 + SGLang on SageMaker Real-time Endpoint     │
│         返回 OpenAI 兼容格式响应                              │
└─────────────────────────────────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | Bedrock 原生模型 | SageMaker 自定义部署 (无解析器) | SageMaker + 自定义解析器 |
|------|-----------------|-------------------------------|------------------------|
| 响应格式 | Bedrock Messages API | OpenAI 兼容格式 | 通过解析器转换为 Bedrock 格式 |
| 部署控制 | 有限 (托管服务) | 完全控制 | 完全控制 |
| 推理框架 | Bedrock 内置 | 任意 (SGLang/vLLM 等) | 任意 |
| Strands 集成 | 开箱即用 | ❌ 不兼容 | ✅ 兼容 |
| 合规性 | 依赖 AWS 认证 | 可自定义满足特定要求 | 可自定义满足特定要求 |
| 成本优化 | 固定定价 | 可优化实例选择和推理配置 | 可优化实例选择和推理配置 |

### 响应格式转换流程

```
SageMaker Endpoint (OpenAI 格式)
         ↓
{
  "id": "cmpl-abc123",
  "object": "chat.completion",
  "choices": [{
    "message": {"role": "assistant", "content": "..."}
  }]
}
         ↓
   [Custom Parser]
   stream() 方法处理
         ↓
Strands 期望格式 (Bedrock Messages API)
{
  "type": "contentBlockDelta",
  "delta": {"text": "..."},
  "contentBlockIndex": 0
}
```

## 实用评估

### 什么场景值得用

1. **企业私有模型部署**：需要在 VPC 内部署模型，数据不出境，同时想用 Strands 构建 Agent 应用
2. **合规要求高的场景**：金融、医疗等行业需要特定的模型版本或推理配置，Bedrock 不满足
3. **性能优化需求**：使用 SGLang/vLLM 等框架获得比 Bedrock 更高的推理吞吐量
4. **成本敏感场景**：长期运行的大规模推理，自定义部署可优化实例选择和自动伸缩策略
5. **特殊模型需求**：需要部署 Bedrock 不支持的模型架构或版本

### 什么场景不值得用

1. **直接使用 Bedrock 托管模型**：如果 Bedrock 已有你需要的模型，直接用原生集成更简单
2. **简单的 OpenAI API 调用**：不需要 Agent 功能，直接调用 OpenAI API 即可
3. **快速原型验证**：部署 SageMaker 端点需要 10-15 分钟，原型阶段用 Bedrock 更快
4. **小流量场景**：固定成本的 SageMaker 端点可能比按量付费的 Bedrock 更贵
5. **缺乏运维团队**：需要维护容器、监控端点健康、处理扩缩容，运维复杂度较高

### 迁移成本

**从 Bedrock 迁移到 SageMaker 自定义部署**：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 安装 ml-container-creator | 10 分钟 | npm 安装 + Yeoman 配置 |
| 生成部署项目 | 5 分钟 | yo ml-container-creator 交互式配置 |
| 构建容器 (CodeBuild) | 15-30 分钟 | 自动构建，无需本地 Docker |
| 部署到 SageMaker | 10-15 分钟 | 端点启动 + 模型加载 |
| 实现自定义解析器 | 1-2 小时 | 扩展 SageMakerAIModel，实现 stream() |
| 测试验证 | 30 分钟 | 端点测试 + Agent 集成测试 |
| **总计** | **约 3-4 小时** | 首次部署，后续更新更快 |

**关键代码变化**：主要工作是实现自定义的 stream() 方法，处理 SSE 格式的流式响应并转换为 Strands 格式。

## 对你的意义

**如果你在用 Strands Agents**：这个方案打开了使用任意 SageMaker 部署模型的大门，不再局限于 Bedrock 支持的模型列表。对于需要私有部署或特定推理优化的场景，这是关键使能技术。

**如果你在评估 Agent 框架**：Strands 的这个设计展示了良好的扩展性——通过自定义解析器支持任意模型后端，而不是硬编码特定供应商。这种架构值得参考。

**建议**：
- **立即试用**：如果你已有 SageMaker 部署的模型，花 1-2 小时实现解析器即可集成
- **观望**：如果你还在选型阶段，可以考虑直接用 Bedrock（如果模型可用），减少运维负担
- **跳过**：如果你只需要简单的 LLM 调用，不需要 Agent 功能，直接用 LangChain 或 LlamaIndex 更轻量

## 关键代码/配置片段

### 自定义解析器核心实现

```python
def stream(self, messages: List[Dict[str, Any]], tool_specs: list, 
           system_prompt: Optional[str], **kwargs):
    # Build payload messages
    payload_messages = []
    if system_prompt:
        payload_messages.append({"role": "system", "content": system_prompt})
    
    # Extract message content from Strands format
    for msg in messages:
        payload_messages.append({
            "role": "user", 
            "content": msg['content'][0]['text']
        })

    # Build complete payload with streaming enabled
    payload = {
        "messages": payload_messages,
        "max_tokens": kwargs.get('max_tokens', self.max_tokens),
        "temperature": kwargs.get('temperature', self.temperature),
        "top_p": kwargs.get('top_p', self.top_p),
        "stream": True
    }

    try:
        # Invoke SageMaker endpoint with streaming
        response = self.runtime_client.invoke_endpoint_with_response_stream(
            EndpointName=self.endpoint_name,
            ContentType='application/json',
            Accept='application/json',
            Body=json.dumps(payload)
        )

        # Process streaming response
        accumulated_content = ""
        for event in response['Body']:
            chunk = event['PayloadPart']['Bytes'].decode('utf-8')
            if not chunk.strip():
                continue

            # Parse SSE format: "data: {json}\n"
            for line in chunk.split('\n'):
                if line.startswith('data: '):
                    try:
                        json_str = line.replace('data: ', '').strip()
                        if not json_str:
                            continue

                        chunk_data = json.loads(json_str)
                        if 'choices' in chunk_data and chunk_data['choices']:
                            delta = chunk_data['choices'][0].get('delta', {})

                            # Yield content delta in Strands format
                            if 'content' in delta:
                                content_chunk = delta['content']
                                accumulated_content += content_chunk
                                yield {
                                    "type": "contentBlockDelta",
                                    "delta": {"text": content_chunk},
                                    "contentBlockIndex": 0
                                }

                            # Check for completion
                            finish_reason = chunk_data['choices'][0].get('finish_reason')
                            if finish_reason:
                                yield {
                                    "type": "messageStop",
                                    "stopReason": finish_reason
                                }

                            # Yield usage metadata
                            if 'usage' in chunk_data:
                                yield {
                                    "type": "metadata",
                                    "usage": chunk_data['usage']
                                }

                    except json.JSONDecodeError:
                        continue

    except Exception as e:
        yield {
            "type": "error",
            "error": {
                "message": f"Endpoint invocation failed: {str(e)}",
                "type": "EndpointInvocationError"
            }
        }
```

### 使用自定义 Provider 初始化 Agent

```python
from strands.agent import Agent

# Initialize custom provider
provider = LlamaModelProvider(
    endpoint_name="llama-31-deployment-endpoint",
    region_name="us-east-1",
    max_tokens=1000,
    temperature=0.7
)

# Create agent with custom provider
agent = Agent(
    name="llama-assistant",
    model=provider,
    system_prompt=(
        "You are a helpful AI assistant powered by Llama 3.1, "
        "deployed on Amazon SageMaker. You provide clear, accurate, "
        "and friendly responses to user questions."
    )
)

# Test the agent
response = agent("What are the key benefits of deploying LLMs on SageMaker?")
print(response.content)
```

### ml-container-creator 项目结构

```
llama-31-deployment/
├── Dockerfile              # 包含 SGLang 和依赖的容器
├── buildspec.yml           # CodeBuild 配置
├── code/
│   └── serve               # SGLang 服务器启动脚本
├── deploy/
│   ├── submit_build.sh     # 触发 CodeBuild
│   └── deploy.sh           # 部署到 SageMaker
└── test/
    └── test_endpoint.sh    # 端点测试脚本
```

---

**参考资源**：
- 完整实现代码：https://github.com/aws-samples/sagemaker-genai-hosting-examples/tree/main/05-agents/strands/custom-response-parser
- ml-container-creator: https://github.com/awslabs/ml-container-creator
- Strands Agents 文档：https://strandsagents.com/

[← Back to Deep Dives](./README.md)
