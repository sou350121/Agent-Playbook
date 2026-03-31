---
auto_generated: true
generated_at: "2026-03-31T05:46:23Z"
source_url: "https://simonwillison.net/2026/Mar/25/thoughts-on-slowing-the-fuck-down/"
signal_type: "significant_update"
---
# Simon Willison：当前 Agentic Engineering 走得太快，应慢下来 (Thoughts on Slowing the Fuck Down)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-31
>
> **项目/工具**: Simon Willison 博客 / Mario Zechner (Pi 框架作者) 观点
> **链接**: https://simonwillison.net/2026/Mar/25/thoughts-on-slowing-the-fuck-down/
> **核心定位**: 对当前 Agent 工程盲目追求自动化速度的批判性反思，提出「认知债务」概念与降速建议

---

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Pi 框架作者 Mario Zechner 批判当前 Agent 工程放弃纪律追求速度，Simon Willison 引申提出「认知债务」警告
- **现在值得用吗**: 这是观点文章而非工具更新——**值得读**，尤其是正在用 Agent 写代码的开发者
- **适合场景**: 团队引入 Agent 辅助编程、个人使用 Cursor/Claude Code 等工具、担心代码质量失控
- **不适合场景**: 纯理论学习、不实际写代码的研究者
- **与 [竞品/前版] 核心差异**: 这是少数从「工程风险」而非「效率提升」角度讨论 Agent 编程的声音

---

## 是什么 / 解决什么问题

2026 年 3 月 25 日，知名开发者博客作者 Simon Willison 发表了一篇链接博文，引用了 Pi Agent 框架创作者 Mario Zechner 对当前 Agentic Engineering 趋势的尖锐批评。

**背景痛点**：

当前 AI 辅助编程工具（Cursor、Claude Code、OpenCode 等）和 Agent 框架（Pi、LangGraph、AutoGen 等）的核心卖点都是「更快写出更多代码」。营销话术通常是「10x 工程师」、「几分钟生成整个应用」、「让 AI 处理繁琐部分」。

但 Mario Zechner 提出了一个被忽视的问题：**当代码生成速度远超人类理解速度时，会发生什么？**

**这次讨论的核心**：

不是某个具体工具的更新，而是对整个 Agentic Engineering 发展方向的反思。Mario 指出：

> We have basically given up all discipline and agency for a sort of addiction, where your highest goal is to produce the largest amount of code in the shortest amount of time. Consequences be damned.

Simon Willison 在此基础上提出了「**Cognitive Debt**（认知债务）」概念——当代码库的演化速度超过开发者心智建模能力时，积累的隐性技术债务。

这篇文章解决的不是技术问题，而是**工程哲学问题**：在 AI 让代码生成变得极其便宜的时代，什么才是值得追求的工程目标？

---

## 技术架构拆解

### 核心设计决策

Mario 和 Simon 的观点可以拆解为以下几个关键设计决策：

| 决策点 | 当前主流做法 | Mario/Simon 建议 |
|--------|-------------|-----------------|
| 代码生成速度 | 越快越好，无上限 | 设置每日生成上限，匹配审查能力 |
| 人类参与度 | 最小化人类干预 | 保持人类在环路中 (human-in-the-loop) |
| 架构/API 设计 | 可用 AI 生成 | **必须手写** (write it by hand) |
| 成功指标 | 产出代码行数/功能数 | 代码可理解性/可维护性 |
| 错误处理 | 依赖 AI 修复 | 人类主动审查 + 限制错误积累速度 |

### 与前版/竞品的关键差异

当前 Agent 工程话语体系 vs Mario/Simon 的批判视角：

| 维度 | 主流 Agent 工程叙事 | Mario/Simon 批判视角 |
|------|-------------------|---------------------|
| 瓶颈假设 | 人类打字慢是瓶颈 | 人类理解力才是瓶颈 |
| 错误成本 | 错误可以快速修复 | 错误会复合积累 (compound) |
| 速度价值 | 速度 = 生产力 | 无纪律的速度 = 技术债务加速器 |
| 人类角色 | 人类是拖慢速度的环节 | 人类是质量控制的最后防线 |
| 代码所有权 | AI 生成的代码也是代码 | 不理解代码 = 失去对代码的掌控 |

