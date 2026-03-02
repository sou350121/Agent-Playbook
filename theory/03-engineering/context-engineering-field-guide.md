# Context 工程實戰指南 (Context Engineering Field Guide)

> **來源**: Karpathy et al. "Agentic Engineering" (2025–2026) + Birgitta Böckeler @ martinfowler.com (2026) + ACE Framework (ICLR 2026, Stanford/SambaNova) + 工程實踐彙編
> **日期**: 2026-03-02
> **定位**: Context Engineering 是 Agentic 系統的新基礎設施——你給 Agent 什麼，比模型本身更決定結果

---

> 📌 **支柱 B — Context 工程**

---

**X-Ray 開場**

> "Context is the bottleneck for coding agents now." — Hacker News top comment on Fowler's context engineering article, 2026

Agent 失敗最常見的原因不是模型能力不足，而是 Context 設計失誤：給得太少導致 Agent 憑空猜測，給得太多導致上下文窗口溢出或觸發 Context Rot（上下文腐化），切割方式不對導致任務邊界不清。Context Engineering 是把「讓 Agent 能夠工作」這件事工程化的學科——它不是 Prompt Engineering 的別名，而是一個獨立的基礎設施設計問題。

---

## 什麼是 Context Engineering

Context Engineering 涵蓋以下四個問題：

1. **什麼信息應該注入**（靜態 vs 動態、全量 vs 按需檢索）
2. **如何構建和維護 Repo Map**（讓 Agent 知道代碼庫的結構）
3. **如何設計 Task Packet**（讓委派的任務邊界清晰、可驗收）
4. **如何應對 Context 衰減**（長會話中 Agent 逐漸「忘記」早期約束）

Context Engineering 的輸入不只是 prompt——它包含：retrieved knowledge、long-term memory、tool call 結果、structured formatting，以及 hooks 觸發的系統注入。設計的目標是「讓模型在任意時刻看到的 context 窗口，恰好包含完成當前步驟所需的全部信息，且不多也不少」。

---

## Context 接口分類（Martin Fowler 2026 Taxonomy）

Birgitta Böckeler 在 martinfowler.com 發表的研究（以 Claude Code 為案例）定義了 coding agent 的三類 context 接口：

| 接口類型 | 說明 | 典型例子 |
|---------|------|---------|
| **Built-in Tools** | 原生能力，模型直接調用 | bash 命令執行、文件讀寫、web fetch |
| **MCP Servers** | 外部程序，通過 Model Context Protocol 暴露數據源和 API | 數據庫查詢 MCP、私有文檔 MCP、代碼倉庫索引 MCP |
| **Skills** | 描述額外資源、指南、文檔、腳本，LLM **按需懶加載** | domain-specific playbooks、測試策略說明、安全審查 checklist |

### 觸發（Activation）模式

Context 加載由誰觸發決定了控制流和可預測性：

| 觸發方式 | 控制者 | 適用場景 |
|---------|-------|---------|
| **LLM-controlled** | 模型自主判斷相關性 | Skills（按任務語義自動加載） |
| **Human-controlled** | 用戶顯式調用 | slash commands（`/review`、`/explain`） |
| **Software-triggered** | 生命周期事件自動注入 | Hooks（PostToolUse、Stop hook） |

> **設計原則**：高確定性要求的約束（安全規則、scope 邊界）用 Software-triggered Hooks 而非 LLM-controlled Skills——不要依賴模型「記得」去加載它們。

---

## ACE 框架：把 Context 當作演化中的劇本（ICLR 2026）

ACE（Agentic Context Engineering）是 Stanford/SambaNova 在 ICLR 2026 發表的框架，核心洞察是：**把 context 當作不斷演化的 playbook，而非一次性寫死的 prompt**。

### 三角色分工

```
┌──────────────────────────────────────────────────────┐
│                   ACE 執行循環                        │
│                                                      │
│  Generator  ──▶  Reflector  ──▶  Curator             │
│  (生成推理軌跡)   (蒸餾洞見)      (結構化更新)          │
│       ▲                              │               │
│       └──────────────────────────────┘               │
│                  演化 Playbook                        │
└──────────────────────────────────────────────────────┘
```

