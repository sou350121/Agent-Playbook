---
auto_generated: true
generated_at: "2026-03-09T12:13:48Z"
source_url: "https://blog.langchain.com/langchain-skills/"
signal_type: "significant_update"
---
# LangChain Skills + LangSmith CLI: AI 编程助手生态工具包 (LangChain Skills & LangSmith CLI: AI Coding Assistant Ecosystem Toolkit)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-09
>
> **项目/工具**: LangChain Skills + LangSmith CLI
> **链接**: https://blog.langchain.com/langchain-skills/ + https://blog.langchain.com/langsmith-cli-skills/
> **核心定位**: 通过「技能包」机制让 AI 编程助手（Claude Code/Cursor 等）获得 LangChain/LangSmith 生态的领域专业知识，将任务完成率从 29% 提升至 95%

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**: LangChain 发布的「技能包」系统，让 AI 编程助手能动态加载领域知识，解决「工具太多导致性能下降」的核心痛点
- **現在值得用嗎**: 是 — 如果你在用 Claude Code/Cursor 开发 LangChain/LangGraph 应用，这是必装工具包
- **適合場景**: LangChain/LangGraph/DeepAgents 项目开发、Agent 调试与评估、团队标准化开发流程
- **不適合場景**: 不使用 LangChain 生态、或已深度定制自己的 Agent 框架
- **與 [競品/前版] 核心差異**: 首次将「渐进式披露」引入 Agent 技能系统 — 只在需要时加载相关技能，避免上下文污染

## 是什么 / 解决什么问题

LangChain 在 2026 年 3 月 4 日同时发布了两套技能包：**LangChain Skills**（11 个技能）和 **LangSmith Skills**（3 个技能），配合新推出的 **LangSmith CLI**，形成了一套完整的 AI Agent 开发与评估工具链。

核心解决的问题是：AI 编程助手（如 Claude Code）在面对复杂框架时，由于缺乏领域知识，任务完成率极低。LangChain 团队测试发现，Claude Code 在 LangChain 相关任务上的基础通过率仅为 29%，在 LangSmith 任务上更是只有 17%。

通过引入「技能包」机制 — 即预先编写好的 Markdown 指令 + 脚本 + 资源集合 — AI 助手可以在需要时动态加载相关知识，而不会因上下文过长导致性能下降。测试结果显示：
- LangChain 任务：29% → 95%（+66 个百分点）
- LangSmith 任务：17% → 92%（+75 个百分点）

这不仅仅是「文档整理」，而是一套经过验证的 Agent 性能优化方法论。

## 技术架构拆解

### 核心设计决策

