---
auto_generated: true
generated_at: "2026-11-25T06:46:34Z"
source_url: "https://github.com/pydantic/pydantic-ai/releases/tag/v2.74.0"
signal_type: "blog_post"
---
# pydantic-ai v2.74.0：把 computer tool 契约收进核心，ComputerTool 成为一等公民 (Pydantic AI v2.74.0: The Computer Tool Contract Lands in Core)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-25
>
> **项目/工具**: pydantic-ai (含 pydantic-ai-harness / pydantic-ai-slim / pydantic-evals)
> **链接**: https://github.com/pydantic/pydantic-ai/releases/tag/v2.74.0
> **核心定位**: 过去「computer use」是各家 Agent 框架各自拼装的胶水层，v2.74.0 把它变成核心库里的稳定契约（`pydantic_ai.computer_use` + `ComputerTool`），并在 harness 层配齐 11 种沙箱的桌面能力与 Anthropic/OpenAI/Google 的原生 computer tool 通路

## ⚡ 快速判断 (30 秒读完这段就够了)

- **一句话定位**：pydantic-ai 把「模型點滑鼠、敲鍵盤、看截圖」這件事從第三方插件提升為核心库的正式抽象，並讓所有主流沙箱一鍵帶桌面
- **现在值得用吗**：看場景 —— 如果你在 Python 生態裡做 GUI Agent（瀏覽器自動化、桌面軟體操作），這是目前最完整的「型別安全 + 多後端」方案；如果你只是要跑 headless 網頁抓取，用它反而是殺雞用牛刀
- **适合场景**：Python 後端的 GUI Agent、需要 Anthropic/OpenAI/Gemini 三家原生 computer tool 來回切換的團隊、需要在 Docker/E2B/Daytona/Modal 等多種沙箱上跑同一套 Agent 程式碼
- **不适合场景**：純 API 的 agent（用不到螢幕）、對每次呼叫延遲極敏感的即時互動、RAM/預算極緊的部署（截圖 token 成本是真實成本）
- **与 MCP / Browser-use 等競品核心差異**：pydantic-ai 不綁定單一後端或單一模型，而是把「Display 協定」抽象出來——同一個 `ComputerUse()` 可以驅動 Claude 原生 computer tool、OpenAI 原生 computer tool，或降級為普通 function tool 給任意模型

## 是什么 / 解决什么问题

GUI Agent（computer use）在 2025–2026 年從 demo 變成真需求：模型能看截圖、點擊、輸入，於是「幫我打開 Firefox 查一下 Python 當前版本」這種任務開始有實用價值。但工程上是個爛攤子——每個框架都自己定義一套「螢幕動作」的資料結構，每個向量沙箱都要手寫一套 VNC/xdotool 的膠水，換個模型就要重寫工具調用層。

pydantic-ai v2.74.0 做的是**收斂**：新增 `pydantic_ai.computer_use` 模組與 `ComputerTool`，把 computer tool 的契約（參數結構、結果格式、metadata 記錄）放進核心庫，而不是留在 harness 擴充包裡。同時把 `ComputerTool` 加進 `NATIVE_TOOLS_REQUIRING_CONFIG`——這是一個明確的設計宣言：computer tool 不是普通 function，它**需要配置一個真正能跑的 computer**才能工作，框架應該在型別層面就知道這件事。

配套的 harness 層則一次把生態補齊：`ComputerUse()` capability、`SupportsDisplay` / `Display` / `DisplayAction` 協定，以及一整排沙箱的 `desktop=True` 選項（DockerContainer、DaytonaSandbox、E2BSandbox、SpritesSandbox、BoxLiteSandbox、BoxdSandbox、SmolSandbox、RenderSandbox、ModalSandbox、KubernetesSandbox、OpenSandbox）。

## 技术架构拆解

### 核心设计决策

- **契約進核心，執行留 harness**：`ComputerTool` 與 `COMPUTER_KIND` 在 `pydantic_ai.computer_use`（核心），實際的螢幕操作在 `pydantic_ai_harness.computer_use`。理由是核心庫要保持輕量且無 Docker/VNC 依賴，但工具契約必須穩定——否則下游 agent 無法跨版本推理自己的工具集。
- **Display 協定而非固定實作**：自訂 workpace 只需實作 `SupportsDisplay`（回傳 `Display`，其有三個方法：`display_size()`、`screenshot()` 回傳 PNG bytes、`act()` 執行一個 `DisplayAction`），可選實作 `SupportsZoom` 與 `SupportsCursorPosition`。座標一律以**截圖像素**為單位，避免跨解析度的模糊地帶。
- **原生優先，可降級**：`ComputerUse(native=True)`（預設）時，若模型是 Claude / OpenAI / Gemini，就把 provider 自己的 computer tool 送過去；其餘模型（或 `native=False`）則降級為普通 function tool。這是取捨的藝術——原生 tool 通常有更好的模型側支援，但功能子集更窄。
- **畫面穩定的「雙幀確認」**：截圖前會持續截到「連續兩張一致」才返回，預設最多等 2 秒（`computer_use` 的等待參數）。這解決了 GUI 自動化最常見的競態：點完之後畫面還在動，模型拿到半張過渡態截圖就會亂點。
- **Prompt caching 自動開啟**：`get_model_settings()` 會打開快取，除非 run 的設定已經明確指定。理由是每次請求都會重送先前所有截圖——這是 computer use 的主要成本項。

