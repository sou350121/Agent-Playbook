---
auto_generated: true
generated_at: "2026-11-24T08:01:12Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/enable-ai-agents-to-pay-for-aws-marketplace-x402-products-with-amazon-bedrock-agentcore-payments/"
signal_type: "significant_update"
---
# AgentCore payments 接入 AWS Marketplace x402：Agent 用 AWS 帐单付美元，告别稳定币钱包 (Agents Pay for AWS Marketplace x402 Products with Amazon Bedrock AgentCore Payments)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-24
>
> **项目/工具**: Amazon Bedrock AgentCore payments + AWS Marketplace connector
> **链接**: https://aws.amazon.com/blogs/machine-learning/enable-ai-agents-to-pay-for-aws-marketplace-x402-products-with-amazon-bedrock-agentcore-payments/
> **核心定位**: 给「会花钱的 agent」补上最后一块企业级拼图——把 x402 按次付费变成 AWS 帐单上的美金行项，不需要稳定币钱包、不需要给 agent 发 API key

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：AgentCore payments 在 2026 年 8 月 GA 时就支持 x402/MPP 协议付费；这次新增的是 **AWS Billing 作为付款方式**，让 agent 能直接在 AWS Marketplace 买 x402 商品，钱记在开发者既有 AWS 帐单上。
- **现在值得用吗**：看你是否需要「生产环境让 agent 自主买东西」。已经在 AWS 上跑 Bedrock/AgentCore 的团队值得；纯云外或只想试玩 agent 付费的，先用 GitHub 范例即可。
- **适合场景**：研究/分析 agent 需要即时付费搜索、付费资料源、付费 API；企业需要采购与审计闭环。
- **不适合场景**：高频微交易（单次最低价与 token 5 分钟 TTL 有摩擦）、非 AWS 的卖家生态、需要动态议价/阶梯计价的商业模式。
- **与前版核心差异**：之前「自主付费」= 要嘛给 agent 塞 API key，要嘛配稳定币钱包；现在 = AWS 帐单 + IAM 角色 + 既有预算/审计工具。

## 是什么 / 解决什么问题

Agent 要真正自主，最后一公里不是「会不会推理」，而是「能不能自己把帐结掉」。过去让 agent 付费有两条路，都不好走：

1. **API key 路线**：开发者把付费服务的 API key 直接写进 agent 的环境变数。好处是简单，坏处是——这个 key 没有用途边界，agent 被注入一个恶意 prompt 就可能用你的 key 去刷单；而且每个卖家一把 key，权限与轮换管理很快就失控。
2. **稳定币钱包路线**：x402 协议原生用加密货币做微支付。技术上优雅，但在企业采购、财务、合规眼里，等于凭空长出一个「没有报销凭证、没有发票、没有供应商入库」的资金池。

这次发布的本质是把第二条路的「付款通道」换成企业已经会用的那条：**AWS 帐单**。Agent 在 AWS Marketplace 上发现一个 x402 商品、被回一个 HTTP 402、拿到签名报价、向 AgentCore payments 换一张付款 token、带著 token 重试拿到内容——整条链路走完，这笔钱会以 AWS Marketplace 行项出现在开发者帐号的月帐单上，并且在 CloudTrail 与 Cost Explorer 里可查。

换句话说，它把「agentic commerce」从一个加密货币话题，变成一个**采购流程话题**。

## 技术架构拆解

### 核心设计决策

- **报价由卖家签名，价格不能改**：卖家回 402 时把签名报价放在 `PAYMENT-REQUIRED` header，AWS Marketplace 用卖家注册公钥验签。报价被改过就直接拒——这一条把「中间人改价」堵死了，是整个信任模型的锚点。
- **付款 token 短命（约 5 分钟）**：token 放在 `PAYMENT-SIGNATURE` header。短 TTL 意味著泄漏窗口小，但也要求 agent 必须在**同一轮**里完成「取报价 → 付款 → 重试兑换」，不能先存起来晚上再花。
- **三套 IAM 角色互相牵制**：官方范例把权限切成 session 角色（能设预算、不能付款）与 agent 角色（能付款、不能开 session）。关键效果是——**agent 没有能力给自己加预算**。这是「防止自动化失控」最朴素也最有效的做法。
- **两层预算**：payment session 有总额上限，另可设单次请求上限（范例预设 session $0.05、单次 $0.02）。预算检查在付款前做，**预算不够时呼叫失败且不扣款**。
- **非同步结算、按月出帐**：首次向某卖家购买时，AWS Marketplace 建立该 AWS 帐号与卖家的协议，之后每次都计量到帐单；结算非同步，行项延迟出现是正常的，不是失败。
- **发现与付款解耦**：AgentCore Gateway 的 AWS Marketplace connector 只提供三个唯读动作（搜寻 listing / 取 listing / 列履约选项），且只返回接受 x402 的端点；不想用 connector 就直接把 `SELLER_URL` 写死给 agent。
- **沿用 Private Marketplace**：企业若有私有市集策略，agent 只能买白名单内的商品——治理不必重新发明。
- **只支持 x402 `exact` 方案**：卖家对每次请求报固定价。这是发布时的明确限制，别指望它处理按量阶梯计价或拍卖式定价。

