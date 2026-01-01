---
title: "Raschka 2025 LLM 年度盘点：推理、推理时扩展、以及 MCP 成为工具访问标准"
authors: [sou35]
tags: [LLM, Reasoning, RLVR, GRPO, MCP, Agents, RAG, 2025]
---

> 原文：`https://magazine.sebastianraschka.com/p/state-of-llms-2025`

这是一份对 2025 年 LLM 进展与问题的“年度清单”。对做 **Agent / Coding Agent / 工具调用系统**的人来说，里面最值得关注的不是某个模型单点，而是 **推理范式 + 推理时扩展 + 工具生态** 这三条线的合流。

---

## 我认为最关键的 7 个要点（面向工程）

1. **推理年（Reasoning）成真**
   - 2025 年，多家推理模型在重要数学竞赛上已达到“金牌级”表现。
   - 意味着：推理能力的上限提升得比许多人预期更快。

2. **RLVR / GRPO 成为训练与对齐的关键词**
   - Raschka 将 GRPO 称为“年度研究宠儿”。
   - 对工程启示：推理模型的能力进展，越来越多来自“训练策略与对齐方式”，而不是单纯堆大。

3. **推理时扩展（Inference-Time Scaling）与工具使用变成主线**
   - 不只训练，推理阶段也在“规模化”提升性能（例如更强的搜索、更多工具调用、更长的思考预算）。
   - 对 Agent 启示：系统层的调度、工具链、上下文投喂，正在变成性能的关键来源。

4. **“Benchmaxxing”成为年度词（基准刷榜文化）**
   - 对实践者启示：更要用“真实任务/真实成本”评估模型，而不是只看榜单。

5. **开源权重生态发生迁移：Qwen 等崛起、更多竞品出现**
   - Raschka 观察到：Llama 的热度在开源权重社区明显下降；Qwen 超越 Llama（以下载/衍生量衡量）。
   - 同时更多开源/开放权重阵营加入（Kimi/GLM/MiniMax/Yi 等）。

6. **更便宜更高效的混合架构优先级上升**
   - 对工程启示：未来一年更可能看到“性价比架构创新”，而不是只追求单模型极限。

7. **MCP 更快成为 Agent 工具/数据访问标准**
   - Raschka 提到：MCP 加入 Linux Foundation 后，已在 agent-style 系统中成为工具访问标准（至少在当前阶段）。
   - 对我们仓库的启示：工具能力的标准化接口，会显著降低 Agent 生态碎片化成本。

---

## 给做 Agent / Coding Agent 的 5 条启示

- **不要只做 Prompt**：工程竞争力越来越偏向“推理时扩展 + 工具链 + 任务治理”。
- **以真实任务驱动评估**：把 benchmark 当参考，别把刷榜当产品。
- **把工具访问做成标准件**：MCP 这类接口会成为“可靠系统”的基础设施。
- **RAG 形态会变**：经典“每问必检索”的默认做法会逐渐退潮，更多依赖长上下文与更好的小模型。
- **把能力提升归因到系统**：很多进展来自 tooling 与 inference-time scaling，而不只是“换模型”。

---

## 关联阅读（仓库内）

- `docs/capabilities/ai-coding-agent-architecture.mdx`（Agent/RAG/LangChain 与治理）
- `docs/beginner-guide/02-tool-stack.md`（MCP/Skills 入门）
