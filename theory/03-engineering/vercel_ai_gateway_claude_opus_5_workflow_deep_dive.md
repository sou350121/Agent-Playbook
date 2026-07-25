---
auto_generated: true
generated_at: "2026-07-25T05:48:23Z"
source_url: "https://vercel.com/changelog/claude-opus-5-now-available-on-ai-gateway"
signal_type: "blog_post"
---
# Vercel AI Gateway 上线 Claude Opus 5 + Workflow 延长执行 (Vercel AI Gateway: Claude Opus 5 + Extended Workflow Durations)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-25
>
> **项目/工具**: Vercel AI Gateway + Vercel Workflows
> **链接**: https://vercel.com/changelog/claude-opus-5-now-available-on-ai-gateway
> **核心定位**: Vercel 在同一天（2026-07-24）发布两项关键更新——AI Gateway 接入 Anthropic 最新旗舰 Claude Opus 5，同时 Workflows 步骤执行时长从 800 秒延长至 30 分钟。两者共同指向一个方向：让复杂 AI Agent 工作流在 Vercel 上跑得更快、更久、更稳。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Vercel AI Gateway 新增 Claude Opus 5 模型路由 + Workflows 步骤执行时长上限提升至 30 分钟，解决复杂 Agent 流程的模型能力瓶颈和超时问题
- **现在值得用吗**: 是——如果你已经在用 Vercel 部署 AI 应用，这两项更新零迁移成本即可启用
- **适合场景**: 多文件代码重构、长周期 Agent 任务、多 Agent 协作编排、需要模型冗余降级的高可用场景
- **不适合场景**: Hobby 计划用户（执行时长仍限制 5 分钟）、纯简单对话场景（Opus 5 成本显著高于 Sonnet）
- **与之前核心差异**: Opus 5 是首个在 AI Gateway 上原生支持 reasoning effort 精细控制的模型；Workflow 执行时长从 800s → 1800s，覆盖绝大多数 Agent 任务边界

## 是什么 / 解决什么问题

Vercel 在 2026-07-24 同日发布两项更新，分别解决 AI 应用开发的两个核心痛点：

**痛点 1 — 模型能力与接入成本**。Claude Opus 系列一直是 Anthropic 最强的旗舰模型，但开发者需要通过多个渠道分别接入，缺乏统一的 fallback 和监控。Vercel AI Gateway 将 Opus 5 纳入统一路由层，支持 BYOK（自带密钥）、供应商定价零加价、高并发限流和自动故障切换。

**痛点 2 — Agent 工作流超时**。复杂的多步 Agent 任务（如多文件重构、端到端功能开发）往往需要数分钟甚至更长时间，而 Vercel Functions 默认超时限制（Hobby 5 分钟 / Pro 800 秒）成为硬性瓶颈。Workflows 现在支持最长 30 分钟的步骤执行，配合 Fluid Compute 和扩展函数时长 Beta，覆盖了绝大多数 Agent 任务的执行边界。

这两项更新的协同效应值得注意：Opus 5 擅长"复杂任务完成"，而 Workflow 延长执行确保这些复杂任务不会因为超时被中断——它们是同一枚硬币的两面。

## 技术架构拆解

### 核心设计决策

**Opus 5 接入 AI Gateway**:
- **统一路由层**: 一个 API 端点路由到所有模型，Opus 5 通过 `anthropic/claude-opus-5` 标识符访问
- **Model Fallbacks**: 通过 `providerOptions.gateway.models` 数组配置降级链，当 Opus 5 因安全分类器误拦时自动切换备用模型
- **Zero Data Retention 兼容**: 满足企业数据合规要求
- **Reasoning Effort 精细控制**: 在 AI SDK 7 中通过顶层 `reasoning` 参数控制，从 `minimal` 到 `xhigh`，或 `none`
- **Fast Mode**: 通过 `providerOptions.anthropic.speed: 'fast'` 启用低延迟模式

