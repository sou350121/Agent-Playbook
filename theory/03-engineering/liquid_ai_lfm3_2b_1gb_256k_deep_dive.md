---
auto_generated: true
generated_at: "2026-11-01T08:01:13Z"
source_url: "https://huggingface.co/blog/LiquidAI/lfm3"
signal_type: "significant_update"
---
# Liquid AI 发布 LFM3：一个 2B 主干长出的六款端侧模型 (Build Specialized Multimodal Models with LFM3)

> 🔍 本文由 Moltbot 自動生成 | 2026-11-01
>
> **项目/工具**: Liquid AI LFM3 系列（LFM3-1.7B / LFM3-VL-2B / LFM3-Audio-2B / LFM3-Omni-2B / d1-2B / d1-omni-2B）
> **链接**: https://huggingface.co/blog/LiquidAI/lfm3
> **核心定位**: 把文本、视觉、音频、全模态、决策五种能力压进同一个 1.7B 主干，让"选一个模态 → 单卡微调 → 部署到应用运行处"成为一条闭环路径。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 不是再发一个更大的通用模型，而是用一条 2B 级共享主干派生六个专用模型，全部开放权重、全部单卡可微调。
- **现在值得用吗**: 看场景——只要你的 agent 需要跑在本地、私有环境或嵌入式硬件上，且愿意做一次领域微调，就值得立刻试；若你依赖闭源大模型的通用推理天花板，它不是替代品。
- **适合场景**: 端侧 agent / 工具调用、文档结构化抽取、语音交互客服、机器人感知-规划-控制栈、低成本批量分类决策（d1）。
- **不适合场景**: 需要超长链推理的高难度问答、需要最强通用知识覆盖的场景、没有数据做微调却想要"开箱专家"的团队。
- **与前版核心差异**: LFM3-1.7B 用比 LFM2.5-2.6B 少 35% 的参数做到更强，最大提升集中在 agentic 任务（WebArena-Verified 38.42 vs 3.02）。

## 是什么 / 解决什么问题

Liquid AI 的 LFM 系列长期押注一条技术判断：**端侧的真实瓶颈不是参数量，而是"能力/参数"与"能力/显存"的比值**。LFM2 证明了短卷积 + 注意力的混合结构能在设备上跑得快而不牺牲质量；LFM3 的野心更大一步——不再做"一个通用小模型"，而是做"一个共享底板 + 一组模态专家"。

这次发布解决的是三个很具体的工程痛点：

1. **多模态模型太大，装不进应用现场。** 过往做一个能看又能听的端侧产品，通常要塞 ASR + VLM + LLM + TTS 四个模型，显存与工程量双重爆炸。LFM3-Omni-2B 用一个模型覆盖这条链路。
2. **小模型不够"专"，大模型不够"便宜"。** 官方立场很明确：前沿模型是强力通才，但不一定是你的用例专家。LFM3 把容量压到 2B 级，目的是让一次短微调就能把它变成你业务里的可靠专家，然后部署到设备、私有基础设施或云上。
3. **Agent 需要长上下文 + 快推理。** 文本模型支持 256K 上下文，官方定位是"让 agent 跑在设备上"，并明确点名其在 Hermes Agent、Pi、OpenClaw 这类 agent harness 中做过后训练。

需要诚实指出：这是**一次模型家族换代 + 权重放出**，不是一篇方法论论文。博客中的数字均来自官方自测（model card 与发布博客），第三方复现尚待社区验证。

## 技术架构拆解

### 核心设计决策

- **硬件在环架构搜索（hardware-in-the-loop）**：搜索空间从 LFM2 时期扩展到 **14 种设备与后端组合**，覆盖手机、Raspberry Pi 5、笔记本、云 CPU、GPU 以及 Qualcomm Hexagon NPU。设计目标直接写成"agentic 用例所需的更高能力/参数比 + 长上下文下的快推理"。
- **Tri-hybrid 层混合**：1.7B-Base 共 24 层，其中 **13 层 gated short convolution + 5 层滑动窗注意力（SWA，窗口 256 token）+ 6 层全局注意力**。卷积核从 LFM2 的 3 提升到 **7**，扩大感受野以承担更多"廉价"的序列建模工作。
- **Head-wise gated attention**：每个注意力头的输出乘一个 sigmoid 门控，让"没什么可补充的头"自行关闭。官方给的理由很实际——抑制那些会伤害量化的 activation outlier。
- **Partial RoPE**：只在全局注意力层对每个头的高频那一半做旋转位置编码，另一半按内容匹配、与距离无关；SWA 层保留完整 RoPE。这是一个相当精致的"局部精确、全局粗粒度"折中。
- **Sandwich norm**：每个 block 对输入和输出各做一次归一化，保持激活尺度稳定。
- **中训练阶段注入 agent 能力**：Base 在 **22T token** 上预训练（与 LFM2.5-8B-A1B 共用 128K 词表），最后 **3.5T token** 是精选数据的中训练阶段，显著提高 agentic trace 与 tool call 占比，并在此阶段把上下文扩展到 256K。
- **自研编码器替代第三方**：新视觉编码器（164M 参数，卷积 + 注意力混合）比之前 LFM VL 使用的 SigLIP2 **少 3 倍算力**；音频编码器全因果，可边说边 prefill，首 token 延迟低至 **50 ms**；音频 tokenizer LiquidCodec 在 Apple M4 Max 单 CPU 线程上约 **87x 实时**，支持流式解码。

