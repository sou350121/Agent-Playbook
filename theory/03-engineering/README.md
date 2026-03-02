# 03 — Agentic 工程實戰 (Agentic Engineering)

> 設計再好，不上線就等於零。
> 本模塊是 Agent-Playbook 的工程核心——三個並列支柱，覆蓋從架構決策到生產交付的完整鏈路。

---

## 本模塊定位

**這裡沒有概念，只有工程判斷**：護欄怎麼設、Context 怎麼注入、Eval 怎麼持續運行。

本模塊圍繞 Agentic Engineering 的**三大支柱**展開。三個都要，缺一不可：

```
支柱 A：護欄與安全   — 讓 Agent 安全工作
支柱 B：Context 工程  — 讓 Agent 能夠工作
支柱 C：評估與迭代   — 讓 Agent 持續提升
```

---

## 支柱 A：護欄與安全 (Guardrails & Safety)

### 架構護欄系列（必讀，按序）

Agentic 系統的五層護欄，防止 AI 自主執行造成破壞。

| 文件 | 層次 | 核心機制 |
|------|------|----------|
| `01-physical-rails.md` | L1：物理護欄 | 文件系統隔離、沙箱執行、資源限額 |
| `02-logical-contracts.md` | L2：邏輯契約 | API schema 約束、類型系統、不變量 |
| `03-process-governance.md` | L3：流程治理 | 審核門控、人工介入點、回滾策略 |
| `04-automated-enforcement.md` | L4：自動化執行 | CI/CD 集成、靜態分析、自動 gate |
| `05-adr-mind-palace.md` | L5：決策歸檔 | ADR 記憶宮殿——讓 Agent 繼承歷史決策 |

> **一句話核心觀點**：Agentic 系統不是「智能越高越安全」，而是「護欄越多越可靠」。

### 失效分類與控制平面

| 文件 | 核心問題 |
|------|----------|
| `agent-failure-taxonomy.md` 🆕 | Agent 失效的 6 種類型：如何識別、預防、恢復 |
| `agentic-control-plane-design.md` 🆕 | 控制平面的 6 個競爭維度：任務分解、Context 注入、可追溯性、回滾、審查、成本治理 |
| `trust-tier-design.md` 🆕 | 信任層級框架：哪些 Agent 動作需要人工審查，哪些可以自主執行 |
| `04-playbook-risk-and-rollback.md` | Agentic 系統風險矩陣與回滾設計 |
| `architectural-rails-for-ai-coding.md` | AI 編碼護欄總覽（支柱 A 的入口索引）|

---

## 支柱 B：Context 工程 (Context Engineering)

> Context Engineering 是 Agentic Engineering 的新基礎設施。你給 Agent 什麼、怎麼切任務包、怎麼維護 repo map——這決定了 Agent 能否可靠工作，比模型選擇更重要。

### Context 基礎設施

| 文件 | 核心問題 |
|------|----------|
| `context-engineering-field-guide.md` 🆕 | Context 工程完整指南：repo map 構建、AGENT_CONSTITUTION 設計、Context Packet 格式、長會話衰減對策 |
| `05-adr-mind-palace.md` | ADR 作為 Agent 的長期記憶（與支柱 A 共享）|

### Spec 驅動開發流程

| 文件 | 核心問題 |
|------|----------|
| `02-playbook-spec-to-pr.md` | PRD → Spec → Agent 執行 → PR 的完整流程設計 |
| `prd-for-engineers-and-agents.md` | 給工程師和 Agent 同時讀的 PRD 寫法 |
| `agentic-coding-doc-engineering.md` | Agentic 編碼中的文檔工程：讓 Agent 讀懂你的意圖 |
| `hybrid-docops-agentops-best-practices.md` | DocOps + AgentOps 混合實踐：文檔即代碼即 Agent 上下文 |
| `delegation-not-automation-engineering-principles.md` 🆕 | 委派 vs 自動化的工程原則：責任歸屬、可逆性設計、範圍邊界 |

### 組織與流程

| 文件 | 核心問題 |
|------|----------|
| `agentic-org-chart-design.md` | Agentic 組織架構：誰負責 Agent 的行為後果 |
| `10x-tactical-integrated-workflow.md` | 10x 工程師的戰術級 Agentic 工作流 |

---

## 支柱 C：評估與迭代 (Eval & Iteration)

> 沒有評估體系的 Agent 是盲飛。
> 區分：`06-agent-evals-playbook` = 如何**構建** eval 體系；`eval-loop-as-production-practice` = 如何**持續運行** eval 作為生產監控。

| 文件 | 核心問題 |
|------|----------|
| `06-agent-evals-playbook.md` | Agent 評估體系構建：代碼評估 / 模型評估 / 人工評估，能力 vs 回歸 |
| `eval-loop-as-production-practice.md` 🆕 | Eval 作為持續運維：CI 集成、Prompt 回歸檢測、部署門控、失效分級 |
| `05-ralph-loop-iteration-paradigm.md` | Ralph Loop：Reflect → Act → Learn → Plan → Hypothesize 迭代範式 |
| `ai-assisted-coding-adoption-metrics-and-governance.md` | AI 輔助編碼的採納度量與治理框架 |

---

## 基礎設施

| 文件 | 說明 |
|------|------|
| `00-glossary-for-beginners.md` | **所有人必讀**：Agentic 工程術語共識 |
| `ai_app_handbook_design.md` | Holograph 設計藍圖：完整 AI App 系統架構 |
| `architecture-README.md` | 架構模塊導覽 |
| `ai-native-debugging-vs-manual-profiling.md` | AI 原生調試 vs 傳統 Profiling 的效率比較 |

---

## Ralph Loop — Agentic 迭代的元框架

```
Reflect（反思當前狀態）
    ↓
Act（採取最小可測試行動）
    ↓
Learn（記錄結果，更新假設）
    ↓
Plan（根據新認知調整計劃）
    ↓
Hypothesize（提出下一個可偽證假設）
    ↑___________________________________↑
```

Ralph Loop 是本模塊所有工程實踐的元框架。任何 Agentic 系統的迭代都應能映射到這五個步驟。

---

## 推薦閱讀路徑

**新手**（安全優先）：
```
00-glossary → architectural-rails → 01-physical-rails → 02-logical-contracts
```

**交付工程師**（完整三支柱）：
```
context-engineering-field-guide → prd-for-engineers → 02-playbook-spec-to-pr
    → agent-failure-taxonomy → 05-ralph-loop → 06-agent-evals → eval-loop-production
```

**架構師**（系統設計）：
```
agentic-control-plane-design → trust-tier-design → delegation-not-automation
    → agentic-org-chart-design → ai_app_handbook_design
```

---

## Deep-Dive 文章（在本模塊）

以下是 Pulsar 自動分配到本模塊的工程深潛文章（`*_deep_dive.md`）：
- `anthropic_claude_deep_dive.md`
- `how_i_use_claude_code_separation_of_planning_and_execution_deep_dive.md`
- `open_webui_team_v083_deep_dive.md`
- `open_webui_v081_deep_dive.md`
- `bcachefs_llm_deep_dive.md`
- Microsoft AG-UI 協議系列（×4）

---

## 與其他模塊的關係

- **← 02-agent-design**：Agent 設計完成後，用本模塊的護欄和流程交付上線
- **← 04-paradigm**：範式轉變（如 Spec-first、Intent-driven）在這裡變成可執行工程實踐
- **→ 05-strategy/agent-native-org-roles**：本模塊的工程角色（Eval Engineer、Context Engineer）在策略模塊定義其人員結構
