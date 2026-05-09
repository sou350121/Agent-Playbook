---
auto_generated: true
generated_at: "2026-05-09T05:47:34Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/introducing-the-agent-quality-loop-agentcore-optimization-now-in-preview/"
signal_type: "significant_update"
---
# AWS AgentCore Optimization：Agent 质量闭环（推荐 + A/B 测试）

> 🔍 本文由 Moltbot 自动生成 | 2026-05-09
>
> **项目/工具**: Amazon Bedrock AgentCore Optimization
> **链接**: https://aws.amazon.com/blogs/machine-learning/introducing-agent-quality-optimization-in-agentcore-now-in-preview/
> **核心定位**: 从生产 trace 自动生成 prompt/tool 优化推荐，经 batch eval + A/B 测试验证后上线，替代人工 prompt 调优循环

## 快速判断（30 秒读完这段就够了）

- **一句話定位**：AWS AgentCore 新增的「觀察 → 評估 → 推薦 → 驗證 → 部署」闭环，让 Agent 质量优化从人工经验驱动变为数据驱动
- **現在值得用嗎**：是——如果你已经在用 AgentCore Runtime + Observability + Evaluations，这是自然延伸；如果没用 AgentCore，则需要整体迁移
- **適合場景**：生产 Agent 持续质量退化、多版本 prompt 需要 A/B 验证、CI/CD 管线需要自动化回归测试
- **不適合場景**：单次性 Agent 原型、非 AgentCore 部署的 Agent（如自建 LangChain/LlamaIndex 服务）、需要优化 tool 代码逻辑（目前只优化 system prompt 和 tool description）
- **與手動調優核心差異**：从「用户投诉 → 开发者读 trace → 凭直觉改 prompt → 盲测上线」变为「trace 自动分析 → 数据驱动推荐 → 统计显著性验证 → 灰度发布」

## 是什么 / 解决什么问题

生产环境的 AI Agent 有一个被严重低估的问题：**质量退化是渐进且隐蔽的**。模型升级、用户行为偏移、prompt 在新场景中被误用——这些因素每天都在悄悄降低 Agent 的表现。但大多数团队的优化流程仍然停留在手动阶段：用户投诉 → 开发者读 trace → 形成假设 → 改写 prompt → 手工测试几个用例 → 上线 → 循环。这个过程有三个致命缺陷：

1. **反应式而非主动式**：等用户投诉才发现问题，此时已经有大量用户受到影响
2. **直觉驱动而非数据驱动**：开发者凭经验判断根因，容易误诊
3. **盲测上线**：修改后只测少量用例，无法保证不引入回归

AWS AgentCore Optimization（预览版）试图用一条完整的自动化管线来解决这个问题。它由三个核心组件构成：

- **Recommendations（推荐）**：分析生产 trace 和评估输出，自动生成 system prompt 或 tool description 的优化建议
- **Batch Evaluation（批量评估）**：用预定义测试数据集验证推荐，报告聚合分数，捕获已知回归
- **A/B Testing（A/B 测试）**：通过 AgentCore Gateway 分割生产流量，用统计显著性验证新版本效果

三者串联后，替代了传统的人工调优循环。

## 技术架构拆解

### 核心设计决策

**决策 1：以 trace 为唯一数据源**
所有推荐都基于 AgentCore Observability 收集的 OpenTelemetry 兼容 trace。每个 model call、tool invocation、reasoning step 都被记录为结构化数据。这意味着推荐的质量直接取决于 trace 的覆盖度和质量。

**决策 2：推荐与验证分离**
Recommendations 只负责「提出建议」，不负责「判断建议好不好」。验证交给 Batch Evaluation（离线）和 A/B Testing（在线）两个独立组件。这种分离确保：
- 推荐可以被多个验证方式交叉检验
- 开发者始终保留最终决定权（"The service proposes, and you decide"）

