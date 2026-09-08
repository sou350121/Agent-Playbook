---
auto_generated: true
generated_at: "2026-09-08T08:06:54Z"
source_url: "https://vercel.com/changelog/build-and-deploy-eve-agents-from-the-vercel-dashboard"
signal_type: "significant_update"
---
# Vercel Dashboard 原生支持 Eve Agent 部署 (Vercel Dashboard Native Support for Eve Agent Deployment)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-08
>
> **项目/工具**: Vercel Dashboard + Eve Agent Framework
> **链接**: https://vercel.com/changelog/build-and-deploy-eve-agents-from-the-vercel-dashboard
> **核心定位**: Vercel 将 AI Agent 的创建和部署从 CLI 命令行推向可视化 Dashboard，Agent 首次成为与 Web 应用同等的一等部署公民。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Vercel Dashboard 新增 Agent 创建入口，用户可在浏览器中零代码生成、配置并部署一个可对话的 AI Agent，底层由 Eve 框架驱动。
- **現在值得用嗎**：是 — 适合快速原型验证和内部工具搭建；生产级复杂 Agent 仍需自定义代码。
- **適合場景**：快速搭建客服/内部助手、验证 Agent 想法、No-code/Low-code 团队快速上线。
- **不適合場景**：需要复杂自定义逻辑、非 Vercel 基础设施依赖、高并发生产级部署。
- **與傳統 CLI 部署的核心差異**：从 `npx eve@latest init` + 手动配置 → 浏览器点点点完成脚手架、模型选择、渠道接入、工具连接全流程。

## 是什么 / 解决什么问题

AI Agent 的部署长期存在一个断层：开发者可以用 LangChain、LlamaIndex 等框架写出 Agent 逻辑，但将其部署为可访问的服务需要自行处理基础设施——选择云服务商、配置域名、设置 CI/CD、管理环境变量。对于非技术背景的团队成员（产品经理、运营），这个门槛几乎是不可逾越的。

Vercel 此次更新将 Agent 部署提升为 Dashboard 中的一等公民。用户在 Vercel Dashboard 中点击 "Add New → Agent"，即可在浏览器中完成：

1. 编写 Agent 的身份指令（System Prompt）
2. 选择通过 Vercel AI Gateway 可用的任意模型
3. 添加 Next.js Web 聊天界面或 Slack 频道作为交互渠道
4. 通过内置连接（Linear、Notion）或自定义 MCP Server 为 Agent 添加工具

整个过程无需打开终端、无需编写配置文件、无需管理 Git 仓库——Vercel 自动完成脚手架创建、私有 Git 仓库初始化、项目部署。

这标志着 Agent 部署范式的一个重要转折：从 "开发者工具" 走向 "平台能力"。Vercel 在 Web 应用部署领域已经建立了事实标准（Next.js 的默认宿主），现在正将这一优势延伸到 Agent 部署。

## 技术架构拆解

### 核心设计决策

**决策 1：Agent 作为一等部署单元**

Vercel 传统上以 "Project" 为部署单元（Web 应用、API Routes、Serverless Functions）。现在 Agent 成为新的 Project 类型，享有同等的部署流水线、域名分配、环境变量管理、预览部署等能力。这意味着 Agent 不再是一个 "附属功能"，而是与 Web 应用平起平坐的独立产品。

**决策 2：Eve 框架作为底层引擎**

Eve 是 Vercel 自研的开源 Agent 框架（`npx eve@latest`），其设计理念是 "Like Next.js for agents"。选择自有框架而非 LangChain 等第三方方案，使 Vercel 能深度优化部署体验，但也带来了框架锁定风险。

**决策 3：Vercel AI Gateway 作为模型路由层**

Agent 不直接绑定特定模型，而是通过 Vercel AI Gateway 选择模型。这提供了模型灵活性（可随时切换底层模型），同时让 Vercel 掌握了模型调用的计量和计费层。

**决策 4：内置工具连接 + MCP 扩展**

Vercel 预置了 Linear、Notion 等常用 SaaS 的工具连接，降低入门门槛；同时支持自定义 MCP Server，为高级用户保留扩展能力。

### 与之前部署方式的关键差异

| 维度 | 之前（CLI + 手动） | 现在（Dashboard） |
|------|-------------------|-------------------|
| 创建方式 | `npx eve@latest init` 命令行 | Dashboard 点击 "Add New → Agent" |
| 模型选择 | 手动配置 API Key 和模型参数 | Dashboard 下拉选择 AI Gateway 可用模型 |
| 渠道接入 | 自行编写 Web Chat 或 Slack Bot 代码 | 一键启用 Next.js Web Chat 或 Slack 频道 |
| 工具连接 | 手动编写 MCP Server 或 API 调用 | 内置 Linear/Notion 连接 + 自定义 MCP |
| Git 管理 | 开发者自行初始化和管理 | Vercel 自动创建私有 Git 仓库 |
| 部署 | 手动 `vercel deploy` | 保存即部署，自动分配域名 |
| 目标用户 | 开发者 | 开发者 + 产品经理 + 运营 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                  Vercel Dashboard                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Identity  │  │  Model   │  │   Channels &     │  │
│  │ (Prompt)  │  │ (AI GW)  │  │   Tools          │  │
│  └────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
│       └──────────────┴──────────────────┘           │
│                     │                               │
│            ┌────────▼────────┐                      │
│            │   Eve Framework │                      │
│            │  (Durable Exec) │                      │
│            └────────┬────────┘                      │
└─────────────────────┼───────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   Next.js Chat   Slack Channel   API Endpoint
   (Web UI)       (Messaging)     (Programmatic)
