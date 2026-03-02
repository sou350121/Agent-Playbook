# 知識骨架 (Theory)

> 工具會過時，框架會迭代，但底層的設計邏輯和認知模型是持久的。
> 本目錄不是操作手冊，而是幫你建立**工程判斷力**的基礎文獻庫。

---

## 六個認知模塊

```
01-principles/      底層原理     — 機器是如何「想」的
02-agent-design/    Agent 設計   — 如何設計穩定自主運行的 Agent
03-engineering/     工程實戰 ★  — Agentic 系統的生產交付全鏈路
04-paradigm/        範式轉變     — 識別正在發生的不可逆轉變
05-strategy/        戰略生存     — 工程師如何在 AI 時代定位與變現
06-frontier/        前沿研究     — 與工程最近的前沿突破
```

★ `03-engineering/` 是本目錄的**工程核心**，建議所有人重點閱讀。

---

## 時間座標：你在哪個層次工作？

基於 Karpathy 等人對 Agentic Engineering 的演化判斷，本知識庫的內容可以按時間維度定位：

```
下0（現在）  — 03-engineering ★
  └ 護欄設計、Spec 驅動交付、Eval Loop、Context Engineering
    這些是今天就要做的事，不做代價立即顯現。

下1步（12-24月）— 04-paradigm + 03-engineering 進階
  └ 工程方法論協議化：控制平面設計、委派 vs 自動化邊界、
    Eval 作為生產運維實踐、失效分類學習閉環。

下2步（24-48月）— 05-strategy + 06-frontier
  └ 組織重構：Agent Architect、Eval Engineer、Context Engineer
    等新角色出現；軟體開始為 Agent 設計（Agent UI/API）。
```

閱讀時請帶著這個問題：「我今天需要這個，還是在為 6 個月後做準備？」

---

## Agentic Engineering 三大支柱（下0核心）

`03-engineering` 圍繞三個並列的工程支柱展開：

```
支柱 A：護欄與安全
  物理護欄 → 邏輯契約 → 流程治理 → 自動化執行 → ADR 記憶
  + 失效分類（agent-failure-taxonomy）
  + 信任層級（trust-tier-design）

支柱 B：Context 工程
  Spec-to-PR → DocOps + AgentOps → ADR 記憶宮殿
  + Context Engineering Field Guide（新）
  + Diff-Based Workflow 生產模式

支柱 C：評估與迭代
  Agent Evals Playbook（一次性構建）
  + Eval Loop as Production Practice（持續運維）（新）
  Ralph Loop → 採納度量與治理
```

沒有哪個支柱比另外兩個更重要。三個都要。

---

## 三條閱讀路徑

### 路徑 A — 新手（建立安全第一的基礎認知）

```
01-principles/latent-space-reasoning
    ↓
01-principles/agent-mental-model          ← 「工程師是管理者」的思維轉換
    ↓
03-engineering/00-glossary-for-beginners  ← 術語共識（必讀）
    ↓
03-engineering/01-physical-rails ～ 04-automated-enforcement  ← 護欄系列
    ↓
02-agent-design/agent-interaction-roles   ← 有了護欄，才學設計
```

**關鍵原則**：先理解安全邊界，再學設計自由度。Agentic 系統從第一天就要有護欄。

---

### 路徑 B — 工程師（Agentic 系統生產交付）

```
03-engineering/prd-for-engineers-and-agents
    ↓
03-engineering/context-engineering-field-guide    ← Context 是生產前提（新）
    ↓
03-engineering/02-playbook-spec-to-pr
    ↓
03-engineering/agent-failure-taxonomy             ← 失效分類（新）
    ↓
03-engineering/05-ralph-loop-iteration-paradigm
    ↓
03-engineering/06-agent-evals-playbook
    ↓
03-engineering/eval-loop-as-production-practice   ← Eval 作為運維（新）
    ↓
02-agent-design/01-operating-model-and-roles      ← 信任層級與委派治理
```

**目標**：能設計、交付並持續運維一個生產級 Agentic 系統（三支柱都到）。

---

### 路徑 C — 研究者 / 決策者（判斷方向，佈局未來）

```
04-paradigm/not-designing-for-humans-paradigm   ← 先理解 Agent 是一等公民
    ↓
04-paradigm/anthropic-agentic-coding-trends-2026
    ↓
01-principles/post-scaling-research-age-playbook
    ↓
06-frontier/1x-world-model-paradigm
    ↓
05-strategy/agent-native-org-roles              ← 組織如何演化（新）
    ↓
05-strategy/intelligence-arbitrage-strategy
```

**目標**：判斷下一個技術和組織轉折點，提前佈局。

---

## deep-dive/ 在學習架構中的角色

Auto-generated deep-dives（週二/四/六）現在分佈在各模塊中（以 `_deep_dive.md` 結尾）。

**使用方式**：當某個前沿話題出現在 deep-dive 文章中，說明它正在從「研究方向」升級為「工程優先級」。把 deep-dive 文章當作信號，而不是文檔。

搜索最新 deep-dive：`find theory/ -name "*_deep_dive.md" | sort -r | head -5`

---

## 寫作規範（新增文章）

新增 theory/ 文檔須遵循 [AGENTS.md](../AGENTS.md) §6 規範：

- 雙語標題：`# 中文標題 (English Title)`
- 必須包含 **X-Ray 開場**（2-3 句：什麼問題 / 什麼發現 / 為何重要）
- 引用需鏈接原始來源（論文 / 官方文檔優先）
- 推薦包含：系統對比表、工程實戰示例、失效模式分析
