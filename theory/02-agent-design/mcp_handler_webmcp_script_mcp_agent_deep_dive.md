---
auto_generated: true
generated_at: "2026-09-24T08:00:55Z"
source_url: "https://vercel.com/changelog/webmcp-mcp-handler"
signal_type: "significant_update"
---
# mcp-handler 支持 WebMCP：一个 script 标签把 MCP 工具暴露给浏览器内 Agent (mcp-handler Adds WebMCP: Expose MCP Tools to In-Browser Agents with One Script Tag)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-24
>
> **项目/工具**: mcp-handler (Vercel) + WebMCP 标准桥接
> **链接**: https://vercel.com/changelog/webmcp-mcp-handler
> **核心定位**: 让你站点上已有的 MCP 工具，通过一行 `<script>` 直接暴露给浏览器内 Agent，并以登录用户身份免 OAuth 调用。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：`mcp-handler@2.2.0` 加入实验性 WebMCP 支持——把服务端已有的 MCP 工具「镜像」成页面内工具，浏览器 Agent 无需 OAuth 即可用当前登录态调用。
- **現在值得用嗎**：**看場景**。前提是你已在用 `mcp-handler` 提供 MCP 端点，且有同源 cookie 会话体系；纯服务端、无前端会话的项目不适用。
- **適合場景**：已有 Next.js/前端会话的 SaaS，希望让浏览器内 Agent 以「用户本人身份」调用只读工具。
- **不適合場景**：只有 bearer-token 鉴权的纯 API 服务；需要在调用前做二次确认/改变可见 UI 的高风险写操作。
- **與「传统后端 MCP 集成」核心差異**：后端集成由 AI 平台直接打你的服务端、绕过 Web UI；WebMCP 复用页面既有客户端逻辑与用户会话，Agent 与用户共享同一份 UI 上下文。

## 是什么 / 解决什么问题

传统上，让 AI 平台（Copilot、ChatGPT、Claude、Gemini 等）操作你的服务，走的都是**后端集成**路线：你按 MCP 或 OpenAPI 把工具注册给平台，平台直接和你的服务器通信。这条路线对服务端动作很合适，但对交互式 Web 应用有三个硬伤（来自 WebMCP 规范 README）：

1. **UI 被绕过、上下文丢失**：Agent 直连服务端，跳过了你的 Web UI 与浏览器体验。
2. **状态与鉴权需要复刻**：Web 开发者必须在另一个服务端复刻用户状态、当前上下文和凭证。
3. **开发者负担**：暴露站点的客户端能力要另写一套专用后端，而不是复用熟悉的客户端 JS。

WebMCP 提出的是**客户端侧替代方案**：让网页直接在页面脚本里定义工具，通过 `document.modelContext` 暴露给页面内 Agent。这样 Agent 可以「更直接、更可靠、更快」地完成用户目标，同时页面 UI 保持可见、状态保持同步。

`mcp-handler` 这次做的事，是把既有 MCP 端点**桥接**进这套浏览器侧标准：你不用重写工具，只要一个 script 标签，就能把服务端已经定义好的 MCP 工具注册到页面，并代理每次调用回你的 MCP 服务器。

## 技术架构拆解

### 核心设计决策

- **桥接而非重写**：`mcp-handler` 不要求你改工具定义。它由 MCP 端点自身生成一小段脚本，脚本列出端点工具、把**白名单子集**通过 `modelContext.registerTool()` 注册到页面。
- **登录态直通，免浏览器侧 OAuth**：工具调用经由页面的 `fetch` 发出，天然携带用户 session cookie——页面内 Agent 调用你的工具时，**是以「已登录用户」身份**，无需浏览器侧 OAuth 流程。
- **白名单是强制项**：`tools` 数组显式列出允许暴露给页面的工具名，未列出的**永不注册**。这是刻意的安全设计。
- **面向无状态端点**：桥接目标是无状态 MCP 端点，采用 `2025-06-18` Streamable HTTP 协议；支持 JSON 和有限 SSE 响应，跟随工具列表分页，**不管理 MCP 会话或持久通知流**。
- **无 provider 时静默 no-op**：在没有 WebMCP provider 的浏览器里，脚本什么都不做，因此可以安全地先上线。