### 与前版/竞品的关键差异

| 维度 | 手搓 / 单点方案（如 browser-use、各家 driver） | pydantic-ai v2.74.0 |
|------|------------|------------|
| 工具契约 | 各框架自定，換框架即重寫 | `ComputerTool` 進核心，型別穩定 |
| 後端抽象 | 通常綁定 Playwright/CDP 或單一 VNC | `SupportsDisplay` 協定，Docker/E2B/Daytona/Modal/K8s 等皆可 |
| 模型原生支援 | 通常只針對一家最佳化 | Anthropic、OpenAI（GPT-5.4+）、Google（Gemini）三家原生 tool 直通 |
| 動作覆蓋 | OpenAI 原生 tool 缺 zoom / triple-click / 按鍵按住 / 讀游標 | 降級為 function tool 即可取得完整動作集 |
| 安全性基線 | 需自行設計審批與私網阻擋 | `ApprovalRequired` hook + PlaywrightBrowser egress policy |
| 持久化執行 | 需自己接 Temporal/Prefect | 每個 computer call = 一個 durable step |

### 架构/信息流图

```
使用者任務："打開 Firefox 查 python.org 上的版本"
        │
        ▼
   Agent (pydantic-ai)
        │  capabilities=[DockerContainer(desktop=True), ComputerUse()]
        ▼
 ┌───────────────────────────────────────────────┐
 │ ComputerUse (harness capability)              │
 │  ├─ get_native_tools(): 依模型送原生 tool     │
 │  ├─ get_model_settings(): 開啟 prompt caching │
 │  └─ wrap_run(): run 結束時釋放未放開的滑鼠鍵  │
 └──────────────────┬────────────────────────────┘
                    │ 呼叫 computer tool（actions 陣列）
                    ▼
        ┌───────────────────────┐
        │  Workspace（沙箱）     │
        │   SupportsDisplay      │
        │    ├─ screenshot() PNG │
        │    ├─ act()            │
        │    └─ display_size()   │
        │  內部：Xvfb + xdotool  │
        │        + scrot + 視窗  │
        └───────────────────────┘
                    │
                    ▼
        截圖回傳 → 模型看見結果 → 下一個動作
        （截圖累積 → token 成本主因 → 快取與 1280x800 建議）
```

桌面環境本身需要 Xvfb（若無 X server）、xdotool、xwininfo、scrot、setsid，以及 fluxbox/tint2/xterm 作為視窗管理器與終端（E2B 例外，用其 template 的 XFCE）。第一次使用若缺失會自動以 root 或免密 sudo 安裝——這是便利與「首次啟動等很久」之間的取捨。

## 实用评估

### 什么场景值得用

- **多沙箱、同一份 Agent 程式碼**：同一組 `Agent(...)` 定義可在 Docker 本地跑、在 E2B 雲端跑、在 Kubernetes 用 `warm_pool=` 預熱跑。這對「本地 debug → 雲端擴展」的工作流價值極高。
- **跨模型供應商的可攜性**：今天用 Claude 的 computer tool，明天要換 Gemini 或降級到開源模型——`ComputerUse(native=False)` 讓你不用改工具層。
- **需要審批閘門的高風險操作**：`before_tool_execute` hook 裡對非唯讀動作拋 `ApprovalRequired`，即可做到「看畫面不用問、動滑鼠要問」，比整段 prompt 約束可靠得多。
- **需要 durable 執行的長任務**：每個 computer call 是一個 durable step，配合 TemporalDurability / PrefectDurability，中途崩潰可續跑。

### 什么场景不值得用

- **只要抓網頁資料**：headless HTTP + readability 的成本比截圖循環低一到兩個數量級。別為了一個 `curl` 開一台 Xvfb。
- **即時互動 / 低延遲要求**：每次 computer call 都會消耗一次 model request，長任務很容易撞到預設 `request_limit=50`；截圖 + 推理的往返延遲不適合秒級反應場景。
- **成本敏感的批量任務**：每次請求都重送先前所有截圖，是主要開銷。Claude 在 200k context 模型上超過 100 張圖就拒絕請求——這是硬牆，不是「建議」。
- **資源受限環境**：桌面棧（Xvfb/core utils/fluxbox）加上容器本身，對 2GB RAM 級別的機器是有感知的負擔。
- **只讀 workspace**：框架直接在設計上就不給 computer tool——因為「在螢幕上動作」可以改動 workspace 裡任何東西。這是對的，但也意味著你不能在唯讀環境驗證 GUI 流程。

### 迁移成本

