---
auto_generated: true
generated_at: "2026-09-30T06:45:56Z"
source_url: "https://huggingface.co/blog/LiquidAI/lfm2-5-vl-dspark"
signal_type: "significant_update"
---
# LFM2.5-VL-DSpark：给视觉语言模型装上 280M 参数的投机解码头 (Speculative Decoding for Vision-Language Models)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-30
>
> **项目/工具**: LFM2.5-VL-DSpark（Liquid AI 实验性 VLM 草稿模型）
> **链接**: https://huggingface.co/blog/LiquidAI/lfm2-5-vl-dspark
> **核心定位**: 这是 Liquid AI 为其开源 VLM `LFM2.5-VL-3B` 推出的投机解码（speculative decoding）草稿模型。它只增加 8.9% 的参数，就把解码（decode）阶段速度最高提升到 3.13x，且不改变输出质量——把端侧多模态推理从「能跑」推向「流畅交互」。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：给 3B 视觉语言模型配一个 280M 的「草稿小模型」，用投机解码换取解码阶段的 2–3x 提速，输出与目标模型逐 token 一致。
- **現在值得用嗎**：看场景。如果你在**端侧跑 VLM 且瓶颈是解码延迟**（交互式多轮、实时 caption），这是当前少有的「开箱即用 + 零质量损失」方案；如果你的负载被图像编码 / prefill 主导，收益会被 Amdahl 定律压扁。
- **適合場景**：端侧 VLM 交互（手机 / Mac）、多轮视觉对话、图像 caption 流式输出；已有 `LFM2.5-VL-3B` 部署且想「白嫖」提速。
- **不適合場景**：以长图 / 大分辨率图像为主的单次问答（prefill 瓶颈）、需要非贪心采样严格一致性的场景、以及不愿引入额外权重与集成 PR 的团队。
- **與前版核心差異**：文本版 DSpark（2026-08）覆盖三款纯文本模型；本次是把同一套 DSpark 方法**首次移植到 VLM**，草稿模型改用 4 层 / block size 9，参数降到 279.5M，并新增 llama.cpp / MLX-VLM / SGLang 三端首日支持。

## 是什么 / 解决什么问题

2026 年 8 月，Liquid AI 为 `LFM2.5` 文本模型族发布了 DSpark 草稿模型，用投机解码把 H100 与 MacBook 上的吞吐拉高了 2–3x，并把函数调用延迟平均砍掉 57%。一个月后（本次发布，2026-09），同一套方法被移植到了他们的视觉语言模型 `LFM2.5-VL-3B` 上——这就是 **LFM2.5-VL-DSpark**。

痛点很具体：**多模态推理的解码阶段是 memory-bound 的**。每一步生成都要把模型权重从 DRAM 搬到 SRAM，真正的计算量反而很小。投机解码的思路是：用一个轻量草稿模型一次性提出一串候选 token（block），再让目标模型在一次前向里批量校验它们——权重加载的成本被 K 个 token 摊薄，于是解码变快。

这篇博客的官方数据是：解码提速**端侧最高 3.13x、H100 上 2.66x**；端到端（含 prefill）提速分别是 2.62x / 2.27x；草稿模型只增加 **280M 参数（+8.9%）**。作者明确强调：投机解码是「精确的（exact）」——目标模型逐个校验，贪心解码下输出序列与目标模型单独运行时完全相同，因此 benchmark 精度不变。

## 技术架构拆解

### 核心设计决策

- **只在目标模型的「固定 tap 层」上做条件**：草稿模型捕获目标模型若干层（tapped layers）的 hidden states，以此为条件一次性起草一个 block 的 k 个候选 token。这与文本版 DSpark 完全一致——**多模态没有引入新的推理算法**。
- **模态在进入 tap 层之前就被统一**：图像 patch 与文本 token 先被投影到**同一个共享表示空间**，因此草稿模型面对的 hidden-state 向量维度与输入模态无关。这是「一套草稿架构同时吃图文」的关键：它把 VLM 问题退化成了它已经解决的文本问题。
- **精简的 attention-only 草稿**：在 3 / 4 / 5 层之间做消融后，最终选了 **4 层**、block size **9**（推理时推荐 8 或 9，视硬件而定）。相比文本版 DSpark 的 5 层，视觉草稿反而更薄。
- **以接受率而非 loss 选 epoch**：训练用混合的视觉语言 SFT 数据，并**按预期负载加权**；跑 10 个 epoch，每轮测量接受率（acceptance），观测到「随训练 token 增加而提升，随后边际递减」。这套「优化接受率」的取向，正是投机解码的核心指标——草稿被接受得越多，摊销收益越大。

### 与前版/竞品的关键差异

