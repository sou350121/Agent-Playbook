# AI應用開發知識系統整體設計

> 一套以「可自我修正的資訊獲取—沉澱—推理—調參閉環」為核心的AI應用開發基礎設施。

---

## 系統是什麼

一個開發者進入AI應用開發領域,面對的根本問題是:每天有大量新工具、新API、新框架、新應用案例湧入,但能花在追蹤上的時間極少。看了等於沒看,沒累積就沒複利。

這套系統解決的問題是:**讓資訊自動變成知識,讓知識可查詢、可推理、可累積。**

它由三個部件組成:

| 部件 | 角色 | 實體 |
|------|------|------|
| **Moltbot** | 生產者 — 每天收集、過濾、判讀、寫入 | AI agent + cron 任務 |
| **Handbook** | 累積者 — 版本控制的結構化知識庫 | GitHub repo |
| **你** | 消費者 + 深度生產者 — 查詢、閱讀、撰寫深度筆記 | Telegram + Cursor + 手寫 |

---

## 核心設計思想

### 1. 信號與資產分離

```
Telegram = 信號(讀完即棄)
Handbook = 資產(三年後還能查到)
```

Moltbot 每天推送到 Telegram 的日報和情報是「信號」——讓你花 2 分鐘掌握今天發生了什麼:哪個AI工具更新了、哪個API有breaking change、哪個應用上線了。但信號的壽命很短,滑過去就沒了。

同一批資訊,Moltbot 同時寫入 Handbook 的索引文件。這才是「資產」——有版本控制、有分類結構、能被搜索、能被未來的推理任務讀取。

你不需要從 Telegram 裡「記住」什麼。你只需要知道:Handbook 裡有。

### 2. Push 轉 Pull

早期設計是 push 架構:Moltbot 把一切推到 Telegram,你被動接收。問題是資訊量一大就成噪音。

成熟設計是 pull 架構:Moltbot 像圖書館員,每天把新工具/應用分類上架(寫入 Handbook)。你需要的時候去書架上找(用 Cursor 或 GitHub 搜索查詢)。Telegram 只在有高價值信號時才響。

### 3. 人寫深度,機器寫廣度

Handbook 裡有兩種內容,不混淆:

- **人寫的**(✍️):深度實作、代碼拆解、架構洞察。少但精,是知識庫的骨架。
- **機器寫的**(📱📊📝):應用索引、雙週報告、工具分析摘要。多但淺,是知識庫的肉。

Moltbot 永遠不觸碰人寫的文件。它只追加索引條目和創建報告文件。

### 4. Prompt 靜態,Memory 動態

所有任務的 prompt 部署後不再修改。可變參數(關鍵詞、RSS 優先級、搜索詞)全部存在 `active-config` memory 中,由自我進化任務定期更新。

這意味著系統可以學習——哪些關鍵詞命中率高、哪些源有用——而不需要人手動改 prompt。

---

## 三層架構

```
┌─────────────────────────────────────────────────────────────┐
│                        策略層(月)                           │
│  Task 6: 月度覆盤                                            │
│  輸入:所有 memory + Handbook 狀態                             │
│  輸出:方向確認、機會窗口、行動建議                               │
│  → 影響你的應用開發決策                                        │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                        推理層(雙週)                          │
│  Task 4: 讀 Handbook Git diff → 跨內容推理                    │
│  Task 5: 讀 daily-stats + change-log → 自動調參               │
│  → Task 4 產出進 Handbook, Task 5 產出進 active-config         │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                        收集層(每日)                          │
│  Task 1: RSS 收集 → memory                                   │
│  Task 2: 日報 → Telegram + Handbook                          │
│  Task 3: 社交情報 → Telegram                                  │
│  → 原始數據進 memory,結構化結果進 Handbook                     │
└─────────────────────────────────────────────────────────────┘
```

每一層的輸出是上一層的輸入。越往上,頻率越低、抽象程度越高、對決策的影響越大。

---

## 資訊生命週期

一個新AI工具從出現到變成你的知識,經過以下階段:

