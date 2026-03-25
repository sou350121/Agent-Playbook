---
auto_generated: true
generated_at: "2026-03-25T06:47:24Z"
source_url: "https://blog.langchain.com/introducing-langsmith-fleet/"
signal_type: "significant_update"
---
# LangSmith Fleet 企业级 Agent 管理平台重构 (Introducing LangSmith Fleet)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-25
>
> **项目/工具**: LangSmith Fleet (前身为 LangSmith Agent Builder)
> **链接**: https://blog.langchain.com/introducing-langsmith-fleet/
> **核心定位**: LangChain 企业级 Agent 管理平台品牌升级，从「构建单个 Agent」转向「管理 Agent 舰队」，引入身份模型、权限分层、审计追踪等企业必需能力

---

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: LangSmith Agent Builder 企业版重构，从个人构建工具升级为组织级 Agent 舰队管理平台
- **现在值得用吗**: 是 — 如果你的团队已有 2+ 个生产 Agent 或计划规模化部署
- **适合场景**: 企业内多 Agent 协作、权限管控、审计合规、共享 Agent 资产
- **不适合场景**: 个人开发者单 Agent 实验、无需权限隔离的小团队
- **与前版核心差异**: 从「谁都能建 Agent」转向「谁能用/改/分享 Agent」的治理层

---

## 是什么 / 解决什么问题

LangSmith Fleet 是 LangChain 对其 Agent Builder 产品的重大重构和品牌升级。核心转变在于：**从降低 Agent 构建门槛，转向解决 Agent 规模化后的治理问题**。

六个月前，构建 Agent 需要工程师。现在任何人都能用自然语言 prompt 生成 Agent。但随之而来的问题是：当团队有 10 个、20 个、100 个 Agent 在运行时，谁拥有它们？它们用什么身份访问外部工具？谁能审计它们的行为？如何安全地共享一个好用的 Agent？

Fleet 回答的就是这些问题。它不再只是一个「Agent 构建器」，而是一个「Agent 舰队指挥中心」——让你能定义每个 Agent 的身份、权限、认证方式，并在一个统一的地方（Inbox）审查所有 Agent 的行动。

这次重构反映了 LangChain 对企业市场的理解深化：**Agent 的价值不在于构建，而在于可信地规模化**。

---

## 技术架构拆解

### 核心设计决策

Fleet 的架构围绕三个核心概念设计：

1. **Agent Identity（Agent 身份）**
   - 每个 Agent 可以有独立的 Slack Bot 身份（如 `@vendor-intake`、`@onboarding-agent`）
   - 不再依赖单一 Bot 路由所有请求
   - 为未来扩展到更多渠道（Teams、Discord 等）铺路

2. **Credentials Model（凭证模型）**
   - **Claws（爪）**: 固定凭证，无论谁运行都用同一套认证。适合团队共享资源（如 Linear Slack Bot，全团队用同一账号创建 issue）
   - **Assistant（助手）**: 按用户认证，每个用户用自己的 OAuth 登录访问工具。适合个人化场景（如 Notion 知识库，每人看到不同文档）

3. **Permission Layers（权限分层）**
   - 三维控制：谁能访问 × 能做什么 × 对哪个 Agent
   - 权限级别：`Can clone`（克隆自定义）/ `Can run`（仅运行）/ `Can edit`（完全编辑）
   - 支持动态调整，随时收回权限

### 与前版/竞品的关键差异

