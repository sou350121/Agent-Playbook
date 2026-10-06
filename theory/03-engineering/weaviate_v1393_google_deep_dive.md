---
auto_generated: true
generated_at: "2026-10-06T05:45:38Z"
source_url: "https://weaviate.io/blog/weaviate-security-release-googlemodules-2026"
signal_type: "significant_update"
---
# Weaviate v1.39.3 高危修复：Google 模块凭据外泄漏洞拆解 (Weaviate v1.39.3: Fixing Credential Disclosure in the Google Modules)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-06
>
> **项目/工具**: Weaviate（向量数据库）v1.39.3 安全版本
> **链接**: https://weaviate.io/blog/weaviate-security-release-googlemodules-2026
> **核心定位**: 修复一个未校验的 `apiEndpoint` 配置项，攻击者可借此把运维者的 Google 凭据（API key 或 cloud-platform 级 OAuth token）外送到任意主机——CVSS 7.1 高危。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：这是 Weaviate 针对 Google 系列模块（vectorizer + generative）的一次安全热修，堵住「把出站请求连同凭据一起重定向到任意主机」的漏洞。
- **現在值得用嗎**：如果是自架 Weaviate 且启用了 Google 模块 → **立刻升**；纯本地/无 Google 模块的部署 → 按常规节奏跟进即可。
- **適合場景**：自架 Weaviate（尤其 GKE + Workload Identity + Vertex AI 向量化的部署）、把 Weaviate 用于 RAG 检索层的团队。
- **不適合場景**：Weaviate Cloud / AWS·Azure·GCP Marketplace 用户——这些已由官方无缝打补丁，无需自行操作。
- **與[前版]核心差異**：v1.39.3 把早已施加于其他厂商 `baseURL` 字段的端点校验，**补到了 Google 模块独有的 `apiEndpoint` 字段**（此前该字段根本不在校验范围内）。

## 是什么 / 解决什么问题

Weaviate 的 Google 系列模块——`text2vec-google`（向量化）、`multi2vec-google`（多模态向量化）、`generative-google`（生成式补全）——允许通过一个 `apiEndpoint` 配置值指定出站 Vertex AI / Gemini 请求的目标主机。问题在于：**这个值被原样写入请求 URL 的 host 部分，没有任何校验**，而运维者配置的 Google 凭据又被无条件地作为 Bearer token 附加到请求上——无论请求实际发往哪里。

结果就是一个典型的 SSRF 式凭据外泄：只要攻击者能影响 `apiEndpoint`，就能让 Weaviate 把凭据亲手送到攻击者控制的主机。CVSS 评分 7.1（High）。CVE 已向 MITRE 申请，编号待分配。

值得注意的是，这不是凭空冒出的新问题——它是一次「**校验覆盖遗漏**」：Weaviate 早前已为大量其他模型厂商的端点字段加了 `baseURL` 校验，但 Google 模块的字段名叫 `apiEndpoint`，**恰好不在那轮加固的覆盖范围内**。字段命名的不一致，直接造成了一个可被利用的缺口。

## 技术架构拆解

### 核心设计决策

- **远端可配置端点**：为支持自定义/私有 Vertex AI 端点，`apiEndpoint` 被设计成可由用户写入，直接拼进请求 URL 的 host 部分。设计上信任了输入。
- **凭据无条件附加**：无论目标主机是谁，都先把运维者的 Google 凭据当作 Bearer token 挂上请求——这是漏洞成立的关键前提。
- **双层校验缺失**：无论是 collection 配置层还是 GraphQL query-parameter 层，都没有对 `apiEndpoint` 做字符串级校验。
- **修复策略**：把端点校验扩展到全部三个 Google 模块的 `apiEndpoint` 字段，**两层同时覆盖**（配置校验层 + GraphQL 查询参数层）。

### 两条利用路径（严重性差异巨大）

| 路径 | 入口 | 权限要求 | 严重性 |
|------|------|----------|--------|
| 路径 1 | `moduleConfig.text2vec-google.apiEndpoint`（collection 创建/更新时设置） | 需要 schema-write 权限 | 高（有门槛） |
| 路径 2 | `generative-google` 的 GraphQL 内联查询参数 | **仅需已配置该模块 collection 的普通读权限** | 最高（主要定级依据） |

路径 2 之所以更严重：**per-query 值会覆盖 collection 的默认端点**，且不需要 schema-write、不需要改动任何存储配置——一个仅有普通读权限的用户即可完成凭据外送。校验层此前只检查了 project ID 是否存在，端点字符串本身从未被检查。

### 泄露的凭据取决于认证方式

| 认证配置 | 被泄露的内容 | 影响范围 |
|----------|--------------|----------|
| 静态 API key | 该 API key 本身 | 取决于 key 权限 |
| `USE_GOOGLE_AUTH` 开启 | 一个 scope 为 cloud-platform 的**实时 OAuth access token** | 可触达底层 service account 能访问的绝大多数 Google Cloud API |

后者是官方文档推荐的、用 Google Cloud ADC 跑 Vertex AI 向量化的方式，也正是 GKE + Workload Identity 部署的常见形态——**这恰恰是受影响面最广的生产环境**。

### 与既有防护的关键差异