| 维度 | 文本版 LFM2.5-DSpark（2026-08） | LFM2.5-VL-DSpark（本次） |
|------|------------------------------|------------------------|
| 目标模型 | 1.2B-Instruct / 2.6B / 8B-A1B（纯文本） | LFM2.5-VL-3B（视觉语言） |
| 草稿层数 | 5 层 | 4 层 |
| Block size | 9 | 9（推理推荐 8–9） |
| 草稿参数 | 约 295.7M–327.7M | **279.5M** |
| 参数量增幅 | 相对文本目标 | **+8.9%（相对 3B 目标）** |
| 峰值解码提速 | 最高 3.18x（GPU）/ 2.87x（端侧） | 最高 3.13x（端侧）/ 2.66x（H100） |
| 端侧框架 | llama.cpp（Metal）、SGLang | llama.cpp、**MLX-VLM**、SGLang |
| 主要局限 | 文本 prefill 成本 | prefill + **视觉编码**双重成本 |

草稿模型参数拆解（官方表格）：

| 组件 | 参数量 |
|------|--------|
| Decoder stack（4 层） | 193.0M |
| Hidden-state projection | 21.0M |
| Markov head | 65.5M |
| Norms + confidence head | 6.4k |
| **Total** | **279.5M** |

值得注意的是 **Markov head 占了 65.5M**——这正是 DSpark 相对 EAGLE-3 / DFlash 的差异点：它在并行起草骨架上叠加了一个建模相邻 token 依赖的马尔可夫链头，用来抬高后段位置的接受率；再配合一个「置信度调度校验器」，在预测到某段 token 存活率低、校验成本大于收益时直接剪枝。**注意**：本博客只复述了 DSpark 的三大组件（并行骨架 / 马尔可夫头 / 置信度调度），VL-DSpark 的具体实现细节需回溯论文 `huggingface.co/papers/2607.05147` 与三个集成 PR。

### 架构/信息流图

```text
                  ┌────────────────────────────┐
  图像 patch ──►  │  共享投影 (modality-agnostic) │ ◄── 文本 token
                  └──────────────┬─────────────┘
                                 │  统一维度 hidden states
                                 ▼
        ┌────────────────────────────────────────────┐
        │  目标模型 LFM2.5-VL-3B  (视觉编码 + 语言骨干)   │
        │  在固定 tap 层导出 hidden states ───────────►  │
        └──────────────┬─────────────┬───────────────┘
                       │             │ 一次前向，批量校验 K 个候选
        tap 层 hidden  ▼             ▼
        ┌────────────────────┐   ┌──────────────────┐
        │ DSpark 草稿 (4 层)   │──►│ 候选 token block  │
        │ + Markov head       │   │ (k=8/9)          │
        │ + confidence head   │   └──────────────────┘
        └────────────────────┘        │
                                       ▼
                   接受 (匹配目标分布) / 拒绝 → 目标模型自出 token
                   ⇒ 贪心输出 === 目标模型单独运行（精确）
```

## 实用评估

### 什么场景值得用

- **端侧交互式 VLM**：MLX 在 M5 Max 上解码提速 2.30x–3.13x，端到端 1.56x–2.62x；llama.cpp 在 M3 Ultra 上解码 1.57x–2.14x，端到端 1.30x–1.77x。如果你在做实时图像 caption、连续多轮视觉对话，这些是直接可感知的流畅度提升。
- **已有 `LFM2.5-VL-3B` 部署**：加一个 280M（+8.9%）的旁挂模型，改几个启动参数即可，**无需改模型精度 / 无需重训目标模型**。
- **贪心解码主导的推理服务**：因为校验是精确的，贪心输出与基线逐 token 一致，适合对「可复现性」有要求的评测或回归测试。

### 什么场景不值得用

- **prefill / 视觉编码占主导的负载**：作者在「Limitations」一节写得非常诚实——投机解码**只加速 decode，不加速视觉编码和 prefill**。VLM 的 prefill 还要先过一遍视觉编码器，再让语言骨干处理「数百个视觉 token + 文本 prompt」。端侧算力远弱于数据中心 GPU，**prefill 在端到端延迟中占比更高**，即便 decode 提速很大，端到端增益依旧有限——这是 Amdahl 定律的教科书写照。单张长图、大分辨率的一次性问答，很可能收益寥寥。
- **需要自定义采样（temperature>0）严格等价**：博客表述的是贪心解码下「输出与目标单独运行相同」。非贪心场景下投机解码的输出分布虽理论上等价的实现存在，但**此处建议按官方「精确 = 贪心」口径理解，temperature 场景待确认**。
- **不愿引入集成 PR 的团队**：SGLang、llama.cpp、MLX-VLM 都要**特定构建/PR**才支持（见下文），不是任意现成版本都能跑。
- **MoE / 大模型端侧场景**：参考文本版数据，MoE 模型（LFM2.5-8B-A1B）在 MacBook 上平均只提速 18%——原因在 llama.cpp Metal 后端的 MoE 实现，以及「校验 k 个 token 会激活更多专家、带来更多权重流量」。

