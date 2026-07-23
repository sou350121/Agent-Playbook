---
auto_generated: true
generated_at: "2026-07-23T03:37:31Z"
source_url: "https://www.36kr.com/p/3899013551245186"
signal_type: "significant_update"
---
# Claude Code 四种循环：从"写提示词"到"设计行为系统" (Loop Engineering: The Four Loop Primitives)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-23
>
> **项目/工具**: Claude Code Agent SDK
> **链接**: https://claude.com/blog/getting-started-with-loops
> **核心定位**: Claude Code 团队首次正式定义 Agent 循环的四种原语，为"循环工程"（Loop Engineering）建立分类标准与工程规范

## 快速判断

- **一句话定位**：Claude Code 将 Agent 循环拆为四种原语（回合制/目标/时间/主动），每种对应不同的"停止条件"设计范式
- **现在值得用吗**：是 — 如果你在用 Claude Code 或 Agent SDK 构建自动化 Agent，这套分类是设计循环的基础框架
- **适合场景**：代码迭代优化、定时监控/巡检、bug 分诊/依赖升级等结构化任务
- **不适合场景**：开放式探索、需要高度创造性判断的任务、非结构化信息处理
- **与前版核心差异**：从"逐轮手动对话"升级为"设计带闸门的行为系统"——编程重心从提示词内容转移到停止条件、验证器、token 预算控制

## 是什么 / 解决什么问题

AI 编程工具正在经历一次范式迁移：从"写一句话得到一个回答"到"设计一套合上电脑还在替你干活的系统"。Claude Code 团队在官方博客中正式定义了"循环"（Loop）的概念——**智能体重复执行一轮又一轮工作，直到触发停止条件**。

这个定义看似简单，但背后解决的是一个工程难题：当 Agent 可以自主调用工具、读取文件、运行命令时，**什么时候该停？** 没有闸门的循环，强大且危险——它能烧光 token 预算，也能陷入"看似有进展、实则原地打转"的死循环。

Claude Code 的解决方案是将循环按"停止条件"拆为四种原语：人来判（回合制）、评估器来判（目标）、时间来判（时间循环）、事件来判（主动循环）。每种原语对应不同的触发方式、停止标准和适用场景。

## 技术架构拆解

### 核心设计决策

1. **停止条件即分类**：四种循环的本质区别不是"做什么"，而是"什么时候停"。这一定义将循环从模糊的"AI 自动跑"变成了可工程化的设计单元。
2. **验证器优先**：官方将"给 Claude 一个能自己检查产出的方式"标为"最有价值的一条"。验证能力决定了循环能否干净利落地收尾。
3. **成本即设计约束**：每种原语都配有"Managed usage by"——token 预算控制不是事后优化，而是循环设计的内置维度。
4. **SDK 级抽象**：Agent SDK 将循环内核暴露为可编程的消息流（SystemMessage → AssistantMessage → UserMessage → ResultMessage），支持 Python 和 TypeScript 双语言嵌入。

### 与前版/竞品的关键差异

| 维度 | 传统提示词交互 | Claude Code 循环体系 |
|------|---------------|---------------------|
| 交互模式 | 一问一答，人驱动 | 自动迭代，停止条件驱动 |
| 编程重心 | 提示词内容设计 | 停止条件 + 验证器 + 预算控制 |
| 任务边界 | 单轮任务，人判断完成 | 多轮循环，机器可判定完成 |
| 持续性 | 人在线时才工作 | /schedule 支持关机后云端运行 |
| 成本可控性 | 单次调用，成本透明 | 多轮迭代，需硬上限 + 无进展检测 |
| 错误恢复 | 人发现后重新提示 | 评估器自动打回重做 |

### 架构/信息流图

```
                    ┌─────────────────────────────────────────┐
                    │          用户 / 事件源                    │
                    └──────────────┬──────────────────────────┘
                                   │ 触发 (prompt / schedule / event)
                                   ▼
                    ┌─────────────────────────────────────────┐
                    │         Agent SDK 循环内核                │
                    │                                         │
                    │  ┌─────────┐    ┌─────────┐            │
                    │  │ Claude  │───▶│ 工具执行 │            │
                    │  │ 评估决策 │    │ (Bash/   │            │
                    │  └────┬───┘    │ Read/     │            │
                    │       ▲        │ Edit/...) │            │
                    │       │        └────┬──────┘            │
                    │       │  结果回流     │                   │
                    │       │             │                   │
                    │       └─────────────┘                   │
                    │          (Turn 循环)                     │
                    └──────────────┬──────────────────────────┘
                                   │ 无工具调用 → 循环结束
                                   ▼
                    ┌─────────────────────────────────────────┐
                    │   ResultMessage (结果 + token 用量 + 成本) │
                    └─────────────────────────────────────────┘
```

### 四种原语详解

