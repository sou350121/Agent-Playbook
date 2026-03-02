# 为什么 Palantir 从不让 AI “回忆”数据？聊聊 Text-to-SQL 的真实解法

企业里最常见的 AI 场景之一叫“问数”（Text-to-SQL）：用户用人话提问，系统返回一条 SQL 的结果。

但做过的人都知道：**把数据库直接丢给大模型，是灾难。**

- SQL 语法错、字段对不上、join 乱连
- 指标口径不一致（“收入”到底含不含退款？）
- 最可怕的是：它**一本正经编造一个数字**

真正的解法不是“训练一个更聪明的模型”，而是把问题从 **Prompt Engineering** 升级为 **System Engineering**：

> 不要让模型“回忆”数据，而要让模型“去查”数据；  
> 模型负责推理与编排，**计算与取数交给确定性工具**。

这也是 Palantir 在其 AIP / Foundry 体系里反复强调的一条工程路线：用 Ontology 把数据变成可操作的业务对象，用工具把推理闭环到可审计的执行链路中。

---

## 1) “直接 Text-to-SQL”为什么总会翻车？

Text-to-SQL 的难点很少是“模型不会写 SQL”，而是这三件事同时存在：

- **语义歧义**：用户没说清（“最好”=最高销售额？最高利润率？）
- **Schema 复杂性**：表太多、字段名反人类、口径藏在代码/人脑里
- **幻觉**：模型在缺少关键上下文时，会“补齐一个看起来合理的世界”

所以你越“放开让它自由写 SQL”，它越像在没有仪表的飞机上开盲飞。

---

## 2) Palantir 的思路：把 LLM 关进笼子里

### 2.1 Ontology：把“表”升维成“业务对象”

Palantir 把 Ontology 放在架构中心：它不只是薄薄的 semantic layer，而是把企业决策建模为 **data / logic / action / security** 的一体化系统。

在官方文档里，Ontology 被描述为“Palantir 架构的核心系统”，用对象（objects）、属性（properties）和链接（links）把碎片化数据源统一成可交互的语义世界，同时把业务规则、动作与安全策略编进同一张“决策图”里。  
参考：`https://palantir.com/docs/foundry/architecture-center/ontology-system/`

一句话翻译成“问数”语境：

- 你不应该让 LLM 面对 `t_fct_order_2023_v2` 这类物理表
- 你要让它面对 **订单 / 客户 / 工厂 / 渠道 / 指标** 这些语义对象

### 2.2 OAG：让模型做“编排器”，而不是“计算器”

Palantir 在文档中把“找上下文”当成构建检索增强系统里最难的部分，并给出了一套围绕语义检索/检索增强的工程方法（从基本语义检索到 HyDE、混合检索等）。  
参考：`https://www.palantir.com/docs/foundry/ontology/ontology-augmented-generation`

这和“直接让模型写 SQL 并给结果”最大的差别是：

- LLM **负责理解意图、选择工具、组装调用参数**
- 真正的取数/计算在 **确定性执行环境**里完成

你可以把它理解为：

> 从 “LLM = 数据分析师”  
> 变成 “LLM = 调度员 / 编排器（Orchestrator）”

### 2.3 Show Your Work：用可追溯性解决信任问题

企业敢不敢用问数，关键不在“能不能答”，而在“能不能解释、能不能追责”。

Palantir 的 Data Lineage 文档明确描述了：你可以在 lineage 图里追踪数据如何生成，并在界面中查看数据预览与生成代码（Code view），进一步跳转到代码工作簿或代码仓库。  
参考：`https://palantir.com/docs/foundry/data-lineage/explore-lineage/`

对“问数”场景而言，这意味着：

- 答案要带上**证据链**（查询/计算路径）
- 能追溯到**数据来源与加工逻辑**（至少到数据集/代码层面；更进一步可做 row-level drill-down）

---

## 3) 业界“问数”金标准：5 条防线（按重要性排序）

下面这 5 条，是你要构建“高容错 Text-to-SQL”的默认配置。

### 防线 1：语义层（Semantic Layer / Metric Store）

把“开放式写 SQL”变成“封闭式选指标”：

- Bad：`SELECT sum(amt) FROM ...`
- Good：`get_metric("Revenue", timeframe="last_month", region="CN")`

**越少自由度，越少幻觉空间。**

### 防线 2：Schema Linking（让模型看懂你的数据库）

必须做两类上下文增强：

- **列值样本/枚举值映射**：例如库里是 `East_China`，用户说“华东”
- **业务术语表（黑话）**：例如“大客户”= 年单量 > 100 万（而不是“很大”）

### 防线 3：慢思考 + 自查（多步推理与反馈回路）

模仿分析师工作流，而不是一步到位：

- 先“解释需求”：指标口径、时间窗、维度、过滤条件
- 再“生成候选查询/调用”
- **执行后再校验**：空集/异常值/单位量纲/同比环比边界
- SQL 报错就把错误信息回灌，让模型重写

### 防线 4：交互式澄清（解决“人没说清”）

当置信度低时，不要硬答，要反问：

- “最好”是销售额还是利润？
- “本月”是自然月还是过去 30 天？
- 币种/含税/是否含退款？

### 防线 5：确定性执行环境（SQL 引擎 / Python Sandbox）

复杂分析很多时候 **Python > SQL**：

- 让模型生成 Pandas/SQLAlchemy 代码
- 在沙箱里跑（只读权限、资源限额、可复现）
- 关键逻辑可以单元测试

---

## 4) 一句话总结

AI 问数的未来，不是“模型更会背数据”，而是：

- 一端用 **语义层**把口径/对象治理清楚
- 另一端用 **工具化与可追溯性**把大模型关进逻辑轨道

当你把“问数”做成一个可审计的执行图（而不是一次性生成的文本），它才从聊天机器人变成可信的数据分析系统。

---

## 配图建议（占位）

- `static/img/text-to-sql/palantir-ontology-system.png`（可引用 Palantir 文档图或自行重绘）
- `static/img/text-to-sql/text-to-sql-reference-architecture.png`（本文第 3 节的五层防线架构图）

---

## 参考链接

- Palantir Foundry：The Ontology system：`https://palantir.com/docs/foundry/architecture-center/ontology-system/`
- Palantir Foundry：Ontology-augmented generation：`https://www.palantir.com/docs/foundry/ontology/ontology-augmented-generation`
- Palantir Foundry：Explore data lineage：`https://palantir.com/docs/foundry/data-lineage/explore-lineage/`

> 我把这篇的“可复制架构”和“落地清单”抽成了 Docs：`docs/tools/text-to-sql-reliable-architecture.md`。

