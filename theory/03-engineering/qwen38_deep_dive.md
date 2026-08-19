---
auto_generated: true
generated_at: "2026-08-19T05:50:22Z"
source_url: "https://readhub.cn/topic/8vaqsTRjDk5"
signal_type: "significant_update"
---
# Qwen3.8-27B 开源发布：首个 Qwen-Max 级稠密模型 (Qwen3.8-27B Open Source Release)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-19
>
> **项目/工具**: Qwen3.8-27B
> **链接**: https://github.com/QwenLM/Qwen3.8
> **核心定位**: 阿里巴巴通义千问团队发布的 27B 原生多模态稠密模型，首次将 Qwen-Max 级能力带入开源稠密模型，在编码、Agent 执行、多模态理解等核心维度全面超越 Qwen3.7-Plus。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：27B 参数的原生多模态稠密模型，基于 Qwen3.5 架构基础，首次将 Qwen-Max 级能力开源。
- **现在值得用吗**：是 — 如果你需要 27B 量级的编码/Agent 能力，且偏好稠密模型（非 MoE）的部署确定性。
- **适合场景**：Agentic Coding（SWE-bench Pro 61.7%）、多模态理解（图像+视频）、本地部署（27B 参数对单卡友好）。
- **不适合场景**：极端追求 SOTA 的场景（Opus4.6 Max 在多数 benchmark 仍领先）；资源极度受限的边缘设备（27B 仍需 ~14GB FP16 显存）。
- **与 Qwen3.6-27B 核心差异**：架构从纯注意力升级为 Gated DeltaNet + Gated Attention 混合架构，引入原生多模态能力和灵活推理控制。

## 是什么 / 解决什么问题

大模型开源社区长期存在一个断层：最强的模型（如 GPT-4o、Claude Opus）闭源且昂贵，而开源模型在编码、Agent 执行等核心能力上明显落后。Qwen3.8-27B 试图弥合这个断层——它不是简单的参数放大，而是通过架构创新（Gated DeltaNet 混合注意力）、原生多模态预训练、以及大规模 RL 后训练，让一个 27B 稠密模型在多项关键 benchmark 上逼近甚至超越更大的闭源模型。

Qwen3.8 系列目前发布两个规格：**Qwen3.8-27B**（稠密模型，本次重点）和 **Qwen3.8-2.4T-A95B**（超大规模 MoE，2.4T 总参数激活 95B）。27B 版本是面向开发者的主力部署选项——足够小，可以在单张 A100/H100 上推理；足够强，在 SWE-bench Pro 上达到 61.7%，超越 Qwen3.7-Plus 的 57.6% 和 Claude Opus 4.6 Max 的 53.4%。

另一个关键突破是**原生多模态**。Qwen3.8-27B 不是"文本模型 + 外挂视觉编码器"的拼接方案，而是在预训练阶段就进行了万亿级多模态 token 的早期融合训练（early fusion training）。这意味着它原生理解图像和视频，而非事后附加能力。

## 技术架构拆解

### 核心设计决策

| 决策点 | 设计选择 | 理由 |
|--------|---------|------|
| 注意力架构 | Gated DeltaNet (线性注意力) + Gated Attention (标准注意力) 混合 | DeltaNet 提供高效长上下文处理，Gated Attention 保留复杂推理能力；16:1 交替模式平衡效率与质量 |
| 多模态策略 | 早期融合预训练（Early Fusion） | 相比后期融合，跨模态表征学习更深入，视觉+语言理解更统一 |
| 推理控制 | 默认开启 thinking mode + reasoning_effort 分级 | 复杂任务需要深度推理，简单任务需要低延迟；三级控制（xhigh/medium/low）平衡成本与质量 |
| 多 Token 预测 | MTP（Multi-Token Prediction）多步训练 | 提升生成效率和连贯性 |
| 上下文窗口 | 原生 262K，可扩展至 1M | 覆盖代码仓库级任务（NL2Repo-Bench）和长视频理解 |

