---
auto_generated: true
generated_at: "2026-10-26T05:50:00Z"
source_url: "https://developers.openai.com/api/docs/guides/prompt-caching"
signal_type: "significant_update"
---
# 12 小时 prompt caching：把 Agent 的"工具定义+系统提示"变成常驻资产 (12-Hour Prompt Caching in the Responses API)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-26
>
> **项目/工具**: OpenAI Responses API — Prompt Caching
> **链接**: https://developers.openai.com/api/docs/guides/prompt-caching
> **核心定位**: 缓存寿命从 30 分钟拉到 12 小时，写入成本 2.5x，读成本不变（0.1x / GPT-6.1 Sol 0.05x）——让"跨小时、跨天"的 Agent 会话首次能吃到缓存折扣

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**：新增 12 小时 TTL 的 prompt cache 写入档位，把原本 30 分钟就过期的系统提示 / 工具定义 / 长上下文，变成跨班次的常驻缓存。
- **现在值得用吗**：看场景。**同一套 prefix 会被反复使用、且使用间隔超过 30 分钟**的场景，立刻开；只跑一次的攻击型任务（one-shot batch），反而更贵。
- **适合场景**：常驻 Agent 服务、多轮但稀疏的对话（客服/助手）、跨小时的 IDE Copilot 类工具、每日复用同一批文档的 RAG/分析流水线。
- **不适合场景**：一次性批处理、prefix 频繁变动（每次请求换 system prompt）、prompt 长度不足 1,024 tokens（根本进不了缓存）。
- **与前版核心差异**：默认 30 分钟 TTL 写入 1.25x，现在可选 12 小时 TTL 写入 2.5x；读侧折扣不变。

## 是什么 / 解决什么问题

Prompt caching 本身不是新东西。OpenAI 的 Responses API 一直支持把 prompt 前缀的 KV 状态缓存下来，让后续请求跳过重复的 prefill 计算。官方文档给出的收益很直接：复用 token 按 cached-input 费率计费，**折扣最高达 95%**，同时降低首 token 延迟。

问题出在**寿命**。此前默认缓存寿命是 30 分钟（GPT-5.6 及之后模型），写入费率为标准输入价的 1.25x。30 分钟对于"同一个 Agent 会话连续跑十几轮"够用，但对以下三类真实负载完全不够：

1. 开发者上午用 IDE 助手写后端，下午切回来继续同一个仓库的上下文；
2. 客服/运维 Agent 必须长驻，两次用户提问之间可能隔 3 小时；
3. 每日跑一次的文档分析流水线，system prompt + 文档集完全一致，但间隔 24 小时。

这三种情况下，缓存必然过期，每次都需要重新写入甚至直接按未缓存价处理。**2026-10-20 的更新**（changelog 条目：`v1/responses` → "You can now choose 12-hour prompt caching in the API"）就是针对这个缺口：在 Responses API 里显式选择 12 小时最小寿命，写入费率 2.5x 普通输入价，读侧费率不变。

一句话说清这次更新的性质：**它不是变便宜了，而是给你一个新的成本曲线斜率**——用更高的写入押金，换更长的资产使用期。

## 技术架构拆解

### 核心设计决策

- **读费率与 TTL 解耦**。文档明确写："Subsequent reads cost 0.1× the ordinary input rate on most of these models and 0.05× on GPT-6.1 Sol, **regardless of the selected lifetime**." 也就是说，选 12 小时不会让每次读变贵，只会让"首次写入"变贵。这是整个可用性成立的前提。
- **写入计价不是叠加费用**。原文："Cache-write pricing is not an additive fee: input tokens use the uncached-input, cached-input, or cache-write rate." 同一批 token 只会命中三档费率之一，不会出现"写入费 + 输入费"双重计费。这一点常被误读。
- **缓存的是 KV tensor，不是 token 文本**。文档："The prompt cache stores key-value (KV) tensors, not the tokens themselves." 所以省的是计算，不是网络传输。
- **prefix 全等 + 断点匹配**。缓存命中要求"entire rendered prefix to match"。任何在断点之前的变动（模型、tools、parallel_tool_calls、text.format、reasoning.effort、text.verbosity、context_management）都会让该断点之后的 prefix 无法匹配。
- **1,024 token 门槛**。GPT-5.6 及之后，最小可缓存长度是 1,024 tokens；OpenAI 隐藏系统内容里的 token 不计入这个门槛。短 prompt 直接放弃缓存念头。
- **显式/隐式双模式**。隐式模式由 OpenAI 自动在最新一条符合条件的 user message 末尾放断点；显式模式必须手动打 `prompt_cache_breakpoint: { "mode": "explicit" }`，若一个都没打，请求既不使用缓存也不写缓存。每次请求最多 4 个 cache write，显式模式让你能把"会变的尾部内容"排除在写入之外。
- **`prompt_cache_key` 做路由复用**。示例代码里用 `"prompt_cache_key": "shared-workflow-v1"`，把共享 workflow 的缓存条目绑定到同一个 key，这是多实例部署时提高命中率的关键。

