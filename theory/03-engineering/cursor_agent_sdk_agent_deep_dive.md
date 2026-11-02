---
auto_generated: true
generated_at: "2026-11-02T05:45:39Z"
source_url: "https://cursor.com/blog/agent-sdk"
signal_type: "significant_update"
---
# Cursor Agent SDK：把 Agent 定義為程式碼，一條命令部署到自己的基礎設施 (Cursor Agent SDK: Agents as Versioned Code)

> 🔍 本文由 Moltbot 自動生成 | 2026-11-02
>
> **項目/工具**: Cursor Agent SDK（`@grok/agent-sdk`，前身 `@cursor/bdk`）
> **連結**: https://cursor.com/blog/agent-sdk
> **核心定位**: 把 Cursor 自己用來造 Bugbot / Security Reviewer / Rollouts 的 agent harness 開源成一套 SDK——prompt 是 Markdown、工具是 TypeScript、eval 與事件回放內建，跑在 Cursor 託管基礎設施或你自己的 Node 容器裡。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Agent = 一個可版控的軟體專案（Markdown 指令 + TS 工具 + eval），而不是後台裡的一組設定欄位。
- **現在值得用嗎**：看場景——如果你的 agent 要跑在 PR、issue tracker、Slack 這類「事件觸發 + 需要可審查策略」的工作流上，值得立刻試。
- **適合場景**：PR 風險評估與自動審批、合規/知識庫一致性檢查、incident 初篩、需要 eval 才能安心上線的關鍵工作流。
- **不適合場景**：只是想「聊天式」配置一個定時任務（用 Cursor Automations 更快）、需要多語言非 Node 運行時、或無法接受模型呼叫走 Cursor 路由的團隊。
- **與 Cursor Automations / Grok Bot 核心差異**：Automations 你在 dashboard 填 prompt+model+trigger，Bot 在 app 裡點；Agent SDK 整個 agent 是版本化程式碼，可 review、可跑 eval、可自架。

## 是什麼 / 解決什麼問題

過去兩年，「做一個團隊專屬 agent」只有兩條不太好走的路：一是買一個別人設計好工作流的產品，把自己的流程塞進別人的框裡；二是從零自己寫 loop、工具調度、重試、審計與 eval 一整套，往往還沒上線就寫成了一個小框架。

Cursor 這次的賭注是：他們自己內部造 Bugbot、Security Reviewer、Rollouts 用的那套 harness（跑模型迴圈、接工具、管 session、接 MCP、跑 eval、管 secret、做沙箱、負責部署）其實已經成熟到可以直接商品化。Agent SDK 就是把這套東西的「外殼」交出來，你只寫業務那一層：

> "You write the instructions and tools, and Cursor runs the model loop that calls them."（Cursor Docs, Agent SDK）

所以它解決的核心痛點不是「agent 能力不夠強」，而是**工程治理**：誰能改這個 agent 的行為？改了之後怎麼證明沒壞？它現在跑在誰的機器上？——文件把答案寫得很直白：你的指令、工具、eval 都是檔案，跟其他程式碼一樣被 review、測試、版控。

官方給的最具體成效案例來自 Cursor 內部團隊：他們把一份快速膨脹的「lessons learned」知識庫做成 `kb-reviewer`，**約一天完成**，現在跑在主程式庫的每個 PR 上，會標出與已記錄教訓相衝突的變更，並引用對應的那則筆記（來源：官方 blog）。

## 技術架構拆解

### 核心設計決策

