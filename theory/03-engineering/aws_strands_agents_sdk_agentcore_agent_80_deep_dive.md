---
auto_generated: true
generated_at: "2026-07-28T06:48:45Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/evaluating-ai-agents-a-production-blueprint-with-strands-and-agentcore/"
signal_type: "significant_update"
---
# AWS Strands Agents SDK + AgentCore：生产级 Agent 评估管线 (Evaluating AI Agents: A Production Blueprint with Strands and AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-28
>
> **项目/工具**: Strands Agents SDK + Amazon Bedrock AgentCore Evaluations
> **链接**: https://aws.amazon.com/blogs/machine-learning/evaluating-ai-agents-a-production-blueprint-with-strands-and-agentcore/
> **核心定位**: 一套框架无关的三层次 Agent 评估 SDK + 生产级持续监控管线，将真实业务中 Agent 错误率从 1/8 降至 1/50

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**：Strands Agents SDK 提供了一个框架无关的三层次 Agent 评估框架（工具使用 → 推理质量 → 输出质量），配合 Amazon Bedrock AgentCore 实现 CI/CD 质量门 + 生产环境持续采样监控。
- **现在值得用吗**：是——如果你正在构建面向用户的 AI Agent 并需要可靠的评估体系。对于内部工具或实验性项目，可能过重。
- **适合场景**：生产级多工具 Agent、需要 CI/CD 质量门禁的团队、已有 AWS 基础设施的部署
- **不适合场景**：简单单轮问答、非 AWS 环境且不愿引入 AWS 依赖、快速原型验证
- **与竞品核心差异**：DeepEval/Ragas 偏 LLM 输出评估，此方案首创「工具调用正确性 + 推理轨迹 + 输出质量」三层递进门控，且 pass^k 指标专为 Agent 非确定性设计

## 是什么 / 解决什么问题

AI Agent 的评估与传统 LLM 评估有本质区别。LLM 评估关注文本生成质量（连贯性、事实准确性），而 Agent 评估需要回答：「Agent 是否选了正确的工具？参数传递是否正确？多轮对话中是否保持了上下文一致性？」

Motorway 是英国一家在线汽车交易市场，每天最多有 8,000 家经销商竞拍 2,500 辆汽车。他们构建了一个 AI 驱动的经销商库存搜索 Agent，允许经销商用自然语言查询车辆（如「Find me diesel SUVs under 25k near my dealership」）。在高峰时段 1,500+ 并发用户下，工具选择错误或语义搜索误解读会直接损害用户信任。

核心痛点：
- **工具选择错误**导致搜索返回错误结果，侵蚀经销商信任
- **语义搜索误解读**：如 "Petrol, Hybrid and electric cars up to 5 years old" 需要 Agent 正确解析多重约束
- **多轮对话上下文漂移**：经销商在多轮交互中细化搜索条件时，Agent 丢失前文约束
- **非确定性输出**使单次测试不可靠——同一输入可能产生不同结果

AWS PACE 团队与 Motorway 联合构建的评估管线，将错误结果从每 8 次查询 1 次错误降至每 50 次查询 1 次错误，问题检测时间从数小时缩短至数分钟。

## 技术架构拆解

### 核心设计决策

1. **两阶段评估策略**：构建时离线评估（CI/CD 质量门）+ 生产环境在线评估（采样监控），覆盖 GenAIOps 全生命周期
2. **三层次递进门控**：工具使用 (>95%) → 推理质量 (>85%) → 输出质量 (>90%)，任一层次失败即阻断部署
3. **pass^k 而非 pass@k**：针对 Agent 非确定性，使用连续 k 次试验均成功的概率衡量可靠性，而非至少一次成功
4. **框架无关设计**：SDK 支持 Strands Agents、LangChain、CrewAI、OpenAI 及自定义 HTTP 端点
5. **生产数据反哺测试集**：生产监控发现的问题自动转化为新测试用例，Motorway 的测试集从 50 条在 3 个月内增长至 150 条

### 与前版/竞品的关键差异

