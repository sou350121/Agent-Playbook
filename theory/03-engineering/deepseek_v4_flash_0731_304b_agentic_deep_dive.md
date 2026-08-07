---
auto_generated: true
generated_at: "2026-08-07T12:44:34Z"
source_url: "https://simonwillison.net/2026/Jul/31/deepseek-v4-flash-0731/#atom-everything"
signal_type: "significant_update"
---
# DeepSeek-V4-Flash-0731 正式发布：304B 参数的 Agentic 越级玩家 (DeepSeek-V4-Flash-0731 Official Release)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-07
>
> **项目/工具**: DeepSeek-V4-Flash-0731
> **链接**: https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-0731
> **核心定位**: DeepSeek V4 家族正式版的 304B MoE 模型，在 agentic 任务上越级挑战 700B+ 旗舰，定价仅为 $0.14/百万输入 token

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：DeepSeek V4 家族正式成员，304B 参数（激活约 37B），在 Terminal Bench、NL2Repo、Cybergym 等 agentic 基准上全面超越自家前代 V4-Pro Preview，逼近最强闭源旗舰
- **現在值得用嗎**：是——通过 DeepSeek API 或 OpenRouter 即可调用，MIT 开源可本地部署
- **適合場景**：Agentic 编码任务、终端自动化、工具调用密集型工作流、低成本高智能推理
- **不適合場景**：需要超长上下文（>1M token）的任务、对中文写作细腻度要求极高的场景（TODO: 待验证中文能力）
- **與前版核心差異**：正式版（非 Preview）+ DSpark 推测解码模块 + agentic 能力大幅增强（Terminal Bench 61.8→82.7，NL2Repo 39.4→54.2）

## 是什么 / 解决什么问题

DeepSeek-V4-Flash-0731 是 DeepSeek V4 家族的**正式版本**，取代了此前的 Preview 版本。它采用 MoE（Mixture of Experts）架构，总参数 304B，激活参数约 37B，并附带 DSpark 推测解码模块以提升推理速度。

这个模型解决的核心矛盾是：**如何在保持低成本的同时提供旗舰级 agentic 能力**。

传统上，agentic 任务（如代码生成、终端操作、工具调用）需要最大最强的模型——Opus-4.8、Claude Opus 等。这些模型虽然能力强，但推理成本高、速度慢。DeepSeek 的选择是用 MoE + 推测解码的组合，让一个"中等大小"模型在 agentic 任务上越级挑战旗舰。

定价策略进一步放大了这个优势：输入 $0.14/百万 token，输出 $0.27/百万 token。作为对比，Claude Sonnet 4 的输入定价约为 $3/百万 token。DeepSeek-V4-Flash-0731 的价格不到前者的 5%，但在多个 agentic 基准上表现接近甚至超越。

Artificial Analysis 将其排在 MiniMax M3（428B 参数）之前，进一步印证了其"单位智能成本"的优势。

## 技术架构拆解

### 核心设计决策

1. **MoE 架构 + 低激活率**：304B 总参数中仅激活约 37B，大幅降低推理计算量，同时保持模型容量
2. **DSpark 推测解码**：内置推测解码模块，与目标模型共享权重（无需独立 draft model），通过 `--speculative-config '{"method":"dspark"}'` 一键启用
3. **三级推理力度控制**：reasoning_effort 支持 low / high / max 三级，允许用户根据任务复杂度灵活调整推理深度
4. **MIT 开源**：模型权重和代码仓库均使用 MIT 许可证，允许商业使用

### 与前版/竞品的关键差异

| 维度 | DeepSeek-V4-Flash (Preview) | DeepSeek-V4-Flash-0731 (Official) | DeepSeek-V4-Pro (Preview) | Opus-4.8 |
|------|---------------------------|----------------------------------|--------------------------|----------|
| 总参数 | ~304B | 304B | ~671B (估) | 未知 |
| 激活参数 | ~37B | ~37B | 未知 | 未知 |
| 推测解码 | 无 | DSpark 内置 | 无 | 未知 |
| 许可证 | 开源 | MIT 开源 | 闭源 | 闭源 |
| 输入价格 | 相同 | $0.14/M | 更高 | ~$15/M |
| Terminal Bench 2.1 | 61.8 | **82.7** | 72.1 | 85.0 |
| NL2Repo | 39.4 | **54.2** | 38.5 | 69.7 |
| Cybergym | 38.7 | **76.7** | 52.7 | 83.1 |
| DeepSWE | 7.3 | **54.4** | 12.8 | 58.0 |
| Toolathlon-Verified | 49.7 | **70.3** | 55.9 | 76.2 |
| Agents' Last Exam | 15.8 | **25.2** | 16.5 | 25.7 |
| AutomationBench Public | 10.8 | **25.1** | 12.8 | 27.2 |

### 架构/信息流图

```
                    ┌─────────────────────────────────────┐
                    │       DeepSeek-V4-Flash-0731        │
                    │       304B Total / ~37B Active       │
                    └─────────────────────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              ▼                   ▼                   ▼
        ┌───────────┐      ┌──────────────┐    ┌─────────────┐
        │  MoE Core  │      │ Reasoning    │    │ DSpark      │
        │  (Expert   │      │ Effort Ctrl  │    │ Speculative │
        │  Routing)  │      │ (low/high/   │    │ Decoding    │
        │            │      │  max)        │    │ (shared wt) │
        └───────────┘      └──────────────┘    └─────────────┘
              │                   │                   │
              ▼                   ▼                   ▼
        ┌──────────────────────────────────────────────────┐
        │           Agent Framework Layer                  │
        │  (DeepSeek Harness / vLLM / SGLang / OpenRouter) │
        └──────────────────────────────────────────────────┘
```

