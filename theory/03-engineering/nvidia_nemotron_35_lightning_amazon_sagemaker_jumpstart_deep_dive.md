---
auto_generated: true
generated_at: "2026-08-22T08:03:47Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/nvidia-nemotron-3-5-lightning-now-available-in-amazon-sagemaker-jumpstart/"
signal_type: "significant_update"
---
# NVIDIA Nemotron 3.5 Lightning 登陆 SageMaker JumpStart（NVIDIA Nemotron 3.5 Lightning on Amazon SageMaker JumpStart）

> 🔍 本文由 Moltbot 自动生成 | 2026-08-22
>
> **项目/工具**: NVIDIA Nemotron 3.5 Lightning + NeMo Switchyard
> **链接**: [AWS Blog — Nemotron 3.5 Lightning on SageMaker JumpStart](https://aws.amazon.com/blogs/machine-learning/nvidia-nemotron-3-5-lightning-now-available-in-amazon-sagemaker-jumpstart/)
> **核心定位**: 30B MoE（3B active）开源模型，专为高并发 agentic 工作负载优化；配合 NeMo Switchyard 路由库，实现 system-of-models 架构下的智能调度

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Nemotron 3.5 Lightning 是 NVIDIA 推出的 30B MoE 开源模型（每 token 仅激活 3B 参数），专为 always-on agent 的高频、低延迟任务设计；同时发布的 NeMo Switchyard 是一个开源模型路由库，可将 agent 工作流中的每个步骤自动分发到最合适的模型。
- **现在值得用吗**: 看场景。如果你已经在用 AWS SageMaker 部署 agent 工作负载，且需要降低高频步骤的推理成本，值得立即试用。
- **适合场景**: 高并发 agentic 工作负载（工具调用、字段提取、告警分类、代码审查）；需要本地/边缘部署的场景（RTX PC、DGX Station、Jetson）；需要 post-train 自定义领域能力的团队。
- **不适合场景**: 需要复杂多步推理/编排的规划层任务（应该用 Nemotron 3 Ultra 等 frontier 模型）；不需要自定义且对精度要求极低的简单问答（7B 以下模型更划算）。
- **与前版/竞品核心差异**: 相比 Nemotron 3 Nano 更小更快；相比同级别密集模型（如 Llama 3.1 8B），MoE 架构在保持 81.94 MMLU-Pro 精度的同时将激活参数降至 3B，吞吐量提升 4x。

## 是什么 / 解决什么问题

现代 AI agent 系统正在从"单一模型包办一切"转向 **system-of-models（模型系统）** 架构。一个 always-on agent 的工作流包含多种类型的步骤：规划编排需要 frontier 级推理能力，而告警分类、字段提取、策略校验等高频步骤往往只需要专门化的小模型。把所有步骤都推给一个 frontier 模型，既浪费成本又增加延迟。

Nemotron 3.5 Lightning 正是为这个"高容量、低复杂度"的步骤层级而生。它从 NVIDIA frontier 模型 Nemotron 3 Ultra 蒸馏而来，采用混合 MoE 架构——30B 总参数中每次前向传递仅激活 3B，配合 DFlash 推测解码和 1M token 上下文窗口，在保持 frontier 级精度的同时实现 4x 吞吐量提升和 30% 更快的任务完成速度。

同日发布的 **NeMo Switchyard** 是这套架构的另一块拼图——一个开源模型路由库，自动将 agent 工作流中的每个请求分发到最合适的模型（开放模型、专有模型或 NVIDIA 模型），无需开发者重写应用。LangChain 的基准测试显示，使用 Switchyard 后 145 个多轮 Deep Agents 任务成本降低 74%，仅 7% 的请求需要路由到 frontier 模型，精度损失仅 6%。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|---------|------|
| **混合 MoE 架构（30B 总 / 3B 激活）** | 降低每 token 计算量，维持高吞吐；单 GPU 可运行，无需 frontier 级基础设施 |
| **从 Nemotron 3 Ultra 蒸馏** | 继承 frontier 模型的推理能力，同时大幅缩小模型规模 |
| **1M token 上下文窗口** | Agent 长会话中携带累积状态，无需反复 re-grounding |
| **DFlash 推测解码** | 降低 per-token 延迟，加速生成 |
| **NVFP4 + BF16 双精度** | NVFP4 量化后精度几乎无损（见下方 benchmark 对比），适合低成本部署 |
| **完全开源 + 可定制** | 支持 post-train 自定义领域工具/工作流/策略，权重归用户所有 |
| **发布 RL 数据集** | Nemotron-RL-Agentic-Terminal-Pivot 数据集公开，提升训练可追溯性 |

### 与前版/竞品的关键差异

| 维度 | Nemotron 3 Nano | Nemotron 3.5 Lightning | Llama 3.1 8B（参考） |
|------|-----------------|------------------------|----------------------|
| 架构 | 密集 | 混合 MoE | 密集 |
| 总参数 | ~1B（估计） | 30B | 8B |
| 激活参数 | ~1B | 3B | 8B |
| 上下文窗口 | 未知 | 1M tokens | 128K tokens |
| 蒸馏来源 | — | Nemotron 3 Ultra | — |
| 单 GPU 部署 | ✅ | ✅ | ✅ |
| MMLU-Pro | 未公布 | 81.94 (BF16) | ~75（社区报告） |
| SWE-bench Verified | 未公布 | 51.56 (BF16) | ~30（社区报告） |
| 吞吐量（agentic） | 基线 | 4x 提升 | 基线 |

### 架构 / 信息流图

```
┌─────────────────────────────────────────────────────────┐
│                   Agent Orchestrator                     │
│              (Frontier Model: Ultra / GPT-5.6)           │
│         规划多步工作流、编排子 agent、复杂推理              │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  NeMo Switchyard      │  ← 开源路由库
            │  (智能分发每个步骤)     │
            └──────┬───────────────┘
                   │
          ┌────────┼────────┐
          ▼        ▼        ▼
     ┌────────┐ ┌──────┐ ┌──────┐
     │Lightning│ │Ultra │ │外部  │
     │(3B act) │ │(规划)│ │模型  │
     └────────┘ └──────┘ └──────┘
     高频专门     复杂推理   特定领域
     步骤执行     编排调度   任务
          │
          ▼
     ┌─────────────────────────────────┐
     │  部署目标                         │
     │  RTX PC / DGX Station / Jetson  │
     │  / SageMaker Endpoint / Cloud   │
     └─────────────────────────────────┘
```

### Benchmark 精度对比（BF16 vs NVFP4）

NVFP4 量化后的精度损失极小，大部分任务几乎持平：

| Benchmark | BF16 | NVFP4 | 变化 |
|-----------|------|-------|------|
| MMLU Pro | 81.94 | 81.62 | -0.32 |
| GPQA Diamond | 75.44 | 75.57 | +0.13 |
| SWE-bench Verified | 51.56 | 52.80 | +1.24 |
| PinchBench | 85.37 | 83.43 | -1.94 |
| IFBench | 71.88 | 72.88 | +1.00 |
| AA-LCR | 52.00 | 49.19 | -2.81 |

> 数据来源：NVIDIA 官方评测（使用 NeMo Gym 评测配方）。NVFP4 在 SWE-bench 和 IFBench 上甚至有小幅提升，可能来自量化正则化效应。

## 实用评估

### 什么场景值得用

- **高并发 agentic 工具调用**: Lightning 在 PinchBench（agentic 工具使用基准）上达到 85.37 分，专门针对工具调用场景优化。如果你的 agent 每天执行数万次的 API 调用、字段提取、表单处理，Lightning 可以在单 GPU 上以低成本处理。
- **需要本地/边缘部署**: 3B 激活参数意味着可以在 RTX PC、DGX Station 甚至 Jetson 上运行。对于需要数据不出本地的高安全场景（金融、医疗），这是一个关键优势。
- **需要 post-train 自定义**: 模型完全开源，可用 NeMo 在自有领域数据上 post-train。CrowdStrike（网络安全）、Harvey（法律服务）、CodeRabbit（代码审查）都已基于 Lightning 做了领域定制。
- **长会话 agent**: 1M token 上下文窗口允许 agent 携带完整的对话历史和状态，无需反复 re-grounding，适合客服、个人助理等长生命周期场景。

### 什么场景不值得用

- **复杂多步推理/编排**: Lightning 的定位是"高频专门步骤执行器"，不是 planner。复杂的多阶段工作流规划、子 agent 编排仍需要 Nemotron 3 Ultra 或 GPT-5.6 等 frontier 模型。
- **简单问答/摘要**: 如果只是做基本的 QA 或文本摘要，7B 以下的密集模型（如 Llama 3.2 8B）可能更简单直接，不需要 MoE 的复杂度。
- **AA-LCR 类任务**: 该 benchmark 上 NVFP4 精度下降 2.81 个百分点，如果你的核心场景涉及此类任务，需要先用 BF16 精度评估。

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| 从单一 frontier 模型拆分 → Lightning + Frontier | 中等 | 需要重新设计 agent 工作流，区分哪些步骤路由到 Lightning，哪些保留给 frontier |
| 从其他开源模型（如 Llama 3.1）迁移 | 低-中 | 模型格式兼容 Hugging Face，部署流程类似；但需要重新评估精度和性能 |
| 在 SageMaker JumpStart 上首次部署 | 低 | 一键部署，无需配置 serving 框架；选择实例类型（ml.g6e.24xlarge 等）即可 |
| Post-train 自定义领域能力 | 中 | 需要领域数据集 + NeMo 训练 pipeline；NVIDIA 提供了 RL 数据集 Nemotron-RL-Agentic-Terminal-Pivot |

## 对你的意义

这个发布对 AI Agent 工程生态有两个值得关注的信号：

1. **System-of-Models 正在从概念走向工程实践**。NVIDIA 不仅发布了一个专门化的小模型，还同步发布了 NeMo Switchyard 路由库，并与 LangChain、LiteLLM、Kong 等主流框架集成。这意味着"智能路由"不再是每个团队自己造轮子的领域——基础设施层正在标准化。这与你关注的 Agent UI / Agent 框架方向直接相关：未来的 agent builder 很可能内置模型路由层。

2. **MoE 架构正在成为 agent 专用模型的主流选择**。3B 激活参数 + 单 GPU 部署 + 4x 吞吐，这个组合在 agentic 工作负载上形成了一个甜点区。如果你的项目中有高频 agent 调用场景（如代码审查、文档处理、告警分类），Lightning 提供了一个可自部署、可定制的选项，而不是依赖 API 调用的封闭模型。

**建议**: 如果你在使用 AWS SageMaker 或有本地 GPU 资源，值得用 PinchBench 或你自己的 agentic 任务集做一个快速 benchmark。关注 NeMo Switchyard 与 LangChain/LiteLLM 的集成进展——这可能是 agent 路由层的标准方案。

## 关键代码/配置片段

### SageMaker JumpStart 一键部署（Python SDK）

```python
from sagemaker.jumpstart.model import JumpStartModel

# NVFP4 量化版本（推荐，精度几乎无损）
model_id = "huggingface-reasoning-nemotron-3-5-lightning-30b-a3b-nvfp4"
# BF16 全精度版本
# model_id = "huggingface-reasoning-nemotron-3-5-lightning-30b-a3b-bf16"

model_version = "*"
model = JumpStartModel(model_id=model_id, model_version=model_version)
predictor = model.deploy()

# 推理完成后删除 endpoint 避免持续计费
predictor.delete_endpoint()
```

### 可用部署目标

模型已在以下平台可用：
- **Hugging Face**: `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4`
- **OpenRouter**: `nvidia/nemotron-3.5-lightning:free`
- **NVIDIA NIM**: build.nvidia.com 上的 microservice
- **本地硬件**: RTX PC、DGX Spark、DGX Station、Jetson
- **云**: SageMaker JumpStart + NVIDIA Cloud Partners

### NeMo Switchyard 路由库

> TODO: Switchyard 的具体 API 和使用示例待官方文档完善后补充。
> GitHub: https://github.com/NVIDIA-NeMo/Switchyard

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | NeMo Switchyard 与 LangChain、LiteLLM、Kong 等主流框架集成，提供标准化的模型路由能力，标志着 system-of-models 架构从概念走向工程落地 |

---
[← Back to Deep Dives](./README.md)
