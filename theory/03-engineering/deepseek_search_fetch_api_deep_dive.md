---
auto_generated: true
generated_at: "2026-10-23T12:41:33Z"
source_url: "https://api-docs.deepseek.com/guides/search/"
signal_type: "significant_update"
---
# DeepSeek 开放自研搜索 Search & Fetch API：把「联网」做成可计费的独立基础设施 (DeepSeek Opens In-House Search & Fetch APIs)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-23
>
> **项目/工具**: DeepSeek Search API / Fetch API
> **链接**: https://api-docs.deepseek.com/guides/search/
> **核心定位**: 把「搜索网页」和「抓取正文」从模型能力中拆出来，做成两个按请求计费、与主 API 共用 Bearer token 的裸 JSON 接口——agent 与 RAG 应用不必再自建爬虫 + 抽取层。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：DeepSeek 首次对外开放自研搜索引擎，新增 `POST /v1/tools/search`（返回结构化结果 + 可选正文）与 `POST /v1/tools/fetch`（URL 直出 Markdown），两个接口均为只读、按成功请求计费。
- **現在值得用嗎**：看場景——如果你已经在用 DeepSeek 主 API，它是零集成成本的联网层；如果你对搜索质量或数据合规有硬要求，建议先做 A/B 对比再决定。
- **適合場景**：agent 的「查资料」工具、RAG 的 ingestion 前置抽取、给模型注入实时网页上下文。
- **不適合場景**：需要站内搜索 / 垂直数据库 / 高频抓取（Fetch 仅 25 QPS）；需要自定义爬取深度与并发策略的规模化采集。
- **與 Tavily / Exa / Bing Grounding 核心差異**：计费单位是「请求」而非 token 或结果数，Search $0.75/千次、Fetch $0.75/千次，且与 LLM 共用同一把 API key 和同一份余额。

## 是什么 / 解决什么问题

任何做过 agent 或 RAG 的人都会撞上同一堵墙：模型本身不会上网。网页搜索、正文抽取、去广告、去导航栏、把 HTML 洗成模型可读的纯文本——这些都是和「调模型」完全不同的工程活，却又是让模型有实时性所必需的。

过去两年，团队通常有三种解法：接第三方搜索 API（Tavily、Exa、Bing Web Search），自己写 requests + readability + trafilatura 的爬虫管道，或者依赖模型厂商的「内置联网」（如某些对话产品的 web search tool）。三种都有代价——前两种要额外采购、额外鉴权、额外运维；第三种通常不开放成稳定 API，无法进入生产 agent 的工具链。

DeepSeek 这次的做法规整得多：把能力拆成两个最小原语（Search、Fetch），用裸 JSON 暴露，鉴权直接复用 DeepSeek 主 API 的 Bearer key，计费进入同一个账户余额。这意味着对已接入 DeepSeek 的团队来说，「让 agent 上网」从「集成一个第三方供应商」变成「加两个 POST」。

另一个不那么显眼但重要的点：**Fetch 直接返回 Markdown**。内容被抽取成 `# 标题\n\n正文` 形式，省掉了 HTML→文本的清洗环节。这正好是 agent 上下文最想要的格式。

## 技术架构拆解

### 核心设计决策

- **拆成 Search / Fetch 两个原语，而不是一个「联网 agent 接口」**。Search 负责发现，Fetch 负责精读，两者可以独立调用、独立计费、独立限流。这是把控制权交还给调用方的做法——你决定搜几次、读几页，而不是让厂商的黑盒 agent 替你决定。
- **鉴权与主 API 共用 Bearer**。请求头就是 `Authorization: Bearer <DeepSeek API Key>` + `Content-Type: application/json`，无独立申请、无独立开通流程。
- **Search 返回双层摘要**。每条结果同时给 `snippet`（100–200 字符，供 UI 展示）和 `summary`（600–800 字符，供模型阅读）。这是明确承认了「人看」和「模型看」需要不同粒度。
- **两个质量信号显式暴露**：`rerank_score`（0–3，综合相关性 / 权威性 / 时效性，≥1.5 视为高质量）与 `authority`（0–4 权威等级，≥3 为高权威来源，-1 未知）。调用方可以据此做过滤与阈值策略，而不是只拿到一个 URL 列表。
- **支持完整搜索运算符**：`site:` / `-site:` / `-"精确短语"` / `lang:` / `after:` / `before:` / 排除词。查询语法被原样透传给搜索引擎，不做改写。
- **`ori_question` 字段**用于提升查询理解：把一个 1–128 字符的原始用户问题一起传，让引擎在改写 query 时有更多上下文。
- **`localization` 接受 IP 地址**用于地域化结果。
- **失败不计费**。只有 HTTP 200 且产生实际结果（Search 非空数组、Fetch 有正文）才计费；空结果、超时、4xx/5xx 都不收钱。
- **对 Harness / Claude Code / Codex 中的服务端工具调用，目前免费，2026-11-01 北京时间 00:00 起开始按请求计费**。这是一条明确的价格预告，做成本估算时必须算进去。

