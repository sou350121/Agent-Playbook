---
auto_generated: true
generated_at: "2026-07-16T06:48:05Z"
source_url: "https://openai.com/index/separating-signal-from-noise-coding-evaluations"
signal_type: "significant_update"
---
# OpenAI 审计 SWE-Bench Pro：约 30% 任务存在设计缺陷 (OpenAI Audit of SWE-Bench Pro: ~30% Tasks Have Design Flaws)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-16
>
> **项目/工具**: SWE-Bench Pro (由 OpenAI 审计)
> **链接**: https://openai.com/index/separating-signal-from-noise-coding-evaluations/
> **核心定位**: OpenAI 对业界最广泛使用的编码评测基准 SWE-Bench Pro 进行了全面审计，发现约 30% 的任务存在设计缺陷，动摇了该基准作为模型编码能力度量标准的可信度。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: OpenAI 发现 SWE-Bench Pro 约 30% 任务存在设计缺陷（测试过严/提示模糊/覆盖不足），撤回了对该基准的推荐。
- **現在值得用嗎**: 否——OpenAI 已明确撤回推荐。社区需要等待由专业开发者从头设计的新一代编码评测基准。
- **適合場景**: 理解评测基准设计的陷阱；为自己的评估体系建立质量保证流程。
- **不適合場景**: 作为模型排序依据；作为采购/选型决策的量化参考。
- **與 SWE-bench Verified 核心差異**: 两者都源自开源 PR，但 Pro 版针对更长的任务 horizon 和更真实的编码场景；两者都被发现存在系统性设计缺陷。

## 是什么 / 解决什么问题

SWE-Bench Pro 是 SWE-bench Verified 的继任者，由 Scale AI 设计，旨在解决 Verified 版被发现的基础性污染和设计问题。Pro 版从 731 个公开任务组成，要求模型实现能通过新测试的功能特性，同时不破坏现有功能。在 Pro 版上，前沿模型在 8 个月内从 23.3% 通过率提升到 80.3%，展示了编码 Agent 能力的快速进步。

然而，OpenAI 的审计揭示了一个令人不安的事实：这个被广泛采用的基准，其任务质量远未达到可靠评测的标准。审计发现 249/731（34.1%）的任务存在可确认的缺陷，其中自动管线标记了 200（27.4%）个。

这对整个 AI 编码领域意味着什么？如果最权威的评测基准有三分之一是不可信的，那么过去几个月基于 SWE-Bench Pro 的所有模型排名、采购决策和论文结论，都需要重新审视。

## 技术架构拆解

### 核心设计决策

OpenAI 的审计方法本身就是一个值得研究的质量保证流程设计：

1. **三层验证管线**: 自动化过滤器 → 人类监督的 Agent 审查 → 人类标注活动
   - 自动化管线首先审查任务指令、模型尝试和测试用例，标记 286 个可疑任务
   - 基于 Codex 的调查 Agent 对标记任务进行深度审计，能运行测试、检查仓库文件、分析失败模式
   - 5 名资深软件工程师独立审查每个标记任务，分歧升级处理

2. **四类缺陷分类法**

| 缺陷类型 | 数量占比 | 说明 |
|----------|---------|------|
| 测试过严 (Overly strict tests) | 最高 | 测试强制执行 prompt 未指定的具体实现细节，使功能正确的提交被判失败 |
| 提示 underspecified (Underspecified prompts) | 次高 | 提示遗漏了隐藏测试所要求且无法合理推断的需求 |
| 测试覆盖不足 (Low-coverage tests) | ~9.4% (人类标注) | 测试未能充分检查请求的功能，不完整的修复也能通过 |
| 误导性提示 (Misleading prompts) | 少量 | 提示将模型引向错误行为或与测试要求矛盾 |

3. **人类 vs Agent 审查的互补性**
   - 人类标注者比 Agent 管线更倾向于标记任务为 broken（34.1% vs 27.4%）
   - 人类更可能为同一任务分配多个缺陷标签（多重缺陷共存）
   - 在最低覆盖测试方面差异最大：人类标记 9.4%，Agent 仅 4.1%
   - 但没有任何被 Agent 管线标记的任务，人类审查的多数结论是"未损坏"

### 与前版的核心差异

| 维度 | SWE-bench Verified | SWE-Bench Pro | 审计后结论 |
|------|--------------------|---------------|-----------|
| 任务来源 | 开源仓库 PR | 开源+私有仓库 PR | 两者同源，共享根本问题 |
| 任务复杂度 | 单文件修改 | 更长 horizon，更真实场景 | 复杂度提升但质量未同步 |
| 公开任务数 | 500 | 731 | Pro 版规模更大但缺陷比例相似 |
| 前沿模型通过率 | ~50% | 80.3% (最新模型) | 高通过率可能部分来自缺陷任务 |
| OpenAI 推荐状态 | 已撤回 | 已撤回 | 两者均不再推荐 |

