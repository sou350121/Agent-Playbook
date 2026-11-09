---
auto_generated: true
generated_at: "2026-11-09T05:50:00Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/use-decision-models-with-amazon-bedrock-agentcore-evaluations/"
signal_type: "significant_update"
---
# 用决策模型给 Agent 打分：Bedrock AgentCore Evaluations 的可阈值化评分后端 (Decision Models as Scoring Backend for AgentCore Evaluations)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-09
>
> **项目/工具**: Amazon Bedrock AgentCore Evaluations + 决策模型（Jev / Strands Decider 2B）
> **链接**: https://aws.amazon.com/blogs/machine-learning/use-decision-models-with-amazon-bedrock-agentcore-evaluations/
> **核心定位**: 把 Agent 评估的"打分步骤"从自由文本的 LLM-as-a-judge 换成返回校准概率的专用决策模型——让评分成为可阈值化、可聚合、可编程判断的数值信号

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: 这不是新产品，而是 AgentCore Evaluations 的一个新用法——通过 code-based evaluator 把 Jev（托管）或 Strands Decider 2B（开源、自托管）接成打分后端，输出"标签 + 校准概率"而不是一段带理由的文本
- **现在值得用嗎**: 看场景——如果你的评估问题是"是否拒答 / 是否离题 / 是否有据可依"这类固定选项判断题，值得；如果你需要"为什么这次失败"的解释，还得用 LLM-as-a-judge
- **適合場景**: 高频在线抽样评估、发布前的 pass/fail 门禁、把评估成本压下来的规模化回归测试
- **不適合場景**: 需要深度归因的探索期评估、无法定义固定答案集的复杂质量判断、不想在 AWS 上搭整套基础设施的团队
- **與 LLM-as-a-judge 核心差異**: 同一个评估问题，前者给你"文本 + 理由"，后者给你"标签 + 0~1 概率"，后者能直接拿来卡阈值

## 是什么 / 解决什么问题

Agent 评估里有一类问题特别窄、特别重复，但特别重要：

- 这条回复有没有守策略？
- 这个工具调用能不能批？
- 这个回答是不是被检索到的上下文所支持？
- Agent 有没有完成用户的目标？

这类问题的特点是**答案集固定，一个有经验的人扫一眼就能判定**。但过去主流做法是用通用大模型当裁判（LLM-as-a-judge）：给一段 rubric，让模型输出一个分数加一段理由。问题在于——**同一条输入跑两次，分数和理由都可能不一样**。理由读起来很合理，但你没法把它接进自动化流水线：不能卡阈值，不能聚合，不能做 A/B 门禁。

AWS 这篇博客给出的解法不是造新评估器，而是复用已有的 code-based evaluator 扩展点：把评估请求转给一个**决策模型**（decision model）——一个小而专的模型，从固定选项集里选一个，并返回**校准过的置信度分布**。文中原话：

> "They take a structured state and a fixed set of allowed answers and return a calibrated probability over them, rather than free-form text whose confidence drifts from run to run."

这就是核心价值：**把"评估"从一次性的人工阅读动作，变成一条可以在 CI/CD 里卡住的数值信号**。

## 技术架构拆解

### 核心设计决策

- **不做替代，做筛选层（screening layer）**：文中反复强调决策模型不是 LLM 评估器的替代品。"Use them for narrow, well-defined checks alongside the built-in evaluators' broader assessment." 决策模型先跑一遍 pass/fail 扫描，把可疑的 turn 挑出来，再交给内置评估器出解释。
- **一次请求答多个问题**：两种后端都支持在同一个 state 上一次问多个问题，所以筛选层的边际成本很低。
- **code-based evaluator 作为通用适配层**：AgentCore 的 code-based evaluator 本质是跑在 AWS Lambda 里的自定逻辑，因此可以调用"任意外部系统、模型或 API"——这条缝让决策模型能接进来，而不用 AWS 改核心产品。
- **三种问题类型覆盖大多数 rubric**：
  - **noul**（是/否）：返回 0~1 的"是"的概率
  - **choice**：最多 255 个选项里选一个，返回最可能选项 + 完整分布 + 置信度
  - **score**：2~10 个有序档位，返回概率加权的分数 + 分布 + 置信度

### 与前版/竞品的关键差异

| 维度 | LLM-as-a-judge（AgentCore 内置） | 决策模型（Jev / Strands Decider 2B） |
|------|------------------------------|--------------------------------|
| 输出 | 分数 + 自然语言理由 | 标签 + 校准概率分布 |
| 可复现性 | 同一输入多次运行可能漂移 | 固定选项集，输出分布 |
| 可阈值化 | 难（分数尺度不稳） | 是（直接卡 P >= 阈值） |
| 可聚合 | 弱 | 强（概率可平均、可统计） |
| 失败归因 | 强（有解释） | 弱（只有标签） |
| 适用边界 | 需要串联证据、识别缺失信息的复杂判断 | 固定选项、扫一眼可判的窄问题 |
| 部署形态 | Bedrock 内托管模型 | Jev = TypeSafe 托管 API（需 API key）；Strands Decider 2B = 2B 参数开源模型，自托管 |