### 与前版/竞品的关键差异

| 维度 | 典型第三方搜索 API（Tavily / Exa / Bing） | DeepSeek Search & Fetch |
|------|------------------------------------------|-------------------------|
| 鉴权 | 独立供应商账号 + 独立 key | 复用 DeepSeek 主 API key |
| 计费单位 | 多为按请求或按 credit | 严格按成功请求，$0.75/千次 |
| 结果数计费 | 常随 count 变化 | `count` 不影响单价（1–50 同价） |
| 正文返回 | 通常需二次调用 extract | `need_content: true` 一次拿回正文 |
| 正文格式 | 多为纯文本 / HTML 片段 | Fetch 直接返回 Markdown |
| 质量信号 | 部分提供 score | 显式给 `rerank_score` + `authority` 双信号 |
| 搜索运算符 | 支持程度不一 | `site:` `-site:` `lang:` `after:` `before:` 等全开 |
| Fetch QPS | 视套餐 | 25 QPS（按账户，另有按域名限流） |
| Search QPS | 视套餐 | 100 QPS（按账户） |
| 生态锁定 | 独立供应商 | 与 DeepSeek 模型生态绑定 |

### 架构/信息流图

```
┌──────────────┐
│ 用户问题      │
└──────┬───────┘
       │ query + ori_question + 运算符
       ▼
┌──────────────────────────────────────┐
│ POST /v1/tools/search                │
│  count (1-50) / need_content / loc.  │
│  powered by DeepSeek 自研搜索引擎     │
└──────┬───────────────────────────────┘
       │ results[]:
       │  title, url, snippet, summary, content,
       │  rerank_score(0-3), authority(0-4), date
       ▼
   ┌───────────────┬──────────────────┐
   │ 直接喂给模型   │ 需要更完整正文时   │
   │ (summary 600+)│                  │
   └───────────────┴────────┬─────────┘
                            ▼
              ┌──────────────────────────────┐
              │ POST /v1/tools/fetch         │
              │  { url } → { title, content }│
              │  content 为 Markdown          │
              └──────────────┬───────────────┘
                             ▼
                 ┌───────────────────────┐
                 │ Agent 上下文 / RAG 索引 │
                 └───────────────────────┘
```

关键点：Search 与 Fetch 是**两条独立路径**，不构成强制流水线。你可以只用 Search 拿 summary 拼上下文，也可以跳过 Search 直接对你已知的 URL 调 Fetch。

## 实用评估

### 什么场景值得用

- **已有 DeepSeek 主 API 的 agent 项目**。集成成本接近于零：同一个 key，两个 POST，返回就是标准 JSON。适合给现有 agent 补上「查资料」工具。
- **RAG 的 ingestion 前置**。Fetch 返回 Markdown，正好可以直接切块入向量库，省掉 HTML 清洗管道。对定期抓取固定信息源（文档站、博客）特别顺手。
- **需要可控联网行为的 agent**。因为 Search 和 Fetch 是分开的，你可以精确控制「搜几次、读几页」，成本可预测且线性——这对生产环境比黑盒联网 agent 更友好。
- **需要质量信号的检索管线**。`rerank_score` 和 `authority` 可以直接做阈值过滤，比如「authority ≥ 3 且 rerank_score ≥ 1.5 才进上下文」，减少低质来源污染。

### 什么场景不值得用

