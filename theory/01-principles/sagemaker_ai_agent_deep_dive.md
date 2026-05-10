---
auto_generated: true
generated_at: "2026-05-10T06:47:38Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/agent-guided-workflows-to-accelerate-model-customization-in-amazon-sagemaker-ai/"
signal_type: "significant_update"
---
# SageMaker AI Agent 引导式模型定制工作流 (Agent-Guided Model Customization Workflows in Amazon SageMaker AI)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-10
>
> **项目/工具**: Amazon SageMaker AI — Agent Skills for Model Customization
> **链接**: https://aws.amazon.com/blogs/machine-learning/agent-guided-workflows-to-accelerate-model-customization-in-amazon-sagemaker-ai/
> **核心定位**: 用自然语言描述用例，AI coding agent 自动完成从数据准备、技术选型、SFT/DPO/RLVR 训练、评估到部署的全流程，将原本需要数月的模型定制周期压缩到数天。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AWS 在 SageMaker AI 中推出了 9 个模块化 Agent Skills，让 coding agent（Kiro / Claude Code / Gemini / Codex）通过自然语言对话引导你完成大模型微调全流程。
- **現在值得用嗎**：是 — 如果你已经在 AWS 生态中做模型定制，这是目前最完整的 agentic fine-tuning 方案。
- **適合場景**：AWS 上的 SFT/DPO/RLVR 微调；需要降低微调技术门槛的团队；希望将最佳实践编码为可复用 Skills 的组织。
- **不適合場景**：非 AWS 环境（Skills 深度绑定 SageMaker API / Bedrock / S3）；需要非 SFT/DPO/RLVR 的训练范式（如 pre-training）。
- **與傳統 SageMaker 核心差異**：从"手动写 notebook + 调 API"变为"自然语言描述 → agent 生成可运行 notebook → 一键执行"，且 Skills 遵循开放的 Agent Skills 格式，可自定义。

## 是什么 / 解决什么问题

模型微调（fine-tuning）长期以来是一个高门槛工作。你需要掌握 SFT、DPO、RLVR 三种不同的训练范式，理解各模型家族（Llama、Qwen、Nova 等）的特定数据格式，设计评估指标，管理实验周期——整个过程通常需要数月。

SageMaker AI 的 Agent Skills 方案将这条链路抽象为 **9 个模块化 Skills**，覆盖从用例定义到部署的完整生命周期。开发者只需用自然语言描述需求（例如"我想微调一个模型做临床推理"），agent 就会自动规划工作流、推荐技术路线、生成训练 notebook、执行评估、并部署模型。

核心创新不在于"用 agent 写代码"——Copilot、Cursor 早已做到。核心创新在于 **Skills 将 AWS ML 最佳实践编码为可复用的指令集**，让通用 coding agent 获得领域专家级别的能力，同时保持代码完全可编辑、可版本控制。

## 技术架构拆解

### 核心设计决策

