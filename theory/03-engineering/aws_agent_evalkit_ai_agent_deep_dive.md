---
auto_generated: true
generated_at: "2026-06-16T06:47:41Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/evaluate-ai-agents-systematically-with-agent-evalkit/"
signal_type: "significant_update"
---
# AWS 开源 Agent-EvalKit：让 AI Agent 评估嵌入开发工作流 (AWS Open-Sources Agent-EvalKit: Systematic Agent Evaluation in Your Dev Environment)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-16
>
> **项目/工具**: Agent-EvalKit
> **链接**: https://aws.amazon.com/blogs/machine-learning/evaluate-ai-agents-systematically-with-agent-evalkit/
> **核心定位**: 一个 Apache 2.0 开源的 AI Agent 评估工具包，通过 AI 编程助手的 slash 命令将六阶段评估流程嵌入开发环境，用自然语言驱动从测试生成到代码级改进建议的完整闭环。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Agent-EvalKit 是一个开源工具包，让 AI 编程助手（Claude Code / Kiro CLI / Kilo Code）自动完成 Agent 的评估全流程——从读代码、生成测试用例、采集执行轨迹，到输出带代码引用的改进建议。
- **現在值得用嗎**：是。如果你在用 Strands / LangGraph / CrewAI 构建 Agent，且尚未建立系统化的评估流程，这是目前最完整的"开箱即用"方案。
- **適合場景**：多工具 Agent 的 faithfulness 评估、工具调用准确性验证、幻觉检测、CI/CD 集成前的质量基线建立
- **不適合場景**：纯 LLM 聊天应用（非 Agent）、需要实时在线评估的生产环境（需配合 Bedrock AgentCore）、非 Python Agent 框架
- **與傳統評估工具核心差異**：传统工具（如 DeepEval standalone）需要你手动写测试用例和评估代码；Agent-EvalKit 让 AI 助手自动读你的 Agent 代码、自动生成测试、自动写评估逻辑、自动出报告——你只需要用自然语言描述关注的质量维度。

## 是什么 / 解决什么问题

AI Agent 的评估是一个比传统软件测试困难得多的问题。传统测试检查输出是否匹配预期，但 Agent 会自主选择工具、编排操作序列、在多个数据源之间跳转。一个 Agent 可能给出了结构良好、看似可操作的答案，同时在底层幻觉——它的工具返回了空结果，但它编造了汇率、温度、景点信息。另一个 Agent 可能得出了正确结论，但跳过了关键的验证步骤。这些失败藏在最终响应的表面之下，仅靠输出级测试无法捕获。

Agent-EvalKit 解决的核心问题是：**让评估不再是部署后的独立环节，而是嵌入开发工作流的一部分。** 它通过与 Claude Code、Kiro CLI、Kilo Code 等 AI 编程助手集成，让你用 slash 命令（如 `/evalkit.plan`、`/evalkit.data`）驱动整个评估流程。你只需要用自然语言描述你关心的质量维度，工具包自动完成代码分析、测试生成、轨迹采集、指标评估、报告输出的六阶段流水线。

这不是一个独立的评估平台——它是你已有 AI 编程助手的扩展能力。同一个帮你构建 Agent 的助手，也帮你评估它。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| 嵌入 AI 编程助手而非独立平台 | 评估与开发在同一环境，减少上下文切换；利用助手已有的代码理解能力 |
| 六阶段流水线（Plan → Data → Trace → Run → Eval → Report） | 每个阶段产出物作为下一阶段输入，支持独立重跑和增量迭代 |
| 自然语言驱动 | 开发者用自然语言描述关注的质量维度，AI 助手将其翻译为具体的评估代码和测试用例 |
| 双轨评估（Code-based + LLM-as-Judge） | 代码评估器快速可复现，LLM 评估器提供 nuanced 判断，组合使用覆盖不同维度 |
| 报告带代码引用 | 评估结论直接指向具体代码位置，而非仅输出分数仪表盘 |
| Apache 2.0 开源 | 降低采用门槛，鼓励社区贡献评估方法和框架支持 |

