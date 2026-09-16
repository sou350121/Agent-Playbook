---
auto_generated: true
generated_at: "2026-09-16T03:30:53Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/build-interactive-mcp-apps-using-amazon-bedrock-agentcore/"
signal_type: "significant_update"
---
# 用 Amazon Bedrock AgentCore 构建交互式 MCP Apps (Building Interactive MCP Apps on Amazon Bedrock AgentCore)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-16
>
> **项目/工具**: MCP Apps + Amazon Bedrock AgentCore（AgentCore Runtime + AgentCore Gateway）
> **链接**: https://aws.amazon.com/blogs/machine-learning/build-interactive-mcp-apps-using-amazon-bedrock-agentcore/
> **核心定位**: 把「返回一段文本」的 MCP 工具升级为「在 AI host 里直接渲染交互式 HTML widget」的标准化应用形态，并给出在 AWS 托管运行时上部署的完整参考架构。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：MCP Apps 是 MCP 的官方扩展，让 MCP server 返回可在 AI host（ChatGPT / Claude 等）内渲染的交互式 HTML widget；AWS 这篇博客给出用 AgentCore 托管这类 app 的架构与部署路径。
- **現在值得用嗎**：看场景——如果你正在做「AI 聊天界面里嵌交互 UI」的产品，且已经或打算用 MCP 做工具层，值得立即评估；如果你只是做普通后端 API，别为它引入额外抽象层。
- **適合場景**：需要在对话里展示可交互的数据/表单/监控面板；需要一次开发、多 host（ChatGPT + Claude）复用同一份 UI；需要官方沙箱安全模型。
- **不適合場景**：纯文本/CLI 交互即可满足；UI 需要与宿主深度耦合且无法忍受 iframe 隔离；不想把运行时绑定到特定云（本案例强依赖 AgentCore）。
- **與传统 MCP 工具核心差異**：传统工具只能返回 text/image/resource/structured data 让 host 以文本形式展示；MCP Apps 额外声明一个 `ui://` 资源，host 会在沙箱 iframe 内渲染自包含 HTML，并通过 postMessage 做双向通信。

## 是什么 / 解决什么问题

MCP（Model Context Protocol）解决的是「让 AI host 能调用外部工具」的问题，但它长期有个体验瓶颈：工具返回值最终都要被压成文本或简单结构化数据，再由 host 用自己的方式渲染。用户问「展示所有可租的独角兽」，结果只能拿到一段列表文字——数据是到了，但交互没有了。

MCP Apps 直接补上这一环。它是 MCP 的官方扩展，允许 server 在工具描述里声明一个指向 `ui://` 资源的引用；当 LLM 决定调用该工具时，host 会去取回这段 HTML，并在会话内以沙箱 iframe 渲染。由此得到几个独立 Web App 做不到的能力：

- **上下文保留**：UI 就长在对话里，用户不切标签页、不丢上下文；
- **双向数据流**：widget 能调用 server 上的任意工具，host 也能把新结果推回 widget；
- **复用宿主能力**：widget 可以把动作（如「安排这个会议」）委托给 host，由 host 走用户已连接的能力完成，而不必每个 app 自己接一遍邮件/日历提供商；
- **安全保证**：widget 运行在 host 控制的沙箱 iframe 中，无法访问父页面、窃取 cookie 或逃逸容器。

AWS 这篇博客的价值不在发明协议，而在把它「落地」：它演示如何把 MCP App 部署到 Amazon Bedrock AgentCore 上，让一个 server 同时被 ChatGPT、Claude 或其他支持 Apps 扩展的 host 复用，体验一致。配套示例是「Unicorn Rentals」——用户可以浏览独角兽、下单租赁、查看进行中的预订、归还独角兽。

## 技术架构拆解

### 核心设计决策

- **把交互 UI 建模为 MCP Resource，而不是自定义协议**：widget 就是一段自包含 HTML，通过标准 `resources/read` 返回；tool 只用 `_meta.ui.resourceUri` 指向它。好处是复用了 MCP 现有的发现与读取语义，host 不需要新造一套加载机制。
- **工具与 UI 解耦，按需渲染**：不是每个工具都需要 widget。示例中 `view_bookings`、`return_unicorn` 就返回纯文本并**完全跳过** widget 渲染阶段——避免为简单请求强加 rich UI 开销。
- **托管运行时承担「无差别重活」**：AgentCore Runtime 提供安全、无服务器、会话隔离、原生支持 MCP 的宿主；AgentCore Gateway 用单一安全端点对外暴露。这样团队只需专注业务逻辑与 widget 设计。
- **凭据不落调用方**：Gateway 对外接受请求（示例用 No Auth 入站），再用自己的 IAM 执行角色通过 SigV4 调用 runtime；外部调用方无需自己处理 AWS 凭据。
- **最小权限**：runtime 的资源策略只允许 Gateway 执行角色调用，其余 principal 一律拒绝。

