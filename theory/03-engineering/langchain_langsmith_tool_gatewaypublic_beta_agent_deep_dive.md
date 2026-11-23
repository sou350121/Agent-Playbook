---
auto_generated: true
generated_at: "2026-11-23T03:30:51Z"
source_url: "https://www.langchain.com/blog/langsmith-tool-gateway"
signal_type: "blog_post"
---
# LangSmith Tool Gateway：把 Agent 工具调用收进统一治理层 (LangSmith Tool Gateway: A Managed Tool Layer for Governed Agent Tool Use)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-23
>
> **项目/工具**: LangSmith Tool Gateway（LangChain / LangSmith Agent Platform）
> **链接**: https://www.langchain.com/blog/langsmith-tool-gateway
> **核心定位**: 一个托管式工具中间层——让所有 Agent 的工具调用经由单一 URL 路由，由平台统一处理凭证、身份、策略与审计，替代每个 Agent 各自手写 OAuth 的做法

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：把「工具调用」从散落在各个 Agent 代码里的 OAuth 与 token 管理，提升为平台级的基础设施：一个 kit URL + 统一身份解析 + 策略 + 全链路追踪。
- **現在值得用嗎**：看場景。如果你已经把 Agent 放进生产、服务成百上千用户且每个用户权限不同——值得立刻在内部跑 PoC；如果还在本地原型阶段，硬编码 token 依然更快。
- **適合場景**：多用户 SaaS 型 Agent、后台常驻/定时触发的 Agent、MCP 服务器数量已经多到难以人工管控的团队、有合规审计要求的企业。
- **不適合場景**：单用户本地脚本、只需要 2-3 个工具的小项目、强依赖离线/私有环境的团队（托管层意味着请求要经过 LangSmith）。
- **與前版/竞品核心差異**：它和已有的 LLM Gateway 形成对称结构——LLM Gateway 管「模型调用」，Tool Gateway 管「工具调用」；核心卖点不是新协议，而是把 MCP 工具接入从「每 Agent 一套 auth」变成「注册一次、按 kit 分发」。

## 是什么 / 解决什么问题

LangChain 在 LangSmith Agent Platform 上发布 Tool Gateway 的 Public Beta。官方 blog 的出发点很明确：Agent 正在从「聊天窗口里等提示词」走向「按时间表或事件自主触发、长时间无人值守地工作」。这带来一个被低估的工程债——**每一个 Agent 调用每一个工具，都涉及「用谁的身份、能调哪些工具、留下什么记录」三个问题**，而这三个问题在原型阶段通常被硬编码糊过去了。

blog 里给了一个非常具象的例子：一家美国大型零售商为门店运营和库存管理构建 Agent。一个是店员助手，需要用**每位店员自己的身份**访问库存、排班和邮件系统；另一个是每天凌晨 3 点运行的库存对账 Agent，用**自己的服务凭证**。他们的工程团队已经搭建了 50+ 个 MCP 服务器，暴露的工具超过 1000 个。但每个 Agent 只应该使用其中一小部分已批准的工具，并且必须在正确的上下文里使用正确的凭证。

问题在于：当凭证硬编码进 Agent，或者直接把一整个工具服务器丢给 Agent 时，**没有任何确定性检查能阻止 Agent 用错凭证或调用未批准的工具**；而且因为缺乏端到端可见性，安全团队根本无从审计。Tool Gateway 就是对这个问题的产品化回答。

## 技术架构拆解

### 核心设计决策

