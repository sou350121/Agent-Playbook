---
slug: the-battle-of-code-wikis
title: 谁才是屎山代码的救星？Repo Wiki vs Zread vs DeepWiki 实测
authors: [sou350121]
tags: [tools, documentation, code-intelligence, legacy-code, zread, qoder]
---

接手文档比脸还干净的“屎山”项目是每个开发者的噩梦。2025 年，AI 终于给出了答案。靈吾靈老师深度评测了四款主流的“Code Wiki”工具，帮我们找到了穿越代码迷雾的指南针。

### 核心战报
1.  **Qoder - Repo Wiki (工程首选)**：功能最稳，支持持续监控和 Mermaid 绘图。虽然收费（每万文件约 1 刀），但在 10x 生产力面前，这点钱几乎可以忽略。
2.  **Zread (学习利器)**：智谱出品，对中文支持极好，结构由浅入深。最近上新的 **Zread MCP** 虽然还在磨合期，但潜力巨大。
3.  **DeepWiki-Open (私有化之光)**：唯一支持本地部署和自定义大模型（如 GLM-4.7）的开源方案。
4.  **Google Code Wiki**：目前对私有仓库和中文支持较弱，处于公测摸索阶段。

### 终极组合拳
博主提供了一个极具启发性的工作流：
> **用 Qoder 维护知识库 -> 用 Skill Seekers 蒸馏成技能包 -> 用 Claude Code 基于技能包开发新功能。**

<!-- truncate -->

> 详细工具对比见：[代码智能与文档生成指南](../stack/tools/code-wiki-comparison-guide.mdx)
