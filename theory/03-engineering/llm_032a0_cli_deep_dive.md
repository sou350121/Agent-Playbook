---
auto_generated: true
generated_at: "2026-05-04T05:46:56Z"
source_url: "https://simonwillison.net/2026/Apr/29/llm/#atom-everything"
signal_type: "significant_update"
---
# LLM 0.32a0 重大架构重构：从 Prompt/Response 到 Messages/Parts

> 🔍 本文由 Moltbot 自动生成 | 2026-05-04
>
> **项目/工具**: LLM (Simon Willison)
> **链接**: https://simonwillison.net/2026/Apr/29/llm/
> **核心定位**: Python LLM 工具链的底层抽象重构 — 将输入从「单条 prompt」升级为「消息序列」，将输出从「纯文本流」升级为「多类型 Parts 流」，首次原生支持 reasoning + tool_call + text 混合输出的统一表达

## 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：LLM 是 Simon Willison 开发的 Python 库 + CLI 工具，用于通过插件系统统一访问各类 LLM。0.32a0 是一次底层抽象的重大重构，解决了原始「文本进、文本出」模型无法表达多模态/推理/工具调用混合输出的根本问题
- **现在值得用吗**：否（alpha 阶段，API 可能变动）；但 stable 0.32 发布后值得升级 — 尤其如果你在用 tool calling 或多轮对话
- **适合场景**：需要统一管理多模型 CLI 调用的开发者、构建 Agent 工作流需要混合 reasoning + tool_call 输出的场景、需要跨进程序列化/反序列化对话状态的系统
- **不适合场景**：仅做简单单轮文本补全且不需要 tool calling 的轻量场景（旧 API 仍可用但无新增收益）
- **与前版核心差异**：之前是 `prompt= → text` 的线性模型，现在是 `messages=[...] → stream_events()` 的图结构模型

## 是什么 / 解决什么问题

LLM 自 2023 年 4 月诞生以来，核心抽象一直是「发送文本 prompt → 收到文本 response」。这个模型在 GPT-3/4 早期完全够用——那时的模型只输出纯文本。

但三年间，LLM 能力发生了根本变化：
- **推理模型**（如 Claude 的 extended thinking、OpenAI 的 o 系列）在最终回答前输出大量 reasoning 文本
- **Tool calling** 让模型在流式输出中穿插 JSON 格式的工具调用请求
- **多模态输出** 让模型返回图片、音频等非文本内容
- **Server-side tool execution**（如 OpenAI code interpreter）让单次请求产生 text → tool_call → tool_result → text 的混合流

旧的 `prompt → text` 抽象已经无法表达这些混合类型。LLM 通过 attachments（图片/音频输入）、schemas（结构化 JSON 输出）、tools（工具调用）等补丁式功能勉强支撑，但底层模型越来越扭曲。

0.32a0 的核心目标就是**推倒重来**：用 OpenAI Chat Completions 风格的 `messages` 数组作为输入，用 typed `StreamEvent` 流作为输出，让抽象与真实 API 对齐。

## 技术架构拆解

### 核心设计决策

**决策 1：输入从 `prompt=` 升级为 `messages=`**

之前版本的多轮对话需要手动维护 `Conversation` 对象，每次调用 replay 完整历史：

```python
# 旧 API（0.31 及之前）
conversation = model.conversation()
r1 = conversation.prompt("Capital of France?")
r2 = conversation.prompt("Germany?")  # 隐式 replay 完整历史
```

问题：无法注入外部对话历史、无法灵活构建非线性的对话图、CLI 的 SQLite 持久化机制与 Python API 割裂。

新 API 直接对齐 OpenAI Chat Completions 的消息格式：

```python
# 新 API（0.32a0）
from llm import user, assistant

response = model.prompt(messages=[
    user("Capital of France?"),
    assistant("Paris"),
    user("Germany?"),
])
```

`llm.user()` / `llm.assistant()` / `llm.system()` / `llm.tool_message()` 是新的 builder 函数，返回 `Message` 对象。旧 `prompt=` 参数仍然可用，但底层自动合成为单元素 `messages` 数组——保证了向后兼容。

**决策 2：输出从 `for chunk in response` 升级为 `response.stream_events()`**

旧流式 API 只产出文本 chunk：

