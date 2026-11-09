---
auto_generated: true
generated_at: "2026-11-09T08:01:45Z"
source_url: "https://vercel.com/changelog/vercel-security-review-public-beta"
signal_type: "significant_update"
---
# Vercel Security Review 公测：push 即扫描、Agent 直接开修复 PR (Vercel Security Review Public Beta)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-09
>
> **项目/工具**: Vercel Security Review（Vercel Agent 驱动的代码安全审查）
> **链接**: https://vercel.com/changelog/vercel-security-review-public-beta
> **核心定位**: 把「安全扫描 → 定位 → 修复 PR」串成 push 后的自动闭环，安全审查第一次被塞进部署平台的默认工作流里

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Vercel 在其平台上推出的 Token 计费式 security review，每次 push 自动分析变更、由 Vercel Agent 给出修复并直接开 PR
- **现在值得用吗**：看場景——如果團隊代碼已托管在 Vercel 且 PR 流量大、又沒有專職 AppSec，值得一試；如果重度依賴其他 CI 或已有成熟 SAST 掃描鏈，先並行觀察
- **适合场景**：中小團隊的 Web 應用、高頻小 PR 的工作流、想降低「安全問題被 backlog 吃掉」概率的項目
- **不适合场景**：強合規要求場景（需自證掃描規則集與覆蓋率）、非 Web 技術棧、對第三方 AI 讀取代碼有硬性紅線的組織
- **与传统 SAST 工具核心差异**：傳統 SAST 只報警，Vercel 把「生成修補 PR」也做了，把安全工作從「發現問題」推到了「提交修復」

> ⚠️ 說明：本次上游 changelog 頁面預抓取與重抓均只拿到頁面骨架（Next.js 客戶端渲染），正文未能提取。以下分析中，凡是官方頁面未證實的內容均以「待確認」標註，請以官方 changelog 原文為準。

## 是什么 / 解决什么问题

長期以來，代碼安全工作流有個結構性問題：**掃描和修復之間有一道人工鴻溝**。SAST 工具（Snyk、Semgrep、GitHub Advanced Security 等）能發現問題，但修不修、誰來修、什麼時候修，全靠人排優先級。結果是安全問題報告年年增長，實際修復率卻不高——這是業界公認的 backlog 困境。

Vercel Security Review 的切入點是把這道鴻溝壓扁：在每次 push 時自動掃描變更內容，並由 Vercel Agent 直接生成修復補丁、開出 PR。開發者看到的不再是一份 JSON 報告，而是一個待審核的 pull request。

這種「發現 → 修復 → PR」的一體化設計，本質上把安全工作變成了一個**可被 review 的代碼產物**。這個思路在 AI agent 領域並不少見（GitHub Copilot Autofix、Google 的 CodeMender 都走類似方向），但由部署平台在 push hook 層默認觸發，是相對少見的位置選擇。

## 技术架构拆解

### 核心设计决策

- **觸發點選在 push，而非 merge 或定時掃描**：最小化曝光窗口——問題在進入主分支之前就被看到。代價是每次 push 都可能產生 token 消耗，需要對 monorepo 或高頻 push 做成本預期。
- **輸出形態是 PR，而不是 issue 或 dashboard 警報**：直接對齊開發者已有的 review 習慣，避免「警報疲勞」。
- **計價模型按 token 計費**：這是 AI Agent 產品的典型拍法——掃描範圍越大（diff 越大）成本越高。對比傳統 SAST 的「按 seat / 項目」訂閱，token 制更貼近實際算力消耗，但也讓成本預測變得困難。
- **公測期免費窗口**：據 changelog 摘要，11/10 之前免費。這意味著公測結束後將正式收費，需要提前評估用量。

### 与传统 SAST / 竞品的关键差异

