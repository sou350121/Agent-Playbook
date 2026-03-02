# 智慧提純：Agent 管理學的興起——從指令到治理的範式遷移

> **信號**：隨著 Agent 進入複雜工程領域，單點的 Prompt 工程已顯疲態。我們需要一套像管理「人類組織」一樣的治理框架。

---

## 🚀 提純後的核心觀察

### 1. 從「魔法指令」到「物理導軌」
過去我們追求寫出「完美的提示詞」，現在我們追求構建「完美的執行軌道」。Agent 管理學的本質是：**用確定的流程（SOP）去約束不確定的模型行為**。

### 2. 角色分工的必要性
讓一個 Agent 同時扮演 PM、架構師、碼農和測試是不科學的。我們需要將其拆解為 **Commander, Planner, Implementer, Reviewer, Guard, Runner**。角色邊界越清晰，熵增就越慢。

### 3. 門禁 (Gates) 是安全之源
不具備回滾能力的 Agent 就像沒有剎車的賽車。Spec Gate、Exec Gate 和 Release Gate 是防止 Agent 在代碼庫中「裸奔」的核心防線。

---

## 💡 給實踐者的啟示

1.  **建立你的 Playbooks**：不要每次都重新教 Agent 怎麼做。將成熟的工作流沉澱為 SOP（如：Spec → PR 流程）。
2.  **先驗證後執行**：所有任務必須先有可驗證的驗收標準（Acceptance Criteria）。
3.  **隔離與審計**：讓 Agent 在受控環境下執行，並保留完整的審計日誌。

---

詳細治理方案見庫中新模組：
- **[Agent 管理學總覽](../../cognition/methodology/agent-management/README.md)**
- **[01 組織模型與角色分工](../../cognition/methodology/agent-management/01-operating-model-and-roles.md)**
- **[02 Playbook：從 Spec 到 PR](../../cognition/methodology/agent-management/02-playbook-spec-to-pr.md)**
- **[04 Playbook：風險治理與回滾](../../cognition/methodology/agent-management/04-playbook-risk-and-rollback.md)**
