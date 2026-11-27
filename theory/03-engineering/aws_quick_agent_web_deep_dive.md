---
auto_generated: true
generated_at: "2026-11-27T13:20:43Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/new-in-aws-quick-more-capable-flows-an-updated-web-experience-and-agents-that-work-together/"
signal_type: "significant_update"
---
# AWS Quick 三项更新：对话式流程编排、多 Agent 并行协作、关掉标签页继续跑 (New in AWS Quick: Conversational Flows, Multi-Agent Orchestration, and Background Execution)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-27
>
> **项目/工具**: AWS Quick（Amazon Quick Suite 的 AI 工作空间）
> **链接**: https://aws.amazon.com/blogs/machine-learning/new-in-aws-quick-more-capable-flows-an-updated-web-experience-and-agents-that-work-together/
> **核心定位**: 把「一个人的做事方法」变成「团队的确定性流程」——用对话生成可验证的 Flows，让多个专职 Agent 并行协作并汇总成单一回答

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AWS Quick 这次把「个人增强型 AI 助手」推向「团队流程化 AI 工作台」——流程可在对话中编排、Agent 可在后台并行跑、多个 Agent 的产出可合并成一个回答
- **現在值得用嗎**：看场景。已经在用 AWS 数据栈（Redshift/S3/QuickSight 生态）且需要把重复性分析流程固化给全团队的，值得试用；只是个人想用 Chat UI 的开发者，没必要为此迁移
- **適合場景**：财务月度报告、跨区域数据分析、需要多部门知识拼接的排障类问答
- **不適合場景**：需要极细粒度代码级控制的 agent 编排、纯本地/离线的部署、低预算团队（Pro/Enterprise 门槛）
- **與旧版 Quick Flows 核心差異**：Flows 从「图形/表单式搭建」变为「对话式生成 + 确定性步骤 + 边长数据量」，并新增多 Agent 并发汇总（真编排层，而非单 Agent 调工具）

## 是什么 / 解决什么问题

AWS Quick 是 AWS 推出的「只为工作而建」的 AI 工作空间（此前归属 Amazon Quick Suite）。官方博客对这次更新的问题陈述非常直白：

> "AI assistants make individuals faster, but the gains often stay with one person. The way one analyst builds the monthly report rarely becomes the way the team builds it, and work waits until someone is back at their desk."

这其实点中了 2026 年 AI 应用层最普遍的痛点：**chat 界面的 AI 提升的是个体速度，而不是组织能力**。一个分析师会做月报，但这套方法活在他的脑子里和私人 checklist 里；他一休假，同事就得从头重建，而且每次做得都不一样。

这次更新给出三条主线：

1. **流程资产化**：在对话里描述流程 → Quick 生成 Flow 并展示步骤图 → 同一对话里测试和迭代 → 发布给团队；
2. **执行不停摆**：web app 支持关掉浏览器后继续跑，回来看 Mission Control 结果；
3. **知识拼接**：多 Agent 编排，一个问题可以同时调动多个专职 Agent（各持自己的指令、知识、上下文），最终合成一个回答。

另外还有连接器（Meta Ads、Amplitude，均通过 MCP server）、Skills 上 web、以及企业级护栏（prompt 内容安全、按组权限与额度、数据源白名单）。

## 技术架构拆解

### 核心设计决策

- **确定性步骤 + Agent 生成混编**。Flow 里既有「固定公式/阈值检查/数值计算」的确定性步骤，也有 Agent 负责起草与分析。这是这次最关键的设计选择：把「可验证的部分」从 LLM 手里拿回来。官方措辞是 "New deterministic steps help make your workflows consistent and verifiable, now with longer-running workflows and support for large data volumes."
- **单一对话即 IDE**。描述、生成、检查（旁边的步骤图）、测试、迭代、发布，全在同一个对话窗口完成。没有单独的 flow builder 画布要切换。
- **Agent 上下文归属明确**。多 Agent 编排里 "Each agent keeps its own instructions, knowledge, and context"——意味着知识边界由业务专家各自维护，而不是塞进一个巨型 system prompt。
- **写操作必须确认**。连接器（如 Meta Ads MCP）在执行创建 campaign、改预算等写动作前显式请求用户许可，且连接器继承既有权限（"Quick only shows each person what they already have access to"）。
- **数据不出环境**。官方声明 "Your data stays in your environment and does not train anyone else's models"。

