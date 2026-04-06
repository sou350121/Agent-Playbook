---
auto_generated: true
generated_at: "2026-04-06T03:32:35Z"
source_url: "https://blog.langchain.com/march-2026-langchain-newsletter/"
signal_type: "significant_update"
---
# LangSmith Fleet 正式发布：从 Agent Builder 到企业级智能体管理平台 (LangSmith Fleet GA: From Agent Builder to Enterprise Agent Management Platform)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-06
>
> **项目/工具**: LangSmith Fleet (formerly Agent Builder)
> **链接**: https://blog.langchain.com/march-2026-langchain-newsletter/
> **核心定位**: LangChain 将 Agent Builder 升级为 LangSmith Fleet，新增技能共享、沙箱执行、身份权限管理，标志 AI Agent 从个人实验工具转向企业级生产平台

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: LangSmith Fleet 是 LangChain 推出的企业级 Agent 管理平台，核心升级是「技能（Skills）」系统让团队可共享领域知识，加上沙箱（Sandboxes）提供安全代码执行环境
- **现在值得用吗**: 是 — 如果你在用 LangChain/LangSmith 构建多 Agent 系统，或需要让团队共享 Agent 配置和领域知识
- **适合场景**: 企业内多团队协作开发 Agent、需要安全执行 Agent 生成代码、希望将领域知识（SOP/品牌规范/工作流程）编码为可复用技能
- **不适合场景**: 单人实验性项目、已有成熟的 Agent 部署和知识管理体系、对 LangChain 生态无依赖
- **与 [竞品/前版] 核心差异**: 相比前版 Agent Builder，Fleet 新增技能共享（一次编写，全团队同步）、沙箱隔离执行（微 VM 级别安全）、审计日志和 ABAC 权限控制；相比 AutoGen/CrewAI，Fleet 提供更完整的平台级管理而非纯框架

## 是什么 / 解决什么问题

LangChain 在 2026 年 3 月的月度通讯中正式宣布：**Agent Builder 更名为 LangSmith Fleet**，并同步发布三大核心功能 — Skills（技能）、Sandboxes（沙箱）、Deploy CLI（部署命令行工具）。这不只是改名，而是 LangChain 对 Agent 开发范式的重新定位：从「个人构建工具」转向「企业级智能体舰队管理」。

这次升级解决的核心问题是：**当 Agent 从个人实验走向企业生产时，如何管理知识、安全和协作？**

在早期 Agent 开发中，开发者关注的是「如何让单个 Agent 完成任务」。但当企业开始部署多个 Agent 时，问题变得复杂：
- 客服 Agent 需要知道公司的 SLA 分级政策，销售 Agent 需要了解产品定价策略 — 这些领域知识散落在 Notion、Slack、Wiki 中，每次都要重新注入上下文
- 当某个团队成员离职，他头脑中的「如何处理边缘情况」的知识也随之消失
- Agent 执行代码时如果没有隔离环境，可能意外删除文件或泄露密钥
- 多个团队开发的 Agent 无法共享最佳实践，重复造轮子

LangSmith Fleet 通过「技能系统」和「沙箱执行」两个核心原语来应对这些挑战。

## 技术架构拆解

### 核心设计决策

**1. 技能（Skills）作为知识载体**
- 技能 = 指令 + 领域知识的组合，附加到 Agent 上作为「持久化简报文档」
- 按需加载：Agent 只在判断技能相关时才加载，避免上下文污染
- 一次编写，全团队同步：技能可共享到工作区，所有 Agent 自动继承更新
- 支持 CLI 拉取到本地：`langsmith fleet skills pull web-research` 可将云端技能同步到本地开发环境（Claude Code/Cursor/Codex）

**2. 沙箱（Sandboxes）作为执行边界**
- 微 VM 隔离：每个沙箱运行在硬件虚拟化的 microVM 中，而非仅 Linux namespace
- Auth Proxy：沙箱访问外部服务通过认证代理，密钥不接触运行时
- 支持长会话：WebSocket 持久连接，支持分钟/小时级任务不超时
- 模板化配置：可预定义 Docker 镜像、CPU/内存配置，支持自动扩缩容

