---
auto_generated: true
generated_at: "2026-11-22T03:30:41Z"
source_url: "https://vercel.com/blog/ai-gateway-production-index-november-2026"
signal_type: "significant_update"
---
# 決策模型喫下 26% 請求，生成與判斷正式分家 (Decision Models Take 26% of Requests: Generation and Judgment Split)

> 🔍 本文由 Moltbot 自動生成 | 2026-11-22
>
> **項目/工具**: Vercel AI Gateway（Production Index 月度報告 + Gemini Decision 1 上架）
> **鏈接**: https://vercel.com/blog/ai-gateway-production-index-november-2026
> **核心定位**: 一份來自真實生產流量的數據報告，顯示「決策模型」已成為 AI 應用的第三種基礎設施——它不生成 token，只回答布爾、選項與分數

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Vercel AI Gateway 每月路由超過 100 萬億 token 的真實流量統計；11 月版最重要的信號是決策模型在六週內喫下 26% 的請求量
- **現在值得用嗎**：**看場景**。如果你的 Agent 裡有大量「路由/政策檢查/工具篩選/排序」這類純判斷步驟，用語言模型來做就是在燒錢
- **適合場景**：請求路由、內容合規檢查、Agent 工具挑選、檢索結果重排、結構化評分
- **不適合場景**：需要自由文本輸出、需要推理鏈、任務邊界模糊到無法寫出判準的場景
- **與前版核心差異**：過去只能選「便宜的固定規則」或「聰明但慢且貴的語言模型」，現在多了第三個選項：貴約 1/70、支援多模態、輸出結構化答案

## 是什么 / 解决什么问题

幾個月前，當軟件需要「做個快速判斷」，工程師只有兩個選擇：寫死規則，便宜但僵硬；或者調用語言模型，聰明但慢、貴、而且輸出一堆你根本不需要的解釋文字。Vercel 在報告裡把這個困境講得很直白：

> "Until recently, when software needed to make a quick call, a team could use either a fixed rule that was cheap but rigid, or a language model that is smart but slow and expensive. Decision models are now a third option."

決策模型（Decision Models，前身叫 evaluation models）就是這個第三選項。它讀入狀態（文本、圖片、音頻、視頻、PDF），回傳布爾概率、選項選擇與分數——**不產生輸出 token**。這不是新概念的發明，而是把它從「廠商自家 API 的實驗性端點」提升為「網關上的一等模型類型」。

這次之所以值得寫，是因為兩件事同時發生：

1. **Gemini Decision 1 上架 AI Gateway**（2026-11 變更日誌）——Google 正式推出多模態決策模型，支援 text / image / audio / video / PDF 輸入
2. **11 月 Production Index 給出量級證據**——決策模型在六週內從零成長到佔據網關 26% 請求，卻只佔 0.53% 的支出

一個是供給側的產品信號，一個是需求側的流量事實。兩者疊在一起，才讓「生成與判斷分家」從推測變成可觀察的架構趨勢。

## 技术架构拆解

### 核心設計決策

- **不產出 token，只回傳結構化答案**。官方文檔明確：回傳 choices、scores、boolean probabilities「instead of free-form text」。這讓單次請求的成本結構從「輸入長度 + 輸出長度」退化為幾乎只有「輸入長度」——部分決策模型甚至只計輸入 token 費用。
- **一個請求可以並行回答多個問題**。文檔寫道："Several questions can be answered in parallel within a single request, against the same state."——同一份上下文可以同時被問「是否違規？」「屬於哪一類？」「風險分數多少？」，省掉重複傳輸上下文。
- **三種問題類型覆蓋絕大多數判斷**：Boolean（給定 criteria 回傳 0-1 概率）、Choice（從具名選項集中挑一個，附每項概率）、Score（沿有序量表評分，附每一檔概率）。
- **Decision Fallbacks 是可選的第二段**：當 Choice/Score 置信度不足、Boolean 概率落在不確定帶、或複合條件命中時，用另一個模型重跑。官方明確這是 opt-in，且**兩段都計費、延遲相加**。
- **多協議兼容而不是另起爐灶**：AI SDK（需 `ai 7.0.128+`，更早版本用 `experimental_evaluate`）、OpenAI 兼容的 `/v1/decisions` HTTP 端點、以及 TypeSafe 兼容 API。舊的 `/v1/evaluate` 仍可用但已標記棄用。**注意：決策請求不走 Chat Completions、Responses、Anthropic 兼容或 Cohere 兼容端點。**

### 與前版/競品的關鍵差異

