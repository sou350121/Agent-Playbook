---
auto_generated: true
generated_at: "2026-07-20T06:49:15Z"
source_url: "https://github.com/Danau5tin/ai-trains-ai/releases/tag/v0.1"
signal_type: "significant_update"
---
# 用 RL 训练 Agent 去训练模型：双层强化学习元学习框架 (RL-Training an Agent That RL-Trains AI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-20
>
> **项目/工具**: ai-trains-ai (Danau5tin)
> **链接**: https://github.com/Danau5tin/ai-trains-ai/releases/tag/v0.1
> **核心定位**: 一个 AI Agent 在 RL 循环中编写训练任务，去训练更小的 AI 模型——双层 RL 循环，全开源，总成本约 $1,275。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：用外层 RL（Tinker + GRPO）训练一个 Agent，让它自动编写内层 RL 训练任务（prime-rl + GRPO），去训练更小的模型。两层 RL 循环嵌套，Agent 的奖励来自它训练出的模型在隐藏评测上的表现。
- **現在值得用嗎**：是——如果你在做模型后训练（post-training）自动化、元学习或 AutoML 方向，这是目前最完整的开源双层 RL 实现。
- **適合場景**：RL 研究者复现元学习 pipeline；需要自动化模型训练流程的团队；对 Tinker / prime-rl / verifiers 技术栈感兴趣的开发者。
- **不適合場景**：生产级 AutoML 产品（这是研究原型）；没有 GPU 资源的个人开发者（需要最多 16 个 GPU pod 并发）。
- **與 Meta-SO / AutoCodeRover 等核心差異**：不是 prompt-based 的代码生成，而是真正的 RL 训练——Agent 通过策略梯度学习如何编写高质量训练任务，而非靠 prompt 工程。

## 是什么 / 解决什么问题

模型后训练（post-training）——包括 SFT、RLHF、GRPO 等——是当前提升小模型能力的关键手段。但设计一个有效的训练任务（环境定义、奖励函数、数据集、超参数）仍然高度依赖人工经验。Meta-SO、AutoCodeRover 等项目尝试用 prompt-based 的 Agent 来自动化这个过程，但它们本质上是"用 LLM 的推理能力做一次性决策"，Agent 本身不会从经验中学习。

ai-trains-ai 走了一条不同的路：**把 Agent 本身也放进 RL 循环**。外层用 Tinker（Thinking Machines 的 RL API）对 Agent（Qwen3.6-35B-A3B）进行 LoRA + GRPO 训练；内层用 prime-rl 在真实 GPU 上训练小模型（Qwen3-0.6B / 1.7B）。Agent 每次尝试编写一个训练任务，提交到 GPU 执行，训练结果在隐藏评测上的得分作为奖励信号回传，驱动外层 RL 更新。

这意味着 Agent 不是"猜一次"——它在 54 步外层训练中逐步学会了：(1) 写出能通过验证的合法任务；(2) 写出能训练出更好模型的任务；(3) 选择更合适的基座模型和超参数。

## 技术架构拆解

### 核心设计决策

- **双层 RL 分离**：外层（训练 Agent）和内层（Agent 训练模型）使用完全不同的训练栈。外层用 Tinker + importance-sampling GRPO；内层用 prime-rl + verifiers GRPO。这种分离避免了单一框架无法同时满足两层需求的问题。
- **真实 GPU 执行**：Agent 编写的训练任务不是在模拟器中评估，而是在 Runpod 的真实 GPU 上执行。这保证了奖励信号的真实性（没有 sim-to-real gap），但也带来了高延迟和高成本。
- **异步 off-policy 训练**：外层使用 `max_steps_off_policy=2` 的异步策略，慢的 episode 不会阻塞整个 batch。在全部 54 步中零 stale discard，解决了 GPU 异构导致的 straggler 问题。
- **奖励函数三要素**：Episode 奖励 = 0.35 × 验证分 + 0.60 × 任务质量 + 0.05 × 训练速度。其中任务质量 = 0.25 × 训练后绝对分数 + 0.75 × 相对于基线的提升。
- **held-out 泛化测试**：6 个任务家族中 5 个用于训练，1 个（triage）完全 held out，用于评估 Agent 学到的技能是否泛化到未见过的任务类型。

### 与前版/竞品的关键差异

