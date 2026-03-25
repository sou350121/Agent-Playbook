---
auto_generated: true
generated_at: "2026-03-25T08:02:05Z"
source_url: "https://blog.langchain.com/polly-langsmith-ga/"
signal_type: "significant_update"
---
# LangSmith Polly 全面上线：Agent 调试的新范式 (LangSmith Polly GA: A New Paradigm for Agent Debugging)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-25
>
> **项目/工具**: LangSmith Polly
> **链接**: https://blog.langchain.com/polly-langsmith-ga/
> **核心定位**: 专为 Agent 调试设计的 AI 助手，能读取百步 trace、定位故障根因、并直接执行修复操作

## 快速判断

- **一句話定位**: LangSmith Polly 从实验性功能升级为全平台 GA，成为能「看懂 trace + 动手修复」的 AI 调试伙伴
- **現在值得用嗎**: 是 — 如果你在用 LangSmith 追踪 Agent，Polly 能显著减少调试时间
- **適合場景**: 百步以上复杂 trace 调试、多实验对比决策、评估器编写、用户对话线程分析
- **不適合場景**: 简单单步调用调试、无需 LangSmith 的轻量项目
- **與前版核心差異**: 从「特定页面的问答助手」升级为「全平台持久上下文 + 可执行操作」的工程伙伴

## 是什么 / 解决什么问题

Agent 调试与传统软件调试有本质不同：一次调用可能产生数百步的 trace（LLM 调用、工具执行、条件分支），prompt 可能跨越数千行，当故障发生时，导致问题的上下文往往埋在中间某个不起眼的节点。

传统调试方式要求工程师手动扫描整个 trace、对比多个实验结果、逐行阅读对话线程 — 这是高度重复且容易遗漏关键信息的工作。

LangSmith Polly 的定位是「能读懂 300 步 trace、发现故障点、并告诉你具体发生了什么」的 AI 助手。2026 年 3 月 18 日，LangChain 宣布 Polly 全面上线（General Availability），从原本仅在 trace 页面、thread 视图和 playground 可用的实验性功能，扩展为覆盖 LangSmith 所有工作流的全平台助手。

这次 GA 的核心变化不是「多了一个聊天机器人」，而是重新定义了 Agent 调试的人机协作范式：Polly 不再只是回答问题，而是能直接执行修复操作（更新 prompt、创建数据集、编写评估器代码、对比实验），并且在整个调试会话中保持上下文记忆。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 理由 |
|----------|------|
| **全平台嵌入** (右下角悬浮) | 调试工作流跨越多个页面（trace → experiment → dataset → prompt），Polly 需要跟随工程师移动而非固定在单一视图 |
| **持久化会话记忆** | 工程师在调试过程中频繁切换视图，Polly 记住上下文避免重复解释，减少认知摩擦 |
| **操作型 AI 而非问答型** | 单纯「解释问题」价值有限，直接「执行修复」（写代码、改 prompt、建数据集）才能形成闭环 |
| **快捷键触发** (Cmd/Ctrl+I) | 调试是高频操作，需要秒级访问而非菜单导航 |
| **Workspace Secret 管理 API Key** | 安全隔离，用户自行控制模型提供商凭证，LangChain 不接触敏感信息 |

### 与前版/竞品的关键差异

| 维度 | 前版 Polly (实验性) | 当前 Polly (GA) | 竞品 (传统日志/人工调试) |
|------|-------------------|----------------|------------------------|
| **覆盖范围** | 仅 trace/thread/playground 3 个页面 | 全部 8+ 工作流页面 (traces, runs, threads, experiments, datasets, annotation queues, evaluators, playground) | 单页面日志查看 |
| **上下文记忆** | 无，每次打开是新会话 | 跨导航持久记忆，切换页面后仍知之前工作内容 | 完全依赖人工记忆 |
| **操作能力** | 仅问答 | 可执行 5+ 操作：更新 prompt、从失败 runs 创建数据集、过滤项目视图、编写评估器代码、对比实验 | 仅查看，修改需手动 |
| **线程分析** | 不支持 | 可分析多轮对话的用户情绪、问题是否解决、主题识别 | 需人工逐条阅读 |
| **评估器辅助** | 不支持 | 可生成/改进评估器代码，解释检查逻辑，迭代优化 | 完全手写 |
| **实验对比** | 基础对比 | 基于数据给出推荐决策，直接指出哪个 prompt/模型/架构更有效 | 人工解析每个结果 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                      LangSmith Platform                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Traces    │  │ Experiments │  │   Datasets / Evals      │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
│         │                │                      │                │
│         └────────────────┼──────────────────────┘                │
│                          │                                       │
│                          ▼                                       │
│              ┌───────────────────────┐                           │
│              │   Polly (Persistent   │                           │
│              │    Context Engine)    │                           │
│              └───────────┬───────────┘                           │
│                          │                                       │
│    ┌─────────────────────┼─────────────────────┐                 │
│    │                     │                     │                 │
│    ▼                     ▼                     ▼                 │
│ ┌──────────┐      ┌──────────┐         ┌──────────────┐         │
│ │ Q&A      │      │ Analysis │         │ Actions      │         │
│ │ 解释 trace│      │ 情绪/主题│         │ 写代码/改 prompt│         │
│ │ 定位故障  │      │ 对比推荐 │         │ 创建数据集   │         │
│ └──────────┘      └──────────┘         └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  User's Model Provider API    │
              │  (configured as Workspace     │
              │   Secret, not stored by LC)   │
              └───────────────────────────────┘