**决策 3：Configuration Bundle 作为版本化载体**
配置变更被打包为 immutable、versioned 的 Configuration Bundle，包含 model ID、system prompt、tool descriptions。Agent 通过 AgentCore SDK 在运行时动态读取活跃配置。**换 prompt 或换模型是配置变更，不是代码变更**。这个设计将 Agent 配置管理提升到了基础设施级别。

**决策 4：预览版限定优化范围**
当前预览版只优化 system prompt 和 tool description，不触碰 tool 代码实现。对 tool description 的优化只 sharpen 描述文字，不改 tool 逻辑。这是合理的范围控制——prompt 优化是最常见、最高频的需求，先做透再扩展。

### 与前版/竞品的关键差异

| 维度 | 传统手动调优 | AgentCore Optimization | LangSmith / LangGraph | Databricks Mosaic AI Eval |
|------|-------------|----------------------|----------------------|--------------------------|
| 推荐生成 | 人工读 trace 凭经验 | 自动分析 trace + 指定 reward signal | 主要提供 observability，无自动推荐 | 提供 eval 框架，无自动推荐 |
| 验证方式 | 手工测试少量用例 | Batch eval（离线）+ A/B test（在线） | 主要靠 eval 框架 | 主要靠 eval 框架 |
| 统计显著性 | 无 | 内置 confidence intervals + p-values | 需自行实现 | 需自行实现 |
| 灰度发布 | 自行实现 | AgentCore Gateway 原生支持流量分割 | 无 | 无 |
| 配置版本化 | Git 管理 prompt 文件 | Configuration Bundle（runtime ARN 绑定） | 无专门机制 | 无专门机制 |
| 闭环程度 | 断裂（推荐和验证分离） | 完整闭环（trace → recommend → validate → deploy） | 半闭环（observability + eval） | 半闭环（eval only） |
| 部署绑定 | 无 | 必须运行在 AgentCore Runtime | 无绑定 | 无绑定 |

### 架构 / 信息流图

```
┌──────────────────────────────────────────────────────────────────┐
│                    AgentCore Optimization Loop                    │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────┐    trace (OTel)    ┌──────────────────┐         │
│  │  Agent      │ ─────────────────► │ Observability     │         │
│  │  Runtime    │                    │ (CloudWatch Logs) │         │
│  │             │ ◄───────────────── │                   │         │
│  │ Config      │    active config   └────────┬─────────┘         │
│  │ Bundle      │                             │                    │
│  └─────────────┘                    eval scores               │
│                                      │                          │
│                               ┌──────▼──────┐                   │
│                               │ Evaluations  │                   │
│                               │ (scored      │                   │
│                               │  traces)     │                   │
│                               └──────┬──────┘                   │
│                                      │                          │
│                    ┌─────────────────┼─────────────────┐        │
│                    │                 │                 │        │
│              ┌─────▼─────┐   ┌───────▼───────┐  ┌────▼─────┐   │
│              │ Recommend │   │ Batch Eval    │  │ A/B Test │   │
│              │ (generate │   │ (offline      │  │ (online  │   │
│              │  prompt/   │   │  validation)  │  │  validation│  │
│              │  tool desc)│   │               │  │ + stats) │   │
│              └─────┬─────┘   └───────┬───────┘  └────┬─────┘   │
│                    │                 │               │         │
│                    └────────┬────────┘               │         │
│                             │                        │         │
│                      ┌──────▼──────┐                 │         │
│                      │ Config      │                 │         │
│                      │ Bundle      │◄────────────────┘         │
│                      │ (v2,        │   promote if              │
│                      │  immutable) │   statistically valid     │
│                      └──────┬──────┘                          │
│                             │                                 │
│                    ┌────────▼────────┐                        │
│                    │ AgentCore       │                        │
│                    │ Gateway         │── split live traffic   │
│                    │ (traffic mgmt)  │                        │
│                    └─────────────────┘                        │
└──────────────────────────────────────────────────────────────────┘
```

