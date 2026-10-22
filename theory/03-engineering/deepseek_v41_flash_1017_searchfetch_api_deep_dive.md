---
auto_generated: true
generated_at: "2026-10-22T05:45:50Z"
source_url: "https://api-docs.deepseek.com/news/news261017/"
signal_type: "significant_update"
---
# DeepSeek-V4.1-Flash-1017：帕累托改进 + 搜索/抓取 API 对外计费 (DeepSeek-V4.1-Flash-1017: Pareto Upgrade and Search/Fetch APIs Go Public)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-22
>
> **项目/工具**: DeepSeek-V4.1-Flash-1017
> **链接**: https://api-docs.deepseek.com/news/news261017/
> **核心定位**: 同价位模型的能力升级（官方称「性能与成本的帕累托改进」），同时把自建搜索引擎包装成按次计费的 Search / Fetch 工具 API，向所有开发者开放。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：DeepSeek 把 Flash 档模型更新到 1017 版本，并把「搜索 + 网页抓取」变成可直接调用、按成功请求计费的原子 API——agent 的检索层第一次可以从模型供应商手里单独买。
- **现在值得用吗**：看场景。做 RAG / agent 检索、且想少维护一套爬虫与搜索索引的团队值得立刻评估；只是单纯做对话生成的，升级模型即可，Search/Fetch 可以先放着。
- **适合场景**：需要即时网页证据的 agent、内部「搜索即工具」的工具链、成本敏感的高并发检索。
- **不适合场景**：对抓取内容合规有强要求、需要完整浏览器渲染、或不能接受单一供应商锁定检索层的场景（详见下文）。
- **与前版/竞品核心差异**：以前检索层要自己拼（搜索引擎 API + 抓取 + 解析 + 重排），现在变成 `POST /v1/tools/search` 和 `POST /v1/tools/fetch` 两个端点，且 DeepSeek 自带检索内核与 rerank/authority 打分。

## 是什么 / 解决什么问题

DeepSeek-V4.1-Flash-1017 是 Flash 档模型的一次版本更新。官方博客对新模型的描述非常克制：「Stronger benchmark performance, faster task completion, and shorter outputs than the previous version—a Pareto improvement in performance and cost.」即基准表现更强、任务完成更快、输出更短，同时价格不变——这是「帕累托改进」这个词的实际含义，**并不是**说它比 Pro 档更强。

注意官方**没有给出具体 benchmark 数字**，只在页面上放了一张 DeepSWE v1.1 Pass@1 vs. 每题成本的散点图（mini-swe-v2 harness 测）。本文不编造数值——需要精确对比的读者请直接看原页面图表。

真正的结构性变化来自后半段：**Search API 和 Fetch API 向所有开发者开放**。这两个端点此前只作为 DeepSeek Harness / Claude Code / Codex 中的 server-side tool 存在（也就是模型在 agent loop 内部隐式调用）。现在它们既是「模型内部的工具」，也是「你可以直接调的 HTTP API」。

这解决了什么痛点？过去构建一个能上网的 agent，检索层通常是拼装出来的：

- 搜索引擎 API（各家格式不一，部分不对外开放）
- 抓取 + 正文抽取（readability、trafilatura 之类的本地库，遇到反爬就崩）
- 重排 / 权威度打分（自己写规则，或者再挂一个 rerank 模型）
- 结果裁剪（token 预算控制）

DeepSeek 把这几步压成了两个端点，并且在返回值里直接带了 `rerank_score`（0–3 的相关性/权威性/新鲜度综合分）和 `authority`（0–4 权威层级）。这对 agent 工程是实质性的简化：**相关性判断从「你的 prompt」转移到「API 的结构化字段」**。

## 技术架构拆解

### 核心设计决策

