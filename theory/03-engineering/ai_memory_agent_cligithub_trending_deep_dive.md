---
auto_generated: true
generated_at: "2026-08-18T05:50:26Z"
source_url: "https://github.com/akitaonrails/ai-memory/releases/tag/v1.28.0"
signal_type: "blog_post"
---
# ai-memory — 跨 Agent CLI 的长期记忆方案 (ai-memory: Long-term Memory for Agent Coding CLIs)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-18
>
> **项目/工具**: ai-memory (akitaonrails/ai-memory)
> **链接**: https://github.com/akitaonrails/ai-memory/releases/tag/v1.28.0
> **核心定位**: 一个 Rust 编写的单二进制工具，让 Claude Code、Codex、Cursor等不同Agent CLI 在同一代码仓库中共享持久化记忆，实现跨工具、跨会话的无缝上下文交接。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 给 AI 编码 Agent 一个跨工具的"长期记忆"——你在 Claude Code 中中断的任务，可以在 Codex 或 Cursor 中继续，无需重新解释上下文。
- **现在值得用吗**: 是——如果你在日常开发中切换多个 Agent CLI（如 Claude Code + Codex + Cursor），这个工具解决的是一个真实且日益增长的痛点。
- **适合场景**: 多 Agent 切换开发、CI/CD 无人值守 Agent 任务交接、团队协作中共享项目记忆
- **不适合场景**: 只用单一 Agent CLI 的轻量项目、需要实时代码符号分析的场景（应配合 LSP/结构化工具使用）
- **与竞品核心差异**: 不是向量数据库方案，而是 Git 版本化的 Markdown Wiki + SQLite FTS5 索引，可 grep、可在 Obsidian 中打开、可 rsync 备份

## 是什么 / 解决什么问题

AI 编码 Agent（Claude Code、OpenAI Codex、Cursor 等）有一个根本性缺陷：**会话结束时上下文丢失**。你花了 2 小时在 Claude Code 中调试一个复杂问题，探索了 3 条失败路径，最终找到了方向——然后会话超时了。下次打开 Codex，你需要重新解释架构、重复之前的失败尝试、重新发现关键信息。

ai-memory 的解决方案简洁而优雅：**一个 Karpathy 风格的 LLM Wiki**。它通过 Agent CLI 的生命周期钩子（lifecycle hooks）自动捕获会话中的关键观察，在会话结束时自动编译为结构化的 Markdown 页面，存入一个 Git 版本化的 wiki 目录。下一个 Agent 启动时，会自动收到一个"你上次停在哪里"的交接块。

这个项目目前支持 **20+ 种 Agent CLI**，包括 Claude Code、Codex、Cursor、Gemini CLI、OpenCode、Devin CLI、Kimi Code、Kiro CLI 等，是目前覆盖最广的跨 Agent 记忆方案。它近期登上 GitHub Trending，反映了社区对这一痛点的强烈共鸣。

## 技术架构拆解

### 核心设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 存储格式 | Git 版本化 Markdown | 可 grep、可 Obsidian 打开、可 rsync 备份、人类可读 |
| 索引层 | SQLite + FTS5 + 实体匹配 + 图邻居 RRF | 轻量、无需外部依赖、支持多路召回融合 |
| 向量检索 | 可选（OpenAI/Voyage/Gemini/Ollama） | 不强制依赖向量数据库，但提供增强召回选项 |
| 捕获机制 | 生命周期钩子（hooks） | 与 Agent 内部实现解耦，通过标准事件接口工作 |
| 二进制 | 单 Rust 二进制 | 零依赖部署，Linux/macOS/Windows 全覆盖 |
| 项目隔离 | 每个 Git 仓库 = 独立项目 | 天然隔离，多客户/多项目互不干扰 |

### 与前版/竞品的关键差异

| 维度 | 手动笔记/总结 | 向量数据库方案 | ai-memory |
|------|--------------|---------------|-----------|
| 写入方式 | 人工 write_note | 人工或 Agent 调用 API | 自动从生命周期钩子捕获 |
| 可读性 | 高（Markdown） | 低（向量嵌入） | 高（Markdown Wiki） |
| 跨 Agent | 需要手动复制 | 需要统一 API | 原生支持 20+ Agent |
| 版本控制 | Git 手动 | 通常无 | Git 自动每次提交 |
| 搜索能力 | grep/全文搜索 | 语义搜索 | FTS5 + 实体 + 图邻居 + 可选向量 |
| 部署复杂度 | 零 | 需要向量 DB 服务 | 单二进制 |
| 上下文交接 | 手动 | 需自定义集成 | 自动 SessionEnd → SessionStart |

### 架构/信息流图

