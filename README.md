# Agent-Playbook

**AI App 工程监控手册** — Pulsar 系统的 AI 工具与 Agent 情报臂，每日自动过滤 50+ 发布，提炼工程关键信号，持续追踪生产级架构模式与预测验证记录。

---

## 这是什么

Agent-Playbook 记录 AI 工具与 Agent 领域的工程级洞察：哪些值得投入、哪些存在生产陷阱、社区真实反馈如何分布。内容由 [Pulsar](https://github.com/sou350121/Pulsar-KenVersion) 自动化流水线驱动，人工审校后归档。

---

## 与其他信息源的区别

| 维度 | Twitter/X 信息流 | GitHub Awesome 列表 | 微信公众号 | **Agent-Playbook** |
|------|-----------------|--------------------|-----------|--------------------|
| 过滤深度 | 无 — 原始噪音 | 收录即存档，不淘汰 | 软文比例高 | 50+ → 5-10，qwen3.5-plus 评级门控 |
| 失效模式分析 | 极少 | 无 | 极少 | 架构深潜：并发陷阱、AI 代码盲区 |
| 社区信号 | 碎片化，不可搜索 | 无 | 无 | Git 历史永久可检索 |
| 独立视角 | 无 | 无 | 无 | Devil's Advocate — 对最强信号给出具体质疑 |
| 预测追责 | 无 | 无 | 无 | 双周预测 + ✅/❌ 验证记录，公开判断历史 |
| 跨域信号 | 无 | 无 | 无 | 与 VLA 机器人研究的交叉规则引擎 |

---

## 内容导航

| 目录 | 聚焦 | 更新频率 |
|------|------|---------|
| `landscape/` | AI 生态图谱：工具索引、技术全景、关键人物 | 月度 |
| `theory/01-principles/` | 底层原理：Transformer、RLVR、Scaling Law 等（11 篇） | 按需 |
| `theory/02-agent-design/` | Agent 设计：架构、记忆、工具、UI/API 设计（17 篇） | 按需 |
| `theory/03-engineering/` | Agentic 工程实战：护欄 / Context 工程 / 评估迭代（35 篇）★ | 按需 |
| `theory/04-paradigm/` | 范式转变：Vibe Coding、Software 3.0、Intent-Driven（11 篇） | 按需 |
| `theory/05-strategy/` | 战略生存：工程师定位、变现、组织角色（13 篇） | 按需 |
| `theory/06-frontier/` | 前沿研究：具身智能、世界模型、生物分子（7 篇） | 按需 |
| `playbooks/onboarding/` | 8 阶段学习路径（思维 → 商业化） | 稳定 |
| `playbooks/tools/` | 30+ 工具集成指南 | 工具发布后 |
| `playbooks/prompts/` | 12 个生产级 Prompt 模板 | 按需 |
| `playbooks/use-cases/` | 真实场景案例研究 | 按需 |
| `playbooks/security/` | IDE 自动执行风险、权限边界 | 按需 |
| `scaffolds/` | 生产就绪项目模板（阿里云、DocOps） | 按需 |
| `reports/` | 双周情报报告 + 预测验证 | 每两周 |
| `memory/blog/archives/` | 日报精选、社交情报归档 | 每日（自动） |

---

## 自动化流水线（北京时间）

```
06:45  RSS 采集       50+ 来源：GitHub、Hacker News、ithome、36kr、少数派等
07:00  AI 日报        qwen3.5-plus 评级 → 5-10 条工程关键精选 → Telegram 推送
07:15  每日精选归档   ai-daily-pick.json 追加，Git 历史永久留存
07:45  社交情报采集   Twitter/X + 论坛，72h 时效窗口，去重过滤
```

**深度分析（周二/四/六 15:30）**

架构深潜：失效模式、AI 代码盲区、并发陷阱、生产部署反模式。

**双周节律**

预测生成 → 下期验证（✅ 准确 / ❌ 偏差）→ 归档，判断历史完全透明。

---

## 信号标签体系

**重要性分级**

| 标签 | 含义 |
|------|------|
| ⚡ | 战略级 — 影响技术选型或架构走向 |
| 🔧 | 可操作 — 近期可落地的工程实践 |
| 📖 | 参考 — 背景知识，按需查阅 |
| ❌ | 不收录 — 噪音、重复、软文 |

**方向标注**

| 标签 | 含义 |
|------|------|
| 🎯 | 主方向 — 当前核心关注域 |
| `[方向名]` | 团队专项追踪（如 `[Coding Agent]`、`[RAG]`） |

---

## Devil's Advocate — 独立质疑机制

对每日评为 ⚡/🔧 的最强信号，流水线额外生成一条具体反驳：

> 🔥 最强反驳
> - [信号名]：具体质疑角度（禁止空话）

目的是对抗确认偏误，保留判断的独立性。

---

## 假设追踪与月度校准

流水线维护 19 条 AI App 领域假设，置信度每月自动校准：

- 日常信号触发时实时比对假设清单
- 大佬观点（Karpathy / Altman / LeCun 等）与假设冲突时标注假设序号
- 月度汇总：置信度上下浮动上限 ±0.08，更新 watch-list

校准记录归档于 `memory/`，可通过 MCP `get_predictions` 接口查询。

---

## Pulsar 自动化系统

本仓库内容由 **Pulsar** 驱动生成：

- 开源模板：[sou350121/Pulsar-KenVersion](https://github.com/sou350121/Pulsar-KenVersion)
- 技术栈：Python 3.11 + DashScope (qwen3.5-plus) + Telegram Bot + GitHub Contents API
- 自托管，2GB RAM 约束下稳定运行，无外部 SaaS 依赖

如需复用本系统监控其他领域，参考 Pulsar-KenVersion 的 `setup.sh` 一键部署流程。

---

## 姊妹仓库

**[VLA-Handbook](https://github.com/sou350121/VLA-Handbook)** — Pulsar 系统的机器人视觉-语言-动作研究臂，追踪 VLA 论文、SOTA 进展与具身智能理论。

跨域规则引擎在两个仓库的信号之间建立连接：AI App 领域出现 embodied AI 实践突破，或 VLA 领域的扩展律研究影响 Agent 架构选型时，自动触发跨域洞察。

---

## 贡献与使用

- 内容归档由自动化流水线写入，人工内容请参阅 [CONTRIBUTING.md](./CONTRIBUTING.md)
- Agent 行为规范参见 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)
- 多 Agent 协作约定参见 [AGENTS.md](./AGENTS.md)

---

## 许可证

内容以 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 授权。引用时注明出处即可。
