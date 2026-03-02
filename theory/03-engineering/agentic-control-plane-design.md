# Agentic 控制平面設計 (Agentic Control Plane Design)

> **來源**: Karpathy "Protocolized Agentic Engineering" 框架 (2025–2026)
> **日期**: 2026-03-02
> **定位**: 當 Agentic Engineering 從個人技巧演化為團隊協議，「控制平面」是讓整個團隊能夠複製高效 Agent 工作流的統一架構

**X-Ray 開場**

今天「會用 Agent 的高手很猛」，下1步的問題是：**普通團隊如何複製這種效率**？答案是控制平面（Control Plane）——把 Agent 的使用從個人技巧變成可治理、可擴展的工程系統。控制平面不是單一工具，而是六個競爭維度的架構決策集合，每個維度之間存在張力，必須明確取捨。

---

## 什麼是控制平面

控制平面是 Agentic 工程團隊的「中樞神經系統」——它決定：
- 任務如何被定義和分解（任務協議）
- Agent 知道什麼（上下文注入）
- 誰做了什麼可以被追溯（可追溯性）
- 出了問題如何撤銷（回滾機制）
- 哪些輸出需要人工確認（審查設計）
- 運行成本如何控制（成本治理）

---

## 六個競爭維度

### 維度 1：任務分解格式 (Task Decomposition Format)

**問題**：如何把一個大目標拆成可委派給 Agent 的原子任務？

**兩個極端**：
- **結構化 Task Packet**（強規範）：JSON schema，明確 scope.in/out，DoD 驗收標準
- **自由文本 Prompt**（弱規範）：直接描述，依靠模型理解

**工程取捨**：

| 維度 | 強規範 Task Packet | 弱規範 Prompt |
|------|-------------------|--------------|
| 可複製性 | 高（任何人可發送相同任務）| 低（依賴個人表達能力）|
| 靈活性 | 低（每次要填 schema）| 高（隨時可改）|
| 審計性 | 強（有結構化記錄）| 弱 |
| 適合場景 | 重複執行的流程 | 探索性任務 |

**推薦**：重複流程用 Task Packet，探索性任務用 Prompt，在控制平面中都支持。

---

### 維度 2：上下文注入協議 (Context Injection Protocol)

**問題**：每次委派任務時，哪些上下文由系統自動注入，哪些由人手動提供？

**三種策略**：

```
策略 A：全量靜態注入
  優點：確定性強  缺點：窗口污染，更新滯後

策略 B：純動態檢索
  優點：按需加載  缺點：檢索相關性不穩定

策略 C：分層注入（推薦）
  靜態骨架（AGENT_CONSTITUTION + 架構摘要）永遠注入
  動態細節（相關代碼文件、ADR）按任務類型檢索
```

控制平面應定義注入層次和每層的更新頻率。

---

### 維度 3：可追溯性 (Traceability)

**問題**：如何知道 Agent 做了什麼，為什麼這樣做？

**必須追蹤的信息**：

```json
{
  "task_id": "task-2026-03-02-001",
  "agent_id": "claude-sonnet-4-6",
  "context_injected": ["AGENT_CONSTITUTION.md", "ARCHITECTURE.md"],
  "tool_calls": [{"tool": "write_file", "path": "src/middleware/rate-limit.ts"}],
  "output_diff_hash": "sha256:abc123",
  "human_reviewer": "ken@example.com",
  "review_decision": "approved",
  "timestamp": "2026-03-02T10:30:00Z"
}
```

**最小可追溯要求**：
- 每個 Agent 動作有唯一 task_id
- 所有 file write 操作有記錄
- 人工審查決策有記錄
- 可從任何輸出追溯到發起的 Task Packet

---

### 維度 4：回滾機制 (Rollback Mechanism)

**問題**：Agent 做錯了，如何撤銷？

**三個層次**：

| 層次 | 機制 | 適用場景 |
|------|------|---------|
| 文件層 | Git revert | 代碼文件修改 |
| 服務層 | Blue-green deployment | 服務部署變更 |
| 數據層 | Database transaction rollback | 數據修改（最高風險）|

控制平面應在 Task Packet 中強制要求聲明「此任務是否涉及數據層變更」，並對應設計回滾策略。

---

### 維度 5：審查門控設計 (Review Gate Design)

**問題**：哪些輸出需要人工審查，誰來審查，審查什麼？

**與信任層級的關係**：審查設計依賴信任層級框架（見 `trust-tier-design`）。

**審查維度的取捨**：

```
審查太嚴 → 人工瓶頸，Agent 效率提升為零
審查太鬆 → 風險失控，T1/T5 失效無法攔截
```

控制平面的職責是**動態調整審查閾值**——隨著 Eval 數據積累，逐步降低低風險操作的審查要求。

---

### 維度 6：成本治理 (Cost Governance)

**問題**：如何在 Agent 使用效率和 Token/API 成本之間取得平衡？

**三個成本控制工具**：

1. **模型選擇策略**：簡單任務用小模型（Haiku），複雜任務用強模型（Sonnet/Opus）
2. **Context 窗口預算**：每個 Task Packet 設定 max_tokens 上限
3. **Eval 成本分配**：快速 Gate（用小模型）vs 語義 Gate（用強模型）分層運行

---

## 六個維度的張力

這六個維度之間存在系統性張力：

```
強任務規範 ←→ 高靈活性
全量注入   ←→ 低成本
強可追溯   ←→ 低運維負擔
嚴格回滾   ←→ 快速交付
人工審查   ←→ 自動化效率
強模型     ←→ 成本控制
```

控制平面設計不是「選最強的選項」，而是**在這些張力中找到適合當前團隊規模和風險承受能力的均衡點**。

---

## 從個人實踐到控制平面的三個階段

**階段 1（個人）**：有意識地在每次使用 Agent 時考慮這六個維度，即使是臨時決策也要記錄。

**階段 2（小團隊）**：制定團隊共識文件（Control Plane Spec），讓每個人的 Agent 使用遵循相同協議。

**階段 3（系統化）**：把控制平面自動化——任務路由、上下文注入、審查觸發都由系統而非人工決定。

---

## 相關文章

- `03-engineering/context-engineering-field-guide.mdx` — 維度 2 的詳細實現
- `03-engineering/agent-failure-taxonomy.mdx` — 維度 4 回滾設計的失效分類基礎
- `03-engineering/trust-tier-design.mdx` — 維度 5 審查門控的信任框架
- `02-agent-design/01-operating-model-and-roles.mdx` — 六角色模型（控制平面的人員映射）
- `05-strategy/agent-native-org-roles.mdx` — 誰負責控制平面的每個維度
