---
auto_generated: true
generated_at: "2026-07-08T09:05:06Z"
source_url: "https://www.36kr.com/p/3871135542424256"
signal_type: "significant_update"
---
# DeepSeek 开源 DeepSpec：DSpark 推测解码推理提速 60-85% (DeepSeek Open-Sources DeepSpec: DSpark Speculative Decoding with 60-85% Speedup)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-08
>
> **项目/工具**: DeepSpec (DSpark 算法)
> **链接**: https://github.com/DeepSeek-AI/DeepSpec
> **核心定位**: DeepSeek 联合北大开源的全栈推测解码训练框架，核心算法 DSpark 通过半自回归架构 + 置信度调度，在 DeepSeek-V4 线上系统中实现每用户生成速度提升 60-85%

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: DeepSpec 是一个推测解码（Speculative Decoding）训练与评估框架，核心算法 DSpark 通过"半自回归 draft + 置信度感知调度"双管齐下，同时解决了并行 draft 的质量衰减和系统级验证浪费问题
- **现在值得用吗**: 是——如果你在用 Qwen3 / Gemma4 系列模型做推理服务优化，预训练 checkpoint 可直接下载即用；如果你需要训练自己的 draft 模型，完整训练管线也已开源
- **适合场景**: 高并发 LLM 推理服务加速、代码/数学等结构化生成场景（接受率天然更高）、需要在不改变模型权重的前提下降低延迟
- **不适合场景**: 单用户低并发场景（收益有限）、thinking mode 模型（需重新微调 draft）、非 Transformer 架构
- **与 Eagle3 / DFlash 核心差异**: Eagle3 是自回归 draft（质量高但慢），DFlash 是纯并行 draft（快但尾部接受率衰减严重），DSpark 是半自回归（并行 backbone + 轻量串行 head）+ 动态验证长度调度——兼顾两者优势

## 是什么 / 解决什么问题

推测解码（Speculative Decoding）是当下 LLM 推理加速最成熟的技术路线之一。核心思路很简洁：用一个轻量级 draft 模型一次性生成多个候选 token，然后让目标大模型并行验证整个候选块——接受最长的一致前缀，再加一个 bonus token。因为验证是并行的且接受规则严格保持目标分布不变，所以加速过程不会有任何质量损失。

但推测解码的性能高度依赖 draft 模型的设计，这里存在一个根本性的 trade-off：

- **自回归 draft**（如 Eagle3）：每个 token 依赖前一个，质量高、接受率高，但 draft 延迟随块大小线性增长，只能用小块
- **并行 draft**（如 DFlash）：一次前向传播生成所有候选 token，draft 延迟几乎不随块大小增长，但位置之间互相独立导致尾部接受率急剧衰减

更深层的系统问题是：即使并行 draft 生成了很长的候选块，无差别地验证所有 token 会浪费宝贵的 batch 容量——在高并发场景下，验证一个大概率被拒绝的尾部 token，占用的 compute 本可以用来服务另一个请求。

DSpark 的核心突破在于**同时从算法和系统两个维度解决这些问题**：

1. **算法层**：半自回归架构——并行 backbone 保持 draft 速度，轻量串行 head 注入 token 间依赖，缓解尾部衰减
2. **系统层**：置信度调度验证——每个 draft token 附带一个置信度分数，调度器根据置信度 + 引擎实时吞吐 profile 动态裁剪验证长度，只验证高回报 token

在 DeepSeek-V4 线上真实流量中，相比生产基线 MTP-1，DSpark 在匹配吞吐量的前提下将每用户生成速度提升 60-85%（V4-Flash）和 57-78%（V4-Pro）。更重要的是，在严格的 SLA 约束下（如 Flash 120 TPS、Pro 50 TPS），基线能力严重恶化时 DSpark 仍能维持稳健吞吐，解锁了之前不可达的严格交互性能层级。

## 技术架构拆解

### 核心设计决策

**1. 半自回归生成（Semi-Autoregressive Generation）**

DSpark 的核心架构创新。传统并行 draft 的所有位置独立预测，导致多模态碰撞和尾部接受率快速衰减。DSpark 的设计选择是：

- **重型并行 backbone**：承担主要的 draft 计算，draft 延迟 T_draft 几乎不随块大小 γ 增长
- **轻量串行输出 head**：在并行 backbone 之上追加一个轻量级自回归模块，注入局部转移信息，改善尾部 token 的连贯性

这个设计的精妙之处在于：串行 head 的计算量远小于 backbone，因此增加的延迟极小，但带来的接受率提升显著。从配置文件中可以看到，block_size=7（每次 draft 7 个 token），num_draft_layers=5（draft 模型 5 层），num_anchors=512（512 个锚点 token），markov_rank=256（Markov head 秩）。

**2. 置信度调度验证（Confidence-Scheduled Verification）**

这是 DSpark 区别于所有 prior work 的系统级创新：

