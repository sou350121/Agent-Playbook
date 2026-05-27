---
auto_generated: true
generated_at: "2026-05-27T05:50:44Z"
source_url: "https://www.kanbots.dev/"
signal_type: "significant_update"
---
# Kanbots: 每张卡片独立跑 AI Agent 的开源看板工具 (Kanbots: Open Source Kanban Board Running Parallel Agents on Every Card)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-27
>
> **项目/工具**: Kanbots
> **链接**: https://github.com/leodavinci1/kanbots
> **核心定位**: 一个本地优先的 Kanban 桌面应用，让每张卡片独立运行一个 AI Agent，支持 11 种 Agent CLI 并行协作，用看板隐喻重构多 Agent 开发工作流。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：本地优先的 Kanban 桌面应用，每张卡片独立跑一个 AI Agent，支持 11 种 Agent CLI 并行协作
- **现在值得用吗**：是 — 如果你已经在用 Claude Code / Codex / Cursor 等 Agent CLI 做开发，Kanbots 能把散落的单 Agent 工作整合成可视化的并行系统
- **适合场景**：多任务并行开发、Persona 驱动的自动功能开发（Autopilot）、需要多 Agent 协作的中型项目
- **不适合场景**：只需要单 Agent 跑简单任务的项目、团队需要云端协作（Cloud 版尚未成熟）、不想安装任何 CLI 工具的用户
- **与 [竞品/前版] 核心差异**：OpenHands / CrewAI 等框架聚焦于 Agent 编排协议层，Kanbots 聚焦于**可视化看板 + 本地工作树隔离**，用 Kanban 隐喻让多 Agent 协作对开发者直观可见

## 是什么 / 解决什么问题

当前的 AI Agent 开发工作流存在一个根本矛盾：我们拥有越来越强大的单 Agent 工具（Claude Code、Codex、Cursor），但实际开发中需要同时处理多个任务——修 bug、开发 feature、写测试、做 code review。现有的解决方案要么是手动在多个终端窗口中分别运行 Agent，要么使用编排框架（如 CrewAI、AutoGen）但缺乏直观的可视化界面。

Kanbots 的解决方案是：**用 Kanban 看板作为多 Agent 协作的元界面**。每张卡片（Card）代表一个任务，点击 Dispatch 后，一个独立的 AI Agent 在隔离的 git worktree 中开始工作。你可以同时 dispatch 多个 Agent，每个在自己的分支上并行推进，看板实时更新进度、成本和决策点。

更激进的是 **Autopilot 模式**：定义一组 Persona（产品经理、工程师、测试员、审查者），Autopilot 编排器以 round-robin 方式轮流激活这些 Persona，Agent 在发现子任务时自动创建新卡片，backlog 自我演化，直到任务收敛或预算耗尽。

这个项目在 Hacker News 上获得了关注，GitHub Stars 已达 323（截至 2026-05-27），MIT 开源协议，桌面版免费。

## 技术架构拆解

### 核心设计决策

1. **本地优先，零数据外泄**：所有数据（SQLite 数据库、配置、worktrees）存储在 `.kanbots/` 目录下，没有云账户、没有遥测、没有 HTTP 服务器。代码永远不会离开本机。
2. **Agent CLI 适配器模式**：通过 `AgentCliAdapter` 抽象层支持 11 种 Agent CLI，复用用户已有的认证（不需要在 Kanbots 中登录）。这使 Kanbots 成为一个**元工具**——它不替代任何 Agent CLI，而是编排它们。
3. **工作树隔离**：每个 Agent 运行在独立的 git worktree 中（`kanbots/issue-N` 分支），互不干扰。完成后可以 Promote 为真实 commit 或 Draft PR，也可以 Discard。
4. **预推送钩子**：每个 worktree 安装 pre-push hook，防止 Agent 自行推送代码。Promotion 始终是用户显式操作。
5. **双产品策略**：Solo（桌面版，MIT 开源）面向个人开发者在一台机器上的工作；Cloud（商业化）面向团队协作。两者共享同一 Kanban 隐喻和 Agent 运行时。

### 与前版/竞品的关键差异