### 与前版/竞品的关键差异

| 维度 | LFM2.5 家族 | LFM3 家族 |
|------|------------|-----------|
| 主干 | 按规模各建 | 单一 LFM3-1.7B-Base 派生六模型 |
| 文本能力 | LFM2.5-2.6B | LFM3-1.7B 超越前代且参数少 35% |
| Agent 基准 | LFM2.5-2.6B: WebArena-Verified 3.02 | LFM3-1.7B: **38.42** |
| 视觉 | LFM2.5-VL-3B（3.1B） | LFM3-VL-2B（1.9B），62 项视觉基准均值 57.6 → **71.4** |
| 语音质量 | LFM2.5-Audio-1.5B: UTMOSv2 3.22 | LFM3-Audio-2B: **3.83** |
| 全模态 | 无 | LFM3-Omni-2B 首发（文本/图/视频/音频输入，文本+语音输出） |
| 决策模型 | d1-3B（ImajevBench 64.0） | d1-2B 参数少 1/3，ImajevBench **75.5** |
| 显存 | — | 文本模型 4-bit 约 **1 GB** |
| 上下文 | 常规 | **256K** |

值得注意的对比数字：官方称 LFM3-VL-2B 在 62 项视觉基准上"与 Gemma 4 12B 持平"，后者参数是它六倍以上；LFM3-Omni-2B 在 Daily-Omni、WorldSense、AV-SpeakerBench 上超过参数达 10.7B 的模型（如 Qwen2.5-Omni-7B）。这类"小打大"的宣称应当作为**待复现**看待——官方未在同一段落披露完整评测协议。

### 架构/信息流图

```
                LFM3-1.7B-Base (22T tokens, 128K vocab, 256K ctx)
                                │
        ┌───────────────┬───────┴────────┬──────────────────┐
        │               │                │                  │
   LFM3-1.7B      LFM3-VL-2B      LFM3-Audio-2B      LFM3-Omni-2B
   Text→Text      +vision enc      +audio enc/dec     +vision enc
        │          (图像/视频)       +LiquidCodec      +audio enc/dec
        │               │            (文本/语音出)      +LiquidCodec
        │               └──► d1-2B ◄──────┐            
        │                              └──► d1-omni-2B
        │                               (一次前向，多问题，
        │                                每个答案带校准概率)
        ▼
   agent harness (Hermes Agent / Pi / OpenClaw)
   + 单卡微调: SFT / DPO / GRPO / CPT
```

## 实用评估

### 什么场景值得用

- **端侧 / 私有化 agent**：1GB（4-bit）文本模型 + 256K 上下文，意味着能在一台普通机器上跑"带完整工具列表与文档上下文"的 agent，而不必把数据送出内网。
- **结构化抽取与决策分流**：d1 系列的设计非常对症——给它一个工单、一张发票、一屏 UI，一次前向回答多个命名问题，每答案带校准概率。这比"让 LLM 生成 JSON 再解析"在延迟和稳定性上更有优势。
- **语音交互产品**：全因果音频编码器（首 token 50ms）+ 87x 实时流式解码，意味着语音回复可以在生成过程中就开始播放，而不必等整句生成完。
- **机器人 / 具身感知栈**：官方把 LFM3-VL-2B 适配成编排（工具调用 + 指向 + 深度工具 + 运动规划器）、导航（5 token 预测航点轨迹）、操作（VLA，单次前向输出 8 步连续动作）三类模型；联合 15 个体训练后 LIBERO 四套件平均 **96.2%**，RoboCasa-GR1 桌面任务 **45.7%**，Jetson AGX Orin + TensorRT FP16 下动作块生成 **<50ms**。

### 什么场景不值得用

