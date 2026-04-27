---
auto_generated: true
generated_at: "2026-04-27T05:46:38Z"
source_url: "https://arxiv.org/abs/2604.17429"
signal_type: "significant_update"
---
# Jupiter-N：主权后训练混合推理模型 (Jupiter-N: Hybrid Reasoning Model with Agentic Capability)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-27
>
> **项目/工具**: Jupiter-N-120B
> **链接**: https://arxiv.org/abs/2604.17429
> **核心定位**: 从 Nemotron 3 Super（120B 全开源模型）后训练而来的混合推理模型，通过 Forget-Me-Not 框架在注入 agentic 能力、威尔士语支持和英国文化对齐的同时，零退化保留基座模型能力——并作为可复用的"主权后训练"模板开源发布。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Jupiter-N 是一个 120B 参数的混合推理模型，从 Nemotron 3 Super 后训练而来，核心贡献是提供了一套可复用的主权后训练（sovereign post-training）方法论——任何国家/组织都可以用相同流程注入本地语言、文化和 agentic 能力。
- **现在值得用吗**：如果你需要一个 120B 级别的全开源、可审计、支持 agentic 工作流的模型，值得试用；如果你只需要通用对话，Nemotron 3 Super 基座已足够。
- **适合场景**：主权/合规部署（数据不出境）、需要 agentic terminal 能力的工作流、多语言 + 文化对齐需求、研究后训练/灾难性遗忘缓解方法。
- **不适合场景**：超大上下文（>10K tokens）的长文档分析（训练序列长度仅 2048）、需要前沿推理能力的任务（GSM8K 94% 虽高但非顶尖）、非英语日常对话（威尔士语评估集仅 400/50 题，方言语料未覆盖）。
- **与 Nemotron 3 Super 核心差异**：Terminal Bench 2 +9.1、IFBench +4.4、威尔士语 +18 ARC-Easy，同时 GSM8K 保持 94% 零退化。

## 是什么 / 解决什么问题

### 主权 AI 的困境

大型语言模型的基础设施正集中在少数司法管辖区的几家厂商手中。这带来了数据主权、国家安全和文化代表性三重风险。但从头预训练前沿模型的成本极高——Llama 3.1 全系列消耗 39.3 百万 H100 GPU 小时，产生 11,390 吨 CO2eq。绝大多数国家无法承受。

### Jupiter-N 的答案

Jupiter-N 提出了一条更务实的路径：**不从头预训练，而是对已有的最强全开源模型进行后训练**。选择 Nemotron 3 Super（120B，全权重 + 全数据集开源）作为基座，通过精心设计的后训练流程，在三个维度上注入新能力：

1. **Agentic 能力**：终端操作和指令跟随，支持可靠的 agent 部署
2. **多语言**：新增威尔士语支持（基座仅支持 7 种语言，无凯尔特语族）
3. **文化对齐**：英国文化规范和社会价值观的 grounded 对齐

关键创新在于 **Forget-Me-Not 框架**——通过 on-policy 合成重放 + off-policy 任务数据的混合，有效缓解了灾难性遗忘。这使得模型在获得新能力的同时，数学推理、安全性和通用指令跟随能力均无退化。

## 技术架构拆解

### 核心设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 基座模型 | Nemotron 3 Super (120B/12B active) | 该参数级别最强全开源模型，权重和数据集均公开可审计 |
| 架构 | LatentMoE（Mamba-2 + MoE + Attention 交错） | 高效推理，12B active 参数降低部署成本 |
| 后训练方法 | LoRA (rank=16, alpha=32) | 参数高效，8×H200 单 epoch 即可完成 |
| 遗忘缓解 | Forget-Me-Not：22% on-policy 重放 + 78% off-policy 任务数据 | 在 Nano 4B 上验证后扩展到 120B |
| 混合推理保留 | 同时训练 reasoning + non-reasoning traces | 推理模式可在推理时通过 chat template 切换 |
| 数据筛选 | 熵基筛选（entropy-based curation） | 选基座模型最不确定的样本，提升样本效率 |

### 九数据集训练混合

训练数据覆盖 5 个领域，9 个数据集，序列长度跨度 3 个数量级（~10^2 到 ~10^4 tokens）：

