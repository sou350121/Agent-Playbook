---
auto_generated: true
generated_at: "2026-05-30T06:48:36Z"
source_url: "https://github.com/affaan-m/ECC/releases/tag/v1.10.0"
signal_type: "significant_update"
---
# ECC（Everything Claude Code）：从 Claude Code 插件到跨 Harness 操作系统的进化 (ECC: From Claude Code Plugin to Cross-Harness Operating System)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-30
>
> **项目/工具**: ECC (Everything Claude Code)
> **链接**: https://github.com/affaan-m/ECC/releases/tag/v2.0.0-rc.1
> **核心定位**: 一个跨 AI 编码工具（Claude Code / Codex / OpenCode / Cursor / Gemini / Zed）的通用性能优化层——把技能、规则、钩子、MCP 配置和 Operator 工作流抽象为可复用资产，让不同 Agent Harness 共享同一套工作流基础设施。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：ECC 是一个 Agent Harness 性能系统，将技能、规则、钩子、安全扫描和 Operator 工作流打包为跨工具可复用的开源资产。
- **现在值得用吗**：是——如果你同时使用多个 AI 编码工具（Claude Code + Codex + Cursor），ECC 的跨 Harness 抽象能显著减少重复配置。
- **适合场景**：多工具并行开发、团队级 Agent 工作流标准化、需要安全审计（AgentShield）的工程团队
- **不适合场景**：只用单一编码工具的个人开发者（ECC 的跨工具优势无法发挥）；需要生产级会话管理的团队（ecc2 Rust 控制平面仍为 Alpha）
- **与竞品核心差异**：Cursor Rules / Copilot Custom Instructions 是单工具配置；ECC 是跨工具的可移植技能系统（SKILL.md 为核心单元），同一套工作流可以部署到 7 种 Harness。

## 是什么 / 解决什么问题

AI 编码工具生态正在快速分化——Claude Code、GitHub Copilot (Codex)、OpenCode、Cursor、Gemini、Zed……每个工具都有自己的规则格式、钩子系统、插件机制和 MCP 配置方式。对于同时使用多种工具的开发者或团队来说，这意味着同一套工作流需要在每个工具里重新实现一遍。

ECC（Everything Claude Code）的解决方案是：**把" durable 的工作流行为"从"工具特定的加载方式"中剥离出来**。

它的核心设计哲学是：技能（Skills）应该用统一的 SKILL.md 格式编写一次，然后通过各 Harness 的适配器层加载。规则（Rules）、钩子（Hooks）、MCP 配置、命令（Commands）遵循同样的模式——共享源，边缘适配。

截至 v2.0.0-rc.1（2026 年 4 月），ECC 已经成长为：
- **63 个 Agent**（覆盖工程、研究、内容、运营等场景）
- **249 个 Skills**（从代码审查到视频制作到预测市场研究）
- **79 个 Legacy Command Shims**（向后兼容）
- **182K+ GitHub Stars**、28K+ Forks、170+ Contributors
- 支持 TypeScript、Python、Go、Java、Kotlin、Swift、Rust、C++、PHP、Perl 等 12+ 语言生态

这个项目在 10 个月的持续高强度使用中迭代出来——不是概念验证，而是从真实产品开发中沉淀出来的系统。

## 技术架构拆解

### 核心设计决策

**1. SKILL.md 作为可移植性核心单元**

ECC 选择 Markdown + YAML Frontmatter 作为技能描述格式：

```yaml
---
name: my-skill
description: "做什么"
origin: "来源"
---
## 何时使用
## 所需工具/连接器
## 示例
```

一个合格的 SKILL.md 应该：不嵌入密钥、不依赖特定 Harness 的命令语法、示例保持仓库相对路径或通用。这样同一份源文件可以被 Claude Code 插件、Codex AGENTS.md、OpenCode 插件、Cursor 规则系统各自加载。

**2. 共享源 + 边缘适配的 Portability Model**

| 资产类型 | 共享源位置 | 各 Harness 适配方式 | 当前状态 |
|----------|-----------|-------------------|---------|
| Skills | `skills/*/SKILL.md` | Claude 插件 / Codex 插件 / .agents/skills / Cursor 复制 / OpenCode 插件 | 支持，各有打包差异 |
| Rules & Instructions | `rules/`, `AGENTS.md` | Claude Rules / Codex AGENTS.md / Cursor Rules / OpenCode Instructions | 支持，行为不完全一致 |
| Hooks | `hooks/hooks.json`, `scripts/hooks/` | Claude 原生钩子 / OpenCode 插件事件 / Cursor 钩子适配器 | Claude/OpenCode/Cursor 有钩子支持；Codex 为指令驱动 |
| MCPs | `.mcp.json`, `mcp-configs/` | 各 Harness 原生 MCP 配置导入 | 支持暴露 MCP 接口的 Harness |
| Commands | `commands/`, CLI 脚本 | Claude 斜杠命令 / 兼容 shim / CLI 入口 | 支持，命令语义有差异 |
| Sessions | `ecc2/`, 会话适配器 | TUI/Daemon / tmux/worktree 编排 | Alpha |

