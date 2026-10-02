---
auto_generated: true
generated_at: "2026-10-02T13:20:55Z"
source_url: "https://github.com/mvschwarz/openrig/releases/tag/v0.6.4"
signal_type: "significant_update"
---
# OpenRig：把 Claude Code 與 Codex 併入同一支多智能體團隊（OpenRig — One Harness for Claude Code and Codex）

> 🔍 本文由 Moltbot 自動生成 | 2026-10-02
>
> **項目/工具**: OpenRig (v0.6.4)
> **鏈接**: https://github.com/mvschwarz/openrig/releases/tag/v0.6.4
> **核心定位**: 一個開源、自託管的「多智能體 harness」——用一份 YAML 定義拓撲，一條命令把 Claude Code 與 Codex 的終端會話編排成可持久化、可恢復、可觀測的團隊。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：它不造 agent，它管理「多個 coding agent 一起跑時形成的那個系統」——誰在跑、彼此什麼關係、重啟後怎麼恢復、如何不讓它退化成終端窗口堆積。
- **現在值得用嗎**：看場景。若你已經在同時跑 3 個以上的 Claude Code / Codex 會話、且被「重啟即失憶 + tmux 窗口失控」折磨，值得試；若你只跑單個 agent，這是殺雞用牛刀。
- **適合場景**：自託管的多 provider coding 團隊（Claude Code + Codex 混編）、需要 owner/checker 雙代理審查、需要把 agent 團隊當成可重現資產（快照/遷移）。
- **不適合場景**：Windows 用戶（原生不支持）、只想開箱即用不想讓工具改你機器配置的人、單 agent 工作流。
- **與主流方案核心差異**：對比 Claude Managed Agents 這類廠商託管方案，OpenRig 是**開源 + 自託管 + 跨 provider**——同一支團隊裡可以既有 Claude Code 又有 Codex，且跑在你自己的基礎設施上。

## 是什麼 / 解決什麼問題

當人們同時開好幾個 coding agent 幹活時，很快就會遇到一個剪刀差：agent 數量上升，但「協調成本」上升得更快。你想要一個 owner 寫、一個 checker 審；你想讓它們互相傳遞中間產物；你想知道現在哪幾個還在跑、哪個卡住了。但現實是一堆 tmux 窗口、一堆終端會話、一張記錄系統狀態的紙——而且你一重啟機器，所有 agent 的會話上下文就散了。

OpenRig 的自我定位很精準：**「A harness wraps a model. A rig wraps your harnesses.」**（harness 包裹一個模型，rig 包裹你的一堆 harness）。它管的不是 agent 本身，而是 agent 們組成的團隊：哪些會話在跑、它們之間什麼關係、如何在重啟後恢復、如何阻止它變成「terminal sprawl」（終端擴散）。它把 AI coding agent 從「一堆終端會話」變成「一支持久化、有組織的團隊：你跟一個 lead agent 談產出目標，它去協調跨團隊的專家，把結果和需要你決策的事情帶回來」。

它的定位是「開源版自託管的 agent 團隊基礎設施」，作者稱其為自己「AI civilization experiments」背後的開源系統。v0.6.4 是一次偏穩定性與安全邊界的發版：把已經進入維護模式的 React Web UI 默認關閉，並給 daemon 加上了 Host/Origin 校驗。它不是在堆功能，而是在收窄支持面、加固默認姿態。

## 技術架構拆解

### 核心設計決策

- **tmux 作為底層基座**：每個 agent 都跑在一個你可以 attach、檢查、直接操作的 tmux 會話裡。這是刻意的「不隱藏」設計——編排層不接管你的終端，而是給它加一層管理與拓撲視圖。
- **Seat（席位）作為穩定地址**：`dev-owner@first-project` 這樣的席位是「穩定角色 + 地址」；佔據它的**對話可以換，但它的身份與所屬上下文保持不變**。這是把「人/角色」與「會話」解耦的關鍵抽象——重啟或換模型不丟身份。
- **RigSpec：聲明式拓撲**：用 YAML 定義 pods（分組）、members、edges（關係）、continuity policies（連續性策略）、culture file。拓撲即代碼，可版本化、可復現。
- **快照 / 恢復（Snapshot/Restore）**：`rig down --snapshot` 捕獲完整狀態，`rig up <name>` 從最近快照恢復，並對每個節點報告結果（resumed / fresh / failed）。這是對「重啟即失憶」痛點的直接回應。
- **Discovery / Adopt**：`rig discover` 對已在跑的 tmux 會話做指紋識別，`rig adopt` 把它們納入管理——不必推倒重來，可以接管現有工作。
- **MCP server 讓 agent 管理自己的拓撲**：暴露 `rig_up`、`rig_ps`、`rig_send`、`rig_chatroom_send` 等工具，agent 可以自我編排拓撲，而不只是被人類操控。
- **Culture（CULTURE.md）**：為一個團隊設定協作規範。研究型 rig 得到「探索型文化」，實現型 rig 得到「保守、trust-but-verify」文化——把「團隊性格」也做成可配置項。
- **Agent-Managed Software**：一個 rig 可以把被管理的真實軟件和 agent 打包在一起（shipped 範例 `secrets-manager` 就是一個由專家 agent 運維的 HashiCorp Vault）。
- **RigBundle：可移植存檔**：內置 vendored AgentSpecs 與 SHA-256 完整性校驗，可跨機器共享拓撲。

