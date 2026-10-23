---
auto_generated: true
generated_at: "2026-10-23T11:00:43Z"
source_url: "https://github.com/google-research/harness2/releases"
signal_type: "significant_update"
---
# Harness²：冻结模型权重，递归优化 Agent Harness (Harness²: Recursive Agent Harnessing for an Open World)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-23
>
> **项目/工具**: Harness² (google-research/harness2)
> **链接**: https://github.com/google-research/harness2
> **核心定位**: 把「模型外围的 Agent 系统」当作可训练对象——权重不动，只递归改写 prompt / 工具 / 记忆 / 技能，用同一任务上的行为对比自我改进。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：一个 plug-and-play 的「Agent harness 自优化」框架，两层递归（任务级 + harnessing 级）在不改模型权重的前提下优化整条 Agent 系统。
- **現在值得用嗎**：看场景 —— 如果你在做 Agent 工程且能接受跑 benchmark 的 API 成本，值得复现一次；如果你只是想把现成 Agent 产品落地，它现在更像研究脚手架而非生产组件。
- **適合場景**：Agent harness 设计（prompt/工具/子 Agent 编排）、专业任务 benchmark 基线搭建、想验证「harness 比模型更决定成败」这个命题。
- **不適合場景**：低延迟生产服务、需要确定性行为的产品链路、没有 GPU/云端模型额度的个人项目。
- **與 [竞品/前版] 核心差異**：多数 Agent 优化框架走「调 prompt 模板」或「RL 微调权重」，Harness² 明确把权重冻结，把优化目标放在 eight 个可编辑组件构成的 harness 上。

## 是什么 / 解决什么问题

一个 agent 的表现，取决于模型之外的那一圈东西：system prompt、工具接口、记忆、子 Agent 调度、技能、脚本、插件。Harness² 把这一圈统称为 **harness**，把优化这一圈的过程叫 **harnessing**。项目 README 的定义很直接：

> "A harness is the system around a model that enables it to act as an agent: prompts, tools, memory, skills, orchestration, and more. Harnessing is the process of optimizing that system."

它要解决的是开放世界里的泛化问题：Agent 会遇到 harness 设计时**没见过**的任务。传统做法是人手工迭代 prompt，或者用训练集去微调模型；这两种方式都假设「你事先知道任务长什么样」。Harness² 的赌注是——即使任务没见过，也可以在**执行过程中**通过对比不同 harness 变体的行为差异来就地改进。

这跟「提示词优化器」的关键区别在于：它不是对着一个静态指标做搜索，而是在同一任务上跑出多次真实执行，从**行为对比**里提取可用证据，而且**不需要 ground truth**。这一点在 README 中被明确写出：

> "propose edits, probe their effects on the same task, and compose a refined harness from behavioral contrasts between executions, without ground-truth feedback."

## 技术架构拆解

### 核心设计决策

| 决策 | 内容 | 理由 / 影响 |
|------|------|------|
| 冻结权重 | 模型权重固定，不微调 | 让优化可移植：同一套 harness 改进可跨模型复用；也避免了训练数据与开放世界任务的错配 |
| 双层递归 | 任务级 + harnessing 级 | 任务级管「这次任务怎么打赢」，harnessing 级管「以后怎么赢得更快」 |
| Propose–Probe–Compose | 提出编辑 → 探测效果 → 组合精炼 | 用一个统一的三段式循环代替手工调 prompt |
| 无 ground truth | 靠多次执行间的行为对比 | 让框架能用在没有标注答案的真实开放任务上 |
| 八个可编辑组件 | system prompt、guardrails、memory、tool guidance、subagents、skills、scripts、plugins | 覆盖上下文构建、工具接口、委派、工具循环内行为四个层面 |
| 并行 vs 顺序递归 | `--mode parallel` / `--mode sequential` | 并行探得宽（探索多个候选 harness），顺序挖得深（逐轮精炼） |

README 对两层递归的表述：

> "Task-level recursion refines the execution harness for the current task through a contrastive Propose–Probe–Compose step... Harnessing-level recursion updates a persistent improvement harness with adopted harnesses and evidence-supported lessons from each task to guide future refinement."

