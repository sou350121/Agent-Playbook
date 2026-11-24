---
auto_generated: true
generated_at: "2026-11-24T06:46:25Z"
source_url: "https://www.36kr.com/p/3787252419681280"
signal_type: "significant_update"
---
# 当 AI 写代码开始按粒计价：Copilot 转按量计费与 vibe coding 的经济性拐点 (From All-You-Can-Eat to Pay-Per-Token: Copilot's Usage-Based Billing and the Unit Economics of Vibe Coding)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-24
>
> **项目/工具**: GitHub Copilot / Anthropic Claude Code（计费模型变更）
> **链接**: https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
> **核心定位**: 把「按请求计费」改为「按 token 计费」——Agentic Coding 的真实推理成本第一次被逐笔摊到每一次真实使用上。

## 快速判断（30 秒读完这段就够了）

- **一句話定位**：GitHub 宣布 2026-06-01 起 Copilot 全系从 premium request 计费转向 GitHub AI Credits（按 input / output / cached token 折算），Anthropic 同期收紧 Claude Code 的 Opus 用量——两家一起给「无限畅饮」模式踩刹车。
- **現在值得用嗎**：看場景。**確定要用 agentic 模式且能承受不确定账单**的团队该用了；只想「顺手补全、偶尔问两句」的个人用户，Copilot Free 与 code completion 仍然不吃 Credit。
- **適合場景**：工程团队内 Agent 占产出比重正在上升、需要把 AI 成本纳入预算与审计的场景。
- **不適合場景**：无法建立 token 预算与观测的项目；依赖「免费额度撑到月底」的个人重度用户。
- **與 [前版] 核心差異**：过去「一次快速提问」与「一次数小时的自主编码会话」消耗同样额度；现在按实际 token 计费，长会话的账单会显著拉开。

## 是什么 / 解决什么问题

过去两年多，AI 编程工具的商业模式几乎没有变过：**按人头订阅，用量不限（soft limit）**。Copilot Pro 每月 10 美元、Claude Pro 每月 20 美元，用户在额度内可以随便跑。这个模式的前提是「平均成本」——高频用户多出来的推理成本，被低频用户摊掉，剩下的由平台吸收。

真正打破这个平衡的不是聊天，而是 **agentic coding**。GitHub 在官方博客里写得很直白：

> "Today, a quick chat question and a multi-hour autonomous coding session can cost the user the same amount. GitHub has absorbed much of the escalating inference cost behind that usage, but the current premium request model is no longer sustainable."

换句话说，产品定位已经从「编辑器里的补全助手」变成「能跑长时多步任务、遍历整个仓库的 agent 平台」，而计费单位还停留在聊天阶段。这次变更就是把计费的「颗粒度」追上产品形态的变化。

Anthropic 的动作方向一致：Claude Code 的负责人 Boris Cherny 对外表态「订阅模式本就不是为这种使用强度设计的」，Pro 用户继续使用 Opus 模型需要额外付费。两家在同一周做出同类决定，说明这不是单家公司的财务问题，而是**整个「agent 无限量」叙事的结构性矛盾**。

## 技术架构拆解

### 核心设计决策

- **替换计费单位，而非替换价格**：按官方说明，Copilot Pro 仍是 $10/月、Pro+ $39、Business $19/seat、Enterprise $39/seat，但改为「每月随订阅附赠等额 AI Credits」，超出后按公布 API 单价可选加购。
- **Credits 由 token 真实折算**：消耗含 **input token、output token、cached token**，按各模型公布的 API 费率计算。这意味着模型选择直接变成成本决策。
- **取消 Fallback 体验**：旧模式额度耗尽后可以降级到更便宜的模型继续工作；新模式里「额度用尽 = 停」，改由 credits 与管理员预算控制来治理。
- **企业侧引入池化与预算控制**：企业/成本中心/用户三级预算；企业内未用完的 included usage 可以 **pooled**，消除「困在个人账户里的闲置容量」。
- **保持 code completion 免费**：代码补全与 Next Edit suggestions 在所有套餐内继续包含、不消耗 AI Credits——这条在产品取舍上很关键，等于把「补全」定性为基础能力、「agent」定性为计费能力。
- **Code review 双重计费**：Copilot code review 除消耗 AI Credits 外，还会消耗 GitHub Actions minutes（按 Actions 同等单价）。

### 与前版/竞品的关键差异

| 维度 | 之前（premium request） | 现在（usage-based） |
|------|------------|------------|
| 计费单位 | Premium Request Units（每次请求计数） | GitHub AI Credits（按 token 折算） |
| 短问 vs 长会话 | 成本几乎相同 | 长会话成本随 token 线性放大 |
| 额度耗尽 | 降级到低价模型继续干 | 停止，或用 credits / 预算继续 |
| 容量归属 | 个人额度相互孤立 | 企业内可池化共用 |
| 治理工具 | 几乎没有 | 企业/成本中心/用户三级预算 |
| 补全类功能 | 包含 | 仍然包含，不消耗 credits |
| 年付用户 | 未定 | 年期内沿用旧倍率，6/1 起模型倍率上调，到期转 Free |

### 架构/信息流图

