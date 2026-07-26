---
auto_generated: true
generated_at: "2026-07-26T06:47:48Z"
source_url: "https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-6-flash-3-5-flash-lite-3-5-flash-cyber/"
signal_type: "significant_update"
---
# Gemini 3.6 Flash、3.5 Flash-Lite 与 3.5 Flash Cyber 三代同发 (Introducing Gemini 3.6 Flash, 3.5 Flash-Lite, and 3.5 Flash Cyber)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-26
>
> **项目/工具**: Google Gemini 模型系列
> **链接**: https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-3-6-flash-3-5-flash-lite-3-5-flash-cyber/
> **核心定位**: Google 一次性发布三款 Flash 系列模型，分别面向"效率优先的 Agent 主力"、"极致吞吐的轻量场景"和"网络安全专精"，核心叙事是：用更少的 token 和更低的延迟完成同样的 Agent 工作流。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 三代 Flash 模型同时发布——3.6 Flash 是新的主力 Agent 模型（输出 token 减少 17%、DeepSWE 精度 49%），3.5 Flash-Lite 是极速轻量模型（350 tokens/s），3.5 Flash Cyber 是安全专精模型（仅通过 CodeMender 向政府/可信伙伴开放）。
- **现在值得用吗**: 是——如果你在用 Gemini API 构建 Agent 工作流，3.6 Flash 几乎在所有维度优于 3.5 Flash 且更便宜，直接升级即可。
- **适合场景**: 多步 Agent 工作流、代码生成/修复、文档解析与数据分析、高吞吐批量处理（Flash-Lite）。
- **不适合场景**: 需要最强推理能力的复杂研究任务（应等 Gemini 3.5 Pro）；通用网络安全扫描（3.5 Flash Cyber 仅限量开放）。
- **与 3.5 Flash 核心差异**: 更少输出 token（-17%）、更低价格（输入 -33%）、更高精度（DeepSWE +12pp、MLE Bench +14.2pp）。

## 是什么 / 解决什么问题

Google 在 2026-07-21 一次性发布了三款 Gemini Flash 系列新模型。这并非简单的版本迭代，而是针对 Agent 工作流不同层级的**精细化分工**：

1. **3.6 Flash** 定位"工作马"——在编码、知识工作和多模态能力上全面超越 3.5 Flash，同时输出 token 减少 17%，定价更低。
2. **3.5 Flash-Lite** 定位"极速通道"——350 输出 tokens/s 的吞吐能力，面向高并发、低延迟的批量任务。
3. **3.5 Flash Cyber** 定位"安全专精"——基于 3.5 Flash 微调，专门用于漏洞发现与修复，但仅通过 CodeMender 向政府和可信伙伴限量开放。

核心痛点：生产级 AI Agent 需要**可预测的 token 消耗**和**可控的延迟**。之前的 Flash 模型在 Agent 场景中输出过于冗长，导致 token 成本不可控、执行时间不可控。3.6 Flash 通过减少不必要的输出 token 和推理步骤，直接回应了这个痛点。

## 技术架构拆解

### 核心设计决策

- **Token 效率优先于绝对能力**: 3.6 Flash 不是"更大"的模型，而是"更精简"的模型。通过减少输出 token 17%（Artificial Analysis Index），在同样预算下可以跑更多 Agent 轮次。
- **分层定价策略**: 三个模型形成清晰的价格梯度——3.6 Flash（$1.50/$7.50 per 1M）→ 3.5 Flash-Lite（$0.30/$2.50 per 1M）→ 3.5 Flash Cyber（限量/未公开定价），让开发者根据任务复杂度选择。
- **Computer Use 内置化**: 3.6 Flash 和 3.5 Flash-Lite 都将 Computer Use 作为 Gemini API 的内置客户端工具，不再需要外部集成。
- **安全前置**: 3.6 Flash 内置 CBRN（化学、生物、放射、核）和网络攻击防御的前线安全框架，显著增强抗越狱能力。

### 与前版/竞品的关键差异

