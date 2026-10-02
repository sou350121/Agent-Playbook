---
auto_generated: true
generated_at: "2026-10-02T12:40:48Z"
source_url: "https://huggingface.co/internlm/Atria-Dawn-Preview"
signal_type: "significant_update"
---
# 上海 AI Lab 發布 Atria Dawn Preview：744B MoE 開源 Agentic 模型 (Atria Dawn Preview: From Research Questions to Verifiable Results)

> 🔍 本文由 Moltbot 自動生成 | 2026-10-02
>
> **項目/工具**: Atria Dawn Preview（Shanghai Artificial Intelligence Laboratory / InternLM）
> **鏈接**: https://huggingface.co/internlm/Atria-Dawn-Preview
> **核心定位**: 一個建立在 744B MoE 底座（GLM-5.2）之上的開源 agentic 模型預覽版，目標是把開放式研究/工程問題推向「可執行、可驗證、可復現」的結果。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：開源（MIT）的 744B MoE agentic 模型，主打「科研自動化 + 辦公交付 + 代碼 + 安全」的端到端長程任務。
- **現在值得用嗎**：看場景。若你要的是**純文本、可自架、能做 deep research / 工具調用 / 終端任務**的開源模型，值得立刻測；若你需要多模態（讀圖/讀 PDF）或最強 SWE，先觀望。
- **適合場景**：DeepSearch/DeepResearch、工具調用（BFCL/Automation）、文檔/報告/PPT 交付、授權環境下的漏洞分析與修復。
- **不適合場景**：需要視覺輸入的任務（該模型**僅接受文本**，會以 `400 ... is not a multimodal model` 拒絕圖片/PDF）；追求極致 SWE-bench 分數的場景（被 Claude Opus 5 等拉開）。
- **與競品核心差異**：同尺寸開源裡工具調用（BFCL v4 77.0、AutomationBench 53.8）明顯領先；但 SWE/終端/交付類落後於閉源旗艦。

## 是什麼 / 解決什麼問題

**Atria Dawn Preview** 是上海人工智能實驗室（Shanghai AI Laboratory）發布的新一代 agentic 模型預覽版，底座是一個 **744B 參數的 MoE 模型 GLM-5.2**。它並不是又一個「聊天更順」的通用 LLM，而是明確鎖定**科研與工程場景**——這些場景要求模型能持續理解環境、使用工具、完成多步任務，而不是一次性回答問題。官方把目標函數寫得很直白：把開放式問題推向 **executable / verifiable / reproducible（可執行、可驗證、可復現）** 的結果（來源：官方 HuggingFace 模型卡）。

它支援的完整閉環是：問題分析 → 方案設計 → 工具使用 → 代碼實現 → 實驗執行 → 結果分析 → 失敗恢復。換句話說，這是一個衝著「能自己把事做完並能自證對錯」去的模型，而不是衝著 benchmark 刷榜去的——雖然它確實帶了一份相當完整的評測表。

這次是 **Preview（預覽）** 版本，已經放出完整權重、FP8 量化版、論文（arXiv 2609.15818），以及國際/中國雙區的 API 入口。對 Ken 這條線的意義在於：一個 744B 級別的開源 agentic 底座把「工具調用 + 長程任務」當成第一公民來做，這正是 Agent 工程最缺的一環。

## 技術架構拆解

### 核心設計決策

- **744B MoE 底座（GLM-5.2）**：沿用稀疏 MoE 架構，在推理成本可控的前提下堆到大參數量。官方同時提供 **FP8 量化版**（Atria-Dawn-Preview-FP8），明顯是為了降低自架部署的顯存門檻。
- **四維能力框架**：模型能力被官方明確切分為四個維度，這種「按任務域組織評測」的做法比單一聚合分數更能指導選型：
  - 🔍 **Discovery**：檢索與組織證據、深度研究、把研究問題轉成可執行實驗計劃。
  - 🛠️ **Creation**：寫軟件、做互動應用/遊戲/可視化、搭 ML 系統。
  - 📦 **Delivery**：把文檔/數據/設計需求轉成報告、演示等結構化交付物。
  - 🛡️ **Cybersecurity**：在授權環境下分析安全問題、驗證漏洞、修補並複驗。
- **256K 上下文**：支援到 256K token，適配長程 agent 任務中不斷累積的工具輸出與環境反饋。
- **純文本模型（關鍵取捨）**：這是 744B 級模型裡**相當罕見**的選擇——它**只接受文本輸入**。模型卡甚至專門給出在 Codex / Claude Code / Kimi Code 中「屏蔽多模態輸入」的配置，因為這些 harness 默認假設模型是多模態的。
- **工具鏈優先的接入策略**：官方不只給 API，還直接給了三大 coding agent harness 的接入範例（Codex、Claude Code、Kimi Code），把「拿來當 coding agent 的 brain」當成主要用法之一。

