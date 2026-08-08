---
auto_generated: true
generated_at: "2026-08-08T06:48:04Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/from-weeks-to-minutes-how-formula-1-uses-agentic-ai-on-aws-to-accelerate-data-operations/"
signal_type: "significant_update"
---
# F1 用 Agentic AI 在 AWS Bedrock 上将数据接入从 8 周缩短至 40 分钟 (F1 Data Accelerator: Agentic AI on AWS Bedrock)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-08
>
> **项目/工具**: AWS Bedrock AgentCore — F1 Data Accelerator
> **链接**: https://aws.amazon.com/blogs/machine-learning/from-weeks-to-minutes-how-formula-1-uses-agentic-ai-on-aws-to-accelerate-data-operations/
> **核心定位**: 一个基于 Amazon Bedrock AgentCore 的生产级 Agentic AI 数据平台，将 F1 全球 8 亿粉丝 MarTech 平台的数据源接入从人工 6-8 周缩短至 AI 自动生成 40 分钟

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：F1 与 AWS 联合构建的 Data Accelerator，用 Agentic AI 自动化 MarTech 平台的数据源接入、Schema 演进监控和根因分析，是 2026 年最具代表性的生产级 Agentic AI 落地案例之一
- **現在值得用嗎**：是 — 如果你的组织面临大量数据源接入、合规治理和跨团队协作的痛点，这套架构模式可直接复用
- **適合場景**：企业级数据平台自动化接入、多源数据治理与合规（GDPR）、Schema 变更自动修复、数据平台可观测性
- **不適合場景**：小型团队（数据源 < 5 个）、非 AWS 环境、需要实时流处理（这是批量接入场景）
- **與傳統 ETL/代碼生成差異**：不是简单的代码生成器——它整合了 GDPR 合规分类、跨仓库 PR 联动、RCA 根因分析，形成闭环自治的数据运维体系

## 是什么 / 解决什么问题

Formula 1（F1）的 Customer 360 MarTech 平台需要接入来自票务伙伴、流媒体、赞助商激活、社交媒体和商品系统的多源数据。在 Data Accelerator 之前，每个新数据源需要工程师手动编写 schema 映射、构建接入管道、配置数据质量检查、定义 GDPR 分类和治理策略——耗时 **6 到 8 周**。F1 IT 总监 Chris Roberts 的描述很形象："我们有 18 个月的积压，只为了接入 12 个新数据源。"

第二个痛点是上游数据源的 Schema 变更。数据提供商频繁修改列名、新增字段或调整 payload 结构，且通常不提前通知。F1 团队往往在管道失败时才发现——经常是在比赛周末或关键营销活动进行中。

第三个痛点是碎片化的可观测性。日志分散在 Amazon S3 路径、Amazon Redshift 控制表、Airflow 日志和 DBT 输出中，当利益相关者质疑某个指标时，工程师需要数小时手动追踪问题。

2026 年初，F1 与 AWS 合作构建了 **Data Accelerator**，基于 Amazon Bedrock AgentCore，将数据源接入时间从 6-8 周缩短至约 **40 分钟代码生成 + 数小时部署审核**，AI Agent 自主完成 **95%** 的工作量。

## 技术架构拆解

### 核心设计决策

1. **AgentCore Runtime 容器托管 Agent**：选择 Bedrock AgentCore 而非自建 Agent 框架，利用其内置的可观测性（CloudWatch 追踪所有 Agent 对话和操作）和运行时管理能力
2. **模块化技能架构（Modular Skill Architecture）**：不是紧密耦合的 Agent 图，而是单一 Agent + 模块化技能定义。每个技能封装独立能力（schema 映射、数据质量验证、治理执行、敏感数据分类），运行时动态激活和组合
3. **多轮推理（Multi-pass Reasoning）**：Pass-0 处理 token 管理（scrubbing），Pass-1 总结工具输出，Pass-2 汇总总体评估——渐进式提升准确性和完整性，而非依赖单次响应
4. **人在回路（Human-in-the-loop）**：Agent 生成 PR 后由工程师审核批准，不直接写入生产环境。这是生产级 Agentic AI 的关键设计——自动化但不失控
5. **声明式治理（Declarative Governance）**：通过 SageMaker Unified Studio 将治理编码为声明式配置，而非手动控制台操作。单一数据源定义同时发布到目录并配置访问控制

