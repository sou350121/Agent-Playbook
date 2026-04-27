# Agent-Playbook 速查表 (Cheat Sheet)

涵盖 AI Agent 工程领域核心框架对比、提示模式、评测体系、失效模式的快速参考。

> **更新**：2026-04-27 · 涵盖 LangChain → Claude Agent SDK · 主流 5 大 prompt patterns · 6 大 eval 工具

---

## 📚 速查内容

1. **[Agent 框架对比](./frameworks.md)** — LangChain / LangGraph / CrewAI / OpenAI Agents SDK / Claude Agent SDK / Mastra / PydanticAI / DSPy / Smolagents
2. **[提示模式速查](./prompt-patterns.md)** — Few-shot / CoT / ReAct / Reflexion / XML 结构化 / Tool calling
3. **[Agent 评测体系](./evaluation.md)** — LangSmith / Braintrust / Phoenix / Inspect AI / Promptfoo / DeepEval · 评测策略与指标
4. **[失效模式 T1-T6](./failure-modes.md)** — Agent 失败分类学（基于 [agent-failure-taxonomy](../theory/03-engineering/agent-failure-taxonomy.md)）

## 使用建议

- **选框架前**：[frameworks](./frameworks.md) 决策矩阵看你的需求落在哪
- **写 Agent 前**：[prompt-patterns](./prompt-patterns.md) 找对应模式 + Anthropic 4-shot 最佳实践
- **eval 不是事后**：[evaluation](./evaluation.md) 把 eval loop 嵌入开发流程
- **Debug Agent 出问题**：[failure-modes](./failure-modes.md) 用 T1-T6 分类排查

## 🚨 常见认知误区

1. ❌ **"用 LangChain 就够了"** —— 2026 年场景下，LangGraph、Claude Agent SDK、OpenAI Agents SDK 在状态管理 / 多 agent / MCP 各有显著优势
2. ❌ **"prompt 写得越长越好"** —— Anthropic 4-shot prompting + XML tags 通常优于 100 行 system prompt
3. ❌ **"先做完功能再加 eval"** —— eval 是生产实践，不是测试阶段的事（[03-engineering 核心论点](../theory/03-engineering/eval-loop-as-production-practice.md)）
4. ❌ **"Multi-agent 一定比 single agent 好"** —— [PULSE](../PULSE.md) 上 SINGLE vs SWARM 竞争对显示当前 single-agent coding 远 winning
5. ❌ **"MCP 是终点"** —— MCP 解决工具协议；context engineering 是另一条独立的路（参见竞争对 ACT vs THINK）

---

[← Back to Agent-Playbook](../README.md)