| 維度 | 固定規則 / 前版 evaluate | 語言模型判斷 | 決策模型（現況） |
|------|------------|------------|------------|
| 單次成本 | 最低 | 基準 1x | 約 1/70（官方報告口徑） |
| 支出佔比 | — | 幾乎全部 | 0.53%（佔 26% 請求） |
| 輸出 | 布爾/枚舉 | 自由文本（需解析） | Boolean / Choice / Score + 概率 |
| 多模態 | 不支持 | 部分支持 | text / image / audio / video / PDF（Gemini Decision 1） |
| 可解釋性 | 需要審規則 | 自然語言解釋 | 概率分佈，但無理由 |
| 靈活性 | 僵硬 | 高 | 中（需可寫出判準） |

### 架構/信息流圖

```
                        ┌──────────────────────────────┐
   應用 / Agent          │        AI Gateway            │
        │               │   (統一路由 / 觀測 / 預算)     │
        │  state        └──────────────────────────────┘
        │ (text/img/         │
        │  audio/video/pdf)  │
        ├───────────────────►│
        │                    ├──► Boolean  → 0-1 概率
        │  questions[]       ├──► Choice   → 選項 + 各項概率
        │  (可多個並行)       ├──► Score    → 分數 + 各檔概率
        │                    │
        │                    └─[低置信/不確定帶]─► Fallback 模型重跑
        │                                              (兩段計費)
        │◄───────────────────┴──────────────────────────┘
        │   answers[] (按問題順序，含 model / usage / cost 元數據)

   典型用途：請求路由、政策檢查、Agent 工具篩選、結果重排
```

一個關鍵的架構含意：決策呼叫**同樣出現在 Gateway 日誌與預算裡**，與其他模型請求並列計數。也就是說，判斷層不是躲在應用後面的黑箱，而是被納入可觀測性與成本治理的同一個平面。

### 流量數據的幾個硬事實（來源：Vercel 11 月 Production Index）

| 指標 | 數值 | 說明 |
|------|------|------|
| 決策模型佔網關請求 | 26%（約 1/4） | 六週內達成 |
| 決策模型佔總支出 | 0.53% | 成本結構幾乎可忽略 |
| 使用過決策模型的付費團隊 | 近 1/3 | 10 月數據 |
| 只用決策模型、完全不發文本生成請求的團隊 | 約 11% | 說明存在「純判斷型」應用 |
| >100 億 token/月 團隊中使用比例 | 7/10 | 規模越大，越依賴判斷層 |
| 決策模型供給 | 15 個模型 / 8 家廠商 | mid-September 上線後累積 |
| 請求量集中度 | Jev（TypeSafe AI）≈ Anthropic 總請求的 4 倍 | 每家 $1 花在 Jev，$64 花在 Anthropic |
| 語言模型請求來自 <60 天新模型 | 超過一半（此前從未超過 3 成） | 模型半衰期約六週 |

> 口徑提醒：以上均為 Vercel 自家網關的匿名聚合流量，支出按「published list prices」估算，實際帳單可能不同。它代表的是**經過 Vercel 生態的企業與新創團隊**，不是全行業普查。

## 实用评估

### 什么场景值得用

- **Agent 工具篩選**：幾十個 MCP 工具裡挑出本次該用的 2-3 個。這是布爾/選項問題的教科書場景，用生成模型做等於讓它寫一段「我選了 X，因為……」的廢話再解析。
- **請求路由**：把用戶輸入分流到不同子 Agent / 不同模型檔位。低延遲 + 高 QPS 場景，成本優勢會被放大。
- **政策與合規檢查**：給定 criteria 回傳概率，再在應用層設閾值。Vercel 官方指南特別建議「把審批金額、金額驗證、路由規則留在應用代碼裡」——即判斷歸模型，決策權歸代碼。
- **檢索重排與評分**：用有序量表打分，比讓語言模型輸出「相關性：8/10」再正則解析可靠得多。

### 什么场景不值得用

- **需要解釋的場景**。決策模型回傳概率，不回傳理由。客服、法務、醫療這種「必須說清楚為什麼」的場合，你仍需要生成模型或人工。
- **任務邊界模糊**。如果團隊說不清「判準是什麼」，決策模型會把模糊性放大成看似精確的數字——這比一段含糊的文字更危險。
- **需要推理鏈的判斷**。多步邏輯、需要計算、需要檢索外部事實的判斷，不屬於這個類型。
- **單一模型的過度依賴**。報告顯示幾乎所有決策請求量都流向 TypeSafe 的 Jev。供給端仍高度集中，議價與可用性風險需自行評估。
- **成本敏感度極高的低頻場景**。如果一天只有幾百次判斷，直接塞進現有語言模型呼叫可能比新引入一套 API 更省事。

### 迁移成本

