---
auto_generated: true
generated_at: "2026-04-12T03:32:00Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/introducing-stateful-mcp-client-capabilities-on-amazon-bedrock-agentcore-runtime/"
signal_type: "blog_post"
---
# AWS Bedrock AgentCore Runtime：状态化 MCP 客户端能力 (Stateful MCP Client Capabilities on Amazon Bedrock AgentCore Runtime)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-12
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime + Model Context Protocol (MCP)
> **链接**: https://aws.amazon.com/blogs/machine-learning/introducing-stateful-mcp-client-capabilities-on-amazon-bedrock-agentcore-runtime/
> **核心定位**: AWS 在 AgentCore Runtime 上实现 MCP 规范中的三项客户端能力（Elicitation/Sampling/Progress），将单向工具执行升级为双向对话式 Agent 工作流

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: AWS Bedrock AgentCore Runtime 新增状态化 MCP 客户端支持，使 MCP Server 能在执行中主动请求用户输入、调用 LLM 生成内容、流式汇报进度
- **现在值得用吗**: 是 — 如果你的 Agent 需要多轮交互工作流（如分步确认、动态生成内容、长任务进度反馈）
- **适合场景**: 交互式工具链（分步收集用户输入）、Server 端无 LLM 凭证但需调用模型、长耗时任务（需进度反馈）
- **不适合场景**: 简单单向工具调用（ Stateless 模式更轻量）、涉及敏感信息输入（密码/API Key 应走 URL 模式或外部通道）
- **与 [前版] 核心差异**: 之前 Stateless 模式下 Server 无法维持会话上下文、无法主动发起请求；现在 Stateful 模式通过微 VM 会话 + Mcp-Session-Id 实现双向通信

## 是什么 / 解决什么问题

**背景痛点**: 在 Agent 开发中，常见三类场景在 Stateless MCP 模式下无法实现：
1. 工具执行到一半需要向用户确认或收集额外输入（如"这笔支出属于哪个类别？"）
2. Server 端没有 LLM API 凭证，但工作流需要动态生成文本（如基于结构化数据生成自然语言摘要）
3. 长耗时任务（如跨数据源搜索）执行中用户只能看到空白界面，无法感知进度

**这次变化的核心**: AWS 在 AgentCore Runtime 上完整实现了 MCP 规范定义的三项**客户端能力**（Client Capabilities）：
- **Elicitation**: Server 暂停执行，通过客户端向用户请求结构化输入
- **Sampling**: Server 向客户端请求 LLM 生成的内容（Client 转发给其连接的 LLM）
- **Progress Notification**: Server 流式汇报任务进度

这标志着 MCP 协议从"Client 调用 Server 工具"的单向模式，进化为"Server 与 Client 双向对话"的完整实现。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 理由 |
|----------|------|
| **Stateless HTTP → Stateful HTTP** | 通过 `stateless_http=False` 开关切换，Stateful 模式下每个会话分配独立微 VM |
| **微 VM 会话隔离** | 每个用户会话拥有独立 CPU/内存/文件系统，会话最长 8 小时，空闲 15 分钟超时 |
| **Mcp-Session-Id 路由** | Initialize 握手时 Server 返回 Session ID，Client 后续请求携带该 ID 路由回同一会话 |
| **客户端能力协商** | Client 在初始化时声明支持哪些能力，Server 仅使用 Client 已声明支持的能力 |
| **Elicitation 三动作模型** | Accept（用户提供数据）/ Decline（用户明确拒绝）/ Cancel（用户取消），Server 需分别处理 |

### 与前版/竞品的关键差异

| 维度 | 之前（Stateless 模式） | 现在（Stateful 模式） |
|------|----------------------|---------------------|
| stateless_http 设置 | TRUE | FALSE |
| 会话隔离 | 每请求独立 | 每会话独立微 VM |
| 会话生命周期 | 无状态 | 最长 8 小时 / 15 分钟空闲超时 |
| 客户端能力 | 不支持 | Elicitation, Sampling, Progress |
| 推荐场景 | 简单工具服务 | 交互式多轮工作流 |
| 配置复杂度 | 单行配置 | 单行配置（同一开关） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                     Amazon Bedrock AgentCore Runtime        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Dedicated microVM per Session            │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │           MCP Server (stateless_http=False)     │  │  │
│  │  │  • Elicitation: ctx.elicit() → 用户输入         │  │  │
│  │  │  • Sampling: ctx.sample() → LLM 生成内容        │  │  │
│  │  │  • Progress: ctx.report_progress() → 进度更新   │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │                    ↑ Mcp-Session-Id header             │  │
│  └───────────────────────────────────────────────────────┘  │
│              Session lifetime: ≤8h, idle timeout 15min      │
└─────────────────────────────────────────────────────────────┘
                            ↑↓ HTTP (Streamable)
                            │
┌─────────────────────────────────────────────────────────────┐
│                      MCP Client                             │
│  • 声明支持的能力 (elicitation/sampling/progress)           │
│  • elicitation_handler: 渲染表单收集用户输入                │
│  • sampling: 转发请求到连接的 LLM（用户可审核）              │
│  • progress: 显示进度条/状态指示器                          │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **分步交互式工具**: 如费用报销工具先搜索历史数据，再让用户从结果中选择类别；旅行预订工具先搜索目的地，再让用户确认偏好
2. **Server 端无 LLM 凭证**: Server 只负责业务逻辑（如查数据库），将自然语言生成委托给 Client 端的 LLM（Client 控制模型选择和成本）
3. **长耗时任务反馈**: 跨多个数据源搜索、批量处理、模型推理等耗时操作，通过进度通知保持用户感知

