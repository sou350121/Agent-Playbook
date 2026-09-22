---
auto_generated: true
generated_at: "2026-09-22T05:45:56Z"
source_url: "https://github.com/akitaonrails/ai-memory/releases/tag/v2.4.0"
signal_type: "blog_post"
---
# ai-memory：给 coding agent CLI 装上跨厂商长期记忆 (ai-memory: Cross-Vendor Long-term Memory for Coding Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-22
>
> **项目/工具**: akitaonrails/ai-memory
> **链接**: https://github.com/akitaonrails/ai-memory/releases/tag/v2.4.0
> **核心定位**: 一个自包含 Rust 二进制 + 自托管服务，用 git 托管的 markdown wiki 作为唯一真源，把 20+ 种 coding agent CLI 的会话记忆统一起来，并支持跨厂商「交接」（handoff）。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：把 Claude Code / Codex / Cursor 等各家 CLI 各自的「本机、本 agent」记忆墙打通——退出一个 agent、在同一目录开另一个，新 agent 能接着你上次的断点继续，不用重新解释架构。
- **現在值得用嗎**：看场景。如果你**同时在用两种以上 coding agent**，或需要**跨机器/跨团队共享项目记忆**，值得试；只用单一 agent 且不跨设备，收益有限。
- **適合場景**：多 agent CLI 混用的工作流、homelab/局域网多机开发、小团队共享项目知识、想要「纯文件、可 grep、可手改」的记忆载体。
- **不適合場景**：追求零运维的托管式记忆 API、团队不想自己跑服务器、或者你只需要单机单 agent 的轻量「记住这个项目」。
- **與 Claude Code 内置记忆 / Mem0 核心差異**：内置记忆是「一台机器、一个 agent、一个 MEMORY.md」；ai-memory 是「一个你自托管的服务器 + git markdown wiki」，默认**零 LLM 调用**也能工作（capture/搜索/handoff 全部无需 API key）。

## 是什么 / 解决什么问题

每个 coding agent 其实都已经有「记忆」功能：Claude Code 会自己记笔记，Cursor 会记住一些东西，各家平台都在往这个方向加功能。但它们有一个共同的墙——**笔记只存在于一台机器上，只属于一个 agent，一旦你切换工具或换队友就消失了**。

`akitaonrails/ai-memory` 要做的就是**墙的另一侧**。它是 `agentmemory` 的 Rust 继任者，一个自包含二进制，同时跑 MCP/HTTP server 并拥有一个数据目录。核心主张是五条「跟随」：

1. **跟随你跨越 agent**：20+ 种 harness（Claude Code、Codex、Cursor、Gemini CLI、OpenCode、Grok、Devin、Kimi、Kiro……）汇入同一份共享记忆。中途退出 Claude Code、在同一目录打开 Codex，下一个 agent 拿到的是一份**真实交接**：你停在哪、什么失败了、什么还没解决。
2. **跟随你跨越机器**：记忆活在你自托管的服务器里（同一台笔记本、homelab、或者任何地方），桌面上放下的项目可以在笔记本上接着做。
3. **为团队工作**：所有人指向同一台服务器，一个人的会话学到的东西，所有人的 agent 都能检索。知识按项目共享，个人 handoff 保持私有。多用户鉴权、逐人归因、审计日志**内置，不是付费档**。
4. **记忆是纯 markdown**：真源是一个 git 托管的普通 `.md` wiki——可以 grep、可以 Obsidian 打开、可以手改、可以 rsync。数据库只是可重建的派生索引，**不需要伺候向量库**，没有东西被扣在二进制 blob 里。
5. **静默捕获工作本身**：lifecycle hooks 记录实际发生的事（prompt、tool call、会话边界），在**有类型的隐私边界**上做脱敏后才落库，再整合成可读页面——不需要「记住这个」的仪式；而且**默认路径零 LLM 调用**。

一句话：它把「agent 记忆」从*产品功能*重新定义为*基础设施*——一个你能拥有、能审计、能 grep 的文件仓库。

## 技术架构拆解