```python
for chunk in response:
    print(chunk, end="")  # 只有文本
```

新 API 产出 typed `StreamEvent`，每种事件类型对应模型输出的一个语义单元：

```python
for event in response.stream_events():
    if event.type == "text":
        print(event.chunk, end="")
    elif event.type == "reasoning":
        # reasoning 文本（如 Claude extended thinking）
    elif event.type == "tool_call_name":
        print(f"\nTool call: {event.chunk}(", end="")
    elif event.type == "tool_call_args":
        print(event.chunk, end="")
```

事件类型包括：`text`、`reasoning`、`tool_call_name`、`tool_call_args`、`tool_result`，以及 opaque reasoning 的 `redacted=True` 标记。

**决策 3：序列化与反序列化 — `to_dict()` / `from_dict()`**

为了解决跨进程/跨服务传递对话状态的问题，新增了 JSON-safe 的序列化机制：

```python
serializable = response.to_dict()  # 可存入任何存储
response = Response.from_dict(serializable)  # 完整恢复
```

关键细节：reasoning signatures（如 Anthropic extended-thinking signatures、Gemini thoughtSignature）会通过 `provider_metadata` 字段 round-trip，确保多轮 extended thinking 在进程边界间正常工作。这是之前 SQLite 硬编码方案无法做到的。

### 与前版/竞品的关键差异

| 维度 | LLM 0.31 及之前 | LLM 0.32a0 |
|------|-----------------|------------|
| 输入抽象 | `prompt=` (单条文本) | `messages=` (Message 序列) |
| 对话管理 | `model.conversation()` 隐式 replay | `messages=` 显式传入，可注入外部历史 |
| 流式输出 | `for chunk in response` (纯文本) | `response.stream_events()` (typed events) |
| Reasoning 支持 | 无原生支持 | `event.type == "reasoning"` 原生区分 |
| Tool calling 流式 | 仅最终结果可见 | `tool_call_name` + `tool_call_args` 实时流式 |
| 序列化 | SQLite 硬编码 | `to_dict()` / `from_dict()` 任意存储 |
| CLI reasoning 显示 | 不可见 | reasoning 文本以 dim 色输出到 stderr |
| 向后兼容 | — | 旧 `prompt=` API 仍可用（自动升级） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    LLM 0.32a0 架构                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  输入层                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐          │
│  │ user()   │    │assistant()│   │system()  │ ...      │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘          │
│       └───────────┬───┘───────────────┘                 │
│                   ▼                                     │
│          messages: List[Message]                        │
│                   │                                     │
│                   ▼                                     │
│  ┌─────────────────────────────────┐                   │
│  │  model.prompt(messages=[...])   │                   │
│  └───────────────┬─────────────────┘                   │
│                  │                                     │
│  输出层 (StreamEvent)                                  │
│                  ▼                                     │
│  ┌──────────────────────────────────────────────┐      │
│  │  response.stream_events()                    │      │
│  │  ├─ text         → 最终回答文本              │      │
│  │  ├─ reasoning    → 推理过程文本              │      │
│  │  ├─ tool_call_name  → 工具名                 │      │
│  │  ├─ tool_call_args  → 工具参数(JSON流)       │      │
│  │  └─ tool_result    → 工具执行结果            │      │
│  └──────────────────────────────────────────────┘      │
│                  │                                     │
│  后处理                                           │
│  ┌──────────────────────────────────────────────┐      │
│  │  response.reply()      → 自动续谈            │      │
│  │  response.execute_tool_calls() → 执行工具    │      │
│  │  response.to_dict()    → 序列化              │      │
│  │  Response.from_dict()  → 反序列化            │      │
│  └──────────────────────────────────────────────┘      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **Agent 工作流构建**：当你的 Agent 需要同时处理 reasoning 输出、tool calling 和最终文本时，新的 `stream_events()` 让你可以精确区分每种事件类型，而不是从纯文本中 regex 解析。这直接降低了 Agent 框架的解析复杂度。
- **多轮对话状态持久化**：`to_dict()` / `from_dict()` 让你可以把对话状态存入 Redis、S3 或任何存储，而不被绑定到 SQLite。对于需要跨进程/跨服务传递对话状态的分布式 Agent 系统，这是一个关键能力。
- **CLI 调试推理模型**：`-R/--no-reasoning` 标志和 reasoning 文本 stderr 输出，让 CLI 用户可以实时观察模型的推理过程，同时不影响管道（piping）——reasoning 走 stderr，最终回答走 stdout。
- **OpenAI Chat Completions API 模拟**：新 `messages=` 接口让构建 OpenAI 兼容的 API 代理变得直接，不再需要 workaround。

