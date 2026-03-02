# 02 — Agent 設計 (Agent Design)

> 一個 Agent 能做什麼，取決於它被設計成什麼。
> 本模塊解決的是：如何設計一個在真實環境中能穩定自主運行的 Agent。

---

## 本模塊定位

**Agentic 系統失敗的主要原因不是模型能力不足，而是設計失誤**：
記憶管理混亂、角色職責模糊、工具接入架構不合理、多智能體協作缺乏治理。
本模塊從設計層面解決這些問題。

---

## 文章索引

### 記憶與上下文

| 文件 | 核心問題 |
|------|----------|
| `agent-memory-system-short-to-long.mdx` | 短期→長期記憶的轉換架構，避免上下文窗口溢出 |
| `rag-agent-memory.mdx` | RAG 在 Agent 記憶系統中的正確打開方式 |
| `database-comparison-for-agents.mdx` | Vector / Graph / Relational 在 Agent 記憶中的選型決策 |

### 角色與編排

| 文件 | 核心問題 |
|------|----------|
| `agent-interaction-roles.mdx` | Planner / Executor / Critic 的職責邊界如何劃定 |
| `01-operating-model-and-roles.mdx` | 人機協作的操作模型：誰決策、誰執行、誰審核 |
| `agentic-orchestration-meta-system.mdx` | Meta-orchestrator 如何管理下層 Agent 的生命週期 |
| `03-playbook-multi-agent-squad.mdx` | 多 Agent 小隊的任務分解、協議設計與衝突解決 |
| `social-simulation-and-multi-agent-systems.mdx` | 社會模擬視角下的多 Agent 湧現行為 |
| `lighthouse-vs-torch-framework.mdx` | Lighthouse（目標導向）vs Torch（探索導向）兩種 Agent 框架 |

### 工具接入與執行環境

| 文件 | 核心問題 |
|------|----------|
| `skill-vs-mcp-architecture.mdx` | Skill-based 與 MCP（Model-Context Protocol）的架構取捨 |
| `ai-coding-agent-architecture.mdx` | AI 編碼 Agent 的完整架構設計（含 LSP、沙箱、回滾機制）|
| `vllm-semantic-routing-deep-dive.mdx` | vLLM 語義路由：如何讓請求找到最合適的模型端點 |
| `agent-execution-environment-cloud-vs-local.mdx` | 雲端 vs 本地執行環境的邊界、延遲、成本三角 |

### 知識蒸餾與遷移

| 文件 | 核心問題 |
|------|----------|
| `knowledge-distillation-workflow.mdx` | 大模型知識蒸餾到小模型的工程流程 |
| `agent-mental-model.mdx` | 工程師應如何建立對 Agent 系統的直覺心智模型 |

---

## Agentic 設計的核心原則

1. **明確職責邊界** — 每個 Agent 只做一件事，Orchestrator 不執行，Executor 不規劃
2. **記憶分層** — Working memory（上下文窗口）/ Episodic memory（近期記錄）/ Semantic memory（向量索引）
3. **工具即契約** — 工具接口要穩定、可測試、有 schema，不是「能用就行」
4. **失敗是常態** — Agent 必須能優雅降級，不能假設工具調用100%成功

---

## 推薦閱讀順序

```
agent-mental-model              # 先建立直覺
    ↓
agent-interaction-roles         # 理解角色分工
    ↓
agent-memory-system             # 解決記憶問題
    ↓
skill-vs-mcp-architecture       # 選擇工具接入方案
    ↓
agentic-orchestration           # 多 Agent 協作治理
```
