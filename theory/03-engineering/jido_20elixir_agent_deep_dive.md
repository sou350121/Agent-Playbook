---
auto_generated: true
generated_at: "2026-03-13T06:46:29Z"
source_url: "https://jido.run/blog/jido-2-0-is-here"
signal_type: "significant_update"
---
# Jido 2.0：Elixir 生态的生产级 Agent 框架 (Jido 2.0: Production-Grade Agent Framework for Elixir Ecosystem)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-13
>
> **项目/工具**: Jido 2.0
> **链接**: https://jido.run/blog/jido-2-0-is-here
> **核心定位**: BEAM 生态首个成熟的 Agent 框架，以纯函数式架构 + 可插拔推理策略 + 标准化工具契约，提供生产级多 Agent 编排能力

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**：Elixir/BEAM 生态的生产级 Agent 框架，18 个月打磨后 2.0 版本正式可用
- **現在值得用嗎**：是 — 如果你在用 Elixir/Phoenix/Ash，或需要高并发 Agent 运行时
- **適合場景**：高并发工具调用 Agent、多 Agent 协作系统、需要 BEAM 容错性的生产环境
- **不適合場景**：快速原型验证（Python/TS 生态更丰富）、单线程简单任务
- **與 [LangChain/AutoGen] 核心差異**：BEAM 原生并发模型 + 纯函数式 Agent 架构 + 编译时工具契约验证

## 是什么 / 解决什么问题

Jido 始于 2024 年的 BotHive 机器人平台，在 AI 浪潮后转向 Agent 框架。作者的核心判断是：**BEAM 虚拟机是为 Agent 系统而生的运行时**。

这个判断有坚实依据：
- TypeScript 框架受限于单线程事件循环，用 Promise "祈祷" 来管理并发 Agent
- Python Agent 初期表现尚可，但长期运行稳定性不足
- BEAM 从设计之初就为高并发、软实时、容错系统而生 — 这正是多 Agent 系统的核心需求

Jido 1.0 于 2025 年 3 月发布，但被作者自评为"过度工程化" — 添加了实践中无意义的抽象，导致基础操作比竞品更复杂。2.0 版本基于大量用户反馈重构：**更简单的 API、更少的仪式、从底层开始的 BEAM 优先设计**。

2.0 的核心突破是将 Agent 从"框架魔法"还原为**纯函数式数据结构**：Agent 只是一个包含状态、动作和工具的 struct，通过单一的 `cmd/2` 函数处理所有输入，输出更新后的 Agent 和一组"指令"(directives)。副作用被描述为类型化的数据结构，由运行时执行。这使得 Agent 可推理、可测试、可调试。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 理由 | 对比竞品 |
|----------|------|----------|
| **Agent 即数据** | 纯函数式架构，状态变更可追踪、可回放 | LangChain/AutoGen 的 Agent 是带内部状态的对象 |
| **cmd/2 单一入口** | 所有输入输出通过统一契约，便于测试和组合 | 多数框架有多个入口点（ask/run/invoke） |
| **Directives 描述副作用** | 副作用与逻辑分离，测试时无需 mock 网络/DB | 通常直接执行副作用，测试困难 |
| **策略可插拔** | ReAct/CoT/ToT 等只是策略实现，同一 Agent 可切换 | 框架通常绑定单一推理模式 |
| **工具即 Jido.Action** | 编译时 schema 验证，自动转换为 LLM tool 格式 | 运行时验证为主，错误发现晚 |

