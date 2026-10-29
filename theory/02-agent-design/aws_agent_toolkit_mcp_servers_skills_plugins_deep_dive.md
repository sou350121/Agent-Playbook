---
auto_generated: true
generated_at: "2026-10-29T06:46:35Z"
source_url: "https://github.com/aws/agent-toolkit-for-aws/releases"
signal_type: "significant_update"
---
# AWS Agent Toolkit：把「coding agent 会用 AWS」做成官方 GA 产品 (Agent Toolkit for AWS — GA: Official MCP Server + Skills + Plugins for Multi-Agent IDEs)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-29
>
> **项目/工具**: Agent Toolkit for AWS（`aws/agent-toolkit-for-aws`）
> **链接**: https://github.com/aws/agent-toolkit-for-aws
> **核心定位**: 一个托管 MCP Server（300+ AWS 服务 / 沙箱脚本执行 / 实时文档搜索）+ 一套可分发的 agent skills + 跨 IDE 插件包，让 Claude Code、Codex、Cursor、Devin、Kiro、fx 都能在同一份 AWS 知识上工作；**这次是 AWS 把 2025 年撒在 awslabs 下的散装 MCP servers 正式收编为单一官方产品并存续旧工具**。

## ⚡ 快速判断（30 秒读完这段就够）

| 问题 | 答案 |
|------|------|
| 一句话定位 | AWS 官方把「agent 怎么正确用 AWS」打包成 MCP Server + skills + plugins 三层，一次接入所有主流 coding agent |
| 现在值得用吗 | **看场景**。已经在 Claude Code / Cursor 里写 AWS 代码、且账号有写权限的人，值得立刻换掉 awslabs 时代的零散 MCP server；纯文档查阅、只读需求则可以只接 MCP Server |
| 适合场景 | 用 coding agent 生成 CDK/CloudFormation、排障、查 IAM 权限边界、需要 CloudTrail 审计 agent 行为的团队 |
| 不适合场景 | 非 AWS 环境；希望「agent 直接拿 root 凭证干活」的快糙路线；无法接受把 AWS 凭证交给托管 MCP Server 的组织 |
| 与 awslabs 旧工具的核心差异 | 旧工具功能保留但不演进；新工具多了 **agent/human 可区分的 IAM condition keys**、每个请求的 CloudWatch metrics + CloudTrail 审计、以及通过端到端评测的 skills |

## 是什么 / 解决什么问题

过去一年半，AWS 的 MCP 工具是「撒胡椒面」式的：awslabs 组织下几十个 MCP server，每个服务一个，配置方式各不相同，agent 读到的是过时的文档快照，权限靠开发者随手贴上的人凭证。结果是 coding agent 写 AWS 基础设施这件事，**能不能跑通几乎是运气问题**。

Agent Toolkit for AWS 把这件事收拢成三件东西：

1. **一个托管 MCP Server**（`https://aws-mcp.us-east-1.api.aws/mcp`）——单点接入 300+ AWS 服务，附带沙箱 Python 脚本执行和**无需认证的实时文档搜索**。
2. **一套 skills**——按任务打包的指令与参考资料，按需加载（`npx skills add aws/agent-toolkit-for-aws/skills`），避免一次把全部上下文塞进窗口。
3. **插件发行层**——把 MCP Server 配置 + skills 捆成一个可 `/plugin install` 的包，分发到 Claude Code、Codex、Cursor、Devin；Kiro 和 fx 走「MCP + skills」两步独立安装。

README 里唯一一句带战略意味的话是：**"The Agent Toolkit for AWS is the successor to those tools."** — awslabs 下的旧 MCP servers 会继续接收贡献，但「好的部分会逐步迁移到 Agent Toolkit」。这是一条明确的生命线宣告，不是又一个 side project。

## 技术架构拆解

### 核心设计决策

- **MCP Server 托管化，文档免认证**：README 明确写「使用 AWS 账号凭证进行 API 调用与脚本执行是必需的，但**文档搜索和 skill 发现不需要**」。这意味着 agent 可以在没有凭证的情况下先查文档、学 API，再决定要不要动真资源——把「探索」和「执行」的权限面切开了。
- **三层分离：MCP / skills / plugins**。MCP 负责「能力」（能调什么 API），skills 负责「知识」（该怎么调用才不踩坑），plugins 负责「分发」（怎么装到某个 IDE）。Kiro/fx 的接入文档特别强调这两者「独立工作」——skills 不依赖 MCP server，MCP server 也不提供本地 skills。这个解耦让非 MCP 生态也能用。
- **agent 身份一等公民**：这是官方列出的三大核心优势之首——**IAM condition keys 可以区分 agent action 与 human action**，从而写出「只允许 MCP server 走只读动作，即使用户底层 IAM role 有写权限」的策略。这是把所有 agent 流量当成人来管、最终被迫给过宽权限这一老大难问题的正解。
- **审计默认开启**：每一个请求都有 CloudWatch metrics 与 CloudTrail audit logging。企业侧真正卡住 agent 上线的往往不是能力而是「出了问题查得到谁」，这条是准入项。
- **skills 走端到端评测**：官方称 skills「经过了彻底的端到端评测，因此可以确信工作流会成功完成」。注意这是官方自述，**具体评测集与方法未在 README 中公开**（> TODO: 待官方发布评测细节后核验）。
- **一个仓库、多 IDE 市场**：Claude Code 走 Anthropic 官方市场（`claude-plugins-official`，默认已加载），其他工具走本仓库自带 marketplace（`.cursor-plugin/marketplace.json`、`codex plugin marketplace add`、`devin plugins install`）。**分发重心明显向 Claude Code 倾斜**——只有它的插件进了 Anthropic 官方市场。

