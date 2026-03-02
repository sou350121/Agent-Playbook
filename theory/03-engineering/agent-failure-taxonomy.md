# Agent 失效分類學 (Agent Failure Taxonomy)

> 📌 **支柱 A — 護欄與安全**

> **最重要的洞察**：失效的根源不是模型本身，而是 Agent 之間的整合點——規格斷層、上下文污染、驗證缺失在鏈式系統中以指數級放大。可命名的失效，才是可工程化的失效。
>
> — 綜合 Karpathy "Agentic Engineering" + MAST 研究 (arXiv 2503.13657) + 生產系統故障分析

**來源**: Karpathy "Agentic Engineering" (2025–2026) + MAST 多 Agent 失效分類學研究 + 生產系統故障分析
**更新日期**: 2026-03-02
**定位**: 失效模式一旦可描述，就能被工程流程吸收——這比換模型更能持續提高勝率

---

## 生產現場數據：失效有多普遍？

MAST 研究（arXiv 2503.13657）對 7 個主流多 Agent 框架的 1600+ 條執行 trace 進行了系統性分析：

- **41–86.7%** 的多 Agent 系統在生產環境中存在失效（不同框架差異顯著）
- **FC2（Agent 間對齊失效）** 是最大的單一失效來源，覆蓋 6 種失效模式
- **79%** 的問題源自規格設計與協調問題，而非底層模型能力
- 生產部署者中 **32%** 將輸出質量列為頭號障礙
- 失效通常在部署後數小時內發生，不是日後的長尾問題

核心結論：**問題很少單獨來自模型，更多出現在整合點。**

---

## 失效分類總覽（T1–T7）

| 類型 | 中文名 | 核心特徵 | 嚴重程度 | MAST 對應 |
|------|--------|---------|---------|-----------|
| T1 | 範圍洩漏 | Agent 修改了 Task Packet 範圍外的文件 | 高（難溯源）| FC1: FM-1.2 |
| T2 | 上下文漂移 | Agent 在長會話中忘記初始約束 | 高（靜默失效）| FC1: FM-1.4 |
| T3 | API 契約誤讀 | Agent 錯誤理解工具或 API 的 schema | 中（可測試發現）| FC1: FM-1.1 |
| T4 | 邊界條件缺失 | Spec 未覆蓋的 edge case，Agent 靜默跳過 | 中（測試階段可發現）| FC3: FM-3.2 |
| T5 | 語義回歸 | 測試通過但行為語義被破壞 | 高（最難檢測）| FC3: FM-3.3 |
| T6 | 多 Agent 鏈式失效 | 上游 Agent 的錯誤在下游被放大 | 極高（需要整條鏈回滾）| FC2: FM-2.3/2.5 |
| T7 | 跨 Agent 上下文污染 | Agent A 的幻覺成為 Agent B 的事實 | 極高（全鏈污染）| FC2: FM-2.4/2.6 |

---

## MAST 三類失效框架（研究背景）

MAST（Multi-Agent System Failure Taxonomy，arXiv 2503.13657）通過 Grounded Theory 方法，識別了橫跨 3 大類別的 14 種失效模式：

### FC1：規格與系統設計失效（5 種模式）

設計層面的缺陷——會在每次執行中持續觸發：

| 代碼 | 名稱 | 本地對應 |
|------|------|---------|
| FM-1.1 | 違反任務規格 | T3 API 契約誤讀 |
| FM-1.2 | 違反角色規格 | T1 範圍洩漏 |
| FM-1.3 | 步驟重複循環 | — |
| FM-1.4 | 對話歷史丟失 | T2 上下文漂移 |
| FM-1.5 | 不知道終止條件 | — |

### FC2：Agent 間對齊失效（6 種模式）—— 最大失效來源

跨 Agent 協作的核心張力——是生產環境中最難預防的類別：

| 代碼 | 名稱 | 描述 |
|------|------|------|
| FM-2.1 | 對話上下文重置 | Agent 間切換導致上下文丟失 |
| FM-2.2 | 未能主動澄清 | 模糊指令下繼續執行而非提問 |
| FM-2.3 | 任務脫軌 | Agent 執行了偏離原始目標的任務 |
| FM-2.4 | 信息隱藏/截斷 | Agent 持有關鍵信息但未傳遞 |
| FM-2.5 | 忽略他方輸入 | Agent 忽視了上游 Agent 的結果 |
| FM-2.6 | 推理-行動不一致 | 推理鏈與實際 tool call 不匹配 |

> MAST 研究特別指出：FC2 的失效需要 Agent 具備更深層的「社交推理能力」——僅靠上下文或通信協議優化通常不夠。

### FC3：任務驗證與終止失效（3 種模式）

| 代碼 | 名稱 | 本地對應 |
|------|------|---------|
| FM-3.1 | 提前終止 | T4 邊界條件缺失 |
| FM-3.2 | 缺少或不完整驗證 | T4 邊界條件缺失 |
| FM-3.3 | 錯誤的驗證邏輯 | T5 語義回歸 |

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
- 最小特權原則：Agent 默認只能訪問當前 task 明確授權的路徑，不繼承全局工具調用權限
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