| 维度 | 3.5 Flash | 3.6 Flash | 3.5 Flash-Lite |
|------|-----------|-----------|----------------|
| 输出 token 效率 | 基线 | **-17%** | 未公布 |
| DeepSWE 精度 | 37% | **49%** (+12pp) | 未公布 |
| MLE Bench | 49.7% | **63.9%** (+14.2pp) | 未公布 |
| OSWorld-Verified | 78.4% | **83.0%** (+4.6pp) | 74.0% |
| GDPval-AA v2 | 1349 | **1421** (+72) | 1140 |
| 吞吐速度 | 未公布 | 未公布 | **350 tokens/s** |
| 输入定价 (`/1M) | `2.25* | **$1.50** (-33%) | **$0.30** (-87%) |
| 输出定价 (`/1M) | `10.00* | **$7.50** (-25%) | **$2.50** (-75%) |
| Computer Use | 需外部集成 | **内置** | **内置** |
| 安全加固 | 标准 | **CBRN + 网络攻击防御** | 标准 |

*3.5 Flash 定价为推测值，基于 3.6 Flash 降价幅度反推。

### 架构/信息流图

```
                    ┌─────────────────────────────────────┐
                    │       Gemini Flash 模型矩阵          │
                    └─────────────────────────────────────┘
                                      │
          ┌───────────────┬───────────┼───────────┬───────────────┐
          │               │           │           │               │
   ┌──────▼──────┐ ┌─────▼─────┐ ┌──▼───────┐ ┌──▼────────┐ ┌───▼──────┐
   │ 3.6 Flash   │ │3.5 Flash  │ │3.5 Flash │ │3.5 Flash  │ │ Gemini   │
   │ (主力)      │ │(上一代)   │ │-Lite     │ │-Cyber     │ │ 3.5 Pro  │
   │             │ │           │ │(极速)    │ │(安全专精) │ │ (测试中) │
   └─────┬───────┘ └─────┬─────┘ └──┬───────┘ └──┬────────┘ └───┬──────┘
         │               │          │            │              │
    Agent主力       逐步退役    高吞吐批量    CodeMender     最强推理
    编码/知识       (被3.6替代)  文档处理    (限量开放)     (待发布)
         │               │          │            │              │
    $1.50/$7.50     $2.25/$10   $0.30/$2.50   未公开        未公开
    17%更少token    基线       350tok/s     安全微调       最强能力
```

### 关键性能数据溯源

| Benchmark | 3.5 Flash | 3.6 Flash | 数据来源 |
|-----------|-----------|-----------|----------|
| DeepSWE (Datacurve) | 37% | 49% | Google Blog |
| MLE Bench | 49.7% | 63.9% | Google Blog |
| OSWorld-Verified | 78.4% | 83.0% | Google Blog |
| GDPval-AA v2 | 1349 | 1421 | Google Blog |
| 输出 token 减少 | 基线 | 17% | Artificial Analysis Index |

| Benchmark | 3.1 Flash-Lite | 3.5 Flash-Lite | 数据来源 |
|-----------|----------------|----------------|----------|
| Terminal-Bench 2.1 | 31% | 54% | Google Blog |
| GDM-MRCR v2 (长上下文) | 60.1% | 72.2% | Google Blog |
| GDPval-AA v2 | 642 | 1140 | Google Blog |
| SWE-Bench Pro | 49.6% (3 Flash) | 54.2% | Google Blog |
| OSWorld-Verified | 65.1% (3 Flash) | 74.0% | Google Blog |

## 实用评估

### 什么场景值得用

- **多步 Agent 工作流**: 3.6 Flash 减少推理步骤和 tool call 数量，直接降低 Agent 的 token 总消耗。对于需要 5-10 轮交互的 Agent 任务，17% 的 token 节省累积效果显著。
- **代码生成/修复 (SWE)**: DeepSWE 从 37% 提升到 49%，意味着 PR 级别的代码修复成功率大幅提升。适合 CI/CD 中的自动化代码审查和修复场景。
- **文档解析与数据分析**: Hebbia 和 Harvey 客户反馈 3.6 Flash 在多模态任务（文档解析、图表分析、报告起草）上表现突出。
- **高吞吐批量处理**: 3.5 Flash-Lite 的 350 tokens/s 吞吐 + $0.30/$2.50 的超低定价，适合日志分析、文档批量翻译、搜索索引构建等场景。
- **Computer Use Agent**: 内置 Computer Use 意味着不再需要额外的 UI 自动化框架集成，Agent 可以直接操作桌面/浏览器界面。

### 什么场景不值得用

- **需要最强推理的复杂研究**: 3.6 Flash 是 Flash 系列，不是 Pro 系列。Gemini 3.5 Pro 正在伙伴测试中，尚未发布。如果你的任务需要深度推理（数学证明、复杂架构设计），应等待 Pro 版本。
- **通用网络安全扫描**: 3.5 Flash Cyber 仅通过 CodeMender 向政府和可信伙伴限量开放，不对外提供 API 访问。
- **对延迟极度敏感的实时交互**: 虽然 3.5 Flash-Lite 吞吐高，但 3.6 Flash 的首 token 延迟数据未公布。如果需要毫秒级响应，需要自行 benchmark。
- **预算极度敏感但任务简单的场景**: 如果任务只是简单的文本分类或问答，Flash-Lite 已经足够，不需要 3.6 Flash 的能力。

### 迁移成本

- **从 3.5 Flash 迁移到 3.6 Flash**: API 接口完全兼容，只需修改模型名称（`gemini-3.5-flash` → `gemini-3.6-flash`）。由于输出 token 减少 17%，需要重新评估 token 预算和上下文窗口分配。预计迁移工作量：< 1 小时。
- **从旧版 Flash-Lite 迁移到 3.5 Flash-Lite**: 同样 API 兼容，模型名称变更即可。性能提升显著（Terminal-Bench 31%→54%），值得升级。
- **Computer Use 集成**: 如果之前使用外部 Computer Use 框架，可以切换到内置版本，但需要适配新的 API 调用方式。

## 对你的意义

这个发布对 AI 应用开发有两个直接信号：

1. **Agent 成本曲线继续下移**: 3.6 Flash 的定价（$1.50/$7.50）比 3.5 Flash 降低 25-33%，同时质量提升。如果你在用 Gemini API 构建 Agent，这直接意味着**同样预算可以跑更多 Agent 轮次**或**同样任务成本降低 25%**。对于生产环境 Agent 部署，这是一个不可忽视的经济性改进。

2. **Flash-Lite 正在蚕食旧版 Flash 的市场**: 3.5 Flash-Lite 在 SWE-Bench Pro 和 OSWorld 上甚至超越了 3 Flash。这意味着过去为了质量不得不选更大模型的场景，现在可以用更轻更快的模型替代。**"够用就好"的模型选择策略变得更加可行**。

**建议**: 如果你在用 Gemini API 构建 Agent 工作流，立即将主力模型切换到 3.6 Flash。对于高吞吐批量任务，评估 3.5 Flash-Lite 是否满足质量要求。

## 关键代码/配置片段

### 3.6 Flash API 调用示例（Gemini API）

```python
# 切换到 3.6 Flash — 只需修改模型名称
from google import genai

client = genai.Client()
response = client.models.generate_content(
    model="gemini-3.6-flash",  # 从 gemini-3.5-flash 切换
    contents="Explain the architecture of this codebase."
)
print(response.text)
```

### 3.5 Flash-Lite 高吞吐配置

```python
# Flash-Lite 可配置 thinking level 以平衡速度和质量
response = client.models.generate_content(
    model="gemini-3.5-flash-lite",
    contents="Process this batch of documents...",
    config=genai.types.GenerateContentConfig(
        thinking_config=genai.types.ThinkingConfig(
            thinking_budget=0  # 最小化推理，最大化吞吐
        )
    )
)
```

### Computer Use 内置调用

```python
# Computer Use 现在是内置工具，无需外部集成
response = client.models.generate_content(
    model="gemini-3.6-flash",
    contents="Take a screenshot and identify the error message.",
    config=genai.types.GenerateContentConfig(
        tools=[genai.types.Tool.computer_use()]  # 内置 Computer Use
    )
)
```

> 以上代码片段基于 Google Gemini API 标准接口模式编写，具体参数以[官方文档](https://ai.google.dev/gemini-api/docs/latest-model)为准。

---
[← Back to Deep Dives](./README.md)
