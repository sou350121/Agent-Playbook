---
auto_generated: true
generated_at: "2026-07-22T06:47:59Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/how-smartsheet-built-a-remote-mcp-server-on-aws/"
signal_type: "significant_update"
---
# Smartsheet 在 AWS 上构建远程 MCP 服务器（Enterprise MCP Server on AWS）

> 🔍 本文由 Moltbot 自动生成 | 2026-07-22
>
> **项目/工具**: Smartsheet MCP Server
> **链接**: https://aws.amazon.com/blogs/machine-learning/how-smartsheet-built-a-remote-mcp-server-on-aws/
> **核心定位**: 企业级 MCP 服务器实战案例——统一内部/外部 Agent 接入，通过 Progressive Disclosure + 自定义序列化节省 30 亿 Token，具高架构参考价值

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：Smartsheet 在 AWS 上构建的远程 MCP Server，让 AI Agent（Amazon Quick、Claude Desktop、内部 Smart Assist）通过统一工具层直接操作企业工作管理数据
- **现在值得用吗**：是——如果你在企业场景部署 Agent 并需要访问 Smartsheet 数据；否则作为 MCP 架构参考案例极具价值
- **适合场景**：企业级 Agent 接入现有 SaaS 数据、统一内部/外部 Agent 工具层、高并发 Agent 流量治理
- **不适合场景**：个人开发者小项目（架构过重）、非 Smartsheet 生态（工具绑定特定 API）
- **与前版/竞品核心差异**：单一 MCP 层同时服务内部 Smart Assist 和外部 AI 客户端，配合 Progressive Disclosure + 自定义序列化将 Token 消耗降低 35-47%

## 是什么 / 解决什么问题

企业正在大规模部署 AI Agent，但 Agent 需要结构化访问内部系统数据——而大多数企业系统（如 Smartsheet）并非为 Agent 交互设计。传统 API 是面向人类 UI 的，参数复杂、响应冗余，直接暴露给 LLM 会导致：Token 消耗爆炸、幻觉参数、权限混乱。

Smartsheet 的解决方案是构建一个**远程 MCP（Model Context Protocol）服务器**，在现有 API 之上增加一层 AI 优化的接口。这层接口做了三件事：

1. **统一接入**：内部 Smart Assist 和外部 AI 客户端（Amazon Quick、Claude Desktop）共用同一套工具定义和基础设施
2. **Token 优化**：通过 Progressive Disclosure（渐进式披露）和自定义序列化格式，将每次工具调用的 Token 消耗降低 35-47%
3. **安全治理**：OAuth2 认证 + 分层限流 + MCP 协议注解（readOnlyHint / destructiveHint），确保 Agent 不会越权操作

上线后，Smartsheet 通过内部遥测数据确认**节省了超过 30 亿 Token**，且在 GA 首四周实现了 **87% 的周用户增长**。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 取舍 |
|------|------|------|
| 单一 MCP 层服务内外 | "Build once, benefit everywhere"——内部 Smart Assist 和外部 Agent 共享同一工具集 | 外部暴露面更大，需额外安全层 |
| AWS Fargate (ECS) 部署 | Agent 流量 bursty（秒级密集调用 → 长时间静默），Fargate 支持计算感知弹性伸缩 | 不如裸 EC2 灵活，但运维成本低 |
| Progressive Disclosure | 每张表响应有 Token 预算，动态计算返回行数，避免大表拖垮上下文窗口 | Agent 需多次往返获取完整数据 |
| 自定义序列化替代 JSON | JSON 的键名重复和结构符号占 Token 的 15-25%，自定义格式在 33 行数据上节省 35% Token | 牺牲了标准兼容性，需客户端适配 |
| Pydantic 强类型 Schema | 防止 LLM 幻觉参数名、虚构操作符 | 维护成本略高 |

### 与前版/竞品的关键差异