## T7：跨 Agent 上下文污染（新提案）

**定義**：Agent A 在執行中產生的幻覺輸出（hallucinated facts、fabricated schemas、invented API names），被 Agent B 作為有效事實直接使用，導致錯誤在整個多 Agent 系統中被「固化」為基礎假設。

這與 T6（鏈式失效）的區別在於：
- T6 是可觀測的「執行錯誤」傳遞（schema error、空返回等）
- T7 是不可觀測的「語義錯誤」傳遞——數據在形式上合法，但內容是虛構的

**識別特徵**：
- Agent B 引用了 Agent A 從未真正調用過的 API 或文件
- 流水線後段產生的輸出「邏輯自洽」但與外部事實對不上
- 各 Agent 本地 trace 看起來正常，但端對端輸出失真
- 幻覺在 handoff 邊界跨越後被「清洗」掉了來源標記

**根本原因**（對應 MAST FC2: FM-2.4 信息截斷 + FM-2.6 推理-行動不一致）：
- Agent 間交接缺乏 handoff contract（無明確的 producer/consumer schema）
- Downstream Agent 不區分「已驗證事實」與「上游推斷內容」
- 中間結果無溯源標記（provenance tag）

**具體示例**：

```
Researcher Agent（上游）
→ 幻覺：「論文 X 使用了 LoRA rank=64，batch_size=32」
→ 輸出 JSON：{"paper": "X", "lora_rank": 64, "batch_size": 32}
                        ↓  無驗證傳遞
Writer Agent（下游）
→ 以此為事實寫入技術文檔：「X 的最佳配置是 rank=64」
                        ↓  無溯源追蹤
Publisher Agent（最下游）
→ 發布至知識庫，成為後續 Agent RAG 的「引用源」
→ 錯誤自我強化，後續系統難以糾正
```

**預防**：
1. **顯式 Handoff Contract**：每個 Agent 的輸出 JSON 必須包含 `confidence`（0–1）和 `source_type`（`verified` / `inferred` / `hallucinated_risk`）字段
2. **Downstream 消費規則**：`confidence < 0.7` 或 `source_type != "verified"` 的字段，下游 Agent 必須先做外部驗證，不得直接引用
3. **溯源標記透傳**：整條鏈中 provenance 標記不得丟失，任何 Agent 不得「淨化」上游的不確定性標記
4. **幻覺防火牆 Agent**：在關鍵 handoff 節點插入專門的 Fact-Check Agent，對高置信度聲明（paradoxically risky）做反向驗證

**恢復**：
- 追溯首次引入幻覺的 handoff 節點
- 從該節點重新執行，要求 Researcher Agent 提供可驗證來源
- 標記下游所有依賴該幻覺的知識庫條目為「待審查」

---

## 級聯放大機制（Cascade Amplification）

> 多 Agent 系統的致命屬性：錯誤不是線性傳遞的，而是指數級放大的。

### 放大機制解析

```
Step 1 - 上游 Agent（Spec 解析）
  輸入: 模糊需求 "優化用戶體驗"
  錯誤: 解析為 "減少頁面元素數量"（而非正確的 "降低操作步驟"）
  輸出置信度: 0.85（看起來合理）
          ↓ 無驗證傳遞
Step 2 - 中游 Agent（設計生成）
  以 Step 1 輸出為事實，生成了「簡化 UI 方案」
  額外引入: 刪除了高級功能入口
  錯誤疊加: Step 1 錯誤 × Step 2 設計偏差
          ↓ 無 Checkpoint
Step 3 - 下游 Agent（代碼實現）
  以 Step 2 設計為基準，實現了功能刪減
  額外引入: 相關測試也隨之刪除（「按設計如此」）
  最終偏差: 原始需求與交付物完全背離
          ↓ 所有自動化測試通過
```

### 放大的三個加速因子

1. **置信度繼承**：下游 Agent 繼承了上游的高置信度，錯誤被當作確定事實
2. **驗證缺失**：每個 Agent 假設上游「已驗證」，沒有人做全局一致性檢查
3. **上下文隔離**：各 Agent 只看自己的輸入輸出，無法感知鏈條整體的方向偏移

### 預防原則

- **Skeptical Consumer 模式**：下游 Agent 默認懷疑上游輸入，必須能解釋「為什麼接受這個輸出」
- **全局目標回歸**：每個 Agent 在輸出前對照原始 Task Goal 做一次「漂移檢查」
- **中間態可觀測**：所有 Agent 間的 handoff payload 必須可被外部監控和審計

---

## 預防矩陣

