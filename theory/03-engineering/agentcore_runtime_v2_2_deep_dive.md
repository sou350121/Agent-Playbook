---
auto_generated: true
generated_at: "2026-11-15T05:45:57Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/architecture-patterns-for-fast-session-startup-on-amazon-bedrock-agentcore-runtime/"
signal_type: "blog_post"
---
# AgentCore Runtime V2：快照预热把冷启动压到 2 秒 (AgentCore Runtime V2: Snapshot Priming Flattens Cold Start to ~2s)

> 🔍 本文由 Moltbot 自動生成 | 2026-11-15
>
> **項目/工具**: Amazon Bedrock AgentCore runtime（platformVersion = "V2"）
> **鏈接**: https://aws.amazon.com/blogs/machine-learning/the-new-agentcore-runtime-elastic-optimized-and-consistently-fast-starts/
> **核心定位**: 把「每次 session 都初始化容器」改成「建置時初始化一次 → 凍結 microVM 快照 → 每個 session 還原」，使冷啟動不再隨鏡像體積與併發度增長

## ⚡ 快速判断 (Quick Verdict)（30 秒讀完這段就夠了）

- **一句話定位**：AgentCore runtime V2 用 microVM 快照取代 per-session 容器初始化，官方實測 P75 冷啟動約 2 秒，且從 200 MB 到 2 GB 鏡像都一樣；同時改為按實際用量回收記憶體計費
- **現在值得用嗎**：看場景——若你在 AgentCore 上跑鏡像大（>500 MB）、併發高的 agent，遷 V2 幾乎是純收益；若是 sub-second 語音/聊天體驗，光換 V2 不夠，還得做預熱
- **適合場景**：雲端部署的長時 agent、coding agent、需要開機載入大模型權重/CLI/browser 的 agent、突發流量明顯的產品
- **不適合場景**：自建 K8s/Fly.io/Cloud Run 已有成熟預熱方案的團隊；完全無狀態且冷啟動本來就 <100 ms 的微小 agent（換 V2 收益有限，但會多出每次部署幾分鐘的建置時間）
- **與前版核心差異**：V1 的冷啟動隨鏡像大小線性惡化（官方數據 ~5.4s → ~30s），V2 固定在小而穩的區間，且記憶體按真實使用而非峰值計費

## 是什麼 / 解決什麼問題

AgentCore runtime 是 Amazon Bedrock AgentCore 的託管運算層：每個 session 跑在獨立 microVM，閒置可縮到零，按實際消耗計費。聽起來很理想，但生產環境暴露了兩個結構性問題（官方 blog 自述）：

1. **記憶體按峰值計費**。session 從配置記憶體那一刻起就一直持有，就算後面根本沒用到，帳單仍追著高水位跑。對「偶爾爆一下、其餘時間閒著」的 agent，這是純浪費。
2. **冷啟動不可預測**。想要 <100 ms 就得保留熱環境，保留熱環境就是預留昂貴算力；不保留就會走「啟動新環境 → 拉鏡像 → 初始化 agent」的完整冷路徑。這段延遲隨鏡像大小與併發度惡化，而最糟的時刻恰恰是突發流量進來時——也就是使用者最有感的時候。

V2 的解法是把初始化搬到「建置期」。建立或更新 runtime 時，平台在乾淨 microVM 啟動你的容器、等第一個 `GET /ping` 健康（120 秒內必須到）、清掉作業系統檔案快取（讓快照變小）、凍結 microVM，把記憶體與磁碟存成快照。之後每個新 session 就是「還原快照」——行程從凍結點繼續跑，imports、物件、clients 都還在。

代價說清楚：**每次 create/update 現在要多花幾分鐘建快照**，初始化時間不再算進請求延遲，而是算進「部署到 READY」的時間。

## 技術架構拆解

### 核心設計決策