- **单一入口 URL**：所有调用方（Agent、coding agent、后端服务）都指向同一个 kit URL，由网关在每次调用时解析身份、管理访问、记录 trace。这正是 MCP 生态最缺的那层「中间人」。
- **工具注册一次，按 kit 分发**：MCP 服务器按 URL 注册一次即可；用「tool kit」把工具子集打包成单一 URL，Agent 接入 kit 后**只能看见 kit 里的工具**。这是把权限边界从「约定」变成「结构性不可见」。
- **大 kit 用 search mode 降载**：当 Agent 面对成百上千个工具时，一次性加载全部工具会拉高延迟并让选工具变难；search mode 让 Agent 先查询自己的 kit，只加载当前任务相关的工具。这是对「工具太多反而更差」这一现实问题的正面回应。
- **双身份模型**：`Acting as the user`（用用户自己的凭证，IdP 如 Okta / Entra ID 识别身份，用户只需连接一次账户；未连接时调用返回登录链接，认证后自动继续）与 `Acting as the agent`（凭证绑定 Agent 本身，通过 agent auth 或 workspace admin 配置一次的 profile 实现共享凭证复用）。这一层解决的就是上面零售商案例里「店员助手 vs 凌晨对账 Agent」的分野。
- **策略分两层**：Deny policies 可按用户、service key 或两者组合在 org / workspace 级别阻断工具使用（也可「对所有人禁用、白名单例外」）；Approval policies 对敏感调用插入 human-in-the-loop，例如「写数据仓库」前必须有人确认。
- **内置服务器省掉 OAuth 工程**：Google、Microsoft、Salesforce、GitHub、Linear、LinkedIn 由 LangSmith 托管 OAuth app；Exa、Tavily、Apollo、Ashby、Pylon、parallel search、网页读取等走 API key。对内置服务器，无需自建服务器、也无需注册 OAuth app。
- **客户端无关**：网关兼容任何 MCP client，官方点名包括 LangChain、Deep Agents、Managed Deep Agents、Claude Code 与 Cursor。

### 与前版/竞品的关键差异

| 维度 | 硬编码 / 直连 MCP 服务器 | Tool Gateway |
|------|------------------------|--------------|
| 凭证管理 | 每个 Agent 手写一份 OAuth 流程，token 存在 Agent 旁边 | 平台统一托管，用户连接一次即可 |
| 工具可见性 | Agent 能看到整个工具服务器的全部工具 | 只能看见所属 kit 内的工具 |
| 权限边界 | 依赖代码正确性，无确定性检查 | Deny / Approval 策略在网关层强制执行 |
| 多用户身份 | 自建 token 刷新与映射 | `Acting as user` 通过 IdP 自动解析 |
| 审计 | 需要跨多个平台拼 trace 与日志 | 每次调用在 Agent trace 与 Enterprise 审计日志中留一条记录 |
| 新增工具成本 | 每接入一个工具都要改路由 | 注册服务器一次，加入 kit 即对所有 Agent 生效 |
| 大工具集性能 | 全量加载，延迟上升 | search mode 按需加载 |

### 架构/信息流图

```
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ Agents       │   │ Coding Agents│   │ Backends     │
│ (LangChain、 │   │ (Claude Code,│   │ (定时任务/API)│
│  Deep Agents)│   │  Cursor)     │   │              │
└──────┬───────┘   └──────┬───────┘   └──────┬───────┘
       │                  │                  │
       └─────────── 单一 Kit URL ─────────────┘
                          │
                 ┌────────▼─────────┐
                 │  Tool Gateway    │
                 │ ───────────────  │
                 │ 1. 身份解析       │  ←─ Okta / Entra ID
                 │ 2. 访问控制(kit)  │  ←─ Deny / Approval 策略
                 │ 3. 调用追踪       │  →─ LangSmith trace / 审计日志
                 └────────┬─────────┘
                          │
        ┌─────────────────┼──────────────────┐
        │                 │                  │
 ┌──────▼──────┐  ┌───────▼──────┐  ┌────────▼────────┐
 │ 内置服务器   │  │ 自注册 MCP   │  │ API-key 类工具   │
 │ Google/     │  │ servers      │  │ Exa/Tavily/     │
 │ Microsoft/  │  │ (50+ 场景)   │  │ Apollo ...      │
 │ GitHub ...  │  │              │  │                 │
 └─────────────┘  └──────────────┘  └─────────────────┘
```

## 实用评估

### 什么场景值得用

- **多用户、权限异构的生产 Agent**：零售商案例就是标准模板——同一套工具，店员助手走用户身份，后台对账 Agent 走服务身份。用网关把这种分化变成配置而非代码。
- **MCP 服务器数量失控的团队**：50 个服务器、1000+ 工具时，人工维护「哪个 Agent 能用哪个工具」的矩阵已经不可能，kit + deny policy 是唯一可扩展的做法。
- **合规与审计要求明确的企业**：Enterprise 计划下的审计日志能回答「昨晚 3 点这个 Agent 用了哪些工具、用了谁的凭证」这类问题——这在直连模式下几乎无法给出确定答案。
- **用多个 MCP client 的团队**：同一套 kit 被 Claude Code、Cursor 和自研 Agent 共用，避免了为每个客户端重做认证。

