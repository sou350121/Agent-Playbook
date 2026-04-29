---
auto_generated: true
generated_at: "2026-04-29T03:35:51Z"
source_url: "https://mimo.xiaomi.com/index#blog"
signal_type: "blog_post"
---
# 小米 MiMo-V2.5-Pro 开源：1T 参数 MoE 模型挑战闭源旗舰 (Xiaomi MiMo-V2.5-Pro Open Source: 1T-Parameter MoE Challenges Closed-Source Flagships)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-29
>
> **项目/工具**: Xiaomi MiMo-V2.5-Pro
> **链接**: https://huggingface.co/XiaomiMiMo/MiMo-V2.5-Pro
> **核心定位**: 小米罗福莉团队发布的 1.02T 参数 MoE 开源大模型，42B 激活参数，1M 上下文窗口，MIT 协议开源，基准测试超越 DeepSeek-V4-Pro 和 Kimi K2.6

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：小米发布的当前最大开源 MoE 模型之一，以 42B 激活参数实现 1T+ 总参数规模，定位高端 agentic 和长上下文任务。
- **现在值得用吗**：是 — MIT 协议零限制，vLLM/SGLang 首日支持，适合需要大模型能力但受限于闭源 API 成本/数据隐私的团队。
- **适合场景**：复杂软件工程（SWE-Bench）、长上下文推理（1M token）、多轮 agent 任务（数千次 tool call）、中文/多语言任务。
- **不适合场景**：单卡/低显存部署（需多卡 DP+EP 并行）、对极致数学推理有要求的场景（GSM8K 虽强但 AIME 仍落后于顶级推理模型）。
- **与 MiMo-V2-Flash 核心差异**：参数规模从 310B/15B active 跃升至 1.02T/42B active，上下文从 256K 扩展到 1M，专注更复杂的 agentic 和长程任务。

## 是什么 / 解决什么问题

MiMo-V2.5-Pro 是小米 MiMo 团队的最新旗舰开源模型，于 2026 年 4 月底发布。它延续了 MiMo-V2-Flash 的架构设计（混合注意力 + MTP），但在规模和能力上实现了质的飞跃。

当前开源模型面临的核心矛盾是：更大的稠密模型推理成本过高，而小型 MoE 模型在复杂任务上能力不足。MiMo-V2.5-Pro 的选择是走「超大 MoE + 高效激活」路线——1.02T 总参数中仅激活 42B，推理成本可控，同时通过混合注意力架构和 MTP 技术解决长上下文效率问题。

另一个关键定位是 **agentic 能力**。模型专为「最 demanding 的 agentic、复杂软件工程、和长程任务」设计，能在 1M token 上下文窗口中维持数千次 tool call 的复杂轨迹，保持强指令遵循和连贯性。这直接对标了当前 AI agent 工作流中最棘手的长程任务场景。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 选择 | 理由 |
|---------|------|------|
| 架构类型 | MoE (384 experts, 8 per token) | 总参量大但激活参量小，推理效率高 |
| 注意力 | SWA + GA 混合 (6:1) | KV-cache 存储减少约 7 倍，同时保持长上下文性能 |
| 推测解码 | 原生 3-layer MTP | 推理输出速度提升 3 倍，同时加速 RL rollout |
| 训练精度 | FP8 (E4M3) 混合精度 | 27T token 预训练的计算效率优化 |
| 上下文长度 | 1M tokens | 支持超长文档理解和多轮 agent 交互 |
| 开源协议 | MIT | 零限制商用，最大化生态采用 |
| 后训练 | SFT → Domain-Specialized RL → MOPD | 三阶段范式，单一学生模型整合多教师能力 |

### 与前版/竞品的关键差异

| 维度 | MiMo-V2.5-Pro | MiMo-V2-Flash | DeepSeek-V4-Pro | Kimi K2 |
|------|---------------|---------------|-----------------|---------|
| 总参数 | 1.02T | 310B | 1.6T | 1.04T |
| 激活参数 | 42B | 15B | 49B | 32B |
| 上下文 | 1M | 256K | — | — |
| 注意力 | SWA+GA (6:1) | SWA+GA (5:1) | — | — |
| MTP | 3 layers | 3 layers | No | No |
| 训练数据 | 27T tokens | — | — | — |
| 精度 | FP8 混合 | — | — | — |
| 专家数 | 384 | 256 | — | 256 |
| 开源协议 | MIT | MIT | 闭源 | 闭源 |
| 部署支持 | vLLM + SGLang (首日) | SGLang | N/A | N/A |

