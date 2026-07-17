---
auto_generated: true
generated_at: "2026-07-17T14:05:42Z"
source_url: "https://github.com/anthropics/claude-code/issues/74066"
signal_type: "significant_update"
---
# Claude Code 企业级 Session/Cache 泄漏：ZDR Workspace 出现跨用户提示词污染
# (Claude Code Enterprise Session/Cache Leakage — Minecraft Prompt Appears in ZDR Workspace)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-17
>
> **项目/工具**: Claude Code (anthropics/claude-code)
> **链接**: https://github.com/anthropics/claude-code/issues/74066
> **核心定位**: 企业 ZDR（Zero Data Retention）workspace 中疑似出现跨用户 session 泄漏，Minecraft 提示词出现在企业用户的编码 agent 会话中，直接挑战 ZDR 隔离承诺

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Claude Code 2.1.199 版本中，企业 ZDR workspace 用户报告收到来自其他用户（可能是 consumer 计划）的 session 上下文污染——agent 突然开始讨论 Minecraft 建筑
- **现在值得用吗**: 企业/ZDR 用户需观望；个人用户影响有限
- **适合场景**: 个人开发、非敏感项目的编码辅助
- **不适合场景**: 处理敏感代码/商业机密的企业环境（ZDR 隔离尚未验证）
- **与竞品核心差异**: GitHub Copilot Agent 模式也有多租户架构，但该 issue 揭示了 Claude Code 在企业隔离层的具体实现漏洞

## 是什么 / 解决什么问题

### 背景：ZDR 承诺 vs 现实

Anthropic 为企业客户提供了 **ZDR（Zero Data Retention，零数据保留）** workspace 选项，核心承诺是：
1. 企业用户的对话数据不会被 Anthropic 用于模型训练
2. 不同 workspace 之间的 session 和 cache 完全隔离
3. 用户数据在会话结束后立即销毁

这对于处理敏感代码、商业机密的企业来说是采用 Claude Code 的**前提条件**。

### 发生了什么

2026年7月17日，GitHub 上出现了一个编号 #74066 的 bug report：

> 一名用户在 **已认证进入 Enterprise ZDR workspace** 的情况下使用 Claude Code，agent 突然开始问他想要什么砖块来建造 Minecraft 神庙，并在 recap 中自信地声称它正在建造一个 Minecraft 神庙。

该用户版本信息：
- **平台**: macOS (darwin)
- **终端**: Apple Terminal
- **Claude Code 版本**: 2.1.199
- **反馈 ID**: f336f5d2-3992-4a04-9e1f-ec30f006f75e

### 为什么这很严重

如果确认是跨用户 session 泄漏而非用户自身配置问题，这意味着：

1. **ZDR 隔离承诺被打破**: 不同 workspace 之间的 cache 或 session 上下文没有正确隔离
2. **敏感数据可能外泄**: 反向推理——如果其他用户的上下文能进入你的 session，你的敏感对话也可能泄露给他人
3. **企业合规风险**: 对于依赖 ZDR 满足 SOC2/ISO27001/GDPR 合规的企业，这是一个 red flag

## 技术架构拆解

### Claude Code 的 Session/Cache 架构（推测）

基于公开信息和该 bug 的表现，Claude Code 的 session 管理大致如下：

```
┌─────────────────────────────────────────────────────────┐
│                    User Terminal (CLI)                    │
│  ┌─────────────┐    ┌──────────────┐    ┌────────────┐  │
│  │ .claude/    │    │ API Client  │    │ Context   │  │
│  │  config     │    │ (v2.1.199)  │    │ Cache     │  │
│  └─────┬───────┘    └──────┬───────┘    └─────┬─────┘  │
│        │                  │                   │        │
│        ▼                  ▼                   ▼        │
│  ┌──────────────────────────────────────────────────┐   │
│  │          Session Manager (本地)                   │   │
│  │  - workspace auth token 管理                      │   │
│  │  - conversation history 缓存                      │   │
│  │  - context compaction 触发                        │   │
│  └────────────────────┬─────────────────────────────┘   │
└───────────────────────┼─────────────────────────────────┘
                        │ HTTPS
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Anthropic API Backend                       │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────┐  │
│  │ ZDR        │  │ Non-ZDR    │  │ Cache Layer      │  │
│  │ Workspace  │  │ Workspace  │  │ (prompt cache /  │  │
│  │ (企业隔离)  │  │ (consumer) │  │  context window) │  │
│  └─────┬──────┘  └─────┬──────┘  └────────┬─────────┘  │
│        │               │                   │            │
│        └───────┬───────┘                   │            │
│                ▼                           │            │
│        ┌──────────────┐                    │            │
│        │ ⚠️ 隔离边界？  │ ◄── 泄漏可能发生在 │            │
│        │  (此处存疑)   │    cache 层或       │            │
│        └──────────────┘    session 路由层    │            │
│                              └──────────────┘            │
└─────────────────────────────────────────────────────────┘
```

### 核心设计决策分析

根据 issue 中的描述，泄漏可能发生在以下几个层面：