| 维度 | OpenHands / CrewAI | Kanbots |
|------|-------------------|---------|
| 交互范式 | 代码/配置文件定义编排 | 可视化 Kanban 看板 |
| 部署模式 | 容器化/云端 | 本地优先，零服务器 |
| Agent 隔离 | 容器级别 | git worktree 级别 |
| 可视化 | 有限（日志为主） | 完整的看板 UI + 实时 Agent 线程流 |
| 决策交互 | 通常自动或 API 回调 | 决策提示弹窗，用户点击选项继续 |
| 成本追踪 | 通常无或需集成第三方 | 内置实时成本分析（per-run/per-card/per-project） |
| 多 CLI 支持 | 通常绑定单一 Agent | 11 种 CLI + ACP 协议扩展 |
| 开源协议 | 各有不同 | MIT，免费 forever |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Kanbots Desktop App                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Card #1  │  │ Card #2  │  │ Card #3  │  ... (Kanban) │
│  │ Backlog  │  │ In Prog  │  │  Review  │              │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘              │
│       │              │              │                    │
│  ┌────▼──────────────▼──────────────▼─────┐             │
│  │        AgentCliAdapter (统一抽象层)      │             │
│  │  claude │ codex │ gemini │ cursor │ ... │            │
│  └────┬──────────────┬──────────────┬─────┘             │
│       │              │              │                    │
│  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐             │
│  │ worktree │  │ worktree │  │ worktree │  (git 隔离)  │
│  │issue-1/  │  │issue-2/  │  │issue-3/  │              │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
         │                              │
    ┌────▼─────┐              ┌────────▼────────┐
    │ .kanbots/│              │ kanbots-mcp-    │
    │ db.sqlite│              │ server (MCP)    │
    │ config   │              │ (Cursor/Claude  │
    │ worktrees│              │  Desktop 可驱动) │
    └──────────┘              └─────────────────┘
```

**Autopilot 编排流**：

```
Persona Roster [PM, Engineer, Reviewer, Tester]
       │
       ▼
┌──────────────┐    ┌──────────────┐
│ Slot 1       │    │ Slot 2       │   ... (最多 4 并行)
│ Round-robin  │    │ Round-robin  │
│ claim persona│    │ claim persona│
└──────┬───────┘    └──────┬───────┘
       │                    │
       ▼                    ▼
  Agent runs in        Agent runs in
  worktree #1          worktree #2
       │                    │
       ▼                    ▼
  Discovers subtask  →  Creates new Card on Board
       │
       ▼
  Orchestrator picks up new card in next cycle
       │
       ▼
  Stops on: completion | budget hit | user stop
