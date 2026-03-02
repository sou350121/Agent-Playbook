# Agent 失效分類學 (Agent Failure Taxonomy)

> **來源**: Karpathy "Agentic Engineering" (2025–2026) + 生產系統故障分析
> **日期**: 2026-03-02
> **定位**: 失效模式一旦可描述，就能被工程流程吸收——這比換模型更能持續提高勝率

**X-Ray 開場**

早期 Agent 的失敗像玄學（亂飄、亂改、忘上下文）。Agentic Engineering 成熟的標誌之一，是失效模式變得可管理：可以被識別、分類、預防，甚至自動恢復。本文定義 6 種 Agent 核心失效類型，並為每種類型提供：識別特徵（signature）、預防機制、恢復路徑。

---

## 失效分類總覽

| 類型 | 中文名 | 核心特徵 | 嚴重程度 |
|------|--------|---------|---------|
| T1 | 範圍洩漏 | Agent 修改了 Task Packet 範圍外的文件 | 高（難溯源）|
| T2 | 上下文漂移 | Agent 在長會話中忘記初始約束 | 高（靜默失效）|
| T3 | API 契約誤讀 | Agent 錯誤理解工具或 API 的 schema | 中（可測試發現）|
| T4 | 邊界條件缺失 | Spec 未覆蓋的 edge case，Agent 靜默跳過 | 中（測試階段可發現）|
| T5 | 語義回歸 | 測試通過但行為語義被破壞 | 高（最難檢測）|
| T6 | 多 Agent 鏈式失效 | 上游 Agent 的錯誤在下游被放大 | 極高（需要整條鏈回滾）|

---

## T1：範圍洩漏 (Scope Leak)

**定義**：Agent 在執行過程中修改、讀取或影響了 Task Packet `scope.out` 明確排除的文件或系統。

**識別特徵**：
- diff 中出現不在 `scope.in` 清單中的文件
- Agent 的 tool call log 顯示對 `scope.out` 路徑的讀寫
- 其他模塊的 test 開始失敗（無明顯原因）

**根本原因**：
- Task Packet 未明確定義 `scope.out`
- Agent 「順手」修改了相關文件（沒有約束阻止）
- 工具調用沒有路徑限制

**預防**：
- Task Packet 強制要求 `scope.out` 字段
- 物理護欄（`01-physical-rails`）：文件系統沙箱限制寫入範圍
- 在 AGENT_CONSTITUTION 中明確：「未在 scope.in 中的路徑，禁止寫入」

**恢復**：
- 回滾 diff 中不在 `scope.in` 的所有變更
- 重新執行帶修訂範圍的 Task Packet

---

## T2：上下文漂移 (Context Drift)

**定義**：在長會話中，Agent 逐漸忘記早期注入的約束、格式要求或決策，導致後期輸出偏離初始規格。

**識別特徵**：
- 輸出格式在會話中途改變（如從 JSON 切換到自由文本）
- Agent 採用早期被否決的方案
- Constraint Summary 要求 Agent 重述約束時，遺漏了關鍵項目

**根本原因**：
- 後期 tool call 結果填滿上下文窗口，擠出早期的 AGENT_CONSTITUTION
- 無 Checkpointing 機制
- 長任務未被分解成多個獨立 Task Packet

**預防**：
- Context Refresh：每 N 輪對話後重新注入 AGENT_CONSTITUTION（見 `context-engineering-field-guide`）
- 設定 Checkpointing：每個中間交付點要求 Agent 報告當前活躍約束
- 大任務拆分：用 Ralph Loop 拆解為短 Task Packet

**恢復**：
- 從最近的 Checkpoint 重新執行
- 在新會話中注入完整 AGENT_CONSTITUTION 後繼續

---

## T3：API 契約誤讀 (API Contract Misread)

**定義**：Agent 錯誤理解工具、外部 API 或內部函數的輸入輸出 schema，導致調用失敗或靜默產生錯誤結果。

**識別特徵**：
- 工具調用返回 schema validation error
- Agent 構造的請求缺少必填字段或包含無效字段
- 返回值被 Agent 誤解（如把 null 當作空數組處理）

**根本原因**：
- API 文檔不在 Agent 的上下文中
- API 版本變更但 Agent 使用舊版 schema
- 工具返回值格式不符合 Agent 友好設計原則（見 `02-agent-design/agent-ui-api-design-patterns`）

**預防**：
- 在 Task Packet 的 `context_refs` 中引用相關 API 文檔
- 工具設計遵循 Agent-friendly 原則：結構化輸出、明確錯誤信息
- 邏輯護欄（`02-logical-contracts`）：在工具層做 schema validation

**恢復**：
- 重新提供正確 schema + 重試
- 若反覆失敗，升級為人工介入（Guard 角色觸發）

