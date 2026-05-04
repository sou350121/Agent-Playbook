---
auto_generated: true
generated_at: "2026-05-04T03:33:22Z"
source_url: "https://www.36kr.com/p/3787252419681280"
signal_type: "significant_update"
---
# AI 编程成本危机：从"无限畅饮"到"按粒收费" (The AI Coding Cost Crisis: From All-You-Can-Drink to Pay-Per-Token)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-04
>
> **项目/工具**: GitHub Copilot / Claude Code
> **链接**: https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
> **核心定位**: GitHub Copilot 和 Anthropic 同步放弃订阅制"无限畅饮"模式，转向按 token 用量计费——AI 编程的经济模型正在经历根本性重构

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**: 两大 AI 编程平台同时从"包月不限次"转向"按 token 计费"，标志着 AI 编程工具补贴时代的终结
- **现在值得用吗**: 看场景。轻度/中度使用依然划算（Pro $10/月含 1000 Credits），重度 Agent 会话需要精确预算控制
- **适合场景**: 日常代码补全、小范围重构、Code Review——这些仍包含在基础订阅中不消耗 Credits
- **不适合场景**: 长时间自主编码会话（agentic coding sessions）、多 Agent 并行跑实验、无预算约束的"vibe coding"
- **与前版核心差异**: 之前问一句"怎么写快排"和跑 3 小时自主编码花一样的钱；现在前者可能花 0.01 美元，后者可能花 5-10 美元

## 是什么 / 解决什么问题

2026 年 4 月底，AI 编程领域发生了两件几乎同步的大事：

1. **GitHub 宣布**（4 月 27 日）：从 6 月 1 日起，所有 Copilot 计划从"按 premium request 计费"（PRU 模式）转向"按 token 用量计费"。推出虚拟计费单位 **GitHub AI Credits**（1 Credit = $0.01），每月订阅费变为"含 X Credits + 超额付费"。
2. **Anthropic 同步行动**：限制 Claude Code 中 Opus 模型的访问，Pro 用户（$20/月）想继续用 Opus 需额外付费。

这两件事指向同一个信号：**AI 编程工具的"自助餐时代"结束了。**

过去几年，Copilot 和 Claude Code 用固定月费覆盖所有使用量。这种模式在 AI 助手时代（补全、简单问答）运行良好——因为每次交互的推理成本很低。但当 Copilot 进化为 agentic 平台（多步骤自主编码、跨仓库迭代），单次会话的 token 消耗从几百激增至数十万。GitHub CPO Mario Rodriguez 的原话是："GitHub has absorbed too much inference cost. The current model is not sustainable."

这不是定价策略的微调，而是整个 AI 编程经济模型的重构。

## 技术架构拆解

### 核心设计决策

GitHub 的新计费架构基于以下关键决策：

| 决策 | 之前（PRU 模式） | 现在（AI Credits 模式） |
|------|-----------------|----------------------|
| 计费单位 | Premium Request Units（按次） | Token 消耗（输入+输出+缓存） |
| 模型差异 | 通过 multiplier 间接体现 | 直接按各模型 API 定价 |
| 超额处理 | 降级到低成本模型继续 | 按 published rates 付费或暂停 |
| 企业管控 | 无细粒度预算控制 | 企业/成本中心/用户三级预算 |
| Code Review | 仅消耗 PRU | AI Credits + GitHub Actions 分钟 |

### 定价结构详解

**月度包含额度（subscription allowance）：**

| 计划 | 月费 | 含 AI Credits | 折合美元 |
|------|------|--------------|---------|
| Copilot Pro | $10/月 | 1,000 Credits | $10 |
| Copilot Pro+ | $39/月 | 3,900 Credits | $39 |
| Copilot Business | $19/用户/月 | 1,900 Credits | $19 |
| Copilot Enterprise | $39/用户/月 | 3,900 Credits | $39 |

**超额定价（按模型 API rates，每百万 token）：**

