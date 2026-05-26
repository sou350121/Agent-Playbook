---
auto_generated: true
generated_at: "2026-05-26T03:34:57Z"
source_url: "https://www.runtm.com/"
signal_type: "significant_update"
---
# Runtime (YC P26) — 团队级沙盒编码 Agent 基础设施
# (Runtime — Team-Level Sandbox Coding Agent Infrastructure)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-26
>
> **项目/工具**: Runtime (runtm.com)
> **链接**: https://www.runtm.com/blog/sandbox-coding-agents/
> **核心定位**: YC P26 新项目，让全团队（含非工程师）在隔离沙盒中安全使用 Claude Code 等编码 Agent，无需工程师逐 session 护航

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**: Runtime 是一个团队级编码 Agent 运行平台——为每个团队提供带公司上下文、集成和防护护栏的隔离沙盒，让非工程师也能安全使用 Claude Code/Codex 等编码 Agent。
- **现在值得用吗**: 看场景——如果你管理一个 10+ 人的团队，希望让非工程角色（产品、设计、运营、财务）也能通过 AI Agent 完成代码类工作，而不需要工程师逐 session 护航，值得申请 early access 评估。个人开发者直接用 Claude Code 更简单。
- **适合场景**: 多团队协作的编码 Agent 部署；非工程师需要安全使用 AI 编码工具；需要审计和成本管控的企业环境。
- **不适合场景**: 个人开发者；需要极致硬件隔离的高安全场景（容器逃逸风险仍存在）；对 AGPL 许可证敏感的企业。
- **与 E2B/Modal 核心差异**: E2B/Modal 提供通用沙盒基础设施（IaaS 层），Runtime 提供完整的团队级 Agent 平台（PaaS 层），包含 Slack/Linear 集成、审批流、成本追踪、持久化环境。

## 是什么 / 解决什么问题

编码 Agent（Claude Code、Codex CLI、Cursor YOLO 模式）正在快速普及，但它们的使用方式高度个人化——每个开发者在自己的笔记本上运行，手动审批每个命令，自己管理依赖和环境。这种方式在单人场景下有效，但当团队规模扩大时，三个问题变得突出：

**第一，安全风险**。Anthropic 的 `--dangerously-skip-permissions` 标志本身就暗示了风险：Agent 可能删除文件、安装恶意脚本、泄露本地数据。Reddit 上已有 Claude 删除用户文件的案例。让非工程师"跳过审批"直接跑 Agent，风险更大。

**第二，环境碎片化**。每个开发者的本地环境不同——不同的包版本、不同的配置、不同的权限。当产品或运营人员需要跑一个编码 Agent 时，他们甚至没有合适的开发环境。

**第三，缺乏治理**。没有人知道团队里有多少 Agent 在跑、花了多少钱、改了什么文件、是否触碰了生产数据。

Runtime 的解决方案是：**为每个团队提供一个持久化的隔离沙盒**，预装所有需要的工具链和集成，Agent 在沙盒内运行，用户通过 Slack/Linear/GitHub 等已有工具与 Agent 交互，管理员可以实时监控所有 session、设置成本上限和审批门。

## 技术架构拆解

### 核心设计决策

Runtime 的架构围绕四个核心决策构建：

**1. 隔离层选择：容器级隔离（Docker + gVisor），冷启动 ~500ms**

Runtime 团队在博客中详细对比了四种隔离方案：

| 方案 | 隔离级别 | 冷启动 | 持久化 | 成本 |
|------|---------|--------|--------|------|
| 模拟环境 (just-bash) | 应用层 | <1ms | 无 | 免费 |
| 容器 (Docker/gVisor) | OS 级 | ~500ms | 可选 | $0.02-0.05/hr (自建) |
| 临时 VM (E2B/Modal) | 硬件级 | ~125ms | Session 级 | $0.10-0.15/hr (托管) |
| 持久 VM (Fly Sprites) | 硬件级 | 1-2s 创建, 即时唤醒 | 持久 | $0.10-0.15/hr (自动休眠) |