### 什么场景不值得用

1. **简单单向工具**: 如"查询天气"、"转换格式"等输入→输出一次性完成的工具，Stateless 模式更轻量
2. **敏感信息输入**: 密码、API Key、支付信息不应通过 Elicitation Form 模式收集，应使用 URL 模式引导到外部安全页面
3. **高并发无状态场景**: 需要水平扩展、会话持久化不重要的场景，Stateless 模式部署更简单

### 迁移成本

从 Stateless 迁移到 Stateful 模式：
- **代码改动**: 仅需在 Server 启动时设置 `stateless_http=False`
- **会话管理**: 需注意 Session ID 失效处理（会话过期/Server 重启后返回 404，Client 需重新初始化）
- **资源开销**: 每个会话占用独立微 VM，需评估并发会话数的成本影响
- **Client 适配**: Client 需实现 elicitation_handler 等回调函数才能发挥完整能力

## 对你的意义

**对 Ken 的 Agent-Playbook 研究的价值**:

1. **MCP 事实标准验证**: AWS 官方完整实现 MCP 客户端能力，进一步巩固 MCP 作为 Agent 工具集成标准的地位（支持假设 A-001）
2. **Agent UI 设计参考**: Elicitation 的 Form/URL 双模式、Sampling 的人机审核机制，为 Agent UI 框架设计提供可直接参考的模式
3. **状态管理实践**: 微 VM 会话隔离 + Session ID 路由的方案，是 Serverless 环境下维持 Agent 对话状态的可行路径

**建议**: 
- **立即试用**: 如果你正在开发需要多轮交互的 Agent 工具，这是目前最成熟的生产级方案
- **关注成本**: 微 VM 会话模式在并发场景下的成本需实测评估
- **参考实现**: AWS 提供的完整示例（含 DynamoDB 集成）可直接复用或作为基准

## 关键代码/配置片段

### Server 端：启用 Stateful 模式

```python
mcp.run(
    transport="streamable-http",
    host="0.0.0.0",
    port=8000,
    stateless_http=False  # 启用状态化模式
)
```

### Elicitation 示例：分步收集用户输入

```python
from pydantic import BaseModel
from fastmcp import FastMCP, Context
from fastmcp.server.elicitation import AcceptedElicitation

mcp = FastMCP(name='ElicitationMCP')

class AmountInput(BaseModel):
    amount: float

class CategoryInput(BaseModel):
    category: str  # one of: food, transport, bills, entertainment, other

@mcp.tool()
async def add_expense_interactive(user_alias: str, ctx: Context) -> str:
    # Step 1: 询问金额
    result = await ctx.elicit('How much did you spend?', AmountInput)
    if not isinstance(result, AcceptedElicitation):
        return 'Expense entry cancelled.'
    amount = result.data.amount

    # Step 2: 选择类别
    result = await ctx.elicit(
        'Select a category (food, transport, bills, entertainment, other):',
        CategoryInput
    )
    if not isinstance(result, AcceptedElicitation):
        return 'Expense entry cancelled.'
    category = result.data.category

    # ... 后续步骤处理
    return f'Expense of ${amount:.2f} added for {user_alias}'
```

### Client 端：注册 Elicitation Handler

```python
from fastmcp import Client
from fastmcp.client.transports import StreamableHttpTransport

async def elicit_handler(message, response_type, params, context):
    # 生产环境：渲染表单并返回用户输入
    # 示例：模拟预设回复
    response = {'amount': 45.50, 'category': 'food'}
    return response

transport = StreamableHttpTransport(url=mcp_url, headers=headers)

async with Client(transport, elicitation_handler=elicit_handler) as client:
    result = await client.call_tool('add_expense_interactive', {'user_alias': 'me'})
```

### Sampling 示例：Server 请求 LLM 生成

```python
@mcp.tool()
async def analyze_spending(user_alias: str, ctx: Context) -> str:
    transactions = db.get_transactions(user_alias)
    
    lines = '\n'.join(
        f"- {t['description']} (${abs(float(t['amount'])):.2f}, {t['category']})"
        for t in transactions
    )

    prompt = (
        f'Here are the recent expenses for a user:\n{lines}\n\n'
        f'Please analyse the spending patterns and give 3 concise, '
        f'actionable recommendations to improve their finances. '
        f'Keep the response under 120 words.'
    )

    ai_analysis = 'Analysis unavailable.'
    try:
        response = await ctx.sample(messages=prompt, max_tokens=300)
        if hasattr(response, 'text') and response.text:
            ai_analysis = response.text
    except Exception:
        pass

    return f'Spending Analysis for {user_alias}:\n{ai_analysis}'
```

### Progress Notification 示例

```python
@mcp.tool()
async def long_running_task(ctx: Context) -> str:
    total_steps = 10
    for i in range(total_steps):
        # 执行某一步骤
        await do_step(i)
        # 汇报进度
        await ctx.report_progress(progress=i + 1, total=total_steps)
    
    return 'Task completed.'
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AWS 官方完整实现 MCP 客户端能力，标志着 MCP 从社区规范走向云厂商生产级支持，进一步巩固其作为 Agent 工具集成标准的地位 |

---

[← Back to Deep Dives](./README.md)
