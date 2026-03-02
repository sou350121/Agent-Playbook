# Agent 信任層級設計 (Trust Tier Design)

> **來源**: Karpathy "Agentic Engineering" + 生產系統治理實踐 + TRiSM 框架 + NIST Agentic AI Standards Initiative (2025–2026)
> **日期**: 2026-03-02
> **定位**: 信任層級是 Agentic 系統的授權框架——它決定「哪些 Agent 動作可以自主執行，哪些需要人工確認」

> 📌 支柱 A — 护栏与安全

**X-Ray 開場**

「給 Agent 的權限不應該比完成任務所需的最小權限多一比特。」

「讓 Agent 自動化一切」是常見的誤區。真正可持續的 Agentic 系統不是把所有操作都設為全自動，而是根據**風險維度**明確劃定每個動作的信任層級，並隨著 Eval 數據積累逐步提升高可信操作的自主度。信任層級不是靜態配置，而是一個可演進的治理框架。

2026 年的行業現狀：超過 80% 的企業已部署 AI Agent，但不足一半建立了完整的權限治理體系（ISACA 2025）。信任層級設計是填補這一缺口的核心抓手。

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

### 信任分層的量化標準

信任層級不只是名字，每一層都有可驗證的量化邊界：

| 層級 | 操作可逆性 | 影響範圍 | 量化門檻 |
|------|-----------|---------|---------|
| **T0** | 操作完全不可逆，或可逆性未知 | 影響生產數據 / 外部系統 / 用戶可見 | 任意不可逆或跨系統操作 |
| **T1** | 操作可回滾，但需要人工介入 | 影響範圍 < 本倉庫 / 工作區 | Eval pass rate 任意（需批准） |
| **T2** | 操作可回滾，失敗代價可接受 | 影響外部可查詢接口（只讀或有限寫） | Eval pass rate ≥ 85%，執行次數 ≥ 10 |
| **T3** | 操作可部分自動回滾 | 影響範圍 < 本進程 / 隔離沙箱 | Eval pass rate ≥ 92%，執行次數 ≥ 20，有自動回滾 |
| **T4** | 操作完全可逆，任何時刻可 rollback | 操作範圍嚴格限於隔離沙箱 | Eval pass rate ≥ 95%，執行次數 ≥ 50，Agent Architect 評審 |

> 設計原則：**有疑問時，選更保守的層級**。傳統 RBAC 遇到 Agent 會出現「角色爆炸」（role explosion）——與其維護 support-agent-tier-1/2/3... 等無限角色，不如用可量化的維度矩陣動態評估。

---

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

## TRiSM 框架集成

Gartner 的 AI TRiSM（Trust, Risk, and Security Management）框架為信任層級設計提供了更廣泛的治理視角。預測到 2026 年，實施 AI 透明度與信任控制的組織，其 AI 模型的採用率和業務目標達成率將提升 50%。

TRiSM 有四個核心支柱，每個支柱與信任層級設計直接映射：

### 1. Explainability（可解釋性）

每個信任層級的 Agent 動作都必須留下可追溯的推理鏈：

```python
# 每個 Agent 動作記錄的最小追蹤單元
action_trace = {
    "action_id": "uuid",
    "trust_tier": "T2",
    "reasoning": "...",          # 決策依據
    "decision_provenance": [...],  # 輸入 context 來源
    "tool_calls": [...],           # 工具調用序列
    "human_approved_by": None,     # T1/T0 時填寫
    "rollback_plan": "...",        # T0-T2 必填
}
```

### 2. ModelOps（模型運維）

信任層級不是一次性配置，需要持續監控和版本管理：

- **版本控制**：每次模型升級後，重新評估已達 T3/T4 的操作（模型行為可能漂移）
- **Drift 監控**：Eval pass rate 連續 3 次下降超過 5% → 自動降一級
- **Rollback 機制**：模型版本回滾時，對應操作的信任層級同步回滾至上一版本評估結果

### 3. Application Security（應用安全）

詳見下方「Prompt Injection 防禦矩陣」章節。核心原則：

- Input Sanitization 在進入 Agent context 之前攔截惡意指令
- Context Isolation 防止跨信任邊界的信息洩漏
- Output Validation 驗證 Agent 輸出符合預期格式和語義
- Human Escalation 在高風險決策點強制人工介入

### 4. Privacy（隱私保護）

多 Agent 系統中，數據最小化原則尤為關鍵：

- **Data Minimization**：Agent 只接收完成任務所需的最小數據集（不傳遞整個用戶檔案）
- **Encryption**：Agent 間通信（A2A）使用加密通道；敏感數據不明文出現在 prompt 中
- **Multi-agent Sharing**：跨 Agent 共享數據時，需降級為接收方的最低信任層級

> Gartner 2026 預警：到 2026 年，80% 以上的未授權 AI 事務將來自企業內部的信息過度共享，而非外部攻擊。

---

## Prompt Injection 防禦矩陣

Prompt Injection 是 OWASP LLM Top 10（2025）的第 1 號威脅，也是 Agent 信任邊界的核心攻擊面。