```
┌──────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  Agent CLI   │────>│ Lifecycle Hooks  │────>│ Hook Router /     │
│ (Claude/Codex│     │ (curl / native   │     │ Sanitizer         │
│  /Cursor...) │     │  ai-memory hook) │     │                   │
└──────────────┘     └──────────────────┘     └────────┬──────────┘
                                                       │
                                                       ▼
┌──────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  memory_query │◄────│ Recall Pipeline  │◄────│ SQLite Index      │
│ (Agent 启动  │     │ FTS5+实体+图RRF  │     │ - sessions/       │
│  自动接收)   │     │ [+可选向量召回]   │     │ - observations    │
└──────────────┘     └──────────────────┘     │ - handoffs        │
                                               │ - page_embeddings │
┌──────────────┐     ┌──────────────────┐     └────────┬──────────┘
│  Wiki 页面   │◄────│ Consolidation    │◄─────────────┘
│ (Markdown)   │     │ (LLM 重写摘要    │    SessionEnd
│              │     │  → concepts/     │
│ git versioned│     │  decisions/      │
│ human-editable│    │  gotchas/)       │
└──────────────┘     └──────────────────┘
```

**数据流 8 步**（稳态循环）：

1. **Agent 发射生命周期钩子** — SessionStart、UserPromptSubmit、PostToolUse 等事件通过 shell 脚本 curl 或原生 ai-memory hook 命令发送到服务器
2. **Hook 路由器清洗和分类** — 唯一从不可信文本进入存储的路径，分配 ObservationKind，入队到 writer actor
3. **SessionEnd 触发摘要生成** — 服务器合成 sessions/<id>.md 摘要页（规则驱动，无需 LLM），为下一个 Agent 打开 Handoff 行
4. **LLM 巩固（可选）** — 当配置了 LLM 提供者，memory_consolidate 将摘要重写为更丰富的持久化页面，分类到 concepts/、decisions/、gotchas/ 等目录
5. **自动改进调度器（可选）** — 审查新完成的会话，自动生成 concepts/decisions/gotchas/procedures/_rules 提案，经 LLM 验证后写入 wiki
6. **memory_query 召回** — FTS5 + 实体匹配 + 链接邻居 RRF 融合召回；配置了 embedder 时加入向量余弦相似度；权威度感知排序偏好 rules/decisions/procedures/gotchas 页面
7. **遗忘清扫** — 按 TTL 硬删除过期页面，按 retention 驱逐冷页面，生成 decay tombstone
8. **备份** — SQLite 在线备份 API 或 git push + rsync

### 支持矩阵（部分）

| Agent CLI | 支持级别 | 关键能力 |
|-----------|---------|---------|
| Claude Code | 完整 | MCP + 生命周期钩子 + per-session 隔离 |
| Codex | 完整 | MCP + 钩子，需手动 finalize-session |
| Cursor | 完整 | MCP + 钩子 |
| Gemini CLI | 完整 | MCP + 钩子 |
| OpenCode | 完整 | 远程 MCP + 自动生成 TS 插件 |
| Devin CLI | 完整 | MCP + 钩子，使用 PostCompaction 事件 |
| Kimi Code | 完整 | MCP + 10 种钩子事件（含子 Agent） |
| Kiro CLI | 完整 | 支持 v2/v3 双引擎 |
| VS Code Copilot | 受限 | MCP only，无钩子 |
| Zed | 受限 | MCP only，无钩子 |

## 实用评估

### 什么场景值得用

**1. 多 Agent 切换开发**
这是核心场景。如果你在 Claude Code 中做架构探索，在 Codex 中做批量重构，在 Cursor 中做快速迭代——ai-memory 让你在不同工具间无缝切换，下一个 Agent 自动看到你上次的工作进展、失败尝试和开放问题。

**2. CI/CD 无人值守 Agent 任务**
Codex 等 Agent 在 CI 中运行时没有交互式会话。ai-memory 的 managed workstream 模式可以让多个 Agent 实例在同一个逻辑工作流中接力，每个实例都能看到前一个的完整上下文。

**3. 团队协作中的项目记忆共享**
_global 作用域存储团队/用户的长期偏好（技术选型、代码风格），自动注入到每个新项目中。新成员加入时，Agent 自动获得团队约定，无需手动 onboarding。

**4. 复杂项目的决策追踪**
decisions/ 和 gotchas/ 目录自动积累项目决策和踩坑记录。6 个月后回看这个项目，你不需要翻聊天记录——wiki 里有结构化的决策历史和失败教训。

### 什么场景不值得用

**1. 单一 Agent CLI 的轻量项目**
如果你只用 Claude Code 或只用 Cursor，且项目不大，手动写 README 和注释就够了。ai-memory 的钩子安装和服务器运行有额外开销。

