---
auto_generated: true
generated_at: "2026-03-28T05:46:08Z"
source_url: "https://blog.langchain.com/two-different-types-of-agent-authorization/"
signal_type: "significant_update"
---
# LangSmith Fleet 推出两种 Agent 授权模式 (Two Different Types of Agent Authorization)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-28
>
> **项目/工具**: LangSmith Fleet
> **链接**: https://blog.langchain.com/two-different-types-of-agent-authorization/
> **核心定位**: 解决企业 Agent 部署中的权限隔离难题——区分「代表用户执行」与「使用固定凭证执行」两种模式

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：LangSmith Fleet 推出 Assistants（用户凭证）和 Claws（固定凭证）双模式，解决企业 Agent 权限隔离问题
- **現在值得用嗎**：是——如果你的 Agent 需要面向多用户提供服务，且涉及敏感数据访问
- **適合場景**：企业内部工具（HR onboarding、IT support）、客户服务 Agent、跨部门协作 Agent
- **不適合場景**：个人使用的单用户 Agent、不涉及第三方 API 调用的简单问答 Agent
- **與前版核心差異**：从单一凭证模型拆分为两种授权类型，支持更细粒度的权限控制

## 是什么 / 解决什么问题

在 LangSmith Fleet 推出之前，Agent 授权模型相对单一：大多数 Agent 使用创建者的凭证运行。这带来了一个核心问题——当多个用户与同一个 Agent 交互时，他们实际上共享同一套权限边界。

想象一个 HR onboarding Agent，它需要访问 Notion 和 Rippling（人力资源系统）。如果这个 Agent 使用创建者的凭证：
- Alice 可以通过 Agent 看到 Bob 的私人信息（因为 Agent 有创建者的全量权限）
- 创建者无法限制不同用户看到不同内容

LangSmith Fleet 通过两种授权模式解决这个问题：
- **Assistants**：代表终端用户执行（on-behalf-of），每个用户使用自己的凭证
- **Claws**：使用固定凭证执行，所有用户共享同一套权限边界

这个区分看似简单，但它是企业级 Agent 部署的关键基础设施——没有它，Agent 无法在保护隐私的前提下规模化服务多用户。

## 技术架构拆解

### 核心设计决策

| 决策点 | 方案 | 理由 |
|--------|------|------|
| 授权模型拆分 | Assistants vs Claws 双类型 | 覆盖两种典型使用场景，避免过度设计 |
| 用户身份映射 | Channel 用户 ID → LangSmith ID | 利用现有渠道（Slack/Gmail 等）的身份体系，降低集成成本 |
| 凭证传递时机 | 运行时动态注入 | 避免凭证持久化存储风险，支持细粒度权限控制 |
| 渠道支持差异 | Assistants 仅支持部分渠道 | 需要渠道支持用户 ID 映射，技术限制下的务实选择 |
| 人机协同 | Claws 支持 human-in-the-loop guardrail | 固定凭证 Agent 风险更高，需要额外防护层 |

### 与前版/竞品的核心差异

| 维度 | 传统单凭证模型 | LangSmith Fleet 双模式 |
|------|---------------|----------------------|
| 权限边界 | 所有用户共享创建者权限 | Assistants 按用户隔离，Claws 统一边界 |
| 数据隔离 | 无法隔离 | Assistants 天然隔离用户数据 |
| 凭证管理 | 创建者管理单一凭证 | Claws 使用专用凭证，Assistants 使用用户凭证 |
| 适用场景 | 个人/小团队 | 企业级多用户部署 |
| 安全风险 | 高（权限过度暴露） | 低（按需授权 + 人机协同） |

