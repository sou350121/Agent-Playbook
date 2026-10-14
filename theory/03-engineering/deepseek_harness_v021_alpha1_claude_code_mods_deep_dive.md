---
auto_generated: true
---

# DeepSeek Harness v0.2.1-alpha.1：把 Claude Code Mods 收编为「插件子集」 (DeepSeek Harness v0.2.1-alpha.1: Absorbing Claude Code Mods as a Plugin Subset)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-14
>
> **项目/工具**: DeepSeek Harness (dsh)
> **链接**: https://github.com/deepseek-ai/deepseek-harness/releases/tag/dsh-v0.2.1-alpha.1
> **核心定位**: 一个主打「万物皆插件（Everything is a Plugin）」的开源 Agent Harness，这次用实验性兼容层去证明 Claude Code Mods API 大致只是它插件能力的一个子集。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**：DeepSeek Harness 是 DeepSeek AI 开源的 Agent 运行时（TypeScript / MIT），这次 alpha 版新增一个**实验性 Claude Code Mods 兼容层**，目的不是「让 dsh 能跑 Claude Code 插件」，而是**用一个真实的第三方扩展 API 来反向验证自家插件模型是超集**。
- **现在值得用吗**：看场景。想研究「Agent Harness 的扩展点应该长什么样」的人值得读；想立刻把 Claude Code 插件搬到 dsh 上跑生产的人，**暂时不要**——官方明说这不是完整兼容。
- **适合场景**：插件系统架构研究、多 Harness 扩展生态互通性观察、需要「运行时一切皆插件」的深度定制。
- **不适合场景**：追求稳定生产环境（该项目仍处 developer preview，官方警告「THERE WILL BE COMPATIBILITY-BREAKING CHANGES」）、只想白嫖 Claude Code 插件。
- **与 Claude Code 的核心差异**：Claude Code 的 Mods（插件）是它自己的扩展面；dsh 把「插件」提升为**唯一的组合原语**——Web、Desktop、自动化任务、甚至兼容层本身都是插件。前者是「核心 + 插件」，后者是「插件构成核心」。

## 是什么 / 解决什么问题

**DeepSeek Harness（命令行 `dsh`）** 是 DeepSeek AI 于 2026 年 8 月中开源的一个 Agent Harness（仓库 `deepseek-ai/deepseek-harness`，MIT 协议，主语言 TypeScript）。它最鲜明的标签写在仓库一句话简介里：**Everything is a Plugin**——整个系统构建在 Cordis 之上，作者团队把其设计写成了一篇论文《A Programming Paradigm for Spatiotemporal Composability》。

真正值得关注的是这次 `dsh-v0.2.1-alpha.1`（2026-10-03 发布，prerelease）里的一句话：

> 新增实验性 Claude Code Mods 兼容层。目前阶段的主要目的是验证 Claude Code Mods API 功能大致为 DeepSeek Harness 插件的一个子集，而非为用户提供实际的完整兼容性。

这句话信息量很大。市面上大多数「兼容」是**实现层**的：写一个适配器，把别人的插件在你这里跑起来。而 dsh 选择的是**反向验证**——它想用 Claude Code 已经成熟的 Mods API 作为参照物，来论证「我们这套插件模型的表达能力 ≥ 对方的扩展面」。这是一个关于**架构自信**的公开声明，也是本文值得深挖的原因：它反映的是 Agent Harness 竞争正从「功能谁多」转向「扩展模型谁更通用」。

## 技术架构拆解

### 核心设计决策

