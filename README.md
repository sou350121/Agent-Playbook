<p align="center"><img src="docs/banner.svg" width="100%" alt="Agent-Playbook"></p>

# Agent-Playbook

[![CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
![Auto-updated](https://img.shields.io/badge/内容-每日自动更新-blue)
[![PULSAR 照见](https://img.shields.io/badge/PULSAR_照见-每日精选-FF6B35.svg)](https://sou350121.github.io/pulsar-web/)
[![VLA-Handbook](https://img.shields.io/badge/VLA_Handbook-配套-0EA5E9.svg?logo=github&logoColor=white)](https://github.com/sou350121/VLA-Handbook)
[![RSS 订阅](https://img.shields.io/badge/RSS-订阅-FFA500.svg?logo=rss&logoColor=white)](https://sou350121.github.io/pulsar-web/subscribe)
[![Daily Pulse](https://img.shields.io/badge/📊_Daily_Pulse-12方法族趋势-8B5CF6.svg)](PULSE.md)

📊 **[PULSAR 照见](https://sou350121.github.io/pulsar-web/)** · 每日北京时间 12:00 更新，减少信息焦虑 — `sou350121.github.io/pulsar-web`

📈 **[Daily Pulse](PULSE.md)** · 12 个 AI Agent 方法族 + 3 大竞争对（SINGLE vs SWARM / ACT vs THINK / OPEN vs CLOSED）· 每日自动生成

📡 **[RSS 订阅](https://sou350121.github.io/pulsar-web/subscribe)** · AI 每日 + 周/双周报告直达你的阅读器 · [完整使用说明](docs/SUBSCRIBE.md)

🎯 **[速查表 (Cheat Sheet)](cheat-sheet/)** · Agent 框架对比 · Prompt 模式 · 评测体系 · 失效模式 T1-T7

### 全中文 · AI Agent 工程情报终端

AI Agent 领域每天 50+ 工具 / 论文 / 公告，95% 是噪音。
这个 Playbook 做一件事：**把"该投入"和"是炒作"之间的边界，每天画清楚。**

> 93 篇 theory（6 个主题模块 × Agentic Engineering 三支柱核心）· 30+ 工具集成指南 · 12 个生产级 Prompt 模板 · 19 条 AI App 假设（月度置信度校准）· 12 期双周预测（✅/❌ 历史可查）· 每日自动 pipeline（⚡ 信号评级 · Devil's Advocate 反驳 · 跨域引擎）

---

## 三句话说清楚这个 Playbook 的价值

1. **不是新闻流，是过滤器**：50+ 原始信号 → qwen3.5-plus 评级（⚡战略 / 🔧可操作 / 📖参考 / ❌噪音）→ 每日 5-10 条精选 + **一条独立反驳**（Devil's Advocate）
2. **预测可追责**：12 期双周报告**公开**了每一条预测的 ✅准确 / ❌偏差。判断错了不藏起来——错的方式比"只发对的"更值得读
3. **跨域感知**：与 [VLA-Handbook](https://github.com/sou350121/VLA-Handbook) 共享跨域规则引擎——具身智能突破影响 Agent 架构选型 / Agent 范式涌入机器人时，自动触发关联洞察

---

## 🔥 三个其他地方没有的能力

> Agent-Playbook 与公众号 / Twitter / Awesome 列表的根本差异，浓缩在三件事上。

### 🛡️ Devil's Advocate · 独立质疑机制

对每日评为 ⚡/🔧 的**最强信号**，流水线**额外**生成一条具体反驳：

> **🔥 最强反驳**
> - [信号名]：具体质疑角度（禁止空话 · 禁止"但需要时间验证"这类废话）

目的是**对抗确认偏误**——再热的信号，也要有人公开质疑它的假设。这不是公平守则，是**认识论纪律**。

### 📋 Predictions · 公开判断历史

每两周一次预测 → 下一期回头**验证**：

| 期 | 预测样例 | 验证 |
|:--:|------|:----:|
| 03-25 | "agentic_coding 三个月内出现 framework 收敛" | ✅ |
| 03-25 | "MCP 在 6 个月内成为 IDE 必备" | ✅ |
| 04-08 | "Claude/OpenAI Agents SDK 会让 LangChain 退场" | ⏳ |
| 04-08 | "context engineering 优先级超过 RAG" | ❌ 反向 |

📎 完整记录：[reports/](reports/) · 12 期预测 · 公开置信度浮动 ±0.08/月

### 🌉 Cross-Domain Engine · VLA × AI Agent 跨域

跨域规则引擎在两个仓库的信号间建立连接——这是单一垂直社区**看不到**的视角：

```
[AI App 域]                              [VLA 机器人域]
   ↓                                          ↓
agentic_coding 加速  ◀── 触发 ──▶  flow_matching 加速
mcp_protocol 普及   ◀── R007 ──▶  VLA tool calling 出现
context_eng 兴起    ◀── R002 ──▶  人类视频预训练（EgoScale）
   ↓                                          ↓
[跨域洞察自动写入 → reports/cross-domain/]
```

---

## 📡 订阅 · 让信号主动找到你

不想每天来刷？订阅 RSS feed，新内容自动推送到阅读器：

| Feed | 内容 | 链接 |
|------|------|------|
| 📘 **AI 每日** | 每日 5-10 条 ⚡🔧 精选 + 深度解读 | [ai-daily.xml](https://sou350121.github.io/pulsar-web/rss/ai-daily.xml) |
| 📚 **周/双周报告** | 前瞻侦察 + 回顾分析（含预测验证） | [weekly.xml](https://sou350121.github.io/pulsar-web/rss/weekly.xml) |
| 🧠 **VLA 新文章**（配套）| theory 每日新增深度解读 | [vla-theory.xml](https://sou350121.github.io/pulsar-web/rss/vla-theory.xml) |
| ⚡ **VLA 每日信号**（配套）| ⚡🔧 论文 + SOTA 榜变动 | [vla-daily.xml](https://sou350121.github.io/pulsar-web/rss/vla-daily.xml) |

**🎁 一键全订阅**：[OPML 导入文件](https://sou350121.github.io/pulsar-web/rss/opml.xml)（Feedly / Inoreader / NetNewsWire 都支持）

**📖 完整使用说明**：[docs/SUBSCRIBE.md](docs/SUBSCRIBE.md) — 含各阅读器教学、CC BY 4.0 说明、FAQ

---

## 与其他 AI 信息源的区别

读 AI Agent 信息，大多数人用这五种方式——先说各自真正好在哪：

**Twitter/X**：实时第一手 + 作者反应，但**碎片化、不可搜索、算法埋没**
**GitHub Awesome 列表**：经典资源书签，但**收录即存档、不淘汰、不评级**
**微信公众号**：中文综述编辑质量稳定，但**软文比例高、90 天后限流**
**Hacker News**：高质量讨论 + 票选机制，但**英文 + 偏 SaaS 视角**
**Discord/官方博客**：第一手发布，但**需要主动追踪每个项目**

**选 Agent-Playbook**：每日自动**过滤 + 评级 + 反驳 + 验证**——不是再增加一条信息流，而是替你**做完判断**。

| 维度 | Twitter/X | Awesome 列表 | 公众号 | HN | Discord/Blog | **Agent-Playbook** |
|------|:---:|:---:|:---:|:---:|:---:|:---:|
| **过滤深度** | ❌ 原始噪音 | ❌ 收录即存档 | ⚠️ 软文比例高 | ⚠️ 票选粗筛 | ❌ 全量 | ✅ **50+ → 5-10 评级门控** |
| **失效分析** | ❌ | ❌ | ⚠️ 极少 | ⚠️ 偶尔 | ❌ | ✅ **架构深潜** |
| **独立质疑** | ❌ | ❌ | ❌ | ⚠️ comments 有 | ❌ | ✅ **Devil's Advocate** |
| **预测追责** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **双周 ✅/❌ 历史** |
| **跨域信号** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **VLA × AI 引擎** |
| **历史可检索** | ❌ 算法埋没 | ✅ 静态 | ❌ 90d 失效 | ✅ 但散乱 | ⚠️ Discord 失效 | ✅ **Git 永久 grep** |

---

## 先看这几篇（30 分钟内建立正确框架）

按依赖顺序排列——每一篇回答上一篇读完后自然产生的问题。

| # | 文章 | 解决什么 | ⏱ |
|:--:|------|---------|:--:|
| 1 | [`playbooks/onboarding/01-mindset-shift.md`](playbooks/onboarding/01-mindset-shift.md) | 从"用 ChatGPT"切到"建 Agent"的思维迁移 | 5 min |
| 2 | [`theory/03-engineering/delegation-not-automation-...`](theory/03-engineering/delegation-not-automation-engineering-principles.md) | 为什么没有 scope 的 Agent 是责任真空 — Task Packet 即委托合同 | 8 min |
| 3 | [`theory/03-engineering/trust-tier-design.md`](theory/03-engineering/trust-tier-design.md) | T0-T3 信任分层 · 谁能做什么 · 何时升级人工 | 10 min |
| 4 | [`theory/03-engineering/agent-failure-taxonomy.md`](theory/03-engineering/agent-failure-taxonomy.md) | T1-T7 失效分类（含 MAST 研究 1600+ trace 实证）| 12 min |
| 5 | [`theory/03-engineering/eval-loop-as-production-practice.md`](theory/03-engineering/eval-loop-as-production-practice.md) | 为什么 eval 是生产实践不是测试阶段 | 10 min |
| 6 | [`theory/03-engineering/context-engineering-field-guide.md`](theory/03-engineering/context-engineering-field-guide.md) | Context 工程 · 不是 prompt engineering 的延伸 | 12 min |
| 7 | [`PULSE.md`](PULSE.md) | 当下生态实时图 · 12 家族 + 3 竞争对 | 3 min |

➡️ **速查**（看完上面再用）：[cheat-sheet/](cheat-sheet/) — Frameworks / Prompts / Eval / Failure Modes 四份对应速查

---

## theory/ 知识体系（93 篇 · 6 模块）

围绕**三个核心张力**构建——读懂它们就读懂了为什么 `03-engineering/` 是整个体系的支柱：

| 张力 | 核心命题 | 工程含义 |
|------|---------|---------|
| **委托 vs. 自动化** | 没有 scope 定义的 Agent = 责任真空 | Task Packet 是最小委托合同 |
| **能力 vs. 可控性** | 越强大的 Agent 越需要分层信任架构 | T0-T3 信任分层决定谁能做什么 |
| **速度 vs. 可靠性** | 评估是生产实践，不是测试阶段的事 | eval loop 嵌入生产流程而非事后 |

```
                ┌─────────────────────────┐
                │  03-engineering ★ (35)  │  ← 三支柱核心
                │  护栏 · Context · Eval  │
                └────────────▲────────────┘
                             │
   ┌─────────────────────────┼─────────────────────────┐
   ▼                         │                         ▼
01-principles            02-agent-design        04-paradigm
原理 (11)                设计 (17)              范式 (11)
   │                         │                         │
   └─────────────────────────┴─────────────────────────┘
                             │
                ┌────────────▼────────────┐
                │     05-strategy (13)    │
                │  战略生存 · 落地变现     │
                └────────────▲────────────┘
                             │
                ┌────────────┴────────────┐
                │   06-frontier (7)       │
                │  前沿 · 具身 · 世界模型  │
                └─────────────────────────┘
```

→ **[完整学习指南 theory/README.md](./theory/README.md)** · 含三条学习路径（开发者 / 架构师 / 战略） · 精选必读 · 全部 93 篇索引

---

## 内容地图

| 目录 | 聚焦 | 更新 |
|------|------|------|
| 📊 **[`PULSE.md`](PULSE.md)** | 12 方法族趋势 + 3 竞争对（每日图） | 每日（自动）|
| 🎯 **[`cheat-sheet/`](cheat-sheet/)** | Frameworks / Prompts / Eval / Failure T1-T7 | 按需 |
| 🗺️ `landscape/` | AI 生态图谱 · 工具索引 · 关键人物 | 月度 |
| 📐 `theory/01-06/` | 6 模块 × 93 篇知识体系 | 按需 |
| 🛣️ `playbooks/onboarding/` | 8 阶段学习路径（思维 → 商业化）| 稳定 |
| 🔧 `playbooks/tools/` | 30+ 工具集成指南 | 工具发布后 |
| 💬 `playbooks/prompts/` | 12 个生产级 Prompt 模板 | 按需 |
| 🎬 `playbooks/use-cases/` | 真实场景案例 | 按需 |
| 🔐 `playbooks/security/` | IDE 自动执行风险 · 权限边界 | 按需 |
| 🏗️ `scaffolds/` | 生产就绪项目模板 | 按需 |
| 📑 `reports/` | 双周深度 + 预测验证 | 每两周 |
| 📦 `memory/blog/archives/` | 日报精选 · 社交情报归档 | 每日（自动）|

---

## 自动更新时刻表（北京时间）

```
06:45  RSS 采集       50+ 来源 · GitHub / HN / 36kr / ithome / Simon Willison Blog ...
07:00  AI 日报        qwen3.5-plus 评级 → 5-10 条精选 → Telegram 推送
07:15  归档           ai-daily-pick.json 追加 · Git 历史永久留存
07:45  社交情报       Twitter/X + 论坛 · 72h 时效窗口 · 去重过滤
12:00  Daily Pulse    field-state 快照 → assets/ai-method-trends.{svg,md}
15:30  深度分析       周二/四/六 · 失效模式 · 并发陷阱 · AI 代码盲区
```

**双周节律**：预测生成 → 下期验证 → 归档 · 判断历史**完全公开**于 [reports/](reports/)

---

## 信号评级系统

| 标签 | 含义 | 通常含义 |
|:--:|------|------|
| ⚡ | 战略级 | 影响技术选型 / 架构走向 / 半年内不会过时 |
| 🔧 | 可操作 | 近期可落地的工程实践 / 有具体使用路径 |
| 📖 | 参考 | 背景知识 · 按需查阅 |
| ❌ | 不收录 | 噪音 · 重复 · 软文 |

**方向标注**：🎯 当前主方向 · `[Coding Agent]` `[RAG]` `[MCP]` 等 — 团队专项追踪

---

## 假设追踪与月度校准

流水线维护 **19 条 AI App 领域假设**，置信度每月自动校准：

- 日常信号触发时**实时**比对假设清单
- 大佬观点（Karpathy / Altman / LeCun 等）与假设冲突时标注假设序号
- 月度汇总：置信度上下浮动上限 **±0.08**，更新 watch-list

校准记录归档于 `memory/`，可通过 MCP `get_predictions` 接口查询。

---

## 背后的系统：照见 Pulsar

本仓库内容由 **Pulsar 照见** 驱动生成：

- 🔓 **开源模板**：[sou350121/Pulsar-KenVersion](https://github.com/sou350121/Pulsar-KenVersion) — 一键部署到自己的服务器
- ⚙️ **技术栈**：Python 3.11 + DashScope (qwen3.5-plus) + Telegram Bot + GitHub Contents API
- 💾 **资源约束**：自托管 · 2GB RAM 稳定运行 · 无外部 SaaS 依赖
- 🌐 **可视化前端**：[Pulsar 照见 网站](https://sou350121.github.io/pulsar-web/) · Astro 5 + Tailwind v4

如需复用本系统监控其他领域（量化交易 / 法律科技 / 游戏行业等），参考 Pulsar-KenVersion 的 `setup.sh` 一键部署流程。

---

## 姊妹仓库

**[VLA-Handbook](https://github.com/sou350121/VLA-Handbook)** · Pulsar 系统的机器人视觉-语言-动作研究臂

| | Agent-Playbook | VLA-Handbook |
|---|---|---|
| **域** | AI 工具 / Agent / 工程实践 | 机器人 / 视觉-语言-动作 / 具身智能 |
| **主战场** | Agentic Engineering 三支柱 | VLA 论文 + SOTA + 真机评测 |
| **数据** | 50+ AI 源 · 19 假设 | 28 源 + 21 GitHub repo · 20 假设 |
| **跨域** | ◀── Cross-Domain Engine ──▶ | ◀── Cross-Domain Engine ──▶ |

跨域规则引擎在两个仓库的信号间建立连接：AI App 领域出现 embodied AI 实践突破，或 VLA 领域的扩展律研究影响 Agent 架构选型时，**自动触发跨域洞察**写入两个仓库的 `reports/cross-domain/`。

---

## 贡献与使用

- 内容归档由自动化流水线写入 · 人工内容请参阅 [CONTRIBUTING.md](./CONTRIBUTING.md)
- Agent 行为规范参见 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)
- 多 Agent 协作约定参见 [AGENTS.md](./AGENTS.md)

引用规范：`sou350121 · Agent-Playbook · https://github.com/sou350121/Agent-Playbook · CC BY 4.0`

---

## 许可证

内容以 **[Creative Commons Attribution 4.0 (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)** 授权 — 可自由转载 / AI 训练 / 商用，只需署名。

代码部分（如 `scripts/`、`scaffolds/`）若有不同许可，以各文件 header 为准。

---

<p align="center">
  <sub><b>Agent-Playbook</b> · Filtered, not flooded · Powered by <a href="https://github.com/sou350121/Pulsar-KenVersion">Pulsar 照见</a></sub>
</p>