### 与前版/竞品的关键差异

| 维度 | 之前（GA 版 / API key 路线） | 现在（AWS Billing + Marketplace） |
|------|------------------------||---------------------------|
| 付款媒介 | 稳定币钱包或供应商 API key | AWS 帐单，以 USD 计价 |
| 卖家准入 | 谁开放 x402 端点谁都能收 | AWS Marketplace 验证卖家（含 KYC 流程） |
| 预算控制 | 靠卖家端限额或自行约束 | session 总额 + 单次上限，付款前强制检查 |
| 审计 | 区块链记录或各家后台 | CloudTrail（谁买了什么）+ Cost Explorer（花了多少） |
| Agent 提权风险 | API key 通常无用途边界 | 角色隔离，agent 无权建 session／加预算 |
| 发现能力 | 开发者手写 endpoint | Gateway connector 唯读发现（可选） |
| 计价模式 | 协议理论上可灵活 | 目前仅 `exact`（每次固定价） |
| 对帐凭证 | 加密货币流水 | AWS Marketplace 行项，可入既有采购流程 |

### 架构/信息流图

```
开发者                     AgentCore                    卖家 / AWS
  │                           │                             │
  │ 1. 建 Payment Manager      │                             │
  │    (AWS Billing connector) │                             │
  │──────────────────────────>│                             │
  │ 2. 建 payment session      │                             │
  │    (总额上限 + 单次上限)     │                             │
  │──────────────────────────>│                             │
  │    session ID 交给 agent    │                             │
  │                           │                             │
  │           ┌───────────────┴──────────────┐              │
  │           │ Agent 执行                   │              │
  │           │  (A) Discover: Gateway 唯读搜寻┼─────────────>│ Marketplace
  │           │  (B) Get quote: 呼叫端点无付款 ┼─────────────>│ 回 402 +
  │           │                                │              │ PAYMENT-REQUIRED
  │           │  (C) Pay: ProcessPayment      │              │ (签名报价)
  │           │      type=AWS_BILLING_X402    │              │
  │           │      ──> 检查预算 ──> 发 token │              │
  │           │  (D) Redeem: 带 PAYMENT-        │              │
  │           │      SIGNATURE 重试 ───────────┼─────────────>│ 回内容
  │           │  (E) Settle: 非同步计量         │              │
  │           └───────────────────────────────┘              │ AWS 帐单 / CloudTrail
```

## 实用评估

### 什么场景值得用

- **研究/分析型 agent 需要即时资料**：原本模型知识截止到上周，现在可以现场买一次 Tavily 搜索并在答案里附来源——而且答案能说明「我买了什么、花了多少」。
- **企业想放开 agent 自主权但保留财务控制**：session 预算 + 单次上限 + Private Marketplace 白名单，这三件套让「让 agent 花钱」从风控不可过审变成可过审。
- **采购与审计要闭环**：CloudTrail 记行为、Cost Explorer 看金额、AWS 帐单做对帐。财务不用为「AI 花的钱」另开一套流程。
- **多 agent 环境的成本归属**：每个任务一个 session，预算天然按任务切分，比事后按日志拆帐干净。

### 什么场景不值得用

- **高频微交易**：5 分钟 token TTL 让「先取一批报价、有空再付」这种模式行不通；单次请求都要走一次 402→付款→重试，延迟与复杂度都不适合每秒几十笔的场景。
- **动态定价 / 按量阶梯计价**：目前只支持 `exact` 方案（每次固定价）。需要按 token 数、按资料量阶梯收费的商业模式还没覆盖。
- **卖家生态不在 AWS Marketplace**：想接的资料源若没上架 x402 商品，这套 AWS Billing 通道帮不上，只能退回 `SELLER_URL` 手动指定＋其他付款方式。
- **非 AWS 基础设施**：整套绑 Payment Manager、service-linked role、IAM、CloudTrail，迁移成本实质等于「先把 agent 搬上 AWS」。
- **需要事前精确成本的场景**：结算非同步、按月在帐单出现，代表你事后才知道总帐；即时成本看板要靠 Cost Explorer 的延迟资料。
- **想要可退款/争议处理的采购**：文章没提退款机制。待确认，建议先小额试点。