```
Product Hunt / GitHub 發布
    │
    ▼
① Task 1 (RSS) 抓到 XML → 關鍵詞過濾 → 存入 memory
    │                        (90% 在這裡被過濾掉)
    ▼
② Task 2 (日報) 讀 memory + web search 補充
    │   → 讀取 active-config 的 focus_areas
    │   → primary 方向(如「Agent + UI」):降低門檻,命中即入報,標記 🎯
    │   → team 方向(如「RAG 工具鏈」):提高門檻,大事才入報,標記 [方向名]
    │   → 分類為 ⚡/🔧/📖(與方向標記組合使用)
    │   → 推送 Telegram(信號)
    │   → 追加到 app_index.md(資產)
    │   → 寫入 daily-stats(統計)
    ▼
③ Task 3 (社交) 搜索相關討論
    │   → 去重(如果日報已覆蓋就跳過)
    │   → 發現日報遺漏的弱信號
    ▼
④ 你讀了日報,覺得某個應用值得深入
    │   → 手動在 Handbook 寫一篇 ✍️ 深度實作筆記
    ▼
⑤ Task 4 (雙週) 讀 Git diff
    │   → 發現你的 ✍️ 筆記和自動收錄的應用之間的關聯
    │   → 推理出趨勢、矛盾、知識缺口
    ▼
⑥ Task 5 (進化) 讀 daily-stats
    │   → 發現某個新關鍵詞反覆命中 → 自動加入 B 級詞
    │   → 下一輪 Task 1 和 Task 2 就會覆蓋這個方向
    ▼
⑦ Task 6 (月度) 綜合所有數據
    │   → 告訴你:你的方向對不對、機會在哪、該做什麼
    ▼
回到 ①,但系統比上個月更準
```

這就是閉環。每一步都在為下一步提供更好的輸入。

---

## Handbook 在系統中的位置

Handbook 不是一個獨立的知識庫。它是整套系統的長期記憶體,同時承擔三個角色:

### 角色 1:沉澱池

Task 2 每天把過濾後的應用/工具寫入 `app_index.md`。三個月後,你有一份自動累積的、分類好的、帶來源標記的應用索引。不需要你手動整理。

### 角色 2:推理輸入

Task 4 不讀 Telegram 歷史,不讀 Moltbot memory。它讀 Handbook 的 Git diff——過去 14 天所有 commit 的內容變更。這意味著:

- Moltbot 自動追加的應用(📱 commit)提供廣度
- 你手動撰寫的筆記(普通 commit)提供深度和方向信號
- 備註欄的 🎯 和 [方向名] 標記讓 Task 4 能按方向分層推理:你的方向講深,隊友方向只講大事
- Task 4 把兩者交叉比對,產出你單獨看任何一個都看不到的洞察

**Handbook 的結構化程度直接決定 Task 4 的推理品質。** 分類清晰,Task 4 就能檢測到「某個分類突然活躍」或「兩個分類出現交叉」。分類混亂,推理就是噪音。

### 角色 3:查詢介面

當你想知道「最近有什麼 Agent UI 框架」,你不翻 Telegram,你打開 `app_index.md` 的 Agent 分類表。當你想回顧上個月的趨勢,你打開 `reports/biweekly/` 最近兩期。

用 Cursor 打開 Handbook repo,你可以用自然語言問它:「過去一個月 app_index 裡新增了哪些跟 Claude API 相關的應用?」

---

## Handbook 內部結構

```
AI-App-Handbook/
│
├── stack/                        技術層:「怎麼實現」
│   ├── app_index.md              ← Moltbot 每日追加(唯一的高頻寫入點)
│   ├── technology_landscape.md   ← 技術全景圖(人寫,低頻更新)
│   ├── {topic}.md                ← 深度筆記(人寫)
│   └── code-notes/               ← 代碼分析速記(Moltbot 創建)
│
├── implementation/               實作層:「怎麼做」
│   └── {topic}.md                ← 人寫
│
├── reports/biweekly/             時間層:「最近發生了什麼」
│   ├── README.md                 ← Moltbot 追加索引
│   └── {YYYY-MM-DD}.md          ← Moltbot 創建
│
├── products/                     產品層:「誰在做」
├── use-cases/                    場景層:「解決什麼問題」
├── api-reference/                速查層
│
├── AGENT.md                      給 AI agent 的使用指令
└── README.md                     入口 + 導覽
```

**設計邏輯**:目錄名即分類,README 即索引,文件名即主題。不需要資料庫,目錄結構本身就是查詢介面。

**Moltbot 只碰三個地方**:
1. `stack/app_index.md`(每日追加行)
2. `stack/code-notes/`(代碼分析時創建新文件)
3. `reports/biweekly/`(每兩週創建文件 + 更新 README 索引)

其餘全是人的領地。

### app_index.md 的設計

這是整個 Handbook 中最核心的文件——Moltbot 的每日寫入目標,也是你查應用的入口。

```markdown
## {{分類名}}

| 應用/工具 | 開發者 | 日期 | 標籤 | 連結 | 備註 |
|----------|--------|------|------|------|------|
| ... | ... | ... | ... | ... | ✍️ 手動加入 |
| ... | ... | ... | ... | ... | 📖 daily 2026-02-10 |
| ... | ... | ... | ... | ... | ⚡ daily 2026-02-10 — 原因 |
| ... | ... | ... | ... | ... | 🎯 agent-ui | 🔧 daily 2026-02-11 |
| ... | ... | ... | ... | ... | [RAG] ⚡ daily 2026-02-11 — 原因 |
```

