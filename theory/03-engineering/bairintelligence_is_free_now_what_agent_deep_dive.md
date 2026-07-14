---
auto_generated: true
generated_at: "2026-07-14T05:48:17Z"
source_url: "http://bair.berkeley.edu/blog/2026/07/07/intelligence-is-free-now-what/"
signal_type: "significant_update"
---
# 智能免费之后：为 Agent 设计数据系统 (Intelligence is Free, Now What? Data Systems for, of, and by Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-14
>
> **项目/工具**: BAIR Perspective — UC Berkeley EPIC Data Lab
> **链接**: https://bair.berkeley.edu/blog/2026/07/07/intelligence-is-free-now-what/
> **核心定位**: BAIR 12 位作者（含 Matei Zaharia、Ion Stoica 等系统领域泰斗）提出：当推理成本趋近于零，数据系统必须从 human-centric 全面转向 agent-centric，并给出 For / Of / By 三层框架。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：BAIR 提出 AI 推理成本从 $30/百万 token（2023）降至 <$1/百万 token（2026），"近乎免费的智能"将重塑数据系统的设计前提——数据系统的用户将从人变为 Agent 集群。
- **現在值得用嗎**：是——这是一篇 **研究路线图 / 框架性思考**，不是可直接使用的工具。但它定义了未来 2-3 年 Agent 基础设施的核心研究方向。
- **適合場景**：Agent 基础设施架构师、数据系统研究者、Agent 平台产品决策者
- **不適合場景**：寻找即插即用 Agent 工具的开发者（本文不推荐具体产品）
- **與傳統觀點核心差異**：传统数据系统假设用户是人（低并发、精确查询、被动执行）；本文假设用户是 Agent 集群（高并发、模糊探索、需要主动反馈），要求重新设计整个数据系统栈。

## 是什么 / 解决什么问题

2023 年初，GPT-4 级别的推理成本约为 $30/百万 token；到 2026 年中，同等能力已降至 <$1/百万 token，部分提供商甚至推向 <$0.10。基准测试显示推理价格年降幅在 9x 到 900x 之间，中位数约 50x。

BAIR 的核心论点是：**当推理成本趋近于零，瓶颈将从"智能"转移到"数据系统"**。Agent 将大规模替代人类成为数据系统的主要负载，而现有数据系统（为人类设计）无法高效支撑 Agent 的行为模式。

文章提出三个新挑战/机遇，构成其核心框架：

| 维度 | 核心问题 | 一句话概括 |
|------|----------|------------|
| **For Agents** | 如何为 Agent 用户重新设计数据系统？ | Agent 不是人——它们的行为模式完全不同 |
| **Of Agents** | 如何构建支撑 Agent 集群运行的基础设施？ | Agent 需要内存、协调、容错的底层基座 |
| **By Agents** | 如何让 Agent 自主合成可信赖的数据系统？ | 免费智能可用于从头生成定制化系统 |

## 技术架构拆解

### 核心设计决策

**决策 1: 将 "Agentic Speculation" 作为一等公民**

BAIR 定义了 Agentic Speculation（代理推测）概念——Agent 查询数据库时执行的是高容量、异构的工作流：schema  introspection → 列探索 → 部分查询 → 完整查询。每个用户请求可能产生数千条 SQL 查询。

关键发现：在 text-to-SQL 基准测试中，**仅 10-20% 的子计划是独特的**，80-90% 的子查询执行重复工作。但冗余对任务成功率有正面影响——更多尝试 = 更高成功率。

**决策 2: 从被动执行到主动引导**

传统数据系统是被动查询执行器。BAIR 提出数据系统应该主动：
- 引导 Agent 走向不同方向
- 为相关查询预提供结果
- 提供性能级反馈（如先给延迟估计而非直接执行昂贵查询）
- 预先准备物化视图和虚拟视图作为 Agent 上下文

可行性基础：Agent 可以接受任何文本反馈，不像传统 BI 工具期望严格的 SQL 结果格式。

**决策 3: 结构化内存替代 MD 文件**

当前主流观点是 "files are all you need"——Agent 写入非结构化 Markdown 文件，通过 grep 或 embedding 检索。BAIR 认为在 Agent 规模下这行不通：
- 有限上下文窗口下，检索所有相关 MD 片段塞入上下文会崩溃
- 即使上下文窗口继续增长，将所有信息序列化进上下文在延迟上也不可行
- Knowledge Graph 同样缺乏结构化搜索能力