### 与前版/竞品的关键差异

| 维度 | 传统 MCP 工具 | MCP Apps（本方案） |
|------|--------------|-------------------|
| 返回形态 | text / image / resource / structured data | 上述 + 可交互 HTML widget |
| 渲染责任 | host 自行决定如何展示 | host 在沙箱 iframe 内渲染 `ui://` 资源 |
| 交互性 | 基本无（只能再发一轮 prompt） | widget 可调工具、可被 host 推送新数据 |
| 安全边界 | 数据层隔离 | 沙箱 iframe + postMessage，明确 capability 授权 |
| 跨 host 一致性 | 依赖 host 文本渲染 | 同一 server 在 ChatGPT / Claude 表现一致 |

### 架构/信息流图

```
        注册阶段（一次性）
  ┌───────────────────────────────────────────┐
  │ AI Host  ── tools/list / resources/list ──▶│
  │                AgentCore Gateway           │
  │          (AWS WAF: IP allowlist+managed)   │
  │                     │ IAM 执行角色 (SigV4) │
  │                     ▼                      │
  │              AgentCore Runtime             │
  │              (托管 MCP App)                │
  └───────────────────────────────────────────┘

        调用阶段（每次用户请求）
  自然语言 ──▶ Host 翻译为 tools/call ──▶ WAF ──▶ Gateway
        ──▶ Runtime(MCP App) ──▶ Lambda(业务逻辑) ──▶ DynamoDB
        ◀── 结果包为 MCP 格式返回

        渲染阶段（仅当工具带 ui:// 资源）
  Host ── resources/read(ui://widget/unicorn-list) ──▶ MCP App
       ◀── 自包含 HTML ──▶ 沙箱 iframe 内渲染
                └─ 注入 structuredContent（tool 响应数据）
                └─ 图片经 CloudFront（S3 源站）拉取
```

### 关键实现要点（来自官方示例）

MCP App 本身是一个 TypeScript 应用，构建在官方 `@modelcontextprotocol/sdk` 加 `@modelcontextprotocol/ext-apps` 扩展之上，作为 Express.js HTTP 服务器运行，由 AgentCore Runtime 内部管理。

- **注册工具**：用 `registerAppTool(name, config, handler)` 注册 `list_unicorns`、`book_unicorn` 等。工具配置里的 `_meta.ui.resourceUri` 字段告诉 host「这次响应该渲染哪个 widget」；`tools/call` 响应中的 `structuredContent` 承载数据载荷，由 host 在渲染时注入 widget。
- **注册 widget**：用 `registerAppResource(name, URI, handler)` 注册资源，handler 返回 widget 的 HTML。示例注册了 `unicorn-list-widget`。
- **部署**：构建过程把代码打成 zip → 上传 S3 → 创建引用它的 AgentCore runtime 资源；配置指定 `NODE_22` 环境、入口和 MCP 协议模式（声明为 MCP server 可激活协议专属优化）。

MCP Apps 扩展本身的通信是「MCP 的一个方言」：app 与 host 通过 JSON-RPC 交互，部分请求/通知复用核心 MCP（如 `tools/call`），部分相似（如 `ui/initialize`），多数以 `ui/` 前缀新定义。widget 与宿主之间的所有通信都走 `postMessage`。

## 实用评估

### 什么场景值得用

- **在聊天里嵌交互式数据探索**：比如「按区域展示销售」，widget 可渲染可点击下钻的地图，无需再发 prompt；
- **多选项配置表单**：部署配置有几十个相互依赖的选项，用一个表单一次性呈现默认值+校验，胜过十几轮来回对话；
- **富媒体查看**：预览 PDF、3D 模型、生成图，内嵌真正的 viewer（平移/缩放/旋转）；
- **实时监控面板**：维持持久连接，数据变化时主动更新；
- **多步工作流**：审批报销、审阅代码变更、issue 分诊——需要导航控件、操作按钮和跨交互持久的 state。

