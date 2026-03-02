# 委派而非自動化：工程原則 (Delegation, Not Automation)

> **來源**: Karpathy "It's delegation" (2025–2026 多次公開表述)
> **日期**: 2026-03-02
> **定位**: 「委派」與「自動化」看起來相似，但工程含義截然不同——錯誤地把委派設計成自動化，是 Agentic 系統最常見的架構失誤

**X-Ray 開場**

Karpathy 反覆強調的一個細節：現在發生的不是「自動化」，而是「委派」（delegation）。這不是語義遊戲——兩者的工程含義有根本差異：自動化消除了人的角色，委派保留了人作為「委派人」的責任主體。把委派系統設計成自動化系統，會導致責任真空、可逆性缺失、以及失敗時無人問責。

---

## 核心區別

| 維度 | 自動化 (Automation) | 委派 (Delegation) |
|------|--------------------|--------------------|
| 人的角色 | 被替代 | 委派人（Principal）|
| 責任歸屬 | 系統 / 無人 | 委派人 |
| 失敗時 | 找系統 bug | 委派人檢討委派設計 |
| 範圍定義 | 固定規則 | 委派人明確授權 |
| 結果驗證 | 非必須（系統正確就行）| 必須（委派人驗收）|
| 可逆性 | 可選 | 原則上必須 |

**一個測試**：如果 Agent 做了一件意外的事，你能說「這是我委派的範圍之外」嗎？

- 能說清楚 → 你在做委派
- 說不清楚 → 你在做自動化（範圍沒有定義）

---

## 委派的四個工程要求

### 要求 1：明確的委派範圍（Explicit Scope）

委派必須有邊界。邊界不清晰的委派等同於全權委任，工程上不可接受。

**實現方式**：Task Packet 的 `scope.in` / `scope.out` + `constraints` 字段（見 `context-engineering-field-guide`）

```json
{
  "scope": {
    "in": ["src/auth/"],
    "out": ["src/db/", "tests/e2e/", "package.json"]
  },
  "constraints": [
    "不得新增外部依賴",
    "不得修改公開 API 的函數簽名"
  ]
}
```

沒有 `scope.out` 的委派 = 不受限的自動化 = T1 失效（範圍洩漏）的根本原因。

---

### 要求 2：委派人的責任歸屬（Principal Accountability）

在委派模型中，**委派人對結果負責**，即使執行是由 Agent 完成的。

工程含義：

- **誰委派，誰審查**：委派人必須是 diff reviewer（不能把委派和審查完全分離給不同人）
- **Task Packet 作為委派記錄**：Task Packet 是委派人的授權文件，應有版本記錄
- **失敗後的 RCA 對象是委派設計**：當 Agent 失敗時，首先問「委派設計哪裡出了問題」，而非「模型能力不夠」

```python
# 在 task_log 中記錄委派人
task_log = {
    "task_id": "task-2026-03-02-001",
    "principal": "ken@example.com",       # 委派人
    "agent": "claude-sonnet-4-6",
    "scope": {...},
    "review_required_by": "ken@example.com",  # 委派人同時是審查人
}
```

---

### 要求 3：可逆性設計（Reversibility by Design）

委派系統中，任何 Agent 動作原則上必須可逆。這不只是「有 rollback 功能」，而是**在設計委派任務時就要考慮可逆性**。

**可逆性檢查清單**（在設計 Task Packet 時完成）：

```
□ 所有文件修改都在 Git 追蹤範圍內（可 git revert）
□ 無對外部不可逆 API 的調用（郵件、金融交易、永久刪除）
□ 數據庫操作有事務包裹或回滾腳本
□ 若涉及不可逆操作，已升級至 T0/T1 信任層級
□ rollback_plan 字段已填寫
```

不可逆的委派是風險等級最高的設計，應在 Task Packet 中強制標記：

```json
{
  "reversibility": "partial",
  "irreversible_actions": ["send_notification_email"],
  "rollback_plan": "通知郵件無法撤回；其他代碼變更可 git revert"
}
```