| 维度 | Meta-SO / AutoCodeRover 等 | ai-trains-ai |
|------|---------------------------|-------------|
| Agent 学习范式 | Prompt-based（一次性推理） | RL-based（策略梯度持续更新） |
| 评估方式 | 模拟/轻量评测 | 真实 GPU 训练 + 隐藏评测 |
| 反馈循环 | 无（单次决策） | 双层 RL 闭环（奖励回传） |
| 可复现性 | 依赖闭源 API | 全开源（权重、代码、数据） |
| 成本 | 低（仅推理成本） | 高（~$1,275 全部训练周期） |
| 技术栈 | 通用 LLM API | Tinker + prime-rl + verifiers + Runpod |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│  Outer Loop: Tinker (GRPO + LoRA)                           │
│  Agent: Qwen3.6-35B-A3B (LoRA rank 8)                       │
│                                                              │
│  ┌─────────────┐   writes    ┌───────────────────────────┐  │
│  │  Trainer     │────────────▶│  Inner Loop Job            │  │
│  │  Agent       │             │  (env + reward + dataset   │  │
│  │  (episode)   │             │   + hyperparams)           │  │
│  └─────────────┘             └──────────┬────────────────┘  │
│       ▲                                  │                   │
│       │  reward signal                   ▼                   │
│       │                        ┌───────────────────────┐     │
│       │                        │  Runpod GPU Fleet     │     │
│       │                        │  (up to 16 pods)      │     │
│       │                        │  prime-rl (GRPO)      │     │
│       │                        │  trains Qwen3-0.6B/1.7B│    │
│       │                        └──────────┬───────────┘     │
│       │                                   │                 │
│       │          pre/post hidden eval     ▼                 │
│       │                        ┌───────────────────────┐     │
│       │                        │  Reward Computation    │     │
│       │                        │  = 0.35*val +         │     │
│       │                        │    0.60*quality +      │     │
│       │                        │    0.05*speed          │     │
│       │                        └──────────┬───────────┘     │
│       │                                   │                 │
│       └───────────────────────────────────┘                 │
│              (reward → GRPO update)                         │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **RL 后训练自动化研究**：这是目前最完整的开源双层 RL 实现。如果你研究"如何让 Agent 学会训练模型"，这个项目的架构、奖励设计、任务定义都可以直接复用。
- **Tinker / prime-rl 技术栈验证**：项目同时验证了 Tinker（异步 off-policy RL）和 prime-rl（GRPO 训练小模型）的实际效果，是这两个框架的 best-practice 参考。
- **成本敏感的模型训练**：全部 1,750 个训练 job 总成本 ~$1,275，平均每 job $0.13-0.30。对于需要批量训练小模型的团队，这个 cost-per-job 数据有参考价值。
- **泛化能力评估**：held-out task family 的结果（reward 0.399 → 0.545）证明了 Agent 学到的不是 memorization，而是可迁移的"训练技能"。

### 什么场景不值得用

- **生产级 AutoML**：这是研究原型，不是产品。缺少错误恢复、监控告警、多用户隔离等工程能力。
- **无 GPU 资源的个人**：需要最多 16 个 GPU pod 并发运行，个人开发者很难复现完整 pipeline。
- **非 RL 方向的模型优化**：如果你的需求是 SFT 或 prompt engineering，这个项目的复杂度远超必要。
- **实时训练场景**：每个 episode 包含真实的 GPU 训练周期（分钟级），不适合需要快速迭代的场景。

### 迁移成本

从 Meta-SO / AutoCodeRover 等 prompt-based 方案迁移到此方案：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 部署 Tinker + prime-rl 环境 | 1-2 天 | 需要配置 Runpod GPU 和 Nebius CPU 编排 |
| 定义任务家族和奖励函数 | 2-3 天 | 参考项目的 6 个 task family 模板 |
| 编写 Agent workspace sandbox | 1 天 | 文件操作 + job 提交 + 验证探针 |
| 启动外层 RL 训练 | 持续 | 每个 batch ~$15-23，需监控成本 |

总计约 1-2 周搭建环境，之后是持续的 GPU 成本。

## 对你的意义

这个项目与 Ken 的 VLA 研究方向有直接关联：

1. **RL 训练 VLA 的元自动化**：VLA 的 RL 训练（如训练策略网络）同样面临 reward design、超参数搜索、环境定义等问题。双层 RL 的架构思路可以直接迁移——用 Agent 自动设计 VLA 训练任务，而非手动调参。
2. **Tinker 作为 RL 基础设施**：Tinker 的异步 off-policy 策略解决了 straggler 问题，这对大规模 VLA 训练（需要大量 GPU）有直接参考价值。
3. **成本意识**：$1,275 完成 54 步双层 RL 训练，展示了用云 GPU + 开源工具链可以低成本复现前沿研究。这对资源有限的研究团队是重要参考。

**建议**：立即关注。如果你在做 RL 训练 VLA 的方向，这个项目的架构设计（双层 RL 分离、异步 off-policy、奖励函数分解）值得深入研究。可以考虑用类似思路自动化 VLA 训练任务的设计。

## 关键代码/配置片段

### 奖励函数定义（来自 README）

```
Episode Reward = 0.35 × Validation + 0.60 × Job Quality + 0.05 × Train Speed

Job Quality = 0.25 × post_training_score + 0.75 × uplift_over_baseline

Validation = 1.0 (first-try valid) decaying per retry; 0 if never valid
```

### 外层训练配置（来自 release notes）

```
Outer Loop: Tinker (importance-sampling GRPO)
  Model: Qwen3.6-35B-A3B, LoRA rank 8, lr 4e-5
  Group size: 8
  Max off-policy steps: 2 (async)
  Episodes per batch: 40 real inner jobs
  GPU pods: up to 16 concurrent (Runpod)

Inner Loop: prime-rl (GRPO)
  Models: Qwen3-0.6B / Qwen3-1.7B
  Verifier: verifiers (env + rubric)
  Scoring: vLLM pre/post on hidden evals
```

### 成本明细（来自 README）

```
单个内层训练 job:  ~$0.13–0.30（含训练 + 预/后评测）
单个外层 episode:  ~$0.15–0.25（Agent tokens + Tinker）
单个外层 batch:    ~$15–23（40 个 GPU job + Agent tokens）
完整训练弧 (54步):  ~$1,275 全部（~$810 Runpod + ~$465 Tinker）
```

### 模型权重加载

```python
# LoRA adapter (rank 8, ~560MB) from step-34 checkpoint
# HF: Danau5tin/ai-trains-ai-trainer
# Base: Qwen/Qwen3.6-35B-A3B
# License: Apache-2.0

from peft import PeftModel
# 或 vLLM LoRA serving
```

---
[← Back to Deep Dives](./README.md)
