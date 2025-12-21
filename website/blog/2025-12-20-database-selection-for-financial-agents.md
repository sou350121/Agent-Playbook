---
slug: database-selection-for-financial-agents
title: 金融级 Agent 存储选型：为什么高手偏爱 PostgreSQL？
authors: [sou350121]
tags: [database, postgresql, financial-data, agent-storage]
---

今日技术争鸣：0xmiracle 分享了在金融行情监控场景下，为何最终放弃 SQLite 和 MySQL，转而选择 PostgreSQL (PG)。

### 核心选型逻辑
- **放弃 SQLite**：败在并发写入。对于多路爬虫+监控同时写入的场景，文件锁是致命伤。
- **放弃 MySQL**：在 JSON 处理的灵活性和金融级精度计算的便捷性上，MySQL 略逊一筹。
- **拥抱 PG**：
    - **NUMERIC 类型**：保证金融计算绝对不丢数据。
    - **JSONB 索引**：灵活应对频繁变动的代币/行情数据结构。
    - **原生窗口函数**：计算涨跌幅、移动平均只需一行 SQL。

<!-- truncate -->

### 给 Agent 开发者的建议
虽然 Vibe Coding 让你可以快速切换数据库，但底层的**数据一致性**和**并发能力**是 AI 无法帮你“磨平”的硬件限制。对于需要处理钱、交易、实时监控的 Agent，**PostgreSQL** 是目前的行业金标准。

[原文参考：0xmiracle]






















