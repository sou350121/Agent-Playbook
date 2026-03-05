---
auto_generated: true
generated_at: "2026-03-05T07:31:59Z"
source_url: "https://simonwillison.net/guides/agentic-engineering-patterns/anti-patterns/"
signal_type: "blog_post"
---
# Simon Willison：Agentic Engineering 反模式指南 (Agentic Engineering Anti-Patterns Guide)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-05
>
> **项目/工具**: Agentic Engineering Patterns (Simon Willison)
> **链接**: https://simonwillison.net/guides/agentic-engineering-patterns/anti-patterns/
> **核心定位**: 系统性总结 AI 编程助手时代的工程反模式——尤其是「把未审查的代码丢给协作者」这一高频痛点

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**：Simon Willison 的 Agentic Engineering Patterns 指南中的「反模式」章节，专门讲 AI 编程时代不该做什么
- **現在值得用嗎**：是——如果你在用 Claude Code/Copilot/Cursor 等工具且需要和他人协作
- **適合場景**：团队开发、开源项目、任何需要 PR review 的场景
- **不適合場景**：纯个人项目、无协作需求的脚本编写
- **與 [競品/前版] 核心差異**：这是第一份系统性总结「AI 编程协作礼仪」的指南，而非工具教程

## 是什么 / 解决什么问题

Simon Willison（Datasette 作者、Python 社区资深开发者）在 2026 年 2 月启动了一个名为「Agentic Engineering Patterns」的项目，系统性记录使用 AI 编程助手（如 Claude Code、OpenAI Codex）时的最佳实践和反模式。

**核心痛点**：AI 让生成代码变得极其便宜，但「生成」不等于「可用」。当开发者用 agent 生成几百行代码后直接开 PR，实际上是把审查工作转嫁给协作者——这是一种新型的技术债务转嫁。

**这次变化的核心**：反模式章节明确定义了什么是「好的 agent PR」：
1. 代码能工作，且你有信心它能工作
2. 变更足够小，便于高效审查
3. PR 包含额外上下文解释变更目的高层目标
4. 包含你手动测试的证据（笔记、截图、视频）

这不仅仅是「代码审查礼仪」——这是 AI 编程时代协作者之间信任机制的重建。

## 技术架构拆解

### 核心设计决策

Simon 的指南采用「模式语言」(Pattern Language) 风格组织，而非传统教程：

| 设计选择 | 理由 |
|----------|------|
| 按场景分类（Principles / Testing / Understanding） | 开发者通常在特定场景下查阅，而非从头读 |
| 每个模式独立成页 | 便于引用和分享，也便于后续更新 |
| 包含「我用的 Prompts」附录 | 提供可复用的具体实践，而非空泛建议 |
| 明确区分「模式」和「反模式」 | 正向引导 + 负向警示双轨并行 |

### 与前版/竞品的关键差异

| 维度 | 传统编程指南 | AI 编程指南（旧） | Agentic Engineering Patterns |
|------|-------------|-----------------|------------------------------|
| 审查责任 | 作者写代码，审查者检查 | agent 写代码，作者直接提交 | **作者必须先审查 agent 输出** |
| PR 大小 | 适中即可 | 越大越好（反正不是人写的） | **小 PR 优先**，agent 可以轻松拆分 commit |
| 上下文 | 代码注释 + commit message | 依赖 agent 生成的 PR 描述 | **人工验证 PR 描述**，补充测试证据 |
| 信任基础 | 作者技术能力 | 工具可靠性 | **作者对 agent 输出的信心** |

### 信息流图

```
传统 PR 流程:
开发者 → 写代码 → 开 PR → 审查者审查 → 合并

AI 反模式流程（❌ 不该做）:
开发者 → prompt agent → 直接开 PR → 审查者被迫审查未验证代码 → 信任损耗

AI 正确流程（✅ 应该做）:
开发者 → prompt agent → 人工审查 + 手动测试 → 补充证据 → 开 PR → 审查者高效审查 → 合并
```

## 实用评估

### 什么场景值得用

1. **团队协作项目**：尤其是开源项目或跨团队项目，审查者时间宝贵
2. **大型重构**：agent 生成的重构代码必须人工验证逻辑等价性
3. **新人 onboarding**：用这份指南作为团队 AI 编程规范的基础
4. **技术负责人**：需要制定团队 AI 使用规范时，这是现成的参考框架

### 什么场景不值得用

1. **纯个人项目**：没有协作者，审查责任完全在自己
2. **探索性/一次性脚本**：代码生命周期短，审查成本高于收益
3. **已有严格 CI/CD 且测试覆盖率高**：自动化测试可替代部分人工审查（但仍需审查逻辑）

### 迁移成本

从「agent 直接提交」迁移到「人工审查后提交」：

| 变更项 | 工作量 | 说明 |
|--------|--------|------|
| 建立审查习惯 | 1-2 周 | 需要刻意练习，形成肌肉记忆 |
| 学习手动测试方法 | 2-4 小时 | 针对不同类型代码的验证策略 |
| 补充 PR 证据 | 每 PR +5-10 分钟 | 截图、测试笔记、录屏等 |
| 拆分大 PR | 依赖 agent | 可用 agent 辅助拆分 commit |

**总体评估**：行为改变成本中等，但收益显著（协作者信任、代码质量、个人技术成长）。

## 对你的意义

对 Ken 的 Agent-Playbook 项目而言，这份指南有直接参考价值：

1. **Handbook 内容补充**：可在 `theory/03-engineering/` 下收录此指南的核心模式
2. **团队协作规范**：如果你的 VLA 研究项目有协作者，可直接采用这套 PR 标准
3. **Agent 设计启发**：未来的 agent 工具应该内置「审查提示」——在生成 PR 前提醒用户验证

**具体建议**：
- ✅ **立即行动**：把这份指南加入书签，下次开 PR 前对照检查清单
- ✅ **本周内**：在 Agent-Playbook 的 engineering 分类下收录核心反模式
- ⏳ **观望**：等待指南其他章节（Testing and QA、Understanding code）更新完成后再做深度整合

## 关键代码/配置片段

Simon 在指南中给出了「好 PR」的具体特征（非代码，但可操作）：

```markdown
一个好 PR 应该包含：

1. 代码能工作，且你有信心
   - 手动运行过关键路径
   - 边界条件已测试

2. 变更足够小
   - 单一职责
   - 审查者可在 15 分钟内理解

3. 额外上下文
   - 高层目标说明
   - 关联 issue/spec 链接
   - 实现选择的权衡说明

4. 验证证据
   - 手动测试笔记
   - 截图或录屏
   - 特定实现选择的注释
```

以及他推荐的工作流：

```bash
# 用 agent 生成代码后
1. 人工阅读每一行变更
2. 运行测试套件
3. 手动验证关键功能
4. 记录测试笔记
5. 用 agent 辅助拆分 commit（如需）
6. 编写 PR 描述（人工验证 agent 生成的描述）
7. 附加测试证据（截图/录屏）
8. 提交 PR
```

---

## 指南完整结构

Simon 的 Agentic Engineering Patterns 包含以下章节（截至 2026-03-05）：

**Principles**
- Writing code is cheap now
- Hoard things you know how to do
- Anti-patterns: things to avoid

**Testing and QA**
- Red/green TDD
- First run the tests

**Understanding code**
- Linear walkthroughs
- Interactive explanations

**Annotated prompts**
- GIF optimization tool using WebAssembly and Gifsicle

**Appendix**
- Prompts I use

---

[← Back to Deep Dives](./README.md)
