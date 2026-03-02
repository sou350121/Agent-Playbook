# AI Agent 记忆系统：从短期到长期的技术架构与实践（上下文工程 + 长期记忆）

随着 AI Agent 应用走向更复杂、更长任务，“记忆”从可选项变成了必选项：上下文窗口有限、token 成本持续上升、以及“如何让 AI 记住用户偏好与历史交互”都会直接决定一个 Agent 能不能变成产品。

（图片：记忆分层示意图，建议放 `static/img/agent-memory/overview.png`）

---

## 1. Memory 的基础概念：不要只按“时间”划分

对 Agent 而言，“记忆”至少有两个层面：

- **会话级记忆（短期 / Session memory）**：单次会话里的多轮交互（用户输入、模型回复、工具调用及结果等）。
- **跨会话记忆（长期 / Long-term memory）**：从多次会话中抽取出来的、可复用的信息（偏好、事实、经验、任务上下文等），用于跨会话辅助推理。

关键点：短期/长期并不是“更久=更长期”这么简单，而是**是否跨 session**。长期记忆通常从短期记忆中“提炼”而来，并在之后回注到短期记忆中，形成闭环。

---

## 2. 各 Agent 框架对“记忆”的命名差异（但模式一致）

不同框架的术语不一样，但基本都在做同一件事：

