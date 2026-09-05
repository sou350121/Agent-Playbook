---
auto_generated: true
generated_at: "2026-09-05T05:47:57Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/designing-lifecycle-policies-for-agentcore-memory/"
signal_type: "blog_post"
---
# AgentCore Memory 生命周期管理：长运行 Agent 的遗忘策略 (Designing Lifecycle Policies for AgentCore Memory)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-05
>
> **项目/工具**: Amazon Bedrock AgentCore Memory
> **链接**: https://aws.amazon.com/blogs/machine-learning/designing-lifecycle-policies-for-agentcore-memory/
> **核心定位**: AWS 推出的生产级 Agent 记忆管理方案，通过评分-合并-修剪的 nightly 工作流，系统性地解决长运行 Agent 因过时上下文导致的质量退化问题。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: AWS 提供了一套可部署的 Agent 记忆生命周期管理架构，包含三种记忆分类 + 三种策略（TTL 过期 / 相关性衰减评分 / LLM 合并），通过 Step Functions 编排 nightly 工作流。
- **现在值得用吗**: 是——如果你正在用或计划用 Bedrock AgentCore 构建长运行 Agent（客服、IT 运维、销售助手）。对个人助手类低频 Agent，TTL + GDPR 可能就够了。
- **适合场景**: 客服 Agent（高交互量、短期上下文有价值）、IT 运维 Agent（事件模式季节性重复）、销售/入职 Agent（deal 周期数周）
- **不适合场景**: 低频个人助手（TTL 即可）、非 AWS 生态的 Agent 部署（需要自行实现类似逻辑）
- **与前版核心差异**: AgentCore Memory 此前只解决了"记住"的问题；这套方案首次系统性地解决了"忘记"的问题——记忆管理从被动积累变为主动治理。

## 是什么 / 解决什么问题

长运行 AI Agent 面临一个被长期忽视的问题：**记忆污染**。

Agent 从每次对话中生成记忆条目。如果不主动管理，这些记忆会无限积累。几个月后，客服 Agent 可能引用四个月前已解决的账单纠纷，运维 Agent 可能重复已被替代的部署手册建议。这不只是"噪音"问题——它会直接降低响应质量，并带来合规风险。

AWS 这篇 blog 提出的方案核心思路是：**记忆应该像数据一样被生命周期管理**。不是简单地加 TTL 删除，而是通过分类（episodic / semantic / procedural）→ 评分（相关性衰减）→ 合并（LLM 压缩）→ 修剪（删除低分记忆）的四步流水线，让 Agent 的记忆保持精简、高信噪比。

方案已提供完整 CDK 部署栈和 GitHub 代码（aws-samples/sample-memory-lifecycle-policies-for-bedrock-agentcore），是一个可以直接落地的生产方案。

## 技术架构拆解

### 核心设计决策

1. **记忆三分法**：将 Agent 记忆分为情景记忆（episodic）、语义记忆（semantic）、程序记忆（procedural），每种类型有不同的保留策略。这是整个方案的设计基础。

2. **三层递进策略**：TTL 过期（硬删除）→ 相关性评分（软筛选）→ LLM 合并（有损压缩）。先粗后细，避免在应该直接删除的记忆上浪费 LLM 调用。

3. **CloudTrail 补全访问数据**：AgentCore Memory API 不暴露 `lastAccessedAt` 字段。AWS 通过 CloudTrail 的 `GetMemoryRecord` 数据事件来追踪每次读取，构建 per-record 的访问 ledger。这是一个巧妙的 workaround。

4. **可配置权重而非硬编码**：相关性评分的三个权重（W_RECENCY=0.4, W_ACCESS=0.35, W_FREQUENCY=0.25）和 pruneDays 参数全部可配置，适配不同 Agent 类型。

### 与前版/竞品的关键差异

| 维度 | 传统 Agent 记忆 | AgentCore Memory（无生命周期） | AgentCore + 生命周期管理 |
|------|----------------|-------------------------------|------------------------|
| 记忆增长 | 无限积累 | 无限积累 | 主动修剪 + 合并 |
| 记忆分类 | 无区分 | 支持 episodic/semantic/procedural 存储 | 按分类差异化 TTL 和策略 |
| 过时内容处理 | 无 | 无 | 相关性衰减评分 + LLM 合并 |
| 合规能力 | 手动 GDPR | TTL 手动管理 | 自动化 TTL + 审计日志 |
| 部署复杂度 | 低 | 低 | 中（CDK 一键部署） |
| 可观测性 | 无 | 基础 API | CloudWatch 指标 + S3 审计 |

### 架构/信息流图

```
┌─────────────┐
│ EventBridge  │  nightly trigger
│  (cron)     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────┐
│              Step Functions State Machine            │
│                                                     │
│  ┌─────────────┐    ┌──────────────┐               │
│  │ 1. Pruner   │───▶│ 2. Scorer    │               │
│  │  (TTL)      │    │  (CloudTrail │               │
│  │  硬删除过期  │    │   + S3 ledger│               │
│  │  记忆       │    │   评分)      │               │
│  └─────────────┘    └──────┬───────┘               │
│                            │                        │
│                            ▼                        │
│                     ┌──────────────┐                │
│                     │ 3. Consolid. │                │
│                     │  (Bedrock    │                │
│                     │   LLM 合并)  │                │
│                     └──────┬───────┘                │
│                            │                        │
│              ┌─────────────┴─────────────┐          │
│              ▼                           ▼          │
│     ┌──────────────┐            ┌──────────────┐    │
│     │ 4. Metrics   │            │ 5. Run Output│    │
│     │ (CloudWatch) │            │  (S3 审计)   │    │
│     └──────────────┘            └──────────────┘    │
│                                                     │
│  失败 → SNS Alert                                   │
└─────────────────────────────────────────────────────┘
```

