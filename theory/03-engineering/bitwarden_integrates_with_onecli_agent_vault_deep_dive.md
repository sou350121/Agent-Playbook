---
auto_generated: true
generated_at: "2026-04-04T03:31:54Z"
source_url: "https://www.onecli.sh/blog/bitwarden-agent-access-sdk-onecli"
signal_type: "significant_update"
---
# Bitwarden Agent Access SDK + OneCLI：AI Agent 凭证安全的新范式 (Bitwarden Agent Access SDK + OneCLI: A New Paradigm for AI Agent Credential Security)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-04
>
> **项目/工具**: Bitwarden Agent Access SDK + OneCLI
> **链接**: https://bitwarden.com/blog/introducing-agent-access-sdk/
> **核心定位**: 通过「人在回路」审批 + 网络层凭证注入，解决 AI Agent 持有 API 密钥的泄露风险

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: Bitwarden 推出 Agent Access SDK，让 AI Agent 通过加密隧道请求凭证，用户审批后由 OneCLI 在网络层注入，Agent 永远看不到明文密钥
- **現在值得用嗎**: 是 / 生产环境需观望（alpha 阶段，API 可能变动）
- **適合場景**: 生产环境 AI Agent 调用外部 API、需要审计凭证使用记录、团队协作场景
- **不適合場景**: 快速原型开发、单机离线 Agent、对延迟极度敏感的场景
- **與傳統方案核心差異**: 传统方案把密钥给 Agent，本方案把密钥给网关，Agent 只拿到执行结果

## 是什么 / 解决什么问题

AI Agent 安全领域长期存在一个根本矛盾：Agent 需要凭证才能调用外部 API，但一旦凭证进入 Agent 的上下文，就变得可提取、可记录、可通过提示词注入泄露。

现有的密钥管理方案（环境变量、密钥管理器、密码保险库）只解决了「存储」问题，没有解决「使用后」的问题。典型的危险流程是：
1. 用户把 API 密钥存入密钥管理器
2. Agent 从密钥管理器读取密钥
3. 密钥进入 Agent 内存和 LLM 上下文
4. 从这一刻起，密钥可能被日志记录、被提示词注入提取、被 LLM 提供商缓存

Bitwarden 的 Agent Access SDK 采取完全不同的思路：**Agent 永远不持有密钥**。它建立一个端到端加密隧道，Agent 发送凭证请求，用户通过 Bitwarden CLI 审批，凭证由 OneCLI 网关在发起 HTTP 请求时注入到网络层。

这是首个将「人在回路」(Human-in-the-Loop, HITL) 审批与「即时访问」(Just-in-Time, JIT) 结合到 AI Agent 工作流的开放协议。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| **凭证请求走加密隧道** | 防止中间人攻击，确保请求内容不被窃听 |
| **用户审批在本地 CLI 完成** | 审批逻辑不依赖云端服务，降低单点故障风险 |
| **凭证注入在网络层而非应用层** | Agent 代码无需修改，网关拦截所有 HTTP 请求统一处理 |
| **会话状态本地存储** | 网关重启后可恢复会话，避免重复配对 |
| **30 分钟会话过期** | 平衡便利性与安全性，长时间不用的会话自动清理 |

### 与前版/竞品的传统方案关键差异

| 维度 | 传统方案 | Bitwarden + OneCLI |
|------|----------|-------------------|
| 密钥存储位置 | 环境变量 / 密钥管理器 | Bitwarden 加密保险库 |
| 密钥访问时机 | Agent 启动时一次性加载 | 每次调用前即时请求 |
| 密钥可见性 | Agent 可读取明文 | Agent 永远看不到明文 |
| 审批机制 | 无 / 一次性授权 | 每次凭证使用需用户审批 |
| 审计能力 | 仅记录访问日志 | 审批记录 + 使用记录双重审计 |
| 泄露面 | 密钥在 Agent 内存中 | 密钥仅在网关内存中短暂存在 |

### 架构/信息流图

```
┌─────────────┐     ①凭证请求      ┌─────────────┐
│  AI Agent   │ ────────────────→ │   OneCLI    │
│ (OpenClaw/  │                    │   Gateway   │
│  NanoClaw)  │                    │             │
└─────────────┘                    └──────┬──────┘
                                          │ ②加密隧道请求
                                          ↓
                                   ┌─────────────┐
                                   │  Bitwarden  │
                                   │  Agent      │
                                   │  Access CLI │
                                   └──────┬──────┘
                                          │ ③弹窗通知用户
                                          ↓
                                   ┌─────────────┐
                                   │    用户     │
                                   │  (审批/拒绝) │
                                   └──────┬──────┘
                                          │ ④审批通过
                                          ↓
                                   ┌─────────────┐
                                   │  Bitwarden  │
                                   │    Vault    │
                                   │ (解密凭证)   │
                                   └──────┬──────┘
                                          │ ⑤返回加密凭证
                                          ↓
┌─────────────┐                    ┌─────────────┐
│ 外部 API     │ ← ⑦带凭证请求 ─── │   OneCLI    │
│ (Anthropic/ │                    │ (注入凭证)   │
│  Stripe)    │                    │             │
└─────────────┘                    └─────────────┘
```

