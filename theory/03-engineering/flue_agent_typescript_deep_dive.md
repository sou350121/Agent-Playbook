---
auto_generated: true
generated_at: "2026-06-21T08:04:42Z"
source_url: "https://github.com/withastro/flue/releases"
signal_type: "blog_post"
---
# Flue：沙箱 Agent 框架，TypeScript 原生编排 (Flue: The Sandbox Agent Framework, TypeScript-Native Orchestration)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-21
>
> **项目/工具**: Flue (@flue/runtime, @flue/cli, @flue/sdk)
> **链接**: https://github.com/withastro/flue
> **核心定位**: 由 Astro 团队打造的 TypeScript 原生 Agent 框架，内置沙箱、持久化执行、子 Agent 和 MCP 支持，让 Agent 从"聊天机器人"升级为"能在安全环境中自主完成工作的程序"。

## 快速判断（30 秒读完这段就够了）

- **一句话定位**: Astro 团队出品的 TypeScript Agent 框架，核心卖点是「沙箱 + 持久化执行 + 子 Agent 编排」三位一体。
- **现在值得用吗**: 看场景。项目尚无正式 Release（截至 2026-06-21），适合关注/尝鲜，不适合生产引入。
- **适合场景**: 需要在 TypeScript 项目中嵌入自主 Agent（代码审查、工单处理、CI 自动化）；需要沙箱隔离的多 Agent 系统。
- **不适合场景**: 需要 Python 生态的 Agent 工作流；追求成熟稳定、有生产案例的框架。
- **与 LangChain/LangGraph 核心差异**: Flue 以 TypeScript 为第一公民，沙箱是内置一等概念而非插件；LangGraph 更通用但沙箱需自行集成。

## 是什么 / 解决什么问题

Agent 框架的发展经历了几个阶段：最早的 raw LLM API 调用只适合简单对话；LangChain/LangGraph 引入了链和图的工作流编排；Claude Code、Codex 等展示了"真正的自主 Agent"——给它任务而非步骤，让它自己决定用什么工具、访问什么文件来完成。

Flue 瞄准的是第二阶段到第三阶段的跨越。它的核心洞察是：一个能自主工作的 Agent 需要的不只是"模型 + prompt"，而是一个完整的 **TypeScript harness**——包含会话管理、工具调用、技能包、文件系统访问、沙箱隔离、持久化执行。这些能力如果由应用层自己拼凑，会非常脆弱且难以维护。

Flue 由 Astro 团队（withastro）出品，这本身就传递了一个信号：前端/全栈框架团队正在认真思考"如何让他们的框架生态中嵌入自主 Agent"。Astro 在构建工具链方面的工程品味（轻量、模块化、开发者体验优先）直接投射到了 Flue 的设计中。

截至 2026-06-21，Flue 尚无正式 GitHub Release，处于早期公开阶段。这意味着 API 可能变动、文档可能不完整、生产使用存在风险。但它的设计思路值得深入分析。

## 技术架构拆解

### 核心设计决策

Flue 的架构围绕以下几个核心决策构建：

**1. Agent = 文件 + 配置对象**

每个 Agent 是 `src/agents/` 下的一个 TypeScript 文件，通过 `createAgent()` 或 `defineAgent()` 导出。这种"文件即 Agent"的设计让 Agent 天然拥有文件系统级别的命名空间和模块边界。

```typescript
// agents/triage.ts
import { defineAgent, type AgentRouteHandler } from '@flue/runtime';
import { local } from '@flue/runtime/node';
import triage from '../skills/triage/SKILL.md' with { type: 'skill' };
import verify from '../skills/verify/SKILL.md' with { type: 'skill' };
import * as githubTools from '../tools/github.ts';

export default defineAgent(() => ({
  model: 'anthropic/claude-sonnet-4-6',
  tools: [...githubTools],
  skills: [triage, verify],
  sandbox: local(),
  instructions,
}));
```

**2. 三层沙箱模型**

Flue 提供三种沙箱类型，覆盖从轻量到重量级的全部场景：

| 沙箱类型 | 隔离级别 | 持久性 | 适用场景 |
|---------|---------|--------|---------|
| Virtual (默认) | 内存级，无文件系统 | 不持久 | 文档处理、轻量工作流 |
| Local | 无隔离（直接访问 host） | 持久 | 可信开发工具、CI Runner |
| Remote (Daytona/Cloudflare) | 容器级隔离 | 可配置 | 多租户、不可信输入、需要 Linux 工具链 |

**3. 持久化执行 (Durable Execution)**

Agent 在长时间工作中遇到失败或重启时，已通过验证的工作进度不会丢失。这是通过 session store + 沙箱生命周期的分离实现的——会话历史由 db adapter（默认或 `@flue/postgres`）管理，文件/工件由沙箱生命周期管理。

**4. 子 Agent 委派 (Subagents)**