| 维度 | 传统 LLM 评估 (DeepEval/Ragas) | Strands + AgentCore 方案 |
|------|-------------------------------|-------------------------|
| 评估对象 | 文本输出质量 | 工具调用 + 推理轨迹 + 输出质量 |
| 非确定性处理 | 单次评分或 pass@k | pass^k（连续 k 次均成功） |
| 部署门禁 | 无硬门控或阈值 | 三层阈值全部通过方可部署 |
| 生产监控 | 需额外集成 LangSmith 等 | AgentCore 内置 OpenTelemetry 采样 |
| 多轮对话 | 有限支持 | ActorSimulator + InteractionsEvaluator 原生支持 |
| 框架兼容性 | 各有侧重 | SDK 框架无关，支持主流 Agent 框架 |
| 测试集演化 | 静态 | 生产数据自动反哺增长 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CI/CD Pipeline (Build-Time)                  │
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐           │
│  │  Layer 1     │───▶│  Layer 2     │───▶│  Layer 3     │───▶ Gate  │
│  │ Tool Usage   │    │ Reasoning    │    │ Output Quality│           │
│  │ >95% thresh  │    │ >85% thresh  │    │ >90% thresh  │           │
│  │ Deterministic│    │ LLM-as-Judge │    │ LLM-as-Judge │           │
│  └──────────────┘    └──────────────┘    └──────────────┘           │
│       │                                            │                │
│       ▼                                            ▼                │
│  ToolSelectionGrader                    OutputEvaluator             │
│  TrajectoryOrderGrader                  GoalSuccessRateEvaluator    │
│                                       + Custom Domain Evaluators    │
└─────────────────────────────────────────────────────────────────────┘
                              │  deploy if all passed
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Production (Online Monitoring)                   │
│                                                                     │
│  Dealer Query ──▶ AgentCore Runtime ──▶ Claude Sonnet 4.6           │
│                        │                      │                     │
│                        ▼                      ▼                     │
│                   8 Tools              LanceDB (Vector)             │
│              (search/filter/           + Titan Embeddings V2         │
│               SQL/hybrid/geo)                                        │
│                        │                                             │
│                        ▼                                             │
│              OpenTelemetry Traces                                    │
│              (sampled 1-5%)                                          │
│                        │                                             │
│                        ▼                                             │
│           AgentCore Evaluations                                      │
│         ┌─────────────────────┐                                      │
│         │ On-demand: debug    │                                      │
│         │ Online: auto-sample │                                      │
│         │ (up to 10 evaluators│                                      │
│         │  + custom domain)   │                                      │
│         └─────────────────────┘                                      │
│                        │                                             │
│                        ▼                                             │
│               CloudWatch Metrics                                     │
│               ┌─────────────────┐                                    │
│               │ Alert on fail   │────▶ New test case added           │
│               └─────────────────┘                                    │
└─────────────────────────────────────────────────────────────────────┘
```

### Agent Runtime 工具矩阵

| 工具类别 | 工具名 | 职责 |
|----------|--------|------|
| 结构化搜索 | search_vehicles | 基于 89+ 车辆属性的结构化过滤 |
| SQL 查询 | run_sql | 经过验证的 pandas 查询 |
| 语义搜索 | hybrid_search | LanceDB 向量相似度 + 结构化过滤混合 |
| 地理过滤 | filter_by_distance | 距离约束过滤 |
| 辅助工具 | get_schema / get_embedding / get_bids | 元数据与嵌入获取 |
| 经销商档案 | Dealer API (MCP) | 通过 AgentCore Gateway 前端化 |
| 跨会话记忆 | AgentCore Memory | 用户偏好与事实的语义策略 |

## 实用评估

### 什么场景值得用

- **生产级多工具 Agent**：你的 Agent 调用 3+ 个工具，工具选择错误会直接影响用户体验。三层次门控能系统性捕获这类问题。
- **需要 CI/CD 质量门禁的团队**：如果你希望部署前自动阻断低质量变更，三层阈值 + pass^k 提供了可操作的门禁标准。
- **多轮对话场景**：ActorSimulator + InteractionsEvaluator 原生支持多轮一致性评估，这是大多数评估框架的盲区。
- **已有 AWS 基础设施**：AgentCore Evaluations 与 Bedrock/Lambda/S3 深度集成，部署成本约 $50-100/月（开发测试环境）。

### 什么场景不值得用

- **简单单轮问答**：如果你的 Agent 只是调用 LLM 生成文本回复，DeepEval 或 Ragas 更轻量。
- **非 AWS 环境且不愿引入 AWS 依赖**：虽然 SDK 框架无关，但生产监控部分强依赖 AgentCore。纯 GCP/Azure 环境迁移成本高。
- **快速原型验证**：初始部署需 30-45 分钟 + 2-3 小时领域定制，对于 2 周内的原型验证来说过重。
- **预算极度受限**：LLM-as-Judge 评估每次运行约 $5-10 Bedrock 推理费用，高频 CI 运行成本会累积。

### 迁移成本

从现有评估框架（如 DeepEval/Ragas）迁移到本方案：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 安装 SDK + 配置 | 30 分钟 | `uv sync` + 配置 eval_config.yaml |
| 定义工具清单 | 1-2 小时 | 列出 Agent 所有工具及预期调用条件 |
| 编写测试用例 | 2-4 小时/20 条 | 每条需标注预期工具轨迹 + 输出 |
| 集成 CI/CD | 1-2 小时 | 在 pipeline 中调用 `run_all_layers()` |
| 部署生产监控 | 2-3 小时 | AgentCore Runtime + OpenTelemetry + 采样配置 |
| 校准 LLM Judge | 1-2 小时 | 用人工标注校准 LLM-as-Judge 评分一致性 |

### pass^k 指标详解

这是该方案最有原创性的设计之一：

```
pass@k = 至少一次成功的概率  → 适合「找到一条正确路径即可」的场景
pass^k = 连续 k 次均成功的概率 → 适合「每次交互都需可靠」的客服/生产场景
```

对于面向用户的 Agent，pass^k 才是正确指标。一个单次成功率 75% 的 Agent，连续 3 次均成功的概率仅为 0.75³ = 42%。用户不会接受「大约一半的时候你会得到正确答案」。

```python
# run_all_layers 内置多试验支持
results = run_all_layers(
    task_fn=my_agent_task,
    registry=tool_registry,
    num_trials=5  # pass^5: 5次连续试验均通过
)
# 部署门控: results["all_passed"] 必须为 True
```

## 关键代码/配置片段

### SDK 最小集成示例

```python
from agentic_evaluation import run_all_layers, TaskFnResult