- **规模化网页采集**。Fetch 只有 25 QPS（且还有按域名的二级限流），Search 100 QPS。这不是爬虫基础设施，是给在线请求用的。
- **需要登录 / 反爬绕过 / JS 渲染的页面**。Fetch 「受目标站点可用性与访问策略约束」，403 表示被安全策略拒绝，404 涵盖「不支持的内容类型」和「无可提取 Markdown 内容」。动态渲染页面大概率拿不到东西。这一点文档没有明说，属于**待验证**。
- **对搜索结果覆盖度有硬性要求的知识库构建**。自研搜索引擎的索引规模未公开，是否覆盖长尾站点、非英语站群，**TODO: 官方未披露索引规模与覆盖面**，建议先做小规模对比。
- **强合规场景**。搜索结果与网页内容经 DeepSeek 服务器中转，如涉及数据出境或受监管行业的检索内容，需先确认合规边界。
- **成本敏感的高频调用**。$0.75/千次看似便宜，但 agent 一次任务若触发 20 次搜索 + 30 次 fetch = 50 次请求，单任务成本约 $0.04；规模化后需核算。另外 2026-11-01 起 Harness / Claude Code / Codex 的服务端工具调用开始收费，这部分成本会显性地落在使用者身上。

### 迁移成本

- **从自建爬虫迁移**：中等。逻辑上只是把 `requests + readability` 换成一次 Fetch 调用，但需要处理错误码映射（403/404 需要降级策略）、限流退避（429 需等待重试）、以及 Markdown 输出的分块策略。估计半天到一天。
- **从 Tavily / Exa 迁移**：低。字段结构高度相似（title / url / snippet / content），主要改动是鉴权与环境变量，估计 1–2 小时。
- **从内置搜索（如 Claude Code 的 WebSearch）迁移**：需评估。内置搜索的调用模式是模型自主决定，迁移到显式工具需要把工具定义写进 prompt 并加上结果格式化，改动主要在 agent 编排层。

## 对你的意义

对你的 Agent-Playbook 方向，这个更新的真正价值不在「又多了一个搜索 API」，而在于两点：

**第一，它是「工具原语化」的一个清晰样本。** 把能力拆成 Search 与 Fetch 两个只读、幂等、可独立计费的接口，比「网关联网」的黑盒设计更适合 agent 编排。这个设计取舍值得写进 agent 设计模式里——你可以对比 Tavily 的单接口与 DeepSeek 的双原语，讨论「发现」与「精读」分离对上下文预算控制的意义。

**第二，它对你的 Deep Dive 采集管线有直接可用性。** 你现在用的是 `web_fetch`（readability 抽取）。如果 DeepSeek Fetch 的 Markdown 质量相当，理论上可以把「抓正文」这一步迁到统一鉴权和统一计费的路径上，简化脚本里的重试与清洗逻辑。但注意 25 QPS 和 403/404 的错误语义，需要先写一层降级。

**建议**：立即做 30 分钟的小实验——用 10 个你熟悉的 URL（含 GitHub release、HuggingFace model card、技术博客、含大量 JS 的页面）跑一次 Fetch，对比返回的 Markdown 质量与当前 `web_fetch` 的差异。这个对比数据比任何评测都准。至于生产接入，等 11 月 1 日计费正式生效后再算总账。

## 关键代码/配置片段

Search 请求（官方文档示例）：

```bash
curl https://api.deepseek.com/v1/tools/search \
  -H "Authorization: Bearer <DeepSeek API Key>" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "DeepSeek V4 release",
    "count": 5,
    "need_content": true
  }'
```

Python 调用并读取结果：

```python
import requests

response = requests.post(
    "https://api.deepseek.com/v1/tools/search",
    headers={
        "Authorization": "Bearer <DeepSeek API Key>",
    },
    json={
        "query": "DeepSeek V4 release",
        "count": 5,
        "need_content": True,
    },
)
response.raise_for_status()

for result in response.json()["results"]:
    print(result["title"], result["url"])
    print(result["summary"])
```

带运算符的查询示例（官方给出）：

```json
{
  "query": "DeepSeek site:github.com OR site:huggingface.co lang:en after:2025",
  "count": 10
}
```

Fetch 调用：

```bash
curl https://api.deepseek.com/v1/tools/fetch \
  -H "Authorization: Bearer <DeepSeek API Key>" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/article"
  }'
```

Fetch 响应结构：

```json
{
  "title": "Example article",
  "content": "# Example article\n\nArticle content."
}
```

计费与限流速查（官方文档）：

```
Search: $0.75 / 1,000 成功请求   QPS 100（账户级）
Fetch:  $0.75 / 1,000 成功请求   QPS 25 （账户级 + 每域名限流）
count (1-50) 不影响单价
失败 / 空结果 / 超时 不计费
Harness / Claude Code / Codex 服务端调用：当前免费，
2026-11-01 北京时间 00:00 起按请求计费
```

---
[← Back to Deep Dives](./README.md)