### 与前版/竞品的关键差异

| 维度 | 旧版 Quick Flows / 典型 Agent Builder | 本次更新 |
|------|------------|------------|
| 流程创建方式 | 画布/表单式搭建 | 对话描述 → 自动生成 + 步骤图校对 |
| 执行确定性 | 以 LLM 行为为主 | 确定性步骤（固定公式、阈值、校验）可与 Agent 混编 |
| 运行时长/数据量 | 短流程、中等数据 | 支持更长流程与更大数据量 |
| 多 Agent | 单 Agent 调工具（tool calling） | 多专职 Agent 并发各处理一块，再合成单一回答 |
| 前台依赖 | 关闭页面即中断 | 关闭标签页后继续执行，Mission Control 收结果 |
| 企管控制 | 用户/角色级 | 增加 IdP 组级权限、Agent 小时额度、数据源类型白名单、prompt 护栏（detect-only 试运行） |
| 连接器 | 有限 | 新增 Meta Ads MCP、Amplitude MCP，写入前征求许可 |

### 架构/信息流图

```
              用户对话描述业务流程
                       |
                       v
        ┌──────────────────────────────┐
        │  Flow 生成器（LLM 解析意图） │──► 旁侧步骤图（人可校对）
        └──────────────────────────────┘
                       |
                       v
    ┌──────────────── Flow Runtime ────────────────┐
    │                                              │
    │  确定性步骤           Agent 步骤             │
    │  (公式/阈值/校验)     (起草/分析/评论)        │
    │        │                   │                 │
    │        └──────┬────────────┘                 │
    │               v                              │
    │        多 Agent 编排器（并行 fan-out）        │
    │        Agent A + Agent B + Agent C → 合成     │
    │               │                              │
    └───────────────┼──────────────────────────────┘
                    v
     数据层：Quick dashboards / Space / 连接器(MCP)
              （权限继承 + 写操作确认）
                    |
                    v
     输出：Excel 草稿 → Shared Space / 邮件 / Slack 通知
                    |
                    v
     后台执行队列（关掉标签页仍继续）→ Mission Control
```

## 实用评估

### 什么场景值得用

- **月度/周期性报告流水线**：官方给的 FP&A 例子很典型——拉上月结果 → 多区域并发 → 与预算表用固定公式比对 → 阈值触发标记 → 起草评论 → 出 Excel 草稿 → Slack 通知。这类流程的价值不在「AI 写得多好」，而在「每次算得一样」。
- **需要多部门知识拼接的诊断问答**：例子里问「某区域运费为什么涨」，同时调用 forecasting agent（团队规划数据）与 procurement agent（采购合同）。这比单 Agent + 一堆工具更接近真实组织。
- **长任务不等人**：开会前提交长请求，回来在 Mission Control 处理。对需要等数据、等 API 的任务体感差别大。
- **强合规场景**：detect-only 模式的 prompt 护栏、按 IdP 组设权限与 Agent 额度、数据源类型白名单，这是把 AI 工作台推向受监管行业的前提。

### 什么场景不值得用