備註欄是關鍵——它記錄了每個應用的來源(手動 vs 自動)、重要性等級、和開發方向關聯。Task 4 讀 diff 時靠這些標記來推理。

分類數量控制在 5-8 個。太少無法區分,太多讓 Moltbot 判斷不穩定。留一個「其他」兜底。

### 標注系統

兩層標記疊加使用:

**第一層:重要性**

| 標記 | 含義 | 入選條件 |
|------|------|---------|
| ⚡ | 戰略級 | 知名團隊 + 架構創新,或大規模應用 |
| 🔧 | 可操作 | 有開源代碼/API/文檔可復現 |
| 📖 | 值得了解 | 有參考價值但不需立即行動 |

**第二層:開發方向**(疊加在第一層之上)

| 標記 | 含義 | Task 2 行為 |
|------|------|------------|
| 🎯 | primary 方向(主攻,如「Agent + UI」) | 降低門檻,命中即入報 |
| `[方向名]` | team 方向(信號追蹤,如 RAG、多模態) | 提高門檻,大事才入報 |
| (無標記) | 通用應用 | 正常規則 |
| ✍️ | 人工手動添加 | Moltbot 不觸碰 |

日報示例:
```
🎯🔧 [AgentUI-Pro] Anthropic 發布新 Claude UI SDK...
🎯📖 [ChatFlow] 新的對話流程設計工具...
[RAG] ⚡ LangChain 發布 RAG pipeline v2...
📖 [SomeApp] 某團隊提出新的 prompt 管理方案...
```

你掃一眼就知道:🎯 = 我的方向要仔細看,[方向名] = 隊友方向大事才出現,無標記 = 通用。

開發方向存在 `active-config.focus_areas` 中。項目啟動後確認實際分工,一句話更新 config,所有任務自動適配。

### Commit Message 規範

通過 emoji 前綴區分人和機器的 commit:

| 來源 | 格式 |
|------|------|
| Task 2 每日應用 | `📱 daily apps: {日期} (+N apps)` |
| Task 4 雙週報告 | `📊 biweekly report: {起始} to {結束}` |
| 代碼分析 | `📝 code analysis: {項目名}` |
| 人手動 | 無 emoji 前綴 |

Task 4 靠 commit message 的 emoji 來判斷哪些變更是自動的、哪些是你手動加的(✍️ 權重最高)。

---

## 自我進化機制

系統不是靜態的。它會學習。

```
                    active-config v1
                         │
Day 1-14:  Task 2 用 v1 的關鍵詞過濾 → 寫 daily-stats
                         │
Day 14:    Task 5 讀 daily-stats ×14
           │  → 某個 B 級詞連續命中 → 保留
           │  → 某個 B 級詞零命中 → 標記(冷啟動期不刪)
           │  → 應用中頻繁出現新詞 → 加入 B 級
           └──→ 寫 active-config v2 + change-log
                         │
Day 15-28: Task 2 用 v2 的關鍵詞過濾 → 寫 daily-stats
                         │
Day 28:    Task 5 讀 daily-stats ×14 + 上輪 change-log
           │  → 驗證 v1→v2 的改動是否有效
           │  → 有效保留,無效回滾
           └──→ 寫 active-config v3 + change-log
```

**進化的邊界**:
- 可以自動調整的:B 級關鍵詞、搜索詞、RSS 優先級
- 需要人確認的:A 級關鍵詞、數據源增刪
- 不能自動調整的:任務架構、頻率、Handbook 結構

**冷啟動保護**:`active-config version ≤ 3` 時,禁止刪除 B 級關鍵詞。早期數據太少,刪詞容易誤判。

---

## 寫入安全

Moltbot 是 LLM agent,它的輸出不 100% 可靠。所以所有寫入都有防護:

| 風險 | 防護 |
|------|------|
| 寫壞 app_index.md 格式 | Prompt 要求:格式異常時跳過寫入,推送告警 |
| 覆蓋人寫的內容 | 機制保證:只 append,不 overwrite |
| GitHub API 失敗 | 不影響主任務(Telegram 已推送),只記錄錯誤 |
| Token 過期 | 90 天輪換,過期推送告警 |
| 寫入了錯誤內容 | 每個 commit 可 revert,commit message 標記來源 |
| 單日應用太多導致膨脹 | 超過 8 個只寫 🔧 和 ⚡,跳過 📖(但 🎯 primary 方向的應用永遠寫入) |

**核心原則:Moltbot 的所有輸出都是唯讀通知。** 它不修改核心知識資產,只追加到特定位置。壞了最多丟一天的數據。

---

## 搭建順序

整套系統的搭建分四個階段,每個階段都是可用的:

### Phase 0:Handbook(第 0 天)

建 GitHub repo,設計分類體系,放入種子內容。這一步最重要——分類體系錯了後面全歪。

