---
slug: notebooklm-plus-claude-skill-orchestration
title: 跨界编排：为什么用 Claude Skill 调 NotebookLM 比直接问更强？
authors: [sou350121]
tags: [notebooklm, claude-code, skills, knowledge-base, orchestration]
---

王树义老师 (@wshuyi) 最近分享了一个让人“愣神”的发现：他把自己海量的文章存入 NotebookLM，但**不直接在里面提问**。

### 核心玩法
- **数据源**：NotebookLM（存放公号与星球文章）。
- **执行层**：通过 Claude Skill 在 Alma/Claude Code 中调用。
- **结果对比**：直接提问的结果（图4）平平无奇；而通过 Claude Skill 调用的结果（图3）在丰富度和完整性上呈现出了质的飞跃。

### 为什么会这样？

<!-- truncate -->

