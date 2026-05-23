---
auto_generated: true
generated_at: "2026-05-23T05:47:53Z"
source_url: "https://huggingface.co/blog/ibm-research/open-agent-leaderboard"
signal_type: "significant_update"
---
# IBM 发布 Open Agent Leaderboard：首个面向完整 Agent 系统的开放基准 (IBM Open Agent Leaderboard: Evaluating Full Agent Systems, Not Just Models)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-23
>
> **项目/工具**: Open Agent Leaderboard + Exgentic Framework
> **链接**: https://huggingface.co/blog/ibm-research/open-agent-leaderboard
> **核心定位**: 业界首个同时报告质量与成本的开放 Agent 系统评估基准，将评估焦点从「模型能力」推向「系统能力」

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：IBM 联合 HuggingFace 推出的 Open Agent Leaderboard 是首个评估**完整 Agent 系统**（而非单模型）的开放基准，同时报告 success rate 和 cost per task。配套开源框架 Exgentic 允许任何人复现和提交结果。
- **現在值得用嗎**：是——如果你是 Agent 开发者或研究者，这是目前最全面的跨域对比基准；如果你只是选型模型，它提供了模型+框架组合视角。
- **適合場景**：Agent 系统横向对比、Agent 架构组件消融分析、跨域通用性评估、成本-质量权衡决策
- **不適合場景**：单模型 benchmark 对比（应继续用 MMLU/HumanEval 等）、垂直领域定制评估（benchmark 偏向通用场景）
- **與傳統 Leaderboard 核心差異**：传统基准测「模型」，这个测「模型+Agent 架构+工具+记忆+错误恢复」的完整系统

## 是什么 / 解决什么问题

当前 AI 评估体系存在一个根本性错位：绝大多数 benchmark（MMLU、HumanEval、SWE-Bench 等）评估的是**模型**的裸能力，但部署时你选择的不是模型，而是**完整的 Agent 系统**——包括规划策略、工具集、记忆机制、错误恢复逻辑。同一个模型搭配不同 Agent 架构，结果可能天差地别。

IBM Research 的 Open Agent Leaderboard 填补了这个空白。它将评估对象从模型提升到系统层面，用 6 个跨域 benchmark 测试 Agent 的通用性（generality），同时报告质量和成本两个维度。配套开源的 Exgentic 框架提供了标准化的评估编排层，让任何人可以复现结果或提交自己的 Agent。

这标志着 Agent 评估从「学术 benchmark 跑分」向「工程部署决策」的重要转变。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|----------|------|
| **评估对象 = 完整 Agent 系统** | 部署时选择的是系统而非模型；同一模型不同架构差异显著 |
| **统一协议（Task/Context/Actions）** | 6 个 benchmark 各有自己的交互范式，统一协议让不同 Agent 可以用原生接口接入 |
| **同时报告质量 + 成本** | 只看不看成本的基准在工程上无意义——一个 90% 成功率但成本 10 倍的系统不值得部署 |
| **不做 benchmark-specific tuning** | 所有 Agent 以通用配置测试，反映真实部署场景而非调参后的极限值 |
| **全开源（Leaderboard + 框架 + 数据）** | 评估标准必须透明可复现，否则无法成为社区标准 |

### 评估基准矩阵

| Benchmark | 任务类型 | 测试能力 |
|-----------|----------|----------|
| SWE-Bench Verified | 软件工程 | 真实代码仓库中的 bug 修复 |
| BrowseComp+ | 开放域研究 | 跨网站复杂信息检索 |
| AppWorld | 多应用交互 | 数百个 app API 的任务完成 |
| tau2-Bench Airline & Retail | 客服 | 遵循公司策略的对话式任务 |
| tau2-Bench Telecom | 技术支持 | 遵循公司策略的技术问题处理 |

### 架构 / 信息流图

