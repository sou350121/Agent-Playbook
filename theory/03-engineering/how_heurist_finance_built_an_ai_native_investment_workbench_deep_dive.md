---
auto_generated: true
generated_at: "2026-09-14T03:30:38Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/how-heurist-finance-built-an-ai-native-investment-workbench-on-amazon-bedrock-agentcore/"
signal_type: "significant_update"
---
# 用 AgentCore 构建 AI 原生投资工作台：Heurist Finance 的支付/记忆/沙箱架构拆解 (How Heurist Finance built an AI-native investment workbench on Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-14
>
> **项目/工具**: Amazon Bedrock AgentCore（案例方：Heurist Finance）
> **链接**: https://aws.amazon.com/blogs/machine-learning/how-heurist-finance-built-an-ai-native-investment-workbench-on-amazon-bedrock-agentcore/
> **核心定位**: 一个零售投资研究产品如何用「按查询付费的付费数据 + 沙箱分析 + 跨会话记忆 + 端到端审计」把机构级工作流塞进一次对话

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Heurist Finance 用 Amazon Bedrock AgentCore 的托管能力（Identity / Memory / Code Interpreter / Observability / payments）搭出一套「按问题买数据、在沙箱里算、带审计轨迹」的 AI 原生投资工作台。
- **現在值得用嗎**：看场景。如果你在做**需要付费数据、需要可审计、又不想自建身份与支付基础设施**的 Agent 产品，这个架构值得照着抄；如果只是内部问答或单租户工具，AgentCore 这套托管栈是过度设计。
- **適合場景**：多租户 Agent 产品、需要 per-query 采购付费第三方的数据密集型 Agent、有合规/审计诉求的金融/医疗类 Agent。
- **不適合場景**：单用户内部工具、无法接受 USDC/区块链结算的法务环境、对成本极度敏感且数据源免费的场景。
- **與「自建 LLM 编排栈」核心差異**：把身份、跨会话记忆、沙箱隔离、支付编排从「几个月自研」变成托管服务——Heurist 自称省了约 80% 的 agent 系统工程。

## 是什么 / 解决什么问题

零售投资者面对的是一个资源鸿沟：统一的「风险—收益」视图、全组合构建、情景分析这些能力，长期只存在于机构终端里。Heurist（自然语言金融智能平台）想把这些能力塞进一个聊天体验：抓市场数据、读财报与新闻、做深度研究、构建并压测组合、监控持仓，而每一个回答都要基于**用户自己的持仓与偏好**。

真正的痛点不是「接个大模型就完事」，而是数据的经济学与合规的工程学。Heurist 用的高端数据（市场、宏观、基本面、另类数据）大多在付费墙和定制 API 后面，没有任何单一供应商覆盖全部。在用户规模起来之前，签企业合同在财务上说不通——**按问题买需要的数据**才是更合理的经济模型。

但这立刻引出一个更硬的工程问题：Agent 需要代表用户花钱，同时强制执行托管、消费上限与审计要求。每个动作都必须能映射到具体的用户、会话与请求；身份要贯穿整个工作流；还需要跨会话状态、隔离的代码执行、支付编排与端到端追踪。自研这套基础设施要花几个月，而且会分掉团队做研究流程和个性化的精力。这正是 Heurist 选择 AgentCore 的原因。

## 技术架构拆解

### 核心设计决策