| 维度 | LangSmith Agent Builder (旧版) | LangSmith Fleet (新版) | 竞品参考 (Zapier/Make) |
|------|-------------------------------|------------------------|------------------------|
| 身份模型 | 单一 Bot 身份 | 每 Agent 独立身份 | 每 App 独立连接 |
| 凭证管理 | 默认共享凭证 | Claws/Assistant 双模式 | 仅支持 per-user OAuth |
| 权限粒度 |  workspace 级访问 | Agent 级三层权限 | 流程级分享链接 |
| 审计追踪 | 基础 tracing | 完整审计日志（谁/何时/为何） | 有限执行历史 |
| 人机协同 | 无 | Agent Inbox 统一审批 | 部分支持审批步骤 |
| 渠道扩展 | Slack only | Slack + 更多渠道即将支持 | 多渠道但无身份隔离 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    LangSmith Fleet                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Agent A   │  │   Agent B   │  │   Agent C   │    │
│  │  @vendor-   │  │  @weekly-   │  │  @onboard-  │    │
│  │   intake    │  │   reports   │  │   ing-agent │    │
│  │  (Claw)     │  │  (Claw)     │  │  (Assistant)│    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  ┌─────────────────────────────────────────────────┐      │
│  │              Agent Inbox (HITL)                 │      │
│  │   统一审查/批准/拒绝所有 Agent 行动               │      │
│  └─────────────────────────────────────────────────┘      │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Linear    │  │   Slack     │  │   Notion    │    │
│  │   (共享凭证) │  │   (渠道)    │  │  (用户 OAuth)│    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│              Observability / Audit Trail                    │
│  完整 tracing: 哪个 Agent / 代表谁 / 用什么凭证 / 做了什么    │
└─────────────────────────────────────────────────────────────┘
```

---

## 实用评估

### 什么场景值得用

1. **企业内多团队共享 Agent**
   - 场景：总部构建了一个「供应商准入 Agent」，需要分发给 5 个区域团队使用
   - Fleet 价值：总部保留 `edit` 权限，区域团队只有 `run` 权限，确保流程一致性

2. **敏感数据访问场景**
   - 场景：HR Agent 需要访问员工绩效数据，但只能让 HR 团队看到
   - Fleet 价值：用 `Assistant` 模式，每个 HR 用自己的 OAuth 登录，数据隔离自动生效

3. **合规/审计要求**
   - 场景：金融/医疗行业需要审计每个 Agent 的决策依据
   - Fleet 价值：完整 tracing + Inbox 审批记录，满足合规要求

4. **Agent 资产化**
   - 场景：团队构建了好用的 Agent，想作为内部产品运营
   - Fleet 价值：权限分层 + 使用统计，可追踪哪些 Agent 被谁用、用得怎么样

### 什么场景不值得用

1. **个人开发者实验**
   - 原因：Fleet 的企业功能对个人是过度设计，直接用 LangGraph 或开源框架更灵活

2. **单 Agent 小团队**
   - 原因：如果全团队就 3 个人、只用 1 个 Agent，权限分层和审计是多余开销

3. **预算敏感场景**
   - 原因：LangSmith 企业版定价未公开，但肯定高于个人版。小团队可先用开源替代（如 LangGraph + 自建权限）

4. **需要深度定制 Agent 逻辑**
   - 原因：Fleet 侧重「自然语言构建」，复杂逻辑仍需代码。此时直接用 LangChain/LangGraph 更合适

### 迁移成本

从旧版 Agent Builder 迁移到 Fleet：

- **现有 Agent**: 自动迁移，无需重建
- **凭证配置**: 需重新选择 Claws/Assistant 模式（默认保持原有共享凭证）
- **权限设置**: 需手动配置每个 Agent 的分享权限（旧版无此概念）
- **Slack 集成**: 如需独立 Bot 身份，需在 Slack 后台创建新 Bot 并绑定

**估计工作量**: 已有 Agent 的团队约 1-2 小时完成配置；新团队直接从头开始即可。

---

## 对你的意义

### 对 Ken 的 AI 应用开发线的启示

1. **Agent-Playbook 架构参考**
   - Fleet 的「Claws vs Assistant」身份模型值得写入 `theory/02-agent-design/`
   - 这是一个清晰的「Agent 身份模式」分类法，可对比其他框架（如 AutoGen 的 group chat、CrewAI 的 role 概念）

2. **企业级 Agent 治理模式**
   - 权限三层模型（clone/run/edit）是行业首次明确定义
   - 可提炼为「Agent 治理矩阵」，作为企业 Agent 部署的检查清单

3. **Inbox 作为 HITL 模式**
   - 统一审批中心的设计值得参考，尤其是多 Agent 并行场景
   - 可研究如何在自己的 Agent 系统中实现类似的「行动审查层」

### 具体建议

- **立即试用**: 如果你有企业客户或正在设计多 Agent 系统，Fleet 提供了一手参考架构
- **关注方向**: 接下来几周 LangChain 会扩展更多渠道（Teams、Discord 等），观察其身份模型如何泛化
- **可跳过**: 如果你只做单 Agent 原型或开源工具开发，Fleet 的企业功能暂时用不上

---

## 关键代码/配置片段

Fleet 是低代码/无代码平台，核心配置通过 UI 完成。以下是关键概念的配置逻辑（伪代码表达）：

```yaml
# Agent 权限配置示例
agent:
  id: vendor-intake-agent
  name: "@vendor-intake"
  
  # 身份模式
  identity:
    type: claw  # 或 assistant
    slack_bot:
      handle: "@vendor-intake"
      channels: ["#vendor-ops", "#procurement"]
  
  # 凭证配置
  credentials:
    linear:
      type: shared  # claw 模式：团队共享
      oauth: false
    notion:
      type: per_user  # assistant 模式：用户各自 OAuth
      oauth: true
  
  # 权限分层
  permissions:
    - user: alice@company.com
      level: edit  # 可修改 Agent 配置
    - group: ops-team
      level: run   # 仅可运行
    - group: all-workspace
      level: clone # 可克隆自定义版本
  
  # Inbox 审批规则
  inbox:
    require_approval_for:
      - tool: linear_create_issue
        condition: priority = "urgent"
      - tool: notion_write
        condition: space = "confidential"
```

```python
# 审计日志查询示例（LangSmith API）
from langsmith import Client

client = Client()

# 查询某 Agent 的所有行动
traces = client.list_traces(
    project_name="vendor-intake-agent",
    filter="eq(metadata.agent_identity, 'claw')",
    start_time="2026-03-20T00:00:00Z"
)

for trace in traces:
    print(f"User: {trace.metadata.user_id}")
    print(f"Action: {trace.name}")
    print(f"Credentials used: {trace.metadata.credential_type}")
    print(f"Inbox approved: {trace.metadata.inbox_approved}")
```

---

## 📌 总结

LangSmith Fleet 的发布标志着一个转折点：**Agent 竞争从「谁能构建」进入「谁能管好」**。

对 LangChain 而言，这是从开发者工具向企业平台的战略升级。对使用者而言，这意味着：
- ✅ 好处：企业级治理能力首次开箱即用
- ⚠️ 代价：复杂度上升，小团队可能觉得过重
- 🔮 趋势：更多 Agent 框架会跟进身份/权限/审计能力

Fleet 不是给所有人的——它是给那些已经把 Agent 当生产力工具、需要规模化部署的团队准备的。如果你在那个阶段，Fleet 值得认真评估。

---

[← Back to Deep Dives](./README.md)