def task_fn(case) -> TaskFnResult:
    # 替换为你的 Agent: Strands, AgentCore, LangChain, OpenAI, ...
    return {
        "output": "the answer",
        "trajectory": ["search", "answer"],
        "metadata": {"latency_ms": 420},  # 被 LatencyEvaluator 读取
    }

results = run_all_layers(task_fn=task_fn)
print("All passed:", results["all_passed"])
```

### CLI 方式

```bash
agentic-eval init --name my-agent --tools "search,answer"
agentic-eval validate --config eval_config.yaml
agentic-eval run --config eval_config.yaml --task-fn my_pkg.tasks:run
```

### 三层评估配置（概念性）

```yaml
# eval_config.yaml (概念结构)
evaluation_layers:
  - layer: tool_usage          # Layer 1: 确定性评分
    threshold: 0.95
    graders:
      - ToolSelectionGrader     # 检查调用了哪些工具
      - TrajectoryOrderGrader   # 检查调用顺序
  - layer: reasoning           # Layer 2: LLM-as-Judge
    threshold: 0.85
    evaluators:
      - HelpfulnessEvaluator
      - TrajectoryEvaluator
  - layer: output_quality      # Layer 3: LLM-as-Judge
    threshold: 0.90
    evaluators:
      - OutputEvaluator
      - GoalSuccessRateEvaluator
  - layer: domain              # 领域层: 延迟/成本/安全
    evaluators:
      - LatencyEvaluator
      - CustomEvaluator  # 数据新鲜度、经销商范围、安全护栏
```

### 多轮对话测试

```python
# ActorSimulator 生成逼真的多轮交互
simulator = ActorSimulator(agent=your_agent)
interactions = simulator.generate(
    num_turns=3,  # 模拟 3 轮对话
    scenarios=["refine_search", "change_constraints"]
)

# InteractionsEvaluator 评分跨轮上下文保持
evaluator = InteractionsEvaluator()
scores = evaluator.evaluate(interactions)
# 捕获: 上下文漂移、过滤累积错误、代词解析失败
```

## 对你的意义

这个方案的核心价值不在于 AWS 服务本身，而在于它提出了一套**可迁移的 Agent 评估方法论**：

1. **三层次框架是通用的**：工具使用 → 推理质量 → 输出质量，这套分层逻辑适用于任何 Agent 框架（LangChain、CrewAI、自研框架）。
2. **pass^k 指标值得借鉴**：如果你在用 pass@k 评估 Agent，现在应该改用 pass^k——尤其是面向用户的场景。
3. **生产数据反哺测试集**是最佳实践：Motorway 从 50 条增长到 150 条测试用例，每条都来自真实用户行为，而非人工臆造。

**建议**：如果你正在构建生产级 Agent（无论是否在 AWS 上），值得花 2-3 小时部署这个 SDK 的 no-AWS 快速入门版本（`quickstart/run_demo.py`），验证三层次框架是否适配你的工具集。即使最终不采用 AgentCore 生产监控，构建时评估部分也具有独立价值。

---
[← Back to Deep Dives](./README.md)
