---
auto_generated: true
generated_at: "2026-07-30T05:47:18Z"
source_url: "https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models"
signal_type: "significant_update"
---
# Claude 5 上下文工程范式重构 (The New Rules of Context Engineering for Claude 5 Generation Models)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-30
>
> **项目/工具**: Claude Code / Claude 5 Generation Models
> **链接**: https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models
> **核心定位**: Anthropic 官方发布 Claude 5 时代的上下文工程指南，宣告 6 条旧规则过时，直接改变所有 Claude Code 和 Agent 开发者的 prompt 写法。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Anthropic 首次系统性地总结 Claude 5 模型与旧版在上下文工程上的范式差异，从"规则+示例+前置"转向"判断+接口设计+渐进式披露"。
- **现在值得用吗**: 是——如果你在用 Claude Code 或基于 Claude 构建 Agent，这篇指南直接决定你的系统是否能发挥模型上限。
- **适合场景**: Claude Code 日常开发、自定义 Agent Harness 构建、CLAUDE.md / Skill.md 体系维护
- **不适合场景**: 使用非 Claude 模型的 Agent 系统（部分原则可借鉴但非原生支持）
- **与前版核心差异**: 旧版依赖大量规则约束和 few-shot 示例补偿模型判断力不足；Claude 5 可以直接理解意图和设计意图，过度约束反而限制能力

## 是什么 / 解决什么问题

Claude Code 自发布以来，社区积累了一套"上下文工程最佳实践"——在 CLAUDE.md 中写大量规则、给模型塞满 few-shot 示例、把所有信息都堆在系统提示最前面。这些做法在早期 Claude 模型上确实有效，但本质上是**用 prompt 工程补偿模型判断力的不足**。

随着 Claude 5 系列模型的能力跃升，Anthropic 发现这些旧实践正在**反噬**模型表现：规则过多限制了模型的灵活性，示例过多约束了探索空间，信息全部前置浪费了上下文窗口。

这篇由 Anthropic MTL Thariq Shihipar 撰写的指南，核心信息只有一个：**Claude 5 已经足够聪明，不需要你把它当傻瓜一样管。** 开发者的精力应该从"写更多规则"转向"设计更好的接口"。

这对所有 Claude Agent 开发者是重大信号——你过去几个月积累的 prompt 技巧，可能正在拖慢你的系统。

## 技术架构拆解

### 核心设计决策

Anthropic 提出了 6 组"Then vs Now"的范式转变：

| # | 旧规则 (Then) | 新规则 (Now) | 核心逻辑 |
|---|--------------|-------------|---------|
| 1 | 给 Claude 规则 | 让 Claude 做判断 | 旧模型需要防最差情况；Claude 5 能权衡上下文 |
| 2 | 给 Claude 示例 | 设计工具接口 | 示例约束探索空间；好的接口设计让模型自主推理 |
| 3 | 所有信息前置 | 渐进式披露 | 按需加载上下文，节省窗口给真正需要的时刻 |
| 4 | 重复强调指令 | 简洁工具描述 | 模型不再受位置偏差影响，指令只需写一处 |
| 5 | 手动记忆到 CLAUDE.md | 自动记忆 | 模型自动识别并保存 relevant context |
| 6 | 简单 Markdown spec | 富引用 (HTML/代码/测试) | 模型能理解更高保真度的引用格式 |

### 关键变化深度分析

#### 1. 规则 → 判断：从防御到信任

旧版系统提示中的经典写法：

```
default to writing no comments. Never write multi-paragraph docstrings
or multi-line comment blocks — one short line max.
```

这种"一刀切"规则防止了旧模型写出大量无意义注释，但也阻止了它在真正需要文档的场景下做出正确判断。

新版只写：

```
Write code that reads like the surrounding code: match its comment density, naming, and idiom.
```

**差异分析**: 旧规则是 28 个 token 的硬性约束，覆盖了模型 100% 的行为但准确率可能只有 80%；新规则是 16 个 token 的原则性指导，依赖模型判断但准确率更高。这是典型的"少即是多"。

#### 2. 示例 → 接口设计：从 few-shot 到类型系统

旧版 tool use 的第一规则是给示例。Anthropic 现在的发现是：**示例把模型限制在示例的探索空间里**。

更好的做法是设计工具的接口本身——比如一个 Todo 工具的 status 字段定义为枚举 `[pending, in_progress, completed]`，并在描述中说明"保持一项为 in_progress"。模型通过接口定义就能理解使用模式，不需要示例。

**对 Agent 开发的启示**: 与其花时间写 tool use 的 few-shot 示例，不如花时间设计 tool 的 schema——参数命名、枚举值、描述文案。接口即文档，文档即 prompt。

#### 3. 前置 → 渐进式披露：从大爆炸到按需加载

这是上下文窗口管理的重大转变。Claude Code 现在使用多种渐进式披露机制：

- **Skills 按需加载**: 代码审查和验证逻辑从主系统提示移到独立 skill，模型需要时才调用
- **Tool Deferred Loading**: 部分工具（如 Task tools）的定义不预先加载，模型通过 ToolSearch 搜索后发现并使用
- **文件树结构**: 不再把所有规则塞进一个 CLAUDE.md，而是组织成可按需加载的文件树

