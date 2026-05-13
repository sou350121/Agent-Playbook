---
auto_generated: true
generated_at: "2026-05-13T05:47:20Z"
source_url: "https://github.com/statewright/statewright/releases"
signal_type: "blog_post"
---
# Statewright：用确定性状态机约束 AI Agent 的工具空间 (Statewright: State Machine Guardrails for AI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-13
>
> **项目/工具**: Statewright
> **链接**: https://github.com/statewright/statewright
> **核心定位**: 一个 Rust 引擎 + MCP 插件层，通过确定性状态机控制 AI 编码 Agent 在每个阶段可用的工具集，解决 agentic 编程中"工具太多导致模型表现脆弱"的问题。

## ⚡ 快速判断

> **一句話定位**：用状态机给 AI Agent 装"护栏"——每个阶段只暴露该阶段的工具，防止模型在 40+ 工具空间中迷失。
>
> **現在值得用嗎**：是，尤其适合在 Claude Code / Codex 上跑结构化 bugfix 流程的开发者。免费层对个人开发者足够。
>
> **適合場景**：结构化编码任务（bugfix、test-driven 开发、代码审查流程）、本地模型推理加速
>
> **不適合場景**：探索性/开放式编码任务（需要灵活切换工具）、Cursor 用户（仅 advisory 模式，非硬拦截）
>
> **與傳統 agentic 核心差異**：传统做法是"给模型更多工具 + 更大 prompt"，Statewright 反其道而行——"让问题变小"，通过确定性状态机缩小每个步骤的搜索空间。

## 是什么 / 解决什么问题

AI 编码 Agent（Claude Code、Codex、Cursor 等）面临一个根本矛盾：模型能力越强，能调用的工具越多，但实际表现却越来越不稳定。给一个模型 40+ 个工具和开放式问题，它往往连第一步都走不稳。

社区常见的应对方案是：更大的模型、更长的 prompt、更好的可观测性。但这些方案要么是成本问题（更大模型），要么是事后诸葛亮（可观测性告诉你哪里错了，但不防止错误发生）。

Statewright 提出了一个不同的思路：**不放大模型，缩小问题**。

它的核心是一个用 Rust 编写的确定性状态机引擎——没有 LLM 参与决策。状态机定义了工作流的阶段（states）、阶段间的转换条件（transitions）、每个阶段允许使用的工具（allowed_tools），以及守卫条件（guards）。Agent 在 planning 阶段只能用 Read/Grep/Glob 等只读工具；转换到 implementing 阶段后，Edit/Write 工具才解锁；testing 阶段只允许运行指定的测试命令。

这种设计的直觉很简单：当模型只需要在 5 个工具中做选择而不是 30 个时，它更可能正确地推理。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| Rust 引擎，确定性执行 | 零延迟、无 LLM 调用开销、行为可预测 |
| MCP 协议集成 | 在协议层拦截工具调用，模型看不到不允许的工具 |
| 状态机（非 DAG） | 支持循环和重试——这才是 agentic 工作的真实需求 |
| 分层架构：引擎 + 插件 | 引擎可嵌入任何宿主，插件适配不同 Agent |
| 每会话状态隔离 | 通过 CLAUDE_SESSION_ID 实现多会话互不干扰 |

### 与前版/竞品的关键差异

| 维度 | 传统 Agentic（无约束） | Statewright |
|------|----------------------|-------------|
| 工具可见性 | 全部 40+ 工具始终可见 | 仅当前状态的 allowed_tools 可见 |
| 错误预防 | 事后观测 + 人工干预 | 协议层硬拦截，不允许即不可见 |
| 决策逻辑 | LLM 自主决定工具调用顺序 | 确定性状态机控制流程 |
| 模型大小影响 | 越大越好（需要更强推理能力处理复杂上下文） | 小模型也能工作（gpt-oss 20B 在 SWE-bench 上 5/5） |
| 可观测性 | 独立工具，事后分析 | 内置状态追踪，实时知道 Agent 在哪个阶段 |
| 成本 | 每次决策消耗 token | 引擎本身零 token 开销 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                  AI Coding Agent                     │
│   (Claude Code / Codex / Cursor / opencode / Pi)    │
│                                                      │
│  ┌──────────┐    ┌──────────────┐    ┌───────────┐  │
│  │ planning │───▶│ implementing │───▶│  testing  │  │
│  │ 只读工具  │    │ 编辑工具      │    │ 测试命令   │  │
│  │ R:8 max  │    │ E:20 lines   │    │ pytest    │  │
│  └──────────┘    └──────────────┘    └─────┬─────┘  │
│         ▲                                   │        │
│         │        ┌──────────────────────┐   │        │
│         └────────│    FAIL → 回退       │◀──┘        │
│                  └──────────────────────┘            │
└──────────────────────┬───────────────────────────────┘
                       │ MCP Protocol
                       ▼