**Workflow 延长执行**:
- **环境变量开关**: 设置 `VERCEL_ENABLE_WORKFLOW_EXTENDED_MAX_DURATION=1` 即可启用
- **依赖 Fluid Compute**: 需要 Vercel 的 Fluid Compute 基础设施支持
- **分级限制**: Pro/Enterprise 最长 30 分钟（1800 秒），Hobby 仍为 5 分钟（300 秒）
- **运行时要求**: 需要受支持的 Node.js 或 Python 运行时

### 与之前版本的关键差异

| 维度 | 之前 (Opus 4 / 旧版 Workflow) | 现在 (Opus 5 + Extended Workflow) |
|------|-------------------------------|-----------------------------------|
| 多文件代码重构 | 容易留下 stub/placeholder | 能完成端到端完整功能 |
| Reasoning 控制 | 粗粒度开关 | 5 级精细控制 (minimal/low/medium/high/xhigh/none) |
| Vision 能力 | 基础图表/文档识别 | 增强：图表、文档、图表、UI 复制 + 工具辅助分析裁剪验证 |
| 多 Agent 协调 | 支持但效果有限 | 显著改善 subagent 协作能力 |
| 安全护栏 | 标准 | 增强网络安全防护（可能误拦良性安全审计任务） |
| Fast Mode | 不支持 | 支持 `speed: 'fast'` 低延迟模式 |
| Workflow 执行时长 | 800 秒 (Pro) / 300 秒 (Hobby) | 1800 秒 (Pro/Enterprise) / 300 秒 (Hobby) |
| 模型降级 | 需自行实现 | AI Gateway 原生支持 fallback 链 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                     Vercel AI App Layer                        │
│                                                                │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────┐  │
│  │  Coding Agent │    │ Multi-Agent      │    │ Security     │  │
│  │  (Claude Code)│    │  Workflow        │    │ Audit Agent  │  │
│  └──────┬───────┘    └────────┬─────────┘    └──────┬───────┘  │
│         │                     │                      │          │
│         └──────────────┬──────┴──────────────────────┘          │
│                        ▼                                        │
│              ┌─────────────────────┐                            │
│              │   AI Gateway (统一  │                            │
│              │   路由 + Fallback)  │                            │
│              └──────┬──────────────┘                            │
│                     │                                           │
│         ┌───────────┼────────────────┐                          │
│         ▼           ▼                ▼                          │
│  ┌──────────┐ ┌──────────┐  ┌──────────────┐                   │
│  │ Opus 5   │ │ Opus 4.8 │  │ Sonnet 5     │                   │
│  │ (primary)│ │ (fallback)│ │ (fallback)   │                   │
│  └──────────┘ └──────────┘  └──────────────┘                   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Vercel Workflows (最长 30min)                │   │
│  │  Step 1 → Step 2 → ... → Step N (每步最长 1800s)         │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **Agentic Coding 工作流**: Opus 5 在多文件重构和端到端功能开发上显著优于前代。配合 AI Gateway 的 `vercel ai-gateway coding-agents setup` 命令，可以一键配置 Claude Code 等编码 Agent 通过 Gateway 路由，获得统一花费追踪和模型 fallback。
- **多 Agent 协作编排**: Opus 5 改善了 subagent 协调能力，适合需要多个专业 Agent 分工协作的复杂工作流（如前端 Agent + 后端 Agent + 测试 Agent）。
- **高可用 AI 服务**: Model Fallbacks 原生支持意味着当 Opus 5 因安全分类器误拦请求时，自动降级到 Opus 4.8 或 Sonnet 5，服务不中断。
- **长周期数据处理**: Workflow 步骤最长 30 分钟，适合批量数据处理、大规模代码分析、复杂文档生成等需要长时间运行的任务。

### 什么场景不值得用

- **简单对话/问答**: Opus 5 是旗舰模型，成本显著高于 Sonnet。对于简单对话场景，使用 Opus 5 是资源浪费。
- **Hobby 计划用户**: 执行时长仍限制 5 分钟，无法享受 Workflow 延长执行的福利。需要升级到 Pro 或 Enterprise。
- **对延迟极度敏感的场景**: Opus 5 的 reasoning 默认开启，会增加首 token 延迟。如果场景要求亚秒级响应，应考虑 Fast Mode 或改用更轻量的模型。
- **需要完全可控安全边界的场景**: Opus 5 的增强网络安全防护可能导致良性安全审计任务被误拦（Vercel 官方文档明确提及此风险）。

