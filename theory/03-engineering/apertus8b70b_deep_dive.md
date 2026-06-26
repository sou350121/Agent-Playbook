---
auto_generated: true
generated_at: "2026-06-26T12:10:55Z"
source_url: "https://apertvs.ai/"
signal_type: "significant_update"
---
# Apertus：瑞士学术联盟发布完全开源基础模型（8B/70B）(Apertus: Fully Open Multilingual Foundation Models by Swiss AI Initiative)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-26
>
> **项目/工具**: Apertus (8B / 70B)
> **链接**: https://huggingface.co/swiss-ai/Apertus-8B-2509
> **核心定位**: 由 EPFL + ETH Zurich + CSCS 联合打造的完全开源（权重+数据+代码+方法）多语言大语言模型，以 EU AI Act 合规为核心卖点，对标同规模 top open-weight 模型。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Apertus 是全球首个同时做到「open weights + open data + open training code + EU AI Act 合规」的开源 LLM，提供 8B 和 70B 两个尺寸。
- **現在值得用嗎**：是——如果你需要 EU 合规的开源模型、多语言场景（1000+ 语言）、或可审计的训练流水线。
- **適合場景**：欧洲企业/政府 AI 部署（GDPR + EU AI Act 合规需求）、多语言 NLP 研究、需要完全可审计训练数据的合规敏感场景。
- **不適合場景**：纯英文高性能场景（Qwen2.5-72B / Llama3.1-70B 仍略强）、需要即插即用 PII 过滤器的场景（目前尚未提供）。
- **與同類核心差異**：OLMo 系列虽然也开源，但数据覆盖仅 ~100 语言；Apertus 覆盖 1800+ 语言且 40% 非英文数据，同时提供完整训练数据重建脚本。

## 是什么 / 解决什么问题

当前开源 LLM 生态存在一个系统性矛盾：大多数「开源模型」只开放权重（open-weight），却不开放训练数据、训练代码和数据合规流程。这意味着用户无法审计模型是否使用了侵权数据、是否包含 PII、是否符合 GDPR 等法规。Apertus 试图从根本上解决这个问题——它宣称自己是「Fully Open」模型，不仅开放权重，还开放训练数据重建脚本、训练代码、对齐方法、评估套件，全部以 Apache 2.0 许可发布。

Apertus 由瑞士 AI Initiative（Swiss AI Initiative）开发，该计划于 2023 年底启动，获得了 2000 万瑞士法郎拨款和 Alps 超算上 1000 万 GPU 小时的初始投入。核心参与机构包括 EPFL（洛桑联邦理工学院）、ETH Zurich（苏黎世联邦理工学院）和 CSCS（瑞士国家超级计算中心），战略伙伴包括 Swisscom。

模型在 Alps 超算上训练，该超算拥有 10,752 块 NVIDIA GH200 Grace-Hopper 芯片，算力 270-435 PFLOPS，2024 年 6 月 TOP500 排名全球第 6。Apertus 1.0 版本使用了约 50% 的可用算力。

## 技术架构拆解

### 核心设计决策

| 决策维度 | 选择 | 理由 |
|---------|------|------|
| 架构 | Decoder-only Transformer | 与主流 LLM 保持一致，便于部署生态兼容 |
| 激活函数 | xIELU（新型） | 据称在长序列和多语言场景下表现更优 |
| 优化器 | AdEMAMix | 相比 AdamW 在大规模训练中展现更好的收敛性 |
| 预训练数据量 | 15T tokens | 确保多语言覆盖和高质量英文能力 |
| 语言覆盖 | 1,811 种语言，40% 非英文 | 解决开源模型普遍英语中心主义问题 |
| 合规策略 | Goldfish 目标函数 + 数据过滤 | 抑制训练数据逐字记忆，尊重 opt-out |
| 对齐方法 | QRPO（Quantile Regression Policy Optimization） | 后训练对齐阶段的新方法 |
| 上下文长度 | 65,536 tokens | 满足长文档和代码场景 |
| 许可协议 | Apache 2.0 | 最宽松的开源许可，允许商业使用 |

### 与前版/竞品的关键差异