- **编排层用 Strands + Anthropic Claude**：Agent 编排交给开源的 Strands agents 框架，推理用部署在 Amazon Bedrock 上的 Anthropic Claude。也就是「框架与模型可替换」——AgentCore 不绑定特定框架或模型，这正是它作为平台的卖点。
- **付费数据用「按查询付费」而非「订阅/合同」**：通过 AgentCore payments，每一次对第三方数据源的请求都单独结算，避免了预付和企业级合同的前期成本。
- **结算走 x402 协议 + USDC on Base**：付费请求遵循 x402（HTTP 402 支付）协议，最终以 USDC 稳定币在 Base 区块链网络结算，经由 Coinbase CDP Payment Connector 完成。
- **花钱被显式限额**：每次交互对应一个 Payment Session，带 `maxSpendAmount` 字段作为该次运行的消费上限；超出即中止并告知用户。
- **身份贯穿每一次服务调用**：AgentCore Identity 把认证用户带到每个服务调用，并在每个工具调用、支付、记忆操作里记录 user ID、workload identity、request ID、trace ID，形成一条跨服务的审计轨迹。
- **分析在无网络出口的沙箱里跑**：AgentCore Code Interpreter 在隔离沙箱中执行相关性分析、情景分析、图表与回测，**没有任意网络出口**，分析结束即销毁。
- **凭据从不进入业务代码**：支付凭据存放在 AWS Secrets Manager，由 Payment Connector 在运行时取用。
- **Guardrails 双向过滤**：Amazon Bedrock Guardrails 同时过滤输入与输出——输入侧拦截针对支付与数据工具的 prompt injection，输出侧强制「不推荐单一未对冲个股」的产品政策。

### 与前版/竞品的关键差异

| 维度 | 自建 LLM 编排栈 | Heurist 的 AgentCore 方案 |
|------|----------------|--------------------------|
| 身份与访问 | 自建 preference store + 访问控制层 | AgentCore Identity，OAuth + 按用户作用域的凭据 |
| 跨会话状态 | 自建数据库与记忆逻辑 | AgentCore Memory，按用户绑定偏好/论点状态/对话历史 |
| 代码执行 | 自建沙箱与隔离 | AgentCore Code Interpreter，无任意网络出口，结束即销毁 |
| 付费数据采购 | 企业合同 / 预付 | AgentCore payments，按查询付费（x402 + USDC on Base） |
| 可观测性 | 自建日志与追踪 | AgentCore Observability，跨服务统一 trace，合规问题一次查询可答 |
| 工程投入 | 数月自研 | Heurist 估计节省约 80% 的 agent 系统工程 |

### 架构/信息流图

```
                     用户提问（"今天的 PCE 数据对我的组合有什么影响？"）
                                     │
                                     ▼
                    ┌───────────────────────────────┐
                    │   Strands 编排器                │
                    │   (Anthropic Claude on Bedrock) │
                    └───────────────────────────────┘
                       │        │         │        │
        读取组合数据    │  身份贯穿 │  沙箱计算 │  付费数据采购
                       ▼        ▼         ▼        ▼
          Aurora PostgreSQL   AgentCore  AgentCore  AgentCore payments
          (组合数据)           Identity   Code       ├ Payment Manager
                                          Interpreter├ Payment Connector (Coinbase CDP)
                                                    └ x402 → USDC on Base
                                       │
                    分析产物 → Amazon S3（图表等）
                    追踪 → Amazon CloudWatch
                    凭据 → AWS Secrets Manager（运行时取用）
                    输入/输出过滤 → Amazon Bedrock Guardrails
```

一次用户提问可以同时组合价格、宏观指标、财报、基本面与新闻，然后在其上跑相关性、情景分析、图表或回测。付费数据请求的时序是：先请求 → 商家返回 HTTP 402 及 x402 支付条款（金额、收款方、资产 USDC、网络 Base）→ AgentCore payments 校验是否超出 `maxSpendAmount` → 在预算内调用 Process Payment API，经 Payment Instrument 签名 → 带 `X-PAYMENT` header 里的支付证明重试请求 → 商家返回数据。

## 实用评估

### 什么场景值得用

- **多租户 Agent 产品**：身份、记忆、审计是天然的横切关注点。AgentCore Identity + Memory 省掉了「再建一套偏好存储与访问控制」的工作。
- **需要按查询采购付费数据的 Agent**：x402 这套「先 402、再签名、再重试」的流程，把「按需买数据」变成可编程的，而不是商务谈判的。适合数据源分散、单买贵、合同签不起的早期产品。
- **有合规/审计诉求的垂直 Agent**：每个工具调用/支付/记忆操作都带上 user/request/trace ID，合规问题「一次查询可答」。金融、医疗这类必须解释「谁在什么时候基于什么数据做了什么」的场景直接受益。
- **小团队想快速验证「AI 原生」产品形态**：Heurist 的定位就是小团队把精力放在差异化研究流程上，而非底层系统。

