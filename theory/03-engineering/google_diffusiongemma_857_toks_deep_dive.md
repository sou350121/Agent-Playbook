---
auto_generated: true
generated_at: "2026-06-15T03:34:14Z"
source_url: "https://simonwillison.net/2026/Jun/10/diffusiongemma/"
signal_type: "significant_update"
---
# Google DiffusionGemma：扩散模型颠覆文本生成范式 (Google DiffusionGemma: Diffusion Models Disrupt Text Generation Paradigm)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-15
>
> **项目/工具**: Google DiffusionGemma (google/diffusiongemma-26B-A4B-it)
> **链接**: [https://blog.google/innovation-and-ai/technology/developers-tools/diffusion-gemma-faster-text-generation/](https://blog.google/innovation-and-ai/technology/developers-tools/diffusion-gemma-faster-text-generation/)
> **核心定位**: 首个开源扩散文本生成模型，用 256-token 并行去噪替代逐 token 自回归，在单 GPU 上实现 4 倍推理加速，为本地交互式 AI 应用打开新窗口

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Google DeepMind 开源的扩散文本生成模型，用"整段并行生成"替代"逐字输出"，在单 GPU 上实现 1000+ tok/s 的推理速度
- **现在值得用吗**: 看场景 — 如果你是本地交互式应用开发者（内联编辑、实时补全、代码 infilling），它值得立即关注；如果你需要最高质量的标准对话输出，Gemini/Gemma 4 仍然是更好的选择
- **适合场景**: 本地实时交互、代码补全/内联编辑、非结构化文本生成（Sudoku/数学图表）、低并发高吞吐场景
- **不适合场景**: 需要最高输出质量的场景（质量低于 Gemma 4）、高并发云端服务（扩散模型的并行优势在 batching 场景下递减）、Apple Silicon Mac（内存带宽瓶颈）
- **与 Gemma 4 核心差异**: 架构范式完全不同 — 从自回归变为编码器-解码器 + 离散扩散，速度 4x 但质量下降约 5-10 个百分点

## 是什么 / 解决什么问题

大语言模型的推理速度长期受限于自回归架构的本质缺陷：每次只能生成一个 token，下一个 token 必须等待上一个 token 完成。在云端高并发场景下，这个问题通过批量处理多个用户请求来掩盖；但在本地单用户场景下，GPU 大部分时间在等待——计算资源严重浪费。

DiffusionGemma 的核心突破是将图像生成中成熟的扩散模型（Diffusion Model）思想引入文本生成。与自回归模型"打字机"式的逐字输出不同，DiffusionGemma 每次生成一整块 256 个 token 的文本，通过多次迭代去噪逐步精炼，最终收敛为高质量输出。

这一架构转变带来了两个根本性变化：
1. **硬件利用效率翻转**：从内存带宽瓶颈（自回归的 KV-cache 逐次加载）转向计算瓶颈（并行去噪充分利用 GPU 算力）
2. **双向注意力成为可能**：生成过程中每个 token 可以同时关注前后文，而非只能看到前面的 token

该项目源于 2025 年 5 月 Google 短暂发布的实验性 Gemini Diffusion 模型（Simon Willison 记录到 857 tok/s），经过一年的沉寂后以开源 Gemma 模型的形式回归，Apache 2.0 许可，可直接商用。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 具体方案 | 理由 |
|----------|----------|------|
| 生成范式 | 离散文本扩散（Discrete Text Diffusion） | 突破自回归的串行瓶颈，实现并行生成 |
| 架构 | 编码器-解码器（Encoder-Decoder） | 编码器缓存 prompt KV，解码器对 canvas 做双向注意力 |
| 块大小 | Canvas = 256 tokens | 平衡并行度与去噪收敛质量 |
| MoE 配置 | 25.2B 总参数 / 3.8B 激活（8/128 experts + 1 shared） | 保持低显存占用，适配消费级 GPU |
| 采样策略 | Entropy-Bounded Denoising + Adaptive Stopping | 动态控制去噪步数，简单任务更快 |
| 精度 | 原生 NVFP4 支持 | NVIDIA 硬件加速，近无损精度 |

### 扩散文本生成流程

```
┌─────────────────────────────────────────────────────────────┐
│                  DiffusionGemma Inference                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: Encoder (Prefill)                                  │
│  ┌──────────────────────────────────────────────┐           │
│  │ Prompt → KV Cache (cached, one-time)         │           │
│  └──────────────────────────────────────────────┘           │
│                          ↓                                  │
│  Step 2: Decoder (Diffusion Loop, repeated)                 │
│  ┌──────────────────────────────────────────────┐           │
│  │ Canvas: [random tokens] × 256                │           │
│  │     ↓ Denoise Step 1                         │           │
│  │ Canvas: [~30% locked + ~70% noisy]           │           │
│  │     ↓ Denoise Step 2~48 (adaptive)           │           │
│  │ Canvas: [~80% locked + ~20% noisy]           │           │
│  │     ↓ Converged                              │           │
│  │ Canvas: [256 final tokens]                   │           │
│  └──────────────────────────────────────────────┘           │
│                          ↓                                  │
│  Step 3: Append to KV Cache → Next Canvas                   │
│  (Block-autoregressive: canvas-by-canvas, not token-by-token)│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | Gemma 4 26B A4B (自回归) | DiffusionGemma 26B A4B (扩散) | 差异幅度 |
|------|--------------------------|-------------------------------|----------|
| 生成方式 | 逐 token 自回归 | 256-token 块并行去噪 | 范式级差异 |
| 注意力方向 | 单向（因果） | 双向（canvas 内全可见） | 架构差异 |
| 推理速度 (H100) | ~250 tok/s（估算） | 1000+ tok/s | **4x 加速** |
| 推理速度 (RTX 5090) | N/A | 700+ tok/s | 消费级 GPU 可用 |
| MMLU-Pro | 82.6% | 77.6% | -5.0pp |
| AIME 2026 | 88.3% | 69.1% | -19.2pp |
| LiveCodeBench v6 | 77.1% | 69.1% | -8.0pp |
| GPQA Diamond | 82.3% | 73.2% | -9.1pp |
| HLE (no tools) | 8.7% | 11.0% | +2.3pp（反常优势）|
| 上下文长度 | 256K | 256K | 持平 |
| 多模态输入 | 文本+图像+视频 | 文本+图像+视频 | 持平 |
| 显存需求 (量化) | ~16GB | ~18GB | 略高 |
| 许可证 | Apache 2.0 | Apache 2.0 | 相同 |

### 关键发现：HLE 反常优势

一个值得注意的现象是 DiffusionGemma 在 HLE（High Level Evaluation，高难度推理）上**超过**了 Gemma 4（11.0% vs 8.7%）。Google 博客未直接解释这一反常，但可能的原因是：
- 扩散模型的双向注意力对需要"全局约束满足"的问题（如 Sudoku、数学图表）有天然优势
- HLE 中的部分任务可能更依赖全局推理而非逐步因果推理
- 需要更多实验验证这一假设

## 实用评估

### 什么场景值得用

**1. 本地实时交互式 AI 应用**
- 内联编辑（inline editing）：在文档中间插入内容时，双向注意力可以同时利用前后文
- 实时代码补全：1000+ tok/s 的速度接近本地编辑器的响应阈值
- 代码 infilling：填补函数体中的空白，扩散模型天然适合这类"双向依赖"任务

**2. 非结构化/约束满足型文本生成**
- Sudoku 求解：Unsloth 已演示 fine-tuned DiffusionGemma 求解 Sudoku，自回归模型在此类任务上表现较差
- 数学图表生成：需要全局一致性的结构化输出
- 氨基酸序列设计：生物信息学中的序列生成任务

**3. 低并发本地部署**
- 消费级 GPU（RTX 5090/4090）上量化运行，18GB VRAM 足够
- 单用户场景下速度优势最大化
- NVIDIA 已优化 NVFP4 内核，支持 DGX Spark/DGX Station 等桌面级部署

**4. 多模态理解 + 高速生成**
- 支持图像/视频输入 + 文本输出
- 可变图像分辨率（70~1120 visual tokens）
- 适合需要快速处理视觉信息的本地应用

### 什么场景不值得用

**1. 最高质量要求的标准对话/写作**
- 所有主流 benchmark 均低于 Gemma 4（5-19 个百分点）
- Google 官方建议："For applications that demand maximum quality, deploy standard Gemma 4"
- 如果质量是首要考量，扩散模型的速度优势无法弥补质量差距

**2. 高并发云端服务**
- 扩散模型的并行优势在低 batch size 下最强
- 云端高 QPS 场景下，自回归模型通过 batching 可以饱和利用算力
- 此时扩散模型的并行解码反而可能增加 serving 成本

**3. Apple Silicon Mac**
- 官方脚注明确指出：Apple Silicon 的统一内存架构在推理时受限于内存带宽而非计算能力
- 扩散模型的速度优势来自计算密集型的并行去噪，在带宽瓶颈设备上无法体现
- 在 Mac 上可能看不到相对于自回归模型的加速

**4. 需要严格逐步推理的复杂数学/逻辑任务**
- AIME 2026 差距 19.2pp 表明在需要严格因果推理的任务上扩散模型仍有劣势
- 双向注意力虽然强大，但可能不利于需要严格顺序推理的问题

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| 从 Gemma 4 切换到 DiffusionGemma | 低 | 同一 Gemma 生态，API 兼容，Transformers 一行代码切换 |
| 从其他开源模型（Llama/Qwen）切换 | 中 | 需要适配新的 generate() API 和采样配置 |
| 从闭源 API（GPT-4/Claude）切换到本地部署 | 高 | 需要硬件投入（RTX 5090 或 H100）+ 部署架构改造 |
| 云端 API 试用（NVIDIA NIM） | 极低 | NVIDIA 免费提供 NIM cloud API，无需本地硬件 |

### 采样配置要求

DiffusionGemma 有严格的采样配置要求，不同于自回归模型的 temperature/top_p：

```
最大去噪步数: 48
温度调度: 线性衰减 0.8 → 0.4
Token 选择: 每步选择最低熵 token，互信息界 ≤ 0.1
自适应停止: 平均熵 < 0.005 且连续两步预测一致时提前终止
```

这意味着迁移时需要调整采样逻辑，不能直接复用自回归模型的 sampling 参数。

## 对你的意义

作为 AI 应用开发者，DiffusionGemma 的出现释放了几个重要信号：

**1. 文本生成的"后自回归时代"正在到来**
扩散模型在图像生成中已经证明了其速度和质量的平衡能力。DiffusionGemma 是第一个将这一范式成功扩展到文本生成的大规模开源模型。虽然当前质量仍有差距，但架构方向明确——速度优先的场景将越来越多地采用扩散方案。

**2. 本地 AI 应用的可行性大幅提升**
1000+ tok/s 的速度意味着本地 AI 应用的响应延迟可以接近原生编辑器体验。如果你正在构建本地 Agent 或交互式 AI 工具，DiffusionGemma + RTX 5090 的组合提供了一个可行的技术栈。

**3. 双向注意力的独特价值**
对于代码 infilling、内联编辑、约束满足等需要"同时看前后文"的任务，扩散模型的双向注意力是自回归模型难以匹敌的。这类场景值得优先试用。

**4. 质量-速度的 trade-off 需要重新评估**
传统上我们只能在"高质量慢速度"和"低质量快速度"之间选择（通过模型大小）。DiffusionGemma 引入了第三个维度：相同参数规模下，通过架构变化改变速度-质量曲线。未来可能出现"质量略降但速度大幅提升"的专用模型。

**建议**: 如果你的项目涉及本地实时交互或代码补全，立即在 NVIDIA NIM 上试用 DiffusionGemma 评估质量是否可接受。如果是标准对话/写作场景，继续用 Gemma 4 或更高质量的模型。

## 关键代码/配置片段

### Transformers 加载（官方示例）

```python
from transformers import DiffusionGemmaForBlockDiffusion, AutoProcessor

MODEL_ID = "google/diffusiongemma-26B-A4B-it"

# 加载模型 — 注意使用 DiffusionGemmaForBlockDiffusion 而非标准 Gemma
processor = AutoProcessor.from_pretrained(MODEL_ID)
model = DiffusionGemmaForBlockDiffusion.from_pretrained(
    MODEL_ID,
    dtype="auto",
    device_map="auto",
)

# 生成 — API 与标准 Gemma 兼容
message = [{"role": "user", "content": "Why is the sky blue?"}]
input_ids = processor.apply_chat_template(
    message, tokenize=True, add_generation_prompt=True,
    return_dict=True, return_tensors="pt"
).to(model.device)
output = model.generate(**input_ids, max_new_tokens=512)
text = processor.decode(output[0], skip_special_tokens=False)
```

### 推理工具链支持

- **vLLM**: 已支持（Red Hat 贡献集成）
- **MLX**: Apple 生态支持（但速度优势可能不明显）
- **llama.cpp**: 官方支持即将推出
- **NVIDIA NIM**: 已上线，免费提供 cloud API
- **Hackable Diffusion**: Google 开源的 JAX 微调工具箱
- **Unsloth**: 已支持 DiffusionGemma 微调

### 性能基准（官方数据）

```
H100 (FP8):     1000+ tokens/second
RTX 5090:       700+ tokens/second
RTX 4090:       量化版本支持中
Apple Silicon:  不保证加速（内存带宽瓶颈）
```

---
[← Back to Deep Dives](./README.md)