**3. 权限与审计**
- ABAC（Attribute-Based Access Control）：在 RBAC 基础上增加标签策略，精细控制谁可访问哪些项目/数据集/提示词
- 审计日志：记录所有管理操作（成员、工作区、数据集、部署），可 API 查询

**4. 部署简化**
- Deploy CLI：一条命令从终端部署到 LangSmith Deployment
- 与 Deep Agents 框架原生集成

### 与前版/竞品的关键差异

| 维度 | Agent Builder (前版) | LangSmith Fleet (当前) | AutoGen/CrewAI (竞品) |
|------|---------------------|----------------------|---------------------|
| 知识管理 | 单 Agent 配置内硬编码 | 可共享技能，团队同步 | 需手动维护提示模板 |
| 代码执行安全 | 无隔离或本地执行 | 微 VM 沙箱，Auth Proxy | 依赖用户自行实现 |
| 权限控制 | 基础 RBAC | ABAC + 标签策略 | 通常无内置权限 |
| 审计能力 | 有限追踪 | 完整审计日志（API 可查） | 需自行集成 |
| 部署方式 | UI 手动操作 | CLI 一键部署 | 通常需自行编写部署脚本 |
| 本地开发同步 | 无 | CLI 拉取技能到本地 | 无 |
| 定位 | 个人/小团队构建工具 | 企业级 Agent 舰队管理 | 开源框架（需自建平台） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                    LangSmith Fleet Platform                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   Skills     │    │  Sandboxes   │    │  Deployment  │      │
│  │   Library    │    │   Pool       │    │   CLI        │      │
│  │              │    │              │    │              │      │
│  │ - SLA Triage │    │ - microVM    │    │ - One-line   │      │
│  │ - Brand Voice│    │ - Auth Proxy │    │   deploy     │      │
│  │ - Refund     │    │ - Templates  │    │ - Deep Agents│      │
│  │   Workflow   │    │ - Autoscale  │    │   integration│      │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘      │
│         │                   │                   │               │
│         ▼                   ▼                   ▼               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Agent Runtime (Fleet)                       │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐    │   │
│  │  │ Agent 1 │  │ Agent 2 │  │ Agent 3 │  │ Agent N │    │   │
│  │  │ + Skills│  │ + Skills│  │ + Skills│  │ + Skills│    │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Governance Layer                            │   │
│  │  - ABAC (Tag-based policies)                             │   │
│  │  - Audit Logs (API queryable)                            │   │
│  │  - Member/Workspace/Dataset access control               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────────┐
         │      Local Development Environment     │
         │  langsmith fleet skills pull <name>    │
         │  → ~/.agents/skills/<name>/SKILL.md    │
         │  → Linked to Claude/Cursor/Codex       │
         └────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

**1. 企业内多团队共享 Agent 配置**
- 场景：客服、销售、市场团队都需要各自的 Agent，但共享公司政策、品牌规范
- 理由：Skills 系统允许「一次编写，全团队同步」，避免每个团队重复配置

**2. 需要安全执行 Agent 生成代码**
- 场景：Agent 需要运行用户提供的代码、执行数据清洗、调用外部 API
- 理由：Sandboxes 提供微 VM 隔离 + Auth Proxy，防止密钥泄露和破坏性操作

**3. 已有 LangChain/LangSmith 技术栈**
- 场景：团队已在使用 LangChain 构建 Agent，需要升级管理能力
- 理由：无缝迁移（只是改名），现有配置继续工作，新增功能渐进采用

**4. 需要合规审计**
- 场景：金融、医疗等受监管行业，需要记录所有 Agent 操作
- 理由：审计日志记录所有管理操作，可 API 查询导出

### 什么场景不值得用

**1. 单人实验项目**
- 理由：Skills 和 ABAC 的价值在于团队协作，单人项目用基础 LangSmith 即可

**2. 已有成熟知识管理体系**
- 理由：如果团队已有完善的 SOP 文档和 Agent 配置管理流程，迁移成本可能高于收益