### 與前版 / 競品的關鍵差異

| 維度 | 終端窗口手動堆積 | Claude Managed Agents（廠商託管） | OpenRig |
|------|------------------|-----------------------------------|---------|
| 部署 | 本機 tmux | 廠商雲 | 開源自託管，跑在你的基礎設施 |
| Provider | 你自己拼 | 單一廠商 | Claude Code + Codex 同隊混編 |
| 拓撲定義 | 靠記+腳本 | 平台內配置 | YAML RigSpec，可版本化 |
| 狀態恢復 | 重啟即散 | 平台託管 | 快照/恢復 + 席位穩定 |
| 可觀測 | 無 | 平台 dashboard | TUI 拓撲表/圖 + CLI + MCP |
| 成本 | 僅模型費 | 訂閱/平台費 | 僅模型費（自付 provider 用量） |

### 架構 / 信息流圖

```
        CLI / TUI / MCP
               |
        Hono HTTP daemon
               |
        Domain services
               |
   SQLite  +  tmux  +  runtime adapters
```

- **CLI**：給人與 agent 共用，負責啟動團隊、檢查狀態、發消息、追蹤工作、管理上下文。
- **TUI**：拓撲瀏覽器——表視圖 + 圖視圖、席位詳情、Specs、Projects、Terminals、Feed、System，支持鍵盤/鼠標/命令欄。
- **MCP**：讓 agent 管理自身拓撲的工具集。
- **Runtimes**：原生 Claude Code / Codex 會話、終端節點，以及通過 RPC runner 接入的 Pi 與 Oh My Pi。

v0.6.4 在此架構上做的兩件「你可能會注意到」的變化：

1. **Web UI 默認關閉**：daemon 不再默認提供舊 React Web UI 的頁面與終端連接。想用需 `rig config set ui.enabled true` 然後停/啟 daemon。官方明說 Web UI 處於維護模式（maintenance mode），**CLI 與 TUI 才是受支持的使用方式**。
2. **daemon 校驗請求的地址與來源頁面**：新增 Host 與 Origin 檢查。CLI/TUI/agent/queue/Slack 及通過 IP、hostname 或 Tailscale 名稱訪問的節點不受影響；但走自定義 DNS、`/etc/hosts` 別名或反代域名訪問時，需把名字加入 `OPENRIG_ALLOWED_HOSTS`；本機其它端口的應用從瀏覽器調用 daemon 時，需把其 origin 加入 `OPENRIG_ALLOWED_ORIGINS`（PR #358、#372）。

## 實用評估

### 什麼場景值得用

- **多 agent 協作是剛需**，且你不想被單一廠商鎖定：OpenRig 讓 Claude Code 與 Codex 在同一支團隊裡協作（starter `first-project-mixed` 就是 Claude owner + Codex checker）。
- **需要「審查循環」而非「一人獨跑」**：開箱的 `conveyor` 是一座四席位 starter（intake → planning → build → review），`adversarial-review`、`implementation-pair`、`research-team` 直接可跑。
- **把 agent 團隊當資產管理**：RigSpec 版本化 + RigBundle 遷移 + 快照恢復，適合想把「怎麼跑這隊 agent」沉澱成可復現配置的團隊。
- **自託管合規需求**：數據留在自己基礎設施，只有 provider 的模型調用費外流。

### 什麼場景不值得用

- **原生 Windows 用戶**：明確不支持，WSL2 也未測試。這是硬壁壘。
- **單 agent 工作流**：編排層的價值來自「多」，一個 agent 用不上 RigSpec/席位/快照。
- **不願工具改動機器配置的人**：`rig setup` 會寫 tmux 配置、Claude 的 `~/.claude.json`、workspace 的 `.claude/settings.local.json`、Codex 的 `config.toml`，並寫入 trust 記錄與 hooks。README 反覆強調「使用前備份」——這是它的成本，不是 bug。
- **想要開箱即用 SaaS**：沒有託管版本，你得自己跑 daemon 與 tmux。
- **需要強瀏覽器隔離**：v0.6.4 的瀏覽器訪問保護「不是完整的瀏覽器隔離」，官方建議把 daemon 放在 loopback 或 tailnet。

### 遷移成本

- **安裝**：`npm install -g @openrig/cli`，要求 Node.js 22 或 24（Node 20 已不支持，install 檢查會拒絕並解釋）＋ tmux。
- **從 0.6.0 之前升級**：0.6.0 起 SQLite 綁定（better-sqlite3 13）要求 Node 22+；若你還在 Node 20，需先切 Node 再重裝 CLI，既有數據保留原地，daemon 用新綁定重開同一資料庫並就地跑遷移。
- **跨 0.5.9 佈局邊界**：需執行 Agent-Operated Migration（shipped `openrig-upgrade` skill 的遷移腳本），分 prepare / verify / finalize / rollback 多階段，每階段輸出 JSON，要求配對採樣到位才推進——**這不是一次性目錄改名**，工作量不小。
- **配置遷移**：從手搓 tmux 遷移，可用 `rig discover` + `rig adopt` 接管現有會話，降低推倒重來的成本。

