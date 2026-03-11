---
auto_generated: true
generated_at: "2026-03-11T05:46:52Z"
source_url: "https://simonwillison.net/guides/agentic-engineering-patterns/agentic-manual-testing/"
signal_type: "significant_update"
---
# Agentic Manual Testing：编码 Agent 的手动测试模式 (Agentic Manual Testing for Coding Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-11
>
> **项目/工具**: Simon Willison 的 Agentic Engineering Patterns 系列
> **链接**: https://simonwillison.net/guides/agentic-engineering-patterns/agentic-manual-testing/
> **核心定位**: 一套让编码 Agent 在生成代码后执行「人工验证」的方法论，填补自动化测试与真实行为之间的 gap

---

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句话定位**：Simon Willison 总结的编码 Agent 最佳实践——在自动化测试之外，让 Agent 用 `python -c`、`curl`、浏览器自动化等工具「亲自跑一遍代码」，发现测试覆盖不到的问题
- **现在值得用吗**：是——如果你在用 Cursor/Codex/Cline 等编码 Agent，这套模式能显著降低「测试全过但代码不能用」的风险
- **适合场景**：Web API 开发、交互式 UI 验证、Agent 生成代码后的快速验收
- **不适合场景**：纯算法/库函数开发（已有完善单元测试覆盖时）、对执行速度要求极高的 CI 流程
- **与 [传统 TDD] 核心差异**：TDD 保证「代码符合测试」，Agentic Manual Testing 保证「代码符合预期」——前者是必要条件，后者是充分条件

---

## 是什么 / 解决什么问题

在编码 Agent 普及之前，开发者面临一个经典困境：LLM 生成的代码无法自动验证，只能人工逐行审查。编码 Agent（如 Cursor、Cline、Codex）的核心突破在于**它能执行自己写的代码**——这改变了整个验证范式。

但 Simon Willison 指出了一个容易被忽视的盲点：**自动化测试通过 ≠ 代码能正常工作**。他列举了几种常见情况：

- 测试全过，但服务器启动即崩溃
- 测试全过，但关键 UI 元素没有渲染
- 测试全过，但遗漏了测试用例未覆盖的边缘场景

这正是「人工测试」存在的理由。传统开发中，开发者会在 merge 前亲自点一遍功能；Simon 提出，**这套逻辑应该延伸到 Agent 工作流中**——让 Agent 自己执行「人工测试」，用工具模拟人类验证行为。

这篇文章的核心贡献在于：它不是泛泛而谈「要测试」，而是给出了**具体可执行的 prompt 模式和工具链**，让 Agent 知道如何「手动」测试不同类型的代码。

---

## 技术架构拆解

### 核心设计决策

Simon 的方法论基于三个关键设计选择：

| 决策 | 理由 | 实现方式 |
|------|------|----------|
| **区分代码类型，匹配测试机制** | Python 库、Web API、UI 应用的验证方式完全不同 | `python -c` → `curl` → 浏览器自动化 |
| **优先使用 CLI 工具** | CLI 的输出结构化，Agent 更容易解析和迭代 | `playwright-cli`、`uvx rodney`、`showboat` |
| **测试发现问题后回归 TDD** | 手动测试发现的 bug 应该被永久捕获 | 用 red/green TDD 将新 case 加入自动化测试 |

### 与前版/竞品的关键差异

这里的「前版」指传统 Agent 工作流（生成 → 单元测试 → merge），「竞品」指纯人工测试流程：

| 维度 | 传统 Agent 工作流 | 纯人工测试 | Agentic Manual Testing |
|------|------------------|------------|------------------------|
| 验证速度 | 快（秒级） | 慢（分钟级） | 中（1-5 分钟） |
| 覆盖率 | 取决于测试用例 | 取决于人的注意力 | 可系统化探索 |
| 发现问题类型 | 逻辑错误、边界条件 | UI 问题、集成问题 | 全谱系（含前两者） |
| 可重复性 | 高 | 低 | 高（prompt 可复用） |
| 文档沉淀 | 测试代码 | 无/手动记录 | Showboat 自动记录 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Agentic Manual Testing Flow              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Agent 生成代码                                      │
│         (Cursor/Codex/Cline 等)                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: 根据代码类型选择测试机制                            │
│  ┌─────────────┬─────────────┬─────────────────────────┐   │
│  │ Python 库    │ Web API     │ 交互式 UI               │   │
│  │ python -c   │ curl        │ Playwright/Rodney       │   │
│  └─────────────┴─────────────┴─────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Agent 执行测试并观察结果                            │
│         - 运行命令                                           │
│         - 解析输出/截图                                      │
│         - 判断是否符合预期                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: 发现问题 → Red/Green TDD 修复                       │
│         无问题 → Showboat 记录测试过程                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Merge + 文档沉淀                                    │
│         (Showboat 生成 Markdown 报告)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 实用评估