替代方案：**Structured Memory**（结构化内存）——按多维度组织内存，每个维度可设为 `*`（通用）或值列表（精确匹配）。例如调试不稳定测试的 Agent 应能按模块、语言、框架、失败模式精确拉取记忆，而非基于关键词或 embedding 相似度模糊匹配。

**决策 4: Agent 合成定制化数据系统**

如果智能免费，可以用它从头合成数据系统。Bespoke OLAP 和 GenDB 已证明：用 Agent 管线可在数分钟到数小时内、花费几美元合成完整的工作负载专属分析引擎。这些引擎是**一次性的**——工作负载变化时直接重新生成。

### 与前版/竞品的关键差异

| 维度 | 传统数据系统 | BAIR 提出的 Agent 原生数据系统 |
|------|------------|-------------------------------|
| **主要用户** | 人类 / BI 工具 | Agent 集群（swarms） |
| **查询模式** | 低并发、精确查询 | 高并发、Agentic Speculation（1000s queries/request） |
| **结果精确度** | 精确结果 | 近似结果可接受（satisficing） |
| **系统角色** | 被动执行器 | 主动引导者（proactive） |
| **内存存储** | MD 文件 + embedding | 结构化内存（多维度 facet 检索） |
| **并发模型** | 少量用户并发 | 数千 Agent 同时编辑共享状态 |
| **系统设计** | 通用系统（Postgres 等） | Agent 合成的定制化系统（一次性） |
| **接口抽象** | SQL 单条查询 | 批量查询 + 高级原语（如 DBT-style Jinja macros） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    User Request                              │
│              "Why did coffee sales drop?"                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Agent Swarm (For Agents)                        │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                     │
│  │ Agent 1 │  │ Agent 2 │  │ Agent N │  ... 1000s queries  │
│  └────┬────┘  └────┬────┘  └────┬────┘                     │
│       │            │            │                           │
│       └─────┬──────┴──────┬─────┘                           │
│             ▼             ▼                                  │
│     ┌───────────────┐  ┌───────────────┐                   │
│     │ Multi-query   │  │ Approximate   │                   │
│     │ optimization  │  │ answers (AQP) │                   │
│     │ (80-90% dedup)│  │ + streaming   │                   │
│     └───────┬───────┘  └───────┬───────┘                   │
└─────────────┼──────────────────┼───────────────────────────┘
              │                  │
              ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│           Data System (Of Agents Substrate)                  │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Structured      │  │ Concurrent Edit │                   │
│  │ Memory          │  │ (MVCC / COW /   │                   │
│  │ (facet-based)   │  │  CRDT / OT)     │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Agent Comm /    │  │ Failure         │                   │
│  │ Negotiation     │  │ Handling        │                   │
│  │ Protocol        │  │ (stragglers)    │                   │
│  └─────────────────┘  └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│           Custom Engine (By Agents)                          │
│                                                              │
│  Workload Spec → Agent Synthesis Pipeline → Custom OLAP/KV   │
│                    │                                         │
│                    ▼                                         │
│           Verification Agent (adversarial)                   │
│                    │                                         │
│                    ▼                                         │
│           Formal Proof + Correctness Check                   │
│                                                              │
│  Cost: few dollars | Time: minutes to hours                  │
│  Disposable: regenerate when workload shifts                 │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **Agent 平台架构设计**：如果你在构建面向 Agent 的数据平台（而非面向人的 BI 工具），这篇文章的三层框架提供了完整的设计 checklist。特别是 For Agents 层的 multi-query optimization 和 AQP（近似查询处理）思路，可以直接转化为工程优化点。
- **多 Agent 协作系统设计**：Of Agents 层对结构化内存、并发编辑、Agent 间协商的讨论，是当前多 Agent 框架（LangGraph、CrewAI 等）普遍缺乏的底层思考。如果你的系统涉及 2+ Agent 共享状态，值得参考。
- **研究型项目**：Bespoke OLAP / GenDB / 定制化 KV Store 的合成管线代表了 "AI for Systems" 的前沿方向。如果你的团队有系统研究能力，这些论文（均引用了 arXiv 链接）提供了可直接跟进的研究路线。

