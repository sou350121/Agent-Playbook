---
slug: agentic-coding-doc-engineering
title: Agentic Coding 的本质：从 Vibe Coding 到“文档工程”
authors: [sou350121]
tags: [agentic-coding, doc-engineering, workflow, codex, claude-code]
---

郭宇（`@turingou`）这段实践有一个非常强的结论：**Agentic Coding 本质上是文档管理的艺术**。当自然语言成为主要编程媒介，软件工程会部分“翻译”为文档工程。

### 一句话提炼
- **代码是产物，文档是操作系统**：你越来越少直接管理代码，而是管理“需求故事网”，由 Agent 让代码在故事网下自然生长。

<!-- truncate -->

### 他的方法论里最可复制的 4 个机制
- **Agent Constitution**：先写一份“宪法”，规定 Agent 的边界、输出格式、权限与安全约束。
- **`roadmap.md` 是母文档**：所有需求从 `roadmap:v0.1` 的迭代 session 派生出来，形成一条可追溯的演进链。
- **`stories/xxx.md` 作为可测试需求单元**：每个 story 是一个完整、可验收的需求白板，包含任务拆分、完成状态、关联文件路径。
- **docs 网状结构做事实账本**：每完成一个 story，就在 `docs/` 的对应路径沉淀一组文档；后续 bug 修复也继续在同一组文档里记录进度，最终形成“产品的故事与描述文件”。

### 关键洞察
- 传统软件工程里，这是 PM/Tech Writer 的工作；但在 agentic coding 里，**工程师要负责把“需求叙事系统”维护好**。
- 与其强行维护一个“万能 architecture 文档”，不如维护**产品故事与需求描述**：它们更贴近迭代现实，也更能驱动 Agent 稳定产出。

原推：`https://x.com/turingou`
