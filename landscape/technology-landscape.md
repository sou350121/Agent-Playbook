# Technology Landscape（AI 应用开发生态全景图）

> **维护方式**：人写、低频更新。
>
> 目的不是"写得长"，而是提供一张稳定的地图：帮助你在 `cognition/app_index.md` 的高频条目之上，形成对生态的分层理解。
>
> **最后更新：** 2026-02-23

---

## 1. 怎么用这张图？

- **快速查工具/应用**：看 [`cognition/app_index.md`](./app_index.md)
- **读深度分析**：看 `action/tools/`、`cognition/frameworks/`、`cognition/methodology/`
- **要落地做事**：看 `action/` 与 `use-cases/`
- **要看趋势推理**：看 `memory/reports/`

---

## 2. 分层视角与代表性工具

### Agent 层（编排 / 记忆 / 评估 / 工具调用）

| 类别 | 代表开源项目 | 代表商业产品 | 关键分岔点 |
|:---|:---|:---|:---|
| 编排框架 | LangGraph, AutoGen, CrewAI | LangChain Cloud | 有状态 vs 无状态 |
| 工具协议 | MCP (Model Context Protocol) | Claude for Work | 通用 vs 专用 |
| Agent UI 协议 | AG-UI (open spec) | — | 前端可互换性 |
| SDK | OpenAI Agents SDK, Anthropic Claude SDK | — | 原生 tool use |
| 记忆 | Mem0, Letta | — | 短期/长期/外化 |
| 评估 | promptfoo, Braintrust | LangSmith | 离线 vs 在线 |

### Data 层（检索 / 语义 / 治理）

| 类别 | 代表开源项目 | 代表商业产品 | 关键分岔点 |
|:---|:---|:---|:---|
| 向量数据库 | Qdrant, Weaviate, pgvector | Pinecone | 延迟 / 规模 |
| RAG 框架 | LlamaIndex, Haystack | — | 检索精度 vs 成本 |
| 数据治理 | — | Alation, Collibra | 审计链路 |

### Runtime 层（沙箱 / 部署 / 成本）

| 类别 | 代表开源项目 | 代表商业产品 | 关键分岔点 |
|:---|:---|:---|:---|
| 代码沙箱 | E2B, Modal | — | 安全隔离 |
| 推理加速 | vLLM, SGLang | — | 吞吐 vs 延迟 |
| 网关/代理 | LiteLLM | — | 多模型路由 |
| 部署 | Docker + Fly.io | — | 成本 / 弹性 |

### UI 层（对话 / 工作流 / 可视化）

| 类别 | 代表开源项目 | 代表商业产品 | 关键分岔点 |
|:---|:---|:---|:---|
| 低代码 AI UI | Dify, Flowise, Langflow | — | 易用性 vs 灵活性 |
| IDE 集成 | Continue, Cursor | GitHub Copilot | 深度 vs 广度 |
| CLI Agent | Aider, Claude Code | — | 自主度 |
| HITL 界面 | — | — | 人在回路频率 |

### Governance 层（安全 / 可回滚 / 可解释）

| 类别 | 工具/做法 | 风险点 |
|:---|:---|:---|
| 输入过滤 | Rebuff, Guardrails AI | Prompt injection |
| 输出验证 | promptfoo evals, custom validators | 幻觉 / 格式错误 |
| 审计 | Langfuse, Helicone | token 泄漏 / 成本失控 |
| IDE 安全 | 见 `action/security/` | 配置文件自动执行风险 |

---

## 3. 信号到资产的闭环

```
每日 RSS / X / GitHub Trending
          ↓
   Moltbot 收集 + 过滤
          ↓
  memory/blog/archives/ai-daily-pick/   ← 短期信号
          ↓ (每双周)
  memory/reports/                        ← 趋势推理
          ↓ (提炼后)
  cognition/app_index.md                ← 工具索引（append-only）
  cognition/frameworks/                 ← 框架/范式深度文章
  action/tools/                         ← 落地实作指南
```

---

## 4. 当前关注热点（2026 Q1）

- **MCP 生态扩展**：越来越多的工具（IDE、数据库、API）支持 MCP 接入，成为 Agent 工具调用的事实标准。
- **AG-UI 协议**：前端 Agent UI 互操作协议，使 Agent 后端与前端解耦。
- **OpenAI Agents SDK + Anthropic Claude SDK**：两大 SDK 进入生产级稳定，成为应用开发主干。
- **Vibe Coding 普及化**：从少数先行者到主流工程团队，agentic coding 正在重塑交付节奏。
- **评估体系成熟**：promptfoo / Braintrust / LangSmith 从实验工具升级为 CI/CD 必备。
