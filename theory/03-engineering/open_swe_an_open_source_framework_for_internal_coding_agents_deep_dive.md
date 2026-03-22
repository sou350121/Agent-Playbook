---
auto_generated: true
generated_at: "2026-03-22T05:47:24Z"
source_url: "https://blog.langchain.com/open-swe-an-open-source-framework-for-internal-coding-agents/"
signal_type: "significant_update"
---
# Open SWE：內部編碼 Agent 的開源框架 (Open SWE: An Open-Source Framework for Internal Coding Agents)

> 🔍 本文由 Moltbot 自動生成 | 2026-03-22
>
> **項目/工具**: Open SWE (LangChain)
> **鏈接**: https://blog.langchain.com/open-swe-an-open-source-framework-for-internal-coding-agents/
> **核心定位**: 基於 Deep Agents + LangGraph 的開源框架，將 Stripe/Ramp/Coinbase 等公司的內部編碼 Agent 架構模式封裝為可定制基礎設施

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：開源框架，讓工程團隊能快速搭建類似 Stripe Minions、Ramp Inspect 的內部編碼 Agent
- **現在值得用嗎**：是 —— 如果你的團隊正在考慮構建內部 coding agent，這是目前最完整的開源起點
- **適合場景**：中大型工程團隊、需要與現有開發流程（Slack/Linear/GitHub）深度集成、希望隔離 agent 執行風險
- **不適合場景**：小團隊（<10 人）、無需隔離沙箱的簡單自動化、已有成熟內部 agent 系統
- **與競品核心差異**：相比從零自建，Open SWE 提供了經過生產驗證的架構模式 + 可插拔組件 + 持續升級路徑

## 是什麼 / 解決什麼問題

過去一年，多家工程組織獨立構建了內部編碼 Agent 系統：Stripe 的 Minions、Ramp 的 Inspect、Coinbase 的 Cloudbot。這些系統雖然獨立開發，但收斂到了相似的架構模式：隔離雲沙箱、精選工具集、子 Agent 編排、與開發者工作流集成。

LangChain 今天發布的 Open SWE 正是將這些生產環境驗證的模式封裝為開源框架。它不是另一個「通用編碼助手」，而是專門為**工程組織構建內部 agent**提供的基礎設施。

核心解決的問題：
1. **重複造輪子**：每個團隊都要從零設計沙箱、工具集、編排邏輯
2. **架構決策風險**：獨立探索可能踩坑，Open SWE 收斂了多家公司的最佳實踐
3. **維護成本**：基於 Deep Agents 組合而非 fork，可以享受上游改進而無需重建自定義層

## 技術架構拆解

### 核心設計決策

Open SWE 的架構選擇反映了生產環境的實際教訓：

| 設計維度 | 選擇 | 理由 |
|----------|------|------|
| **執行環境** | 隔離雲沙箱 | 將錯誤的爆炸半徑限制在沙箱內，沙箱內授予完整權限無需逐個審批 |
| **工具策略** | 精選 (~15 個) 而非累積 | Stripe 經驗：500 個工具需要精心維護，質量比數量重要 |
| **觸發入口** | Slack/Linear/GitHub | 在開發者現有工作流中相遇，避免上下文切換 |
| **上下文注入** | AGENTS.md + 任務上下文 | 倉庫級知識（規範/測試要求）+ 任務級信息（issue/線程歷史）雙層 |
| **編排機制** | 子 Agent + 中間件 | 模型驅動的靈活性和確定性邏輯分離 |
| **基礎框架** | 組合 Deep Agents | 避免 fork，保留升級路徑和自定義能力 |

### 與前版/競品的關鍵差異

Open SWE 與三家公司的內部系統對比：

| 維度 | Open SWE | Stripe (Minions) | Ramp (Inspect) | Coinbase (Cloudbot) |
|------|----------|------------------|----------------|---------------------|
| **Harness** | 組合 (Deep Agents/LangGraph) | Forked (Goose) | 組合 (OpenCode) | 從零自建 |
| **沙箱** | 可插拔 (Modal/Daytona/Runloop/LangSmith) | AWS EC2 devboxes (預熱) | Modal containers (預熱) | 自研 |
| **工具數量** | ~15，精選 | ~500，按 agent 精選 | OpenCode SDK + 擴展 | MCPs + 自定義 Skills |
| **上下文** | AGENTS.md + issue/線程 | 規則文件 + 預水合 | OpenCode 內置 | Linear-first + MCPs |
| **編排** | 子 Agent + 中間件 | Blueprints (確定 + 能動) | Sessions + 子會話 | 三種模式 |
| **觸發** | Slack, Linear, GitHub | Slack + 嵌入按鈕 | Slack + web + Chrome 擴展 | Slack-native |
| **驗證** | Prompt 驅動 + PR 安全網 | 3 層 (本地 + CI + 1 重試) | 視覺 DOM 驗證 | Agent councils + 自動合併 |

### 架構/信息流圖

```
┌─────────────────────────────────────────────────────────────────┐
│                    觸發層 (Invocation)                           │
│    Slack (@mention)  │  Linear (comment)  │  GitHub (tag)       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    上下文組裝層                                   │
│    AGENTS.md (倉庫規範)  +  Issue/Thread 完整歷史                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Deep Agents 核心 (Agent Harness)                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐     │
│  │  規劃器     │  │  工具調用   │  │  子 Agent 生成 (task) │     │
│  │ write_todos │  │  execute/   │  │  獨立上下文 + 待辦   │     │
│  │             │  │  read_file  │  │                     │     │
│  └─────────────┘  └─────────────┘  └─────────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    中間件層 (Middleware)                         │
│  check_message_queue_before_model  →  注入跟隨消息               │
│  open_pr_if_needed               →  PR 安全網                   │
│  ToolErrorMiddleware             →  錯誤處理                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    沙箱執行層 (Sandbox)                          │
│    Modal │ Daytona │ Runloop │ LangSmith │ 自定義後端           │
│    每個會話獨佔沙箱，自動重建，並行執行                          │
└─────────────────────────────────────────────────────────────────┘
```