```
┌─────────────────────────────────────────────────────────────┐
│                    Jupiter-N 训练流水线                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Terminal/   │    │  UK Cultural │    │  Welsh Lang  │  │
│  │  Agentic     │    │  Alignment   │    │  Data        │  │
│  │ (熵基筛选)   │    │ (CultureBank │    │ (平行语料 +  │  │
│  │ 30K samples  │    │  + Qwen3.5)  │    │  合成翻译)   │  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘  │
│         │                   │                   │          │
│  ┌──────┴───────┐    ┌──────┴───────┐    ┌──────┴───────┐  │
│  │ Self-Cognition│    │ Experience   │    │ General IF   │  │
│  │ (身份锚定)   │    │ Replay       │    │ (指令跟随)   │  │
│  │              │    │ (22% on-     │    │              │  │
│  │              │    │  policy)     │    │              │  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘  │
│         │                   │                   │          │
│         └───────────────────┼───────────────────┘          │
│                             │                              │
│                    ┌────────▼────────┐                     │
│                    │  合并 + Shuffle  │                     │
│                    │  LoRA FT (1 ep) │                     │
│                    │  8×H200, bs=64  │                     │
│                    └────────┬────────┘                     │
│                             │                              │
│                    ┌────────▼────────┐                     │
│                    │   Jupiter-N     │                     │
│                    │  120B (12B act) │                     │
│                    └─────────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

### 熵基筛选：选模型最不会的

传统的数据筛选通常按任务结果过滤（成功的轨迹保留，失败的丢弃）。Jupiter-N 采用了不同的策略：**按信息密度筛选**。

具体方法：
1. 用未修改的基座模型对每个样本进行 greedy decoding（T=32 tokens）
2. 记录每个位置的 top-20 log-probabilities
3. 计算归一化后的 Shannon 熵：H_t = -Σ p̂_{t,i} · log(p̂_{t,i})
4. 样本级得分 H̄ = (1/T) Σ H_t
5. 保留熵最高的 30,000 个样本（模型最不确定的）

这种方法的优势：高熵样本意味着模型对这类任务不熟悉，学习这些样本能最大化信息增益。同时，高熵样本也更可能包含失败轨迹——而作者引用 Nemotron-Terminal-Corpus 原论文发现，保留失败轨迹反而能提升鲁棒性。

### 与前版/竞品的关键差异

| 维度 | Nemotron 3 Super (基座) | Jupiter-N | 变化 |
|------|------------------------|-----------|------|
| 参数量 | 120B (12B active) | 120B (12B active) | 相同 |
| 架构 | LatentMoE | LatentMoE + LoRA | 相同基座 |
| Terminal Bench 2 | 基线 | +9.1 | 显著提升 |
| IFBench (reasoning off) | 基线 | +4.4 | 显著提升 |
| IFBench (reasoning on) | 基线 | +4.1 | 显著提升 |
| GSM8K | 93.56% | 94.01% | 持平/微升 |
| 威尔士语 ARC-Easy | 基线 | +18.0 | 从零到有 |
| 威尔士语 MMLU-Lite | 基线 | +5.25 | 从零到有 |
| AgentHarm (reasoning off) | 基线 | -5.2 (有害率降低) | 安全性提升 |
| AgentHarm (reasoning on) | 基线 | -1.6 | 安全性提升 |
| 开源程度 | 全开源 | 全开源 + 训练数据开源 | 更透明 |
| 训练成本 | 预训练 (极高) | 9.25h × 8×H200 ≈ 52 kWh | 极低 |

## 实用评估

### 什么场景值得用

- **主权/合规部署**：如果你需要在特定司法管辖区部署 LLM，且要求数据可审计、训练来源可追溯，Jupiter-N 提供了从基座到后训练的全链路开源方案。论文明确将其定位为"主权后训练模板"——替换文化知识库、机构语料和目标语言即可适配任何国家。
- **Agentic Terminal 工作流**：Terminal Bench 2 提升 +9.1 分，意味着模型在 shell 命令规划、文件操作、包管理等终端任务上有实质性改进。适合需要 agent 操作服务器的场景。
- **混合推理切换**：模型保留了在推理时切换 thinking/non-thinking 模式的能力。对需要兼顾推理质量和吞吐量的场景很有价值——简单任务用 non-thinking 模式提速，复杂任务用 reasoning 模式保证质量。
- **研究后训练方法**：Forget-Me-Not 框架和熵基筛选策略对研究灾难性遗忘、数据高效微调的学者有直接参考价值。

### 什么场景不值得用

- **需要顶尖推理能力**：GSM8K 94% 虽高，但并非当前最优水平。如果你的核心需求是数学/逻辑推理，可能有更好的选择。
- **长上下文分析**：训练序列长度仅 2048 tokens，虽然基座支持 11M 上下文，但后训练并未针对长上下文优化。
- **威尔士语日常对话**：平行语料仅来自议会和法律领域（正式文体），模型在口语/非正式威尔士语上可能表现不佳。评估集也很小（ARC-Easy 仅 50 题）。
- **资源受限部署**：120B 模型即使只有 12B active，仍需多 GPU 部署（论文用 4×GPU 做推理 serving）。边缘设备不适用。

### 迁移成本

从 Nemotron 3 Super 迁移到 Jupiter-N：
- **推理端**：零成本。模型权重直接替换，chat template 和接口完全兼容。
- **训练端**：如果你要复现后训练流程，需要 8×H200 约 9.25 小时（~52 kWh），成本可控。LoRA adapter 可独立加载，不需要合并到基座权重。
- **数据端**：所有 9 个训练数据集已在 HuggingFace 开源（locailabs/jupiter-training-data），可直接复用或替换。

## 对你的意义

这篇论文对 Ken 的两条线都有参考价值：

**VLA 研究线**：Forget-Me-Not 框架的核心思路——on-policy 重放 + off-policy 任务数据混合——与 VLA 后训练中缓解灾难性遗忘的思路高度一致。VLA 模型在从通用能力迁移到特定触觉/操作任务时，同样面临"学会新技能但忘记旧技能"的问题。Jupiter-N 的 22% on-policy 比例和在 Nano 4B 上先验证再扩展的策略，对 VLA 后训练有直接启发。

**AI 应用线**：Jupiter-N 展示了主权 AI 的一条务实路径——不从头造轮子，而是对最强开源模型做精准后训练。这对 Agent 部署有实际意义：如果你的应用场景需要特定文化对齐或语言支持，这套流程可以直接复用。另外，熵基筛选策略对 agent 训练数据的质量控制也有参考价值。

**建议**：如果你在做主权/合规相关的 AI 部署项目，值得深入阅读这篇论文的 Forget-Me-Not 框架和数据混合设计。如果只是通用 agent 开发，Nemotron 3 Super 基座已足够。

## 关键代码/配置片段

### LoRA 训练配置

```python
# LoRA 参数
lora_rank = 16
lora_alpha = 32
# Mamba out_proj 层排除（自定义 kernel 不兼容 LoRA）
exclude_layers = ["mamba.out_proj"]

