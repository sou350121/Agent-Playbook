---
auto_generated: true
generated_at: "2026-04-14T05:47:24Z"
source_url: "https://blog.langchain.com/deep-agents-deploy-an-open-alternative-to-claude-managed-agents/"
signal_type: "significant_update"
---
# Deep Agents Deploy：开源替代 Claude Managed Agents 的模型无关部署方案 (Deep Agents Deploy: An Open Alternative to Claude Managed Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-14
>
> **项目/工具**: LangChain Deep Agents Deploy
> **链接**: https://blog.langchain.com/deep-agents-deploy-an-open-alternative-to-claude-managed-agents/
> **核心定位**: 用一条命令将模型无关的开源 Agent Harness 部署到生产环境，核心卖点是「记忆所有权」—— 不被供应商锁定

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：LangChain 推出的生产级 Agent 部署方案，支持任意模型提供商，强调开源生态和记忆自主权
- **现在值得用吗**：是 —— 如果你在构建需要长期记忆的客户-facing Agent，或想避免 Anthropic 锁定
- **适合场景**：多模型策略、需要自托管记忆、企业级 Agent 部署、MCP/A2A 协议集成
- **不适合场景**：简单一次性 Agent 任务、已深度绑定 Claude 生态且无迁移需求
- **与 Claude Managed Agents 核心差异**：Deep Agents Deploy 是开源 + 多模型 + 可自托管；Claude Managed Agents 是专有 + 仅 Anthropic + 云端锁定

## 是什么 / 解决什么问题

Agent Harness（Agent 框架）是将 LLM 转化为 Agent 的基础设施，包含编排逻辑、工具、技能等核心组件。随着「Harness Engineering」成为独立学科，一个关键问题浮现：**当你的 Agent 积累大量交互记忆后，如何避免被供应商锁定？**

Claude Managed Agents 和 Deep Agents Deploy 在架构上相似（都有 Harness、Agent Server、Sandbox），但根本差异在于生态开放性：

- **Claude Managed Agents**：专有 Harness，仅支持 Anthropic 模型，记忆存储在封闭 API 背后
- **Deep Agents Deploy**：MIT 开源 Harness，支持 OpenAI/Anthropic/Google/Bedrock 等任意提供商，记忆以标准格式（AGENTS.md、skills）存储，可自托管

LangChain 的核心论点是：**模型切换相对容易，但记忆锁定是致命的**。想象一个面向客户的销售 Agent，它积累了大量客户交互记忆 —— 如果这些记忆被锁在封闭 API 里，迁移成本将是重置整个 Agent 的知识库。

Deep Agents Deploy 的目标是用一条命令解决生产部署的所有步骤：
```
deepagents deploy
```
自动处理：Agent 编排逻辑部署、多租户可扩展架构、Sandbox 按需启动、MCP/A2A/Agent Protocol 端点暴露、人机回环（Human-in-the-loop）接口、记忆端点。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 影响 |
|------|------|------|
| **模型无关** | 避免单一提供商锁定，支持混合模型策略 | 用户可根据成本/性能/功能选择最佳模型组合 |
| **开源 Harness** | MIT 许可，Python + TypeScript 双实现 | 社区可审计、可贡献、可 fork |
| **标准协议暴露** | MCP、A2A、Agent Protocol 均为开放标准 | 可与其他 Agent 系统互操作，UI 可独立开发 |
| **记忆外部化** | 记忆以文件形式（AGENTS.md、skills）存储，可通过 API 直接查询 | 迁移时只需复制文件，无需 API 迁移 |
| **Sandbox 可插拔** | 支持 Daytona/Modal/Runloop/LangSmith 或自定义 | 用户可根据安全/成本/地域需求选择 |
| **自托管选项** | LangSmith Deployments 可自托管 | 敏感数据可保留在内部基础设施 |

### 与前版/竞品的关键差异

