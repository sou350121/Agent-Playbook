---
auto_generated: true
generated_at: "2026-11-07T03:30:58Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/govern-ai-agent-access-with-okta-cross-app-access-and-amazon-bedrock-agentcore-part-2/"
signal_type: "blog_post"
---
# Agent 凭证治理的规模化：Okta XAA × Bedrock AgentCore Gateway (Scaling Agent Credential Governance: Okta XAA Meets AgentCore Gateway)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-07
>
> **项目/工具**: Amazon Bedrock AgentCore + Okta Cross App Access (XAA)
> **链接**: https://aws.amazon.com/blogs/machine-learning/govern-ai-agent-access-with-okta-cross-app-access-and-amazon-bedrock-agentcore-part-2/
> **核心定位**: 把「每个 agent 直连每个 MCP server、各自持有 token 交换权限」的 N×M 接线矩阵，收敛成「Gateway 单一前门 + Cedar 默认拒绝策略」；权限判定逻辑从数千个 server 的复制粘贴代码，搬到网关上一个可审计的策略集合。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：AgentCore Gateway 接管 agent 的凭证兑换职责——agent 只把 Okta 签发的 ID-JAG 转发给网关，由网关用 TOKEN_EXCHANGE 换取目标资源 token；agent 角色从此不持有任何 token-exchange 或 secret 权限。
- **现在值得用吗**：看场景——如果你已有 3 个以上 agent 且工具数在持续增长，这套拓扑能省掉大量重复接线与权限漂移；只有 1 个 agent、2 个工具的话，Part 1 的原样就够了。
- **适合场景**：多 agent、多 MCP server 的企业内部平台；需要统一审计「哪个 agent 代表哪个用户访问了哪个系统」的合规场景；agent 跨运行时（AgentCore runtime + EKS）混合部署。
- **不适合场景**：目标应用的授权服务器不接受 ID-JAG（如 GitHub）——那得走 per-user OAuth consent 通道；单 agent 小规模场景属过度设计；对 200-400ms 额外鉴权延迟敏感的高频内部调用。
- **与前版核心差异**：Part 1 证明「机制成立」，Part 2 解决「拓扑不可扩展」；治理机制本身没变，变的只有围绕它的拓扑。

## 是什么 / 解决什么问题

AWS 与 Okta 合作的这组系列文章，Part 1 搭了一个最小可行的托管授权链：任务 agent 跑在 AgentCore runtime 上，通过 Okta Cross App Access 代表已登录用户行事，AgentCore Identity 在 agent 内部兑换 Okta 的授权。这证明了「谁可以代表谁」的治理机制能跑通——但跑通在一个刻意很小的拓扑上：**1 个 agent、2 个 MCP server、授权检查写在每个 server 自己的代码里**。

Part 2 的出发点就一句话：机制能扩展，拓扑不能。AWS 在文中直接列出三处会崩的地方：

| Part 1 的做法 | 为什么不能扩展 | Part 2 改成 |
|---|---|---|
| agent 持有每个 MCP server 的 runtime ARN 并直连 | N 个 agent × M 个 server 是接线矩阵，每加一个工具要动所有需要它的 agent | agent 只连一个 Gateway 端点，目标注册表放在 Gateway |
| agent 角色持有 token-exchange 权限并读取提供方 secret | 每个代表用户的 agent 都获得通往它可能触及的一切资源的凭证路径 | Gateway 负责兑换，agent 角色不再持有 token-exchange 或 secret 权限 |
| 每个 MCP server 在自己的代码里做同一套 groups 检查 | 同一条规则复制进数千个 server，会漂移，且无法一处修改、无法统一审计 | 一套默认拒绝的 Cedar 策略集，在工具执行前于 Gateway 求值 |

这第三点其实是所有企业 AI 平台都会撞上的墙：**授权逻辑一旦写进工具侧代码，它的正确性就无法被集中证明**。你有 800 个 MCP server，就有 800 份可能被改坏的权限判断，而审计员问「谁能让这个 agent 写这个系统的数据」时，你只能去翻代码。

原文的解决方案很克制：治理机制一个字没改，Okta 配置、AgentCore Identity 的 credential provider、Part 1 的 MCP server 全部原样保留。改的只有拓扑——前面插一个 Gateway。

## 技术架构拆解

### 核心设计决策