### 迁移成本

| 动作 | 工作量 |
|------|--------|
| 开通 `AWSServiceRoleForMarketplaceAgenticCommerce` service-linked role | 一次性，几分钟 |
| 建 Payment Manager + AWS Billing connector | 跑 `setup_aws_billing.py` 级别的设定 |
| 切分 session 角色 / agent 角色 / 其他 IAM 角色 | 半天到一天（含权限边界设计与审核） |
| 接 Gateway connector（可选） | 半小时；不接就写死 `SELLER_URL` |
| 改 agent 的付款逻辑：处理 402、取签名报价、调 `ProcessPayment`、重试带 token | 核心改动，1–3 天（依框架而定；范例用 Strands） |
| 验证闭环：CloudTrail / Cost Explorer / Private Marketplace | 半天 |

从「API key 直连」迁过来，最麻烦的不是程式码，而是**IAM 角色切分要通过内部安全审核**——但这正是这套方案存在的理由。

## 对你的意义

我正在追的是「Agent + UI」与工具链工程化。这篇文章的价值不在于「agent 会付钱了」这个新闻点，而在于它展示了企业级 agent 落地的三个通用模式：

1. **权限与意图分离**：能花钱的角色不能改预算，能改预算的角色不能花钱。这个模式可以照搬到任何 agent 工具链（档案写入 vs 审批、部署 vs 核准）。
2. **短命能力凭证**：5 分钟 token + 一次性用途，取代长期 API key。以后设计 agent 调外部服务时，优先想「能不能发一张短命票」，而不是「能不能塞一把 key」。
3. **把新能力塞进既有企业流程**：不是造一套新的 AI 财务系统，而是让交易落到 AWS 帐单/Cost Explorer。企业采购最怕「新增一个要另外对帐的地方」，这点值得记住。

具体建议：**先观望，跑一次 GitHub 范例即可**。目前只支持 `exact` 计价，对大多数 agent 产品来说还太窄；但有两个触发点值得立即跟进——(a) 你的 RAG/搜寻 agent 需要接付费资料源且公司已在 AWS；(b) 出现第一个非 AWS 厂商推出对等的「帐单内付费」方案（那才是 Agentic Commerce 真正成气候的信号）。

## 关键代码/配置片段

以下取自官方 GitHub 范例与文章描述，皆为真实内容，未改写。

建立 Payment Manager 与 AWS Billing connector：

```bash
python setup_aws_billing.py --region us-east-1
```

建立 Gateway + Marketplace connector（可选）：

```bash
python setup_gateway.py --region us-east-1
```

不接 Gateway 时，直接指定卖家端点：

```text
SELLER_URL=<seller endpoint>
```

跑示范 agent（预设 session 预算 $0.05、单次上限 $0.02）：

```bash
python strands_marketplace_agent.py "What was announced about agentic payments this week? Cite sources."
```

一次真实试跑的呼叫序列与花费（来自官方文章）：

```text
Tool calls: search_marketplace -> get_remaining_budget -> search_marketplace
  -> search_marketplace -> get_listing -> get_listing
  -> get_seller_endpoints -> get_seller_endpoints
  -> fetch_paid_api -> get_remaining_budget
Payments this run: 1, total $0.01
```

协议层的关键常数与 header：

```text
付款类型: AWS_BILLING_X402
报价 header: PAYMENT-REQUIRED   (卖家签名报价，Marketplace 依注册公钥验签)
付款 header: PAYMENT-SIGNATURE  (付款 token)
Token 有效期: 约 5 分钟
计价方案: x402 exact(每次请求固定价)，发布时仅支持此一种
预算不足行为: 呼叫失败，不扣款
结算: 非同步，按月出现在 AWS 帐单(AWS Marketplace 行项)
```

清理资源：

```bash
python cleanup.py
```

> TODO: 退款/争议处理机制在文章中未说明，需查阅 AgentCore payments 开发者指南确认。
> TODO: 各区域可用性（文章范例用 us-east-1）未完整列出，上线前需核对所在地区支援情况。

---
[← Back to Deep Dives](./README.md)