### 兩類攻擊向量

| 類型 | 定義 | 攻擊路徑示例 | 危險等級 |
|------|------|-------------|---------|
| **Direct Injection**（直接注入） | 攻擊者直接向 Agent 輸入惡意指令 | 用戶輸入框中插入「忽略所有規則...」 | 中（易於輸入驗證攔截） |
| **Indirect Injection**（間接注入） | 攻擊者污染 Agent 讀取的外部數據源 | 網頁、文檔、MCP tool description、memory store 中藏入惡意指令 | 高（攻擊者無需直接接觸系統） |

間接注入之所以危險，是因為攻擊者不需要直接操作 Agent 界面——只需污染 Agent 會讀取的任何外部數據源（網頁、PDF、代碼倉庫、郵件、MCP schema）即可。

### 四層防禦體系

```
Layer 1: Input Sanitization（輸入淨化）
         ↓
Layer 2: Context Isolation（上下文隔離）
         ↓
Layer 3: Output Validation（輸出驗證）
         ↓
Layer 4: Human Escalation（人工升級）
```

| 防禦層 | 實施要點 | 對應信任層級 |
|--------|---------|-------------|
| **L1 Input Sanitization** | 在數據進入 Agent context 之前，過濾已知注入模式；MCP tool description 在協議邊界攔截並掃描 | 所有層級 |
| **L2 Context Isolation** | 不同信任域的數據不混入同一 context window；用戶數據 ≠ 系統 prompt；tool output 標記來源 | T2–T4 強制 |
| **L3 Output Validation** | 驗證 Agent 輸出符合預期 schema；tool call 參數白名單驗證；semantic 合規性檢查 | T3–T4 強制 |
| **L4 Human Escalation** | 高風險 tool call 前強制人工確認；置信度低於閾值時停止並上報 | T0–T1 必須；T2 推薦 |

**MCP 特殊威脅**：Model Context Protocol 的普及大幅擴展了間接注入攻擊面。tool poisoning（惡意 tool description）和 credential theft 是 2026 年的新型攻擊向量，需要在 MCP 協議邊界額外部署 schema 掃描。

---

## 多 Agent 信任傳遞問題

當 Agent A 委托 Agent B 執行子任務時，信任層級如何傳遞？

### 核心原則：默認不繼承，顯式提升

```
Agent A (T3) 委托 Agent B 執行子任務
→ Agent B 默認獲得 T0（最保守）
→ 需要顯式聲明 elevation，並記錄授權依據
```

**為什麼不繼承？**
- Agent B 可能是第三方插件，其行為未經 T3 Eval 驗證
- 委托鏈越長，累積風險越高（A→B→C 的鏈式失效風險）
- 攻擊者可能通過控制 Agent B 來繞過 Agent A 的信任層級

### 實現模式：委托令牌（Delegation Token）

```python
delegation_token = {
    "delegator": "agent_a_id",
    "delegatee": "agent_b_id",
    "granted_tier": "T1",          # 顯式聲明，不超過委托方當前層級
    "scope": ["read:repo", "write:branch"],  # 最小權限集
    "expires_at": "2026-03-02T12:00:00Z",
    "requires_human_approval": True,    # T1 需要批准
    "audit_trail_id": "uuid",
}
```

**OAuth Scope 模式**：用戶和管理員通過 OAuth Scope 決定 Agent 的操作邊界，權限可見、可撤銷。每次委托都在 delegation graph 中記錄為一個可加密驗證的關係節點。

### 多 Agent 鏈式信任矩陣

| 場景 | 委托方層級 | 子 Agent 默認層級 | 允許提升上限 |
|------|-----------|-----------------|------------|
| 標準委托 | T3 | T0 | T2（需顯式聲明） |
| 已驗證子 Agent | T3 | T1（預配置） | T2（需顯式聲明） |
| 第三方 / 未知 Agent | 任意 | T0（強制） | T0（不允許提升） |
| 鏈式委托（A→B→C） | 任意 | T0（強制） | T1（需每層審批） |

> 降級觸發：發生 T6（多 Agent 鏈式失效）→ 整條鏈降至 T0，直到每個節點重新通過 Eval 評審。

---

## EU AI Act 合規映射

EU AI Act 於 2026 年 8 月 2 日正式要求高風險 AI 系統完成合規評估。信任層級設計是合規架構的核心載體。

### 風險分類與信任層級對應

| EU AI Act 風險類別 | 典型 Agent 操作 | 對應最低信任層級 | 合規要求 |
|------------------|----------------|----------------|---------|
| **不可接受風險**（禁止） | 社會評分、生物識別監控 | 禁止部署 | 架構層面排除 |
| **高風險**（嚴格管控） | 影響僱傭/信貸/教育的決策 | T0–T1 | 合規評估 + CE 標識 + EU 數據庫注冊 |
| **有限風險**（透明義務） | 面向用戶的生成內容 | T1–T2 | 告知用戶正在與 AI 交互 |
| **最小風險**（自願） | 內部工具、代碼輔助 | T2–T4 | 無強制要求（推薦遵循最小權限） |