### 架构/信息流图

```
Agent 运行（Strands Agents → AgentCore runtime）
        │  OpenTelemetry spans
        ▼
┌─────────────────────────────────────────────┐
│ AgentCore Evaluations                       │
│                                             │
│  ┌───────────────┐  ┌────────────────────┐  │
│  │ 确定性 code    │  │ 内置 LLM-as-a-judge │  │
│  │ evaluator      │  │ (15 个内置评估器)   │  │
│  │ (长度/正则)    │  │                    │  │
│  └───────────────┘  └────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │ code-based evaluator (Lambda)          │  │
│  │  spans.py 归一化 OTel → 决策模型请求    │  │
│  │        ↓                               │  │
│  │  Jev（托管） / Strands Decider 2B（自托管）│  │
│  │        ↓ 概率分布 → label + value       │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
        │
        ▼  按阈值筛选 → 可疑 turn 送内置评估器出解释
```

### 三个决策模型评估器的映射方式（来自文中表格）

这三个评估器是实现参考，也是理解"概率如何变成评估结果"的最好样本：

| 评估器 | 层级 | 问题类型 | 标签 | 取值 |
|------|------|------|------|------|
| Jev/DeciderGroundedness | TRACE | noul（是/否） | Grounded / Ungrounded | P(grounded) |
| Jev/DeciderHelpfulness | TRACE | score（4 档） | 最可能档位 | 期望档位，缩放到 0~1 |
| Jev/DeciderGoalCompletion | SESSION | choice（三选一） | 最可能选项 | 概率加权值 |

映射规则很直白：noul 问题取"真"的概率作为 value、最可能答案作为 label；score 问题取概率加权的期望档位并缩放到 [0,1]；choice 问题取预定义选项值的加权平均。

注意一个工程细节：**trace 级评估只发送目标 turn 和简短历史，session 级评估才发送完整对话**——这是控制成本的关键，也意味着你设计的评估问题必须自己明确"需要多少上下文才判得准"。

## 实用评估

### 什么场景值得用

- **在线高频抽样**：文中的示例配置直接开了"100% sampling 的在线评估"。在这种量级下，用 LLM 裁判逐条写理由的成本和延迟都不可接受；决策模型（尤其 2B 自托管）是更现实的底座。
- **发布门禁 / CI 回归**：你只需要一个 pass/fail 信号决定能不能发，概率阈值比"模型说 4 分（满分 5）"好卡得多。
- **策略合规类检查**：拒答、离题、越权工具调用这类问题，答案集天然固定，正是决策模型的舒适区。
- **想控制评估成本又要保留解释能力**：筛掉 90% 的明显 pass，把剩下 10% 交给内置评估器出解释——两层结构比一层更省。

### 什么场景不值得用

- **你说不清"正确答案集"是什么**：如果一个质量问题的答案是"看情况"，决策模型会把它强行压成分布，校准也救不了语义上的错。
- **你主要想知道"为什么失败"**：决策模型不产出解释，只有标签和概率。归因还得靠内置 LLM 评估器的 rationale。
- **你没有真实流量做校准**：文中专门用一整节讲验证，因为**重写 rubric 就是造了一个新度量**——"A reframed rubric often lands stricter or looser than the original intended"。没有标注样本，你无法知道阈值该定在哪。
- **不想承担整套 AWS 基建**：需要 AgentCore 可用的 Region、CloudWatch Transaction Search、Bedrock 模型访问、Lambda、Docker，Jev 还要 TypeSafe API key，Strands Decider 需要一台能被 Lambda 在 VPC 内访问的主机。这是一条完整的云上工程链路，不是 pip install。
- **把它当便宜替代品无脑全铺**：文中明确"不是替代"，一次性对所有指标上决策模型通常意味着你在为每次改动重新校准一堆度量。

### 迁移成本

从"纯 LLM-as-a-judge"迁到"决策模型筛选 + LLM 解释"，实际要做的事：

1. **把 rubric 重写成问题类型**：把自由评分标准压缩成 noul / choice / score 三型之一——这一步最费脑子，也是价值最高的部分。
2. **写一个 Lambda 适配器**：归一化 OpenTelemetry span → 决策模型请求 → 概率映射回 AgentCore 结果格式。文中的 `spans.py` 就是做这件事，可参考 `awslabs/agentcore-samples` 里的 `custom-code-based-evaluation` 示例。
3. **标注 + 校准**：抽真实 session（要覆盖失败和边界，不只是 happy path）、三个独立标注者取多数票、决策模型与内置评估器在同一批输入上对比。
4. **选后端**：Jev 省运维但要 API key 和外部调用成本；Strands Decider 2B 自主可控但你要自己跑一台推理主机。

