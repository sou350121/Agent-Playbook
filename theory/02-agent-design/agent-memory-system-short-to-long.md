# Agent 记忆系统：短期（上下文工程）到长期（可审计的外部记忆）架构

> 📌 **02-agent-design — 记忆系统**

> **X-Ray 洞察**：Agent 的记忆问题本质是**资源调度问题**，不是"存储问题"。Context window 是 CPU 寄存器，向量库是 RAM，对象存储是磁盘——MemGPT 的突破在于把操作系统的虚拟内存思路搬进了 LLM 架构。
> 重点不是概念科普，而是：**如何控 token 成本、如何让记忆可更新/可回滚/可删除、如何防止记忆变成"隐私与投毒的灾难现场"。**

---

## 1. 四层记忆体系（完整分类法）

人类认知科学的四类记忆结构已被 2025-2026 年的主流 Agent 框架（MemGPT/Letta、MIRIX、Google ADK、Amazon Bedrock AgentCore）普遍采用：

```
┌─────────────────────────────────────────────────────────┐
│              Agent 四层记忆体系                           │
├──────────┬──────────────────────────┬───────────────────┤
│ 层级      │ 英文名                   │ 生命周期           │
├──────────┼──────────────────────────┼───────────────────┤
│ L1       │ Working Memory           │ 单次 session       │
│ L2       │ Episodic Memory          │ 天 / 周            │
│ L3       │ Semantic Memory          │ 持久（可更新）      │
│ L4       │ Procedural Memory        │ 模型生命周期        │
└──────────┴──────────────────────────┴───────────────────┘
```

### L1 工作记忆（Working Memory）
- **存储内容**：当前 context window 中的 messages、活跃任务状态、工具调用结果
- **特性**：容量受 token 上限约束；读写速度最快；session 结束即消失
- **工程类比**：CPU 寄存器

### L2 情景记忆（Episodic Memory）
- **存储内容**：历史交互摘要、决策轨迹、session 级别的事件日志
- **特性**：跨 session 持久化；以时间序列组织；支持"上次我们聊到哪里了"的检索
- **工程类比**：快速 SSD，近期数据热存

### L3 语义记忆（Semantic Memory）
- **存储内容**：领域知识、事实、用户偏好、实体关系——以 embedding 向量存储
- **特性**：语义检索；可增量更新；长期持久化；与时间顺序无关
- **工程类比**：向量数据库 / 知识图谱（RAM 级延迟，但容量无限）

### L4 程序记忆（Procedural Memory）
- **存储内容**：技能模式、学到的工作流、系统 Prompt 中的指令集、微调后的权重
- **特性**：最稳定；修改成本最高；体现"Agent 的性格和能力边界"
- **工程类比**：ROM / 模型权重

---

## 2. 定义：短期记忆 vs 长期记忆（工程视角）

- **短期记忆（Session memory）**：本次会话的 messages/events（用户输入、模型输出、工具调用与结果）。直接进入模型上下文，受 token 上限与成本约束。对应 **L1 工作记忆**。
- **长期记忆（Cross-session memory）**：从多次会话提炼出的"可复用信息"（偏好、画像、事实、经验、历史状态）。通过检索回注短期记忆，辅助个性化与长任务。对应 **L2-L3-L4**。

工程上的关键区分：**是否跨 session**，而不是"时间远近"。

---

## 3. 通用闭环：Retrieve → Inject → Act → Record

一个可生产的记忆系统，至少要跑通这条闭环：

1. **Retrieve**：推理前，根据 query 从长期记忆检索相关条目（L2/L3）
2. **Inject**：把检索结果以可控格式注入短期上下文（L1），并明确来源/置信度/时间戳
3. **Act**：模型推理、调用工具、修改状态
4. **Record**：推理后，从短期轨迹抽取"应该写入"的信息，更新 L2/L3

注意：Record 与 Retrieve 不是对称操作——**写入策略**决定了你未来检索的噪声上限。

---

## 4. MemGPT / Letta 架构：OS 启发的虚拟内存分页

MemGPT（2023，斯坦福）的核心突破：把操作系统的**虚拟内存分页**机制引入 LLM Agent。

```
MemGPT 内存层级（OS 类比）
══════════════════════════════════════════════════════
  Main Context（上下文窗口）   ←  CPU 寄存器 + L1/L2 Cache
  ┌─────────────────────────────────────────────────┐
  │  System Prompt (Core Memory)  [pinned, ~2k tok] │
  │  Conversation Buffer          [rolling window]  │
  │  Working Memory Block         [active task]     │
  └───────────────────┬─────────────────────────────┘
                      │ 分页调入/调出（Agent 自主决策）
  External Storage（外部存储）     ←  RAM + Disk
  ┌─────────────────────────────────────────────────┐
  │  Recall Memory  (conversation history + search) │
  │  Archival Memory (vector store, unlimited)      │
  └─────────────────────────────────────────────────┘
══════════════════════════════════════════════════════
```