**AI應用的分類建議**:
- Agent 框架(LangChain、AutoGPT 系列)
- UI/UX 工具(聊天界面、可視化編輯器)
- RAG 工具鏈(向量數據庫、檢索增強)
- API 包裝器(Claude、OpenAI、本地模型)
- 垂直應用(寫作助手、代碼生成、數據分析)
- 基礎設施(部署、監控、評估)

### Phase 1:收集層(第 1-3 天)

部署 Task 1/2/3。你開始每天收到 Telegram 日報和情報。Task 2 同時把應用寫入 Handbook。

**數據源配置**:
- Product Hunt RSS
- GitHub Trending (AI/ML 分類)
- Hacker News API
- Twitter/X lists (AI builders)
- Reddit r/LocalLLaMA, r/ClaudeAI
- Discord/Slack 社群更新

驗證:GitHub 出現 `📱 daily apps` commit,格式正確。

### Phase 2:推理層(第 7-14 天)

等 daily-stats 累積 7 天後,部署 Task 4 和 Task 5。

Task 4 第一次跑時,Handbook 裡至少要有你的種子內容 + 一週的自動追加,它才有東西可以推理。

### Phase 3:策略層(第 30 天)

部署 Task 6。需要至少一個月的數據累積。

---

## 實際應用場景

### 場景 1:追蹤技術棧變化

**問題**:Claude API 每月都有更新,LangChain 架構持續演進,你需要知道何時該升級依賴。

**系統行為**:
- Task 1 抓到 Anthropic blog RSS → 過濾出 API 變更
- Task 2 標記為 ⚡(breaking change)或 🔧(新功能)
- 寫入 `app_index.md` 的「API 包裝器」分類
- 推送 Telegram:「🎯⚡ Claude API 新增 vision 支持,附遷移指南」

**你的行動**:看到推送,打開 Handbook 找到完整條目,點開官方文檔,決定何時升級。

### 場景 2:發現跨領域機會

**Task 4 雙週報告推理示例**:

```
## 趨勢檢測

過去兩週觀察到:
1. Agent 框架分類新增 5 個項目 vs 平均 2 個/雙週 → 升溫
2. RAG 工具鏈分類出現 3 個向量數據庫更新 → 基礎設施成熟
3. 你手動添加了「✍️ Claude Code 實作筆記」→ 實際需求信號

## 交叉推理

Agent 框架 + RAG 工具鏈的同步升溫 + 你對 Claude Code 的關注
→ **機會窗口**:Claude Code + RAG 的組合可能有未被滿足的需求
→ **行動建議**:搜索「Claude Code RAG」現有方案,評估自建可行性
```

這是 Task 4 自動產出的。你看完可能意識到:確實沒人做 Claude Code 的 RAG 插件,這是個機會。

### 場景 3:自動學習你的偏好

**初始狀態**(Day 1):
```
active-config.focus_areas:
  primary: "agent-ui"  # 你主攻方向
  team: ["RAG", "evaluation"]  # 隊友方向
  
active-config.keywords_B:
  ["chatbot", "conversation", "interface"]
```

**Task 5 觀察**(Day 14):
```
daily-stats 分析:
- "chatbot" 連續 14 天命中,但你從不點開 → 誤報
- "agent-ui" 相關應用中頻繁出現 "streaming" 但未被過濾 → 遺漏
- [RAG] 方向的大事:LlamaIndex 2.0 發布
```

**自動調整**(Day 14):
```
active-config v2:
  keywords_B:
    - 移除 "chatbot"(冷啟動期只標記,不刪除)
    - 新增 "streaming"
    - 新增 "real-time"
```

**結果**(Day 15+):Task 2 開始過濾到之前漏掉的 streaming UI 工具。

---

## 與傳統方法的對比

| 維度 | 手動追蹤 | Newsletter 訂閱 | 本系統 |
|------|---------|----------------|--------|
| 覆蓋範圍 | 看到什麼是什麼 | 編輯篩選的 | 自動全覆蓋 + 智能過濾 |
| 累積性 | 看過就忘 | 郵件堆積 | Git 版本控制 |
| 可查詢 | 靠記憶 | 全文搜索郵件 | 結構化索引 + AI 查詢 |
| 推理能力 | 人腦連結 | 無 | 自動檢測趨勢和關聯 |
| 個性化 | 完全個人 | 一刀切 | 自我進化學習偏好 |
| 時間成本 | 1-2 小時/天 | 30 分鐘/天 | 2 分鐘/天 + 按需查詢 |

---

## 一句話總結

用可回滾的自動調參,把每天的應用/工具資訊流變成可累積的知識資產(Handbook),再用資產的 diff 觸發跨內容推理——這是一套越跑越準、越跑越值錢的AI應用開發基礎設施。
