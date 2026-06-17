---
auto_generated: true
generated_at: "2026-06-17T03:33:16Z"
source_url: "https://vercel.com/changelog/program-agent-harnesses-with-ai-sdk"
signal_type: "significant_update"
---
# Vercel AI SDK 7 引入 HarnessAgent：agent-as-tool 范式进入主流 SDK (HarnessAgent: Program Agent Harnesses with AI SDK 7)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-17
>
> **项目/工具**: Vercel AI SDK 7 — HarnessAgent
> **链接**: https://vercel.com/changelog/program-agent-harnesses-with-ai-sdk
> **核心定位**: 一个统一的 TypeScript API，让开发者用同一套代码编排 Claude Code、Codex、Pi 等完整 Agent 运行时，实现"写一次 Agent，随时切换最佳 harness"

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：AI SDK 7 新增 HarnessAgent 抽象层，将 Claude Code / Codex / Pi 等完整 Agent 运行时封装为可互换的"工具"，统一 API 入口
- **現在值得用嗎**：看場景 — 实验性 API（experimental），expect breaking changes；但架构方向明确，值得提前了解
- **適合場景**：需要在应用中编排编码 Agent、多轮会话 Agent、沙箱化工作流的 TypeScript/Next.js 项目
- **不適合場景**：需要精细控制 model call 层级（tool loop、structured output、自定义 agent 架构）的场景；应继续使用 AI SDK Core 的 generateText/streamText
- **與之前方案的核心差異**：之前每个 Agent harness 有各自的 SDK/API；现在通过 HarnessAgent 统一，流式输出兼容 AI SDK UI 组件（useChat 可直接消费）

## 是什么 / 解决什么问题

Vercel AI SDK 自诞生以来就致力于解决一个核心问题：LLM 集成高度依赖特定 provider，开发者被迫在技术细节上浪费时间而非构建应用价值。AI SDK 6 及之前版本已经实现了 **model 层的可互换**——通过统一的 provider 抽象，你可以用 `generateText({ model: "anthropic/claude-sonnet-4.5" })` 这样的 API 切换底层模型而不重写业务逻辑。

但 model 层的可互换远远不够。当你的应用需要的是一个**完整的 Agent 运行时**（coding agent、multi-turn session、sandboxed workspace），每个 harness 都有自己的 SDK、自己的流式协议、自己的会话管理。Claude Code 有 Claude Code 的 API，OpenAI Codex 有 Codex 的 API，Pi 有 Pi 的 API——它们不是"模型"，它们是**运行时**。

AI SDK 7 的 HarnessAgent 解决了这个问题：**将 harness 层也标准化**。

> "AI SDK has always let you switch models without rewriting your agent. Now you can switch the harness the same way. Write the agent once. Use the best harness available. Today. In 3 months. A year from now."

这句话概括了 HarnessAgent 的野心——它不只是又一个 adapter 层，而是试图建立 **agent-as-tool** 的 SDK 标准。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|----------|------|
| **Harness 与 Provider 双层解耦** | Provider 管 model call（generateText/streamText），Harness 管 agent runtime（HarnessAgent）。两者独立但流式原语兼容 |
| **流式输出投影到 AI SDK 类型** | HarnessAgent.generate() 返回 GenerateTextResult，stream() 返回 StreamTextResult。现有 useChat 等 UI 组件无需修改即可消费 harness 输出 |
| **Session 作为一等公民** | Harness 不是无状态调用——session 携带运行时、沙箱、工作目录、原生对话历史、待审批权限。必须 createSession → 使用 → destroy |
| **沙箱隔离** | 所有 harness 运行在隔离沙箱中，保护宿主机环境安全 |
| **可定制性保留** | 允许传入自定义 instructions、skills、AI SDK tools、permission settings、sandbox hooks |

### 与前版/竞品的关键差异