### 插件清单

| 插件 | 覆盖面 | 备注 |
|------|--------|------|
| `aws-core` | 服务选型、CDK/CloudFormation、serverless、容器、存储、可观测性、账单、SDK 用法、部署 | **官方标注 Start here**，必备底座 |
| `aws-agents` | 在 Bedrock 与 AgentCore 上构建 AI agent | 与 AI 应用线直接相关 |
| `aws-data-analytics` | S3 Tables、Glue、Athena 数据湖与 ETL | 数据工作流 |
| `aws-agents-for-devsecops` | 事故调查、代码评审、UAT、漏洞扫描、渗透测试（AWS DevOps Agent + Security Agent） | 需 `/aws-agents-for-devsecops:setup`，且只能用 `aws/agent-toolkit-for-aws` 市场安装 |
| `aws-startup-advisor` | 创业公司架构/成本/安全建议、从 Azure/GCP/Heroku/OpenAI/Gemini 迁移、Activate credits | 仅本仓库市场，未进官方市场 |

### 与前版/竞品的关键差异

| 维度 | awslabs 时代（2025） | Agent Toolkit（GA） |
|------|----------------------|---------------------|
| 入口 | 每服务一个 MCP server，配置各异 | 单一托管端点 `aws-mcp.us-east-1.api.aws/mcp` |
| 文档 | 依赖模型记忆 / 手动粘贴 | 实时文档搜索，**免认证** |
| 权限粒度 | 用开发者凭证，人机不分 | IAM condition keys 区分 agent / human action |
| 审计 | 自行拼 CloudTrail | 每请求 metrics + CloudTrail 默认开启 |
| 知识层 | 无官方 skills | 按任务按需加载的 skills，官方称已端到端评测 |
| 生态位 | 实验性质 | **官方 successor**，awslabs 好料逐步迁入 |

### 架构 / 信息流图

```text
                 [ Coding Agent: Claude Code / Codex / Cursor / Devin / Kiro / fx ]
                            │                    │                    │
                    插件(含 MCP 配置+skills)   直接 skills        AWS CLI
                            │                    │                    │
                            ▼                    ▼                    ▼
              ┌──────────────────────┐   ┌───────────────┐   aws configure
              │  AWS MCP Server      │   │  skills/      │      agent-toolkit
              │  (托管, 单一端点)    │   │  SKILL.md     │
              ├──────────────────────┤   │  + references │
              │ 300+ 服务 API        │   └───────────────┘
              │ 沙箱 Python 执行     │
              │ 实时文档搜索(免认证) │
              └──────────┬───────────┘
                         │ SigV4 认证 / IAM condition keys
                         ▼
              [ CloudTrail 审计 + CloudWatch metrics ]
                         │
                         ▼
                   [ AWS 账号资源 ]
```

## 实用评估

### 什么场景值得用

- **用 coding agent 写 CDK/CloudFormation 的团队**：`aws-core` 直接覆盖合成、部署、可观测性与账单——这是最容易让 agent 生成「看起来能跑但 policy 会拒」的模板的地方，实时文档 + IAM 上下文明显降低返工。
- **要过安全评审的组织**：agent 流量单独打标签、单独给只读策略、全量 CloudTrail。这比「给 agent 一个开发者 access key」在审计上是质的差别。
- **多 IDE 团队**：同一个团队里有人用 Cursor、有人用 Claude Code、有人用 Codex 时，官方插件分发至少保证了 MCP 配置口径一致，不需要各自手抄 `mcp.json`。
- **AgentCore / Bedrock 上的 agent 工程**：`aws-agents` 插件正好对上路。

### 什么场景不值得用

