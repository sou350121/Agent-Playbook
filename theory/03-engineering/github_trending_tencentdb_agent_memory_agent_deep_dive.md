---
auto_generated: true
generated_at: "2026-08-10T03:32:26Z"
source_url: "https://github.com/TencentCloud/TencentDB-Agent-Memory/releases/tag/v2.0.0"
signal_type: "blog_post"
---
# 腾讯开源 Agent 记忆层：TencentDB Agent Memory v2.0.0 (TencentDB Agent Memory v2.0.0 — Team-Level Memory for AI Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-10
>
> **项目/工具**: TencentDB Agent Memory
> **链接**: https://github.com/TencentCloud/TencentDB-Agent-Memory/releases/tag/v2.0.0
> **核心定位**: 让 Agent 团队的经验、文档、代码沉淀为可复用资产，新 Agent 加入时"直接读档"而非从零学习

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：腾讯开源的 Agent 团队级记忆系统，将对话/文档/代码自动转化为 Chat Memory、Skill、Wiki、CodeGraph 四类资产，通过 Memory Hub 统一管理和 Memory Proxy 注入 Agent 上下文
- **现在值得用吗**：是 — 如果你在用 Claude Code / CodeBuddy 等 coding agent 做团队开发，且遇到"每个 Agent 都要重新学项目"的问题
- **适合场景**：多 Agent 协作开发、团队知识沉淀、Agent 冷启动加速
- **不适合场景**：单用户个人 Agent（杀鸡用牛刀）、需要实时代码执行的环境（Wiki/CodeGraph 异步构建有延迟）
- **与普通 RAG 核心差异**：RAG 解决"能查到什么"，Agent Memory 解决"谁可以用、哪个版本有效、应该给哪个 Agent"

## 是什么 / 解决什么问题

AI Agent 开发中有一个反复出现的问题：**每次新 Agent 启动，都要重新学习项目上下文**。文档读一遍、代码读一遍、团队偏好再沟通一遍。即使同一个用户、同一个项目，不同 Agent 实例之间也无法共享经验。

TencentDB Agent Memory（以下简称 TAM）的定位不是"记住对话"，而是**让经验沉淀、流动，然后被下一位 Agent 直接继承**。v2.0.0 于 2026-08-03 正式发布 GA，相比 beta.1 新增了 Skill 强制归档、CodeGraph 定时同步、面板中英文切换、管理员资产管理等特性。

它解决三个核心问题：
1. **什么值得留下** — 不是所有对话都有价值，系统自动提炼四层记忆
2. **谁可以使用** — 通过 Owner / 版本 / 可见性 / ACL 精确控制
3. **下一次怎样少拿但拿对** — Agent Loadout 机制让每个 Agent 只携带完成工作所需的记忆

## 技术架构拆解

### 核心设计决策

TAM 的架构围绕"记忆资产"（Memory Asset）这一核心概念展开，将四种不同形态的知识统一为可管理的资产：

| 资产类型 | 来源 | 结构 | 典型用途 |
|----------|------|------|----------|
| **Chat Memory** | 对话记录 | L0→L1→L2→L3 四层递进 | 保留用户偏好、决策历史、交互模式 |
| **Skill** | 跑通的任务 | 版本 + 资源文件 + 触发边界 + 执行步骤 + 验证规则 | 排障 SOP、上线检查清单、代码 Review 流程 |
| **Wiki** | 文档/文件 | 结构化页面 + 链接图谱 | 产品文档、设计方案、运维手册 |
| **CodeGraph** | 代码仓库 | 符号/文件/调用关系/影响路径 | 改代码前做 impact analysis、查找 callers/callees |

### 分层记忆：从原始对话到长期认知

Chat Memory 采用四层递进结构，这是 TAM 最有特色的设计之一：

| 层级 | 内容 | 用途 | 召回方式 |
|------|------|------|----------|
| **L0 Conversation** | 原始对话与完整上下文 | 核对原话、时间、来源 | 精确检索 |
| **L1 Atom** | 提取的事实、偏好、约束、事件 | 精确召回可执行信息 | BM25 + 向量检索 |
| **L2 Scenario** | 围绕项目/场景组织的知识块 | 快速恢复一个工作场景 | 场景匹配 |
| **L3 Core/Persona** | 长期画像、稳定模式、高层认知 | 让 Agent 迅速进入用户和团队语境 | Fixed Binding |

召回时通过 RRF（Reciprocal Rank Fusion）融合多路结果，并受条数、字符预算和超时限制约束，避免记忆反过来占满上下文窗口。

### 与 RAG 的关键差异

| 维度 | 普通 RAG | TencentDB Agent Memory |
|------|----------|----------------------|
| 跨会话理解用户 | △ 部分支持 | ✅ Chat Memory L2/L3 |
| 沉淀可执行经验 | — | ✅ Skill（含版本/触发边界/验证规则） |
| 文档结构与关系 | △ 切片检索 | ✅ Wiki + Link Graph |
| 代码调用与影响范围 | — | ✅ CodeGraph（符号级索引） |
| Owner / 版本 / 状态 | — | ✅ 全维度追踪 |
| 团队分享与 Agent 配装 | — | ✅ Agent Loadout |
| 私有 / 团队 / ACL | — | ✅ 四级可见性 |

### 架构信息流

