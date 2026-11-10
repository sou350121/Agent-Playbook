---
auto_generated: true
generated_at: "2026-11-10T05:45:51Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/getting-started-with-web-answer-on-amazon-bedrock-agentcore/"
signal_type: "significant_update"
---
# Bedrock AgentCore Web Answer 正式 GA：把「检索—合成—引用」整条管线外包给网关 (Web Answer on Amazon Bedrock AgentCore Goes GA)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-10
>
> **项目/工具**: Amazon Bedrock AgentCore — Web Answer（managed connector）
> **链接**: https://aws.amazon.com/blogs/machine-learning/getting-started-with-web-answer-on-amazon-bedrock-agentcore/
> **核心定位**: 一个托管 MCP 工具，用一次调用返回「带源 URL 引用的、已合成的答案」，agent 无需自己维护 search → retrieve → synthesize → cite 的整条流水线

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Web Answer 是 AWS 拥有的托管连接器，挂在 AgentCore Gateway 上，agent 通过 MCP `tools/list` / `tools/call` 调用，输入自然语言问题，输出每条论断都绑定引用 URL 的答案。
- **現在值得用嗎**：看场景——如果你的 agent 里有大量「子问题需要即时事实」的检索环节，且你不想自己养一条 citation pipeline，值得立刻试；如果你需要完全掌控检索与合成逻辑，或不在 AWS 生态内，用 Web Search 自建更合适。
- **適合場景**：企业内 agent 需要回答「现在的规定/费率/标准是什么」这类时效性问题；需要可审计引用链的合规/金融/法务问答；已经在用 AgentCore Gateway 的团队。
- **不適合場景**：需要自控 chunk 策略与排序的深度 RAG；非 AWS 环境（无 AgentCore Gateway）；对吞吐有高要求的批处理（默认每账号 10 TPS）。
- **與 Web Search 核心差異**：Web Search 只返回排序后的 URL/标题/snippet，模型由你自己跑；Web Answer 连 agentic 检索循环、合成、归因一起跑掉，直接给成品答案。

## 是什么 / 解决什么问题

构建一个能回答「当前网络上事实」的 agent，业界已经形成一个反复出现的模式：先调搜索 API，判断哪些结果可信，抓取并清洗页面正文，用 prompt 让模型合成答案，最后再做一轮引用抽取，让结论能回溯到来源。这五步每一步都是你得自己维护的代码，每一步也各有一个典型故障模式——官方 blog 里写得非常直白：

- 证据不足时模型**幻觉**；
- 索引移动后引用内容**过期**；
- 论断与来源**漂移**时归因断链（broken attribution）。

Web Answer 的做法是把整条管线压缩成一次请求：你发一个问题，几秒内拿回一个带引用的答案。它不是让你少写几行胶水代码，而是把「谁跑模型」这件事从你身上转移到 AWS 侧——这是它和 Web Search 的根本分界线。

这个变化对 agent 工程的意义在于：**检索从「你架构里的一段代码」变成「网关上的一个工具」**。这也意味着治理权（鉴权、域名白名单、限流、VPC 出网）从应用层上移到了基础设施层。

## 技术架构拆解

### 核心设计决策

- **托管连接器而非新 API**：Web Answer 被建模为一个 AgentCore Gateway 的 connector target，用 `connectorId: "web-answer"` 声明，AWS 侧的资源 ARN 是 `arn:aws:bedrock-agentcore:us-east-1:aws:tool/web-answer.v1`。这意味着接入方式是声明而非编程——管理员建 target，工具就自动出现在所有挂载该网关的 agent 的 `tools/list` 里。
- **MCP 作为唯一接口面**：agent 不需要任何 Web Answer 专属 SDK。官方示例用 Strands Agents + `mcp-proxy-for-aws`，但明确说同样适用于 LangChain、LangGraph、CrewAI 或任何 MCP 兼容客户端。这是把 MCP 当「工具总线」用的典型做法。
- **永远现搜，注入当天日期**：官方说明每次调用都重新发起搜索，且模型会被注入今天的日期，以便搜索「最新」信息。这是对「RAG 索引陈旧」问题的架构级回答——干脆不做索引。
- **Agentic 检索循环**：Web Answer 自己规划搜索、并行执行多条、读取关键页面核对事实，**证据不足时会再搜一轮**，然后才写答案。检索轮数不对外暴露为参数，属于服务内部策略。
- **双层鉴权、出站凭据零管理**：入站由 Gateway 的 authorizer 决定（AWS IAM SigV4 或 JWT），出站由 Gateway 服务角色承担，只需 `bedrock-agentcore:InvokeWebAnswer` 权限。**不需要 `bedrock:InvokeModel`**——因为模型跑在 Web Answer 侧，不在你的 agent 身份下。
- **管理员设定的策略边界**：域名过滤在 target 层设置一次，对所有经过该 target 的调用生效；agent 侧只能「收紧」（排除更多域名，或在 include 列表内再收窄），不能突破管理员设定的上限。

