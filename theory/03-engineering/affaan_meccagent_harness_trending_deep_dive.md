---
auto_generated: true
generated_at: "2026-09-21T06:45:45Z"
source_url: "https://github.com/affaan-m/ECC/releases/tag/v2.2.1"
signal_type: "blog_post"
---
# ECC：把 Agent Harness 当操作系统来做 (ECC — The Agent Harness Operating System)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-21
>
> **项目/工具**: affaan-m/ECC（npm 包 `ecc-universal`）
> **链接**: https://github.com/affaan-m/ECC/releases/tag/v2.2.1
> **核心定位**: 一個跨 harness 的「工程流程層」——把 plan/test/review/verify/remember 固化進 Claude Code、Codex、Cursor 等 coding agent，而不是每個 prompt 重寫一遍。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：ECC 不是一個 coding agent，而是套在 agent 外面的「作業系統」——提供 68 個 subagent、292 個 skill、94 個 command shim，加上 hooks / memory / 安全掃描，讓任意 harness 都能跑同一套工程紀律。
- **現在值得用嗎**：看場景。如果你主要用 Claude Code，且願意接受「插件式安裝 + hook 運行時」的侵入性，值得試；如果你只需要零散幾個 prompt 模板，殺雞用牛刀。
- **適合場景**：多 harness 並用的團隊（Claude Code + Codex 雙棲）、想把 TDD / code review / security scan 流程化、需要 agent 安全審計（AgentShield）的團隊。
- **不適合場景**：低上下文、無 hook 需求的輕量使用；不想讓 ECC 接管 `~/.claude/settings.json` 的人；對供應鏈安全極度敏感、無法接受 `npx` 拉取第三方包執行的環境。
- **與「單一 harness 內建功能」核心差異**：harness 內建能力綁死在單一廠商；ECC 把同一套流程抽象成可移植層，並用 install-state 所有權機制保證可安全卸載。

（註：候選 URL 指向 v2.2.1，而 README 標示當前版本為 2.2.2，兩者存在版本落差，下文以發版說明 v2.2.1 為準，並標註不確定處。）

## 是什么 / 解决什么问题

Coding agent（Claude Code、Codex、Cursor…）的能力上限，很大程度上取決於你怎麼「餵」它——你寫什麼 prompt、給它什麼上下文、讓它遵循什麼流程。問題是：這套工程紀律 **每次都要在 prompt 裡重建一遍**，而且換一個 harness 就全部歸零。

ECC 的解法是把它做成安裝一次、常駐生效的層。它的核心口號是 `plan -> test -> implement -> review -> verify -> remember -> improve`，對應一句設計宣言：「Optimize the context window. Persist everything else.」（優化上下文窗口，其餘全部持久化。）

具體來說，ECC 提供一個 MIT 授權的開源倉庫，內含：

| 組件 | 數量 | 作用 |
| --- | ---: | --- |
| Agents | 68 | 規劃、review、build 修復、安全、架構、領域工作的專職 subagent |
| Skills | 292 | TDD、research、security、docs、frontend、data、ML、ops 等可重用工作流 |
| Commands | 94 | 便捷入口（正逐步遷移到 skills-first 介面） |
| Hooks / memory | Runtime | 強制執行、session 摘要、continuous learning、instincts、上下文控制 |
| Rules | 選擇性 | 依語言/專案選擇的 always-loaded 標準 |
| AgentShield | 內建 | 掃描 prompts、hooks、MCP config、權限、secrets、agent 檔案 |

本次候選的 v2.2.1 是一次 **bug 與安全補丁**，保持 v2.2.0 的已發佈歷史不可變。它不引入新 harness 平台，而是把 2.2 線的安全面補牢——這反而是理解 ECC 工程成熟度的好窗口。

## 技术架构拆解

### 核心设计决策