- **原子化而非捆绑**：Search 和 Fetch 是两个独立计费的端点，不强制你走完整的 agent loop。你可以只用 Fetch 抓 20 个已选 URL，也可以只用 Search 拿标题和摘要。
- **计费锚定「成功请求」而非 token 或返回条数**：官方明确写「billed per successful request, not by tokens or by the number of returned results」，且 `count` 不影响单价；失败请求、空结果、超时不计费。这对成本可预测性非常有利——你可以按 1000 次呼叫 $0.75 做预算，不必担心一次大搜索把账单打爆。
- **Search 与 Fetch 独立限流**：账号级 QPS，Search 100 / Fetch 25，两者配额互不占用。Fetch 额外还有 per-domain QPS 限制——这实际上是在替供应商层面做「别把某个站抓死」的保护。
- **本地化参数用 IP 而非国家码**：`localization` 字段接收一个 IP 地址用于本地化搜索结果。这是一个略显少见但工程上更直接的设计（比起 `country=CN`，IP 能表达更细的地理粒度），同时也意味着调用方需要自己决定「以谁的身份看世界」。
- **搜索语法原样透传**：支持 `site:` / `-site:` / `"..."` / `-` / `lang:zh,en` / `after:` / `before:` 运算符，且强调「query is forwarded with its search syntax intact」。这让 agent 可以自行构造精确查询，而不是被 API 塞进固定的检索模板。
- **代理式优化前置**：官方提示「Optimized for DeepSeek Harness, Tencent CodeBuddy, WorkBuddy, and more」，并要求 Harness 升级到 v0.2.1-rc.1 以上。说明模型的能力提升与自家 agent 框架的提示/工具协议是配套调优的。

### 与前版/竞品的关键差异

| 维度 | 之前（自建检索层） | 现在（DeepSeek Search/Fetch API） |
|------|------------------|--------------------------------|
| 接口形态 | 搜索 API + 抓取库 + 解析 + rerank 多段拼装 | 两个 POST 端点，返回即结构化 |
| 相关性信号 | 自己写规则或再挂 rerank 模型 | `rerank_score` (0–3，≥1.5 视为高质量) |
| 权威度 | 无统一字段，靠人工维护白名单 | `authority` (0–4，≥3 视为高权威) |
| 计费单位 | token / 搜索次数 / 自有服务器成本混合 | 每 1000 次成功请求 $0.75（Search、Fetch 同价） |
| 失败成本 | 抓取失败也烧代理 IP 和 CPU | HTTP 200 且产出结果才计费 |
| 限流 | 取决于上游供应商 | Search 100 QPS / Fetch 25 QPS，账号级独立 |
| 输出格式 | HTML / 需自己做正文抽取 | Fetch 直接返回 Markdown |

### 架构/信息流图

```
用户 query
    │
    ├─► POST /v1/tools/search
    │       query / count(1-50) / ori_question / localization(IP) / need_content
    │                       │
    │                       ▼
    │        results[]: rerank_score, title, url, snippet,
    │                   summary(600-800字), content, site_name,
    │                   date(RFC3339), authority
    │                       │
    │         （agent 依据 rerank_score / authority 过滤）
    │                       ▼
    └─► POST /v1/tools/fetch   { "url": "..." }
                │
                ▼
        { "title": "...", "content": "# ... Markdown" }
                │
                ▼
        注入模型上下文 → 生成 / 决策

计费：仅 200 + 有效结果计入；Search $0.75/1k，Fetch $0.75/1k
限流：Search 100 QPS，Fetch 25 QPS（+ per-domain QPS）
```

## 实用评估

### 什么场景值得用

- **需要即时网页证据的 agent**：Fetch 直接返回 Markdown，省掉正文抽取环节；对大模型来说 Markdown 是比 HTML 干净得多的上下文。
- **成本敏感的高并发检索**：按成功请求计费 + 失败不计费，比「按 token 付费的 rerank 模型」更容易做预算上限。
- **重检索型 RAG**：`need_content: true` 让 Search 一次调用同时拿到摘要和正文，少一次往返。
- **工具调用型 agent（MCP 风格）**：Search/Fetch 是天然的工具定义，schema 简单、错误码清晰（400/401/402/403/404/408/413/429/500/504）。

### 什么场景不值得用

