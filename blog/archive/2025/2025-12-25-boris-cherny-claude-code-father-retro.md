---
slug: boris-cherny-claude-code-father-retro
title: 消失的 IDE 与 200 个 PR：Claude Code 之父 Boris 的 2025 预言
authors: [sou350121]
tags: [claude-code, boris-cherny, karpathy, vibe-coding, engineering-culture, mindset]
---

圣诞节当天，Claude Code 的创造者 **Boris Cherny** 开启了 X 上的活跃模式，并与 Karpathy 进行了一场关于“编程 9 级地震”的深度互动。

### 核心爆料：震撼工程界的实录
1.  **IDE 消失术**：Boris 透露，作为顶尖工程师，他上个月整整一个月没有打开过 IDE。所有的代码（约 200 个 PR）全是由 **Opus 4.5** 编写的。
2.  **AI 原生调试 vs 老路子**：
    - **传统派**：挂载 Profiler，手动翻 Heap 分配（Boris 一开始也走了这条老路）。
    - **AI 原生派**：直接让 Claude 生成 Heap Dump，再让 Claude 读 Dump 找对象。**AI 一次命中 Bug 并提交 PR。**
3.  **6 个月原则**：不要为今天的模型做产品，要为 **6 个月后的模型** 做产品。
4.  **新人优势**：刚毕业的工程师因为没有“老模型的历史记忆”和“旧工具的路径依赖”，反而能把 AI 用得最有效。

### 启示
软件工程正在发生根本性的变化。最难的部分不是学习新工具，而是**不断重新调整自己的预期**。如果你还在用“人工”的方式处理问题，请提醒自己：**“Claude 可能就能直接搞定这个。”**

<!-- truncate -->

> 深度分析：[Boris 范式：如何通过 Agent 编排实现 20 个并行开发](../stack/frameworks/ai-native-debugging-vs-manual-profiling.mdx)