粗估：熟悉 AgentCore 的团队用现成示例跑通 pipeline 是几天到两周量级；要做成能对发布卡门禁的度量，标注与校准是主要工作量。`> TODO: 官方示例未披露吞吐/延迟/单条评估成本数据，需自测。`

### 验证方法（文中给出的五步，值得单独抄下来）

这是全文最可迁移的部分——它其实不是"如何使用决策模型"，而是"如何验证任何新评估器"：

| 步骤 | 做什么 | 关键点 |
|------|------|------|
| 1. 建标注样本 | 从真实 session 抽样 | 必须覆盖失败与边界，只测 happy path 等于没测 |
| 2. 拿人类参考标签 | 3 个独立标注者 + 多数票 | **分歧票最有价值**——它暴露的是 rubric 本身的模糊，而不是模型的错 |
| 3. 同输入跑两个评估器 | 决策模型 + 内置评估器一次批跑 | 同输入才可比 |
| 4. 三维度读结果 | 一致率（分 easy/hard 拆开看）、校准（高置信是否对应高准确）、以及跨类别稳定性 | 只在 hard 案例上失手 ≈ 和人类标注者的行为一致，这是好现象 |
| 5. 定阈值再上线 | 用校准曲线选阈值 | 先验证再卡门禁，顺序不能反 |

## 对你的意义

对做 Agent 工程的人来说，这篇的技术含量不在"决策模型"这个名词，而在它指出的一个结构性缺口：**我们的评估体系缺一个既便宜又可靠的中间层**。

目前大多数团队的评估是二元的——要么是确定性代码检查（快、便宜、只能测死规则），要么是 LLM 裁判（灵活、贵、结果飘）。中间这一层"语义上需要理解、但答案集固定"的判断（有据可依吗？越权了吗？跑题了吗？）一直是灰色地带，实践中往往变成"用 LLM 裁判但不敢卡门禁"。

决策模型填的就是这个缝。而且它天然给出概率，这让**评估从"每条的判定"变成"分布上的统计决策"**——你可以设 P < 0.6 为可疑、> 0.9 为通过，中间地带交给更强的评估器。这是一个可以直接搬到自己 pipeline 里的设计，即使完全不用 AWS：

1. 把评估问题先分类成"固定选项 / 需要解释"两类，别混着测。
2. 固定选项类优先用便宜模型（甚至小型分类器）跑，输出概率而不是文本。
3. 只在低置信区间调强模型 + 出理由。
4. 上线前必须做标注-校准，否则阈值是拍脑袋。

明确建议：**如果你在 AWS 上跑 Agent，值得抄示例**；不在 AWS 上，也值得抄它的三段式结构（确定性检查 → 决策模型筛选 → LLM 归因）和那五步验证法。别抄的是"到处上决策模型"——文中自己说了它不是替代品。

## 关键代码/配置片段

文中未给出完整可运行代码（完整版本在 `awslabs/agentcore-samples` 仓库），但给出了可以直接用的 CLI 入口，这些是源材料中真实存在的：

现有 pipeline 无 flag 时跑的是确定性检查 + LLM-as-a-judge 基线：

```bash
# 部署 HR Assistant + 两个确定性 Lambda 评估器 + 内置评估器批跑
python evaluate.py
```

接入 Jev（托管决策模型），一次注册三个评估器：

```bash
python evaluate.py --with-jev --jev-secret-arn <ARN>
```

接入 Strands Decider 2B（开源 2B 自托管），并自动开 EC2 跑推理机：

```bash
python evaluate.py --with-decider --decider-ec2
```

关键点：决策模型评估器是 **opt-in** 的，与基线评估器并行运行、不改动原流程。这个设计让"加一层筛选"的风险降到很低——先并行跑一个月，看两个评估器的一致率，再决定是否卡门禁。

文中对内建评估器总体结构的描述值得原样引用：

> "Alongside 15 built-in evaluators, AgentCore Evaluations supports custom evaluators that you define as either an LLM-as-a-judge or a code-based evaluator."

以及决策模型与 LLM 裁判的定位差异：

> "Decision models are not a replacement for LLM evaluators. They're an addition that the code-based evaluator framework makes possible."

`> TODO: 决策模型自身在中英文混合流量上的校准表现、2B 模型自托管的延迟与显存需求，文中均未披露，需自测。`

---
[← Back to Deep Dives](./README.md)
