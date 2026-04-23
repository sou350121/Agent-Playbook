---
auto_generated: true
generated_at: "2026-04-23T05:46:45Z"
source_url: "https://qwen.ai/blog?id=qwen3.6-35b-a3b"
signal_type: "significant_update"
---
# Qwen3.6-35B-A3B：开源 MoE 模型挑战 Agentic Coding 顶端 (Qwen3.6-35B-A3B: Agentic Coding Power, Now Open to All)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-23
>
> **项目/工具**: Qwen3.6-35B-A3B（阿里巴巴通义实验室）
> **链接**: https://huggingface.co/Qwen/Qwen3.6-35B-A3B
> **核心定位**: 继 Qwen3.5 系列之后，Qwen 团队推出首个 Qwen3.6 变体——一个 35B 总参数/3B 激活的混合架构 MoE 模型，专为 agentic coding 场景深度优化，在 SWE-bench Verified 等核心指标上达到 73.4%，对标闭源 Claude Sonnet 4.5 水平。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Qwen3.6 系列首款开源模型，35B 总参/3B 激活的混合架构 MoE，主攻 agentic coding，性能逼近 Claude Sonnet 4.5。
- **現在值得用嗎**：是——如果你需要自部署 coding agent 且 GPU 资源充足（8x GPU tensor parallel 推荐）。
- **適合場景**：自托管 agentic coding 工作流、SWE-bench 级别代码修复、前端代码生成、需要 262K 上下文窗口的长代码库理解。
- **不適合場景**：低资源环境（需要 8x GPU 或 CPU-GPU 异构推理）、纯文本对话（有更大更通用的模型可选）、实时低延迟场景（MoE routing + thinking mode 增加延迟）。
- **與 Qwen3.5-35B-A3B 核心差異**：SWE-bench Verified 从 70.0→73.4（+3.4pts），Terminal-Bench 2.0 从 40.5→51.5（+11pts），新增 Thinking Preservation 机制和 MTP 加速。

## 是什么 / 解决什么问题

Qwen3.6-35B-A3B 是阿里巴巴通义实验室发布的 Qwen3.6 系列首个开源变体。在 2026 年 2 月 Qwen3.5 系列之后，团队基于社区反馈，将重心放在**稳定性**和**真实世界实用性**上，特别针对 agentic coding 场景做了深度优化。

这个模型解决的核心痛点是：开源 coding 模型在 SWE-bench 等真实代码修复任务上长期落后于闭源方案（Claude、GPT）。Qwen3.6-35B-A3B 在 SWE-bench Verified 上达到 73.4%，首次让开源 MoE 模型在这个关键指标上逼近闭源旗舰水平（Claude Sonnet 4.5 未公开但 Qwen 声称对标），同时保持 3B 激活参数的推理效率。

两个关键创新：
1. **Agentic Coding 深度优化**：前端工作流和仓库级推理的流畅度和精度显著提升
2. **Thinking Preservation**：新增选项保留历史消息中的推理上下文，减少迭代开发中的重复思考开销

## 技术架构拆解

### 核心设计决策

Qwen3.6-35B-A3B 采用了高度创新的混合架构设计，而非传统的纯 Transformer：

**1. 混合注意力机制（Gated DeltaNet + Gated Attention）**
模型 40 层的 hidden layout 为：`10 × (3 × (Gated DeltaNet → MoE) → 1 × (Gated Attention → MoE))`
- 每 4 层 block 中，3 层使用 Gated DeltaNet（线性注意力变体），1 层使用 Gated Attention（传统注意力）
- Gated DeltaNet：32 个线性注意力头（V）+ 16 个头（QK），head dim 128
- Gated Attention：16 个 Q 头 + 2 个 KV 头（GQA），head dim 256
- 这种设计在长序列效率（DeltaNet 优势）和建模能力（Attention 优势）之间取得平衡

**2. 超大规模稀疏 MoE**
- 256 个专家网络，每次仅激活 8 个 routed + 1 个 shared = 9 个专家
- 每个专家 intermediate dim = 512
- 总参数 35B，激活参数仅 3B（约 8.6% 激活率）
- 专家 intermediate dim 从 Qwen3.5 的更大值缩减到 512，配合更多专家数量实现更细粒度的路由

