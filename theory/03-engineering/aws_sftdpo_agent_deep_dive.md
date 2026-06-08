---
auto_generated: true
generated_at: "2026-06-08T06:48:04Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/improve-your-agents-tool-calling-accuracy-with-sft-and-dpo-on-amazon-sagemaker-ai/"
signal_type: "significant_update"
---
# AWS：用 SFT+DPO 提升 Agent 工具调用准确率 (Improve Agent Tool-Calling Accuracy with SFT+DPO)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-08
>
> **项目/工具**: Amazon SageMaker AI — Qwen3 工具调用微调管线
> **链接**: https://aws.amazon.com/blogs/machine-learning/improve-your-agents-tool-calling-accuracy-with-sft-and-dpo-on-amazon-sagemaker-ai/
> **核心定位**: AWS 官方给出了一套端到端方案——用 SFT 教会小模型工具语言，再用 DPO 对齐偏好，无需 RL 即可将 SLM 工具调用准确率提升约 30 个百分点。

## ⚡ 快速判断

- **一句话定位**: AWS 官方教程，展示如何用 SFT + DPO 两阶段微调将 Qwen3-1.7B 的工具调用准确率从 41.6% 提升到 71.1%，超越近两倍参数量的 Llama 3.2 3B。
- **现在值得用吗**: 是——如果你在 AWS 上部署 Agent 且对工具调用准确率有硬性要求，这套管线可直接复用。
- **适合场景**: 需要自研工具调用能力的中小团队；受成本/延迟限制必须用 SLM 的场景；已在 SageMaker 上的用户。
- **不适合场景**: 不需要微调就能满足准确率的场景（直接用 GPT-4/Claude）；非 AWS 基础设施用户迁移成本高。
- **与竞品核心差异**: 相比纯 RLHF，DPO 省去了奖励模型训练环节；相比仅做 SFT，DPO 额外带来 ~10% 准确率提升。

## 是什么 / 解决什么问题

AI Agent 的核心能力之一是**工具调用（Tool Calling / Function Calling）**——根据用户请求选择正确的工具、生成正确的参数格式、在多步工作流中正确串联工具调用。当 Agent 选错工具、参数格式错误或打断工作流链时，任务完成时间增长、错误率上升、支持成本增加、用户体验下降。

随着越来越多组织将 Agent 应用从试点推向生产，**工具调用准确率**成为可靠自动化的关键瓶颈。大模型（LLM）如 GPT-4、Claude 在工具调用上表现不错，但成本高、延迟大。小模型（SLM）成本低、推理快，但原生工具调用能力弱。

AWS 这篇博客给出了一个**两阶段微调方案**：
1. **SFT（监督微调）**: 用高质量标注数据教会模型工具语言、命令格式和约束条件
2. **DPO（直接偏好优化）**: 在 SFT 基础上，用"喜欢/不喜欢"偏好数据进一步对齐模型输出

核心结论：**Qwen3-1.7B 经过 SFT+DPO 后，工具调用准确率达到 71.06%，比 Llama 3.2-3B-Instruct 高 8.4 个百分点，而参数量不到后者的一半。**

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 微调策略 | SFT → DPO 两阶段 | SFT 建立基础工具语言能力，DPO 在此基础上做偏好对齐，比单阶段效果更好 |
| 替代 RLHF | 使用 DPO 而非 RLHF | DPO 不需要训练奖励模型，资源需求和训练时间大幅降低，效果相当 |
| 基座模型 | Qwen3-1.7B（主要） | 在 SFT+DPO 后增益最大（+29.5%），性价比高 |
| PEFT 方法 | Spectrum（AWS 自研） | 基于信噪比选择最优可训练层，也可替换为 LoRA/QLoRA |
| 数据集 | NVIDIA When2Call | 覆盖"何时调用工具/何时追问/何时拒绝"四种决策场景 |
| 训练基础设施 | SageMaker AI ModelTrainer | 全托管，自动处理环境配置、扩缩容和工件管理 |

### 与前版/竞品的关键差异

