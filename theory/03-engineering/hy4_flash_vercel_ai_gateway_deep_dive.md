---
auto_generated: true
generated_at: "2026-11-18T05:45:42Z"
source_url: "https://vercel.com/changelog/hy4-flash-now-available-on-ai-gateway-for-50-off"
signal_type: "blog_post"
---
# Hy4 Flash 上架 Vercel AI Gateway：1/10 價格的完整能力面 (Hy4 Flash on Vercel AI Gateway: Full Feature Set at a Tenth of the Price)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-18
>
> **项目/工具**: Tencent Hy4 Flash（经 Vercel AI Gateway 分发，模型名 `tencent/hy4-flash`）
> **链接**: https://vercel.com/changelog/hy4-flash-now-available-on-ai-gateway-for-50-off
> **核心定位**: Hy4 家族的新低成本档位——保留完整 Hy4 能力集（1M 上下文、思考保留、工具调用、结构化输出、prompt caching、图像输入），单 token 价格约为家族高端档位的十分之一

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Hy4 的「便宜但功能不缺」版本，通过 AI Gateway 一个模型名即可接入，适合高频、可关思考的批量负载
- **現在值得用嗎**：是，但限「量大 + 质量容错」的场景；首期五折只到 2026-11-29
- **適合場景**：高并发 coding agent 的日常任务、文档批处理、需要 1M 上下文但单次请求不追求极致推理的 pipeline
- **不適合場景**：需要稳定强推理的长链任务（该关思考的档位本质上是在省算力）、有严格数据驻留要求的合规负载（需自行确认 provider 的 ZDR / No-Training 条款）
- **與 Hy4 全价档核心差異**：功能面几乎相同，差在每 token 价格约 1/10——也就是说，同样的 1M 上下文、同样的 reasoning-with-preserved-thinking、同样的工具调用都还在

## 是什么 / 解决什么问题

Hy4 Flash 是腾讯 Hy4 模型家族里的新低成本成员。按 Vercel changelog 的表述，它「keeps the full Hy4 feature set at roughly a tenth of the price per token」——也就是说不做能力阉割式降级（不是砍上下文、不是砍工具调用），而是把成本压到家族高端档的约十分之一。

它解决的是很具体的一个工程痛点：**agent 与 coding 负载的调用量大、单次请求却往往不需要顶配推理**。一道改 bug、一次文件检索、一轮格式化输出，占的是调用量和 token 量的大头，但吃掉高端模型的预算。Hy4 Flash 的定位就是把这类「量大利薄」的请求挪到便宜档位，把贵的算力留给真正难的那几步。

同时它也解决「模型选型碎片化」的问题：上架 Vercel AI Gateway 之后，它跟网关上的其他模型共享同一套调用面（AI SDK、OpenAI Chat Completions、OpenAI Responses、Anthropic Messages 四种格式），换模型只需改一个 model 名。这对已经有网关的项目是几乎零成本的多模型策略。

## 技术架构拆解

### 核心设计决策

- **能力不阉割，只压价格**：changelog 明确列出保留项——`reasoning with preserved thinking across turns`、`tool calling`、`structured outputs`、`prompt caching`、`image input`，以及同样的 `1M-token context window`。这是「同能力、低价位」而不是「同价位、砍功能」的产品策略。
- **思考可关闭**：`Reasoning can be turned off for requests that don't need it, which suits high-volume coding, agent, and document workloads`。这是一个显式的成本旋钮——高并发场景把 reasoning 关掉，省的不只是时间还有 reasoning token。
- **网关抽象层优先**：模型本身不是重点，重点是「一个 model 名 + 自动 failover」。AI Gateway 的做法是把同一模型路由到多个 provider，`order` 表达偏好但保留全部 provider 作为后备，`only` 则是硬白名单。
- **思考量跨格式桥接**：AI Gateway 提供 provider-agnostic 的 reasoning 档位 `none / minimal / low / medium / high / xhigh`，在 Chat Completions 与 Responses 格式下映射为 `reasoning.effort`，在 Anthropic Messages 格式下映射为原生 thinking token budget。
- **零加价分发**：`AI Gateway reflects provider pricing with no markup and does not charge a platform fee on inference`，BYOK 请求同样不加平台费。

### 与前版/竞品的关键差异

| 维度 | Hy4 全价档 | Hy4 Flash（网关口径） |
|------|-----------|----------------------|
| 上下文窗口 | 1M | 1M（相同） |
| 最大输出 | 待确认 | 64K（`maxOutputTokens` 上限） |
| 思考保留跨轮 | 支持 | 支持（相同） |
| 工具调用 / 结构化输出 | 支持 | 支持（相同） |
| 图像输入 | 支持 | 支持（相同） |
| 输入价格 | 约为 Flash 的 10 倍（据 changelog「a tenth of the price」） | $0.04 / M tokens（五折期） |
| 输出价格 | 同上口径 | $0.14 / M tokens（五折期），缓存写 $0.0015 / M |
| 缓存命中 | — | 82%（网关页面实时统计） |
| 延迟 / 吞吐 | — | P50 TTFT 3.1s / 156 tps（页面实时数据） |
| 发布日期 | — | 2026-11-16 |

> 说明：上表的价格、延迟、吞吐取自 Vercel 模型页在抓取时的展示值，属于**实时网关统计**而非官方基准测试，流量结构变化会带动数字波动。Hy4 全价档的具体每 token 价格本文未取到官方数字，只引用 changelog 的「约十分之一」相对表述。

### 架构/信息流图