### 关键机制

- **Self-editing memory**：Agent 可以通过工具调用（`core_memory_replace`、`archival_memory_insert`）**主动修改**自己的记忆，而不是被动存储。
- **分页调度**：当 token 接近上限，Agent 自主决定把什么"换出"到 archival，把什么"换入"主上下文。
- **Letta（2024 → 2026）**：MemGPT 的开源框架化产品。2026 年 2 月引入 **Context Repositories**（基于 git 版本化的可编程上下文管理）和 **Conversations API**（跨并行会话的共享记忆）。

---

## 5. 记忆选择矩阵

| 层级 | 存储后端 | 检索方式 | 适用场景 | 延迟 | 成本 |
|------|----------|----------|----------|------|------|
| L1 工作记忆 | Context window（内存） | 直接访问（无检索） | 当前任务状态、工具结果 | 0ms | 最高（按 token 计费） |
| L2 情景记忆 | SQLite / PostgreSQL / 时序 DB | 时间范围 + 关键词 | 上次交互摘要、任务历史 | 1-5ms | 低 |
| L3 语义记忆 | 向量数据库（Chroma/Pinecone/Weaviate） | ANN 语义检索 + 可选 rerank | 用户偏好、领域知识、FAQ | 10-50ms | 中（embedding 调用） |
| L4 程序记忆 | 模型权重 / System Prompt | 无（已编码进模型） | 固定技能、输出格式、行为约束 | 0ms | 最高（微调 = 一次性大投入） |

---

## 6. 短期记忆（Context Engineering）：三策略 + 一条铁律

铁律：**短期上下文必须是"最小必要信息集"**，而不是"完整聊天记录"。（Context rot 现象：上下文越长，模型注意力越分散，性能反而下降。）

### 6.1 Context Reduction（缩减）

适用：细节可丢、只需要 gist 的内容（例如超长工具输出）。

- preview（截断保留前 N 字）
- summarize（摘要）

### 6.2 Context Offloading（卸载）

适用：内容很长但可能要回看（网页、日志、长文档）。

做法：把内容写到外部存储（文件/DB/object store），短期上下文只留 `ref`（path/uuid）。

关键：卸载的内容必须可定位、可访问控制、可过期清理。

### 6.3 Context Isolation（隔离）

适用：只要结果，不要过程（needle search、抽取、一次性转换）。

做法：用子 agent/子任务隔离上下文，把"巨大上下文"关进子流程，主 agent 只收最终摘要/结构化结果。

---

## 7. 长期记忆（Record & Retrieve）：最小可用架构

### 7.1 组件清单（MVP）

- **Extractor（LLM）**：从 transcript 抽取"事实/偏好/经验/计划"并决定是否写入
- **Embedder**：向量化
- **Vector store**：语义检索与存储
- **Audit log（推荐）**：记录所有写入/更新/删除（可用 SQLite 起步）

### 7.2 可选增强

- **Reranker**：提升相关性、降低噪声
- **Graph store**：实体-关系（适合复杂关系与多跳推理）
- **Policy layer**：隐私/权限/保留策略（TTL、加密、分区）

---

## 8. 实战：RAG vs Fine-tuning vs Context Stuffing 决策树

> 这三种策略本质上对应 L3/L4/L1 的取舍，没有万能选择——只有情境最优解。

```
开始
  │
  ├─ 知识变化频率高？数据每天/每周更新？
  │   └─ YES → RAG（向量检索）
  │
  ├─ 需要严格的输出格式/风格一致性？分类任务？延迟 <200ms？
  │   └─ YES → Fine-tuning（L4 程序记忆）
  │
  ├─ 知识量少（<50 条）且本次任务必用？
  │   └─ YES → Context Stuffing（直接塞进 L1）
  │
  ├─ 以上均不是 → RAG 起步，再按需 Fine-tune 热点路径
  │
  └─ 合规/隐私要求严格？→ RAG（数据不烧进权重，可审计/可删除）
```

### 三维对比

| 维度 | Context Stuffing | RAG | Fine-tuning |
|------|-----------------|-----|-------------|
| 知识新鲜度 | 实时（手动塞） | 准实时（索引延迟） | 滞后（重新训练） |
| 可审计性 | 高（看得见） | 高（有检索日志） | 低（已内化权重） |
| 成本结构 | 按 token 付费（贵） | 中（embedding + 检索） | 高一次性（训练）+ 低推理 |
| 适合知识类型 | 任务即时信息 | 大规模领域知识 | 稳定技能/格式/风格 |
| 隐私合规 | 风险高（context 泄漏） | 中（检索可控） | 低风险（数据不在线） |