| 维度 | 传统 API 直连 | Smartsheet MCP Server | 典型 MCP Wrapper |
|------|-------------|----------------------|-----------------|
| 接入方式 | 每个 Agent 自建适配器 | 统一 MCP 层，一次建设所有 Agent 受益 | 每个工具单独封装 |
| Token 效率 | 原始 JSON 响应，无优化 | Progressive Disclosure + 自定义序列化，节省 35-47% | 通常直接透传 API 响应 |
| 安全治理 | 应用层自行实现 | OAuth2 + 分层 WAF 限流 + MCP 注解（readOnlyHint/destructiveHint） | 通常只有基础认证 |
| 弹性伸缩 | 按请求量 | 计算感知弹性（考虑 LLM 序列化开销） | 通常按 QPS |
| 可观测性 | 标准 API 日志 | Agent-first 追踪（关联工具链上下文） | 通常无 Agent 链追踪 |
| 测试策略 | 确定性 API 测试 | 包含 LLM 的端到端工作流测试 | 通常只有单元/集成测试 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Clients                               │
│  Amazon Quick │ Claude Desktop │ Smart Assist (Internal)    │
└─────────────────────────┬───────────────────────────────────┘
                          │ OAuth2 Auth
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  API Gateway Layer                          │
│  AWS WAF → AWS Shield → ALB → OAuth2 Proxy                │
│  Layered Rate Limiting: Edge / Per-User / Path-Specific   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              MCP Server (AWS Fargate / ECS)                 │
│  ┌──────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ Tool Catalog │  │ Progressive      │  │ Custom        │ │
│  │ (Pydantic    │  │ Disclosure       │  │ Serialization │ │
│  │  Schema)     │  │ (Token Budget)   │  │ (35-47% less) │ │
│  └──────────────┘  └──────────────────┘  └───────────────┘ │
└───────┬─────────────────────────────┬───────────────────────┘
        │                             │
        ▼                             ▼
┌───────────────────┐    ┌───────────────────────────────┐
│  Domain Services  │    │    Intelligence Layer         │
│  (Smartsheet APIs)│    │    Neptune (Knowledge Graph)  │
│  ─ Fine-grained   │    │    Databricks + S3            │
│    permissions    │    │    (Medallion Arch)           │
└───────────────────┘    │    Kinesis + Flink → S3       │
                         └───────────────────────────────┘
                              │
                              ▼
                     ┌────────────────┐
                     │  OpenTelemetry │
                     │  Kinesis →     │
                     │  OpenSearch    │
                     │  Datadog APM   │
                     │  PagerDuty     │
                     └────────────────┘