### 迁移成本

从「裸跑 `LFM2.5-VL-3B`」迁移到「带 DSpark 草稿」大致是：

1. 拉取草稿权重（Safetensors 或 GGUF）。
2. 采用带 DSpark 支持的框架构建（SGLang PR #40651 / llama.cpp PR #29339 / MLX-VLM PR #2280）。
3. 在启动命令里挂上草稿并设置 block size（见下节）。
4. **评估再上线**：先在真实图文负载上量测端到端延迟。若 prefill 已是瓶颈，收益可能不达预期。

工作量约「半天到一天」量级（拉权重 + 换构建 + 跑基准），无模型改动。

## 对你的意义

这是一条与 Agent 工程直接相关的信号：**「端侧可交互推理」正在成为 Agent 落地的物理前提**。你在 Agent + UI 方向关注 streaming 与多模态——端侧 VLM 的解码吞吐，直接决定「视觉输入 → 流式响应」这条 UI 链路能不能做到人类可接受的实时感。

对 Ken 的现实判断：

- 如果你在做**本地/端侧多模态 Agent 原型**（截图理解、视觉工具调用、实时 caption），**建议立即试用**：成本低（+8.9% 参数）、风险低（贪心等价）、生态全（llama.cpp / MLX-VLM / SGLang 首日支持）。
- 如果是**云端 GPU 服务**，收益同样存在（H100 解码最高 2.66x），但优先度低于端侧——云端算力充裕时，吞吐瓶颈往往不在这一步。
- **观望理由**：这是「experimental」草稿，且真正决定成败的是你的 prefill/decode 占比。**先做一次 profile**，比盲目集成分到更靠谱。

跨领域联想：DSpark 的「并行骨架 + 序列头 + 置信度剪枝」三段式，是一种**通用加速范式**——与 Agent 领域「先并行草拟、再校验剪枝」的 speculative 式 agentic 流程（如并行工具调用 + 验证器）在思路上同构。值得留意是否会被搬到 agent 规划层。

## 关键代码/配置片段

**SGLang**（需带 DSpark 支持、面向 LFM2 target 的构建，PR #40651）：

```bash
python -m sglang.launch_server \
 --model-path LiquidAI/LFM2.5-VL-3B \
 --speculative-algorithm DSPARK \
 --speculative-draft-model-path LiquidAI/LFM2.5-VL-3B-DSpark \
 --speculative-draft-attention-backend flashinfer \
 --speculative-dspark-block-size 9 \
 --disable-radix-cache
```

随后访问 OpenAI 兼容端点 `http://localhost:30000/v1`。block size 从草稿模型的 `config.json` 读取；**基线 = 去掉那三个 `--speculative-*` 参数**。

**llama.cpp**（需对应构建，PR #29339）：

```bash
llama-server -m models/LFM2.5-VL-3B-F16.gguf \
 --mmproj models/mmproj-LFM2.5-VL-3B-F16.gguf \
 -md LFM2.5-2.6B-DSpark-F16.gguf \
 --spec-type draft-dspark --spec-draft-n-max 8 --spec-draft-n-min 0 \
 -fa on -ngl 99 -c 8192
```

**MLX-VLM**（需对应构建，PR #2280）：

```bash
mlx_vlm.server --model LiquidAI/LFM2.5-VL-3B --draft-model LiquidAI/LFM2.5-VL-3B-DSpark
```

> 注意：博客的 llama.cpp 示例里 `-md` 写的是 `LFM2.5-2.6B-DSpark-F16.gguf`——疑为从文本版示例复制粘贴的残留（与本文档的 VL-3B 目标不一致），实际路径请以官方 VL-3B-DSpark GGUF 仓库为准，**待确认**。

block size 从草稿的 sidecar metadata 读取（`n-max` 会被 clamp 到它）；**投机解码是精确的**：目标模型校验每个候选 token，贪心输出等价于目标模型单独运行，逐响应计时会报告 `draft_n / draft_n_accepted`。

草稿权重获取：Safetensors 与 GGUF 均在 Hugging Face（`LiquidAI/LFM2.5-VL-3B-DSpark` 及其 `-GGUF` 仓库）。

> TODO: 官方「H100 解码 20.4x–2.66x」一句中的「20.4x」疑为「2.04x」笔误（与端侧 2.30x–3.13x、GPU 端到端 1.64x–2.27x 量级不符），待原文确认。

---
[← Back to Deep Dives](./README.md)
