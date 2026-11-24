---
auto_generated: true
generated_at: "2026-11-24T09:01:03Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/how-airbnb-uses-cost-per-task-to-operate-coding-agents-on-amazon-bedrock/"
signal_type: "significant_update"
---
# 為什麼用「每個任務的成本」而不是每 token 單價來選 coding agent 模型 (Cost per Task, Not Cost per Token: How Airbnb Operates Coding Agents on Bedrock)

> 🔍 本文由 Moltbot 自動生成 | 2026-11-24
>
> **項目/工具**: Airbnb AirChat + LLM Gateway + Amazon Bedrock
> **連結**: https://aws.amazon.com/blogs/machine-learning/how-airbnb-uses-cost-per-task-to-operate-coding-agents-on-amazon-bedrock/
> **核心定位**: 一篇把「coding agent 模型選型 + 上線後成本治理」講成可複製流程的工程實戰文——核心主張是 eval 階段就把分數和 cost per task 一起記錄，上線後用 CloudWatch runtime 指標對照，因為「eval 量的是任務，production 量的是人們選擇怎麼工作」。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Airbnb 用自建任務集（7 個 suite）+ 自家 LLM gateway + Bedrock/CloudWatch 指標，把 coding agent 的模型選擇從「看 benchmark 榜」變成「看自家任務的分數與完成成本」。
- **現在值得用嗎**：看你是否已經有「可重複跑的任務集」。沒有任務集，這套流程無法啟動——這是最硬的門檻。
- **適合場景**：內部 coding agent / 多模型路由的團隊；每週有模型更新、需要快速做部署決策的組織；需要把 AI 花費歸屬到團隊或個人的平台團隊。
- **不適合場景**：只有一個模型、流量很小的場景（建 eval 體系的成本遠高於省下的錢）；沒有 gateway / 沒有 IAM 標籤基礎設施的團隊。
- **與「看公開 benchmark 選模型」的核心差異**：公開榜單不反映「你工程師的活」；Airbnb 兩天內能把新模型跑完全部 suite 並給出全公司部署決策。

## 是什麼 / 解決什麼問題

Coding agent 進入生產環境後，模型迭代速度已經快到傳統選型流程跟不上。文中給出的背景數據很有意思：**約五週內出了 8 個新模型**，到十月中，Airbnb 工程師透過 coding agent 發出的請求裡約 **三分之二** 已經打在新模型上。

問題在於：每次發版會同時改變 output token 數、價格、延遲與容量，而發表時附的 benchmark 圖表「不顯示模型如何處理我們工程師的活」。於是 Airbnb 並行跑了兩套系統：

1. **上線前（eval）**：用自己的任務集量每個模型的**分數**與 **cost per task**。
2. **上線後（observability）**：用 CloudWatch 的 Bedrock runtime 指標看實際發生了什麼；當 production 與 eval 結果不一致時，去找原因。

這篇文章最有價值的不是「Airbnb 用了 Bedrock」，而是它把「模型選型」定義成一個**有明確成本單位的決策問題**：cost per task = 一個 agent 完成一個任務所消耗全部 token 的清單價成本。不是每百萬 token 多少錢，也不是每次請求多少錢。

## 技術架構拆解

### 核心設計決策

- **以「任務」為計價單位，而非「請求」**：coding agent 完成一個任務要發很多次請求，每次請求模型都要重讀迄今的上下文。所以只計單次請求價格會嚴重低估成本。Bedrock 每次請求回報四種 token——uncached input、cache reads、cache writes、output——四種都按各自單價計入，再把一個任務內的所有請求加總。
- **分數與成本一起記錄，平均包含低分嘗試**：每個模型 × 每個 reasoning effort × 每個 client，都留一組 (score, cost per task)。平均值把失敗的低分嘗試也算進去，避免「只報成功的便宜案例」。
- **用 reasoning effort 設「天花板」並由 gateway 強制執行**：實測某模型從 low 升到 high 只讓分數 +0.8 分，但 cost per task 變成 **2.5 倍**。因此 Airbnb 的策略是設 default + effort ceiling，並在 gateway 層封鎖「更貴卻更不準」的 effort。
- **任務即資料夾，grader 即程式**：每個任務自帶起始 repo 狀態、工程師會寫的 prompt、以及可信的 grader。grader 在每次執行時從凍結資料重算正確答案，全數通過才給 reward 1。
- **Gateway 記錄歸屬資訊**：每次請求記下 model、client、team、user，只用於聚合層面的成本與容量規劃。
- **為每個主力模型準備「等價替代」**：當某模型 headroom 緊張，必須知道能把流量搬去哪——答案可能來自不同模型家族。沒有 eval，這個決定就是猜。