| 角色 | 職責 |
|-----|------|
| **Generator** | 執行任務，生成帶有 success/error 的推理軌跡 |
| **Reflector** | 從軌跡中蒸餾具體可操作的洞見（不是模糊總結） |
| **Curator** | 用增量 delta 更新 playbook，做語義去重，防止細節丟失 |

### 解決兩個核心問題

**Brevity Bias（簡潔性偏差）**：傳統 prompt 優化傾向壓縮，導致領域洞見被丟棄。ACE 用「grow-and-refine」機制——新 bullet 追加，舊 bullet 更新，而非重寫整個 context。

**Context Collapse（上下文崩塌）**：反復改寫導致早期積累的細節被侵蝕。ACE 用**增量 delta 更新**（非 LLM 邏輯合並），多個 delta 確定性合并，保留知識積累。

### 性能結果

- Agent 任務（AppWorld）：+10.6% 平均提升，用更小開源模型達到頂級生產 Agent 水準
- 領域任務（金融推理）：+8.6% 提升
- 適應延遲降低 **86.9%**，無需標注數據

### 實踐啟示

ACE 的 playbook 結構可以直接映射到本地 `AGENT_CONSTITUTION.md`：

```yaml
# playbook bullet 示例（ACE 風格）
- id: rate-limit-strategy
  usage_count: 7
  insight: "rate limit 配置永遠從環境變量讀取；token bucket 優先於 sliding window（原因：easier to reason under burst）"
  last_updated: "2026-02-15"
  source_trajectory: "task-2026-02-15-003"
```

---

## Repo Map：Agent 的空間感知

Repo Map 是讓 Agent 理解代碼庫結構的核心上下文。沒有 Repo Map 的 Agent 像在黑暗中工作。

### 最小可行 Repo Map

```
project/
├── AGENT_CONSTITUTION.md    ← Agent 行為約束（什麼能做、什麼不能做）
├── ARCHITECTURE.md          ← 高層架構圖 + 主要模塊職責
├── docs/adr/                ← Architecture Decision Records（為什麼這樣設計）
└── .agent/
    ├── repo-map.json        ← 機器可讀的模塊依賴圖
    └── hot-paths.md         ← 最常被修改的文件列表（Agent 應優先了解）
```

### AGENT_CONSTITUTION.md 設計原則

AGENT_CONSTITUTION 是 Agent 的操作邊界文件（對應 Claude Code 中的 `CLAUDE.md`），應包含：

| 章節 | 內容 |
|------|------|
| 身份與職責 | 這個 Agent 是誰，負責什麼範圍 |
| 禁止操作 | 明確列出不能做的事（比工具調用攔截更早） |
| 輸出格式 | 期望的交付格式（diff / PR / JSON report）|
| 升級條件 | 什麼情況下必須請求人工介入 |
| 引用文檔 | ADR / ARCHITECTURE.md 的讀取順序 |

> **漸進式構建原則**（來自 Fowler 2026）：「像構建 rules files 一樣漸進地構建 context——不要一開始就把最大量的 context 全部注入。」現代模型需要的顯式指令比上一代少，過度注入反而引入噪聲。

---

## Task Packet：委派的最小契約

Task Packet 是人類向 Agent 委派任務的標準化格式。沒有 Task Packet 的委派是「自動化」，有的才是「委派」（見 `delegation-not-automation-engineering-principles`）。

### Task Packet 結構

```json
{
  "id": "task-2026-03-02-001",
  "objective": "為 UserService 新增 rate limiting 中間件",
  "scope": {
    "in": ["src/middleware/", "src/services/UserService.ts"],
    "out": ["src/db/", "tests/e2e/"]
  },
  "constraints": [
    "不得修改現有 test fixtures",
    "rate limit 配置從環境變量讀取，不硬編碼",
    "保持向後相容性"
  ],
  "acceptance_criteria": [
    "unit tests 覆蓋 limit exceeded / under limit 兩個 case",
    "新中間件通過現有 CI gate",
    "diff 大小 < 200 行"
  ],
  "fallback": "若無法確定 rate limit 策略，停止執行並輸出 ambiguity_report.md",
  "context_refs": ["docs/adr/003-rate-limiting.md", "ARCHITECTURE.md#middleware"]
}
```