- **单一组合原语**：dsh 把「插件」当作系统唯一的组装单位。Release notes 里能直接看到这一哲学的落地——`Automation`（自动化任务）这次被明确「改为 Web 内置能力」，连官方能力都在用插件边界重新划。
- **按模式裁剪工具集**：提醒工具（reminder tools）被限定在 `标准 / 创造 / PTC` 三种模式可用，**极简模式（Minimal）和子代理（subagents）拿不到**。这是有意为之的能力面收窄，避免「模式」和「权限」互相污染。
- **兼容层定位为「验证器」而非「适配器」**：官方措辞是 verify（验证）subset（子集），而不是 provide compatibility（提供兼容）。这是判断该功能成熟度的关键——它先要证明命题，再谈实用。
- **插件可自举（Agent 造插件）**：插件管理页新增「让 Agent 创建插件」入口，进入 Creator 模式并保留草稿，**发送需求后才开始执行**。把「造插件」也纳入 Agent 的闭环，是插件体系自我繁殖的一步。
- **对外地址显式化**：新增 `--public-url`，把「展示给用户 / 浏览器打开 / 提供给模型」三个对外地址统一为一个可配置项，并支持带路径前缀的反向代理。多部署形态（本地、SSH、反代）下的地址歧义是 Harness 类工具的常见坑，这是正面修。

### 与前版/竞品的关键差异

| 维度 | Claude Code（Mods API） | DeepSeek Harness（本次更新） |
|------|------------------------|------------------------------|
| 扩展模型 | 核心 + Mods 插件 | 万物皆插件，核心亦由插件构成 |
| 兼容层意图 | —— | 用 Mods API 反向验证自家插件为超集（**非完整兼容**） |
| 插件创建 | 手写为主 | 新增「让 Agent 创建插件」入口（Creator 模式保留草稿） |
| 组合包机制 | —— | 可选「开发者工具组合包」；alpha.2 起 Claude Code / Codex 组合包按需安装 |
| 破坏性策略 | 渐进 | developer preview，明确「会有破坏性变更」，本次即移除 invariant 插件与 `./invariant` 导出 |
| 统计扩展点 | —— | 拆分为 `activity` 与 `usage` 两个独立入口（旧 `stats` 整行需改注册 ID） |

### 架构/信息流图

```
                    ┌────────────────────────────────────────┐
                    │            Web UI (dsh web)              │
                    │   模式: 标准 / 创造 / PTC  (极简除外)     │
                    └───────────────┬─────────────────────────┘
                                    │  --public-url (反代前缀)
                    ┌───────────────▼─────────────────────────┐
                    │        Cordis 插件内核 (everything        │
                    │        is a plugin) ─ 统一扩展点          │
                    └───┬───────┬───────┬───────┬──────────────┘
                        │       │       │       │
        ┌───────────────▼─┐ ┌───▼────┐ ┌▼─────┐ ┌▼─────────────┐
        │ Claude Code     │ │ Codex  │ │DevTools│ │ Git Worktree │
        │ Mods 兼容层     │ │ 组合包 │ │组合包  │ │ / i18n 等    │
        │ (实验/验证子集) │ │(按需)  │ │(可选)  │ │ (插件)       │
        └───────────────┬─┘ └────────┘ └───────┘ └──────────────┘
                        │ 子集映射 / 能力校验
        ┌───────────────▼─────────────────────────────────────────┐
        │  Agent 运行时 → 模型网关 (pi-ai 路由) → 工具调用流        │
        └──────────────────────────────────────────────────────────┘
```

## 破坏性变更清单（升级前必看）

本次 alpha 明确包含 Breaking change，集中列出以免踩坑：

| 变更 | 影响对象 | 需要做什么 |
|------|----------|------------|
| 移除运行时 `invariant` 插件及各包 `./invariant` 导出 | 依赖这些诊断入口的扩展、自定义 profile | 改用替代诊断路径，或自行保留私有实现 |
| 输入区统计扩展拆为 `activity` 与 `usage` 两个独立入口 | 覆盖旧 `stats` 整行的插件 | 更新注册 ID，拆分到两个入口 |
| 子路径插件不再读取独立 `package.json` | 子路径插件的作者 | 显示文本与图标改为通过对应子路径导出 |
| `Automation` 任务改判为 Web 内置能力 | 依赖旧实验组合包中 Automation 的配置 | 旧实验组合包选择会自动清理，已有任务保留 |

