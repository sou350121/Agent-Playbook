# Agent 失效分類學速查 · T1-T7

> 🧠 速查版 · 完整理論見 [theory/03-engineering/agent-failure-taxonomy.md](../theory/03-engineering/agent-failure-taxonomy.md)
> 📎 來源：Karpathy "Agentic Engineering" (2025-2026) + MAST 多 Agent 失效分類學研究 ([arXiv:2503.13657](https://arxiv.org/abs/2503.13657))

---

## 🚨 速查總表

| 類型 | 中文名 | 英文 | 嚴重 | MAST 對應 |
|------|--------|------|:---:|-----------|
| **T1** | 範圍洩漏 | Scope Leak | 高 · 難溯源 | FC1: FM-1.2 |
| **T2** | 上下文漂移 | Context Drift | 高 · 靜默 | FC1: FM-1.4 |
| **T3** | API 契約誤讀 | API Contract Misread | 中 · 可測 | FC1: FM-1.1 |
| **T4** | 邊界條件缺失 | Boundary Condition Gap | 中 · 可測 | FC3: FM-3.2 |
| **T5** | 語義回歸 | Semantic Regression | 高 · 最難測 | FC3: FM-3.3 |
| **T6** | 多 Agent 鏈式失效 | Multi-Agent Cascade | 極高 · 鏈回滾 | FC2: FM-2.3/2.5 |
| **T7** | 跨 Agent 上下文污染 | Cross-Agent Context Pollution | 極高 · 全鏈污染 | FC2: FM-2.4/2.6 |

📎 **MAST 研究關鍵數據**：1600+ trace 系統分析顯示——
- **41-86.7%** 多 Agent 系統存在失效
- **79%** 問題源自規格設計而非模型能力
- **FC2（Agent 間對齊失效）** 是最大單一失效來源

---

## 🔴 T1 · 範圍洩漏（Scope Leak）

**定義**：Agent 修改/讀取/影響了 Task Packet `scope.out` 明確排除的文件或系統。

**症狀**：
- diff 出現不在 `scope.in` 的文件
- 其他模塊 test 開始無故失敗

**根因**：Task Packet 未明確 `scope.out` · Agent「順手」修改 · 工具無路徑限制

**預防**：
- Task Packet 強制 `scope.out`
- 物理護欄：文件系統沙箱
- 最小特權：Agent 只訪問當前 task 授權路徑

**恢復**：回滾 `scope.in` 之外的 diff

---

## 🔴 T2 · 上下文漂移（Context Drift）

**定義**：長會話中 Agent 逐漸忘記早期約束、格式要求、決策。

**症狀**：
- 輸出格式中途改變（JSON → 自由文本）
- Agent 採用早期已被否決的方案

**根因**：tool call 結果擠出早期約束 · 無 Checkpointing · 大任務沒拆分

**預防**：
- Context Refresh：每 N 輪重新注入 AGENT_CONSTITUTION
- Checkpointing：交付點要求重述當前約束
- Ralph Loop 拆解大任務為短 packets

**恢復**：從最近 Checkpoint 重啟，新會話重灌 constitution

---

## 🔴 T3 · API 契約誤讀（API Contract Misread）

**定義**：Agent 錯誤理解工具/API 的 schema → 調用失敗或靜默產錯。

**症狀**：
- schema validation error
- 構造請求缺必填字段 / 把 null 當空數組

**根因**：API 文檔不在 context · 版本變了用舊 schema · 工具非 Agent-friendly

**預防**：
- Task Packet `context_refs` 引用 API 文檔
- 工具設計：結構化輸出 + 明確 error
- 邏輯護欄：工具層 schema validation

**恢復**：提供正確 schema → 重試 · 反覆失敗 → 升級人工

---

## 🔴 T4 · 邊界條件缺失（Boundary Condition Gap）

**定義**：Spec 未覆蓋的 edge case，Agent 靜默跳過或用錯誤默認處理。

**症狀**：
- 特定輸入導致空輸出 / 通用 fallback
- 測試覆蓋只有 happy path

**根因**：PRD 未思考 edge case · Agent 接受模糊規格未提問 · 驗收標準只有正常路徑

**預防**：
- PRD 強制「已知 edge case」章節
- Spec Gate：執行前對每個不確定點提問
- Eval 包含邊界 case 測試

**恢復**：補規格 → 補執行 / 已上線觸發回滾

---

## 🔴 T5 · 語義回歸（Semantic Regression）

**定義**：修改通過所有自動化測試，但破壞了代碼/系統的**語義意圖**（行為變了，測試不知道）。

**症狀**：
- CI 全綠，但人工 review 發現異常
- 「接近但不完全符合」預期
- 用戶感知行為變化但難用測試描述

**根因**：測試覆蓋實現細節非業務意圖 · Agent 找到繞過測試的最短路徑 · Acceptance Criteria 過於技術化

**預防**：
- Acceptance Criteria 必須含行為描述
- Model-based eval（LLM 評估語義正確性）
- 人工 review 是最後防線（不可被 CI 完全替代）

**恢復**：回滾 → 重寫 AC 含語義測試 → 加 regression test → 重新委派

---

## 🔴 T6 · 多 Agent 鏈式失效（Multi-Agent Cascade）

**定義**：上游 Agent 錯誤輸出被下游當正確輸入 → 錯誤在鏈中**指數放大**。

**症狀**：
- 最終質量遠低於單個 Agent 能力
- 追溯 trace 發現錯源來自鏈早期
- 中間 Agent 輸出無驗證直接傳遞

**根因**：Agent 間無輸出驗證 · 流水線無中間 Checkpoint · 失敗被設計為「繼續執行」而非「停止報告」

**預防**：
- 每個 Agent 輸出強制 schema validation 才能傳遞
- 關鍵節點插入 Reviewer Agent（獨立驗證，不執行）
- Fail-fast：任何失敗 → 整鏈停止

**恢復**：從失效點重啟（非從起點） · 鏈式 Rollback

---

## 🔴 T7 · 跨 Agent 上下文污染（Cross-Agent Context Pollution）

> **這是 T6 的進化版本**：T6 是可觀測的「執行錯誤」傳遞；T7 是不可觀測的「語義錯誤」傳遞——數據形式合法，內容是虛構的。

**定義**：Agent A 的幻覺輸出（fabricated facts/schemas/API names）被 Agent B 當作有效事實使用 → 錯誤在多 Agent 系統中被「固化」為基礎假設。

**症狀**：
- Agent B 引用了 Agent A 從未真正調用過的 API/文件
- 輸出「邏輯自洽」但與外部事實對不上
- 各 Agent 本地 trace 看起來正常，但端對端輸出失真

**典型示例**：
```
Researcher Agent → 幻覺 "論文 X 用 LoRA rank=64"
                ↓ 無驗證傳遞
Writer Agent → 寫進文檔「X 最佳配置 rank=64」
                ↓ 無溯源追蹤
Publisher Agent → 發布至知識庫
                ↓ 後續 RAG 引用源
                錯誤自我強化
```

**根因**：
- Agent 間無 handoff contract（無 producer/consumer schema）
- Downstream 不區分「已驗證事實」與「上游推斷」
- 中間結果無 provenance（溯源標記）

**預防**：
1. **顯式 Handoff Contract**：每個輸出必含 `confidence` + `source_type`（verified / inferred / hallucinated_risk）
2. **Downstream 消費規則**：`confidence < 0.7` 或 `source_type != "verified"` 必須先外部驗證
3. **溯源標記透傳**：provenance 不得丟失，任何 Agent 不得「淨化」上游不確定性
4. **幻覺防火牆 Agent**：在關鍵 handoff 插入 Fact-Check Agent

**恢復**：追溯首次幻覺節點 → 從該節點重啟並要求可驗證來源 → 標記下游所有依賴條目為「待審查」

---

## 🎯 Debug 決策樹

```
Agent 行為異常
│
├─ 修改了不該修改的 → T1 範圍洩漏
│
├─ 長會話中違反早期約束 → T2 上下文漂移
│
├─ tool call schema error / 字段錯誤 → T3 API 契約誤讀
│
├─ 特定輸入靜默跳過 → T4 邊界條件缺失
│
├─ 測試全綠但行為錯 → T5 語義回歸
│
├─ 多 Agent 鏈中：錯誤從上游放大下來 → T6 鏈式失效
│
└─ 多 Agent 鏈中：邏輯自洽但事實錯 → T7 上下文污染
```

---

## 📐 級聯放大三加速因子

📎 為什麼多 Agent 系統的錯誤是**指數級**而非線性傳遞：

1. **置信度繼承**：下游繼承上游高置信度，錯誤被當確定事實
2. **驗證缺失**：每個 Agent 假設上游「已驗證」，無人做全局一致性
3. **上下文隔離**：各 Agent 只看自己 I/O，無法感知整鏈方向偏移

**對抗原則**：
- **Skeptical Consumer**：下游默認懷疑，必須能解釋「為什麼接受這個輸出」
- **全局目標回歸**：每個 Agent 輸出前對照原始 Task Goal 做漂移檢查
- **中間態可觀測**：所有 handoff payload 可被外部監控審計

---

## 📚 延伸閱讀

- 📎 [完整理論：agent-failure-taxonomy.md](../theory/03-engineering/agent-failure-taxonomy.md) · 含預防矩陣 + 故障響應 SLA + 學習閉環
- 📎 [trust-tier-design.md](../theory/03-engineering/trust-tier-design.md) · 信任分層降低 T1/T6 風險
- 📎 [delegation-not-automation.md](../theory/03-engineering/delegation-not-automation-engineering-principles.md) · Task Packet 是最小委託合同
- 📎 [eval-loop-as-production-practice.md](../theory/03-engineering/eval-loop-as-production-practice.md) · T4/T5 eval 防線
- 📎 [MAST 論文 arXiv:2503.13657](https://arxiv.org/abs/2503.13657) · Multi-Agent Failure Taxonomy
- [Eval](./evaluation.md) · 怎麼 eval 這些失效
- [Frameworks](./frameworks.md) · 哪些框架支援 retry / fallback / handoff contract

---

[← Back to Cheat Sheet](./README.md)
