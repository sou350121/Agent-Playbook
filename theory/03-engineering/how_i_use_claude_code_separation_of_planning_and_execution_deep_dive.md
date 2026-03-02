---
auto_generated: true
generated_at: "2026-02-26T01:34:38Z"
source_url: "https://boristane.com/blog/how-i-use-claude-code/"
signal_type: "blog_post"
---
# 规划与执行分离：Claude Code 的高效工作流 (How I Use Claude Code: Separation of Planning and Execution)

> 🔍 本文由 Moltbot 自动生成 | 2026-02-26
>
> **项目/工具**: Claude Code + 人工审核工作流
> **链接**: https://boristane.com/blog/how-i-use-claude-code/
> **核心定位**: 一套将 AI 编码的「规划」与「执行」严格分离的纪律性流程，通过多轮标注迭代确保架构决策正确后再让 AI 写代码

## 一句话摘要

**永远不要在 Claude 写出计划之前让它写代码**——通过「深度研究 → 书面计划 → 多轮标注迭代 → 机械执行」的四阶段流程，将 AI 编码从「试错循环」转变为「可预测的装配线」。

## 是什么 / 解决什么问题

大多数开发者使用 AI 编码工具（Claude Code、Cursor、Codex 等）时的典型模式是：输入提示词 → AI 生成代码 → 发现错误 → 修正提示词 → 重复。对于更「资深」的用户，可能会串联起 Ralph 循环、MCP 工具、各种自动化脚本。但作者 Boris Tane 指出，这两种方式在处理非平凡任务时都会崩溃。

核心问题在于：**AI 会在没有充分理解系统和确认架构方向的情况下就开始写代码**，导致：
- 忽略现有缓存层而重复造轮子
- 迁移脚本不符合 ORM 约定
- API 端点重复已有逻辑
- 早期假设错误导致后续 15 分钟的代码需要全部回滚

这套工作流的核心原则是：**在审核并批准书面计划之前，绝不让 Claude 写代码**。规划与执行的分离是单一最重要的实践，它能防止浪费、保持架构控制权，并以极少的 token 消耗产生显著更好的结果。

作者使用这套流程已有 9 个月，适用于任何需要 AI 辅助的编码场景，尤其是涉及现有代码库修改的复杂任务。

## 技术架构拆解

### 架构本质

这套工作流的本质是**将 AI 编码从「黑盒试错」重构为「透明装配线」**。核心洞察是：

> AI 擅长机械执行，但不具备产品上下文和工程权衡判断。人类擅长战略决策，但不擅长重复性编码。传统工作流让 AI 做它不擅长的事（架构决策），让人类做他们不擅长的事（debug AI 的错误假设）。

通过 `plan.md` 作为「共享可变状态」，工作流实现了：
- **决策可见性**：所有架构选择落在纸面上，可审核、可修改
- **责任分离**：人类对「做什么/为什么」负责，AI 对「怎么做」负责
- **回滚成本最小化**：错误在计划阶段被发现，而非代码完成后

### 核心设计决策

