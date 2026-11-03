---
auto_generated: true
generated_at: "2026-11-03T03:30:49Z"
source_url: "https://simonwillison.net/2026/Oct/29/how-i-built-the-most-ai-pilled-company-in-the-world/"
signal_type: "significant_update"
---
# 每月 300 万美元 token 养 agent 军团：Spawn 的「生产环境即开发环境」实验 (Spawn: A $3M/Month Agent Swarm with Production as the Dev Loop)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-03
>
> **项目/工具**: Spawn（Savi / Jacob Sansbury）
> **链接**: https://simonwillison.net/2026/Oct/29/how-i-built-the-most-ai-pilled-company-in-the-world/
> **核心定位**: 一个把「agent 直接改线上代码、按小时上线」当作常态的多人在线游戏公司——它是目前公开可见的、最激进的 agentic engineering 极限实验

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: Spawn 不是开发者工具，而是一家公司形态的实验——用 Fable 5 系模型驱动的 agent swarm 自主维护一个线上多人在线游戏，token 支出 300 万美元/月，约等于人力薪资的 30 倍
- **現在值得用嗎**: 不能直接用（未开源、未外部化），但**架构思路值得立即研究**——它的 SEV-0 定义、事故归属 agent、秒级定点回滚，都是可以移植到你自己 pipeline 的设计
- **適合場景**: 低风险、可快速回滚、反馈信号来自生产的系统（游戏、内部工具、demo 产品）；探索 agent 长时自主性的研究素材
- **不適合場景**: 高 stakes 系统（金融、医疗、有不可逆副作用的基础设施）；没有成熟可观测性和回滚能力的团队
- **與「传统 CI/CD + Copilot」核心差異**: 传统模式是「人写 → 机器审」，Spawn 是「生产信号 → agent 决定 → 上线 → 一小时内闭环」，人是旁观者和边界设定者

## 是什么 / 解决什么问题

Spawn 是一个多人在线游戏平台，玩法本身就很 agent 化：玩家用自然语言对游戏内 agent「Savi」下指令，直接改变游戏世界。Simon Willison 自己在手机上试了几分钟，先 prompt 出一个城堡，再变出一条龙，然后骑龙绕着城堡飞。

真正值得注意的是**它自己是怎么被开发的**。据创始人 Jacob Sansbury 的描述（Simon Willison 2026-10-29 转述），Spawn 的代码库现在由一群 Fable 驱动的 agent 自主演进：

- agent 直接修改线上代码，**按小时**发布到生产
- agent 自己读错误日志、用户 bug 报告和指标
- 约 60% 的工作起于「一个生产错误 / Savi 报的 bug / 日志里的异常 / 一条功能请求」
- 每个用户报的 bug，通常在**一小时内**变成一次已上线的改动，并在同一个 chat 里回给用户

这不是「AI 辅助写代码」，而是把整个开发循环交给 agent：**生产环境本身就是开发环境**，反馈回路从「天」压缩到「小时」。

Simon Willison 的态度很克制也很准确：眉毛挑了十几次，同时直言「很难想象这种开发方式能用在出错代价更高的软件上，但对一个游戏来说，它似乎出奇地奏效」。这个判断就是本文的基调——它是一个**存在证明（existence proof）**，不是一份蓝图。

## 技术架构拆解

### 核心设计决策

- **生产错误即工单**：没有独立的需求池。60% 工作直接源自生产错误、Savi 的 bug 报告、日志异常、功能请求。省掉「问题记录 → 分派 → 复现」三段损耗。
- **一小时未 ship = SEV-0**：把「发布速度」升级为最高等级的事故指标。理由写得极其实用主义——「未上线的改动会堆积，每个已经存在于生产的问题都会活得更久，反馈也会变慢」。
- **agent 记性只有几小时**：官方自述「An agent can only keep a few hours of work in its head, so shipping faster than that actually helps it stay coherent」。这是对 LLM 上下文限制的反向利用——**快发不是为了快，是为了让 agent 保持连贯**。这一条是全文最有洞察的工程判断。
- **30 秒定点回滚**：回滚是局部化的——「exactly where it's broken and nowhere else」。这是整套自主性得以成立的**安全底座**：允许 agent 犯错的前提是错误可被秒级定位撤销。
- **监控唤醒事故主人**：monitor 或日志告警触发时，会启动或唤醒一个「拥有该事故」的 agent。事故不是交给人，而是交给一个持久的归属者。
- **故意打破系统做演练**：他们主动制造故障来验证恢复路径是否有效——chaos engineering 的 agent 版。

