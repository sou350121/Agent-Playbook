---
auto_generated: true
generated_at: "2026-07-29T06:50:55Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/get-started-with-openai-gpt-5-6-sol-terra-and-luna-on-amazon-bedrock/"
signal_type: "significant_update"
---
# GPT-5.6 Sol/Terra/Luna 正式登陆 Amazon Bedrock (GPT-5.6 Sol, Terra, and Luna on Amazon Bedrock)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-29
>
> **项目/工具**: OpenAI GPT-5.6 系列 (Sol / Terra / Luna)
> **链接**: https://aws.amazon.com/blogs/machine-learning/get-started-with-openai-gpt-5-6-sol-terra-and-luna-on-amazon-bedrock/
> **核心定位**: OpenAI 首次以三模型分层架构登陆 AWS Bedrock，通过 bedrock-mantle 端点提供 Responses API 兼容访问，引入 Prompt Caching 机制将重复上下文成本降低 90%

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: OpenAI 将 GPT-5.6 家族的三个能力层级（Sol=旗舰推理 / Terra=均衡生产 / Luna=高速低成本）全面引入 Amazon Bedrock，通过兼容 OpenAI Responses API 的 bedrock-mantle 端点访问
- **现在值得用吗**: 是——如果你已经在 AWS 生态内运行 Agent 工作负载，这是目前最无缝的接入方式
- **适合场景**: 企业级 Agent 编排（IAM/VPC/CloudTrail 合规）、高吞吐推理（Luna 分类/摘要）、深度推理任务（Sol 编码/安全研究）
- **不适合场景**: 非 AWS 用户（需额外配置 bedrock-mantle 端点）、需要 EU/APAC 区域部署（目前仅美国区域可用）
- **与 GPT-5.5 核心差异**: 三层能力分级 + Prompt Caching（缓存命中 90% 折扣）+ 新 bedrock-mantle 推理引擎 + 272K 上下文

## 是什么 / 解决什么问题

OpenAI 在 2026 年 7 月推出了 GPT-5.6 系列，引入了全新的命名体系：数字标识代际（5.6），后缀标识能力层级（Sol/Terra/Luna）。这三个模型各自独立进化，可以在不同节奏上迭代。这是 OpenAI 首次以多模型分层策略发布，标志着从"单一旗舰模型"向"能力矩阵"的战略转变。

Amazon Bedrock 的集成解决了几个关键问题：

1. **企业合规**: 所有推理请求在 AWS IAM 策略下运行，走 VPC，日志进入 CloudTrail，满足数据驻留要求。Bedrock 采用 Zero-Operator Access (ZOA) 安全模型，在芯片级别强制执行，确保 AWS 运维人员无法访问你的 prompts 或 completions。

2. **成本控制**: Prompt Caching 机制让重复上下文（系统指令、工具定义、参考文件）的 token 费用降低 90%。对于 Agent 循环中常见的 20-50 次模型调用，缓存命中后整体成本可降 60-80%。

3. **能力匹配**: 三模型分层让用户可以根据任务复杂度选择合适的能力层级，避免"用大炮打蚊子"。Sol 在 Artificial Analysis Coding Agent Index 上达到 80 分（比第二名高 2.8 分），同时输出 token 数不到对方的一半，耗时不到一半，成本约为三分之一。

## 技术架构拆解

### 三层能力矩阵与底层设计

| 模型 | Model ID | 最佳场景 | 可用 Region | 推理级别 |
|------|----------|----------|-------------|----------|
| **Sol** | openai.gpt-5.6-sol | 自主编码、安全研究、科学分析、深度多步推理 | US East (N. Virginia), US East (Ohio) | none/low/medium/high/xhigh/max |
| **Terra** | openai.gpt-5.6-terra | 通用生产负载，平衡推理/性能/成本 | US East (N.Virginia), US East (Ohio), US West (Oregon) | none/low/medium/high/xhigh/max |
| **Luna** | openai.gpt-5.6-luna | 高吞吐低延迟：分类、摘要、路由 | US East (N.Virginia), US East (Ohio), US West (Oregon) | none/low/medium/high/xhigh/max |

**关键设计洞察**:

1. **统一 API 表面**: 三个模型共享相同的 Responses API 接口和推理努力级别选项。这意味着你可以在不修改代码的情况下切换模型，只需改 model ID。这是 OpenAI 对"模型即服务"理念的进一步贯彻——模型切换应该是配置问题，不是工程问题。

2. **bedrock-mantle 端点的架构意义**: 这不是一个简单的 API 代理。bedrock-mantle 是 AWS 的新一代推理引擎，专门为 Agent 流量设计。Agent 流量的特征是 bursty——一个用户请求可能触发数百次模型调用，需求变化快。mantle 引擎通过池化容量吸收需求峰值，同时隔离每个客户的吞吐量，减少了在"共享容量"和"可预测性能"之间的权衡。

3. **Prompt Caching 的底层机制**:
   - Implicit 模式: 自动在最新消息处放置缓存断点，对开发者透明
   - Explicit 模式: 通过 `prompt_cache_breakpoint` 标记缓存边界，配合 `prompt_cache_key` 实现跨请求缓存路由
   - 缓存经济模型: 写入成本 1.25x（惩罚首次写入），读取成本 0.1x（鼓励重复使用），有效期 30 分钟
   - 最小前缀 1024 tokens 的设计意图: 防止小片段缓存造成的碎片化，确保缓存命中率

### 与前版/竞品的关键差异

| 维度 | GPT-5.5 (OpenAI 官方) | GPT-5.6 (Bedrock) | Claude Sonnet 4 (Bedrock) |
|------|----------------------|-------------------|--------------------------|
| 模型策略 | 单一旗舰 | 三层矩阵 (Sol/Terra/Luna) | 单一模型 (Sonnet) |
| 上下文窗口 | 128K | 272K | 200K |
| Prompt Caching | 不支持 | Implicit + Explicit 双层 | 支持 (Prompt Caching) |
| 缓存折扣 | N/A | 90% (读取) | 约 90% (读取) |
| 访问端点 | api.openai.com | bedrock-mantle.{region}.api.aws | Bedrock 标准 API |
| 安全合规 | API Key | IAM + VPC + CloudTrail + ZOA | IAM + VPC + CloudTrail |
| 多模态 | 文本为主 | 文本 + 图像输入 | 文本 + 图像输入 |
| Region 覆盖 | 全球 | 仅美国 (3 region) | 多区域 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    用户应用层 (Your App)                     │
│              OpenAI SDK >= 2.45.0 (BedrockOpenAI)           │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              bedrock-mantle 推理引擎 (AWS)                   │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   Sol 旗舰   │  │  Terra 均衡  │  │   Luna 高速低成本  │   │
│  │  272K ctx   │  │  272K ctx    │  │   272K ctx        │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Prompt Cache (Implicit/Explicit)           │    │
│  │  缓存命中 → 90% 折扣 | 有效期 ≥30min | 最小1024 tokens │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  安全层: IAM + VPC + CloudTrail + ZOA (零运维访问)    │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   AWS 基础设施层                              │
│         US-East-1 / US-East-2 / US-West-2                   │
└─────────────────────────────────────────────────────────────┘
```

## 实战陷阱与避坑指南

### 陷阱 1: Prompt Caching 的 1024-token 最小前缀

**问题**: 如果你的系统指令少于 1024 tokens，缓存不会生效，`cached_tokens` 始终为 0。这是一个静默失败——API 调用成功，但缓存不工作。

**解决方案**: 在系统指令末尾填充参考文档、工具定义或上下文信息，确保总前缀超过 1024 tokens。可以用 `tiktoken` 估算 token 数：

```python
import tiktoken
enc = tiktoken.encoding_for_model("gpt-4o")
prefix_length = len(enc.encode(system_prompt + tool_definitions))
assert prefix_length >= 1024, f"Prefix too short: {prefix_length} tokens"
```

### 陷阱 2: Tool Calling 的多轮交互必须携带推理输出

**问题**: GPT-5.6 会先推理再响应。如果你在 tool calling 的多轮交互中只传递 `response.output_text` 而遗漏了推理项（reasoning items），下一轮模型会丢失推理上下文，导致工具调用失败或产生重复推理。

**正确做法**: 必须将整个 `response.output`（包含推理项和函数调用项）传递到下一轮：

```python
# 错误做法
input_list.append({"role": "assistant", "content": response.output_text})