```
┌─────────────────────────────────────────────────┐
│              Open Agent Leaderboard              │
│                                                  │
│  ┌──────────┐    ┌──────────────┐    ┌────────┐ │
│  │  Agent A  │    │   Agent B    │    │Agent C │ │
│  │(same model│    │ (same model  │    │(diff    │ │
│  │ diff arch)│    │  diff arch)  │    │ model) │ │
│  └────┬─────┘    └──────┬───────┘    └───┬────┘ │
│       │                 │                 │      │
│       ▼                 ▼                 ▼      │
│  ┌──────────────────────────────────────────┐   │
│  │         Exgentic Unified Protocol         │   │
│  │  Task (what to do) + Context (what to    │   │
│  │  know) + Actions (what's allowed)        │   │
│  └──────────────────┬───────────────────────┘   │
│                     │                           │
│        ┌────────────┼────────────┐              │
│        ▼            ▼            ▼              │
│   ┌────────┐  ┌─────────┐  ┌────────┐          │
│   │SWE-Bench│  │BrowseComp│  │ tau2   │          │
│   │Verified │  │   +     │  │Bench   │          │
│   └────────┘  └─────────┘  └────────┘          │
│        │            │            │              │
│        ▼            ▼            ▼              │
│   ┌──────────────────────────────────────┐      │
│   │  Results: Success Rate + Cost/Task   │      │
│   └──────────────────────────────────────┘      │
└─────────────────────────────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | 传统 Model Leaderboard | Open Agent Leaderboard |
|------|----------------------|----------------------|
| 评估对象 | 模型（prompt → output） | 完整 Agent 系统（模型+架构+工具+记忆） |
| 跨域覆盖 | 通常单域（代码/数学/常识） | 6 个跨域 benchmark（代码/研究/客服/技术支持） |
| 成本报告 | ❌ 不报告 | ✅ 每任务成本 |
| 通用性测试 | 间接（通过多 benchmark 平均） | 直接（同一 Agent 跨所有 benchmark 无调参） |
| 复现性 | 通常不可复现 | Exgentic 开源，CLI 一行命令复现 |
| 提交方式 | 需厂商配合 | 开源 PR 提交到 results dataset |

## 实用评估

### 什么场景值得用

- **Agent 系统选型**：需要对比不同 Agent 框架（如 Claude Code vs OpenAI Codex vs Gemini CLI）在通用任务上的表现和成本。Leaderboard 直接给出质量-成本散点图，一目了然。
- **架构组件消融**：Exgentic 允许替换 Agent 内部组件（memory、planning、tool shortlisting），可以量化每个组件对最终结果的贡献。论文发现 tool shortlisting 在**每个测试模型**上都提升了性能。
- **开放模型评估**：DeepSeek V3.2 和 Kimi K2.5 已上榜，显示开放模型在特定组合上有竞争力，但平均落后前沿闭源模型 18-29 个百分点。适合评估开放模型的部署可行性。
- **成本优化决策**：失败运行的成本比成功运行高 20-54%。对于生产环境，理解 Agent 的失败行为模式与理解成功率同等重要。

### 什么场景不值得用

- **单模型能力对比**：如果你只关心「GPT-5 vs Claude 4 谁更强」，传统 benchmark 更直接。这个 Leaderboard 的分数会因 Agent 架构不同而与单模型分数有差异。
- **垂直领域评估**：6 个 benchmark 覆盖通用场景，但不覆盖医疗、法律、金融等垂直领域。需要自行扩展 benchmark。
- **最新模型评估**：Leaderboard 上的模型有滞后性（目前 5 个模型/5 个 Agent），最新发布的模型需要自行用 Exgentic 评估并提交。

### 迁移成本

从传统 benchmark 评估迁移到 Exgentic：

```
# 安装（uv 或 pip）
uv tool install exgentic

# 列出可用 benchmark 和 agent
exgentic list benchmarks
exgentic list agents

# 运行评估（一行命令）
exgentic evaluate --benchmark tau2 --agent tool_calling --subset retail --num-tasks 10 \
  --model gpt-4o \
  --set benchmark.user_simulator_model="gpt-4o"
```

- **基础设施**：需要 Docker（可选，用于隔离）或本地 Python 环境
- **API Key**：仅需对应模型的 API Key（OpenAI/Anthropic）
- **自定义 Agent 接入**：需适配 Exgentic 协议，工作量取决于 Agent 复杂度，预计 1-3 天
- **学习曲线**：CLI 设计简洁，文档完整，入门成本低

## 对你的意义

这个发布对 Ken 的双线工作都有直接价值：

**AI 应用线**：Exgentic 是目前最成熟的 Agent 评估开源框架。如果你的 Agent UI 工具链需要集成评估能力，Exgentic 的协议设计和输出结构（trajectory.jsonl、otel 追踪、成本报告）是很好的参考。tool calling agent 已通过 LiteLLM 接入，与你关注的 Agent UI 方向直接相关。

**VLA 研究线**：虽然 Open Agent Leaderboard 聚焦软件/客服领域而非机器人，但「系统 vs 模型」的评估范式迁移到 VLA 领域同样成立——VLA 的规划模块、记忆机制、工具调用策略对最终任务成功率的影响，可能不亚于模型本身的选择。这个思路值得在 VLA 评估中借鉴。

**建议**：立即关注 Exgentic 的 GitHub 仓库（star/watch），它的协议设计可能成为 Agent 评估的事实标准。如果团队有自研 Agent，可以用 Exgentic 做一次基线评估。

## 关键发现（来自论文数据）

| 发现 | 数据支撑 | 含义 |
|------|----------|------|
| 通用 Agent 已可匹敌专用 Agent | 多个 benchmark 上通用 Agent 匹配或超越专用系统 | Agent 架构成熟度超出预期 |
| 同一模型不同 Agent 差异显著 | Top 3 使用同一模型，但分数和成本不同 | Agent 架构设计是独立变量 |
| 失败比成功更贵 | 失败运行成本比成功运行高 20-54% | 成本优化需关注失败模式 |
| Tool shortlisting 普适有效 | 在所有测试模型上均提升性能 | 工具过滤是 Agent 架构的关键组件 |
| 开放模型差距明显 | 落后前沿闭源 18-29 个百分点 | 开放模型需架构补偿 |

## 关键代码/配置片段

### Exgentic Python API 调用

```python
from exgentic import evaluate

results = evaluate(
    benchmark="tau2",
    agent="tool_calling",
    subset="retail",
    num_tasks=2,
    model="gpt-4o",
    benchmark_kwargs={"user_simulator_model": "gpt-4o"},
)
```

### Docker 隔离运行

```bash
exgentic evaluate --benchmark tau2 --agent tool_calling --subset retail --num-tasks 2 \
  --model gpt-4o \
  --set benchmark.runner=docker \
  --set benchmark.user_simulator_model="gpt-4o"
```

### 输出结构（每 run 自动生成）

```
outputs/<run_id>/
├── results.json          # 总体分数、成本、per-session 统计
├── benchmark_results.json # benchmark 级聚合结果
└── sessions/<id>/
    ├── trajectory.jsonl   # 每步 action + observation
    ├── results.json       # session 结果
    └── agent/agent.log    # Agent 执行日志
```

---
[← Back to Deep Dives](./README.md)