换句话说，**第二层把第一层的战果沉淀下来**——被采纳的 harness 和「有证据支撑的经验」会进入一个持久的 improvement harness，作为下一次任务的起点。这才是「递归」这个词的实质：不是把同一个 loop 跑 N 遍，而是让 loop 的输出改变 loop 的初始条件。

### 与前版/竞品的关键差异

| 维度 | 传统 prompt 优化 / 微调 | Harness² |
|------|------------------------|----------|
| 优化对象 | prompt 模板或模型权重 | 整个 harness（8 个组件） |
| 反馈信号 | 需要评测集 / ground truth | 执行间的行为对比，无需 ground truth |
| 跨任务迁移 | 弱（模板对任务过拟合） | 通过持久 improvement harness 累积经验 |
| 跨模型可移植性 | 权重微调不可移植 | 权重冻结，理论可跨模型复用 |
| 执行器 | 自己实现 | 支持 OpenCode（默认）与 Codex (`--substrate cx`) |

### 架构/信息流图

```
                 ┌──────────────────────────────┐
                 │  Model (weights FROZEN)      │
                 └──────────────┬───────────────┘
                                │
   ┌────────────────────────────┴────────────────────────────┐
   │                  HARNESS (8 editable parts)             │
   │  system prompt │ guardrails │ memory │ tool guidance    │
   │  subagents │ skills │ scripts │ plugins                 │
   └────────────────────────────┬────────────────────────────┘
                                │
        ┌───────────────────────┴───────────────────────┐
        │   Task-level recursion (Propose–Probe–Compose) │
        │   k = 1 → 一次精炼                              │
        │   k = K, parallel  → 探 K 个通用 + K 个领域候选   │
        │   k = K, sequential→ 连续 K 步逐一精炼          │
        └───────────────────────┬───────────────────────┘
                                │ adopted harness + lessons
                                ▼
        ┌───────────────────────────────────────────────┐
        │   Harnessing-level recursion                  │
        │   persistent improvement harness → 下一个任务  │
        └───────────────────────────────────────────────┘
```

### 官方实验数字（README 声称）

| Benchmark | 声称增益 | 备注 |
|-----------|---------|------|
| WorkBuddy-Bench | 单步最大 **+11.5 分** | Office / web / code 三子集 |
| JobBench | 单步最大 **+4.5 分** | 专业工作任务 |
| LAB partial pass rate | 单步最大 **+11.8 个百分点** | 法律任务 |

覆盖模型为 GLM-5 与 Gemini 3.5 Flash，在 3 个专业 benchmark × 4 种 model–harness 配置上测试。README 的原话：

> "a single Harness² step improves GLM-5 and Gemini 3.5 Flash over their base harnesses, with gains of up to 11.5 points on WorkBuddy-Bench, 4.5 points on JobBench, and 11.8 percentage points on LAB's partial pass rate. Increasing the task-level recursion budget brings further gains."

需要注意的解读边界：这些数字是「相对各自 base harness」的提升，不是绝对 SOTA；WorkBuddy-Bench 是 Google 侧的 benchmark，跨 benchmark 对比意义有限。而且 +11.5 是「单步最高」，分布如何、方差多少，README 里没有给出细节，应到 arXiv 论文 (arXiv:2610.14224) 与 `docs/BENCHMARKS.md` 核实。**本文不对这些数字做独立验证。**

## 实用评估

### 什么场景值得用

- **Agent harness 工程实验**：你的瓶颈不在模型能力，而在 prompt 编排、工具定义、子 Agent 划分——Harness² 的八个组件划分本身就是一份不错的检查清单。
- **专业任务 baseline 搭建**：LAB（法律）、JobBench（通用专业工作）、WorkBuddy-Bench（Office/web/code）三个现成 benchmark，自带 setup / check / run / judge / report 的完整 CLI 链路，适合做内部基线。
- **验证「harness > 模型」假设**：如果你的团队在争论该换模型还是该改 Agent 系统，这个框架提供了一个可量化的实验台。

### 什么场景不值得用