### 什么场景不值得用

- **本体是单用户工具**：个人 CLI、本地脚本，硬编码 token 的成本远低于引入托管层的复杂度。
- **必须全离线的环境**：Tool Gateway 是托管服务，工具请求要经过 LangSmith，对 air-gapped 部署不友好。
- **工具数量很少**：2-3 个工具的 Agent 用不上 kit 分层与 search mode，收益接近零。
- **需要完全自定义的鉴权编排**：blog 未说明对非常规 OAuth 扩展、私有 IdP 自定义协议的支持程度；这部分建议先用 docs 里的 quickstart 验证。
- **Public Beta 的成熟度风险**：deny policies 与 audit log 官方明确挂在 Enterprise 计划下，定价与配额待确认（> TODO: public beta 的价格与限制需查 docs / sales）。

### 迁移成本

- **接入路径**：Open Tools → 注册 MCP server URL 或启用内置 → 连接账户/保存 API key → 建 kit → 把 client 指向 kit URL。官方描述为「5 步」。
- **代码改动量**：客户端侧基本只换 MCP 端点 URL；真正的成本在**清理旧代码**——移除各 Agent 里的 OAuth 流程与 token 存储，以及把现有服务器的工具清单重新划分成合理的 kit 边界。后者是架构工作，不是接线工作。
- **组织成本**：需要 IdP（Okta / Entra ID）与 workspace admin 协作配置 profile 与共享凭证。

## 对你的意义

对 Agent + UI 这条线，这件事的价值不在「又一个 LangSmith 功能」，而在它印证了一个正在成型的分层：**LLM Gateway 管模型，Tool Gateway 管工具，Agent 本体只管编排逻辑**。如果你在设计带工具调用的 Agent 产品，最该借鉴的是两个概念而不是产品本身：

1. **Kit 作为权限单元**——Agent 能看不见未授权的工具，比「看得见但被拒绝」安全得多。这个设计可以在自研系统里直接用一张工具白名单 + 单一内部端点复刻。
2. **双身份模型**——「代表用户行事」与「代表 Agent 自身行事」必须在数据模型层面分开，否则一旦接入多用户就会推倒重来。凌晨跑批的任务天然属于后者，别让它借用某个用户的 token。

建议：**观望 + 内部 PoC**。若你现在还只有一两个 MCP 服务器，不必迁移；但应在下一个项目里预留「单一工具端点 + kit 概念」的位置，等工具数超过 10 个再决定是否接入 LangSmith。另外，它与 A-001（MCP 成为工具集成事实标准）是强相关信号：网关层的出现通常意味着协议层已经稳定到值得在其上做商品化。

## 关键代码/配置片段

Tool Gateway 的接入以配置为主，官方 quickstart 的核心动作如下（从 blog 的 5 步流程整理，具体参数以 docs 为准）：

```text
1. Get access: 在 LangSmith 打开 Tools
2. Add a server: 注册 MCP server URL，或启用 built-in server
3. Connect account: 每个工具登录一次，或保存 API key
4. Build a kit: 勾选该 Agent 需要的工具 → 得到一个 MCP URL
5. Point client at kit URL:
   - LangChain / Deep Agents / Managed Deep Agents
   - Claude Code / Cursor（任何 MCP client）
```

内置伺服器覆盖范围（官方 blog 原文列举）：

```text
Managed by LangSmith（托管 OAuth，点 Connect 登录）:
  Google, Microsoft, Salesforce, GitHub, Linear, LinkedIn

API key / public（启用后填 key）:
  Parallel search, Exa, Tavily, Apollo, Ashby, Pylon, web page reading
```

> ⚠️ 注意：blog 明确写出 deny policies 与 audit log 面向 Enterprise 计划；Public Beta 期间的具体可用性请在 `docs.langchain.com/langsmith/tool-gateway` 内核实（> TODO: 确认 beta 阶段哪些策略对非 Enterprise 开放）。

---
[← Back to Deep Dives](./README.md)
