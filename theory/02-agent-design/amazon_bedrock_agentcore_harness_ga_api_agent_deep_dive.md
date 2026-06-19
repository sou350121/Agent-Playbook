---
auto_generated: true
generated_at: "2026-06-19T11:05:11Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-harness-is-now-generally-available-go-from-idea-to-production-grade-agent-in-minutes/"
signal_type: "blog_post"
---
# Amazon Bedrock AgentCore Harness GA：两步 API 生产级 Agent (Amazon Bedrock AgentCore Harness GA: Production-Grade Agents in Two API Calls)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-19
>
> **项目/工具**: Amazon Bedrock AgentCore Harness
> **链接**: https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-harness-is-now-generally-available-go-from-idea-to-production-grade-agent-in-minutes/
> **核心定位**: AWS 将 Agent 生产环境所需的一切（沙盒计算、记忆、工具路由、可观测性、评估优化）封装为两个 API 调用的托管抽象，让 Agent 从原型到生产级部署从"工程"变为"配置"

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: AWS 推出的 Agent 生产托管平台，用 CreateHarness + InvokeHarness 两个 API 调用替代手动编排基础设施
- **现在值得用吗**: 是 — 如果你已在 AWS 生态内运行 Agent 工作负载，且面临从原型到生产的编排瓶颈
- **适合场景**: 多模型切换的 Agent 工作流、需要生产级可观测性和评估的 Agent 系统、MCP/Gateway 工具集成、Step Functions 工作流编排
- **不适合场景**: 非 AWS 环境（锁定在 AWS 基础设施上）、超轻量级单轮对话（overkill）、需要完全自定义编排逻辑的场景（应直接写代码而非配置）
- **与竞品核心差异**: 相比 LangServe/LangGraph Server（需自建编排）、Azure AI Agent Service（仅 Azure 模型为主），AgentCore Harness 提供跨模型提供商的中立抽象层 + 完整的评估/优化/版本管理闭环

## 是什么 / 解决什么问题

Agent 开发的核心矛盾在 2025-2026 年变得愈发清晰：编写 Agent 循环本身（LLM 调用 → 工具使用 → 循环）越来越简单，但围绕循环的基础设施越来越复杂。

Simon Willison 一年前的定义依然精准："An LLM agent runs tools in a loop to achieve a goal." Kiro、Amazon Q Developer、Quick Agents、Codex、Claude Code 底层都运行同样的循环模式。但循环从来不是难点——难点在于循环之外的一切：

- 选择框架、连接工具、配置沙盒计算
- 管理存储、密钥、网络、身份
- 决定记忆存储位置、接入可观测性
- 将正确的依赖打入容器
- 本地原型容易（一个开发者下午即可搭建），但生产部署时工作量爆炸：并发、隔离、身份、状态、扩缩容

更糟的是，这些开销随每个新用例线性增长。想换模型、换工具、指向新领域？重复同样的管道工作。**瓶颈不是智能，而是编排和基础设施。**

Amazon Bedrock AgentCore Harness 在 2026 年 4 月以 Preview 发布，2026 年 6 月正式 GA。它的核心假设是：AgentCore 的原语（Runtime、Memory、Gateway、Browser、Identity、Observability）已经覆盖了生产所需的一切，开发者不应每次都手动连接它们。Harness 将这些连接封装为托管抽象——**从"你构建的东西"变成"你配置的东西"**。

## 技术架构拆解

### 核心设计决策

| 设计选择 | 具体方案 | 理由 |
|---------|---------|------|
| 配置优先于代码 | CreateHarness + InvokeHarness 两个 API | 最小化编排代码，最大化声明式配置 |
| 模型中立 | 支持 Bedrock / OpenAI / Gemini / LiteLLM 四大 provider | 允许 mid-session 切换模型而不丢失上下文 |
| 工具即配置 | tools 参数声明式列表，harness 自动连接 | 消除 per-API adapter 代码和 MCP server 生命周期管理 |
| 自动记忆 | 省略 memory 参数时自动 provision 托管记忆 | 降低生产部署门槛，同时保留 BYO 灵活性 |
| Skills 按需加载 | 元数据常驻，内容按需注入上下文 | 避免 skill 膨胀消耗 context window |
| 可观测性内置 | 每个 primitive 的日志自动关联到统一 trace | 消除"开五个 tab 拼凑故事"的调试噩梦 |
| 渐进式毕业 | export harness → Strands 代码 | 配置不够用时不推倒重来，而是同一计算路径上的平滑迁移 |

### 与前版/竞品的关键差异