**3. ECC 与 Hermes 的边界分离**

ECC v2.0 明确区分了两个概念：
- **ECC** = 可复用的子层（substrate）——技能、规则、钩子、MCP 配置
- **Hermes** = Operator Shell（操作外壳）——聊天、定时任务、交接、日常路由

Hermes 消费 ECC 资产（导入技能、使用 MCP 约定、路由工作流），但 Hermes 本身不是 ECC 的运行时。公共仓库只发布可复用模式，不发布本地 Hermes 状态。

**4. AgentShield 安全管道**

内置 `/security-scan` 命令，直接调用 AgentShield 进行安全扫描。截至 v1.6.0，拥有 1282 个测试用例和 102 条规则。这是 ECC 区别于普通配置包的关键——它不只是"更好的 prompt"，而是包含安全审计能力的完整系统。

**5. Rust 控制平面（ecc2/）—— Alpha 阶段**

v2.0 引入了 Rust 编写的控制平面原型 `ecc2/`，提供以下命令：
- `dashboard` — 仪表板
- `start` / `stop` / `resume` — 会话生命周期管理
- `sessions` / `status` — 状态查询
- `daemon` — 守护进程模式

这是一个 Alpha 功能，尚未进入通用发布。但它代表了 ECC 从"配置包"向"运行时系统"演化的方向。

### 与前版/竞品的关键差异

| 维度 | Cursor Rules / Copilot Instructions | ECC v2.0.0-rc.1 |
|------|-----------------------------------|-----------------|
| 跨工具支持 | 单工具 | 7 种 Harness（Claude Code, Codex, OpenCode, Cursor, Gemini, Zed, Terminal） |
| 技能格式 | 工具特定 | 统一 SKILL.md + YAML Frontmatter |
| 钩子系统 | 有限或无 | 原生钩子（Claude/OpenCode/Cursor）+ 指令驱动（Codex） |
| 安全审计 | 无 | AgentShield 集成（1282 测试, 102 规则） |
| 会话管理 | 无 | ecc2/ Alpha（Rust 控制平面） |
| 持续学习 | 无 | Instinct 系统（置信度评分 + 导入/导出 + 演化） |
| 安装方式 | 手动 | 清单驱动（install-plan.js + install-apply.js）+ 选择性安装 |
| 测试覆盖 | N/A | 997+ 内部测试全绿 |
| 许可证 | 闭源 | MIT（永久开源） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                    Operator (Hermes)                  │
│  Chat · Cron · Handoff · Daily Routing               │
└────────────────────┬────────────────────────────────┘
                     │ 消费/导入
┌────────────────────▼────────────────────────────────┐
│              ECC — Reusable Substrate                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │ Skills/  │ │ Rules/   │ │ Hooks/   │ │ MCPs/  │ │
│  │ SKILL.md │ │ AGENTS.md│ │ hooks.json││ .mcp.json││
│  └──────────┘ └──────────┘ └──────────┘ └────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────────┐ │
│  │Commands/ │ │ecc2/     │ │ AgentShield          │ │
│  │ CLI shim │ │ Rust CP  │ │ (1282 tests, 102 rl) │ │
│  └──────────┘ └──────────┘ └──────────────────────┘ │
└─────────┬──────────┬──────────┬──────────┬──────────┘
          │          │          │          │
    ┌─────▼───┐ ┌───▼────┐ ┌──▼───┐ ┌───▼────┐
    │Claude   │ │Codex   │ │Cursor│ │OpenCode│ ...
    │Code     │ │        │ │      │ │        │
    │Plugin   │ │AGENTS  │ │Rules │ │Plugin  │
    │+ Hooks  │ │+ MCP   │ │+ Hook│ │+ Events│
    └─────────┘ └────────┘ └──────┘ └────────┘