- **Google ADK**：`Session` 负责单次对话的 events/state；`MemoryService` 提供跨会话的“可搜索长期知识库”。  
  参考：[`https://google.github.io/adk-docs/sessions/memory/`](https://google.github.io/adk-docs/sessions/memory/)
- **LangChain / LangGraph**：短期记忆在核心组件里；长期记忆通过 LangGraph persistence 的 store 实现（更偏“外挂知识库/画像库”）。  
  参考：[`https://docs.langchain.com/oss/python/langchain/long-term-memory`](https://docs.langchain.com/oss/python/langchain/long-term-memory)
- **AgentScope**：提供 memory 原子能力（存储/标记/检索），压缩等策略更多由 agent 侧实现；并支持独立“长期记忆”模块。  
  参考：[`https://doc.agentscope.io/zh_CN/tutorial/task_memory.html`](https://doc.agentscope.io/zh_CN/tutorial/task_memory.html)

---

## 3. 集成记忆系统的通用架构（4 步闭环）

无论你用什么框架，集成记忆通常都会落在下面 4 步：

1. **推理前加载（Retrieve before think）**：根据当前 query，从长期记忆检索相关信息
2. **上下文注入（Inject）**：把检索结果注入短期记忆，作为 LLM 输入的一部分
3. **记忆更新（Record after act）**：推理完成后，从短期记忆抽取有效信息写入长期记忆
4. **信息处理（Extract / Embed / Index）**：长期记忆内部做信息提取、向量化、存储、检索、重排

---

## 4. 短期记忆：上下文工程（Context Engineering）才是第一性问题

短期记忆就是“messages/events”，它直接喂给模型，但你会立刻遇到两个硬约束：

- **max tokens 上限**
- **成本与延迟随上下文长度线性/超线性上升**

所以短期记忆的工程核心，不是“都塞进去”，而是“如何在信息不丢关键性的前提下，把上下文变短”。

常见三策略：

### 4.1 上下文缩减（Context Reduction）

- **保留预览**：超长内容只保留前 N 字或关键片段
- **摘要压缩**：用小模型/便宜模型把长内容总结成短摘要

代价：信息会丢，属于“牺牲细节换成本”。

### 4.2 上下文卸载（Context Offloading）

把大块内容卸载到外部存储（文件/DB），在短期上下文中只留最小引用（path/UUID）。需要时可按引用拉回。

优势：上下文更干净，信息不丢，还能随取随用；特别适合网页搜索结果、超长工具输出、日志等。

### 4.3 上下文隔离（Context Isolation）

用多智能体/子任务隔离，把“巨大上下文”关进子 agent：主 agent 只给简短指令，只收最终结果。

适用：needle search、单点抽取、一次性转换等“只要结果”的任务。

---

## 5. 长期记忆：Record & Retrieve 是两条管道

长期记忆的核心是双向交互：

- **Record（写入）**：从短期记忆里提取“事实/偏好/经验”，写入长期记忆
- **Retrieve（检索）**：按当前 query 检索相关记忆，并回注短期记忆

实践上长期记忆往往是独立组件（Mem0 / Zep / 等）以 API 方式接入，因为它内部通常包含：抽取、embedding、向量库、重排、审计日志等完整链路。

---

## 6. 一个可落地的长期记忆技术架构（最小完整形态）

长期记忆常见组件（按功能拆解）：

1. **LLM**：信息抽取/归纳/更新决策（把“对话”提纯成“记忆条目”）
2. **Embedder**：把文本/结构化信息向量化
3. **VectorStore**：向量持久化与语义检索
4. **(可选) GraphStore**：实体-关系（更适合复杂关系推理）
5. **(可选) Reranker**：重排提升相关性
6. **Audit log（例如 SQLite）**：记忆操作留痕，支持版本回溯与合规审计

（图片：Record/Retrieve 流程图，建议放 `static/img/agent-memory/record-retrieve.png`）

---

## 7. 长期记忆 vs RAG：像，但不等同

“长期记忆”在技术上常常用 RAG 组件实现（embedding + 向量检索 + 回注上下文），但两者有本质差异：

- **RAG**：更偏“外部知识库”（事实/文档），强调“查询→检索→生成”
- **长期记忆**：更偏“个性化 + 持续更新”（用户画像、偏好、历史状态、经验），强调“写入→巩固→遗忘→检索”


---

## 8. 关键挑战：准确性 / 安全隐私 / 多模态 / 参数化记忆

### 8.1 准确性（写入质量 + 检索质量）

- 写入：用户画像建模、记忆巩固/更新/遗忘机制
- 检索：embedding/检索/重排能力，避免噪声与错召回

### 8.2 安全与隐私（这是红线）

记忆会积累大量敏感信息，必须考虑：

- 访问控制与加密
- 防止恶意注入/数据投毒
- 用户对自己数据的掌控（可查看/可删除/可导出）

### 8.3 多模态记忆

文本/图像/语音往往仍是孤岛：统一的多模态记忆空间、跨模态检索与低延迟仍是难点。

### 8.4 参数化记忆（把记忆写进模型参数）

优点：推理快；缺点：更新成本高、灾难性遗忘、难以审计。工程上更常见的是“外部记忆增强”为主。

---

## 9. 进一步阅读

- FlowLLM Context Engineering（资料索引）：  
  [`https://github.com/FlowLLM-AI/flowllm/tree/main/docs/zh/reading`](https://github.com/FlowLLM-AI/flowllm/tree/main/docs/zh/reading)
- Google ADK Memory：  
  [`https://google.github.io/adk-docs/sessions/memory/`](https://google.github.io/adk-docs/sessions/memory/)
- LangChain Long-term memory：  
  [`https://docs.langchain.com/oss/python/langchain/long-term-memory`](https://docs.langchain.com/oss/python/langchain/long-term-memory)
- AgentScope Memory：  
  [`https://doc.agentscope.io/zh_CN/tutorial/task_memory.html`](https://doc.agentscope.io/zh_CN/tutorial/task_memory.html)
- O-Mem（个性化长期记忆研究）：  
  [`https://arxiv.org/abs/2511.13593`](https://arxiv.org/abs/2511.13593)

---

> 结论：短期记忆靠上下文工程“控成本”，长期记忆靠 Record/Retrieve“可持续进化”。能不能把这两套管道做成闭环，决定了你的 Agent 是“聊天玩具”，还是“长期可用的数字员工”。