---

### 要求 4：結果驗收（Outcome Verification）

委派的最後一步是委派人對結果的驗收。沒有驗收的委派退化為自動化。

**驗收不等於「看一眼 diff」**。有效驗收需要對照 Acceptance Criteria：

```
Acceptance Criteria（Task Packet 中定義）：
  □ unit tests 覆蓋 limit exceeded / under limit
  □ diff 大小 < 200 行
  □ 無 scope.out 範圍外的文件修改

驗收動作：
  1. 確認所有 Acceptance Criteria 狀態
  2. 運行受影響模塊的測試
  3. Review diff 的語義意圖（不只是語法）
  4. 記錄驗收決定（approved / rejected + 原因）
```

---

## 常見錯誤模式

### 錯誤 1：「完全信任」陷阱

```
錯誤：設置 Agent 全自動運行，不看結果，因為「它大部分時候是對的」
問題：T5 語義回歸無法被檢測；委派人失去了對系統的感知
正確：建立 Eval Loop（見 eval-loop-as-production-practice），用數據確認信任，而非盲目假設
```

### 錯誤 2：「範圍擴張」容忍

```
錯誤：Agent 改了不在 scope.in 的文件，但結果看起來對，就接受了
問題：你在訓練 Agent 忽視委派邊界；下次洩漏可能是破壞性的
正確：任何 T1 失效（範圍洩漏）都應被記錄並觸發 Task Packet 設計的改進
```

### 錯誤 3：「結果導向」驗收

```
錯誤：測試通過了就 merge，不看 Agent 的執行路徑
問題：T5 語義回歸正是這樣被埋入生產的
正確：驗收應包含「Agent 是否按預期路徑完成任務」，而非只看輸出結果
```

### 錯誤 4：「一次委派永久授權」

```
錯誤：「上次 Agent 做對了，這次同樣的任務不用再設定 Task Packet」
問題：模型更新、代碼庫變化、依賴版本都會改變 Agent 的行為
正確：每次委派都需要完整的 Task Packet，即使任務相似；可以有模板，但不可省略
```

---

## 委派 vs 自動化：什麼時候用哪個

並非所有 Agent 工作都必須是委派模式。有些操作確實適合純自動化。

### 適合委派的操作

- 需要工程判斷的任務（架構決策、業務邏輯實現）
- 影響範圍不確定的操作
- 首次執行某類任務
- 涉及業務語義（不只是語法/格式）的修改

### 適合自動化的操作

- 純機械性操作（格式化、linting）
- 有完整回歸測試保護的重複性任務
- 已經在 T4 信任層級且 Eval 數據穩定的操作
- 無業務語義的技術任務（dependency patch 更新）

**判斷標準**：如果操作失敗，你需要「工程判斷」來修復 → 委派。
如果操作失敗，你只需要「執行已知修復步驟」→ 自動化。

---

## 實踐：委派設計 Checklist

在啟動任何 Agent 工作流之前：

```
委派設計 Checklist
□ 是否有明確的 Task Packet（objective / scope / constraints / acceptance_criteria）
□ scope.out 是否明確定義
□ 可逆性是否評估（reversibility 字段）
□ 信任層級是否設定（T0-T4）
□ 委派人是否也是審查人
□ 驗收標準是否可操作（不只是「測試通過」）
□ 失敗時的 rollback_plan 是否定義
```

---

## 相關文章

- `03-engineering/context-engineering-field-guide.mdx` — Task Packet 的完整格式設計
- `03-engineering/trust-tier-design.mdx` — 委派範圍與信任層級的關係
- `03-engineering/agent-failure-taxonomy.mdx` — T1 範圍洩漏 = 委派邊界設計失敗
- `02-agent-design/01-operating-model-and-roles.mdx` — 委派人（Commander）與執行者（Implementer）的角色分工
- `05-strategy/agent-native-org-roles.mdx` — Automation PM 負責定義哪些流程用委派，哪些用自動化
