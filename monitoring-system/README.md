# 监控系统配置（monitoring-system/）

这里存放“监控系统”的可变参数与自动生成输出。

> **重要**：这些文件服务于 Moltbot 的自动化闭环。
>
> - 允许改动，但要谨慎（建议小步提交、写清原因）。
> - `daily-stats/` 与 `change-log/` 未来会由自动化任务写入。

---

## 文件说明

- `active-config.json`：当前生效的动态参数（focus_areas / keywords / data_sources / filtering_rules）
- `daily-stats/`：每日统计数据（自动生成）
- `change-log/`：配置变更历史（自动生成或半自动生成）

---

## 配置结构速读

### focus_areas

定义监控重点方向：

- `primary`：主攻方向（降低过滤门槛；命中就收录）
- `team`：团队方向（提高过滤门槛；只收大事）

### keywords

两级关键词系统：

- `A_tier`：核心关键词（不可自动删除）
- `B_tier`：次级关键词（可自动调整；冷启动期应避免删除）

### data_sources

数据源配置（是否启用、语言/类别、最低阈值等）。

### filtering_rules

过滤与节流：

- `max_apps_per_day`：单日收录上限
- `primary_direction_threshold` / `team_direction_threshold`：不同方向的收录门槛

---

## 自我进化机制（规划）

每 14 天，系统自动：

1. 分析 `daily-stats/`
2. 调整 `B_tier` 关键词与数据源权重
3. 更新 `active-config.json`
4. 记录到 `change-log/`

---

## 人工干预（建议流程）

1. 编辑 `active-config.json`
2. 提交 commit：`chore: update monitoring config - <原因>`
3. 由下次任务执行时生效
