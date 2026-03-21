---
auto_generated: true
generated_at: "2026-03-21T05:46:50Z"
source_url: "https://mistral.ai/news/leanstral"
signal_type: "significant_update"
---
# Leanstral：可信赖 Vibe Coding 的开源基础 (Leanstral: Open-Source Foundation for Trustworthy Vibe-Coding)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-21
>
> **项目/工具**: Leanstral (Mistral AI)
> **链接**: https://mistral.ai/news/leanstral
> **核心定位**: 首个专为 Lean 4 证明助手设计的开源代码 Agent，用形式化验证替代人工代码审查

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Leanstral 是 Mistral 發布的首個開源形式化驗證代碼 Agent，專為 Lean 4 證明工程設計，能在生成代碼的同時自動證明其正確性
- **現在值得用嗎**：是——如果你在從事形式化驗證、數學證明或高可信軟件開發，這是目前性價比最高的開源選擇
- **適合場景**：Lean 4 證明工程、數學形式化、高可信軟件規格驗證、形式化方法教學
- **不適合場景**：常規 Web 開發、快速原型、非形式化項目
- **與 [競品/前版] 核心差異**：相比通用代碼 Agent（Claude Code、Codex），Leanstral 專精於形式化驗證領域，用 6B 活躍參數達到接近 Opus 4.6 的證明能力，成本僅 1/92

## 是什么 / 解决什么问题

AI 代碼生成已經證明瞭自己的能力，但當我們把這些模型推向高風險領域——從前沿數學研究到任務關鍵型軟件——遇到了一個擴展瓶頸：**人工審查**。手動驗證機器生成邏輯所需的時間和專業知識，成為了工程速度的主要阻抗。

Mistral 的願景是新一代編碼 Agent：不僅執行任務，還能針對嚴格規格**形式化證明**其實現。人類不再需要調試機器生成的邏輯，只需定義想要什麼。Leanstral 是邁向這一願景的第一步。

Leanstral 是首個專為 Lean 4 設計的開源代碼 Agent。Lean 4 是一個證明助手，能夠表達複雜數學對象（如 perfectoid spaces）和軟件規格（如 Rust 片段屬性）。與現有證明系統（作為通用大模型的包裝層或專注於單一數學問題）不同，Leanstral 採用高度稀疏架構（120B 總參數，6B 活躍參數），專為在真實形式化倉庫中操作而訓練。

## 技术架构拆解

### 核心设计决策

| 設計選擇 | 理由 |
|---------|------|
| **稀疏 MoE 架構 (120B-A6B)** | 用 6B 活躍參數實現高效推理，同時保持大容量知識存儲 |
| **專精 Lean 4 領域** | 通用模型在形式化驗證任務上效率低，領域專精可提升性價比 |
| **Apache 2.0 開源授權** | 降低學術和工業界採用門檻，促進生態發展 |
| **MCP 原生支持** | 通過 Mistral Vibe 支持任意 MCP，特別是 lean-lsp-mcp |
| **平行推理 + Lean 驗證器** | 利用 Lean 作為完美驗證器，支持 pass@N 策略提升成功率 |

### 与前版/竞品的关键差异

| 維度 | 通用代碼 Agent (Claude Code/Codex) | Leanstral |
|------|----------------------------------|-----------|
| **設計目標** | 通用代碼生成與調試 | 形式化證明 + 代碼生成 |
| **驗證機制** | 無（依賴人工審查） | Lean 4 作為形式化驗證器 |
| **參數規模** | 千億級稠密模型 | 120B 總參數 / 6B 活躍參數 (稀疏) |
| **授權** | 閉源 / 有限開源 | Apache 2.0 完全開源 |
| **成本 (FLTEval)** | Sonnet 4.6: $549 | Leanstral pass@2: $36 |
| **評估基準** | HumanEval、MBPP 等通用編碼 | FLTEval (真實 PR 證明完成度) |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Mistral Vibe (Scaffold)                   │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   User       │ →  │   Leanstral  │ →  │   Lean 4     │  │
│  │   Prompt     │    │   (6B active)│    │   Verifier   │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         ↑                                       │           │
│         │         MCP (lean-lsp-mcp)            │           │
│         └───────────────────────────────────────┘           │
│                     (Tool Calls / LSP)                      │
└─────────────────────────────────────────────────────────────┘
                              ↓
                    ┌──────────────────┐
                    │  Proof Complete  │
                    │  or Error Report │
                    └──────────────────┘
