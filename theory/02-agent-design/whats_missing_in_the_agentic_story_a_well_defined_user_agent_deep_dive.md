---
auto_generated: true
generated_at: "2026-04-30T05:47:00Z"
source_url: "https://www.mnot.net/blog/2026/04/24/agents_as_collective_bargains"
signal_type: "significant_update"
---
# Agentic AI 缺少什么：一个明确定义的用户代理角色 (What's Missing in the 'Agentic' Story: A Well-Defined User Agent Role)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-30
>
> **项目/工具**: Mark Nottingham 博客 — IETF 编辑对 Agentic 架构的底层批判
> **链接**: https://www.mnot.net/blog/2026/04/24/agents_as_collective_bargains
> **核心定位**: IETF 首席编辑 Mark Nottingham 从互联网标准视角指出：Agentic AI 当前最大的缺失不是模型能力，而是一个被明确定义的"用户代理"（User Agent）角色——没有它，AI 代理无法建立用户与服务端之间的双向信任。

## 快速判断

- **一句话定位**: IETF 编辑 Mark Nottingham 撰文指出，当前 Agentic AI 的架构讨论忽略了互联网 30 年积累的核心教训——浏览器作为"用户代理"所做的集体议价（collective bargaining）功能，AI 代理需要同等机制
- **现在值得用吗**: 是——这篇文章是理解 AI 代理信任模型的最佳框架性论述之一，适合所有构建或评估 AI Agent 产品的人阅读
- **适合场景**: Agent 架构设计、AI 安全策略制定、理解 AI 代理与用户/服务端三方信任关系
- **不适合场景**: 寻找具体工具实现或代码教程——这是概念层论述，不是工程指南
- **与同类文章核心差异**: 不是从 AI/ML 视角，而是从互联网协议设计视角审视 Agent 信任问题，提供了浏览器→AI 代理的类比框架，这在 AI 社区讨论中非常罕见

## 是什么 / 解决什么问题

Agentic AI 的叙事建立在一个看似不言自明的前提上：LLM + 工具调用 = 你的代理，它会代表你的利益行动。这个前提如此自然，以至于几乎没有人质疑它。

Mark Nottingham 的文章直接挑战了这个前提。他的核心论点可以概括为：

> 当前的 AI 代理模型是"相对简单的"（relatively simplistic），因为缺乏一个被明确定义的用户代理角色——没有透明、公开的标准来嵌入对交互双方的制衡。这使得 marketplace 难以形成。

文章从三个层次展开论证：

1. **历史回顾**: 计算史上长期存在"机器代表用户利益"的假设，这个假设在本地计算时代基本成立
2. **信任崩塌**: 互联网时代，企业系统性利用信任漏洞——TV 监控用户、Meta 解密私人流量、Microsoft 窃取第三方邮箱密码……这些不是边缘案例，而是常态
3. **浏览器作为用户代理**: Web 浏览器是互联网没有彻底崩溃的原因——它作为用户代理，在用户和网站之间做集体议价，而不是让用户逐个谈判

然后他抛出核心问题：**AI 代理缺少浏览器这个角色。**

## 技术架构拆解

### 核心设计决策

文章的核心洞察不是技术性的，而是**架构哲学**性的。他提出了一个对比框架：

| 维度 | Web 浏览器（成熟模型） | AI 代理（当前状态） |
|------|----------------------|-------------------|
| 角色定义 | 明确的"用户代理"——代表用户利益与网站交互 | 无统一定义——"只是一个概念" |
| 信任机制 | 浏览器在用户和网站间做集体议价，嵌入全球性条约 | 每次交互都需要用户重新信任，无集体保障 |
| 标准制定 | W3C/IETF 透明共识流程，多方参与 | 各公司自行定义，无公开标准 |
| 市场选择 | 多个浏览器可选，形成市场竞争压力 | 用户被迫接受供应商定义的代理行为 |
| 数据可见性 | 网站知道浏览器会做什么，有预期框架 | 数据源不知道代理会怎么处理数据——可能存储、重发布、滥用 |
| 监管可读性 | 已有成熟框架（GDPR、CCPA 等直接适用） | 监管难以介入，因为角色定义模糊 |

### 信任崩塌的证据链

文章列举了 8 个具体案例说明信任崩塌已经常态化：

| 案例 | 信任 violation | 后果 |
|------|---------------|------|
| 智能电视 | 未经同意监控用户活动 | 德州起诉主要厂商 |
| Meta | 解密研究用户手机上的 Snapchat 流量 | 诉讼 |
| Facebook + Netflix | 允许 Netflix 访问用户私人 DM | 诉讼 |
| Microsoft Outlook | 秘密发送第三方邮箱密码到云端 | 与 700+ 数据经纪商共享 |
| 汽车制造商 | 收集详细驾驶数据并分享给保险公司 | 几乎找不到不违反信任的汽车 |
| Ring (Amazon) | 安全实践松散，内部人员和黑客滥用摄像头访问 | FTC 和解 |
| Grindr | 未经同意分享 HIV 健康信息给第三方 | 用户寻求赔偿 |
| Photobucket | 强行修改 ToS 允许 AI 使用用户照片 | 法庭上失败 |

这些案例的共同模式：**企业利用用户"这台设备是我的"这一心理假设，在用户不知情的情况下将信任扩展到第三方。**

### 浏览器作为用户代理的架构

文章的核心类比——浏览器如何做到集体议价：