### 架构/信息流图

```
                    ┌─────────────────────────────────────┐
                    │       Pre-Training (27T tokens)      │
                    │   FP8 Mixed Precision · 32k seq len  │
                    └──────────────────┬───────────────────┘
                                       │
                    ┌──────────────────▼───────────────────┐
                    │      Post-Training (3-Stage)         │
                    │                                      │
                    │  Stage 1: SFT                        │
                    │  ─── Curated instruction data        │
                    │                                      │
                    │  Stage 2: Domain-Specialized RL      │
                    │  ─── Math teacher ─┐                 │
                    │  ─── Safety teacher ─┤ Expert models  │
                    │  ─── Agentic teacher ─┘               │
                    │                                      │
                    │  Stage 3: MOPD                       │
                    │  ─── Multi-Teacher On-Policy         │
                    │     Distillation                     │
                    │  ─── Student learns from own         │
                    │     rollouts + teacher rewards       │
                    └──────────────────┬───────────────────┘
                                       │
                    ┌──────────────────▼───────────────────┐
                    │       Inference Architecture          │
                    │                                      │
                    │  ┌──────────┐    ┌──────────────┐    │
                    │  │  GA Layer │◄──►│  SWA Layer   │    │
                    │  │ (Global) │    │ (Window=128) │    │
                    │  └──────────┘    └──────────────┘    │
                    │       10 layers          60 layers    │
                    │                                      │
                    │  ┌──────────────────────────────┐    │
                    │  │  3-Layer MTP (Speculative)   │    │
                    │  │  Dense FFN · SWA             │    │
                    │  │  → 3× output speedup         │    │
                    │  └──────────────────────────────┘    │
                    └─────────────────────────────────────┘
```

### 长上下文能力深度分析

MiMo-V2.5-Pro 在长上下文推理上实现了质的飞跃。根据 HuggingFace README 中的 GraphWalks 基准测试结果：

- **MiMo-V2-Flash/V2.5**：超过 128K 后性能快速退化，在 1M 时两个子任务均降至 0.00
- **MiMo-V2.5-Pro**：在 512K 时仍保持 0.56 (BFS) / 0.92 (Parents)，在 1M 时仍有 0.37 / 0.62

这一提升归功于两个关键技术：
1. **可学习的 attention sink bias**：在 SWA+GA 混合架构中，通过 learnable bias 维持全局信息流
2. **6:1 的 GA/SWA 比例调整**（相比 V2-Flash 的 5:1）：增加了全局注意力层比例，改善跨窗口信息传递

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| 复杂软件工程 (SWE-Bench) | AgentLess 模式下 35.7%，远超 V2.5 Base 的 30.8% 和 Kimi K2 的 28.2% |
| 长文档分析 (100K+ tokens) | 1M 上下文 + GraphWalks 在 512K 仍保持 0.56+ 的分数 |
| 多轮 Agent 任务 | 官方强调能维持「数千次 tool call 的复杂轨迹」 |
| 中文/多语言 NLP | C-Eval 91.5 / CMMLU 90.2 / GlobalMMLU 83.6，中文能力对标闭源模型 |
| 数学推理 | GSM8K 99.6% / MATH 86.2% / AIME 37.3%，数学能力在开源中领先 |
| 数据隐私敏感场景 | MIT 协议 + 本地部署，无需将数据发送到闭源 API |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| 单卡部署 | 1.02T 参数需多卡 DP+EP 并行（示例配置需 32 卡：pp=1, dp=2, tp=16, ep=16） |
| 极致推理任务 | AIME 37.3% 虽不错，但顶级推理专用模型（如 o3 级别）仍更高 |
| 低成本边缘部署 | 42B 激活参数 + FP8 仍需大量显存，不适合边缘场景 |
| 实时低延迟对话 | MoE + 3-layer MTP 虽加速输出，但总参量大导致首 token 延迟较高 |
| 视觉/多模态任务 | 当前版本为纯语言模型，无视觉能力（需关注 MiMo-VL 系列） |

### 部署成本估算

根据 SGLang 官方示例配置：
- **并行策略**：pp=1, dp=2, tp=16, ep=16 → 需要 32 张 GPU
- **量化**：FP8 (E4M3) 混合精度
- **显存**：mem-fraction-static=0.7，单卡需约 80GB 可用显存（推荐 H200/A100-80G）
- **上下文**：最大 1M tokens，page-size=64
- **推测解码**：EAGLE 算法，3 steps，4 draft tokens

