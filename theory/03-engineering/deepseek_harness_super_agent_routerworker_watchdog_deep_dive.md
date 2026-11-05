---
auto_generated: true
generated_at: "2026-11-05T06:45:57Z"
source_url: "https://github.com/deepseek-ai/dsh-superagent-prototype/releases"
signal_type: "significant_update"
---
# DeepSeek Harness 的 Super-agent 原型：把调度、配额与看门狗搬进 Agent 架构 (dsh-superagent-prototype: An Opinionated, Attention-Budgeted Coding Agent)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-05
>
> **项目/工具**: deepseek-ai/dsh-superagent-prototype
> **链接**: https://github.com/deepseek-ai/dsh-superagent-prototype
> **核心定位**: 一个面向单一 GitHub 仓库的「常驻型」主动编码 Agent——它监听 GitHub（可选飞书），收到请求后开 Ticket、开独立 session + 独立目录干活，最后回到原对话交 PR；整套设计以「最小消耗人类注意力」为第一性原理。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：不是又一个「能写代码的 Agent」，而是一套**把多人协作、注意力配额、并发槽位、后台任务超时、身份委派**都当成一级概念写进领域模型的编码 Agent 参考实现。
- **现在值得用吗**：看場景。想直接拿来跑生产——不值得（官方明说 research code）；想学「怎么把 Agent 做成团队基础设施」——**很值得读，尤其是 docs/ 那 8 份按序阅读的设计文档**。
- **适合场景**：单仓库、有代码评审文化的小团队；想做「Agent 常驻在 Issue/PR 流程里」而不是「在 IDE 里点一次」的团队；研究 Agent 并发与后台作业治理的人。
- **不适合场景**：多仓库/单仓多产品的大型工程组织（当前只服务一个 repository）；需要强隔离的多人共享环境（见下文「安全性」）；纯对话式 Agent 需求。
- **与一般 Coding Agent 核心差异**：Claude Code / Cursor 类工具把「一次会话」当作单位；dsh-superagent 把**Ticket（工单）**当作单位——会话可被替换、被重启、被后台作业唤醒，而工单的生命周期由 PR 是否关闭来判定，不由 Agent 说「我做完了」来判定。

---

## 是什么 / 解决什么问题

绝大多数 coding agent 的问题是同一个：**它把成本内化了，把注意力外化了**。Agent 越能干，越容易把团队淹没在消息、PR、评论和「请你确认一下」里。DeepSeek 团队在这份原型里给出的答案不是「更聪明的提示词」，而是**把注意力当成预算来管理**。

README 里那句原则很硬：

> Take as little human attention as possible, and give as much value as possible.
> Every part of the project is judged by the attention it costs. A message, a notification, a question, a setting, a panel element and a paragraph of documentation each cost someone's attention, and each has to give more value than that, or it is removed.

由此派生出的行为约束是三条硬规则（docs/000-philosophy.md）：

1. **只在被请求、或被团队写下的规则允许时行动。** 无主动请求的工作必须先跑在「只记录不执行」模式。
2. **只在人必须行动、或结果可被使用时说话。** 请求确认一次、写下要做什么，然后工作期间保持沉默。
3. **一次只问一个具体问题**，用结构化形式发出，而不是埋在一份长报告里。

工程上，它把这个原则变成了可执行的领域模型：Trigger → Thread → Eval → Decision → Ticket → Assignment → Report。一条 GitHub Issue、一条 PR review、一条飞书消息，都是 Trigger；它们落在 Thread 上；Thread 上挂着 Eval（一次判定）；判定产出 Decision（accept / stop / ignore / unavailable）；accept 之后变成 Ticket，Ticket 领到 Assignment，Assignment 交给 Executor Session 干活，Executor 回报 Report（progress / waiting / ready / blocked / failed / dropped）。**人的每一次介入、Agent 的每一次沉默，在这个模型里都有明确的状态位。**

## 技术架构拆解

### 核心设计决策