- **從自寫 Playwright 脚本遷移**：主要是重寫「動作 → 判斷」迴圈，讓模型取代硬編碼的選擇器。工具層可刪掉一大段；但你要重新思考安全性（頁面/URL 可由攻擊者影響時，egress policy 是預設開啟的）。
- **從舊版 pydantic-ai harness 遷移**：把 `pydantic_ai_harness` 的 computer 相關 import 改指向 `pydantic_ai.computer_use`（`COMPUTER_KIND` 等）。`ComputerTool` 現在列入 `NATIVE_TOOLS_REQUIRING_CONFIG`，若你之前手工裝配 tool 而沒給 computer 配置，會在啟動階段就被型別/驗證擋下——這是好事，早失敗好過半夜 alert。
- **其他需注意的 breaking 變更**：GPT-6.2 續接 response 時若只用 `openai_previous_response_id` 而不傳 `message_history`，會繼承該 response 的 static instructions（解法：傳 `message_history`，或 `OpenAIModelProfile(openai_responses_stable_instructions_as_input=False)`）；Gemini 經 OpenAIChatModel 串流時，usage 現在報**終值**而非累加值——成本數字會下降，`UsageLimits` 的 token 上限會更晚觸發。

## 对你的意义

Ken 的 **Agent + UI** 方向正好在這次更新的靶心上。如果你的 agent builder / visual workflow 需要「讓 agent 操作一個真實的 UI」（不管是自家產品的 E2E 驗證，還是讓使用者用自然語言驅動一個 web app），pydantic-ai 這套是目前 Python 側結構最清楚的選擇：契約在核心、後端可插拔、三家模型原生通。

但別急著全面上。務實的做法：

1. **先在 Docker 上跑一個最小任務**（文檔給的「打開 Firefox 查 Python 版本」就是很好的 smoke test），量測兩件事：首次鏡像建置時間、以及一次 20 步任務的 token 成本。
2. **只在你的 eval pipeline 裡導入**——把它當成「真實 UI 的端到端測試器」，這是投資報酬率最高的用法：風險低（跑在沙箱）、價值高（測到真實渲染與互動）。
3. **產品功能裡要慎重**：截圖累積的 token 成本 + Claude 100 張圖的上限，意味著「長流程 agent」需要精心的截圖管理（例如主動要求 `zoom` 局部而非全螢幕、控制 1280x800）。
4. **安全面**：這次 release 順帶修了 6 個 CVE，其中 4 個在 `PlaywrightBrowser` 的私網阻擋（IPv6 site-local `fec0::/10`、NAT64 內嵌雲 metadata、query 反斜線導致 host 判空、WebRTC/WebTransport/WebSocketStream/FedCM 繞過 egress policy）。如果你現在就用 `PlaywrightBrowser` 開攻擊者可控的頁面，**這是升級的理由，不是選配**。另外 `ElevenLabsAgentsRealtimeModel` 在 2.58.0–2.62.0 會把 `secret__` 動態變數（設計上放 API key/token）完整寫進 trace span，`include_content=False` 也擋不住——用語音 agent 的務必升。

## 关键代码/配置片段

最小可用範例（引自官方 Computer Use 文檔）：

```python
from pydantic_ai import Agent
from pydantic_ai_harness import ComputerUse, DockerContainer

agent = Agent('anthropic:claude-sonnet-5-5', capabilities=[DockerContainer(desktop=True), ComputerUse()])

result = agent.run_sync('Open Firefox and find the current Python release on python.org.')
print(result.output)
```

裝載：

```bash
pip install "pydantic-ai-harness[anthropic]"
# 把 anthropic 換成你的 provider extra，設定 API key，並確保 Docker 在跑
```

只審批「會動到東西」的動作（引自官方文檔）：

```python
from pydantic_ai import ApprovalRequired
from pydantic_ai.capabilities import Hooks
from pydantic_ai.computer_use import COMPUTER_KIND

hooks = Hooks()

@hooks.on.before_tool_execute
async def ask_before_acting(ctx, *, call, tool_def, args):
    looking = {'screenshot', 'zoom', 'wait', 'cursor_position'}
    if tool_def.tool_kind == COMPUTER_KIND.id and not ctx.tool_call_approved:
        if any(action.type not in looking for action in args['actions']):
            raise ApprovalRequired
    return args
```

自訂 workpace 的顯示層（協定要點，非範例程式碼）：實作 `SupportsDisplay.display`，回傳**每次都相同**的 `Display`（或 `None`），且不得做 I/O；`Display` 需提供 `display_size()`、`screenshot()`（PNG bytes）、`act(DisplayAction)`；無法精確執行的動作拋 `UnsupportedActionError`。要支援 `zoom` / `cursor_position` 動作，另需實作 `SupportsZoom` / `SupportsCursorPosition`。

Temporal 上的必要設定（引自官方文檔，直接影響正確性）：

```python
ActivityConfig(
    start_to_close_timeout=...,                  # 須長於你最長的呼叫，預設 60 秒不夠
    retry_policy=RetryPolicy(maximum_attempts=1) # 一次即止，避免同一動作跑兩次
)
# 另外用 model_activity_config=ActivityConfig(retry_policy=RetryPolicy())
# 與 toolset_activity_config 把重試還給其他工具
# 幾個 step 之後截圖會超過 Temporal 2 MB payload 限制 → 需啟用 external storage
```

---
[← Back to Deep Dives](./README.md)