# 正确做法
input_list += response.output  # 包含 reasoning + function_call 项
```

### 陷阱 3: bedrock-mantle 端点的 Region 限制

**问题**: Sol 仅在 us-east-1 和 us-east-2 可用。如果你的应用部署在 eu-west-1 或 ap-northeast-1，直接调用会失败。

**解决方案**: 使用 Terra 或 Luna（多区域可用），或者在应用层实现 Region 路由逻辑。

### 陷阱 4: 短期 Token 过期

**问题**: 使用 `AWS_BEARER_TOKEN_BEDROCK` 环境变量方式认证时，token 最多 12 小时过期。长时间运行的 Agent 进程可能在运行中途认证失败。

**解决方案**: 生产环境必须使用 `BedrockOpenAI` 客户端的自动刷新机制，或在 AWS Secrets Manager 中管理 token 轮换。

## 实用评估

### 什么场景值得用

1. **企业级 Agent 编排**: 需要 IAM 权限控制、VPC 隔离、CloudTrail 审计的企业，这是目前最完整的方案。ZOA 安全模型确保 AWS 运维人员无法访问你的 prompts/completions。

2. **多步 Agent 循环（高缓存命中率）**: Agent 工作负载中系统指令和工具定义在多次调用间保持不变。Prompt Caching 可以让后续调用的输入 token 费用降为 10%。一个典型的 Agent 循环可能发起 20-50 次模型调用，缓存命中后成本可降 60-80%。

3. **深度推理任务**: Sol 在 Artificial Analysis Coding Agent Index 上达到 80 分（比第二名高 2.8 分），同时输出 token 数不到对方的一半，耗时不到一半，成本约为三分之一。在 ExploitBench 安全研究测试中达到 73.5%（GPT-5.5 为 47.9%）。在 Agents' Last Exam（55 个领域的长期专业工作流评估）中达到 53.6 分，比第二名高 13.1 分。

4. **高吞吐低延迟推理**: Luna 专为分类、摘要、路由等任务设计，适合需要处理大量请求且对延迟敏感的场景。

### 什么场景不值得用

1. **非 AWS 用户**: 如果你不在 AWS 生态内，直接使用 api.openai.com 更简单。bedrock-mantle 端点需要 AWS 凭证配置和 IAM 权限管理，增加了接入复杂度。

2. **需要 EU/APAC 区域部署**: Sol 仅在 US East (N. Virginia) 和 US East (Ohio) 可用；Terra/Luna 多一个 US West (Oregon)。如果你的业务需要 EU 或 APAC 区域的推理，目前不可用。

3. **预算极度敏感且不需要合规**: 如果团队不需要 VPC 隔离、IAM 权限控制、CloudTrail 审计等企业级安全特性，直接使用 OpenAI 官方 API 更简单。

### 迁移成本

**从 OpenAI 官方 API 迁移到 Bedrock**:
- 修改 base URL: `api.openai.com` → `bedrock-mantle.{region}.api.aws`
- 修改 model ID: `gpt-5.6-sol` → `openai.gpt-5.6-sol`
- 认证方式: API Key → AWS 凭证（推荐用 `BedrockOpenAI` 客户端自动刷新短期 token）
- 代码改动量: 约 5-10 行代码（主要是客户端初始化和认证逻辑）
- OpenAI SDK 版本要求: >= 2.45.0

**从 GPT-5.5 迁移到 GPT-5.6**:
- API 兼容: Responses API 完全兼容，无需改调用逻辑
- 新增能力: 需要显式启用 Prompt Caching（implicit 模式零改动，explicit 模式需加 breakpoint）
- 模型选择: 需要从单一模型决策变为三模型分层决策

## 对 Agent 开发的意义

1. **Agent 框架的成本结构变了**: Prompt Caching 让 Agent 循环的成本大幅下降。如果你的 Agent 框架（如 LangGraph、AutoGen）运行在 AWS 上，接入 bedrock-mantle 可以让多步 Agent 的成本降低 60-80%。这是 Agent 从"实验"走向"规模化生产"的关键基础设施。

2. **三模型分层是行业趋势信号**: OpenAI 从单一旗舰转向能力矩阵，暗示未来主流模型供应商都会采用类似策略。这意味着 Agent 框架需要内置"模型路由"能力——根据任务复杂度自动选择 Sol/Terra/Luna。

3. **AWS 生态的护城河加深**: Bedrock 的 IAM+VPC+CloudTrail+ZOA 安全栈是目前云厂商中最完整的。如果你的客户是企业，这个组合很难被绕过。

4. **对 Claude Code 生态的潜在影响**: Claude Code 等 Agentic Coding 工具目前主要依赖 Anthropic 自家模型。GPT-5.6 Sol 在 Coding Agent Index 上以 80 分领先，且成本仅为竞品三分之一。如果未来有工具支持 GPT-5.6 Sol 作为 coding agent 后端，将对 Claude Code 形成直接竞争。

**建议**: 如果你正在 AWS 上跑 Agent 工作负载，立即评估 Prompt Caching 的 ROI。一个 1024-token 系统指令的 Agent 循环，缓存命中后每次调用可节省约 90% 的输入 token 费用。

## 关键代码/配置片段

### 认证：自动刷新短期凭证（推荐生产环境）

```python
from aws_bedrock_token_generator import provide_token
from openai import BedrockOpenAI