- **Engine 是唯一写入者，且全部同步。** `src/core/engine.ts` 是 Trigger / Thread / Decision / Ticket / Assignment 的唯一写入者；每个命令在**一个事务内**改完聚合。外部副作用（发消息、调 Executor）通过 `Effects` 端口在**提交后**执行。这是典型的「领域事件 + outbox」写法搬进 Agent 系统——消息发送和状态变更不会出现半个成功。
- **按角色切分接口，而不是给全权。** 调用方只能拿到 Engine 的一个 `Pick`：`EngineForSources` / `EngineForMainSession` / `EngineForPeople` / `EngineForSettings` / `EngineForExecutor`。Source 插件只能 `receive(trigger)` 和 `bindThread(...)`，碰不到 Ticket 生命周期。
- **两层 Session，权限不同。** 主会话跑 `dsh-superagent-router` 预设（工具更少，只做路由/判定）；每个 Ticket 一个 `worker-<ticket id>` Executor Session，跑 `dsh-superagent-worker` 预设。Worker 子 Agent 用 Harness 的 `standard` 预设，只保留 worker 允许的工作工具，Ticket 结束时这些工具被收回。
- **前台不阻塞：5 秒转后台。** 前台 shell 命令超过 5 秒自动转后台作业，这样 worker 能在**下一步**就收到新消息，而不是干等一个长命令。`standard` 预设下是 60 秒。
- **后台作业有 30 分钟硬上限。** 一轮 turn 结束时如果还有后台作业在跑，Ticket **继续占用 worker 槽位**、状态保持 working，不会被误报成 waiting。30 分钟到，shell job 被杀、Ticket 报 waiting，报告里带上 Executor 最后说了什么、杀了哪些作业。
- **人的消息有专属槽位。** 并发上限之外额外保留一个槽位给「人的消息 / 状态查询」。新工作不能挤占人继续一个已有 Ticket 的能力。
- **结束判定看 PR，不看 Agent 的自述。** Ticket 跟随它开启的 PR；只有当它开的 PR 都关了（或它没开 PR 而跟随的 PR 全关），且没有在关闭后恢复、尚未 `ready` 的工作，Ticket 才结束。Executor 说 ready 不算完。
- **状态机是「第一个匹配行胜出」的表。** Ticket stage 按固定顺序匹配：delivery 失败 → 等回答 → 等评审 → blocked/failed → queued → idle → working。读表从上到下，行为完全确定。

### 与前版/竞品的关键差异

| 维度 | 典型 Coding Agent（IDE 内） | dsh-superagent |
|------|------------|------------|
| 工作单位 | 一次会话 / 一次任务 | Ticket（生命周期由 PR 关闭判定） |
| 触发来源 | 人打字 | GitHub Issue/PR/review + 飞书；Trigger 去重（`stored`/`duplicate`/`filtered`） |
| 并发控制 | 无显式概念 | 槽位制，人的消息有保留槽 |
| 后台任务 | 无治理 | 5s/60s 转后台，30 分钟上限，报告里注明被杀作业 |
| 权限 | 单一账号全权 | 主会话 router 预设 / worker 预设 / subagent standard 预设，工具集递减 |
| 授权 | 通常「你点了同意」 | 允许名单 + 「团队开放请求的对话」+ 规则驱动（未请求工作先只记录） |
| 合并 | 人手动 | 默认**永不**以 Agent 账号开 auto-merge；仅当 PR 为 Ticket 所开、required approvals 覆盖 head commit、增删合计 < 200 行 |

最后一条值得单独说：默认情况下 Executor **不会**以 agent 账号开启 auto-merge，理由是「GitHub 把合并归因于开启 auto-merge 的人」。想自动合并，必须在 Delivery requirements 里显式指定另一个账号的 CLI。这是一个很少见的、把「归因责任」当成设计约束的细节。

### 架构/信息流图

```text
Source plugins (GitHub / Feishu)
        │  SourceContext
        ▼
   ┌─────────┐   Repositories   ┌───────┐
   │ Engine  │◄────────────────►│ Store │
   └────┬────┘                  └───────┘
        │ Policy / SourceScope
   ┌────┴────┬─────────┬─────────┐
   ▼         ▼         ▼         ▼
Policy  MasterAssessor DshExecutor Outbox
             │  decide   │ assignmentStarted
             │           │ inputsDelivered / report
             └─────► Engine ◄──────┘
                       │ enqueue Effects
                       ▼
                  Effects → Store → SourceRegistry.send

Engine 内部（单向依赖）：
Intake → Tickets → Evals → Assignments → Replies
```

Engine 的内部拆分同样是单向依赖（`Intake` 依赖 `Tickets`；`Evals`、`Tickets`、`Assignments`、`Replies` 依序），跨部分的命令（`attach`、`evaluateDue`、`policyChanged`）按序调用。命名上也有纪律：命令用祈使句（`stopTicket`），适配器回报的事实用过式（`assignmentStarted`），查询用名词（`candidate`）。

## 实用评估

### 什么场景值得用

- **单仓库 + 有 PR 文化的团队。** 整个模型围绕「请求 → 工单 → PR → 关闭」闭环，PR 就是验收信号，不需要额外发明完成判定。
- **想把 Agent 常驻进流程。** 它有 `Passes`：每两秒一拍，跑 due 的 effects 再跑 `Engine.evaluateDue`；且「一次只跑一拍」，不会并发重复判定。这是心跳式系统的正确写法。
- **想研究/复用架构模式。** outbox、角色化接口、槽位并发、后台作业超时、状态表匹配——每一条都独立可移植，甚至可以不看代码只看 `docs/007-architecture.md`。

### 什么场景不值得用

