---
auto_generated: true
generated_at: "2026-10-30T12:00:57Z"
source_url: "https://cloud.google.com/blog/topics/developers-practitioners/data-agent-kit-is-now-ga-bring-google-data-cloud-to-any-coding-agent/"
signal_type: "significant_update"
---
# Google Data Agent Kit 正式 GA：把 Google 数据云塞进你已有的 coding agent (Google Data Agent Kit is Now GA: Bring Google Data Cloud to Any Coding Agent)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-30
>
> **项目/工具**: Google Cloud Data Agent Kit
> **链接**: https://cloud.google.com/blog/topics/developers-practitioners/data-agent-kit-is-now-ga-bring-google-data-cloud-to-any-coding-agent/
> **核心定位**: 一套免费的 MCP 工具 + 开源 agent skills，让 Antigravity / Claude Code / Codex 直接操作你的 BigQuery、Spanner、AlloyDB、Bigtable、Spark 环境——不发模型，只发「上下文 + 连接 + 护栏」

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Google 不造 agent，而是把自家 15+ 数据服务包成 MCP server + skills，装进别人的 coding agent 里
- **现在值得用吗**：看场景——只要你的数据在 Google Cloud 上、且团队已经在用 Claude Code / Codex / Antigravity，几乎零成本值得立刻试
- **适合场景**：BigQuery + Spark 管道开发、Spanner/AlloyDB/Bigtable 运维查询、dbt/Dataform 管道搭建、Airflow DAG 排障
- **不适合场景**：数据主体在 AWS/Databricks 且不想上 GCP、需要完全离线、或团队不允许 agent 直接持有生产库凭证
- **与前版核心差异**：GA 新增 BigQuery Graph、Bigtable、Managed Service for Apache Spark 三大块，并把「一次性登录 → 自动开 API + 装 skills + 配 MCP server」的配置流程做完；护栏层面用 IAM 做硬边界、skills 做软约束，形成两层治理

---

## 是什么 / 解决什么问题

Coding agent 写 SQL、PySpark、管道代码已经相当行，但它们**默认没有环境上下文**：不知道你有哪些表、表怎么分区、哪些表是团队信得过的、昨晚的 job 为什么挂。结果是开发者不停地往聊天框里贴 schema 和错误日志。

Data Agent Kit 补的正是这个缺口，用两样东西：

