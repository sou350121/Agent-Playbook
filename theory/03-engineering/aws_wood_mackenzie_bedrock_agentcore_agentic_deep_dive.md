---
auto_generated: true
generated_at: "2026-09-18T12:00:50Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/a-shared-agentic-platform-for-wood-mackenzie-on-amazon-bedrock-agentcore/"
signal_type: "blog_post"
---
# 共享 Agentic 平台实战：Wood Mackenzie 如何用 Bedrock AgentCore 把三个 Agent 项目收敛为一个平台 (A Shared Agentic Platform for Wood Mackenzie on Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-18
>
> **项目/工具**: APEX (Agentic Platform for Energy eXperience) / Amazon Bedrock AgentCore
> **链接**: https://aws.amazon.com/blogs/machine-learning/a-shared-agentic-platform-for-wood-mackenzie-on-amazon-bedrock-agentcore/
> **核心定位**: 用一套托管平台统一 runtime、身份、观测、护栏与连接层，让多个团队共用同一个 Agent 底座，而不是各自重建一遍基础设施。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：能源研究公司 Wood Mackenzie 基于 AWS Bedrock AgentCore 搭建的共享 Agent 平台 APEX——把原本三套并行自建的 agent 栈收敛成一套「平台层 + 业务逻辑」的分层架构。
- **現在值得用嗎**：看場景。如果你所在的组织有 **2 个以上团队**在并行做 agent，且吃的是 AWS 生态，值得认真评估；如果是单人/单团队小项目，用 AgentCore 的托管 runtime 反而增加封套成本。
- **適合場景**：多团队复用（registry/网关）、企业级身份与合规（IAM/OAuth/Entitlements）、需要统一观测与评估的非确定性 agent、模型可替换（model-agnostic）。
- **不適合場景**：纯研究原型（跑得起来就行）、强绑定非 AWS 云栈的团队、对更低层 runtime 完全控制有硬需求、无法接受 serverless 隔离模型的场景。
- **與 LangChain/CrewAI 自建栈的核心差異**：AgentCore 把「托管 hosting + 自动扩缩 + 原生护栏/身份 + 企业 SLA」打包成平台；自建栈给你灵活性但每项能力都要自己运维。

## 是什么 / 解决什么问题

文章开篇给出一个刺眼的数字：**搭建一个能跑的 agent 原型只要一个下午，但让它上生产才是工作量爆炸的地方**。一旦 agent 要服务多个用户，并发、会话隔离、身份、持久状态、扩缩容、护栏这些层就会出现——而大多数团队每次都从头重建。

Wood Mackenzie 自己的经验更直接：**88% 的 AI PoC 从未进入规模化部署**。行业调研（截至 2026 年初）显示企业 AI 实验几乎已经普及，但只有约四分之一组织在**至少一个职能**里把 agent 推上了生产。文章引用 Forrester 的判断：agent 失败主要归因于歧义、协调失调和不可预测的系统行为，而不是普通 bug。被提名最多的单一阻塞点是**评估与可观测性**——团队无法提前判断一个非确定性 agent 什么时候会答错，而标准回归测试抓不到。

APEX 的设计出发点就是把这个问题从「每个团队各修一遍」变成「平台修一次」。在 APEX 之前，Woody、Lens AI、ST Trading App 三个应用各自打算自建 agent 栈——三套 runtime、三套身份、三套观测、三套硬编码的模型。APEX 让这一份基础设施税只交一次，团队专注在差异化业务逻辑上。

## 技术架构拆解

### 核心设计决策

- **托管优先于库**：AgentCore 提供的是托管平台，不是需要自己运维的库。AWS 负责扩缩、打补丁、可用性，平台团队专注在 agent 能力上。
- **模型无关（model-agnostic）**：Claude、GPT-4.1、Amazon Nova、Mistral、Llama 都能通过同一平台访问。团队可以「用 A 模型规划、用 B 模型执行」，或在不改业务逻辑、不丢对话上下文的前提下替换供应商。这是为了应对「某个模型出了 regression 想立刻切走」的场景。
- **原生护栏 + 身份**：内容过滤、PII 检测、策略执行都是托管能力。AgentCore Policy 集成 Gateway，**实时拦截每一次工具调用**，把自然语言规则转成 **Cedar**（AWS 开源的策略语言），让开发、合规、安全团队无需写代码就能编写与审计规则。AgentCore Identity 提供 IAM 集成、VPC 隔离与加密，agent 可以「代表用户」或「以自身身份」在既定访问控制下行动。
- **可组合构建块**：每个能力都是独立积木——可以只取 AgentCore memory，也可以只要 Gateway，或全套组装成自主工作流。定价按服务单独计费，允许团队只采用单个能力而不用整体迁移。
- **计费按活跃消费**：runtime 按每秒活跃 CPU 与内存计费，**I/O 等待期间不计 CPU 费用**。文章指出 agentic 工作负载通常有 **30–70% 的时间在等待**模型响应、工具调用或数据库查询——预分配算力会为这段空闲付费，AgentCore 不会。

