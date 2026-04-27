# AI Agent 框架对比（2026-04 状态）

> 9 个主流框架 × 7 维度 · 选型决策矩阵 · 各自的"真正定位"

---

## 📊 主表：9 个框架 × 关键维度

| 框架 | 出品方 | 语言 | 抽象级别 | 状态管理 | Multi-Agent | MCP | 评测 | 生产就绪度 |
|------|-------|------|:-------:|:--------:|:-----------:|:---:|:----:|:--------:|
| **[LangChain](https://github.com/langchain-ai/langchain)** | LangChain | Py / TS | 高（过度抽象批评） | 弱（链式） | ⚠️ 通过 LangGraph | ✅ | LangSmith | ★★★ |
| **[LangGraph](https://github.com/langchain-ai/langgraph)** | LangChain | Py / TS | 中（DAG / 状态机） | ✅ 强（checkpointer） | ✅ Supervisor + Worker | ✅ | LangSmith | ★★★★ |
| **[CrewAI](https://github.com/crewAIInc/crewAI)** | CrewAI Inc | Py | 中（角色/任务） | 中 | ✅ 核心定位 | ⚠️ 第三方 | 自带 | ★★★ |
| **[AutoGen](https://github.com/microsoft/autogen)** | Microsoft | Py | 中（消息驱动） | 中 | ✅ 多 agent 对话 | ⚠️ | 自带 | ★★★（v0.4+） |
| **[OpenAI Agents SDK](https://github.com/openai/openai-agents-python)** | OpenAI | Py | 低（原语） | ✅ Handoffs / Sessions | ✅ | ⚠️ 通过 hosted tools | OpenAI Evals | ★★★★ |
| **[Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk-python)** | Anthropic | Py / TS | 低（原语） | ✅ Subagents | ✅ 原生（MCP servers） | ✅ 原生 | 自定义 / 第三方 | ★★★★ |
| **[Mastra](https://github.com/mastra-ai/mastra)** | Mastra | TS | 中（声明式） | ✅ Workflows + Suspend/Resume | ✅ | ✅ | 自带 evals | ★★★★ |
| **[PydanticAI](https://github.com/pydantic/pydantic-ai)** | Pydantic | Py | 中（type-safe） | 中 | ✅ Agent graphs | ✅ | Logfire 集成 | ★★★ |
| **[DSPy](https://github.com/stanfordnlp/dspy)** | Stanford NLP | Py | 高（声明式 + 优化） | 弱 | ⚠️ | ⚠️ | 自带（compile + evaluate） | ★★★ |

---

## 🎯 选型决策树

```
你的场景？
│
├─ 写一个简单 RAG / Tool-using Agent
│   ├─ Python  → LangChain（生态最大）或 PydanticAI（type-safe）
│   └─ TypeScript → Mastra（最现代）
│
├─ 多 Agent 协作 / 复杂状态机
│   ├─ Python  → LangGraph（DAG + checkpointer）或 OpenAI Agents SDK
│   └─ Multi-agent 是核心 → CrewAI / AutoGen
│
├─ 想要 MCP 原生支持
│   └─ Claude Agent SDK（最完整）或 LangGraph
│
├─ 长程任务 / 暂停-恢复
│   └─ Mastra（Suspend/Resume）或 LangGraph（checkpointer）
│
├─ 严格类型安全 / 大型代码库
│   └─ PydanticAI（Python）或 Mastra（TS）
│
├─ 想自动优化 prompt
│   └─ DSPy（compile-style 优化）
│
├─ 直接对接 OpenAI 生态
│   └─ OpenAI Agents SDK（hosted tools / Realtime API）
│
├─ 直接对接 Anthropic 生态
│   └─ Claude Agent SDK（Subagents / MCP / prompt caching）
│
└─ 给 Microsoft 生态供应链落地
    └─ AutoGen + Semantic Kernel
```

---

## 🔍 各框架的"真正定位"

### LangChain
- **真定位**：早期把所有 LLM 调用工程化的"通用粘合剂"
- **批评**：📎 [社区反馈](https://news.ycombinator.com/) 持续抱怨抽象过深、性能差、API 变动快
- **2026 现状**：仍是教学/原型最快上手的，但生产中**多数团队转 LangGraph 或换栈**
- 🧠 仅适合：快速原型、文档/教程项目

### LangGraph
- **真定位**：状态机驱动的 Agent 工作流
- **核心创新**：📎 显式 graph + checkpointer 让 Agent 可暂停/恢复/分支
- **生产案例**：[LinkedIn / Klarna / Replit 等](https://blog.langchain.dev/) 都在用
- 🧠 选它当：需要**可观测、可恢复**的多步 Agent 流水线

### CrewAI
- **真定位**：以"角色 + 任务"建模 multi-agent
- **特色**：📎 角色定义贴近商业团队比喻（Researcher / Writer / Reviewer）
- 🧠 选它当：业务方能直接读懂 agent 配置（"市场调研 Agent + 写手 Agent"）

### OpenAI Agents SDK
- **真定位**：OpenAI 官方原语层，Handoffs + Sessions + 内置 hosted tools
- **优势**：📎 与 GPT-5 / Realtime API / hosted MCP 深度集成
- 🧠 选它当：你已经全栈 OpenAI，不想搬到第三方框架

### Claude Agent SDK
- **真定位**：Anthropic 原语，Subagents + MCP + prompt caching 一等公民
- **优势**：📎 [Subagents](https://docs.anthropic.com/) 让分工天然 clean
- 🧠 选它当：用 Claude 做主力，需要 MCP / 长 context / prompt caching 的最佳工程实践

### Mastra
- **真定位**：TypeScript-first、声明式 Workflow + Eval 一体
- **优势**：📎 Suspend/Resume + 内置 evals + LangSmith-like 观测
- 🧠 选它当：TS 生态、想要"框架自带 eval"

### PydanticAI
- **真定位**：用 Pydantic 类型守护的 type-safe Agent
- **优势**：📎 静态类型 + Logfire 观测一体
- 🧠 选它当：Pydantic 重度用户、想 IDE 一路飘绿

### DSPy
- **真定位**：编译式 prompt 优化（不写 prompt，写 program）
- **特色**：📎 把 prompt 当作"可优化的子程序"
- 🧠 选它当：不愿手调 prompt，宁愿让框架优化

### Smolagents (HF)
- **真定位**：Code-action agent（让 LLM 写 Python 代码作为动作）
- **特色**：📎 [Hugging Face 出品](https://github.com/huggingface/smolagents)，强调"写代码而非 JSON"作为 action
- 🧠 选它当：研究方向、code-as-action 实验

---

## 📐 维度详解

### 抽象级别
- **低级（原语）**：OpenAI Agents SDK / Claude Agent SDK —— 你直接用 LLM API 原语
- **中级**：LangGraph / Mastra / PydanticAI / CrewAI —— 框架给一层 mental model
- **高级**：LangChain / DSPy —— 强抽象，可能成为障碍

### 状态管理（生产关键）
- **强**：LangGraph (checkpointer) · Mastra (Workflow Suspend) · OpenAI Agents SDK (Sessions)
- **中**：CrewAI · AutoGen · PydanticAI
- **弱**：LangChain (链式无状态) · DSPy

### MCP 支持（2025+ 越来越关键）
- **原生一等公民**：Claude Agent SDK
- **正式集成**：LangGraph · Mastra · PydanticAI · OpenAI Agents SDK
- **第三方/不完整**：CrewAI · AutoGen

### Eval 集成
- **自带 + 紧密**：Mastra (evals) · LangSmith (LangChain/Graph) · Logfire (PydanticAI)
- **官方独立工具**：OpenAI Evals · Braintrust（任何框架）
- **需自建**：CrewAI · AutoGen · DSPy（DSPy 有 compile-time evaluate 但运行时 eval 较弱）

---

## 🚩 选型时的常见陷阱

| 陷阱 | 为什么 |
|------|------|
| **"用最热门的"** | LangChain 最热不等于最适合你的场景 |
| **"先用通用框架，以后再优化"** | 抽象层会成为后期改架构的最大障碍 |
| **"反正都封装了 LLM API"** | 状态管理、observability、可恢复性差异巨大 |
| **"我们多 agent 才厉害"** | [PULSE](../PULSE.md) 显示 SINGLE vs SWARM 竞争对中 single-agent coding 在 winning |
| **"框架自带 eval 就够了"** | 自带的 eval 多数是流程式 trace，不是真正的 quality 评估，需要 Braintrust / Inspect AI 等专业工具 |

---

## 📚 延伸阅读

- [Agent 设计：架构、记忆、工具](../theory/02-agent-design/) · 17 篇深度分析
- [Agentic 工程实战](../theory/03-engineering/) · 140+ 篇核心 ★
- [Prompt 模式速查](./prompt-patterns.md)
- [Agent 评测体系](./evaluation.md)
- [Agent 失效模式 T1-T6](./failure-modes.md)

---

[← Back to Cheat Sheet](./README.md)