### Article 12：審計日誌要求 → 信任層級日誌規範

EU AI Act Article 12 要求高風險 AI 系統自動記錄事件，確保可追溯性。信任層級日誌必須滿足：

```python
# 高風險操作（T0/T1）的最小合規日誌結構
compliance_log = {
    "timestamp": "ISO8601",
    "action_id": "uuid",
    "trust_tier": "T0",
    "agent_identity": "agent_id + version",
    "human_supervisor": "user_id",       # Article 14 人工監督
    "decision_inputs": [...],              # 決策依據（可追溯）
    "output_summary": "...",
    "rollback_available": True,
    "tamper_resistant": True,              # 日誌不可篡改
}
```

### Article 14：人工監督要求 → 信任層級門控

EU AI Act Article 14 要求高風險 AI 系統允許有效的人工監督。「人工監督」不是事後審查，而是：
- 人工監督者能夠理解系統局限性（需要 Explainability，見 TRiSM）
- 能夠在輸出影響用戶之前介入或中斷（T1 的批准門控）
- 能夠主動防止自動化偏差（Eval 數據驅動的層級評估）

> **實踐映射**：T0/T1 自動滿足 Article 14；T2/T3 的 exception escalation 機制提供部分合規保障；T4 需要額外的監控和干預機制才能用於高風險場景。

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
Eval pass rate 連續 3 次下降 >5% → 降一級（TRiSM Drift 監控觸發）
發生 T6（多 Agent 鏈式失效）→ 整條鏈降至 T0
```

---

## 實戰：最小權限原則實施清單

以下 10 條清單適用於任何 Agent 工作流的信任層級落地評審：

- [ ] **1. 動作清單完整**：列出工作流中的所有 Agent 動作（無遺漏）
- [ ] **2. 四維度評分**：每個動作完成範圍風險 / 可逆性 / 成本 / 新穎性四維度評分
- [ ] **3. 量化標準達標**：使用「信任分層的量化標準」表格驗證層級設定
- [ ] **4. Task Packet 聲明**：在 `trust_tier` 字段中明確聲明每個動作的層級
- [ ] **5. Prompt Injection 防禦**：為所有外部數據源輸入配置 L1（Input Sanitization）
- [ ] **6. 委托令牌配置**：多 Agent 場景下，為每個子 Agent 生成 delegation token，顯式聲明提升層級
- [ ] **7. 審計日誌啟用**：T0/T1 操作啟用合規日誌（不可篡改、含 human_supervisor 字段）
- [ ] **8. 自動回滾測試**：T3/T4 操作的自動回滾機制經過演練驗證
- [ ] **9. Drift 監控配置**：設置 Eval pass rate 連續下降告警（閾值 >5%，窗口 3 次）
- [ ] **10. 季度評審排期**：由 Agent Architect 每季度審查層級配置，依 Eval 數據決定晉升/降級

---

## 與現有框架的關係

`02-agent-design/01-operating-model-and-roles.md` 的四個門控（Spec Gate / Diff Gate / Exec Gate / Release Gate）是**流程**層面的人工介入點。

信任層級框架是**授權**層面的決策框架——它決定哪些操作需要觸發哪個門控，以及如何隨時間演進。

```
信任層級（授權）→ 門控設計（流程）→ 審查執行（操作）
         ↑
    TRiSM 框架（治理）覆蓋整個生命週期
```

---

## 操作手冊：新增 Agent 工作流的信任層級設定

1. 列出工作流中的所有 Agent 動作
2. 對每個動作，用四維度矩陣確定起始層級
3. 使用量化標準表驗證層級合理性
4. 在 Task Packet 的 `trust_tier` 字段中聲明
5. 配置對應的 Prompt Injection 防禦層（L1 最低要求）
6. 多 Agent 場景：為每個委托關係生成 delegation token
7. 設定晉升目標和評估週期
8. 每季度由 Agent Architect 審查層級配置

---

## 相關文章

- `02-agent-design/01-operating-model-and-roles.md` — 六角色模型與四個流程門控
- `03-engineering/agent-failure-taxonomy.md` — 各層級的失效模式分布
- `03-engineering/agentic-control-plane-design.md` — 信任層級是控制平面第 5 維度
- `03-engineering/04-playbook-risk-and-rollback.md` — 各層級的回滾策略
- `05-strategy/agent-native-org-roles.md` — 誰有權批准信任層級晉升（Agent Architect）

---

## 參考來源

- Gartner AI TRiSM Framework — Trust, Risk and Security Management for AI (2025–2026)
- OWASP Top 10 for LLM Applications 2025 — LLM01: Prompt Injection
- EU AI Act Articles 12, 14, 16 — High-Risk AI System Requirements (2026 Deadline)
- NIST AI Agent Standards Initiative — Software and AI Agent Identity and Authorization (Feb 2026)
- Microsoft Defense-in-Depth for Indirect Prompt Injection (2025)
- ISACA — The Looming Authorization Crisis: Why Traditional IAM Fails Agentic AI (2025)
- OpenID Foundation — Identity Management for Agentic AI (2025)