| 维度 | 仅 SFT | SFT + DPO（本方案） | 纯 RLHF |
|------|--------|---------------------|---------|
| 训练复杂度 | 中 | 中-高（两个阶段） | 高（需奖励模型） |
| Qwen3-1.7B 准确率 | 60.4% | **71.1%** | TODO: 未对比 |
| 额外数据需求 | 仅需标注对话 | 需要 chosen/rejected 偏好对 | 需要奖励标注 |
| 计算成本 | 1× | ~1.5×（DPO 阶段额外开销） | 2-3×（奖励模型+PPO） |
| 适用场景 | 基础工具调用 | 高精度工具调用 | 复杂对齐需求 |
| 开源生态 | TRL SFTTrainer | TRL DPOTrainer | TRL PPOTrainer |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                     数据准备层                                │
│                                                             │
│  NVIDIA When2Call Dataset                                   │
│  ├── train_sft   (15,000 samples) → SFTTrainer             │
│  ├── train_pref  (9,000  samples) → DPOTrainer             │
│  └── test        (3,652 MCQ + 300 LLM-judge) → 评估        │
└──────────────────────┬──────────────────────────────────────┘
                       │ upload to S3
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Phase 1: SFT 微调                          │
│                                                             │
│  Base: Qwen3-1.7B (bfloat16)                                │
│  Method: Spectrum PEFT (或 LoRA/QLoRA)                       │
│  Hardware: ml.p4d.24xlarge (1× A100 8-GPU)                  │
│  Config: lr=5e-5, epochs=10, batch=4, grad_accum=2          │
│  Output: Qwen3-1.7B-function-calling checkpoint             │
│                                                             │
│  准确率: 41.57% → 60.43% (+18.9pp)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ SFT checkpoint 作为 DPO 基座
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Phase 2: DPO 对齐                          │
│                                                             │
│  Input: SFT checkpoint + 9,000 preference pairs             │
│  Method: TRL DPOTrainer (sigmoid loss)                       │
│  Config: beta=0.1, lr=5e-7, epochs=10, batch=2              │
│  Output: SFT-DPO Qwen3-1.7B final model                     │
│                                                             │
│  准确率: 60.43% → 71.06% (+10.6pp)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   评估 & 部署                                 │
│                                                             │
│  Eval: NVIDIA When2Call MCQ (3,652 questions)               │
│  Metrics: Acc-Norm (normalized accuracy)                    │
│  Deploy: SageMaker endpoint / 任意推理服务                    │
└─────────────────────────────────────────────────────────────┘
```

### 关键实验结果

| 模型 | 基线 | SFT | SFT + DPO | 总增益 |
|------|------|-----|-----------|--------|
| Llama 3.2 3B Instruct | 46.50% | 53.41% | 62.67% | +16.2pp |
| Qwen3-0.6B | 47.64% | 56.10% | 62.02% | +14.4pp |
| **Qwen3-1.7B** | **41.57%** | **60.43%** | **71.06%** | **+29.5pp** |

几个值得注意的发现：
- **Qwen3-0.6B 基线最强**：尽管参数量最小，开箱即用的工具调用能力反而最好（47.64%），说明 Qwen3 系列在工具调用上有很强的 pre-training 先验
- **Qwen3-1.7B 增益最大**：SFT 阶段提升 18.9pp，DPO 阶段再提升 10.6pp，总增益 29.5pp，说明中等规模模型从微调中获益最多
- **DPO 的边际收益稳定**：三个模型 DPO 阶段分别提升 9.3pp / 5.9pp / 10.6pp，证明偏好对齐在工具调用任务上具有普遍有效性

## 实用评估

### 什么场景值得用

- **AWS 生态内的 Agent 开发团队**：整套管线基于 SageMaker AI，从数据管理、训练到 MLflow 实验追踪全托管，拿来即用。GitHub 仓库（`aws-samples/amazon-sagemaker-generativeai`）提供了完整的 notebook 和脚本。
- **成本敏感的生产部署**：Qwen3-1.7B-SFT-DPO 在 71% 准确率下超越 Llama 3.2-3B（62.7%），而推理成本约为后者的 1/2。对于高并发工具调用场景（如客服 Agent、自动化工作流），成本差异显著。
- **需要定制化工具集的团队**：When2Call 是通用 benchmark，实际使用时可以用你自己的工具定义替换 dataset 中的 tools 字段，SFT+DPO 管线直接复用。
- **对 RLHF 望而却步的团队**：DPO 省去了奖励模型训练和 PPO 调参，训练复杂度大幅降低。TRL 的 DPOTrainer API 与 SFTTrainer 几乎一致。

### 什么场景不值得用

- **已有足够准确率的 API 调用方案**：如果你的 Agent 直接用 GPT-4o/Claude Sonnet 就能满足工具调用准确率，没必要自研微调管线。API 成本 vs 训练+推理总成本需要综合评估。
- **非 AWS 基础设施**：虽然方法论本身与云无关，但教程深度绑定 SageMaker AI（ModelTrainer API、S3 数据通道、MLflow 追踪）。迁移到自有 GPU 集群或 GCP/Azure 需要重写基础设施层代码。
- **工具调用不是瓶颈的场景**：如果 Agent 的主要错误来自推理能力而非工具选择，微调工具调用不会解决根本问题。
- **资源极度受限**：训练需要 ml.p4d.24xlarge（8×A100 40GB），按需约 $30+/小时。虽然 Spectrum PEFT 减少了可训练参数，但全量 SFT+DPO 仍需显著的 GPU 时间。

### 迁移成本

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 克隆 GitHub 仓库 | 5 分钟 | `git clone` + 安装依赖 |
| 配置 AWS 环境 | 30 分钟-2 小时 | IAM 角色、SageMaker Studio、ECR 容器、S3 bucket |
| 准备数据集 | 1-3 天 | 如果用 When2Call 可直接加载；自定义工具集需要标注 chosen/rejected 偏好对 |
| SFT 训练 | 2-6 小时 | 取决于模型大小和 dataset 规模（10 epochs on 15K samples） |
| DPO 训练 | 1-3 小时 | 9K preference pairs，10 epochs |
| 评估 & 调参 | 1-2 天 | 跑 MCQ 评估、调整 beta/lr 等超参 |
| 部署到生产 | 2-4 小时 | SageMaker endpoint 或自建推理服务 |

**总估算**: 已有 AWS 环境的团队约 2-3 天可跑通全流程；从零开始约 5-7 天。

## 对你的意义

这个方案对 Ken 的 AI Agent 开发工作有直接参考价值：

1. **工具调用是 Agent 的核心瓶颈**：你追踪的 Agent UI 和 Agent 框架（如 LangChain、LlamaIndex）都依赖工具调用。了解如何从底层提升工具调用准确率，有助于评估不同框架的能力边界。
2. **SLM + 微调路线的可行性**：如果未来需要在边缘/低成本场景部署 Agent，Qwen3-1.7B-SFT-DPO 提供了一个经过验证的基线——71% 准确率在不少场景已可用。
3. **DPO 作为 RLHF 的轻量替代**：对于中小团队，DPO 的训练复杂度远低于 RLHF，但在这项任务上效果相当。这降低了自研 Agent 模型的技术门槛。

**建议**: 如果你在 AWS 上有基础设施，值得花半天时间跑通 GitHub 仓库的 notebook，亲自验证 When2Call 上的结果。这比读十篇论文更有实操价值。

## 关键代码/配置片段

### SFT 训练配置（YAML）

```yaml
# Model arguments
model_name_or_path: Qwen/Qwen3-1.7B
tokenizer_name_or_path: Qwen/Qwen3-1.7B
torch_dtype: bfloat16
attn_implementation: flash_attention_2