### 与前版/竞品的关键差异

| 维度 | 传统方式（F1 旧版） | Data Accelerator |
|------|-------------------|------------------|
| 新数据源接入时间 | 6-8 周/源 | ~40 分钟代码生成 + 数小时部署 |
| 自动化比例 | 0%（全手动） | 95%（Agent 自主完成） |
| Schema 变更发现 | 管道失败后被动发现 | 事件驱动主动检测 + 自动生成修复 PR |
| GDPR 合规 | 手动分类审核 | Agent 自动分析每列并标记 GDPR 类别 |
| 可观测性 | 分散在 4+ 个工具中 | 单一交互式血缘图 + RCA 根因分析 |
| 跨团队协作 | 3 个独立环境（工程师/科学家/分析师） | SageMaker Unified Studio 统一入口 |
| 积压 backlog | 18 个月 12 个数据源 | 大幅减少（具体数字未披露） |

### 架构/信息流图

```
                    ┌─────────────────────────────────────────────┐
                    │           F1 Customer 360 Platform          │
                    └─────────────────────────────────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
   ┌──────▼──────┐          ┌────────▼────────┐         ┌────────▼────────┐
   │  Data Source │          │  Schema Evolution│         │  Observability  │
   │  Onboarding  │          │  Monitor & Fix   │         │  & RCA Agent    │
   └──────┬──────┘          └────────┬────────┘         └────────┬────────┘
          │                          │                           │
          ▼                          ▼                           ▼
   ┌──────────────────────────────────────────────────────────────────┐
   │              Amazon Bedrock AgentCore Runtime                    │
   │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────────┐  │
   │  │Schema  │ │Quality │ │Govern- │ │GDPR    │ │Multi-pass    │  │
   │  │Mapping │ │Valid.  │ │ance    │ │Classif.│ │Reasoning     │  │
   │  └────────┘ └────────┘ └────────┘ └────────┘ └──────────────┘  │
   └──────────────────────────────────────────────────────────────────┘
          │                          │                           │
          ▼                          ▼                           ▼
   ┌──────────────┐         ┌──────────────┐         ┌──────────────────┐
   │ GitHub PRs   │         │ EventBridge  │         │ Interactive      │
   │ (3 repos)    │         │ + Lambda     │         │ Lineage Graph    │
   │ + Jira Ticket│         │ Triggers     │         │ + Root Cause     │
   └──────────────┘         └──────────────┘         └──────────────────┘
          │
          ▼
   ┌──────────────────────────────────────────────────────────────────┐
   │           SageMaker Unified Studio (Data Mesh)                   │
   │  [Catalog] ─── [Access Control] ─── [Governed Self-Service]      │
   └──────────────────────────────────────────────────────────────────┘
```

### 两阶段接入流程详解

**Phase 1: 配置生成**
1. 团队成员将业务需求文档（BRD）上传至 S3 bucket
2. S3 上传事件触发 AWS Lambda → 调用 Bedrock AgentCore Runtime
3. Agent 读取 BRD，生成配置文件集
4. Agent 通过 GitHub App 将文件推送为 PR 到标准化 Git 仓库
5. Agent 通过 Jira REST API 创建引用该 PR 的工单
6. 所有 Agent 对话和操作通过 CloudWatch 追踪
7. 工程师审核、调整（如需要）、批准

**Phase 2: 完整管道生成**
1. 人工触发下一阶段
2. Agent 基于已批准的配置生成三个独立 PR：
   - AWS Glue 应用和基础设施代码
   - DBT 转换框架
   - 治理策略（含 GDPR 标记）
3. 三个 PR 链接到同一个 Jira 工单，确保可追溯性
4. 工程师在 Infrastructure、DBT 和 Governance 三个仓库中分别审核批准

## 实用评估

### 什么场景值得用