### 与前版/竞品的关键差异

文章给出一张选型对比表（原文 Table，来源：AWS 官方 blog）：

| Framework | Hosting | Cost Model | Model Agnostic | Scalability | Governance | Enterprise Support |
|-----------|---------|-----------|----------------|-------------|-----------|-------------------|
| LangChain | Self-Hosted | Free/Enterprise | Yes | Manual | DIY | Community |
| LangChain | Self-Hosted/LangSmith | Free + LangSmith | Yes | Manual | LangSmith | Community |
| CrewAI | Self-Hosted/CrewAI-Cloud | Free/Cloud | Yes | Limited | Basic | Community |
| n8n | Self-Hosted/Cloud | Free/Pro | No | Moderate | Workflow | Community + Pro |
| Frontier Model Direct | Provider-hosted | Per-token | No | Provider-Managed | None | Provider SLA |
| Bedrock AgentCore | AWS managed | Pay-per-use | Yes | Automatic scaling | Native Bedrock Guardrails and Policy | AWS Enterprise SLA |

这张表的关键不是「谁更强」，而是定位差异：**托管层卖的是「不用自己运维」，自建层卖的是「完全掌控」**。

### 架构/信息流图

APEX 的分层结构（基于原文 Figure 1 描述）：

```
┌───────────────────────────────────────────────────────────┐
│  应用层: Woody (内部) | Lens AI (外部) | ST Trading App      │
├───────────────────────────────────────────────────────────┤
│  APEX Frontend SDK  (AG-UI + A2UI 生成式 UI)               │
├───────────────────────────────────────────────────────────┤
│  APEX Backend                                              │
│   AgentCore Runtime  (serverless, session-isolated)        │
│     └─ AI Agents Studio: Strands / LangGraph / CrewAI /    │
│                          n8n / Vertex / OpenAI             │
│   Orchestrator → Woodmac Agent Registry                    │
│   RAG: Amazon Bedrock Knowledge Bases (vector DB)          │
│   AgentCore Memory (短/长期上下文，跨会话)                  │
│   AgentCore Gateway（工具入口）                            │
│      ├─ Code Interpreter / Nova Act web tool               │
│      └─ APIs / Lambda / 既有 MCP servers → 统一工具面       │
│   Bedrock Guardrails + Policy (Cedar)                      │
│   AgentCore Observability (OTel→CloudWatch)                │
│   AgentCore Evaluations (helpfulness/tool/accuracy 打分)    │
├───────────────────────────────────────────────────────────┤
│  基建轨道: WM IaC Framework (AWS CDK + GitHub)              │
│            MCP 层 (对接 AWS Marketplace / 合作方系统)       │
└───────────────────────────────────────────────────────────┘
```

最核心的一个模式是 **hub-and-spoke 的 MCP 网关**：没有它，N 个消费方 × M 个数据服务 = N×M 的点对点集成问题，每个连接都要重建身份、限流、合规等横切关注点。有了它，所有消费方（内部分析师、客户 chatbot、交易 agent）都接到同一个 hub，hub 再扇出到数据服务（Lens Direct、Short Term Trading、Digital Content、P&R Dataset）。**横切关注点在 hub 处只执行一次**，策略一改立即全平台生效。

## 实用评估

### 什么场景值得用

- **多团队并行做 agent 的组织**：Agent Registry + 统一 Gateway 让「一个团队的 agent 变成另一个团队可复用的资产」——解决重复造轮子。
- **强合规/强身份要求的企业**：Entitlements 贯穿每一次 agent 调用（不是只在边缘检查一次），agent 代表用户时把权限一路带到下游工具与数据调用；配合 Cedar 策略语言可审计。
- **需要统一评估与观测的团队**：AgentCore Observability 输出 OpenTelemetry 兼容遥测到 CloudWatch，可以从一个会话追踪到单个 span；Evaluations 内置 helpfulness、tool selection、accuracy 等质量维度评估器。
- **模型频繁切换的团队**：model-agnostic + 模型目录，切换供应商不改业务逻辑、不丢上下文。

