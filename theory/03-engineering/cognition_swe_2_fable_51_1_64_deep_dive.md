---
auto_generated: true
generated_at: "2026-09-15T05:45:44Z"
source_url: "https://cognition.com/blog/swe-2"
signal_type: "significant_update"
---
# Cognition SWE-2：把 RL 首次推到万亿参数，逼近前沿且成本低 64% (Cognition SWE-2: Pushing the Pareto Frontier)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-15
>
> **项目/工具**: Cognition SWE-2（编码 Agent 模型）
> **链接**: https://cognition.com/blog/swe-2
> **核心定位**: Devin 背后的新一代编码模型——用「一次 RL 训练覆盖全部推理档位」的方法，把整个成本-性能前沿整体上移，以 Fable 5.1 约 1/3 的价格拿到只差 1 分的成绩。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Cognition 发布 SWE-2 编码模型，RL 训练首次规模化到 multi-trillion 参数，整套成本-性能曲线被整体抬高。
- **現在值得用嗎**：看场景。若你已经在用 Devin（Desktop/CLI），可立即切换，长任务成本下降明显；若只是评估编码模型选型，值得把它纳入成本维度对比。
- **適合場景**：大批量、可并行、成本敏感的编码 Agent 任务；需要多档推理预算（简单任务省钱、复杂任务加力）的流水线。
- **不適合場景**：极端难任务（Terminal-Bench 4 仅 27.3%，远低于 Fable 5.1 的 55.8%）；对托管配套生态有强依赖的团队。
- **與前版/竞品核心差異**：相比 SWE-1.7，medium 档得分更高、平均少用 58% 轮次、成本低 81%；相比 Fable 5.1，FrontierCode 1.1 Main 仅差 0.9 分（50.0% vs 50.9%）而便宜 64%。

## 是什么 / 解决什么问题

Cognition 于 2026-09-10 发布 SWE-2，称其为「迄今最强的编码模型」。它并不是又一个刷榜模型，而是明确瞄准了一个工程痛点：**编码 Agent 的真实成本-性能权衡**。随着模型越来越贵，"哪一档推理强度、花多少钱、换多少分"成了所有 Agent 产品必须回答的问题。

SWE-2 的核心贡献有两层。第一层是结果：在 FrontierCode 1.1 Main 上拿到 50.0%，距离 Fable 5.1 的 50.9% 仅差 1 分（0.9 个百分点），但成本低 64%；在 DeepSWE 1.1 上以 73.0% 反超 Fable 5.1（67.4%）和 GPT-5.6 Sol（72.7%）。第二层是方法：Cognition 提出了一套「Pareto-informed cost penalty」的 RL 目标，**在一次 RL 训练中同时训练所有推理档位（effort level）**，让整条成本-性能前沿上移，而不是只优化单点。

这一点值得关注，因为此前 K3 这类模型的通行做法是为每个「领域 × 档位」组合单独训练专家，再用 multi-teacher on-policy distillation 合并。SWE-2 把这件事收敛成一次端到端 RL，是方法层面的简化与统一。

## 技术架构拆解

### 核心设计决策

