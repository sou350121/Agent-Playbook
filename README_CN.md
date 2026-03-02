# Agent-Playbook

**AI App 工程監控手冊** — Pulsar 系統的 AI 工具與 Agent 情報臂，每日自動過濾 50+ 發布，提煉工程關鍵信號，持續追蹤生產級架構模式與預測驗證記錄。

---

## 這是什麼

Agent-Playbook 記錄 AI 工具與 Agent 領域的工程級洞察：哪些值得投入、哪些存在生產陷阱、社群真實反饋如何分布。內容由 [Pulsar](https://github.com/sou350121/Pulsar-KenVersion) 自動化流水線驅動，人工審校後歸檔。

---

## 與其他資訊源的區別

| 維度 | Twitter/X 資訊流 | GitHub Awesome 列表 | 微信公眾號 | **Agent-Playbook** |
|------|-----------------|--------------------|-----------|--------------------|
| 過濾深度 | 無 — 原始噪音 | 收錄即存檔，不淘汰 | 軟文比例高 | 50+ → 5-10，qwen3.5-plus 評級門控 |
| 失效模式分析 | 極少 | 無 | 極少 | 架構深潛：並發陷阱、AI 代碼盲區 |
| 社群信號 | 碎片化，不可搜索 | 無 | 無 | Git 歷史永久可檢索 |
| 獨立視角 | 無 | 無 | 無 | Devil's Advocate — 對最強信號給出具體質疑 |
| 預測追責 | 無 | 無 | 無 | 雙週預測 + ✅/❌ 驗證記錄，公開判斷歷史 |
| 跨域信號 | 無 | 無 | 無 | 與 VLA 機器人研究的交叉規則引擎 |

---

## 內容導航

| 目錄 | 聚焦 | 更新頻率 |
|------|------|---------|
| `landscape/` | AI 生態圖譜：工具索引、技術全景、關鍵人物 | 月度 |
| `theory/01-principles/` | 底層原理：Transformer、RLVR、Scaling Law 等（10 篇） | 按需 |
| `theory/02-agent-design/` | Agent 設計：架構、記憶、工具、UI/API 設計（16 篇） | 按需 |
| `theory/03-engineering/` | Agentic 工程實戰：護欄 / Context 工程 / 評估迭代（28 篇）★ | 按需 |
| `theory/04-paradigm/` | 範式轉變：Vibe Coding、Software 3.0、Intent-Driven（11 篇） | 按需 |
| `theory/05-strategy/` | 戰略生存：工程師定位、變現、組織角色（13 篇） | 按需 |
| `theory/06-frontier/` | 前沿研究：具身智能、世界模型、生物分子（7 篇） | 按需 |
| `playbooks/onboarding/` | 8 階段學習路徑（思維 → 商業化） | 穩定 |
| `playbooks/tools/` | 30+ 工具整合指南 | 工具發布後 |
| `playbooks/prompts/` | 12 個生產級 Prompt 模板 | 按需 |
| `playbooks/use-cases/` | 真實場景案例研究 | 按需 |
| `playbooks/security/` | IDE 自動執行風險、權限邊界 | 按需 |
| `scaffolds/` | 生產就緒項目模板（阿里雲、DocOps） | 按需 |
| `reports/` | 雙週情報報告 + 預測驗證 | 每兩週 |
| `memory/blog/archives/` | 日報精選、社交情報歸檔 | 每日（自動） |

---

## 自動化流水線（北京時間）

```
06:45  RSS 採集       50+ 來源：GitHub、Hacker News、ithome、36kr、少數派等
07:00  AI 日報        qwen3.5-plus 評級 → 5-10 條工程關鍵精選 → Telegram 推送
07:15  每日精選歸檔   ai-daily-pick.json 追加，Git 歷史永久留存
07:45  社交情報採集   Twitter/X + 論壇，72h 時效窗口，去重過濾
```

**深度分析（週二/四/六 15:30）**

架構深潛：失效模式、AI 代碼盲區、並發陷阱、生產部署反模式。

**雙週節律**

預測生成 → 下期驗證（✅ 準確 / ❌ 偏差）→ 歸檔，判斷歷史完全透明。

---

## 信號標籤體系

**重要性分級**

| 標籤 | 含義 |
|------|------|
| ⚡ | 戰略級 — 影響技術選型或架構走向 |
| 🔧 | 可操作 — 近期可落地的工程實踐 |
| 📖 | 參考 — 背景知識，按需查閱 |
| ❌ | 不收錄 — 噪音、重複、軟文 |

**方向標注**

| 標籤 | 含義 |
|------|------|
| 🎯 | 主方向 — 當前核心關注域 |
| `[方向名]` | 團隊專項追蹤（如 `[Coding Agent]`、`[RAG]`） |

---

## Devil's Advocate — 獨立質疑機制

對每日評為 ⚡/🔧 的最強信號，流水線額外生成一條具體反駁：

> 🔥 最強反駁
> - [信號名]：具體質疑角度（禁止空話）

目的是對抗確認偏誤，保留判斷的獨立性。

---

## 假設追蹤與月度校準

流水線維護 19 條 AI App 領域假設，置信度每月自動校準：

- 日常信號觸發時實時比對假設清單
- 大佬觀點（Karpathy / Altman / LeCun 等）與假設衝突時標注假設序號
- 月度彙總：置信度上下浮動上限 ±0.08，更新 watch-list

校準記錄歸檔於 `memory/`，可通過 MCP `get_predictions` 接口查詢。

---

## Pulsar 自動化系統

本倉庫內容由 **Pulsar** 驅動生成：

- 開源模板：[sou350121/Pulsar-KenVersion](https://github.com/sou350121/Pulsar-KenVersion)
- 技術棧：Python 3.11 + DashScope (qwen3.5-plus) + Telegram Bot + GitHub Contents API
- 自托管，2GB RAM 約束下穩定運行，無外部 SaaS 依賴

如需復用本系統監控其他領域，參考 Pulsar-KenVersion 的 `setup.sh` 一鍵部署流程。

---

## 姊妹倉庫

**[VLA-Handbook](https://github.com/sou350121/VLA-Handbook)** — Pulsar 系統的機器人視覺-語言-動作研究臂，追蹤 VLA 論文、SOTA 進展與具身智能理論。

跨域規則引擎在兩個倉庫的信號之間建立連接：AI App 領域出現 embodied AI 實踐突破，或 VLA 領域的擴展律研究影響 Agent 架構選型時，自動觸發跨域洞察。

---

## 貢獻與使用

- 內容歸檔由自動化流水線寫入，人工內容請參閱 [CONTRIBUTING.md](./CONTRIBUTING.md)
- Agent 行為規範參見 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)
- 多 Agent 協作約定參見 [AGENTS.md](./AGENTS.md)

---

## 許可證

內容以 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 授權。引用時注明出處即可。
