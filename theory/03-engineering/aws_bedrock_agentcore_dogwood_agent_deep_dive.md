---
auto_generated: true
generated_at: "2026-08-15T08:05:48Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/control-agent-behaviors-and-cost-beyond-a-single-action-new-capabilities-in-amazon-bedrock-agentcore/"
signal_type: "significant_update"
---
# AWS Bedrock AgentCore 推出 Dogwood 策略语言：跨动作时序控制 Agent 行为 (Control Agent Behaviors and Cost Beyond a Single Action: New Capabilities in Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-15
>
> **项目/工具**: Amazon Bedrock AgentCore Gateway + Dogwood Policy Language
> **链接**: https://aws.amazon.com/blogs/machine-learning/control-agent-behaviors-and-cost-beyond-a-single-action-new-capabilities-in-amazon-bedrock-agentcore/
> **核心定位**: 为 AI Agent 网关引入时序策略引擎（Temporal Policies）和速率限制，解决"单个动作合法但序列行为越权"的企业级安全盲区

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AWS 在 Bedrock AgentCore 网关中引入了基于 Dogwood 语言的时序策略引擎，使 Agent 安全控制从"逐动作检查"升级为"跨动作序列检查"
- **現在值得用嗎**：是——如果你正在 AWS 上运行多 Agent 系统，或正在评估 Agent 安全治理方案
- **適合場景**：金融/支付场景的预算控制、工作流顺序强制、会话级速率限制、合规审计
- **不適合場景**：非 AWS 基础设施的 Agent 部署（Dogwood 开源但 AgentCore 网关是 AWS 托管服务）、单 Agent 简单任务（overkill）
- **與傳統 guardrails 核心差異**：传统 guardrails 只检查单个请求；Dogwood 检查动作序列（"它之前做过什么"）

## 是什么 / 解决什么问题

根据 McKinsey 2026 年报告，约 **80% 的组织** 已经遇到过 AI Agent 的危险行为。安全与信任顾虑已成为扩展 Agentic AI 的首要障碍。

问题的根源在于：**现有安全控制只检查单个动作，不检查动作序列**。一个 Agent 可能：
- 先查询客户账户，再把钱转到另一个账户——每个调用单独看都合法
- 连续下多笔订单，每笔都低于审批阈值——没有人在意总额
- 反复调用失败的工具直到跑完 token 预算——没有上限控制

每个请求单独判断都通过，但序列组合起来就是事故。**模式只在序列中可见，而 Agent 自身不可能自我检测。**

AWS 的解决方案是两层：
1. **时序策略（Temporal Policies）**：在网关层检查 Agent 在当前会话中的动作序列
2. **速率限制（Rate Limiting）**：在网关层限制每个用户的 token/请求/连接消耗

两者都在 AgentCore Gateway 执行——一个全托管、无服务器的 AI 流量入口点。Agent 代码无需任何修改。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| 网关层执行策略 | 所有请求必经网关，是施加限制的最可靠位置 |
| 策略逻辑与 Agent 代码分离 | Agent 看不到策略，无法通过 prompt 或缺陷绕过 |
| 基于 Cedar 构建 Dogwood | Cedar 是 AWS 经过验证的策略语言（已用于 AWS IAM） |
| 开源 Dogwood 规范 + 参考实现 | 客户可完全审查策略评估逻辑，生态可构建工具 |
| 默认拒绝（Deny by Default） | 安全基线：未被明确允许的一律禁止 |
| 确定性判定 | 不依赖 LLM 判断，策略是确定性的 |

### Dogwood 语言核心特性

Dogwood 基于 Cedar 的 `permit/forbid` 语法，增加了**时序构造**：

| 特性 | 说明 |
|------|------|
| `formerly within <window>` | 检查某动作是否在时间窗口内发生过 |
| `since <event>` | 检查自某事件以来的动作序列 |
| `once` | 确保某动作在整个会话中只执行一次 |
| 聚合（Aggregations） | 对会话内动作进行计数/求和，支持预算控制 |
| 信息提供者（Information Providers） | Rhai 脚本在评估时注入计算事实作为上下文 |
| 编译到 Cedar | Dogwood 策略降阶为标准 Cedar，时序条件变为 `context.*` 槽位 |
| 可插拔后端 | 策略引擎（本地 Cedar / 远程策略库）和时序引擎（内存 / 数据库）独立替换 |

### 与前版/竞品的关键差异

| 维度 | 传统 Agent Guardrails | AgentCore + Dogwood |
|------|----------------------|---------------------|
| 检查粒度 | 单个请求 | 动作序列 + 单个请求 |
| 预算控制 | 无（或应用层自行实现） | 会话级聚合 + 网关层强制 |
| 工作流顺序 | 无（依赖 Agent 自行遵守） | 策略强制步骤顺序 |
| 速率限制 | 无（或独立系统） | 集成在网关，按用户/工具/模型分别设置 |
| 绕过可能 | Agent 可能通过 prompt 绕过 | 策略在 Agent 外部执行，无法绕过 |
| 审计能力 | 有限 | 每次判定记录完整上下文（含为何被拒） |
| 部署位置 | 应用代码中 | 基础设施层（网关），Agent 代码零修改 |

### 架构/信息流图

