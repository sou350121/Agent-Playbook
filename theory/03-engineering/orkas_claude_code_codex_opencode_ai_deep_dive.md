---
auto_generated: true
generated_at: "2026-11-07T09:00:54Z"
source_url: "https://github.com/Orkas-AI/Orkas/releases/tag/v2026.11.4"
signal_type: "significant_update"
---
# Orkas：把已装的 Claude Code / Codex / OpenCode 收编成一支本地 AI 团队 (Orkas: A Local-First Multi-Agent Desktop That Orchestrates Your Existing CLI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-07
>
> **项目/工具**: Orkas (Orkas-AI/Orkas)
> **链接**: https://github.com/Orkas-AI/Orkas/releases/tag/v2026.11.4
> **核心定位**: 一个 MIT 开源、local-first 的桌面多 Agent 应用——由一个 Commander 把目标拆成 to-do，派给 16 个内置专才 Agent，并把已经装在机器上的 Claude Code / Codex / OpenCode / OpenClaw / Hermes-Agent 当作"员工"纳入同一份计划一起跑。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：不是又一个 coding agent，而是 coding agent 的"调度层 + 项目管理器"——把 CLI agent 当执行体，自己在上面做计划、分工、记忆和排程。
- **現在值得用嗎**：看场景。如果你日常已经在用 2 个以上 CLI coding agent、并且有大量"跨会议/跨天"的持续型任务，值得试；如果只写单次代码补丁，收益接近零。
- **適合場景**：多 Agent 混合编排、持续型项目（项目记忆 + to-do + Auto-advance）、定时自动化、跨媒体产出（研报/PPT/视频/Office 文件）。
- **不適合場景**：需要确定性可复现的 CI/生产流水线；拒绝桌面 GUI 只接受终端与脚本；需要开源构建即具备团队协作/云同步（该能力仅在打包版付费计划）。
- **與前版核心差異**：v2026.11.4 加入了 GPT-6.1 Terra 支持、多星期几/多日期重复排程、以及一批"中断恢复"类修复（队列消息、附件、被中断会话的恢复不再被误判为新草稿）。

## 是什么 / 解决什么问题

过去一年 AI 工程圈的一个隐性痛点：**CLI coding agent 越装越多，但它们彼此不知道对方存在**。你用 Claude Code 写实现、用 Codex 做 review、用 OpenCode 跑另一个仓库的实验——每条会话都是孤岛，上下文、计划、进度全靠人脑粘合。任务一旦跨越几小时或几天，"上次做到哪了"就成了最大的成本项。

Orkas 的解法是把这层粘合产品化。它把"目标 → 计划 → 分工 → 执行 → 回收结果"作为一等公民：一个 Commander 负责拆解与分派，16 个内置专才 Agent（DeepResearcher、PptMaker、ProductDeveloper、OfficeWorker、五个电商 Agent 等）负责领域执行，而你已经安装的 Claude Code / Codex / OpenCode / OpenClaw / Hermes-Agent 以"本地会话"的形式挂进同一个计划里。官方 README 的原话是：Commander 把每部分交给最擅长的那个，"and keeps one plan across all of them, so a single chat can fix the bug, review the change and draft the release note"——一次对话里完成修 bug、review 改动、写 release note 三件事。

更值得注意的是它的产品重心不在"能力"而在"持续性"。项目（Project）承载目标、规则、记忆与文件，每条新会话从上次继续；to-do 列表可以在人与 Agent 之间分配；Auto-advance 让团队自己在空闲时捡起下一项；排程支持每小时/每天/每周/每月。这三件套组合起来，实际上是把"待办驱动 + 记忆承载 + 定时触发"做成了 Agent 的运行时外壳。

## 技术架构拆解

### 核心设计决策