## 實用評估

### 什麼場景值得用

1. **中大型工程團隊（20+ 工程師）**：有足夠的開發工作流（Slack/Linear/GitHub）支撐 agent 使用頻率，團隊規模使得自動化收益顯著

2. **需要隔離風險的場景**：agent 需要執行 shell 命令、修改代碼、調用內部 API —— 沙箱隔離可以防止錯誤影響生產系統

3. **已有成熟開發工具鏈**：使用 Linear 做 issue 追蹤、Slack 做溝通、GitHub 做代碼管理 —— Open SWE 直接集成這些工具而非要求切換

4. **希望快速試點內部 agent**：相比從零自建（可能需要數月），Open SWE 可以在數天內部署試點，驗證價值後再深度定制

### 什麼場景不值得用

1. **小團隊（<10 人）**：溝通成本低，agent 的收益可能不抵配置和維護成本

2. **簡單自動化需求**：如果只是需要運行固定腳本或 CI/CD 流程，不需要能動的 agent 架構

3. **已有成熟內部 agent 系統**：如果已經有類似 Stripe/Ramp 的自建系統，遷移成本可能高於收益

4. **對特定雲 provider 有強制要求**：雖然支持多個沙箱後端，但如果需要特定的內部基礎設施，可能需要自實現沙箱適配層

### 遷移成本

從現有工作流遷移到 Open SWE：

| 遷移步驟 | 工作量估算 | 說明 |
|----------|------------|------|
| **GitHub App 創建** | 30 分鐘 | 用於 PR 操作和 webhooks |
| **LangSmith 設置** | 1-2 小時 | 追蹤和調試 agent 執行 |
| **Slack/Linear 集成** | 2-4 小時 | Bot token、webhook 配置 |
| **沙箱 provider 選擇** | 1-2 小時 | Modal/Daytona/Runloop 賬號設置 |
| **AGENTS.md 編寫** | 2-8 小時 | 編碼規範、測試要求、架構決策文檔 |
| **自定義工具開發** | 可選 | 內部 API、部署系統、測試框架適配 |

總體來說，基礎設置可以在 1 天內完成，深度定制（自定義工具、中間件）可能需要 1-2 周。

## 對你的意義

如果你正在關注 Agent + UI 方向，Open SWE 有幾個值得注意的信號：

**1. 企業級 agent 架構正在收斂**
Stripe/Ramp/Coinbase 獨立開發卻收斂到相似模式，說明這套架構經過了生產驗證。關鍵模式（隔離沙箱、精選工具、子 agent 編排）可能成為未來 1-2 年的標準實踐。

**2. 「組合而非 fork」的架構智慧**
Open SWE 基於 Deep Agents 組合而非 fork，這是一個重要的工程決策。它保證了：
- 上游改進（上下文壓縮、prompt 緩存、規劃效率）可以自動流入
- 自定義層（工具、prompt、中間件）可以獨立維護
- 避免 fork 帶來的分叉和合併負擔

這對你構建自己的 agent 系統有參考價值：**找到合適的基礎層，在其上構建自定義，而非從零開始或 fork 後陷入維護困境**。

**3. 上下文工程的重要性**
AGENTS.md 模式值得借鑒 —— 將倉庫級知識（編碼規範、測試要求、架構決策）編碼為 agent 可讀的文件，在每次執行時自動注入。這比在 prompt 中硬編碼更靈活、更易維護。

**具體建議**：
- **立即試用**：如果你的團隊正在考慮內部 agent，Open SWE 是目前最完整的開源起點
- **觀望**：如果團隊規模小或需求簡單，可以等更多案例沉澱
- **借鑒模式**：即使不使用 Open SWE，其架構模式（沙箱隔離、工具精選、中間件編排）值得在自建系統中參考

## 關鍵代碼/配置片段

Open SWE 的核心配置示例（來自博客）：

```python
create_deep_agent(
    model="anthropic:claude-opus-4-6",
    system_prompt=construct_system_prompt(repo_dir, ...),
    tools=[
        http_request,
        fetch_url,
        commit_and_open_pr,
        linear_comment,
        slack_thread_reply
    ],
    backend=sandbox_backend,
    middleware=[
        ToolErrorMiddleware(),
        check_message_queue_before_model,
        open_pr_if_needed,
    ],
)
```

AGENTS.md 示例結構（倉庫根目錄）：

```markdown
# Agent Guidelines for This Repository

## Coding Conventions
- Use TypeScript strict mode
- All functions must have return type annotations
- Prefer composition over inheritance

## Testing Requirements
- Run `npm test` before committing
- New features require unit tests
- Integration tests for API endpoints

## Architectural Decisions
- Services communicate via message queue
- Database migrations use Flyway
- Authentication via OAuth2 + JWT
```

## 📌 AI Agent 假設追蹤

| 假設 | 方向 | 關聯說明 |
|------|------|----------|
| A-002: Agentic Coding 在初級任務達 80% 成功率 | 支持 | Open SWE 專注於內部編碼 agent，將生產驗證的架構模式開源化，降低了團隊構建 coding agent 的門檻，加速 agentic coding 在工程實踐中的普及 |

---
[← Back to Deep Dives](./README.md)
