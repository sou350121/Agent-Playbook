# Agent 记忆系统：短期（上下文工程）到长期（可审计的外部记忆）架构

> **目的**：给工程团队一份可落地的“记忆系统蓝图”。  
> 重点不是概念科普，而是：**如何控 token 成本、如何让记忆可更新/可回滚/可删除、如何防止记忆变成“隐私与投毒的灾难现场”。**

---

## 1. 定义：短期记忆 vs 长期记忆

- **短期记忆（Session memory）**：本次会话的 messages/events（用户输入、模型输出、工具调用与结果）。直接进入模型上下文，受 token 上限与成本约束。
- **长期记忆（Cross-session memory）**：从多次会话提炼出的“可复用信息”（偏好、画像、事实、经验、历史状态）。通过检索回注短期记忆，辅助个性化与长任务。

工程上的关键区分：**是否跨 session**，而不是“时间远近”。

---

## 2. 通用闭环：Retrieve → Inject → Act → Record

一个可生产的记忆系统，至少要跑通这条闭环：

1. **Retrieve**：推理前，根据 query 从长期记忆检索相关条目
2. **Inject**：把检索结果以可控格式注入短期上下文（并明确来源/置信度/时间戳）
3. **Act**：模型推理、调用工具、修改状态
4. **Record**：推理后，从短期轨迹抽取“应该写入”的信息，更新长期记忆

注意：Record 与 Retrieve 不是对称操作——**写入策略**决定了你未来检索的噪声上限。

---

## 3. 短期记忆（Context Engineering）：三策略 + 一条铁律

铁律：**短期上下文必须是“最小必要信息集”**，而不是“完整聊天记录”。

### 3.1 Context Reduction（缩减）

适用：细节可丢、只需要 gist 的内容（例如超长工具输出）。

- preview（截断保留前 N 字）
- summarize（摘要）

### 3.2 Context Offloading（卸载）

适用：内容很长但可能要回看（网页、日志、长文档）。

做法：把内容写到外部存储（文件/DB/object store），短期上下文只留 `ref`（path/uuid）。

关键：卸载的内容必须可定位、可访问控制、可过期清理。

### 3.3 Context Isolation（隔离）

适用：只要结果，不要过程（needle search、抽取、一次性转换）。

做法：用子 agent/子任务隔离上下文，把“巨大上下文”关进子流程，主 agent 只收最终摘要/结构化结果。

---

## 4. 长期记忆（Record & Retrieve）：最小可用架构

### 4.1 组件清单（MVP）

- **Extractor（LLM）**：从 transcript 抽取“事实/偏好/经验/计划”并决定是否写入
- **Embedder**：向量化
- **Vector store**：语义检索与存储
- **Audit log（推荐）**：记录所有写入/更新/删除（可用 SQLite 起步）

### 4.2 可选增强

- **Reranker**：提升相关性、降低噪声
- **Graph store**：实体-关系（适合复杂关系与多跳推理）
- **Policy layer**：隐私/权限/保留策略（TTL、加密、分区）

---

## 5. 记忆条目怎么设计（建议 schema）

长期记忆最容易“烂掉”的原因，是你把它当作“另一份聊天记录”。建议把记忆当作“数据产品”，至少包含：

- **type**：`preference | profile | fact | instruction | skill | task_state`
- **subject**：`user_id / org_id / agent_id / project_id`
- **content**：结构化优先（JSON），文本作为补充
- **source**：来源证据（session_id、message_id、tool_result_ref）
- **timestamp**：产生时间与写入时间
- **confidence**：抽取置信度（或需要人类确认）
- **retention**：TTL / 是否可长期保留

---

## 6. 可靠性问题：写入错误比检索错误更致命

### 6.1 “写入污染”比“忘记”更可怕

一条错误的偏好（例如“用户喜欢英文”）会在未来持续污染输出，造成“越用越偏”的错觉。

建议：

- 把“偏好类/画像类”记忆设为**可撤销**（支持版本与回滚）
- 对低置信度记忆加上“待确认”标记

### 6.2 记忆要有“遗忘机制”

没有遗忘的系统必然熵增：噪声增长、召回变差、成本变高。

最小遗忘策略：

- TTL（自动过期）
- 低频访问淘汰
- 同类条目合并（consolidation）

---

## 7. 安全与隐私（生产必做）

长期记忆的风险不是“回答错”，而是：

- **泄露隐私**
- **被投毒**
- **不可解释与不可删除**

最低要求：

- 访问控制（按 user/org 分区）
- 加密（静态 + 传输）
- 审计（谁在什么时候写入/读取了什么）
- 用户数据权利：可查看/可导出/可删除

---

## 8. 与 RAG 的关系

技术上，长期记忆常用 RAG 组件实现；概念上，长期记忆更强调“个性化 + 可演化 + 可治理”。

本仓库的 RAG 入门（偏知识库角度）：[`rag-agent-memory.mdx`](../methodology/planning/rag-agent-memory.mdx)

---

## 9. 参考链接

- Google ADK Memory：[`https://google.github.io/adk-docs/sessions/memory/`](https://google.github.io/adk-docs/sessions/memory/)
- LangChain long-term memory：[`https://docs.langchain.com/oss/python/langchain/long-term-memory`](https://docs.langchain.com/oss/python/langchain/long-term-memory)
- AgentScope memory：[`https://doc.agentscope.io/zh_CN/tutorial/task_memory.html`](https://doc.agentscope.io/zh_CN/tutorial/task_memory.html)
- O-Mem（研究）：[`https://arxiv.org/abs/2511.13593`](https://arxiv.org/abs/2511.13593)

