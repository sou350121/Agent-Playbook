---
auto_generated: true
generated_at: "2026-09-04T12:06:45Z"
source_url: "https://claude.com/blog/how-warp-builds-self-improving-agents-on-claude"
signal_type: "significant_update"
---
# Warp 自改进 Agent 架构：基于 Claude Skills 的反馈闭环 (Self-Improving Agents on Claude)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-04
>
> **项目/工具**: Warp (warp.dev) + Claude Platform Agent Skills
> **链接**: https://claude.com/blog/how-warp-builds-self-improving-agents-on-claude
> **核心定位**: Warp 用 Claude Skills 将用户反馈沉淀为自改进循环，让 AI Agent 从一次性工具进化为持续学习系统

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Warp 用 Claude Skills 构建了两层 Agent 架构——内层执行任务、外层根据人类反馈持续改进内层，形成自改进闭环
- **現在值得用嗎**：是——如果你在用 Claude Platform 构建 Agent，这是目前最成熟的生产级自改进模式
- **適合場景**：代码审查、Issue 分类、Spec 编写等可标准化且有明确反馈信号的重复性 Agent 任务
- **不適合場景**：一次性探索任务、反馈信号模糊的领域、需要实时自适应的场景
- **與傳統 Prompt Engineering 核心差異**：知识从 prompt 内移到文件（Skill），改进从手动改 prompt 变成 Agent 驱动的 PR 流程

## 是什么 / 解决什么问题

Warp 是一个 AI 驱动的终端和 agentic 开发环境，基于 Rust + Golang 构建，拥有 800 万月活开发者，56% 的 Fortune 500 企业在使用。其产品核心集成了 Claude Platform，累计运行了超过 1000 万 Claude Code 会话（每周 40 万+）。

在构建内部代码审查 Agent 时，Warp 遇到了一个经典但棘手的问题：**Agent 的首次 prompt 通常只能达到 ~80% 的准确率，剩下的 20% 噪声让用户感到困扰**。团队尝试了手动重写 prompt、改进 AGENTS.md 上下文文件等方案，都能改善但都不可扩展——每次 Agent 犯错都需要工程师手动介入修改 prompt，反馈在会话结束后就消失了。

**核心洞察**：反馈到 Agent 的反馈通常在会话结束时消失，带走了改进 agentic 循环的关键上下文。Warp 的解决方案是基于 Claude Skills 构建了一个自改进架构——将知识编码为文件，让 Agent 自己根据人类反馈持续更新这些文件，改进通过标准 PR 流程审核合并。

这解决了一个更根本的问题：**如何让 Agent 从"一次性工具"进化为"持续学习的系统"**。

## 技术架构拆解

### 核心设计决策

1. **技能即文件（Skills as Files）**：Skill 是纯文本文件，编码领域知识和操作指令。Agent 在执行任务时读取 Skill 文件而非将其硬编码在 prompt 中。
2. **双层 Skill 架构**：内层/基础 Skill（base skill）持有功能性领域知识；外层/改进者 Skill（improver skill）作为观察 Agent 定期运行，分析人类反馈并提出对基础 Skill 的改进。
3. **反馈闭环通过标准 PR 流程**：Skill 文件的修改通过 Pull Request 流转——描述变更原因、人类审核批准、合并后下次运行即生效。人在回路中。
4. **反馈采集零摩擦**：反馈直接在 PR 评论或 Issue 中给出，不需要额外的提交步骤。"低摩擦是信号持续流动的关键"。

### 与前版/竞品的关键差异

