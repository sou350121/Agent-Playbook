---
auto_generated: true
generated_at: "2026-10-20T05:45:40Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/structured-outputs-for-anthropic-claude-models-on-amazon-bedrock/"
signal_type: "blog_post"
---
# Amazon Bedrock 为 Claude 全系模型上线 Structured Outputs 与 Strict Tool Use (Structured Outputs & Strict Tool Use for Claude on Amazon Bedrock)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-20
>
> **项目/工具**: Amazon Bedrock（把 Anthropic Claude 系列模型托管在 AWS 上的托管推理服务）——本次更新为 Structured Outputs + Strict Tool Use，现已 GA（一般可用）
> **链接**: https://aws.amazon.com/blogs/machine-learning/structured-outputs-for-anthropic-claude-models-on-amazon-bedrock/
> **核心定位**: 在 token 生成阶段用 constrained decoding 强制 JSON Schema，宣布「结构化输出从概率问题变成确定性问题」，同时把同样的约束能力延伸到 Agent 的工具参数（`strict: true`）。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Bedrock 上的 Claude 现在可以保证吐出符合你 JSON Schema 的响应，工具调用参数也可以被严格约束，不再需要「解析失败→重试」这一层胶水代码。
- **現在值得用嗎**：**看場景** —— 只要你的业务依赖「LLM 输出必须能直接落库 / 直接进入下一步 Agent 调用」，就值得迁移过去；如果只是自由文本生成，收益不大。
- **適合場景**：票据/合同/邮件的字段抽取、分类路由（enum 约束）、多步 Agent 工作流里的工具参数校验、批量离线抽取（batch inference）。
- **不適合場景**：依赖递归 schema、数值/长度约束（`minimum`/`maxLength`）、外部 `$ref` 的复杂数据模型 —— 这些**不会被强制生效**；也不想为每个新 schema 付首次编译延迟的场景。
- **與「自己写 retry + JSON repair」核心差異**：从「事后修复错误输出」变成「根本不生成非法 token」，同时因为只允许 schema 内字段，输出 token 数变少。

## 是什么 / 解决什么问题

过去两年里，几乎所有 Agent 应用的工程代码里都住着同一个小魔鬼：`json.loads()` 炸了，然后走 retry、走正则修补、走「再问模型一次」。这套胶水代码既贵（多一次推理）、又不可靠（重试仍可能失败）、还难 debug（失败是概率性的）。

Bedrock 这次的做法是把问题前移：**在 token 生成阶段就用 constrained decoding 约束语法**，让模型不可能产出违反 schema 的 token。官方 blog 的原话是——「The model doesn't produce tokens that would violate your schema. This changes output formatting from probabilistic to deterministic.」

这次更新同时覆盖两条链路：

- **JSON Schema output format**：控制模型整体响应的结构，面向数据抽取、报告生成、API 响应。
- **Strict tool use**：校验工具/函数参数是否匹配 schema，面向 Agent 工作流、函数调用、多步自动化。

两个端点是 `bedrock-runtime`（Boto3 / InvokeModel / Converse）和 `bedrock-mantle`（Messages API 风格，面向 agentic 应用，带服务端工具、后台推理、有状态会话）。也就是说，**不管你是「AWS 原生 SDK 派」还是「Anthropic SDK 派」，都能用上**。

## 技术架构拆解

### 核心设计决策

- **约束发生在解码时，而不是事后校验**。这是最关键的一条：不是「生成完再检查 + 重试」，而是「非法分支从一开始就被 mask 掉」。因此 blog 才敢说 `JSON.parse()` 错误「不再出现」。
- **语法产物（grammar artifact）编译 + 缓存**。新 schema 第一次请求时，Bedrock 先做 schema 校验、再编译语法产物，所以首次请求「可能稍慢」；编译结果按账号维度缓存 **24 小时**，后续同 schema 请求「开销极小」。
- **缓存失效条件被精确定义**：改 schema 的**结构**会失效缓存并重新编译；只改 `name` / `description` 字段**不会**失效。这是一个相当务实的细节——鼓励你「结构定死，描述随便迭代」。
- **`additionalProperties: false` 是硬性要求**，所有 object 都必须设置，否则 schema 不被接受。这条同时带来副作用收益：输出只包含 schema 内字段，**输出 token 变少、高频负载成本下降**。
- **双端点一致能力**：`bedrock-runtime` 与 `bedrock-mantle` 都支持这两个机制；`bedrock-runtime` 还额外兼容 **cross-Region inference**（跨区域推理）和 **batch inference**（批量异步），并支持「以 typed events 流式返回结构化响应」。
- **失败路径被显式保留**：blog 明确说有两种情况会产生不符合 schema 的响应——**拒绝（refusal，出于安全原因）**和**token 上限（max_tokens 未写完）**。所以「确定性」不是绝对的，`stop_reason` 必须检查。