```

## 实用评估

### 什么场景值得用

**1. 多工具并行开发团队**
如果你的团队同时使用 Claude Code（复杂重构）、Cursor（快速原型）、Codex（CI 集成），ECC 的跨 Harness 抽象可以让团队维护一套技能库而非三套。SKILL.md 编写一次，各工具通过适配器加载。

**2. 需要安全审计的工程流程**
AgentShield 集成提供了开箱即用的安全扫描能力（1282 测试 + 102 规则）。对于有合规要求的团队，这是 ECC 区别于其他配置工具的核心价值。

**3. 需要 Agent 工作流标准化的团队**
ECC 的 63 个 Agent 覆盖工程审查、研究、内容创作、运营等场景。如果团队需要标准化的 Agent 工作流（而非每个人写自己的 prompt），ECC 提供了经过 10 个月实战验证的模式库。

**4. 持续学习需求**
ECC 的 Instinct 系统支持从会话中自动提取模式并转化为可复用技能，带有置信度评分和导入/导出/演化能力。对于希望 Agent 工作流随时间进化的团队，这是独特能力。

### 什么场景不值得用

**1. 单一工具用户**
如果你只用 Claude Code 或只用 Cursor，ECC 的跨工具优势无法发挥。直接使用工具原生的规则/插件系统更简单。

**2. 需要生产级会话管理**
ecc2/ Rust 控制平面仍是 Alpha 状态。如果需要可靠的会话管理、跨会话状态恢复、分布式编排，ECC 目前不能替代专业的 Agent 编排框架（如 LangGraph、AutoGen）。

**3. 轻量级需求**
如果你只需要基本的代码审查规则或简单的 prompt 模板，ECC 的完整安装（63 agents + 249 skills）可能过重。可以使用 `--profile minimal` 只安装规则，但即便如此，学习成本也不低。

**4. 需要 Hook 完全一致的行为**
虽然 ECC 支持多 Harness 的钩子，但各工具的钩子语义和执行时机不完全一致（Codex 目前仅指令驱动，无原生钩子）。如果工作流对钩子执行时机有严格要求，需要仔细验证。

### 迁移成本

**从 Cursor Rules 迁移到 ECC**：
- 将现有 Cursor Rules 重写为 SKILL.md 格式（YAML Frontmatter + Markdown 正文）
- 配置 ECC 的 Cursor 适配器（复制规则到 `.cursor/` 目录）
- 预计工作量：每个规则文件 15-30 分钟重写 + 一次性 ECC 安装配置（约 1-2 小时）

**从 Copilot Custom Instructions 迁移到 ECC**：
- 将 Instructions 拆解为 Skills + Rules
- 配置 Codex AGENTS.md + MCP 参考配置
- Hook 支持目前为指令驱动（Codex 无原生钩子），需要调整工作流预期
- 预计工作量：每个 Instruction 20-40 分钟拆解 + 安装配置（约 2-3 小时）

**从空白开始**：
- ECC 提供交互式安装向导（`configure-ecc` skill）
- 支持选择性安装（`--profile minimal` / `--profile core` / `--profile full`）
- 支持 `--without baseline:hooks` 跳过钩子运行时
- 预计首次上手时间：30 分钟到 2 小时（取决于选择的配置深度）

## 对你的意义

ECC 的跨 Harness 架构与 AI Agent 生态的碎片化趋势直接相关。随着 Claude Code、Codex、Cursor、OpenCode 等工具各自发展，工作流的可移植性正成为一个真实痛点。

**值得关注的信号**：
- ECC 的 SKILL.md 格式如果成为事实标准，可能影响整个 Agent 配置生态的走向
- Hermes 作为 Operator Shell 的定位——它尝试解决"人如何高效管理多个 Agent 会话"的问题，这是多 Agent 协作的前置条件
- ecc2/ Rust 控制平面的演进方向——如果从 Alpha 走向 GA，ECC 将从"配置系统"升级为"运行时系统"

**建议**：如果你正在构建跨工具的 Agent 工作流，或者团队已经感受到多工具配置的维护成本，值得花时间评估 ECC 的 SKILL.md 格式和跨 Harness 适配模型。即使不直接采用，它的设计思路也值得学习。

## 关键代码/配置片段

### SKILL.md 标准格式（来自 ECC 文档）

```yaml
---
name: skill-name
description: "技能描述"
origin: "来源"
---

## 何时使用
<!-- 描述触发条件 -->

## 所需工具/连接器
<!-- 列出需要的工具，不嵌入密钥 -->

## 示例
<!-- 仓库相对路径或通用示例 -->
```

### 选择性安装命令（来自 README）

```bash
# 最小安装（不含钩子运行时）
./install.sh --profile minimal --target claude

# 核心安装但禁用钩子
./install.sh --profile core --without baseline:hooks --target claude

# 后续按需添加钩子
./install.sh --target claude --modules hooks-runtime

# 运行时控制钩子行为
export ECC_HOOK_PROFILE=minimal  # 或 standard / strict
export ECC_DISABLED_HOOKS="hook1,hook2"
```

### Operator 状态快照（来自 v2.0.0-rc.1）

```bash
# 生成本地状态的可移植交接文档
ecc status --markdown --write status.md

# 同步 GitHub PR/Issue 队列状态
ecc work-items sync-github --repo owner/repo

# 自动化就绪检查（失败时返回非零退出码）
ecc status --exit-code
```

---
[← Back to Deep Dives](./README.md)
