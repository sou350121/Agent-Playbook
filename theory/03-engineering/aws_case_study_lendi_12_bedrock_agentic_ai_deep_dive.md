---
auto_generated: true
generated_at: "2026-03-09T12:23:15Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/how-lendi-revamped-the-refinance-journey-for-its-customers-using-agentic-ai-in-12-weeks-using-amazon-bedrock/"
signal_type: "significant_update"
---
# AWS 案例研究：Lendi 用 Bedrock 在 16 周构建 Agentic AI 房贷系统 (AWS Case Study: Lendi Builds Agentic AI Mortgage System with Bedrock in 16 Weeks)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-09
>
> **项目/工具**: Lendi Guardian + Amazon Bedrock + Agno
> **链接**: https://aws.amazon.com/blogs/machine-learning/how-lendi-revamped-the-refinance-journey-for-its-customers-using-agentic-ai-in-12-weeks-using-amazon-bedrock/
> **核心定位**: 澳大利亚 FinTech 公司 Lendi 用 Amazon Bedrock + Agno 框架构建多 Agent 房贷系统，16 周上线，实现房贷再融资 10 分钟完成

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**: Lendi 用 Amazon Bedrock + Agno 框架构建「Home Loan Guardian」多 Agent 系统，自动化房贷监控 + 再融资流程
- **現在值得用嗎**: 看场景 — 适合已有 AWS 栈 + 需要合规金融场景的企业；不适合个人开发者或轻量级应用
- **適合場景**: 金融/保险等强监管行业的客户服务平台、需要多轮对话 + 工具调用的复杂业务流程、已有 AWS 基础设施的团队
- **不適合場景**: 预算有限的初创公司、简单问答机器人、非 AWS 环境（迁移成本高）
- **與 [竞品/前版] 核心差異**: 用 MCP 服务器实现 Agent 与内部系统解耦 + Bedrock Guardrails 确保合规，而非硬编码集成

## 是什么 / 解决什么问题

澳大利亚房贷平台 Lendi Group 面对的核心问题是：房贷是普通人的最大财务承诺，但用户缺乏实时工具监控自己的贷款是否仍有竞争力。利率变化、房产价值波动、个人财务状况改变 — 这些信息差导致用户错失省钱机会。

传统再融资流程繁琐：即使用户发现更好的利率， paperwork 和行政负担也让他们望而却步。同时，房贷经纪人花费大量时间在行政任务上，而非高价值的客户关系建立。

Lendi 的解决方案「Guardian」是一个 agentic AI 系统，作为用户的 24/7 房贷管家：
- 持续扫描数千房贷产品，发现更优利率时主动提醒用户
- 实时追踪房产价值变化，让用户了解自己的资产状况
- 自动化再融资流程，10 分钟完成申请，无需 paperwork 或电话
- 基于用户财务状况提供个性化建议

关键指标：**16 周开发周期**，**已结算数百万澳元房贷**，**再融资周期时间显著快于基线**。

## 技术架构拆解

### 核心设计决策

Lendi 的架构选择反映了企业级 AI 系统的典型考量：

1. **多模型策略**: 使用 Amazon Bedrock 的多个基础模型，针对不同任务选择最优模型（而非单一模型通吃）
2. **MCP 服务器解耦**: 用 Model Context Protocol 服务器让 Agent 访问内部知识和外部服务，实现 Agent 与业务系统的松耦合
3. **Guardrails 合规优先**: 用 Bedrock Guardrails 确保所有客户沟通符合金融监管要求
4. **可观测性内置**: 用 Langfuse 捕获完整的 Agent traces（输入、输出、推理链、性能指标）
5. **EKS 弹性部署**: 用 Amazon EKS 托管 Agent，支持自动扩缩容应对波动需求

### 架构分层

```
┌─────────────────────────────────────────────────────────────┐
│  UI Layer: Chat interface in Lendi dashboard                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  API Layer: Amazon API Gateway                              │
│  - Request routing, authentication, rate limiting           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Compute Layer: Amazon EKS                                  │
│  - Hosts and orchestrates AI agents                         │
│  - Auto-scaling for varying demand                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Intelligence Layer: Amazon Bedrock + Agno Framework        │
│  - Multiple specialized agents                              │
│  - MCP servers for internal/external integrations           │
│  - Bedrock Guardrails for compliance                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Observability: Langfuse + CloudWatch                       │
│  - Agent traces, inputs, outputs, reasoning chains          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Storage: MongoDB + Amazon S3                               │
│  - User context, conversation history, session state        │
│  - Document storage                                         │
└─────────────────────────────────────────────────────────────┘
```