```
                    ┌─────────────────────────────────────────┐
                    │           AgentCore Gateway              │
                    │  ┌─────────────┐  ┌──────────────────┐  │
  Agent Request ──► │  │  Cedar Policy │  │  Temporal Engine │  │
                    │  │  (per-action) │  │  (per-session)   │  │
                    │  └──────┬──────┘  └────────┬─────────┘  │
                    │         └────────┬─────────┘            │
                    │                  ▼                       │
                    │         ALLOW / DENY + Audit Log         │
                    └──────────────────┬───────────────────────┘
                                       │
                    ┌──────────────────┼───────────────────────┐
                    │                  ▼                       │
                    │    MCP Servers / LLMs / Agents / KBs     │
                    └──────────────────────────────────────────┘
```

关键路径：
1. Agent 发起工具调用 → Gateway 拦截
2. Cedar 引擎检查单个请求（身份、权限、输入约束）
3. 时序引擎检查会话历史（预算、顺序、频率、前置条件）
4. 两者都通过 → 放行；任一拒绝 → 记录审计日志并拒绝
5. 事件写入会话历史，供后续请求的时序检查使用

### 策略示例：登录后才能读取

Dogwood 仓库中的 `read_after_login` 示例：

```rust
// policy.dw
@id("read_after_login")
permit (
    principal,
    action == Drupe::Action::"Read",
    resource
)
when temporal {
    formerly within 1h Drupe::Action::"Login"::request{
        input.user: context.input.user
    }
};
```

效果：用户必须在 1 小时内登录过才能读取资源。CLI 回放验证：

```
$ dogwood replay policy.dw --schema schema.cedarschema --trace trace.log
@0   (t=0s)    DENY    — 登录本身，无读取请求
@10  (t=10s)   ALLOW   — Alice 刚登录，读取允许
@7200 (t=2h)  DENY    — 登录已过期（超过 1h 窗口）
```

## 实用评估

### 什么场景值得用

- **金融/支付 Agent**：防止越权转账、预算超支、重复下单。时序策略可以要求"转账金额必须与之前查询的账户余额匹配"
- **多步工作流强制执行**：确保 Agent 按顺序执行（先审批 → 后执行），跳过步骤直接拒绝
- **成本治理**：速率限制按用户/工具/模型分别设置 per-second 和 per-minute 上限，防止重试循环或异常会话消耗全部预算
- **合规审计**：每次策略判定都记录完整上下文，满足 SOC2/ISO27001 等审计要求
- **多 Agent 平台**：统一安全基线，无需每个团队自行实现 guardrails

### 什么场景不值得用

- **非 AWS 环境**：Dogwood 语言开源可独立使用，但 AgentCore 网关是 AWS 托管服务。如果你不在 AWS 上运行 Agent，集成成本较高
- **单 Agent 简单任务**：如果 Agent 只做简单的问答或单步操作，传统 guardrails 足够
- **需要 LLM 判断的模糊场景**：Dogwood 是确定性策略引擎，不做概率判断。如果你的安全策略需要"理解意图"，需要额外层
- **对延迟极度敏感的场景**：时序引擎需要维护会话状态，引入额外延迟（TODO: 具体延迟数据待确认）

### 迁移成本

- **现有 Agent 代码**：零修改。策略在网关层执行
- **策略编写**：需要学习 Dogwood/Cedar 语法。AWS 提供 CLI 工具（`validate`、`lower`、`replay`）辅助开发
- **集成**：需要部署 AgentCore Gateway 并将 Agent 流量路由到网关
- **学习曲线**：中等。Cedar 语法对熟悉 IAM 策略的开发者友好；时序构造需要额外理解

## 对你的意义

Dogwood 的开源（Apache 2.0）意味着即使不在 AWS 上，你也可以参考其设计构建自己的时序策略引擎。几个值得关注的点：

1. **"编译到 Cedar" 架构**：Dogwood 策略降阶为标准 Cedar，时序条件变为运行时上下文槽位。这个模式可以复用到其他策略系统中
2. **Rhai 信息提供者**：用 Rhai 脚本在评估时注入计算事实，这是一个灵活的扩展机制
3. **Agent 安全治理趋势**：AWS 明确将"信任"定位为 Agent 创新的瓶颈因素。时序策略是基础设施层安全控制的关键一步——值得在你的 Agent 架构设计中预留类似的策略层

**建议**：如果你在 AWS 上运行 Agent，立即评估 AgentCore Gateway。如果不在 AWS，关注 Dogwood 生态发展——它可能成为 Agent 策略语言的事实标准（类似 Cedar 在 IAM 领域的地位）。

## 关键代码/配置片段

### 时序策略基本模式（来自 AWS Blog）

```rust
// 预算控制：会话内总花费超过阈值则拒绝
permit(principal, action, resource)
when { context.input.amount < 1000 }
when formerly within 1h {
    Action::"Approve"::request{ approver: context.input.approver }
};
```

### Dogwood CLI 工作流

```bash
# 1. 验证策略语法
dogwood validate policy.dw --policy-schema schema.cedarschema

# 2. 降阶到 Cedar（查看编译结果）
dogwood lower policy.dw --policy-schema schema.cedarschema --emit both

# 3. 回放事件轨迹验证策略行为
dogwood replay policy.dw --policy-schema schema.cedarschema --trace events.log
```

### Rust 库集成

```toml
[dependencies]
dogwood-language = { git = "https://github.com/dogwood-policy/dogwood.git" }
```

---
[← Back to Deep Dives](./README.md)
