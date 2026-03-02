# 02 — Agent 設計 (Agent Design)

> 一個 Agent 能做什麼，取決於它被設計成什麼。
> 本模塊解決的是：如何設計一個在真實環境中能穩定自主運行的 Agent。

---

## 本模塊定位

**Agentic 系統失敗的主要原因不是模型能力不足，而是設計失誤**：
記憶管理混亂、角色職責模糊、工具接入架構不合理、多智能體協作缺乏治理。
本模塊從設計層面解決這些問題。

> 思維方式轉換（工程師應如何「想」Agent）見 `01-principles/agent-mental-model.md`。
> 本模塊假設你已建立正確的心智模型，直接處理設計決策。

---

## 文章索引

### 記憶與上下文

| 文件 | 核心問題 |
|------|----------|
| `agent-memory-system-short-to-long.md` | 短期→長期記憶的轉換架構，Retrieve/Inject/Act/Record 四步循環 |
| `rag-agent-memory.md` | RAG 在 Agent 記憶系統中的正確打開方式 |
| `database-comparison-for-agents.md` | Vector / Graph / Relational 在 Agent 記憶中的選型決策 |

### 角色與編排

| 文件 | 核心問題 |
|------|----------|
| `agent-interaction-roles.md` | Planner / Executor / Critic 的職責邊界如何劃定 |
| `01-operating-model-and-roles.md` | 6 角色模型（Commander/Planner/Implementer/Reviewer/Guard/Runner）+ 4 審查門控 + 1:20 委派比例 |
| `agentic-orchestration-meta-system.md` | Meta-orchestrator 如何管理下層 Agent 的生命週期 |
| `03-playbook-multi-agent-squad.md` | 多 Agent 小隊：Pipeline/Sharding/Mirror 三種協作模式 |
| `social-simulation-and-multi-agent-systems.md` | 社會模擬視角下的多 Agent 湧現行為 |
| `lighthouse-vs-torch-framework.md` | Lighthouse（目標導向）vs Torch（探索導向）兩種 Agent 框架 |

### 工具接入與執行環境

| 文件 | 核心問題 |
|------|----------|
| `skill-vs-mcp-architecture.md` | Skill-based 與 MCP（Model-Context Protocol）的架構取捨 |
| `ai-coding-agent-architecture.md` | AI 編碼 Agent 的完整架構設計（含 LSP、沙箱、回滾機制）|
| `vllm-semantic-routing-deep-dive.md` | vLLM 語義路由：如何讓請求找到最合適的模型端點 |
| `agent-execution-environment-cloud-vs-local.md` | 雲端 vs 本地執行環境的邊界、延遲、成本三角 |

### Agent UI / Agent API 設計

| 文件 | 核心問題 |
|------|----------|
| `agent-ui-api-design-patterns.md` 🆕 | 為 Agent 作為一等用戶設計的 API 模式：JSON-first、冪等性、結構化錯誤、Agent API 版本管理 |

> **跨模塊參考**：`04-paradigm/not-designing-for-humans-paradigm.md` 提供了哲學基礎；本模塊的 `agent-ui-api-design-patterns` 提供工程落地。

### 知識蒸餾

| 文件 | 核心問題 |
|------|----------|
| `knowledge-distillation-workflow.md` | 大模型知識蒸餾到小模型的工程流程 |

---

## Agentic 設計的核心原則

1. **明確職責邊界** — 每個 Agent 只做一件事，Orchestrator 不執行，Executor 不規劃
2. **記憶分層** — Working memory（上下文窗口）/ Episodic memory（近期記錄）/ Semantic memory（向量索引）
3. **工具即契約** — 工具接口要穩定、可測試、有 schema；為 Agent 消費者設計，不是為人類
4. **失敗是常態** — Agent 必須能優雅降級，不能假設工具調用 100% 成功
5. **委派而非自動化** — 明確委派範圍、審查機制和結果驗證責任（見 `03-engineering/delegation-not-automation-engineering-principles`）

---

## 推薦閱讀順序

```
agent-interaction-roles         # 理解角色分工（mental model 已在 01-principles 建立）
    ↓
agent-memory-system             # 解決記憶問題
    ↓
skill-vs-mcp-architecture       # 選擇工具接入方案
    ↓
01-operating-model-and-roles    # 完整治理框架（含信任層級）
    ↓
agentic-orchestration           # 多 Agent 協作治理
    ↓
agent-ui-api-design-patterns    # 為 Agent 設計介面
```

---

## Deep-Dive 文章（在本模塊）

Pulsar 自動分配到本模塊的框架深潛文章：
- `autogen_autogen_v04_deep_dive.md` — AutoGen v0.4 多 Agent 框架
- `llamaindex_team_opensearch_v100_nmslib_faiss_deep_dive.md` — 向量搜索棧比較