### 与 Web Search 的关键差异

| 维度 | Web Search（AgentCore 上的同类工具） | Web Answer（本次 GA） |
|------|------------|------------|
| 返回内容 | 排序 URL、标题、snippet、元数据 | 已合成的答案 + 每条论断的引用 URL |
| 谁跑模型 | 你自己 | AWS 侧 |
| 检索循环 | 你实现 | 服务内部 agentic loop（不足会再搜） |
| 引用归因 | 你抽取 | 服务返回 structured citations |
| 控制粒度 | 完全可控（chunk、排序、prompt） | 只有入参级控制（domain filter、日期区间、国家） |
| 典型用途 | 广域研究、需要原始结果的场景 | 大 agent 中的「子任务式事实问答」 |
| 适用客户端 | 任意 | 任意 MCP 兼容客户端（经 Gateway） |

官方明确说「很多客户会两个都用」：广域研究用 Web Search 拿原始结果，特定事实问题用 Web Answer 拿快速带引用的答案。这个组合建议是本次发布里最实用的一句话。

### 架构/信息流图

```
Agent (Strands / LangChain / LangGraph / CrewAI)
   │  tools/call: web-answer-tool___WebAnswer {question, domainFilter?, dateRange?, country?}
   ▼
AgentCore Gateway  ── 入站鉴权：AWS IAM (SigV4) / JWT
   │               ── 管理员设定的域名过滤上限
   │  出站：Gateway service role (bedrock-agentcore:InvokeWebAnswer)
   ▼
Web Answer (AWS-managed connector)
   ├─ 规划 → 并行多路搜索 → 读页核对
   ├─ 证据不足 → 再搜一轮
   └─ 合成答案，逐条绑定 citation URL（注入当天日期）
   │
   ▼  MCP tool result
{ content: [text/markdown with [[1](url)]],
  structuredContent: { answer: [{ text, citations: [{domain, url}] }] },
  _meta: { latencyMs } }
```

## 实用评估

### 什么场景值得用

- **企业内部的时效性事实问答**：官方 demo 用的是「Basel III 对 Tier 1 资本的最低要求是多少」。这类问题的特征是好坏判定很清晰、答案随监管更新而变化、且必须能指回权威域名——正好落在 Web Answer 的设计点上。
- **需要可审计引用链的合规场景**：返回结构里 `structuredContent.answer[].citations[]` 是机器可读的 `{domain, url}` 列表，不是把引用混在文本里等你自己正则解析。这让下游做「引用覆盖率检查」变得很轻。
- **多工具大 agent 中的检索子任务**：官方建议把 Web Answer 当作 sub-task 用。你不想为了一个附带的事实核实环节去维护一整套检索代码时，声明一个 target 就够了。
- **已有 AgentCore Gateway 的团队**：接入成本最低，几分钟量级：建 target → 等服务端状态 READY → agent 侧 `list_tools_sync()` 就能发现工具。

### 什么场景不值得用

- **需要自控 RAG 细节**：如果你靠 chunk 策略、reranker、向量库召回率做差异化，Web Answer 不给你这些旋钮。它只接受 domain filter、published-date 范围、country 三个可选参数。
- **非 AWS 环境**：没有 AgentCore Gateway 就没有接入路径。这是一项强绑定 AWS 的服务，不是可自托管的开源组件。
- **高吞吐批处理**：官方口径是每账号 10 TPS（us-east-1），要提额需联系 AWS Support。批量跑几千条问答的离线任务会被这个限流卡住。
- **区域锁定**：当前接入步骤要求 Gateway 在 `us-east-1`，资源 ARN 也写死在该区域。低延迟诉求或多区域部署的团队要额外考虑。
- **对成本敏感的高频调用**：Gateway 与 Web Answer 调用都计费，且一次调用背后是多次搜索 + 多次读页 + 一次合成；成本结构与「你控制检索轮数」的自建方案不同，高频场景需要先算账。
- > TODO: 官方 blog 未在正文给出 Web Answer 的具体单价与单次调用平均搜索次数，成本评估需查 AgentCore Pricing 页。

