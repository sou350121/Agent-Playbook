---
auto_generated: true
generated_at: "2026-11-16T06:46:44Z"
source_url: "https://github.com/pydantic/pydantic-ai/releases/tag/v2.68.0"
signal_type: "blog_post"
---
# Pydantic AI v2.68.0：审批与反问回到 run 内 (Pydantic AI v2.68.0 — Approvals and Questions Move Inside the Run)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-16
>
> **项目/工具**: Pydantic AI
> **链接**: https://github.com/pydantic/pydantic-ai/releases/tag/v2.68.0
> **核心定位**: 在 agent 框架里，把「等人回话」从一场外部状态机变成 run 内的一等能力——顺带把 `max_tokens` 截断做成了自动降级触发器

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Pydantic AI 在 v2.68.0 把 human-in-the-loop（审批 / 反问 / 外部结果）收进 `HandleDeferredToolCalls` capability，run 不再中途「停尸」等下一次 `agent.run()`；同时新增 `OutputTokenLimitExceeded`，让 `ModelFallback` 在输出被 `max_tokens` 截断时自动换下一个模型。
- **现在值得用吗**：看场景。如果你在生产里跑需要人工审批的 agent（付款、删库、发邮件、改防火墙），值得立刻升级；如果只是玩具级别的单轮调用，可以先放着。
- **适合场景**：需要审批闸门的自动化、durable workflow（Temporal / DBOS / AWS Lambda durable functions）、多 agent 委派里需要子 agent 反问用户、以及被迫控制输出的长文本生成。
- **不适合场景**：还没上 2.x 的老项目（迁移成本不划算）；不需要人工介入的纯批处理；以及只用 OpenAI 一家、且不在意输出截断兜底的轻量脚本。
- **与前版核心差异**：之前 deferred tool call 基本等于「run 结束 → 你把结果塞回去再 run 一次」的 stop-the-world 模式；现在 handler 可以在 run 内原地回答，或者拿一个 resume token 交给外部（Slack / 邮件 / DB 行），run 就地挂起等待。

## 是什么 / 解决什么问题

Pydantic AI 是 Pydantic 团队做的 Python agent 框架，定位一直很清楚：让 agent 的输入输出、工具参数、结构化输出都由类型系统兜住，而不是靠 prompt 里写「请返回 JSON」。

它长期存在一个结构性尴尬：**agent 一旦需要人**，run 就断了。模型说「我需要你批准这个 `delete_database`」，框架把 `DeferredToolRequests` 作为 run 的输出吐出来，你的应用层存进数据库，等人类点了按钮，你再拿着 message history 重新 `agent.run()` 一次，把结果喂回去。这个「停尸—复活」流程能用，但状态管理全压在使用者身上：DAG 里怎么表达、durable engine 里怎么表达、重放时怎么保证不重复执行，全是自己的活。

v2.68.0 动的是这一层。`HandleDeferredToolCalls` 成为标准 capability：注册之后，工具抛出的 `ApprovalRequired`、`CallDeferred`、以及 Harness `AskUser(answerer=None)` 提的问题，都会交给你的 handler 处理，**run 在原地继续推进**，就像这些工具正常返回了一样。

第二个变化小一点但很实用：`OutputTokenLimitExceeded` 异常 + `ModelFallback` 默认把它列入 `fallback_on`。响应被 `max_tokens` 或模型自身的输出上限截断（`finish_reason='length'`）时，框架不再把半截内容当结果返回，而是换下一个模型重试。

本文不引用未公开的 benchmark：release notes 未给出这两项改动的性能数据，故所有性能层描述都只停留在机制层面。

## 技术架构拆解

### 核心设计决策

