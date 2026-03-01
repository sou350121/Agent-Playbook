# 监控系统配置（action/monitoring/）

这里存放监控系统的可变参数与自动生成输出。完整 pipeline 脚本参考见 [`SCRIPTS.md`](./SCRIPTS.md)。

> **重要**：这些文件服务于 Moltbot 的自动化闭环。
>
> - 允许改动，但要谨慎（建议小步提交、写清原因）。
> - `daily-stats/` 与 `change-log/` 由自动化任务写入，不要手动编辑。

---

## 文件说明

| 文件/目录 | 说明 |
|---|---|
| [`SCRIPTS.md`](./SCRIPTS.md) | Pipeline 脚本参考：命名规则、DAG 拓扑、所有活跃脚本 |
| `active-config.json` | 当前生效的动态参数（focus_areas / keywords / filtering_rules） |
| `daily-stats/` | 每日统计数据（自动生成） |
| `change-log/` | 配置变更历史（自动或半自动生成） |

---

## 配置结构速读

### focus_areas

- `primary`：主攻方向（降低过滤门槛；命中就收录）
- `team`：团队方向（提高过滤门槛；只收大事）

### keywords

- `A_tier`：核心关键词（不可自动删除）
- `B_tier`：次级关键词（可自动调整）

### filtering_rules

- `max_apps_per_day`：单日收录上限
- `primary_direction_threshold` / `team_direction_threshold`：不同方向的收录门槛

---

## 人工干预（建议流程）

1. 编辑 `active-config.json`
2. 提交 commit：`chore: update monitoring config - <原因>`
3. 由下次任务执行时生效