| 原语 | 触发方式 | 停止条件 | 核心命令 | 适用场景 |
|------|---------|---------|---------|---------|
| **回合制** (Turn-based) | 用户逐轮提示词 | Claude 自判完成或需更多上下文 | 手动逐轮发送 | 探索性任务、需要人持续判断的短任务 |
| **目标循环** (/goal) | 手动触发 | 目标达成 OR 达到最大轮数 | `/goal` + 量化标准 | Lighthouse 分数优化、测试通过率提升 |
| **时间循环** (/loop, /schedule) | 时间间隔触发 | 用户取消或工作完成 | `/loop 5m ...` / `/schedule` | 定时巡检、PR 监控、Slack 消息摘要 |
| **主动循环** (Proactive) | 事件/调度触发 | 单任务目标达成；整条例行任务需手动关闭 | `/schedule` + `/goal` + 动态工作流 | bug 分诊、依赖升级、问题分类 |

## 实用评估

### 什么场景值得用

- **代码质量迭代**：用 `/goal` 设定量化标准（如"测试通过率从 70% 提到 90%"），让 Agent 自动迭代直到达标。比手动逐轮高效得多。
- **定时巡检/监控**：用 `/loop` 或 `/schedule` 定期检查 PR 状态、CI 结果、反馈频道。替代传统 cron + 脚本方案，Agent 可以自主判断和修复。
- **结构化流水线**：bug 报告 → 分诊 → 修复 → 回复，用主动循环 + 动态工作流串联。每个子任务有独立的停止条件，整条例行任务持续运行。
- **SKILL 驱动的自我验证**：将手动验收步骤编码为 SKILL.md，让 Agent 在回合制循环中自我检查。验证越能量化，人工介入越少。

### 什么场景不值得用

- **开放式探索**：如"改进这个代码库"——没有明确的停止条件，循环会无限延伸或产出低质量结果。
- **创造性设计**：UI 设计、产品架构决策等需要人类判断的任务，不适合交给循环。
- **确定性脚本任务**：如"批量重命名文件"——跑脚本比让模型逐步推理便宜且可靠得多。官方明确建议"确定性的活交给脚本"。
- **高成本敏感场景**：不设上限的循环可能烧穿 token 预算。Steinberger 自称"手握无限 token 的男人"（OpenAI 员工福利），但普通人没有这个条件。

### 迁移成本

- **从手动提示词到回合制循环**：零成本。你已经在用了，只需开始用 SKILL.md 编码验证步骤。
- **从脚本到时间循环**：中等成本。需要将脚本逻辑转化为提示词 + 停止条件设计，但 `/loop` 命令本身很简单。
- **从零构建主动循环**：较高成本。需要组合 `/schedule` + `/goal` + 动态工作流 + auto mode，并设计完整的验证和闸门机制。建议先在小区块试跑，再扩展到全量。

### 工程社区的闸门共识

Reddit 工程讨论中总结的三条必备闸门（写循环之前就得设计好）：

1. **Done 条件**：必须机器可判定（测试全绿、某个 spec 项关闭）
2. **硬上限**：最大轮数 + 最大花费，防成本失控和无限循环
3. **无进展检测**：反复碰同一批文件却没有新通过测试 → 强制停下

## 关键代码/配置片段

### SKILL.md 驱动的自我验证

```markdown
---
name: verify-frontend-change
description: Verify any UI change end-to-end before declaring it done.
---

# Verifying frontend changes
Never report a UI change as complete based on a successful edit alone.

1. Start the dev server and open the edited page in the browser.
2. Interact with the change directly — click, confirm state change, screenshot.
3. Check browser console: zero new errors or warnings.
4. Run performance trace and audit Core Web Vitals.

If any step fails, fix and rerun from step 1.
```

### 时间循环示例

```
/loop 5m check my PR, address review comments, and fix failing CI
```

### 主动循环组合示例

```
/schedule every hour: check #project-feedback for bug reports.
/goal: don't stop until every report found this run is triaged, actioned, and responded to.
When fixing a bug, use a workflow to explore three solutions in parallel worktrees
and have a judge adversarially review them.
```

### Agent SDK 循环内核（消息流）

```
SessionStart → SystemMessage("init")
  → Turn 1: AssistantMessage(tool_call=Bash) → UserMessage(tool_result)
  → Turn 2: AssistantMessage(tool_call=Read) → UserMessage(tool_result)
  → Turn 3: AssistantMessage(tool_call=Edit) → UserMessage(tool_result)
  → Final: AssistantMessage(text_only) → ResultMessage(cost, usage, sessionId)
```

## 对你的意义

这套循环体系对你（Agent + UI 方向）的意义在于：

1. **Agent 设计模式标准化**：四种原语提供了一个清晰的决策框架——拿到一个自动化任务时，先问"它的停止条件是什么"，然后选择对应原语。这比模糊的"让 AI 自动做"要工程化得多。
2. **与你的 Agent-Playbook 高度相关**：`theory/03-engineering` 目录中关于 Agent 循环的内容可以基于这套官方分类进行重构。四种原语 + 闸门设计 + 验证器模式，是一个完整的工程方法论。
3. **Loop Engineering 是一个新赛道**：Addy Osmani 命名、Boris Cherny 和 Peter Steinberger 实践——这正在成为 AI 编程的后提示词时代的核心技能。值得关注这个方向的进一步演进。

**建议**：立即试用 `/goal` 和 `/schedule` 命令，将它们集成到你日常的工作流中。先从小任务开始（如定时检查某个 PR），验证闸门设计的有效性后再扩展到更复杂的主动循环。

---
[← Back to Deep Dives](./README.md)