### 什么场景不值得用

- **传统 BI / 数据分析**：如果你的用户是人（分析师、产品经理），传统数据系统（ClickHouse、BigQuery、Snowflake）完全够用。本文的前提是 Agent 成为主要负载——这个前提在大多数企业尚未成立。
- **短期工程决策**：这是一篇 2026 年 7 月的 perspective 文章，大量方向（结构化内存 schema、Agent 协商协议、合成系统验证）仍处于研究阶段，没有成熟产品。不适合直接指导当下的技术选型。
- **小团队快速原型**：Agent 合成定制化数据系统需要验证 Agent + 形式化证明，门槛极高。小团队应继续使用成熟通用系统。

### 迁移成本

从当前架构迁移到本文描述的方向，成本分层评估：

| 迁移层级 | 工作量 | 说明 |
|----------|--------|------|
| **For Agents: 查询缓存/去重** | 低（1-2 周） | 利用现有 multi-query optimization 和 shared scan 技术，对 Agent 子查询做去重 |
| **For Agents: 近似查询** | 中（1-2 月） | 集成 AQP 引擎（如 BlinkDB、Presto 的近似聚合），需要评估精度-延迟 tradeoff |
| **Of Agents: 结构化内存** | 高（3-6 月） | 从 MD 文件 + embedding 迁移到多维度结构化存储，需要定义 schema 和检索 API |
| **Of Agents: 并发协调** | 极高（6-12 月） | 数千 Agent 并发编辑共享状态，涉及 MVCC/CRDT/OT 等底层技术，目前无成熟方案 |
| **By Agents: 系统合成** | 研究级（12+ 月） | 需要验证 Agent + 形式化证明，属于前沿研究，非工程交付 |

## 对你的意义

这篇文章与 Ken 的两条追踪线都有直接关联：

**AI 应用线（Agent + UI）**：
- Of Agents 层的结构化内存方案直接关联 Agent 记忆/状态管理——这是当前 Agent 框架（LangChain/LlamaIndex/CrewAI）的核心痛点
- 如果 Ken 在评估 Agent 平台，可以关注哪些平台开始支持结构化内存而非简单的 MD 文件存储
- Agent 协商/共识机制是多 Agent 协作框架（A-003 假设方向）的基础设施前提

**VLA 研究线（具身智能）**：
- 虽然本文聚焦软件 Agent，但 "Data Systems Of Agents" 的并发编辑、容错、协调框架对多机器人协作系统有直接借鉴意义
- 具身智能中的 "world model" 概念在本文中被引用为 "world models for memory"——两个领域的术语正在融合

**建议**：这是一篇值得收藏的框架性文章。短期内不需要基于它做任何工程决策，但应该用它来审视正在评估的 Agent 平台——它们是否考虑了 Agent 作为数据系统一等公民的设计？如果没有，可能在 1-2 年后面临架构瓶颈。

## 关键代码/配置片段

本文是 perspective 文章，不提供代码。但引用了若干关键研究论文，以下是最值得深入阅读的：

**Agentic Speculation 实证**：
- 论文: [Agentic Speculation](https://arxiv.org/abs/2509.00997)
- 核心发现: text-to-SQL 基准中仅 10-20% 子计划独特，80-90% 重复

**结构化内存**：
- 论文: [Structured Memory](https://arxiv.org/abs/2602.13521)
- 核心设计: 多维度 facet 检索，维度可设为 `*`（通用）或值列表（精确匹配）

**定制化 OLAP 引擎合成**：
- 论文: [Bespoke OLAP](https://arxiv.org/abs/2603.02001) / [GenDB](https://arxiv.org/abs/2603.02081)
- 核心数据: 数分钟到数小时，花费几美元，合成完整分析引擎

**定制化 KV Store 合成 + 验证**：
- 论文: [Custom KV Stores](https://arxiv.org/abs/2605.24096)
- 验证方法: 辅助验证 Agent 生成对抗测试用例，扩展不完备的规格说明

**形式化证明**：
- 论文: [System + Proof Generation](https://arxiv.org/abs/2605.23109)
- 状态: 早期成功，需进一步巩固

---
[← Back to Deep Dives](./README.md)
