---
auto_generated: true
generated_at: "2026-04-16T03:32:09Z"
source_url: "https://blog.langchain.com/your-harness-your-memory/"
signal_type: "significant_update"
---
# 你的 Harness，你的记忆 (Your Harness, Your Memory)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-16
>
> **项目/工具**: LangChain Deep Agents / Agent Harnesses
> **链接**: https://blog.langchain.com/your-harness-your-memory/
> **核心定位**: LangChain 创始人 Harrison Chase 详解 Agent Harness 与记忆系统的耦合关系，警告闭源 API 依赖风险，倡导开放 Harness 架构

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Harrison Chase 论证 Agent Harness 与记忆系统不可分割，使用闭源 Harness 等于将记忆控制权交给第三方平台
- **現在值得用嗎**：是 — 如果你正在构建需要长期记忆的 Agent 系统，必须认真考虑 Harness 的开放性
- **適合場景**：企业级 Agent 开发、需要跨会话记忆的个性化 Agent、希望避免供应商锁定的团队
- **不適合場景**：一次性/无状态 Agent 任务、对记忆无需求的简单工具调用
- **與 [競品/前版] 核心差異**：Deep Agents 开源且模型无关 vs Claude Managed Agents 全托管锁定

## 是什么 / 解决什么问题

2026 年 4 月 11 日，LangChain 创始人 Harrison Chase 发表了一篇关于 Agent Harness 与记忆系统关系的重要文章。这篇文章的核心论点是：**Agent Harness 不是临时脚手架，而是 Agent 系统的核心架构，它与记忆系统深度耦合，选择闭源 Harness 意味着放弃对记忆的控制权。**

文章背景是 AI Agent 开发范式的演进：2023 年 ChatGPT 刚推出时，简单的 RAG 链就够用；模型能力提升后，出现了 LangGraph 这样的复杂流程编排；而现在模型能力更强，催生了 Agent Harness 这一新型架构。Harrison 列举了当前主流的 Harness 实现：Claude Code、Deep Agents、Pi (OpenClaw)、OpenCode、Codex、Letta Code 等。

一个关键洞察是：**即使模型能力再强，Harness 也不会消失**。证据是 Claude Code 的源码泄露显示它有 512k 行代码 — 这些代码就是 Harness。即使是最强模型的制造商也在大量投资 Harness 开发。

## 技术架构拆解

### 核心设计决策

Harrison 在文章中阐述了几个关键设计决策：

1. **Harness 管理上下文，记忆是上下文的一种形式**
   - 短期记忆（对话消息、工具调用结果）由 Harness 处理
   - 长期记忆（跨会话记忆）需要由 Harness 读取和更新
   - 记忆不是独立服务，而是 Harness 的核心能力

2. **记忆管理的核心问题**（引用 Sarah Wooders 的观点）：
   - AGENTS.md 或 CLAUDE.md 文件如何加载到上下文？
   - Skill 元数据如何展示给 Agent（系统 prompt 还是系统消息）？
   - Agent 能否修改自己的系统指令？
   - 压缩（compaction）时什么保留、什么丢失？
   - 交互是否存储并可查询？
   - 记忆元数据如何呈现给 Agent？
   - 当前工作目录如何表示？暴露多少文件系统信息？

3. **开放 vs 闭源的记忆控制**：
   - 状态化 API（如 OpenAI Responses API、Anthropic 服务端压缩）将状态存储在供应商服务器
   - 闭源 Harness（如 Claude Agent SDK）的记忆交互方式不透明
   - 全托管 Harness（如 Claude Managed Agents）将一切放在 API 后面，用户零控制权

### 与前版/竞品的关键差异

