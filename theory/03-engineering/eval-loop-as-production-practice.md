# Eval Loop 作為生產實踐 (Eval Loop as Production Practice)

> **來源**: Agentic Engineering 工程實踐彙編 (2025–2026)
> **日期**: 2026-03-02
> **定位**: 區分「構建 Eval 體系」（一次性工程）與「持續運行 Eval」（生產運維）——這是兩個不同的工程問題

**X-Ray 開場**

`06-agent-evals-playbook.md` 解決的是「如何構建評估體系」。本文解決的是不同的問題：**評估體系構建好之後，如何讓它持續運行、自動門控部署、並在 Prompt 或模型變化時及時告警**。Eval 不只是發布前跑一次的測試——它是 Agentic 系統的生產監控基礎設施。

---

## 兩個概念的邊界

| 維度 | Eval 體系構建（`06-agent-evals-playbook`）| Eval 作為生產實踐（本文）|
|------|-------------------------------------------|-----------------------------|
| 時機 | 一次性建立，按需迭代 | 持續運行，每次變更觸發 |
| 問題 | 「我怎麼設計評估指標和評估器？」 | 「誰觸發 Eval？誰看結果？結果如何門控部署？」|
| 輸出 | Eval harness 代碼、rubrics、graders | Eval 報告、通過/失敗門控信號、回歸告警 |
| 類比 | 設計測試用例 | 把測試集成到 CI/CD |

---

## Eval 持續運行的觸發條件

以下任何一個變化都應自動觸發 Eval：

```
1. Prompt 變更（system prompt / few-shot examples 修改）
2. 模型版本更新（model ID 變更或 API 默認版本滾動）
3. 工具 schema 變更（tool definition 修改）
4. 代碼庫結構變化（影響 context injection 的文件改動）
5. 定時執行（每日一次，檢測模型 API 行為漂移）
```

---

## CI 集成：Eval Gate 設計

### 基本結構

```yaml
# .github/workflows/agent-eval.yml
name: Agent Eval Gate

on:
  push:
    paths:
      - 'prompts/**'
      - 'tools/**'
      - '.agent/AGENT_CONSTITUTION.md'

jobs:
  eval:
    runs-on: ubuntu-latest
    steps:
      - name: Run Eval Suite
        run: python eval/run_suite.py --suite regression

      - name: Check Pass Rate
        run: |
          PASS_RATE=$(cat eval/results/latest.json | jq '.pass_rate')
          if (( $(echo "$PASS_RATE < 0.85" | bc -l) )); then
            echo "Eval failed: pass rate $PASS_RATE < 0.85 threshold"
            exit 1
          fi

      - name: Post Results to PR
        uses: actions/github-script@v6
        with:
          script: |
            const results = require('./eval/results/latest.json')
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: `## Agent Eval Results\n- Pass rate: ${results.pass_rate}\n- Regressions: ${results.regressions}`
            })
```

### 三級 Gate 設計

| Gate | 觸發條件 | 閾值 | 失敗後果 |
|------|---------|------|---------|
| 快速 Gate | 每次 PR | 核心能力 pass rate ≥ 85% | 阻塞合併 |
| 回歸 Gate | 每次合併到 main | 全套回歸 pass rate ≥ 90% | 阻塞部署 |
| 語義 Gate | 每日定時 | Model-based eval score ≥ 4.0/5.0 | 告警（不阻塞）|

---

## Prompt 回歸檢測

模型 API 的靜默行為漂移是最難發現的問題——同樣的 Prompt，不同版本的模型輸出不同。

### 回歸測試集設計原則

1. **黃金用例集**：保存 50-100 個「已知正確輸出」的測試對（input → expected output）
2. **邊界 case 優先**：黃金集應以邊界 case 為主，happy path 用少量代表
3. **輸出比較策略**：不做字符串完全匹配，而是提取關鍵 assertion

```python
# eval/compare.py
def check_regression(actual: str, expected: str, rubric: dict) -> bool:
    """Model-based comparison instead of string match."""
    prompt = f"""
    Expected behavior: {rubric['intent']}
    Expected output example: {expected}
    Actual output: {actual}

    Does the actual output fulfill the expected behavior?
    Answer: pass/fail + one-line reason
    """
    result = call_eval_model(prompt)
    return result.startswith("pass")
