---
auto_generated: true
generated_at: "2026-10-05T03:30:49Z"
source_url: "https://vercel.com/changelog/ai-gateway-adds-browserbase-search-and-fetch-tools"
signal_type: "significant_update"
---
# AI Gateway 内置 Browserbase Search / Fetch：把「联网检索」抽象成跨模型可移植工具 (AI Gateway Adds Browserbase Search and Fetch Tools)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-05
>
> **项目/工具**: Vercel AI Gateway — Browserbase Search & Fetch tools
> **链接**: https://vercel.com/changelog/ai-gateway-adds-browserbase-search-and-fetch-tools
> **核心定位**: 在 AI Gateway 里给任意支持 tool calling 的模型接上「网页搜索 + 页面抓取」两个内置工具，用同一把 API Key 跨模型复用。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：AI Gateway 把 Browserbase 的 Search（找页面）和 Fetch（读页面）变成网关级工具；模型换供应商时工具定义不用重写。
- **現在值得用嗎**：看场景——如果你的 agent 需要在多家模型间切换又想要统一联网能力，值得；只锁死一家模型且已用其原生 web search 的，收益有限。
- **適合場景**：多模型路由/failover 的 agent、需要「先搜后读」两段式检索的检索流、想给不支持原生检索的模型补联网能力。
- **不適合場景**：需要 JS 渲染或交互式浏览的重页面（Fetch 是轻量、非浏览器会话方案）、调用量极大且对成本极敏感的场景。
- **與原生 Provider 检索核心差異**：Browserbase 工具与模型供应商解耦，`gateway.tools.*` 一把 Key 通用；Anthropic/OpenAI/Google 的原生检索更深度但绑定供应商。

## 是什么 / 解决什么问题

给一个 LLM 加「联网」这件事，长期存在两个痛点。

第一是**碎片化**：每家模型供应商都有一套自己的 web search 工具——Anthropic 的 `webSearch_20250305`、OpenAI 的 `webSearch`、Google 的 grounding、xAI 的 `webSearch`——定义、参数、计费各不相同。你一旦做多模型路由或 failover，就必须为每家各写一套工具定义，切换模型等于重写代码。

第二是**模型能力与检索能力的错配**：不少模型（尤其是小而便宜、本地部署的）本身没有原生检索能力，但你想用它们的推理去驱动联网任务时，只能自己搭一套搜索 API 的胶水层。

Vercel 这次的更新把 Browserbase 的 Search 与 Fetch 收进 AI Gateway 的内置工具（helpers）。官方的说法是：**"AI Gateway lets you use Browserbase's tools across model providers with one API key. Add web search and page retrieval to any model that supports tool calling, and keep the same tools when you switch models."** 翻译过来就是——用一把 AI Gateway API Key，就能给「任何支持 tool calling 的模型」补上搜索和抓取，而且换模型时工具保持不变。

这两个工具分工明确，直接对应 agent 检索的两步：

| 工具 | 作用 | 底层 |
|------|------|------|
| `browserbaseSearch` | 找页面——快速、结构化的 web discovery | Browserbase Search API，返回标题/URL/元数据，**不开启浏览器会话** |
| `browserbaseFetch` | 读页面——抓取模型已持有 URL 的内容 | Browserbase Fetch API，轻量，适合不需要 JS 执行/浏览器交互的页面 |

官方推荐的组合是：**先用 Search 找页面，再用 Fetch 读其中一个**。这正好是 agentic RAG 里最经典的「search → read」两段式。

## 技术架构拆解

### 核心设计决策

- **工具与模型供应商解耦**：`browserbaseSearch` / `browserbaseFetch` 可与任何模型使用，与模型供应商或创建者无关（"can be used with any model regardless of the model provider or creator"）。这正是解决碎片化的关键。
- **两个工具各司其职，避免「搜索即读取」的粗放**：Search 只返回标题、URL、元数据，不拉正文；Fetch 负责把指定 URL 变成 raw / markdown / json。这种拆分让 agent 能先低成本筛候选，再对少量 URL 做昂贵的抽取。
- **开发者默认值覆盖模型生成值**：网关会把你写在 `browserbaseSearch()` / `browserbaseFetch()` 里的选项当作 developer defaults，**覆盖模型自己生成的值**。这是成本与安全的护栏——你可以在代码里把 `format`、`proxies` 钉死，模型就无法擅自选择更贵的档位。
- **安全敏感参数只允许开发者设置**：`schema` 和 `allowInsecureSsl` 是 developer configuration only，**模型无法设置**，"a prompt-injected value is discarded before the fetch runs"。也就是说，即使页面里藏了注入指令想诱导 agent 传 `allowInsecureSsl: true`，也会在 fetch 前被丢弃。这是针对 prompt injection 的一个明确防护点。
- **按选项计费，成本可预测**：Search 固定 $7 / 1,000 次请求（不论请求多少结果）；Fetch 按选项叠加——见下表。

