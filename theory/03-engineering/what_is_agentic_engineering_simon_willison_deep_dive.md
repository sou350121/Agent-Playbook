---
auto_generated: true
generated_at: "2026-03-20T11:03:31Z"
source_url: "https://simonwillison.net/guides/agentic-engineering-patterns/what-is-agentic-engineering/"
signal_type: "significant_update"
---
# 什么是 Agentic Engineering？— Simon Willison 实战指南 (What is Agentic Engineering? — Simon Willison Practical Guide)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-20
>
> **项目/工具**: Agentic Engineering Patterns (Simon Willison)
> **链接**: https://simonwillison.net/guides/agentic-engineering-patterns/what-is-agentic-engineering/
> **核心定位**: 系统性定义「Agentic Engineering」方法论 — 专业开发者如何使用 coding agents 提升工程效能，而非被其替代

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Simon Willison 提出的新工程範式，定義專業開發者如何與 coding agents（Claude Code、OpenAI Codex、Gemini CLI）協作，核心是「人類定義問題 + Agent 迭代實現 + 人類驗證質量」
- **現在值得用嗎**：是 — 若你已在用 Claude Code 或類似工具，這套模式能幫你建立可複用的工程習慣
- **適合場景**：獨立開發者/小團隊快速原型、測試驅動開發、代碼重構、文檔生成、多並行任務
- **不適合場景**：高安全要求系統（需人工逐行審計）、性能極致優化（Agent 難理解底層約束）、 legacy 系統無測試覆蓋
- **與 Vibe Coding 核心差異**：Vibe Coding 是「寫完不看代碼」，Agentic Engineering 是「Agent 寫代碼 + 人類定義質量標準 + 系統化驗證」

## 是什么 / 解决什么问题

**背景痛点**：2025-2026 年，coding agents（能寫代碼 + 執行代碼的 Agent）快速普及，但行業缺乏系統性的使用方法。開發者面臨兩個極端：要麼全盤拒絕（「AI 寫的代碼不可信」），要麼過度依賴（「Vibe Coding」— 寫完不看代碼）。這兩種態度都無法最大化 agents 的價值。

**Simon Willison 的解法**：他在 2026 年 2 月啟動了 [Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/) 項目，目標是收集並文檔化「如何從 coding agents 獲得最佳結果」的實踐模式。這不是 AI 生成的內容 — Simon 明確聲明所有文字都是他自己寫的（LLM 僅用於校對和生成示例代碼）。

**核心定義**：
- **Agent**：「Agents run tools in a loop to achieve a goal」— Agent 是調用 LLM、傳遞工具定義、執行 LLM 請求的工具並將結果反饋回 LLM 的軟件
- **Coding Agent**：工具集中包含代碼執行能力的 Agent（Claude Code、OpenAI Codex、Gemini CLI）
- **Agentic Engineering**：使用 coding agents 輔助開發軟件的實踐

**關鍵洞察**：代碼執行能力是 agentic engineering 的定義性特徵。沒有直接運行代碼的能力，LLM 輸出的任何內容價值有限；有了代碼執行，agents 可以迭代生成「可驗證能工作」的軟件。

## 技术架构拆解

### 核心设计决策

| 設計選擇 | 理由 |
|---------|------|
| **人類定義問題，Agent 實現** | 寫代碼從來不是軟件工程師的唯一活動 — 核心工藝是「決定寫什麼代碼」。任何軟件問題都有數十種潛在解決方案，人類的工作是導航這些選項並找到最適合當前情境的 |
| **Agent 迭代 + 人類驗證** | LLM 不會從過去的錯誤中學習，但 coding agents 可以 — 前提是人類刻意更新指令和工具集來吸收經驗 |
| **測試優先（Red/Green TDD）** | 測試驅動開發是 coding agents 的最佳匹配：先寫測試、確認失敗、再實現到通過。這保護了兩種常見錯誤：代碼不工作、代碼不必要 |
| **代碼變便宜，好代碼仍有成本** | 生成初始可運行代碼的成本降至近乎免費，但「好代碼」仍然昂貴 — 需要測試、文檔、錯誤處理、可維護性設計 |
| **模式驅動而非工具驅動** | 目標是描述「不易過時」的模式，而非特定工具教程。工具會變，但「如何與 Agent 協作」的原則更穩定 |

### 与前版/竞品的关键差异

| 维度 | Vibe Coding (Karpathy 定義) | 傳統 AI 輔助編程 | Agentic Engineering |
|------|---------------------------|-----------------|---------------------|
| **人類角色** | 提示後不管，「忘記代碼存在」 | 逐輪對話，手動複製粘貼 | 定義問題 + 提供工具 + 驗證結果 |
| **代碼質量** | 原型級，未審查 | 依賴人類審查 | 測試保護 + 迭代驗證 |
| **適用人群** | 非程序員/快速原型 | 所有開發者 | 專業軟件工程師 |
| **學習曲線** | 低（提示即可） | 中（需學會對話） | 高（需建立新工程習慣） |
| **長期可維護性** | 低 | 中 | 高（測試 + 文檔 + 模式） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Agentic Engineering Loop                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: 人類定義                                           │
│  - 問題規格（詳細程度恰當）                                   │
│  - 提供工具集（Agent 需要的工具）                             │
│  - 質量標準（什麼是「完成」）                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 2: Agent 迭代                                         │
│  - 調用 LLM 生成代碼                                          │
│  - 執行代碼驗證                                              │
│  - 失敗 → 分析錯誤 → 重新生成                                 │
│  - 成功 → 輸出結果                                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Phase 3: 人類驗證                                           │
│  - 審查輸出（功能 + 質量）                                    │
│  - 更新指令/工具集（吸收經驗）                                │
│  - 決定：接受 / 迭代 / 重啟                                   │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