**黄金组合**：Fine-tune 负责"Agent 的性格和能力"（L4），RAG 负责"Agent 的知识更新"（L3），Context Stuffing 负责"当前任务的短期激活"（L1）。

---

## 9. 记忆污染问题（Memory Poisoning）

> **最危险的不是记忆丢失，而是记忆错误却持续影响输出。**

### 9.1 污染的三种来源

| 来源 | 典型案例 | 影响层级 |
|------|----------|----------|
| 抽取错误 | LLM 抽取了错误偏好（"用户喜欢英文"实际是临时切换） | L2/L3 |
| 对抗注入 | 恶意用户在会话中植入虚假事实，被写入 L3 | L3 |
| 数据漂移 | 旧知识未更新（公司政策已变，向量库未同步） | L3 |
| 概念混淆 | 不同用户的记忆被错误关联（多租户隔离失效） | L3/L4 |

### 9.2 防护策略

```
写入前
  ├─ confidence 阈值门控（低置信度 → "待确认"标记，不立即写入）
  ├─ 来源溯源（每条记忆必须有 source session_id + message_id）
  └─ 抽取 prompt 添加"不确定时宁可不写"指令

运行期
  ├─ 分区隔离（user_id / org_id 严格分区，禁止跨区检索）
  ├─ 时间衰减（老记忆降权而非删除，保留审计链）
  └─ 矛盾检测（新写入与已有记忆语义冲突 → 触发人工确认）

纠错
  ├─ 版本化（支持回滚到写入污染前的状态）
  ├─ 软删除（逻辑删除 + 审计日志，而非物理删除）
  └─ 用户可干预（提供"纠正记忆"接口）
```

### 9.3 L4 微调污染的特殊性

L4（Fine-tuning）的污染修复成本最高——错误已烧进权重，需要重新训练或 RLHF 纠偏，周期以天/周计。因此**高风险知识（频繁更新、用户个性化）不应进入 L4**，优先保留在可更新的 L3/L2。

---

## 10. 记忆条目设计（建议 schema）

长期记忆最容易"烂掉"的原因，是你把它当作"另一份聊天记录"。建议把记忆当作"数据产品"，至少包含：

- **type**：`preference | profile | fact | instruction | skill | task_state`
- **subject**：`user_id / org_id / agent_id / project_id`
- **content**：结构化优先（JSON），文本作为补充
- **source**：来源证据（session_id、message_id、tool_result_ref）
- **timestamp**：产生时间与写入时间
- **confidence**：抽取置信度（或需要人类确认）
- **retention**：TTL / 是否可长期保留
- **version**：写入版本号（支持回滚，防止污染扩散）

---

## 11. 可靠性问题：写入错误比检索错误更致命

### 11.1 "写入污染"比"忘记"更可怕

一条错误的偏好（例如"用户喜欢英文"）会在未来持续污染输出，造成"越用越偏"的错觉。

建议：

- 把"偏好类/画像类"记忆设为**可撤销**（支持版本与回滚）
- 对低置信度记忆加上"待确认"标记

### 11.2 记忆要有"遗忘机制"

没有遗忘的系统必然熵增：噪声增长、召回变差、成本变高。

最小遗忘策略：

- TTL（自动过期）
- 低频访问淘汰
- 同类条目合并（consolidation）

---

## 12. 工程实现模板：三层记忆管理器

下面是一个生产可用的 3 层记忆管理器的核心骨架（Python，抽象掉具体向量库依赖）：