| 维度 | 传统 Prompt Engineering | Warp Skills 自改进架构 |
|------|----------------------|----------------------|
| 知识存储 | 硬编码在 prompt 中 | 独立 Skill 文件，Agent 按需读取 |
| 改进方式 | 工程师手动修改 prompt | Agent 分析反馈 → 生成 PR → 人类审核 |
| 反馈利用 | 会话结束即丢失 | 累积到外层 Skill，定期驱动改进 |
| 可扩展性 | 每个 Agent 独立维护 | 改进者 Skill 高度可复用 |
| 版本控制 | 手动跟踪 | 天然通过 Git PR 流程 |
| 人在回路 | 每次改进都需要人 | 仅在审核阶段需要人 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    触发事件 (PR / Issue)                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  内层 Agent (Base Skill)                                     │
│  - 读取领域 Skill 文件                                        │
│  - 执行任务（代码审查 / Issue 分类 / Spec 编写）                │
│  - 输出结果                                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  人类反馈 (Human Feedback)                                    │
│  - 在 PR/Issue 中直接评论                                      │
│  - 点赞/踩 / 详细说明                                          │
│  - "这个变量命名不对，因为我们约定全局变量用这种格式"              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  外层 Agent (Improver Skill) — 定期调度运行                     │
│  - 拉取累积的人类反馈                                          │
│  - 分析 Agent 建议 vs 人类回应                                  │
│  - 提出对 Base Skill 的最小改动                                │
│  - 生成 PR（描述变更原因 + 具体改动）                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  人类审核 → 合并 → 下次 Base Skill 运行即继承改进               │
└─────────────────────────────────────────────────────────────┘
```

### Issue Triage Agent 实战案例

Warp 开源了一个完整的 Issue 分类 Agent 示例仓库（`warpdotdev/warp-agents-demo-github-issue-triage`），展示了完整的自改进流程：

1. **触发**：有人提交新的 GitHub Issue
2. **内层执行**：GitHub Action 触发 Agent，分析 Issue 的复杂度和可行性，分配标签，建议修复方向
3. **内层 Skill 内容**：持有每个标签的含义、如何研究代码库的领域知识
4. **实际案例**：某 Issue 被正确分类但遗漏了 `ready-to-spec` 标签（表示贡献者可以开始编写产品和技术规格）
5. **反馈**：Maintainer 直接在 Issue 中评论——不仅指出遗漏了什么，还解释了为什么
6. **外层改进**：调度运行的 "update triage" Agent（在 Warp 的 Oz 编排平台上）拉取反馈 → 生成 JSON 摘要 → 识别具体反馈信号 → 提出最小改动 → 打开 PR
7. **合并生效**：人类审核合并 PR → 下次 triage 运行自动继承新知识

## 实用评估

### 什么场景值得用

- **代码审查 Agent**：Warp 的核心用例。每次 PR 评论都是反馈信号，积累后驱动 Skill 改进，减少重复性噪声评论
- **Issue 分类/路由**：标签体系稳定、反馈明确的场景，适合用 Skill 编码分类规则
- **Spec 编写 Agent**：根据历史 PR 反馈改进规格文档的质量标准
- **任何重复性任务 + 明确反馈信号**的组合：关键是反馈必须足够具体（不只是 thumbs up/down）

### 什么场景不值得用

- **一次性探索任务**：没有重复执行就没有累积改进的价值
- **反馈信号模糊的领域**：如果人类自己也说不清"好"和"不好"的标准，Skill 无法学到有效模式
- **需要实时自适应的场景**：改进通过 PR 流程，有审核延迟，不适合秒级自适应需求
- **反馈质量差但量大**：Warp 团队明确指出——"少量资深工程师的详细反馈 > 大量粗略反馈"

### 迁移成本

从传统 Prompt Engineering 迁移到 Skills 自改进架构：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 提取现有 prompt 为 Skill 文件 | 低（~1h/Agent） | 将 prompt 中的领域知识部分提取为独立文件 |
| 搭建反馈采集机制 | 中（~1-2天） | 在现有工作流中嵌入反馈采集（PR 评论、Issue 标签等） |
| 编写 Improver Skill | 中（~2-3天） | 这是最关键的步骤——需要设计反馈分析 + Skill 更新的 prompt |
| 集成到编排平台 | 中（~1-2天） | 将 Improver 设为定期调度任务 |
| 建立审核流程 | 低（配置） | 确保 Skill 变更走 PR 流程 |

**关键洞察**：Warp 团队指出，"除了领域知识部分，改进者 Skill 在不同用例间高度可复用——代码审查的 improver 和任何其他 Agent 的 improver 差别不大。" 这意味着一次投入可复用到多个 Agent。

## 对你的意义

这个架构对 Agent 开发有几个重要启示：

1. **Skills 是 Agent 知识管理的正确抽象**。将知识从 prompt 中解耦出来，使其可版本控制、可审查、可复用——这类似于软件工程中将配置与代码分离的原则。

2. **自改进循环的门槛比想象中低**。Warp 的架构核心只有两个 Skill 文件 + 一个调度任务。不需要复杂的 RLHF 管线或专门的训练基础设施。

3. **反馈质量 > 反馈数量**。Warp 管理整个开源仓库（数百贡献者、数千次代码审查），但强调"少量详细反馈"比"大量粗略反馈"更有价值。这对你构建自己的 Agent 反馈机制有指导意义。

4. **与你的 Agent + UI 方向高度相关**。如果你关注 Agent 框架的工程质量，这个模式展示了如何将 Agent 从"玩具"提升到"生产级"——关键在于建立可持续的改进机制，而不是一次性调优。

**建议**：如果你在用 Claude Platform 构建 Agent，立即采用 Skills 架构。如果不在用 Claude，这个"知识文件化 + 观察 Agent 改进"的模式本身也值得借鉴到其它框架中。

## 关键代码/配置片段

Warp 团队的最佳实践原文引用：

**关于 Skill 编写原则**：
> "Write principles, not rules. Construct the skill as though you're instructing a smart person, not like you're programming a computer."

**关于反馈采集**：
> "Low friction is what keeps signal flowing. If you make it too hard you're not going to get the feedback and you're not going to be able to improve the skill."

**关于 Skills vs Memory 的区别**：
> "Skills are procedural and stable — 'how to do X,' run-agnostic, changed deliberately. Memory is auto-written by the agent at inference time and never stops changing."

**关于 Improver 复用性**：
> "Outside of the domain specific knowledge component, this is a fairly reusable mechanism — the improver skill for a code review agent is not that different from the improver skill for any other agent."

Warp 的 Oz 编排平台负责调度 Improver Skill 的定期运行，Python 脚本作为 Skill 的资源文件 bundled 在一起，避免每次重新编写代码。

---
[← Back to Deep Dives](./README.md)