---

## 靜態注入 vs 動態檢索

| 維度 | 靜態注入 | 動態檢索（RAG / Skills 懶加載） |
|------|---------|-------------------------------|
| 適用場景 | 任務固定、上下文小（< 10K tokens） | 大型代碼庫、長會話、跨文件查詢 |
| 優點 | 確定性強，Agent 不會「找錯」 | 按需加載，不佔窗口 |
| 缺點 | 窗口污染風險；更新需手動同步 | 檢索相關性不穩定；延遲增加 |
| 推薦組合 | AGENT_CONSTITUTION + ADR（靜態）+ Skills（懶加載）+ 代碼文件（動態 RAG）| |

---

## Context Rot（上下文腐化）：長會話的隱形殺手

**Context Rot** 是指隨著輸入 context 增長，LLM 性能系統性下降的現象——即使窗口遠未填滿。Chroma Research 測試了 18 個前沿模型，**全部**都隨輸入長度增加而性能下降。

### 三個根本機制

| 機制 | 說明 |
|-----|------|
| **Lost-in-the-Middle** | 模型對窗口中間的信息注意力顯著低於頭尾 |
| **Attention Dilution** | token 數量增大時，attention mechanism 計算量爆炸，關注點分散 |
| **Distractor Interference** | 大量無關信息干擾模型對關鍵約束的響應 |

### Context Rot 的表現

- Agent 忘記「不得修改 db/ 目錄」的約束
- Agent 開始使用早期已被否定的方案
- Agent 輸出格式逐漸偏離 Task Packet 規範
- Agent 輸出出現自相矛盾的推理（早期結論被後期稀釋）

### 三個具體對策

#### 策略 1：Checkpoint Injection（檢查點注入）

每 N 輪（建議 15-20 輪）强制重新注入核心約束，不依賴模型「記得」：

```python
def inject_checkpoint(session, constitution_path, interval=15):
    """每 interval 輪重新注入 AGENT_CONSTITUTION 核心摘要"""
    if session.turn_count % interval == 0:
        summary = extract_critical_constraints(constitution_path)
        session.inject_system_message(
            f"[CHECKPOINT] 當前活躍約束重申：\n{summary}"
        )
```

#### 策略 2：Constitutional Anchoring（憲法錨定）

在每次工具調用**後**，通過 PostToolUse Hook 觸發約束自檢：

```python
# PostToolUse hook 示例
def post_tool_use_hook(tool_name, result, session):
    if tool_name in ["Write", "Edit", "Bash"]:
        # 注入約束提醒，防止 drift
        session.inject_user_message(
            "請確認：本次操作是否符合 Task Packet scope.in 範圍？"
            "是否觸碰了 scope.out 中列出的文件？"
        )
```

#### 策略 3：Sliding Window with Priority Retention（優先保留的滑動窗口）

不是簡單截斷舊 context，而是按優先級保留：

```
優先保留順序（從高到低）：
P1 - AGENT_CONSTITUTION 核心約束（永不截斷）
P2 - 當前 Task Packet（任務期間保留）
P3 - 最近 N 輪工具調用結果（按相關性保留）
P4 - 早期推理軌跡（可壓縮為摘要）
P5 - 背景 repo-map（可替換為摘要版）
```

> 對比 ACE 框架：ACE 的增量 delta 更新是同一思路的自動化版本——用確定性合并代替 LLM 自由改寫，防止細節被侵蝕。

---

## 漸進式 Context 構建原則

> "Build context like rules files — gradually, not dumping maximum context upfront."
> — Birgitta Böckeler, martinfowler.com 2026

這個原則的背後是一個反直覺的洞察：**模型在 context 稀疏時往往比 context 密集時表現更好**，因為噪聲信號更少。

### 漸進構建的操作步驟

```
Step 1: 從靜態骨架開始
  → 只注入 AGENT_CONSTITUTION + ARCHITECTURE.md 摘要

Step 2: 按任務按需加載
  → 根據 Task Packet 的 context_refs 字段加載 ADR

Step 3: 工具調用後增量注入
  → 把關鍵工具結果 append 進 context，而非重建

Step 4: 長會話觸發壓縮
  → P4/P5 優先級 context 替換為 LLM 生成的摘要

Step 5: Checkpoint 定期錨定
  → 每 N 輪重申 P1 約束
```