| 場景 | 理由 | 預期收益 |
|------|------|---------|
| **測試驅動開發** | Red/Green TDD 與 Agent 天然匹配 — Agent 可以自動運行測試並迭代到通過 | 測試覆蓋率提升，回歸錯誤減少 |
| **代碼重構** | Agent 可以並行重構多個模塊，人類專注於設計決策 | 重構速度提升 3-5x |
| **文檔生成** | Agent 可以從代碼提取結構並生成初稿，人類補充語境 | 文檔更新滯後問題緩解 |
| **原型探索** | 快速驗證多個設計方案，成本低 | 決策質量提升（更多選項對比） |
| **並行任務** | 一個人類可以同時驅動多個 Agent 會話（實現、重構、測試、文檔並行） | 吞吐量提升 |

### 什么场景不值得用

| 場景 | 理由 | 風險 |
|------|------|------|
| **高安全要求系統** | Agent 可能引入微妙漏洞，需人工逐行審計 | 安全漏洞、合規風險 |
| **性能極致優化** | Agent 難理解底層硬件約束和微觀優化 | 性能退化、難以調試 |
| **Legacy 系統無測試** | 沒有測試保護，Agent 改動可能破壞隱含約束 | 回歸錯誤、系統不穩定 |
| **團隊無 Agent 經驗** | 缺乏新工程習慣，容易退回「Vibe Coding」或全盤拒絕 | 質量下降、團隊信任受損 |

### 迁移成本

從傳統開發模式遷移到 Agentic Engineering：

| 變更項 | 工作量 | 說明 |
|--------|--------|------|
| **建立測試套件** | 中 - 高 | 若無現有測試，需補寫；若有，需確保 Agent 可訪問 |
| **學習提示工程** | 低 - 中 | 需學會「定義問題而非指定實現」的提示風格 |
| **更新工程習慣** | 中 | 需建立新直覺：什麼值得手動做、什麼值得委托 Agent |
| **工具集配置** | 低 | 為 Agent 配置必要的工具（文件讀寫、測試運行、代碼執行） |

**估計時間**：個人開發者 1-2 週適應期；小團隊 2-4 週（需協調習慣）

## 对你的意义

**對 Ken 的 VLA 研究線**：
- VLA 系統開發涉及大量實驗代碼（模型訓練、數據處理、評估腳本）— Agentic Engineering 可以加速實驗迭代
- 建議：為 VLA 實驗建立標準測試套件（數據加載驗證、模型輸出形狀檢查），讓 Agent 安全迭代

**對 Ken 的 AI 應用開發線**：
- Agent-Playbook 本身就是在文檔化 Agent 工程模式 — Simon 的指南是極佳的參考框架
- 建議：將 Agentic Engineering Patterns 的核心原則整合到 Handbook 的「Engineering」分類，並對比現有條目

**具體建議**：
1. **立即試用**：若你還未系統使用 Claude Code，現在是時機 — Simon 的模式提供了結構化方法
2. **建立個人模式庫**：開始記錄「什麼提示有效、什麼工具配置有效」— 這是 Agentic Engineering 的核心資產
3. **觀望點**：Simon 的指南仍在更新（目標每週 1-2 章）— 建議訂閱他的博客，追蹤新模式

## 关键代码/配置片段

### Red/Green TDD 示例提示（来自 Simon 指南）

```
Write a test for [feature description]. Run the test and confirm it fails.
Then implement the feature to make the test pass. Run the test again to
confirm it now passes.
```

### 人類定義問題的提示結構

```
Goal: [清晰定義目標，而非指定實現]

Context: [相關背景、約束條件、現有代碼位置]

Tools available: [Agent 可以使用的工具列表]

Success criteria: [什麼是「完成」— 測試通過？性能指標？]

Constraints: [不可違反的約束 — 兼容性、安全性、依賴限制]
```

### Agent 迭代循環的隱含邏輯

```
while not goal_achieved:
    code = LLM.generate(prompt + context)
    result = execute(code)
    if result.success:
        return result
    else:
        prompt = prompt + "\nError: " + result.error
        # Agent 分析錯誤並重新生成
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Simon 的模式提供了系統化方法論，使 Agentic Coding 從「實驗性技巧」走向「工程實踐」— 這正是假設 A-002 成立的前提條件。Red/Green TDD 等模式顯著提升了 Agent 生成代碼的可靠性，使初級任務（測試生成、文檔更新、簡單重構）的成功率可達工業級標準 |

---

[← Back to Deep Dives](./README.md)