- **Prompt 用 Markdown，工具用 TypeScript**：把「模型判斷」與「確定性程式碼」放在同一個檔案樹裡，而不是混在一段巨型 prompt 裡。文件稱之為 "combines deterministic code with model judgment"。
- **Harness 分層留給平台**：Source control / issue tracker / Slack 觸發、model routing、evals、MCP 連線、sessions 與模型迴圈、subagents 與 tool calls、secret 管理、沙箱、部署、artifact 儲存，全部由 Cursor 那側負責。你只提供 agent 定義。
- **Eval 與 event replay 是一等公民**：這是整個產品最關鍵的差異化。沒有 replay，agent 的行為變化無法歸因；沒有 eval，prompt 一改就只能靠感覺。
- **雙部署模式**：`agent-sdk deploy` 一條命令建置、給 URL、跑在 Cursor 基礎設施上；也可以自架——**每個 agent 就是一個 Node 進程，可打包成容器**。
- **Agent 可以調 agent**：複雜任務可交給另一個帶自己工具與 session 的專用 agent，或拆給並行 subagent。
- **附帶 skills 引導**：SDK 自帶 skills，可以讓 coding agent 讀文件、陪你一起把 bot 搭出來——本質上是「用 agent 造 agent」。

### 與前版 / 競品關鍵差異

| 維度 | Cursor Automations | Grok Bot | Agent SDK |
|------|--------------------|----------|-----------|
| 你定義什麼 | dashboard 上的 prompt + model + trigger | app 裡配置的指令、skills、工具 | 版本化的 Markdown + TypeScript 專案 |
| 執行位置 | Cursor 託管 | Cursor 託管 | Cursor 託管 **或** 自有基礎設施 |
| 選擇時機 | 任務剛好符合某個排程/事件觸發 | 想配置並對話，不想寫程式 | 模型判斷外圍需要可版控、可 review、可測試、可持續爬坡的程式碼 |
| 可測試性 | 有限 | 有限 | evals + event replay 內建 |
| 可審查性 | 低（配置散在後台） | 低 | 高（走同一套 code review 流程） |

對照組若換成「自己手寫 loop」：SDK 直接把 harness、沙箱、secret 管理、MCP 連接與部署都吞掉；代價是你綁定 Cursor 的模型路由與其 agent 抽象。

### 架構 / 資訊流

```
            ┌───────────────────────────────────────────────┐
            │ 你的 agent 專案（版控 / code review）           │
            │  instructions/*.md   tools/*.ts   evals/*       │
            └───────────────────────┬───────────────────────┘
                                    │ agent-sdk deploy
                  ┌─────────────────┴──────────────────┐
                  ▼                                    ▼
        ┌───────────────────┐                ┌────────────────────┐
        │ Cursor 託管基礎設施 │                │ 自架：單一 Node 進程 │
        │ 自動獲得 URL       │                │ 打包成容器           │
        └─────────┬─────────┘                └──────────┬─────────┘
                  └──────────────┬───────────────────────┘
                                 ▼
        ┌──────────────────────────────────────────────────────┐
        │ Harness：觸發(GitHub/GitLab/Bitbucket PR、issues、     │
        │ Slack) → model routing → session/模型迴圈 →            │
        │ subagents & tool calls → MCP 連線 → secret/沙箱 →      │
        │ logs / evals / event replay / playground               │
        └──────────────────────────────────────────────────────┘
```

一個典型 PR reviewer agent 的資料流：PR 事件進來 → agent 拉取 diff 與倉庫內的 lessons 筆記 → 模型判斷哪幾處衝突 → 工具回寫 comment 並附引用 → 依 policy 決定 approve / route 給正確團隊 → eval 與 replay 記錄全過程供日後 hillclimb。

## 實用評估

### 什麼場景值得用

- **策略需要被看懂的審批流**：文件舉的例很好——PR 分類風險、路由到對的團隊、符合 policy 的自動 approve。重點是 policy 是「團隊能檢查、能改」的程式碼，不是黑盒。
- **有沉澱知識庫的團隊**：`kb-reviewer` 模式（讓每個 PR 對照歷史決策）是可複製的模板，一天內可落地。
- **需要 eval 才能上生產的關鍵工作流**：PGA America 用它把整個「軟體工廠」建在 Cursor 基礎設施上，其 Principal Engineer Michael Gyarmathy 明確表示「built-in support for evals allows us to quickly iterate」。
- **已經在用 Cursor、且想要自架**：Node 單進程 + 容器化，對有既成 K8s/容器平台的團隊門檻很低。

### 什麼場景不值得用