### 六阶段流水线

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Phase 1    │────▶│  Phase 2    │────▶│  Phase 3    │
│  Plan       │     │  Data       │     │  Trace      │
│ 评估计划    │     │ 测试生成    │     │ 轨迹注入    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│  Phase 6    │◀────│  Phase 5    │◀────│  Phase 4    │
│  Report     │     │  Eval       │     │  Run Agent  │
│ 改进报告    │     │ 指标评估    │     │ 执行采集    │
└─────────────┘     └─────────────┘     └─────────────┘
```

**Phase 1 — Plan (`/evalkit.plan`)**：读取 Agent 源码（工具定义、system prompt、框架配置），构建对 Agent 能力的理解，产出评估计划——将每个质量维度映射到具体的评估方法。

**Phase 2 — Data (`/evalkit.data`)**：基于评估计划生成测试用例，每个用例包含输入和预期结果。支持导入生产日志或手动测试数据。

**Phase 3 — Trace (`/evalkit.trace`)**：为 Agent 添加 OpenTelemetry 兼容的追踪注入。对 Strands、LangGraph、CrewAI 等框架自动检测并应用对应 instrumentation。

**Phase 4 — Run Agent (`/evalkit.run_agent`)**：对每个测试用例执行 Agent，产出结构化 trace 文件，记录完整的工具调用历史、模型响应和中间状态。

**Phase 5 — Eval (`/evalkit.eval`)**：将评估计划中的指标实现为可执行评估代码，对采集的 trace 运行评估。支持 DeepEval 和 Strands Evals SDK。

**Phase 6 — Report (`/evalkit.report`)**：分析跨测试用例的模式，生成带优先级的改进建议，每个建议引用 Agent 代码中的具体位置，并附带预期影响评估。

### 与竞品/前版的关键差异

| 维度 | DeepEval (standalone) | RAGAS | Agent-EvalKit |
|------|----------------------|-------|---------------|
| 测试用例生成 | 手动编写 | 手动编写 | AI 自动生成（基于 Agent 代码分析） |
| 评估代码编写 | 手动编写 | 手动编写 | AI 自动生成 |
| 轨迹采集 | 需自行集成 | 不支持 | 内置 OTel 注入，自动采集 |
| 报告输出 | 分数仪表盘 | 分数仪表盘 | 带代码引用的改进建议 |
| 集成方式 | Python 库 | Python 库 | AI 编程助手 slash 命令 |
| 支持的 Agent 框架 | 通用 | RAG 专用 | Strands / LangGraph / CrewAI |
| 迭代方式 | 修改代码后重跑 | 修改代码后重跑 | 可单独重跑任一阶段，复用已有产物 |

## 实用评估

### 什么场景值得用

- **多工具 Agent 的 faithfulness 验证**：Agent-EvalKit 的 demo study 中，一个旅行研究 Agent 的 Response Quality 得分 83.9%（看起来不错），但 Faithfulness 仅 32.3%——当 web search 工具返回空结果时，Agent 会编造汇率、温度和景点信息。这种"表面好但底层幻觉"的问题，传统输出级测试很难发现。
- **工具调用准确性评估**：Demo 中 Tool Parameter Accuracy 仅 64.5%，说明 Agent 虽然选对了工具，但经常传入不精确的参数。这类问题直接影响 Agent 的可靠性。
- **CI/CD 质量门禁**：每次有意义的代码变更后运行评估，捕获回归、衡量改进影响。六阶段流水线支持增量迭代——第一次评估聚焦 faithfulness，后续可单独重跑 eval 阶段深化 tool accuracy 分析，无需重新生成数据或重新注入追踪。
- **新团队成员上手**：`/evalkit.quick` 引导式流程让不熟悉评估方法的开发者也能快速建立基线。

### 什么场景不值得用

- **纯 LLM 聊天应用**：如果你的应用不涉及工具调用、多步推理、跨数据源操作，Agent-EvalKit 的六阶段流水线是过度设计。DeepEval 或 RAGAS 更轻量。
- **非 Python Agent 框架**：目前仅支持 Python 生态的 Strands、LangGraph、CrewAI。TypeScript/Go Agent 暂不支持。
- **生产环境实时监控**：Agent-EvalKit 是开发期工具。生产环境持续监控需要配合 Amazon Bedrock AgentCore Observability + AgentCore Evaluation。
- **需要 LLM-as-Judge 但无 Bedrock 访问**：评估需要 LLM-as-judge 指标，依赖 Amazon Bedrock 的基础模型。无 AWS 账户无法使用核心评估能力。

### 迁移成本

从手动评估流程迁移到 Agent-EvalKit：

| 步骤 | 工作量 |
|------|--------|
| 安装与环境配置 | ~15 分钟（uv tool install + evalkit init） |
| 将 Agent 代码复制到评估项目 | ~5 分钟 |
| 运行 `/evalkit.quick` 首次评估 | ~30 分钟（含 AI 助手分析 + 测试生成 + 执行） |
| 审查和调整评估结果 | 1-2 小时（首次需要人工验证 AI 生成的测试和评估代码） |
| 集成到 CI/CD | ~2 小时（编写脚本自动化六阶段流程） |

**总计**：首次上手约 3-4 小时，后续每次评估运行约 15-30 分钟（取决于 Agent 复杂度和测试用例数量）。

## 对你的意义

Agent 评估是当前 AI Agent 工程中最被低估的环节之一。Ken 在构建 Agent-Playbook 中涉及的 Agent 框架和工具链时，评估能力是区分"玩具"和"生产级"的关键分水岭。

**具体建议**：
- **如果 Ken 的团队正在用 Strands/LangGraph 构建生产级 Agent**：立即试用 Agent-EvalKit，建立 faithfulness 和 tool accuracy 的基线。Demo 中 32.3% 的 faithfulness 分数说明即使"看起来好用"的 Agent 也可能存在严重的底层幻觉问题。
- **如果 Ken 在做 Agent 相关的研究或内容创作**：Agent-EvalKit 的"AI 助手评估 AI 助手"范式本身就是一个值得记录的设计模式——它把评估从"写测试代码"变成了"描述关注点"，降低了评估的门槛。
- **观望项**：目前仅支持 Python 生态和 AWS Bedrock。如果团队技术栈不同，需要关注社区是否扩展其他框架和模型提供商的支持。

## 关键代码/配置片段

### 安装与初始化

```bash
# 安装
uv tool install evalkit --from git+https://github.com/awslabs/Agent-EvalKit.git

