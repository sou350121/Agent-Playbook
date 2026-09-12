---
auto_generated: true
generated_at: "2026-09-12T06:46:07Z"
source_url: "https://www.36kr.com/p/3972641004843521"
signal_type: "significant_update"
---
# OpenAI 研究加速：AI 研究实习生上岗，3.1 倍工时与 RSI 的实证刻度 (Research Acceleration: The View Inside OpenAI)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-12
>
> **项目/工具**: OpenAI「自动化 AI 研究实习生」（Coding Agents for AI R&D）
> **链接**: https://openai.com/index/research-acceleration-view-inside-openai/
> **核心定位**: OpenAI 首次公开内部数据，证明编码 Agent 已把研究组织的人机工时比推到 3.1:1，并宣告"自动化研究实习生"里程碑达成——同时给出了 RSI（递归自我改进）的第一份工程刻度。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：这不是一个新产品发布，而是 OpenAI 用一手工程数据回答"Agent 到底有没有真的加速 AI 研究"——答案是"有，但集中在中低层劳动，且仍需人扶"。
- **现在值得用吗**：看你想要什么。想要**方法论／评估范式**（如何度量 Agent 对生产力的真实贡献）→ 强烈推荐精读；想要**能下载的工具**→ 没有，这不是开源项目。
- **適合場景**：Agent 产品负责人定 OKR/度量体系、研究者设计"人机协作"实验记录、投资/战略判断 RSI 叙事真伪。
- **不適合場景**：想找可直接部署的 coding agent；想复现 benchmark；想拿它当"AGI 已来"的证据链（官方口径远比自媒体克制）。
- **與一般"Agent 提效"文章的核心差異**：它给的是**内部真实账单与成功率曲线**（包含失败与干预率），而不是 demo 或自评。

## 是什么 / 解决什么问题

2026 年 9 月 7 日，OpenAI 发布官方长文《Research acceleration: The view inside OpenAI》，首次系统性公开其研究部门使用编码 Agent 的内部数据。背景是一个长期悬而未决的问题：**"Agent 提效"一直停留在体感和 demo 层面，缺乏可对外披露、可复现的度量**。OpenAI 这次的核心动作，是把内部指标——推理开销、Agent 工时、任务成功率、干预率——摊开来，作为"迈向 RSI"的公开刻度。

官方明确的里程碑定义是：去年秋天（2025 年 10 月）Sam Altman 立下的"2026 年 9 月造出自动化 AI 研究实习生"，**按 OpenAI 自己的测量已达成**。所谓"研究实习生"（research intern），官方定义是：**能在人类给定方向下，独立完成定义清晰的研究任务，包括熟练研究员需要几天才能完成的任务**。下一个节点是 **2028 年 3 月造出"自动化 AI 研究员"**，届时它需自主立项、规划路线、闭门推演数周。

需要泼一盆冷水的地方：**中文自媒体把这篇长文与黄仁勋"AGI 已来"的喊话打包成"AGI 时代开启"，这属于叙事放大**。官方原文的口径恰恰相反，反复强调"我们尚不知如何安全地走到完全对齐的 RSI"、"不能假设对齐与安全进展能跟上"，并披露了因安全事件**暂停 RL 训练**的事实。读这篇的正确姿势是读数据，不是读标题。

## 技术架构拆解

### 核心设计决策

- **用"账单"而非"能力榜单"度量进展**：OpenAI 选择公开每位研究员的**推理开销**（按 API 价格折算），而不是发布某个 coding benchmark 分数。理由是前者难以造假、可直接反映真实用量。
- **用工时比而非 token 数作为主指标**：把研究组织内所有 Agent 总运行时长折算成标准 8 小时工作日，与人类工作日对比——得到"3.1 个 Agent 工作日 / 1 个人类工作日"。
- **借用第三方分类法（Epoch AI 的 R&D taxonomy）**：把研究生命周期拆成 Decide / Design / Build / Run / Analyze / Communicate 六阶段，再把 Agent 产出的 token 归类，从而回答"活到底干在哪一层"。
- **主动披露失败与干预率**：官方明确给出"过去 6 个月，超过一半成功的 4–8 小时任务，中途至少需要人类干预 1 次"。把负面指标写进官方文档，是这份报告最值得学的地方。
- **安全事件驱动的节奏控制**：在 Hugging Face 事件后，OpenAI 暂停了面向部署的最新模型的 RL 训练，7 月 20 日关闭了训练用容器服务，并在强化限制后逐步恢复。

### 与前版/竞品的关键差异

| 维度 | 常见"Agent 提效"叙事 | 本报告（OpenAI 内部数据） |
|------|----------------------|--------------------------|
| 证据来源 | Demo / 自评 / 抽样 | 内部真实账单 + 全量用量 + 成功率曲线 |
| 主指标 | 任务完成时间下降 X% | 人机工时比（3.1:1）、推理开销（人均/日） |
| 失败披露 | 通常缺失 | 明确给出干预率与长任务成功率 |
| 任务分层 | 单一 benchmark | 按"人类预计耗时"分桶（<15min / 4–8h / 32h+） |
| 语气 | "AGI 已来" | "仍需人类设定优先级，且不知如何安全走向 RSI" |

### 架构/信息流图