**3. Multi-Token Prediction (MTP)**
- 训练时同时预测多个未来 token，推理时可通过 speculative decoding 加速
- SGLang/vLLM 均已支持 MTP 加速，可配置 speculative steps

**4. 原生 262K 上下文窗口**
- 可扩展至 1,010,000 tokens
- 支持 vision encoder（图像/视频输入）
- 词汇表 248,320 tokens（padding 后）

### 与前版/竞品的关键差异

| 维度 | Qwen3.5-27B | Qwen3.5-35B-A3B | Qwen3.6-35B-A3B | Gemma4-31B |
|------|-------------|-----------------|-----------------|------------|
| 架构 | Dense | MoE (混合) | MoE (混合+DeltaNet) | MoE |
| 总参数 | 27B | 35B | 35B | 31B |
| 激活参数 | 27B | ~3B | ~3B | ~4B |
| SWE-bench Verified | — | 70.0 | **73.4** | 52.0 |
| SWE-bench Multilingual | — | 60.3 | **67.2** | 51.7 |
| Terminal-Bench 2.0 | — | 40.5 | **51.5** | 42.9 |
| Claw-Eval Avg | 64.3 | 65.4 | **68.7** | 48.5 |
| NL2Repo | 27.3 | 20.5 | **29.4** | 15.5 |
| QwenWebBench (Elo) | 1068 | 978 | **1397** | 1178 |
| 上下文窗口 | — | 262K | 262K (ext→1M) | — |
| Thinking Preservation | ❌ | ❌ | ✅ | ❌ |
| MTP 加速 | ❌ | ❌ | ✅ | ❌ |

### 架构信息流图

```
输入 (文本/图像/视频)
  │
  ▼
┌─────────────────────────────────────────────┐
│  Vision Encoder (可选)                       │
│  图像/视频 token 化                          │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  Embedding (248,320 vocab)                   │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  40 Layers × 10 Repetitions                  │
│                                              │
│  ┌─ 3× [Gated DeltaNet → MoE (256 experts)] │
│  │   • 线性注意力 (32V + 16QK heads)         │
│  │   • 8 routed + 1 shared activated         │
│  │                                           │
│  └─ 1× [Gated Attention → MoE (256 experts)]│
│      • GQA (16Q + 2KV heads)                │
│      • RoPE (dim=64)                        │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  MTP Head (multi-token prediction)           │
│  → speculative decoding 加速                 │
└──────────────┬──────────────────────────────┘
               │
               ▼
         输出 token
```

## 实用评估

### 什么场景值得用

- **自托管 Agentic Coding Agent**：SWE-bench Verified 73.4% 在开源模型中领先，适合需要本地部署 coding agent 的团队。比 Qwen3.5-35B-A3B 提升 3.4pts，Terminal-Bench 2.0 提升 11pts 尤为显著。
- **前端代码生成**：QwenWebBench Elo 从 978→1397（+419 分！），在 Web Design、Data Visualization、Animation 等 7 个类别上全面超越竞品。
- **长代码库理解**：原生 262K 上下文窗口（可扩展至 1M），配合 Thinking Preservation 机制，适合需要跨文件推理的大型仓库场景。
- **多模态代码任务**：支持图像/视频输入，适合需要理解 UI 截图生成前端代码的场景。
- **推理密集型任务**：AIME26 达到 92.7%，GPQA 86.0%，数学推理能力在 35B 级别中表现突出。

### 什么场景不值得用

- **低资源部署**：推荐 8x GPU tensor parallel 部署，即使使用 KTransformers CPU-GPU 异构推理，35B 参数对显存/内存要求依然不低。
- **简单对话/摘要**：MoE routing + thinking mode 默认开启带来额外延迟，简单任务用更小的 dense 模型更高效。
- **极致低延迟场景**：thinking mode 默认生成 `<think>...</think>` 推理链后才输出最终答案，latency-sensitive 应用需要切换到 instruct mode。
- **闭源 API 替代（成本敏感）**：虽然开源，但 8x GPU 的硬件成本可能超过 API 调用费用，需要综合评估。