```python
import time
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class MemoryEntry:
    type: str                    # preference | fact | task_state | skill
    subject: str                 # user_id / org_id
    content: dict
    source: str                  # session_id:message_id
    confidence: float            # 0.0 - 1.0
    timestamp: float = field(default_factory=time.time)
    version: int = 1
    ttl: Optional[float] = None  # None = 永久
    tags: list[str] = field(default_factory=list)


class ThreeTierMemoryManager:
    """
    L1 Working  : 外部传入的 context（由调用方管理 token 预算）
    L2 Episodic : 本地 SQLite，按时间+subject 检索
    L3 Semantic : 向量数据库，语义检索
    """

    def __init__(self, episodic_db, vector_store, embedder, confidence_threshold=0.7):
        self.episodic = episodic_db      # e.g. SQLiteEpisodicStore
        self.semantic = vector_store     # e.g. ChromaStore / PineconeStore
        self.embedder = embedder
        self.threshold = confidence_threshold

    # ── RETRIEVE ─────────────────────────────────────────────────────────
    def retrieve_for_context(self, query: str, subject: str, top_k: int = 5) -> list[MemoryEntry]:
        """合并 L2 + L3 检索结果，按相关性排序后返回。"""
        episodic_hits = self.episodic.recent(subject, limit=3)
        embedding = self.embedder.embed(query)
        semantic_hits = self.semantic.search(embedding, subject=subject, top_k=top_k)
        # 合并去重、按 confidence + recency 加权排序
        return self._merge_and_rank(episodic_hits, semantic_hits)

    # ── RECORD ───────────────────────────────────────────────────────────
    def record(self, entry: MemoryEntry) -> bool:
        """
        写入前置检查：
        1. confidence < threshold → 打 pending 标记，不写入主库
        2. 矛盾检测：与已有 L3 条目语义相似度 >0.9 → 触发 conflict review
        3. 分层写入：task_state/session → L2；fact/preference → L3
        """
        if entry.confidence < self.threshold:
            self._mark_pending(entry)
            return False

        conflict = self._detect_conflict(entry)
        if conflict:
            self._flag_for_review(entry, conflict)
            return False

        if entry.type in ("task_state", "session_summary"):
            self.episodic.insert(entry)
        else:
            embedding = self.embedder.embed(str(entry.content))
            self.semantic.upsert(entry, embedding)
        return True

    # ── FORGET ───────────────────────────────────────────────────────────
    def evict_expired(self):
        """清理已过 TTL 的条目（软删除 + 审计日志）。"""
        now = time.time()
        self.episodic.soft_delete_where(f"ttl IS NOT NULL AND ttl < {now}")
        self.semantic.soft_delete_where(ttl_lt=now)

    def _detect_conflict(self, entry: MemoryEntry):
        """检测新条目是否与现有 L3 记忆语义冲突（简化版：余弦相似度阈值）。"""
        emb = self.embedder.embed(str(entry.content))
        hits = self.semantic.search(emb, subject=entry.subject, top_k=1)
        if hits and hits[0].similarity > 0.9 and hits[0].content != entry.content:
            return hits[0]  # 返回冲突条目
        return None

    def _merge_and_rank(self, episodic, semantic):
        seen = set()
        merged = []
        for e in episodic + semantic:
            key = str(e.content)
            if key not in seen:
                seen.add(key)
                merged.append(e)
        # 按 confidence 降序、timestamp 降序
        return sorted(merged, key=lambda e: (e.confidence, e.timestamp), reverse=True)
```

**关键设计决策**：

- **写入门控**：confidence < 0.7 不进主库，先进 pending queue 等人工确认
- **软删除**：所有删除均为逻辑标记，保留审计链路
- **矛盾检测**：语义相似度 > 0.9 且内容不同 → conflict review（防止静默覆盖旧事实）
- **分层路由**：任务状态走 SQLite（快、时序）；知识/偏好走向量库（语义检索）

---

## 13. 安全与隐私（生产必做）

长期记忆的风险不是"回答错"，而是：

- **泄露隐私**
- **被投毒**
- **不可解释与不可删除**

最低要求：

- 访问控制（按 user/org 分区）
- 加密（静态 + 传输）
- 审计（谁在什么时候写入/读取了什么）
- 用户数据权利：可查看/可导出/可删除

---

## 14. 与 RAG 的关系

技术上，长期记忆常用 RAG 组件实现；概念上，长期记忆更强调"个性化 + 可演化 + 可治理"。

本仓库的 RAG 入门（偏知识库角度）：[`rag-agent-memory.md`](../methodology/planning/rag-agent-memory.md)

---

## 15. 参考链接

- MemGPT 论文（2023，斯坦福）：[arxiv.org/abs/2310.08560](https://arxiv.org/abs/2310.08560)
- Letta（MemGPT 框架化）文档：[docs.letta.com](https://docs.letta.com/concepts/memgpt/)
- Letta Blog — Agent Memory 深度解析：[letta.com/blog/agent-memory](https://www.letta.com/blog/agent-memory)
- ICLR 2026 Workshop — MemAgents（记忆系统综述）：[openreview.net/pdf?id=U51WxL382H](https://openreview.net/pdf?id=U51WxL382H)
- MIRIX 多 Agent 记忆系统（2025）：[arxiv.org/abs/2507.07957](https://arxiv.org/abs/2507.07957)
- Episodic Memory as Missing Piece（2025）：[arxiv.org/abs/2502.06975](https://arxiv.org/abs/2502.06975)
- Google ADK Memory：[google.github.io/adk-docs/sessions/memory/](https://google.github.io/adk-docs/sessions/memory/)
- Amazon Bedrock AgentCore Memory：[aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-memory-building-context-aware-agents/](https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-memory-building-context-aware-agents/)
- Weaviate — Context Engineering for Agents：[weaviate.io/blog/context-engineering](https://weaviate.io/blog/context-engineering)
- LangChain long-term memory：[docs.langchain.com/oss/python/langchain/long-term-memory](https://docs.langchain.com/oss/python/langchain/long-term-memory)
- O-Mem（研究）：[arxiv.org/abs/2511.13593](https://arxiv.org/abs/2511.13593)