| 失效類型 | 檢測方式 | 自動化預防 | 人工審查觸發條件 |
|---------|---------|-----------|----------------|
| T1 範圍洩漏 | diff 比對 scope.in 清單 | 文件系統沙箱、路徑白名單 | diff 中出現 scope.out 路徑 |
| T2 上下文漂移 | Constraint Replay 檢查 | Context Refresh 注入、Checkpointing | Agent 遺漏 >2 個初始約束 |
| T3 API 誤讀 | Schema Validation 日誌 | 工具層強制 schema validation | validation error 連續 3 次 |
| T4 邊界缺失 | Edge case 測試套件 | Spec Gate（執行前問題清單）| 空輸出或 fallback 被觸發 |
| T5 語義回歸 | Model-based eval + 人工 review | 語義測試用例庫、LLM judge | CI 通過但 LLM judge 分數 <0.7 |
| T6 鏈式失效 | 端對端 trace 分析 | fail-fast 傳播、Reviewer Agent | 最終輸出質量低於基準 20% |
| T7 上下文污染 | Provenance 標記追蹤 | Handoff Contract schema 強制 | source_type=inferred 被下游直接引用 |

---

## 故障響應 SLA 建議

根據失效類型的影響範圍和可逆性，建議以下嚴重程度分級和響應目標：

### P0：立即停止（< 15 分鐘響應）

觸發條件：
- T1 範圍洩漏波及生產數據或安全邊界
- T7 上下文污染已擴散至知識庫（多 Agent 共享事實庫被污染）
- T6 鏈式失效導致整條 pipeline 輸出不可用

響應動作：
1. 立即暫停整條 Agent pipeline
2. 隔離受影響的共享存儲（知識庫、向量庫）
3. 啟動全鏈回滾（從最後一個已驗證 Checkpoint）
4. 通知所有依賴下游

### P1：當日修復（< 4 小時響應）

觸發條件：
- T2 上下文漂移已產生輸出但尚未下游傳遞
- T5 語義回歸在代碼審查中發現（未上線）
- T6 鏈式失效影響單條 pipeline（不影響共享資源）

響應動作：
1. 從最近 Checkpoint 重新執行
2. 補充 Constraint Refresh 機制
3. 更新 Acceptance Criteria
4. 添加回歸測試保護

### P2：計劃修復（< 48 小時）

觸發條件：
- T3 API 誤讀導致調用失敗但已優雅降級
- T4 邊界條件缺失影響非核心路徑
- T5 語義回歸在測試環境中發現

響應動作：
1. 記錄到 Failure Log
2. 補充 edge case 規格和測試
3. 下次迭代中修復

### SLA 監控指標

```json
{
  "sla_targets": {
    "P0": {"response_minutes": 15, "resolve_hours": 2},
    "P1": {"response_hours": 4, "resolve_hours": 24},
    "P2": {"response_hours": 24, "resolve_hours": 48}
  },
  "escalation_triggers": {
    "T7_knowledge_base_contamination": "P0",
    "T6_full_pipeline_failure": "P0",
    "T1_production_scope_breach": "P0",
    "T2_drift_with_downstream_impact": "P1",
    "T5_semantic_regression_pre_release": "P1",
    "T3_api_failure_degraded": "P2",
    "T4_edge_case_non_critical": "P2"
  }
}
```

---

## 失效 → 改進的學習閉環

每次生產失效應觸發以下流程：

```
失效發生
    ↓
分類（T1-T7）+ MAST 對應（FC1/FC2/FC3）
    ↓
根本原因分析（RCA）
    ↓
改進動作（3選1）：
  - Prompt / Spec 改進（T2/T4 首選）
  - 工具 / 護欄改進（T1/T3/T6/T7 首選）
  - 測試 / Eval 改進（T5 首選）
    ↓
記錄到 Failure Log → 更新 Agent Evals（回歸保護）
```

失效日誌格式（推薦）：

```json
{
  "date": "2026-03-02",
  "type": "T7",
  "mast_category": "FC2",
  "mast_modes": ["FM-2.4", "FM-2.6"],
  "severity": "P0",
  "task_id": "task-2026-03-02-001",
  "description": "Researcher Agent 幻覺論文配置被 Writer Agent 當作事實引用",
  "root_cause": "Handoff payload 缺少 confidence 和 source_type 字段",
  "fix": "強制所有 Agent 間 payload 包含 provenance schema",
  "regression_test_added": true,
  "knowledge_base_remediation": "標記 3 條受污染條目為 needs_reverification"
}
```

---

## 研究來源

- [Why Do Multi-Agent LLM Systems Fail? (MAST, arXiv 2503.13657)](https://arxiv.org/abs/2503.13657) — 14 種失效模式 + 1600+ traces 分析
- [MAST GitHub 數據集](https://github.com/multi-agent-systems-failure-taxonomy/MAST) — 7 框架跨平台驗證數據
- Karpathy "Agentic Engineering" (2025–2026) — T1–T6 原始分類框架
- 生產系統故障分析（多 Agent 框架 2025–2026）

## 相關文章

- `03-engineering/01-physical-rails.md` — T1 的物理層預防
- `03-engineering/02-logical-contracts.md` — T3/T6/T7 的邏輯層預防
- `03-engineering/04-playbook-risk-and-rollback.md` — 各類型的回滾策略
- `03-engineering/06-agent-evals-playbook.md` — T5 語義回歸的 Model-based eval
- `03-engineering/context-engineering-field-guide.md` — T2 Context 漂移的預防
- `03-engineering/trust-tier-design.md` — Agent 間信任層次與 Handoff 安全邊界