- **Confidence Head**：为每个 draft token 估计一个前缀生存概率（prefix survival probability）——即该 token 及之前所有 token 都被接受的概率
- **硬件感知调度器**：结合置信度分数和引擎实时吞吐 profile，动态决定每个请求的验证长度
- **核心逻辑**：低置信度的尾部 token 直接丢弃，不进入验证阶段——节省的 batch 容量可以服务更多请求

这解决了并行 draft 的第二个瓶颈：不是所有 draft token 都值得验证。

**3. 共享嵌入和输出层**

与 DFlash 类似，DSpark 的 draft 模型共享目标模型的 embedding 层和 language modeling head（两者 frozen）。这减少了 draft 模型的参数量，也保证了 draft 和目标模型在 token 空间上的一致性。

### 与前版/竞品的关键差异

| 维度 | Eagle3（自回归） | DFlash（纯并行） | DSpark（半自回归 + 调度） |
|------|-----------------|-----------------|------------------------|
| Draft 架构 | 自回归，逐 token 生成 | 纯并行，单次前向传播 | 并行 backbone + 轻量串行 head |
| Draft 延迟 | 随块大小线性增长 | 几乎不随块大小增长 | 几乎不随块大小增长 |
| 接受率 | 高（token 间有依赖） | 尾部衰减严重 | 高（缓解尾部衰减） |
| 验证策略 | 固定长度 | 固定长度 | 动态置信度调度 |
| 系统效率 | 中等 | 高并发下验证浪费 | 高（按需验证） |
| Qwen3-4B 相对接受长度 | 基线 | +16.3% over Eagle3 | +30.9% over Eagle3 |
| Qwen3-8B 相对接受长度 | 基线 | +18.4% over Eagle3 | +26.7% over Eagle3 |
| Qwen3-14B 相对接受长度 | 基线 | +18.3% over Eagle3 | +30.0% over Eagle3 |
| 线上加速比（V4-Flash） | N/A | N/A | 60-85% over MTP-1 |
| 线上加速比（V4-Pro） | N/A | N/A | 57-78% over MTP-1 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Decoding Cycle                            │
│                                                              │
│  Target Model (previous step)                                │
│       │                                                      │
│       ▼                                                      │
│  [Anchor Token D] ──────── Draft Phase ──────────────────┐   │
│       │                                                   │   │
│       ▼                                                   │   │
│  ┌──────────────────────────────────────────────┐         │   │
│  │         DSpark Draft Model                    │         │   │
│  │                                               │         │   │
│  │  ┌─────────────┐    ┌───────────────────┐    │         │   │
│  │  │ Parallel     │───▶│ Lightweight       │    │         │   │
│  │  │ Backbone     │    │ Sequential Head   │    │         │   │
│  │  │ (5 layers)   │    │ (Markov + Conf.)  │    │         │   │
│  │  └─────────────┘    └───────────────────┘    │         │   │
│  │         │                    │               │         │   │
│  │         ▼                    ▼               │         │   │
│  │  Draft Tokens: [E F G H]                     │         │   │
│  │  Confidence:   [c1 c2 c3 c4]                 │         │   │
│  └──────────────────────────────────────────────┘         │   │
│       │                                                   │   │
│       ▼                                                   │   │
│  ┌──────────────────────────────────────────────┐         │   │
│  │   Hardware-Aware Prefix Scheduler            │         │   │
│  │   c4 低置信度 → 丢弃 H                       │         │   │
│  │   保留前缀: [E F G]                          │         │   │
│  └──────────────────────────────────────────────┘         │   │
│       │                                                   │   │
│       ▼                                                   │   │
│  Target Model Verification (parallel)                     │   │
│       │                                                   │   │
│       ▼                                                   │   │
│  [E ✓] [F ✓] [G ✗] → 接受前缀 [E F] + bonus token        │   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **高并发推理服务**：DSpark 的置信度调度在高并发下优势最明显——减少低价值验证，释放 batch 容量给更多请求。DeepSeek-V4 线上数据在 120 TPS（Flash）和 50 TPS（Pro）的严格 SLA 下仍能维持稳健吞吐
- **代码/数学生成**：结构化任务的 draft 接受率天然高于开放对话，DSpark 在 humaneval、mbpp、livecodebench、gsm8k 等 benchmark 上表现突出
- **Qwen3 / Gemma4 系列模型**：预训练 checkpoint 已发布在 HuggingFace，覆盖 Qwen3-4B/8B/14B 和 Gemma4-12B，可直接下载用于 speculative decoding
- **需要训练自定义 draft 模型**：DeepSpec 提供完整的数据准备 → 训练 → 评估管线，支持 Eagle3 / DFlash / DSpark 三种算法

### 什么场景不值得用

- **单用户低并发**：推测解码的 batch 容量优化收益在低并发下不明显，简单的自回归 draft 可能就够了
- **Thinking Mode 模型**：论文明确提到，如果目标模型运行在 thinking mode，需要针对该模式重新微调 draft 模型——预训练 checkpoint 不直接适用
- **非 Transformer 架构**：DeepSpec 当前仅支持 Qwen3 和 Gemma 系列，架构依赖较强
- **资源极度受限**：训练数据缓存默认约 38 TB（针对 Qwen3-4B），训练需要 8 GPU 节点