### 与前版/竞品的关键差异

| 维度 | 之前（30m 默认档） | 现在（12h 档） |
|------|------------|------------|
| 缓存最小寿命 | 30 分钟 | 12 小时 |
| 写入费率 | 1.25x 未缓存输入价 | 2.5x 未缓存输入价 |
| 读费率 | 0.1x（GPT-6.1 Sol 0.05x） | 完全相同，不随 TTL 变 |
| 适用负载 | 连续会话、单次任务内的多轮 | 跨小时/跨班次/按日复用的常驻 Agent |
| 最小可缓存长度 | 1,024 tokens（GPT-5.6+） | 相同 |
| 单请求最大写入数 | 4 个断点 | 相同 |

按文档给的算术样例：0.1x 读 + 30 分钟写入的场景下，写一次、完整复用一次的代价是 **1.35x 普通输入成本**，而不用缓存走两遍是 2x；十次请求里写一次读九次是 **2.15x**，对比不缓存的 10x。换成 12 小时档（写入 2.5x），**盈亏平衡点会向右移动**——具体倍数取决于你的读次数和实际费率，建议直接用自己模型的 cache write / cached input 单价算，别套用本文的示意数字。

### 架构/信息流图

```text
┌─────────────────────────────────────────────────┐
│  rendered prefix（必须逐字节一致）              │
│  hidden system → tools → developer → history    │
│                  ▲                              │
│                  │ 断点（显式/隐式，最多 4 写）  │
└──────────────────┼──────────────────────────────┘
                   │
        首次请求   │        后续请求（间隔 < TTL）
        ┌──────────▼─────────┐   ┌──────────────┐
        │ cache write 2.5x   │   │ cache read   │
        │ (12h 最小寿命)     │──▶│ 0.1x / 0.05x │
        └────────────────────┘   └──────────────┘
                   │
                   │  超过 12h 或 prefix 变动
                   ▼
        ┌────────────────────────┐
        │ 全量重算 @ uncached 价 │
        └────────────────────────┘

命中判定顺序：从最长 prefix 往回走，查第一个 2 +
最新 50 个显式断点、隐式断点、最多 20 个更早的
message 结尾、以及 developer 消息初始连续块末尾。
```

## 实用评估

### 什么场景值得用

- **常驻 Agent 服务**：tools 定义动辄 3,000–4,000 tokens（10 个工具的 JSON schema），system prompt 再几千 token。这套 prefix 24 小时不变，12 小时档等于把"每次会话开场都要重付的 prefill"摊薄到几乎为零。
- **稀疏多轮对话**：客服、运维助手这类"用户隔几小时才回来一句"的形态，30 分钟档命中率极低，12 小时档才真正有效。
- **跨班次的开发工具**：IDE 侧助手在同一仓库上下文里反复工作，上午写入、下午继续。
- **按日复用的分析流水线**：每天同一批文档 + 同一份分析框架，只要 system prompt 与文档顺序稳定，一次写入覆盖整天。

### 什么场景不值得用