这套工作流由三个明确阶段组成，每个阶段都有具体的输入输出和审核点：

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1: Research (研究)                                       │
│  ─────────────────────────────────────────────────────────────  │
│  输入：任务描述 + 代码库路径                                      │
│  动作：深度阅读代码，理解系统细节                                  │
│  输出：research.md（持久化文档，非聊天摘要）                        │
│  审核点：人工验证 AI 是否真正理解了系统                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Phase 2: Planning (规划)                                       │
│  ─────────────────────────────────────────────────────────────  │
│  输入：research.md + 功能需求                                    │
│  动作：编写详细实现计划，包含代码片段和文件路径                      │
│  输出：plan.md（独立 Markdown 文件，非内置 Plan 模式）             │
│  审核点：多轮标注迭代（1-6 轮），直到计划完全正确                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Phase 3: Implementation (执行)                                 │
│  ─────────────────────────────────────────────────────────────  │
│  输入：审核通过的 plan.md + todo 清单                            │
│  动作：机械执行计划，标记进度，持续类型检查                        │
│  输出：完成的代码 + 更新的 plan.md（标记完成状态）                 │
│  审核点：简短的纠正反馈（「更宽」「还有 2px 间隙」）                │
└─────────────────────────────────────────────────────────────────┘
```

### 关键设计选择与理由

| 设计选择 | 理由 |
|----------|------|
| 强制输出 `research.md` 而非聊天摘要 | 提供可审核的持久化文档，确保 AI 真正深入阅读而非表面浏览 |
| 使用独立 `plan.md` 而非内置 Plan 模式 | 完全控制权：可在编辑器中修改、添加行内注释、作为项目资产持久化 |
| 多轮「标注 - 更新」循环（1-6 轮） | 注入人类的产品优先级、用户痛点、工程权衡等 AI 不具备的上下文 |
| 明确的「don't implement yet」守卫 | 防止 AI 在计划未完善时提前开始编码，避免回滚链式错误 |
| 执行前生成 granular todo 清单 | 提供进度追踪器，长会话中可随时查看完成状态 |
| 单长会话贯穿三阶段 | 保持上下文连续性，AI 在研究和标注中积累的理解决不会丢失 |

### 与前版/竞品的关键差异

| 维度 | 典型 AI 编码工作流 | 本工作流 |
|------|------------------|----------|
| 规划方式 | 聊天中口头描述或内置 Plan 模式 | 独立 Markdown 文件，可编辑、可标注 |
| 审核时机 | 代码生成后发现问题再修正 | 计划阶段多轮迭代，问题在写代码前解决 |
| 人类角色 | 被动等待结果，然后 debug | 主动架构师，在标注循环中注入判断 |
| 上下文管理 | 担心 token 超限而分割会话 | 单长会话，依赖 auto-compaction + 持久化文档 |
| 错误处理 |  incremental patch 修复 | 回滚 + 缩小范围重新执行 |
| 进度追踪 | 聊天历史中翻找 | plan.md 中的 todo 清单标记完成状态 |

### 架构/信息流图

```
┌──────────────────────────────────────────────────────────────────┐
│                     完整工作流信息流                              │
└──────────────────────────────────────────────────────────────────┘

  ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
  │ Research│────>│  Plan   │────>│ Annotate│────>│  Todo   │
  │  .md    │     │  .md    │     │  Loop   │     │  List   │
  └─────────┘     └─────────┘     └─────────┘     └─────────┘
       ↑               ↑               │               │
       │               │               ▼               │
       │               │         ┌─────────┐          │
       │               │         │ 1-6 轮   │          │
       │               │         │ 迭代    │          │
       │               │         └─────────┘          │
       │               │               │               │
       │               ▼               ▼               ▼
       │         ┌─────────────────────────────────────┐
       │         │          审核通过？                  │
       │         └─────────────────────────────────────┘
       │                      │
       │            ┌─────────┴─────────┐
       │            │                   │
       │          是 │                   │ 否
       │            ▼                   ▼
       │     ┌─────────────┐      ┌─────────────┐
       │     │ Implement   │      │ 继续标注    │
       │     │   Phase     │      │ 循环        │
       │     └─────────────┘      └─────────────┘
       │            │
       │            ▼
       │     ┌─────────────┐
       │     │ Feedback &  │
       └────<│  Iterate    │
             └─────────────┘
```

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| **修改现有代码库** | 研究阶段确保 AI 理解现有架构、缓存层、ORM 约定，避免破坏性变更 |
| **复杂功能开发** | 多轮标注迭代能注入产品优先级和工程权衡，避免过度设计或设计不足 |
| **长会话任务（>30 分钟）** | todo 清单提供进度追踪，plan.md 在 auto-compaction 后仍保持完整 |
| **多人协作项目** | research.md 和 plan.md 作为持久化文档，新成员可快速理解决策背景 |
| **前端 UI 调整** | 可引用现有组件作为参考（「跟 users table 一样」），减少描述成本 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| **简单脚本/一次性任务** |  overhead 过高，直接提示词更高效 |
| **探索性原型** | 目标是不确定性高的实验，详细计划反而限制灵活性 |
| **AI 已极度熟悉的代码库** | 若 AI 已有足够上下文（如长期维护同一项目），研究阶段可简化 |
| **紧急 hotfix** | 时间压力优先于架构完美，快速修复比完整流程更合适 |
| **纯重构任务** | 若只是格式化/重命名等机械操作，无需多轮规划 |

### 迁移成本

从典型 AI 编码工作流迁移到本工作流：

| 变化项 | 工作量 | 说明 |
|--------|--------|------|
| 学习新提示词模板 | 低（1-2 小时） | 研究/规划/执行三阶段各有标准提示词，可直接复用 |
| 改变心理模型 | 中（1-2 周） | 从「快速试错」转变为「先想清楚再动手」需要纪律性 |
| 创建文档习惯 | 低 | research.md 和 plan.md 由 AI 生成，人工只需审核和标注 |
| 会话时长增加 | 无 | 单长会话替代多个短会话，总时间可能更短（减少回滚） |

**预期收益**：作者报告 9 个月使用后，token 消耗显著降低（因为减少回滚），代码质量提升，且「想知道没有这套流程之前是怎么交付代码的」。

## 理论好用，实践呢？

### 潜在陷阱与应对

| 陷阱 | 表现 | 应对 |
|------|------|------|
| **标注循环无限迭代** | 反复修改计划超过 6 轮，迟迟不进入执行 | 设定硬上限：6 轮后强制进入执行，问题在反馈阶段修复 |
| **研究阶段过度深入** | AI 花费大量时间阅读无关代码，research.md 冗长 | 明确范围：「只读 notification 相关代码，跳过测试文件」 |
| **计划过于详细** | plan.md 包含每一行代码，失去灵活性 | 要求「包含关键代码片段」而非完整实现，留出执行时调整空间 |
| **单会话上下文爆炸** | 长会话导致 auto-compaction 丢失关键信息 | 关键决策点要求 AI 更新 plan.md，持久化文档不受 compaction 影响 |
| **人类审核疲劳** | 连续审核多个 plan.md 后注意力下降 | 限制每日深度任务数量（建议≤3 个），简单任务用快捷流程 |

### 何时不应该用这套流程

```
❌ 错误场景：修复拼写错误、调整日志格式、一次性数据脚本
   → 直接用简短提示词，无需研究 + 规划

