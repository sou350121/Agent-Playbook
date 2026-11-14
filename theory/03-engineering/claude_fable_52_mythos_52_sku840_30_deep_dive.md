---
auto_generated: true
generated_at: "2026-11-14T03:30:46Z"
source_url: "https://www.anthropic.com/claude-fable-and-mythos-5-2"
signal_type: "significant_update"
---
# Claude Fable 5.2 / Mythos 5.2：同底模双 SKU 的工程学分账 (Claude Fable 5.2 & Mythos 5.2: One Base Model, Two SKUs)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-14
>
> **项目/工具**: Claude Fable 5.2 / Claude Mythos 5.2（Anthropic）
> **链接**: https://www.anthropic.com/claude-fable-and-mythos-5-2
> **核心定位**: 同一个底模，按「安全门槛」切成两个产品 SKU——Fable 面向所有人（带网安/生物双护栏），Mythos 只对通过验证计划的机构开放。同时价格下调到 $8/$40，输出速度提升最多 30%。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Anthropic 把「能力」和「可访问性」彻底拆开卖——底模只有一个，差别只在护栏与授权流程。
- **現在值得用嗎**：**看场景**。绝大多数日常编码/知识任务应该留在 Opus 5.5，只有当任务被模型规模卡住（跨仓库迁移、长时程 agent、科研计算）才值得往上跳。
- **適合場景**：大规模代码迁移、多 agent 编排（Orchestrator/Advisor 模式）、科研/数学形式化、机器人评测、需要「一个模型演完所有角色」的量化研究流程。
- **不適合場景**：日常补全、简单 RAG、成本敏感的高频调用（Fast mode 是 $16/$80，涨一倍）；以及任何需要网安/生物能力的民用场景——Fable 会直接挡掉。
- **與 [競品/前版] 核心差異**：相对 Fable 5.1，SWE v2 从 56.3% → 69.9%，FrontierCode 2.0 从 32.4% → 49.1%，但价格从上一代的档位往下探到 $8/$40。

## 是什么 / 解决什么问题

Anthropic 这次发布的重点，与其说是「又一代模型」，不如说是**一次产品形态的定型**。官方文档第一句就说得很直白：Fable 和 Mythos 是同一个底模。Fable 带强力的网络安全和生物学护栏，所以可以开放给所有人；Mythos 去掉那部分护栏，只对通过 Life Sciences / Cyber Verification Program 的机构开放。以前「太危险」和「太贵」是两个分别解决的问题，现在被合并成一个授权工作流。

第二个变化是定价结构。$8/M 输入、$40/M 输出——官方说这是「更低的价」。同时输出速度比 Fable 5.1 / Mythos 5.1 快最多 30%。这对高频 agent 循环意义比绝对价格更大：agent 的延迟是串联的，每一步快 30%，一个 50 步的任务感知延迟差距远不止 30%。

第三个变化藏在产品定位里：**官方明确劝你大多数时候别用它**。「对大多数编码和知识任务，我们建议从 Claude Opus 5.5 开始」，然后按复杂度往上切到 Fable/Mythos，或往下切到 Sonnet/Haiku 5.5。这是一个诚实的成本建议，也意味着模型家族已经形成「分层调度」的语法——不再是「一款最强模型打天下」，而是「一个模型家族 + 路由器」。

## 技术架构拆解

### 核心设计决策

- **单底模 + 双护栏策略**：护栏不是另一个模型，而是同一权重上的输出过滤/拒答层。证据在于系统卡和 benchmark 表里 Mythos 5.2 与 Fable 5.2 在非敏感任务上分数几乎一致，仅在 CyScenarioBench、CVE Rediscovery、binder design 等敏感项上 Mythos 明显更高（且标注了 "without safeguards"）。
- **Fast mode 作为独立计费维度**：不是新模型，是同一模型的加速通路，价格翻倍（$16/$80），最高 2.5x token 生成速度。把「延迟」做成可购买的 SKU，而不是让所有人共担算力成本。
- **模型可扮演 Advisor / Orchestrator**：Fable 5.2 可以当 Advisor（被 Haiku/Sonnet/Opus 咨询）或 Orchestrator（把简单任务下派给小模型）。这是把「模型路由」从应用层收回到模型层。
- **Effort 分级（Medium/High/Xhigh）**：官方数据显示 Medium 是 Claude app 和 Claude Code 的默认档；在 FrontierCode 2.0 上，Fable 5.2 @ High 大致等于 Opus 5.5 @ Max，成本约为后者一半。也就是说，**调 effort 比换模型更划算**。
- **防蒸馏的最强保护**：官方明确称这次用了「有史以来最强的防蒸馏攻击保护」——这是对模型家族被外部蒸馏复制的直接回应。