### 與前版/競品關鍵差異

官方評測表把 Atria Dawn Preview 與 DeepSeek V4 Pro 0813、KIMI K3、Qwen 3.8 Max、GLM 5.3、GPT 5.6 sol、Claude Opus 5 放在一起比。以下截取關鍵差異（粗體為該行最佳，來源：官方模型卡評測表）：

| 維度 | Benchmark | Atria Dawn Preview | 對照組最佳 | 結論 |
|------|-----------|--------------------|------------|------|
| Discovery | DeepSearchQA | **96.0** | KIMI K3 95.9 | Atria 領先 |
| Discovery | BrowseComp | **92.5** | GPT 5.6 sol 92.2 | Atria 領先 |
| Discovery | DeepResearch Bench II | 51.1 | Claude Opus 5 54.1 | 落後 |
| Creation | SWE-bench Pro | 59.6 | Claude Opus 5 74.7 | 落後明顯 |
| Creation | Terminal-Bench 2.1 | 78.3 | Claude Opus 5 90.2 | 落後明顯 |
| Creation | MLE-bench Lite | 86.2 | GPT 5.6 sol 88.9 | 略落後 |
| Tool Use | BFCL v4 | **77.0** | 次高 GLM 5.3 74.1 | Atria 領先 |
| Tool Use | AutomationBench | **53.8** | 次高 Qwen 3.8 Max 49.7 | Atria 領先 |
| Tool Use | SkillsBench | 66.4 | Qwen 3.8 Max 66.7 | 幾乎並列 |
| Tool Use | τ³-Bench Banking | 41.2 | Qwen 3.8 Max 55.2 | 落後明顯 |
| Delivery | Workspace-Bench | 65.0 | Claude Opus 5 65.8 | 幾乎並列 |
| Delivery | GDPval | 1583 | Claude Opus 5 1768 | 落後 |
| Delivery | JobBench | 50.3 | Claude Opus 5 68.0 | 落後明顯 |
| Cybersecurity | CyberGym | **86.5** | 次高 GLM 5.3 84.5 | Atria 領先 |

**讀法**：Atria 的優勢集中在 **Discovery（檢索/深研） + Tool Use（工具調用） + 部分安全任務**——這恰好是 agent 的「感知與行動」層；而 **SWE/終端/職業交付（JobBench、GDPval）** 則明顯落後於 Claude Opus 5。這個畫像很一致：它更像是「會查、會調工具、會跑實驗」的研究助手，而不是「最強碼農」。

### 架構/信息流圖

```
            ┌──────────────────────── Atria Dawn Preview (744B MoE / 256K) ────────────────────────┐
            │                                                                                     │
  任務輸入   │   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐      │
 (純文本) ──┼──▶│ 問題分析  │──▶│ 方案設計  │──▶│ 工具使用  │──▶│ 代碼實現  │──▶│ 實驗執行/驗證 │──┐   │
            │   └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────────┘  │   │
            │        ▲                                                              │          │   │
            │        └───────────────── 失敗恢復 / 環境反饋 ◀───────────────────────┘          │   │
            │                                                                                  ▼   │
            │  四維輸出：Discovery(證據/深研) · Creation(代碼/應用) · Delivery(報告/交付) · Security │
            └──────────────────────────────────────────────────────────────────────────────────────┘
                 ▲ 接入方式：API（國際 api.atria-asi.ai / 中國 intern-ai.org.cn）
                 │         自架（SGLang ≥ v0.5.13.post1 / vLLM ≥ v0.23.0）
                 │         Coding harness（Codex / Claude Code / Kimi Code 自訂 provider）
```

## 實用評估

### 什麼場景值得用

- **Deep research / DeepSearch 類應用**：DeepSearchQA 96.0、BrowseComp 92.5 領先，配合 256K 上下文，適合做「檢索→組織證據→出結論」的研究代理。
- **工具調用密集的 agent**：BFCL v4 77.0、AutomationBench 53.8 都是該表最佳，工具編排層值得一試。
- **授權下的安全分析**：CyberGym 86.5 領先，漏洞驗證/修復/複驗這條線有真實優勢。
- **需要自架與可審計的團隊**：MIT 許可 + 完整權重 + FP8 量化版，適合對數據不出域、成本可控有硬要求的場景。

### 什麼場景不值得用