1. **Skills 与 Agent 解耦**：Skills 遵循开放的 [Agent Skills 格式](https://agentskills.io/home)，不绑定特定 coding agent。Kiro 是默认选项，但 Claude Code、OpenCode、Gemini、Codex 等 ACP（Agent Communication Protocol）兼容 agent 均可使用同一套 Skills。
2. **9 个 Skills 覆盖全生命周期**：从用例定义到部署，每个阶段一个 Skill，避免单个 prompt 过长导致的指令丢失。
3. **Serverless 优先**：微调训练使用 SageMaker AI Serverless 模式，无需管理实例类型和容量规划。
4. **MCP Server 集成**：通过 AWS 提供的 MCP servers 调用 SageMaker API、访问 S3 数据源、交互模型注册表——这是 MCP 在 ML 工作流中的实际落地案例。
5. **可自定义**：Skills 以 Markdown 文件存储在 `~/.kiro/skills` 目录，可版本控制、可团队共享、可扩展。

### 与前版/竞品的关键差异

| 维度 | 传统 SageMaker 微调 | SageMaker AI Agent Skills | 竞品 (如 Hugging Face AutoTrain) |
|------|---------------------|--------------------------|--------------------------------|
| 交互方式 | 手动写代码 / notebook | 自然语言对话 | 低代码 UI / CLI |
| 技术选型 | 开发者自行决定 | Agent 根据数据集自动推荐 SFT/DPO/RLVR | 手动选择或自动推荐（有限） |
| 数据格式转换 | 手动编写转换脚本 | Dataset Transformation Skill 自动完成 | 内置部分格式支持 |
| 评估 | 手动设计评估 pipeline | Model Evaluation Skill 自动生成 LLM-as-Judge 评估 | 有限内置评估 |
| 部署 | 手动配置 endpoint | Model Deployment Skill 自动选择 SageMaker / Bedrock | 通常只支持单一部署路径 |
| 可定制性 | 完全自由但需从零开始 | Skills 可自定义 + 预构建最佳实践 | 通常封闭，难以扩展 |
| 环境绑定 | AWS | AWS（深度绑定） | 多云 / 本地 |

### 架构 / 信息流图

```
用户自然语言输入
       │
       ▼
┌─────────────────────────────────────────────┐
│         Coding Agent (Kiro / Claude Code)    │
│  ┌───────────────────────────────────────┐   │
│  │          Planning Skill               │   │
│  │  识别需求 → 激活相关 Skills            │   │
│  │  生成多步工作流 → 用户确认/修改         │   │
│  └───────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
       │ 按阶段激活
       ▼
┌─────────────────────────────────────────────┐
│  Skills Pipeline (9 个模块)                  │
│                                             │
│  [Use Case Spec] → [Planning]               │
│       ↓                                      │
│  [Fine-tuning Setup] → [Dataset Eval]        │
│       ↓                                      │
│  [Dataset Transform] → [Fine-tuning]         │
│       ↓                                      │
│  [Model Eval] → [Model Deployment]           │
│                                             │
│  每个 Skill 生成可运行的 Jupyter Notebook     │
└─────────────────────────────────────────────┘
       │ 通过 MCP Server 调用
       ▼
┌─────────────────────────────────────────────┐
│  AWS 服务层                                  │
│  SageMaker AI Serverless Training           │
│  S3 (数据存储)                                │
│  Bedrock (模型部署选项)                        │
│  MLflow (实验追踪)                            │
│  Model Registry (模型版本管理)                 │
└─────────────────────────────────────────────┘
```

### 9 个 Skills 详解

| Skill 名称 | 阶段 | 职责 |
|-----------|------|------|
| Use Case Specification | Configuration | 结构化发现：定义业务问题、用户、成功标准 |
| Planning | Discovery | 生成动态多步定制计划 |
| Fine-tuning Setup | Configuration, Training | 从 SageMaker AI Hub 选择基座模型，推荐技术（SFT/DPO/RLVR） |
| Dataset Evaluation | Evaluation, Training | 训练前验证数据集格式和 schema |
| Dataset Transformation | Data Engineering | 在 OpenAI chat / SageMaker / Hugging Face / Amazon Nova 格式间转换 |
| Fine-tuning | Training | 生成 SageMaker AI Serverless 微调训练 notebook |
| Model Evaluation | Evaluation | 配置 LLM-as-Judge 评估，支持内置和自定义指标 |
| Model Deployment | Deployment | 确定部署路径（SageMaker endpoint 或 Bedrock），生成部署代码 |

### 支持的微调技术

| 技术 | 描述 | 最佳场景 |
|------|------|---------|
| SFT (Supervised Fine-Tuning) | 基于输入/输出对训练 | 指令跟随、格式合规、领域适配响应 |
| DPO (Direct Preference Optimization) | 基于偏好/拒绝输出对训练 | 对齐语气、风格、主观偏好 |
| RLVR (RL with Verifiable Rewards) | 基于可编码验证的 reward function 训练 | 正确性可程序化验证的任务（如数学、代码） |

## 实用评估

### 什么场景值得用

1. **AWS 上的中小团队模型定制**：团队有 ML 基础但缺乏微调专家经验。Agent Skills 将最佳实践编码化，降低了 SFT/DPO/RLVR 的技术门槛。官方声称"原本需要数月的专业 ML 工作现在可以在数天内完成"。

2. **需要标准化微调流程的组织**：Skills 以 Markdown 文件存储，可版本控制、可团队共享。你可以扩展 model-evaluation skill 加入领域特定指标，或为自定义部署目标编写新 skill。这解决了"通用 coding assistant 难以复现组织最佳实践"的痛点。

3. **多 agent 工具并存的团队**：ACP 协议支持意味着团队可以自由选择 Kiro、Claude Code、Gemini 或 Codex，而不影响 Skills 的复用。这在 agent 工具快速演进的当下是一个重要优势。

4. **快速验证微调可行性**：Serverless 模式 + agent 自动生成 notebook 意味着你可以用极低的启动成本验证"我的数据是否适合微调"这个关键问题。

### 什么场景不值得用

1. **非 AWS 环境**：Skills 深度绑定 SageMaker API、S3、Bedrock。如果你的基础设施在 GCP 或 Azure，或者使用本地 GPU 集群，这套方案无法直接使用。

2. **Pre-training 或大规模分布式训练**：当前 Skills 聚焦于 fine-tuning（SFT/DPO/RLVR），不支持从零 pre-training 或需要多节点分布式训练的大模型（如 70B+ 参数）。

3. **需要非标准训练范式的场景**：如果你的工作流涉及 LoRA/QLoRA 等参数高效微调、或者需要自定义 training loop，当前 Skills 可能不够灵活——虽然生成的代码可编辑，但 Skill 本身不直接支持这些选项。

4. **对 token 成本敏感的场景**：虽然 AWS 声称 Skills 能降低 token 用量（相比通用 coding assistant），但 agent 交互本身仍会产生额外的 LLM 调用成本。对于简单的微调任务，直接写 script 可能更经济。

### 迁移成本

从传统 SageMaker 手工微调迁移到 Agent Skills：

- **基础设施**：无需变更。需要 SageMaker AI Domain、S3 bucket、IAM role（与现有要求一致）。
- **环境准备**：SageMaker AI Distribution 镜像版本 ≥ 4.1；JupyterLab space。
- **学习成本**：低。核心交互是自然语言描述用例。主要学习点是理解 9 个 Skills 的职责边界和可自定义方式。
- **代码迁移**：无需迁移。现有 notebook 和 script 可继续使用；Agent Skills 是增量选项而非替代。

从 Hugging Face AutoTrain 或其他低代码微调工具迁移：
- **数据迁移**：需要先将数据移至 S3。Dataset Transformation Skill 可帮助格式转换。
- **流程迁移**：中等。需要重新用自然语言描述工作流，但 Skills 会自动生成等效的 notebook。

## 对你的意义

这个变化对 Ken 的两条线都有参考价值：

**AI 应用开发线（Agent + UI）**：
- **ACP 协议的实战落地**：SageMaker AI 选择 ACP 作为 agent 互操作协议，支持 Kiro、Claude Code、Gemini、Codex 等多 agent。这是 ACP 在 enterprise 场景的重要背书，值得在 Agent-Playbook 中记录。
- **Skills 格式的工程化**：Agent Skills 开放格式（agentskills.io）将领域知识编码为可复用指令集——这是一种比 prompt engineering 更结构化的知识封装方式。如果 Ken 在做 agent builder 或 workflow 工具，这个模式值得借鉴。
- **MCP 在 ML 工作流中的落地**：通过 MCP server 调用 SageMaker API、S3、Model Registry——这是 MCP 从"工具集成"走向"工作流编排"的具体案例，支持假设 A-001。

**VLA 研究线**：
- 虽然这是 NLP 微调方案而非 VLA 训练框架，但其"agent 引导式工作流"的理念对具身智能训练 pipeline 有启发——未来 VLA 训练是否也可以抽象为模块化 Skills，让研究者用自然语言描述训练目标？

**建议**：如果 Ken 的团队有 AWS 上的模型定制需求，建议立即试用。如果没有，至少将 ACP + Skills 模式记录到 Agent-Playbook 中——这是 agent 工程化的一个重要方向。

## 关键代码/配置片段

### 配置 Claude Code 使用 Bedrock

```json
~/.claude/settings.json:
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1"
  }
}
```

### Skills 自定义目录结构

```
~/.kiro/skills/
├── use-case-specification.md
├── planning.md
├── finetuning-setup.md
├── dataset-evaluation.md
├── dataset-transformation.md
├── finetuning.md
├── model-evaluation.md
└── model-deployment.md
```

Skills 以 Markdown 文件存储，可版本控制、可共享。你可以修改现有 skill 或编写新 skill 以匹配团队标准。

### ACP 兼容 agent 列表

```
Claude        → npm install -g @zed-industries/claude-agent-acp
OpenCode      → opencode CLI >= 1.0.0
Gemini        → gemini CLI >= 0.34.0
Codex         → codex-acp
```

### 支持的模型家族（Serverless 微调）

Amazon Nova、GPT-OSS、Llama、Qwen、DeepSeek。本文示例使用 Qwen3-0.6B，因其训练和部署成本低且足以胜任医疗推理等特定领域任务。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | SageMaker AI 通过 AWS 提供的 MCP servers 调用 SageMaker API、S3、Model Registry，是 MCP 在 ML 工作流中的企业级落地案例 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | ACP 协议支持 Kiro、Claude Code、Gemini、Codex 四种 agent 共享同一套 Skills，证明多 agent 互操作正在成为工程现实 |

---
[← Back to Deep Dives](./README.md)
