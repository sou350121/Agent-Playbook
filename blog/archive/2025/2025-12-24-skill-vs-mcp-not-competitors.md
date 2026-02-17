---
slug: skill-vs-mcp-not-competitors
title: Skill vs MCP：不是替代关系，而是“灵魂”与“手脚”的互补
authors: [sou350121]
tags: [claude-code, skills, mcp, architecture, workflow]
---

WquGuru🦀 (@wquguru) 分享了一个非常有代表性的内部分享选择题：**Skill 和 MCP 到底是什么关系？**

### 核心结论
**Skill 和 MCP 本质上是互补的，而非替代关系。**

- **Skill**：通过注入领域专家指令、最佳实践和示例对话，为模型提供**特定任务的工作流（Workflow）**。它本质上是“灵魂注入”。
- **MCP**：作为标准化协议，为模型提供**外部资源、工具的调用入口**。它本质上是“安装手脚”。

### 为什么要区分？
如果你的需求是“教 AI 如何写好本公司的 React 组件”，你应该用 **Skill**；如果你的需求是“让 AI 能读写你的数据库或 Notion”，你应该用 **MCP**。

<!-- truncate -->

> 深度对比见：[架构分析：Skill 与 MCP 的边界与配合](../stack/frameworks/skill-vs-mcp-architecture.mdx)
