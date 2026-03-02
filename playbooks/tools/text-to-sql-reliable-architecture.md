# Text-to-SQL 的真实解法：从“写 SQL”到“可审计的取数系统”

> **结论先行**：在企业“问数”（Text-to-SQL）场景里，最可靠的路线不是让 LLM 直接写 SQL 并给数字，而是让 LLM 做 **推理与编排**，把“取数/计算”交给 **确定性工具链**，并把结果放进 **可追溯（audit/lineage）** 的白盒执行图里。

---

## 1. 为什么“把数据库丢给模型”必翻车？

Text-to-SQL 的失败通常不是“模型不会写 SQL”，而是三类根因叠加：

- **语义歧义**：用户没说清（指标口径/时间窗/维度/单位）
- **Schema 复杂性**：表多、字段名不可读、口径散落在代码与人脑
- **幻觉**：缺上下文时模型会补齐一个“看起来合理”的世界

因此你要做的是：用系统工程把自由度压缩，把错误显性化，把执行确定化。

---

## 2. 参考系：Palantir 的 Ontology / OAG / Lineage（可引用证据链）

这套思路在 Palantir Foundry 的官方文档中有非常清晰的“系统化”表达：

- **Ontology 处于架构中心**：以 data / logic / action / security 四要素建模企业决策，并把数据统一为对象（objects）、属性（properties）、链接（links）。  
  `https://palantir.com/docs/foundry/architecture-center/ontology-system/`

- **Ontology-augmented generation**：强调“找上下文”是检索增强系统最难的部分，并给出从 basic semantic search 到 HyDE、混合检索等策略。  
  `https://www.palantir.com/docs/foundry/ontology/ontology-augmented-generation`

- **Data lineage**：提供图谱化追溯能力，并在界面中展示数据预览与生成代码（Code view），可跳转到代码工作簿/仓库。  
  `https://palantir.com/docs/foundry/data-lineage/explore-lineage/`

> **翻译成工程语言**：把 LLM 当作“编排器（orchestrator）”，把数据与指标口径交给“语义层”，把计算交给“确定性执行环境”，把解释与追责交给“审计与溯源”。

---

## 3. 一套可落地的 Text-to-SQL 参考架构（分层）

把系统拆成 6 层，每层都在减少幻觉与歧义：

1) **语义层（Semantic Layer / Ontology / Metric Store）**  
- 资产：指标（Metric）、维度（Dimension）、口径（Definition）、默认过滤（Default filters）  
- 输出：封装后的 **metric API**（而不是让模型拼 SQL）

2) **Schema/术语检索层（Schema Linking）**  
- 资产：表/列字典、业务术语表（glossary）、枚举值同义词、样本值（value examples）  
- 输出：为当前 query 检索出“最相关的一小撮” schema 与词表映射

3) **计划层（Plan / Clarify）**  
- 任务：把人话变成结构化意图（指标、时间窗、维度、过滤、排序、粒度）  
- 能力：低置信度时触发澄清问答（不要硬答）

4) **生成层（SQL 或 Tool Call）**  
- 优先：生成 **工具调用**（例如 `get_metric(...)`）  
- 兜底：生成 SQL，但必须在 guardrails 下执行

5) **确定性执行层（DB / Python Sandbox）**  
- SQL：只读账号、超时/限额、强制 `LIMIT`、必要时 `EXPLAIN`  
- Python：沙箱执行（资源配额、依赖白名单、网络隔离、可复现）

6) **审计与可解释层（Audit / Lineage / Show-your-work）**  
- 记录：意图解析、schema 证据、生成的 SQL/工具参数、执行日志、返回行数与采样  
- 展示：执行 DAG、可点击的来源与代码/数据集追溯

配图建议（占位）：

- `static/img/text-to-sql/text-to-sql-reference-architecture.png`

---

## 4. “不让模型写 SQL”的第一原则：封闭式指标接口

把自由度收敛到一个稳定接口，是准确率跃迁的最快方式。

### 4.1 指标 API（推荐）

- `get_metric(name, timeframe, grain, filters) -> dataframe`
- `get_dimension_values(dimension, query) -> candidates`
- `explain_metric(name) -> definition + lineage`

### 4.2 SQL 生成（兜底）

只有在满足以下条件时才让模型生成 SQL：

- schema 已检索并注入（少量、相关、带样本值）
- 指标口径已绑定（或在语义层可解释）
- 执行有严格 guardrails（见下一节）

---

## 5. SQL Guardrails：把“写对”变成“很难写错”

### 5.1 结构性约束（强制）

- **只读权限**：不允许 `INSERT/UPDATE/DELETE/DDL`
- **表/列 allowlist**：只允许访问被 schema linking 选中的对象
- **结果上限**：强制 `LIMIT N`（并对 N 设上限）
- **资源限额**：超时、扫描行数/字节上限、并发上限
- **解释优先**：先生成“意图 JSON”，再生成 SQL（可拦截明显不一致）

### 5.2 执行前检查（建议）

- SQL AST 解析：拒绝危险语法、拒绝跨库/跨 schema
- `EXPLAIN` + 规则：禁止全表扫、禁止笛卡尔积、禁止过深嵌套
- 单位/币种校验：避免“数对了但单位错了”

### 5.3 执行后自查（建议）

- 空集：自动提示可能原因（时间窗/过滤过严/口径不匹配）
- 异常值：触发二次验证（对比历史均值/同环比）
- 抽样展示：返回“数字 + 关键明细采样 + 查询说明”

---

## 6. 澄清机制：把“人没说清”变成产品能力

触发条件（示例）：

- 指标候选 > 1 且置信度差距小
- 时间窗缺失（“最近”）
- “最好/最大/最优”这类未定义比较标准

澄清问题模板：

- “你说的【最好】是指【销售额最高】还是【利润率最高】？”
- “你要看【本月自然月】还是【过去 30 天滚动】？”
- “是否需要【含税/不含税】？币种是【CNY/USD】？”

---

## 7. 为什么 Python Sandbox 越来越常见？

SQL 擅长筛选聚合，但这类需求用 Python 更稳：

- 同比/环比、异常检测、预测、分组窗口逻辑
- 复杂口径复用与单元测试
- 更可控的中间结果与调试体验

推荐做法：

- SQL 只做“取最小必要数据集”
- Python 做“确定性计算与可测试逻辑”

---

## 8. 落地检查清单（MVP → 生产）

### MVP（两周能做出来的）

- [ ] 指标字典（Metric catalog）+ 口径说明
- [ ] 术语表（Glossary）+ 枚举值同义词
- [ ] schema linking：把 query 映射到有限表/列集合
- [ ] 只读 SQL 执行器 + 超时/限额 + 强制 LIMIT
- [ ] 返回：数字 + SQL + 行数 + 数据源说明

### 生产（可上线、可审计）

- [ ] 指标 API（替代直接 SQL）
- [ ] AST/EXPLAIN 审查与策略引擎
- [ ] 全链路审计（intent / evidence / execution / output）
- [ ] lineage/证据链 UI（show your work）
- [ ] 评测集：歧义问法、口径陷阱、长尾 schema、对抗性输入