| 可能泄漏点 | 机制 | 严重性 | 证据强度 |
|-----------|------|--------|---------|
| **Prompt Cache 层** | Anthropic 的 prompt caching 机制可能在多个 workspace 间共享 cache key 空间 | 高 | 间接 — Minecraft 提示词出现在 recap 中，暗示 cache 污染 |
| **Session 路由层** | API 请求的 workspace token 验证可能在某些边界条件下失效 | 极高 | 间接 — 用户确认已认证进入 ZDR workspace |
| **Context Compaction** | 用户提到 agent 在 compaction 后"忘记"了之前的指令，开始在错误的目录工作 | 中 | 直接 — 用户自己承认 compaction 导致了上下文丢失 |
| **本地 .claude/ 目录** | 用户承认自己做了"奇怪的事"：在无关目录启动 agent，但该目录有 .claude/ context | 低 | 直接 — 用户自认配置异常 |

### 用户自己的补充说明

该用户在 issue 中补充了一个重要细节：

> "我做的事情有点奇怪。我在一个与工作目录无关的目录中启动了 session（因为那里有一个我需要的 .claude 目录），但它实际上在另一个目录中工作。它提到的'更早的污染'是因为它在某个时刻 compacted 对话，然后开始在我启动 agent 的目录中工作（因为它忘记了我不要碰它的指令）。"

这段补充说明**部分解释了 compaction 导致的上下文丢失**，但**没有解释 Minecraft 提示词的出现**——这是两个不同的问题。

### 与竞品的对比

| 维度 | Claude Code (ZDR) | GitHub Copilot Agent | Cursor |
|------|-------------------|---------------------|--------|
| 企业隔离模型 | ZDR workspace（承诺零数据保留） | Enterprise Managed Users (EMU) | Business 租户隔离 |
| Session 隔离粒度 | workspace 级别 | organization 级别 | team 级别 |
| Prompt Cache 隔离 | 未公开说明 | 文档化隔离策略 | 未公开说明 |
| 跨租户泄漏先例 | 本次 issue（待确认） | 无公开记录 | 无公开记录 |
| 开源审计 | ✅ claude-code 部分开源 | ❌ 闭源 | ❌ 闭源 |

## 实用评估

### 什么场景值得用

- **个人开发项目**: 非敏感代码，Minecraft 提示词污染最多是有趣而非危险
- **非 ZDR 依赖的企业内部工具开发**: 代码不涉及商业机密或客户数据
- **快速原型验证**: 短期 session，不涉及跨用户协作

### 什么场景不值得用

- **处理敏感代码的企业环境**: 如果 ZDR 隔离确实存在漏洞，商业机密可能泄露给其他用户
- **合规要求严格的项目**: SOC2 Type II、ISO 27001、GDPR 等框架下，无法验证隔离有效性意味着合规风险
- **多租户协作场景**: 如果 cache 层确实跨 workspace 共享，协作环境中的泄漏风险更高
- **依赖长期 context 的大型项目**: context compaction 的不稳定性会加剧泄漏风险

### 迁移成本

如果决定从 Claude Code 迁移到替代方案：

| 迁移目标 | 迁移成本 | 主要障碍 |
|---------|---------|---------|
| GitHub Copilot Agent | 中 | 工作流适配、IDE 插件生态差异 |
| Cursor | 低 | 基于 VS Code，配置迁移简单 |
| Continue (开源) | 中 | 需要自建 API 连接，但完全可控 |

## 对你的意义

### 对 Ken 的 AI 应用开发工作

1. **Agent 安全是 Q2 的采购硬假设** — 这个 issue 直接验证了 MEMORY.md 中的假设 A（Agent 安全评估 Q2 成采购硬要求）。企业级 AI 工具的安全隔离不是可选项，而是底线。

2. **Claude Code 的企业采用需要观望** — 在 Anthropic 官方回应并修复之前，企业环境中使用 Claude Code 需要额外的风险评估。

3. **ZDR 承诺需要技术验证** — "零数据保留"不应该只是一个法律术语，应该有可审计的技术保障。这个 issue 暴露了当前缺乏第三方验证机制的问题。

### 建议

- **短期**: 如果你在用 Claude Code 处理敏感项目，关注此 issue 的进展（#74066）
- **中期**: 评估 GitHub Copilot Agent 作为替代方案——它的企业隔离模型更成熟
- **长期**: 关注 AI 工具安全审计标准的建立——类似 SOC2 但专门针对 agent session 隔离

## 关键引用

**原始 Issue 描述**（来源: GitHub #74066）:

> "Apparent session leakage, despite authenticated to Enterprise ZDR workspace. Agent suddenly started asking me what kind of bricks I wanted for my Minecraft temple and confidently asserted in its recap that it's building a Minecraft temple. I thought cache was isolated to workspace? Maybe one of my colleagues is building a minecraft temple. That's one way to spend your token allowance, I suppose. Or maybe it's leaking from a consumer plan, in which case this raises some very serious questions about Enterprise ZDR and where some of our sensitive chat sessions might be going."

**环境信息**:
- Claude Code 版本: 2.1.199
- 平台: macOS (darwin)
- 反馈 ID: f336f5d2-3992-4a04-9e1f-ec30f006f75e

> TODO: Anthropic 官方是否已回应此 issue？ — 截至 2026-07-17 抓取时，issue 中尚无官方回复
>
> TODO: 该泄漏是否已被复现？ — 需要更多用户报告确认
>
> TODO: ZDR workspace 的技术实现细节（cache 隔离策略）— Anthropic 未公开

---
[← Back to Deep Dives](./README.md)