- **Gateway 作为唯一前门，承担第二次 token 兑换**。agent 把收件箱里的 ID-JAG（Identity Assertion JWT Authorization Grant）作为自己 MCP session 的 bearer token 转发给 Gateway，网关的 inbound authorizer 只接受"发给这个 agent 的"ID-JAG。Cedar 放行后，网关才让 AgentCore Identity 拿 credential provider 去 Okta 的自定义授权服务器兑换目标资源 token。Cedar 拒绝的调用**根本不会触发兑换**——这是把「授权」前置到「取凭证」之前的顺序设计。
- **agent 角色被剥到最小权限**。原文原话：'Remove the Part 1 AgentCore Identity statements from the agent's execution role. That's the only change to the role, which now holds no token-exchange or secret permissions, because the Gateway's role holds the permission to exchange tokens.'（译文：Part 2 删除了 Part 1 中 agent 执行角色上的 AgentCore Identity 语句；这是对角色唯一的改动，此后 agent 角色不持有 token-exchange 或 secret 权限，因为这些权限改由网关角色持有。）——**凭证路径从 agent 侧彻底移除**，这是整个方案最实质的安全收益。
- **工具名写死，策略才能引用**。每个 target 必须给静态工具 schema（`listingMode` 设为 `DEFAULT` 并内联 `mcpToolSchema`），因为「在测试中，点名具体工具的策略无法挂到动态列出的 target 上」。这是实践中的硬约束，不是可选项。
- **Cedar 用 permit-only + 默认拒绝，而且必须防 tag 缺失**。Cedar 把 JWT claims 暴露为 tag；读取不存在的 tag 会报错并被跳过。跳过的 permit 等于不授权（默认拒绝兜底），但**跳过的 forbid 等于什么都没禁**——所以每个 tag 都必须用 `hasTag` 守卫。这个细节很容易被抄错。
- **第一方身份不依赖运行时**。第二个 agent（reporting agent）跑在 EKS 上，通过自己的 Okta 身份加入，走自己的 Gateway 和 credential provider。EKS Pod Identity 给 pod 一个只能调模型、写自己日志与 trace 的 IAM 角色。原文点明：front door 不关心 agent 跑在哪。
- **审计面统一到 CloudWatch Omni**。Runtime、Gateway、Identity、Policy 在开启 Transaction Search 与 trace 投递后，**无需改代码**就发出 OpenTelemetry span；Okta 的 System Log 通过 EventBridge 送入 CloudWatch；一次 Omni 查询就能把「Okta 发了授权」和「后来发生了什么决定」join 起来。

### 与前版/竞品的关键差异

| 维度 | Part 1 / 传统 in-server 授权 | Part 2 / Gateway 集中授权 |
|------|------------|------------|
| 凭证持有者 | 每个 agent 角色持有 token-exchange 与 secret 读权限 | 只有 Gateway 角色持有，agent 角色为零 |
| 授权规则位置 | 复制进每个 MCP server 的代码 | 一个 Cedar 策略引擎，挂在 Gateway 上 |
| 规则变更方式 | 改 N 个服务并逐个发布 | 改一处策略集合 |
| 默认行为 | 取决于每个 server 的写法 | 默认拒绝（permit-only 引擎） |
| 新工具接入 | 所有需要它的 agent 都要改接线 | 在 Gateway 目标注册表加一条 |
| 审计关联 | 分散在各服务日志 | OTEL span + Okta System Log 在 Omni 一次 join |
| 撤销传播 | 见下方实测对比 | Okta 停发下一个 ID-JAG，已发 token 约 5 分钟内过期 |

### 架构/信息流图

```
[用户登录] → BFF 用 ID token 换 ID-JAG（发给 task agent）
                 │
                 ▼
     Agent A (AgentCore runtime) ── 转发 ID-JAG 作为 MCP bearer
                 │
                 ▼
     ┌──────────────── AgentCore Gateway A ────────────────┐
     │ 1. InboundAuth: 只接受发给我这个 agent 的 ID-JAG     │
     │ 2. Policy (Cedar): 逐工具 listing / 逐个 call 求值   │
     │ 3. 放行后才让 Identity 去 Okta 兑换目标资源 token    │
     │ 4. InvokeTool ─────────────────┐                    │
     └────────────────────────────────┼────────────────────┘
                                      ▼
                              MCP server（仍用 groups claim 决定该用户的权限，
                                          并记录 authz.check span）
     Agent B (EKS) ── 自己的 Okta 身份 ── 自己的 Gateway B ── 同上路径
                 │
                 ▼
     OTEL spans ──► AgentCore Observability ──► CloudWatch Transaction Search
     Okta System Log ──EventBridge──► CloudWatch Logs ──► Omni 查询 join
```