### 与前版/竞品的关键差异

| 维度 | Qwen3.6-27B | Qwen3.8-27B | Qwen3.7-Plus (闭源) | Opus4.6 Max |
|------|-------------|-------------|---------------------|-------------|
| 架构 | 纯注意力 | Gated DeltaNet + Gated Attention 混合 | 未公开 | 未公开 |
| 多模态 | 无原生支持 | 原生图像+视频 | 原生多模态 | 原生多模态 |
| SWE-bench Pro | 53.5% | **61.7%** | 57.6% | 53.4% |
| Terminal Bench 2.1 | 63.4% | **73.0%** | 64.0% | 78.2% |
| LiveCodeBench v6 | 83.9% | **90.3%** | 89.6% | 88.8% |
| OSWorld-Verified | 63.9% | **84.36%** | 73.3% | 72.7% |
| IFBench (指令跟随) | 69.1% | **79.5%** | 79.1% | 62.5% |
| GPQA Diamond | 87.8% | 89.2% | **90.3%** | 91.3% |
| Agent Last Exam (Pass@1) | 10.6% | **20.4%** | 13.2% | -- |

**关键洞察**：
- Qwen3.8-27B 在编码和 Agent 执行类 benchmark 上全面超越 Qwen3.7-Plus（闭源），这是稠密开源模型首次在多个维度逼近闭源旗舰。
- 在 OSWorld-Verified（计算机使用）上达到 84.36%，显著高于所有对比模型，说明其多模态 Agent 能力有质的飞跃。
- GPQA Diamond（科学推理）仍略低于 Opus4.6 Max，说明在深度科学推理方面仍有差距。

### 架构信息流图

