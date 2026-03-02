# Agent-Native 組織新角色 (Agent-Native Organization Roles)

> **來源**: Karpathy "下2步" 框架 + 工程組織演化觀察 (2025–2026)
> **日期**: 2026-03-02
> **定位**: 當 Agent 成為一等公民操作主體，公司組織必須演化出對應的新職能——不是舊職稱換名字，而是全新的責任邊界

**X-Ray 開場**

「把 AI 工具導入工程團隊」是下0的思路。下2步的思路是：當 Agent 作為一等公民持續執行工程工作，人類的組織結構必須相應演化。Karpathy 描述的轉變——工程師從「寫代碼」到「設計讓 Agent 安全工作的系統」——在組織層面意味著四個新角色的出現。這不是遠期猜測：這些職能在今天的前沿工程團隊中已有雛形，只是還沒有統一的名字。

> **注意**：`03-engineering/agentic-org-chart-design.mdx` 描述的是如何組織你的 Agent（Agent 拓撲設計）。
> 本文描述的是如何組織你的**人**（圍繞 Agent 的人員職能設計）。

---

## 四個新角色

### 角色 1：Agent Architect（智能體架構師）

**核心職責**：設計整個 Agentic 系統的拓撲結構——哪些任務委派給哪些 Agent、Agent 間如何協調、控制平面如何設計。

**不同於傳統 Software Architect**：

| 維度 | Software Architect | Agent Architect |
|------|-------------------|----------------|
| 設計對象 | 代碼模塊、服務邊界 | Agent 拓撲、委派邊界、信任層級 |
| 主要產出 | 架構圖、ADR | Agent 拓撲圖、Task Packet schema、信任層級矩陣 |
| 關鍵判斷 | 哪些服務需要分離 | 哪些任務適合委派 vs 自動化 |
| 失敗責任 | 系統不可用 | Agent 產生有害輸出或超出授權範圍 |

**核心技能**：
- 理解 Agent 失效模式（T1-T6，見 `agent-failure-taxonomy`）
- 設計控制平面的六個維度（見 `agentic-control-plane-design`）
- 能設計信任層級框架並定義 Agent 晉升路徑

**過渡路徑**：從 Senior Software Architect 轉型，需補充 Agentic 系統設計和失效模式知識。

---

### 角色 2：AI QA / Eval Engineer（AI 品質與評估工程師）

**核心職責**：設計、維護並持續運行 Eval 基礎設施。是 Agentic 系統進入生產的最後守門人。

**不同於傳統 QA Engineer**：

| 維度 | QA Engineer | AI QA / Eval Engineer |
|------|-------------|----------------------|
| 測試對象 | 確定性代碼行為 | 概率性 Agent 輸出 |
| 測試方法 | Unit / Integration / E2E | Code-based + Model-based + Human eval |
| 核心挑戰 | 覆蓋所有代碼路徑 | 覆蓋語義意圖，而非代碼路徑 |
| 主要工具 | pytest, Selenium | Eval harness, rubrics, golden datasets |
| 失敗判斷 | 測試通過/失敗（二元）| Pass rate 趨勢 + 語義回歸（連續）|

**核心技能**：
- 設計 Model-based eval rubrics（如何用 LLM 評估 LLM 輸出）
- 維護 golden test dataset（選擇、更新、版本控制）
- 把 Eval 集成進 CI/CD pipeline（見 `eval-loop-as-production-practice`）
- 失效分類與 Root Cause Analysis（見 `agent-failure-taxonomy`）

**過渡路徑**：從 Senior QA Engineer 或 ML Engineer 轉型。前者帶來測試設計能力，後者帶來對模型行為的理解。

---

### 角色 3：Context Engineer（上下文工程師）

**核心職責**：設計並維護 Agent 的知識基礎設施——repo map、AGENT_CONSTITUTION、context injection 策略、長期記憶結構。

**這是 Karpathy 框架中最新的職能**，在現有工程師職稱中沒有直接對應。

**工作內容**：
- 維護 `AGENT_CONSTITUTION.md` 和 repo-level context 文件
- 設計 Task Packet 標準格式（見 `context-engineering-field-guide`）
- 管理 retrieval 策略（什麼靜態注入，什麼動態檢索）
- 監控 Context 衰減問題並設計緩解方案

**Context Engineer 的核心判斷**：

```
問題：Agent 在執行任務時表現不佳。
Context Engineer 的問題清單：
  1. Agent 知道代碼庫的結構嗎？（Repo Map 是否存在且更新）
  2. Agent 知道它的邊界嗎？（AGENT_CONSTITUTION 是否清晰）
  3. Agent 在會話中途「忘記」了什麼？（Context 衰減監控）
  4. Task Packet 的範圍描述是否明確？（scope.in / scope.out）
  5. 相關 ADR 是否在 Agent 的上下文中？（context_refs）
```