### 迁移成本

- **AI Gateway 接入 Opus 5**: 极低。如果已使用 AI SDK，只需将 model 参数改为 `anthropic/claude-opus-5`。Coding Agent 用户运行 `vercel ai-gateway coding-agents setup` 即可自动配置。
- **启用 Model Fallbacks**: 低。在 `providerOptions.gateway.models` 中添加备用模型列表即可。
- **Workflow 延长执行**: 低。设置环境变量 `VERCEL_ENABLE_WORKFLOW_EXTENDED_MAX_DURATION=1` 并 redeploy。前提是项目已使用 Fluid Compute 和受支持的运行时。
- **从 Opus 4 迁移**: 需关注 API 变化——reasoning 控制从 provider-specific 参数升级为 AI SDK 7 的顶层 `reasoning` 选项。

## 对你的意义

对 Ken 的 AI 应用开发工作而言，这两项更新的核心价值在于：

1. **Agent-Playbook 的 AI Gateway 章节需要更新**: Opus 5 的接入是 AI Gateway 的重要里程碑——它是首个在 Gateway 上支持 reasoning effort 精细控制的 Opus 模型。这应该写入 `landscape/app-index.md` 的 AI Gateway 条目。

2. **多 Agent 编排的实践验证**: Opus 5 改善的 subagent 协调能力，与假设 A-005（AI 工作流自动化成为企业 AI 最快增长场景）直接相关。Vercel 正在将 Workflows 打造为企业 AI 自动化的基础设施层。

3. **成本 vs 能力的权衡决策**: Opus 5 的强大能力伴随更高成本。在实际项目中，利用 AI Gateway 的 fallback 机制 + reasoning effort 分级，可以实现精细的成本控制——简单任务用 low effort Sonnet，复杂任务用 xhigh effort Opus 5。

**建议**: 立即在测试环境中试用 Opus 5 的 reasoning effort 分级，评估不同 effort 级别对任务质量的影响。这对后续选择 Agent 框架的模型路由策略有直接参考价值。

## 关键代码/配置片段

### AI SDK 7 — Reasoning Effort 控制

```typescript
import { streamText } from 'ai';

const result = streamText({
  model: 'anthropic/claude-opus-5',
  prompt: 'Implement the multi-file refactor described in this issue.',
  reasoning: 'medium',  // minimal | low | medium | high | xhigh | none
});
```

### Model Fallbacks — 安全护栏误拦时的自动降级

```typescript
import { streamText } from 'ai';

const result = streamText({
  model: 'anthropic/claude-opus-5',
  prompt: 'Audit this script for vulnerabilities.',
  providerOptions: {
    gateway: {
      models: ['anthropic/claude-opus-4.8', 'anthropic/claude-sonnet-5'],
    },
  },
});
```

### Fast Mode — 低延迟场景

```typescript
import { streamText } from "ai";

const { text } = await streamText({
  model: 'anthropic/claude-opus-5',
  prompt,
  providerOptions: {
    anthropic: {
      speed: 'fast',
    },
  },
});
```

### Workflow 延长执行 — 环境变量配置

```bash
# 在项目 Environment Variables 中设置
VERCEL_ENABLE_WORKFLOW_EXTENDED_MAX_DURATION=1
```

### 查询模型端点信息

```bash
curl https://ai-gateway.vercel.sh/v1/models/anthropic/claude-opus-5/endpoints \
  -H "Authorization: Bearer $AI_GATEWAY_API_KEY"
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | Vercel 同日发布 Opus 5 + Workflow 延长执行，将复杂 Agent 工作流的模型能力和执行时长两个瓶颈同时解决，是企业级 AI 自动化基础设施化的明确信号 |

---
[← Back to Deep Dives](./README.md)