### 核心设计决策

- **File-first（文件优先）**：git 托管 markdown wiki 是唯一真源，SQLite 只是「可由文件重建」的派生索引。这意味着记忆是可移植、可 diff、可手工编辑的，而不是某个向量库里的不透明行。
- **零 LLM 默认（zero-LLM default）**：capture、搜索、handoff 默认全部不需要 API key。FTS5 全文检索在没有任何 key 时仍可用；LLM 只在**可选的**会话摘要整合与语义搜索里才被调用。
- **Hook-based 自动捕获**：不靠用户手动「记一下」，而是通过 lifecycle hooks 在会话结束时把观察（observations）编译成连贯的 markdown 页面。
- **Handoff 是协议，不是约定**：跨 agent 交接是**有类型、有属主、恰好被认领一次（claimed exactly once）**的协议——避免多个 agent 抢同一份上下文。
- **一条 SQLite writer 串行化写入**：server 把所有写入串行化到单个 SQLite writer，编译会话观察为 markdown 页面。
- **诚实的工程数字**：README 明确写了「measured write ceiling (~700/s)」而不是拍脑袋；purge 命令会说清「删除」到底删了什么；每次变更都有审计日志。

### 与前版/竞品的关键差异

README 自带了一张非常坦率的对比表，核心差异如下：

| 维度 | 同类/前版 | ai-memory |
|------|----------|-----------|
| Mem0 / LangMem（事实抽取器） | 逐轮抽取原子事实，存不透明 fact rows | 记忆编译成你可拥有、可编辑的**可读页面**；检索融合 FTS + entity + graph（+ 可选向量），不是纯向量 |
| Zep / Graphiti（时序知识图谱） | 需要起一个图数据库 | 在**一个二进制**上做 bi-temporal-lite（`as_of`、版本过滤检索）与有类型的边，无需独立图库 |
| mcp-memory-service（最近的兄弟） | SQLite + 本地向量、hook 捕获、typed edges | 换成**人类可编辑的 markdown 页面**，并把跨 agent handoff 抬升为一等公民的 claim-once 协议 |
| basic-memory（file-first 兄弟） | markdown-on-disk 做真源 | 在其上加**自动 lifecycle 捕获** + 派生的 FTS/entity/graph 索引 + 跨 agent handoff + 多用户共享 |
| Claude Code 内置记忆 | 零配置的「记住我的项目」 | 跨机器/跨 agent 同步、可搜索、支持团队、能捕获 tool 生命周期——不是一台笔记本一个 MEMORY.md |
| Supermemory / LiquidLM（托管 API） | 托管「第二大脑」，自动 ingestion | **你拥有的 git 版本化 markdown**、无必需 API 花费、可离线、按项目共享 |

一致的取舍主线：**你拥有的文件（git markdown）+ 零 LLM 默认 + 单一自包含二进制 + 跨 agent/跨机器/团队共享 + 自动 lifecycle 捕获 + 有类型 claim-once handoff**。可选功能（LLM 整合、向量搜索）始终保持 opt-in。

### 架构/信息流图

```text
  capture            consolidate          recall             handoff
 ──────────►  ───────────────────►  ────────────►  ──────────────────►
  hooks          session-end           search            next agent
  (静默观察)      观察 → wiki 页面      FTS+entity+graph    注入「bounded brief」
                 (可选 LLM 写)        (+可选向量, RRF)     任意 harness 可读

数据目录 (一个 binary owns 一个 data dir):
<data_dir>/
├── wiki/     # markdown 唯一真源，git-versioned
├── raw/      # 不可变的、已脱敏的 managed-workstream transcript 片段
├── db/       # SQLite 索引 (FTS5 / entities / embeddings)
├── models/   # 预留：本地 embedding 模型
└── logs/     # 滚动 tracing 输出
```

检索层由 **FTS5 + entity-match + graph-neighbor 的 RRF 融合**（可选加向量 RRF）、有界的 source-authority 调整、以及对非全局搜索的有界 raw-observation 回退组成。

### 支持矩阵（第一方集成，CI 守真）

