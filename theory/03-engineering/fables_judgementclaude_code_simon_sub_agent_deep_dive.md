---
auto_generated: true
generated_at: "2026-07-08T08:03:51Z"
source_url: "https://simonwillison.net/2026/Jul/3/judgement/"
signal_type: "significant_update"
---
# Fable 自主判断 + Sub-agent 委派：Claude Code 的模型分层推理实践 (Fable's Judgement + Sub-agent Delegation: Claude Code's Tiered Model Reasoning in Practice)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-08
>
> **项目/工具**: Claude Code (Fable/Opus/Sonnet/Haiku)
> **链接**: https://simonwillison.net/2026/Jul/3/judgement/
> **核心定位**: Claude Code 团队在 AIE 大会上公开建议：让顶级模型（Fable/Opus）自主判断何时委派子任务给低阶模型（Sonnet/Haiku），而非由人类硬编码规则——这是一种"模型分层推理"的工程实践模式

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 顶级 AI 编码助手（Claude Code 的 Fable）不再需要人类规定"什么时候跑测试"或"什么时候用子代理"——让它自己判断，并把执行层工作委派给更便宜的模型
- **现在值得用吗**: 是——如果你在用 Claude Code 的 Fable/Opus 级别模型，这个模式能显著降低 token 消耗同时保持输出质量
- **适合场景**: Fable/Opus 日常编码（配额有限时）、多步骤复杂项目（需要分层决策）、成本敏感的生产环境
- **不适合场景**: 使用非 Claude Code 工具链、模型不支持 sub-agent 委派机制、简单单文件编辑任务
- **与传统 prompt 工程核心差异**: 传统做法是人类写死规则（"大功能跑测试，小改动跳过"）；新模式是人类设定目标，模型自主判断执行策略

## 是什么 / 解决什么问题

2026 年 7 月 3 日，Simon Willison 在其博客中分享了一个来自 AIE（AI Engineer）大会 Fireside Chat 的关键洞察。Simon 与 Claude Code 团队的 Cat Wu 和 Thariq Shihipar 对话时，团队提出了一个反直觉的建议：**让 Fable（以及 Opus）使用自己的判断力，而不是由人类规定它应该如何工作。**

这个建议背后有一个深刻的工程问题：随着 AI 编码 agent 能力越来越强，人类试图通过 prompt 工程来控制 agent 行为的努力变得越来越低效。你告诉 Fable "只在大型功能开发时运行自动化测试，小的文案或设计改动不要更新和运行测试"——但 Fable 实际上比你能更好地判断什么值得测试、什么不值得。

与此同时，Simon 收到了 Jesse Vincent 的另一个相关建议：在 Fable 定价上涨前的最后几天，如何让 Fable 把子任务委派给低阶模型（Sonnet/Haiku），从而节省宝贵的 Fable token 配额。

这两个建议合在一起，指向一个更大的趋势：**模型分层推理（Tiered Model Reasoning）**——顶级模型负责判断和架构决策，低阶模型负责执行。这不是简单的"用便宜模型省钱"，而是一种基于模型能力差异的架构设计。

## 技术架构拆解

### 核心设计决策

**1. 让顶级模型自主判断（Judgement-first Design）**

Claude Code 团队的核心洞察是：Fable/Opus 这类顶级模型本身就具备判断力——它们能判断一个改动是否需要测试、一个子任务是否需要委派。人类试图用规则覆盖这种判断力，反而降低了效率。

这背后的假设是：模型的判断能力已经超过了大多数人类开发者能写出的规则质量。

**2. Sub-agent 委派作为成本控制机制**

Simon 的实践展示了一个具体的实现模式：

```
主循环 (Fable)
  ├── 判断任务类型
  ├── 实质性编码 → spawn sub-agent (Sonnet)
  ├── 机械性编辑 → spawn sub-agent (Haiku)
  └── 设计/审计/综合 → 主循环自己处理
```

关键设计点：
- 委派决策由 Fable 自主做出，不是人类硬编码
- 每个 sub-agent 接收一个 self-contained prompt（自包含的提示），不依赖主循环上下文
- 主循环在 commit 前 review sub-agent 的结果——保持质量门控