> 注：这一批变更多是「扩展点收口」，方向与兼容层一致——把能力往统一的插件/模式边界上收，而不是继续堆特例。

## 实用评估

### 什么场景值得用

- **架构研究**：想知道「一个 OS 级的 Agent Harness 如何把 Web/Desktop/自动化/兼容层全部收敛到插件原语」，dsh 是当下少见的公开样本（且附带 Cordis 论文）。
- **多扩展生态互通观察**：兼容层 + alpha.2 的「Claude Code / Codex 组合包按需安装」组合起来，是观察「第三方扩展 API 是否会事实收敛」的一手窗口。
- **高度定制化工作流**：`--public-url`、`Git Worktrees` 插件、DevTools 组合包（原始日志 + 会话正文双向定位 + 内嵌 Host 调试）对自建深度流水线的人有实际价值。

### 什么场景不值得用

- **生产稳定依赖**：官方自述为 developer preview 并明言会有破坏性变更；把生产绑在 alpha 通道上风险自负。
- **只为跑 Claude Code 插件**：兼容层是**验证性**的，官方原话「非为用户提供实际的完整兼容性」。抱此目的会失望。
- **受限资源 / 特殊平台**：本次仍有多条 Windows / macOS 平台修复（端口、PTY 清理、图标等），说明跨平台尚未完全收敛，非主流环境需自测。

### 迁移成本

- **从旧版 dsh 升级**：中低。主要是三项——删掉对 `invariant` 的依赖、把 `stats` 注册 ID 拆成 `activity`/`usage`、子路径插件改为子路径导出。改动集中在扩展/插件层，核心使用方式不变。
- **从 Claude Code 迁移**：高。没有官方迁移路径，兼容层不承诺完整兼容；应视为「在同一 Harness 上重建」，而非「换引擎」。

## 对你的意义

你的 AI 应用线主攻 **Agent + UI、visual workflow、RAG 工具链**，dsh 这次的信号比「又出了一个 Harness」更值得记一条：

1. **扩展模型的竞争点已经变了**。过去比「支持多少插件」，现在 dsh 直接在 release note 里做子集证明——这是把「扩展 API 的通用性」当成卖点。你在选型 Agent 框架时，「扩展点是否单一原语、是否有清晰的插件边界」应作为硬指标之一。
2. **「让 Agent 创建插件」值得单独盯**。它把插件开发本身纳入 Agent 闭环（保留草稿 → 发送需求才执行）。这与你关注的 **visual workflow / agent builder** 是同一赛道：未来低代码层的入口可能不是拖拽画布，而是「用自然语言让 Agent 现场造一个扩展」。建议列入观察清单。
3. **建议动作**：**观望 + 抽半天做架构拆解**。生产别碰 alpha；但把它的插件内核（Cordis）与兼容层设计读一遍，对你自己 Agent 架构的扩展点设计有直接参考价值。等它进入非 alpha 通道再评估试用。

## 关键代码/配置片段

安装与启动（来自仓库 README）：

```sh
# 从 npm 直接运行
npx @deepseek-ai/dsh web

# 从源码运行
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

新增的对外地址配置（来自 release notes）：

```sh
# Web 支持通过 --public-url 指定显示/打开/提供给模型的对外访问地址，
# 支持带路径前缀的反向代理入口
dsh web --public-url https://example.com/harness/
```

本次核心变更原文（来自 GitHub release notes，v0.2.1-alpha.1）：

```text
新增实验性 Claude Code Mods 兼容层。目前阶段的主要目的是验证 Claude Code Mods API
功能大致为 DeepSeek Harness 插件的一个子集，而非为用户提供实际的完整兼容性。
```

破坏性变更原文（来自 GitHub release notes）：

```text
破坏性变更：移除运行时 invariant 插件及各包的 ./invariant 导出；
依赖这些诊断入口的扩展和自定义 profile 需要调整。
```

---
[← Back to Deep Dives](./README.md)