### 与前版/竞品的关键差异

| 维度 | 模型原生检索（Anthropic/OpenAI/Google） | AI Gateway + Browserbase |
|------|------------------------------------------|--------------------------|
| 绑定关系 | 绑定自家模型 | 与供应商解耦，任意 tool-calling 模型可用 |
| 换模型 | 工具定义需重写 | 工具保持不变，只换 model 字符串 |
| 找页面 | 各自实现，参数不统一 | `browserbaseSearch` 统一，`numResults` 1–25 |
| 读页面 | 通常没有独立「抓 URL」工具 | `browserbaseFetch` 独立，支持 raw/markdown/json |
| 结构化抽取 | 少见 | Fetch 支持按 JSON Schema 抽取为结构化 JSON |
| 安全护栏 | 各家不一 | 开发者默认值覆盖 + 注入参数丢弃 |
| 计费 | 随模型定价 | Search $7/1k；Fetch $1–$7/1k |

同属 AI Gateway 的「跨供应商搜索」家族里，Browserbase 之外还有 Perplexity、Exa、Tako、Parallel 可选，定位各有侧重（例如 Exa 偏内容抽取、Tako 偏实时财经/体育知识图谱、Parallel 偏 LLM 优化的研究摘录）。Browserbase 的差异点是**搜索 + 轻量抓取成对出现**，且抓取端能做 JSON Schema 抽取。

### 架构/信息流图

```
你的应用 (Node, AI SDK 7.0.116+)
        │  streamText({ model, tools: { browserbase_search, browserbase_fetch } })
        ▼
   Vercel AI Gateway  ── 一把 AI_GATEWAY_API_KEY / 或 BYOK
        │   1) 解析 tools，注入 developer defaults（覆盖模型生成值）
        │   2) 丢弃模型提供的敏感参数 (schema, allowInsecureSsl)
        ▼
   ┌──────────────┐        ┌──────────────┐
   │ Browserbase  │        │ Browserbase  │
   │ Search API   │        │ Fetch API    │
   │ 找页面        │        │ 读页面        │
   └──────────────┘        └──────────────┘
        │                        │
        └──────────┬─────────────┘
                   ▼
        结果并入模型上下文 → 模型给出最终回答
        （成本与调用次数回报在 gateway usage metadata）
```

## 实用评估

### 什么场景值得用

- **多模型路由 / failover 的 agent**：这是最直接受益的场景。工具定义一次写好，模型从 A 换到 B，联网能力不用动。官方原话就是 "keep the same tools when you switch models"。
- **需要补联网能力的「弱模型」**：一些模型没有原生 web search，但只要支持 tool calling，就能通过网关接上 Browserbase 的检索。
- **两段式 agentic 检索**：Search 筛候选（廉价、只回元数据）→ Fetch 精读少量 URL。比「搜索直接把全文塞进上下文」更省 token、更可控。
- **需要结构化抽取的流水线**：Fetch 的 `format: 'json'` + `schema` 能把页面抽成按 JSON Schema 定义的对象，适合把网页变成结构化数据的任务。

### 什么场景不值得用