### 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                        │
│   Integrations, delivery channels, operator tooling         │
├─────────────────────────────────────────────────────────────┤
│                      AI LAYER                               │
│   jido_ai: Reasoning strategies, memory, model routing      │
│   ┌─────────┬─────────┬─────────┬─────────┬─────────────┐   │
│   │ ReAct   │  CoT    │  ToT    │  GoT    │  Adaptive   │   │
│   │ (default)│(math/logic)│(branching)│(graph)│(auto-select)│   │
│   └─────────┴─────────┴─────────┴─────────┴─────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                     CORE LAYER                              │
│   jido: Agent lifecycle runtime, GenServer wrapper, signals │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Jido.AgentServer (supervised GenServer)            │   │
│   │  ┌───────────────────────────────────────────────┐  │   │
│   │  │  Agent struct + cmd/2 + directives executor   │  │   │
│   │  └───────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                  FOUNDATION LAYER                           │
│   jido_action: Universal action contract (25+ pre-built)    │
│   jido_signal: CloudEvents v1.0.2 based messaging (9 adapters)│
│   req_llm: 11 providers, 665+ models                        │
└─────────────────────────────────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | Jido 1.0 / 竞品 | Jido 2.0 |
|------|----------------|----------|
| **Agent 定义** | 带内部状态的类/对象 | 纯数据 struct |
| **执行模型** | 框架魔法，隐式状态管理 | cmd/2 纯函数 + directives |
| **测试难度** | 需 mock LLM/网络/DB | 单元测试决策逻辑，无需外部依赖 |
| **策略扩展** | 困难，通常需 fork 框架 | 实现策略 behaviour 即可 |
| **工具契约** | 运行时验证 | 编译时 schema 验证 |
| **信号系统** | 自定义协议 | CloudEvents v1.0.2 标准 |

### 推理策略矩阵

Jido AI 内置 8 种推理策略，覆盖不同 trade-off：

| 策略 | 模块 | 适用场景 | 成本/延迟 |
|------|------|----------|-----------|
| **ReAct** | Jido.AI.Agent | 工具调用默认选择 | 中等 |
| **CoD** | Jido.AI.CoDAgent | 简洁推理，低延迟/成本 | 低 |
| **Chain-of-Thought** | Jido.AI.CoTAgent | 数学、逻辑等多步任务 | 中等 |
| **AoT** | Jido.AI.AoTAgent | 单遍算法探索 | 中等 |
| **Tree-of-Thoughts** | Jido.AI.ToTAgent | 复杂任务的分支探索 | 高 |
| **Graph-of-Thoughts** | Jido.AI.GoTAgent | 图式探索 | 高 |
| **TRM** | Jido.AI.TRMAgent | 迭代递归精化 | 高 |
| **Adaptive** | Jido.AI.AdaptiveAgent | 混合负载，自动选择策略 | 中等 |

## 实用评估

### 什么场景值得用

1. **你在 Elixir/Phoenix/Ash 生态中**
   - 原生集成，无需跨语言调用
   - ash_jido 让 CRUD 动作直接变为 AI 可调用的工具，保留授权策略和类型安全

2. **需要高并发 Agent 系统**
   - BEAM 轻量级进程模型可轻松支撑数千并发 Agent
   - 每个 Agent 是独立 GenServer，故障隔离

3. **生产环境需要可观测性和容错**
   - Telemetry 事件集成，稳定事件名便于生产监控
   - Supervisor 树自动重启失败 Agent

4. **需要多策略切换**
   - 同一 Agent 可根据任务复杂度切换 ReAct/CoT/ToT
   - Adaptive 策略自动选择

### 什么场景不值得用

1. **快速原型验证**
   - Python/TS 生态有更丰富的预建工具和示例
   - Jido 生态仍在成长中

2. **单线程简单任务**
   - BEAM 并发优势无法发挥
   - 学习曲线较陡

3. **需要特定 LLM 提供商独家功能**
   - ReqLLM 覆盖 11 提供商 665+ 模型，但最新功能可能有延迟

4. **团队无 Elixir 经验**
   - 学习 OTP/GenServer/Behaviour 需要时间投入

### 迁移成本

**从 LangChain/AutoGen 迁移**：
- 工具定义方式不同：需从 Python/TS class 转为 Elixir module + Jido.Action
- Agent 状态管理范式转变：从对象状态到纯函数式数据流
- 预计工作量：中等（2-5 天熟悉架构 + 重写核心逻辑）

**从零开始**：
- 使用 Igniter 安装：`mix igniter.install jido_ai` 自动配置依赖和模型别名
- 第一个 ReAct Agent 可在 30 分钟内完成