---

## T4：邊界條件缺失 (Boundary Condition Gap)

**定義**：Task Packet 或 Spec 未覆蓋某些 edge case，Agent 在遇到這些 case 時靜默跳過或用錯誤的默認行為處理。

**識別特徵**：
- 特定輸入導致 Agent 輸出為空或返回通用 fallback
- Agent 對某類輸入無警告地選擇了「最近似」的錯誤處理方式
- 測試覆蓋只有 happy path，邊界 case 從未被測試

**根本原因**：
- PRD / Spec 寫作者未思考 edge case
- Agent 接受了模糊規格而沒有提出問題（應在 Spec 階段觸發）
- 驗收標準（acceptance criteria）只有正常路徑

**預防**：
- PRD 模板中強制包含「已知 edge case 和期望行為」章節
- Agent 在開始執行前，必須對規格中的每個不確定點提出問題（Spec Gate）
- 評估體系（`06-agent-evals-playbook`）中包含邊界 case 測試

**恢復**：
- 補充 edge case 規格後，在原 Task Packet 上補充執行
- 若影響已上線功能，觸發回滾流程

---

## T5：語義回歸 (Semantic Regression)

**定義**：Agent 的修改通過了所有自動化測試，但破壞了代碼或系統的語義意圖（行為變了，但測試不知道）。

**識別特徵**：
- CI 全部綠燈，但人工 review 發現行為異常
- 功能表現「接近但不完全符合」預期
- 用戶反映行為改變，但難以用測試描述

**根本原因**：
- 測試覆蓋了實現細節，沒有覆蓋業務意圖
- Agent 找到了「繞過」測試的最短路徑（並非理解語義）
- Acceptance Criteria 過於技術化（pass tests）而非功能化（behavior matches spec）

**預防**：
- Acceptance Criteria 必須包含行為描述，不只是「測試通過」
- Model-based eval（`06-agent-evals-playbook`）：用 LLM 評估語義正確性
- 人工 review 是最後防線（不能被 CI 完全替代）

**恢復**：
- 回滾 Agent 的修改
- 重寫 Acceptance Criteria 以包含語義測試
- 加入回歸測試用例後重新委派

---

## T6：多 Agent 鏈式失效 (Multi-Agent Cascade)

**定義**：在多 Agent 流水線中，上游 Agent 的錯誤輸出被下游 Agent 當作正確輸入，導致錯誤在整條鏈中被放大。

**識別特徵**：
- 最終輸出質量遠低於單個 Agent 的能力水平
- 追溯 tool call log 發現錯誤源自流水線早期
- 中間 Agent 的輸出在沒有驗證的情況下直接傳遞

**根本原因**：
- Agent 間沒有輸出驗證機制（每個 Agent 假設上游正確）
- 流水線設計沒有中間 Checkpoint
- 錯誤被設計為「繼續執行」而非「停止並報告」

**預防**：
- 每個 Agent 的輸出必須通過 schema validation 才能傳遞（邏輯護欄）
- 在流水線關鍵節點插入 Reviewer Agent（獨立驗證，不執行）
- 設計失敗傳播策略：任何 Agent 失敗 → 整條鏈停止（fail-fast）

**恢復**：
- 從失效點重新執行，而非從起點
- 需要完整的鏈式 Rollback（`04-playbook-risk-and-rollback`）

---

## 失效 → 改進的學習閉環

每次生產失效應觸發以下流程：

```
失效發生
    ↓
分類（T1-T6）
    ↓
根本原因分析（RCA）
    ↓
改進動作（3選1）：
  - Prompt / Spec 改進（T2/T4 首選）
  - 工具 / 護欄改進（T1/T3/T6 首選）
  - 測試 / Eval 改進（T5 首選）
    ↓
記錄到 Failure Log → 更新 Agent Evals（回歸保護）
```

失效日誌格式（推薦）：

```json
{
  "date": "2026-03-02",
  "type": "T1",
  "task_id": "task-2026-03-02-001",
  "description": "Agent 修改了 src/db/ 下的 schema 文件",
  "root_cause": "Task Packet 缺少 scope.out 定義",
  "fix": "更新 Task Packet 模板，強制要求 scope.out",
  "regression_test_added": true
}
```

---

## 相關文章

- `03-engineering/01-physical-rails.md` — T1 的物理層預防
- `03-engineering/02-logical-contracts.md` — T3/T6 的邏輯層預防
- `03-engineering/04-playbook-risk-and-rollback.md` — 各類型的回滾策略
- `03-engineering/06-agent-evals-playbook.md` — T5 語義回歸的 Model-based eval
- `03-engineering/context-engineering-field-guide.md` — T2 Context 漂移的預防