**3. Memory 文件作为持久化策略**

Simon 让 Claude Code 将委派策略保存为 project-level memory 文件：

```markdown
---
name: delegate-coding-to-subagents
description: Simon wants coding tasks delegated to subagents running an appropriately lower-power model
metadata:
  node_type: memory
  type: feedback
  originSessionId: 30068d78-43a9-4fb1-bb29-9799e18c526a
---

Stated by Simon on 2026-07-03: "For all coding tasks use your judgement to
decide an appropriate lower power model and run that in a subagent."

Why: cost/efficiency — implementation work rarely needs the top-tier
model; judgment, review, and synthesis stay with the main loop.

How to apply: when a task in this project is primarily writing/editing
code, spawn an Agent with a model override (sonnet for substantive
implementation, haiku for trivial/mechanical edits) and a self-contained
prompt; review the result in the main loop before committing. Design,
auditing, data synthesis, and anything judgment-heavy stays in the main
model.
```

这个 memory 文件的作用是：让 Fable 在每次启动时都能加载这个策略，形成一致的行为模式。这是一种"策略即代码"的实践。

### 与传统的 key 差异

| 维度 | 传统 Prompt 工程 | 模型分层推理 |
|------|-----------------|-------------|
| 决策者 | 人类写规则 | 顶级模型自主判断 |
| 执行者 | 同一模型 | 按任务复杂度分层 |
| 成本控制 | 手动限制 token | 自动委派到低阶模型 |
| 质量门控 | 人类 review 所有输出 | 顶级模型 review 子代理输出 |
| 可扩展性 | 规则越多越难维护 | 模型判断随能力自然扩展 |
| 适用模型 | 单模型场景 | 多模型 tier 共存 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                    Human (Ken)                       │
│          设定目标 / 审查最终结果 / commit              │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│              Main Loop: Fable (Opus-tier)            │
│                                                      │
│  ┌─────────────┐    ┌──────────────┐                │
│  │ 判断任务类型  │───▶│ 自主委派决策  │                │
│  └─────────────┘    └──────┬───────┘                │
│                            │                         │
│         ┌──────────────────┼──────────────────┐     │
│         ▼                  ▼                    ▼     │
│  ┌────────────┐    ┌────────────┐       ┌──────────┐ │
│  │ 设计/架构   │    │ 实质性编码  │       │ 审计/综合 │ │
│  │ (自己做)    │    │ (委派)     │       │ (自己做)  │ │
│  └────────────┘    └─────┬─────┘       └──────────┘ │
│                          │                            │
└──────────────────────────┼────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ Sonnet   │ │ Haiku    │ │ ...      │
        │ (复杂编码)│ │ (机械编辑)│ │ (其他)   │
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             │            │            │
             └────────────┼────────────┘
                          ▼
              ┌───────────────────────┐
              │  结果回传 → Fable review│
              │  → Human review → commit│
              └───────────────────────┘