## 对你的意义

### 对 Ken 的 AI 应用开发线的价值

1. **Agent-Playbook 新增 Elixir 生态视角**
   - 目前 Handbook 以 Python/TS 为主，Jido 提供 BEAM 视角的 Agent 架构参考
   - 纯函数式 Agent 设计模式值得跨语言借鉴

2. **高并发 Agent 系统的参考实现**
   - 如果你在规划多 Agent 协作系统，Jido 的 GenServer + Supervisor 模型是成熟方案
   - directives 模式可借鉴到其他语言（如 Python 的 dataclass + executor）

3. **MCP 集成验证假设 A-001**
   - Jido 支持 MCP（Model Context Protocol），验证了 MCP 成为工具集成事实标准的趋势
   - BEAM 生态的 MCP 实现细节值得研究

### 建议

- **立即试用**：如果你在 Elixir 生态中，Jido 2.0 已生产就绪
- **观望学习**：如果你用 Python/TS，建议阅读其架构文档，借鉴纯函数式 Agent 设计
- **跳过**：如果你只需要简单单 Agent 原型，LangChain 仍更便捷

## 关键代码/配置片段

### 定义工具（Jido.Action）

```elixir
defmodule MyApp.Actions.ProcessOrder do
  use Jido.Action,
    name: "process_order",
    description: "Process a customer order",
    schema: Zoi.object(%{
      order_id: Zoi.string(),
      quantity: Zoi.integer()
    })

  @impl true
  def run(%{order_id: order_id, quantity: quantity}, _context) do
    # 业务逻辑
    {:ok, %{status: "processed", order_id: order_id}}
  end
end
```

### 定义 AI Agent

```elixir
defmodule MyApp.SupportAgent do
  use Jido.AI.Agent,
    name: "support_agent",
    description: "Customer support agent with tool access",
    tools: [
      MyApp.Actions.LookupOrder,
      MyApp.Actions.CheckInventory,
      MyApp.Actions.CreateTicket
    ],
    model: "anthropic:claude-sonnet-4-20250514",
    max_iterations: 6,
    system_prompt: """
    You are a customer support agent. Use the available tools
    to look up orders, check inventory, and create tickets.
    Be concise and helpful.
    """
end
```

### 启动并调用

```elixir
# 启动 Agent Server
{:ok, pid} = Jido.AgentServer.start_link(agent: MyApp.SupportAgent)

# 同步调用
{:ok, answer} = MyApp.SupportAgent.ask_sync(
  pid,
  "Order #4521 hasn't arrived. Can you check on it and open a ticket?",
  timeout: 60_000
)

# 异步调用（适合长任务）
{:ok, request} = MyApp.SupportAgent.ask(pid, "Complex query...")
{:ok, result} = MyApp.Agent.await(request, timeout: 15_000)
```

### 纯函数式测试（无需 mock）

```elixir
# 测试 Agent 决策逻辑，无需网络/LLM
test "process order action returns correct directive" do
  agent = MyApp.SupportAgent.new()
  {:ok, updated_agent, directives} = Jido.Agent.cmd(agent, {:ProcessOrder, order_id: "123"})
  
  assert length(directives) == 1
  assert hd(directives).type == :tool_call
  # 完全确定性，可重复测试
end
```

### 配置模型别名和提供商

```elixir
# config/config.exs
config :jido_ai,
  model_aliases: %{
    fast: "anthropic:claude-3-haiku-20240307",
    capable: "anthropic:claude-sonnet-4-20250514",
    reasoning: "openai:o1-preview"
  }

config :req_llm,
  anthropic_api_key: System.get_env("ANTHROPIC_API_KEY"),
  openai_api_key: System.get_env("OPENAI_API_KEY")
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | Jido 2.0 原生支持 MCP 集成，验证了 MCP 在 BEAM 生态的落地；结合 Python 生态的 MCP 实现，跨语言标准化趋势明显 |

---

[← Back to Deep Dives](./README.md)