### 完整工作流（以模型升级场景为例）

```
1. Observability 收集生产 trace（每个 model call / tool invocation / reasoning step）
2. Evaluations 自动评分（goal success rate, tool selection accuracy, helpfulness, safety）
3. 开发者调用 Recommendations API：
   - 指向 CloudWatch Log group
   - 选择 reward signal（要优化的评估维度）
   - 选择优化目标（system prompt 或 tool descriptions）
4. AgentCore 分析 trace，生成推荐
5. 开发者将推荐打包为 Configuration Bundle v2
6. Batch Evaluation：用 curated dataset 跑 v2，对比 baseline 聚合分数
7. A/B Testing：Gateway 分割流量（如 90% v1 / 10% v2），实时评分
8. 统计显著性达标 → promote v2 为默认配置
9. v2 成为新 baseline，产生新 trace → 回到步骤 1（飞轮）
```

## 实用评估

### 什么场景值得用

**场景 1：生产 Agent 质量退化追踪**
当你的 Agent 已经上线运行一段时间，用户反馈质量下降但难以定位根因。AgentCore Optimization 可以从 trace 中自动发现模式——例如某类 query 的 goal success rate 持续下降，并自动生成针对性的 prompt 修改建议。NTT DATA 的案例表明，「原本需要数周手动 prompt 调优的流程，现在变成了快速可重复的循环」。

**场景 2：多版本 prompt 需要统计验证**
当你不确定两个 prompt 版本哪个更好时，A/B Testing 提供了科学的验证方式。它不只是分割流量，还内置 confidence intervals 和 p-values，让你知道差异是否具有统计显著性，而非随机波动。Nomura Research Institute 的评价是：「每次循环都为下一次产生基线数据——改进过程是复利式的。」

**场景 3：CI/CD 管线中的 Agent 配置回归测试**
Batch Evaluation 可以接入 CI/CD 管线，确保每次配置变更都经过已知 good cases 的检验。对于有严格发布流程的企业团队，这比手工测试可靠得多。

**场景 4：Tool description 优化**
当 Agent 的工具选择准确率不高时，往往不是 tool 代码的问题，而是 tool description 不够清晰导致 LLM 选错工具。AgentCore Optimization 可以单独 sharpen tool description 而不触碰 tool 实现，这是一个高频但常被忽视的优化点。

### 什么场景不值得用

**场景 1：非 AgentCore 部署的 Agent**
如果你用 LangChain、LlamaIndex 或自建框架构建 Agent，且不打算迁移到 AgentCore Runtime，这个功能完全不可用。它是 AgentCore 平台的原生能力，不是独立工具。

**场景 2：需要优化 tool 代码逻辑**
当前预览版只优化 system prompt 和 tool description。如果你的问题在于 tool 实现本身的 bug 或性能瓶颈，这个工具帮不上忙。

**场景 3：单次性原型或 PoC**
如果你的 Agent 还在实验阶段，不需要持续优化闭环，手动调优反而更直接。这个管线的价值在于「持续飞轮」，一次性使用无法摊平学习成本。

**场景 4：需要多目标同时优化且存在 trade-off**
当前版本只支持单一 reward signal。如果你的场景需要同时优化 helpfulness 和 safety 且两者存在冲突，需要等未来版本支持 multi-evaluator 权衡。

### 迁移成本

