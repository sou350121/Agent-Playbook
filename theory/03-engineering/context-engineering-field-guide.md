# Context 工程實戰指南 (Context Engineering Field Guide)

> **來源**: Karpathy et al. "Agentic Engineering" (2025–2026) + 工程實踐彙編
> **日期**: 2026-03-02
> **定位**: Context Engineering 是 Agentic 系統的新基礎設施——你給 Agent 什麼，比模型本身更決定結果

**X-Ray 開場**

Agent 失敗最常見的原因不是模型能力不足，而是 Context 設計失誤：給得太少導致 Agent 憑空猜測，給得太多導致上下文窗口溢出，切割方式不對導致任務邊界不清。Context Engineering 是把「讓 Agent 能夠工作」這件事工程化的學科——它不是 Prompt Engineering 的別名，而是一個獨立的基礎設施設計問題。

---

## 什麼是 Context Engineering

Context Engineering 涵蓋以下四個問題：

1. **什麼信息應該注入**（靜態 vs 動態、全量 vs 按需檢索）
2. **如何構建和維護 Repo Map**（讓 Agent 知道代碼庫的結構）
3. **如何設計 Task Packet**（讓委派的任務邊界清晰、可驗收）
4. **如何應對 Context 衰減**（長會話中 Agent 逐漸「忘記」早期約束）

---

## Repo Map：Agent 的空間感知

Repo Map 是讓 Agent 理解代碼庫結構的核心上下文。沒有 Repo Map 的 Agent 像在黑暗中工作。

### 最小可行 Repo Map

```
project/
├── AGENT_CONSTITUTION.md    ← Agent 行為約束（什麼能做、什麼不能做）
├── ARCHITECTURE.md          ← 高層架構圖 + 主要模塊職責
├── docs/adr/                ← Architecture Decision Records（為什麼這樣設計）
└── .agent/
    ├── repo-map.json        ← 機器可讀的模塊依賴圖
    └── hot-paths.md         ← 最常被修改的文件列表（Agent 應優先了解）
```

### AGENT_CONSTITUTION.md 設計原則

AGENT_CONSTITUTION 是 Agent 的操作邊界文件，應包含：

| 章節 | 內容 |
|------|------|
| 身份與職責 | 這個 Agent 是誰，負責什麼範圍 |
| 禁止操作 | 明確列出不能做的事（比工具調用攔截更早） |
| 輸出格式 | 期望的交付格式（diff / PR / JSON report）|
| 升級條件 | 什麼情況下必須請求人工介入 |
| 引用文檔 | ADR / ARCHITECTURE.md 的讀取順序 |

---

## Task Packet：委派的最小契約

Task Packet 是人類向 Agent 委派任務的標準化格式。沒有 Task Packet 的委派是「自動化」，有的才是「委派」（見 `delegation-not-automation-engineering-principles`）。

### Task Packet 結構

```json
{
  "id": "task-2026-03-02-001",
  "objective": "為 UserService 新增 rate limiting 中間件",
  "scope": {
    "in": ["src/middleware/", "src/services/UserService.ts"],
    "out": ["src/db/", "tests/e2e/"]
  },
  "constraints": [
    "不得修改現有 test fixtures",
    "rate limit 配置從環境變量讀取，不硬編碼",
    "保持向後相容性"
  ],
  "acceptance_criteria": [
    "unit tests 覆蓋 limit exceeded / under limit 兩個 case",
    "新中間件通過現有 CI gate",
    "diff 大小 < 200 行"
  ],
  "fallback": "若無法確定 rate limit 策略，停止執行並輸出 ambiguity_report.md",
  "context_refs": ["docs/adr/003-rate-limiting.md", "ARCHITECTURE.md#middleware"]
}
```

---

## 靜態注入 vs 動態檢索

| 維度 | 靜態注入 | 動態檢索（RAG） |
|------|---------|---------------|
| 適用場景 | 任務固定、上下文小（< 10K tokens） | 大型代碼庫、長會話、跨文件查詢 |
| 優點 | 確定性強，Agent 不會「找錯」 | 按需加載，不佔窗口 |
| 缺點 | 窗口污染風險；更新需手動同步 | 檢索相關性不穩定；延遲增加 |
| 推薦組合 | AGENT_CONSTITUTION + ADR（靜態）+ 代碼文件（動態）| |

---

## Context 衰減：長會話的隱形殺手

在長 Agent 會話中，早期注入的約束逐漸被後期信息稀釋——這是 Context 衰減。

### 衰減的表現

- Agent 忘記「不得修改 db/ 目錄」的約束
- Agent 開始使用早期已被否定的方案
- Agent 輸出格式逐漸偏離 Task Packet 規範

### 緩解策略

1. **Context Refresh**：每 N 輪對話後重新注入 AGENT_CONSTITUTION
2. **Checkpointing**：在 Task Packet 中定義中間驗收點（Agent 必須報告狀態）
3. **Short Sessions**：拆分大任務為多個獨立的 Task Packet（Ralph Loop 的分解策略）
4. **Constraint Summary**：在每次工具調用後要求 Agent 重述當前活躍約束

---

## 失效模式

| 失效類型 | 症狀 | 預防 |
|---------|------|------|
| Context 欠注入 | Agent 猜測不存在的 API / 架構 | 確保 repo-map + ARCHITECTURE.md 已注入 |
| Context 過注入 | Agent 輸出質量下降、矛盾增多 | 分層加載：先靜態骨架，再動態細節 |
| Task Packet 邊界模糊 | Agent 「順手」修改了不在範圍內的文件 | 明確 `scope.out` + 審查 diff 覆蓋範圍 |
| ADR 未讀 | Agent 重複已被否決的決策 | AGENT_CONSTITUTION 強制要求在開始前讀 ADR |
| Context 衰減 | 長會話後 Agent 違反早期約束 | 設定 Checkpointing + Context Refresh 策略 |

---

## 相關項目

- `03-engineering/05-adr-mind-palace.md` — ADR 作為 Agent 長期記憶
- `03-engineering/02-playbook-spec-to-pr.md` — Task Packet 在 Spec-to-PR 流程中的位置
- `03-engineering/delegation-not-automation-engineering-principles.md` — 為什麼 Task Packet 是委派的必要條件
- `02-agent-design/agent-memory-system-short-to-long.md` — 記憶系統的 Retrieve/Inject/Act/Record 循環