### 多 Agent 协作流程

Lendi 设计了 5 个专业化 Agent，通过清晰的任务分工和上下文传递完成再融资流程：

| Agent | 职责 | 关键能力 |
|-------|------|----------|
| Mortgage Broker Associate | 初始接触，评估用户再融资意向 | 友好专业人设，自然对话引导 |
| Customer Information Collection | 系统化收集用户贷款/收入/就业信息 | 上下文感知，避免重复提问 |
| Product Recommendation | 匹配 lenders 和产品，计算潜在节省 | 数据库查询，对比分析 |
| Product-Specific Info Collection | 根据选定 lender 收集额外信息 | 动态适配不同 lender 要求 |
| Linda (Communication Agent) | 跨渠道（SMS/Email/WhatsApp）重新 engagement | 检测停滞进度，定时提醒，个性化语气 |

**关键设计亮点**: Linda 作为「离线 Agent」，在用户离开系统后继续通过多渠道保持连接。这是大多数 Agent 系统忽略但对企业转化率至关重要的能力。

### 与前版/竞品的关键差异

| 维度 | 传统方案 / 竞品 | Lendi Guardian |
|------|----------------|----------------|
| 集成方式 | 硬编码 API 调用 | MCP 服务器解耦 |
| 合规保障 | 事后审核 | Bedrock Guardrails 实时过滤 |
| 模型选择 | 单一模型 | 多模型按任务优化 |
| 可观测性 | 基础日志 | Langfuse 完整 trace（含推理链） |
| 用户 engagement | 仅应用内 | Linda 跨渠道主动触达 |
| 开发周期 | 6-12 个月 | 16 周 |

## 实用评估

### 什么场景值得用

1. **强监管行业（金融/保险/医疗）**: Bedrock Guardrails 提供开箱即用的合规边界，避免 AI 输出违规内容。Lendi 的案例证明这在金融场景是可行的。

2. **复杂多轮业务流程**: 再融资涉及信息收集→产品匹配→申请准备→跨渠道跟进，这种需要状态保持和多 Agent 协作的场景正是 agentic AI 的优势区。

3. **已有 AWS 基础设施的团队**: 如果已经在用 EKS、API Gateway、MongoDB 等，集成成本较低。Lendi 16 周上线的前提是「已有微服务架构」。

4. **需要规模化个性化服务**: Guardian 让 Lendi 能在不增加人力的情况下服务更多客户，同时保持「人性化」体验（Agent 人设设计 + 跨渠道跟进）。

### 什么场景不值得用

1. **预算有限的初创公司**: Amazon Bedrock + EKS + Langfuse + MongoDB 的成本不低。如果你的业务规模还没到需要「自动化数千客户」的程度，ROI 可能为负。

2. **简单问答场景**: 如果只是 FAQ 机器人或单轮问答，用这个架构是过度设计。Lendi 的价值在于「多 Agent 协作完成复杂流程」。

3. **非 AWS 环境**: 虽然理论上可以迁移，但整个架构深度绑定 AWS（Bedrock、EKS、API Gateway、S3、CloudWatch）。迁移到 Azure/GCP 需要重写大部分集成层。

4. **对延迟极度敏感的场景**: 多 Agent 协作 + MCP 服务器调用 + Guardrails 检查会增加响应延迟。如果用户期望「秒级响应」，可能需要优化。

### 迁移成本

从传统系统迁移到类似架构的工作量估算：

- **基础设施搭建** (EKS + API Gateway + MongoDB): 2-4 周
- **Agent 开发** (用 Agno 或其他框架): 4-8 周（取决于流程复杂度）
- **MCP 服务器集成** (连接内部系统): 2-4 周
- **Guardrails 配置与测试**: 1-2 周
- **可观测性集成** (Langfuse): 1 周
- **端到端测试与合规审核**: 2-4 周

**总计**: 12-23 周（Lendi 的 16 周是合理估计）

## 对你的意义

### 对 VLA 研究的启发

虽然这是 AI 应用案例，但对具身智能研究有参考价值：
- **多 Agent 协作模式**: Lendi 的 5 个 Agent 分工（感知→信息收集→决策→执行→跟进）与 VLA 系统的 perception-planning-action 循环有相似性
- **MCP 作为工具接口标准**: VLA 系统需要访问多种传感器和执行器，MCP 可能成为标准化工具调用协议
- **Guardrails 在物理世界的重要性**: 金融领域的合规 guardrails 类比到机器人领域就是 safety constraints