**如果你已经在用 AgentCore Runtime + Observability + Evaluations**：
- 迁移成本：**低**。Recommendations API 是自然延伸，Configuration Bundle 和 Gateway 可能需要进行少量配置调整
- 学习时间：阅读 [tutorial](https://github.com/awslabs/agentcore-samples/tree/main/01-tutorials/12-AgentCore-optimization) 约 1-2 小时可上手

**如果你使用其他 Agent 框架**：
- 迁移成本：**高**。需要整体迁移到 AgentCore Runtime，包括 tool 注册、observability 集成、evaluation 配置
- 需要评估：AgentCore 的平台锁定风险 vs. 优化闭环的收益

## 对你的意义

对 Ken 的 AI 应用开发方向来说，这个发布有几个值得关注的信号：

1. **Agent 质量运维正在产品化**。AWS 把「trace → eval → recommend → validate → deploy」做成了平台能力，说明 AgentOps 正在从「自建工具链」走向「平台内置」。这与你关注的 Agent 工程化趋势一致——工具链的成熟度在快速提升。

2. **Configuration as Code 的延伸**。Configuration Bundle 的概念把 prompt 和 tool description 提升到了「基础设施即代码」的级别。这跟 GitOps 的理念一脉相承——prompt 不再是代码里的字符串，而是可版本化、可回滚、可灰度的独立制品。

3. **A/B Testing for Agents 是差异化能力**。市面上大多数 eval 工具只覆盖离线评估，A/B Testing（带统计显著性）是 AgentCore 的差异化点。如果 Ken 的团队未来需要为企业客户交付可验证的 Agent 质量改进，这种能力有直接价值。

**建议**：如果 Ken 的团队正在评估 Agent 平台选型，AgentCore Optimization 的闭环能力是一个加分项。但如果已经深度绑定其他框架，单独为这个功能迁移的 ROI 需要仔细评估。可以先阅读 [Market Trends Agent sample](https://github.com/awslabs/agentcore-samples/tree/main/02-use-cases/market-trends-agent) 了解完整工作流，再做判断。

## 关键代码/配置片段

以下是来自 AWS 官方文档和示例的核心概念说明（引用自官方博客）：

**Configuration Bundle 概念**：
> Configurations ship as bundles, which are immutable, versioned snapshots of your agent's configuration keyed by runtime ARN: model ID, system prompt, tool descriptions. Your agent reads its active configuration dynamically at runtime through the AgentCore SDK, so swapping a prompt or a model is a configuration change, not a code change.

**Recommendations 调用方式**：
> Point the Recommendations API at the CloudWatch Log group where your agent writes traces. Pick the reward signal as the evaluator you want to optimize for, either a built-in evaluator from AgentCore or a custom evaluator you've built, and choose what to optimize: the system prompt or the tool descriptions.

**A/B Testing 流量分割**：
> Configure AgentCore Gateway to split live production traffic between two variants, with the current version as the control and the candidate as the treatment. Variants can be different bundle versions on the same runtime for configuration-only changes, or different gateway targets pointing to separate runtime endpoints for changes that include code.

**客户评价 — NTT DATA（Yoshiharu Okuda, Head of GenAI Business Strategy）**：
> Processes that traditionally required weeks of manual prompt tuning have evolved into rapid, repeatable cycles through the use of AgentCore.

**客户评价 — Nomura Research Institute（Masashi Shimizu, Senior Managing Director）**：
> What took weeks of manual prompt iteration is now a repeatable cycle with AgentCore: generate a recommendation from production traces, validate it against live traffic with statistical significance, and deploy the winning configuration. Each cycle produces the baseline data for the next — the improvement process compounds.

## Roadmap 展望

官方博客披露了未来方向：

| 方向 | 说明 |
|------|------|
| Multi-evaluator 推荐 | 同时权衡多个评估维度，展示 trade-off |
| Skills 优化扩展 | 不仅优化 prompt/tool description，还提议新 skill 或改进现有 skill |
| Trace 聚类分析 | 将生产失败自动聚类为模式，在问题扩散前主动处理 |
| Monitor Alarms 自动触发 | 评估分数低于阈值时自动启动推荐 + 验证流程，结果进入 review queue |
| 飞轮自动化 | 从「开发者手动触发」走向「系统自动运转」，人工只保留 approve/reject 权限 |

当前预览版是「开发者手动触发」模式。自动化飞轮是愿景，但尚未实现。

---
[← Back to Deep Dives](./README.md)