**效果**: 主上下文窗口保持精简，只在需要时加载详细信息。这对长上下文任务（如跨文件重构、大型项目维护）尤其重要。

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Claude 5 Agent System                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐    ┌──────────────────────────────────┐   │
│  │System    │    │         CLAUDE.md                │   │
│  │Prompt    │    │  - Repo 简述 (轻量)               │   │
│  │(产品层)  │    │  - Codebase gotchas (核心)       │   │
│  │          │    │  - 引用 verification skill →     │   │
│  └──────────┘    │  - 引用 custom skill →           │   │
│                  └──────────┬────────────────────────┘   │
│                             │ 渐进式加载                  │
│                  ┌──────────▼────────────────────────┐   │
│                  │        Skills (按需)               │   │
│                  │  - verification.md                │   │
│                  │  - code-review.md                 │   │
│                  │  - team-specific-practices.md     │   │
│                  └──────────┬────────────────────────┘   │
│                             │ 按需加载                   │
│                  ┌──────────▼────────────────────────┐   │
│                  │     References (@提及)              │   │
│                  │  - HTML artifacts (高保真)         │   │
│                  │  - 测试套件 (可执行规范)            │   │
│                  │  - Rubrics (品味验证器)             │   │
│                  └───────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Auto-Memory: 模型自动识别并保存 relevant context  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Tool Deferred Loading: ToolSearch 按需发现工具   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **Claude Code 日常开发**: 如果你每天用 Claude Code 写代码，简化你的 CLAUDE.md 能立即提升输出质量。Anthropic 推出了 `claude doctor` 命令自动帮你做这个简化。
- **企业级 Agent Harness 构建**: 如果你在构建基于 Claude 的自定义 Agent 系统，这篇指南是系统提示设计的必读材料。系统提示层应该花最多时间——不是写更多，而是写更精。
- **团队级 Skill 体系**: 如果你的团队维护一套共享的 CLAUDE.md / Skill.md，渐进式披露的文件树结构能显著降低维护成本。
- **长项目/跨文件重构**: 渐进式披露 + 富引用（HTML artifact、测试套件）让 Claude 在大型项目中表现更稳定。

### 什么场景不值得用

- **非 Claude 模型的 Agent**: 这些规则是 Anthropic 对自家模型的观察。GPT-4/Claude 4 等旧模型可能仍然需要规则和示例。但原则（简洁 > 冗余）可以借鉴。
- **一次性 prompt 任务**: 如果你只是偶尔让 Claude 做翻译或摘要，不需要重构你的上下文策略。
- **极度合规敏感场景**: 如果你的场景需要模型 100% 遵守特定规则（如金融合规、医疗文本），完全放开"让模型判断"可能引入不可接受的风险。这时需要保留部分规则层。

### 迁移成本

| 迁移项 | 工作量 | 说明 |
|--------|--------|------|
| 简化 CLAUDE.md | 1-2 小时 | 用 `claude doctor` 自动分析 + 手动审查 |
| 重构 Skill 文件树 | 半天 | 将 monolithic 文件拆分为按需加载的模块 |
| 重写 tool 描述 | 视工具数量 | 从"描述+示例"改为"接口设计+简洁描述" |
| 移除冗余规则 | 1-2 小时 | 识别并删除不再需要的防御性规则 |

## 对你的意义

这篇指南对 Ken 的两条线都有直接意义：

**AI 应用开发线**:
- 如果你在 Claude Code 中维护了较重的 CLAUDE.md，现在是简化的好时机。`claude doctor` 命令可以自动识别冗余内容。
- "接口设计 > 示例"的原则可以直接应用到 Agent 工具设计中——花时间设计 tool schema 比写 few-shot 示例 ROI 更高。
- 渐进式披露的文件树结构值得引入到 Agent-Playbook 的实践中。

**VLA 研究线**:
- 虽然这篇指南针对 Claude Code，但"从规则到判断"的范式转变对 VLA 系统的策略设计有启发——当模型能力足够强时，过度约束策略空间反而限制性能。这与 VLA 中"减少 hard-coded reward 让模型自主学习"的思路异曲同工。

**建议**: 立即试用 `claude doctor` 分析现有 CLAUDE.md，评估简化空间。不需要全面重写，但可以开始逐步移除那些"以防万一"的规则。

## 关键代码/配置片段

### 旧版 vs 新版系统提示对比

```
# 旧版 (过度约束)
default to writing no comments. Never write multi-paragraph
docstrings or multi-line comment blocks — one short line max.
Don't create planning, decision, or analysis documents unless
the user asks for them — work from conversation context, not
intermediate files.

# 新版 (原则性指导)
Write code that reads like the surrounding code: match its
comment density, naming, and idiom.
```

### Todo 工具接口设计示例（展示"接口即 prompt"）

```json
{
  "name": "Todo",
  "description": "Track tasks throughout the conversation",
  "parameters": {
    "status": {
      "type": "string",
      "enum": ["pending", "in_progress", "completed"],
      "description": "Keep one item in_progress at a time"
    }
  }
}
```

通过枚举定义和一句话描述，模型自动理解使用模式，无需 few-shot 示例。

### CLAUDE.md 简化结构

```
CLAUDE.md              # 入口：repo 简述 + 关键 gotchas
├── skills/
│   ├── verification.md    # 验证规则（按需加载）
│   ├── code-review.md     # 代码审查指南（按需加载）
│   └── team-practices.md  # 团队特定实践（按需加载）
└── specs/
    ├── api-design.md      # API 设计规范
    └── test-rubric.md     # 测试验收标准（rubric）
```

---
[← Back to Deep Dives](./README.md)