- **基座选择**：SWE-2 从 Kimi K3 后训练而来，K3 是一个 **2.8T 参数**、且已经过大量 agentic coding RL 的模型。Cognition 称即便在如此强的基座上，自家 RL 仍找到 5–6 分的 headroom，并把 K3 的整条成本-性能前沿整体移动。
- **成本惩罚进 reward（first principles）**：对每个档位施加线性成本惩罚，且惩罚系数按基座 Pareto 前沿在该档位处的**局部斜率**来标定。官方给出的形式为 `R = S - λ_e · C`，其中 S∈{0,1} 表示 rollout 是否成功，C 是 rollout 成本（USD 推理成本 + rollout 时间的混合），λ_e 按档位 e 的斜率设定。
- **为什么必须线性**：Cognition 证明，若希望 reward 在任务分布 D 上的期望**只**依赖平均成本与平均解出率（即与具体联合分布无关），则惩罚必须（在加常数与缩放下）是线性的——只有线性惩罚对「先平均 cost 再算」与「先算再平均」结果一致。
- **λ 怎么定**：把 λ_e 设为该档位当前前沿点的斜率 m，可使 iso-reward 线与前沿相切——此时沿前沿移动对目标 J 的一阶影响为 0，任何提升 reward 的更新都真正改善前沿，而非把高档位"退化成"中档位。
- **length-weighted reward baseline**：自 SWE-1.6 沿用至今，用 `b = (Σ R_i·L_i) / (Σ L_i)` 近似最优 baseline，降梯度方差、稳定训练，且保持 inference–training KL 低。
- **RL rollout 服务化**：四项目标——最大化吞吐、降低延迟（控制 staleness）、留在 KV-cache 容量内、保持训练/推理数值接近。手段包括 prefill delayer（把相邻请求批处理，TPM/GPU 与 TPS/request 提升 **10–20%**）、DSpark 推测解码 + SpecForge 训练新 draft 模型（accept length 长 **15%**）+ 在线 draft 训练。
- **低精度数值**：NVFP4/FP8 kernel + 量化感知训练。MLA 层 K/Q/V 与 score 计算用 FP8，比 SWE-1.7 的混合精度（NoPE 用 FP8、RoPE 留 BF16）更简化。

### 与前版/竞品的关键差异

| 维度 | SWE-1.7 | SWE-2 |
|------|---------|-------|
| 训练方式 | 单档位/固定长度惩罚 | 一次 RL 训练全部档位，Pareto 斜率标定 λ |
| 探索行为 | 过度探索、简单任务 overthink | 聚焦探索，medium 首次真实编辑中位 18 步（前版 48 步）|
| 平均轮次（FrontierCode 1.1 Main）| 127 | medium 53 / high 80 / max 98 |
| 平均成本 | 基准 | medium 比 SWE-1.7 便宜 81% |
| 数值精度 | 混合精度（NoPE FP8 / RoPE BF16）| MLA K/Q/V + score 全 FP8 |
| RL 环境数 | 基准 | ×3，加 instruction-following overlay + verifier flywheel |

### 基准对比（官方 blog 数据）

| Benchmark | SWE-2 | Kimi K3 | Grok 4.6 | Fable 5.1 | GPT-5.6 Sol | GPT-6 Astra | SWE-1.7 |
|-----------|-------|---------|----------|-----------|-------------|-------------|---------|
| FrontierCode 1.1 Main | 50.0% | 44.2% | 48.0% | 50.9% | 47.5% | 53.3% | 42.0% |
| DeepSWE 1.1 | 73.0% | 68.5% | 67.5% | 67.4% | 72.7% | 74.1% | 37.7% |
| Terminal-Bench 2.1 | 92.8% | 88.3% | 88.4% | 91.4% | 88.8% | 89.9% | 81.5% |
| Terminal-Bench 4 | 27.3% | 21.5% | 20.3% | 55.8% | 37.3% | 57.9% | 7.6% |

这张表同时告诉了两件事：SWE-2 在主流与长程终端任务上确实全面领先同价位对手；但在**最难的 Terminal-Bench 4 上只有 27.3%**，被 Fable 5.1（55.8%）和 GPT-6 Astra（57.9%）拉开明显差距——"逼近前沿"是有条件的。

### 架构/信息流图

```
SFT/后训练基座: Kimi K3 (2.8T, 已 agentic RL)
        │
        ▼
  ┌─────────────────────────────────────┐
  │  单次 RL run（全部 effort level）     │
  │   reward  R = S - λ_e · C            │
  │   λ_e ← 基座 Pareto 前沿的局部斜率    │
  │   baseline b = Σ R_i·L_i / Σ L_i     │
  └─────────────────────────────────────┘
        │  rollout（服务化）
        ▼
  prefill delayer → DSpark 推测解码(在线 draft)
        │              + NVFP4/FP8 + QAT
        ▼
   数据闭环: 三倍 RL 环境 + instruction overlay
             + 用 SWE-2 旧 checkpoint 硬化 verifier
        │
        ▼
  部署: Devin Desktop / CLI（首发）→ Devin Web / Fusion
```

## 实用评估