```
                         ┌───────────────────────────────┐
                         │   Copilot 请求 (agentic 会话)  │
                         └───────────────┬───────────────┘
                                         │
                          input / output / cached tokens
                                         │ × 模型 API 费率
                                         ▼
                         ┌───────────────────────────────┐
                         │   GitHub AI Credits 扣减      │
                         └───────────────┬───────────────┘
              ┌──────────────────────────┼──────────────────────────┐
              ▼                          ▼                          ▼
      ┌───────────────┐        ┌──────────────────┐      ┌──────────────────┐
      │ 个人 included │        │ 企业 pooled pool │      │ Enterprise / CC  │
      │ ($10 / $39)   │        │ (可跨人共享)     │      │ / User 预算上限  │
      └───────┬───────┘        └────────┬─────────┘      └────────┬─────────┘
              │  额度耗尽               │                         │
              ▼                         ▼                         ▼
      停止 / 加购（按公布单价）  ← 管理员决定「允许超额」或「硬帽」
```

## 实用评估

### 什么场景值得用

- **需要把 AI 成本纳入工程预算的团队**：以前 token 账单是平台的黑箱，现在至少有了「预览账单 + 三级预算 + 池化额度」这套工具，成本开始可管理、可审计。
- **agent 产出占比高的组织**：如果 agent 已经承担了可观的编码产出，按量计费反而更公平——低频用户不再被高频用户「抽税」。
- **只用补全的人**：code completion 与 Next Edit 继续不计 credits，这类用户实际体验接近不变。

### 什么场景不值得用

- **靠免费额度跑长时 agent 的个人用户**：旧模式下「一个月 $10 跑到底」的打法会失效，尤其是重度使用高端模型时。
- **无法预估用量的场景**：一次 agentic 会话会「想」多久、调多少次工具、读多少上下文，用户事前并不知道；官方也只能在 5 月初先给一个「费用预览」的模糊可见性。
- **对 deterministic 预算敏感的小团队**：账单波动会直接落到现金流上，且可预测性远低于固定人头费。

### 迁移成本

- **个人月付用户**：6 月 1 日自动迁移，无需操作；需要做的是建立用量观测、想清楚主力模型。
- **个人年付用户**：年期内继续按旧倍率计费，但 6 月 1 日起模型倍率上调（对高端模型感受明显）；到期后转 Copilot Free，需重新选择付费月付或提前转月付拿按比例退款。
- **企业管理员**：需要做的是设定三级预算、决定超额策略（放行 or 硬帽）、以及评估 pooled credits 的分配规则。
- **粗略工作量**：观测与预算配置是「小时级」；把「模型选择」写进团队工程规范、重新评估 agent 使用边界，是「周级」的事。

## 对你的意义

对 Ken 这类「自己既是研究者又是开发者、同时在跑一套自动化 agent 管线」的使用者，这次变更的意义不在于多花几美元，而在于**把「agent 的单位经济学」摆到台面上**。

有三个具体含义：

1. **模型分层要显式化**。以前「用最强模型」几乎无成本差；现在模型选择直接乘到账单上（年付用户的高端模型倍率从 6/1 起上调就是预演）。日常格式化、小重构走轻模型，只有真正需要长链推理时才上旗舰模型。
2. **账单即架构信号**。如果一个 pipeline 的 token 账单里「工具 schema + 多轮循环」占了大头，说明问题在架构而非模型——工具描述冗余、循环轮次失控，都会在账单上直接现形。
3. **「免费补贴」不是长期假设**。InfoQ 的分析里提到，行业估算需要 token 消耗在未来几年增长 5 万到 10 万倍才能支撑当前的资本回报预期——这个数字本身就是结论：**没人能长期补贴重度 agent 使用者**。

建议：**立即试用**（观测工具有了，先摸清自己每类任务的实际 token 分布）；**观望付费结构**（等 5 月初的费用预览与 6 月 1 日实际账单出来后，再决定主力模型与套餐）。

## 关键代码/配置片段

官方公告中的计费要点（按条目引用）：

```
起点: 2026-06-01，所有 Copilot 套餐转为 usage-based billing
计费单位: GitHub AI Credits
消耗口径: input tokens + output tokens + cached tokens
          按各模型公布的 API 费率折算

价格未变:
  Copilot Pro        $10/月   → 含 $10 AI Credits
  Copilot Pro+       $39/月   → 含 $39 AI Credits
  Copilot Business   $19/seat/月 → 含 $19 AI Credits
  Copilot Enterprise $39/seat/月 → 含 $39 AI Credits

不计 Credits:
  code completions / Next Edit suggestions

取消的行为:
  fallback to lower-cost model（额度耗尽不再自动降级）

新增:
  企业 ~成本中心 ~用户 三级预算
  企业内 included usage 可池化共享
  预览账单体验（5 月初）
```

> TODO: 每个模型的 Credits↔token 具体换算表（官方指向 docs.github.com 的 models-and-pricing 页面），建议正式切换后从该页取最新数值再来校准预算。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 挑战 | 本事件不是能力问题而是经济问题：当 agent 真实推理成本被逐笔计价，agentic coding 的可行性开始受 unit economics 而非成功率约束。 |

---


[← Back to Deep Dives](./README.md)