- **Root 是唯一真相源**：agents/skills/commands/rules/hooks 都放在倉庫根目錄，各平台 adapter（`.claude-plugin/`、`.codex/`、`.opencode/`、`.cursor/`）只是「打包或映射」同一套工作流，而非各自維護副本。這解決了多 harness 下配置漂移的問題。
- **Skills-first 表面**：slash command 被定位為「兼容性 shim」，主工作流面是 skills。舊短名（如 `/tdd`、`/eval`）被移入 `legacy-command-shims/`，需顯式 opt-in。
- **install-state 所有權制**：安裝器記錄自己寫過哪些檔案，卸載時只刪這些，不碰使用者檔案。v2.2.1 進一步強化：安裝寫入會拒絕與「未被追蹤的使用者自有檔案」碰撞；失敗安裝只刷新實際寫過的檔案的所有權雜湊。
- **多安裝路徑互斥**：官方明確禁止「插件安裝 + 完整手動安裝」疊加（會造成 skills/hooks 重複）。同一 harness 只能選一條路徑，但可跨多個 harness 各裝一次。
- **Hook runtime 需顯式決策**：任何會 materialize hook runtime 的 profile，若沒給 `--enable-hooks` / `--no-hooks`，安裝器會先說明 hooks 能做什麼然後停下，不寫入任何東西。

### 与前版/竞品的关键差异

| 维度 | 單一 harness 內建 / 手寫 prompt 模板 | ECC |
| --- | --- | --- |
| 可移植性 | 綁死單一廠商 | 同一套流程映射到 7+ harness |
| 流程強制力 | 靠自覺 | hooks 在 runtime 強制執行 |
| 記憶 | 每次重來 | continuous learning + instincts + memory vault |
| 安全 | 各自為政 | AgentShield 統一掃描 agent 配置面 |
| 卸載 | N/A | install-state 追蹤 + dry-run + repair |
| 授權 | 廠商條款 | MIT（OSS 永久免費） |

### 架构/信息流图

```text
        ┌─────────────────────────────────────────────┐
        │  使用者 / CI                                  │
        └───────────────┬─────────────────────────────┘
                        │ /ecc:plan  or  skills invoke
                        ▼
        ┌─────────────────────────────────────────────┐
        │  ECC Root (唯一真相源)                         │
        │  agents/  skills/  commands/  rules/  hooks/  │
        └───────┬───────────┬───────────┬──────────────┘
                │           │           │   adapter 映射 (非複製)
        ┌───────▼──┐ ┌──────▼───┐ ┌─────▼─────┐
        │ Claude   │ │ Codex    │ │ Cursor /  │
        │ Code     │ │ (native) │ │ Gemini …  │
        │ plugin   │ │          │ │ (limited) │
        └───────┬──┘ └──────┬───┘ └─────┬─────┘
                └───────────┴───────────┘
                        │
                        ▼
        plan → test → implement → review → verify → remember → improve
                        │
                ┌───────▼────────┐
                │ install-state  │  ← 所有權追蹤 / doctor / repair / uninstall
                │ + AgentShield  │
                └────────────────┘
```

## 实用评估

### 什么场景值得用

- **Claude Code 重度使用者**：這是 ECC 的「最佳」支援 harness（原生 `ecc@ecc` 插件、完整 hook profile）。想要開箱即用的 TDD / code review / security scan 流程，ECC 直接給。
- **Claude Code + Codex 雙棲**：ECC 提供原生 Codex 插件路徑，兩邊共用同一套 skills 定義，配置不易漂移。
- **需要 agent 安全審計**：AgentShield 掃描 prompts / hooks / MCP config / permissions / secrets，對把 agent 引入 CI 的團隊有實際價值。
- **想制度化「記憶」**：continuous-learning-v2 的 instinct-based learning（帶 confidence scoring）與 unified memory vault，是把重複成功轉成可複用資產的機制。

### 什么场景不值得用

- **只是偶爾叫 agent 改幾行**：ECC 的價值在「流程化」，輕量使用下入侵性大於收益。
- **不想被接管 settings**：手動安裝 hook 會把 ECC 自有 hook 條目註冊進 `~/.claude/settings.json`（以穩定 ID 追蹤），對「settings 潔癖」者是負擔。
- **供應鏈敏感環境**：官方推薦 `npx ecc-universal@2.2.2 setup`，等於拉取 npm 包直接執行。發版說明本身也提醒「A version pin is not a security audit or an integrity check」。
- **Kimi / Cursor 等有限支援 harness**：v2.2.1 明確聲明「不引入新 harness 平台」，多數 adapter 仍是 capability-limited；Kimi 適配器連 hooks 都不配置。
- **想靠它省 token**：ECC 的 rules 是 always-loaded context，裝越多規則，常駐上下文越大——官方自己也提醒先從 `common` + 一個語言包開始。