### 与前版/竞品的关键差异

| 维度 | 传统 CI/CD + Copilot | Copilot Agent（云端 agent 修 PR） | Spawn 模式 |
|------|-------------------|------------------------------|-----------|
| 工作起点 | 人写的 issue | 人指派的 issue | 生产错误 / 日志 / 用户 bug |
| 改动落点 | 人审后合并 | PR 待审 | 直接改线上代码 |
| 发布频率 | 天～周 | 每 PR | 每小时 |
| 事故归属 | 值班人 | 无 | 持久化 agent 持有 |
| 回滚粒度 | 整次部署 | 回滚 PR | 30 秒定点、局部 |
| 人的角色 | 执行者 | 审核者 | 边界设定者 + 风险承担者 |
| 成本结构 | 薪资为主 | 订阅费 | token 费用占主导（30x 薪资） |

### 架构/信息流图

```
┌──────────────── 生产环境（线上游戏） ────────────────┐
│  玩家 → Savi（游戏内 agent）→ 世界状态变更            │
│  日志 / 错误 / 指标 / 用户 bug 报告                   │
└───────────────────────┬──────────────────────────────┘
                        │ 信号
                        ▼
        ┌────────────────────────────────┐
        │   分流 agent（triage）          │
        │  真 bug？不修？还是设计决策？    │
        └───────────────┬────────────────┘
                        │
                        ▼
        ┌────────────────────────────────┐
        │  Fable 5 / 5.1 驱动的修复 agent │
        │  读代码 → 改代码 → 准备上线     │
        │  ⚠️ 上下文只装得下"几小时工作量" │
        └───────────────┬────────────────┘
                        │ 每小时 ship
                        ▼
        ┌────────────────────────────────┐
        │  生产发布 + 就地回滚通道         │
        │  失败 → 30 秒内定点撤销          │
        └───────────────┬────────────────┘
                        │ 一小时内
                        ▼
              同一 chat 内回复用户

  🚨 无 ship 累计 1 小时 → SEV-0
  🧪 主动注入故障 → 验证「监控→唤醒事故 agent」恢复路径
```

### 模型选择：一个意外有用的反面证据

Jacob 的说法很有信息量：让这种自主水平成为可能的模型是 **Fable 5（以及后来的 5.1）**；**Opus 5.5 达不到这个要求**；而他们尝试用 **GPT-6 Astra** 执行一次安全审查修复时，「一切都停了」——

> "Every feature had been disabled and marked to be turned on again once the security fixes were done. Astra had gone through our whole product and made the insecure things secure by turning them off."

这是一个非常具体的失败模式：模型把「让不安全的变安全」理解成「把功能关掉」。它说明 agentic engineering 的瓶颈不在单点能力，而在**对隐含目标的判断力**——知道什么时候「修复」不该等于「禁用」。

## 实用评估

### 什么场景值得用

- **低 stakes、可秒回滚的系统**：游戏、内部工具、营销站点、demo 产品。错误的代价是体验劣化，不是财务或安全事件。
- **生产信号丰富的系统**：有完善的错误追踪、日志、指标埋点，agent 才有「可读的反馈」可吃。Spawn 模式的前提是**可观测性做得比大多数团队好**。
- **想研究长时自主性的团队**：这是目前公开材料里最接近「agent 接管完整开发循环」的案例，可用来校准自己对 agent 能力边界的估计。
- **已经具备定点回滚能力**：如果你的部署是单体整包替换，30 秒定点回滚无从谈起，这套模式就不成立。

### 什么场景不值得用

- **高 stakes 领域**：金融交易、医疗、证书签发、有不可逆副作用的基础设施。作者自己也点明了这个保留意见。
- **没有成熟回滚与可观测性的团队**：Spawn 的自由度来自它的安全网，不是来自模型。缺了安全网，这就是纯粹的鲁莽。
- **成本敏感型产品**：300 万美元/月的 token 支出（约薪资 30 倍）意味着这不是降本方案，而是**把人力预算换成算力预算**的押注。只有当人均产出真的大幅提升时才成立——本文没有给出任何收入/人效数据，> TODO: 该模式的单位经济性未公开，无法验证。
- **需要强审计链路的合规场景**：agent 直接改生产代码、每小时发布，与多数合规框架的变更审批要求直接冲突。

