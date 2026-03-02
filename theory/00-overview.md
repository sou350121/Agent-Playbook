# Agentic Engineering 全景：2026 年的工程学地图

> **定位**: 这不是入门教程，也不是学术综述——它是一张坐标图，帮你在混乱的 Agentic 工程领域找到自己所在的位置，以及接下来该读什么。
> **日期**: 2026-03-02

---

**X-Ray 开场**

2026 年，57% 以上的工程团队已把 Agent 部署进生产。最大的瓶颈不再是"能不能做到"，而是"做到之后能不能稳"。Agentic Engineering 正在从实验期进入治理期：失效模式变得可分类，Context 变得可工程化，评估变得可持续——这套知识库记录的，正是这个转型期的系统性认知。

---

## 1. 这个领域在解决什么问题

### 1.1 能力与可信之间的鸿沟

LLM 能写代码、做决策、调用工具——但它能被信任在生产环境中自主运行吗？

早期的答案是"不能"。原因不是模型能力不足，而是**缺乏工程纪律**：没有范围定义、没有故障分类、没有可逆性保证、没有持续评估机制。工程师把 LLM 接入系统，然后祈祷它不出错。

Agentic Engineering 的核心任务，是弥合这条鸿沟：不是让 AI 更聪明，而是让 AI **在可定义的边界内可靠地运行**。

### 1.2 从"AI 作为工具"到"AI 作为被委派的执行者"

这是一个范式跃迁，不只是功能扩展：

| 旧范式：AI 作为工具 | 新范式：AI 作为 Agent |
|---|---|
| 人类执行每一步，AI 辅助 | AI 自主执行多步任务 |
| 调用一次，得到输出 | 持续循环，产生副作用 |
| 错了，人类纠正 | 错了，可能已级联传播 |
| 关注输出质量 | 关注范围、可逆性、问责 |
| Prompt Engineering | Delegation Engineering |

这个转变意味着：工程师不再是"编程者"，而是"委派人（Principal）"。失败时要问的不是"模型哪里错了"，而是"委派设计哪里有缺陷"。（详见 [`delegation-not-automation-engineering-principles`](./03-engineering/delegation-not-automation-engineering-principles.md)）

### 1.3 为什么 2026 年是拐点

三个同步信号：

1. **生产渗透率**: 57%+ 团队已有 Agent 在生产，Gartner 预测 2026 年末 40% 企业应用将内嵌 Agent。这意味着"能不能用"不再是问题，"出了问题怎么办"成为主题。

2. **主要障碍从可行性变为质量**: 早期障碍是"做不到"，现在首要障碍是**质量（32%）**，其次才是延迟和安全。治理需求替代了探索需求。