```

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| **复杂 Agent 调试** (100+ 步 trace) | 人工扫描耗时且易遗漏，Polly 可快速定位故障节点并解释因果链 |
| **多实验 A/B 测试决策** | Polly 基于数据给出推荐，避免人工解析数百条结果的主观偏差 |
| **评估器开发迭代** | 自动生成初始代码 + 解释逻辑 + 迭代优化，减少样板工作 |
| **用户对话质量分析** | 批量分析 thread 中的用户情绪、问题解决率、主题分布，无需逐条阅读 |
| **从失败案例构建测试集** | 一键从 failing runs 创建数据集，加速回归测试覆盖 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| **简单单步调用调试** | trace 仅 2-3 步，人工查看更快，Polly  overhead 不划算 |
| **未使用 LangSmith 的项目** | Polly 是 LangSmith 内置功能，需先接入 LangSmith 追踪 |
| **对数据隐私极度敏感** | 虽然 API Key 由用户自控，但 trace 数据需上传至 LangSmith 云端 |
| **预算有限的个人项目** | LangSmith 付费 tier 可能超出个人项目预算（Polly 需 workspace 配置模型 API） |

### 迁移成本

| 起点 | 迁移到 Polly 的工作量 |
|------|---------------------|
| **已在用 LangSmith (无 Polly)** | 约 2 分钟：在 workspace secrets 添加模型提供商 API Key，Cmd+I 即可使用 |
| **在用其他观测工具 (Arize Phoenix/Weights & Biases)** | 中等：需接入 LangSmith SDK，修改 tracing 代码，约 1-2 小时 |
| **无观测工具 (纯日志调试)** | 较高：需学习 LangSmith 数据模型、接入 SDK、配置项目，约半天到一天 |

## 对你的意义

如果你正在开发或维护基于 LangChain/LangGraph 的 Agent 系统，Polly GA 是一个值得立即试用的升级：

**立即行动的理由**:
1. **调试效率提升**: 对于复杂 Agent，调试时间可能从小时级降至分钟级
2. **评估器开发加速**: 自动生成 + 迭代优化，减少手写样板代码
3. **数据驱动决策**: 实验对比不再依赖直觉，Polly 基于实际数据给出推荐

**建议步骤**:
1. 如果已有 LangSmith 项目，直接进入任意页面按 Cmd+I 激活 Polly
2. 在 workspace secrets 配置你的模型提供商 API Key（OpenAI/Anthropic 等）
3. 选择一个历史复杂 trace，尝试问 Polly「这个调用为什么失败了？」
4. 在评估器页面，让 Polly 帮你写一个检测幻觉的评估器

**观望的理由**:
- 如果你的 Agent 逻辑简单（<10 步 trace），Polly 的价值有限
- 如果团队已有成熟的调试流程且效率满意，可等待更明确的 ROI 信号

## 关键代码/配置片段

### 配置 Polly API Key (Workspace Secrets)

在 LangSmith 界面：
```
Settings → Workspace → Secrets → Add Secret
Key: <your_provider_api_key>
Value: sk-...
```

然后在任意页面按 `Cmd+I` (Mac) 或 `Ctrl+I` (Windows/Linux) 激活 Polly。

### Polly 可执行操作示例

**1. 从失败 runs 创建数据集**:
```
用户: "Create a dataset from the failing runs in this experiment"
Polly: [自动筛选失败案例 → 创建数据集 → 返回数据集链接]
```

**2. 编写评估器代码**:
```
用户: "Write an evaluator that checks for hallucinations"
Polly: 
```python
from langsmith import evaluate

def hallucination_evaluator(run, example):
    # Check if response contains unsupported claims
    response = run.outputs.get("response", "")
    context = example.inputs.get("context", "")
    
    # Logic to detect claims not grounded in context
    # ...
    return {"score": 0.85, "reason": "Minor unsupported claim detected"}
```
```

**3. 对比实验并给出推荐**:
```
用户: "Which experiment performed better, A or B?"
Polly: "Experiment B outperformed A by 12% on accuracy metric. 
        The key difference is the prompt template in B includes 
        explicit chain-of-thought instructions. Recommend adopting B."
```

### 线程分析查询示例

```
用户: "Did the user seem frustrated in this thread?"
Polly: "Yes, frustration signals detected at turns 7 and 12. 
        User repeated the same question twice and used phrases 
        like 'this isn't working' and 'I've tried this already'."

用户: "Was the user's problem solved?"
Polly: "Partially. The initial issue was resolved at turn 15, 
        but a new issue emerged at turn 18 regarding X."
```

---

[← Back to Deep Dives](./README.md)