1. **渐进式披露（Progressive Disclosure）**: 技能不会一次性全部注入 Agent 上下文，而是根据任务相关性动态加载。这解决了「给 Agent 太多工具反而导致性能下降」的经典问题（LangChain 在之前的 [React Agent Benchmark](https://blog.langchain.com/react-agent-benchmarking/) 中已验证）。

2. **技能可移植性**: 每个技能由 Markdown 文件 + 脚本组成，可以跨 Agent 平台使用。只要目标 Agent 支持 [Agent Skills 规范](https://skills.sh)，就能安装这些技能包。

3. **CLI 优先（CLI-First）**: LangSmith CLI 的设计哲学是「Agent-Native」— 让 Agent 能通过终端命令完整操作 LangSmith，而非依赖 Web UI。这符合「Agent 开发循环将由其他 Agent 驱动」的未来趋势。

4. **三层技能结构**:
   - **Trace**: 添加追踪、查询追踪
   - **Dataset**: 构建评估数据集
   - **Evaluator**: 创建自定义评估器
   
   这三层对应 LangSmith AI 工程的三大核心环节，形成闭环。

### 与前版/竞品的关键差异

| 维度 | 传统文档/教程 | Cursor/Windsurf 内置知识 | LangChain Skills |
|------|------------|----------------------|-----------------|
| 加载方式 | 手动查阅 | 静态注入 | 动态按需加载 |
| 上下文占用 | 不占用 | 持续占用 | 仅使用时占用 |
| 可移植性 | 高 | 低（平台绑定） | 高（跨平台） |
| 性能影响 | 无 | 可能下降 | 优化后提升 |
| 更新频率 | 手动 | 依赖平台更新 | 独立更新 |
| 脚本集成 | 无 | 有限 | 每个技能含 helper scripts |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Coding Agent                          │
│                  (Claude Code / Cursor)                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ 任务识别
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              Skills Router (渐进式披露)                      │
│   "当前任务需要 LangGraph 知识 → 加载 langgraph-fundamentals" │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
   │ LangChain   │ │ LangGraph   │ │ DeepAgents  │
   │ Skills (4)  │ │ Skills (3)  │ │ Skills (3)  │
   │             │ │             │ │             │
   │ - create_   │ │ - StateGraph│ │ - harness   │
   │   agent     │ │ - checkpoint│ │ - memory    │
   │ - middleware│ │ - interrupt │ │ - subagents │
   │ - RAG       │ │             │ │             │
   └─────────────┘ └─────────────┘ └─────────────┘
                          │
                          │ 执行
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              LangSmith CLI + Skills                         │
│   ┌─────────┐  ┌──────────┐  ┌───────────┐                 │
│   │  trace  │  │ dataset  │  │ evaluator │                 │
│   │ 查询追踪 │  │ 构建数据集│  │ 创建评估器 │                 │
│   └─────────┘  └──────────┘  └───────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **LangChain/LangGraph 项目开发**: 如果你正在用 LangChain 构建 Agent，这套技能包能让 AI 助手准确理解 `create_agent()`、`StateGraph`、checkpointers 等核心概念，减少调试时间。

2. **团队标准化**: 技能包可以作为团队内部的最佳实践载体。新成员安装后，AI 助手会自动遵循团队约定的开发模式。

3. **Agent 评估闭环**: LangSmith Skills 的三层结构（trace → dataset → evaluator）让 AI 助手能自主完成「添加追踪 → 生成数据 → 评估性能」的完整循环。

4. **跨平台协作**: 团队成员使用不同 IDE（Cursor/Windsurf/Claude Code）时，技能包提供一致的知识基线。

### 什么场景不值得用

1. **不使用 LangChain 生态**: 如果你用 LlamaIndex、Haystack 或其他框架，这套技能包不适用。

2. **已深度定制框架**: 如果你的团队对 LangChain 做了大量魔改，官方技能包可能与你的实践不符。

3. **学习阶段**: 初学者可能更适合系统学习官方文档，而非依赖 AI 助手的碎片化建议。

4. **生产环境敏感场景**: 技能包处于 early development 阶段，API 可能变化，不建议在关键生产流程中完全依赖。

### 迁移成本

从「无技能」到「安装技能包」：
- **时间**: 5-10 分钟（运行 npx 命令 + 设置 API key）
- **风险**: 低（技能包只读，不修改项目代码）
- **回滚**: 删除 `.skills/` 目录即可

从「其他框架」迁移到 LangChain + Skills：
- **时间**: 取决于项目复杂度，通常 1-3 天
- **风险**: 中（需要理解 LangChain 范式）
- **建议**: 先用技能包在 side project 上试验

## 对你的意义

如果你在用或计划用 LangChain/LangGraph 构建 Agent，这套技能包是**必装工具**。它解决了 AI 编程助手在复杂框架上「知道语法但不懂生态」的核心痛点。

具体建议：
1. **立即试用**: 在现有 LangChain 项目上安装技能包，观察 AI 助手建议质量的变化
2. **关注 LangSmith CLI**: 这是未来 Agent 开发的核心工具 — 让 Agent 自己调试自己
3. **贡献反馈**: 项目处于 early development，你的使用反馈会影响后续技能设计

对于 Agent-Playbook 的读者，这套技能包验证了一个重要模式：**「领域技能包」是解决 AI 助手泛化能力不足的有效路径**。未来可能出现更多框架的官方技能包（如 LlamaIndex Skills、Haystack Skills）。

## 关键代码/配置片段

### 安装命令

```bash
# 本地安装（当前项目）
npx skills add langchain-ai/langchain-skills --skill '*' --yes

# 全局安装（所有项目）
npx skills add langchain-ai/langchain-skills --skill '*' --yes --global

# 绑定到特定 Agent（如 Claude Code）
npx skills add langchain-ai/langchain-skills --agent claude-code --skill '*' --yes --global
```

### LangSmith CLI 安装

```bash
curl -sSL https://raw.githubusercontent.com/langchain-ai/langsmith-cli/main/scripts/install.sh | sh
```

### 环境变量设置

```bash
# LangChain Skills
export OPENAI_API_KEY=<your-key>
export ANTHROPIC_API_KEY=<your-key>

# LangSmith Skills
export LANGSMITH_API_KEY=<your-key>
export OPENAI_API_KEY=<your-key>
```

### 11 个 LangChain Skills 列表

```
Getting Started:
- framework-selection      # LangChain vs LangGraph vs Deep Agents 对比
- langchain-dependencies   # Python + TypeScript 版本管理参考

Deep Agents:
- deep-agents-core         # Agent 架构、harness 设置、SKILL.md 格式
- deep-agents-memory       # 记忆、持久化、文件系统中间件
- deep-agents-orchestration# 子 Agent、任务规划、人在回路

LangChain:
- langchain-fundamentals   # create_agent、工具、结构化输出、中间件基础
- langchain-middleware     # 人在回路审批、自定义中间件、Command resume
- langchain-rag            # RAG 流水线（文档加载器、嵌入、向量存储）

LangGraph:
- langgraph-fundamentals   # StateGraph、节点、边、状态 reducer
- langgraph-persistence    # Checkpointers、thread_id、跨线程记忆
- langgraph-human-in-the-loop # 中断、人工审查、审批工作流
```

### 3 个 LangSmith Skills 列表

```
- langsmith-trace     # 查询和导出追踪（含 helper scripts）
- langsmith-dataset   # 从追踪生成评估数据集（含 helper scripts）
- langsmith-evaluator # 创建自定义评估器（含 helper scripts）
```

### 性能对比数据

```
LangChain 任务测试:
┌─────────────────────────────┬──────────────┬────────────┐
│ Test                        │ Model        │ Pass Rate  │
├─────────────────────────────┼──────────────┼────────────┤
│ Claude Code without Skills  │ Sonnet 4.6   │ 25%        │
│ Claude Code with Skills     │ Sonnet 4.6   │ 95%        │
└─────────────────────────────┴──────────────┴────────────┘

LangSmith 任务测试:
┌─────────────────────────────┬──────────────┬────────────┐
│ Test                        │ Model        │ Pass Rate  │
├─────────────────────────────┼──────────────┼────────────┤
│ Claude Code without Skills  │ Sonnet 4.6   │ 17%        │
│ Claude Code with Skills     │ Sonnet 4.6   │ 92%        │
└─────────────────────────────┴──────────────┴────────────┘
```

> 注：Pass rate 通过 LangSmith evaluations 计算，测试基准计划开源。

---
[← Back to Deep Dives](./README.md)