1. **MCP tools**：连接 15+ Google Data Cloud 服务。Agent 可以查 schema、跑查询、读 job logs、管理资源——操作的是**活的**环境，不是贴进 prompt 的快照。
2. **Google 官方 skills**：在 [GoogleCloudPlatform/data-agent-kit-plugin](https://github.com/GoogleCloudPlatform/data-agent-kit-plugin) 上开源的一批指令（社区常引用的说法是 37 个 skill，本次 blog 正文未给出数字，标记为待确认），教 agent 做数据最佳实践——优化 BigQuery SQL、设计 Bigtable row key、搭 dbt 管道、给 Airflow 排障。

一句话概括 Google 的姿势：**「Bring Google Data Cloud to any coding agent」**。它不跟 Claude Code / Codex 抢客户端，而是成为这些客户端的数据侧插件。这个站位选择，比工具本身更值得琢磨。

## 技术架构拆解

### 核心设计决策

- **不做自有 agent 前端，只做 MCP + skills 双件套**：分发面最大化。同一套能力，VS Code 扩展、Antigravity 2.0/CLI、Claude Code、Codex CLI 都能用。
- **skills 开源、可审计可 fork**：Google 在 [GitHub 仓库](https://github.com/GoogleCloudPlatform/data-agent-kit-plugin) 明文写「your team can audit them, fork them, or write custom skills for your own internal standards」。这是把「最佳实践」当代码资产分发，而不是藏进黑盒产品。
- **身份即权限，不做权限模拟**：agent 以**你本人身份**或你 impersonate 的 service account 连接，所以 BigQuery/Spanner 的 row-level 与 column-level security **自动生效**。这一点是整套设计的基石——它不需要重建一套权限模型。
- **成本感知内建在 skill 里**：skills 会引导 agent 检查分区键、以及执行 BigQuery 查询前先跑 dry run，避免误触全表扫描。这类「省钱行为」被写成 agent 指令，而非等用户自己记住。
- **配置自动化**：登录一次 → 勾选服务 → 自动启用所需 API、安装匹配的 skills、配置 MCP servers，**无需手写 setup 文件**。这一条直接消灭了 MCP 生态最常见的摩擦点。

### 护栏的两层结构：软约束 vs 硬拒绝

这是本文认为最值得抄走的设计。Data Agent Kit 把「治理」拆成两层：

| 层级 | 载体 | 性质 | 能拦住什么 |
|------|------|------|-----------|
| 软约束层 | skills（开源指令） | 概率性的、可被绕过 | 全表扫描、坏 row key、非最佳实践的管道写法 |
| 硬边界层 | IAM / ADC / 账号 impersonation | 确定性的、绕不过 | 越权读表、跨项目访问、行级/列级数据泄露 |
| 旁路审计层 | Model Armor（MCP 流量筛查）、VPC Service Controls、Principal Access Boundary | 网络/策略级 | 提示注入引发的异常调用、越界访问 |
| 供应链层 | skills 开源可 fork | 组织级 | 不合内部规范的做法（团队可自带 skills） |

关键洞察是：**prompt-level guardrail 永远无法作为安全边界**。Google 没有假装 skills 能防住恶意行为，而是明确把安全压到 IAM 上，skills 只负责质量。很多自建 agent 团队恰好搞反了——指望 system prompt 拦住危险操作。

### 架构/信息流图

```
┌──────────────────────────────────────────────┐
│  Coding Agent（Claude Code / Codex / Antigravity）│
│                                              │
│   prompt: "预测下月需求并核对库存"              │
└───────────────┬──────────────────────────────┘
                │ skills 被加载（软约束：怎么做才对）
                ▼
     ┌──────────────────────┐
     │ Google-authored skills│  ← 开源、可 fork
     │  bigquery-graph-author│
     │  bigquery-graph-query │
     │  bigtable-basics      │
     │  gcp-pipeline-orch.   │
     │  federate-lakehouse-* │
     └──────────┬───────────┘
                │ MCP tool calls
                ▼
     ┌──────────────────────────────────────┐
     │   Data Agent Kit MCP Servers (15+)    │
     │   BigQuery · BigQuery Graph · Spanner  │
     │   AlloyDB · Cloud SQL · Bigtable       │
     │   Managed Spark · GCS · Knowledge Cat. │
     └──────────┬───────────────────────────┘
                │ 以「你 / 你 impersonate 的 SA」身份
                ▼
     ┌──────────────────────────────────────┐
     │  IAM + ADC（硬边界）                   │
     │  row/column-level security 自动生效    │
     │  PAB 限定项目 · VPC-SC 圈网络          │
     │  Model Armor 筛 MCP 流量               │
     └──────────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | 通用 agent 自建数据工具 | Data Agent Kit（GA） |
|------|------------------------|---------------------|
| 环境上下文 | 靠人贴 schema / 日志 | MCP 直连活环境，查 schema、读 job logs |
| 最佳实践 | 写在 wiki 里，agent 看不见 | 编成开源 skills，agent 主动加载 |
| 权限模型 | 常自建、易与云 IAM 两套账 | 复用 IAM/ADC，RLS/CLS 自动继承 |
| 配置成本 | 手写 MCP 配置 + API 开关 | 登录一次自动完成 |
| 成本防护 | 事后看账单 | dry run + 分区键检查前置到 skill |
| 跨云 | 各写各的 | `federate-lakehouse-catalog` 连 AWS Glue / Databricks Unity Catalog |

## 实用评估

### 什么场景值得用

- **BigQuery + Spark 双栈的数据工程团队**：agent 可以一边写 Spark SQL、一边用 BigQuery 查表，且 Spark 侧用 serverless（无需管集群）、每个 session 保留状态，临时视图可跨语句复用。
- **需要给 agent 开生产数据但过不了安全评审的团队**：以 service account impersonation + 最小角色 + Principal Access Boundary 的方式接入，评审话术现成——仓库 README 直接给了「principle of least privilege」四条清单。
- **想统一多 CLI agent 的数据能力**：同一套 skills/MCP，Claude Code 和 Codex 都能装，团队不必为每个 agent 单独维护一套数据集成。
- **Airflow / dbt 管道排障**：IDE 里的 pipeline canvas 点 "Diagnose"，把日志丢给 agent，由 troubleshooting skill 追根因并提修复方案待批准。这是日常最高频、最省时间的用法。

### 什么场景不值得用

- **数据主体不在 GCP**：虽然能通过 federation 摸到 AWS Glue / Databricks，但主力栈若不是 GCP，收益折扣很大——你得不到「IAM 自动继承」这个最大卖点。
- **无法接受 agent 持有可执行凭证**：即便有 PAB，agent 仍能跑查询。如果组织策略是「agent 永远不碰生产库」，这套方案不解决问题。
- **需要完全离线/内网隔离**：MCP server 依赖 gcloud auth 与云服务，本质是线上工具；本地化部署路径未在本次材料中给出，标记 `> TODO: 确认是否有 on-prem / 私有化部署形态`。
- **小规模一次性取数**：装插件、配 ADC 的成本高于直接写 SQL。
- **遥测敏感**：默认收集使用统计（如哪些 skill / MCP tool 被用到），虽然声称不采集代码、文件内容与应用数据值，但需要在环境里设 `DO_NOT_TRACK=1` 或改 `~/.data_agent_kit/config.json` 才能关闭。

### 迁移成本

低。安装是分钟级：

```bash
# Claude Code
claude plugin marketplace add https://github.com/GoogleCloudPlatform/data-agent-kit-plugin
claude plugin install dak@dak-marketplace

# Codex CLI
codex plugin marketplace add GoogleCloudPlatform/data-agent-kit-plugin
codex plugin add dak@dak-marketplace

# Antigravity CLI
agy plugin install https://github.com/GoogleCloudPlatform/data-agent-kit-plugin
```

前置条件是 Node.js（推荐最新 LTS）+ gcloud 已安装并完成：

```bash
gcloud auth login
gcloud auth application-default login
```

Codex 有个坑：**默认 sandbox 会阻止 DAK 自我配置**，必须先用 `codex -s danger-full-access` 启动一次、执行 `$dak:dak-setup`、重启后再恢复 sandbox 正常使用。这个顺序错了会一直卡在配置失败。

## 对你的意义

如果你的团队在 GCP 上做数据/ML，这件事的实际价值不在于「Google 又发了个工具」，而在于三个可复用的模式：

1. **「让 agent 进你已有的工作台」比「让人进你的 agent」分发效率高一个数量级。** Google 放弃抢客户端，换来覆盖 Claude Code / Codex / Antigravity 三个阵营。自建 agent 产品时，先想想能不能做成 MCP + skills 的双件套。
2. **护栏分层要分清「确定性」和「概率性」。** skills 管质量、IAM 管安全，不要拿 system prompt 假装是权限系统。这条可以直接搬进任何 agent 设计评审。
3. **把「省钱/防事故」写成 skill，而不是写成 doc。** dry run、分区键检查这类动作，写在文档里没人读，写成 skill 后 agent 每次都会执行。

具体建议：**立即试用**——如果你的数据在 Google Cloud。如果不在，先读那份开源的 skills 清单，比读这篇 blog 收获更大：里面是 Google 数据工程师的真实工作流拆解，与用不用 Data Agent Kit 无关。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | Google 选择以 MCP 而非自有协议接入 15+ 核心数据服务，并将其作为跨客户端（Claude Code/Codex/Antigravity）唯一集成路径，是对 MCP 作为集成层的强背书 |
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | GA 把「写 SQL/PySpark/dbt 模型/排障 Airflow DAG」定位为 coding agent 已能胜任的日常任务，缺口被归因为「环境上下文」而非模型能力 |

---
[← Back to Deep Dives](./README.md)