```

### 回歸基線管理

```
eval/
├── baselines/
│   ├── 2026-03-01.json   ← 每次 release 後保存基線快照
│   └── current.json      ← 當前基線（PR eval 對比此文件）
├── cases/
│   ├── core/             ← 核心能力 case（每次 PR 都跑）
│   └── extended/         ← 擴展 case（每日定時跑）
└── results/
    └── latest.json
```

---

## Eval 失效分級與響應

| 等級 | 定義 | 響應 |
|------|------|------|
| P0 — 核心能力失效 | 核心 case pass rate < 70% | 立即回滾；不允許部署；緊急 RCA |
| P1 — 回歸失效 | 之前通過的 case 現在失敗 | 阻塞部署；24h 內修復 |
| P2 — 質量下滑 | Pass rate 下降 5-10pp | 告警；本次 sprint 修復 |
| P3 — 趨勢異常 | 連續 3 天輕微下降 | 調查根本原因；可不立即修復 |

---

## 模型版本漂移監控

當模型 API 提供商靜默更新模型版本時，Eval 是唯一的早期預警系統。

### 監控策略

```python
# eval/drift_monitor.py
import schedule

def daily_drift_check():
    """Run golden test suite daily and compare to baseline."""
    results = run_eval_suite("cases/core/")
    baseline = load_baseline("baselines/current.json")

    delta = results.pass_rate - baseline.pass_rate
    if delta < -0.05:  # > 5pp drop
        send_alert(
            level="P2",
            message=f"Model drift detected: {delta:.1%} regression",
            details=results.failed_cases
        )

    # Save daily snapshot for trend analysis
    save_snapshot(results, f"snapshots/{today()}.json")

schedule.every().day.at("02:00").do(daily_drift_check)
```

---

## Eval 結果的可視化與追蹤

Eval 的歷史趨勢比單次結果更有價值。

### 最小可行 Dashboard

```
Eval Trend (30d)
├── Pass Rate: 92% ↓ (was 95% last week)  ← 觸發調查
├── Regression Count: 3 new failures
├── Avg Latency: 2.3s ↑ (was 1.8s)        ← 性能劣化
└── P0 Incidents: 0 (30d)
```

追蹤重點：
- **Pass rate 趨勢**（週環比，月環比）
- **新增回歸 case**（哪些 case 從 pass → fail）
- **已修復回歸**（哪些 case 被新增測試覆蓋）
- **P0/P1 事件計數**（系統穩定性指標）

---

## Ralph Loop 與 Eval Loop 的關係

Ralph Loop（`05-ralph-loop-iteration-paradigm`）是任務級迭代框架。
Eval Loop（本文）是系統級監控框架。

```
任務級（Ralph Loop）：
  Reflect → Act → Learn → Plan → Hypothesize
  └ 作用範圍：單個 Agent 任務的迭代

系統級（Eval Loop）：
  變更 → Eval Gate → 部署 → 監控 → 告警 → 修復
  └ 作用範圍：整個 Agentic 系統的生產健康
```

兩者協同：Ralph Loop 的每次迭代產出的 Prompt / Tool 變更，應觸發 Eval Loop 的 Gate 驗證。

---

## 相關文章

- `03-engineering/06-agent-evals-playbook.md` — Eval 體系構建（本文的前提）
- `03-engineering/agent-failure-taxonomy.md` — Eval 失效對應的失效類型分類
- `03-engineering/05-ralph-loop-iteration-paradigm.md` — 任務級迭代框架
- `03-engineering/04-automated-enforcement.md` — CI/CD 自動化 gate 的底層機制