```
研究员（人类）
   │  设定方向 / 判断取舍 / 决定是否扩缩、暂停、部署
   ▼
┌─────────────────────────────────────────────┐
│            Coding Agent 会话层                │
│  （并发：>4 个 Agent 的研究员占比 30%→70%+）    │
└─────────────────────────────────────────────┘
   │  产出 token，按 Epoch AI 六阶段归类
   ▼
Decide → Design → Build → Run → Analyze → Communicate
  ↑ 增量最小            ↑ 增量最大（研究与基建代码、
  （决策类 <1000 tok/日）  技术求助、启动/监控训练，>13 万 tok/日）
   ▼
内部技术求助频道发帖量：2025 年 ~20/日 → 2026 年 8 月 个位数
（提问对象从人变成 Agent，一个团队干脆解散了 Office Hour）
```

## 实用评估

### 什么场景值得用

- **设计 Agent 度量体系**：直接照搬"工时折算 + 人类预计耗时分桶 + 干预率"三件套，比自评问卷靠谱得多。
- **判断 RSI 叙事真伪**：报告给出了增速的**边界**——Agent 吃掉的是劳动密集型环节，战略决策层"极少"被替代。这比任何"AGI 已来"的口号都更有信息量。
- **AGI/RSI 议题的政策与传播研究**：OpenAI 明确呼吁"要求企业公开追踪 RSI 进展"，这是可引用的立场文件。

### 什么场景不值得用

- **想找能跑的代码/工具**：本文不含任何开源组件或 API 文档，链接指向的是官方博客正文。
- **想做 benchmark 复现**：成功率曲线只给了趋势与图，未给出完整数据集与评测脚本；具体分桶数字（如 <15 分钟任务 60%→90%）来自**中文媒体对图表的解读**，官方正文未逐字给出，需标为待验证。
- **想证明"Agent 可完全接管研发"**：恰恰相反，32 小时以上长任务的零干预成功率仍只有约 20%，4–8 小时任务过半需要人工干预。

### 迁移成本

这份材料本身不需要"迁移"。若要把其中的方法落进自己的团队：

- **最小可行版**：把每个 Agent 会话的运行时长、任务预估人类耗时、是否需人工干预三项记录下来，一周即可建立基线。工作量：半天搭表 + 持续录入。
- **进阶版**：接入你的 coding agent 日志，按类 Epoch AI 的分类法给 token 打标，得到"活干在哪一层"的分布。工作量：约 1–2 人日，取决于日志是否结构化。
- **注意**：OpenAI 自己承认"这些测量仍是初步的（preliminary）"，且不同组织基线不可直接横比。

## 对你的意义

对 Ken 的两条线都有直接价值：

1. **AI App 线（Agent + UI）**：这份报告最可复用的是**度量范式**。你在做 Agent 工具链与评估时，"人机工时比 + 人类预计耗时分桶 + 干预率"是一个可直接引用的成熟框架。它还隐含一个产品判断：**并发多 Agent 调度**是当前价值密度最高的一环（>4 Agent 并发的占比一年内翻倍以上），这与你的 "visual workflow / agent builder" 方向高度契合。
2. **VLA 线**：同样是"AI 加速 AI 研究"，OpenAI 的六阶段拆解（尤其"Run：训练/评估运行、硬件、服务"这一层）与 VLA 的"训练任务启动与监控"是可以互译的。可以留意：**越是长线、越是跨阶段的任务，人类干预率越高**——这与 VLA 后训练（RL/世界模型）阶段"仍高度依赖人调"的现状一致。

**具体建议**：立即精读原文（链接在文首），重点是第 1、2、3 节的数据口径；**观望**任何"AGI 已来"的转述。若你要设计自己的 Agent 效率看板，直接把"干预率"作为一等指标——这是多数团队缺失、而 OpenAI 特意披露的一项。

## 关键代码/配置片段

本文不含可运行代码。以下为官方口径的关键原文引用（便于引用与核对）：

```
"By 'research intern,' we mean a system that can carry out well-defined
 research tasks under human direction, including tasks that would take a
 skilled researcher a few days. We are making strong progress toward
 creating an automated AI researcher by March of 2028."
```

```
"Before June 2026, total agent runtime across the research organization was
 still below that of total human labor. That has since changed. In terms of a
 standard 8 hour workday, as of mid-August, in total, the research
 organization uses 3.1 agent-workdays of effort for every workday of human
 labor."
```

```
"the 90th percentile user in our research organization now uses more than
 $7,000 of tokens per day"  # 中位研究员 > $600/日（按 API 价格折算）
```

六阶段分类法（Epoch AI R&D taxonomy，官方引用）：

```
Decide      → what to work on, what to continue, where to allocate
Design      → research ideas and engineering specs
Build       → code and datasets
Run         → training/eval runs, hardware, serving
Analyze     → experiments, models, deployment, external work
Communicate → findings, feedback, status, decisions
```

> TODO: 具体分桶成功率（<15 分钟任务 60%→90%；4–8 小时 20%→50%；32 小时以上约 20%）与"人均输出 token 增至年初 124 倍""代码改动量 7 倍"">4 并发占比 30%→70%"等数字，来自新智元对官方图表的解读（36 氪转载），官方正文未逐字给出，引用时建议标注"据图表解读、待官方数据佐证"。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | 15 分钟以内碎片任务的零干预成功率据图表解读已达约 90%，超过 80% 阈值；但 4–8 小时任务仅约 50%、长任务约 20%，说明"达标"目前只适用于**短时初级任务**，中长任务仍差得远。 |

---
[← Back to Deep Dives](./README.md)