region = "us-east-1"

client = BedrockOpenAI(
    aws_region=region,
    bedrock_token_provider=lambda: provide_token(region=region),
)
```

### 控制推理努力级别

```python
response = client.responses.create(
    model="openai.gpt-5.6-sol",
    input="A train leaves at 3 PM at 60 km/h. Another leaves an hour later at 90 km/h...",
    reasoning={"effort": "high"},  # none / low / medium / high / xhigh / max
)
```

### Explicit Prompt Caching（Agent 循环降本核心）

```python
# 系统指令必须 >= 1024 tokens，否则缓存不生效
system_prompt = "You are a technical support agent... (1,024+ tokens)..."

def ask(question):
    return client.responses.create(
        model="openai.gpt-5.6-terra",
        prompt_cache_key="support-agent:system-prompt-v1",
        prompt_cache_options={"mode": "explicit"},
        input=[
            {
                "type": "message",
                "role": "developer",
                "content": [{
                    "type": "input_text",
                    "text": system_prompt,
                    "prompt_cache_breakpoint": {"mode": "explicit"},
                }],
            },
            {
                "type": "message",
                "role": "user",
                "content": [{"type": "input_text", "text": question}],
            },
        ],
    )

# 首次调用：写入缓存
first = ask("How do I configure SSO?")
print("write:", first.usage.input_tokens_details.cache_write_tokens)

# 后续调用：读取缓存（90% 折扣）
second = ask("How do I reset password?")
print("read: ", second.usage.input_tokens_details.cached_tokens)
```

### Tool Calling 多轮交互（必须携带推理输出）

```python
tools = [{
    "type": "function",
    "name": "get_weather",
    "description": "Get the current weather for a given location",
    "parameters": {
        "type": "object",
        "properties": {
            "location": {"type": "string", "description": "City and country"},
            "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
        },
        "required": ["location"],
    },
}]

input_list = [{"role": "user", "content": "What's the weather like in Seattle?"}]

# 第一轮：模型请求工具调用
response = client.responses.create(
    model="openai.gpt-5.6-terra",
    input=input_list,
    tools=tools,
)

# 关键：必须将整个 response.output（含推理项）传递到下一轮
input_list += response.output

# 执行工具调用并返回结果
for item in response.output:
    if item.type == "function_call":
        args = json.loads(item.arguments)
        result = {"location": args["location"], "temperature": 64, "condition": "Partly cloudy"}
        input_list.append({
            "type": "function_call_output",
            "call_id": item.call_id,
            "output": json.dumps(result),
        })

# 第二轮：模型整合工具结果生成最终回答
final_response = client.responses.create(
    model="openai.gpt-5.6-terra",
    input=input_list,
    tools=tools,
)
print(final_response.output_text)
```

---
[← Back to Deep Dives](./README.md)