### 反模式（Anti-patterns）

| 反模式 | 症狀 | 後果 |
|-------|------|------|
| Big Bang Injection | 任務開始時注入所有可能相關文件 | 噪聲增加，Context Rot 加速 |
| Static Constitution Only | 只在開始注入一次約束，從不刷新 | 長會話後 Agent 違反約束 |
| Greedy RAG | 把 RAG 結果全部注入，不過濾相關性 | 窗口污染，Distractor Interference |
| No Fallback Scope | Task Packet 沒有 `fallback` 字段 | 邊界情況 Agent 自由發揮 |

---

## 失效模式

| 失效類型 | 症狀 | 預防 |
|---------|------|------|
| Context 欠注入 | Agent 猜測不存在的 API / 架構 | 確保 repo-map + ARCHITECTURE.md 已注入 |
| Context 過注入 | Agent 輸出質量下降、矛盾增多 | 漸進構建；先靜態骨架，再動態細節 |
| Task Packet 邊界模糊 | Agent 「順手」修改了不在範圍內的文件 | 明確 `scope.out` + 審查 diff 覆蓋範圍 |
| ADR 未讀 | Agent 重複已被否決的決策 | AGENT_CONSTITUTION 強制要求在開始前讀 ADR |
| Context Rot | 長會話後 Agent 違反早期約束 | Checkpoint Injection + Constitutional Anchoring |
| Brevity Bias | playbook 被壓縮，領域洞見丟失 | ACE 風格增量 delta，禁止全量改寫 |
| Skills 過度依賴 LLM 加載 | 安全約束未被加載，Agent 不知道 | 關鍵約束改用 Software-triggered Hook |

---

## 實戰檢查清單

在部署任何 Agent 系統前，逐項確認：

- [ ] **AGENT_CONSTITUTION 已定義** — 包含身份、禁止操作、輸出格式、升級條件，且在每個 session 開始時注入
- [ ] **Context 接口已分類** — Built-in Tools / MCP Servers / Skills 各自的觸發方式（LLM / Human / Hook）已明確，關鍵約束不依賴 LLM-controlled 加載
- [ ] **Task Packet 已結構化** — 每個委派任務有明確的 `scope.in`、`scope.out`、`acceptance_criteria`、`fallback`
- [ ] **Checkpoint 策略已配置** — 長 session（> 15 輪）有 Checkpoint Injection 機制，核心約束定期重申
- [ ] **漸進構建已實踐** — 從靜態骨架開始，按 context_refs 按需加載，禁止 Big Bang Injection
- [ ] **Context Rot 監控已設置** — 可觀測 token 使用增長，並在閾值觸發時自動壓縮 P4/P5 context
- [ ] **ACE 風格演化已考慮** — 對反復執行的任務，使用增量 delta 更新 playbook，積累領域洞見而非每次從零開始

---

## 相關項目

- `03-engineering/05-adr-mind-palace.md` — ADR 作為 Agent 長期記憶
- `03-engineering/02-playbook-spec-to-pr.md` — Task Packet 在 Spec-to-PR 流程中的位置
- `03-engineering/delegation-not-automation-engineering-principles.md` — 為什麼 Task Packet 是委派的必要條件
- `02-agent-design/agent-memory-system-short-to-long.md` — 記憶系統的 Retrieve/Inject/Act/Record 循環
- `03-engineering/trust-tier-design.md` — Context 可信層級與 scope 邊界

## 延伸閱讀

- [Context Engineering for Coding Agents — Birgitta Böckeler @ martinfowler.com](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html)
- [ACE: Agentic Context Engineering — arxiv 2510.04618 (ICLR 2026)](https://arxiv.org/abs/2510.04618)
- [Context Rot: When Long Context Fails — Chroma Research](https://research.trychroma.com/context-rot)
- [Context Engineering for Agents — LangChain Blog](https://blog.langchain.com/context-engineering-for-agents/)