- **Commander 作为唯一入口，而非"多 Agent 平权"**：用户只说目标，由 Commander 决定自己干、还是派给哪个专才。这样避免了"用户要自己当调度器"的常见失败模式，代价是 Commander 的规划质量成为系统上限。
- **CLI agent 作为子进程会话存在，保留各自模型设置**：README 明确"External CLI agents keep their own model settings"，而 Commander 与内置 Agent 共享一个模型设置。这是一个务实取舍——不去统一各家 CLI 的鉴权与模型配置，只统一调度。
- **Local-first 作为默认，而非选项**：对话、文件、知识库、自定义 Agent 默认留在本地磁盘；用自己的 key 时模型调用直接从本机发往 provider。只有内置 Orkas model 走 Orkas 的托管模型服务。
- **Agent 是可成长对象**：每个 Agent 保有私有 skills 与 memory，空闲时后台 review 会"refine self-assessment, reusable methods and learned skills"。这是把 post-training 的思路搬到了产品层（自我评估 + 方法沉淀），但效果目前无法从文档验证。
- **断点补跑作为显式承诺**：v1.9 起，每次自动化在电脑唤醒或 Orkas 启动时，会在 12 小时内补上最近一次错过的运行。这是 local-first 排程器的必要设计——桌面应用不可能永远在线。

### 与前版/竞品的关键差异

| 维度 | 典型做法（单 CLI agent / 云编排平台） | Orkas |
|------|------------|------------|
| 调度主体 | 人（手动开多个终端）或云平台 DAG | 本地 Commander，人只说目标 |
| 执行体 | 单一 agent | 16 个内置专才 + 5 种外部 CLI agent 混编 |
| 上下文连续性 | 单会话内有效，跨会话丢失 | Project 承载 goal/rules/memory/files，跨会话延续 |
| 数据位置 | 多为云端 | 默认本地磁盘；云同步为打包版可选项 |
| 模型绑定 | 绑定单一 provider | 内置模型 / 自有 key（Claude、OpenAI、Gemini、DeepSeek、Kimi、GLM、Qwen、MiniMax、Doubao）/ 本地 OpenAI 兼容端点 |
| 许可 | 多为闭源 SaaS | MIT 开源，打包版另含协作与发布能力 |
| 中断恢复 | 视实现而定，常需重跑 | v2026.11.4 显式修复队列消息、附件、被中断会话的恢复 |

### 架构/信息流图

```
                 用户目标 (goal)
                       │
                       ▼
              ┌─────────────────┐
              │   Commander     │  拆解 → to-do → 分派 → 汇总
              │  (planner)      │  共享模型设置
              └────────┬────────┘
                       │
      ┌────────────────┼──────────────────┬──────────────────┐
      ▼                ▼                  ▼                  ▼
 ┌─────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
 │ 16 内置 │   │ Claude Code  │   │    Codex     │   │ OpenCode /   │
 │ 专才    │   │ (CLI 会话)   │   │ (CLI 会话)   │   │ OpenClaw /   │
 │ Agent   │   │ 自有模型设置 │   │ 自有模型设置 │   │ Hermes-Agent │
 └────┬────┘   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
      │               │                  │                  │
      └───────────────┴────────┬─────────┴──────────────────┘
                               ▼
                    ┌────────────────────┐
                    │  Project 层        │  goal / rules /
                    │  (持久上下文)      │  memory / files
                    └─────────┬──────────┘
                              │
              ┌───────────────┼────────────────┐
              ▼               ▼                ▼
        ┌──────────┐   ┌───────────┐   ┌──────────────┐
        │ To-do /  │   │ 排程自动化 │   │ Connectors   │
        │ Auto-    │   │ hourly →  │   │ Gmail/Calendar│
        │ advance  │   │ monthly   │   │ Notion/Slack/ │
        └──────────┘   │ 12h 补跑  │   │ Shopify/Stripe│
                       └───────────┘   └──────────────┘
                              │
                              ▼
                    完成结果 → 回到人工 review
```

## 实用评估

### 什么场景值得用

- **"一个目标，跨多种产出"**：README 给的例子很具体——市场调研最终变成报告、幻灯片和发布视频。这类任务天然需要多个专才接力，人肉串联的成本最高，Orkas 的结构收益最大。
- **已有 CLI agent 投资不想浪费**：如果你团队已经按 Claude Code 写实现、Codex 做 review 形成习惯，Orkas 不是替代品而是把它们编进同一份 plan，迁移的实质成本较低（不改各家配置）。
- **需要"每周自动跑一次"的例行产出**：周报、竞品检查、销售简报这类任务，配合排程与 Auto-advance 是产品设计最对口的用法。
- **数据敏感但不想上云**：默认本地存储 + 自带 key 直连 provider，适合内部资料不进第三方的场景。

### 什么场景不值得用