- **初始化 vs 請求處理的邊界重定義**：V2 之下 `init`（`app.run()` 之前的一切）只跑一次。所以傳統「lazy import、把初始化做小」的冷啟動建議**在這裡剛好相反**——延到 handler 的靜態工作，每個新 session 都要重付。
- **檔案快取在凍結前清空**：init 期間讀過的檔案不會因此變快；還原後的 session 第一次讀每個 block 都是從快照儲存取，之後才就近快取。這條決定了「把資料保留在記憶體物件裡」才有意義，單純 read 一次沒用。
- **映像檔 lazy load**：檔案按 block 首次存取時抓取，所以「大鏡像」不再直接等於「慢啟動」。
- **Build hook（建置鉤子）**：處理那些「無法活在行程記憶體裡」的東西——會執行後退出的 CLI、browser binary。平台在 build microVM 上會對你的容器發兩次 POST：
  - `Warmup-Type: memory`：快照前，載入的內容會進快照，每個 session 都有。
  - `Warmup-Type: disk`：測試還原後，在另一個 microVM 上，不會被快照，用途是「讓還原後的 session 第一次讀這些檔比較快」。
  - 兩次呼叫**共用 120 秒**；非 2xx、連不上、超時都會讓 create/update 失敗且**不重試**。
- **記憶體回收**：從「小而有效的記憶體剖面」啟動，按需分頁配置；依據「數十億次 session 的配置模式分析」調校，冷掉且不太可能再被存取時回收，帳單跟隨實際變化。
- **不可快照的安全邊界**：隨機數、nonce、密鑰、`time.time()`、monotonic timer、rate limiter、TTL cache、自行取得的憑證——全部必須在 handler 內建立。**init 時產生的隨機狀態在每個 session 都會一模一樣**，這在 blog 裡被明講為安全問題。

### 與前版/競品的關鍵差異

| 維度 | V1（原 runtime） | V2（新 runtime） |
|------|-----------------|------------------|
| 冷啟動（P75，含跨區 RTT） | 隨鏡像大小惡化，200 MB ~5.4s → 2 GB ~30s | 200 MB ~2 GB 約 2s（鏡像大小無影響） |
| 初始化時機 | 每個新 session | 每次 create/update 一次（建快照時） |
| 部署時間 | 快 | 每次 create/update 多幾分鐘 |
| 記憶體計費 | 按峰值持有到 session 結束 | 按實際使用，冷掉即回收 |
| 檔案讀取 | 每次 session 從鏡像讀 | 首次讀取從快照儲存取，之後就近快取 |
| 擴充手段 | 保留熱環境（成本高） | 快照還原 + build hook + 使用者互動時背景預熱 |
| 已運行 session 回應 | — | 約 200 ms（blog 舉例） |

### 架構/資訊流圖

```
[create / update runtime]
   │
   ├─ 啟動容器於乾淨 microVM
   ├─ 等 GET /ping 健康（≤120s）
   ├─ POST /warmup  (Warmup-Type: memory)  ← build hook 第一次
   ├─ 清 OS file cache
   └─ 凍結 microVM → 存 memory + disk 快照
                                    │
                                    ▼
[測試還原 microVM]
   └─ POST /warmup  (Warmup-Type: disk)   ← build hook 第二次（不進快照）

[每個新 session]
   ├─ 還原快照（行程續跑，imports/clients/物件都在）
   ├─ 首次讀映像 block → 從快照儲存抓（lazy）
   └─ 進 handler（per-session 邏輯、動態資料、隨機值）
```

## 實用評估

### 什麼場景值得用

- **鏡像偏大的 agent**：官方數據顯示 V1 在 2 GB 鏡像下 P75 冷啟動接近 30 秒，V2 還是 ~2 秒。這類差距直接決定產品體感。
- **會載入模型權重、embedding、資料集、browser binary、CLI toolchain 的 agent**：blog 指名這些是「受益最明顯」的類型；把它們在 init 時載進記憶體物件或 `/dev/shm`，或交給 build hook。
- **突發流量明顯的產品**：V1 最差的時刻就是併發高峰，V2 的啟動時間對併發不敏感。
- **記憶體尖峰型 agent**：長跑、偶爾爆記憶體但多數時間閒著，按真實用量計費能省實錢（具體省多少 blog 未給倍數，屬於個案取決）。

### 什麼場景不值得用 / 要小心

- **sub-second 語音或聊天**：blog 自己說得很直白——「對聊天和語音體驗，就算 2 秒也太慢」。必須再上一層：使用者打開 App/聊天窗時就背景 `invoke` 一個 warm-up 請求，把 session ID 綁到會話上。已運行 session 約 200 ms，這才是 sub-second 的來源。
- **需要拿 snapshot 存狀態的設計**：任何「init 時算一次就好」的假設都可能踩雷。時間、隨機、憑證、動態工具目錄（AgentCore Gateway tool catalog）、feature flag、價目表——都會被凍結成部署那一刻的陳舊值。session 可長達 8 小時（`idleRuntimeSessionTimeout` 預設 15 分鐘，`maxLifetime` 預設且上限 8 小時），動態資料必須在 handler 內掛 TTL 快取。
- **不能承受部署流程變重的團隊**：每次 create/update 多幾分鐘；hook 設計不良（超時、非 2xx）會直接讓部署失敗且不重試。
- **把大資料全塞記憶體**：快照變大 → 每個 session 都為這份記憶體付費，只是把延遲換成帳單。