### 与前版/竞品的关键差异

| 维度 | 之前（prompt 约束 + 事后解析） | 现在（Bedrock Structured Outputs） |
|------|------|------|
| 输出合法性 | 概率性，需要 retry / repair | 解码期强制，格式确定性 |
| 字段类型 | 靠模型自觉 | 强制类型、required 字段必现 |
| 多余字段 | 模型可能瞎加字段 | 被 schema 限制，不会越界 |
| Token 成本 | 通常更高（多字段/多轮修复） | 输出更省（只产出 schema 内字段） |
| 首次延迟 | 无额外开销 | 新 schema 需编译语法，首次略慢 |
| 重复请求 | 无状态 | 同一 schema 24h grammar cache |
| 工具参数 | 调用后才校验，可能畸形 | `strict: true` 生成期约束参数 |

### 架构/信息流图

```
Client (Boto3 / Anthropic SDK)
        │
        ▼
┌─────────────────────────────────────────────┐
│  Bedrock 请求入口                            │
│  1. Schema 校验（JSON Schema Draft 2020-12   │
│     子集 + 强制 additionalProperties:false） │
│  2. Grammar 编译（新 schema 首次 → 稍慢）    │
│  3. Grammar Cache（账号级，24h TTL）         │
│     └ 改 name/description → 命中缓存         │
│     └ 改结构 → 缓存失效，重新编译            │
└─────────────────────────────────────────────┘
        │
        ▼
   Constrained Decoding（非法 token 被屏蔽）
        │
        ├──► JSON 响应（schema 合规）
        └──► strict tool use（参数合规）
        │
        ▼
   客户端：检查 stop_reason
     end_turn   → 直接 json.loads() ✅
     max_tokens → 截断，需调大重试 ⚠️
     refusal    → 模型拒绝，非 schema 问题 ⚠️
```

## 实用评估

### 什么场景值得用

- **票据 / 合同 / 临床记录 / 财报抽取**：blog 列出的典型场景。这类任务的特点是「字段固定、下游强依赖类型」，任何一次 `json.loads()` 失败都会打断流水线。确定性地省掉重试层，收益立竿见影。
- **分类与路由**：用 `enum` 把输出限定在有限标签集（如 `billing | technical | account | sales | other`，优先级 `low/medium/high/urgent`，情感 `positive/neutral/negative`）。这比「告诉模型只能输出这四个词」稳得多。
- **Agent 多步工作流**：`strict: true` 让工具参数在**生成时**就合规，「malformed input 导致步骤失败」这一类经典故障被消掉。对 Bedrock Mantle 上带服务端工具（web search、code interpreter）的编排尤其相关。
- **批量离线任务**：支持 batch inference，可以把大批抽取任务异步跑，同时拿到的仍是 schema 合规输出。

### 什么场景不值得用

- **依赖不支持特性的 schema**：**递归 schema、外部 `$ref`、`minimum`/`maximum`/`multipleOf`、`minLength`/`maxLength`** —— blog 写得很直白：这些关键字「API 接受，但生成期不强制」，请求会成功返回，但模型仍可能违反。你**必须在应用层自己校验**。这是个容易踩的坑：看起来"上了结构化输出"，实际上那部分约束是空气。
- **schema 频繁结构性变化的场景**：每次结构改动都让 24h 缓存失效，触发重新编译，首请求延迟上升。如果你的 schema 是动态生成的（比如按用户数据模型拼），缓存命中率会很差。
- **极短、极简单的输出**：如果只是要一个数字或一个布尔值，自己解析的成本本来就低，引入 schema 反而是负担（而且 schema 本身会占用 Converse API 的 payload 体积）。
- **平台依赖风险**：这是 Bedrock 的托管能力，绑定 AWS 账号与区域模型可用性。想跨云/自托管保持一致行为的团队要评估锁定成本。

### 迁移成本

- **改动点非常集中**：Anthropic 原生请求体里把 schema 放进 `output_config.format`（**注意是 JSON 对象，不是 JSON 字符串**）；工具调用则加一个 `"strict": True` + `"additionalProperties": False`。
- **可以渐进迁移**：先给一两个高风险接口加 schema，把原来的 retry/repair 逻辑保留作为兜底（因为 refusal 和 max_tokens 截断仍可能发生），确认稳定后再逐层拆除。
- **需要补的工程细节**：① 所有 object 补 `additionalProperties: false`；② 每个响应检查 `stop_reason`；③ 有 `max_tokens` 风险的接口调大上限；④ schema 设计「先最小可用，再逐步加复杂度」（basic schema 编译更快、更好 debug、payload 更小）。
- 粗估工作量：**单接口 0.5–1 人日**（改请求体 + 补 stop_reason 处理 + 跑真实数据回归）；如果原本有厚厚的 JSON repair 层，删代码的时间可能比写代码还多。

## 对你的意义