### 迁移成本

从 Qwen3.5-35B-A3B 迁移：
- **API 兼容**：完全兼容 OpenAI Chat Completions API，只需改 model name
- **采样参数调整**：官方推荐 thinking mode temperature=1.0, top_p=0.95（精确 coding 用 temperature=0.6）
- **推理框架升级**：vLLM ≥0.19.0 / SGLang ≥0.5.10，需要升级框架版本
- **预计工作量**：1-2 小时（模型切换 + 参数调优 + 验证）

从其他开源 coding 模型（如 DeepSeek-Coder、CodeLlama）迁移：
- 需要适配新的 sampling 参数和 thinking mode 输出格式
- 预计 0.5-1 天（含测试验证）

## 对你的意义

作为关注 Agent + UI 方向的开发者，这个模型有几个值得关注的点：

1. **前端代码生成的质变**：QwenWebBench 上 1397 的 Elo 远超竞品，如果你在用开源模型做 UI 生成/前端自动化，这是目前最强的开源选择。
2. **Agentic Coding 的开源标杆**：73.4% 的 SWE-bench Verified 意味着你可以用这个模型搭建接近商用水平的 coding agent，而不依赖闭源 API。
3. **Thinking Preservation 对 agent loop 的价值**：多轮迭代开发中保留推理上下文，减少重复思考——这正是 agent 工作流的核心痛点。
4. **成本考量**：8x GPU 的部署成本需要认真评估。如果你的 agent 工作流主要跑在云端，API 调用可能更经济；如果有本地 GPU 集群，这个模型提供了极强的自托管能力。

**建议**：值得在测试环境部署试用，特别是前端代码生成和 SWE-bench 级别的代码修复场景。生产部署前先用 SGLang 或 vLLM 做性能 benchmark。

## 关键代码/配置片段

### vLLM 部署（含 MTP 加速）

```bash
# 标准部署
vllm serve Qwen/Qwen3.6-35B-A3B --port 8000 \
  --tensor-parallel-size 8 \
  --max-model-len 262144 \
  --reasoning-parser qwen3

# 启用 tool calling（agentic coding 必备）
vllm serve Qwen/Qwen3.6-35B-A3B --port 8000 \
  --tensor-parallel-size 8 \
  --max-model-len 262144 \
  --reasoning-parser qwen3 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder

# MTP 加速（speculative decoding）
vllm serve Qwen/Qwen3.6-35B-A3B --port 8000 \
  --tensor-parallel-size 8 \
  --max-model-len 262144 \
  --reasoning-parser qwen3 \
  --speculative-config '{"method":"qwen3_next_mtp","num_speculative_tokens":2}'
```

### 官方推荐采样参数

```python
# Thinking mode — 通用任务
temperature=1.0, top_p=0.95, top_k=20, min_p=0.0, presence_penalty=1.5

# Thinking mode — 精确 coding（如 WebDev）
temperature=0.6, top_p=0.95, top_k=20, min_p=0.0, presence_penalty=0.0

# Instruct mode（关闭 thinking，降低延迟）
temperature=0.7, top_p=0.8, top_k=20, min_p=0.0, presence_penalty=1.5
```

### OpenAI SDK 调用示例

```python
from openai import OpenAI
client = OpenAI(base_url="http://localhost:8000/v1", api_key="EMPTY")

response = client.chat.completions.create(
    model="Qwen/Qwen3.6-35B-A3B",
    messages=[{"role": "user", "content": "Fix the bug in this PR"}],
    max_tokens=81920,
    temperature=0.6,  # 精确 coding 推荐
    top_p=0.95,
    extra_body={"top_k": 20},
)
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | SWE-bench Verified 73.4% 已接近 80% 门槛，且为开源模型首次达到此水平，验证了 agentic coding 能力持续逼近实用化 |

---
[← Back to Deep Dives](./README.md)