### 什么场景值得用

| 场景 | 理由 | 推荐工具 |
|------|------|----------|
| **Agent 生成新 API endpoint** | 单元测试可能遗漏 HTTP 层问题（状态码、headers、序列化） | `curl` + 探索式 prompt |
| **前端组件/页面开发** | CSS 布局、交互反馈、响应式行为难以用单元测试覆盖 | Playwright / Rodney |
| **Agent 重构现有代码** | 回归测试可能遗漏行为变化，手动验证可快速发现 breaking changes | 组合使用 |
| **快速原型验证** | 在写正式测试前，先用手动测试确认方向正确 | `python -c` + `showboat` |

### 什么场景不值得用

| 场景 | 理由 | 替代方案 |
|------|------|----------|
| **纯算法/工具函数** | 已有完善单元测试，手动测试收益低 | 坚持 TDD |
| **高频 CI/CD 流程** | 浏览器自动化测试慢且易 flaky | 仅保留关键路径 E2E |
| **Agent 仅生成样板代码** | 如 CRUD scaffold，逻辑简单可预测 | 代码审查即可 |
| **资源受限环境** | 浏览器自动化需要额外依赖和内存 | 降级为 `curl`/`python -c` |

### 迁移成本

从「生成 → 单元测试 → merge」迁移到「生成 → 手动测试 → TDD 补充 → merge」：

- **学习成本**：低——只需掌握 3-4 个核心 prompt 模式（Simon 已给出模板）
- **工具成本**：低——`playwright`、`rodney`、`showboat` 均为开源/免费
- **时间成本**：中——每次开发多花 2-5 分钟，但可显著降低后期 debug 时间
- **集成成本**：低——不影响现有 CI 流程，手动测试在本地/开发环境执行

---

## 对你的意义

如果你在用 Agent 辅助开发（尤其是 Web 应用），这套模式的价值在于：

1. **降低「假阳性」风险**：测试全过但功能不可用的情况会大幅减少
2. **加速反馈循环**：Agent 可以在几秒内完成人类需要几分钟的手动验证
3. **沉淀可复用的测试 prompt**：一旦验证某个 prompt 有效，可以在类似场景中重复使用

**建议行动**：
- 立即试用：下次用 Cursor 生成 API 后，加一句「用 curl 探索这个新 endpoint，尝试 5 种不同的请求」
- 渐进采用：先从 Web UI 项目开始（收益最明显），再扩展到 API/库开发
- 工具准备：安装 `playwright` 或 `rodney`，熟悉 `showboat` 的文档记录模式

---

## 关键代码/配置片段

### 1. Python 库快速测试

```bash
# 让 Agent 用 python -c 测试边缘情况
python -c "from mylib import func; print(func(edge_case_1)); print(func(edge_case_2))"
```

### 2. Web API 探索式测试

```bash
# 启动开发服务器后，让 Agent 用 curl 探索
curl -X POST http://localhost:8000/api/new-endpoint \
  -H "Content-Type: application/json" \
  -d '{"test": "payload"}'
```

### 3. 浏览器自动化测试（Rodney 示例）

```bash
# Simon 的 prompt 模板
Start a dev server and then use `uvx rodney --help` to test the new homepage, 
look at screenshots to confirm the menu is in the right place
```

这个 prompt 的三个技巧：
- `uvx rodney --help` 自动安装并展示用法
- `--help` 输出专为 Agent 设计，包含完整 API
- `look at screenshots` 提示 Agent 使用视觉能力验证 UI

### 4. Showboat 文档记录

```bash
# Showboat 核心命令
showboat note "测试新 homepage 的菜单布局"
showboat exec "uvx rodney screenshot --selector .menu"
showboat image "menu-screenshot.png"
```

`exec` 命令的关键作用：记录命令 + 输出，防止 Agent「编造」测试结果。

---

## 📌 AI Agent 假设追踪

*本候选无 assumption_matches，跳过此段。*

---

## 局限性与待验证点

| 局限性 | 说明 |
|--------|------|
| **依赖 Agent 的工具调用能力** | 如果 Agent 无法正确执行 shell 命令或解析输出，流程会中断 |
| **浏览器测试的 flakiness** | 即使有 Agent 维护，E2E 测试仍可能因 UI 微调而失败 |
| **需要明确的「预期」定义** | Agent 需要知道「什么是正确的」才能判断测试是否通过 |

| 待验证点 | 说明 |
|----------|------|
| **长期 ROI** | 多花的 2-5 分钟/次是否真能降低后期 debug 时间？需团队实践数据 |
| **不同 Agent 的表现差异** | Cursor、Cline、Codex 在执行这类任务时的成功率是否有显著差异？ |

---

[← Back to Deep Dives](./README.md)