### 与前版/竞品的关键差异

| 维度 | Fable 5.1 / Mythos 5.1 | Fable 5.2 / Mythos 5.2 | Opus 5.5（官方推荐日常档） |
|------|------------|------------|------------|
| SWE v2（agentic coding） | 56.3% | **69.9%** | 62.3% |
| FrontierCode 2.0（Xhigh effort） | 32.4% | **49.1%** | 45.5%（高 effort 档） |
| AutomationBench（业务工作流） | 31.4% | **51.4%** | 42.5% |
| OSWorld 2.1（computer use） | 83.5% | **89.3%** | 87.2% |
| RoboDojo Sim（机器人） | 27.6% | **64.9%** | 39.4% |
| Humanity's Last Exam（带工具） | 65.6% | **74.2%** | 67.7% |
| Chartography（无工具读图） | 44.8% | **73.4%** | 64.4% |
| 定价（输入/输出 每百万 token） | — | **$8 / $40** | 见官方定价页 |

数据来源：Anthropic 官方发布页 benchmark 表（2026-11-13/14）。同表竞品：GPT-6 Astra 在 SWE v2 为 65.5%、FrontierCode 2.0 为 42.8%；Gemini 4 Carbon 分别为 61.2% / 41.1%（均为各自最高可用 effort）。注意 Gemini 在 AutomationBench 上为 53.9%，高于 Fable 5.2 的 51.4%——**这是少数 Fable 不占优的项**。

RoboDojo Sim 从 27.6% → 64.9% 是这张表里最陡的一条曲线，且官方注明该 benchmark 是内部跑的、取最高可用 effort 档。对做具身智能的方向来说这条值得留意，但内部评测 + 最高 effort 的组合意味着数字偏乐观，不宜直接当外部可复现结论用。

### 架构/信息流图