❌ 错误场景：探索性原型（不确定要做什么）
   → 目标是在试错中发现需求，详细计划反而限制灵活性

❌ 错误场景：紧急 hotfix（线上故障）
   → 时间压力优先于架构完美，快速修复比完整流程更合适
```

## Claude Code 的盲区与本工作流的补救

### Claude Code 固有局限

| 局限 | 表现 | 本工作流如何补救 |
|------|------|-----------------|
| **缺乏产品上下文** | 不知道用户痛点、业务优先级、历史技术债务 | 标注循环中人工注入：「这个功能下季度要支持多租户，预留扩展点」 |
| **过度工程化倾向** | 倾向于设计通用解决方案，而非简单直接的实现 | 人工标注：「remove this section, we don't need caching here」 |
| **无法判断 API 稳定性** | 不知道哪些函数签名被外部依赖，哪些可以随意修改 | 人工约束：「the signatures of these three functions should not change」 |
| **对现有模式不敏感** | 可能引入与代码库风格不一致的实现 | 研究阶段强制输出 research.md，AI 必须先理解现有模式 |
| **容易过早优化** | 在不需要性能的场景添加缓存/索引 | 标注阶段直接删除：「no — this should be a PATCH, not a PUT」 |

### 典型错误示例对比

```
❌ 没有本工作流时：
   用户：「添加用户列表的分页功能」
   Claude：直接实现 offset-based 分页，写了 200 行代码
   问题：系统已有 cursor-based 分页工具函数，且 offset 在大数据量下性能差
   结果：回滚，重写，浪费 30 分钟

✅ 使用本工作流：
   Phase 1 Research: Claude 阅读代码，发现 existing pagination utilities
   Phase 2 Plan: Claude 提议使用 cursor-based 分页，写入 plan.md
   人工标注：「用现有的 paginate() 工具函数，不要自己实现」
   Phase 3 Implement: 50 行代码完成，一次通过
```

### 并发与安全考量

| 问题 | 风险 | 本工作流的处理 |
|------|------|---------------|
| **并发任务冲突** | 多个 AI 会话同时修改同一文件 | plan.md 明确列出「将修改的文件路径」，人工可预判冲突 |
| **敏感信息泄露** | AI 可能将 API key/密码写入代码 | 研究阶段要求「不要读取.env 文件」，计划阶段审核代码片段 |
| **破坏性迁移** | 数据库迁移未考虑向后兼容 | 计划阶段强制要求「包含迁移脚本和回滚方案」 |
| **类型安全退化** | AI 使用 `any` 或 `unknown` 类型绕过类型检查 | 执行提示词明确：「do not use any or unknown types」 |
| **测试缺失** | AI 实现功能但不写测试 | 计划阶段要求「包含测试计划」，todo 清单中有测试任务 |

### 长会话的并发安全实践

```markdown
## 推荐做法

1. **单一会话原则**：研究→规划→执行在同一会话，避免上下文分裂
2. **持久化文档**：research.md 和 plan.md 作为 Git 跟踪文件，会话中断可恢复
3. **Git 检查点**：每个阶段完成后提交：`git commit -m "plan approved"`
4. **类型检查守卫**：执行提示词包含「continuously run typecheck」

## 不推荐做法