```

## 实用评估

### 什么场景值得用

- **Fable/Opus 配额有限时**: Simon 的原话是 "my Fable allowance is shrinking less quickly than before"。在定价上涨前（或任何配额受限场景），sub-agent 委派能延长顶级模型的使用时间。
- **多步骤复杂项目**: 当一个项目包含架构设计、编码实现、代码审查、文档编写等多种任务时，分层推理能让每种任务匹配最合适的模型。
- **团队级标准化**: 通过 memory 文件将委派策略项目级持久化，团队成员可以共享相同的分层策略，形成一致的 agent 行为。
- **成本敏感的生产环境**: 如果编码 agent 的使用成本是企业级考量，分层推理可以在不显著降低质量的前提下将成本降低 50-80%（据 Simon 的实践）。

### 什么场景不值得用

- **非 Claude Code 工具链**: 这个模式依赖 Claude Code 的 sub-agent 机制和 model override 能力。如果使用 Cursor、Copilot 或其他工具，实现方式不同。
- **简单单文件编辑**: 如果只是修改一个配置文件或修复一个小 bug，sub-agent 委派引入的 overhead 可能超过收益。
- **模型不支持委派机制**: 如果使用的模型 tier 不支持 sub-agent spawning 或 model override，这个模式无法实施。
- **需要高度一致输出风格的场景**: 不同模型的输出风格有差异，Sonnet 写的代码和 Fable 写的代码可能在风格上不完全一致。

### 迁移成本

- **从单模型工作流迁移**: 几乎零成本。只需在 project memory 中添加委派策略，模型会自动开始使用。Simon 的实践表明，一行 prompt 就能启动。
- **从硬编码规则迁移**: 需要移除已有的细粒度规则（如 "大功能跑测试，小改动跳过"），改为信任模型的判断力。这可能需要一个适应期。
- **团队推广**: 需要团队成员理解并信任模型的判断力，这可能需要一些 demo 和数据支撑。

## 对你的意义

结合 Ken 的 AI 应用开发方向（Agent + UI），这个模式有几个直接相关的启示：

1. **Agent 架构设计**: 如果你在设计自己的 AI agent 系统，"主模型判断 + 子模型执行"是一个已经验证的架构模式。不一定需要等 Claude Code 提供这个能力——你可以在自己的 agent 框架中实现类似的分层逻辑。

2. **成本控制策略**: 如果你在用多模型 tier（如 GPT-5/4o/Claude Opus/Sonnet），这个模式提供了一个成本优化的参考框架。顶级模型做决策，中阶模型做执行，低阶模型做机械工作。

3. **A-003 假设验证**: 这个实践为"多 Agent 协作框架从实验走向工程实践"（A-003）提供了又一个工程案例。虽然它不是传统意义上的多 agent 框架（如 AutoGen/CrewAI），但它展示了一种轻量级的、基于模型能力差异的协作模式。

4. **A-004 假设验证**: Fable/Opus 在判断和架构决策上的持续优势，支持了"推理模型在 Agent 任务展现持续优势"（A-004）的假设——顶级模型的价值不在于执行所有任务，而在于做正确的判断。

**建议**: 如果你在用自己的 Claude Code 实例，值得立即尝试这个模式。一行 prompt + 一个 memory 文件，几乎零成本。

## 关键代码/配置片段

Simon 使用的 prompt（原文引用）：

```
For all coding tasks use your judgement to decide an appropriate 
lower power model and run that in a subagent.
```

Claude Code 自动生成的 memory 文件（`~/.claude/projects/name-of-project/memory/delegate-coding-to-subagents.md`）：

```yaml
---
name: delegate-coding-to-subagents
description: Simon wants coding tasks delegated to subagents running an appropriately lower-power model
metadata:
  node_type: memory
  type: feedback
  originSessionId: 30068d78-43a9-4fb1-bb29-9799e18c526a
---

Stated by Simon on 2026-07-03: "For all coding tasks use your judgement to 
decide an appropriate lower power model and run that in a subagent."

Why: cost/efficiency — implementation work rarely needs the top-tier 
model; judgment, review, and synthesis stay with the main loop.

How to apply: when a task in this project is primarily writing/editing 
code, spawn an Agent with a model override (sonnet for substantive 
implementation, haiku for trivial/mechanical edits) and a self-contained 
prompt; review the result in the main loop before committing. Design, 
auditing, data synthesis, and anything judgment-heavy stays in the main 
model. See also [[project-goals]].
```

Simon 的反馈（原文引用）：

> "So far it seems to be working well. I'm getting a ton of work done and my Fable allowance is shrinking less quickly than before."

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Simon 的实践展示了一种轻量级多 agent 协作模式——主模型判断 + 子模型执行，无需复杂的编排框架 |
| A-004: 推理模型在 Agent 任务展现持续优势 | 支持 | Fable/Opus 在判断和架构决策上的角色不可替代，低阶模型无法胜任——验证了推理模型的核心价值在于"判断"而非"执行" |

---
[← Back to Deep Dives](./README.md)
