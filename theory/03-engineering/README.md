# 03 — Agentic 工程實戰 (Agentic Engineering)

> 設計再好，不上線就等於零。
> 本模塊是 Agent-Playbook 的工程核心——從架構決策到生產交付的完整鏈路。

---

## 本模塊定位

**這裡沒有概念，只有工程判斷**：
- 如何在 Agentic 系統中建立護欄，避免 AI 自主執行造成破壞？
- 如何設計評估體系，讓迭代有方向？
- 如何管理 spec → PR → review → deploy 的完整 Agentic 開發流程？

本模塊對應 Pulsar 系統「Playbook 驅動的工程實踐」——每篇都有可操作的具體步驟。

---

## 文章索引

### 架構護欄系列（必讀，按序）

這是一個完整的五篇系列，描述如何為 Agentic 系統建立多層護欄，防止 AI 編碼錯誤蔓延。

| 文件 | 層次 | 核心機制 |
|------|------|----------|
| `01-physical-rails.mdx` | L1：物理護欄 | 文件系統隔離、沙箱執行、資源限額 |
| `02-logical-contracts.mdx` | L2：邏輯契約 | API schema 約束、類型系統、不變量 |
| `03-process-governance.mdx` | L3：流程治理 | 審核門控、人工介入點、回滾策略 |
| `04-automated-enforcement.mdx` | L4：自動化執行 | CI/CD 集成、靜態分析、自動 gate |
| `05-adr-mind-palace.mdx` | L5：決策歸檔 | ADR 記憶宮殿——讓 Agent 繼承歷史決策 |

**一句話核心觀點**：Agentic 系統不是「智能越高越安全」，而是「護欄越多越可靠」。

---

### Agentic 開發流程

| 文件 | 核心問題 |
|------|----------|
| `02-playbook-spec-to-pr.mdx` | PRD → Spec → Agent 執行 → PR 的完整流程設計 |
| `prd-for-engineers-and-agents.mdx` | 給工程師和 Agent 同時讀的 PRD 寫法 |
| `agentic-org-chart-design.mdx` | Agentic 組織架構：誰負責 Agent 的行為後果 |
| `10x-tactical-integrated-workflow.mdx` | 10x 工程師的戰術級 Agentic 工作流 |
| `agentic-coding-doc-engineering.mdx` | Agentic 編碼中的文檔工程：讓 Agent 讀懂你的意圖 |
| `hybrid-docops-agentops-best-practices.mdx` | DocOps + AgentOps 混合實踐：文檔即代碼即 Agent 上下文 |

---

### 評估與迭代

| 文件 | 核心問題 |
|------|----------|
| `06-agent-evals-playbook.mdx` | Agent 評估體系：不是測試準確率，而是測試自主行為質量 |
| `05-ralph-loop-iteration-paradigm.mdx` | Ralph Loop：Reflect → Act → Learn → Plan → Hypothesize 迭代範式 |
| `04-playbook-risk-and-rollback.mdx` | Agentic 系統風險矩陣與回滾設計 |
| `ai-assisted-coding-adoption-metrics-and-governance.mdx` | AI 輔助編碼的採納度量與治理框架 |

---

### 基礎設施與效能

| 文件 | 核心問題 |
|------|----------|
| `00-glossary-for-beginners.mdx` | 進入 Agentic 工程的術語共識（所有人都必讀）|
| `ai_app_handbook_design.md` | Holograph 設計藍圖：完整 AI App 系統架構 |
| `architecture-README.mdx` | 架構模塊導覽 |
| `architectural-rails-for-ai-coding.mdx` | AI 編碼的架構護欄總覽 |
| `agentic-data-analysis-best-practices.mdx` | Agentic 數據分析：讓 Agent 安全查詢和解釋數據 |
| `ai-native-debugging-vs-manual-profiling.mdx` | AI 原生調試 vs 傳統 Profiling 的效率比較 |
| `ai-native-languages.mdx` | AI 原生編程語言的設計方向 |

---

## Ralph Loop — Agentic 迭代的核心範式

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

## 推薦閱讀順序

**入門**：
```
00-glossary-for-beginners → architectural-rails-for-ai-coding → 01-physical-rails → 02-logical-contracts
```

**進階交付**：
```
prd-for-engineers-and-agents → 02-playbook-spec-to-pr → 04-playbook-risk-and-rollback → 06-agent-evals-playbook
```

**精通迭代**：
```
05-ralph-loop-iteration-paradigm → 10x-tactical-integrated-workflow → ai_app_handbook_design
```

---

## 與其他模塊的關係

- **← 02-agent-design**：Agent 設計完成後，用本模塊的護欄和流程交付上線
- **← 05-strategy**：本模塊是「策略」落地到「代碼」的橋樑
- **→ deep-dive/**：深潛文章的許多案例分析都源自本模塊的工程問題