### 遷移成本

- **最小路徑**：多數 agent 只要把 `platformVersion` 設成 `"V2"` 即可，不需改碼。
- **要拿全額收益**：把靜態工作（imports、clients、靜態資料、常駐 helper 子行程）搬進 init；關掉 init 期間建立的網路連線（還原後 socket 是陳舊的）；`UV_COMPILE_BYTECODE=1` 或 `pip install --compile` 預先編譯 bytecode；必要時設 build hook。
- **工作量估算**：小型 agent 半天內可完成並驗收；有 browser/CLI/本地模型的 agent 需要 1–3 天重構 + 壓測。blog 強烈建議**先量再優化**：用 CloudWatch `Latency`（TTFB）、`OverheadLatency`（平台部分）與兩者相減（你的程式時間）做 P90/P99 或 TM90，並以**生產級的新 session 到達率**測試，而非部署後跑幾十個 session。

## 對你的意義

對 agent 工程線來說，這是「冷啟動優化從調參變成架構問題」的一個明確信號。過去大家調 lazy import、調鏡像瘦身；V2 把變數換成「初始化放哪一側」——放 init 進快照，還是放 handler 每次重付。這個二分法可以直接套用到任何 serverless 型 agent 平台（Lambda SnapStart、Cloud Run 的類似思路），不只是 AWS。

判斷上我傾向：**如果你的 agent 要在雲上服務真人互動，這篇的檢查清單比 V2 本身更有價值**。特別是那張「哪些東西必須留在 handler」的表——隨機數、時鐘、憑證、動態目錄——這是快照式部署最容易埋的雷，而且隨機數那條是安全問題不是效能問題。建議立即做的是把自己的 agent 按這張表過一遍（哪怕你不在 AgentCore 上）；V2 遷移本身，等你有實際 P90 冷啟動數據再排。

## 關鍵代碼/配置片段

init 時建好物件（每個 session 繼承）：

```python
import json, pathlib
import boto3
import pandas as pd
from strands import Agent
from strands.models import BedrockModel
from bedrock_agentcore.runtime import BedrockAgentCoreApp

MODEL_ID = "us.anthropic.claude-haiku-5-5"

# Init: runs once, before the snapshot.
PROMPTS = json.loads(pathlib.Path("prompts.json").read_text())
ddb = boto3.client("dynamodb")
agent = Agent(model=BedrockModel(model_id=MODEL_ID), system_prompt=PROMPTS["system"])

app = BedrockAgentCoreApp()

@app.entrypoint
def invoke(payload):
    return agent(payload["prompt"])

app.run()  # /ping answers only after this line
```

建置鉤子配置：

```python
client = boto3.client("bedrock-agentcore-control")
client.create_agent_runtime(
    agentRuntimeName="my_agent",
    agentRuntimeArtifact={"containerConfiguration": {"containerUri": IMAGE_URI}},
    roleArn=ROLE_ARN,
    networkConfiguration={"networkMode": "PUBLIC"},
    platformVersion="V2",
    hooksConfiguration={
        "build": {
            "warmup": {"action": {"httpPost": {"path": "/warmup", "port": 8080}}}
        }
    },
)
```

注意：`UpdateAgentRuntime` 會**整組替換** hook 配置，想保留就得每次 update 都帶上。

使用者互動時背景預熱（sub-second 路徑）：

```python
session_id = f"chat-{uuid.uuid4().hex}"   # session ID 至少 33 字元
agentcore.invoke_agent_runtime(
    agentRuntimeArn=ARN,
    runtimeSessionId=session_id,
    payload=json.dumps({"action": "prime"}).encode(),
)
save_conversation(user_id, session_id)
```

> TODO: V2 的具體定價與記憶體回收帶來的實際帳單降幅，官方 blog 未給量化數字，需以自家 session 剖面實測。

---
[← Back to Deep Dives](./README.md)