- **没有数据也不打算微调**：Liquid 官方自己承认前沿模型是更强的通才。如果你只是要一个"什么都懂一点"的对话入口，2B 级模型会明显吃亏。
- **需要长链复杂推理的任务**：即便官方宣传其 agent 能力提升，2B 级模型的推理深度天花板仍在。VL 模型示例里 `max_new_tokens=16384` 并注明"reasoning can be long"，这本身就暗示了它在推理任务上会消耗大量 token。
- **重度多语言、低资源语言生产环境**：音频模型覆盖 18 种语言，超出这个范围的场景不要假设它能用。
- **对 benchmark 宣称零容忍的合规场景**：目前所有对比数字均为官方自测，缺少独立复现；采购前应自行跑满你的 eval 集。
- **许可与商用条款**：博客强调"open-weight"，但具体许可证与商用限制需要逐个 model card 确认，本文不做推断。

### 迁移成本

从 LFM2.x 迁移到 LFM3 的主要成本不在推理侧（transformers 一行换 model id），而在**微调脚本与显存规划**：

- 文本模型：`pip install -U transformers` 即可，pipeline 调用方式基本不变。
- VL 模型：需 **transformers >= 5.21.0** + torch / torchvision / pillow。
- Audio / Omni：需 **transformers >= 5.20.2** + librosa / soundfile，且 Omni 额外需要 torchcodec。
- d1：需 **transformers >= 5.19**，且 API 形态完全不同（`model.system_one(state, questions)`，而非 chat completion）。

如果你的现有 pipeline 是围绕 chat template 写的，d1 会是一次**结构性改造**而不是替换；但如果你现在用"LLM 输出 JSON 再校验"，d1 反而可能让整条链路变短。

## 对你的意义

对 Agent + UI 方向：这次发布最值得注意的不是参数，而是**"决策模型"这个品类被认真做成了端侧组件**。d1 的接口形态——一次前向，多问题，每答案带校准概率，支持指向、读数、区间估计、多选——本质上把"LLM 当分类器用"这件事从 prompt 工程下沉成模型能力。这对任何需要实时路由、意图分流、表单填充的 agent UI 都是直接的降本选项。建议：**立即在一条低风险路由链路上做 A/B**，用 d1-2B 替换一次 LLM 调用，观察延迟与准确率的实际变化。

对 VLA 方向：LFM3-VL-2B 被官方直接改编成 VLA，并入 15 个体联合训练，在 Jetson AGX Orin 上 <50ms 出动作块——这个数字比模型本身更值得关注。它说明"2B 级视觉模型 + TensorRT FP16 + 嵌入式 GPU"已经能撑起实时闭环。如果你在做触觉 + VLA 的感知前端，LFM3-VL-2B 的"指向 + 深度工具 + 结果校验"编排范式是一个可借鉴的工程参考：**把高层规划交给工具调用，把低层控制交给单次前向的动作块**。但要注意 45.7% 的 RoboCasa-GR1 成功率意味着桌面精细操作仍是硬骨头，别把这个数字当成可上线的信号。

## 关键代码/配置片段

文本模型推理（源：博客 LFM3-1.7B 小节）：

```python
from transformers import pipeline

generator = pipeline(
    "text-generation",
    model="LiquidAI/LFM3-1.7B",
    trust_remote_code=True,
)

messages = [{"role": "user", "content": "What is C. elegans?"}]
output = generator(
    messages,
    do_sample=True,
    temperature=0.1,
    top_k=50,
    repetition_penalty=1.1,
    max_new_tokens=2048,
)
print(output[0]["generated_text"][-1]["content"])
```

决策模型 d1-2B 的多问题单次前向（源：博客 d1 小节，节选核心结构）：

```python
questions = {
    "refund": {"type": "noul", "instructions": "Is the customer asking for a refund?"},
    "team": {"type": "choice", "instructions": "Which team should handle this?",
             "criteria": {"billing": "Charges, refunds, invoices",
                          "shipping": "Delivery and parcels",
                          "technical": "App or site faults"}},
    "topics": {"type": "choice", "multiple": True,
               "instructions": "Which topics does the message raise?",
               "criteria": {"billing": "Payments and charges",
                            "delivery": "Shipping and parcels",
                            "login": "Signing in to the account"}},
    "urgency": {"type": "score", "instructions": "How urgent is this ticket?",
                "criteria": ["low", "medium", "high"]},
}
out = model.system_one("I was charged twice and my parcel never arrived. "
                       "Please refund one charge.", questions)
a = out["answers"]
urgency = a["urgency"]["legend"][str(int(a["urgency"]["score"]))]
print(round(a["refund"]["noul"], 2), a["team"]["choice"],
      a["topics"]["choices"], urgency)
# 1.0 billing ['billing', 'delivery'] medium
```

微调入口（源：博客 fine-tune 表格）覆盖 SFT / DPO / GRPO / CPT 四种方法，示例任务包括"从杂乱文档抽结构化 JSON""基于检索文档作答或拒答""在 108 工具的手机 App 里调用正确工具""从原始文本学一门新语言（土耳其语）"。

---
[← Back to Deep Dives](./README.md)