- **需要 JS 渲染 / 交互式浏览的页面**：Fetch 明确是「不需要 JavaScript 执行或浏览器交互」的轻量方案。这类页面要靠 Browserbase 的浏览器会话（另一套产品），不是这两个工具。
- **只锁死一家模型、且已用其原生检索**：原生工具（如 Anthropic 的 `maxUses`、`allowedDomains`、`blockedDomains`）往往更贴合自家模型，且计费已含在模型定价里。此时引入网关工具属可选项而非必选。
- **超大调用量 + 成本极敏感**：Search $7/1k、带代理与抽取的 Fetch $7/1k 是实打实的分项支出。海量调用需先估算。
- **对抽取可用性有硬依赖**：官方提示，若 Browserbase 抽取不可用或配额耗尽，`markdown`/`json` 请求会返回 `configuration_error`（HTTP 403），需回退到一个 `format: 'raw'` 并省略 schema——也就是说结构化抽取不是 100% 保底，需要写降级逻辑。

### 迁移成本

- **从「自建搜索胶水层」迁移**：改为在 `tools` 里传 `gateway.tools.browserbaseSearch()` / `browserbaseFetch()`，删掉自维护的搜索 API 调用代码。工作量：小（半天级）。
- **从「某家原生检索」迁移**：把原生工具替换为网关 helper，注意工具定义**不能跨格式复制**（官方明确警告别在 TS / Python / Chat Completions / Responses 之间照抄工具定义）。工作量：中。
- **从「无检索」新增**：只要模型支持 tool calling，加两个 helper 即可。工作量：小。需注意先把 SDK 升到 AI SDK 7.0.116+（`pnpm add ai@latest`）并配置 `AI_GATEWAY_API_KEY`。

## 对你的意义

结合 Ken 的 AI 应用开发线（Agent + UI / RAG 工具链），这个更新值得放进「检索层选型」的候选清单：

- **如果你在做多模型策略**（比如成本分层：便宜模型跑轻任务、强模型跑难任务，或做 failover），这个「工具与模型解耦」的抽象正好命中痛点——它把你从「每接一家模型就重写一遍 web search」里解放出来。
- **它和你关注的 Agent 设计模式直接相关**：`browserbaseSearch` + `browserbaseFetch` 就是 search→read 的显式化，天然适合做成可复用的检索子图节点。
- **安全设计值得借鉴**：「开发者默认值覆盖模型生成值」+「敏感参数模型不可设、注入值丢弃」这两条，是可迁移到自研工具层的护栏思路，尤其你关注评估与安全方向。

**建议：观望偏试用。** 如果你的栈已经或计划用 Vercel AI SDK 做多模型编排，可以立刻开个小实验验证工具定义的可移植性；若你目前单模型且已有原生检索，先记档、按需再上。

## 关键代码/配置片段

以下为官方 changelog 给出的真实用法（AI SDK 7.0.116+）：

```javascript
import { gateway, streamText } from 'ai';

const result = streamText({
  model: 'moonshotai/kimi-k3',
  prompt: "Find Browserbase's latest announcement, fetch the page, and summarize it.",
  tools: {
    browserbase_search: gateway.tools.browserbaseSearch({ numResults: 3 }),
    browserbase_fetch: gateway.tools.browserbaseFetch({
      allowRedirects: true,
    }),
  },
});
```

安装与鉴权（官方原文）：

```bash
pnpm add ai@latest
# 然后设置环境变量 AI_GATEWAY_API_KEY
```

关键参数与计费（来源：Vercel AI Gateway Web Search 文档）：

| 工具 | 关键参数 | 计费 |
|------|----------|------|
| `browserbaseSearch` | `numResults`（1–25，默认 10）；query 1–200 字符 | $7 / 1,000 次请求（不论结果数） |
| `browserbaseFetch` | `format`：`raw` / `markdown` / `json`；`schema`（仅 `json` 有效，且**仅开发者可设**）；`allowRedirects`（默认 false）；`proxies`（默认 false）；`allowInsecureSsl`（默认 false，**仅开发者可设**） | raw $1/1k；+proxies $3/1k；+抽取(markdown/json) $3/1k；代理+抽取 = $7/1k |

成本护栏示例——把 `format`、`proxies` 钉死以免模型选到更贵档位：

```javascript
browserbase_fetch: gateway.tools.browserbaseFetch({
  format: 'markdown',   // 钉死抽取格式
  proxies: false,       // 钉死是否走代理
  allowRedirects: true,
}),
```

> TODO: 官方 changelog 未给出 benchmark 或延迟数据；如需评估「网关中转 vs 直连 Browserbase」的额外开销，需自行压测。

---
[← Back to Deep Dives](./README.md)