### 什么场景不值得用

- **单人/小团队原型**：托管平台的价值在多团队复用与合规，单团队用反而背上平台层的学习与配置成本。
- **非 AWS 生态**：整篇文章的护栏、身份、观测都深度依赖 AWS（IAM、CloudWatch、Bedrock Guardrails、Cognito、Okta 联邦）。
- **需要极低层 runtime 控制**：serverless + 会话隔离意味着你放弃了部分底层掌控权。
- **纯离线/内网极端环境**：虽然 AgentCore GA 时已支持 VPC / PrivateLink / CloudFormation，但托管前提仍是接受 AWS 控制面。
- **成本对 token/CPU 极度敏感**：按活跃消费计费虽省了空闲成本，但高频 agent 的 CPU 计费需实测才能确认比重。

### 迁移成本

从「每个团队各自搭栈」迁移到共享平台，主要工作不在 API 层面，而在**组织与分层**：需要把平台代码与业务逻辑严格解耦（文章称「decoupled evolution」），把身份、限流、合规收敛到 hub。APEX 的六个工程原则（可组合构建块、飞轮、抽象无差别重活、组件化复用、解耦演进、复利价值）本质上是迁移的施工图。文章没有给出具体工时数字，此处 > TODO: 缺少从零到 APEX 的实际投入工时数据。

## 对你的意义

如果你的 Agent + UI 方向正在从「单 agent demo」走向「多团队/多应用复用」，这篇文章的价值在于它把**平台层的抽象边界**说得很清楚：runtime、identity、gateway、memory、observability、evaluation 应该收在平台里，业务逻辑留在团队侧。

几个具体可迁移的点：

1. **hub-and-spoke 网关**几乎是必然选择——N×M 集成问题是所有 agent 平台都会撞上的墙，MCP 作为统一工具面已经被验证可行。
2. **生成式 UI 的 AG-UI + A2UI 组合**尤其契合你的 UI 关注点：AG-UI 做传输（SSE 事件流），A2UI（源自 Google）以 JSON blueprint 描述 UI，由客户端用可信组件目录渲染，避免任意代码执行。这与你追踪的 agent UI / visual workflow 赛道高度相关。
3. **OpenTelemetry 兼容观测 + 内置评估器**是评估与安全工具链的落地方向——非确定性 agent「能不能发现它坏掉」比「它能不能跑」更值钱。

建议：**立即价值中等，优先吸收架构模式而非直接采用**。若团队吃 AWS，可小范围用 AgentCore 的 Memory 或 Gateway 单点试水（平台支持按服务单独计费）；若不吃 AWS，把它当作「平台分层 + MCP 网关 + 生成式 UI」的参考蓝图更有性价比。

## 关键代码/配置片段

文章未给出完整可复制的代码，但披露了关键部署与协议细节（来源：AWS 官方 blog 原文）：

部署到 AgentCore runtime 后暴露的交互端点：

```
POST /invocations   # agent 交互入口
GET  /ping          # 健康检查
```

身份认证通过 AgentCore Identity，使用 **OAuth authorizer，底层由 Amazon Cognito 支撑**；前端凭 bearer token 连接已部署的 runtime 端点。工具调用侧则通过 AgentCore Gateway，支持 **IAM、OAuth 2.1、API key** 三种认证方式。

两个真实工作流示例（原文 Figure 4/5）值得记录：

- **Lens 中的 Synapse AI**：用户在 Power Summary 仪表盘侧边栏用自然语言提问「哪些国家可再生能源装机最多」，agent 调用 `extractWidgetConfig` 工具，读取当前仪表盘排名 widget 的配置与数据，返回一张按国家排序的太阳能+风能装机表——**答案基于用户已经在看的数据**，而不是一次脱节的网络搜索。
- **Woody 的伊朗冲突研究流**：一条自然语言指令触发多工具编排——web 搜索 agent + Lens Direct MCP server + Vega-Lite 图表工具 + PowerPoint 生成器，最终产出 4 张交互图表 + 15 页可下载 PPT。另一个「训练天然气需求模型」流程里，agent 在 `GUIDANCE.md` 需人工复核时**显式暂停**，列出 `train.py` / `inference.py` 所需修复项，未经确认绝不继续——这就是 human-in-the-loop 在 runtime 层的强制约束。

---
[← Back to Deep Dives](./README.md)