| 维度 | Apertus-8B | Apertus-70B | Llama3.1-8B | Llama3.1-70B | OLMo2-7B | OLMo2-32B |
|------|-----------|------------|-------------|--------------|----------|-----------|
| 平均得分 | 65.8 | 67.5 | 65.4 | 67.3 | 64.0 | 67.7 |
| ARC | 72.7 | 70.6 | 71.6 | 74.4 | 72.9 | 76.2 |
| HellaSwag | 59.8 | 64.0 | 60.0 | 56.5 | 60.4 | 66.7 |
| WinoGrande | 70.6 | 73.3 | 73.4 | 79.4 | 74.5 | 78.6 |
| XNLI | 45.2 | 45.3 | 45.3 | 44.3 | 40.4 | 42.9 |
| XCOPA | 66.5 | 69.8 | 61.8 | 66.7 | 55.2 | 60.1 |
| PIQA | 79.8 | 81.9 | 80.1 | 82.3 | 80.9 | 82.1 |
| 开源程度 | 全开 | 全开 | 仅权重 | 仅权重 | 全开 | 全开 |
| 语言数 | 1811 | 1811 | ~100 | ~100 | ~100 | ~100 |
| 合规认证 | EU AI Act | EU AI Act | 无 | 无 | 无 | 无 |
| 许可 | Apache 2.0 | Apache 2.0 | Llama 3.1 License | Llama 3.1 License | Apache 2.0 | Apache 2.0 |

**关键发现**：
- Apertus-8B 在 XNLI（多语言推理）上显著优于 OLMo2-7B（45.2 vs 40.4），多语言优势明显
- Apertus-8B 在 XCOPA（因果推理）上大幅领先 OLMo2-7B（66.5 vs 55.2），领先超 10 个百分点
- Apertus-70B 在 XNLI 上超越 Llama3.1-70B（45.3 vs 44.3），在 XCOPA 上也领先（69.8 vs 66.7）
- 在英文基准上，Apertus 与同规模 Llama3.1 基本持平，未显著超越

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Swiss AI Initiative                    │
│  EPFL  │  ETH Zurich  │  CSCS  │  Swisscom (Partner)     │
└────────────────────┬────────────────────────────────────┘
                     │
          ┌──────────▼──────────┐
          │   Alps Supercomputer │
          │  10,752 GH200 GPUs   │
          │  270-435 PFLOPS      │
          └──────────┬──────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   ┌─────────┐ ┌──────────┐ ┌──────────┐
   │Data Prep │ │Pretraining│ │Post-Train│
   │         │ │          │ │          │
   │•15T tokens│ │•Megatron-LM│ │•SFT      │
   │•1811 langs│ │•xADAMix   │ │•QRPO     │
   │•40% non-EN│ │•bfloat16  │ │alignment │
   │•PII filter│ │•4096 GPUs │ │          │
   │•Goldfish  │ │•xIELU act │ │          │
   └─────┬─────┘ └─────┬─────┘ └────┬─────┘
         │             │            │
         └─────────────┼────────────┘
                       ▼
              ┌────────────────┐
              │  Apertus Models │
              │  8B / 70B       │
              │  Apache 2.0     │
              │  65K context    │
              │  Tool use       │
              └───────┬─────────┘
                      │
         ┌────────────┼────────────┐
         ▼            ▼            ▼
    ┌────────┐  ┌─────────┐  ┌──────────┐
    │HF Hub  │  │vLLM/    │  │EU AI Act │
    │(weights│  │SGLang/  │  │Compliance│
    │ +data) │  │MLX/TFRS │  │Docs      │
    └────────┘  └─────────┘  └──────────┘