- **需要 JS 渲染的页面**：Fetch 明确说「Fetching is subject to the target site's availability and access policies」，且 404 覆盖了「unsupported content type」和「no extractable Markdown content」。纯前端渲染的站点大概率抓不到可解析正文。
- **不能接受检索层单点依赖**：搜索内核是 DeepSeek 自建（官方称「serving hundreds of millions of requests daily worldwide」），但外部无法审计其索引覆盖与排序偏好。做严肃研究型检索的团队仍需要交叉验证。
- **对抓取合规有强要求**：403 表示「rejected by the security policy」，但具体策略未公开；企业合规审查时这会是一个需要填的空白。
- **超大批量抓取**：Fetch per-domain QPS 限制意味着「把某个站全站抓一遍」这类用法会被 429。
- **只做生成、不需要实时信息**：那这次只需要升级模型，不为 Search/Fetch 付钱。

### 迁移成本

- **模型升级**：改 model 名即可；但官方要求 Harness 升到 v0.2.1-rc.1+ 才能拿到「最佳体验」。其他 agent 框架（CodeBuddy、WorkBuddy）同样需要对应版本。
- **检索层替换**：如果原来用第三方搜索 API，需要重写三块——查询构造（可利用 `site:`/`after:` 等运算符）、结果过滤（改用 rerank_score / authority 双阈值）、错误处理（402 代表余额不足，429 区分 QPS 与 per-domain）。
- **成本模型**：把「搜索次数 × 单价」替换成「成功请求数 × $0.75/1k」，并且要预留 429 重试的余量。
- **计费窗口**：通过 DeepSeek Harness、Claude Code、Codex 走的 server-side tool 调用**目前免费**，按官方说明计费从 **2026-10-31 16:00 UTC**（北京时间 11 月 1 日 00:00）开始。这意味着现在正是压测和基线采集的最佳窗口——免费额度会给到你真实的使用曲线。

## 对你的意义

对做 Agent + UI 的工程线来说，这次更新的价值不在模型本身，而在**检索层终于可以被当成一个可插拔组件来设计**。

具体建议：**立即试用，但先只做一件事**——在免费窗口内（10/31 16:00 UTC 之前）用你的 agent 跑一遍现有的检索需求，记录三件事：每次任务实际需要多少次 Search、多少次 Fetch、以及 `rerank_score ≥ 1.5` 的命中率。这三个数字决定计费上线后你的成本基线。如果命中率低于 50%，说明还需要在 prompt 里加过滤策略，现在改比之后改便宜。

对于多模态/机器人方向的 VLA 线，Fetch API 返回 Markdown 这一点值得一提：论文页面、GitHub README、项目文档这类内容抓取的质量通常比自建 trafilatura 流水线更稳，可以作为一个低成本的文献入口补充。但注意它不带浏览器渲染，需要 JS 的论文站点（含部分会议官网）可能抓不到正文，仍需要本地兜底。

另外值得留意的是「短输出」这个说法。官方把「shorter outputs」列为升级点之一——对 agent 来说这既是成本利好（输出 token 下降），也可能是风险（信息密度提高的同时，细节省略的概率上升）。这需要实测确认，不要在未验证的情况下把长文档生成任务直接迁过来。

## 关键代码/配置片段

Search 调用（Python，摘自官方指南）：

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

Fetch 调用（curl，摘自官方指南）：

```bash
curl https://api.deepseek.com/v1/tools/fetch \
  -H "Authorization: Bearer <DeepSeek API Key>" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/article"
  }'
```

带运算符的检索式示例（摘自官方指南）：

```json
{
  "query": "DeepSeek site:github.com OR site:huggingface.co lang:en after:2025",
  "count": 10
}
```

计费与限流速查：

| 项目 | 数值 |
|------|------|
| Search 单价 | $0.75 / 1,000 次成功请求 |
| Fetch 单价 | $0.75 / 1,000 次成功请求 |
| Search QPS | 100（账号级） |
| Fetch QPS | 25（账号级）+ per-domain 限制 |
| 计费判定 | HTTP 200 且产出有效结果（Search 非空数组 / Fetch 有正文） |
| 免费截止 | server-side tool 调用免费至 2026-10-31 16:00 UTC |

> TODO: 官方博客未公开 V4.1-Flash-1017 的具体 benchmark 数值、参数规模与上下文长度，需从 Hugging Face 模型卡补充。

---
[← Back to Deep Dives](./README.md)