# 训练超参数
gpus = 8  # H200
batch_size = 64  # global (local 8)
seq_length = 2048
optimizer = Adam(beta1=0.9, beta2=0.999)
lr_schedule = cosine_decay(1e-5, 1e-6)
epochs = 1
loss_masking = "assistant_only"  # role-based loss masking
```

### 熵基筛选核心逻辑

```python
# 对每个样本计算信息密度得分
def compute_entropy_score(model, prompt, T=32, k=20):
    """
    用基座模型 greedy decoding T tokens，
    记录 top-k log-probs，计算归一化 Shannon 熵
    """
    tokens = []
    for t in range(T):
        logits = model.forward(prompt)[:, -1, :]  # 最后一个位置
        top_k_logits, top_k_indices = logits.topk(k)
        probs = softmax(top_k_logits)  # 归一化 top-k
        entropy = -sum(p * log(p) for p in probs)  # H_t
        tokens.append(entropy)
        # greedy 选择下一个 token 继续
        next_token = top_k_indices[probs.argmax()]
        prompt = concat(prompt, next_token)
    return mean(tokens)  # H̄ = 样本级得分
```

### 训练数据混合比例

```
On-policy replay (22%):
  - Synthetic replay (UltraChat, reasoning + non-reasoning)
  - Extended reasoning traces (Nemotron3-Super-Reasoning-2000x)
  - Nemotron IF Chat subset

Off-policy task data (78%):
  - Terminal trajectories (30K, entropy-curated from 226K)
  - UK Cultural Alignment (CultureBank + Qwen3.5 235B)
  - Welsh parallel corpora (170K pairs → filtered)
  - Welsh synthetic chat (20K translated)
  - Self-cognition (identity grounding)
  - General instruction following
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-004: 推理模型在 Agent 任务展现持续优势 | 支持 | Jupiter-N 保留混合推理能力（reasoning/non-thinking 可切换），在 Terminal Bench 2（agentic terminal 任务）上提升 +9.1，且推理模式下 IFBench 也提升 +4.1，表明推理能力对 agentic 任务有直接增益 |

---
[← Back to Deep Dives](./README.md)