| 維度 | 傳統 SAST（如 Snyk / Semgrep） | Vercel Security Review |
|------|------------------------------|------------------------|
| 觸發時機 | 定時掃描或 CI 步驟 | 每次 push 自動觸發 |
| 輸出形態 | 報告 / 儀表板 / issue | 修復 PR + 審查意見 |
| 修復執行者 | 開發者手工 | Vercel Agent 生成補丁 |
| 計價方式 | 訂閱制 / 按 seat | 按 token 消耗 |
| 依賴外部 CI | 是 | 否（內建在 Vercel 工作流） |
| 規則集透明度 | 高（可自定義規則） | 待確認（官方未公開規則細節） |

### 架构/信息流图

```
  developer git push
        │
        ▼
  ┌─────────────────────┐
  │ Vercel build trigger │
  └─────────┬───────────┘
            │ (并行)
            ├──────────────► build & deploy pipeline
            │
            ▼
  ┌─────────────────────────┐
  │ Security Review (Agent)  │
  │  1. diff / 变更文件分析   │
  │  2. 漏洞模式识别          │
  │  3. 生成修复补丁          │
  └─────────┬───────────────┘
            │
            ▼
  ┌─────────────────────────┐
  │ 开 PR (含修复 + 说明)     │
  └─────────┬───────────────┘
            │
            ▼
  人工 review → merge / 驳回
```

## 实用评估

### 什么场景值得用

- **小團隊 / 無專職 AppSec**：沒有安全工程師時，自動化修復 PR 能實質降低「知道有漏洞但沒人修」的概率。
- **高頻小 PR 的 Web 應用**：diff 小、審核快、Agent 修復建議的準確度和可 review 性都比較可控。
- **Vercel 原生託管項目**：零接入成本，無需維護 CI 配置或 API key。

### 什么场景不值得用

- **合規強約束場景（金融、醫療）**：這類組織通常要求掃描規則集可審計、誤報率可量化、供應商數據處理協議明確。Vercel 目前未公開足夠的規則和數據處理細節，待確認前不宜作為唯一防線。
- **成本敏感的大 monorepo**：token 計費 + 每次 push 觸發，在 diff 巨大、push 頻繁的倉庫裡成本可能失控。建議先在非核心倉庫試用，觀察帳單。
- **非 Vercel 部署的項目**：這是平台內建功能，離開 Vercel 沒有意義。
- **已有成熟 SAST + autofix 鏈路的團隊**：與 GitHub Advanced Security / Copilot Autofix 功能重疊度高，會增加噪音。

### 迁移成本

- **從無掃描到有掃描**：接近零（Vercel 項目開啟即可），但需觀察 token 帳單。
- **從現有 SAST 遷移到 Vercel Security Review**：不建議直接替換。SAST 的價值很大程度上在於規則集可自定義和誤報調優——這些能力在 AI agent 方案裡尚未被證明對等。建議並行運行 1-2 個月，對比檢出率。
- **團隊流程改造**：需要建立「安全 PR 的 review 準則」——即如何判斷 Agent 給的補丁是對的，這本身需要一定的安全知識儲備，是隐性學習成本。

## 对你的意义

Ken 的兩條線裡，這算是 **AI App 線（工程側）** 的一次方向性信號：「安全審查 agent 化」正在從獨立工具變成平台默認能力。

如果你的 Agent-Playbook 或其他 web 項目在 Vercel 上，建議：
1. **公測免費期（11/10 前）** 立刻開啟試一次，觀察輸出 PR 的質量——這是免費拿到的一次樣本採集；
2. 重點看兩件事：**誤報率**（Agent 報的漏洞有幾個是真實可利用的）和 **補丁正確率**（PR merge 的比例）；
3. 如果誤報率高，這個功能就只是噪音生成器，不建議長期啟用。

從更長遠看，這個方向值得放進「AI Agent 假設追蹤」觀察：當安全審查也被 agent 接管，工程師的核心價值更多轉向「判定 agent 判斷對不對」——這跟 Agentic Coding 的整體趨勢一致。

## 关键代码/配置片段

> TODO: 官方 changelog 正文未能提取，具體的開啟步驟、配置項與計費細節（如每 token 單價、免費額度上限）待官方頁面確認後補充。目前可確認的僅有：公測階段、push 觸發、Vercel Agent 生成修復 PR、按 token 計費。

---
[← Back to Deep Dives](./README.md)