**3. 对 LangChain 生态无依赖**
- 理由：Fleet 深度集成 LangChain，如果用 AutoGen/LlamaIndex 等框架，切换成本高

**4. 预算敏感**
- 理由：LangSmith 是企业级产品，定价高于开源方案；沙箱目前仅 Private Preview，可能产生额外费用

### 迁移成本

**从 Agent Builder 迁移到 Fleet**:
- 工作量：~0（自动迁移）
- 说明：官方明确表示「所有现有 Agent、配置、集成继续工作，无需更新」

**从其他平台迁移到 Fleet**:
- 工作量：中等（2-5 人天）
- 步骤：
  1. 重新定义 Skills（将现有提示模板/领域知识转换为 Skill 格式）
  2. 配置 Sandboxes（选择 Docker 镜像、设置资源限制）
  3. 设置 ABAC 策略（定义标签和访问规则）
  4. 迁移现有 Agent 配置到 Fleet UI 或 CLI

## 对你的意义

**对 Ken 的 AI 应用开发线的意义**:

1. **Agent-Playbook 可新增「技能模板」分类**
   - Fleet 的 Skills 本质是结构化的 Agent 提示 + 领域知识
   - 可在 `landscape/app-index.md` 中增加「Skill Templates」分类，收集开源技能模板

2. **沙箱架构值得深入研究**
   - Fleet Sandboxes 的微 VM 隔离 + Auth Proxy 设计是行业最佳实践
   - 可写一篇「Secure Code Execution for Agents」的理论文章，对比 OpenClaw/Cursor 的本地执行风险

3. **本地 - 云端同步模式值得借鉴**
   - `langsmith fleet skills pull` 将云端技能同步到本地开发环境（Claude Code/Cursor/Codex）
   - 这种「云端管理、本地开发」的混合模式可能是未来 Agent 开发的标准范式

**建议**: 
- **立即试用**: 如果你在用 LangSmith，直接启用 Skills 功能（GA 可用）
- **观望**: Sandboxes 目前 Private Preview，等生产环境验证后再采用
- **学习**: 阅读「The Anatomy of an Agent Harness」文章，理解 Harness Engineering 的设计思想

## 关键代码/配置片段

**1. 拉取技能到本地开发环境**
```bash
# 从 Fleet 拉取技能到本地
langsmith fleet skills pull web-research --format pretty

# 输出：
# Installed skill "web-research" to ~/.agents/skills/web-research
# Linked: ~/.claude/skills/web-research
#
# web-research-test/
# ├── SKILL.md
# └── references/
#     └── search-tips.md
```

**2. 技能文件结构（SKILL.md 示例）**
```markdown
# Skill: Web Research

## Purpose
Conduct comprehensive web research on any topic, synthesizing 
information from multiple sources.

## Instructions
1. Start by clarifying the research question with the user
2. Use search tools to find relevant sources
3. Evaluate source credibility before citing
4. Synthesize findings into a structured report
5. Include citations with URLs

## Company Guidelines
- Always check internal knowledge base first
- For competitive research, use approved competitor list
- Cite sources using [Company Style Guide](link)
```

**3. 沙箱创建（Python SDK）**
```python
from langsmith import Client

client = Client(api_key="your-api-key")

# 创建沙箱
sandbox = client.sandbox.create(
    image="python:3.11-slim",  # Docker 镜像
    cpu_limit=2,               # CPU 核心数
    memory_limit=4096,         # 内存 MB
    timeout=3600,              # 超时秒数
)

# 执行代码
result = sandbox.run("pip install pandas && python analyze.py")
print(result.output)
```

**4. ABAC 策略示例**
```yaml
# ABAC Policy: 限制特定标签的项目访问
policy:
  name: "project-access-restriction"
  rules:
    - effect: deny
      condition: 
        resource.type: "project"
        resource.tags: ["confidential"]
        subject.department: not_in ["research", "executive"]
      action: ["read", "write", "deploy"]
```

---
[← Back to Deep Dives](./README.md)