**2. 需要实时代码符号分析**
ai-memory 是**历史记忆**，不是**代码智能**。它不知道当前 checkout 中的函数签名、调用关系或依赖图。官方文档明确建议：用 ai-memory 存储决策和教训，用 LSP/结构化工具做符号分析。两者互补，不替代。

**3. 对隐私极度敏感的环境**
如果配置了 LLM consolidation，项目内容会被发送到配置的 LLM 提供者（Anthropic/OpenAI/Gemini 等）。虽然捕获排除策略可以过滤敏感文件，但需要仔细配置。

**4. 需要实时协作的场景**
ai-memory 是会话级别的批量写入，不是实时同步。多个 Agent 同时操作同一项目时，可能有竞态条件。

### 迁移成本

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 安装二进制 | 5 分钟 | cargo install / Docker / 预编译二进制 |
| 为每个 Agent 安装钩子 | 10-15 分钟 | `ai-memory install-mcp` + `ai-memory install-hooks` |
| 配置 LLM 提供者（可选） | 5 分钟 | 设置 AI_MEMORY_LLM_PROVIDER 和 API key |
| 配置捕获排除策略（可选） | 10 分钟 | 在 [.ai-memory.toml] 中配置 ignore_paths |
| 第一个会话积累记忆 | 自动 | 无需手动操作，第一个会话结束后自动生成 |

**总计**: 首次设置约 30 分钟，之后零维护。

## 对你的意义

Ken，这个工具对你有双重意义：

**在 AI 应用开发层面**：你主攻 Agent + UI 方向，而 ai-memory 解决的是 Agent 工程中最基础的"记忆"问题。随着 Agent 框架越来越多（Claude Code、Codex、Cursor、OpenCode...），跨 Agent 互操作性会成为刚需。ai-memory 的"生命周期钩子 + Markdown Wiki"架构是一个值得参考的设计模式——它不绑定任何特定 Agent，而是通过标准事件接口工作。

**在研究层面**：ai-memory 的"Karpathy 风格 LLM Wiki"理念与 VLA 研究中的"世界模型"有有趣的交叉点——两者都在解决"如何让 AI 系统积累和回忆经验"这个问题。ai-memory 用的是确定性的 Markdown + SQLite，而 VLA 研究倾向于用神经网络表征。这两种路径的对比值得思考。

**建议**: 立即试用。在你的 Agent-Playbook 和 VLA-Handbook 仓库中各跑一个会话，观察它自动生成的 wiki 页面质量。重点关注 consolidation 后的页面是否准确捕捉了你的工作上下文。

## 关键代码/配置片段

### 安装和钩子注册（来自官方文档）

```bash
# 安装（Arch Linux）
yay -S ai-memory-bin

# 为 Claude Code 安装 MCP 配置
ai-memory install-mcp --session-aware

# 为 Claude Code 安装生命周期钩子
ai-memory install-hooks --agent claude-code

# 为 Codex 安装
ai-memory install-mcp --client codex
ai-memory install-hooks --agent codex
```

### 捕获排除策略（来自 marker-file.md）

```toml
# .ai-memory.toml — 项目级标记文件
[capture]
ignore_paths = [
  "node_modules/**",
  "*.lock",
  "target/**",
  ".git/**",
]
```

### 生命周期事件类型（来自 ARCHITECTURE.md）

| 存储类型 | 语义 |
|---------|------|
| session-start | Agent 会话开始；捕获 cwd/model/会话身份 |
| user-prompt | 用户提交 prompt 文本 |
| pre-tool-use | Agent 即将调用工具 |
| post-tool-use | Agent 完成工具调用 |
| pre-compact | Agent 即将压缩上下文 |
| post-compaction | Agent 压缩完成并提供摘要 |
| notification | Agent 发出通知类事件 |
| stop | Agent 完成一轮交互 |
| session-end | Agent 会话结束；触发摘要/交接 |

### 多用户隔离配置（可选）

```toml
[slots]
per_user = true  # 共享服务器上按操作员隔离上下文注入
```

### Managed Workstream 模式

```bash
# 启动 managed workstream — 自动接力最新可用会话
ai-memory run claude
ai-memory run codex --yolo
ai-memory run command-code

# 不带参数 — 自动继续最新可用会话
ai-memory run
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | ai-memory 通过 MCP 协议为 20+ Agent CLI 提供统一记忆接口，MCP 是其跨工具互操作的核心基础设施 |
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | ai-memory 解决 Agent 编码的最大痛点之一（上下文丢失），直接提升多 Agent 接力编码的可靠性 |

---
[← Back to Deep Dives](./README.md)