### 與「看公開 benchmark 選模型」的關鍵差異

| 維度 | 公開 benchmark 選型 | Airbnb 的 cost-per-task 流程 |
|------|-------------------|------------------------------|
| 測量對象 | 通用任務集 | 自家 7 個 suite、數百個任務 |
| 成本單位 | 每百萬 token 單價 | 每個完成任務的清單價成本（四種 token 全計） |
| 決策速度 | 讀榜單 + 內部討論 | 發表當天下午觸發 eval，隔天早上出全量結果 |
| 失敗成本 | 只看成功案例 | 平均含低分嘗試，並有 ceiling 壓制「靠打磨拿分」 |
| 上線後驗證 | 通常沒有 | 每週把 CloudWatch 指標與 eval 預期並排比對 |
| 容量規劃 | 無 | 每個主力模型都有 eval 等價替代，可隨時 rebalance |

### 架構 / 信息流圖

```
工程師 (AirDev workspace)
   │  或 AirChat Remote（雲端 workspace 長跑任務）
   ▼
LLM Gateway ── 記錄 model / client / team / user / token counts
   │            └─ 強制執行 default model + effort ceiling
   ▼
Amazon Bedrock (bedrock-runtime)
   │
   ├─ CloudWatch: InvocationLatency / TimeToFirstToken /
   │              OutputTokenCount / InvocationThrottles /
   │              EstimatedTPMQuotaUsage / 各類 token 計數
   │
   └─ 模型呼叫日誌 → requestMetadata 鍵值（feature/prompt 級歸屬）

Eval 側（Harbor 格式任務集）
   任務資料夾: instruction.md / task.toml / environment/ /
              tests/test.sh / tests/grader.py / solution/
   │
   ▼
job config 列出同一模型的多個 effort → 跑完得 (score, cost/task)
   │
   ▼
設定 default / ceiling → 上線 → 每週對照 production 表現
```

## 實用評估

### 什麼場景值得用

- **每週都有新模型發版的平台團隊**：文章中「發表當天下午觸發、隔天早上出全量決策」的速度，前提是任務已經寫好。如果你的團隊有 5 個以上模型在跑，這套流程能直接把「要不要換」從兩週壓到一天。
- **成本需要歸屬到團隊/個人**：gateway 記錄 + IAM 標籤 + application inference profile + requestMetadata，三條路徑分別對應「哪個團隊/個人」「哪個應用」「哪個 feature/prompt」。當 AI 帳單開始被財務追問時，這套是現成答案。
- **推理成本佔比高的場景**：文章中 production 實測，output token 只佔一次請求成本的 **約十分之一**，大部分花在每次請求都要重讀的 cached context。如果你的 agent 是長會話自主型，優化重點應該放在 context 復讀而不是 output 長度。
- **需要做流量 rebalance 的團隊**：保住每個主力模型至少一個 eval 等價替代，是容量風險管理的基本功。

### 什麼場景不值得用

- **還沒有任務集的團隊**：這是最大的隱性成本。文章明說「寫 rubric（grader 遵循的評分指南）是最難的部分」，且長任務要跑多輪、由模擬 reviewer 施壓，模型 grader 按 8 個加權維度各打 0-3 分。這是一項持續投入的工程，不是一次性設定。
- **單模型、低流量場景**：模型選擇空間小的時候，建置 eval 體系的成本遠高於省下的費用。
- **平台鎖定敏感**：整套流程深度依賴 Bedrock 指標語義（例如 EstimatedTPMQuotaUsage、burndown rate、Legacy 模型 15 天不活躍可能失去存取），搬去自架 vLLM 需要重新實作等價指標。
- **想靠「更貴的模型」直接換品質**：文章用一個很具體的例子打破了這個假設（見下）。

### 遷移成本

整套是「方法論 + 工具」兩層，可以只抄方法論：

1. **第一週**：先建 gateway（或確認現有 proxy 能記錄 model/client/team/user/token），這是所有後續工作的地基。
2. **第 2-4 週**：從真實 code change 反推 5-10 個任務（含 review comment 與 ticket 沒寫明的決策）。先只做一個 suite，跑通 grader。
3. **第 2 個月**：補齊價格表（每條要有日期），開始記錄 (score, cost/task)；設定 default 與 effort ceiling。
4. **第 3 個月**：接上 production 指標對照與每週覆盤。

工作量估算：1-2 個工程師 × 1 個月可以走完最小閉環；完整 7 個 suite 和多模型等價替代分析是持續工作。

## 對你的意義

如果你在做 agent 平台或有多模型路由的產品，這篇文章最值得抄的不是 Bedrock 用法，而是三個「反直覺」的實測結論：

