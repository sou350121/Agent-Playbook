# Agent 存储选型：SQLite, MySQL 还是 PostgreSQL？

在构建 Agent 系统时，选择合适的“记忆库”（数据库）决定了系统的上限。以下是针对不同 Agent 场景的选型对比。

## 选型矩阵

| 特性 | SQLite | MySQL (8.0+) | PostgreSQL |
| :--- | :--- | :--- | :--- |
| **并发写入** | ❌ 弱（文件锁） | ✅ 强 | ✅ 强 |
| **数据灵活性** | ❌ 弱 | ⚠️ 中（支持 JSON） | ✅ 强（JSONB + GIN 索引） |
| **金融计算** | ❌ 危险 | ✅ 较好（DECIMAL） | ⭐ 极佳（NUMERIC） |
| **部署成本** | ⭐ 极低（单文件） | ⚠️ 中 | ⚠️ 中 |
| **AI 兼容性** | ✅ 极佳（上下文小） | ✅ 良好 | ✅ 良好（扩展性极强） |

## 深度分析

### 1. 什么时候选 SQLite？
- **MVP / Demo 阶段**：Agent 只需要本地存储少量的配置或临时日志。
- **Edge Agent**：运行在手机或边缘设备上的 Agent。
- **单人工具**：不存在多用户并发操作。

### 2. 什么时候选 PostgreSQL？ (推荐)
- **金融/行情监控**：利用 `NUMERIC` 保证精度，利用窗口函数计算指标。
- **长短期记忆存储**：利用 `pgvector` 扩展同时存储结构化数据和向量数据。
- **复杂数据结构**：数据经常变动，需要高效检索 JSON 字段。

## 实战：计算 5 分钟涨幅 (PG 版)

在金融 Agent 中，你经常需要让模型帮你写 SQL。PG 的窗口函数语法非常清晰：

```sql
SELECT coin,
       price,
       LAG(price, 5) OVER (PARTITION BY coin ORDER BY timestamp) as price_5min_ago,
       (price - LAG(price, 5) OVER (PARTITION BY coin ORDER BY timestamp)) / 
       LAG(price, 5) OVER (PARTITION BY coin ORDER BY timestamp) * 100 as change_pct
FROM prices;
```

## 结论
如果你在做一个**赚钱**的 Agent（涉及金融、交易、监控），不要犹豫，直接上 **PostgreSQL**。如果你只是做一个**辅助**工具，**SQLite** 是最快的起步方案。






