**核心技能**：
- 理解上下文窗口的物理限制和信息優先級
- 設計 retrieval 系統（向量搜索、BM25、混合）
- 用數據驅動優化 context 配置（通過 eval 結果反饋）

**過渡路徑**：從 Technical Writer、DevOps Engineer 或 ML Engineer 轉型。關鍵是對「信息如何影響模型行為」有深入理解。

---

### 角色 4：Automation PM（自動化產品經理）

**核心職責**：定義人機分工的邊界——哪些流程適合「委派給 Agent 自動化執行」，哪些必須「保留人工介入」，並持續調整這個邊界。

**不同於傳統 Product Manager**：

| 維度 | Product Manager | Automation PM |
|------|-----------------|---------------|
| 設計對象 | 用戶與產品的交互 | 人類與 Agent 的協作邊界 |
| 主要問題 | 「用戶要什麼功能？」| 「哪些決策可以委派，哪些必須人工做？」|
| 核心工具 | PRD, Roadmap | 委派邊界矩陣、Autonomy Slider 設計 |
| 成功指標 | 用戶留存、NPS | Agent pass rate、人工介入率、審查效率 |

**Autonomy Slider 設計**：

每個工程流程的自主度應明確定義，並可以隨時間調整：

```
Level 0 — 全人工：Agent 提供建議，人類決策並執行
Level 1 — 人工批准：Agent 提案，人類批准後執行
Level 2 — 人工審查：Agent 執行，人類事後審查 diff
Level 3 — 例外升級：Agent 自動執行，僅在特定條件下升級
Level 4 — 完全自動：Agent 自動執行，僅記錄日誌
```

一個新流程應從 Level 0-1 開始，隨著 Eval 數據積累逐步提升自主度。

**核心技能**：
- 理解 Agent 信任層級框架（`trust-tier-design`）
- 能將業務風險轉化為 Agent 設計約束
- 用 Eval 數據驅動 Autonomy Slider 的調整決策

**過渡路徑**：從 Product Manager + 對 AI 系統有深入理解。關鍵是能在「效率提升」和「風險控制」之間做有依據的決策。

---

## 四個角色的協作模式

```
新功能 / 流程改進
    │
    ├─→ Automation PM：定義委派邊界，設計 Autonomy Slider
    │       ↓
    ├─→ Agent Architect：設計 Agent 拓撲，確定信任層級
    │       ↓
    ├─→ Context Engineer：設計 AGENT_CONSTITUTION + Task Packet
    │       ↓
    └─→ AI QA / Eval Engineer：設計 Eval rubrics，集成 CI Gate
            ↓
        生產部署 → 持續監控 → 反饋改進
```

---

## 與現有角色的關係

這四個角色不是要取代現有工程師，而是**現有工程師職能的分化**：

| 現有角色 | 分化出的新職能 |
|---------|-------------|
| Senior Software Architect | Agent Architect（+ Agentic 系統設計）|
| Senior QA / SDET | AI QA / Eval Engineer（+ 語義評估能力）|
| Technical Writer / DevOps | Context Engineer（全新職能，無直接前身）|
| Senior PM | Automation PM（+ AI 系統風險判斷能力）|

**在小團隊中**：一個人可以兼任多個角色。但隨著 Agentic 系統規模增長，這四個職能的分化是不可避免的。

---

## 今天就可以做的事

在正式設立這些角色之前，你可以立即做的：

1. **指定 Context Owner**：誰負責維護 AGENT_CONSTITUTION 和 repo map？
2. **指定 Eval Owner**：誰負責 eval suite 的健康和 CI gate 的閾值？
3. **明確委派邊界**：用 Autonomy Slider 評估現有的每個 Agent 工作流
4. **做一次 Failure Review**：收集上個月的 Agent 失效，用 T1-T6 分類，找出誰應該擁有每類失效的預防責任

---

## 相關文章

- `03-engineering/agentic-control-plane-design.mdx` — Agent Architect 的主要設計工具
- `03-engineering/context-engineering-field-guide.mdx` — Context Engineer 的操作手冊
- `03-engineering/eval-loop-as-production-practice.mdx` — AI QA Engineer 的核心實踐
- `03-engineering/agent-failure-taxonomy.mdx` — 四個角色共同使用的失效框架
- `05-strategy/reconstructing-engineering-mindset.mdx` — 個人如何從執行者轉型為決策者（本文的個人層面版本）