```
                     ┌─────────────────────────────┐
                     │   单一底模（一个权重）        │
                     └──────────────┬──────────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
     ┌────────▼────────┐                        ┌─────────▼─────────┐
     │  Fable 5.2      │                        │  Mythos 5.2       │
     │  网安 + 生物护栏 │                        │  无护栏           │
     │  公开可用        │                        │  需验证计划授权    │
     └────────┬────────┘                        └─────────┬─────────┘
              │                                           │
     ┌────────▼───────────────────────────────────────────▼─────────┐
     │  调用层：effort 档（Medium / High / Xhigh）× fast mode（可选）│
     │  价格：$8/$40 标准  |  $16/$80 加速                          │
     └────────┬────────────────────────────────────────────────────┘
              │
     ┌────────▼──────────────────────────────────────┐
     │  在家族中的角色：                              │
     │  · 主力模型（Opus 5.5）的 Advisor —— 被咨询    │
     │  · 多 agent 的 Orchestrator —— 下派简单任务    │
     └───────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **跨语言/跨服务的生产级迁移**。官方给的案例：一队 agent 用早期版 Fable 5.2 把关键生产服务从 Python 迁到 Rust，启动速度约快 26 倍。这类任务的瓶颈通常不是「写不对」，而是「改不完 + 不敢改」，正是长时程 agent 的甜区。
- **多 agent 编排**。1,000 个 Fable 5.2 agent 用 30 小时完成费马大定理的形式化，而 Opus 5.5 在同样 1,000 agent 设置下 18 小时只完成 26%。更关键的是：Fable 5.2 从极简 prompt 出发**自己发明了协调方式**，而且用的 action token 只有首次形式化的三分之一，产出的证明短 7 倍。这是「模型自己设计多 agent 协议」的一个可观测样本。
- **需要判断力而非模板的业务工作流**。AutomationBench 31.4% → 51.4%（+20 分）是相对能力提升幅度最大的一项，说明它更会处理模糊指令下的多步骤业务逻辑。
- **量化研究与分析**。Jump Trading 的反馈：Fable 5.2 在一次运行中同时担任 code-writer、coordinator、planner、job-submitter，之前需要大量人力重新平衡角色分工。对建自己的研究 harness 的人来说，这是个有用的信号——**单模型多角色**正在替代「多模型拼装」。

### 什么场景不值得用

- **高频、低复杂度的调用**。$40/M 输出在小模型面前毫无竞争力；官方自己都说大多数任务从 Opus 5.5 起步。
- **需要网安或生物能力的民用/研究流程**。Fable 会挡掉大部分网络安全任务——这不是 bug 是设计。要 Mythos 得走 Cyber Verification Program，有审核周期。
- **延迟敏感且预算敏感的在线服务**。Fast mode 是 2.5x 速度但价格翻倍；不在 Fast mode 下，「输出快 30%」也改变不了 $40/M 的成本结构。
- **对评测数字要求外部可复现的场景**。RoboDojo Sim 为内部运行、取最高 effort 档；部分 benchmark 混用了不同 effort 等级，跨模型直接比较要打折扣。

### 迁移成本

从 Fable 5.1 / Mythos 5.1 上来基本是零成本：同一个 API、同一个模型名家族，只改版本号。真正的工作量在**架构层**：

1. 重新审视 effort 档位——很多团队会把所有调用钉在 Xhigh，而在 FrontierCode 2.0 上 High 档已接近 Opus 5.5 Max 的效果、成本约一半。
2. 如果之前用「小模型做分派器」的架构，可以评估把 Orchestrator 角色交给 Fable 5.2，让分派和判断用同一个上下文。
3. Mythos 需要走验证计划申请，务必提前评估审核时间是否影响项目排期。

估算：纯换版本号约 1 小时；重新设计 effort/路由策略是 1–2 天的实验工作。

## 对你的意义

对 VLA 研究线：RoboDojo Sim 从 27.6% → 64.9% 是这篇发布里和具身智能最直接相关的一条。官方描述是「即使是从未显式训练过的机器人任务，控制能力也显著提升」，并把 RoboDojo 定位为「从相机图像控制模拟双臂机器人」的 benchmark。这个数字说明**通用大模型的视觉-动作泛化正在逼近专用机器人系统**（官方称其超过多数专为控制机器人构建的 AI 系统）。但要注意三点：模拟而非真机、内部运行、最高 effort 档。作为方向性信号有价值，作为可复现基线不足。建议的动作：去 https://robodojo-benchmark.com/ 取公开 harness 的自测结果，而不是只引用官方数字。

对 AI 应用线：**这次发布最重要的工程含义不是模型能力，而是「模型家族 + 路由」的正式成立**。Advisor/Orchestrator 两个角色被产品化，意味着如果你的 agent 框架还在硬编码「用哪个模型」，这层抽象已经过时了。更值得注意的是多 agent 协议的自生成——Fable 5.2 在费马定理任务里自己发明协调方式、token 消耗降到三分之一。如果你的多 agent 框架里有大量手写的工作分配逻辑，这是值得重新审视的理由：上层协议可能该由模型自己长出来，框架只提供隔离和预算控制。

建议：**观望 + 小范围试点**。不必现在重写任何东西，但可以做两件低成本的事：(1) 把现有 agent 流程里最「改不完」的那个任务（大规模重构、跨文件迁移）拿来跑一次 Fable 5.2 @ High effort，对比 Opus 5.5 @ Max 的成本和成功率；(2) 在架构里预留 effort 档作为参数，而不是常量。

## 关键代码/配置片段

官方发布页未给出具体 SDK 调用代码。文档中可确认的配置面如下（原文表述，非代码）：

```
模型名：claude-fable-5-2 / claude-mythos-5-2（Mythos 仅限验证计划机构）
价格：    标准  $8  / M input  ·  $40 / M output
          fast  $16 / M input  ·  $80 / M output（最高 2.5x 生成速度）
effort：  Medium（Claude app / Claude Code 默认） | High | Xhigh
角色：    Advisor（被 Haiku/Sonnet/Opus 咨询）
          Orchestrator（向小模型下派子任务）
护栏：    Fable = 网安 + 生物；Mythos = 关闭，需授权
```

> TODO: 补充 Anthropic API 文档中 effort 参数的正式字段名与取值范围。
> TODO: 补充 Fast mode 的开启方式（请求参数名待确认）。
> TODO: Advisor / Orchestrator 的 SDK 接入示例见 code.claude.com/docs/en/advisor 与 platform.claude.com/docs/en/managed-agents/multiagent-orchestration，需单独核对。

另一个值得记录的数字：官方称 Anthropic 核心代码库中，**超过 90% 的合并改动现在由 Claude 编写**（配合人类指导）。这是一个关于「AI 写 AI」的自指数据点，也是解释为什么这代模型在编码基准上跳这么快的线索。

---
[← Back to Deep Dives](./README.md)
