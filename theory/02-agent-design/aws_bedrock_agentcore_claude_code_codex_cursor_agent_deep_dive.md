---
auto_generated: true
generated_at: "2026-06-09T03:34:37Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/its-safe-to-close-your-laptop-now-hosting-coding-agents-on-amazon-bedrock-agentcore/"
signal_type: "blog_post"
---
# AWS Bedrock AgentCore：把编程 Agent 从笔记本搬到云端 (Hosting Coding Agents on Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-09
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime
> **链接**: https://aws.amazon.com/blogs/machine-learning/its-safe-to-close-your-laptop-now-hosting-coding-agents-on-amazon-bedrock-agentcore/
> **核心定位**: 为 Claude Code / Codex / Cursor 等编程 Agent 提供云端托管的微 VM 环境，让开发者可以合上笔记本继续跑 Agent，同时满足企业级安全、可观测和并行需求。

## 快速判断

- **一句話定位**：AWS 推出的编程 Agent 云端托管平台，每个 Agent 会话运行在独立的 Firecracker 微 VM 中，支持持久化工作区、交互式 Shell、MCP 工具网关和企业级身份管理。
- **现在值得用吗**：看场景。如果你已经在 AWS 生态中、有企业安全合规要求、或需要并行运行多个 Agent，值得立即评估。个人开发者或小团队可能觉得过重。
- **适合场景**：企业级 Agent 部署、多 Agent 并行 A/B 测试、需要安全隔离和审计的团队、长时间运行的 Agent 任务（重构/迁移/CI）
- **不适合场景**：个人快速实验（本地更轻量）、非 AWS 用户（绑定较深）、需要 GPU 加速的 Agent（微 VM 无 GPU）
- **与竞品核心差异**：相比 GitHub Codespaces / Gitpod 等云端开发环境，AgentCore 的核心差异化是 **Agent-first 设计**——MCP Gateway 统一管理工具凭证、Identity 层实现 on-behalf-of 令牌交换、Firecracker 微 VM 级别的物理隔离。

## 是什么 / 解决什么问题

编程 Agent（Claude Code、Codex、Cursor CLI 等）正在改变软件开发方式，但它们有一个根本问题：**运行在哪里**。

目前大多数编程 Agent 跑在开发者的笔记本上。这带来四个结构性问题：

1. **安全攻击面过大**：Agent 共享开发者的 shell、文件系统、SSH 密钥、AWS 凭证、VPN。一个被 prompt 注入的 README 就能拿到所有凭据。
2. **秘密与代码相邻**：`.env`、`~/.aws/credentials`、`~/.ssh/id_ed25519` 都在同一个 shell 中可访问，最小权限原则完全不存在。
3. **并行是半解决方案**：用 `git worktree` 跑多个 Agent 只是逻辑隔离，它们仍然共享同一个 localhost:5432、同一个 :3000 端口、同一个 SSH keyring、同一个出站 IP。三个 Agent 在三个分支上就是三个进程在抢一台机器。
4. **笔记本盖子就是杀开关**：合上盖子 = 挂起 Agent。开会给半小时、坐飞机两小时、甚至只是去吃个午饭，半完成的重构、正在跑的测试套件、正在安装的依赖——全部丢失。

AWS 的解决方案很直接：**把 Agent 从笔记本搬到一个独立的、持久的、企业级管理的微 VM 中**。Agent Core Runtime 为每个会话提供：

- 独立的 Linux 微 VM（基于 Firecracker）
- 持久化的 `/mnt/workspace` 目录（停止/恢复后文件仍在）
- 真正的交互式 PTY Shell
- 确定性的命令行执行（不经过 LLM）
- MCP Gateway 统一管理工具凭证
- Identity 层实现用户身份代理
- CloudWatch 可观测性开箱即用

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| Firecracker 微 VM 而非容器 | 物理隔离，每个会话独立内核、独立文件系统、无端口/进程冲突 |
| 持久化 `/mnt/workspace` | Agent 的工作状态（node_modules、.git、build cache）需要跨会话保留，14 天不活跃期 |
| MCP Gateway 统一工具接入 | 避免把 GitHub/Jira/Slack 凭证塞进微 VM 的 `~/.netrc`，凭证在 Gateway 层管理 |
| Identity on-behalf-of 令牌交换 | PR 归因到具体开发者而非共享 bot，符合企业审计要求 |
| 模型无关 | Agent 用什么模型、走什么路由（Bedrock / 直连 / 自有 Gateway）由 harness 决定，Runtime 不干预 |
| 按实际 CPU/内存计费 | I/O 等待不额外收费，适合 Agent 这种 I/O 密集的工作负载 |

