# 05 Playbook：Ralph Loop 迭代範式与 AFK 指挥

> 目标：解决 Agent 的“半途而废”问题。通过外部 Stop Hook 拦截退出动作，强迫 Agent 在客观事实（测试、Lint、文件状态）面前持续迭代直到真正完成。

---

## 🧠 核心洞见

> **“Agent 管理学的终极目标是 AFK (Away From Keyboard)。”**

Ralph Loop（也称 Ralph Wiggum Loop）代表了从“交互式提示”向“自主迭代生产线”的跃迁。它的核心在于：**不依赖 LLM 的主观自我评估，而是依赖外部的客观验证。**

---

## 1. 核心要素 (The Ralph Trinity)

1.  **明确完成承诺 (Completion Promise)**：
    - 定义一个特定的關鍵字（如 `<promise>COMPLETE</promise>`）。
    - 除非 Agent 確信達成了所有驗收標準，否則不得輸出該標記。
2.  **停止鉤子 (Stop Hook)**：
    - 攔截 Agent 的退出指令（Exit Code）。
    - 掃描輸出，若無完成承諾，則重新讀取任務提示詞啟動下一輪迭代。
3.  **安全閥 (Safety Valve)**：
    - `max-iterations`：防止無限循環導致的 Token 爆炸。
    - **Docker 沙盒**：AFK 模式下必須在隔離環境運行，防止失控指令損毀系統。

---

## 2. 狀態持久化架構

為了解決上下文腐爛，每一輪 Ralph 迭代應重新載入狀態，而非擴張對話歷史。

### 2.1 `prd.json` (任務清單)
```json
{
  "userStories": [
    { "id": "US-001", "title": "Add Auth", "passes": false },
    { "id": "US-002", "title": "Add UI", "passes": false }
  ]
}
```

### 2.2 `progress.txt` (進度日誌)
Agent 在每一輪迭代末尾追加：
- **今日工作**：實現了 US-001。
- **發現的模式**：項目使用 Tailwind，嚴禁 inline style。
- **遇到的坑**：數據庫權限問題已修復。

---

## 3. 實戰腳本範例 (Simple Ralph Bash)

```bash
#!/bin/bash
# ralph-runner.sh
set -e
MAX_ITER=${1:-10}

for i in $(seq 1 $MAX_ITER); do
  echo "═══ Iteration $i ═══"
  # 執行 Agent 指令，傳入任務提示詞與進度文檔
  OUTPUT=$(cat task-prompt.md | claude-code --continue 2>&1 | tee /dev/stderr)
  
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo "✅ 任務達成！"
    exit 0
  fi
  sleep 2
done
echo "⚠️ 已達最大迭代次數"
exit 1
```

---

## 4. 適用場景與策略

### 4.1 適合的任務
- **TDD 開發**：寫測試 → 跑失敗 → 改代碼 → 重複直到全綠。
- **大規模遷移**：從 Jest 遷移到 Vitest（機械、重複、可驗證）。
- **測試覆蓋率提升**：持續編寫測試直到 Coverage 達標。

### 4.2 從 HITL 轉向 AFK
1.  **HITL (人在回路)**：前 3 輪觀察 Agent 的規劃是否正確，手動修正 `prd.json`。
2.  **AFK (離開鍵盤)**：信心建立後，開啟 20 輪循環，去喝杯咖啡。
3.  **Return (審查)**：回來審查 Git History 里的每一小步提交。

---

## 🔗 关联章节
- **[02 Playbook：从 Spec 到 PR](./02-playbook-spec-to-pr.mdx)**
- **[04 Playbook：风险治理与回滚](./04-playbook-risk-and-rollback.mdx)**
- **[架構治理：物理導軌](../../../cognition/architecture/01-physical-rails.mdx)**