| 模型 | 输入 | 缓存输入 | 输出 |
|------|------|---------|------|
| GPT-5.4 | $2.50 | $0.25 | $15.00 |
| GPT-5.5 | $5.00 | $0.50 | $30.00 |
| Claude Opus 4.7 | $5.00 | $0.50 | $25.00 |
| Claude Sonnet 4.6 | $3.00 | $0.30 | $15.00 |
| Gemini 2.5 Pro | $1.25 | $0.125 | $10.00 |
| Grok Code Fast 1 | $0.20 | $0.02 | $1.50 |

**年费用户的 multiplier 暴涨**（在年费到期前仍按旧模式但 multiplier 调整）：

| 模型 | 旧 multiplier | 新 multiplier | 涨幅 |
|------|--------------|--------------|------|
| Opus 4.7 | 7.5x | 27x | **3.6x** |
| GPT-5.4 | 1x | 6x | **6x** |

### Token 消耗架构：钱到底烧在哪了？

这篇文章最核心的洞察是拆解了 AI Agent 的 token 消耗层次：

```
用户输入 (50 tokens)
  │
  ├─ ① 输入 token ────────────────────── 直接成本
  │
  ├─ ② 推理 token ──────────────────── "深度思考"产生的隐藏成本
  │    (可能数千到数万，用户看不到)
  │
  ├─ ③ 工具调用循环 ────────────────── Agent 特有成本
  │    思考 → 调工具(3-4K tokens/schema) → 读结果 → 再思考
  │    通常 6-15 轮
  │
  ├─ ④ 输出 token ──────────────────── 最终返回给用户的
  │    (比输入贵 2-6x，因为生成是串行的)
  │
  └─ ⑤ 结构性 overhead ─────────────── 看不见的脚手架
       [SYS]/[USR]/[AST] 标记、padding、模式触发 token

一个 50-token 的用户问题 → 可能消耗 100,000+ tokens 总账单
```

**关键数据点**：
- 输出 token 比输入贵 2-6 倍（物理层面：生成是串行的，输入可并行）
- 每个工具调用的 schema overhead：3,000-4,000 tokens（无论是否真正用到）
- Agent 循环：50 token 输入 → 100,000+ token 总消耗
- 一张截图（视觉 token）比一整页文字更贵
- 一小时会议录音 ≈ 180,000 audio tokens

### 与前版/竞品的关键差异

| 维度 | 旧 Copilot（PRU） | 新 Copilot（Credits） | Cursor（竞品参考） |
|------|-----------------|---------------------|-----------------|
| 计费粒度 | 按请求（粗） | 按 token（细） | 按请求 + 月度上限 |
| 模型选择成本 | 隐藏在高 multiplier 中 | 透明 API 定价 | 不同模型不同额度消耗 |
| 企业预算控制 | 无 | 三级（企业/成本中心/用户） | 有限 |
| Code 补全 | 消耗 PRU | **免费无限**（不消耗 Credits） | 包含在订阅中 |
| 超额策略 | 自动降级 | 付费或暂停（用户可选） | 月度用尽即停 |

## 实用评估

### 什么场景值得用

- **日常代码补全和 Next Edit Suggestions**：仍然免费无限，不受 Credits 影响。这是 Copilot 最核心的价值，且在新模式下反而更"划算"——因为不消耗额度。
- **Code Review**：虽然开始消耗 Credits + Actions 分钟，但自动化 PR review 的 ROI 通常很高。建议设置合理的 Actions 预算上限。
- **中小规模重构**：Pro 的 1,000 Credits（$10）足够覆盖大部分日常 agentic 会话。一次典型的文件级重构约消耗 50-200 Credits。
- **企业团队**：pooled credits + 三级预算控制是实质性改进。之前每个用户的未用额度是" stranded capacity"，现在可以共享。

### 什么场景不值得用（或需要谨慎）