### 与前版/竞品的关键差异

| 维度 | 笔记本本地运行 | GitHub Codespaces / Gitpod | AgentCore Runtime |
|------|---------------|---------------------------|-------------------|
| 隔离级别 | 无隔离（共享 host） | 容器级别 | Firecracker 微 VM（物理隔离） |
| 持久化 | 本地磁盘 | 容器卷 | `/mnt/workspace` + S3/EFS 挂载 |
| 并行能力 | worktree（逻辑隔离） | 多 codespace（需分别创建） | 秒级创建 N 个微 VM，天然并行 |
| 凭证管理 | 本地 `~/.aws/credentials` | 依赖 codespace 注入 | Gateway MCP + Identity 令牌交换 |
| 可观测性 | 无 | 有限 | CloudWatch + CloudTrail + OTel 全链路 |
| VPC 集成 | 无 | 有限 | 完整 VPC 模式，安全组/私有端点/Network Firewall |
| 盖子合上 | 会话死亡 | 不受影响 | 不受影响 |
| 最大运行时间 | 受限于电池/笔记本 | 通常数小时 | 8 小时 |
| 模型路由 | 直连 API | 直连 API | Bedrock / 直连 / 自有 Gateway 三选一 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Laptop                         │
│                                                                 │
│  Claude Code / Codex / Cursor / Kiro / OpenCode / Gemini CLI   │
│         │                                    │                  │
│         ▼                                    ▼                  │
│  MCP Config (1 line)              agentcore exec --it           │
│  ──> Gateway URL                   ──> Interactive Shell        │
└────────┬────────────────────────────────────┬───────────────────┘
         │                                    │
         ▼                                    ▼
┌─────────────────────┐            ┌──────────────────────────┐
│  AgentCore Gateway   │            │  AgentCore Runtime CLI   │
│                      │            │  (agentcore exec)        │
│  ┌────────────────┐  │            └──────────┬───────────────┘
│  │ Tool Catalog   │  │                       │
│  │ (GitHub/Jira/  │  │                       ▼
│  │  Slack/Lambda) │  │            ┌──────────────────────────┐
│  └───────┬───────┘  │            │   Firecracker MicroVM    │
│          │          │            │   (per session)          │
│  ┌───────▼───────┐  │            │                          │
│  │ Identity Layer│  │            │  /mnt/workspace (persist)│
│  │ Token Vault   │  │            │  /mnt/skills (S3 mount)  │
│  │ (OAuth RFC    │  │            │  /mnt/cache (EFS mount)  │
│  │  8693 exchange)│  │            │                          │
│  └───────────────┘  │            │  PTY Shell (interactive) │
└─────────────────────┘            │  Deterministic commands  │
         │                         │  (InvokeAgentRuntimeCmd) │
         ▼                         └──────────┬───────────────┘
┌─────────────────────┐                       │
│  AWS Services       │                       │
│  CloudTrail (audit) │                       │
│  CloudWatch (OTel)  │                       │
│  Secrets Manager    │            ┌──────────▼───────────────┐
│  VPC / Security Grp │            │   Model Routing          │
└─────────────────────┘            │  Bedrock / Direct / GW   │
                                   └──────────────────────────┘
```

### 四大核心能力详解

#### 1. 持久化工作区 `/mnt/workspace`

每个会话有一个零配置的持久目录。微 VM 空闲退出后，文件系统保留。用同一个 session ID 恢复时，新的微 VM 在毫秒级挂载同一文件系统。数据保留 14 天不活跃期。

```python
client.create_agent_runtime(
    agentRuntimeName="acme-coding-agent",
    agentRuntimeArtifact={"containerConfiguration": {"containerUri": "..."}},
    filesystemConfigurations=[
        {"sessionStorage": {"mountPath": "/mnt/workspace"}}
    ],
    roleArn="arn:aws:iam::...:role/AgentExecutionRole",
)
```

对比笔记本上的 `git worktree`：worktree 只是逻辑隔离（共享 repo history），而 AgentCore 提供物理隔离——独立的 build cache、独立的 node_modules、独立的文件系统状态。

#### 2. 真正的交互式 Shell

2026 年 6 月 5 日新增功能。`agentcore exec --it` 打开 PTY 支持的 shell 直接进入运行中的微 VM。支持颜色、tab 补全、Ctrl+C、终端缩放、网络断开自动重连。

```bash
# 进入 Agent 的 VM
agentcore exec --it --runtime acme-coding-agent --session-id sess-jane-1234