Runtime 选择容器方案是在隔离强度、启动速度和成本之间的权衡。gVisor 通过用户态内核拦截系统调用，减少了主机内核暴露面，但代价是部分系统调用不兼容（见下文实战陷阱）。

**2. 网络隔离 = 域名白名单代理**

Runtime 团队发现一个关键洞察："网络隔离和文件系统隔离同样重要"。完全禁用网络不现实（Agent 需要 pip install、npm install、git clone），但开放网络意味着数据可能泄露到任意端点。

解决方案：所有网络流量经过代理网关，只允许批准的域名（pypi.org、github.com、npmjs.org 等）。这个模式出现在 Anthropic 的 web sandbox、Claude Code 本地沙盒和所有托管服务中——说明这是行业共识方案。

**3. 持久化运行时（Persistent Runtime）**

与 E2B/Modal 的临时沙盒不同，Runtime 强调环境的持久性：

```
Session 1: 创建数据库 schema
Session 2: 添加种子数据
Session 3: 构建 API 端点
Session 4: 用真实数据测试
Session 5: 部署到生产
```

每个 session 建立在前一个之上。Agent 写的文件下周还能读，node_modules 不需要每次都重新安装。这对于需要多轮迭代的真实开发工作至关重要。

**4. 开源策略：分层开源**

| 组件 | 许可证 | 说明 |
|------|--------|------|
| Templates | MIT | 最宽松，鼓励复用 |
| CLI & Shared libs | Apache 2.0 | 允许商业使用 |
| API & Worker | AGPL v3 | 要求衍生作品开源 |

这种分层策略允许用户自由使用模板和 CLI，但核心的 API 和 Worker 服务需要 AGPL 合规或商业授权。对大型企业来说，AGPL 是一个需要法务评估的因素。

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    用户层 (User Layer)                    │
│  Slack / Linear / GitHub / Jira / 浏览器 / Terminal / API│
└────────────────────────┬────────────────────────────────┘
                         │ @mention / API call
┌────────────────────────▼────────────────────────────────┐
│               编排层 (Orchestration Layer)                │
│  • Session 管理    • 任务路由    • 审批门 (Approval Gates)│
│  • 成本追踪 (per agent/user/team)    • 实时可见性         │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│              沙盒层 (Sandbox Layer)                       │
│  • Docker + gVisor 容器隔离   • 域名白名单网络代理        │
│  • 预装工具链 (mise/npm/brew)  • PII 脱敏 + 行级数据范围  │
│  • 持久化文件系统 + 快照恢复                                │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│              集成层 (Integration Layer)                   │
│  数据仓库: Snowflake / BigQuery / Redshift               │
│  计费: Stripe / NetSuite / QuickBooks                    │
│  HR: Rippling / Gusto / Workday / Deel                   │
│  CRM: HubSpot / Segment / GA4                            │
│  客服: Zendesk / Intercom                                │
│  告警: PagerDuty / Sentry / Datadog                      │
│  工程: GitHub / Linear / Notion                          │
│  + 任意 MCP Server / CLI / REST API                      │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│              模型层 (Model Layer)                         │
│  Claude Code / Codex CLI / 其他编码 Agent                │
│  (支持自托管: 自有云 + 自有模型 + 自有密钥)                │
└─────────────────────────────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | Claude Code (本地) | E2B / Modal | Runtime |
|------|-------------------|-------------|---------|
| 目标用户 | 单个开发者 | 开发者 (基础设施) | 全团队 (含非工程师) |
| 隔离方式 | bubblewrap/Seatbelt (弱) | Firecracker VM (强) | Docker + gVisor (中) |
| 网络控制 | 有限 | 无（需自建） | 域名白名单代理（内置） |
| 持久化 | 本地文件系统 | Session 级临时 | 持久化环境 + 快照 |
| 团队协作 | 无 | 无 | Slack/Linear 集成 + 命名 Agent |
| 审计/治理 | 无 | 有限 | 完整：session 可见性 + 成本追踪 + 审批门 |
| 自托管 | ✅ | N/A (托管) | ✅ 完整自托管 |
| 冷启动 | N/A (本地) | ~125ms | ~500ms (预构建镜像) |
| 定价 | 免费/$100-200/mo | $0.10-0.15/hr | 未公开 (YC 阶段) |