- **无预算约束的长时间 Agent 会话**：Chamath Palihapitiya 的数据——单个 Agent 通过 Claude API 一天花 $300（一年 $100,000）。如果你的工作流依赖 7×24 跑 Agent，新模型下成本可能翻 10-50 倍。
- **"Vibe Coding"实验性使用**：快速原型验证很爽，但 token 账单会很痛。Meta 内部 8.5 万人 30 天烧掉 60 万亿 token（估 $900M），个人最高月账单 $2M。
- **重度依赖 Opus/GPT-5.5 等高端模型**：这些模型的 output token 定价是轻量模型的 10-20 倍。如果你的工作流不真正需要 Opus 的推理能力，切换到 Sonnet 或 GPT-5.4 可以节省 60-80%。
- **年费订阅用户**：multiplier 从 1-7.5x 暴涨到 6-27x。建议在 6 月 1 日前转为月费计划以享受新定价。

### 迁移成本

- **从 PRU 到 Credits**：对月费用户是自动迁移，无需操作。但需要：
  1. 在 5 月初的"费用预览"中查看预估成本
  2. 评估当前使用模式：如果月均消耗 > 包含额度，需调整模型选择或接受超额付费
  3. 企业管理员需配置预算策略（允许超额 vs 硬性上限）
- **从年费转月费**：GitHub 提供按比例退款（prorated credits）。操作成本极低，但需要重新走一遍订阅流程。
- **团队层面**：建议建立 token 预算文化。按 Chamath 的做法——给每个开发者设定 token 预算，并要求生产力提升至少 2x 来覆盖"工资 + AI 账单"总成本。

## 对你的意义

这个变化对 AI 应用开发者的核心影响是：**Agentic Coding 的经济性模型被重新定义了。**

之前，"让 AI 跑一个小时的自主编码会话"的边际成本接近于零（已包含在月费中）。现在，每次会话都有明确的 dollar cost。这意味着：

1. **Agent 设计必须考虑 token 效率**。减少不必要的工具调用轮次、优化 schema 大小、避免无意义的"思考→重试"循环——这些从"工程优化"变成了"成本优化"。
2. **模型选择从"性能优先"变为"性价比优先"**。如果 Sonnet 能完成 90% 的任务但成本只有 Opus 的 1/3，那么智能的策略是"Sonnet 为主 + Opus 兜底"。
3. **vibe coding 的热度可能降温**。当"让 AI 随便写写看"的成本从 $0 变成 $5-20，开发者的使用行为会发生实质性变化。

**建议**：立即在 5 月初开启费用预览，评估当前使用量。如果你的月均 Credits 消耗在 500 以内，Pro ($10) 依然超值。如果超过 2,000，考虑 Pro+ 或调整模型策略。

## 关键代码/配置片段

**GitHub AI Credits 计费逻辑**（来自官方文档）：

```
每次交互成本 = (input_tokens × input_rate + 
                cached_tokens × cached_rate + 
                output_tokens × output_rate) / 1,000,000

1 AI Credit = $0.01 USD

示例：使用 GPT-5.4 的一次交互
- 输入 50,000 tokens: 50,000 × $2.50 / 1,000,000 = $0.125
- 缓存 30,000 tokens: 30,000 × $0.25 / 1,000,000 = $0.0075
- 输出 5,000 tokens:  5,000 × $15.00 / 1,000,000 = $0.075
- 总成本: $0.2075 = 20.75 AI Credits
```

**企业预算控制**（来自 GitHub Blog）：

```
管理员可设置三级预算：
├── Enterprise 级别：总预算上限
├── Cost Center 级别：部门/团队预算
└── User 级别：个人预算

超额策略二选一：
├── Allow additional usage at published rates（允许超额付费）
└── Cap spend（硬性上限，用尽即停）
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 挑战 | 技术成功率可能达标，但经济可行性被 token 成本严重制约——如果单次 Agent 会话成本 $5-10，"成功"的定义需要从"能做"扩展到"值得做" |

---

> **数据源**: GitHub Blog (2026-04-27), GitHub Docs (Models & Pricing), 36kr/InfoQ 深度分析
> **注**: Claude Code 的 Opus 限制细节未在公开文档中完全披露，部分信息来自用户报告和 Anthropic 负责人 Boris Cherny 的公开表态

---
[← Back to Deep Dives](./README.md)