```
┌─────────────────────────────────────────────────┐
│                   用户 (User)                    │
│  "这是我的电脑，我的数据"                          │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│            Web 浏览器 (User Agent)               │
│                                                  │
│  职责:                                           │
│  1. 代表用户利益 — 隔离网站、限制追踪、保护数据     │
│  2. 代表网站利益 — 确保页面可预测渲染              │
│  3. 在 W3C/IETF 框架下做集体议价                  │
│  4. 结果对所有人一致 — 不是逐个谈判                 │
│                                                  │
│  关键: 嵌入"全球条约"，不是"个案合同"              │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│                  网站 (Site)                     │
│  知道浏览器会做什么 → 可预期 → 可信任              │
└─────────────────────────────────────────────────┘
```

### AI 代理缺少的架构层

```
当前 AI 代理模型:

┌──────────┐     ┌──────────────────┐     ┌──────────┐
│   用户    │────▶│  AI 代理 (黑盒)   │────▶│  数据源   │
│          │     │  无统一定义       │     │          │
│  "这是我的│     │  无制衡机制       │     │ 不知道   │
│  代理"    │     │  无透明标准       │     │ 代理会    │
│          │     │  无集体议价       │     │ 怎么处理  │
└──────────┘     └──────────────────┘     │  数据     │
                                          └──────────┘

缺失: 没有浏览器那样的中间层来代表用户做集体议价
```

### 为什么 TEE/沙箱方案不够

文章特别反驳了一种常见方案——把 AI 代理关进 TEE（可信执行环境）或沙箱：

> Some proposals for AI agents assume that putting agentic code in a TEE or similar 'jail' will solve these problems, but that ignores the need to collectively bargain — if agents can ask for intrusive permissions, we're pretty much guaranteed a world where they constantly bug us for them.

核心问题：**技术隔离不等于信任机制。** TEE 可以防止代理访问你的文件系统，但它不能防止代理要求你授予 intrusive permissions——而用户会在不断的权限请求中疲劳，最终放弃判断。

## 实用评估

### 什么场景值得用这个框架

- **Agent 架构设计**: 如果你在构建面向消费者的 AI 代理产品，这个框架帮你识别信任模型的盲区——你的代理如何代表用户利益？谁来制衡？
- **企业 AI 策略**: 文章明确指出，"在有限领域内有预设信任的代理——如企业内部及其第三方供应商——可能在没有明确用户代理角色的情况下蓬勃发展"。企业内 Agent 可以靠合同关系调节，但面向消费者的 Agent 不行。
- **AI 安全/合规**: 文章指出定义用户代理角色可以让代理"对法律监管更具可读性"——这是 AI 安全监管的前瞻性思考
- **理解行业格局**: 文章引用 The Economist 对 Meta/Amazon/OpenAI 的分析，揭示了这些公司实际上有动机把 AI 体验锁在封闭平台内——理解这一点有助于判断哪些 Agent 产品是开放的、哪些是围墙花园

### 什么场景不值得用

- **寻找具体技术方案**: 文章没有给出 AI 用户代理的具体实现方案，只说"可能需要全新平台，也可能 AI 能力被有机地添加到 Web 中"
- **短期工程决策**: 这是一个架构哲学论述，不是立即可以执行的工程计划
- **技术选型对比**: 不比较具体 Agent 框架（LangChain vs CrewAI vs AutoGen 等）

### 迁移成本

这不是一个可以"迁移"到某个工具的建议——它是一个**思考框架**。迁移成本在于：

- 重新审视你构建的 Agent 的信任模型：你的代理如何代表用户利益？
- 与合规/法务团队讨论：你的 Agent 行为是否可以被监管"读取"？
- 在产品设计中考虑三方信任（用户-代理-数据源），而不仅是用户-代理 的双边关系

## 对你的意义

这篇文章对 Ken 的双线工作都有意义：

**AI 应用开发线**: 你关注的 Agent + UI 方向，这篇文章提供了一个底层视角——Agent UI 不只是交互设计问题，更是信任代理的可视化问题。用户如何知道他们的 Agent 在代表谁的利益？这个问题在 UI 层如何表达？

**VLA 研究线**: 虽然文章聚焦软件 Agent，但"用户代理"的概念对具身智能同样适用——当机器人代表用户行动时（如家庭服务机器人），谁来制衡它的行为？它的"集体议价"机制是什么？

**建议**: 这篇文章值得精读并纳入 Agent-Playbook 的理论基础部分。它提供的浏览器→AI 代理类比框架，在中文 AI 社区几乎看不到同等深度的讨论。

## 关键代码/配置片段

文章没有提供代码，但有几个关键引用值得记录：

**关于用户代理的定义**（引用 W3C）:
> A User Agent is software that acts on your behalf, representing your interests in your interactions with other parties.

**关于集体议价的必要性**:
> In the bargain between big sites and individual users, the sites have more bargaining power and therefore users' interests need to be considered holistically — not on a case-by-case basis where sites can chip away at them. A browser embeds what is effectively a global treaty between sites and users.

**关于封闭平台的风险**（引用 The Economist）:
> It is no accident that Meta is interested in smart glasses... For Meta, more time spent on its platforms means more ad revenue. Amazon would likewise be delighted to have its Echo speakers in every home... And OpenAI would be well served if people ditched their screens and relied instead on a chatbot to handle their interactions with the digital world.

---
[← Back to Deep Dives](./README.md)