- **企业级多数据源接入**：如果你的组织每月需要接入 2+ 个新数据源，且涉及多团队协调，这套架构可以大幅缩短周期
- **强合规要求**：GDPR/CCPA 等数据合规场景，Agent 自动分类敏感数据并标记，减少合规团队手动审核
- **上游数据源不稳定**：数据提供商频繁变更 Schema 的场景，事件驱动的自动检测和修复可以显著降低故障时间
- **数据平台可观测性缺失**：当团队无法快速回答"这个数据现在对吗"时，交互式血缘图 + RCA 是刚需

### 什么场景不值得用

- **小型团队/少量数据源**：数据源 < 5 个且变更不频繁的团队，这套架构的复杂度远超需求
- **非 AWS 环境**：深度依赖 Bedrock AgentCore、SageMaker Unified Studio、AWS Glue 等 AWS 原生服务，迁移到 GCP/Azure 需要大量重构
- **实时流处理需求**：这是批量数据接入场景，不是实时流处理方案
- **需要 Agent 完全自主决策**：此架构设计为 95% 自动化 + 5% 人工审核，如果你需要全自动无人值守或完全人工控制，都不匹配

### 迁移成本

从传统手动 ETL 迁移到 Data Accelerator 模式：

| 阶段 | 工作量 | 说明 |
|------|--------|------|
| Agent 技能开发 | 4-6 周 | 定义 schema mapping、quality validation、governance、GDPR 分类技能模块 |
| 基础设施搭建 | 2-3 周 | Bedrock AgentCore 环境、Lambda、EventBridge、S3 触发器 |
| 现有数据源迁移 | 1-2 周/源 | 将现有手工接入的数据源迁移到 Agent 驱动模式 |
| 团队培训 | 1-2 周 | 工程师学习审核 Agent 生成的 PR，分析师学习 Unified Studio |
| **总计** | **约 2-3 个月** | 取决于数据源数量和团队规模 |

## 对你的意义

这个案例对 AI 应用开发者的核心启示是：**生产级 Agentic AI 不是"让 LLM 写代码"，而是构建一个包含技能模块化、人在回路、声明式治理、端到端可观测性的系统工程。**

具体观察：

1. **模块化技能 > 多 Agent 图**：F1 选择单一 Agent + 模块化技能，而非多 Agent 协作图。这简化了调试和监控——所有 Agent 对话在 CloudWatch 中单一窗口可查。对于正在评估 Agent 架构的团队，这是一个值得参考的设计决策。

2. **人在回路不是妥协，是生产前提**：95% 自动化 + 5% 人工审核的比例表明，即使在高度自动化的场景中，人工审核仍然是不可或缺的。这挑战了"全自主 Agent"的叙事。

3. **声明式治理是 Agent 安全的关键**：SageMaker Unified Studio 的声明式配置确保 Agent 无法绕过安全约束。"平台从结构上保证正确性"——这是 Agent 安全治理的最佳实践。

4. **RCA + 上下文图 = 从"知道什么失败了"到"理解为什么失败"**：这是可观测性从监控到诊断的关键跃迁。对任何数据平台都有参考价值。

**建议**：如果你负责企业数据平台或 MarTech 系统，值得深入研究这个案例的架构细节。Bedrock AgentCore 的模块化技能架构和多轮推理模式可以直接应用到你的 Agent 设计中。

## 关键代码/配置片段

> TODO: 原文未提供具体代码片段。以下从架构描述中提炼关键流程。

**Phase 1 触发流程（概念性）：**

```
S3 Bucket (BRD Upload)
  → AWS Lambda (trigger)
    → Bedrock AgentCore Runtime (invoke)
      → Agent reads BRD
      → Agent generates config files
      → Agent → GitHub App (push PR)
      → Agent → Jira REST API (create ticket)
      → CloudWatch (trace all actions)
```

**多轮推理流程：**

```
Pass-0: Token Management (scrubbing)
  ↓
Pass-1: Summarize tool outputs
  ↓
Pass-2: Roll up overall assessment
  ↓
Output: Refined accuracy & completeness
```

**模块化技能激活：**

```
Agent Runtime
  ├─ Skill: Schema Mapping & Data Type Inference
  ├─ Skill: Data Quality Validation
  ├─ Skill: Governance Enforcement
  └─ Skill: Sensitive Data Classification (GDPR)

Runtime: evaluate requirements → activate relevant skills → compose via multi-pass
```

---
[← Back to Deep Dives](./README.md)