**流程说明**:
1. Agent 发起 API 调用（不带凭证）
2. OneCLI 拦截请求，通过加密隧道向 Bitwarden 请求凭证
3. Bitwarden CLI 弹窗通知用户，显示哪个 Agent 请求哪个域的凭证
4. 用户审批（或拒绝）
5. Bitwarden 从保险库解密凭证，通过加密隧道返回
6. OneCLI 将凭证注入到 HTTP 请求头（如 `Authorization: Bearer <token>`）
7. 请求转发到目标 API，Agent 全程不接触明文凭证

## 实用评估

### 什么场景值得用

- **生产环境 Agent 部署**: 当 Agent 需要调用付费 API（如 Anthropic、Stripe）时，凭证泄露意味着直接经济损失
- **团队协作场景**: 多个开发者共享同一 Agent 实例时，可追溯谁在什么时候使用了什么凭证
- **合规要求场景**: 金融、医疗等行业需要审计所有敏感数据访问记录
- **高价值凭证**: 数据库主密码、云服务商根密钥等一旦泄露后果严重的凭证

### 什么场景不值得用

- **快速原型开发**: 审批流程会增加开发迭代速度，本地测试环境可用环境变量替代
- **离线/内网 Agent**: 需要连接 Bitwarden 云服务（或使用自建中继服务器）
- **批量自动化任务**: 需要调用数百次 API 的场景，每次都要审批不现实（但可配置会话复用）
- **延迟敏感场景**: 审批流程引入额外延迟（首次请求约 5-10 秒）

### 迁移成本

从传统环境变量方案迁移到 Bitwarden + OneCLI：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 安装 Bitwarden CLI + Agent Access | 10 分钟 | 下载二进制文件，加入 PATH |
| 安装 OneCLI | 10 分钟 | `npm install -g onecli` 或 Docker |
| 配置 Bitwarden 为凭证源 | 5 分钟 | `onecli provider add bitwarden --vault-url ...` |
| 配对 Agent 与 Bitwarden | 5 分钟 | 首次运行生成配对令牌 |
| 修改 Agent 代码 | 0 | OneCLI 拦截网络请求，无需改代码 |
| 配置速率限制规则 | 15 分钟 | 可选，为不同 API 配置不同限流策略 |

**总计**: 约 45 分钟，无需修改现有 Agent 代码

## 对你的意义

如果你在用 OpenClaw、NanoClaw 或其他 Agent 框架调用外部 API，这个组合解决了长期存在的安全隐患。

**建议行动**:
1. **立即试用**: 在测试环境部署，用示例凭证熟悉流程
2. **生产观望**: 等待 beta 版本（当前 alpha API 可能变动）
3. **关注 Browserbase 集成**: Bitwarden 正在开发 Browserbase 原生集成，浏览器自动化场景将受益
4. **评估自建中继**: 如果担心云服务依赖，可研究自部署 WebSocket 中继服务器

## 关键代码/配置片段

### OneCLI 配置 Bitwarden 为凭证源

```bash
onecli provider add bitwarden \
  --vault-url "https://vault.bitwarden.com"
```

### 配置速率限制规则

```bash
onecli rules create \
  --name "Stripe rate limit" \
  --host-pattern "api.stripe.com" \
  --action rate_limit \
  --rate-limit 10 \
  --rate-window 1h
```

### Bitwarden Agent Access CLI 使用示例

```bash
# 启动监听（生成本地配对令牌）
aac listen

# 远程连接（Agent 侧）
aac connect --token <pairing-token> --domain github.com --output json

# 直接获取凭证并注入到子进程
aac run --domain github.com -- docker login
```

### Python SDK 调用示例

```python
from agent_access import RemoteClient

client = RemoteClient("python-remote")
client.connect(token="ABC-DEF-GHI")
cred = client.request_credential("example.com")
print(cred.username, cred.password)
client.close()
```

### 会话行为配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `BITWARDEN_PROXY_URL` | `wss://ap.lesspassword.dev` | WebSocket 中继服务器地址 |
| 会话过期时间 | 30 分钟 | 无活动后从内存清理 |
| 会话恢复 | 自动 | 网关重启后从数据库恢复 |

## 局限性与待验证项

- **alpha 阶段**: API 和协议可能变动，不建议用于生产环境
- **CLI 为主**: 目前主要通过命令行交互，浏览器扩展「未来会提供」但未发布
- **云服务依赖**: 默认使用 Bitwarden 提供的 WebSocket 中继，自建方案文档不足
- **审批疲劳风险**: 频繁调用 API 的场景可能导致用户盲目点击审批
- **多 Agent 隔离**: 同一 Bitwarden 账户下多个 Agent 的权限隔离机制待验证

## 总结

Bitwarden Agent Access SDK + OneCLI 代表了 AI Agent 凭证管理的新方向：**把密钥留在保险库，把执行权交给 Agent**。这种架构既保留了 Agent 的自动化能力，又通过人在回路审批和网络层注入消除了凭证泄露风险。

对于在生产环境部署 AI Agent 的团队，这套方案值得认真评估。虽然当前处于 alpha 阶段，但其设计思路（加密隧道、HITL 审批、JIT 访问）很可能成为未来 Agent 安全的行业标准。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | 凭证安全是多 Agent 生产部署的前提条件，此方案为工程化铺路 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | 企业采纳工作流自动化的主要障碍是安全合规，此方案直接解决 |

---
[← Back to Deep Dives](./README.md)