| 维度 | Claude Managed Agents | Deep Agents Deploy |
|------|----------------------|-------------------|
| **模型支持** | 仅 Anthropic | OpenAI、Anthropic、Google、Bedrock、Azure、Fireworks、Baseten、OpenRouter 等 |
| **Harness 许可** | 专有、闭源 | MIT 开源 |
| **Sandbox** | 内置（不可选） | LangSmith、Daytona、Modal、Runloop 或自定义 |
| **MCP 支持** | ✅ | ✅ |
| **Skill 支持** | ✅ | ✅（Agent Skills 开放标准） |
| **AGENTS.md 支持** | ❌ | ✅（开放标准） |
| **Agent 端点** | 专有协议 | MCP、A2A、Agent Protocol |
| **自托管** | ❌ | ✅ |
| **记忆所有权** | 存储在 Anthropic API 后 | 标准格式，可查询、可导出、可自托管 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    deepagents deploy                         │
│  (bundles your Deep Agent + LangSmith Deployment server)    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Deployed Agent Server                      │
│  (production-ready, horizontally scalable)                   │
├─────────────────────────────────────────────────────────────┤
│  Endpoints (30+):                                            │
│  ├── MCP (modelcontextprotocol.io) → call agent as tool     │
│  ├── A2A (a2a-protocol.org) → multi-agent setup             │
│  ├── Agent Protocol → build custom UIs                       │
│  ├── Human-in-the-loop → guardrails & approval flows        │
│  └── Memory API → short-term & long-term memory access      │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
     ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
     │   Sandbox   │ │   Sandbox   │ │   Sandbox   │
     │  (Daytona)  │ │  (Modal)    │ │  (Runloop)  │
     │  per session│ │  per session│ │  per session│
     └─────────────┘ └─────────────┘ └─────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
                   ┌─────────────────┐
                   │  Memory Store   │
                   │  (your DB only) │
                   │  AGENTS.md +    │
                   │  skills files   │
                   └─────────────────┘
```

## 实用评估

### 什么场景值得用

1. **企业级客户-facing Agent**：销售支持、客服、SDR（Sales Development Representative）Agent 需要积累大量客户交互记忆。Deep Agents Deploy 确保这些记忆存储在自有数据库，而非供应商 API 后。

2. **多模型策略**：需要根据任务类型选择不同模型（如：推理用 Claude、代码用 GPT、成本敏感用开源模型）。Deep Agents Deploy 支持任意模型提供商，可在 `deepagents.toml` 中灵活配置。

3. **合规/数据主权要求**：金融、医疗等行业需要将数据保留在境内或私有云。自托管 LangSmith Deployments 可满足这一需求。

4. **Agent 互操作需求**：需要将 Agent 暴露为 MCP 工具供其他 Agent 调用，或通过 A2A 协议构建多 Agent 协作系统。

5. **长期项目**：计划持续迭代 Agent 能力、积累领域知识的项目。开放格式确保未来可迁移。

### 什么场景不值得用

1. **简单一次性任务**：如果只是跑一次数据提取或简单问答，无需部署生产级服务。直接用 LangChain 本地运行即可。

2. **已深度绑定 Claude 生态**：如果团队已全面使用 Anthropic 模型 + Claude Managed Agents，且无迁移计划，切换成本可能不划算。

3. **预算极有限**：虽然 Harness 开源，但 LangSmith Deployments 可能产生费用（自托管需自行维护基础设施）。个人项目可考虑本地 `deepagents dev`。

4. **需要 stdio MCP 服务器**：部署环境仅支持 HTTP/SSE 传输的 MCP 服务器，stdio 传输会被拒绝。需提前改造。

### 迁移成本

从 Claude Managed Agents 迁移到 Deep Agents Deploy：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| **模型切换** | 低 | 修改 `deepagents.toml` 中 `model` 字段，调整 prompt 格式 |
| **记忆导出** | 中 | 需通过 Claude API 导出历史对话，转换为 AGENTS.md 格式（TODO：需确认是否有官方迁移工具） |
| **Skills 重写** | 中 | Agent Skills 标准与 Claude Skills 可能不兼容，需重写脚本 |
| **端点适配** | 低 | MCP/A2A 为标准协议，客户端改动较小 |
| **Sandbox 配置** | 低 | 选择提供商并配置 API key |

**估算**：小型项目（<5 个 Skills）约 1-2 天；中型项目（10+ Skills）约 1 周。

## 对你的意义

如果你正在构建 Agent-Playbook 中追踪的「Agent 工程化」内容，Deep Agents Deploy 是一个值得深入分析的案例：

1. **开放 vs. 封闭的范式之争**：这不仅是技术选择，更是生态战略。LangChain 押注「开放标准 + 多提供商」，Anthropic 押注「垂直整合 + 体验优化」。长期看，企业客户可能更倾向开放方案（避免锁定），但初创团队可能更看重 Anthropic 的一体化体验。

2. **记忆作为核心资产**：这篇文章强化了一个观点 —— Agent 的真正价值不在模型能力（可替换），而在积累的记忆和领域知识（难迁移）。这为「Agent 评估」提供了新维度：不仅要看任务成功率，还要看记忆可移植性。

3. **MCP/A2A 协议成熟度**：Deep Agents Deploy 同时支持 MCP 和 A2A，说明这两个协议正在成为 Agent 互操作的事实标准。值得在 Agent-Playbook 中追踪协议演进。

**建议**：
- **立即试用**：如果你正在评估 Agent 部署方案，用 `deepagents init my-agent` 花 30 分钟体验工作流
- **观望**：如果你已稳定使用其他方案且无痛点，可等 beta 阶段结束（API 可能变化）
- **跳过**：如果只需要本地开发，`deepagents dev` 已足够，无需部署

## 关键代码/配置片段

### deepagents.toml 配置示例

```toml
[agent]
name = "research-assistant"
model = "anthropic:claude-sonnet-4-6"