```
              ┌───────────────────────────────┐
              │  Claude Code / Codex / Cursor │
              │  AI SDK / OpenAI 兼容 / Anthropic │
              └──────────────┬────────────────┘
                             │  model = tencent/hy4-flash
                             ▼
              ┌───────────────────────────────┐
              │        Vercel AI Gateway      │
              │  • 鉴权 / API Key 预算约束     │
              │  • reasoning 档位归一化        │
              │    (none..xhigh → 原生配置)    │
              │  • 路由 order / only / sort    │
              │  • failover 到其他 provider    │
              │  • ZDR 过滤 / 用量与成本记录    │
              └──────────────┬────────────────┘
                             ▼
              ┌───────────────────────────────┐
              │   Provider: Tencent Cloud     │
              │   1M ctx · 64K max output     │
              │   思考可关 · 工具 · 结构化输出  │
              └───────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **高并发 coding agent 的常规回合**：单文件修改、跑测试、读日志这类任务占调用量最大头，关思考后单位成本极低，1M 上下文还能整仓塞进去。
- **文档批处理流水线**：结构化输出 + 1M 上下文 + 便宜的输入价（五折期 $0.04/M），适合一次吞整份长文档再产出 JSON 的批处理。
- **需要多模型 fallback 的生产链路**：网关的 `order` / `only` / `sort` 让「便宜模型打头、贵的兜底」变成一行配置，而不是自建路由层。
- **已经在 Vercel 生态里的项目**：跑 `npx vercel ai-gateway setup` 就能在 Claude Code、Cursor 里选到它，接入成本接近零。

### 什么场景不值得用

- **强推理长链任务**：这档位的卖点之一是「可以关思考来省钱」，反过来说明它在需要持续深推理的任务上不是最优选。复杂多步规划、需要严密数学推导的负载，仍应交给高端档位。
- **强合规 / 数据驻留要求**：页面上的 ZDR 与 No-Training 列为「—」，即该 provider 在当前展示下未标注支持。必须走 `zeroDataRetention: true` 的项目要自行确认是否能路由到合规 provider，否则请求会失败而非降级。
- **依赖思考 token 精细计费做预算控制的团队**：`Reasoning tokens typically count toward your output-token usage, though how they're reported and billed varies by provider`——计费口径随 provider 变化，预算模型需要按 provider 分别建模。
- **折扣期当作长期价格假设**：五折只到 2026-11-29，之后的成本测算要按原价重算。

### 迁移成本

- **从其他模型换过来**：改一个 `model` 字符串，其余参数（`messages`、`temperature`、`tools`）不变；如果原来用的是 reasoning 参数，需要按 `none / minimal / low / medium / high / xhigh` 重新对齐档位。
- **从直连腾讯云换到网关**：多一层网关，但换来 failover、预算控制、统一用量统计；BYOK 模式下不加平台费，成本中性。
- **在 coding agent 里换模型**：安装最新 Vercel CLI 后跑 `npx vercel ai-gateway setup`，再在 agent 里选 `tencent/hy4-flash`。
- 工作量估计：单模型替换以小时计；如果要设计「便宜打头 + 贵兜底」的路由策略，需要额外做一轮质量回归对比——这部分是真正的时间成本。

## 对你的意义

对你的 AI 应用线（Agent + UI、RAG 工具链）来说，这条变化的实际价值不在模型本身，而在**成本结构**：RAG 的 query 改写、rerank 前的内容筛选、agent 的中间步骤，都属于「量大利薄」的调用，过去要么用贵模型烧钱，要么用小模型降质量。现在多了一个「1M 上下文 + 工具调用 + 结构化输出都在，但价格 1/10」的选项，可以在网关层做**分级路由**：常规步骤打给 Flash，疑难步骤走 `order` 里的贵模型。

对 VLA 线关系不大——那不是 LLM 调用密集的场景，深推理也不是这类廉价档位擅长的。

**建议：立即试用，但先做两件事**——(1) 用你自己的 agent 任务跑一组 A/B，量化「关思考 vs 开低中档」的质量差，因为这决定了你能把多少流量下放到廉价档；(2) 在 11-29 折扣结束前重算一次预算模型，别把五折价写进长期假设。

## 关键代码/配置片段

配置模型名与运行 setup（引自 Vercel changelog）：

```bash
# 在 Claude Code / Codex / Cursor 等 agent 中使用
npx vercel ai-gateway setup
# 然后在 agent 里选择 tencent/hy4-flash
```

网关路由与零数据驻留选项（引自 AI Gateway 模型页的参数表）：

```jsonc
{
  "model": "tencent/hy4-flash",
  "reasoning": "low",              // 'provider-default' | 'none' | 'minimal' | 'low' | 'medium' | 'high' | 'xhigh'
  "maxOutputTokens": 64000,        // 输出上限，reasoning token 也计入
  "providerOptions": {
    "gateway": {
      "order": ["tencent"],        // 偏好顺序，其余 provider 仍作为 fallback
      "sort": "cost",              // 'cost' | 'ttft' | 'tps'
      "zeroDataRetention": true    // 硬约束：只路由到支持 ZDR 的 provider
    }
  }
}
```

四种调用格式共用同一模型：

```text
AI SDK generateText / streamText
OpenAI Chat Completions API（改 base URL）
OpenAI Responses API（改 base URL）
Anthropic Messages API（改 base URL）
```

> TODO: Hy4 Flash 在官方公开 benchmark 上的具体分数（如 SWE-bench、数学推理）在本次抓取的源材料中未披露，本文不做任何数值推断。若需要量化对比，请以腾讯官方模型卡或独立评测为准。

---
[← Back to Deep Dives](./README.md)