### 架构权衡的独到洞察

Runtime 的选择揭示了一个更深层的趋势：**Agent 基础设施正在从"运行代码"演进为"运行工作流"**。

传统的沙盒（E2B/Modal）关注的是"给 Agent 一个干净的 OS 环境"——这是基础设施思维。Runtime 关注的是"让 Agent 在团队的工作流中安全运转"——这是平台思维。两者的区别在于：

- **基础设施层**解决的是隔离和启动速度问题（How to run safely and fast）
- **平台层**解决的是治理和协作问题（How to govern and collaborate at scale）

Runtime 选择容器而非 VM，说明他们认为对于编码 Agent 场景，启动速度和成本比极致隔离更重要——因为编码 Agent 的沙盒生命周期短（单次 session 通常 <30min），且运行的是开发者熟悉的工具链（git、npm、pip），而非不可信的二进制。这个判断在大多数场景下成立，但 gVisor 的系统调用兼容性问题是真实风险（见下文）。

## ⚠️ 实战陷阱

### 陷阱 1: gVisor 系统调用兼容性

gVisor 通过用户态内核拦截系统调用，但它并不实现所有 Linux syscall。一些冷门但常用的工具可能出问题：
- **某些 FUSE 操作**：如果 Agent 需要挂载远程文件系统（如 s3fs），gVisor 可能不支持对应的 FUSE ioctl
- **某些 ptrace 操作**：调试器（如 gdb）和部分性能分析工具依赖 ptrace，gVisor 对 ptrace 的支持有限
- **某些 seccomp 相关操作**：如果 Agent 尝试修改自身的 seccomp 配置，会被 gVisor 拦截

**应对**: 在正式部署前，用团队最常用的工具链做兼容性测试。重点关注：数据库客户端连接、cgroup 操作、网络命名空间操作。

### 陷阱 2: 域名白名单误杀内部私有源

很多企业的内部服务（私有 npm registry、内部 GitLab、私有 PyPI mirror）不在公网域名白名单中。如果 Runtime 的默认白名单不包含这些内部域名，Agent 在沙盒内将无法访问。

**应对**: 部署时主动将内部域名加入白名单。特别注意：某些 SaaS 工具会动态分配子域名（如 `*.internal.company.com`），需要通配符支持或提前枚举。

### 陷阱 3: 持久化环境的"脏状态"累积

持久化沙盒意味着状态会累积。Agent A 安装的包可能和 Agent B 的依赖冲突；数据库 schema 变更可能没有回滚；临时文件可能占满磁盘。

**应对**: 建立定期快照 + 清理策略。建议：每次重要 session 后打快照，每周做一次环境重置，监控磁盘使用量。

### 陷阱 4: AGPL v3 合规风险

Runtime 的 API & Worker 组件采用 AGPL v3 许可证。如果企业修改了这些组件并对外提供服务，需要开源修改后的代码。对大型企业来说，这可能触发法务审查。

**应对**: 如果不打算修改 API/Worker，直接使用官方镜像，AGPL 风险较低。如果需要定制，提前咨询法务。

## 生存指南（落地建议）

