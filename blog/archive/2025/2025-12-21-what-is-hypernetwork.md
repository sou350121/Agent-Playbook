---
slug: what-is-hypernetwork
title: 什么是 Hypernetwork？大模型的“场外指导老师”
authors: [sou350121]
tags: [hypernetwork, lofa, architecture, weight-prediction]
---

在讨论 LoFA 时，我们提到了“超网络（Hypernetwork）”。它是 AI 架构中一个非常硬核且有趣的概念：**一个用来生成另一个网络权重的神经网络**。

### 核心概念
- **主网络 (Target Network)**：负责干活的模型（如 Stable Diffusion, WAN）。
- **超网络 (Hypernetwork)**：负责观察需求（如指令），然后告诉主网络：“你应该把这些神经元的参数改成这样。”

<!-- truncate -->

### 为什么它在 2025 年重新火了？
过去 Hypernetwork 因为训练难、精度低被 LoRA 抢了风头。但在 LoFA 框架中，研究者利用它实现了“瞬间生成 LoRA”，让模型适配从“几小时训练”变成了“毫秒级预测”。

[查看深度技术文档获取更多细节]