# Dataset arguments
dataset_id_or_path: /opt/ml/input/data/dataset/dataset.json
max_seq_length: 2048
packing: true

# Spectrum arguments (AWS 自研 PEFT 层选择)
spectrum_config_path: /opt/ml/input/data/code/spectrum-layer/
  snr_results_Qwen-Qwen3-1.7B_unfrozenparameters_50percent.yaml

# Training arguments
num_train_epochs: 10
per_device_train_batch_size: 4
gradient_accumulation_steps: 2
learning_rate: 5.0e-5
lr_scheduler_type: cosine
warmup_ratio: 0.1
```

### DPO 训练配置（YAML）

```yaml
model_name_or_path: /opt/ml/input/model/Qwen3-1.7B-function-calling/
beta: 0.1                    # DPO 关键超参，控制偏离参考模型的程度
max_length: 1536
max_prompt_length: 768
loss_type: sigmoid
num_train_epochs: 10
per_device_train_batch_size: 2
gradient_accumulation_steps: 8
learning_rate: 5.0e-7        # DPO 需要比 SFT 低 100× 的学习率
lr_scheduler_type: constant
warmup_ratio: 0.03
```

### DPO 数据格式（TRL 标准）

```json
{
  "prompt": ["<array of input samples>"],
  "chosen": "<complete preferred response (j)>",
  "rejected": "<complete non-preferred response (k)>"
}
```

### SageMaker ModelTrainer 启动代码

```python
from sagemaker.modules.train import ModelTrainer
from sagemaker.modules.configs import Compute, SourceCode, InputData

compute = Compute(
    instance_count=1,
    instance_type="ml.p4d.24xlarge",
    volume_size_in_gb=96,
)

source_code = SourceCode(
    source_dir="./scripts",
    requirements="requirements.txt",
    entry_script="run_training_sft.sh",
)

model_trainer = ModelTrainer(
    training_image=image_uri,
    compute=compute,
    source_code=source_code,
    ...
)
model_trainer.train(input_data_config=[training_data], wait=True)
```

---
[← Back to Deep Dives](./README.md)