### 什么场景值得用

- **成本敏感的批量编码任务**：medium 档"得分更高、轮次少 58%、成本低 81%"，在 CI 修复、批量重构、issue 清理这类规模可以铺开的场景里，单位成本的产出提升是实打实的。
- **需要分档预算的 Agent 流水线**：单次 RL 训练保留了多档推理行为（medium 快速动手、high/max 更多规划与验证），调度层可以按任务难度动态选档。
- **已经在用 Devin 的团队**：Desktop 与 CLI 当日即可用，切换成本近乎为零。

### 什么场景不值得用

- **极端困难的推理/长程任务**：Terminal-Bench 4 上 27.3% 的得分显著落后前沿（Fable 5.1 55.8%、GPT-6 Astra 57.9%），这类任务上"便宜"换不来"搞定"。
- **强依赖托管生态/多供应商的团队**：SWE-2 主要通过 Devin 系产品分发，若你不在 Devin 栈内，获取与集成路径待确认。
- **把 benchmark 数字直接当 SLA 的场合**：官方数据为自测，且用三跑均值，实际生产分布会不同，需自行复测。

### 迁移成本

- **Devon Desktop/CLI 用户**：几乎零成本，切换到 SWE-2 即可；建议对长任务先从 high/max 档试，再按成本回落到 medium。
- **自建 Agent 框架**：需要接入 Cognition 的调用入口，并重新做一次"难度 → 档位"的映射与成本预算；工作量集中在调度与评估层，而非模型替换本身。
- **评估层面**：建议新增"每分成本"指标（cost per point），把 SWE-2 的 Pareto 卖点量化进你的选型表。

## 对你的意义

如果你在做 Agent 产品（尤其编码类），SWE-2 给的信号不只是"多了一个便宜模型"，而是**成本-性能前沿正在被当成一等训练目标**。过去大家比单点分数，现在 Cognition 直接把"每分多少钱"做进 reward 里，这意味着未来的模型选型表必须从"分数榜"升级为"Pareto 曲线"。

行动建议：**立即观望 + 小范围试用**。如果你有 Devin 账号，本周挑一个成本敏感的批量任务跑 medium 档，对比你当前模型的"每分成本"；如果没有，先把"Pareto 前沿"这个维度加进你的内部选型框架——这比多一个模型更重要。

## 关键代码/配置片段

以下公式来自 Cognition 官方 blog（此处以纯文本表达，避免 LaTeX）：

```
# 成本惩罚奖励函数
R = S - λ_e * C
#   S  : 0/1，rollout 是否成功
#   C  : rollout 成本（USD 推理成本 + rollout 时间的混合）
#   e  : 推理档位（medium / high / max）
#   λ_e: 按基座 Pareto 前沿在档位 e 处的局部斜率设定

# λ 的几何直觉：令 iso-reward 线 s = λ_e * c + J 与前沿相切
# 沿前沿移动一阶影响：ΔJ ≈ (m - λ_e) * Δc
# 取 λ_e = m（前沿局部斜率）→ 沿前沿移动不改变目标，只推动前沿整体上移

# length-weighted reward baseline（自 SWE-1.6 沿用）
b = (Σ_i R_i * L_i) / (Σ_i L_i)

# 关键工程参数（官方口径）
#  - prefill delayer: TPM/GPU 与 TPS/request +10~20%
#  - SpecForge 新 draft 模型: accept length +15%
#  - 精度: NVFP4/FP8 + QAT；MLA 层 K/Q/V 与 score 用 FP8
```

部署入口（来自 blog）：SWE-2 首发于 Devin Desktop 与 Devin CLI，随后滚动覆盖 Devin Web 与 Fusion。

> TODO: 公开 API 定价与 rate limit 未在本文档给出，需查 Devin 定价页确认。
> TODO: Terminal-Bench 4 上落后前沿的根因，官方未展开，待验证。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | SWE-2 在 DeepSWE 1.1 达 73.0%、Terminal-Bench 2.1 达 92.8%，并以"每分成本"为训练目标压低初级任务成本，朝该门槛持续逼近 |

---
[← Back to Deep Dives](./README.md)