通过 `defineAgentProfile()` 定义可复用的 Agent 行为模板，主 Agent 通过 `subagents` 字段引用。子 Agent 不暴露独立 HTTP 端点，仅作为父 Agent 的委派目标。

```typescript
const policyResearcher = defineAgentProfile({
  name: 'policy_researcher',
  description: 'Finds relevant policy text and quotes the supporting passages.',
  instructions: 'Read the policy workspace and return supporting quotations.',
});

export default createAgent(() => ({
  model: 'anthropic/claude-sonnet-4-6',
  subagents: [policyResearcher],
}));
```

**5. Skills 作为编译时内联资源**

Skill 文件（`.SKILL.md`）通过 TypeScript import attributes（`with { type: 'skill' }`）在构建时内联为字符串。这避免了运行时读取文件的开销和路径问题，同时让 IDE 能够提供类型检查。

**6. HTTP 路由 + 异步 dispatch**

Agent 通过 `route` handler 暴露 HTTP 端点（`POST /agents/<name>/<id>`），同时支持通过 `dispatch()` 异步处理 webhook、队列消息等事件。这种同步+异步双模式覆盖了 Agent 与外部系统交互的主要模式。

### 与前版/竞品的关键差异

| 维度 | LangGraph (Python/TS) | Vercel AI SDK | Flue |
|------|----------------------|---------------|------|
| 语言优先 | Python 为主，TS 次之 | TypeScript | TypeScript |
| 沙箱 | 需自行集成 (E2B/Docker) | 无内置 | 内置三层沙箱 |
| 持久化执行 | 需自行实现 checkpoint | 无 | 内置 durable execution |
| 子 Agent | 支持 (graph branching) | 无 | 内置 subagent profile |
| MCP 支持 | 需插件 | 需插件 | 内置 MCP Server 连接 |
| 部署目标 | 广泛 | Vercel 生态 | Node/Cloudflare/GitHub Actions/GitLab |
| 成熟度 | 生产级 | 生产级 | 早期 (无正式 Release) |
| 团队背景 | LangChain 公司 | Vercel | Astro 团队 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                    Application Layer                 │
│  POST /agents/<name>/<id>  │  dispatch(webhook)     │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────▼────────────┐
          │    @flue/runtime        │
          │  ┌───────────────────┐  │
          │  │   createAgent()   │  │
          │  │  ┌─────────────┐  │  │
          │  │  │   Model     │  │  │  (Anthropic/OpenAI/etc)
          │  │  └─────────────┘  │  │
          │  │  ┌─────────────┐  │  │
          │  │  │   Tools     │  │  │  (typed actions)
          │  │  └─────────────┘  │  │
          │  │  ┌─────────────┐  │  │
          │  │  │   Skills    │  │  │  (SKILL.md, inlined)
          │  │  └─────────────┘  │  │
          │  │  ┌─────────────┐  │  │
          │  │  │ Subagents   │  │  │  (delegation)
          │  │  └─────────────┘  │  │
          │  │  ┌─────────────┐  │  │
          │  │  │  Sandbox    │  │  │  │
          │  │  │ virtual/local│  │  │  │
          │  │  │ /remote     │  │  │  │
          │  │  └─────────────┘  │  │
          │  │  ┌─────────────┐  │  │
          │  │  │  Session    │  │  │  │
          │  │  │  (history)  │  │  │  │
          │  │  └─────────────┘  │  │
          │  └───────────────────┘  │
          └────────────┬────────────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
    ┌────▼────┐  ┌────▼────┐  ┌────▼────┐
    │ Session │  │  File   │  │  Tool   │
    │  Store  │  │  System │  │  Call   │
    │ (Postgres│  │(sandbox)│  │(MCP/API)│
    │ /default)│  │         │  │         │
    └─────────┘  └─────────┘  └─────────┘
