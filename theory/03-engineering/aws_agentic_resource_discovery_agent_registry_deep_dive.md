---
auto_generated: true
generated_at: "2026-08-29T05:49:10Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/agentic-resource-discovery-ard-an-open-specification-for-agent-discovery/"
signal_type: "significant_update"
---
# AWS 发布 Agentic Resource Discovery 开放规范 + Agent Registry (AWS ARD & Agent Registry)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-29
>
> **项目/工具**: AWS Agent Registry + Agentic Resource Discovery (ARD)
> **链接**: https://aws.amazon.com/blogs/machine-learning/agentic-resource-discovery-ard-an-open-specification-for-agent-discovery/
> **核心定位**: AWS 推出企业级 Agent 发现基础设施——Agent Registry 提供集中式目录，ARD 开放规范实现跨云/跨环境的 Agent 互操作发现，类比 DNS 在 Agent 生态中的角色。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**: AWS 发布了两件套——Agent Registry（企业内集中式 Agent/MCP 目录）+ ARD 开放规范（跨环境联邦发现协议），解决 Agent 生态从孤岛走向互操作的发现层问题。
- **現在值得用嗎**: 是，如果你的团队已经在 AWS 上部署多个 MCP server / Agent，或者你正在规划多 Agent 协作架构。
- **適合場景**: 企业内 Agent/MCP 工具治理、跨云 Agent 发现、MCP 生态集成
- **不適合場景**: 个人开发者单云单环境、不需要 Agent 发现/治理的小型项目
- **與 MCP 核心差異**: MCP 定义的是 Agent 与工具之间的通信协议；ARD 定义的是 Agent/工具/技能之间的发现与编目协议。两者互补，不竞争。

## 是什么 / 解决什么问题

当组织规模扩展 AI Agent 部署时，核心瓶颈从「如何构建 Agent」转移到了「如何找到正确的 Agent」。团队构建了 MCP server、部署了 Agent、开发了专用工具，但如果没有集中编目，这些资源就分散在孤岛中。开发者需要手动定位资源、审核、连接和维护——这对几个工具可行，但对数十个 Agent、MCP server、技能和 API 完全不可扩展。

更棘手的是多环境挑战：企业通常在多个云、本地基础设施、SaaS 平台和企业应用之间部署 Agent，每个环境有自己的注册表、命名约定和元数据模式。要让它们互操作，传统方案是为每对注册表编写定制连接器——这是组合爆炸。

AWS 的解决方案是分层的：

1. **AWS Agent Registry**: 在 AWS 环境内提供集中式、可搜索的目录
2. **Agentic Resource Discovery (ARD)**: 跨环境的开放联邦发现规范，让不同环境的注册表可以互操作

这类似于 DNS 在网络中的作用：本地命名空间自治，但通过统一协议实现全局可发现性。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| 分离「目录」与「发现协议」 | Agent Registry 处理 AWS 内的集中管理；ARD 处理跨环境联邦。职责清晰，可独立演进 |
| Apache 2.0 开源 ARD 规范 | 确保规范不被单一厂商锁定，鼓励跨厂商采纳 |
| MCP-native 访问端点 | Registry 本身暴露为远程 MCP endpoint，任何 MCP 兼容客户端可直接搜索和使用 |
| 审核工作流（Approval Workflow） | 企业级安全/合规要求：只有经过审核的记录才可被发现，管理员可随时撤销 |
| 混合搜索（Hybrid Search） | 语义理解 + 关键词匹配，同时支持自然语言查询和精确定位 |
| 灵活授权（IAM + JWT） | 支持 AWS 原生 IAM 和企业身份提供商 JWT，适配不同组织环境 |

### 核心工作流

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Administrator │──▶│   Publisher   │──▶│   Curator     │──▶│  Consumer     │
│               │     │              │     │              │     │ (Human/Agent)│
│ 1. 创建注册表  │     │ 3. 提交记录   │     │ 4. 审核/拒绝  │     │ 5. 搜索发现  │
│ 2. 配置授权    │     │    等待审批   │     │ 6. 废弃记录   │     │    使用资源  │
└─────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
        │                    │                    │                    │
        ▼                    ▼                    ▼                    ▼
   IAM/JWT 配置         描述 MCP/Agent/      安全/合规/质量        自然语言/精确
   审批策略设置         工具的元数据         审核把关              搜索 + 语义检索
```

### 与竞品的关键差异

| 维度 | MCP (Model Context Protocol) | ARD (Agentic Resource Discovery) | AWS Agent Registry |
|------|------------------------------|----------------------------------|---------------------|
| 定位 | Agent ↔ 工具的通信协议 | Agent/工具/技能的发现协议 | 企业内集中式目录产品 |
| 层级 | 传输/调用层 | 发现/编目层 | 目录/治理层 |
| 范围 | 单次连接 | 跨环境联邦 | AWS 环境内 |
| 开源 | Apache 2.0 (Anthropic 主导) | Apache 2.0 (ards-project) | AWS 托管服务 |
| 关系 | 被 ARD 发现和编目的对象 | 编目和发现 MCP server 等资源的规范 | 实现 ARD 规范的具体产品 |

### ARD 联邦架构

```
┌──────────────────────────────────────────────────────────────────┐
│                      ARD Federation Layer                        │
│              (跨环境发现协议 - 类比 DNS 的互操作层)                  │
└────────────┬──────────────────┬──────────────────┬───────────────┘
             │                  │                  │
   ┌─────────▼────────┐ ┌───────▼───────┐ ┌───────▼────────┐
   │  AWS Agent       │ │  On-Prem      │ │  SaaS Platform │
   │  Registry        │ │  Registry     │ │  Registry      │
   │                  │ │               │ │                │
   │ • MCP Servers    │ │ • Internal    │ │ • 3rd-party    │
   │ • Agents         │ │   Agents      │ │   Tools        │
   │ • Skills         │ │ • Custom Res  │ │ • APIs         │
   │ • Custom Resources│ │               │ │                │
   └──────────────────┘ └───────────────┘ └────────────────┘
             │                  │                  │
             └──────────────────┼──────────────────┘
                                │
                    统一 ARD 协议端点
                    每个注册表自治控制
                    发布方决定可见性