- **生产环境直接部署。** README 第一段就写了：research prototype for reference only，not an official DeepSeek product，may still contain bugs，code style and engineering practices may be inconsistent。
- **多仓库组织。** 它是一个「proactive coding agent for **one** GitHub repository」。
- **把它当沙箱。** 文档写得很直白：Executor Session **以 operator 的 OS 用户身份、无审批地**运行命令；`DSH_SUPERAGENT_BLOCKED_COMMANDS` 和目录约定「establish defaults, not a security boundary. A worker can still execute a program by absolute path.」绝对路径就能绕开限制。
- **需要强审计的企业。** 自动合并的默认策略是「人合并」，这恰恰说明作者自己也不信任全自动合并。

### 迁移成本

不存在「从 X 迁移到 Y」的问题——它不是替代品，是要**新增一层基础设施**。真正的工作量在于：

- 安装是「让 coding agent 和你一起做」的交互式流程（读 `SETUP.md`，一次问一个短问题，展示完整计划后安装配置）。听起来轻，实际要准备好的东西不少：GitHub agent 账号、`gh` CLI、仓库 worktree 权限、可选的飞书 bot 与 `lark-cli`、执行根目录、并发上限、Delivery requirements 提示词。
- Ticket 目录准备用 `sh` 在 execution root 下跑一次 `prepare` 命令，10 分钟超时，典型做法是 `git worktree` 建 checkout。PR 归属靠「分支路径最后一段匹配 Ticket short name」——这条约定意味着团队的分支命名要统一。

## 对你的意义

对 Ken 的两条线，这份原型的价值不在「用」，而在「抄」。

如果你是 VLA 研究者，这套东西最直接可借的是**「Agent 说完成 ≠ 完成」的判定原则**。你们若在做 RL 训练 VLA 或后训练流程的自动化，很容易掉进「模型报告任务成功」的陷阱。dsh-superagent 的做法是把验收锚点放到外部的、不可被模型自述改变的事件上（PR 关闭、CI 结果、required approvals）。在 VLA 里，对应物就是**外部评测 episode 的真实成功率**，而不是模型自己生成的 success flag 或奖励模型打分。

如果你是 AI 应用开发者，这里有三个可以直接搬进自己 agent 项目的模式：

1. **Effects/Outbox**：状态写库与外部发送分离，发送在事务提交后执行。任何「Agent 发消息」的系统都该这么做，否则重启就会丢消息或重复发。
2. **人消息保留槽**：并发上限之外留一个槽给人。这一条几乎零成本，但直接消灭了「Agent 忙死了，人也进不来」的经典体验灾难。
3. **注意力预算化的输出策略**：确认一次、工作期间沉默、只在需要人行动时开口、一次只问一个问题。这比任何「回答要简洁」的提示词都更可执行。

**建议：观望——但只用半天读 docs。** 不要部署，先按顺序读 `000-philosophy.md` → `001-domain.md` → `003-execution.md` → `007-architecture.md`。`003-execution.md` 里的 Ticket stage 表和后台作业规则，是我今年读到的关于「长时间运行 Agent 如何不悬空」最具体的工程说明。

## 关键代码/配置片段

后台作业与槽位的核心规则（摘自 `docs/003-execution.md`，原文）：

```text
When a turn ends with shell jobs or subagents still running, the Ticket keeps
its worker slot and stays working. It is not reported as waiting, and the main
Session receives no waiting report. A completed job or subagent wakes the
Executor with its result in the same slot.

After each turn, background work has at most 30 minutes to finish. At that
limit, shell jobs are killed and the Ticket is reported waiting. The report
includes the Executor's last words and which jobs were killed or subagents
remain active. Subagents are allowed to continue.
```

人的专属槽位（原文）：

```text
The configured concurrency limit applies to these slots, with one extra slot
for a person's message or a status request. Such a wake can use the extra slot
when normal slots are full, and takes the next free slot before a new launch.
New work therefore cannot prevent a person from continuing an existing Ticket.
```

Ticket 阶段判定表（原文摘要，从上到下第一个匹配行胜出）：

| Stage | 条件 | Panel 显示 |
| --- | --- | --- |
| person / delivery | 向 Executor 投递 Input 失败（2 秒后重试，延迟翻倍至 1 分钟） | Input undelivered |
| person / answer | 有 Attention | Awaiting answer |
| person / review | 最新 Report 为 `ready` | Awaiting review |
| person / blocked, failed | 最新 Report 为 `blocked`/`failed` 且此后无人消息 | Blocked · Failed |
| working / queued | 无 Assignment 或存在 pending | Queued |
| idle | 最新 Report 为 `waiting`，或 Assignment 已结束 | Waiting for a Trigger |
| working | 其余 | Working |

自动合并的默认约束（原文摘要）：默认永不以 agent 账号开启 auto-merge；仅当 PR 为该 Ticket 所开、处于 ready、required approvals 覆盖 head commit、且 additions + deletions 合计少于 200 行时可开；推送新版本前须撤回 auto-merge。这些指令是**约束 Agent 的提示词**，不是 GitHub 的合并规则。

> TODO: 原型未提供任何 release / benchmark 数据（Releases 页面为空），亦未给出任务成功率、PR 采纳率或成本对比数字；本文不对此类指标做任何推断。

---
[← Back to Deep Dives](./README.md)
