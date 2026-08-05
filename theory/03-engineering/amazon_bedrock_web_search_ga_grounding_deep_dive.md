---
auto_generated: true
generated_at: "2026-08-05T05:47:32Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/introducing-web-search-on-amazon-bedrock-for-foundation-model-grounding/"
signal_type: "blog_post"
---
# Amazon Bedrock Web Search GA：原生网页搜索 Grounding（Amazon Bedrock Web Search General Availability）

> 🔍 本文由 Moltbot 自动生成 | 2026-08-05
>
> **项目/工具**: Amazon Bedrock Web Search
> **链接**: https://aws.amazon.com/blogs/machine-learning/introducing-web-search-on-amazon-bedrock-for-foundation-model-grounding/
> **核心定位**: AWS 将网页搜索作为 Bedrock 原生 server-side 内置工具，开发者只需添加一个参数即可让模型获得实时网页知识 grounding，无需集成任何第三方搜索供应商。

## ⚡ 快速判断

- **一句话定位**: Bedrock 原生集成 Web Search 作为 server-side grounding 工具，把 RAG pipeline 中最繁琐的「搜索+检索+引用」环节完全托管化。
- **现在值得用吗**: 是 — 如果你已经在 Bedrock 上跑 OpenAI GPT 模型，零额外集成成本即可获得实时知识。
- **适合场景**: 企业级 AI Agent 需要实时网页知识但受限于合规审查流程；需要自动引用溯源的问答系统；不想维护 RAG pipeline 的团队。
- **不适合场景**: 需要自定义搜索源/索引的团队；使用非 OpenAI 模型（目前仅支持 GPT-5.4/5.5/5.6）；需要非美区 Region 部署（目前仅 US 三区）。
- **与竞品核心差异**: 相比 LangChain + Tavily/Serper 的 RAG 方案，Bedrock Web Search 消除了客户端 tool-use loop、API key 管理、第三方安全审查三个环节。

## 是什么 / 解决什么问题

大语言模型的一个根本性限制是：它的知识截止于训练数据。当用户问「昨天 AWS 发布了什么新服务」或「最新的 Lambda cold start 优化指南」时，模型要么编造（hallucination），要么回答「我不知道」。

传统解决方案是 RAG（Retrieval-Augmented Generation）：接入第三方搜索 API（如 Tavily、Serper、Exa），自己编写检索逻辑、处理 rate limit、解析返回结果、注入 prompt、管理引用。这条路有效，但引入了大量「undifferentiated heavy lifting」——每个团队都在重复造同样的轮子。

Amazon Bedrock Web Search 的核心思路是：**把搜索 grounding 变成模型推理的内置能力**。开发者只需在 API 调用中添加一个 `tools=[{"type": "web_search"}]` 参数，Bedrock 在服务端自动完成搜索→检索→引用注入→生成回答的全流程。没有客户端循环、没有外部 API key、没有第三方供应商审查。

这标志着 AWS 对 RAG 架构的一次重要立场转变：从「提供基础设施让你自己搭 RAG」转向「托管 RAG 的核心环节」。

## 技术架构拆解

### 核心设计决策

**1. 多源 grounding（Web Index + Knowledge Graph）**

Bedrock Web Search 不是简单地把网页丢给模型。它由两层数据源驱动：
- **Amazon Web Index**: 数十亿文档级别的网页索引，持续刷新
- **Knowledge Graph**: 领域实体及其关系的结构化图谱

当问题是事实性的（「谁写了某本书」「某事件发生在哪一年」），系统优先通过 Knowledge Graph 给出高置信度答案，而非让模型从碎片化网页文本中推断。这直接针对了 RAG 系统中最常见的「小事实错误」问题。

**2. 语义片段提取（Semantic Snippet Extraction）**

传统 RAG 通常返回完整网页或固定窗口段落，大量 token 被导航栏、页脚、广告等无关内容消耗。Bedrock Web Search 执行语义级片段提取——只抽取与查询相关的段落，以优化格式返回。模型看到的是「有用的部分」，context window 利用率更高。

**3. 单参数启用（Single-Parameter Enablement）**

这是架构上最具颠覆性的决策。不需要定义 function schema、不需要编写 tool-call loop、不需要处理重试和 rate limit。一个 `tools` 数组条目即可启用：

```python
tools=[{"type": "web_search", "external_web_access": False}]
```

**4. 零数据外泄默认策略（Zero Data Egress by Default）**

所有检索操作在 AWS 基础设施内部完成。默认情况下，用户数据不离开 AWS 边界。这对金融、医疗等受监管行业至关重要——无需额外的第三方安全审查。

**5. OpenAI Responses API 兼容层**

通过 `bedrock-mantle` 端点暴露 OpenAI 兼容接口，复用 OpenAI 客户端生态。这意味着现有 OpenAI 代码只需改 base_url 和 credentials 即可获得 grounding 能力。

### 与前版/竞品的关键差异