❌ 在多个会话间切换（丢失上下文）
❌ 仅依赖聊天历史（auto-compaction 后丢失）
❌ 执行中途人工干预架构决策（破坏「机械执行」原则）
```

## 对你的意义

### 对 Ken 的 AI 应用开发线的启示

你正在追踪 Agent + UI 工具链，这套工作流揭示了当前 AI 编码工具的一个关键空白：**缺乏结构化的规划 - 执行分离机制**。

**值得立即试用的点**：
1. **标注循环模式**：这是一个尚未被工具化的交互范式。现有工具（Cursor、Claude Code 内置 Plan）都缺少「行内标注 → AI 更新 → 多轮迭代」的流畅体验。这可能是一个产品机会。
2. **持久化计划文档**：将 plan.md 作为项目资产而非临时聊天记录，这与你的 Handbook 理念一致——信号（聊天）与资产（文档）分离。
3. **进度追踪器**：todo 清单嵌入计划文档，AI 自动标记完成状态。这是一个简单但有效的 UX 模式，可复用到你的 Agent 框架评估中。

**建议行动**：
- **本周**：在你的下一个 Agent-Playbook 条目中，将这套工作流作为「最佳实践」收录
- **本月**：尝试在你的实际开发中应用此流程（尤其是修改 RAG pipeline 或 UI 组件时），记录体验
- **长期**：观察是否有工具开始原生支持「标注循环」模式，这可能是 Agent IDE 的下一个差异化功能

### 对 VLA 研究线的潜在启发

虽然这是软件工程的实践，但「规划 - 执行分离」与 VLA 领域的「world model + action policy」架构有概念上的呼应：
- research.md ≈ world model（理解环境）
- plan.md ≈ policy planning（规划动作序列）
- implementation ≈ action execution（执行动作）

若你在追踪的 VLA 论文中有类似的「显式规划」架构，可考虑在 Handbook 中建立跨领域连接。

## 关键代码/配置片段

### 研究阶段提示词模板

```
read this folder in depth, understand how it works deeply, what it does 
and all its specificities. when that's done, write a detailed report of 
your learnings and findings in research.md
```

关键用语：「deeply」「in great details」「intricacies」「go through everything」—— 这些不是废话，而是防止 AI 浅层阅读的必要信号。

### 规划阶段提示词模板

```
I want to build a new feature <name and description> that extends the 
system to perform <business outcome>. write a detailed plan.md document 
outlining how to implement this. include code snippets

the list endpoint should support cursor-based pagination instead of 
offset. write a detailed plan.md for how to achieve this. read source 
files before suggesting changes, base the plan on the actual codebase
```

### 标注循环提示词模板

```
I added a few notes to the document, address all the notes and update 
the document accordingly. don't implement yet
```

**关键守卫**：「don't implement yet」—— 没有这句话，AI 会在认为计划足够好时立即开始编码。

### 执行阶段提示词模板

```
implement it all. when you're done with a task or phase, mark it as 
completed in the plan document. do not stop until all tasks and phases 
are completed. do not add unnecessary comments or jsdocs, do not use 
any or unknown types. continuously run typecheck to make sure you're 
not introducing new issues.
```

### 典型标注示例（人工添加到 plan.md 的行内注释）

```markdown
<!-- 人工标注示例 -->

- "use drizzle:generate for migrations, not raw SQL" 
  → 领域知识注入

- "no — this should be a PATCH, not a PUT" 
  → 纠正错误假设

- "remove this section entirely, we don't need caching here" 
  → 拒绝提议的方案

- "the queue consumer already handles retries, so this retry logic 
   is redundant. remove it and just let it fail" 
  → 解释为何需要变更

- "this is wrong, the visibility field needs to be on the list itself, 
   not on individual items. when a list is public, all items are public. 
   restructure the schema section accordingly" 
  → 重定向整个章节
```

### 执行阶段纠正反馈（极简）

```
- "You didn't implement the deduplicateByTitle function."
- "You built the settings page in the main app when it should be in 
   the admin app, move it."
- "wider"
- "still cropped"
- "there's a 2px gap"
```

前端视觉问题时，可直接附加截图，比文字描述更高效。

### 回滚 + 缩小范围

```
I reverted everything. Now all I want is to make the list view more 
minimal — nothing else.
```

当方向错误时，不回补 patch，而是回滚后缩小范围重新执行。

---

## 总结

这套工作流的本质是**将 AI 编码从「创意过程」重新定义为「装配线过程」**：
- 创意工作（架构决策、权衡判断）在标注循环中由人类完成
- 机械工作（写代码、跑类型检查、标记进度）由 AI 完成
- 两者通过持久化的 plan.md 文档解耦，各取所长

作者的最后建议值得全文引用：

> "Try my workflow, you'll wonder how you ever shipped anything with 
> coding agents without an annotated plan document sitting between you 
> and the code."

---
[← Back to Deep Dives](./README.md)