- **從 TypeSafe 遷入**：最低。官方稱現有 TypeSafe SDK 不用改寫請求，只要把 client 指向 `https://ai-gateway.vercel.sh/typesafe`。
- **從 `/v1/evaluate` 遷移到 `/v1/decisions`**：中等但機械。映射關係官方已給出對照表：`state` → `input`、`questions` 物件 → 陣列（每 key 變 `name`）、`boolean` → `predicate`、`choice.criteria` → `choices[]`、`score.criteria` → `levels[]`、`answers` 物件 → 按問題順序的陣列。`providerOptions` 原樣保留。
- **從語言模型判斷遷來**：這是真正的工程工作。你需要 (1) 把 prompt 裡的判準拆成 criteria/choices/levels；(2) 在應用層重寫結果解析與閾值邏輯；(3) 建立評估案例集，同時測「模型答案」與「應用據此採取的動作」。官方給的建議是先在 pilot 階段量測**錯誤動作率與人工複核工作量**，再開自動執行。
- **AI SDK 版本門檻**：`ai 7.0.128+`；`7.0.133+` 之後 `state` 傳陣列的語義變更（變成有序 parts，要用 `{ type: 'json', value }` 包 JSON），升版時注意這個 breaking 細節。

## 对你的意义

對 Ken 的 Agent + UI 方向，這份報告的價值不在「又一個模型上架」，而在那個 **0.53% 對 26%** 的失衡。它告訴你：真實生產系統裡，絕大多數「模型呼叫」在數量上是廉價的判斷，在金額上才是生成。

幾個具體建議：

- **立即可做**：翻一遍你現有的 Agent 流程，把每個 LLM 呼叫標註成「生成」或「判斷」。我猜判斷類會佔到一半以上，而它們現在都在用最貴的方式跑。
- **值得觀望**：決策模型供給仍集中在 TypeSafe Jev 一家。多廠商（含 Google 這次）剛開始進場，等 2-3 個月看價格與可靠性再重度投入更穩妥。
- **值得警惕**：模型半衰期已縮到約六週，超過一半語言模型請求來自不到兩個月的新模型。對你這種自建管線的系統，**頻繁換模型本身就是一種維護成本**；決策層用結構化接口（而非 prompt 工程）反而更抗換代——換模型不用重寫 prompt。
- **對多模態 Agent 的啟示**：Gemini Decision 1 支援 video/audio 輸入做判斷，這對 UI 類 Agent（截圖判斷、界面狀態檢查）是直接可用的能力，比用視覺語言模型輸出一段描述再解析要靠譜。

## 关键代码/配置片段

以下代碼/片段均引自 Vercel 官方文檔與變更日誌，未做編造。完整請求/響應範例請查閱原文。

模型 ID 與協議支援（來源：changelog）：

```
google/gemini-decision-1

可用於：AI SDK / TypeSafe-compatible API / Decisions API
PDF、audio、video 輸入：經 AI SDK 7 支援
TypeSafe-compatible 與 Decisions API：僅 text + image
不支援：Chat Completions、Responses、Anthropic-compatible、Cohere-compatible
```

AI SDK 版本要求與端點（來源：official docs）：

```
AI SDK: ai 7.0.128 或更新（更早的 AI SDK 7 用 experimental_evaluate）
HTTP:   POST /v1/decisions（OpenAI-compatible Decisions API）
兼容:   https://ai-gateway.vercel.sh/typesafe（TypeSafe request/response 形狀）
棄用:   POST /v1/evaluate（仍可用，新整合請勿使用）
```

問題類型對應（遷移映射，來源：official docs）：

```
boolean + criteria {true,false}   → predicate（criteria 寫進 instructions）
choice  + criteria {key: desc}    → choice  with choices: [{ value, description }]
score   + criteria ['Low','High'] → score   with levels: [{ label: 'Low' }, ...]
state: 'text'                     → input: 'text'
state: 物件 / 物件陣列             → input: [{ role: 'user', content: [{ type: 'input_json', data: state }] }]
state: 其他 JSON                  → input: JSON.stringify(state)
```

計費注意（來源：official docs）：

```
決策請求照常回報 token usage，按模型 per-token 費率計費；
部分決策模型只計 input token。
觸發 Decision Fallback 時，兩段都計費，usage 為兩次呼叫之和，延遲亦疊加。
```

> TODO: 各決策模型的具體 per-token 單價未在本次抓取的頁面中列出，需查 AI Gateway Models 頁（`?capabilities=decision` 篩選）確認。
> TODO: 文中「約 1/70 成本」為 Vercel 報告的整體口徑，非單一模型實測；若要做採購決策，建議用自家流量做 A/B 實測。

---
[← Back to Deep Dives](./README.md)
