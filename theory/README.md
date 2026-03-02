# 知識骨架 (Theory)

> 工具會過時，框架會迭代，但底層的設計邏輯和認知模型是持久的。
> 本目錄不是操作手册，而是幫你建立**工程判斷力**的基礎文獻庫。

---

## 六個認知模塊

```
01-principles/      底層原理     — 機器是如何「想」的
02-agent-design/    Agent 設計   — 如何設計穩定自主運行的 Agent
03-engineering/     工程實戰 ★  — Agentic 系統的生產交付全鏈路
04-paradigm/        範式轉變     — 識別正在發生的不可逆轉變
05-strategy/        戰略生存     — 工程師如何在 AI 時代定位與變現
06-frontier/        前沿研究     — 與工程最近的前沿突破
deep-dive/          深潛週報     — Pulsar 每週自動生成的工程分析
```

★ `03-engineering/` 是本目錄的**工程核心**，建議所有人重點閱讀。

---

## 三條閱讀路徑

### 路徑 A — 新手入門（建立基礎認知）

```
01-principles/README → 01-principles/latent-space-reasoning
    ↓
01-principles/lofa-vs-rag-comparison
    ↓
02-agent-design/agent-mental-model
    ↓
03-engineering/00-glossary-for-beginners
    ↓
03-engineering/01-physical-rails ～ 05-adr-mind-palace（護欄系列）
```

目標：建立正確的 Agent 系統直覺，避免最常見的設計錯誤。

---

### 路徑 B — 工程師（Agentic 系統落地）

```
03-engineering/prd-for-engineers-and-agents
    ↓
03-engineering/02-playbook-spec-to-pr
    ↓
03-engineering/05-ralph-loop-iteration-paradigm
    ↓
03-engineering/06-agent-evals-playbook
    ↓
02-agent-design/agentic-orchestration-meta-system
    ↓
02-agent-design/03-playbook-multi-agent-squad
```

目標：能夠設計、交付並持續迭代一個生產級 Agentic 系統。

---

### 路徑 C — 研究者 / 決策者（判斷方向）

```
04-paradigm/anthropic-agentic-coding-trends-2026
    ↓
04-paradigm/vibe-coding-paradigm
    ↓
01-principles/post-scaling-research-age-playbook
    ↓
06-frontier/1x-world-model-paradigm
    ↓
05-strategy/intelligence-arbitrage-strategy
```

目標：判斷下一個技術轉折點在哪裡，提前佈局。

---

## Agentic Engineering — 本庫的核心主題

Agent-Playbook 的理論核心是 **Agentic Engineering**：
讓 AI Agent 在真實生產環境中**可靠、可測、可迭代**地自主工作。

這不是「讓 AI 更聰明」，而是「設計讓 AI 安全工作的系統」。

關鍵工程命題：
- **護欄優先** — 沒有護欄的自主性是風險，不是能力（→ 03-engineering/護欄系列）
- **評估驅動** — 沒有評估體系的 Agent 是盲飛（→ 03-engineering/06-agent-evals-playbook）
- **Ralph Loop** — 持續迭代的元框架（→ 03-engineering/05-ralph-loop-iteration-paradigm）
- **記憶分層** — 上下文管理是 Agent 可靠性的關鍵（→ 02-agent-design/）

---

## 寫作規範（新增文章）

新增 theory/ 文檔須遵循 [AGENTS.md](../AGENTS.md) §6 規範：

- 雙語標題：`# 中文標題 (English Title)`
- 必須包含 **X-Ray 開場**（2-3 句，回答：什麼問題 / 什麼發現 / 為何重要）
- 引用需鏈接原始來源（論文 / 官方文檔優先）
- 推薦包含：系統對比表、工程實戰示例、失效模式分析

---

## deep-dive/ 的位置

`deep-dive/` 與 `01-06` 模塊並列，不屬於任何一個分類。
它是 Pulsar 每週（周二/四/六）從當週 ⚡/🔧 信號中自動生成的工程分析，時效性最強。

**推薦組合閱讀**：先讀 `01-06` 建立骨架，再用 `deep-dive/` 追蹤最新工程實踐。
