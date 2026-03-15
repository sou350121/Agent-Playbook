---
auto_generated: true
generated_at: "2026-03-15T03:37:47Z"
source_url: "https://simonwillison.net/guides/agentic-engineering-patterns/better-code/#atom-everything"
signal_type: "significant_update"
---
# AI 应该帮助我们写出更好的代码 (AI Should Help Us Produce Better Code)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-15
>
> **项目/工具**: Simon Willison - Agentic Engineering Patterns
> **链接**: https://simonwillison.net/guides/agentic-engineering-patterns/better-code/
> **核心定位**: 一套用 AI coding agents 系统性提升代码质量而非降低质量的方法论，核心是「零容忍技术债」+「复合工程循环」

## ⚡ 快速判斷（30 秒读完这段就够了）

- **一句话定位**: Simon Willison 提出的 AI 辅助编程范式，主张用 coding agents 处理耗时但概念简单的重构任务，实现「同时交付新功能 + 提升代码质量」
- **现在值得用吗**: 是 — 如果你已在用 Claude Code/Codex/Gemini Jules 等异步 agent
- **适合场景**: 大规模重构、API 一致性修复、技术债偿还、技术选型验证原型
- **不适合场景**: 紧急 hotfix、对 agent 输出无评审能力的团队、代码库无自动化测试
- **与「AI 降低代码质量」担忧的核心差异**: 把 agent 定位为「零成本重构工具」而非「替代人类写新功能」

## 是什么 / 解决什么问题

开发者对 AI 编程的普遍担忧是：外包代码给 AI 会导致质量下降，产出大量快速但糟糕的代码，决策者因速度而忽视缺陷。Simon Willison 在《Agentic Engineering Patterns》指南中提出一个反直觉观点：**用 AI 写出更差的代码是一种选择，我们完全可以选择写出更好的代码**。

核心问题在于技术债的累积模式。技术债来自权衡：「用正确的方式做太花时间，所以我们在时间约束下工作，祈祷项目能活到还债那天」。最常见的技术债类型是**概念简单但耗时**的修改：

- 原始 API 设计未覆盖后期出现的重要场景，修复需在几十处改代码，不如加一个略有不同的新 API 忍受重复
- 早期命名选择糟糕（如用 teams 而非 groups），但全局清理太费时，只在 UI 层修复
- 系统随时间增长出重复但略有不同的功能，需要合并重构
- 单个文件膨胀到数千行，理想情况应拆分为独立模块

这些修改概念上都简单，但需要 dedicated time，而在更紧急的问题面前很难证明其合理性。

## 技术架构拆解

### 核心设计决策

Simon 的方法论建立在四个关键设计选择上：

1. **异步 Agent 优先**: 使用 Gemini Jules、OpenAI Codex web、Claude Code on the web 等异步工具，在后台 branch/worktree 运行重构任务，不中断本地开发流
2. **PR 评审门控**: agent 输出必须经过 Pull Request 评审 — 好则合并，接近则提示修正，差则丢弃
3. **零容忍态度**: 因代码改进成本降至极低，可以对 minor code smells 和不便采取零容忍
4. **复合工程循环**: 每个 coding 项目以 retrospective 结束，将有效方法文档化供未来 agent 运行使用（源自 Every 公司的 Compound Engineering 实践）

### 与前版/竞品的核心差异

| 维度 | 传统 AI 编程用法 | Simon 的 Agentic Engineering |
|------|----------------|---------------------------|
| **定位** | 替代人类写新功能 | 处理人类不愿做的耗时重构 |
| **工作流** | 同步交互，即时生成 | 异步后台运行，PR 评审 |
| **质量门控** | 依赖开发者即时审查 | PR 流程 + 可丢弃分支 |
| **技术债态度** | 可能加速累积（追求速度） | 系统性偿还（成本极低） |
| **实验成本** | 高（需手动搭建原型） | 极低（单 prompt 生成负载测试） |
| **知识沉淀** | 无系统化积累 | Compound step 文档化 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Compound Engineering Loop                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  1. 识别技术债                                               │
│     - API 不一致 / 命名混乱 / 重复代码 / 大文件              │
│     - 概念简单但耗时                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  2. 启动异步 Agent                                           │
│     - Claude Code / Gemini Jules / Codex web               │
│     - 在 branch/worktree 后台运行                            │
│     - 不中断本地开发流                                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  3. PR 评审门控                                              │
│     - 好 → 合并                                              │
│     - 接近 → 提示修正                                        │
│     - 差 → 丢弃（成本极低）                                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Compound Step（复合步骤）                                │
│     - 项目 retrospective                                     │
│     - 文档化有效方法供未来 agent 使用                         │
│     - 小改进复利累积                                         │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **大规模重构**: 需要改动几十处文件的 API 一致性修复、命名统一、模块拆分 — agent 可后台 churn，人类只需评审 PR
2. **技术选型验证**: 需要验证某技术是否适合（如「Redis 能否支撑数千并发的 activity feed」）— agent 可从单 prompt 生成模拟系统 + 负载测试，成本几乎为零
3. **多方案并行实验**: 因实验成本极低，可同时测试多个解决方案选最优
4. **已有异步 agent 工作流的团队**: 若团队已用 Claude Code/Codex 等，直接套用此模式几乎无迁移成本