3. **故障模式已可分类**: T1–T6 故障分类学（见 [`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md)）的出现，标志着 Agentic 系统失效从"玄学"进入"工程学"——可描述的故障模式才能被流程吸收。

---

## 2. 三个核心张力：这个知识库的知识脊梁

所有 Agentic Engineering 的工程决策，都在三个核心张力之间做取舍。理解这三个张力，才能理解为什么各模块的文章要回答那些问题。

### 张力总览

| 张力 | 两极 | 工程杠杆 | 核心文章 |
|---|---|---|---|
| A. 委托 vs. 自动化 | 人为主体 ↔ 系统为主体 | Task Packet、范围定义 | `delegation-not-automation` |
| B. 能力 vs. 可控性 | 更强的 Agent ↔ 更安全的系统 | 信任分层、护栏 | `trust-tier-design`, `01-physical-rails` |
| C. 速度 vs. 可靠性 | 快速迭代 ↔ 稳定交付 | 评估环路、Ralph Loop | `eval-loop-as-production-practice` |

---

### 张力 A：委托 vs. 自动化

这是最根本的区别，也最容易被忽视。

**自动化**（Automation）替代人的角色：规则确定、人退出流程、系统自主运行。流水线是自动化的典型。

**委托**（Delegation）保留人作为委派人（Principal）：人定义范围、人负责结果、人验收交付。Agent 是执行者，不是决策主体。

工程含义：

```
自动化设计问题："这个流程如何不需要人就能运行？"
委托设计问题："这个任务的授权边界在哪里？谁对结果负责？"
```

当你把委托设计成自动化——范围没有定义、没有授权记录、没有人验收——就产生**责任真空**。Agent 出了问题，没有人能说清楚"这在授权范围之内还是之外"。这正是 T1（范围泄漏）故障的根源。

**工程实现**: Task Packet 的 `scope.in` / `scope.out` / `constraints` 三字段，是委托合同的最小化编码。没有这三个字段的任务，是工程上不完整的委托。

---

### 张力 B：能力 vs. 可控性

更强的 Agent（更大的上下文窗口、更复杂的工具调用链、更多的自主决策）= 更高的 T1 和 T6 风险。

这不是一个需要"解决"的矛盾，而是需要**明确管理**的权衡。信任分层矩阵（Trust Tier Matrix）是管理这个张力的主要工具：

| 信任层级 | 权限范围 | 审查要求 | 适用场景 |
|---|---|---|---|
| T0（最高信任）| 可执行不可逆操作 | 双人审查 | 生产部署、数据删除 |
| T1（高信任）| 可写入生产系统 | 单人审查 + 回滚计划 | 代码合并、配置变更 |
| T2（中信任）| 可读写沙箱环境 | 自动化门控 | 开发环境操作 |
| T3（低信任）| 只读 + 草稿输出 | 异步人工审查 | 内容生成、分析 |

信任层级越低的操作，Agent 的自主性空间越小——这是有意为之，不是对 Agent 能力的不信任，而是对**后果不对称性**的工程响应。

物理护栏（`01-physical-rails`）在此基础上提供机械性保障：文件系统沙箱、网络限制、不可逆操作拦截——这些比 Prompt 约束更可靠，因为它们不依赖模型遵从指令。

---

### 张力 C：速度 vs. 可靠性

"快速迭代"和"稳定交付"在传统软件工程中已是张力，在 Agentic 系统中被放大：Agent 的非确定性输出意味着即使代码没变，行为也可能悄悄漂移。

**错误的解法**: 在 CI 里加几条 Agent 测试，测过就发。
**正确的解法**: 评估环路（Eval Loop）作为**持续生产实践**，不是一次性测试。

关键区别：

```
测试（Testing）: 验证特定输入下的特定输出是否正确
评估（Eval）:   持续监测 Agent 行为是否在可接受的分布内
```

Ralph Loop（见 [`05-ralph-loop-iteration-paradigm`](./03-engineering/05-ralph-loop-iteration-paradigm.md)）提供了将速度和可靠性协调的迭代节奏：短任务包 → 执行 → 检查点验证 → 下一个任务包。每个检查点都是一个可评估、可回滚的锚点。

---

## 3. 六大模块的知识地图

### 模块关系图

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                   │
│   [01-principles]  ──→  [02-agent-design]  ──→  [03-engineering] │
│    底层理论                  系统设计                工程实战      │
│    "LLM 是什么"             "如何架构"               "如何治理"    │
│        ↑                        ↑                       ↓         │
│   [06-frontier]           [04-paradigm]           [05-strategy]  │
│    前沿扩展                  范式背景                 战略应用      │
│    "未来走向"               "为什么转变"             "如何生存"    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘

阅读路径: 新手 → 01→04→02→03→05
          工程师 → 03→02→01（按需）
          管理者/策略 → 04→05→03（摘要）
          研究者 → 01→06→03→02
```

---

### 01-principles：底层原理

**核心问题**: LLM 是如何"思考"的？其不确定性的来源是什么？何为"智能"？

理解 LLM 的推理机制——贝叶斯估计、潜空间推理、RLVR 下的 jagged intelligence——不是为了学术兴趣，而是为了在工程决策时有正确的心智模型：知道模型在哪些任务上天然可靠，在哪些情况下会产生系统性偏差。

**连接关系**:
- 为 `02-agent-design` 提供理论基础：知道 LLM 的边界才能正确设计 Agent 的记忆系统和工具选型
- 为 `03-engineering` 的故障分类（T2 上下文漂移、T5 语义回归）提供机制解释
- `06-frontier` 的世界模型、具身 AI 研究，在很大程度上是本模块理论的延伸

**关键文章**:
- [`agent-mental-model`](./01-principles/agent-mental-model.md): Agent = LLM（大脑）+ Tools（四肢），开发者即管理者——最重要的心智模型重置，适合所有读者
- [`bayesian-estimation-and-uncertainty`](./01-principles/bayesian-estimation-and-uncertainty.md): LLM 输出的不确定性如何量化和处理
- [`latent-space-reasoning`](./01-principles/latent-space-reasoning.md): 解释为什么 CoT 有效，以及 Chain Failure 的深层机制
- [`jagged-intelligence-rlvr`](./01-principles/jagged-intelligence-rlvr.md): 为什么 Agent 在某些任务上极强、某些任务上意外脆弱

**适合谁**: 所有角色都应读 `agent-mental-model`；对推理机制好奇的工程师和研究者读完整模块。

---

### 02-agent-design：系统设计

**核心问题**: 如何把 LLM 能力和工具调用组合成一个可靠的 Agent 系统？如何设计多 Agent 协作？

这个模块处于理论和工程之间：它不讲"LLM 是什么"，也不讲"怎么治理"，而是回答"如何设计一个在架构层面就减少故障概率的 Agent"。

**连接关系**:
- 依赖 `01-principles` 的心智模型：只有理解 LLM 的上下文依赖特性，才能正确设计记忆系统
- 向 `03-engineering` 输送设计决策：Agent 的编排架构决定了哪些护栏是必要的
- 与 `04-paradigm` 相互印证：Vibe Coding 和 Software 3.0 的范式转变，直接影响 Agent 的角色设计

**关键文章**:
- [`agent-memory-system-short-to-long`](./02-agent-design/agent-memory-system-short-to-long.md): 短期记忆（上下文窗口）→ 长期记忆（向量存储/外部知识库）的工程化路径
- [`agentic-orchestration-meta-system`](./02-agent-design/agentic-orchestration-meta-system.md): 多 Agent 系统的编排模式，从链式到状态机
- [`skill-vs-mcp-architecture`](./02-agent-design/skill-vs-mcp-architecture.md): Skill（内置能力）vs. MCP（外部协议）的架构权衡
- [`agent-ui-api-design-patterns`](./02-agent-design/agent-ui-api-design-patterns.md): Agent 与人类的交互接口设计，避免"黑箱感"

**适合谁**: 系统架构师、技术负责人、需要设计 Agent 协作流程的工程师。

---

### 03-engineering：工程实战 ⭐ 核心模块

**核心问题**: 如何让 Agent 在生产环境中可靠、可治理、可持续地运行？

这是知识库中最大的模块（34 篇），也是最有工程密度的模块。它的三个支柱——**A. 护栏 / B. Context 工程 / C. 评估迭代**——对应了生产 Agentic 系统最常见的三类工程挑战。

**三支柱结构**:

```
支柱 A：护栏体系（防止 Agent 越界）
├── 01-physical-rails         物理隔离：文件系统、网络、不可逆操作拦截
├── 02-logical-contracts      逻辑约束：AGENT_CONSTITUTION、scope 定义
├── 03-process-governance     流程治理：审查节点、委派人制度
└── 04-automated-enforcement  自动化门控：CI 集成、静态分析

支柱 B：Context 工程（防止 Agent 迷路）
├── context-engineering-field-guide    Context 的完整工程化框架
├── 05-adr-mind-palace                 决策记录作为 Agent 上下文锚点
└── agentic-coding-doc-engineering     文档即 Context 的工程实践

支柱 C：评估迭代（防止 Agent 悄悄变差）
├── eval-loop-as-production-practice   评估环路作为持续生产实践
├── 06-agent-evals-playbook            评估指标设计和基准建立
└── 05-ralph-loop-iteration-paradigm   迭代节奏：短任务包 + 检查点验证
```

**连接关系**:
- 是整个知识库的"应用层"：前五个模块的所有理论，最终都需要在这里落地
- `trust-tier-design` 和 `delegation-not-automation` 是本模块的核心概念文章，与 `02-agent-design` 深度交叉

**关键文章（必读）**:
- [`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md): T1–T6 故障分类，是整个工程实践的起点——**所有生产团队必读**
- [`context-engineering-field-guide`](./03-engineering/context-engineering-field-guide.md): Context 工程的完整框架，Repo Map + Task Packet + Context Decay 处理
- [`delegation-not-automation-engineering-principles`](./03-engineering/delegation-not-automation-engineering-principles.md): 委托 vs. 自动化的工程原则，架构设计的根基
- [`trust-tier-design`](./03-engineering/trust-tier-design.md): 信任分层矩阵，权限治理的核心工具
- [`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md): 评估不是测试，是持续生产实践

**适合谁**: 所有构建生产级 Agent 系统的工程师；CTO 和技术负责人重点读 `agent-failure-taxonomy` + `trust-tier-design`。

---

### 04-paradigm：范式转变

**核心问题**: 软件工程正在经历什么根本性的范式转变？为什么这些转变是不可逆的？

这个模块提供**背景脉络**，不是操作指南。它解释为什么 Agentic Engineering 的出现是必然的——从 Vibe Coding 的个人体验，到 Software 3.0 的系统性表述，到"为 AI 设计而非为人类设计"的产品哲学转变。

**连接关系**:
- 是理解 `03-engineering` 中许多设计决策的"为什么"：为什么要委托而非自动化？因为 Software 3.0 中人类主体性的定位发生了变化
- 与 `05-strategy` 强关联：范式转变带来的职业和组织冲击，在策略模块里详细展开
- 与 `02-agent-design` 互动：Intent-Driven 设计模式是 Vibe Coding 范式在系统设计层面的映射

**关键文章**:
- [`vibe-coding-paradigm`](./04-paradigm/vibe-coding-paradigm.md): 从"指令驱动"到"意图驱动"，Vibe Coding 的范式起点
- [`anthropic-agentic-coding-trends-2026`](./04-paradigm/anthropic-agentic-coding-trends-2026.md): 2026 年 Agentic 编码的全景趋势分析
- [`intelligence-as-a-resource`](./04-paradigm/intelligence-as-a-resource.md): 智能作为可调度资源的经济学含义
- [`not-designing-for-humans-paradigm`](./04-paradigm/not-designing-for-humans-paradigm.md): 当 Agent 成为主要用户，产品设计原则如何改变

**适合谁**: 技术领导者、产品经理、需要向非技术受众解释"为什么我们要做这个转型"的工程师。

---

### 05-strategy：战略生存

**核心问题**: 在 Agentic Engineering 时代，个人工程师、团队、组织如何做出正确的战略决策？

这个模块最接近"现实世界的应用"：职业转型路径、组织角色重设计、分发和变现策略。它不讲工程细节，讲**在宏观范式转变中如何定位自己**。

**连接关系**:
- 依赖 `04-paradigm` 的范式判断作为前提假设
- 与 `03-engineering` 中的 `agentic-org-chart-design`（Agent 原生组织架构）强关联
- `agent-native-org-roles` 是连接个人策略和组织策略的桥梁文章

**关键文章**:
- [`agent-native-org-roles`](./05-strategy/agent-native-org-roles.md): Agent 时代的组织角色重新定义——谁被替代，谁被放大，谁出现新的
- [`backend-engineer-roadmap-evolution`](./05-strategy/backend-engineer-roadmap-evolution.md): 后端工程师在 Agentic 时代的能力演进路径
- [`intelligence-arbitrage-strategy`](./05-strategy/intelligence-arbitrage-strategy.md): 用 AI 能力套利的商业逻辑和时间窗口
- [`reconstructing-engineering-mindset`](./05-strategy/reconstructing-engineering-mindset.md): 工程思维的底层重构：从执行到委托

**适合谁**: 希望做职业规划的个人工程师；需要重设组织结构的 CTO；做 AI-native 产品战略的创始人。

---

### 06-frontier：前沿研究

**核心问题**: Agentic Engineering 的边界正在往哪里扩展？物理世界、多模态、跨领域融合的下一个研究节点在哪里？

这个模块是"信号站"而非"指南"——它记录当前尚未工程化的研究前沿，帮助工程团队提前感知技术轨迹，为未来的架构决策预留空间。

**连接关系**:
- 是 `01-principles` 的未来延伸：世界模型、具身 AI 是潜空间推理在物理世界的投影
- 与 `02-agent-design` 存在前向连接：今天的前沿研究，两年后会成为 Agent 设计的新组件

**关键文章**:
- [`embodied-ai-economic-agents`](./06-frontier/embodied-ai-economic-agents.md): 具身 AI 与经济 Agent 的融合路径
- [`1x-world-model-paradigm`](./06-frontier/1x-world-model-paradigm.md): 世界模型的工程含义——不只是"更好的 LLM"
- [`spatial-intelligence`](./06-frontier/spatial-intelligence.md): 空间智能作为下一代 Agent 的感知基础

**适合谁**: 研究导向的工程师、AI 基础设施团队、关注 3–5 年技术趋势的架构师。

---

## 4. 六个核心框架：跨模块的知识锚点

这是知识库中使用频率最高的六个框架。每当你面对具体的工程决策，这六个框架应该是第一反应层。

---

### 框架 1：T1–T6 故障分类法

**出处**: [`agent-failure-taxonomy`](./03-engineering/agent-failure-taxonomy.md)

**一句话**: 一旦故障模式可以被命名，它就能被工程流程吸收。

| 类型 | 名称 | 核心特征 | 预防方法 |
|---|---|---|---|
| T1 | 范围泄漏 | Agent 修改了 scope.out 内的文件 | 物理护栏 + scope 定义 |
| T2 | 上下文漂移 | 长会话中遗忘早期约束 | Context Refresh + 检查点 |
| T3 | API 契约误读 | 错误理解工具 schema | Spec-First 工具定义 |
| T4 | 边界条件缺失 | edge case 未覆盖 | Eval 套件 + 压力测试 |
| T5 | 语义回归 | 测试通过但行为语义被破坏 | 语义评估（非结构化 Eval）|
| T6 | 多 Agent 链式失效 | 上游错误在下游被放大 | DAG 检查点 + 上游验证门 |

**使用方式**: 每次 Agentic 系统上线前，对照 T1–T6 做逐项风险评估。不是每种都能完全消除，但都应该有应对策略。

---

### 框架 2：Context 工程三要素

**出处**: [`context-engineering-field-guide`](./03-engineering/context-engineering-field-guide.md)

**一句话**: Context 是基础设施，不是 Prompt 技巧。

三要素结构：

```
Context 工程
├── Repo Map（空间导航）
│   └── 让 Agent 知道"项目的结构是什么"
│       文件树 + 关键模块说明 + 依赖关系摘要
│
├── Task Packet（任务授权）
│   └── 让 Agent 知道"这次任务的边界和约束是什么"
│       scope.in / scope.out / constraints / rollback_plan
│
└── Context Decay 处理（时间导航）
    └── 让 Agent 在长会话中不迷路
        Context Refresh 节点 / AGENT_CONSTITUTION 周期性重注入
```

**关键洞察**: Context Decay（上下文衰减）是 T2 故障的直接原因。工程上的应对不是用更大的上下文窗口，而是主动设计 Context 刷新机制。

---

### 框架 3：委托设计契约

**出处**: [`delegation-not-automation-engineering-principles`](./03-engineering/delegation-not-automation-engineering-principles.md)

**一句话**: 没有 scope.out 的委托，是工程上不完整的委托。

最小化委托契约（Task Packet 的核心字段）：

```json
{
  "task_id": "task-2026-03-02-auth-refactor",
  "principal": "engineer@team.com",
  "scope": {
    "in": ["src/auth/"],
    "out": ["src/db/", "tests/e2e/", "package.json"]
  },
  "constraints": [
    "不得新增外部依赖",
    "不得修改公开 API 函数签名",
    "所有变更必须通过现有测试套件"
  ],
  "reversibility": "full",
  "review_required_by": "engineer@team.com"
}
```

委托契约的四个工程要求：范围明确、责任归属、可逆性设计、验收标准。缺少任何一个，都是委托设计的漏洞。

---

### 框架 4：信任分层矩阵

**出处**: [`trust-tier-design`](./03-engineering/trust-tier-design.md)

**一句话**: 权限不是按"Agent 能力"分配，而是按"操作后果的不可逆程度"分配。

分层原则：

- **后果越不可逆** → 信任层级越低 → 审查要求越高 → Agent 自主性越小
- **后果越可逆** → 信任层级可以更高 → 可以更多自主执行

常见错误：给"聪明的 Agent"更高权限。正确逻辑：给"后果可逆的操作"更高自主权。

这个框架和 T1（范围泄漏）直接关联：信任层级定义了 scope.out 的操作集合。

---

### 框架 5：评估环路

**出处**: [`eval-loop-as-production-practice`](./03-engineering/eval-loop-as-production-practice.md)

**一句话**: Eval 是持续生产实践，不是上线前的一次性测试。

测试 vs. 评估的核心区别：

```
测试（Testing）:
  "给定输入 X，输出是否等于 Y？"
  → 确定性验证，适合传统软件
  → Agent 的非确定性使其不充分

评估（Eval）:
  "Agent 的行为分布是否在可接受范围内？"
  → 统计性验证，适合 Agentic 系统
  → 需要持续运行，不只是上线前
```

生产级 Eval 的三个组成部分：
1. **黄金数据集（Golden Set）**: 代表真实工作负载的基准案例
2. **行为指标（Behavioral Metrics）**: CLASSic 框架——Cost, Latency, Accuracy, Security, Stability
3. **漂移检测（Drift Detection）**: 同样的任务，输出分布是否在随时间变化？

---

### 框架 6：Agent 心智模型

**出处**: [`agent-mental-model`](./01-principles/agent-mental-model.md)

**一句话**: 把 Agent 当"被委派的员工"思考，而非"被配置的程序"。

```
旧心智模型（编程思维）:
  "我需要告诉 Agent 每一步怎么做"
  → 导致过度 Prompt 工程
  → 导致 Agent 变成脆弱的状态机

新心智模型（管理思维）:
  "我需要定义 Agent 的职责、权限、验收标准"
  → 导致更好的 Task Packet 设计
  → Agent 有更大的自主空间完成目标
```

这个心智模型的切换，是理解整个 Agentic Engineering 知识库最重要的一步。所有其他框架，都建立在"开发者是管理者/委派人"这个基础认知上。

---

## 5. 2026 年的现状：已解决 vs. 仍待攻克

| 维度 | 已解决 / 成熟 | 仍然困难 |
|---|---|---|
| **基础能力** | 上下文窗口（100K+）、基础工具调用 | 跨 Agent 状态一致性 |
| **编排架构** | 链式 Agent、有向无环图（DAG）编排 | 开放式多 Agent 循环的可靠性 |
| **可观测性** | 工具调用追踪、日志结构化（89% 覆盖）| 在线语义评估（仅 37–44% 覆盖）|
| **护栏机制** | 物理护栏、逻辑合约的工程化方案 | 跨信任边界的动态权限协商 |
| **故障分类** | T1–T6 可命名、可预防 | T6（链式失效）的自动化恢复 |
| **Context 管理** | Repo Map、Task Packet 标准化 | Context Rot（长期项目的上下文腐化）|
| **评估实践** | 离线 Eval 管道、黄金数据集方法论 | 实时生产评估、语义漂移自动检测 |
| **人机协作** | 委托模型、审查节点设计 | Agent-to-Agent 委托链的问责机制 |

**最重要的两个未解问题**（值得持续关注）：

1. **跨 Agent 上下文对齐**: 当 Agent A 的输出成为 Agent B 的输入，如何保证语义在传递中不失真？这是 T6 故障的根本机制，目前没有系统性解法，只有局部缓解手段（上游验证门、结构化中间格式）。

2. **Context Rot**: 长期运行的 Agent 系统（数周到数月），其"项目理解"会随着代码库演化而衰减。Repo Map 是静态快照，不是动态感知——这个问题需要更主动的上下文维护机制。

---

## 6. 如何使用这个知识库

这不是一本线性阅读的教科书。它是一个**按问题索引的参考体系**——当你面对具体的工程挑战，带着问题来找答案。

### 按问题类型的入口

| 我在遇到的问题 | 推荐入口文章 | 所在模块 |
|---|---|---|
| Agent 修改了不该修改的文件 | `agent-failure-taxonomy` (T1) | 03-engineering |
| 长会话后 Agent "忘记"了约束 | `context-engineering-field-guide` | 03-engineering |
| 不知道给 Agent 多少权限 | `trust-tier-design` | 03-engineering |
| 多个 Agent 协作时出错 | `agent-failure-taxonomy` (T6) + `agentic-orchestration-meta-system` | 03-engineering + 02-agent-design |
| 测试通过但行为感觉不对 | `eval-loop-as-production-practice` | 03-engineering |
| 如何设计 Agent 的任务边界 | `delegation-not-automation-engineering-principles` | 03-engineering |
| 想理解 Agent 的基本工作原理 | `agent-mental-model` | 01-principles |
| 想规划 Agentic 时代的职业方向 | `agent-native-org-roles` + `reconstructing-engineering-mindset` | 05-strategy |
| 想理解为什么要做范式转型 | `vibe-coding-paradigm` + `anthropic-agentic-coding-trends-2026` | 04-paradigm |
| 想了解未来 3–5 年的技术方向 | `1x-world-model-paradigm` + `embodied-ai-economic-agents` | 06-frontier |
| 刚接触这个领域，不知从哪开始 | `00-glossary-for-beginners` + 本文 | 03-engineering + theory/ |

### 文章之间的知识图谱

知识库内的文章不是独立条目——它们形成了一个引用网络。关键连接：

```
agent-mental-model
    └─→ delegation-not-automation
            └─→ context-engineering-field-guide
                    └─→ agent-failure-taxonomy (T1, T2)
                    └─→ trust-tier-design
                            └─→ 01-physical-rails
                            └─→ 02-logical-contracts
    └─→ eval-loop-as-production-practice
            └─→ 06-agent-evals-playbook
            └─→ 05-ralph-loop-iteration-paradigm
```

核心阅读顺序（最小完整路径，约 5 篇）：
1. `agent-mental-model` — 重置心智模型
2. `delegation-not-automation` — 理解委托与自动化的根本区别
3. `agent-failure-taxonomy` — 知道会出什么错
4. `context-engineering-field-guide` — 知道如何管理上下文
5. `eval-loop-as-production-practice` — 知道如何持续保证质量

---

## 7. 结语

Agentic Engineering 的承诺不是 AI 替代工程师，而是**纪律性的委托创造新型工程杠杆**。

当你把 Agent 设计为被委派的执行者——有明确的范围授权、可分类的故障模式、可工程化的上下文管理、持续运行的评估环路——你不是在失去控制权，而是在**用更高阶的方式行使控制权**：定义"什么值得做"和"边界在哪里"，而不是"每一步怎么做"。

这正是 Software 3.0 的核心命题：人类提供意图和判断，AI 在有治理的结构中自主执行——不是因为 AI 更聪明，而是因为有了足够的工程纪律，这种分工才变得安全。

这套知识库是这个工程学科的地图——不完整，但在持续演进。地图的价值不在于完备，而在于当你迷失在具体问题中时，帮你找回坐标。

---

> **导航**: [theory/ 模块索引](./README.md) | [工程实战 03-engineering](./03-engineering/) | [系统设计 02-agent-design](./02-agent-design/) | [范式转变 04-paradigm](./04-paradigm/)
>
> **关键文章直链**: [Agent 失效分类法](./03-engineering/agent-failure-taxonomy.md) · [Context 工程指南](./03-engineering/context-engineering-field-guide.md) · [委托工程原则](./03-engineering/delegation-not-automation-engineering-principles.md) · [信任分层设计](./03-engineering/trust-tier-design.md) · [评估环路](./03-engineering/eval-loop-as-production-practice.md)