### 审计管线架构

```
┌─────────────────────────────────────────────────────────────┐
│                    SWE-Bench Pro Dataset                     │
│                       (731 tasks)                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │  Automated Filter      │
              │  (管线初筛)              │
              │  审查: 指令/尝试/测试     │
              └───────────┬────────────┘
                          │ 标记 286 个可疑任务
                          ▼
              ┌────────────────────────┐
         ┌────┤   并行双轨验证          ├──┐
         │    └────────────────────────┘    │
         ▼                                   ▼
┌──────────────────┐              ┌──────────────────┐
│ Agent 审查轨      │              │ 人类标注轨        │
│ (Codex 调查 Agent) │              │ (5 名资深工程师)  │
│ 运行测试/检查文件  │              │ 独立判断+证据     │
└────────┬─────────┘              └────────┬─────────┘
         │ 200 broken (27.4%)              │ 249 broken (34.1%)
         ▼                                   ▼
┌─────────────────────────────────────────────────────────────┐
│              交叉验证 + 分歧升级 → 最终结论                   │
│              ~30% 任务存在设计缺陷                             │
│              OpenAI 撤回对 SWE-Bench Pro 的推荐               │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得参考

- **评测基准设计者**: 这是教科书级别的"不要这样做"案例。理解为什么从开源 PR 直接转换的评测任务会存在系统性缺陷，对设计新一代基准至关重要。
- **模型选型决策者**: 如果之前基于 SWE-Bench Pro 排名选择编码 Agent 工具，需要重新评估。OpenAI 的审计意味着这些排名可能有高达 30% 的噪声。
- **AI 安全/合规团队**: 审计管线本身（自动化 + Agent + 人类三层验证）是可复用的质量保障模式，适用于其他评测基准的审计。

### 什么场景不值得参考

- **模型性能排序**: 基于有缺陷基准的排名不可信。80.3% 的通过率可能包含了大量缺陷任务的"假阳性"通过。
- **采购决策依据**: 企业如果以 SWE-Bench Pro 分数作为编码 Agent 采购标准，需要寻找替代评测方法。
- **学术研究比较**: 基于 SWE-Bench Pro 的论文结论需要重新验证，特别是那些通过率提升幅度较小的改进。

### 迁移成本

- **从 SWE-Bench Pro 迁移**: 目前尚无官方替代基准。OpenAI 呼吁社区开发由专业开发者从头设计的评测基准。在替代方案出现前，建议：
  - 使用多个基准交叉验证（SWE-Bench Verified + 内部测试集 + 人工审查）
  - 对评测任务进行自己的质量保证审计
  - 将 SWE-Bench Pro 分数视为"上限估计"而非精确度量

## 对你的意义

对 Ken 的 AI 应用开发工作，这个审计有直接含义：

1. **Agent 编码能力评估**: 如果你在评估不同编码 Agent（Claude Code、Codex、Cursor 等）的能力，不要单一依赖 SWE-Bench Pro 分数。OpenAI 自己已撤回推荐。
2. **内部评测体系建设**: 审计中展示的三层验证管线（自动化 + Agent + 人类）是构建可靠内部评测的参考模板。特别是"用模型检查模型"的思路——用更强的模型审计评测任务质量——在 Agent 评估中越来越重要。
3. **对 A-002 的影响**: 假设"A-002: Agentic Coding 在初级任务达 80% 成功率"——如果 SWE-Bench Pro 上 80% 的通过率中有 30% 来自缺陷任务，真实成功率可能只有 50-60%。这个假设需要更严格的验证。

## 关键引用

来自 OpenAI 原文的核心结论：

> "We find evidence of breaking issues in a significant portion of the dataset. Our datapoint analysis pipeline flagged 200 (27.4%) broken tasks, while the human annotation campaign identified 249 (34.1%)."

> "The issues primarily fell into four categories: Overly strict tests, Underspecified prompts, Low-coverage tests, A misleading prompt."

> "Given the issues uncovered in this analysis, we retract our earlier recommendation to adopt SWE-Bench Pro."

> "Ultimately, an eval should provide meaningful signal through benchmarks that are hard to game, easy to trust, and genuinely reflective of model capability or alignment."

来自方法论部分的关键细节：

> "Human reviewers were more likely than the investigator agents to mark tasks as broken... In no flagged task was 'not broken' the most common human label."

> "Tests included in pull requests can be overly strict because they are written to validate a specific change, rather than to define an implementation-agnostic standard for solving the task."

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 挑战 | SWE-Bench Pro 上 80.3% 通过率中约 30% 可能来自缺陷任务，真实成功率可能被严重高估 |
| A-004: 推理模型在 Agent 任务展现持续优势 | 需谨慎 | 如果评测基准本身有 30% 噪声，"优势"幅度的可信度需要重新校准 |

---
[← Back to Deep Dives](./README.md)