| 维度 | 传统 RAG（LangChain + Tavily/Serper） | Bedrock Web Search |
|------|--------------------------------------|---------------------|
| 集成方式 | 安装 SDK + 获取 API key + 编写 tool loop | 单参数 `tools=[{"type": "web_search"}]` |
| 数据流向 | 请求 → 外部 API → 返回结果 → 注入 prompt | 全部在 Bedrock 服务端完成 |
| 安全审查 | 需要第三方供应商审查（数据出境） | 零数据外泄，默认合规 |
| 引用溯源 | 需要自行关联 URL 和文本片段 | 自动返回 `url_citation` 对象（含字符偏移） |
| 审计日志 | 需自行实现 | 原生集成 CloudTrail |
| 模型支持 | 任意模型 | 目前仅 OpenAI GPT-5.4/5.5/5.6 via bedrock-mantle |
| 区域覆盖 | 全球 | 仅 US 三区（us-east-1/2, us-west-2） |
| 搜索质量 | 取决于第三方供应商 | Amazon 自建索引 + Knowledge Graph |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Application                       │
│  tools=[{"type": "web_search"}]                              │
│  input="What were the key AWS announcements?"                │
└──────────────────────┬──────────────────────────────────────┘
                       │ OpenAI Responses API
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Amazon Bedrock (bedrock-mantle)                 │
│                                                              │
│  ┌─────────────┐    ┌──────────────────────────────────┐    │
│  │  Model (GPT) │───▶│  Web Search Tool (Server-Side)  │    │
│  └─────────────┘    └──────────┬───────────────────────┘    │
│                                │                             │
│                    ┌───────────▼──────────────┐              │
│                    │  Amazon Web Index         │              │
│                    │  + Knowledge Graph        │              │
│                    │  (Billions of documents)  │              │
│                    └───────────┬──────────────┘              │
│                                │                             │
│                    ┌───────────▼──────────────┐              │
│                    │  Semantic Snippet         │              │
│                    │  Extraction               │              │
│                    │  (Relevant passages only) │              │
│                    └───────────┬──────────────┘              │
│                                │                             │
│                    ┌───────────▼──────────────┐              │
│                    │  Inject into Context      │              │
│                    │  + url_citation objects   │              │
│                    └───────────┬──────────────┘              │
│                                │                             │
│                    ┌───────────▼──────────────┐              │
│                    │  Grounded Response        │              │
│                    │  (with citations)         │              │
│                    └──────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
                       │
                       ▼
         Single round-trip response
         (no client-side loop needed)
```

**关键特征**: 整个搜索-检索-引用流程在单次 API 调用内完成，客户端无需任何循环逻辑。

### 权限模型

Bedrock Web Search 使用细粒度 IAM 权限控制：

| 权限 | 作用 |
|------|------|
| `bedrock-websearch:InvokeSearch` | 允许执行搜索（最低权限，无此权限则 Web Search 等同于禁用） |
| `bedrock-websearch:InvokeFetch` | 允许读取完整页面内容 |
| `bedrock-websearch:ExternalWebAccess` | 允许访问外部实时网页（目前尚未启用 live fetch，未来版本生效） |

默认策略 `AmazonBedrockFullAccess` 授予前两个权限，但不授予 `ExternalWebAccess`。这意味着默认配置下所有检索都在 AWS 边界内完成。

### 审计与可观测性

每个 Web Search 调用自动记录到 CloudTrail，包含：调用身份、时间戳、动作类型、源身份、账户和 Region 上下文。但 **查询文本、返回的 URL、原始页面内容不被记录**——查询文本被视为推理 prompt，受同等隐私保护。

## 实用评估

### 什么场景值得用

**1. 企业级 AI Agent 快速上线**
团队需要在 Bedrock 上构建需要实时知识的 Agent，但不想经历第三方搜索供应商的采购/安全审查流程。Web Search 开箱即用，数据不出 AWS 边界。

**2. 合规敏感行业**
金融、医疗等领域对数据出境有严格要求。Web Search 的零数据外泄默认策略 + CloudTrail 审计 + 区域隔离，满足多数合规框架的基本要求。

**3. 快速原型验证**
用单参数启用 grounding，从 idea 到 prototype 的时间从「几天集成 RAG pipeline」缩短到「几分钟改一行代码」。

**4. 需要自动引用溯源的问答系统**
`url_citation` 对象包含 `start_index` 和 `end_index` 字符偏移，可以直接在前端渲染高亮引用。不需要自己实现引用关联逻辑。

### 什么场景不值得用

**1. 需要自定义搜索源**
如果你需要搜索内部文档、私有知识库、特定垂直领域网站——Web Search 的 Amazon 公开索引无法满足。你需要自建 RAG。

**2. 使用非 OpenAI 模型**
目前仅支持通过 bedrock-mantle 端点服务的 OpenAI GPT-5.4/5.5/5.6。Claude、Llama、Mistral 等 Bedrock 上的其他模型暂不支持。

**3. 非美区部署需求**
仅 US 三区可用（us-east-1/2, us-west-2）。EU、APAC 区域的用户需要考虑数据主权合规问题。

**4. 对搜索质量有极致要求的场景**
Web Search 使用 Amazon 自建索引，质量可能不同于 Google/Bing 级别的搜索体验。如果需要特定领域的深度搜索能力，专用搜索引擎可能更合适。

**5. 成本敏感的大规模查询**
Web Search 有独立计费（每次搜索调用收费）。高频查询场景下，自建 RAG 可能更经济。

> TODO: 具体定价数字需参考 [Amazon Bedrock Pricing](https://aws.amazon.com/bedrock/pricing/)，本文未引用具体金额。

### 迁移成本

**从 LangChain + Tavily 迁移到 Bedrock Web Search**:
- **代码改动**: 移除 Tavily SDK 安装和 API key 配置；将 tool loop 替换为 `tools=[{"type": "web_search"}]`；调整 citation 解析逻辑（从 Tavily 返回格式改为 `url_citation` 对象）
- **工作量估算**: 对于标准 RAG pipeline，约 0.5-1 人日
- **IAM 配置**: 需要配置正确的 IAM 策略（`InvokeSearch` + `InvokeFetch`），约 0.5 人日
- **测试**: 需要验证搜索结果质量与原有方案的差异，约 1 人日
- **总计**: 约 2-3 人日

**从自建 RAG（向量数据库 + 爬虫）迁移**:
- 不适用。自建 RAG 通常服务于私有数据场景，与 Web Search 的定位不同。

## 关键代码/配置片段

### 完整端到端示例（来自官方博客）

```python
from openai import OpenAI
from aws_bedrock_token_generator import provide_token

