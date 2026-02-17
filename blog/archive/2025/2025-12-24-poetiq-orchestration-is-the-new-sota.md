---
slug: poetiq-orchestration-is-the-new-sota
title: 决定 AI 上限的已不再是底座，而是“推理编排” (Orchestration)
authors: [sou350121]
tags: [orchestration, agent-system, ARC-AGI, methodology]
---

Poetiq 最近的一项研究震撼了 AI 圈：在底座模型（GPT-5.2 xhigh）完全不变的前提下，仅靠一套 **Agentic Orchestration Layer（推理编排层）**，就让模型在极难的 ARC-AGI-2 测试中，成绩从 60% 飙升至 **75%**。

### 核心结论
- **智力溢出**：底座模型的能力往往被低估了，缺乏的是高效的“指挥部”。
- **Orchestration > Base Model**：决定上限的已不再是模型本身，而是外围的编排系统。
- **元系统 (Meta-system) 的威力**：这不是简单的提示词技巧，而是架构层面的迭代。

### 编排层的闭环流程
1. **自动生成**：生成大量候选解（甚至直接写代码）。
2. **闭环检查**：利用样例或反馈进行自动化检查。
3. **迭代修正**：根据反馈反复优化，直到通过审计。
4. **自我审计**：自主决定何时停止，避免算力空转。

<!-- truncate -->

> 深度分析见：[推理编排与元系统：榨干 LLM 的最后一滴潜力](../stack/frameworks/agentic-orchestration-meta-system.mdx)
