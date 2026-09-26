---
auto_generated: true
generated_at: "2026-09-26T06:45:54Z"
source_url: "https://vercel.com/changelog/pixel-canary-is-now-available-in-stealth-for-free-on-ai-gateway"
signal_type: "blog_post"
---
# Pixel Canary 登陆 Vercel AI Gateway：隐身编码模型借 AGENTS.md 追平 Next.js evals 榜首 (Pixel Canary Now Available in Stealth on Vercel AI Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-26
>
> **项目/工具**: Vercel AI Gateway — stealth/pixel-canary
> **链接**: https://vercel.com/changelog/pixel-canary-is-now-available-in-stealth-for-free-on-ai-gateway
> **核心定位**: 一个尚未揭名的前沿编码模型，以限时免费方式接入 AI Gateway，在 Next.js evals 上以 90.3% 追平 GPT-6 Astra，配上 AGENTS.md 文档后冲到 96.8% 榜首水平。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Vercel 把一个匿名/隐身（stealth）编码模型 Pixel Canary 上架到 AI Gateway，主打前端与移动端界面代码生成，stealth 期间限时免费。
- **現在值得用嗎**：值得，但**只在你接受 prompt 可能被用于训练**、且需要大量前端/Next.js 编码的场景下立即试用。
- **適合場景**：Next.js / React 前端开发、App Router 迁移、响应式布局与交互组件生成、既有前端代码重构、在 coding agent（如各类 CLI agent）里换模型做 A/B 对比。
- **不適合場景**：任何涉及敏感/私有代码或客户数据的任务（该模型**不支持 ZDR**）、需要长期稳定版本契约的生产流水线、非前端为主的纯后端/算法任务（官方未给出此类 benchmark）。
- **與 GPT-6 Astra (high) 核心差異**：基线同为 90.3%，但 Pixel Canary 在「喂入 Next.js 文档（AGENTS.md）」时能到 96.8%，说明它对上下文文档注入的敏感度/收益更明显；且它是隐身免费模型，Astra 是正式商业模型。

## 是什么 / 解决什么问题