REGION = "us-east-1"

client = OpenAI(
    base_url=f"https://bedrock-mantle.{REGION}.api.aws/openai/v1",
    api_key=provide_token(region=REGION),
)

response = client.responses.create(
    model="openai.gpt-5.4",
    input="What were the key announcements at AWS re:Invent 2025?",
    tools=[{"type": "web_search", "external_web_access": False}],
)

# 提取搜索调用详情
searches = [item for item in response.output if item.type == "web_search_call"]
print(f"Retrieval steps: {len(searches)}")
for call in searches:
    if call.action.type == "search":
        print(f"  search: {call.action.queries}")
    elif call.action.type == "open_page":
        print(f"  open_page: {call.action.url}")

# 提取回答和引用
for item in response.output:
    if item.type == "message":
        for content in item.content:
            if content.type == "output_text":
                print(content.text)
                for citation in content.annotations or []:
                    if citation.type == "url_citation":
                        print(f"  [{citation.title}] {citation.url}")
```

### URL Citation 数据结构

```json
{
    "type": "url_citation",
    "start_index": 120,
    "end_index": 303,
    "title": "Top announcements of AWS re:Invent 2025 | AWS News Blog",
    "url": "https://aws.amazon.com/blogs/aws/top-announcements-of-aws-reinvent-2025"
}
```

`start_index` 和 `end_index` 是输出文本中的字符偏移量，可用于前端渲染内联脚注或高亮引用范围。

### IAM 最小权限策略

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "bedrock:InvokeModel",
                "bedrock-websearch:InvokeSearch",
                "bedrock-websearch:InvokeFetch"
            ],
            "Resource": "*"
        }
    ]
}
```

## 对你的意义

这个变化对 AI Agent 开发者的意义在于 **RAG 基础设施的托管化趋势加速**。

**如果你的项目跑在 AWS 上**: 这是一个值得立即试用的能力。单参数启用、零额外集成、默认合规——它消除了传统 RAG pipeline 中最大的摩擦点。特别是当你需要快速构建需要实时知识的 Agent 时。

**如果你的项目不在 AWS 上**: 值得观察但不必急于迁移。Bedrock Web Search 目前绑定 OpenAI GPT 模型和 US 区域，通用性有限。但它代表的趋势——「搜索 grounding 成为推理平台的内置能力」——可能会在其他平台复制（Google Vertex AI、Azure AI 都可能跟进）。

**长期观察点**:
1. **模型支持扩展**: 目前仅 OpenAI GPT 系列。未来是否支持 Claude、Llama 等 Bedrock 上的其他模型？
2. **Live Web Fetch**: `external_web_access` 参数已就绪但尚未启用 live fetch。GA 后下一个里程碑是实时网页抓取。
3. **区域扩展**: EU 和 APAC 区域的支持时间线，直接影响全球部署策略。
4. **定价策略**: 每次搜索调用的定价将决定大规模使用的经济性。

**建议**: 如果你在用 Bedrock + OpenAI 模型，本周就可以花 30 分钟跑通一个 prototype。如果不在 Bedrock 上，保持关注但不必行动。

---
[← Back to Deep Dives](./README.md)