```

## 实用评估

### 什么场景值得用

1. **形式化數學證明**：如果你在參與 Lean 4 數學形式化項目（如 FLT Project、perfectoid spaces），Leanstral 能自動完成證明草稿並驗證正確性

2. **高可信軟件開發**：需要證明軟件屬性（如 Rust 片段的安全性、類型系統正確性）的場景

3. **學術研究與教學**：開源授權 + 免費 API 端點使其成為形式化方法課程的理想工具

4. **代碼遷移與升級**：案例顯示 Leanstral 能診斷 Lean 版本升級帶來的 breaking changes 並提供修復方案（如 `def` → `abbrev`）

5. **跨證明助手翻譯**：能將 Rocq/Coq 定義轉換為 Lean 並證明相關屬性

### 什么场景不值得用

1. **常規 Web/移動應用開發**：Leanstral 專精形式化驗證，對 React/Vue/Django 等框架無特殊優化

2. **快速原型開發**：形式化驗證需要明確規格，不適合探索性編碼

3. **非 Lean 生態項目**：雖然基於 Mistral 架構，但訓練數據高度偏向 Lean 4，在其他語言上表現可能不如通用模型

4. **預算極度受限且無需驗證**：如果不需要形式化保證，更小的通用模型（如 Qwen2.5-Coder）性價比更高

### 迁移成本

| 從 X 遷移到 Leanstral | 工作量 |
|---------------------|--------|
| **Claude Code → Leanstral** | 低（Vibe CLI 語法相似，需學習 `/leanstall` 和 `vibe --agent lean`） |
| **手動 Lean 證明 → Leanstral** | 中（需適應 Agent 協作模式，學習如何用自然語言描述證明目標） |
| **其他證明助手 → Lean 4 + Leanstral** | 高（需學習 Lean 4 語法 + 形式化思維方式） |

## 对你的意义

如果你正在追蹤 **Agent + 形式化方法** 的交叉領域，Leanstral 是一個重要信號：

1. **領域專精 Agent 的興起**：通用 Agent（Claude Code、Codex）在特定領域（如形式化驗證）被專精模型超越，這預示著未來 Agent 生態將出現更多垂直領域專家

2. **開源 vs 閉源的性價比逆轉**：Leanstral 用 $36 達到 Sonnet $549 的性能，開源模型在特定領域已具備商業競爭力

3. **MCP 生態的成熟**：Leanstral 原生支持 MCP（特別是 lean-lsp-mcp），說明 MCP 已成為 Agent 工具調用的事實標準

4. **對 VLA 研究的啟示**：形式化驗證的思路（用數學證明保證行為正確性）可能啟發 VLA 系統的安全性驗證——如何證明機器人的動作序列滿足安全規格？

**建議**：
- 如果你在從事形式化方法相關研究 → **立即試用**（免費 API 端點 `labs-leanstral-2603`）
- 如果你關注 Agent 架構演進 → **觀測**（追蹤 FLTEval 基準和生態發展）
- 如果你只做常規 AI 應用開發 → **跳過**（除非你需要高可信保證）

## 关键代码/配置片段

### 在 Mistral Vibe 中啟用 Leanstral

```bash
# 安裝並激活 Leanstral
/leanstall

# 使用方式 1：在 Vibe 中按 Shift+Tab 切換模型直到顯示 Leanstral
# 使用方式 2：直接用 CLI 指定 agent
vibe --agent lean
```

### API 端點配置

```python
# 免費/近免費 API 端點（限時開放收集反饋）
endpoint = "labs-leanstral-2603"

# 文檔：https://docs.mistral.ai/models/leanstral-26-03
```

### 案例：Lean 版本遷移修復

問題：Lean 4.29.0-rc6 中 `rw` tactic 無法匹配 type alias

原始代碼（失敗）：
```lean
def T2 := List Bool  -- def 創建剛性定義，需要顯式展開
```

Leanstral 建議修復：
```lean
abbrev T2 := List Bool  -- abbrev 創建透明別名，立即定義等於原類型
```

原理：`def` 創建的定義需要 explicit unfolding，阻礙 `rw` tactic 看到底層結構；`abbrev` 創建的別名與原類型定義相等，`rw` 可以完美匹配模式。

### FLTEval 基準結果

| Model | Cost ($) | Score |
|-------|----------|-------|
| Haiku 4.5 | 184 | 23.0 |
| Sonnet 4.6 | 549 | 23.7 |
| Opus 4.6 | 1,650 | 39.6 |
| Leanstral pass@1 | 18 | 21.9 |
| Leanstral pass@2 | 36 | 26.3 |
| Leanstral pass@4 | 72 | 29.3 |
| Leanstral pass@8 | 145 | 31.0 |
| Leanstral pass@16 | 290 | 31.9 |

關鍵洞察：Leanstral pass@2 ($36) 已超越 Sonnet 4.6 ($549)，成本僅 6.5%，性能高 11%。

---
[← Back to Deep Dives](./README.md)