```

## 实用评估

### 什么场景值得用

- **TypeScript 全栈项目嵌入 Agent**: 如果你的技术栈是 TypeScript/Node.js，Flue 的原生 TS 支持意味着零桥接成本。Agent 可以直接 import 你项目中的工具函数、类型定义、配置。
- **CI/CD 自动化**: Flue 支持 GitHub Actions 和 GitLab CI/CD 部署，配合 local sandbox 可以直接操作代码仓库。适合代码审查、测试验证、依赖更新等场景。
- **多 Agent 协作系统**: 内置 subagent profile 让你可以定义专业化的子 Agent（如"政策研究员"、"代码审查员"），主 Agent 按需委派。这比手动编排多个 LangGraph 更简洁。
- **需要沙箱隔离的 SaaS**: 结合 Daytona 或 Cloudflare Sandbox 的 remote sandbox，可以为每个用户/租户提供隔离的 Agent 工作环境。

### 什么场景不值得用

- **Python 主导的技术栈**: Flue 是纯 TypeScript 框架。如果你的团队主要用 Python，LangGraph 或 CrewAI 是更自然的选择。
- **生产环境急需稳定框架**: 截至 2026-06-21，Flue 尚无正式 Release。API 可能随时变动，缺少生产案例和 bug 修复历史。
- **只需要简单 LLM 调用链**: 如果你的需求只是"调用 LLM → 解析结果 → 返回"，Flue 的沙箱、持久化、子 Agent 等重量级能力是过度设计。Vercel AI SDK 或直接的 LLM API 调用更合适。
- **需要丰富的预构建工具生态**: LangChain 拥有数百个预构建的 tool integrations（数据库、API、搜索引擎等）。Flue 目前工具生态处于早期阶段。

### 迁移成本

从 LangGraph 迁移到 Flue 的主要成本：

| 迁移项 | 估计工作量 | 说明 |
|--------|-----------|------|
| Agent 逻辑重写 | 高 | 从 Python graph 语法 → TypeScript file-based 定义 |
| 工具适配 | 中 | LangChain tools 需重写为 Flue typed tool 格式 |
| 沙箱替代 | 低 | Flue 内置沙箱，可能减少自行集成的工作量 |
| 持久化层 | 中 | 从 LangGraph checkpoint → Flue session store + db adapter |
| 部署配置 | 低 | Flue 支持 Node/Cloudflare/GitHub Actions |

如果是新项目，迁移成本为零——直接选择 Flue 即可。

## 对你的意义

结合 Ken 在 **Agent + UI** 方向的关注，Flue 值得留意的原因：

1. **TypeScript 原生 Agent 框架的崛起**: 随着 Vercel AI SDK、Flue 等框架的出现，TS 生态正在补齐 Agent 编排的能力短板。如果 Ken 的团队以 TS 为主，这类框架可能比 LangChain 更适合作为 Agent 基础设施。

2. **沙箱作为一等概念**: Flue 把沙箱从"可选插件"提升为"框架内置能力"。这反映了 Agent 框架的一个重要趋势——自主 Agent 必须运行在受控环境中，否则安全风险不可接受。这对 Ken 关注的 Agent Builder/Agent UI 方向有直接影响：任何面向用户的 Agent 产品都需要沙箱隔离。

3. **Astro 团队的工程品味**: Astro 在构建工具领域的成功（ISlands 架构、零 JS 默认值）证明了这个团队对"开发者体验"和"按需加载"的深刻理解。Flue 如果延续这种品味，有可能成为 TS 生态中 Agent 框架的"轻量级首选"。

**建议**: 关注，暂不引入。等待 1-2 个正式 Release 后再评估。但 Flue 的设计思路（file-based agent、三层沙箱、skill 编译时内联）值得在架构讨论中参考。

## 关键代码/配置片段

### Agent 定义（来自官方文档）

```typescript
// agents/repository-reviewer.ts
import { createAgent, type AgentRouteHandler } from '@flue/runtime';
import { local } from '@flue/runtime/node';
import reviewChecklist from '../skills/review-checklist/SKILL.md' with { type: 'skill' };
import { repositoryTools } from '../shared/repository-tools.ts';

export const description = 'Review the requested change and report only findings supported by evidence.';

export const route: AgentRouteHandler = async (_c, next) => next();

export default createAgent(() => ({
  model: 'anthropic/claude-sonnet-4-6',
  instructions: 'Review the requested change and report only findings supported by evidence.',
  cwd: '/srv/repositories/catalog-service',
  tools: repositoryTools,
  skills: [reviewChecklist],
  sandbox: local(),
}));
```

### 异步事件分发（来自官方文档）

```typescript
// Webhook 接收 → dispatch 到对应 Agent
import { dispatch } from '@flue/runtime';
import { flue } from '@flue/runtime/routing';
import { Hono } from 'hono';
import supportAssistant from './agents/support-assistant.ts';
import { verifySupportWebhook } from './shared/support-webhooks.ts';

const app = new Hono();

app.post('/webhooks/support-comments', async (c) => {
  const event = await verifySupportWebhook(c.req.raw);
  const receipt = await dispatch(supportAssistant, {
    id: event.ticketId,
    input: {
      type: 'support.comment.created',
      commentId: event.commentId,
      text: event.text,
    },
  });
  return c.json(receipt, 202);
});

app.route('/', flue());
```

### 虚拟沙箱工作流（来自官方文档）

```typescript
// 无 sandbox 配置 → 默认 virtual sandbox
import { createAgent, type FlueContext } from '@flue/runtime';

const reviewer = createAgent(() => ({
  model: 'anthropic/claude-sonnet-4-6',
  cwd: '/workspace',
}));

export async function run({ init, payload }: FlueContext<{ document: string }>) {
  const harness = await init(reviewer);
  await harness.fs.writeFile('document.md', payload.document);

  const session = await harness.session();
  await session.prompt('Review document.md and write your findings to review.md.');

  return { review: await harness.fs.readFile('review.md') };
}
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | Flue 内置 MCP Server 连接支持，将 MCP 作为一等工具集成方式，反映 MCP 正在被主流 Agent 框架采纳 |

---
[← Back to Deep Dives](./README.md)