- **单次、明确的小任务**：修一个 bug、写一个函数，直接开 Claude Code 更快。加一层 Commander 只是多一次 LLM 调用和一次等待。
- **需要确定性可复现的流水线**：Commander 的规划是 LLM 行为，同一目标两次拆解可能不同。放进 CI 或生产触发链里是反模式。
- **开源构建即可用的团队协作**：README 明确 shared projects、cloud sync、web-app publishing **仅打包版支持**，开源构建不支持。选开源版就要接受这个功能缺口。
- **成本不可预测的批量场景**：Commander + 多个专才 + 后台 review 的调用层数远高于单 agent，token 消耗结构更复杂。文档未给出量化的 token/成本模型，属待验证项。
- **成熟的 benchmark 结论依赖者**：目前**没有任何公开 benchmark 数据**说明 Orkas 的多 agent 编排在任务成功率上优于单 agent。所有"更强"的说法都缺一手数据支撑。

### 迁移成本

- **从"手动多终端"迁入**：主要是配置模型 key 与 CLI 路径，README 声称支持从源码安装（macOS/Windows/glibc 2.34+ Linux x64/arm64），工作量约半天。
- **从自建编排（LangGraph / 自写 DAG）迁入**：需要把工作流语义重新表达为 project + to-do + agent 分工，这是一次真正的重写；且 Orkas 是桌面 GUI 优先，难以嵌入既有服务端流水线。评估成本高。
- **从单一 IDE 内置 agent 迁入**：低。可以保留原 agent 作为外部 CLI 会话。

## 对你的意义

对你的双线场景，Orkas 的参考价值大于使用价值，但有两处值得实际动手：

第一，**它是"多 Agent 编排 UI 化"的一个公开样本**。你追踪 Agent + UI 方向，Orkas 把 Commander / to-do / Auto-advance / 项目记忆这套抽象直接做成了可交互界面，且是 MIT 开源——这比读一篇架构博客有用得多。建议直接读它的 `resources/builtin/marketplace/agents/` 下的 skills 组织方式，看它如何给每个专才打包 skills 与 memory。

第二，**它在解决的正是你 Pulsar 系统手写的那层东西**：项目记忆、to-do 驱动、排程、断点补跑、失败恢复。你的 watchdog + DAG 自愈本质是同一问题的服务端实现。Orkas 的"12 小时内补跑最近一次错过的运行"这类边界处理，可以直接借鉴到自己的 cron 设计里。

**建议：观望 + 源码精读，暂不迁移。** 理由很简单——没有 benchmark、没有真实项目验证、Commander 规划质量未知。但它的架构决策清单本身就是一份好的设计参考。

⚠️ 链接注意：README 中提到的 "OpenClaw" 与 Orkas 的项目归属、以及文中出现的 "GPT-6.1 Terra" 模型名，均为源材料原文，本任务未作独立核实，使用前请自行确认。

## 关键代码/配置片段

排程补跑语义（源材料 README 原文，v1.9 起的承诺）：

```
Scheduled automations — run any task hourly, daily, weekly or monthly.
Orkas runs on your computer.
From v1.9, each automation catches up its most recent missed run
within 12 hours when the computer wakes or Orkas starts.
```

外部 CLI agent 与内置 Agent 的模型设置分离（README 原文）：

```
- Any model, switch any time — the Commander and built-in agents share
  one model setting: the built-in Orkas model, your own provider, or a
  local endpoint.
  External CLI agents keep their own model settings.
```

v2026.11.4 的变更要点（GitHub release notes 原文）：

```
### Highlights
- Use GPT-6.1 Terra in supported provider and model settings.
- Choose multiple weekdays or month dates for recurring automations
  and review clearer schedule summaries.
- Capture product pages and recover video compositions with clearer
  preview and delivery checks.

### Fixes
- Recover queued messages, selected attachments and interrupted
  conversations without treating downloaded files as new drafts.
- Keep search results complete through cache rebuilds, file changes,
  deletion and restoration.
- Preserve both recoverable copies when Library moves encounter
  concurrent edits or partial deletion.
- Keep desktop background work, shutdown and provider failures
  consistent with the task's actual completion state.
```

> TODO: 未能核实 GPT-6.1 Terra 的来源与可用范围（release notes 仅称 "in supported provider and model settings"）。
> TODO: 未有公开 benchmark 数据说明多 Agent 编排带来的任务成功率提升幅度。
> TODO: 未有 token/成本量化的对比数据。

---
[← Back to Deep Dives](./README.md)