# 稍后重连到同一个 shell
agentcore exec --it --session-id sess-jane-1234 --shell-id shell-789
```

每个交互会话有两个 ID：runtime session ID（哪个微 VM）和 shell ID（微 VM 内的哪个 shell）。传回两者就能回到同一个 shell、同一个工作目录、同一个滚动历史——无需重启、无需 re-clone。

#### 3. 确定性命令执行

不经过 LLM 直接执行 shell 命令。适合跑测试套件、推分支、安装依赖等确定性操作——无 token 消耗、无概率性决策。

```bash
agentcore exec --runtime acme-coding-agent --session-id sess-jane-1234 \
    "cd /mnt/workspace && npm test"
```

Agent 刚写的文件对命令立即可见，通过 HTTP/2 流式返回 stdout/stderr。

#### 4. 自带文件系统（S3/EFS 挂载）

跨会话共享数据（团队 Skills 库、共享依赖缓存、流水线产物）可通过 S3 Files 或 EFS access point 挂载为 POSIX 目录。每个 runtime 最多 5 个挂载点。

```python
filesystemConfigurations=[
    {"sessionStorage": {"mountPath": "/mnt/workspace"}},
    {"s3FilesAccessPoint": {"accessPointArn": "...", "mountPath": "/mnt/skills"}},
    {"efsAccessPoint": {"accessPointArn": "...", "mountPath": "/mnt/cache"}},
]
```

### 工具与凭证：安全的方式

这是 AgentCore 最有设计深度的部分。Gateway + Identity 提供了三种凭证模式：

| 模式 | 适用场景 | 工作原理 | PR 归因 |
|------|---------|---------|---------|
| Bot Pattern | Agent 自主操作 | GitHub bot + fine-grained PAT，Gateway Token Vault 管理 | 归因到 bot |
| On-Behalf-Of | Agent 代表人操作 | IdP 登录 → OAuth 2.0 Token Exchange (RFC 8693) → GitHub-scoped token | 归因到开发者 |
| Broker Pattern | 完全控制凭证流 | Gateway → Lambda 获取凭证 → 代理请求，凭证永不返回 Agent | 取决于 Lambda 实现 |

```bash
# Claude Code 接入 Gateway — 一行配置
claude mcp add agentcore \
    https://<gateway-id>.gateway.bedrock-agentcore.us-west-2.amazonaws.com/mcp \
    --transport http

