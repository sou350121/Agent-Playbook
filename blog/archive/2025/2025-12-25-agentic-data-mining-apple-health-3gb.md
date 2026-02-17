---
slug: agentic-data-mining-apple-health-3gb
title: 3.5GB 原始数据的“降维打击”：六叔的 Agentic 数据盘点实录
authors: [sou350121]
tags: [data-analysis, apple-health, claude-code, codex, agentic-workflow, quantified-self]
---

六叔 (@nake13) 刚才分享了一个震撼的案例：他利用 Coding Agent 对自己过去 10 年、体积高达 **3.5GB** 的 Apple Health 原始数据进行了一次全量盘点。

### 核心突破：抹平“数据税”
以往处理这种规模的 XML 数据，工程师需要花费数天编写 Python 脚本、处理复杂的 XML 嵌套并清洗异常值。而六叔通过 **Claude Code / Codex CLI**，实现了以下闭环：
1.  **自主探知**：Agent 自己去读 3.5GB 里的结构。
2.  **递归修正**：遇到代码跑不动或结构对不上，Agent 自己改代码。
3.  **深度洞察**：挖掘出“环境噪音”、“久坐时间”与“静息心率”之间的强相关性。

### 10x 工程师的启示
- **CLI 是必选项**：Web 端无法上传 GB 级文件。要处理真正的大数据，必须赋予 Agent **本地文件读写权**。
- **验证胜过信任**：六叔强调了“验证机制”。Agent 会产生幻觉，必须要求其输出**中间统计数据**或进行**交叉验证**。

<!-- truncate -->

> 深度方法论：[Agentic 数据分析实战指南](../stack/frameworks/agentic-data-analysis-best-practices.mdx)