- **把「等待」建模成 capability，而不是 API 调用**。`HandleDeferredToolCalls` 是 `AbstractCapability` 的子类，注册方式是 `capabilities=[...]`，跟其他 capability 一样参与链条。好处是它天然可组合——多个 handler 按顺序各答一部分，没人答的继续冒泡成 `DeferredToolRequests` 输出。
- **handler 的签名决定行为**。两个位置参数 `(ctx, requests)` 表示「现场回答」：返回 `DeferredToolResults` 就地解决，返回 `None` 表示「我不答」，交给下一个 capability。三个必填位置参数 `(ctx, requests, token)` 则拿到 resume token，可以把它发到 Slack、写邮件、插一行数据库，然后返回 `None`，run 挂起等这个 token 被外部 resolve。
- **resume token 走 `wait_for_external_event`**。普通 run 里这是进程内等待；durable run 里则交给引擎记录。文档明确：当前支持这一点的 durable 引擎是 **AWS Lambda durable functions（通过 Harness 的 `AWSLambdaDurability`）**，其他 durable engine 会以 `UserError` 拒绝。
- **deferred call 带类型标签**。`DeferredToolRequests.kind(tool_call_id)` 返回三种值：`'approval'`（同意执行）、`'question'`（模型问的内容，例：Harness 的 `AskUser`）、`'external'`（外部执行的结果）。这个区分很关键——审批和提问以前混在同一个 `calls` 字典里，调用方只能靠猜。
- **回答者可以署名**。`DeferredToolResults.answered_by` 按 `tool_call_id` 记录「谁答的」，文档写得很克制：Pydantic AI 只上报、不校验。这明显是为审计留的口子，而不是做访问控制。
- **截断不再静默成功**。`OutputTokenLimitExceeded` 被定义为 `UnexpectedModelBehavior` 的子类，仅在「响应里没有可用的输出」时抛出——纯文本被截断仍作为 run 结果返回（这点很务实，半截文本有时就是能用的）。命名进 `fallback_on` 后，语义变成「任何 `finish_reason='length'` 的响应都拒收」，换下一个模型。

### 与前版/竞品的关键差异

| 维度 | 之前的 stop-the-world | v2.68.0 的 in-run 流程 |
|------|----------------------|----------------------|
| 状态管理 | 应用层自己存 message history + 请求 | 框架内，handler 就地解决 |
| 等待人的方式 | run 结束，等外部事件再重开 | run 挂起，resume token 被 resolve 后继续 |
| deferred 类型区分 | 审批与外部结果都在 `calls` / `approvals`，question 混在里面 | `kind()` 明确三态：`approval` / `question` / `external` |
| 多 handler 组合 | 无 | capability 链，未答的继续冒泡 |
| durable 引擎支持 | 自行实现重放逻辑 | 引擎侧记录 handler 答复（目前仅 AWS Lambda durable functions） |
| 输出截断 | 半截内容当结果用 | 无可用输出时抛 `OutputTokenLimitExceeded`，触发 `ModelFallback` |

### 架构/信息流图

```
模型调用工具
   │
   ├─ requires_approval / ApprovalRequired ──┐
   ├─ CallDeferred(kind='external') ─────────┤
   └─ CallDeferred(kind='question') ─────────┤
                                             ▼
                              DeferredToolRequests
                              (approvals / calls / _kinds)
                                             │
                              HandleDeferredToolCalls
                                  ┌──────────┴──────────┐
                     (ctx, requests)          (ctx, requests, token)
                     handler 直接回答            handler 拿到 resume token
                          │                          │
                     DeferredToolResults        None → run 挂起
                          │                          │  (Slack / 邮件 / DB 行)
                          │                          ▼
                          │                   wait_for_external_event
                          │                          │
                          └────────► run 原地继续 ◄───┘
                                          │
                              无人回答 → 冒泡为
                             DeferredToolRequests 输出
```

## 实用评估

### 什么场景值得用

- **生产审批闸门**：工具标了 `requires_approval=True`，你希望审批结果能在同一次 run 里生效，而不是把 message history 转存再续跑。代码就三行：`HandleDeferredToolCalls(handler=...)` + 返回 `requests.build_results(approve_all=True)`。
- **异步人机协作**：handler 第三个参数拿 token，把提问发到 Slack 频道，run 挂起；人在 Slack 里点完，外部代码用 token resolve。这正好是「agent 早上发起、人下午回」的形态，比轮询数据库干净。
- **多 agent 委派里子 agent 反问**：release notes 提到 `SubAgents` 委派可以跑成 Temporal / DBOS 的子工作流，sub-agent 的 task-control 事件也加了 `agent_name` 与 `parent_task_id`。子 agent 想问用户时，不用层层冒泡回主循环。
- **长文本生成的兜底**：翻译、摘要、代码生成这类容易撞 `max_tokens` 的活，`ModelFallback` 会自动换模型，一次配置省掉一堆 `finish_reason` 判断。
- **审计需求**：`answered_by` 把「谁批的」写进结果对象，虽然框架不校验，但你的日志能直接落地。

### 什么场景不值得用