# Codex CLI
[mcp_servers.agentcore]
url = "https://<gateway-id>.gateway.bedrock-agentcore.us-west-2.amazonaws.com/mcp"
```

**一个已知限制**：GitHub MCP server 无法 clone 私有仓库（没有 clone verb）。初始拉取仍需通过 git + 凭证。AWS 建议用 fine-grained PAT（只读 scope）或 deploy key，存在 Secrets Manager，会话启动时通过 Identity 获取，clone 一次后所有其他 GitHub 操作走 Gateway。

### VPC 网络控制

Agent 可以运行在用户的 VPC 内，这意味着：

- **包安装**：Route 53 private zone 将 pypi.org 解析到内部 CodeArtifact 镜像
- **Git 操作**：安全组只允许出站 443 到 GitHub Enterprise IP 范围，prompt 注入的 `git remote set-url` 在 TCP 层失败
- **构建工具链**：NAT Gateway + Network Firewall 域名白名单控制

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| 企业多 Agent 并行开发 | 物理隔离 + MCP Gateway + Identity = 安全合规开箱即用 |
| Agent A/B 测试 | 秒级创建 N 个微 VM，同一 prompt 跑 Claude Code vs Codex vs Cursor |
| 长时间运行任务 | 90 分钟重构/ overnight 迁移不再需要笔记本盖子一直开着 |
| 平台团队统一 Agent 基础设施 | VPC + CloudTrail + CloudWatch + 凭证管理 = 平台工程的标准需求 |
| 安全敏感环境 | 凭证不在 LLM 控制的微 VM 内，网络在安全组控制下 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| 个人快速实验 | 本地跑 Claude Code 更简单，不需要 VPC/Gateway/Identity 的复杂度 |
| 非 AWS 用户 | 深度绑定 AWS 生态（VPC、Secrets Manager、CloudWatch、ECR） |
| 需要 GPU 的 Agent | Firecracker 微 VM 无 GPU 支持 |
| 预算敏感的小团队 | 按实际 CPU/内存计费，但微 VM 本身有基础成本 |
| 已有成熟 CI/CD 且不需要 Agent 并行 | 传统 CI 已经满足需求，引入 AgentCore 增加运维负担 |

### 迁移成本

从笔记本本地迁移到 AgentCore：

1. **Agent 打包**：将 Agent 容器化或 zip 部署（Python/Node.js 项目直接部署），预计 1-2 小时
2. **Gateway 配置**：注册工具（GitHub/Jira/Slack），配置 MCP endpoint，预计 2-4 小时
3. **Identity 配置**：连接 IdP、配置 on-behalf-of 令牌交换，预计 4-8 小时（取决于 IdP 复杂度）
4. **VPC 网络**：如果启用 VPC 模式，配置安全组/私有端点/Route 53，预计 4-8 小时
5. **开发者适配**：修改 Agent 的 MCP 配置指向 Gateway URL（一行），预计 10 分钟

**总计**：平台团队 1-2 周完成基础设施搭建，开发者端迁移几乎零成本。

## 对你的意义

这个发布对 Ken 的两条线都有信号意义：

**AI 应用线**：
- AgentCore 是 **第一个将编程 Agent 作为一等公民的云平台产品**。它不是"云端 IDE"，而是"云端 Agent 运行时"。这个定位差异很重要。
- MCP Gateway 作为统一工具接入层，是 MCP 协议在企业级场景的一个重要落地案例。
- 三种凭证模式（bot / on-behalf-of / broker）几乎涵盖了所有企业集成场景，可以作为 Agent 凭证管理的参考架构。

**VLA 研究线**（间接）：
- AgentCore 的"持久化工作区 + 微 VM 隔离 + MCP 工具接入"架构模式，与具身智能中的"持久化记忆 + 隔离执行环境 + 工具标准化"有结构相似性。虽然领域不同，但架构思路可以互相借鉴。

**建议**：如果团队在 AWS 上跑 Agent 开发，值得立即评估。如果只是个人使用，可以先关注——这个产品定义了一个新的品类，未来可能会有更轻量的版本。

## 关键代码/配置片段

### 创建 Runtime 并挂载持久化工作区

```python
client.create_agent_runtime(
    agentRuntimeName="acme-coding-agent",
    agentRuntimeArtifact={"containerConfiguration": {"containerUri": "..."}},
    filesystemConfigurations=[
        {"sessionStorage": {"mountPath": "/mnt/workspace"}}
    ],
    roleArn="arn:aws:iam::...:role/AgentExecutionRole",
)
```

### 确定性命令执行（不经过 LLM）

```python
client.invoke_agent_runtime_command(
    agentRuntimeArn=ARN,
    runtimeSessionId=sid,
    body={"command": "cd /mnt/workspace && npm test", "timeout": 300},
)
```

### 多 Agent 并行配置（Race/Bench 实验）

```python
AGENTS = {
    "claude-code": {
        "name": "Claude Code",
        "default_model": "global.anthropic.claude-opus-4-8",
    },
    "kiro": {
        "name": "Kiro",
        "default_model": "auto",
    },
    "codex": {
        "name": "Codex",
        "default_model": "openai.gpt-5.5",
    },
    "hermes": {
        "name": "Hermes",
        "default_model": "global.meta.llama4-maverick-17b-instruct-v1:0",
    }
}
```

### Gateway MCP 接入（一行配置）

```bash
# Claude Code
claude mcp add agentcore \
    https://<gateway-id>.gateway.bedrock-agentcore.us-west-2.amazonaws.com/mcp \
    --transport http
```

## 客户案例

| 客户 | 场景 | 成果 |
|------|------|------|
| Thomson Reuters | CoCounsel AI Agent（法律工作流） | 平台工程自动化，首发 15x 生产力提升 |
| Iberdrola | IT 运维 Agent（LangGraph） | VPC 内运行，Runtime + Identity + Gateway |
| Cox Automotive | 17 个 Agent 生产部署 | 从零到生产仅用一个月 |
| Druva | 8-10 个网络安全 Agent 编排 | Identity 精细化权限隔离 |
| Kollab | 团队 AI 工作空间 | 持久化工作区支持每日定时任务状态累积 |

> TODO: 具体定价信息未在博客中披露，需查阅 [Pricing 页面](https://aws.amazon.com/bedrock-agentcore/pricing/) 确认微 VM 小时成本和存储成本。

---
[← Back to Deep Dives](./README.md)

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AgentCore Gateway 以 MCP 作为统一工具接入协议，支持 Claude Code/Codex/Cursor/Kiro/OpenCode 等所有主流编程 Agent，表明 MCP 在企业级平台中已被采纳为标准 |
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | AgentCore 提供 Race/Bench 实验框架，直接支持多 Agent 对比测试（延迟/成本/测试通过率），说明 agentic coding 已进入工程化评估阶段而非实验阶段 |