| 维度 | LangServe / LangGraph Server | Azure AI Agent Service | Amazon Bedrock AgentCore Harness |
|------|------------------------------|------------------------|----------------------------------|
| 模型支持 | 任意（需自建 adapter） | 主要 Azure OpenAI | Bedrock + OpenAI + Gemini + LiteLLM（4 类） |
| 工具连接 | 需手写代码连接 MCP/Gateway | 内置但有限 | 声明式配置（gateway/MCP/browser/code_interpreter/inline_function） |
| 记忆 | 需自建存储 | 内置但有限 | 自动托管记忆 + BYO 记忆 + 完全无状态（3 种模式） |
| 可观测性 | 需集成 LangSmith | 内置 | CloudWatch GenAI Observability 统一视图 |
| 评估/优化 | 需集成外部工具 | 有限 | AgentCore Evaluations + Optimization（含 A/B 测试） |
| 版本管理 | 需自建 | 有限 | 内置版本 + endpoint 管理 + 一键回滚 |
| 毕业路径 | 导出到 LangGraph 代码 | 无 | export → Strands 代码（Claude Agent SDK 即将支持） |
| 部署环境 | 任意 | Azure | AWS（ECR/EFS/S3/VPC/Step Functions） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                    CreateHarness (配置层)                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────┐   │
│  │ Model    │  │ Tools    │  │ Skills   │  │ Memory        │   │
│  │ Provider │→ │ Config   │→ │ Sources  │→ │ (auto/BYO/    │   │
│  │ + Prompt │  │ List     │  │ git/s3/  │  │  disabled)    │   │
│  │          │  │          │  │ awsSkills│  │               │   │
│  └──────────┘  └──────────┘  └──────────┘  └───────────────┘   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              AgentCore Harness (托管抽象层)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ microVM     │  │ Managed     │  │ Unified Observability   │  │
│  │ Sandbox     │  │ Memory      │  │ (CloudWatch GenAI)      │  │
│  │ + Filesystem│  │ (semantic + │  │                         │  │
│  │ + Shell     │  │  summary)   │  │ trace → session → step  │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬────────────┘  │
│         │                │                      │               │
│  ┌──────▼────────────────▼──────────────────────▼──────────┐    │
│  │              Tool Router (声明式连接)                     │    │
│  │  agentcore_gateway │ remote_mcp │ browser │ code_interp  │    │
│  └──────────────────────┬──────────────────────────────────┘    │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│              InvokeHarness (执行层)                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  LLM Loop: 推理 → 工具调用 → 记忆读写 → 文件操作 → 浏览器 │   │
│  │  (mid-session 可切换模型 provider，上下文不丢失)           │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│              生产闭环 (GA 新增)                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────┐   │
│  │ Evaluations│ Optimization│ Versioning │ Step Functions  │   │
│  │ (LLM-as- │ (prompt 优化 │ (版本 +    │ (工作流集成)    │   │
│  │  judge)  │  + A/B test)│  回滚)     │               │   │
│  └──────────┘  └──────────┘  └──────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 多模型切换机制

Harness 的模型切换是 GA 的关键差异化能力。CreateHarness 时设置默认模型，InvokeHarness 时可覆盖为任意 provider：

- **bedrock**: Claude、Nova、Llama、DeepSeek、Qwen、Kimi、MiniMax、Cohere、Mistral、GPT-5.5/GPT-5.4
- **openAi**: 直接访问 OpenAI API
- **gemini**: Google Gemini
- **liteLlm**: Anthropic direct、Cohere、Mistral、Vertex、Azure OpenAI 等

关键特性：**mid-session 切换不丢失上下文**。用 Claude Opus 规划，切到 GPT-5.5 写代码，再切到 Gemini 做摘要——对话继续。凭证存储在 AgentCore Identity 的 token vault 中，Agent 永远看不到原始密钥。

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| 多模型路由的 Agent 系统 | 天然支持 provider 切换，无需自建 adapter |
| 需要生产级可观测性的 Agent | CloudWatch GenAI Observability 统一 trace，从 harness → session → step 逐层下钻 |
| MCP 工具集成 | remote_mcp 类型一行声明即可连接任意 MCP server |
| 需要评估/优化的 Agent | 内置 LLM-as-judge 评估 + prompt 优化建议 + A/B 测试 |
| 需要版本管理的 Agent | 每次 UpdateHarness 创建不可变版本，endpoint 指向即可回滚 |
| Step Functions 工作流中的 Agent | InvokeHarness 成为一等状态，可直接拖入 Workflow Studio |
| 从配置到代码的渐进迁移 | export 命令一键导出为 Strands 代码，同一计算路径 |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| 非 AWS 环境 | 完全锁定在 AWS 基础设施（ECR/EFS/S3/VPC），跨云不可用 |
| 超轻量级单轮对话 | 两个 API 调用 + 沙盒环境是 overkill，直接用模型 API 即可 |
| 需要完全自定义编排逻辑 | Harness 是声明式配置，复杂多 Agent 协作应直接写代码 |
| 对供应商锁定敏感的团队 | 虽然可 export 到代码，但核心托管服务（记忆/可观测性/评估）仍依赖 AWS |
| 预算敏感的小团队 | microVM 沙盒 + 托管记忆 + 可观测性 = 额外成本，简单场景不划算 |