### 什么场景不值得用

- **简单单轮补全**：如果你只是 `llm -m gpt-5.5 "summarize this"`，旧 API 完全够用，新 API 没有额外收益
- **Alpha 稳定性风险**：这是 alpha 发布，Simon 明确说 "unless alpha testing reveals some design flaw"。生产环境建议等 stable 0.32
- **不依赖插件生态的轻量场景**：如果你只用 LLM 做简单的文本输入输出，这个重构对你透明的——旧 API 仍然工作

### 迁移成本

**对终端用户（CLI）**：零迁移成本。所有现有 `llm prompt` / `llm chat` 命令继续工作。唯一新增的是 `-R/--no-reasoning` 标志。

**对 Python API 用户**：
- 如果只用 `model.prompt("text")`：零成本，旧 API 自动升级为单元素 messages
- 如果用 `conversation.prompt()`：需要评估是否改用 `messages=` 显式传入历史。迁移量取决于对话复杂度，简单场景不改也行
- 如果开发了自定义 model plugin：需要阅读新的 [Advanced model plugins](https://llm.datasette.io/en/latest/plugins/advanced-model-plugins.html) 文档，适配 `StreamEvent` 和 `response.prompt.messages`

**对插件开发者**：中等工作量。需要适配新的 `StreamEvent` 类型系统、消费 `prompt.messages`、处理 provider metadata round-trip。Simon 已更新插件文档，但每个插件需要单独适配。

## 对你的意义

LLM 是 AI Agent 生态中最重要的基础设施工具之一——它本质上是一个「模型抽象层」，让开发者用统一接口访问任意 LLM。这次重构的意义在于：

1. **它定义了 Python 生态中 LLM 抽象的「标准形态」**：messages 输入 + typed parts 输出。这可能会影响其他框架（如 LangChain、LlamaIndex）的 API 设计方向
2. **对 Agent 开发者的直接影响**：如果你在用 LLM 构建 Agent，新的 `stream_events()` + `reply()` 自动 tool execution 让 agent loop 的实现大幅简化
3. **序列化能力是分布式 Agent 的关键拼图**：`to_dict()` / `from_dict()` 让对话状态可以在进程间传递，这是构建多 Agent 协作系统的底层需求

**建议**：Alpha 阶段先在开发环境试用，熟悉新 API。等 stable 0.32 发布后评估升级。如果你开发了 LLM 插件，关注 Simon 的插件适配文档更新。

## 关键代码/配置片段

### 新的消息构建 API

```python
import llm
from llm import user, assistant

model = llm.get_model("gpt-5.5")

# 注入外部对话历史
response = model.prompt(messages=[
    user("Capital of France?"),
    assistant("Paris"),
    user("Germany?"),
])
print(response.text())  # "Berlin"
```

### 流式混合事件处理

```python
response = model.prompt(prompt, tools=[describe_dog])

for event in response.stream_events():
    if event.type == "text":
        print(event.chunk, end="", flush=True)
    elif event.type == "tool_call_name":
        print(f"\nTool call: {event.chunk}(", end="", flush=True)
    elif event.type == "tool_call_args":
        print(event.chunk, end="", flush=True)

# 自动执行工具调用并续谈
print(response.reply("Tell me about the dogs"))
```

### 序列化/反序列化

```python
# 保存对话状态
serializable = response.to_dict()
# store serializable anywhere (Redis, S3, database...)

# 恢复对话状态
response = Response.from_dict(serializable)
```

### CLI reasoning 控制

```bash
# 显示 reasoning 文本（dim 色，输出到 stderr）
llm -m claude-sonnet-4.6 'Think about 3 cool dogs' -o thinking_display 1

# 抑制 reasoning 输出
llm -m claude-sonnet-4.6 'Think about 3 cool dogs' -R
```

---
[← Back to Deep Dives](./README.md)