| 维度 | AI SDK 6 及之前 | AI SDK 7 HarnessAgent |
|------|-----------------|----------------------|
| **抽象层级** | 仅 model/provider 层可互换 | model + harness 双层可互换 |
| **Agent 编排** | 每个 harness 各自 SDK | 统一 HarnessAgent API |
| **流式协议** | 各 harness 自有协议 | 投影到 AI SDK stream parts |
| **UI 集成** | 需为每个 harness 写适配 | useChat 等组件直接消费 |
| **会话管理** | 应用层自行管理 | session 作为一等对象，支持 detach/stop/resume |
| **沙箱** | 无统一方案 | 内置沙箱 provider 抽象 |
| **定制能力** | 完全控制 model call | 保留 instructions/skills/tools/custom sandbox |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Your Application                      │
│  (Next.js / React / Node.js / Vue / Svelte)             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐    ┌──────────────┐                   │
│  │ AI SDK Core  │    │ HarnessAgent │                    │
│  │              │    │              │                    │
│  │ generateText │    │ createSession│                    │
│  │ streamText   │    │ generate     │                    │
│  │ stream       │    │ stream       │                    │
│  └──────┬───────┘    └──────┬───────┘                   │
│         │                   │                            │
│  ┌──────▼───────┐    ┌──────▼───────┐                   │
│  │   Provider   │    │  Harness     │                    │
│  │   Adapter    │    │  Adapter     │                    │
│  │              │    │              │                    │
│  │ anthropic/   │    │ claudeCode   │                    │
│  │ claude-xxx   │    │ codex        │                    │
│  │ openai/xxx   │    │ pi           │                    │
│  └──────────────┘    └──────┬───────┘                   │
│                            │                            │
│                     ┌──────▼───────┐                    │
│                     │   Sandbox    │                    │
│                     │   Provider   │                    │
│                     │              │                    │
│                     │ createVercel │                    │
│                     │  Sandbox()   │                    │
│                     └──────────────┘                    │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                    AI SDK UI                             │
│         useChat / toUIMessageStream                     │
│    (同时消费 Core streams 和 Harness streams)            │
└─────────────────────────────────────────────────────────┘
```

关键洞察：**stream 兼容性是这套架构的粘合剂**。Harness 输出的 text delta、tool call、tool result、usage、finish reason 全部映射到 AI SDK 已有的 stream parts 格式。没有一等映射的事件（如 workspace file changes、compaction）则作为 dynamic provider-executed tool parts 暴露。这意味着你现有的 AI SDK UI 代码——`useChat`、`toUIMessageStream`——可以零修改地消费 harness 输出。

## 实用评估

### 什么场景值得用

- **在应用中嵌入编码 Agent**：你的产品需要让用户在沙箱中让 Claude Code / Codex 检查测试失败、修复代码、审查 PR——HarnessAgent 提供了一站式方案，无需为每个 harness 写集成层
- **多 Agent 编排场景**：需要在一个工作流中切换不同 harness（比如用 Claude Code 做代码修改、用 Pi 做代码审查），统一 API 让切换成本降为零
- **已有 AI SDK 应用升级**：已经用 AI SDK 6 构建了 chat UI，现在想增加 agent 能力——直接导入 HarnessAgent，stream 兼容意味着 UI 层不需要重写
- **需要沙箱隔离的生产环境**：Harness 强制沙箱运行，天然适合需要环境隔离的 SaaS 场景

### 什么场景不值得用

- **需要精细控制 model call 层级**：如果你需要自定义 tool loop 逻辑、structured output、特定的 model settings（temperature、top_p 等），继续使用 AI SDK Core 的 generateText/streamText。HarnessAgent 封装了这些细节
- **自定义 agent 架构**：如果你有自己的 agent 架构（multi-agent、ReAct loop、plan-and-execute），HarnessAgent 的 session 模型可能限制你的灵活性
- **非 TypeScript 生态**：AI SDK 是 TypeScript 原生工具。如果你的后端是 Python/Go/Rust，这个抽象对你没有直接价值
- **实验性 API 的生产风险**：官方明确标注 "experimental, expect breaking changes"。生产环境需要评估升级成本

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| 从零开始新项目 | 低 | 直接 `npm install @ai-sdk/harness @ai-sdk/harness-claude-code @ai-sdk/sandbox-vercel` |
| 已有 AI SDK 6 项目加 harness | 中 | 保留现有 Core/UI 代码，新增 HarnessAgent 调用；stream 兼容意味着 UI 不改 |
| 从各 harness 自有 SDK 迁移 | 中高 | 需要重写 harness 调用代码，但换来的是统一抽象和未来可互换性 |
| 从非 AI SDK 方案迁移 | 高 | 需要整体迁移到 AI SDK 生态，但 harness 抽象是迁移的核心理由之一 |

## 对你的意义

这个变化对 Agent + UI 方向的开发者有标志性意义：

1. **agent-as-tool 范式被主流 SDK 正式接纳**。Vercel AI SDK 是 TypeScript AI 应用最主流的 SDK 之一。当它把 harness 作为一等抽象，说明行业共识正在形成——Agent 不再是"调用模型的 wrapper"，而是**可编排的运行时**。

2. **对你的 RAG/Agent 工具链可能有间接影响**。如果 Agent-Playbook 中追踪的 Agent 框架（如 OpenClaw、KiloCode 等）未来接入 AI SDK harness 生态，你将获得一个统一的编排层——不需要为每个框架写适配代码。

3. **建议立即关注，暂缓生产使用**。实验性阶段意味着 API 可能大变，但架构方向（harness 抽象 + stream 兼容 + 沙箱隔离）几乎不会变。现在阅读文档、理解设计，等 stable release 后快速迁移。

## 关键代码/配置片段

### 创建 HarnessAgent 并流式调用（来自官方 changelog）

```typescript
import { HarnessAgent } from '@ai-sdk/harness/agent';
import { claudeCode } from '@ai-sdk/harness-claude-code';
import { createVercelSandbox } from '@ai-sdk/sandbox-vercel';

const agent = new HarnessAgent({
  harness: claudeCode,
  sandbox: createVercelSandbox({
    runtime: 'node24',
    ports: [4000],
  }),
  tools: { /* pass custom tools */ },
  skills: [ /* pass custom skills */ ],
});

const session = await agent.createSession();
try {
  const result = await agent.stream({
    session,
    prompt: 'Check the test failures and fix the production code.',
  });
  for await (const part of result.fullStream) {
    if (part.type === 'text-delta') {
      process.stdout.write(part.text);
    }
  }
} finally {
  await session.destroy();
}
```

### 切换 harness 只需改一行

```typescript
// 从 Claude Code 切换到 Codex
import { codex } from '@ai-sdk/harness-codex';

const agent = new HarnessAgent({
  harness: codex,  // ← 仅此一行
  sandbox: createVercelSandbox({ runtime: 'node24', ports: [4000] }),
});
```

### 流式输出直接对接 useChat

```typescript
// HarnessAgent stream 可以直接传给 AI SDK UI
import { toUIMessageStream } from 'ai';

const result = await agent.stream({ session, prompt: '...' });
const uiStream = toUIMessageStream(result);
// → 可以直接在 useChat 中消费，无需任何适配
```

> TODO: 官方标注 Harness packages 为 experimental，具体 breaking changes 范围待 stable release 确认。
> TODO: 各 harness adapter（claude-code / codex / pi）的具体能力差异（内置工具、权限模型、compaction 策略）待官方文档补充。

---
[← Back to Deep Dives](./README.md)