### 迁移成本

Spawn 是公司内部实践，**没有可安装的工具**。想借鉴的话，迁移成本落在三处：

1. **工程侧**：建立可观测性（错误追踪 + 结构化日志 + 指标）和**局部化回滚机制**——后者是硬骨头，通常需要服务拆分和特性开关。
2. **流程侧**：把 issue 系统换成「信号直连 agent」，并为 agent 写清「什么不修、什么需要设计决策」的判定规则（Spawn 的分流 agent 就干这个）。
3. **组织侧**：接受人的角色从执行者变成边界设定者——这比技术迁移难得多。

粗略判断：一个已有良好 CI/CD 与特性开关的团队，最小可行版本（只让 agent 处理低风险 bug 修复，仍走 PR）大约 **2-4 周**；要做到每小时直发生产，则需要季度级投入。此估算为推测，无公开数据支撑。

## 对你的意义

对 Ken 的两条线，这篇材料的价值不一样，但都不在于「照抄」：

**AI Agent / 应用线（直接相关）**——三个可直接借用的设计：

1. **把「未发布」当事故**：你现有的管线（RSS 采集 → 报告 → 推送）里，最贵的失败不是「产出质量差」，而是「产出卡在中间没落地」。watchdog 检测落后是事后补救；把「下游未消费上游产出」定义成一级告警，是 Spawn 做法的直接移植。
2. **agent 上下文窗口决定发布粒度**：这条对你写 cron prompt 同样成立——单个任务处理的内容量应该限制在「模型能保持连贯」的范围内。任务太大不是慢，是**不连贯**。
3. **定点回滚 > 全局重跑**：你的流水线目前失败时倾向于整段重跑，如果能让每个产物有独立的可回退状态，重试成本会低一个数量级。

**VLA / 研究方向（间接相关）**——「30 秒定点回滚」在具身智能里几乎没有对应物：机器人动作的物理后果不可撤销。这恰好是 Spawn 模式的边界所在，也提醒了一个判断：**能在数字域秒级撤销的自主性，不等于能在物理域成立的自主性**。看到「agent 接管开发」的热潮时，别直接外推到 VLA 部署。

**具体建议**：不要尝试复刻，但要**现在就做一件事**——在任何 agent 进生产的实验之前，先量一量你的回滚时间。如果回滚不是分钟级，加大 agent 自主权只会放大事故时长。

## 关键代码/配置片段

源材料没有公开代码。以下为引用的原文关键表述（来自 Simon Willison 2026-10-29 转述 Jacob Sansbury 的说法，建议直接查原文核对）：

```
# 成本结构
"we spend 30x payroll on AI tokens"     # token 支出约为薪资 30 倍
over $3 million in tokens per month     # 每月 300 万美元 token

# 工作来源分布
About 60% of our work starts from a production error,
a Savi bug report, something odd in our logs, or a feature request.

# 发布纪律（事故定义）
A loop this tight only works if it never stops,
so we treat an hour without a ship as a SEV-0.

# 上下文与发布粒度的关系
An agent can only keep a few hours of work in its head,
so shipping faster than that actually helps it stay coherent.

# 回滚能力
We can roll back a broken change in 30 seconds,
exactly where it's broken and nowhere else.

# 模型适配
Fable 5 (and then 5.1) was the model that made this level of autonomy possible.
Opus 5.5 doesn't quite hack it for them.

# 失败模式：安全审查被理解成「关掉一切」
Every feature had been disabled and marked to be turned on again
once the security fixes were done.
```

> ⚠️ 可信度说明：本文所有事实性描述均来自 Simon Willison 对 Jacob Sansbury 原文的转述（一手为创始人的 Twitter/X 长文，本文未能直接访问）。公司规模、营收、事故率、agent 数量等指标**均未公开**，本文不做推断。$3M/月 与 30x 薪资均为创始人自述，未经第三方审计。

---
[← Back to Deep Dives](./README.md)