### 架构信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    LangSmith Fleet                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │   Assistants     │         │      Claws       │         │
│  │  (on-behalf-of)  │         │ (fixed creds)    │         │
│  ├──────────────────┤         ├──────────────────┤         │
│  │ User A → Cred A  │         │                  │         │
│  │ User B → Cred B  │         │  Fixed Cred X    │         │
│  │ User C → Cred C  │         │  (shared by all) │         │
│  └────────┬─────────┘         └────────┬─────────┘         │
│           │                            │                    │
│           ▼                            ▼                    │
│  ┌─────────────────────────────────────────────────┐       │
│  │              Tool Execution Layer               │       │
│  │  (Notion / Rippling / Slack / Gmail / etc.)     │       │
│  └─────────────────────────────────────────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Channel Mapping (Assistants only):
Slack User ID → LangSmith User ID → User-specific Credentials
```

## 实用评估

### 什么场景值得用

| 场景 | 推荐模式 | 理由 |
|------|---------|------|
| 企业内部 HR/IT 支持 Agent | Assistants | 每个员工只能看到自己的数据，符合隐私合规 |
| 客户服务 Agent（回复邮件） | Claws + HITL | 统一品牌声音，敏感操作需人工确认 |
| 竞品监控/产品问答 Agent | Claws | 使用专用 Notion 账号，权限可控 |
| 个人生产力 Agent | 无需 Fleet | 单用户场景，双模式优势不明显 |

### 什么场景不值得用

| 场景 | 原因 |
|------|------|
| 单用户个人 Agent | 增加复杂度但无实际收益 |
| 不涉及第三方 API 的纯问答 Agent | 无需凭证管理 |
| 渠道不支持用户 ID 映射的场景 | Assistants 无法使用，Claws 可能权限过宽 |
| 预算有限的初创团队 | Fleet 可能增加成本，需评估 ROI |

### 迁移成本

从传统单凭证 Agent 迁移到 LangSmith Fleet：

| 迁移类型 | 工作量 | 关键步骤 |
|---------|--------|---------|
| 现有 Agent → Claw | 低（1-2 小时） | 创建专用凭证账号，更新 Agent 配置 |
| 现有 Agent → Assistant | 中（4-8 小时） | 集成渠道用户映射，测试权限隔离 |
| 新建 Agent | 低 | 直接选择合适模式，按文档配置 |

**注意事项**：
- Assistants 目前仅支持部分渠道（Slack、Gmail、Outlook、Teams 中的一部分）
- 需要 LangSmith 账户体系与渠道账户的映射关系
- Claws 模式建议配合 human-in-the-loop 使用，尤其是涉及写操作的场景

## 对你的意义

如果你正在构建面向多用户的 Agent 系统（尤其是企业场景），这个更新解决了核心痛点：

**立即行动建议**：
1. **评估现有 Agent**：检查是否涉及多用户 + 敏感数据访问
2. **选择合适模式**：
   - 需要用户数据隔离 → Assistants
   - 统一服务入口 + 可控权限 → Claws
3. **试点部署**：从非核心业务开始，验证权限模型是否符合预期

**观望建议**：
- 如果当前 Agent 是单用户使用，无需急于迁移
- 等待更多渠道支持 Assistants 模式（目前支持有限）

**关键洞察**：这个更新反映了 Agent 基础设施的成熟——从「能跑」到「能安全地规模化」。对于企业级应用，授权模型的重要性不亚于模型本身。

## 关键代码/配置片段

LangSmith Fleet 的 Agent 创建配置示例（概念性）：

```yaml
# Assistant 配置（on-behalf-of 模式）
agent:
  type: assistant
  channels:
    - slack
  tools:
    - notion
    - rippling
  auth:
    mode: user_credentials  # 运行时注入用户凭证
  sharing:
    enabled: true
    user_mapping: required  # 需要渠道用户 ID → LangSmith ID 映射

# Claw 配置（固定凭证模式）
agent:
  type: claw
  channels:
    - slack
    - email
  tools:
    - calendar
    - email
  auth:
    mode: fixed_credentials  # 使用创建者配置的专用凭证
    credential_id: "cred_abc123"
  guardrails:
    human_in_the_loop:
      enabled: true
      actions: ["send_email", "create_calendar_event"]
```

**凭证管理最佳实践**（来自官方文档）：
- Claws 应使用专用账号（而非创建者个人账号）
- 专用账号权限应遵循最小权限原则
- 敏感操作（发送邮件、创建日程）应配置 HITL 审批

---

*本文基于 LangChain 官方博客分析，原文发布于 2026-03-28（Fleet 发布后一周）。*

[← Back to Deep Dives](./README.md)