[sandbox]
provider = "daytona"
template = "deepagents-deploy"
image = "python:3"
scope = "thread"  # 每个对话独立 sandbox
```

### 项目结构

```
my-agent/
├── deepagents.toml      # Agent 配置
├── AGENTS.md            # 系统 prompt（记忆核心）
├── .env                 # API keys
├── mcp.json             # MCP 服务器配置（HTTP/SSE only）
└── skills/
    ├── code-review/
    │   └── SKILL.md     # 代码审查技能
    └── data-analysis/
        └── SKILL.md     # 数据分析技能
```

### AGENTS.md 示例（系统 prompt）

```markdown
# Research Assistant

You are a research assistant specialized in AI agent engineering.

## Project Conventions
- Always cite sources when making claims
- Prefer primary sources (official docs, GitHub repos) over blog posts
- When uncertain, mark as "TODO: verify"

## Preferences
- Use Chinese for analysis, English for technical terms
- Keep responses structured with clear headings
```

### 部署命令

```bash
# 安装 CLI
uv tool install deepagents-cli

# 或直接运行（无需安装）
uvx deepagents-cli deploy

# 本地开发模式
deepagents dev --config deepagents.toml --port 2024

# 生产部署
deepagents deploy --config deepagents.toml
```

### MCP 配置示例（mcp.json）

```json
{
  "mcpServers": {
    "github": {
      "url": "https://mcp.github.com/sse",
      "transport": "sse"
    },
    "filesystem": {
      "url": "http://localhost:8080/mcp",
      "transport": "http"
    }
  }
}
```

⚠️ **注意**：部署环境不支持 stdio 传输的 MCP 服务器，必须使用 HTTP 或 SSE。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | Deep Agents Deploy 原生支持 MCP 协议，将 Agent 暴露为 MCP 工具，强化 MCP 作为标准接口的地位 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | 通过 A2A 协议端点，Deep Agents Deploy 支持多 Agent 调用，表明多 Agent 协作正在产品化 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 生产级部署方案的出现（Deep Agents Deploy）表明企业正在将 Agent 从实验推向生产，工作流自动化需求增长 |

---

[← Back to Deep Dives](./README.md)