```
┌─────────────────────────────────────────────────────┐
│                   User Input                         │
│           (Text / Image / Video)                     │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│              Early Fusion Encoder                    │
│    Vision Token + Text Token 统一嵌入                │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│           Transformer Layers (64 layers)             │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ 16 × [ 3 × (Gated DeltaNet → FFN)           │    │
│  │         → 1 × (Gated Attention → FFN) ]     │    │
│  │                                             │    │
│  │ Gated DeltaNet: 48 heads (V) + 16 heads (QK)│    │
│  │   Linear Attention, head_dim=128            │    │
│  │ Gated Attention: 24 heads (Q) + 4 heads (KV)│    │
│  │   Standard Attention, head_dim=256          │    │
│  │ FFN: intermediate_dim=17,408                │    │
│  └─────────────────────────────────────────────┘    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│           Multi-Token Prediction (MTP)              │
│           多步预测训练头                             │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│         Thinking Control Layer                       │
│  reasoning_effort: xhigh / medium / low              │
│  preserve_thinking: 跨会话保留推理上下文              │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│              Output (248,320 vocab)                  │
└─────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| **Agentic Coding** | SWE-bench Pro 61.7%、Terminal Bench 73.0%，在 27B 量级中表现最强，适合自动化代码修复和终端任务 |
| **多模态 Agent** | OSWorld-Verified 84.36%、WebArena-Verified 64.8%、AndroidWorld 81.9%，计算机/浏览器/手机三端 Agent 能力全面领先 |
| **本地部署** | 27B 参数在 FP16 下约 54GB（可量化至 ~14GB INT4），单卡 A100 80GB 可完整加载，适合私有化部署 |
| **长上下文任务** | 原生 262K 上下文，支持 NL2Repo-Bench 级别的代码仓库理解 |
| **视频理解** | 原生支持小时级视频输入，适合视频分析和多帧推理任务 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| **极致科学推理** | GPQA Diamond 89.2% 虽强，但仍低于 Opus4.6 Max 的 91.3%；如果核心需求是科研问答，闭源旗舰仍有优势 |
| **超低延迟场景** | 默认开启 thinking mode，复杂任务的推理延迟较高；即使关闭 thinking，64 层 transformer 的延迟也不低 |
| **边缘设备** | 27B 参数即使 INT4 量化仍需 ~14GB 显存/内存，无法在手机或嵌入式设备上运行 |
| **极低成本需求** | 如果需要极低成本的 API 调用，Qwen3.5 系列的小模型（0.8B/2B/4B/9B）或 MoE 变体可能更经济 |

### 迁移成本

从 Qwen3.6-27B 迁移到 Qwen3.8-27B：

- **模型文件替换**：直接更换 HuggingFace model ID 为 `Qwen/Qwen3.8-27B`，API 兼容层无需修改。
- **推理框架升级**：需要使用最新版本的 vLLM/SGLang/Transformers，确保支持 Gated DeltaNet 架构和 thinking mode。
- **API 参数调整**：新增 `reasoning_effort`（xhigh/medium/low）和 `preserve_thinking` 参数，如需关闭 thinking mode 需显式设置 `enable_thinking: False`。
- **采样参数调整**：官方推荐 thinking mode 下 `temperature=1.0, top_p=0.95`；instruct mode 下 `temperature=0.7, top_p=0.80, presence_penalty=1.5`。
- **预计工作量**：对已有 Qwen3.x 部署，迁移约 1-2 小时（模型下载 + 参数调整 + 验证测试）。

## 对你的意义

结合 AI 应用开发视角，Qwen3.8-27B 的开源释放了几个重要信号：

1. **稠密模型 vs MoE 的重新平衡**：在 MoE 成为主流趋势的背景下，Qwen3.8-27B 证明稠密模型通过架构创新（Gated DeltaNet）仍可达到旗舰级性能。对于需要确定性推理延迟和简化部署的场景，稠密模型重新成为可行选择。

2. **原生多模态成为标配**：Qwen3.5 已引入 early fusion 多模态预训练，Qwen3.8 进一步强化了这一方向。这意味着未来的 Agent 框架需要原生支持多模态输入，而非事后拼接。

3. **编码 Agent 的开源门槛大幅降低**：SWE-bench Pro 61.7% 意味着一个可本地部署的 27B 模型，在代码修复能力上已经可以替代部分闭源 API 调用。对于关注 Agent 成本优化的团队，这是值得试用的选项。

**建议**：如果你的 Agent 系统需要编码能力且对成本敏感，建议立即在测试环境部署 Qwen3.8-27B 进行 benchmark 对比。如果当前已在使用 Qwen3.6-27B，迁移成本很低，值得升级。

## 关键代码/配置片段

### vLLM 部署命令

```bash
vllm serve Qwen/Qwen3.8-27B \
  --port 8000 \
  --tensor-parallel-size 4 \
  --max-model-len 262144 \
  --reasoning-parser qwen3 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder
```

### SGLang 部署命令

```bash
sglang serve --model-path Qwen/Qwen3.8-27B \
  --port 8000 \
  --tp-size 4 \
  --context-length 262144 \
  --reasoning-parser qwen3 \
  --tool-call-parser qwen3_coder
```

### API 调用（Thinking Mode）

```python
from openai import OpenAI
client = OpenAI()

completion = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=[{"role": "user", "content": "Write a Python function..."}],
    extra_body={
        "chat_template_kwargs": {
            "enable_thinking": True,      # 默认开启
            "preserve_thinking": True,    # 跨会话保留推理上下文
        },
    },
    reasoning_effort="xhigh",  # xhigh / medium / low
    stream=True,
)
```

### 架构参数速查

```
参数总量: 27B
隐藏维度: 5120
层数: 64
词表大小: 248,320
上下文: 262K (原生) / 1M (可扩展)
DeltaNet: 48 heads (V) + 16 heads (QK), head_dim=128
Attention: 24 heads (Q) + 4 heads (KV), head_dim=256
FFN: intermediate_dim=17,408
层模式: 16 × (3 × DeltaNet → 1 × Attention)
```

---
[← Back to Deep Dives](./README.md)