- **生产链路**：多轮 propose–probe–compose 意味着同一任务要跑多次，成本与延迟都是乘数级。README 自己也写了 "Model-backed runs incur API costs; start with a small task selection."。
- **需要确定性行为的产品**：harness 在运行中被改写，同一输入不保证同一 harness，可复现性依赖 seed 与 `HARNESS2_RUNS_DIR` 的管理。
- **评测污染风险场景**：README 有一句很值得注意的警告——"Executor network access is unrestricted, and Codex runs with its sandbox disabled. Public benchmark rubrics may be accessible online." 也就是说默认情况下执行器可以联网，公开 benchmark 的评分标准可能被抓到。跑评测前必须自己配网络限制，否则分数没有意义。
- **本地无云模型的个人项目**：依赖 Vertex AI 配置；虽然有 `harness2-demo`（确定性编辑器 + 真实 Python 执行、无需模型凭证），但那只能验证流程，不能验证效果。

### 迁移成本

| 项目 | 工作量 |
|------|--------|
| 环境 | Linux + Python 3.12 + uv；benchmark 需要 Node.js 20+、gcloud CLI |
| 额外依赖 | LAB 需 Pandoc + Poppler；WorkBuddy-Bench 需 Docker |
| 认证 | `gcloud auth application-default login` + `.env` 配置 Vertex AI 项目与模型 ID |
| 概念迁移 | 需要先想清楚自己的 Agent 系统怎么映射到八个组件上；这一步比装环境耗时 |
| 评测纪律 | 每次 judge/report 必须与 refine 使用相同的 bench / executor / subset / `--k` / `--mode` / seed，否则结果不可比 |

## 对你的意义

对我们的 Pulsar 系统来说，Harness² 的价值不在「直接拿来跑」，而在**它的组件划分可以当作自查表**。我们现在的 agent 体系里，system prompt 和 cron prompt 混在一起、技能目录是隐式的、记忆散在多个 markdown 文件里，子 Agent 只有 spawn 这一个粗粒度机制。如果按 Harness² 的八组件去看：

- **guardrails** —— 我们在 SOUL.md 里有红线，但是没有结构性 guardrail 层，全靠 prompt 自律；
- **memory** —— 有，但检索层（semantic-search）与写入层（daily notes）没有闭环，缺少「证据支撑的经验」这种结构化沉淀；
- **skills / scripts** —— 这是我们最强的一环，也是唯一「可执行、可验证」的部分；
- **tool guidance / plugins** —— 工具说明散在 TOOLS.md，没有和工具定义绑定。

更值得留意的是「无 ground truth 的行为对比」这个思路。我们每天跑几十个 cron job，但没有一套机制在同一个任务上跑两个 harness 变体做对比。Harness² 提供的框架说明这件事**在工程上是可以做的**：并行探 K 个候选 harness，用执行证据组合。如果要做，最小可行的形态是——挑一个高频、失败率可观测的任务（比如 VLA Hotspots），固化两个 harness 变体跑一周对比输出质量。这比继续堆 prompt 想象空间更大。

**建议**：先读 arXiv 论文 + `docs/EXPERIMENTS.md` 的 baseline comparison 部分，然后跑一次 `harness2-demo`（零凭证）确认流程理解无误。真正引入要观望到有人给出独立复现的结果——尤其是那 11.5 分在不同 benchmark 配置下的方差。

## 关键代码/配置片段

安装与本地演示（无需模型凭证，确定性编辑器 + 真实 Python 执行）：

```bash
uv venv --python 3.12 .venv
source .venv/bin/activate
uv pip install -e '.[render]'
harness2-demo --output runs/demo --k 2
```

跑 LAB benchmark 的单任务（官方示例）：

```bash
harness2-setup lab
harness2-check --bench lab
harness2 --bench lab --k 1 --mode parallel \
  --only-domains antitrust-competition --max-tasks 1
harness2-judge --bench lab --k 1 --mode parallel
harness2-report --bench lab --k 1 --mode parallel
```

实验参数（来自 README 的 Experiments 表）：

| 选项 | 行为 |
|------|------|
| `--k 1` | 一次 Propose–Probe–Compose |
| `--k K --mode parallel` | 探 K 个通用 + K 个领域候选，再产出 K 个组合 |
| `--k K --mode sequential` | K 步连续精炼 |
| `--substrate cx` | 用 Codex 替代默认的 OpenCode 执行器 |

模型配置走 `.env`（复制 `.env.example`），填 Vertex AI 项目与模型 ID 后 `gcloud auth application-default login`。

License：Apache 2.0。注意 README 的免责声明——"This is not an officially supported Google product."，且不适用 Google 开源漏洞奖励计划。

---
[← Back to Deep Dives](./README.md)