Linux / macOS / Windows via WSL2 均 Supported（原生 Windows 为 Experimental）。Agent 侧第一方集成包括：Claude Code、Codex、Command Code、Devin CLI、OpenCode、OpenCode 2 (beta)、Cursor、Gemini CLI、Oh My Pi / OMP、Pi、OpenClaw、Antigravity CLI、Grok Build CLI、Zero、ZCode、Kimi Code、Kiro CLI；另有 MCP-only（Claude Desktop、VS Code Copilot、Zed、Muse Code）、Managed-only（Crush）、Hooks-only（Pool）、Community（Hermes Agent）等分级。

## 实用评估

### 什么场景值得用

- **多 agent CLI 混用的开发者**：这是产品设计的第一性目标。你退出 Claude Code、开 Codex，下一个 agent 拿到「停在哪 / 什么失败 / 什么待办」的真实交接。有 CI 守真的 20+ harness 支持矩阵说明这不是 PPT 承诺。
- **homelab / 多机开发**：记忆活在你自托管的服务器上，同一项目在台式机与笔记本之间无缝续接。这正是 Vercel/云托管记忆 API 做不到的（数据在你自己机器上）。
- **小团队**：一台服务器 + 多用户鉴权 + 逐人归因 + 审计日志，让「一个人的会话所学」变成「所有人的 agent 可检索」。且这些是内置而非付费档。
- **想要 file-first 记忆的人**：git markdown wiki 可 grep / Obsidian / 手动编辑 / rsync，SQLite 只是可重建索引。对「不信任黑盒记忆」的人很友好。

### 什么场景不值得用

- **不想自托管服务器的人**：核心卖点之一是「跑你自己的服务器」。如果你想要零运维的托管记忆 API（Supermemory 类），这个项目的形态是反方向。
- **只需单机单 agent**：如果你只用 Claude Code 一台机器，内置记忆「零配置」就够了，ai-memory 的服务器 + hooks 装配成本显得过重。
- **追求纯向量语义检索的场景**：向量搜索是 **opt-in**，且需要额外的 embedding provider；默认路径是 FTS5 全文，语义召回能力弱于纯向量方案。
- **资源极度受限的环境**：它是一个常驻 server 进程 + SQLite 写入串行化。在 2GB RAM 级别的机器上与其他服务共存需要实测（README 未给出内存基线，见下方 TODO）。
- **原生 Windows 用户**：原生 Windows 仍是 Experimental，推荐走 WSL2 或 Docker Desktop。

### 迁移成本

- **安装**：Linux 用 AUR（`yay -S ai-memory-bin`）或 Docker（`docker.io/akitaonrails/ai-memory:latest`，含 amd64/arm64）；macOS 有原生 release 二进制。默认 quick-start **无鉴权、仅绑定 loopback**（`127.0.0.1:49374`），单机笔记本足够安全。
- **接线**：每个 agent 两条命令（`install-mcp --client X --apply` + `install-hooks --agent X --apply`）。更省事的方式是 `ai-memory run claude`——首次运行会自动装好该 harness 的 hooks + MCP，幂等且每 harness 只需一次。
- **从既有项目接入**：`ai-memory bootstrap` 用于采纳一个已有数月历史的项目。若从 2.0 之前升级，有 `docs/MIGRATION-2.0.md` 描述**备份门控的自动迁移**与回滚。
- **卸载**：`ai-memory uninstall --apply` 只移除它自己装过的东西；install 命令幂等，且写时间戳备份。

## 对你的意义

对 Ken 而言，有两层相关性：

1. **AI 应用开发线（直接相关）**：Ken 的 Agent-Playbook 本身就在沉淀「Agent 架构 / 设计模式」知识。ai-memory 展示了一个值得记录的工程范式——**把 agent 记忆当成 file-first 基础设施而非产品功能**，并用 claim-once handoff 协议解决多 agent 上下文竞争。这与 Playbook 里 `theory/03-engineering` 的分类高度契合，本篇文章正是归档于此。
2. **VLA 线的间接启发**：跨 agent handoff 的「有类型、恰好认领一次」协议，和具身智能里多机器人/多策略**任务交接与状态传递**在抽象上同源——都是从「隐式约定」升级为「显式协议」。值得在跨领域交叉点上留意。