### 与前版/竞品的关键差异

| 维度 | 后端 MCP 集成（传统） | 本工具（Bridge to WebMCP） |
|------|----------------------|---------------------------|
| 通信路径 | AI 平台 → 你的服务端 API | 页面脚本 → MCP 端点（同源 fetch） |
| 鉴权 | 需在服务端复刻凭证 / OAuth | 直接复用浏览器 session cookie |
| UI 同步 | 前端状态与可见 UI 需间接推断 | 复用页面客户端逻辑，UI 与状态同源 |
| 工具暴露范围 | 服务端全量 | 页面内 Agent 仅见白名单子集 |
| 是否替换工具定义 | — | 否，桥接既有 MCP 工具 |
| 浏览器依赖性 | 无 | 需 WebMCP provider（Chrome origin trial），当前实验性 |

### 架构/信息流图

```
┌──────────────┐   1. 用户 prompt    ┌─────────────────┐
│ 浏览器内 Agent │ ─────────────────▶ │  AI agent 平台   │
└──────┬───────┘                    └─────────────────┘
       │ 3. 调用页面内 WebMCP 工具
       ▼
┌──────────────────────────────────────────────┐
│ 运行中的页面 index.html                        │
│  <script src="/api/mcp?webmcp-script" async>  │
│         │ 列出工具 + 注册白名单                 │
│         ▼                                      │
│  document.modelContext.registerTool(...)       │
│         │ 4. execute → fetch 同源调用          │
│         ▼                                      │
│  MCP 端点 /api/mcp  (mcp-handler)              │
│         │ tools/call（携带 session cookie）    │
│         ▼                                      │
│  服务端逻辑 → 返回结果 → 页面更新状态与 UI      │
└──────────────────────────────────────────────┘
       │ 6. WebMCP 工具结果
       ▼
```

关键点：**站点自己的代码执行动作并保持 UI 同步**（规范 README 的 sequence 图明确指出），这解决了后端集成的「前端状态必须被间接推断和操控」问题。

### 可配置项（来自官方 WEBMCP.md）

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `tools` | 是 | — | 暴露给页面的工具白名单；未列出的永不注册 |
| `credentials` | 否 | `"same-origin"` | 页面发起 fetch 的 credentials 模式（`same-origin`/`include`/`omit`） |
| `cacheControl` | 否 | `"public, max-age=300"` | 脚本响应的 `Cache-Control` 头 |

## 实用评估

### 什么场景值得用

- **已有同源 cookie 会话的 SaaS/内部工具**：想让浏览器内 Agent 以用户本人身份调用只读工具（如「查我的订单」「查文档」），桥接几乎零改造。
- **前端逻辑可复用的交互式应用**：工具的 `execute` 可直接复用页面既有客户端代码并同步 UI，避免为 Agent 重写一套后端。
- **渐进式试水**：由于无 provider 时是 no-op，可以先埋脚本，等 Chrome origin trial 覆盖到位再启用。

### 什么场景不值得用

- **只有 bearer-token 鉴权的纯 API 服务**：桥接调用会是**未认证**的，除非 verifier 同时接受 session cookie；否则需要额外的同源 session/BFF 层，官方明确警告**不要把 access token 放进生成的脚本**。
- **高风险写操作**：白名单内的任何工具都可能被页面内**任意脚本或 Agent** 用用户凭证调用。官方建议「优先只读工具；对带副作用的工具，把它当作同站表单提交来对待」。
- **需要调用前确认/变更 UI 的场景**：应改为在页面内注册客户端工具（而非走桥接），以便请求确认、失效缓存或跟随组件生命周期。
- **依赖 MCP 会话/持久通知**：桥接不支持 MCP session 管理或持久通知流。
- **非 Chromium / 未开 provider 的环境**：WebMCP 当前需安全上下文 + origin-isolated 文档；跨域 iframe 需显式暴露。规范状态为 W3C Web Machine Learning CG 提案、活跃开发中，API 与浏览器可用性均可能变化。

### 迁移成本