| 维度 | 早前的 baseURL 加固 | 本次 apiEndpoint 修复 |
|------|---------------------|----------------------|
| 覆盖字段 | 其他厂商的 `baseURL` | Google 模块的 `apiEndpoint`（此前遗漏） |
| 运行期 dial-time 保护 | `MODULES_VALIDATE_BASE_URL`（opt-in，仅拦 loopback/私网/link-local） | 无法阻止凭据发往公网上的攻击者主机 → 必须靠本次校验修复 |

也就是说，即使你开了 `MODULES_VALIDATE_BASE_URL`，它也**挡不住**凭据被发往公网上的恶意主机——这正是必须升级 v1.39.3 的原因。

### 架构/信息流图

```
攻击者（可影响 apiEndpoint）
        │
        │  ① collection config  (需 schema-write)
        │  ② GraphQL 内联参数   (仅需 read，覆盖默认值) ← 更危险
        ▼
┌──────────────────────┐
│  Weaviate Google 模块 │
│  apiEndpoint = 攻击者主机 │
│  未校验 ────────┐      │
└────────────────┼──────┘
                 │ 拼接 host + 附加凭据(Bearer)
                 ▼
        ┌───────────────────────┐
        │ 任意主机（攻击者控制） │
        │ 收到 API key / OAuth  │
        │ cloud-platform token  │
        └───────────────────────┘
```

## 实用评估

### 什么场景值得用（立即升级）

- **自架 Weaviate + 启用任一 Google 模块**：这是直接受影响对象，应立即升到 v1.39.3+。
- **GKE + Workload Identity + Vertex AI 向量化**：泄露的是 cloud-platform 级 OAuth token，爆炸半径最大，优先级最高。
- **多租户 / 开放读权限的 Weaviate**：路径 2 仅需普通读权限，暴露面显著放大。

### 什么场景不值得用（或无需自己动手）

- **Weaviate Cloud 客户**、**AWS / Azure / GCP Marketplace 客户**：官方已无缝打补丁，无需自行操作。
- **完全未启用 Google 模块的部署**：不受此漏洞影响，按正常发版节奏跟进即可。
- **仅本地开发、凭据无实际权限**：风险有限，但仍建议随手升级。

### 迁移成本

- **能升级**：直接升到 v1.39.3 或更高，属于小版本安全发布，迁移成本极低。
- **暂时无法升级的过渡措施**：
  1. 从 `enabled_modules` 中移除 `text2vec-google`、`multi2vec-google`、`generative-google` 以禁用受影响模块；
  2. 若模块必须保留，限制对启用这些模块的 collection 的 schema-write 与查询访问权限；
  3. 把用于 Vertex AI 的 service account 权限收敛到最小，而非依赖宽泛的 cloud-platform scope。

> TODO: CVE 编号（MITRE 待分配）与官方补丁的具体 commit/PR 链接，待 Weaviate 更新博文后补入。

## 对你的意义

对 Ken 的 RAG 工具链实践而言，这条不仅仅是「一个库打了补丁」，而是一个值得复用的**工程教训**：

1. **「可配置远端端点」= 潜在 SSRF 面**。任何允许用户设置出站目标主机 + 同时携带凭据的功能，都必须做端点校验与凭据隔离。这类模式在 RAG stack（vectorizer、reranker、LLM gateway）里随处可见。
2. **校验覆盖会因字段命名而漏**。厂商早前加固了 `baseURL`，却漏掉了名字不同的 `apiEndpoint`——真实世界里「安全加固」的盲区常来自命名不一致。自检清单应基于「语义」而非「字段名」。
3. **opt-in 防护往往不够**。`MODULES_VALIDATE_BASE_URL` 是可选且只拦内网地址，挡不住公网外泄——**默认关闭的安全开关，等于没有**。

**建议**：若你自架 Weaviate 且用到 Google 模块 → 立即升级，并顺便把 service account scope 收敛一次；否则标记为待办、在下个维护窗口跟进即可。同时，把这三点教训纳入你自建 RAG 服务的端点校验 checklist。

## 关键代码/配置片段

漏洞根因（描述性伪代码，说明 `apiEndpoint` 曾被原样拼接）：

```text
# 受影响版本的行为（< v1.39.3）
request_url = f"https://{moduleConfig['apiEndpoint']}/v1/models/..."
headers     = {"Authorization": f"Bearer {google_credential}"}   # 无条件附加
# 校验仅检查 project ID 是否存在，apiEndpoint 本身未做字符串校验
```

过渡期缓解配置（从 `enabled_modules` 移除 Google 模块）：

```yaml
# 禁用受影响模块（Weaviate 配置）
enabled_modules:
  - text2vec-openai
  - generative-openai
  # 移除以下三项直到升级完成：
  # - text2vec-google
  # - multi2vec-google
  # - generative-google
```

升级建议（见官方博文）：

```text
受影响版本: Weaviate < v1.39.3
修复版本:   Weaviate >= v1.39.3
CVSS:       7.1 (High)
CVE:        申请中（MITRE 待分配）
```

> 本漏洞由独立安全研究员 Syed Anas Mohiuddin 通过 Weaviate 漏洞披露计划报告；官方表示目前没有该漏洞被利用的迹象。

---
[← Back to Deep Dives](./README.md)