### 迁移成本

- **使用预训练 checkpoint**：极低。从 HuggingFace 下载 checkpoint，配置 target model 和 draft model 路径，即可运行评估。约 30 分钟可完成部署验证
- **训练自定义 draft**：中等。需要：(1) 目标模型 serving 能力用于数据再生（~38 TB 缓存），(2) 8 GPU 节点训练（默认配置 10 epochs），(3) 训练时间取决于硬件——默认配置下约数小时到一天
- **从 Eagle3 迁移**：低。DeepSpec 同时支持 Eagle3 和 DSpark，同一评估框架，切换算法只需改 config_path

## 对你的意义

DSpark 的开源对 AI 应用开发社区有几个实际意义：

1. **推测解码从"学术概念"走向"工程可复用"**：DeepSpec 提供了完整的数据准备、训练、评估管线，不是论文代码——是生产可用的。如果你在做 LLM 推理优化，这是一个可以直接拿来用的工具箱
2. **预训练 checkpoint 覆盖主流模型**：Qwen3 4B/8B/14B + Gemma4 12B 的 checkpoint 可直接下载，不需要自己训练。这意味着你可以立即在自己的推理服务中集成推测解码
3. **置信度调度是一个新的优化维度**：之前的推测解码研究集中在 draft 模型设计（如何 draft 得更好），DSpark 把"验证多少 token"也变成了一个可优化的变量。这个思路可以延伸到其他推理优化场景
4. **与 Agent 工作流的关联**：多轮 agentic 工作流对延迟敏感（每轮交互都累积延迟），推测解码可以显著改善多轮场景的用户体验

**建议**：如果你在用 Qwen3 或 Gemma4 系列做推理服务，立即试用预训练 checkpoint 验证收益。如果你在训练自定义模型，DeepSpec 的管线值得学习——即使不直接用 DSpark，其数据准备和评估框架也有参考价值。

## 关键代码/配置片段

### DSpark 训练配置（Qwen3-4B）

来源：`config/dspark/dspark_qwen3_4b.py`

```python
model = dict(
    target_model_name_or_path=QWEN_3_4B,
    block_size=7,              # 每次 draft 7 个 token
    num_draft_layers=5,        # draft 模型 5 层
    target_layer_ids=[1, 9, 17, 25, 33],  # 目标模型特征提取层
    mask_token_id=151669,      # mask token ID
    num_anchors=512,           # 锚点 token 数量

    ## Markov head（串行依赖注入）
    markov_rank=256,
    markov_head_type='vanilla',

    ## Confidence head（置信度估计）
    confidence_head_alpha=1.0,
    confidence_head_with_markov=True,

    ## 损失函数权重
    loss_decay_gamma=4.0,
    ce_loss_alpha=0.1,
    l1_loss_alpha=0.9,
)

train = dict(
    trainer_cls=Qwen3DSparkTrainer,
    lr=6.0e-4,
    warmup_ratio=0.04,
    precision="bf16",
    local_batch_size=1,
    global_batch_size=512,
    num_train_epochs=10,
    sharding_strategy="no_shard",
    torch_compile=True,
)
```

### 已发布的 Checkpoint

| 算法 | Qwen3-4B | Qwen3-8B | Qwen3-14B | Gemma4-12B |
|------|----------|----------|-----------|------------|
| DSpark | deepseek-ai/dspark_qwen3_4b_block7 | deepseek-ai/dspark_qwen3_8b_block7 | deepseek-ai/dspark_qwen3_14b_block7 | deepseek-ai/dspark_gemma4_12b_block7 |
| DFlash | deepseek-ai/dflash_qwen3_4b_block7 | deepseek-ai/dflash_qwen3_8b_block7 | deepseek-ai/dflash_qwen3_14b_block7 | deepseek-ai/dflash_gemma4_12b_block7 |
| Eagle3 | deepseek-ai/eagle3_qwen3_4b_ttt7 | deepseek-ai/eagle3_qwen3_8b_ttt7 | deepseek-ai/eagle3_qwen3_14b_ttt7 | deepseek-ai/eagle3_gemma4_12b_ttt7 |

### 评估运行方式

```bash
# 评估脚本
bash scripts/eval/eval.sh

# 关键参数
# target_name_or_path: Qwen/Qwen3-4B
# draft_name_or_path: deepseek-ai/dspark_qwen3_4b_block7
# 评估数据集: gsm8k, math500, aime25, humaneval, mbpp, livecodebench, mt-bench, alpaca, arena-hard-v2
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-004: 推理模型在 Agent 任务展现持续优势 | 支持 | DSpark 通过推测解码在不改变模型质量的前提下显著提升推理速度（60-85%），使推理密集型 Agent 工作流的延迟成本大幅降低，间接支持"推理模型在 Agent 任务中更具可行性"的判断 |

[← Back to Deep Dives](./README.md)