- **已是 `mcp-handler` 用户**：升级到 `mcp-handler@2.2.0`，在 `createMcpHandler` 第二参数加 `experimental_webMcp.tools` 白名单，页面加一行 `<script>`——工作量约「改几行配置」。
- **非 `mcp-handler` 用户**：需要先有 MCP 端点（或采用 `mcp-handler`），并确保存在同源 cookie 会话体系；若原本是 bearer-only，则要额外搭同源 session/BFF 层，成本显著上升。

## 对你的意义

如果你在做 **Agent + UI** 方向的产品，这是一个明确的信号：**Agent 与 Web UI 的交互范式正在从「DOM 抓取/模拟点击」转向「页面主动声明工具」**。规范 README 把旧路径描述为 Agent 依赖截图、DOM/可访问性树快照、模拟人类输入——脆弱且不可靠；WebMCP 让**站点方**可以决定「是否、以及如何」让 Agent 与自己交互，这把控制权还给了 Web 开发者。

具体建议：**观望 + 埋点试水**。把桥接当作「让浏览器内 Agent 复用你 MCP 工具」的低成本实验，但先只暴露只读工具，并把 `Sec-Fetch-Site: same-origin` 校验、CSP nonce 等加固项一并做好。等 Chrome origin trial 稳定、`document.modelContext` API 冻结后再上生产。

## 关键代码/配置片段

**1. 在既有 MCP handler 上启用桥接（Vercel changelog / WEBMCP.md）**

```typescript
// app/api/mcp/route.ts
import { createMcpHandler } from "mcp-handler";

const handler = createMcpHandler(
  (server) => {
    // Register your MCP tools here.
    server.registerTool("roll_dice", /* ... */);
  },
  {
    experimental_webMcp: {
      // Only these tools are exposed to in-page agents.
      tools: ["roll_dice", "search_docs"],
    },
  },
);

export { handler as GET, handler as POST };
```

**2. 页面引入（依次为：直接引入 / 需顺序加载时用 defer）**

```html
<script src="/api/mcp?webmcp-script" async></script>

<!-- 有依赖顺序时：先 polyfill 后桥接 -->
<script src="/your-webmcp-polyfill.js" defer></script>
<script src="/api/mcp?webmcp-script" defer></script>
```

**3. 加固：cookie 鉴权 gate 到同源 + CSP nonce（来自 WEBMCP.md Hardening）**

```html
<script src="/api/mcp?webmcp-script" nonce="<your-request-nonce>" async></script>
```

> 官方说明：同源 MCP 端点下，浏览器的桥接工具调用带 `Sec-Fetch-Site: same-origin`。若 verifier 接受 session cookie，应拒绝来自其他来源的 cookie 鉴权调用（对 bearer 客户端不受影响），并设 `required: true`，避免被拒/缺失的 session 退化为未认证执行。

**4. 规范的底层 API（WebMCP README，供理解桥接目标）**

```js
// 页面侧注册工具
await document.modelContext.registerTool({
  name: "add-todo",
  description: "Add a new item to the user's active todo list",
  inputSchema: {
    type: "object",
    properties: { text: { type: "string" } },
    required: ["text"],
  },
  async execute({ text }) {
    await addTodoItemToCollection(text);
    return { content: [{ type: "text", text: `Added: "${text}"` }] };
  },
});

// Agent 侧发现与调用
const tools = await document.modelContext.getTools();
const t = tools.find((x) => x.name === "add-todo");
await document.modelContext.executeTool(t, { text: "Buy groceries" });
```

> 说明：桥接使用默认的 **same-origin exposure**；跨域 iframe 需显式 `exposedTo` 或 Permissions Policy `allow="tools"`。规范 README 提醒：模型上下文有限，注册过多工具会消耗 token、增加延迟并降低工具选择准确率——建议**动态注册/注销**（`AbortSignal`）而非一次性注册全量。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | WebMCP 明确「与 MCP 共享工具/参数/模式的通用词汇」并沿用 MCP 的 tools 语义；`mcp-handler` 让既有 MCP 端点零改造接入浏览器侧——MCP 正从服务端标准扩展为跨端（服务端 + 页面内）的工具集成底座 |

---
[← Back to Deep Dives](./README.md)