```

## 实战陷阱

### 陷阱 1 — Autopilot 并行度设太高导致资源耗尽

**现象**：将 parallelism 设为 4 同时跑 4 个 Agent，每个 Agent 都在做 LLM 调用 + 文件操作。macOS M2 上 CPU 和内存会飙升，磁盘 I/O 成为瓶颈，导致所有 Agent 都变慢。

**规避方案**：从 parallelism=2 开始，观察系统资源使用。如果 CPU 使用率持续 >80% 或内存接近上限，降回 1。Kanbots 的 Autopilot 支持随时调整 parallelism 并重启会话，不需要重新配置。

### 陷阱 2 — worktree 磁盘空间泄漏

**现象**：每次 Agent dispatch 创建一个 worktree，如果频繁 discard 而不清理，`.kanbots/worktrees/` 目录会积累大量废弃分支和工作树，占用磁盘空间。

**规避方案**：定期运行 `git worktree prune` 清理孤立的 worktree。Kanbots 目前没有内置清理机制（TODO: 确认是否有自动清理），建议每周手动检查 `.kanbots/worktrees/` 目录大小。

### 陷阱 3 — 决策提示无人值守导致 Autopilot 挂起

**现象**：Agent 在运行中遇到需要人类决策的点时会暂停等待。如果 Autopilot 在夜间运行且没有人在电脑前，所有并行槽位可能最终都停在决策提示上，整个编排流挂起。

**规避方案**：使用 per-session cost budget 设置自动停止上限。当 Agent 累计成本达到预算时，Autopilot 自动停止所有运行中的 Agent，避免无限等待。也可以在 dispatch 前尽量提供详细的 spec，减少 Agent 需要决策的点。

## 生存指南

### 建议 1 — 从本地模式开始，熟悉后再切 GitHub 模式

本地模式（SQLite 存储 issues）零配置，适合快速上手。等熟悉了 Kanbots 的 dispatch → worktree → promote 流程后，再切换到 GitHub 模式驱动真实仓库的 issues。这样可以在不污染 GitHub 仓库的情况下练习。

### 建议 2 — Claude Code 用户：利用 CCR 路由到更便宜的模型

如果你使用 Claude Code 但担心成本，Kanbots 支持 CCR（Claude Code Router），复用 Claude Code 的认证但路由到替代模型（如更便宜的 Claude 版本）。在 Kanbots 的 Providers 面板中选择 CCR 作为 CLI，可以在保持相同工作流的同时降低成本。

### 建议 3 — 用 Sentry import 驱动错误修复工作流

如果你的项目接入了 Sentry，Kanbots 的 Sentry import 功能可以自动拉取错误组到看板，一键交给 Agent 处理。这比手动复制错误信息、创建 issue、dispatch Agent 的流程效率高得多。特别适合生产环境的错误批量修复场景。

### 建议 4 — 为每个 Agent CLI 设置独立的 cost cap

Kanbots 支持 per-run 和 per-session 两个层级的成本上限。建议为每个 Agent CLI 设置合理的 per-run cap（如 Claude Code 设为 $5/run），防止单个 Agent 因循环调用产生意外费用。Autopilot 模式下额外设置 per-session cap（如 $20/session）作为总预算控制。

### 建议 5 — Autopilot 的 Persona 要写具体的 system prompt

内置 Persona 模板是通用的。如果你在做特定领域的项目（如 Web 开发、数据管道），自定义 Persona 的 system prompt，加入项目特定的上下文、技术栈约束、代码风格要求。Autopilot 的效果高度依赖 Persona 的质量——模糊的 prompt 产生模糊的结果。

## Claude Code 专属视角

### 为什么 Kanbots 对 Claude Code 用户特别有价值

Claude Code 是目前最强的 agentic coding 工具之一，但它的局限在于：它是一个单线程 CLI。你打开一个终端，运行 `claude`，它在一个工作目录中工作。如果你需要同时做三件事——修 bug #123、开发 feature #456、写测试——你需要开三个终端窗口，手动管理三个工作目录。

Kanbots 把这个过程自动化了：
- **自动 worktree 管理**：每个卡片自动创建隔离的 git worktree，你不需要手动 `git worktree add`
- **并行调度**：一键 dispatch 多个 Agent，每个在自己的分支上并行推进
- **决策集中**：所有 Agent 的决策提示汇聚到一个 UI，不需要在多个终端间切换
- **成本可视化**：每个 run 的 token 用量和费用实时展示，Claude Code 本身不提供这个

### Claude Code + Kanbots 的典型工作流

```
1. 打开 Kanbots，选择项目文件夹
2. 创建 3 张卡片：Bug #123、Feature #456、Refactor auth module
3. 每张卡片选择 Claude Code 作为 CLI，设置 per-run cap = $5
4. 点击 Dispatch（3 张卡片并行）
5. 在 Decision 面板查看 Agent 的决策提示，点击选项继续
6. 完成后，Promote 每张卡片的 worktree 为 commit
7. 在 GitHub 模式下，一键开 Draft PR
```

### 注意事项

- Claude Code 的 `claude -p` 模式（prompt 模式）是 Kanbots 调用的方式，不是交互式模式。确保你的 Claude Code 版本支持 `-p` 标志
- Claude Code 需要登录认证（`claude /login`），Kanbots 不管理认证，它直接调用 PATH 上的 `claude` 命令
- 如果 Claude Code 的 session 超时或认证过期，Kanbots 中的 run 会失败。建议定期检查 Claude Code 的登录状态

## 实用评估

### 什么场景值得用

- **多任务并行开发**：同时修多个 bug、开发多个 feature，每个 dispatch 到独立卡片，Agent 并行推进。比手动开多个终端窗口管理效率高得多。
- **Persona 驱动的功能开发（Autopilot）**：定义一组 Persona（产品经理、工程师、审查者、测试员），Autopilot 自动编排它们协作。PM 拆分需求 → 工程师实现 → 审查者检查 → 测试员验证，发现子任务自动创建新卡片。适合功能明确但任务分解复杂的场景。
- **需要多 Agent CLI 混用的项目**：团队中有人偏好 Claude Code、有人偏好 Codex、有人用 Cursor。Kanbots 统一看板，每个卡片可以用不同的 CLI dispatch。
- **成本敏感场景**：内置实时成本分析，per-run/per-card/per-project 三个维度，可设 per-run 和 per-session 预算上限，超预算自动停止。
- **Sentry 错误驱动开发**：Sentry import 功能自动拉取错误组到看板，一键交给 Agent 处理。

### 什么场景不值得用

- **单 Agent 简单任务**：如果只需要跑一个 Claude Code 或 Codex 完成简单任务，直接用 CLI 更高效。Kanbots 的价值在于多 Agent 协作。
- **需要云端团队协作**：Cloud 版尚在早期（定价页面存在但功能有限），如果团队需要多设备/多人协作，目前不是最佳选择。
- **不想安装 CLI 工具**：Kanbots 本身不运行 Agent，它调用你 PATH 上的 Agent CLI。你需要先安装至少一个 Agent CLI。
- **非 git 项目**：Kanbots 依赖 git worktree 机制，非 git 项目无法使用。
- **Windows 用户需注意**：Windows 构建未签名，SmartScreen 会警告，体验不如 macOS/Linux 流畅。

### 迁移成本

- **从手动多终端切换到 Kanbots**：安装 `npx kanbots`（~80MB），选择 git 仓库文件夹，Kanbots 在 `.kanbots/` 中创建数据库和配置。迁移成本极低，约 5 分钟。
- **从 OpenHands / CrewAI 迁移**：需要重新定义工作流——从代码/配置文件定义的编排转为看板驱动的可视化编排。学习曲线中等，但可视性大幅提升。
- **从单一 Agent CLI 切换到多 Agent 协作**：需要理解 worktree 隔离、Promotion 流程、决策提示交互。大约 1-2 个 session 的上手时间。

## 对你的意义

对 Ken 的 AI Agent 开发方向来说，Kanbots 有几个值得关注的点：

1. **多 Agent 协作的可视化范式**：Kanbots 用 Kanban 隐喻解决多 Agent 协作的可视化问题，这与 Agent-Playbook 中追踪的 Agent 架构趋势高度契合。它证明了"可视化编排"是一个真实需求，而不只是概念。
2. **Persona 驱动的 Autopilot**：Autopilot 模式中 Persona 自我演化的 backlog 机制，与多 Agent 协作框架（CrewAI、AutoGen）的方向一致，但用更轻量的方式实现——不需要容器编排，只需要 git worktree。
3. **MCP 集成**：内置 MCP server，Cursor / Claude Desktop 等 MCP-aware 工具可以直接驱动看板。这是 MCP 协议在工具集成场景的一个具体落地案例，支持 A-001（MCP 成为 AI Agent 工具集成事实标准）。
4. **本地优先策略**：在 AI 工具越来越依赖云端的趋势下，Kanbots 坚持本地优先、零数据外泄，这对注重数据安全的场景有参考价值。

**建议**：如果 Ken 的团队正在探索多 Agent 协作的实际工作流，Kanbots 值得试用。它把抽象的 Agent 编排变成了可视化的看板操作，降低了多 Agent 协作的认知负担。

## 关键代码/配置片段

### .kanbots/ 目录结构

```
.kanbots/
├── db.sqlite          # 所有 issues, threads, runs, providers, settings
├── config.json        # workspace mode + defaults
├── worktrees/         # 每个 Agent run 一个子目录
├── attachments/       # 拖入聊天/卡片的文件
├── mcp-runtime/       # 临时 MCP 配置
└── promote/           # worktree 提升为 commit 的暂存区
```

### 安装方式

```bash
# 推荐方式：npx
npx kanbots