- **纯批处理 pipeline**：没有人工介入点，这套 capability 只会增加一层你不需要的抽象。
- **自建 durable 编排且不用 AWS Lambda**：文档写得很直白——非 Lambda durable functions 的引擎会以 `UserError` 拒绝带 token 的等待。想用异步等待，你得先确认引擎支持；否则只能用两参数的「就地回答」形态。
- **以为 `answered_by` 是权限控制**：它只上报、不校验。想防越权审批，得自己在 handler 里比对身份。
- **指望它解决 schema 截断**：`OutputTokenLimitExceeded` 只在「没有可用输出」时抛；`NativeOutput` / `PromptedOutput` 被截成非法 JSON 会抛，但纯文本半截仍返回。想严格禁止半截输出，得自己检查 `finish_reason`。

### 迁移成本

- **`RequestInput` → `HandleDeferredToolCalls`**：release notes 明确 `RequestInput` 已被标记为 deprecated（源码注释写着 `TODO(v3): remove this module`）。区别只在 handler 签名——`RequestInput` 的 `ask` 永远带 token，`HandleDeferredToolCalls` 则看你是否声明了第三个必填位置参数。老代码改成三参数签名即可行为等价，但**这本身是 breaking 风险**：如果你原本写的是两参数 handler，升级后它会走「就地回答」分支而不是等待。
- **harness 字段重命名**：`num_results` → `max_results`、`max_duration_secs` → `max_duration_seconds`；`CapabilityEvent` 字段统一成 `*_count` / `*_name` / `duration_ms` / `previous_item`，子 agent 事件加 `Event` 后缀。旧名保留为 deprecated alias，短期不会炸，但会在 warning 里持续提醒你。
- **估算**：小团队一周内能消化。大头不在 API，而在**把停尸式续跑逻辑拆掉**——这部分业务代码里往往藏着幂等键、去重、重试策略，删掉要小心。

## 对你的意义

如果你的 Agent-Playbook 里那套 RAG / workflow pipeline 迟早要接「人审」环节，这次更新值得认真看一眼——它把「agent 停下来等人」从一个流程设计问题改成了一个 capability 配置问题。这是框架该做的事。

具体建议：**观望两周再上**。理由不是质量，而是时序——v2.68.0 同时动了 `RequestInput` 弃用、harness 字段重命名、子 agent 事件命名三套 API，短期内的 minor 版本大概率还会继续收尾。先在自己的一条非关键 pipeline 上升级，把两参数/三参数 handler 的语义差别跑通，再推生产。

另外那个 `OutputTokenLimitExceeded` → `ModelFallback` 的组合，其实跟你 VLA 那边的长输出场景也有共鸣：让框架在「输出被截断」时换模型，而不是让下游解析器炸掉，这是很干净的失败面设计。

## 关键代码/配置片段

就地回答（两参数 handler，auto-approve 全部）：

```python
from pydantic_ai import Agent
from pydantic_ai.capabilities import HandleDeferredToolCalls
from pydantic_ai.tools import DeferredToolRequests, DeferredToolResults, RunContext


async def handle_deferred(
    ctx: RunContext, requests: DeferredToolRequests
) -> DeferredToolResults:
    # Auto-approve all tools that need approval
    return requests.build_results(approve_all=True)


agent = Agent(
    'openai:gpt-5',
    capabilities=[HandleDeferredToolCalls(handler=handle_deferred)],
)
```

拿到 resume token 后交给外部（三参数 handler，run 挂起等待）：

```python
HandleDeferredToolCalls(
    handler,                 # handler(ctx, requests, token) -> DeferredToolResults | None
    timeout=timedelta(hours=4),
    name='approve_refund',   # durable engine 历史里的名字，跨部署要保持稳定
)
```

来源注释（`deferred_tool_handler.py`）：handler 返回 `None` 时，run 通过 `wait_for_external_event` 等待，直到外部用 `DeferredToolResults` 的 JSON 形式 resolve 这个 token；`timeout` 触发时，所有待批的审批被拒、待外部结果的调用失败，并向模型说明原因。

截断检测（`exceptions.py`）——`OutputTokenLimitExceeded` 的触发条件是 `finish_reason='length'` 且响应中没有可用的输出；`IncompleteToolCall` 是它在「模型在发工具调用途中被截断」这一子场景下的子类。

---
[← Back to Deep Dives](./README.md)