### 什么场景不值得用

- **单用户/内部工具**：没有多租户身份与支付需求时，AgentCore 的托管栈属于过度设计，直接自建轻量编排更省。
- **无法接受区块链结算的环境**：最终结算走 USDC on Base，法务或合规上不接受加密资产结算的组织基本被排除。
- **数据源免费或已签好企业合同**：如果不需要 per-query 采购，payments 模块的价值大幅下降。
- **成本极端敏感**：托管服务的便利对应的是持续的平台使用成本；Heurist 强调的是「可预测的 per-user 边际成本」，但这是相对自建的对比，不等于绝对值低。

### 迁移成本

- 若你已在用 Strands 或其他框架编排、模型跑在 Bedrock 上，接入 AgentCore 的横切能力（Identity / Memory / Code Interpreter / Observability）是**渐进式**的——官方明确 AgentCore 支持任意框架与模型，不必重写编排逻辑。
- 若要启用 payments：需要接入 Payment Manager、Payment Connector（如 Coinbase CDP），并处理 x402 协商流程与 USDC/Base 结算链路。这是新增的**支付通道工程量**，也是需要法务确认的部分。
- 数据面需要把组合/用户数据落到 Aurora PostgreSQL 之类的关系库，分析产物落 S3，凭据进 Secrets Manager。
- Heurist 的量级参考：官方博文称约省 80% 的 agent 系统工程。这是**案例方自述**，不是第三方基准，**待独立验证**。

## 对你的意义

这条案例的价值不在「又一个 Agent 应用」，而在它把 **Agent 的「花钱能力」**当成一等公民来设计——这恰好是当前 Agent 工程化里最缺一块拼图的领域。

- **如果关注 Agent + UI / 工作流**：Heurist 的形态是「一个聊天入口 + 后台一堆机构级工作流」，是典型的「对话式工作台（chat workbench）」范式。值得留意它如何把「风险—收益统一视图、全组合构建、情景分析」这些重操作折叠进单轮对话——这是 Agent UI 设计里「重操作轻界面」的一个样本。
- **如果关注 RAG / 工具链**：x402 的「HTTP 402 协商 → 签名 → 带证明重试」其实是**工具调用的支付化**。把它和 MCP 之类的工具集成标准放一起看，会出现一个组合命题：工具不仅被调用，还能被**按次计费**。这可能是「Agent 经济体」最基础的一层协议。
- **如果关注评估与安全**：Guardrails 双向过滤 + 全链路审计 ID 是「可解释 Agent」的落地样板。尤其「输出侧强制不推荐单一未对冲个股」——这是把**监管/产品政策编码进输出约束**，而不是靠提示词祈祷。
- **建议**：若你短期不涉及付费数据或多租户合规，**先跳过 payments，但把 Identity/Memory/Code Interpreter/Observability 的设计模式记下来**——这四件套几乎是任何生产级 Agent 的通用骨架。payments 部分观望，等 x402/Agent 支付的生态与法务环境更明朗再评估。

## 关键代码/配置片段

源材料未给出完整代码，但明确描述了关键配置与流程要素（以下为对官方描述的复述，非可运行代码）：

支付会话与消费上限（概念性）：

```
# 每次交互获得一个 Payment Session
Payment Session:
    maxSpendAmount: <该次运行的消费上限>

# 校验逻辑（3. 步骤）
if charge > PaymentSession.maxSpendAmount:
    告知用户并建议替代方案   # 不在预算内不支付
else:
    调用 Process Payment API   # 经 Payment Instrument 签名
    以 X-PAYMENT header 携带证明重试请求
```

x402 协议约定的返回（概念性）：

```
HTTP 402
payment terms:
    amount:    <金额>
    recipient: <收款方>
    asset:     USDC
    network:   Base
```

审计字段（每个工具调用/支付/记忆操作记录）：

```
user_id | workload_identity | request_id | trace_id
```

---

[← Back to Deep Dives](./README.md)
