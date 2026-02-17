# AGENT.md（AI 应用开发监控系统：给 Claude Code / Codex / Cursor 等编码代理）

> **最高准则：** 在开始任何工作前，务必阅读并严格遵守 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)。
>
> **项目定位：** 本仓库是“AI 应用开发监控系统”的 **Handbook（长期记忆体）**。
>
> - 信号（短寿命）：`blog/`
> - 资产（长期可查）：`stack/` + `implementation/` + `reports/`
>
> **核心目标：** 让信息自动变成知识，让知识可查询、可推理、可累积。

---

## 1) 系统心智模型（你要按这个写）

- **Moltbot 写广度**：收集/过滤/写入索引、生成双周报告。
- **人写深度**：深度实作、代码拆解、架构洞察。

> 任何不确定事实必须标注“待核实”，严禁编造。

---

## 2) 目录拓扑（新结构优先）

- `stack/`：技术层（索引/地图/工具/框架/方法论/资源）
  - `stack/app_index.md`：**核心索引（高频写入点）**
- `implementation/`：实作层（SOP、集成、部署、提示词、脚手架）
- `reports/biweekly/`：双周推理报告
- `use-cases/`：可复现应用场景
- `products/`：产品/公司分析
- `monitoring-system/`：动态配置与统计输出
- `blog/`：日更信号与运行日志

---

## 3) 文件写入规则（硬约束）

### ✅ 允许编辑（人写区域）

- `stack/frameworks/**` / `stack/tools/**` / `stack/methodology/**`
- `implementation/**`
- `use-cases/**`
- `products/**`

### ⚠️ 仅追加，不覆盖（机器/索引区域）

- `stack/app_index.md`：只能在对应分类表格末尾追加新行
- `reports/biweekly/README.md`：只能追加索引条目

### ❌ 默认不要触碰（自动化资产）

- `monitoring-system/daily-stats/**`
- `monitoring-system/change-log/**`

> `monitoring-system/active-config.json` 只有在“用户明确要求调整监控策略”时才允许改，并必须写清原因。

---

## 4) 标注系统（必须遵守）

- 重要性：⚡ / 🔧 / 📖
- 方向：🎯（primary）/ `[方向名]`（team）/ ✍️（人工）

`stack/app_index.md` 的备注栏是关键证据链：记录来源、优先级与方向。

---

## 5) 提交规范

- 小步提交（每次只做一类改动：新增一篇文档、更新一个索引、修复一组链接）。
- commit message 建议：
  - `docs: ...`（文档/结构）
  - `feat: ...`（新增机制/脚手架）
  - `chore: ...`（配置/整理）

---

## 6) 查询提示（你应该怎么找答案）

- “最近有什么 X 相关的工具/应用？”→ 查 `stack/app_index.md`
- “如何落地做 Y？”→ 查 `implementation/` 与 `use-cases/`
- “过去两周趋势是什么？”→ 查 `reports/biweekly/`