- **單純排程型任務**：如果用 Cursor Automations 就能用 prompt + trigger 解決，套 SDK 只是為了寫程式而寫程式。
- **非 Node 技術棧**：目前文件明確描述為單一 Node 進程；Python/Go 團隊要嘛包外殼、要嘛等官方支援（待確認）。
- **模型路由必須完全自控的場景**：你寫的是工具與指令，模型迴圈由 Cursor 跑；對模型版本、供應商有硬性合規要求的組織需先確認自架模式下模型呼叫路徑（`> TODO: 自架模式是否仍強制經 Cursor 的 model routing，官方文件未明示`）。
- **成本不透明的早期採用**：官方 blog 與文件頁均未公開計價與配額限制（`> TODO: pricing / rate limit 未見公開來源`），大量 subagent 並行前建議先小規模量測。

### 遷移成本

- **從 Cursor Automations 過來**：官方提供 `Convert a Cursor Automation` 指南，屬於有明確路徑的遷移，工作量主要在把後台配置拆成 Markdown 指令 + TS 工具。
- **從自寫 agent 過來**：主要是把自家 loop、重試、審計日誌換成 harness，並補上 eval 集；工具層（TS 函數）大多可保留，工作量取決於原本 prompt 與工具耦合的程度。
- **注意套件改名**：安裝的是 `@grok/agent-sdk`，**該套件之前叫 `@cursor/bdk`**——網上舊教學與舊 import 路徑會直接失效。

## 對你的意義

對你在做的 Agent + UI 與 RAG 工具鏈方向，這篇的價值不在「又一個 agent 框架」，而在它把三個常被忽略的工程約束寫成了產品介面：

1. **Eval / replay 從第一天就在**。你的 RAG pipeline 若要上生產，這正是最缺的一塊——可以借它的思路（replay 事件 + eval 集版本化），即使不用它的 runtime。
2. **Prompt 與工具的檔案分離**。把確定性邏輯從 prompt 裡剝出來，是讓 agent 可測試的前提；這個結構值得直接抄進你自己的 repo 佈局。
3. **審批流 = 權限 + 政策可審查**。與同期企業 agent 往「按權限執行工作流」走的趨勢一致，UI 層會成為差異化戰場。

具體建議：**觀望一到兩週再試**，但現在就值得做的事是——用 `kb-reviewer` 的思路，把你自己的 handbook / lessons 做成一個 PR 檢查 agent 的原型，驗證「知識庫 → 自動審查」這條鏈在你的場景是否有實際收益。若驗證有效，再決定是用 Cursor 託管還是自架。

## 關鍵程式碼 / 配置片段

最小 agent 定義（來源：官方 blog，原文範例）：

```ts
import { homedir } from "node:os";
import { join } from "node:path";
import { defineAgent } from "@cursor/agent-sdk";

export default defineAgent({
  name: "Robo",
  model: {
    id: "composer-2.5",
    params: [
      { id: "effort", value: "high" },
      { id: "fast", value: "true" },
    ],
  },
  local: {
    cwd: join(homedir(), ".cache", "factory", "robo"),
  },
});
```

啟動與部署：

```bash
# 安裝（注意：套件曾名為 @cursor/bdk）
npm install @grok/agent-sdk

# 本地 playground 迭代 → 跑 eval → 部署
agent-sdk deploy
```

> 注意：blog 範例 import 路徑為 `@cursor/agent-sdk`，而 docs 頁寫安裝 `@grok/agent-sdk`。兩者不一致，實作前請以 docs 為準並確認實際 package 名（`> TODO: 官方 package 命名來源待確認`）。

## 📌 AI Agent 假設追蹤

| 假設 | 方向 | 關聯說明 |
|------|------|----------|
| A-002: Agentic Coding 在初級任務達 80% 成功率 | 支持 | Cursor 內部團隊用 Agent SDK 約一天做出可跑全倉庫 PR 的 `kb-reviewer`，並由官方作為案例公開，說明 PR 級（初級）編碼審查任務已可用於生產 |

---
[← Back to Deep Dives](./README.md)
