---
auto_generated: true
generated_at: "2026-11-18T03:30:51Z"
source_url: "https://vercel.com/changelog/decision-1-1-now-available-on-ai-gateway"
signal_type: "blog_post"
---
# Decision-1.1 上架 Vercel AI Gateway：把「决策」从开放式生成里拆出来 (Microsoft AI Decision-1.1 on Vercel AI Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-18
>
> **项目/工具**: Microsoft AI Decision-1.1（经 Vercel AI Gateway 提供）
> **链接**: https://vercel.com/changelog/decision-1-1-now-available-on-ai-gateway
> **核心定位**: 一个专门返回结构化决策结果（布尔概率 / 分类概率 / 打分）的模型，替换掉用自由文本 LLM 做路由、分级、评审的老做法；这一版主打更准、校准更好、更快，且请求格式与 Decision-1 完全兼容

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：它不是又一个通用聊天模型，而是把「该走哪个分支」「该交给哪个模型」「该打几分」这类小判断单独建模，直接吐结构化概率，而不是让你去解析一段自然语言。
- **現在值得用嗎**：看場景——如果你的 Agent 里塞了一堆「用小模型/大模型做 if-else」的调用，值得立刻试；如果你所有判断都是长上下文推理，这个救不了你。
- **適合場景**：客服工单分流、模型路由（router）、workflow 下一步选择、AI 回复打分/评审、需要设阈值触发人工复核的闸门。
- **不適合場景**：需要长链推理的任务、需要生成内容的场景、需要读多模态/长文档才能判断的场景（决策模型输入是多选一条件判定，不是对话）。
- **與 Decision-1 核心差異**：官方口径——更准（more accurate）、校准更好（better calibrated）、更快（faster）；接口零改动，只换 model id。

> 注：官方 changelog 未公布具体 benchmark 数字与延迟指标，本文不替它编数字。所有「更准/更快」均沿用官方措辞，属于供应商声明，非第三方复现。

## 是什么 / 解决什么问题

Agent 工程里有一个长期被将就的环节：**小决策**。要不要升级人工？这条请求该路由给哪个模型？这个 tool call 该不该放行？这段输出算合格还是不合格？

过去两年大家的标准做法是「拿一个通用 LLM 当分类器」——把选项写进 prompt，要求返回 JSON，然后用正则或 JSON.parse 去赌它没跑偏。这套做法的问题很实在：

1. **不校准**。模型说「85% 可能」，这个 85 在实践中经常既不是置信度也不是频率。你没法拿它设阈值。
2. **输出不稳**。自由文本 → 偶发多一句话、偶发包 markdown、偶发把 "A" 写成 "选项 A"，下游解析就得写一堆补丁。
3. **贵且慢**。为了做一个三分类，付了通用对话模型的全部成本（长 system prompt、生成 token、上下文窗口）。

Decision 模型的方向是：把这一类任务从「生成」降级为「判别」。输入是条件与选项，输出是概率结构，模型没机会跟你聊天。这一版 Decision-1.1 的核心宣称就是三条——更准、校准更好、更快——并且**请求格式不变**，这意味着它是纯替换，不是迁移。

值得注意的是它的落点：**Vercel AI Gateway**。决策模型单独挂在 Gateway 上，天然接进 request logs、budgets 与 decision fallbacks，也就是说它被当成「Agent 运行时里的一个基础设施部件」，而不是「一个可对话的工具」。这个定位比模型本身更能说明方向。

## 技术架构拆解

### 核心设计决策

- **结构化输出是类型系统的一部分，不是 prompt 约束**。官方定义了三种问题类型：Boolean（条件为真的概率）、Choice（选中类目 + 每个选项的概率）、Score（你自定义量程上的数值评分）。输出形态由 API 决定，模型不再有「格式自由」。
- **一次请求承载多个问题、共享同一份输入**。Multiple questions can share the same input in one request. 这一条对工程价值很大——同一段上下文要做「是否含 PII」「紧急度评分」「该路由给谁」三件事时，不用打三次模型，也不用手动拼三次 prompt。
- **校准被当作一等公民**。官方原文："Better calibration means the model's probabilities track how often it is right, so your application can set thresholds for when to act, flag a case for review, or escalate." 这句话点出了决策模型真正的商业价值：**概率可当阈值用**。
- **零迁移**。Decision-1.1 accepts the same request format as Decision-1. To switch, change the model ID to `microsoft/decision-1.1`.
- **多入口**：AI SDK、OpenAI 兼容的 Decisions API、AI CLI。对已经用 AI SDK 的团队来说是顺手的，对非 TS 生态也有 Python SDK 路径（官方标注 OpenAI Python SDK 3.26.0+）。

### 与前版/通用 LLM 的关键差异

| 维度 | 之前：通用 LLM 当分类器 | 现在：Decision-1.1 |
|------|------------|------------|
| 输出形态 | 自由文本 + JSON 约定，需解析容错 | API 层直接返回 Boolean / Choice / Score 结构 |
| 置信度可用性 | 通常是自报置信，缺乏校准保证 | 官方声明校准更好，概率可用于设阈值 |
| 多问题成本 | 多次调用或手工拼 prompt | 一次请求，多问题共享输入 |
| 迁移成本 | — | 仅改 model id（从 Decision-1 迁） |
| 可观测性 | 自己埋点 | 进 AI Gateway request logs / budgets / fallbacks |
| 任务边界 | 通用，但小任务溢价严重 | 专做判别，不做生成 |

### 架构/信息流图