Vercel 在 changelog 中宣布，[Pixel Canary](https://vercel.com/ai-gateway/models/pixel-canary) 已以 `stealth/pixel-canary` 的标识上线 [AI Gateway](https://vercel.com/ai-gateway)，并在隐身（stealth）阶段**限时免费**开放。所谓 stealth，通常指模型厂方尚未公开真实身份与正式版本号，先借托管平台放出让开发者试用的状态——你调的是它，但你还不知道它是谁。

它的定位非常明确：**擅长 coding，包括从零构建应用和重构既有代码**，并且**特别适配前端开发与移动端 App 设计**——覆盖响应式布局、应用界面（app screens）、导航以及可交互组件。这延续了 2025–2026 年一个清晰的趋势：编码模型从「通用代码补全」转向「面向界面/产品级实现的 agentic coding」，重点不再是单函数正确率，而是能否把一整个界面/页面/迁移任务端到端做对。

对 Ken 这类**既是研究者又是开发者**的使用者来说，这件事的意义有两层。第一层是工具层：你现在可以在自己的 coding agent 里零成本切换到一个疑似前沿的编码模型，做最直接的实战验证。第二层是信号层：Vercel 用 AI Gateway 作为「模型分发+评测+成本管控」的中间层，正在把「模型选择」变成可插拔的运行时决策——这本身就是 Agent 工程栈里值得关注的架构范式。

需要先讲清楚的是：本条目**没有任何关于模型规模、训练数据、许可证、推理成本或延迟的数据**，官方 changelog 只给了 evals 结果与接入方式。因此本文不会编造这些数字，缺失处一律以 `> TODO` 标注。

## 技术架构拆解

### 核心设计决策

- **以 stealth 别名分发**：模型通过 `stealth/pixel-canary` 这个统一标识接入，开发者不需要知道底层供应方，也不绑定任何单一模型厂商。这降低了「换模型」的迁移成本，同时让平台方能在模型转正后平滑替换底层。
- **限时免费引导试用**：stealth 阶段免费（"free for a limited time while in stealth"）是典型的冷启动策略——用零成本换取真实流量与 eval 数据，同时换取开发者心智。
- **用 AGENTS.md 承接上下文工程**：官方明确给出「把 Next.js 文档通过 AGENTS.md 注入」能显著提升成绩（90.3% → 96.8%）。这意味着该模型对 **agent 上下文文件（AGENTS.md）作为知识注入通道**有正向响应，和当前 Agent 生态「用 AGENTS.md 固化项目规范/文档」的主流实践高度契合。
- **不做 ZDR**：官方明说 ZDR（零数据保留）对该模型不可用，且 prompt 与响应「可能被用于训练和模型改进」。这是 stealth 免费换取的代价，也是一条硬性合规红线。
- **接入即统一 API**：AI Gateway 提供统一调用接口，附带用量与成本追踪、API key 预算（budgets）、路由规则（routing rules）。也就是说，换模型不需要改调用协议，只需要改 model 名。

### 与前版/竞品的关键差异

| 维度 | GPT-6 Astra (high) | Pixel Canary (stealth) |
|------|--------------------|------------------------|
| Next.js evals 基线成功率 | 90.3%（未给出高文档设定下的对照） | 90.3%（28/31 任务） |
| 配 AGENTS.md 注入 Next.js 文档 | 待确认 | 96.8%（30/31 任务），追平该设定下榜首 |
| 覆盖能力 | 通用前沿模型 | 编码 + 前端/移动端界面设计特化 |
| 计费（stealth 期间） | 正式商业计价 | 限时免费 |
| ZDR / 数据保留 | 以其自身条款为准 | **不支持 ZDR，prompt 可能用于训练** |
| 接入方式 | 通过 AI Gateway 统一 API | 同左，model 设为 `stealth/pixel-canary` |
| 模型身份 | 公开 | 隐身（stealth），真实来源未公开 |

> 注：表中 GPT-6 Astra 一行仅列官方 changelog 提到的信息，未给出的项目标注为待确认，不做推测填充。

### 架构/信息流图

```text
开发者 / Coding Agent
        │
        │ 统一调用（model = stealth/pixel-canary）
        ▼
┌─────────────────────────────────────────┐
│           Vercel AI Gateway             │
│  ┌────────────┐  ┌───────────────────┐  │
│  │ 路由规则   │  │ 用量/成本追踪      │  │
│  │ routing    │  │ usage & spend     │  │
│  └────────────┘  └───────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ API key 预算 budgets              │  │
│  └───────────────────────────────────┘  │
└───────────────────┬─────────────────────┘
                    │ 转发（stealth 别名）
                    ▼
        ┌──────────────────────────┐
        │  stealth/pixel-canary    │
        │  （底层供应方隐身）       │
        └──────────────────────────┘
                    ▲
                    │ 上下文注入
        ┌──────────────────────────┐
        │  AGENTS.md（Next.js 文档） │
        │  90.3%  →  96.8%          │
        └──────────────────────────┘
```

关键点在于：**AGENTS.md 这条注入链路，直接把一个模型的 eval 成绩从 90.3% 拉到 96.8%**。这再次验证了「agent 上下文文件 > 单纯 prompt 微调」在真实编码任务里的杠杆效应。

## 实用评估

### 什么场景值得用

- **前端/Next.js 实战验证**：官方 eval 覆盖 App Router 迁移、数据获取（data fetching）、图片与字体优化、缓存（caching）、视图过渡（view transitions）等具体任务。如果你手头正好有这类需求，可以直接拿它跑一轮 pass@4 对比。
- **在 coding agent 里做模型 A/B**：配合 `vercel ai-gateway setup`，命令会自动探测已安装的 agent、签发或复用 AI Gateway key，并配置连接。换模型只需在其模型配置里选 `stealth/pixel-canary`，非常适合做「同任务跨模型」对照实验。
- **成本敏感的探索性开发**：stealth 期间免费，适合用真实项目量做压力测试、观察它在自己代码库上的实际表现，而无需担心账单。
- **前端重构**：官方点明它「擅长重构既有代码」，对遗留前端现代化改造是有针对性的。

### 什么场景不值得用

- **任何含敏感数据的工作**：**不支持 ZDR，且 prompt/响应可能被用于训练**。客户代码、私有仓库、含 PII 的数据——不要送进去。这是硬红线，不是权衡项。
- **依赖稳定版本契约的生产流水线**：stealth 模型的真实身份、转正时间、弃用节奏都未公开，把它挂在关键路径上等于接受「随时可能消失或改行为」的风险。
- **纯后端/非界面任务**：官方只给了前端与移动端界面方向的 eval，未见后端、算法、数据管线等 benchmark。用在这些场景属于未经证实的领域。
- **需要可预测成本与延迟的规模化调用**：`> TODO: 该模型在 stealth 转正后的定价、rate limit、上下文窗口、延迟均未在 changelog 中披露`，规模化前必须自行实测。

### 迁移成本

从「用 GPT-6 Astra」迁移到「用 Pixel Canary」的成本**极低**，因为两者都走 AI Gateway 统一 API：

1. 安装/升级 Vercel CLI：`npm i -g vercel@latest`
2. 运行 `vercel ai-gateway setup`（自动探测 agent、签发 key、配置连接）
3. 在 agent 的模型配置里把模型改成 `stealth/pixel-canary`

如果本来就用 AI Gateway，理论上只需改一个 model 字符串。真正的工作量不在接入，而在**验证**：跑你自己的工作集，确认它对 AGENTS.md 的响应、以及它在敏感数据边界上是否被正确隔离。

## 对你的意义

对 Ken（Agent + UI 方向）来说，这条信号的价值大于「又一个模型上架」：

1. **UI/前端方向多了一个免费的前沿选择**。你的关注点本就是 agent builder、visual workflow、chat UI——这些都是重前端实现的方向。Pixel Canary 显式把「应用界面、导航、交互组件」列为主打场景，值得在你的 UI 工具链里当一次候选模型实测。
2. **AGENTS.md 作为上下文杠杆被再次证实**。90.3% → 96.8% 的跃升说明：在 agentic coding 里，把项目文档/规范固化进 AGENTS.md 的收益，可能比换更强模型还直接。这和你「信息自动变成知识，知识可查询、可累积」的理念一致——AGENTS.md 就是项目知识的可注入形态。
3. **AI Gateway 的「中间层」范式值得纳入 landscape**。统一 API + 用量追踪 + key 预算 + 路由规则，这是把「模型选择」从硬编码变成运行时可插拔的工程答案。它不是模型，但它是 agent 工程栈里的基础设施层，符合你维护 `app-index` 的分类价值。

**具体建议**：**立即试用，但限定在非敏感的项目上**。用一次真实的 Next.js/UI 任务做 pass@4 对照，重点观察两件事：(a) 它在你的 AGENTS.md 注入下是否也出现类似跃升；(b) 免费窗口关闭/模型转正后它的行为是否稳定。**不建议**把它挂到任何含私有代码或客户数据的流程里。

## 关键代码/配置片段

以下配置片段**直接引用自官方 changelog**，未做任何改写：

设置模型为 stealth 别名：

```text
stealth/pixel-canary
```

在 coding agent 中接入（官方给出的步骤）：

```bash
npm i -g vercel@latest

vercel ai-gateway setup
```

官方对该命令的说明原文（引用）：该命令 "detects installed agents, provisions or reuses an AI Gateway API key, and configures their connection to the gateway"，随后在 agent 的模型配置中选择 `stealth/pixel-canary`。

评测口径（原文引用）：成绩使用 **pass@4**——"a task passes if any of up to four attempts succeeds"；基线为 28/31 任务通过（90.3%），注入 Next.js 文档后为 30/31（96.8%）。

> TODO: 模型上下文窗口、定价、吞吐/延迟、ZDR 转正后是否开放，均未在官方 changelog 中披露，需以转正公告为准。

---
[← Back to Deep Dives](./README.md)