# 升级
npx kanbots@latest

# macOS 一键安装脚本（清除 Gatekeeper 隔离标记）
curl -fsSL https://kanbots.dev/install-mac.sh | bash

# 从源码运行
git clone https://github.com/leodavinci1/kanbots.git
cd kanbots
pnpm install
pnpm desktop        # 构建并打开 Electron
pnpm desktop:dev    # 热重载开发模式
```

### 支持的 Agent CLI 一览

| Provider | CLI Binary | Sign-in |
|----------|-----------|---------|
| Claude Code | `claude` | `claude /login` |
| Codex | `codex` | `codex login` 或 `OPENAI_API_KEY` |
| Gemini | `gemini` | `gemini auth` |
| Cursor CLI | `cursor-agent` | `cursor-agent login` |
| GitHub Copilot CLI | `gh-copilot` | `gh auth login` |
| Amp | `amp` | `amp login` |
| OpenCode | `opencode` | `opencode auth` |
| Droid | `droid` | `droid auth` |
| CCR | `ccr` | 复用 Claude Code auth |
| Qwen Code | `qwen` | `qwen auth` |
| ACP-compatible | 自定义 | 按 CLI 而定 |

### 决策交互（Decision Prompts）

Agent 在运行中遇到需要人类决策的点时会暂停，UI 弹出决策提示：
- 编号选项：点击选择，运行继续
- 回复框：支持 `/spec`、`/review`、`/split` 等斜杠命令
- 实时线程流：每个 `tool_use` / `tool_result` 事件实时展示

---
[← Back to Deep Dives](./README.md)