| 维度 | 闭源 Harness / 托管 API | 开放 Harness (Deep Agents) |
|------|----------------------|--------------------------|
| 记忆所有权 | 供应商控制 | 用户控制 |
| 模型切换 | 困难（丢失记忆） | 容易（记忆可迁移） |
| 记忆存储 | 供应商指定 | 可选 Mongo/Postgres/Redis 等 |
| 源码可见性 | 不可见 | 开源 |
| 部署方式 | 云端托管 | 自托管/任意云部署 |
| 长期锁定风险 | 高 | 低 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    开放 Harness 架构                      │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   Agent      │◄──►│   Harness    │◄──►│  记忆存储  │ │
│  │   (LLM)      │    │  (上下文管理) │    │ (用户控制)│ │
│  └──────────────┘    └──────────────┘    └───────────┘ │
│         │                   │                   │       │
│         ▼                   ▼                   ▼       │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   工具调用    │    │ AGENTS.md    │    │ Mongo/    │ │
│  │              │    │ Skills       │    │ Postgres  │ │
│  └──────────────┘    └──────────────┘    └───────────┘ │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    闭源托管架构                          │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐   │
│  │              供应商 API 边界                       │   │
│  │  ┌────────────┐    ┌────────────┐                │   │
│  │  │   LLM      │◄──►│  Harness   │                │   │
│  │  │            │    │  (黑盒)    │                │   │
│  │  └────────────┘    └────────────┘                │   │
│  │                          │                        │   │
│  │                          ▼                        │   │
│  │                   ┌─────────────┐                 │   │
│  │                   │ 记忆存储     │                 │   │
│  │                   │ (供应商控制) │                 │   │
│  │                   └─────────────┘                 │   │
│  └──────────────────────────────────────────────────┘   │
│                        ▲                                 │
│                        │ API 调用                         │
│                        │                                 │
│  ┌─────────────────────┴─────────────────┐              │
│  │            用户应用                     │              │
│  └─────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **企业级 Agent 部署**：需要长期记忆积累用户偏好、业务规则、历史交互数据
2. **个性化 Agent 产品**：记忆是差异化竞争的核心（Harrison 的邮件助手案例）
3. **多模型策略团队**：希望保留切换模型供应商的灵活性
4. **数据合规要求严格**：需要将记忆数据存储在可控的基础设施中
5. **长期产品路线图**：计划构建基于记忆的数据飞轮效应

### 什么场景不值得用

1. **一次性/无状态任务**：简单的工具调用、单次查询不需要记忆
2. **快速原型验证**：早期 MVP 阶段可以暂时用托管服务加速开发
3. **对供应商锁定不敏感**：小团队/个人项目，切换成本可接受
4. **预算有限且无运维能力**：自托管 Harness 需要额外的运维投入

### 迁移成本

从闭源 Harness 迁移到开放 Harness 的成本取决于：

- **记忆数据可导出性**：如果供应商提供记忆数据导出 API，迁移成本较低；否则需要重新积累
- **Harness 逻辑复杂度**：如果业务逻辑深度耦合到闭源 Harness 的特定行为，重构成本高
- **记忆格式标准化程度**：使用 AGENTS.md、Skills 等开放标准的系统迁移成本更低

Harrison 分享了一个真实案例：他的内部邮件助手基于 Fleet 模板构建，使用平台内置记忆。几个月后 Agent 被误删，重新创建时发现体验大幅下降 — 需要重新教授所有偏好、语气等。这说明了记忆的价值和迁移的痛苦。

## 对你的意义

如果你正在追踪 Agent 框架和 UI 工具链（如 Ken 的 AI 应用开发方向），这篇文章有几个关键启示：

1. **架构决策要趁早**：在 Agent 项目早期就应考虑 Harness 的开放性问题，后期迁移成本极高
2. **记忆是护城河**：有记忆的 Agent 比无记忆的 Agent 更难被复制 — 这是产品差异化的关键
3. **Deep Agents 值得关注**：LangChain 的开源方案提供模型无关、可自托管、支持多种记忆存储的选项
4. **警惕"模型吸收 Harness"叙事**：模型供应商有动机将更多功能放到 API 后面制造锁定

具体建议：
- **立即行动**：如果正在用闭源 Harness 构建生产系统，评估记忆数据导出方案
- **新项目**：优先考虑 Deep Agents 等开源 Harness，保留架构灵活性
- **技术雷达**：将"记忆所有权"纳入 Agent 框架评估维度

## 关键代码/配置片段

Harrison 在文章中提到 Deep Agents 的关键特性：

```yaml
# Deep Agents 配置示例（概念性）
deep_agents:
  open_source: true
  model_agnostic: true
  standards:
    - agents.md
    - skills
  memory_plugins:
    - mongodb
    - postgres
    - redis
  deployment:
    - langsmith_deployment
    - self_hosted
    - any_cloud
  web_framework:
    - "任意标准 Web 托管框架"
```

记忆存储的灵活性是关键优势：

```python
# 概念性示例：使用不同记忆存储
from deep_agents import Agent, MemoryStore

# MongoDB 记忆存储
mongo_store = MemoryStore("mongodb://localhost:27017/agent-memory")

# PostgreSQL 记忆存储  
postgres_store = MemoryStore("postgresql://user:pass@localhost/agent-memory")

# Redis 记忆存储
redis_store = MemoryStore("redis://localhost:6379")

# Agent 可以切换存储而不丢失架构
agent = Agent(memory_store=mongo_store)  # 或 postgres_store, redis_store
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | 开放 Harness 架构与 MCP 理念一致，都强调开放标准和互操作性 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Harness 作为 Agent 核心架构，其开放性是协作框架工程化的前提 |

---

[← Back to Deep Dives](./README.md)