### 核心问题链条（ASCII 图）

```
┌─────────────────────────────────────────────────────────────┐
│  当前 Agent 工程的危险循环                                    │
└─────────────────────────────────────────────────────────────┘

[AI 生成代码] → [人类来不及审查] → [代码合并]
      ↑                                  │
      │                                  ↓
      │                          [认知债务积累]
      │                                  │
      │                                  ↓
      │                          [代码库超出理解范围]
      │                                  │
      └──────────────────────────[问题爆发时已太晚]←┘

┌─────────────────────────────────────────────────────────────┐
│  Mario 建议的降速循环                                        │
└─────────────────────────────────────────────────────────────┘

[设置每日代码生成上限] → [人类审查每行生成代码]
         ↓                        │
         │                        ↓
   [架构/API 手写] ←─────── [保持理解力同步]
         ↓
   [可持续的代码库演化]
```

---

## 实用评估

### 什么场景值得用

**1. 团队引入 Agent 辅助编程初期**

如果团队刚开始用 Cursor/Claude Code 等工具，这篇文章是必读的「预防针」。在建立工程规范时就纳入「降速」原则，比后期修复认知债务成本低得多。

**2. 个人开发者感到「代码失控」**

如果你发现自己经常合并 AI 生成的代码但不完全理解其实现，或者代码库变得难以调试——这是认知债务的早期信号。Mario 的建议可以直接应用：

- 设置每日 AI 生成代码审查上限（例如 500 行/天）
- 核心架构代码坚持手写
- 每次合并前强制自己解释代码逻辑

**3. Agent 框架设计者**

如果你在设计 Agent 协作系统（如多 Agent 编排），Mario 的警告尤其重要：**多 Agent 系统的错误复合速度远超单 Agent**。需要在框架层面设计「降速机制」，例如：

- 强制人类确认关键决策点
- 限制并行 Agent 数量
- 自动生成代码变更摘要供审查

### 什么场景不值得用

**1. 原型/一次性脚本**

如果是快速验证想法的原型代码（预期寿命<1 周），认知债务不是问题。速度优先是合理选择。

**2. 纯数据/配置生成**

如果 AI 生成的是数据文件、配置文件、样板代码（boilerplate），而非核心业务逻辑，审查成本较低，可以放宽限制。

**3. 已有严格 Code Review 流程的团队**

如果团队已有强制 Code Review 且审查质量高，AI 生成代码会经过人类审查，认知债务风险已得到控制。但仍需注意审查者是否真正理解 AI 生成的代码。

### 迁移成本

从「无限制 AI 生成」迁移到「降速模式」的成本：

| 变更项 | 工作量 | 说明 |
|--------|--------|------|
| 设置每日代码生成上限 | 低 | 团队约定或工具配置 |
| 架构代码手写政策 | 中 | 需明确定义什么是「架构代码」 |
| 强制审查流程 | 中 - 高 | 取决于当前流程成熟度 |
| 代码理解文档 | 中 | 要求 AI 生成代码附带解释文档 |

**预估迁移时间**：小团队 1-2 周建立规范，大团队 1-2 月落地。

---

## 对你的意义

### 对 Ken 的 Agent-Playbook 项目的启示

你正在构建的 Agent-Playbook 是记录 Agent 工程最佳实践的知识库。这篇文章提出了一个**元问题**：最佳实践应该包含「何时不用 Agent」和「如何限制 Agent」的指南。

**具体建议**：

1. **在 Handbook 中新增「降速模式」章节**
   - 记录认知债务的早期信号
   - 提供可操作的降速策略模板
   - 收录类似 Mario 的批判性观点

2. **重新审视现有的 Agent 模式**
   - 检查是否有模式鼓励无限制代码生成
   - 为高风险模式（如多 Agent 并行）添加警告标签

3. **在 AI Daily Pick 中纳入批判性声音**
   - 当前信息流偏向「新工具/新功能」
   - 应平衡纳入「反思/警告」类内容

### 对 VLA 研究的间接启示