```
Agent / Workflow
     │
     │  { questions: [Boolean, Choice(n), Score],
     │    input: <shared context> }
     ▼
Vercel AI Gateway  ──► request logs / budgets
     │                 decision fallbacks (失败降级)
     ▼
Microsoft AI Decision-1.1
     │
     ▼
{ prob: 0.83, choice: "billing", scores: {...} }
     │
     ├─ prob > 0.9  ──► 自动执行
     ├─ 0.5 ~ 0.9   ──► 标记复核
     └─ < 0.5       ──► 升级人工 / 走 fallback 模型
```

这张图里最值钱的不是模型，是最后那三分支。**决策模型的存在意义就是把「要不要人工介入」变成一个可调参数**，而不是写死在 prompt 里的主观判断。

## 实用评估

### 什么场景值得用

- **客服工单/请求分流**。工单进来到哪个队列、紧急度几分——这是教科书级的 Choice + Score 组合，且量大、单价敏感，专模模型省下的成本很直接。
- **Agent 的模型路由**。官方明确列了 "choosing which model should handle a request"。你自己搭 router 时，用决策模型替代「让大模型自己说要谁处理」能少一轮往返。
- **Workflow 下一步选择**。"selecting the next step in a workflow" —— 对状态机式的 agent workflow，这是把分支判断从 prompt 里搬出来的标准动作。
- **AI 回复评审/打分**。grading AI responses 需要稳定可比的分数，Score 类型比「请打 1-10 分并说明理由」可靠得多。
- **需要人体工学的闸门**。凡是你要说「置信度低于 X 就人来看」的地方，优先考虑它——前提是官方宣称的校准在你的数据上成立（**必须先自己验证**）。

### 什么场景不值得用

- **长上下文推理**。判断依赖跨多份文档的推理链时，判别模型的优势会消失，通用推理模型仍是正确选择。
- **需要解释原因**。决策模型吐概率不吐论证。如果下游需要「为什么」，你还得再调一次生成模型。
- **低频、低量任务**。为一天十次的判断引入新模型接入、新 SDK 版本约束（ai 7.0.128+ / Python SDK 3.26.0+）、新计费项，不划算。
- **零容错场景**。校准再好也是概率，不能替代确定性规则校验。
- **对供应商 lock-in 敏感的路径**。挂在 AI Gateway 上意味着可观测性与 fallback 都绑在这层抽象上；虽然有 decision fallbacks 兜底，但迁移时这层是要重新设计的。

### 迁移成本

- **从 Decision-1 迁**：几乎为零——改 model id 即可，官方明说请求格式一致。
- **从「通用 LLM 当分类器」迁**：中等。真正的工作量不在调用，而在**把 prompt 里那些隐含判断重写成显式问题**（Boolean 怎么写、Choice 的选项集怎么定、Score 的量程怎么定），以及重新标定阈值。建议先在一条低风险链路上做影子对比，用自己的历史数据跑一遍，确认概率分布与实际命中率的关系，再切流量。
- **SDK 前置**：TypeScript 需 `ai 7.0.128+`；Python 需 OpenAI SDK `3.26.0+`。老项目升级 SDK 的连带影响要单独评估。

## 对你的意义

对 Ken 的 Agent + UI 线，这件事的价值不在于「又多了个模型」，而在于**它把 Agent 里最难测的那部分——分支判断——变成了可度量、可调参、可做回归测试的对象**。

具体建议：

1. **立刻做**：翻一遍你现有 Agent 的 prompt，把所有「请你判断是否…」的段落列出来。如果超过 3 处，说明你有 router 债。
2. **本周做**：挑一条量最大的分支（大概率是「这条请求该怎么处理」），用 Decision-1.1 的影子模式跑 3-5 天，画出「模型概率 vs 实际结果」的可靠性曲线。这是唯一能证明「校准更好」对你有意义的方式——官方那句话对你不构成证据。
3. **观望的部分**：不要为了一个分类任务重写整个 Agent 架构。决策模型是一个**可插拔部件**，先插在一个点上。
4. **跨域提示**：VLA 侧同样有类似模式——动作选择、是否触发人类接管、轨迹质量评分，本质上都是「判别」而非「生成」。Decision 这类模型的工程范式（结构化输出 + 校准 + 阈值化）在具身智能的 safety gate 设计中值得借鉴，虽然目前这类模型只处理文本输入。

判断：**值得试用，不值得重仓**。它是工程卫生工具，不是能力跃迁。

## 关键代码/配置片段

> 以下代码结构依据官方 changelog 说明整理；具体请求体字段请以 Decisions API 文档为准，本处不虚构字段名。

模型切换，唯一的必要变更：

```text
microsoft/decision-1.1
```

三类问题类型（官方定义）：

```text
Boolean : the probability that a condition is true
Choice  : a selected category and probabilities for each option
Score   : a numerical rating on a scale you define
```

多问题共享输入的调用形态（示意，字段名待以官方文档核对）：

```text
{
  "model": "microsoft/decision-1.1",
  "input": "<shared context>",
  "questions": [
    { "type": "boolean", "question": "Is this request urgent?" },
    { "type": "choice",  "question": "Which team should handle it?", "options": ["billing", "tech", "sales"] },
    { "type": "score",   "question": "Quality of the draft reply", "min": 1, "max": 5 }
  ]
}
```

> TODO: 官方 changelog 未给出请求体的精确 schema，实际字段（如 questions 的 key 名、Score 的量程参数名）需以 https://vercel.com/docs/ai-gateway/modalities/decision 为准。

SDK 版本前置：

```text
TypeScript : ai 7.0.128 or later
Python     : OpenAI Python SDK 3.26.0 or later
```

阈值闸门（工程模式，非官方示例）：

```text
if (p >= 0.90)            -> auto_act()
else if (p >= 0.50)       -> flag_for_review()
else                      -> escalate_to_human()
```

---
[← Back to Deep Dives](./README.md)