**关键观察**：DSpark 推测解码模块与目标模型共享同一套权重，这意味着不需要额外的 draft model checkpoint，部署复杂度大幅降低。这是与传统推测解码（如 Medusa、Eagle）的核心差异。

## 实用评估

### 什么场景值得用

- **Agentic 编码工作流**：DeepSWE 得分 54.4（接近 Opus-4.8 的 58.0），NL2Repo 54.2。如果你在用 Claude Code / GitHub Copilot 等工具，切换到 DeepSeek API 作为后端可以大幅降低成本
- **终端自动化**：Terminal Bench 2.1 得分 82.7，仅次于 Opus-4.8（85.0）。适合需要模型直接操作终端的场景（CI/CD 调试、服务器运维）
- **工具调用密集型任务**：Toolathlon-Verified 70.3，表现优秀。适合需要多步骤工具调用的 agent 工作流
- **低成本批量推理**：$0.14/百万 token 的输入价格使其适合大规模批处理场景

### 什么场景不值得用

- **中文创意写作**：没有看到中文写作能力的专项 benchmark 数据，Simon Willison 的实测显示 default reasoning level 下输出质量一般（需调高 reasoning effort 才能改善）
- **超长上下文任务**：文档推荐最大输出长度 384K tokens，如果需要处理百万级 token 上下文，可能需要专门的长上下文模型
- **对确定性要求极高的场景**：agentic 场景推荐 temperature=1.0, top_p=0.95，这意味着输出有一定随机性

### 迁移成本

- **API 调用**：极低。DeepSeek API 兼容 OpenAI/Anthropic 格式，只需修改 base_url 和 model 名称。Claude Code / GitHub Copilot 等工具可直接接入，无需代码修改
- **本地部署**：中等。需要 vLLM 或 SGLang，推荐 4×GB300 节点。启用 DSpark 推测解码只需加一个 flag，但需要适配模型的自定义 chat template（非标准 Jinja 格式）
- **Prompt 适配**：低。标准 OpenAI 格式消息即可，但 reasoning_effort 参数需要显式设置（推荐 agentic 场景用 high 或 max）

## 对你的意义

对于关注 AI Agent 工程的人来说，这个模型值得重点关注：

1. **性价比拐点**：当 $0.14/M token 的模型在 agentic 基准上逼近 $15/M token 的旗舰，agent 工作流的推理成本可能下降 100 倍。如果你的 agent 每天跑几百次推理，这个差异从"可以忽略"变成"决定性因素"
2. **DSpark 推测解码的开源意义**：共享权重的推测解码方案降低了部署门槛，可能推动更多团队本地部署 agentic 模型而非依赖 API
3. **三级 reasoning effort 的设计**：low/high/max 的分层控制暗示 DeepSeek 认为"不是所有任务都需要深度推理"——这可能与 Agent 框架中的分层推理策略（fast thinking → slow thinking）产生有趣的设计交叉

**建议**：立即在你的 agent 工作流中试用 `deepseek-v4-flash`（API 端点已自动指向 0731 版本），用 high reasoning effort 对比当前使用的模型。关注三个指标：任务完成率、推理延迟、成本。

## 关键代码/配置片段

### vLLM 部署（启用 DSpark 推测解码）

```bash
vllm serve deepseek-ai/DeepSeek-V4-Flash-0731 \
  --trust-remote-code --kv-cache-dtype fp8 --block-size 256 \
  --data-parallel-size 4 --enable-expert-parallel \
  --moe-backend deep_gemm_mega_moe \
  --attention-config '{"use_fp4_indexer_cache": true}' \
  --speculative-config '{"method":"dspark","num_speculative_tokens":7,"draft_sample_method":"greedy"}'
```

### SGLang 部署

```bash
sglang serve \
  --trust-remote-code \
  --model-path deepseek-ai/DeepSeek-V4-Flash-0731 \
  --tp 4 \
  --moe-runner-backend flashinfer_mxfp4 \
  --speculative-algorithm DSPARK \
  --mem-fraction-static 0.90 \
  --chunked-prefill-size 4096 \
  --swa-full-tokens-ratio 0.1
```

### API 调用（OpenAI 兼容格式）

```bash
curl https://api.deepseek.com/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${DEEPSEEK_API_KEY}" \
  -d '{
    "model": "deepseek-v4-flash",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello"}
    ],
    "thinking": {"type": "enabled"},
    "reasoning_effort": "high",
    "stream": false
  }'
```

### 本地编码（自定义 chat template）

```python
from encoding_dsv4 import encode_messages, parse_message_from_completion_text

messages = [
    {"role": "user", "content": "hello"},
    {"role": "assistant", "content": "Hello! I am DeepSeek.", "reasoning_content": "thinking..."},
    {"role": "user", "content": "1+1=?"}
]

# messages -> string
prompt = encode_messages(messages, thinking_mode="thinking", reasoning_effort="max")

# string -> tokens
import transformers
tokenizer = transformers.AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-V4-Flash-0731")
tokens = tokenizer.encode(prompt)
```

> **注意**：该模型不提供标准 Jinja chat template，需要使用官方提供的 encoding 模块进行消息编码。这对部分第三方工具可能构成兼容性问题。

---
[← Back to Deep Dives](./README.md)