```

**数据流说明**：
1. AI Client 发送 MCP 工具调用 → API Gateway 验证 OAuth2 + 分层限流
2. MCP Server 解析工具调用，通过 Pydantic Schema 验证参数
3. 调用 Domain Services API 获取数据 → 应用 Progressive Disclosure 裁剪响应
4. 使用自定义序列化格式压缩 → 返回给 AI Client
5. 变更事件通过 Kinesis + Flink 流入 Intelligence Layer（S3 上的 Medallion 架构）
6. 所有调用通过 OpenTelemetry 发射可观测信号

## 实用评估

### 什么场景值得用

- **企业 Agent 接入 SaaS 数据**：如果你的组织正在部署 AI Agent 并需要访问 Smartsheet 的工作管理数据，这个 MCP Server 是官方方案，开箱即用
- **统一内部/外部 Agent 工具层**：当内部团队和外部客户都需要通过 Agent 访问同一数据源时，"Build Once" 架构避免重复开发
- **高 Token 成本场景**：如果你的 Agent 工作流 Token 消耗是主要成本驱动因素，Progressive Disclosure + 自定义序列化的优化思路可直接借鉴
- **企业级 MCP 部署参考**：即使不用 Smartsheet，这个架构的 WAF 分层限流、计算感知弹性、Agent-first 可观测性、LLM-in-the-loop 测试等实践都是行业标杆

### 什么场景不值得用

- **个人开发者小项目**：架构涉及 Fargate、Kinesis、Flink、Neptune、OpenSearch 等 AWS 服务，对小型项目来说过重
- **非 Smartsheet 生态**：工具定义紧密绑定 Smartsheet API（Sheets、Workspaces、Forms 等），不直接适用于其他 SaaS
- **需要标准 JSON 交互的客户端**：自定义序列化格式虽然节省 Token，但需要客户端适配，标准 MCP 客户端可能无法直接解析
- **低延迟实时场景**：Progressive Disclosure 意味着 Agent 可能需要多次往返才能获取完整数据，不适合对延迟极度敏感的场景

### 迁移成本

| 从... | 到... | 工作量估算 | 关键步骤 |
|-------|-------|-----------|---------|
| Smartsheet 传统 API | Smartsheet MCP Server | 低（客户端侧） | 切换端点 + 适配 MCP 协议 + 处理 Progressive Disclosure 元数据 |
| 自建 MCP Wrapper | Smartsheet MCP Server | 中 | 迁移工具定义 + 重新配置认证 + 测试工作流 |
| 其他 SaaS API | 类似 MCP 架构 | 高 | 需自建完整架构（网关、MCP Server、序列化层、可观测性） |

## 对你的意义

这个案例对 Ken 的两条线都有参考价值：

**AI 应用开发线**：
- MCP 作为 Agent 工具集成协议的企业级落地案例，验证了 A-001 假设（MCP 成为事实标准）
- Progressive Disclosure 的设计思路可直接应用于 RAG 工具链——当检索结果过多时，先返回摘要 + 元数据，让 Agent 按需深入
- 自定义序列化节省 35-47% Token 的思路值得在 Agent 工具响应优化中尝试

**VLA 研究线**：
- "Build Once, benefit everywhere" 的单层架构思想与 VLA 系统中统一工具接口的理念相通
- Agent-first 可观测性（关联工具链上下文）对多步 VLA 推理链的调试有启发

**建议**：立即关注 Smartsheet MCP Server 的后续发展（特别是 Bedrock AgentCore 集成和个性化 Resources），作为企业 MCP 部署的标杆案例跟踪。

## 关键代码/配置片段

**Progressive Disclosure 元数据返回结构**（来自官方文档）：

```
# 每次工具响应包含以下元数据字段：
- is_sampled: boolean          # 数据是否被截断
- rows_in_sheet: int           # 表中总行数
- rows_actual: int             # 实际返回的行数
- filters_applied: list        # 当前生效的过滤器
```

**MCP 工具注解**（控制 AI 客户端行为）：

```
# 每个工具携带 MCP 协议注解：
- readOnlyHint: true/false     # 只读操作，无需用户确认
- destructiveHint: true/false  # 破坏性操作，需用户确认
```

**分层限流架构**（AWS WAF 三层防护）：

```
Layer 1: Edge Protection     → 全局防护，防止 DDoS
Layer 2: Per-User Metering   → 基于身份头的每用户配额（非 IP 聚合）
Layer 3: Path-Specific       → 昂贵操作的专项限流
```

**Token 优化效果数据**（官方报告）：

```
33-item filtered query:
  JSON response:    ~6,000 tokens
  Optimized format: ~3,900 tokens
  Savings:          ~35%

1,000 rows (gap widens):
  JSON repeats keys per row
  Optimized declares keys once
  Savings:          >35% (increases with row count)

Total tokens saved since launch: 3+ billion
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | Smartsheet 作为企业级 SaaS 平台选择 MCP 作为统一 Agent 接入协议，内部 Smart Assist 和外部 AI 客户端（Amazon Quick、Claude Desktop）共用同一 MCP 层，GA 首四周 87% 周增长验证了市场需求 |

---
[← Back to Deep Dives](./README.md)