- **任何需要視覺輸入的任務**：模型**只收文本**。官方模型卡明確說明，圖片/PDF 附件會被 endpoint 以 `400 Atria-Dawn-Preview is not a multimodal model` 拒絕。要讀圖/讀 PDF 得自己在 harness 層攔截（官方反而給了「屏蔽多模態」的 hook 範例）。
- **追求頂級 SWE/終端能力**：SWE-bench Pro 59.6 vs Claude Opus 5 的 74.7、Terminal-Bench 2.1 78.3 vs 90.2，差距不小，重度 coding agent 不宜首選。
- **職業任務交付（JobBench 50.3 / GDPval 1583）**：對照組 Opus 5 明顯更強，辦公文檔類交付要謹慎。
- **資源受限環境**：744B MoE 即使有 FP8 版，自架門檻仍高；輕量場景直接走 API 更現實。

### 遷移成本

- **走 API**：最低。國際用 `https://api.atria-asi.ai/v1`，中國區用 intern-ai.org.cn 的 token-plan，皆為 OpenAI 兼容接口。
- **接入現有 coding harness**：中等，且有踩坑點。以 Codex 為例，需新增 `model_providers.atria`、提供一個 `model_catalog_json`（把 `input_modalities` 設為 `["text"]`、`context_window` 設為 256000），否則 Codex 會默認多模態並附圖導致 400。`model_catalog_json` 是**替換**而非合併，切換模型時要一併補進 catalog。需 Codex CLI 0.154.0+。
- **Kimi Code**：需在 `~/.kimi-code/config.toml` 設 `max_context_size=256000`、`max_output_size=65536`（Atria 的 max_tokens 合法範圍是 1–65536）、`capabilities=["tool_use","thinking"]` 等欄位；缺 `max_context_size` 會靜默解析失敗。
- **自架**：SGLang `v0.5.13.post1+`（官方 cookbook 指向 GLM-5.2）或 vLLM `v0.23.0+`；需要相應的大規模算力。

## 對你的意義

對 Ken 的 **Agent + UI** 線，這個模型提供了兩條線索：

1. **「研究代理」的開源底座可用了**。Discovery + Tool Use 領先是它的差異化畫像，若你在做 deep research / 工具編排類 agent，它比通用閉源模型更貼題，而且 MIT 可自架。
2. **它是 coding harness 的「大腦」候選**。官方直接給 Codex / Claude Code / Kimi Code 的接入範例，這說明生態開始把「可換 brain 的 coding agent」當成常態——這與你追蹤的 Agent 架構趨勢一致。

建議：**立即小規模試用（走 API）**。先用一兩個 deep research / 工具調用任務對比現有模型；**不要**在需要讀圖的 pipeline 裡替換，也別指望它接管最難的 SWE 任務。等正式版（非 Preview）出來再評估是否投入自架成本。

## 關鍵代碼/配置片段

以下為官方模型卡給出的真實接入片段（節選）。

**Codex — 定義純文本模型（節選）**：

```json
{
  "models": [
    {
      "slug": "Atria-Dawn-Preview",
      "context_window": 256000,
      "max_context_window": 256000,
      "input_modalities": ["text"]
    }
  ]
}
```

模型卡說明：`"input_modalities": ["text"]` 是關閉多模態輸入的關鍵設置；`context_window` 需設為模型真實上限（256000），否則 Codex 會回退到保守默認值、浪費可用上下文。

**Kimi Code — 提供商與模型（節選，官方範例）**：

```toml
default_model = "atria/Atria-Dawn-Preview"

[providers.atria]
type = "openai"
base_url = "https://api.atria-asi.ai/v1"
api_key = "ATRIA_API_KEY"

[models."atria/Atria-Dawn-Preview"]
provider = "atria"
model = "Atria-Dawn-Preview"
max_context_size = 256000
max_output_size = 65536
capabilities = ["tool_use", "thinking"]
```

模型卡強調：`max_output_size` 不設會讓 Kimi 發送 `max_context_size`，而 Atria 的 max_tokens 合法範圍為 1–65536；`max_context_size` 缺失會導致模型條目靜默加載失敗。

**自架版本要求（官方）**：SGLang `v0.5.13.post1+`、vLLM `v0.23.0+`。

> TODO: 模型卡中的評測柱狀圖（`assets/evaluation.png`）尚未提供文字標註，具體實驗條件與統計口徑待官方補充。
> TODO: Preview 版與未來正式版的能力差異、以及 744B 自架的實際吞吐/成本數據，模型卡未給出，待驗證。

---
[← Back to Deep Dives](./README.md)