┌─────────────────────────────────────────────────────┐
│              Statewright Engine (Rust)               │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ State Machine│  │   Guards     │  │  Bash      │ │
│  │ Definition   │  │ (predicates) │  │ Discernment│ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ Tool         │  │ Edit         │  │ Approval   │ │
│  │ Enforcement  │  │ Guards       │  │ Gates      │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
│                                                      │
│  Deterministic · No LLM in the loop · Zero latency   │
└─────────────────────────────────────────────────────┘
```

### 护栏体系详解

Statewright 提供了 8 层护栏，构成完整的执行约束体系：

| 护栏 | 机制 | 效果 |
|------|------|------|
| Per-state tool enforcement | 工具不在 allowed_tools 时对 Agent 不可见 | 从源头消除误调用 |
| Bash discernment | 拦截重定向(>>), 破坏性操作(rm, shred), 脚本解释器 | 防止意外数据损坏 |
| Edit guards | 限制 max_edit_lines 和 max_files_per_state | 防止大规模误改 |
| Command allow-lists | 按状态前缀匹配允许的命令 | 只允许 pytest/cargo test 等 |
| Conditional transitions | 程序化守卫（eq, gt, exists 等） | 测试通过才允许进入 completed |
| Approval gates | requires_approval 暂停等待人工审核 | 高风险操作需人工确认 |
| Environment scoping | blocked_env + env_overrides 按状态隔离 | 防止环境变量泄露 |
| Session isolation | 每会话独立状态 | 多任务互不干扰 |

## 研究数据

Statewright 在本地模型上做了可测量的验证。在 5 题 SWE-bench 子集上：

| 模型 | 大小 | Bug Fix (26行) | SWE-bench (5 tasks) |
|------|------|----------------|---------------------|
| gemma3 | 3.3GB | FAIL | FAIL |
| gemma4:e2b | 7.2GB | PASS* | FAIL |
| gpt-oss:20b | 13.8GB | PASS | PASS (5/5) |
| gemma4:31b | 19.9GB | PASS | PASS (5/5) |
| llama3.3 | 42.5GB | PASS | PASS (2/2)† |

关键数据点：
- **13.8GB 和 19.9GB 模型从 2/10 提升到 10/10**——相同任务、相同硬件，仅加状态机约束
- 低于 13GB 的模型无法保留足够的文件内容来产生准确的编辑——这是模型能力下限，不是 Statewright 的限制
- 前沿模型（Claude、GPT-4 等）的结构性收益在于打破"读循环死亡螺旋"（模型反复读同一个文件 5+ 次却从不编辑）

> TODO: 官方提到 full research brief 在 statewright.ai/research，但该页面为 JS 渲染 SPA，未能抓取完整数据。SWE-bench 子集的具体 5 个 task ID 未在 README 中列出。

## 工作流定义示例

Statewright 的工作流用 JSON Schema 定义，Agent 也可以通过 `statewright_create_workflow` MCP 工具自动生成：

```json
{
  "id": "bugfix",
  "initial": "planning",
  "states": {
    "planning": {
      "allowed_tools": ["Read", "Grep", "Glob"],
      "max_iterations": 8,
      "on": { "READY": "implementing" }
    },
    "implementing": {
      "allowed_tools": ["Read", "Edit", "Write"],
      "max_edit_lines": 20,
      "max_files_per_state": 3,
      "on": { "DONE": "testing" }
    },
    "testing": {
      "allowed_tools": ["Read", "Bash"],
      "allowed_commands": ["pytest", "cargo test", "npm test"],
      "on": {
        "PASS": { "target": "completed", "guard": "tests_passed" },
        "FAIL_TEST": "implementing"
      }
    },
    "completed": { "type": "final" }
  },
  "guards": {
    "tests_passed": { "field": "test_result", "op": "eq", "value": "pass" }
  }
}
```

这个例子的精妙之处在于：
1. **planning 阶段限制 8 次迭代**——防止模型无限读文件
2. **implementing 限制每次最多 20 行编辑、3 个文件**——防止大规模误改
3. **testing 阶段只允许测试命令**——防止在测试阶段执行任意 bash 命令
4. **FAIL_TEST 回退到 implementing**——状态机支持循环，不是单向 DAG

## 支持的 Agent 与执行强度

| Agent | 集成方式 | 执行强度 |
|-------|---------|---------|
| Claude Code | Hooks + MCP | **Hard**（协议层拦截） |
| Codex | Hooks | **Hard**（alpha） |
| opencode | TypeScript 插件 | **Hard**（alpha） |
| Pi | Skills 扩展 | **Hard**（alpha） |
| Cursor | MCP + rules | **Advisory**（仅注入规则，不硬拦截） |

**Hard vs Advisory 的区别**：Hard 模式下，工具调用在协议层被拦截，模型根本看不到不允许的工具。Advisory 模式下，规则只是注入到上下文中，模型可以选择忽略——Cursor 因为架构限制无法实现硬拦截。

## 实用评估

### 什么场景值得用

- **结构化 bugfix 流程**：读代码 → 修改 → 测试 → 完成，这是 Statewright 的 default workflow，开箱即用
- **TDD 开发循环**：写测试（红）→ 实现功能（绿）→ 重构，状态机天然匹配这个循环
- **代码审查流程**：planning（阅读 PR diff）→ implementing（提出修改建议）→ testing（验证修改不破坏其他功能）
- **本地模型推理加速**：在 13B+ 本地模型上，状态机约束可以显著提升成功率（2/10 → 10/10），这对资源受限场景意义重大
- **多 Agent 协作中的角色隔离**：不同 Agent 负责不同状态阶段，避免工具冲突

### 什么场景不值得用

- **探索性编码**：当你不确定该用什么工具时，状态机的约束反而会成为障碍
- **Cursor 用户**：目前仅 Advisory 模式，不保证硬拦截效果
- **复杂多步骤重构**：如果重构涉及 10+ 个文件的交叉修改，20 行/3 文件的限制可能需要频繁调整
- **需要灵活工具切换的研究型任务**：状态机假设你能预先定义工作流，但研究型任务的工作流往往是 emergent 的

### 迁移成本

- **安装**：Claude Code 下 3 条命令（`/plugin marketplace add` → `/plugin install` → `/reload-plugins`），约 2 分钟
- **配置**：需要注册 statewright.ai 获取 API key（免费层可用）
- **工作流定制**：使用默认 bugfix workflow 零配置；自定义 workflow 需要学习 JSON schema，约 30 分钟
- **团队部署**：Pro 计划 $29/月（10 workflow，2500 次转换/月），Team 计划 $99/月

### 已知局限

| 局限 | 影响 | 缓解方案 |
|------|------|---------|
| 需要 MCP 支持 | Codex/opencode 仅 alpha | 使用 Hooks 模式替代 |
| Cursor 仅 Advisory | 不保证硬拦截 | 等待 Cursor 开放更多协议层 API |
| 小模型（<13GB）无法准确编辑 | 不是 Statewright 的限制，是模型能力下限 | 使用 13B+ 模型 |
| 研究数据仅 5-task 子集 | 未在完整 SWE-bench (2294 tasks) 上验证 | TODO: 等待完整 benchmark |
| Workflow 过于严格可能导致 Agent 卡住 | 需要人工干预 | `statewright_deactivate` 作为逃生舱 |

## 对你的意义

Statewright 代表了一个重要的范式转变：**从"让模型更聪明"到"让问题更简单"**。

对 Ken 的两条线都有启发：

**AI 应用线**：Statewright 直接解决了 Agent 框架中最棘手的可靠性问题。如果你的 Agent-Playbook 关注 Agent 工程实践，这个工具值得收录——它提供了一种不同于 LangGraph 状态图的新思路（更轻量、更确定、更专注于编码场景）。

**VLA 研究线**：虽然 Statewright 面向编码 Agent，但其核心思想——用确定性状态机约束高维决策空间——与 VLA 中的 action space 约束有异曲同工之妙。VLA 面临类似的问题：给模型太多的 action 选项会导致策略学习困难。Statewright 的"缩小问题空间"思路可能值得在 VLA 的 action 规划层借鉴。

**建议**：如果你在 Claude Code 上跑 bugfix 任务，立即试用。默认 workflow 开箱即用，零配置成本。如果想深入，可以自定义 workflow 来匹配你的开发流程。

## 关键代码/配置片段

### 引擎嵌入示例（Rust）

```rust
use statewright_engine::{MachineDefinition, resolve_transition, validate_definition};
```

引擎以 Apache 2.0 开源，可嵌入无运行时依赖。

### 安装命令（Claude Code）

```
/plugin marketplace add statewright/statewright
/plugin install statewright
/reload-plugins
```

### 工作流启动

```
❯ start the bugfix workflow — fix the failing tests in calc.py

◆ statewright — statewright_start (workflow: bugfix)
◆ [statewright] Workflow activated: bugfix

◆ statewright — statewright_get_state (MCP)
◆ Current phase: planning. Let me read the code first.

 Read 2 files
 [statewright] planning => implementing

◆ statewright — statewright_transition (READY)

 Edit calc.py: 1 line changed
 [statewright] implementing => testing

◆ statewright — statewright_transition (DONE)

 Bash: pytest -x — 7 passed
 [statewright] testing => completed

◆ [statewright] Workflow complete. 46 seconds.
```

### 许可证

- 引擎核心（`crates/engine`）：Apache 2.0
- 其余部分：FSL-1.1-ALv2（2029-05-03 自动转换为 Apache 2.0）

---
[← Back to Deep Dives](./README.md)
