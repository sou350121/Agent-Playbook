---
slug: glm-47-agent-first-model
title: GLM-4.7：面向编程与 Agent 的国产 MoE 强力竞争者
authors: [sou350121]
tags: [model-comparison, agents, GLM, MoE]
---

最近 AI 领域的英文 KOL 都在转发 GLM-4.7，Hacker News 上的讨论也异常热烈。这款模型与泛聊天模型不同，其核心定位非常明确：**编程与 Agent**。

### 核心亮点
- **MoE 架构**：通过混合专家模型实现算力效率的最大化。
- **长上下文 (200k)**：极适合处理多文件、长代码库任务。
- **工具调用优化**：原生兼容 OpenAI-style tool calling，几乎可以零成本接入现有的 Agent 框架。
- **状态保留 (Preserved Thinking)**：支持多轮状态保留，对长链路 Agent 任务至关重要。

### 工程挑战
- **显存黑洞**：MoE 虽然省算力，但全权重体积巨大，本地推理对硬件要求极高。
- **量化波动**：低 bit 量化后稳定性有所下降。

<!-- truncate -->

> 详细优劣势对比见：[GLM-4.7 模型评测](../stack/model-comparisons/glm-47-review.mdx)