### 迁移成本

從「裸 harness」到 ECC：

1. 先跑 `npx ecc-universal@2.2.2 setup`（需 Node.js 18+；Claude 路徑另需 Git 與 Claude Code 2.1+）。
2. 選擇 scope（user / project / local）與 hook profile——這一步會寫入 settings，是唯一有實質侵入的操作。
3. 若用 Codex/Kimi，改用 `install --guided`，先 `--dry-run` 驗證。
4. 若不滿意：`list-installed → doctor → repair → uninstall` 有完整回退鏈。

工作量估計：初次安裝 + 驗證約 15–30 分鐘；真正的成本在「決定裝哪些 rules/skills」，以及把團隊既有流程對齊 ECC 的 plan→test→review 紀律。

## 对你的意义

Ken 的 Agent-Playbook 關注 agent builder、visual workflow 與工程實踐——ECC 正好是「agent 工程化」的一個極端樣本：它把 agent 從「一個模型 + 一個 prompt」推向了「帶 OS、帶所有權管理、帶安裝生命週期的軟體產品」。

具體建議：**觀望偏試用**。理由有三：

1. **可借鑑的是機制，不只是功能**。ECC 的 install-state 所有權、dry-run/repair 回退鏈、多路徑互斥，是任何想把 agent 工具「產品化」的人都該抄的工程範式。
2. **它驗證了一條 Agent-Playbook 的假設**——agent 能力的差異會從「模型」轉向「harness 工程」。ECC 用 292 個 skill 把這個論點具象化了。
3. **但別急著全盤接入**。ECC 成長極快（單一維護者每週發版、跨 7 個 harness），介面與版本仍在動（2.2.1 是補丁、README 已到 2.2.2）。先在一個 project-local scope 試一個月，評估 hook 對你工作流的摩擦再說。

跨領域聯想：ECC 的「plan→verify→remember→improve」迴圈，與 VLA 領域的 world-model + 後訓練思想有結構上的相似——都是在 agent/模型外面架一層「可累積、可驗證」的迴圈。值得留意是否有論文把類似 harness 概念引入機器人策略學習。

## 关键代码/配置片段

安裝（Claude Code，官方推薦）：

```bash
npx ecc-universal@2.2.2 setup
```

Claude Code 原生插件路徑（與上面二選一，不可疊加）：

```text
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc
```

v2.2.1 的升級指令（發版說明原始片段）：

```bash
npm install -g ecc-universal@2.2.1
ecc doctor
```

v2.2.1 安全補丁的具體內容（引自 release notes）：

- GateGuard 與 governance capture 現在能識別破壞性 PowerShell 命令，包含原生 PowerShell 工具路徑；動態命令處理防止「後續變數賦值掩蓋先前的未解析調用」（#2961）。
- Relative GateGuard exemption globs 被限制在 project root 內；絕對路徑豁免仍支援（#2921）。
- 卸載尊重 `ECC_DRY_RUN=1`，且拒絕無效的 dry-run 值，而非靜默允許刪除（#2952）。
- 手動 Claude 安裝會註冊 ECC 自有 hook 條目，repair / consent 變更 / uninstall 會對賬這些條目，同時保留無關設定（#2992）。

> TODO: 上述 PR 編號為 release notes 原文，未逐條核對 diff；`#2961` / `#2921` 等具體修復行為以倉庫為準。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | ECC 把 TDD、verification-loop、eval-harness 內建為強制流程，正是「靠工程紀律把初級任務成功率推向可交付區間」的工程化路徑；其存在本身即反映了業界對 agent 可靠性的補償性投入。 |

---
[← Back to Deep Dives](./README.md)