**具体建议：观望为主，局部试用。** 不必立刻把整套服务器搬进现有 infra（2GB RAM 环境下常驻 server 需先压测）；但可以：
- 在**单机**上先跑一个 Docker 容器 + 一个 agent（如 Claude Code），体验 `ai-memory run` 的零配置接管与 handoff 质量；
- 评估它的**支持矩阵覆盖面**（是否覆盖你在用的 harness）；
- 把「file-first + claim-once handoff」写进 Playbook 的设计模式条目，作为「agent 记忆架构」的参考实现。

## 关键代码/配置片段

Docker 起服务（默认 zero-LLM 模式可省略 LLM/EMBEDDING 两行，FTS5 检索仍可用）：

```bash
docker run -d --name ai-memory \
  --restart unless-stopped \
  -p 127.0.0.1:49374:49374 \
  -v ai-memory-data:/data \
  -e AI_MEMORY_LLM_PROVIDER=anthropic \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -e AI_MEMORY_EMBEDDING_PROVIDER=openai \
  -e OPENAI_API_KEY=sk-... \
  docker.io/akitaonrails/ai-memory:latest
```

接线一个 agent（两条命令）+ 首选启动方式：

```bash
ai-memory install-mcp --client claude-code --apply
ai-memory install-hooks --agent claude-code --apply

# 首选：首次运行自动装好该 harness 的 hooks + MCP（幂等，每 harness 一次）
ai-memory run claude
ai-memory run codex --yolo   # 之后：同一 workstream，不同 harness
ai-memory continue           # 恢复最新的 managed checkout
```

数据目录布局（一个 binary 拥有一个 data dir）：

```text
<data_dir>/
├── wiki/     # markdown 唯一真源，git-versioned
├── raw/      # 不可变、已脱敏的 managed-workstream transcript 片段
├── db/       # SQLite 索引 (FTS5 / entities / embeddings)
├── models/   # 预留：本地 embedding 模型
└── logs/     # 滚动 tracing 输出
```

> TODO: 官方 README 未给出常驻 server 的**内存/CPU 基线**（本机 2GB RAM 环境下与其它服务共存的可行性需实测）。同项目的 `docs/benchmarks/` 只覆盖**检索质量**数字，不含运行时资源占用。
> TODO: v2.4.0 tag 页面仅列出校验和与安装方式，未附 changelog 正文；下述近期变更取自仓库 CHANGELOG（含 v2.4.0 之后的 Unreleased 段），**版本归属待确认**。

近期 CHANGELOG 要点（来源：仓库 CHANGELOG.md）：

- **安全**：`rmcp` 升到 2.x（2.2.0），修复三个 MCP transport 公告（GHSA-9pj6-vhgr-3mwh 未鉴权的 Streamable-HTTP session-table 泄漏/DoS、GHSA-33f5-2c5q-wgwj OAuth resource 字段校验缺失、GHSA-9g45-5xwm-f3wc 自定义 header 跨源重定向泄漏）；仅改名 `rmcp::model::Content` → `ContentBlock`，23-tool MCP 面不受影响。
- **修复**：定时 `auto_improve` review 失败不再永久移除队列（claim 记录失败并释放，3 次后 park 并保留最后错误）；Windows Docker wrapper 补全 provider 凭据/环境变量转发；隐私 strip 现在也脱敏 Windows 凭据路径（`.ssh`/`.aws`/`.kube`/`.gnupg` 等）与 JSON 内嵌密钥。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | ai-memory 的核心价值建立在「coding agent 能独立推进多步任务」之上——正因为 agent 会长时间自主工作、跨会话积累上下文，跨 agent/跨机器的记忆交接才有意义；它把「agent 产出是否可信、可续」这一前提工程化。 |

---
[← Back to Deep Dives](./README.md)
