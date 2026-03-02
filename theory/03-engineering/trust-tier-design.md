# Agent 信任層級設計 (Trust Tier Design)

> **來源**: Karpathy "Agentic Engineering" + 生產系統治理實踐 (2025–2026)
> **日期**: 2026-03-02
> **定位**: 信任層級是 Agentic 系統的授權框架——它決定「哪些 Agent 動作可以自主執行，哪些需要人工確認」

**X-Ray 開場**

「讓 Agent 自動化一切」是常見的誤區。真正可持續的 Agentic 系統不是把所有操作都設為全自動，而是根據**風險維度**明確劃定每個動作的信任層級，並隨著 Eval 數據積累逐步提升高可信操作的自主度。信任層級不是靜態配置，而是一個可演進的治理框架。

---

## 四個信任評估維度

在為任何 Agent 動作設定信任層級之前，先對這四個維度打分：

| 維度 | 定義 | 低風險 | 高風險 |
|------|------|--------|--------|
| **範圍風險** | 操作影響的文件/系統範圍 | 單一文件、隔離模塊 | 跨模塊、共享基礎設施 |
| **可逆性** | 操作是否可以無損回滾 | Git revert 可完全恢復 | 數據庫寫入、外部 API 調用 |
| **成本** | 操作失敗的業務代價 | 開發環境、非核心功能 | 生產環境、核心數據、用戶可見 |
| **新穎性** | Agent 執行此類操作的歷史記錄 | 已執行 >20 次且 pass rate >90% | 首次執行或 pass rate 不穩定 |

---

## 五個信任層級

```
T0 — 完全人工
T1 — 人工批准後執行
T2 — 執行後人工審查
T3 — 例外條件升級
T4 — 完全自主
```

### T0：完全人工 (Full Human)

**定義**：Agent 只提供建議/草稿，人類決策並親自執行。

**適用條件**（任意一個即適用）：
- 涉及生產數據庫的寫入或 Schema 變更
- 外部服務的不可逆調用（發送郵件、金融交易）
- 首次在新代碼庫執行的任何操作
- 範圍風險 + 不可逆 + 高成本三重高風險

**Agent 的角色**：分析、建議、起草——不執行。

---

### T1：人工批准後執行 (Human Approval)

**定義**：Agent 準備完整的執行計劃（含 diff preview），人類批准後才執行。

**適用條件**：
- 跨模塊的重構操作
- 新增或修改 CI/CD pipeline
- 影響多個文件（>10 files）的系統性變更
- 首次引入新的外部依賴

**審查流程**：
```
Agent → 生成執行計劃 + diff preview
      → 人類審查（必須確認 scope.in 邊界）
      → 批准後 Agent 執行
      → Agent 輸出結果報告
```

---

### T2：執行後人工審查 (Human Review)

**定義**：Agent 自主執行，人類事後審查 diff 並決定是否合併。

**適用條件**：
- 單模塊內的功能新增（有清晰的 Task Packet）
- 有充分測試覆蓋的 bug fix
- 文檔更新、README 修改
- 該類型操作的 Eval pass rate ≥ 85% 且已執行 ≥ 10 次

**審查重點**（reviewer 應確認）：
- diff 是否在 Task Packet 的 scope.in 範圍內（T1 失效檢測）
- 測試是否覆蓋了 Acceptance Criteria
- 是否有意外的 side effect

---

### T3：例外條件升級 (Exception Escalation)

**定義**：Agent 完全自主執行，僅在預定義的例外條件觸發時升級至人工。

**適用條件**：
- 重複性的標準化操作（如格式化、類型修復、依賴版本更新）
- 操作已建立完整的回歸測試套件
- 過去 30 天 Eval pass rate ≥ 92%
- 失敗有明確的自動回滾機制

**例外條件示例（需升級至人工）**：
```python
ESCALATION_CONDITIONS = [
    "diff_size > 500 lines",           # 範圍超出預期
    "new_file_created outside scope",  # T1 失效特徵
    "test_failures > 0",               # CI 失敗
    "confidence_score < 0.7",          # 模型自報低置信度
    "touched_files contains 'db/'",    # 高風險路徑
]
```

---

### T4：完全自主 (Full Autonomy)

**定義**：Agent 完全自主執行，僅記錄日誌，無需人工介入。

**適用條件**（全部滿足）：
- 操作完全可逆（任何時刻可 rollback）
- 過去 90 天 Eval pass rate ≥ 95%
- 失敗有完整的自動恢復機制
- 操作範圍嚴格限於隔離沙箱
- 已通過 Agent Architect 的正式 T4 晉升評審

**典型 T4 操作**：
- 代碼格式化（oxfmt / prettier）
- Lint 自動修復（oxlint --fix）
- 依賴的 patch 版本更新
- 測試文件的自動生成（模板化部分）

---

## 信任層級矩陣

快速判斷工具——根據四個維度的組合確定起始層級：

| 範圍風險 | 可逆性 | 成本 | 新穎性 | 起始層級 |
|---------|--------|------|--------|---------|
| 低 | 可逆 | 低 | 有記錄 | T3 或 T4 |
| 低 | 可逆 | 低 | 首次 | T2 |
| 低 | 可逆 | 高 | 任意 | T1 |
| 低 | 不可逆 | 任意 | 任意 | T1 |
| 高 | 可逆 | 低 | 有記錄 | T2 |
| 高 | 可逆 | 高 | 任意 | T1 |
| 高 | 不可逆 | 任意 | 任意 | T0 |

**原則**：有疑問時，選更保守的層級。

---

## 信任層級的晉升機制

信任層級不是永久固定的，而是基於 Eval 數據可以升降。

### 晉升條件

```
T0 → T1：  完成 ≥5 次人工協助執行，並記錄標準化流程
T1 → T2：  ≥10 次 T1 批准無異議 + Eval pass rate ≥ 85%
T2 → T3：  ≥20 次 T2 review 通過 + Eval pass rate ≥ 92% + 有自動回滾
T3 → T4：  ≥50 次 T3 零升級 + Eval pass rate ≥ 95% + Agent Architect 正式評審
```

### 降級條件（立即執行）

```
任何 T2 或以上操作觸發 T5（語義回歸）→ 降至 T1
連續 3 次 Eval 失敗 → 降一級
發生 T6（多 Agent 鏈式失效）→ 整條鏈降至 T0
```

---

## 與現有框架的關係

`02-agent-design/01-operating-model-and-roles.md` 的四個門控（Spec Gate / Diff Gate / Exec Gate / Release Gate）是**流程**層面的人工介入點。

信任層級框架是**授權**層面的決策框架——它決定哪些操作需要觸發哪個門控，以及如何隨時間演進。

```
信任層級（授權）→ 門控設計（流程）→ 審查執行（操作）
```

---

## 操作手冊：新增 Agent 工作流的信任層級設定

1. 列出工作流中的所有 Agent 動作
2. 對每個動作，用四維度矩陣確定起始層級
3. 在 Task Packet 的 `trust_tier` 字段中聲明
4. 設定晉升目標和評估週期
5. 每季度由 Agent Architect 審查層級配置

---

## 相關文章

- `02-agent-design/01-operating-model-and-roles.md` — 六角色模型與四個流程門控
- `03-engineering/agent-failure-taxonomy.md` — 各層級的失效模式分布
- `03-engineering/agentic-control-plane-design.md` — 信任層級是控制平面第 5 維度
- `03-engineering/04-playbook-risk-and-rollback.md` — 各層級的回滾策略
- `05-strategy/agent-native-org-roles.md` — 誰有權批准信任層級晉升（Agent Architect）