### 迁移成本

- **从自建 pipeline 迁移**：把原来的「搜索→抓取→合成→引用抽取」四段代码替换为一次 MCP 工具调用，然后处理返回体——markdown 文本里带 `[[1](url)]` 内联标记，同时有 `structuredContent` 结构化版本。工作量主要在 prompt 重写（不再需要教模型「记得引用」）和把结果映射回原有数据结构。
- **从 Web Search 迁移**：如果原先用 Web Search 只为了做事实问答，迁移几乎零成本；如果原先依赖原始 snippet 做二次加工，则不适合迁移。
- **前置条件**：AWS 账号有 AgentCore Gateway 访问权、Gateway 使用 `AWS_IAM` 入站鉴权、Python 3.10+ 与 `boto3 strands-agents mcp mcp-proxy-for-aws` 四个包。

## 对你的意义

对 Ken 的两条线，这件事的价值不完全一样：

- **AI 应用线（Agent + UI）**：这也是一条明确的架构趋势信号——**检索正在从「应用层的 pipeline」下沉为「网关层的托管工具」**。如果 Agent-Playbook 未来要讨论 agent 工具层设计，「哪些能力应该被托管化」会是一个反复出现的分类问题：搜索、引用合成、权限边界，都是典型的「每个团队都要重写一遍但没什么差异」的组件。Web Answer 给出了一个由云厂商主导的答案。
- **VLA 线**：短期无直接关系。唯一可迁移的思路是「证据不足时自动重检索」这类 agentic loop 的显式化设计，与 VLA 世界模型中的不确定性触发重规划有结构性相似，但仅限概念层面，不宜过度拉伸。

**建议**：如果你手上有基于 AgentCore Gateway 的 agent，立刻花 30 分钟验证一次——成本极低，能立刻判断 `structuredContent` 的引用质量是否够用。如果不在 AWS 生态内，把这个案例作为「托管检索工具」的参照系记在 Playbook 里，而不是去移植它。

## 关键代码/配置片段

以下均引自官方 blog（2026-11-04 发布）。

权限策略（给 Gateway 服务角色，仅需一个 action）：

```python
iam.put_role_policy(
    RoleName="<gateway-service-role>",
    PolicyName="WebAnswerGuide",
    PolicyDocument=json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Sid": "InvokeWebAnswer",
            "Effect": "Allow",
            "Action": "bedrock-agentcore:InvokeWebAnswer",
            "Resource": "arn:aws:bedrock-agentcore:us-east-1:aws:tool/web-answer.v1",
        }],
    }),
)
```

注册 target（含管理员级域名过滤上限）：

```python
target_response = gateway_client.create_gateway_target(
    name="web-answer-tool",
    gatewayIdentifier=gateway_id,
    targetConfiguration={
        "mcp": {
            "connector": {
                "source": {"connectorId": "web-answer"},
                "configurations": [{"name": "WebAnswer", "parameterValues": {
                    "domainFilter": {"include": ["bis.org"], "exclude": ["unreliable-source.net"]}
                }}],
            }
        }
    },
    credentialProviderConfigurations=[
        {"credentialProviderType": "GATEWAY_IAM_ROLE"}
    ],
)
```

从 Strands agent 调用：

```python
from strands import Agent
from strands.models.bedrock import BedrockModel
from strands.tools.mcp import MCPClient
from mcp_proxy_for_aws.client import aws_iam_streamablehttp_client

gateway_url = "https://gateway-<id>.gateway.bedrock-agentcore.us-east-1.amazonaws.com/mcp"

mcp_client = MCPClient(lambda: aws_iam_streamablehttp_client(
    endpoint=gateway_url,
    aws_region="us-east-1",
    aws_service="bedrock-agentcore",
    aws_profile="<aws-profile-id>",
))

model = BedrockModel(model_id="us.anthropic.claude-sonnet-5", max_tokens=1024)

with mcp_client:
    tools = mcp_client.list_tools_sync()
    agent = Agent(model=model, tools=tools)
    result = agent("What are the Basel III minimum requirements for Tier 1 capital?")
```

返回结构关键字段（`_meta.latencyMs` 是官方示例中的实测值格式，非性能承诺）：

```json
{
  "structuredContent": {
    "answer": [{
      "text": "... [[1](https://www.bis.org/...)] ...",
      "citations": [{ "domain": "bis.org", "url": "https://www.bis.org/..." }]
    }]
  },
  "isError": false,
  "_meta": { "latencyMs": 5210 }
}
```

---
[← Back to Deep Dives](./README.md)