## 实用评估

### 什么场景值得用

- **agent 数量会持续增长的企业平台**：文中举的媒体娱乐场景很典型——制片跟踪、标题与资产元数据、版权与本地化、观众支持，每个 agent 面对不同系统、不同授权模型和不同审计员。真正的问题不是「能不能管住第一个 agent」，而是「第一百个 agent 是不是用同一套方式被管住」。
- **需要回答「谁能让 agent 做什么」的合规团队**：Cedar 策略是可读的代码，策略集合就是权限边界的唯一事实来源。审计时给一份策略，而不是给一堆服务源码。
- **混合运行时**：AgentCore runtime 上有、EKS 上也有 agent，但希望同一套身份与审计路径。原文实测：agent A 的 ID-JAG 发到 EKS 上的 agent B，98 毫秒内被拒，且拒绝发生在模型调用之前。
- **希望撤销能即时生效的场景**：见下方 XAA vs 用户 consent 的实测差异。

### 什么场景不值得用

- **目标应用不接受 ID-JAG**。GitHub 这类自带授权服务器的应用走 per-user OAuth consent，用户必须自己点同意。原文建议：**按目标应用分别选择，而不是为整个企业选一次**。
- **规模很小的内部工具**：单 agent + 两个 server，Part 1 拓扑已经够用，Part 2 增加的 EKS、Log Streaming、Omni 都是纯成本。
- **对每次调用的额外鉴权延迟敏感**：实测数据（Gateway A 24 小时 span，p50/p90）——InboundAuth 34/69ms、Identity.GetWorkloadAccessToken 48/94ms、Identity.GetResourceOauth2Token **70/439ms**、Cedar 单次调用 47/56ms、工具列表 65/75ms。也就是说身份 + 策略的中位数合计约 0.2 秒，但 **token 兑换的 p90 达 439ms**，这是新增的固定开销。相比之下 MCP server 自身调用是 5,565/6,273ms，占比不大，但对极低延迟的内部调用仍是可见成本。
- **需要靠平台保证「生产可用」的项目**：原文明确声明这些代码是 sample code for non-production use，需自行与安全/法务团队确认合规。

### XAA 与 per-user consent 的撤销差异（实测）

这一块是最值得抄进自己的设计评审的：

| 操作 | 下一个 GitHub 工具调用 |
|---|---|
| Alice 在 consent portal 完成授权 | 返回她的 GitHub 身份 |
| Bob 从未同意 | MCP error -32042，附带 AgentCore 授权 URL |
| Alice 在 Okta 被暂停，但复用旧 token | **仍然可用**——网关只检查入站 token 的签名与过期，该 token 活 1 小时 |
| Alice 被暂停后重新登录 | 拒绝 |
| Alice 解除暂停 | 直接可用，无需重新同意 |
| Alice 在 portal API 断开授权 | 变为未连接，然后再次 -32042 |

结论很锋利：**XAA 下 Okta 能阻止下一个 ID-JAG 的签发，且已发 token 约 5 分钟内过期；consent 通道下 Okta 只控制登录，存下的 grant 会活得比暂停更久**，直到被显式断开。

### 迁移成本

- 原文给的增量工作量：**约 90 分钟**（在 Part 1 已完成的前提下）。这包含 Gateway、Policy 引擎、EKS 第二个 agent、Okta Log Streaming 与 Omni。
- 真正的时间可能不在配置，而在三处坑：
  1. 工具必须静态 schema，否则点名工具的策略挂不上 target；
  2. `tools/list` 按 target 分页，客户端必须跟随 cursor，否则后面 target 的工具「消失」；
  3. AgentCore Python SDK 默认绑定 localhost，需设 `DOCKER_CONTAINER=true`；EKS Auto Mode 通用节点池只跑 amd64，得构建多架构镜像。
- 费用侧：EKS 控制面 $0.10/小时 + 节点 + Auto Mode 管理费；AgentCore 相关能力按用量计费。

## 对你的意义