**最小可行配置**：官方未公布最小部署配置，估计需至少 8 卡（tp=8, ep=8）运行。

## 对你的意义

### 对 AI 应用开发者的意义

1. **开源替代方案**：MIT 协议意味着可以直接商用，无需担心 API 成本或数据合规。如果你的 agent pipeline 依赖闭源模型（GPT-4/Claude），MiMo-V2.5-Pro 提供了一个有竞争力的开源替代。

2. **vLLM/SGLang 首日支持**：不需要自己写推理后端，生态成熟度已经到位。SGLang 的 EAGLE 推测解码集成可以直接利用模型的 3-layer MTP。

3. **长上下文 agent 场景**：1M 上下文 + 强 agentic 能力，适合构建需要处理大量上下文的 agent（如代码库理解、长文档分析）。

### 对研究者的意义

1. **MOPD 范式的验证**：Multi-Teacher On-Policy Distillation 在更大规模模型上的效果得到验证。这一范式（< 1/50 传统 SFT+RL 算力）值得在自己的研究中参考。

2. **SWA+GA 混合架构的扩展性**：从 V2-Flash (310B) 到 V2.5-Pro (1T) 的架构延续，证明了混合注意力在超大 MoE 上的可扩展性。

3. **FP8 预训练的可行性**：27T token 的 FP8 混合精度训练是一个重要的工程实践参考。

### 建议

**值得立即关注**。MIT 协议 + 首日推理框架支持 + 有竞争力的 benchmark 数据，使得 MiMo-V2.5-Pro 成为当前最值得尝试的开源大模型之一。如果你的团队有算力资源（32 卡 H200 或等效），值得在 agentic pipeline 中做对比测试。

## 关键代码/配置片段

### SGLang 部署配置（来自 HuggingFace README）

```bash
SGLANG_ENABLE_SPEC_V2=1
SGLANG_DEEPEP_NUM_MAX_DISPATCH_TOKENS_PER_RANK=256
python3 -m sglang.launch_server \
  --model-path XiaomiMiMo/MiMo-V2.5-Pro \
  --trust-remote-code \
  --pp-size 1 \
  --dp-size 2 \
  --ep-size 16 \
  --tp-size 16 \
  --moe-dense-tp-size 1 \
  --enable-dp-attention \
  --moe-a2a-backend deepep \
  --quantization fp8 \
  --context-length 1048576 \
  --speculative-algorithm EAGLE \
  --speculative-num-steps 3 \
  --speculative-eagle-topk 1 \
  --speculative-num-draft-tokens 4 \
  --enable-multi-layer-eagle
```

关键参数解读：
- `--quantization fp8`：利用模型原生 FP8 权重，无需额外量化
- `--speculative-algorithm EAGLE`：启用 MTP 推测解码，官方称可提升 3 倍输出速度
- `--context-length 1048576`：启用完整的 1M 上下文窗口
- `--ep-size 16` + `--tp-size 16`：Expert + Tensor 并行，MoE 模型的关键优化

### 模型架构关键参数（来自 README）

| 组件 | MiMo-V2.5-Pro | MiMo-V2.5 |
|------|---------------|-----------|
| 总参数 | 1.02T | 310B |
| 激活参数 | 42B | 15B |
| Hidden Size | 6144 | 4096 |
| 层数 | 70 (1 dense + 69 MoE) | 48 (1 dense + 47 MoE) |
| 全局注意力层 | 10 | 9 |
| SWA 层 | 60 | 39 |
| 注意力头数 | 128 | 64 |
| KV 头数 | 8 (GQA) | 8 (GA) / 4 (SWA) |
| 路由专家数 | 384 | 256 |
| 每 token 专家数 | 8 | 8 |
| SWA 窗口大小 | 128 | 128 |
| MTP 层数 | 3 | 3 |

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | MiMo-V2.5-Pro 明确定位为 agentic 任务设计，强调「数千次 tool call 的复杂轨迹」能力，反映大模型正在为多 agent 协作提供基础设施级支持 |
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | SWE-Bench AgentLess 模式下 35.7% 虽未达 80%，但 MiMo-V2-Flash 在 SWE-Bench Verified 上已达 73.4%，开源模型在 agentic coding 上正快速逼近实用门槛 |

---
[← Back to Deep Dives](./README.md)