```

### Eve 框架核心能力

根据 eve.dev 官方文档，Eve 框架提供以下生产级能力：

| 能力 | 说明 |
|------|------|
| **Durable Execution** | 工作流持久化，崩溃重启后从检查点恢复；Agent 等待时暂停，收到消息后恢复 |
| **Sandboxed Compute** | Agent 代码在隔离沙箱中执行，文件系统访问、Bash 执行完全隔离 |
| **Multi-Channel Delivery** | 同一 Agent 代码库可部署到 Web Chat、Slack、API、Cron、CLI 等多个渠道 |
| **Human-in-the-Loop** | 需要确认的工具调用触发审批门，会话暂停直到人工响应后继续 |
| **Subagents** | 将专业任务委派给子 Agent，各自拥有独立的 Prompt、工具和沙箱 |
| **Evaluations** | 定义测试套件和评分标准，每次部署和定时运行评估 |

## 实用评估

### 什么场景值得用

- **快速原型验证**：产品经理或设计师可以在 5 分钟内搭建一个可对话的 Agent 原型，验证想法后再投入开发资源。
- **内部工具/助手**：团队内部的知识问答、工单处理、数据查询等场景，内置的 Linear/Notion 连接可直接使用。
- **Slack 集成场景**：一键启用 Slack 频道，适合需要在工作流中嵌入 Agent 的团队。
- **Vercel 现有用户的自然延伸**：已经使用 Vercel 部署 Next.js 应用的团队，Agent 可以作为同一项目的一部分部署。

### 什么场景不值得用

- **复杂自定义逻辑**：Dashboard 配置能力有限，需要复杂业务逻辑的 Agent 仍需回到代码层面。
- **非 Vercel 基础设施**：如果团队的基础设施在 AWS/GCP/Azure，将 Agent 单独放在 Vercel 会增加架构复杂度。
- **高并发生产部署**：Eve 框架相对年轻（2025 年发布），大规模生产验证数据有限。
- **模型灵活性要求极高**：虽然通过 AI Gateway 支持多模型，但仍在 Vercel 生态内，无法自由使用任意 API。

### 迁移成本

- **从 CLI Eve 迁移到 Dashboard**：零成本。Dashboard 创建的 Agent 底层仍是 Eve 框架，代码可自定义。
- **从 LangChain/LlamaIndex 迁移**：中等成本。需要重写 Agent 逻辑为 Eve 框架的 API，但 Dashboard 降低了部署环节的成本。
- **从自建部署迁移**：需要评估 Vercel 定价与自建成本的对比，但部署运维成本会显著降低。

## 对你的意义

作为关注 Agent + UI 方向的开发者，这个变化有几个值得注意的信号：

1. **Agent 部署平台化趋势确认**：Vercel 将 Agent 提升为一等公民，意味着 Agent 部署正在从 "开发者手工操作" 走向 "平台标准化服务"。这与你关注的 Agent UI 方向直接相关——当部署门槛降低，Agent 的数量会激增，Agent UI/UX 的重要性会同步上升。

2. **Eve 框架值得跟踪**：作为 "Next.js for Agents"，Eve 的 Durable Execution + Sandbox + Multi-Channel 设计代表了 Agent 框架的一个清晰方向。如果你的项目涉及 Agent 部署，Eve 是一个值得评估的选项。

3. **MCP 生态集成加速**：Vercel 内置自定义 MCP Server 支持，说明 MCP 作为 Agent 工具集成标准正在被主流平台采纳。这与假设 A-001（MCP 成为 AI Agent 工具集成事实标准）形成呼应。

**建议**：可以花 30 分钟在 Vercel Dashboard 上创建一个测试 Agent，体验从创建到部署的全流程。不需要立即投入生产，但了解平台能力边界对后续架构决策有帮助。

## 关键代码/配置片段

### Eve 框架初始化（CLI 方式，Dashboard 的等价操作）

```bash
npx eve@latest init my-agent
```

### Next.js 集成示例

```typescript
// 将 Agent 挂载到现有 Next.js 应用
import { withEve } from 'eve'

export default withEve({
  // Agent 配置
})
```

### Dashboard 配置能力（非代码，可视化操作）

- **Identity**：编写 System Prompt 定义 Agent 身份和行为
- **Model**：从 Vercel AI Gateway 可用模型列表中下拉选择
- **Channel**：勾选启用 Next.js Web Chat 或 Slack 频道
- **Tools**：启用内置连接（Linear、Notion）或配置自定义 MCP Server URL

---
[← Back to Deep Dives](./README.md)