对 Ken 的两条线，这件事的意义不太一样：

- **AI 应用线（Agent + UI）**：这是**直接可用的工程杠杆**。你手上的 RAG / Agent 流水线里，凡是有「LLM 输出 → 解析 → 入库 / 调工具」的环节，都是这次更新的受益者。尤其值得先拿**分类路由**和**工具参数**两个点开刀——这两处投入最小、失败代价最高。另外，blog 里那句「首次编译慢 + 24h 缓存」建议直接写进你的 benchmark：如果你的 Agent 每次用不同 schema，延迟表现会和文档里的漂亮数字差很远。
- **VLA / 研究线**：结构化约束这一套（constrained decoding / grammar 缓存）本身是**推理工程范式**，和你关心的「世界模型 + VLA 输出动作序列」有结构相似性——动作也可以是受约束的 token 序列。可以留意后续有没有把 schema 约束用到**结构化动作空间**上的工作。
- **建议**：**立即试用（限定范围）**。选一个非关键但高频的抽取接口做 2 天灰度，把「JSON 解析失败率」「重试次数」「输出 token 成本」三个指标前后对比。如果三项都改善，再推广。不需要大迁移，风险可控。

## 关键代码/配置片段

**1）JSON Schema 结构化输出（bedrock-runtime / InvokeModel）** —— 注意 schema 是对象，放在 `output_config.format`：

```python
import boto3
import json

REGION = "us-east-1"
bedrock_runtime = boto3.client(service_name="bedrock-runtime", region_name=REGION)

schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string", "description": "Customer name"},
        "email": {"type": "string", "description": "Customer email address"},
        "plan_interest": {"type": "string", "description": "Product plan of interest"},
        "demo_requested": {"type": "boolean", "description": "Whether a demo was requested"}
    },
    "required": ["name", "email", "plan_interest", "demo_requested"],
    "additionalProperties": False
}

response = bedrock_runtime.invoke_model(
    modelId="global.anthropic.claude-sonnet-5-5",
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 512,
        "messages": [
            {"role": "user", "content": (
                "Paulo Santos (paulo@example.com) is interested in our Enterprise plan "
                "and wants to schedule a demo for next Tuesday at 2pm."
            )}
        ],
        "output_config": {"format": {"type": "json_schema", "schema": schema}}
    })
)

body = json.loads(response["body"].read())

# 关键：先看 stop_reason 再解析
if body["stop_reason"] == "end_turn":
    result_text = next(b["text"] for b in body["content"] if b["type"] == "text")
    print(json.dumps(json.loads(result_text), indent=2))
elif body["stop_reason"] == "max_tokens":
    print("Response truncated: increase max_tokens and retry.")
```

**2）Strict tool use（bedrock-mantle / Messages API）** —— 加 `strict: True` + `additionalProperties: false`：

```python
from anthropic import AnthropicBedrockMantle

client = AnthropicBedrockMantle(aws_region="us-east-1")

message = client.messages.create(
    model="anthropic.claude-sonnet-5",
    max_tokens=512,
    messages=[{"role": "user", "content": "What's the weather like in San Francisco?"}],
    tools=[
        {
            "name": "get_weather",
            "description": "Get the current weather for a specified location",
            "strict": True,
            "input_schema": {
                "type": "object",
                "properties": {
                    "location": {"type": "string", "description": "The city and state, e.g., San Francisco, CA"},
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"], "description": "Temperature unit"}
                },
                "required": ["location", "unit"],
                "additionalProperties": False
            }
        }
    ]
)

for block in message.content:
    if block.type == "tool_use":
        print(f"Tool: {block.name}")
        print(f"Input: {json.dumps(block.input, indent=2)}")
```

**3）需要自己兜底的部分（官方明确列出）**：

```text
支持的 JSON Schema 特性（子集）：
  - 基础类型: object / array / string / integer / number / boolean / null
  - enum（仅 string / number / boolean / null）
  - const, anyOf, allOf（有局限）
  - `ref, `def, definitions（仅内部引用）
  - string formats: date-time, time, date, duration, email, hostname, uri, ipv4, ipv6, uuid
  - array minItems（仅支持 0 和 1）

不支持的（会被接受但不强制！必须应用层校验）：
  - 递归 schema
  - 外部 $ref
  - minimum / maximum / multipleOf
  - minLength / maxLength
  - additionalProperties 设为 false 以外的任何值
```

> TODO: 官方未公布结构化输出相对「prompt + 重试」的端到端延迟/成本量化 benchmark；「首请求编译慢」的具体毫秒级开销需实测。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 严格工具参数 schema 校验是 MCP 工具协议落地的关键前置能力——当参数合规由推理端保证，工具集成的可靠性瓶颈就从「模型」转移到「schema 设计」，这类基础设施完善会反过来加速工具集成的标准化。 |

---
[← Back to Deep Dives](./README.md)