### 相关性评分公式

系统使用三项加权衰减公式计算每条记忆的相关性分数（0.0-1.0）：

```python
score = W_RECENCY * exp(-decay_rate * days_since_creation)
      + W_ACCESS  * exp(-decay_rate * days_since_last_access)
      + W_FREQ    * min(access_count / MAX_ACCESS_BASELINE, 1.0)
```

其中 decay_rate 由直觉参数 `pruneDays` 推导：

```python
decay_rate = -ln(threshold) / prune_days
# 默认: pruneDays=45, threshold=0.3 → decay_rate ≈ 0.02676
```

**设计亮点**：用 `pruneDays` 代替裸 `decay_rate` 作为输入参数——运营者可以说"45 天没访问的记忆应该被标记"，而不是调一个抽象的指数衰减常数。

### Agent 类型推荐配置

| Agent 类型 | pruneDays | 理由 |
|-----------|-----------|------|
| 实时客服 | 7 | 工单数小时/天解决，旧上下文无价值 |
| 销售/入职 | 21 | Deal 周期数周，过时线索污染上下文 |
| 通用助手 | 45 | 混合负载的平衡保留 |
| IT 运维 | 90 | 事件模式季节性重复 |
| 法律/合规 | 180 | 先例数月内仍有参考价值 |

## 实用评估

### 什么场景值得用

- **生产级客服 Agent**：日交互数百次，记忆快速膨胀。TTL 7-30 天 + 高频合并可显著减少上下文窗口浪费。
- **IT 运维/Helpdesk Agent**：事件模式有季节性（如季度末、大促期间），pruneDays=90 保留足够的历史参考。
- **销售 Agent**：Deal 周期通常 2-4 周，pruneDays=21 确保推荐的是当前有效的报价和方案。
- **合规敏感场景**：自动化 TTL 删除比手动管理更可靠，配合 S3 审计日志满足 GDPR/CCPA 要求。

### 什么场景不值得用

- **低频个人助手**：每天几次对话，记忆积累慢。简单的 TTL 过期 + GDPR 手动删除就够了，不需要 nightly 工作流。
- **非 AWS 生态**：方案深度绑定 Bedrock AgentCore + Step Functions + CloudTrail。如果 Agent 跑在自有基础设施上，需要自行实现类似逻辑（但思路可借鉴）。
- **高保真要求场景**：LLM 合并是有损的——5 条记忆合并为 1 条可能丢失细节。医疗/法律等高风险场景应考虑归档而非删除。

### 迁移成本

- **已有 AgentCore 部署**：CDK 一键部署，约 30 分钟完成基础设施创建。主要工作量是调整 pruneDays 和权重参数以匹配业务场景。
- **无 AgentCore 部署**：需要先在 Bedrock 上部署 AgentCore Memory，然后叠加生命周期管理。整体约 1-2 天。
- **非 AWS 环境**：架构思路可直接复用（分类 → TTL → 评分 → 合并），但需要自行实现：记忆存储层、访问追踪（可用应用日志替代 CloudTrail）、LLM 合并（可用任意 LLM API）。

## 对你的意义

这套方案对 Ken 的 AI 应用开发有两层价值：

1. **架构参考**：即使不跑在 AWS 上，"记忆三分法 + 三层递进策略"的设计模式可以直接借鉴。任何长运行 Agent 都面临记忆污染问题，这套方案提供了一个经过生产验证的模板。

2. **Agent 基础设施趋势信号**：AWS 开始系统化解决 Agent 记忆管理问题，说明 Agent 基础设施正在从"能跑"向"能长期稳定运行"演进。记忆治理、Agent 可观测性、Agent 合规——这些 Q2 还是实验性的方向，正在变成工程标配。

**建议**：如果 Ken 正在设计 Agent 架构，值得把"记忆如何被管理"纳入设计考量，而不是等到记忆污染成为问题再补救。

## 关键代码/配置片段

### TTL 过期实现（利用 AgentCore Memory 的时间戳过滤）

```python
cutoff = (now - timedelta(days=ttl_days)).isoformat()

response = client.list_memory_records(
    memoryId=memory_id,
    namespace=agent_id,
    metadataFilters=[{
        "left": {"metadataKey": "x-amz-agentcore-memory-createdAt"},
        "operator": "BEFORE",
        "right": {"metadataValue": {"dateTimeValue": cutoff}},
    }],
)
```

### 相关性评分函数（完整实现）

```python
def compute_relevance_score(
    created_at: datetime,
    last_accessed_at: datetime,
    access_count: int,
    decay_rate: float,
    now: datetime,
    w_recency: float = 0.4,
    w_access: float = 0.35,
    w_frequency: float = 0.25,
    max_access_baseline: int = 50,
) -> float:
    days_since_creation = max((now - created_at).total_seconds() / 86400, 0.0)
    days_since_last_access = max((now - last_accessed_at).total_seconds() / 86400, 0.0)
    recency_term = w_recency * math.exp(-decay_rate * days_since_creation)
    access_term = w_access * math.exp(-decay_rate * days_since_last_access)
    frequency_term = w_frequency * min(access_count / max_access_baseline, 1.0)
    return recency_term + access_term + frequency_term
```

### LLM 合并 Prompt

```python
CONSOLIDATION_PROMPT_TEMPLATE = """You are a memory consolidation assistant.
Given the following agent memories, create a single concise summary that
preserves essential facts, user preferences, and actionable knowledge.
Remove redundancy and outdated information.

Memories:
{memory_contents}

Output a JSON object with:
- "summary": the consolidated memory text
- "confidence": a float 0.0-1.0 indicating consolidation quality
- "key_facts": list of preserved key facts"""
```

---
[← Back to Deep Dives](./README.md)