```
┌─────────────────────────────────────────────────────────┐
│                    Agent Session                         │
│  (Claude Code / CodeBuddy / Hermes / OpenClaw)          │
└────────────────────┬────────────────────────────────────┘
                     │ /v1/messages 或 /v1/chat/completions
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  Memory Proxy                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │ sessionInit → 用户选择 Team/Agent/Task            │  │
│  │ 每轮注入 → L2/L3 记忆 + matched Skill             │  │
│  │         → Wiki/CodeGraph tool call                │  │
│  │ 鉴权 → x-tdai-user-key → /v3/meta/auth/verify     │  │
│  └───────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌──────────┐
   │  Core   │ │  Hub    │ │ Knowledge│
   │ (Memory │ │ (Panel  │ │ (Wiki +  │
   │  Asset) │ │  + ACL) │ │ CodeGraph│
   └─────────┘ └─────────┘ └──────────┘
         │                           │
         ▼                           ▼
   ┌─────────┐                ┌──────────────┐
   │  Vector │                │ Code Index   │
   │  Store  │                │ (Symbol/Call │
   │ + BM25  │                │  Graph)      │
   └─────────┘                └──────────────┘
```

### 三层可见性与 Agent Loadout

记忆资产默认私有（private），分享是明确动作而非默认泄漏：

| 可见性 | 语义 |
|--------|------|
| **private** | 只有 Owner 可读，团队管理员也不例外 |
| **team** | 团队成员可读，Owner/Admin 负责管理 |
| **restricted** | 通过 User/Role/Agent ACL 精确授权 |
| **agent** | 用于同团队 Agent 的定向装配 |

Agent Loadout 机制让不同 Agent 携带不同"装备包"：

```
Tiny but Serious Inc.          ← 一个 Team
├── Scout   → 用户访谈 Memory + 市场研究 Wiki + 竞品分析 Skill
├── Builder → 产品 Wiki + 项目 CodeGraph + Feature Delivery Skill
├── Reviewer→ 历史事故 Memory + 项目 CodeGraph + Release Checklist Skill
└── Agent Memory → 全队经验沉淀层
```

## 实用评估

### 什么场景值得用

- **多 Agent 协作开发**：团队内有多个 coding agent（Claude Code、CodeBuddy 等），每个都需要了解项目上下文。TAM 让经验在 Agent 间流动而非重复学习。
- **Agent 冷启动加速**：导入已有文档、代码库和历史对话 Session，新 Agent 从现有经验开始工作。README 明确说"不再重新训练每一个 Agent，给它读档"。
- **团队知识管理**：Skill 库让跑通的做法（排障流程、上线检查、代码 Review）可复用，不依赖个人记忆。
- **代码影响分析**：CodeGraph 在改代码前提供符号级调用关系和影响路径，减少"改了这里却坏了那里"的问题。

### 什么场景不值得用

- **单用户个人 Agent**：如果你只有一个 Agent、一个项目，TAM 的部署复杂度（三件套 Docker）远超收益
- **需要实时代码变更感知**：Wiki 和 CodeGraph 是异步构建的，代码变更后需要等待处理时间才能 ready
- **私有仓库全量接入**：CodeGraph 当前首先支持公开 HTTPS 仓库，私有仓库和 SSH 凭证接入仍在完善中
- **全自动记忆路由**：当前 Hub 已支持人工绑定资产，但全自动记忆路由仍在迭代中

### 迁移成本

从旧版（v1.x / v0.x）迁移：项目提供了数据迁移工具（`MemoryCore/scripts/migrate-v2-to-v3/`），全新安装可跳过。

从零部署：Docker 三件套（memory-core / memory-hub / memory-proxy），`start-all.sh` 一键拉起，支持 linux/amd64 和 linux/arm64。首次启动自动 init-admin 并生成 `.admin-key`。

接入 Agent：支持 Anthropic Messages API 和 OpenAI Chat Completions 双协议。Claude Code 用户可直接复制启动命令（start-all.sh 结束后打印）。

SDK 支持 TypeScript（`@tencentdb-agent-memory/memory-sdk-ts-v2`）和 Python（`tencentdb-agent-memory-sdk-python`，同步+异步双客户端）。

## 对你的意义

TAM 直接对应 AI 应用开发中 Agent Memory 赛道的一个关键方向：**团队级记忆而非个人级记忆**。与 Karpathy 的 LLM Wiki 理念一脉相承，但走得更远——不只是文档知识库，而是把对话经验（Chat Memory）和可执行流程（Skill）也纳入统一管理。

**建议：值得试用。** 如果你在用 Claude Code 做团队开发，TAM 的 Agent Loadout 机制能显著减少每个 Agent 的冷启动成本。CodeGraph 的符号级索引也比传统 RAG 的代码检索更精准。

值得关注的后续：全自动记忆路由（当前为人工绑定）、私有仓库支持、更广泛的跨框架迁移能力。

## 关键代码/配置片段

### 一键部署

```bash
git clone https://github.com/Tencent/TencentDB-Agent-Memory.git
cd TencentDB-Agent-Memory/deploy/global-images
cp .env.example .env
$EDITOR .env  # 填入两组 LLM 参数（memory 组 + proxy 组）
./start-all.sh  # 一键起三件套
```

### Memory Proxy 双协议支持

```
# Anthropic Messages API
POST /claude-code/v1/messages

# OpenAI Chat Completions API
POST /v1/chat/completions
```

### 鉴权流程

```
x-tdai-user-key → 内核 /v3/meta/auth/verify → user_id → 按用户维度控制资产可见性
```

### Benchmark 数据

| Benchmark | 无 TAM | 启用后 | 相对提升 |
|-----------|--------|--------|----------|
| PersonaMem | 48% | 76% | +59% |

PersonaMem 检验 Agent 能否在长期交互后正确理解和运用用户信息（来源：项目 README）。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | TAM 提供 Team/Agent 管理、Agent Loadout、ACL 权限控制，直接解决多 Agent 协作中的记忆共享与隔离问题 |

---
[← Back to Deep Dives](./README.md)