对正在搭 Agent 平台的团队，这篇的价值不在 AWS 特有 API，而在于它把**「凭证路径的收敛」讲成了可复制的架构模式**：

1. **授权判定要前置于凭证兑换**。如果你的 agent 架构是「先拿 token，再靠工具侧检查权限」，那你就处在 Part 1 的拓扑里——工具越多，权限漂移越难审计。把 Gateway 放在前面，让失败发生在兑换之前，顺带把 token 兑换次数也降下来（Cedar 拒绝的调用不兑换）。
2. **策略只写 permit，靠引擎默认拒绝兜底**——但要小心 Cedar 的 tag 缺失语义：跳过的 permit 安全，跳过的 forbid 不安全。这个不对称必须写进团队的设计规范。
3. **凭证撤销的粒度要提前测**。consent 通道里「暂停用户后旧 token 仍能用 1 小时」这种事，往往要等到安全评审才被发现。原文那张表可以直接拿来当验收清单。
4. **审计要一次 join**。OTEL span 与 IdP 日志如果不能在同一查询里关联，「为什么这次调用了成功」就永远只能靠人肉比对。

**判断：观望偏试用**。如果你的平台还在 MCP server 数量个位数、agent 一只手数得过来的阶段，把这篇当作半年后的架构目标存档；一旦跨过「谁能代表谁」需要跟审计员解释的那条线，就直接按这个拓扑改。它解决的问题不是功能缺失，而是复杂度债务——而这类债务的利息，通常在你最没时间的时候结算。

## 关键代码/配置片段

以下均引自 AWS 官方 blog（Part 2）原文，非改写。

Gateway 的 inbound authorizer —— 只接受发给这个 agent 的 ID-JAG：

```
authorizer = {"customJWTAuthorizer": {
  "discoveryUrl": f"{OKTA_ORG}/.well-known/openid-configuration",   # the ID-JAG's issuer
  "allowedAudience": [f"{OKTA_ORG}/oauth2/{CUSTOM_AS_ID}"],         # the resource's authorization server
  "allowedClients": [AGENT_CLIENT_ID],                              # only this agent's ID-JAGs
  "allowedScopes": ["xaa:read", "xaa:write"],
}}
```

每个 MCP server 变成 Gateway target，出站授权走 TOKEN_EXCHANGE：

```
"credentialProviderConfigurations": [{
  "credentialProviderType": "OAUTH",
  "credentialProvider": {"oauthCredentialProvider": {
    "providerArn": provider_arn,           # the JWT_AUTHORIZATION_GRANT provider from Part 1
    "scopes": ["xaa:read", "xaa:write"],   # must equal the ID-JAG's scopes
    "grantType": "TOKEN_EXCHANGE",
  }},
}]
```

Cedar permit 策略（注意 `hasTag` 守卫与空格分隔 scope 的四种匹配形式）：

```
permit(
  principal is AgentCore::OAuthUser,
  action in [AgentCore::Action::"taskmanager___create_task",
             AgentCore::Action::"taskmanager___update_task_status"],
  resource == AgentCore::Gateway::"<gateway-arn>"
) when {
  principal.hasTag("client_id") && principal.getTag("client_id") == "<agent-client-id>" &&
  principal.hasTag("scope") &&
  (principal.getTag("scope") == "xaa:write" ||
   principal.getTag("scope") like "xaa:write *" ||
   principal.getTag("scope") like "* xaa:write" ||
   principal.getTag("scope") like "* xaa:write *")
};
```

Agent 侧唯一的改动 —— 把 ID-JAG 直接转给 Gateway：

```
id_jag = context.request_headers["Authorization"].removeprefix("Bearer ")  # allowlisted header
tools = make_client(GATEWAY_URL, id_jag)  # the Gateway redeems the ID-JAG for each target
```

> TODO: Part 2 文章的完整可运行版本以 awslabs 的 `08-okta-xaa-delegation-chain` 样例为基座，但样例走的是「Gateway interceptor 自己完成两次兑换」的另一条路线；若要与本文拓扑完全一致，需自行替换 interceptor 部分。原文声明所有代码为非生产用的 sample code。

> TODO: 本文引用的延迟数据来自作者团队 24 小时实测（单区域、特定拓扑），未在第二套环境中复现，横向对比其他厂商网关时需谨慎。

---
[← Back to Deep Dives](./README.md)