1. **申请 Early Access 做 PoC**: Runtime 刚进 YC P26，官方尚未公开定价。先申请 early access，用一个 5-10 人的小团队做 PoC，验证 gVisor 兼容性和域名白名单配置是否满足需求。
2. **从 Slack 集成开始，而非 API**: Runtime 的 Slack 集成是最成熟的使用路径——命名 Agent（如 `@runtime-finance`），@mention 触发任务，回复带 source rows 和 cost。比直接调 API 低摩擦得多。
3. **先配置审批门，再开放使用**: 在让非工程师使用之前，先设置好 production writes 的 PR review 流程。确保 Agent 不会直接修改生产数据。这是 Runtime 区别于本地 Claude Code 的最大价值——不配置审批门就失去了这个价值。
4. **监控 token 成本 per session**: Runtime 提供 per agent/user/team 的成本追踪。建议设置 session 级 cost cap（如 $5/session），防止 Agent 陷入无限循环消耗 token。

## Claude Code 集成视角

对于已经在使用 Claude Code 的团队，Runtime 提供的价值在于**将个人工具转化为团队平台**：

- **权限调优**: 本地 Claude Code 的 `--dangerously-skip-permissions` 在 Runtime 沙盒中等价于"信任沙盒隔离"。Runtime 的 gVisor + 域名白名单提供了比本地 bubblewrap 更强的隔离，但弱于 Firecracker VM。对于大多数编码场景，这个隔离级别足够。
- **Claude Code 的 MCP Server 支持**: Runtime 支持接入任意 MCP Server。如果团队已经为 Claude Code 配置了内部工具的 MCP 集成（如内部 API 文档查询、代码库搜索），这些可以直接迁移到 Runtime 沙盒中。
- **Session 可观测性**: Runtime 提供 tool calls、chain of thought、file changes 的实时可见性。这对于调试 Agent 行为和理解 Agent 决策过程非常有帮助——本地 Claude Code 没有这个能力。

## 对你的意义

对于 Ken 的 AI 应用开发方向，Runtime 代表了一个值得关注的趋势：**编码 Agent 从个人工具演变为团队基础设施**。

具体来说：
1. **Agent 安全治理正在成为产品需求**：Runtime 的域名白名单代理、审批门、成本追踪等功能，说明市场已经开始认真对待 Agent 的安全问题。这与 A-002 假设（Agentic Coding 在初级任务达 80% 成功率）直接相关——当成功率提升，规模化部署的安全和治理需求就会浮现。
2. **持久化运行时 vs 临时沙盒**：这是一个架构层面的重要分歧。如果 Agent-Playbook 涉及 Agent 基础设施选型，这个对比（容器 vs VM、临时 vs 持久）值得收录为参考架构。
3. **YC P26 的方向信号**：YC 在这一批中押注了"团队级 Agent 基础设施"这个方向，说明投资人认为这是下一个增长点。值得持续关注 Runtime 的产品迭代和早期用户反馈。

**建议**: 申请 early access 做 PoC 评估，但不急于生产部署。Runtime 刚进 YC，产品成熟度和长期可持续性待验证。如果 PoC 验证了 gVisor 兼容性和审批流满足需求，可以在小团队中试用。

## 关键代码/配置片段

Runtime 博客中披露的隔离方案对比数据（来源：[Running coding agents without burning down your machine](https://www.runtm.com/blog/sandbox-coding-agents/)）：

```
Approach          | Isolation     | Cold Start | Persistence    | Cost
------------------|---------------|------------|----------------|---------------------
Simulated         | Application   | <1ms       | None           | Free
Containers        | OS-level      | ~500ms     | Optional       | $0.02-0.05/hr (self)
Ephemeral VMs     | Hardware      | ~125ms     | Session-scoped | $0.10-0.15/hr (managed)
Durable VMs       | Hardware      | 1-2s/inst  | Persistent     | $0.10-0.15/hr (sleep)
```

关于网络隔离的核心结论（同上来源）：

> "Every implementation we looked at landed on the same insight: you need network control. ... The answer is a proxy with an allowlist. Traffic routes through a gateway that only permits approved domains like pypi.org, github.com, and npmjs.org."

开源许可证分层（来源：[runtm.com 官网](https://www.runtm.com/)）：

```
Templates        → MIT
CLI & Shared libs → Apache 2.0
API & Worker     → AGPL v3
```

---
[← Back to Deep Dives](./README.md)