前提条件是：你确实需要「UI 与 LLM 对话紧耦合」，并且愿意接受 host 的沙箱模型。

### 什么场景不值得用

- **纯文本/CLI 就够的场景**：引入 widget 与 `ui://` 资源只会增加复杂度；
- **需要突破 iframe 隔离的 UI**：沙箱刻意禁止访问父页面 DOM / cookie / localStorage、禁止导航父页面，别指望绕过；
- **不愿绑定特定托管栈的团队**：本案例的运行时、网关、鉴权链强依赖 Amazon Bedrock AgentCore 及其 IAM/SigV4/WAF 体系；MCP Apps 协议本身是 host-agnostic，但**这套部署路径不是云中立的**；
- **信息尚未公开的部分**：AWS 博客未给出性能/延迟 benchmark、定价与配额数字，也没有 OAuth 路径的完整示例——涉及这些指标的选型需自行实测，勿据本文推断。

### 迁移成本

从「普通 MCP server」迁移到「MCP App」主要工作量在于：

1. 把 UI 从无到有写成自包含 HTML（含内联 JS/CSS），并注册为 resource；
2. 给需要渲染的工具补上 `_meta.ui.resourceUri`，并确保 `structuredContent` 结构与 widget 期望一致；
3. 若走 AgentCore 托管：新增 Runtime + Gateway + WAF 的部署编排与 IAM 角色/资源策略；
4. host 侧需支持 MCP Apps 扩展，否则退回文本渲染。

对已有 MCP server 而言，(1)(2) 是核心增量；纯业务逻辑（Lambda + DynamoDB）基本可复用。

## 对你的意义

这条线正落在你 AI 应用监控里「Agent + UI」的核心方向上。MCP Apps 的意义在于它把「Agent 的工具层」和「Agent 的交互层」用同一个协议对齐了：tool 通过 `_meta.ui.resourceUri` 与 `ui://` 资源把 UI 一起声明出去，host 负责安全渲染。这正好呼应你配置里反复出现的「tool calling / agent 架构 / multimodal」交叉信号。

具体建议：

- **立即试用**——如果你有一个用 MCP 暴露能力的项目，挑一个「返回结构化数据但展示体验差」的工具，按官方 sample（`aws-samples/sample-agentcore-mcp-apps`）做一个 widget 原型，验证「同 server 在 ChatGPT 与 Claude 体验一致」这一点是否成立。
- **观望**——如果你还没上 MCP，或当前宿主不支持 Apps 扩展，先把协议层对齐，UI 层不必抢跑。
- **跳过**——如果你的场景就是 CLI/后端服务，MCP Apps 不带来价值。

一个待验证的观察：MCP Apps 让 server 作者能以纯 HTML 交付 UI，这会**抬高 MCP 生态里「交互标准」的竞争门槛**——值得持续跟踪其他 host 是否跟进支持 `ui://` 资源与 `ui/` 方法族。

## 关键代码/配置片段

以下为源材料中明确出现的接口与字段（非虚构，摘自 AWS 官方博客的架构说明）：

```text
# 工具注册：声明该工具的响应由哪个 widget 渲染
registerAppTool(name="list_unicorns", config, handler)

# 工具配置中的 UI 绑定字段
_meta.ui.resourceUri = "ui://widget/unicorn-list"

# tools/call 响应：承载注入 widget 的数据载荷
structuredContent = { ... }

# widget 资源注册：handler 返回 HTML
registerAppResource(name, uri, handler)   # 例：unicorn-list-widget

# 运行时配置（部署时）
environment = "NODE_22"
entry point + MCP protocol mode
```

```text
# 渲染触发的判据
if tool has associated resource URI (e.g. ui://widget/unicorn-list):
    host → resources/read(uri) → MCP App 返回自包含 HTML → 沙箱 iframe 渲染
else:
    return text-only        # 如 view_bookings / return_unicorn，跳过渲染阶段
```

> TODO: AWS 博客未公开 widget 加载延迟、Gateway 吞吐/配额、以及 No Auth 入站之外的完整鉴权（OAuth）配置样例，需查阅 AgentCore 官方文档补齐。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | MCP Apps 作为 MCP 官方扩展，把「工具 + 交互 UI」纳入同一协议并由多家 host（ChatGPT/Claude）复用，强化 MCP 作为集成标准的地位；AWS 官方博客背书其企业级落地路径。 |

---
[← Back to Deep Dives](./README.md)