```

### 训练基础设施

- **GPU**: 4,096 块 GH200（约占总量的 38%）
- **框架**: Megatron-LM（瑞士 AI Initiative 的 fork 版本）
- **精度**: bfloat16
- **预训练 token 数**: 15 万亿（15T）
- **课程学习**: 分阶段 curriculum —— web → code → math

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| 欧洲企业/政府 AI 部署 | EU AI Act 合规 + GDPR 合规 + 瑞士数据保护法三重保障，是目前开源模型中合规最完善的 |
| 多语言 NLP 研究 | 1811 种语言覆盖，XNLI/XCOPA 显著优于同规模竞品，适合低资源语言研究 |
| 需要完全可审计训练数据的场景 | 提供完整的数据重建脚本（github.com/swiss-ai/pretrain-data），可追溯每个 token 来源 |
| 学术研究和教学 | Apache 2.0 许可 + 完全开源，适合二次研究和教学使用 |
| 主权 AI（Sovereign AI） | 瑞士主导的公共利益项目，适合对数据主权有要求的国家/地区 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| 纯英文高性能需求 | Qwen2.5-72B（69.8 均分）和 Llama3.1-70B 在综合基准上仍略强；Apertus 的优势在多语言而非英文绝对性能 |
| 需要即插即用 PII 过滤 | 官方明确说明「Currently no output filter is provided」，PII 输出过滤器尚未发布 |
| 需要快速部署的商业产品 | 模型使用 xIELU 激活函数，需要 transformers >= v4.56.0，生态兼容性尚在建设中 |
| 需要大规模商用支持 | 学术项目背景，无商业公司提供的 SLA 或技术支持 |
| 对训练数据版权有极致要求的金融/医疗场景 | 虽然合规，但 Goldfish 目标函数抑制记忆的效果仍需更多独立验证 |

### 迁移成本

- **从 Llama3.x 迁移**：若仅使用推理，迁移成本较低——API 接口兼容（通过 vLLM/SGLang），但需要升级 transformers 到 v4.56.0+。模型权重格式不同，需重新加载。
- **从 OLMo2 迁移**：两者都是完全开源，但 Apertus 的多语言覆盖远胜。迁移主要成本在于重新评估下游任务性能。
- **从闭源模型（GPT-4/Claude）迁移**：性能差距仍然显著，适合合规优先、性能可妥协的场景。

## 对你的意义

Apertus 的出现标志着开源 LLM 生态进入了一个新阶段——从「open-weight」（只公开权重）向「fully open」（权重+数据+代码+方法全公开）的范式转变。

对于 Ken 的 AI 应用开发工作：
- **Agent 合规部署**：如果未来有面向欧洲市场的 Agent 产品，Apertus 可能是目前唯一满足 EU AI Act 要求的开源基础模型选项
- **多语言 Agent**：1811 种语言覆盖意味着可以构建真正全球化的多语言 Agent，而不依赖商业 API
- **可审计性**：完全开放训练数据使得 Agent 的行为可追溯，这在企业级部署中越来越重要

**建议**：观望为主，但值得关注。Apertus 的合规框架和数据透明度是真正的差异化优势，但在纯性能上尚未超越 Qwen/Llama 系列。如果你的场景涉及 EU 合规或多语言需求，值得尽早试用。

## 关键代码/配置片段

### 快速加载（Transformers）

```python
pip install -U transformers

from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "swiss-ai/Apertus-8B-2509"
device = "cuda"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name).to(device)

prompt = "Give me a brief explanation of gravity in simple terms."
messages_think = [{"role": "user", "content": prompt}]

text = tokenizer.apply_chat_template(
    messages_think, tokenize=False, add_generation_prompt=True
)
model_inputs = tokenizer([text], return_tensors="pt").to(model.device)

generated_ids = model.generate(**model_inputs, max_new_tokens=32768)
output_ids = generated_ids[0][len(model_inputs.input_ids[0]):]
print(tokenizer.decode(output_ids, skip_special_tokens=True))
```

### 部署支持

```bash
# vLLM
pip install vllm  # 需最新版本

# SGLang
pip install sglang

# 本地推理（MLX，Apple Silicon）
pip install mlx-lm
```

推荐采样参数：`temperature=0.8, top_p=0.9`。

---

## 📌 参考来源

- Tech Report: https://arxiv.org/abs/2509.14233
- Model Card (8B): https://huggingface.co/swiss-ai/Apertus-8B-2509
- Model Card (70B): https://huggingface.co/swiss-ai/Apertus-70B-2509
- 官方文档: https://apertvs.ai/docs/
- GitHub org: https://github.com/swiss-ai
- 训练数据重建脚本: https://github.com/swiss-ai/pretrain-data
- Swiss AI Initiative: https://www.swiss-ai.org/
- EU AI Act 合规文档: https://huggingface.co/swiss-ai/Apertus-70B-2509/blob/main/Apertus_EU_Public_Summary.pdf

---
[← Back to Deep Dives](./README.md)