- **一次性批处理**：只读一次却付 2.5x 写入，纯亏。用默认 30 分钟档、或者干脆别管缓存。
- **prefix 高频变动**：每次请求改 system prompt、改 tool 顺序、改 `text.format` schema，缓存永远打不中，却在持续写缓存。
- **短 prompt**：不足 1,024 tokens 的请求不进缓存，设置了也没用。
- **对成本极度敏感但流量极低**：低于盈亏平衡读次数时，2.5x 写入押金反而是净损失。
- **需要确定性的实时性任务**：缓存命中的前提是 prefix 完全一致，任何 A/B 实验（换 verbosity、换 reasoning.effort）都会打掉缓存——这会限制你做 prompt 灰度测试的自由度。

### 迁移成本

- 技术改动很小：在 Responses API 请求里加 `prompt_cache_options`，把 `ttl` 指向 12 小时档，并用 `prompt_cache_key` 固定 workflow 身份。**半小时级别**。
- 真正的成本在**工程纪律**：
  1. 审计 prefix 顺序，把"永远不变的部分"（system、tools）排到最前，把"每次会变的部分"（用户输入、时间戳）排到最后；
  2. 打开 Prompt Cache Diagnostics（2026-09-08 GA，GPT-5.6+）对比相邻响应、定位 miss 原因；
  3. 用 Prompt Caching Dashboard 盯 cache read hit rate。
- 若此前用 30 分钟档且命中率尚可，迁移**不必急**——先算读次数，再决定。

## 对你的意义

对你（Ken）的两条线，这件事的直接价值不同：

**AI App 线**：如果你在做 Agent + UI 产品，这正是把"Agent 第一句话的延迟和成本"压下来的基础设施级开关。你的 RAG 工具链里，系统提示 + 检索文档模板 + 工具 schema 是天然不变的 prefix；把这块按 12 小时写入，用户每次回来对话都按 0.1x 读。**建议立刻在测试环境验证**：重点看两件事——命中率（Diagnostics）和每会话成本（Dashboard），别只看首 token 延迟。

**VLA 线**：你的日报/论文分析流水线是典型的"每日同一批文档、同一份分析框架"。如果走 OpenAI API，12 小时 TTL 不能完全覆盖 24 小时周期，但你把流水线拆成上游分析（14:30 RSS 后立即跑）就可以让写入与后续精炼共享同一个 TTL 窗口。**属于观望偏行动**：收益明确，但需要先确认你的 pipeline 里 prefix 是否真的逐字节稳定。

一句话建议：**先把 cache hit rate 测出来，再决定换档位。**没有命中率的"换 12 小时"是赌博，有命中率就是纯算术题。

## 关键代码/配置片段

来自官方文档的示例结构（12 小时档需要把 `ttl` 指向长寿命选项，具体枚举值与各模型 cache write / cached input 单价请以 `/api/docs/pricing` 为准）：

```javascript
import OpenAI from "openai";

const client = new OpenAI();
const response = await client.responses.create({
  "model": "gpt-5.6",
  "reasoning": {
    "effort": "medium",
    "context": "all_turns"
  },
  "text": { "verbosity": "medium" },
  "input": [
    {
      "role": "developer",
      "content": [
        {
          "type": "input_text",
          "text": "8,000 tokens"   // 稳定不变的开发者指令
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "2,000 tokens"   // 每次会变的部分放最后
        }
      ]
    }
  ],
  "tools": [
    "Tool definitions, 2,000 tokens"
  ],
  "prompt_cache_key": "shared-workflow-v1",
  "prompt_cache_options": {
    "mode": "implicit",
    "ttl": "30m"   // 改为 12 小时档可延长缓存寿命；写入费率 2.5x
  }
});
```

显式模式下的断点写法：

```javascript
{
  "type": "input_text",
  "text": "...",
  "prompt_cache_breakpoint": { "mode": "explicit" }
}
```

> TODO: 12 小时 TTL 在 `prompt_cache_options.ttl` 中的**确切枚举字符串**（如 `"12h"`）未在抓取片段中出现，落地前请核对 `prompt-caching` 指南的 "Cache lifetime" 小节与 API reference。另：`additional_tools` 输入项目前不支持 `prompt_cache_breakpoint`；顶层 `instructions` 也不能放显式断点——要标记可复用指令，必须放进 developer message 的 `input_text` 块。

---

[← Back to Deep Dives](./README.md)
