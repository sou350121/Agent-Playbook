# 贡献指南（AI 应用开发监控系统）

感谢你对本项目的贡献。

本仓库的定位不是“写更多内容”，而是把信息流变成长期可复利的知识资产。

---

## 你可以贡献什么？

- **新增应用/工具条目**（结构化索引）
- **深度分析/实作笔记**（可复现、可迁移的 SOP）
- **案例复盘**（证据链 + 可复现）
- **修正错误**（链接、事实、步骤、代码）

---

## 贡献落点（写到哪里）

- **应用/工具索引（高频入口）**：[`stack/app_index.md`](./stack/app_index.md)
- **技术分析（人写深度）**：`stack/tools/`、`stack/frameworks/`、`stack/methodology/`
- **实作与 SOP**：`implementation/`
- **场景复盘**：`use-cases/`
- **产品/公司分析**：`products/`
- **双周报告**：`reports/biweekly/`（通常由 Moltbot 生成）

---

## 写入安全规则（必须遵守）

- `stack/app_index.md`：**只能追加**，不得重排表格/改列/覆盖旧行；人工条目备注栏标 `✍️`。
- `monitoring-system/daily-stats/` 与 `monitoring-system/change-log/`：默认不改（自动化生成）。
- 不要提交任何密钥/Token。

---

## 命名规范

- 文件名：英文小写 + 连字符，例如 `text-to-sql-guardrails.md`
- 日期：`YYYY-MM-DD-title.md`
- 图片：统一放在 `static/img/<topic>/...` 并用相对路径引用

---

## 模板

历史模板暂时仍放在 `docs/_templates/`（迁移中）：

- `docs/_templates/workflow.mdx`
- `docs/_templates/case-study.mdx`
- `docs/_templates/prompt-card.mdx`

后续会迁移到 `implementation/` 下。