# 初始化评估项目
evalkit init my-agent-evaluation
cd my-agent-evaluation
cp -r /path/to/your/agent .

# 启动 AI 助手
claude
```

### 六阶段评估流程

```bash
# 方式 A：引导式（推荐首次使用）
/evalkit.quick Evaluate my agent at ./my_agent for response quality and tool accuracy

# 方式 B：分阶段控制
/evalkit.plan Evaluate my agent at ./my_agent for response quality and tool accuracy
/evalkit.data                        # 生成测试用例
/evalkit.trace                       # 注入 OpenTelemetry 追踪
/evalkit.run_agent                   # 执行 Agent 采集 trace
/evalkit.eval                        # 运行评估代码
/evalkit.report                      # 生成改进报告
```

### Demo 评估结果（旅行研究 Agent）

```
Response Quality:        83.9%  ✅ 输出清晰可用
Tool Parameter Accuracy:  64.5%  ⚠️ 工具选择正确但参数不精确
Faithfulness:             32.3%  ❌ 工具返回空结果时编造数据
```

核心发现：当 web search 工具返回空或不完整结果时，Agent 会编造汇率、温度、景点信息，并将其呈现为工具返回的数据。最高优先级修复建议：在 system prompt 中加入工具空结果的披露指令，改进所有代码路径中的工具错误处理。

---
[← Back to Deep Dives](./README.md)