```

## 实用评估

### 什么场景值得用

- **企业多 Agent 治理**: 当你的组织有 10+ 个 Agent/MCP server 分散在不同团队时，Agent Registry 提供统一的发现入口和治理机制。审核工作流确保只有经过安全/合规审查的资源才可被发现。
- **跨云 Agent 互操作**: 如果 Agent 部署在 AWS + Azure + 本地数据中心，ARD 开放规范让你不需要为每对注册表编写定制连接器。每个环境维护自己的目录，通过 ARD 协议实现联邦发现。
- **MCP 生态集成**: ARD 原生支持 MCP。任何 MCP 兼容客户端可以直接搜索 ARD 注册表发现可用的 MCP server，无需硬编码端点地址。
- **公共 Agent 市场**: 任何组织可以在自己的域名上发布 ARD 目录，让 ARD 兼容客户端发现。这为跨组织 Agent 市场打开了可能性。

### 什么场景不值得用

- **个人开发者/小团队**: 如果你只有几个 Agent 工具，手动配置端点比维护注册表更简单。ARD 的价值在于规模——资源数量越多，发现成本越高，ARD 的收益越大。
- **单云单环境**: 如果所有 Agent 都部署在同一个 AWS 账户内，不需要跨环境联邦，ARD 的联邦能力是多余的。单用 Agent Registry 即可。
- **早期实验阶段**: 如果团队还在探索 Agent 能做什么，尚未形成稳定的 Agent 资产，此时引入发现协议是过度工程。

### 迁移成本

| 迁移路径 | 工作量 | 说明 |
|----------|--------|------|
| 从手动配置到 Agent Registry | 中等 | 需要描述现有 MCP server/Agent 的元数据，配置注册表、审核流程 |
| 从其他注册表到 ARD | 较高 | 需要实现 ARD 规范的端点，映射现有元数据到 ARD 格式 |
| 从 AWS Agent Registry 到 ARD 联邦 | 低 | Agent Registry 原生支持 ARD，配置联邦端点即可 |

## 对你的意义

结合 Ken 在 Agent + UI 方向的关注，这个发布有几个值得注意的信号：

1. **MCP 生态的治理层正在成形**: MCP 解决了 Agent 如何调用工具的问题，但没人解决「如何找到工具」。ARD 填补了这个空白。这意味着 MCP 生态的完整技术栈正在从「通信协议」向「发现 + 治理」扩展。
2. **Agent 互操作的标准化加速**: ARD 类比 DNS 的设计思路——本地自治 + 全局互联——是构建大规模 Agent 生态的正确模式。如果这个规范被广泛采纳，未来 Agent 之间的互操作将不再依赖定制集成。
3. **对 Agent-Playbook 的影响**: Agent Registry + ARD 代表了一种新的 Agent 架构模式——「发现驱动的 Agent 编排」。这应该在 Agent-Playbook 中作为独立的设计模式记录下来。

**建议**: 关注 ARD 规范的演进（github.com/ards-project）和采纳情况。如果 2-3 个主流 Agent 框架宣布支持 ARD，值得在 Agent-Playbook 中增加 ARD 集成指南。

## 关键代码/配置片段

来自 AWS 官方博客的架构描述：

> "Think of ARD as enabling federation across registries analogous to how the Domain Name System (DNS) enables name resolution across networks. An organization can deploy agents across environments, and each environment's catalog surfaces these resources in a common protocol, behind an endpoint."

> "ARD's design mirrors the control model AWS customers expect: the organization that publishes a catalog controls what's in it, who can see it, and when to revoke access."

核心工作流（来自官方文档）：

```
# 1. 管理员创建注册表
# - 配置 IAM/JWT 授权
# - 设置审批策略

# 2. 发布者提交记录
# - 描述 MCP server / Agent / 工具
# - 提交等待审批

# 3. 审核者审查
# - 安全/合规/质量审核
# - 批准/拒绝/废弃

# 4. 消费者（人类或 Agent）搜索发现
# - 自然语言查询 / 精确定位
# - 混合搜索返回相关结果
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | ARD 原生支持 MCP-native 访问，将 MCP server 作为一等公民编目，强化了 MCP 在 Agent 生态中的核心地位 |
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Agent Registry + ARD 提供了多 Agent 协作的基础设施层——没有发现机制，多 Agent 协作只能是硬编码的玩具 |

---
[← Back to Deep Dives](./README.md)