虽然这是 Agent 工程领域的讨论，但对 VLA（Vision-Language-Action）系统有相似启示：

- VLA 训练中是否也存在「训练速度 > 理解速度」的问题？
- 当模型生成动作序列时，是否有机制防止错误复合？
- 「认知债务」概念是否可以迁移到「模型行为可解释性」领域？

**建议**：在 VLA Handbook 的 theory 部分记录这个跨领域类比。

### 个人行动建议

| 行动 | 优先级 | 时间投入 |
|------|--------|----------|
| 阅读 Mario 原文（Pi 框架 GitHub） | 高 | 30 分钟 |
| 在 Agent-Playbook 创建「降速工程」条目 | 高 | 1 小时 |
| 审查当前项目中的 AI 生成代码比例 | 中 | 2 小时 |
| 设计个人代码生成上限规则 | 中 | 30 分钟 |
| 在下次 AI Deep Dive 中追踪相关讨论 | 低 | - |

**总体判断**：这篇文章的价值不在于具体技术方案，而在于**提供了一个被忽视的视角**。在所有人都鼓吹「更快」时，有人提醒「慢下来」——这种声音值得认真对待。

---

## 关键代码/配置片段

Mario 在原文中没有提供具体代码，但提出了可操作的原则。以下是基于其建议的**伪代码实现示例**：

```python
# 示例：在 Agent 编程工作流中实施「降速」限制

class SlowingDownAgent:
    def __init__(self, daily_code_limit=500):
        self.daily_limit = daily_code_limit
        self.daily_generated = 0
        self.architecture_paths = ['src/arch/', 'src/api/', 'src/core/']
    
    def can_generate(self, file_path, estimated_lines):
        # 规则 1: 架构代码禁止 AI 生成
        if any(path in file_path for path in self.architecture_paths):
            return False, "架构代码必须手写"
        
        # 规则 2: 检查每日额度
        if self.daily_generated + estimated_lines > self.daily_limit:
            return False, f"超出每日限制 (已用{self.daily_generated}/{self.daily_limit})"
        
        return True, "允许生成"
    
    def after_generation(self, code_lines):
        self.daily_generated += len(code_lines)
        # 强制记录：要求 AI 生成代码解释
        return self.generate_explanation(code_lines)
```

```markdown
# 示例：Code Review 清单（AI 生成代码专用）

## AI 生成代码审查清单

- [ ] 我理解这段代码的核心逻辑吗？
- [ ] 我能向同事解释为什么这样实现吗？
- [ ] 这段代码引入了新的依赖吗？是否必要？
- [ ] 错误处理是否充分？
- [ ] 是否有隐藏的边界情况？
- [ ] 如果 AI 错了，调试成本有多高？

**规则**：任一问题回答「否」→ 拒绝合并，要求重写或人工实现
```

---

## 📌 AI Agent 假设追踪

> 本文不直接关联当前追踪的假设列表（A-001 至 A-006）。但提出了一个**元假设**值得记录：

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-007 (新): 无约束的 Agent 代码生成会导致认知债务积累 | 挑战 | Mario/Simon 的观点直接挑战「Agent 总是提升生产力」的默认假设，提示需要工程约束 |

---

## 参考资源

- [原文：Thoughts on slowing the fuck down - Simon Willison](https://simonwillison.net/2026/Mar/25/thoughts-on-slowing-the-fuck-down/)
- [Pi Agent Framework - GitHub](https://github.com/badlogic/pi-mono)
- [Cognitive Debt 标签 - Simon Willison](https://simonwillison.net/tags/cognitive-debt/)
- [Hacker News 讨论串](https://news.ycombinator.com/item?id=47517539)

---

## 结语

这篇文章的价值不在于提供答案，而在于**提出正确的问题**。

当整个行业都在问「如何让 Agent 写得更快」时，Mario 和 Simon 问的是：「写快了之后，代价是什么？」

这个问题值得每个使用 AI 辅助编程的开发者思考——包括你，包括 Ken，包括正在构建 Agent 框架的每一个人。

慢下来，不是拒绝进步。是为了走得更远。

---
[← Back to Deep Dives](./README.md)