### 对 AI 应用开发的启发

1. **Agno 框架值得关注**: Lendi 选择 Agno（开源 agentic 框架）而非 LangChain/LlamaIndex，说明这个生态还在早期，有探索空间。

2. **「离线 Agent」是差异化能力**: Linda 作为跨渠道 re-engagement Agent，解决了「用户离开应用后如何保持连接」的问题。这是大多数 Agent 产品忽略但对企业转化率关键的能力。

3. **可观测性不是可选**: Langfuse 捕获完整推理链，这对 debugging 和持续优化至关重要。生产级 Agent 系统必须内置可观测性。

4. **16 周上线是可行的**: 这个案例证明，如果有清晰架构 + 合适工具链，企业级 Agent 系统可以在季度级别上线，而非年级别。

### 具体建议

- **立即试用**: 如果你在用 AWS 且需要构建复杂对话流程，参考这个架构。Agno + Bedrock + MCP 是可行组合。
- **观望**: 如果你不在 AWS 生态，等待 Agno 或其他框架的多云支持。
- **跳过**: 如果你的场景是简单问答或预算有限，这个架构过度设计。

## 关键代码/配置片段

### Agno Agent 示例（基于 Lendi 架构推断）

```python
from agno.agent import Agent
from agno.models.bedrock import Bedrock
from agno.tools.mcp import MCPTools

# Mortgage Broker Associate Agent
broker_agent = Agent(
    name="Mortgage Broker Associate",
    model=Bedrock(id="anthropic.claude-3-sonnet-20240229-v1:0"),
    tools=[MCPTools(server="lendi-customer-data")],
    instructions=[
        "You are a friendly, professional mortgage broker.",
        "Assess customer's interest in refinancing.",
        "Keep conversations natural, not interrogative.",
    ],
    markdown=True,
)

# Customer Information Collection Agent
info_agent = Agent(
    name="Customer Info Collection",
    model=Bedrock(id="anthropic.claude-3-haiku-20240307-v1:0"),
    tools=[MCPTools(server="lendi-loan-database")],
    instructions=[
        "Collect loan details, employment status, income.",
        "Be context-aware: don't ask for information already provided.",
        "Provide clarifications when needed.",
    ],
)

# Product Recommendation Agent
recommend_agent = Agent(
    name="Product Recommendation",
    model=Bedrock(id="anthropic.claude-3-5-sonnet-20241022-v2:0"),
    tools=[MCPTools(server="lendi-lender-products")],
    instructions=[
        "Analyze customer profile against lender database.",
        "Present options with clear benefits and potential savings.",
    ],
)
```

### Bedrock Guardrails 配置（简化版）

```json
{
  "guardrailIdentifier": "lendi-compliance-guardrail",
  "contentPolicyConfig": {
    "filtersConfig": [
      {
        "type": "PROFANITY",
        "inputStrength": "HIGH",
        "outputStrength": "HIGH"
      },
      {
        "type": "INSULTS",
        "inputStrength": "HIGH",
        "outputStrength": "HIGH"
      }
    ]
  },
  "topicPolicyConfig": {
    "topicsConfig": [
      {
        "name": "MortgageRelated",
        "definition": "Conversations about home loans, refinancing, interest rates",
        "type": "ALLOW"
      },
      {
        "name": "OffTopic",
        "definition": "Any conversation not related to mortgage services",
        "type": "DENY"
      }
    ]
  }
}
```

### MCP 服务器示例（连接内部贷款数据库）

```python
# MCP Server: lendi-loan-database
from mcp.server import Server
from mcp.server.stdio import stdio_server

server = Server("lendi-loan-database")

@server.tool("get_customer_loan_details")
async def get_loan_details(customer_id: str) -> dict:
    """Retrieve customer's current loan information"""
    # Connect to internal loan database
    loan_data = await query_loan_db(customer_id)
    return {
        "current_rate": loan_data["rate"],
        "outstanding_balance": loan_data["balance"],
        "loan_type": loan_data["type"],
        "lender": loan_data["lender"]
    }

@server.tool("search_competitive_products")
async def search_products(loan_amount: float, credit_score: int) -> list:
    """Find competitive loan products"""
    products = await query_product_db(loan_amount, credit_score)
    return [{"lender": p["lender"], "rate": p["rate"], "savings": p["savings"]} for p in products]
```

---
[← Back to Deep Dives](./README.md)