### 迁移成本

| 从...迁移 | 工作量 | 说明 |
|-----------|--------|------|
| 自建 LangGraph/LangServe | 中 | 需重写工具连接为声明式配置，但可观测性/评估/版本管理自动获得 |
| Azure AI Agent Service | 高 | 模型 provider 和工具生态不同，需重新适配 |
| 裸模型 API + 手写编排 | 低 | 核心逻辑可保留，只需将编排层迁移到 Harness 配置 |
| 已有 AgentCore Runtime 用户 | 极低 | Harness 是 Runtime 的托管封装，export 路径双向兼容 |

## 对你的意义

对 Ken 的 Agent + UI 方向而言，这个变化有几个值得关注的信号：

1. **MCP 正式成为 AWS Agent 生态的一等公民**。Harness 原生支持 `remote_mcp` 工具类型，一行声明即可连接任意 MCP server。这进一步强化了 MCP 作为 Agent 工具集成事实标准的趋势（对应假设 A-001）。

2. **"配置优先"范式正在成为行业共识**。AWS 将 Agent 从"构建"变为"配置"的思路，与 LangGraph 的声明式工作流、Azure AI Agent Service 的托管抽象殊途同归。这意味着 Agent 开发的基础设施层正在被平台化，开发者的注意力应更多放在 Agent 的"智能"层面（prompt 工程、skills 设计、评估优化）而非管道搭建。

3. **export-to-code 是聪明的设计**。AWS 没有把 Harness 做成封闭黑盒——当配置不够用时，你可以导出为可读可改的代码，且保持同一计算路径。这种"渐进式毕业"策略值得借鉴：在你自己的 Agent 架构中，也应该保留从配置到代码的平滑过渡路径。

**建议**: 如果你的 Agent 工作负载运行在 AWS 上，值得立即试用 Harness 的 GA 版本。特别是如果你正在为 Agent 的可观测性、评估、版本管理头疼——Harness 提供了一条从配置到生产的完整路径。

## 关键代码/配置片段

### 创建 Harness（最小配置）

```json
{
  "harnessName": "myAgent",
  "model": {
    "bedrock": { "modelId": "anthropic.claude-opus-20260101-v1:0" }
  },
  "tools": [
    { "type": "agentcore_browser" },
    { "type": "agentcore_code_interpreter" },
    { "type": "remote_mcp", "name": "X_tool",
      "config": { "remoteMcp": { "url": "https://mcp.X_tool/mcp" } }
    },
    { "type": "agentcore_gateway", "name": "Y_tool",
      "config": { "agentCoreGateway": { "arn": "arn:aws:bedrock-agentcore:..." } }
    }
  ],
  "skills": [
    { "awsSkills": {} },
    { "git": { "uri": "https://github.com/anthropics/skills", "path": "document-skills/xlsx" } },
    { "s3": { "uri": "s3://my-bucket/skills/team-sops/" } }
  ],
  "memory": {
    "managedMemoryConfiguration": {
      "strategies": ["SEMANTIC", "SUMMARIZATION"],
      "eventExpiryDuration": 30
    }
  }
}
```

### 版本管理与回滚

```bash
# 创建 PROD endpoint，固定到 V2
aws bedrock-agentcore-control create-harness-endpoint \
  --harness-id my-harness-xxx --endpoint-name PROD --harness-version 2

# 升级到 V5（或回滚到 V4）
aws bedrock-agentcore-control update-harness-endpoint \
  --harness-id my-harness-xxx --endpoint-name PROD --harness-version 5
```

### 导出为代码（渐进式毕业）

```bash
agentcore export harness --name myHarness-6dk4df --output ./my-agent
```

### 文件系统三模式对比

| 类型 | 托管方 | 需要 VPC | 持久化范围 |
|------|--------|----------|-----------|
| Managed session storage | AWS 托管 | 否 | 同一 runtimeSessionId 的 stop/resume 周期 |
| EFS access point | 自带 | 是 | 所有 session，可跨 harness 共享 |
| S3 Files access point | 自带 | 是 | 所有 session 和 harness，完整 S3 耐久性和版本控制 |

---
[← Back to Deep Dives](./README.md)

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AgentCore Harness 原生支持 `remote_mcp` 工具类型，一行声明即可连接任意 MCP server，MCP 从"可选"升级为 AWS Agent 基础设施的一等公民 |