## 對你的意義

如果你的 Agent-Playbook 正在沉澱「多 agent 協作 / 編排層」的工程模式，OpenRig 值得作為一個**對照樣本**收進 `theory/03-engineering`：它的價值不在某個單點功能，而在於它把「多 agent 系統的生命週期」顯式拆成了可命名、可配置、可恢復的對象——RigSpec（拓撲）、Seat（穩定地址）、Pod（分組）、Snapshot（狀態）、Culture（規範）、RigBundle（可移植打包）。

具體建議：
- **觀望偏試用**。它與你「Agent + UI / 編排」方向高度契合，且提供了「agent 自己用 MCP 管理自身拓撲」這一值得觀察的範式。但它要求 macOS/Linux + Node 22/24 + tmux，且會改寫本機 provider 配置，**建議先在一台可犧牲的測試機或容器裡跑一遍 starter**，再判斷是否納入日常。
- 值得單獨留意的一個信號：**v0.6.4 主動把 Web UI 降級為維護模式、只保留 CLI/TUI**——這是「編排層應該長在哪個界面」的一次明確表態（終端優先，而非瀏覽器），與當前「agent 管理台都要配個 Web UI」的潮流是反向的，值得在你的 UI 判斷裡記一筆。
- 它的 starter 名（`conveyor`、`adversarial-review`、`product-team`）本身也是一份不錯的**多 agent 拓撲模式清單**，可作為設計 checklist 參考。

## 關鍵代碼 / 配置片段

安裝與首次運行（來自 README）：

```bash
npm install -g @openrig/cli
rig setup --dry-run
```

選一種 starter 並啟動團隊（源自 README 的 guided first-use path）：

```bash
cd /path/to/your/repository
starter=first-project   # 或 first-project-claude / first-project-mixed
rig specs preview "$starter" --kind rig
rig up "$starter" --cwd . --plan
rig up "$starter" --cwd .
rig tui --shared
```

給 owner 一個有界任務，並讓同 rig 的 checker 審查精確候選（> 原文引用）：

```bash
rig send "dev-owner@$starter" 'Implement <one useful change>. Track the task in the queue and return its ID. Keep it local, verify the behavior, ask dev-check in this rig to check the exact candidate, and record the result and how I can try it.'
rig queue list --destination "dev-owner@$starter" --limit 1000
```

v0.6.4 瀏覽器訪問相關的兩個環境變量（來自 release notes，需重啟 daemon 生效）：

```text
OPENRIG_ALLOWED_HOSTS    # 自定義 DNS 名 / /etc/hosts 別名 / 反代域名
OPENRIG_ALLOWED_ORIGINS  # 其它端口應用從瀏覽器調用 daemon 時的來源
```

模型與 runtime 由 starter 決定，README 中表格列出的 Starter/模型對照如下（原文照錄，Codex 側標注為 `gpt-6-astra`）：

| Team | Starter | Models |
|------|---------|--------|
| Two Codex agents | `first-project` | 兩個 `gpt-6-astra` |
| Two Claude agents | `first-project-claude` | Claude 原生默認 |
| Claude owner + Codex checker | `first-project-mixed` | Claude 默認 + `gpt-6-astra` |

> TODO: README 未給出性能/benchmark 數字（無「準確率提升 X%」類指標），因此本文不對其質量做量化主張。發版方只提供了「測試環境與已知限制」列表（如 macOS Apple silicon 上 Claude Code 2.1.286/2.1.287、Codex 0.159.3，Node 24.21.0；Ubuntu x86-64 上 Claude Code 2.1.220、Codex 0.145.0）。

**已知限制（官方列明，務必先讀）**：
- 恢復可能「誤報」問題——測試中 `rig up` 在一次完整 down/up 後報錯說某 Claude 席位需注意，但該席位實際能正常收發消息（issue #273）。
- Codex 默認 sandbox 下可能無法訪問本地 daemon，阻塞其 queue 工作（issue #275）；該測試未證明跨席位 queue 交接。
- 重啟後 daemon **不會**自動回來，需 `rig daemon start` 再 `rig up`。
- 停止 daemon 時可能報超時（issue #166）。
- Slack 長消息曾丟失 1800 字符後的內容，v0.6.4 已修（PR #404，對應 #361/#375）。
- Windows 未測試；瀏覽器訪問保護非完整隔離。

## 📌 AI Agent 假設追蹤

| 假設 | 方向 | 關聯說明 |
|------|------|----------|
| A-002: Agentic Coding 在初級任務達 80% 成功率 | 支持 | OpenRig 把「編寫—審查」做成 owner/checker 雙席位的默認協作範式（`first-project-mixed`、`conveyor`、`adversarial-review`），本質上是承認單個 coding agent 已足以承擔初級編寫任務、而人類價值上移到「審查與決策」，側面支持該假設的成立 |

---
[← Back to Deep Dives](./README.md)