- **需要代码级编排控制**：LangGraph / 自研 runtime 里那种对状态机、重试策略、token 预算的精细掌控，平台型产品给不了。Flows 是「业务人员可维护」的抽象，代价是深度可控性。
- **个人或小团队**：护栏里的 prompt 安全、按组权限被明确标注为 "available to all AWS Quick customers subscribed to Professional and Enterprise plans"——即付费档才完整。个人开发者用不上这些，反而被平台锁定。
- **非 AWS 数据栈**：连接器本质是 MCP server，其他数据源需自建；若你的数据主要在 GCP 之外的自研系统中，集成成本会显著上升。
- **对「确定性」有硬要求的数值场景**：官方说用固定公式保证一致，但公式之外的数据抽取（从 dashboard 读上月结果）仍涉及 Agent 解析，端到端可复现性待验证。
- **延迟敏感**：多 Agent 并行 fan-out 能缩短墙钟时间，但总 token 成本会上升；官方未公布定价细则，成本模型待确认。

### 迁移成本

- **从 Quick 旧版**：官方明确 "Your existing dashboards, topics, and spaces work as before, and you do not need to turn anything on." —— 零迁移。
- **从自研 Agent 流水线迁移**：中等偏高。核心工作量不在 API，而在**把隐性流程显性化**：要写出「公式是怎么算的」「阈值是多少」「评论用什么模板」。没人写下来的流程，AI 也生成不出来。
- **从其他 Agent Builder（如 Copilot Studio / n8n）**：主要是连接器与数据层重接，以及权限模型对齐。

## 对你的意义

Ken 的 AI App 线与 VLA 线在这里有一个很实际的交集：**「确定性步骤 + Agent 生成」混编，本质上就是 VLA 日报管线一直在做的事**——脚本负责抓取、去重、阈值判断，LLM 负责起草与归类。Quick 这次把这种混合模式产品化了，说明这个架构选择不是权宜之计，而是被大厂认可的工程范式。

三条具体判断：

1. **架构参考价值 > 直接使用价值**。你的管线跑在本机脚本 + cron 上，迁到 Quick 不划算。但「Flow 步骤图」这个产品设计值得抄：给 `prep-ai-deep-dive.py` 这类脚本增加一个可读的执行计划输出，人一眼就能校对流程是否符合预期。
2. **多 Agent 的「上下文归属」原则值得借鉴**。Quick 让每个 Agent 保持自己的指令与知识边界，而不是塞进一个巨型 prompt。你的 VLA 与 AI App 两条线如果未来做联合推理，用「各有自己配置文件的子 Agent + 汇总层」会比一个万能 prompt 更稳。
3. **MCP 连接器策略是明确信号**。Meta Ads 与 Amplitude 都通过 MCP server 接入，写入前征求许可——这已经是第二家大厂把 MCP 当作事实上的集成层。

结论：**观望 + 借鉴架构，不迁移**。除非你需要在一个受治理的企业环境里把分析流程交给非工程同事，否则这套能力你用不上，但它的设计决策值得逐条对照。

## 关键代码/配置片段

官方博客未提供 SDK 级代码，所有内容均为产品行为描述。以下为博文中可直接引用的关键设计表述：

```text
# 确定性步骤（官方原文）
"New deterministic steps help make your workflows consistent and verifiable,
 now with longer-running workflows and support for large data volumes."

# 多 Agent 上下文边界（官方原文）
"Each agent keeps its own instructions, knowledge, and context, so the people
 who know that work best can build and maintain it."

# 连接器写操作确认（官方原文）
"Quick asks for your permission before it creates a campaign, changes a budget,
 or takes any other write action in an ad account."

# 权限继承（官方原文）
"Connectors respect your existing permissions.
 Quick only shows each person what they already have access to."
```

连接器能力入口（博文给出）：

```text
Meta ads   → Meta Ads Model Context Protocol (MCP) server
Amplitude  → Amplitude MCP server
```

> TODO: 官方未公布 Flows 的编程接口（API/SDK）、单次执行的 token 计量方式、以及「确定性步骤」在数据抽取阶段的失败重试语义，需查阅 Quick 开发者文档确认。

---
[← Back to Deep Dives](./README.md)
