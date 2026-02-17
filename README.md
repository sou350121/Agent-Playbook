# AI 应用开发监控系统（AI App Monitoring Handbook）

> 🚀 将每日涌入的 AI 工具、应用、API 更新转化为**可查询、可推理、可累积**的知识资产（GitHub 直读优先）。

本仓库是整套系统中的 **Handbook（长期记忆体）**：

- **Moltbot**：生产者（收集/过滤/写入/报告）
- **Handbook（本 repo）**：累积者（结构化、版本控制、可搜索）
- **你**：消费者 + 深度生产者（查、读、写深度笔记）

系统设计文档：[`implementation/architecture/ai_app_handbook_design.md`](./implementation/architecture/ai_app_handbook_design.md)
---

## 快速开始（3 个入口）

1) **查应用/工具索引（高频入口）**：[`stack/app_index.md`](./stack/app_index.md)

2) **看双周趋势与跨内容推理**：[`reports/biweekly/`](./reports/biweekly/)

3) **看落地实作与 SOP**：[`implementation/`](./implementation/)

---

## 目录导航（新结构）

| 目录 | 说明 | 更新频率 |
|---|---|---|
| `stack/` | 技术层：索引、工具/框架/方法论分析、资源 | 每日 + 不定期 |
| `implementation/` | 实作层：集成、部署、提示词、脚手架与 SOP | 不定期 |
| `reports/` | 时间层：双周报告等推理产物 | 每两周 |
| `use-cases/` | 场景层：可复现案例与解决方案 | 不定期 |
| `products/` | 产品层：公司/产品拆解 | 不定期 |
| `monitoring-system/` | 监控系统配置（动态参数、统计、进化记录） | 自动 |
| `blog/` | 信号层：日更动态/运行日志（可丢弃但可追溯） | 每日 |
| `static/img/` | 图片/截图资源 | 随内容 |

---

## 写作与贡献（简版）

- **新增应用条目**：只在 `stack/app_index.md` 对应分类表格末尾追加新行，并在备注标注 `✍️`。
- **写深度分析**：优先写在 `stack/`（分析）或 `implementation/`（实作）。
- **不要把 repo 变成信息垃圾场**：信号进 `blog/`，资产进 `stack/` / `implementation/`。

更完整规范见：[`CONTRIBUTING.md`](./CONTRIBUTING.md)

---

## ⚖️ 许可协议

内容采用 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.zh) 许可协议，代码采用 MIT 协议。
