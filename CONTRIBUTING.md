# 貢獻指南

感謝你對本項目的貢獻。

本倉庫的定位不是「寫更多內容」，而是把信息流變成長期可複利的知識資產。

---

## 你可以貢獻什麼？

- **新增工具 / 應用條目**（結構化索引）
- **深度分析 / 實作筆記**（可復現、可遷移的 SOP）
- **案例復盤**（證據鏈 + 可復現）
- **修正錯誤**（連結、事實、步驟、代碼）

---

## 貢獻落點（寫到哪裡）

| 內容類型 | 目錄 |
|---------|------|
| AI 生態工具索引 | `landscape/app-index.md` |
| 底層原理 / 模型理論 | `theory/01-principles/` |
| Agent 架構 / 記憶 / 工具設計 | `theory/02-agent-design/` |
| Agentic 工程實戰（護欄 / Context / 評估）| `theory/03-engineering/` |
| 範式轉變 / 新工作方式 | `theory/04-paradigm/` |
| 戰略 / 定位 / 變現 / 組織角色 | `theory/05-strategy/` |
| 前沿研究（具身 / 世界模型 / 生物）| `theory/06-frontier/` |
| 工具鏈整合指南 | `playbooks/tools/` |
| 生產級 Prompt 模板 | `playbooks/prompts/` |
| 真實場景案例 | `playbooks/use-cases/` |
| 安全 / 權限邊界 | `playbooks/security/` |
| 可復用項目模板 | `scaffolds/` |
| 雙週情報報告 | `reports/`（通常由 Pulsar 自動生成）|
| 日報精選 / 社交情報歸檔 | `memory/blog/archives/`（自動）|

---

## 寫入安全規則（必須遵守）

- 不要提交任何密鑰 / Token
- 不要在文章中使用真實設備名、主機名或個人路徑
- 自動化流水線歸檔內容請勿手動編輯（`memory/blog/archives/` 下）

---

## 命名規範

- 文件名：英文小寫 + 連字符，例如 `text-to-sql-guardrails.md`
- 深度分析文章：`topic-name_deep_dive.md`（Pulsar 自動生成格式）
- 日期歸檔：`YYYY-MM-DD-title.md`
- 圖片：統一放在 `static/img/<topic>/` 並用相對路徑引用

---

## 模板

- 案例復盤：`playbooks/templates/case-study.md`
- 失敗記錄：`playbooks/templates/failure-log.md`
- Prompt 卡：`playbooks/templates/prompt-card.md`
- 工作流：`playbooks/templates/workflow.md`

---

## Agent 行為規範

多 Agent 協作規則參見 [AGENTS.md](./AGENTS.md)。
Agent 行為邊界參見 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)。