### 什么场景不值得用

1. **紧急 hotfix**: 需要立即上线的修复，异步 agent 的 PR 评审流程太慢
2. **无自动化测试的代码库**: agent 重构输出无法自动验证，人工审查成本过高
3. **团队无 agent 使用经验**: 需先建立基本的 prompt 工程和评审流程
4. **对「丢弃差结果」有心理障碍的团队**: 若团队认为「agent 生成的代码必须用」，会失去零成本试错优势

### 迁移成本

从传统开发模式迁移到此模式：

- **工具层**: 几乎为零 — 使用现有异步 agent（Claude Code web 免费层即可）
- **流程层**: 需建立「识别技术债 → agent 后台运行 → PR 评审」的固定节奏，建议每周固定 2-3 小时专门处理技术债
- **心理层**: 需接受「agent 输出可丢弃」的心态，这是零成本实验的前提

## 对你的意义

对 Ken 的 Agent-Playbook 项目和 VLA 研究代码库，这套方法有直接应用价值：

1. **VLA 代码库重构**: VLA 模型代码常因快速迭代积累技术债（如 tactile 编码方案不统一、数据加载接口不一致）— 可用异步 agent 系统性清理
2. **Agent-Playbook 示例代码**: Handbook 中的示例代码需保持高质量，可用此模式在添加新示例时同步重构旧代码
3. **技术选型验证**: 在考虑新框架（如新 Agent UI 工具链）时，用 agent 快速搭建原型验证，而非直接承诺采用

**具体建议**: 
- **立即试用**: 本周选一个 VLA 代码库中的技术债（如统一数据加载接口），用 Claude Code 后台运行重构
- **建立节奏**: 每周五下午固定 2 小时「技术债清理」，用 agent 处理当周累积的 small smells
- **文档化**: 在 Agent-Playbook 的 `theory/03-engineering/` 中记录有效的 agent prompt 模式，形成 Compound Engineering 资产

## 关键代码/配置片段

Simon 在文中未提供具体代码，但给出了典型使用模式：

```
# 典型异步 agent 工作流（伪代码）

# 1. 在本地创建 feature branch
git checkout -b refactor/api-consistency

# 2. 启动异步 agent（以 Claude Code web 为例）
# Prompt 示例：
"""
Refactor the API endpoints in /src/api/ to use consistent response format:
- All success responses should be {success: true, data: {...}}
- All error responses should be {success: false, error: {code, message}}
- Update all 47 endpoint files accordingly
- Run existing tests and report any failures

Work in the current branch. When done, create a PR with summary of changes.
"""

# 3. 等待 agent 完成（后台运行，可继续其他工作）

# 4. 评审 PR
# - 检查改动是否符合预期
# - 运行 CI/CD 验证
# - 好则合并，接近则提示修正，差则关闭 PR
```

### Compound Step 模板（源自 Every 公司）

```markdown
## Project Retrospective: [项目名称]

### What Worked
- [有效的方法/工具/prompt 模式]
- 例：用「先读现有代码再重构」的 prompt 比直接要求重构效果好 3x

### What Didn't Work
- [无效的方法]
- 例：要求 agent「优化性能」但未指定具体指标，输出不可用

### Compound Instructions（供未来 agent 使用）
- [文档化的 prompt 模式]
- 例：「重构 API 时先列出所有受影响文件，确认后再执行」
```

---
[← Back to Deep Dives](./README.md)