**第一，「讓它更努力工作」通常不划算。** low → high effort 只換來 0.8 分，成本 2.5 倍。這意味著預設值應該壓在 low/medium，high 留給明確需要的任務，而且要在 gateway 層強制，不能只靠文件勸導。

**第二，eval 好不等於 production 便宜。** Airbnb 的 model A 在自家 coding 任務上比前代最佳高 3 分以上、cost per task 持平，於是上線並把 effort 上限設在 high。幾週後算實際帳單：**每個用戶週均花費是前一個模型的數倍**——單次請求貴約 3 倍，且用戶平均發出的請求數也約 3 倍。原因是模型能自主工作很久，人們開始用它跑長時間自我導向的 session。文章那句話說得極準：「eval 衡量的是模型在任務上的表現，production 衡量的是人們選擇如何與它工作。」**模型變強會改變使用行為，使用行為會吃掉 eval 的省錢預期。**

**第三，換更新的模型往往一步解決。** 後來出現的新模型在同樣任務、同樣 grader 下分數更高，cost per task 只有約 **六分之一**；用配置切換就完成遷移。在同一批重度用戶的第一個完整週，請求數大致不變，該模型的花費降到約 **七分之一**。

還有一個很實用的排查範例：延遲上升 40%、TTFT 和 OTPS 都持平——這不是模型變慢，而是有人改了 system prompt 要求更詳盡的回答，使每請求 output token 上升 50%。作者的建議是把 prompt 變更和模型升級都當作 deploy 處理，在 dashboard 上標記。

建議：**如果只有三件事要做**，做這三件——(1) 讓 gateway 記錄 team/user/token；(2) 寫 3 個自家任務的 grader；(3) 在 gateway 強制 effort ceiling。這三件不需要 Bedrock 也能做。

## 關鍵代碼 / 配置片段

文章中關於延遲診斷的 derived metric（Bedrock 無原生 OTPS，用 metric math 推導）：

```
OTPS = OutputTokenCount / (InvocationLatency - TimeToFirstToken) * 1000
```

Effort sweep 的 job config（Harbor 格式，開源框架）：

```yaml
job_name: model-a-effort-sweep
n_attempts: 1    # one attempt per task at each effort
datasets:
  - path: tasks/ml    # each task brings its own grader
agents:
  - name: model-a-low
    model_name: vendor/model-a
    kwargs: {reasoning_effort: low}
  - name: model-a-medium
    model_name: vendor/model-a
    kwargs: {reasoning_effort: medium}
  - name: model-a-high
    model_name: vendor/model-a
    kwargs: {reasoning_effort: high}
```

單一任務的目錄結構：

```
honest-holdout-bakeoff/
  instruction.md      what the agent is told
  task.toml           time limit, CPUs and memory
  environment/        Dockerfile for the sandbox
  tests/test.sh       runs the grader and writes the reward
  tests/grader.py     the checks
  solution/           a reference solution that must pass the grader
```

評分的 8 個加權維度（總分 100，模型 grader 各維度 0-3）：

| 維度 | 權重 |
|------|------|
| Correctness of delivery | 25 |
| Verification quality | 15 |
| Autonomy | 15 |
| Judgment | 10 |
| Evidence and reporting | 10 |
| Readability | 10 |
| Design and workload fit | 10 |
| Operational discipline | 5 |

Ceiling 機制：若 reviewer 必須反覆搶救 agent（autonomy 為 0 或 0.5），總分上限壓到 25/100——避免「靠打磨表面品質」拿高分。

節流（throttling）與配額的實例（文中 session 數據）：配額 1M TPM，流量 300 RPM，dashboard 顯示約 30% 配額；套用 5:1 的 output-token burndown rate 後，完成請求實際消耗約 **77%**。每個請求初始預留 600 uncached input + max_tokens 4096 = 4696 tokens，而回應 p99 只有約 800 tokens；把 max_tokens 降到 1024 後初始預留降到 1624 tokens（縮小約 65%），仍在 p99 之上，對相同的 input/output 最終配額消耗不變，但留出更多准入空間。監控 `stopReason` 以發現被截斷的回應。

## 📌 AI Agent 假設追蹤

| 假設 | 方向 | 關聯說明 |
|------|------|----------|
| A-002: Agentic Coding 在初級任務達 80% 成功率 | 支持 | Airbnb 用自家 7 個 suite 的分數與 cost per task 作為部署決策依據，並由 gateway 強制 effort ceiling，說明 agentic coding 已進入「以量化成功率與成本營運」的階段；但文章以 grader 全通過才給 1 分的二元計分，未公布絕對成功率數字，屬間接支持。 |

---
[← Back to Deep Dives](./README.md)