- **只是想查 AWS 文档**：MCP Server 的文档搜索虽免认证，但完整接入需要 `uv`、账号与区域配置；直接开浏览器更快。
- **本地/离线或非 AWS 环境**：整套东西围绕 AWS 服务，没有跨云价值。
- **凭证敏感程度高的组织**：托管 MCP Server 意味着 API 调用经过 AWS 运营的端点——虽然这本来就是 AWS 自己的服务，但需要确认内部数据合规政策允许 agent 走托管通道，而非自建 proxy。README 提供了 `mcp-proxy-for-aws-cli` 作为本地转发层，但**转发层的具体能力边界未在 README 详述**（> TODO: 需查阅 user guide）。
- **期待精确版本/指标的人**：本次是产品级 GA 与文档重构，**不是带 benchmark 的版本发布**；README 没有给成功率、延迟或成本数据。任何「提升 X%」的说法目前都缺乏一手依据。

### 迁移成本

| 步骤 | 动作 | 粗估工作量 |
|------|------|-----------|
| 1 | Claude Code：`/plugin marketplace update claude-plugins-official` 后 `/plugin install aws-core@claude-plugins-official` | 5 分钟 |
| 2 | 卸载 awslabs 时代的旧 MCP servers，避免同一 agent 里工具重复注册 | 10–30 分钟（取决于旧配置数量） |
| 3 | 把 IAM 策略从「用户角色」改为写 agent 专用 condition 策略 | 半天起，需安全团队确认 |
| 4 | 打开 CloudTrail 审计口径与 CloudWatch 告警 | 半天 |
| 5 | Kiro / fx / 其他 agent：按两步（MCP + skills）分别配置，注意 `uv` 前置依赖 | 每人 15–30 分钟 |

最容易出问题的一步是第 2 步：新旧 MCP server 同时挂着时，agent 面对的会是两套名称相近的工具，选择行为不可预测。

## 对你的意义

对你两条线的实际含义不太一样，分开说：

**AI 应用线（Agent + UI）**：这是一份「官方如何做 agent 工具分发」的现成教案。三层解耦（能力 / 知识 / 分发）本身就是可以抄的架构——如果你之后要给自己或团队的工具做 MCP 或 skill 包，这个分层比「一个大 MCP server 包打天下」更可维护。另外「文档搜索免认证、执行需认证」这个权限面切分，是值得直接借鉴的模式。

**VLA 线（研究）**：关联度低。这套东西是云基础设施 agent 化，跟触觉 + VLA 没有交集，不必分注意力。

**建议**：如果你平时用 Claude Code / Cursor 写 AWS 相关代码（哪怕只是偶尔查 IAM 怎么配、CDK 怎么写），**立刻装 `aws-core`**，成本 5 分钟。但**先不要**把生产账号的写权限交给它——先只用只读策略跑一周，看 agent 实际会产生多少 API 调用、有没有误操作倾向，再谈放宽。

## 关键代码/配置片段

Claude Code（插件进 Anthropic 官方市场，默认已加载）：

```bash
/plugin install aws-core@claude-plugins-official
/plugin install aws-agents@claude-plugins-official
/plugin install aws-data-analytics@claude-plugins-official
```

若提示 `Plugin not found`，先更新本地市场索引：

```bash
/plugin marketplace update claude-plugins-official
```

Kiro：MCP 与 skills 两步独立配置。

```json
{
  "mcpServers": {
    "aws": {
      "command": "uvx",
      "args": [
        "mcp-proxy-for-aws-cli@latest",
        "https://aws-mcp.us-east-1.api.aws/mcp",
        "--metadata",
        "AWS_REGION=us-west-2"
      ]
    }
  }
}
```

```bash
npx skills add aws/agent-toolkit-for-aws/skills
```

fx（注意键名是 `mcp` 而非 `mcpServers`，且 `command` 为数组）：

```json
{
  "mcp": {
    "aws": {
      "type": "local",
      "command": [
        "uvx",
        "mcp-proxy-for-aws-cli@latest",
        "https://aws-mcp.us-east-1.api.aws/mcp",
        "--metadata",
        "AWS_REGION=us-west-2"
      ]
    }
  }
}
```

```bash
fx mcp add aws uvx mcp-proxy-for-aws-cli@latest https://aws-mcp.us-east-1.api.aws/mcp --metadata AWS_REGION=us-west-2
npx skills add aws/agent-toolkit-for-aws/skills -a fx
```

DevSecOps 插件需先加本仓库市场并执行 setup：

```bash
/plugin marketplace add aws/agent-toolkit-for-aws
/plugin install aws-agents-for-devsecops
/reload-plugins
/aws-agents-for-devsecops:setup
```

AWS CLI 直连路径：

```bash
aws configure agent-toolkit
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 最有力的一条证据是 AWS 把 300+ 服务收敛到**单一托管 MCP 端点**，并把 awslabs 旧工具定为「被取代者」；同时插件层把 MCP 配置当作默认分发内容，而非可选项。这一动作把 MCP 从「社区共识」推成「云厂商的基础设施接口」。 |

---
[← Back to Deep Dives](./README.md)
