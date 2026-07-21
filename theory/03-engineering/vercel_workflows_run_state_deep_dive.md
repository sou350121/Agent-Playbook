---
auto_generated: true
generated_at: "2026-07-21T03:36:56Z"
source_url: "https://vercel.com/changelog/configure-where-run-state-lives-in-vercel-workflows"
signal_type: "blog_post"
---
# Vercel Workflows 区域感知架构：Agent 持久化的关键拼图 (Vercel Workflows Regional Placement: A Key Piece for Agent Persistence)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-21
>
> **项目/工具**: Vercel Workflows
> **链接**: https://vercel.com/changelog/configure-where-run-state-lives-in-vercel-workflows
> **核心定位**: Vercel Workflows 新增区域感知能力，允许将每个 run 的状态、队列调度和输出流固定在单一地理区域，解决 AI Agent 工作流的延迟与数据驻留问题

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Vercel Workflows 是 Vercel 的托管式持久工作流平台，本次更新让每个 run 可以绑定到指定地理区域，状态/队列/输出流全部留在该区域
- **現在值得用嗎**：是 — 如果你的 Agent 工作流有低延迟或数据合规需求，这是一个开箱即用的优化；否则默认行为已足够
- **適合場景**：全球用户分布的 Agent 服务、有数据驻留合规要求的场景、需要故障隔离的多区域部署
- **不適合場景**：单区域部署的简单工作流（默认行为已足够）、需要跨区域强一致性的场景（区域隔离恰恰意味着不共享状态）
- **與前版核心差異**：从所有 run 统一存放在 `iad1`（美东）变为可自定义区域绑定，SDK 版本从 4.x 升级到 5.0.0-beta.33+

## 是什么 / 解决什么问题

AI Agent 工作流有一个长期存在的架构矛盾：Agent 的代码可以部署在全球任意边缘节点，但工作流的状态存储（checkpoint、队列消息、输出流）之前往往集中在单一区域。这意味着一个在悉尼触发的 Agent run，其状态可能存储在美国弗吉尼亚（iad1），每次 checkpoint 和状态恢复都要跨洋往返。

Vercel Workflows 是 Vercel 推出的托管式持久工作流平台，构建于开源 Workflow SDK 之上。它让 TypeScript/JavaScript/Python 代码具备「暂停、恢复、保持状态」的能力——Agent 可以等待外部事件、可以 sleep 数分钟到数月、可以在部署和崩溃后从精确断点恢复。

本次更新（workflow@5.0.0-beta.33+）引入了**区域感知 placement**：每个 run 的状态、队列调度和输出流被绑定到一个"home region"，默认是触发该 run 的函数所在区域，也可以通过 `region` 参数显式指定。run 在其整个生命周期内保持该区域不变。

这对 AI Agent 的意义很直接：一个服务悉尼用户的 Agent，其整个推理循环（执行 → checkpoint → 流式输出）都在悉尼完成，不再有跨洋延迟。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| 每个 run 绑定单一 home region | 避免跨区域往返延迟，保证状态操作在热路径上 |
| 默认绑定触发函数所在区域 | 零配置即可实现"run 靠近用户"的效果 |
| 支持显式指定 region 参数 | 满足数据合规（如 GDPR 要求 EU 数据留在 EU）和特殊调度需求 |
| run 生命周期内区域不可变 | 简化一致性模型，避免区域迁移带来的状态同步问题 |
| 区域故障自动 failover 到最近区域 | 保证可用性，同时最小化 failover 后的延迟增加 |
| 4.x → 5.x 不向后兼容 | 4.x 的 run 固定在 iad1，5.x 需要新架构支持多区域 |

### 与前版/竞品的关键差异

| 维度 | Vercel Workflows 4.x | Vercel Workflows 5.x (本次更新) | Temporal / Inngest |
|------|----------------------|--------------------------------|-------------------|
| 状态存储区域 | 统一 iad1（美东） | 可自定义，默认触发区域 | 自托管或指定云区域 |
| 区域绑定方式 | 无 | `start()` 的 `region` 参数 | 集群级配置 |
| 区域故障容错 | 手动 | 自动 failover 到最近区域 | 取决于部署架构 |
| 多区域部署 | 不支持 | 自动（每个 run 独立绑定） | 手动配置多集群 |
| 数据驻留合规 | 不支持 | 支持（可指定 EU/AP 区域） | 支持（自托管） |
| 部署复杂度 | 低（托管） | 低（托管） | 中高（需管理集群） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                    Vercel Edge Network               │
│                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐       │
│  │  Sydney   │    │  Frankfurt│    │   SFO    │       │
│  │ Function  │    │ Function  │    │ Function │       │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘       │
│       │               │               │              │
│       ▼               ▼               ▼              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐       │
│  │ Run A    │    │ Run B    │    │ Run C    │       │
│  │ home:syd │    │ home:fra │    │ home:sfo │       │
│  │ state    │    │ state    │    │ state    │       │
│  │ queue    │    │ queue    │    │ queue    │       │
│  │ streams  │    │ streams  │    │ streams  │       │
│  └──────────┘    └──────────┘    └──────────┘       │
│       │               │               │              │
│       │  (failover →  │               │              │
│       │   next closest)               │              │
│       ▼                               ▼              │
│  ┌──────────┐                   ┌──────────┐         │
│  │ Melbourne│                   │  Oregon  │         │
│  │ (backup) │                   │ (backup) │         │
│  └──────────┘                   └──────────┘         │
└─────────────────────────────────────────────────────┘

 Reads / hook resumes / stream consumers can come from ANYWHERE
 Platform auto-routes them to the run's home region
```

### 区域隔离的边界

需要注意的是，区域隔离**仅作用于写路径**（状态存储、队列调度、输出流）。读操作（read）、hook 恢复（hook resumes）和流消费者（stream consumers）可以从任何区域发起，Vercel 平台会自动将它们路由到 run 的 home region。

这意味着：
- **写路径**：严格单区域，零跨洋往返
- **读路径**：全局可达，平台自动路由

这种读写分离的设计是一个务实的权衡——大多数 Agent 工作流的写操作（checkpoint）频率远低于读操作（状态查询），将写路径锁定在单区域即可消除大部分延迟。

## 实用评估

### 什么场景值得用

**全球分布的 AI Agent 服务**
如果你的 Agent 服务面向全球用户，每个 run 绑定到用户所在区域可以将 checkpoint 延迟从数百毫秒降低到个位数毫秒。对于需要频繁 checkpoint 的长-running Agent（如多步工具调用链、长时间等待用户反馈的对话 Agent），累积延迟降低显著。

**数据驻留合规场景**
GDPR、CCPA 等法规要求特定区域的用户数据不得流出该区域。通过 `region: 'fra1'` 显式指定欧洲区域，可以确保 run 的所有状态数据（包括中间推理步骤、工具调用记录）都存储在欧盟境内。

**多区域容灾部署**
区域故障自动 failover 到最近区域，无需手动干预。对于生产级 Agent 服务，这意味着可以在不牺牲太多性能的前提下获得区域级别的容灾能力。

### 什么场景不值得用

**单区域部署的简单工作流**
如果你的应用只部署在一个区域，默认行为（绑定触发区域）已经足够，不需要额外配置。这个功能的核心价值在于多区域场景。

**需要跨区域强一致性的场景**
区域隔离意味着不同区域的 run 之间不共享状态。如果你需要多个 run 之间强一致地读写同一份状态，Vercel Workflows 的区域模型不适合——应该考虑使用数据库或分布式缓存。

**从 4.x 升级的存量 run**
4.x 创建的 run 固定在 iad1，升级到 5.x SDK 不会自动迁移它们。必须启动新的 run 才能使用区域功能。如果你的工作流有长期运行的存量 run（比如 sleep 数月的定时任务），需要等待它们自然完成或主动取消重建。

### 迁移成本

从 4.x 升级到 5.x 的迁移工作量：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 升级 SDK | 5 分钟 | `pnpm i workflow@beta` |
| 添加 region 参数（可选） | 10-30 分钟 | 根据业务需求决定是否显式指定区域 |
| 配置 Function regions | 15 分钟 | 在 vercel.json 中配置 `regions` 键 |
| 存量 run 处理 | 视业务而定 | 4.x run 不受影响，新 run 自动使用 5.x 行为 |
| 测试验证 | 30-60 分钟 | 验证多区域部署和 failover 行为 |

总体迁移成本较低（1-2 小时），主要风险在于确认存量 4.x run 的生命周期不会与新 run 产生冲突。

## 对你的意义

作为关注 AI Agent 工作流自动化的开发者，这个更新有几个直接含义：

1. **Agent 工作流的延迟瓶颈被消除了一大半**。之前 Agent 的推理循环中，跨洋 checkpoint 往往是最大的单点延迟来源。区域绑定后，整个 loop 都在用户附近完成。

2. **数据合规从"架构难题"变成了"一行配置"**。`region: 'fra1'` 就够了。对于面向企业客户的 Agent 产品，这可能是一个采购决策因素。

3. **Vercel Workflows 与 Temporal/Inngest 的差距在缩小**。之前 Vercel Workflows 的主要短板是多区域能力，现在补上了。如果你的技术栈已经在 Vercel 生态内，Workflows 现在是比自托管 Temporal 更轻量的选择。

**建议**：如果你的 Agent 工作流部署在 Vercel 上且有全球用户，立即升级到 5.x 并评估区域绑定策略。如果是单区域部署，可以先观望，等需要时再升级。

## 关键代码/配置片段

### 显式指定区域

```typescript
import { start } from 'workflow/api';
import { myWorkflow } from '@/workflows/my-workflow';

// Pin run to San Francisco region
const run = await start(myWorkflow, [input], { region: 'sfo1' });
```

### 多区域 Function 部署（vercel.json）

```json
{
  "functions": {
    "app/api/**/*.ts": {
      "regions": ["sfo1", "iad1", "fra1", "syd1"]
    }
  }
}
```

### 版本要求

```
Multi-region requires workflow version 5.0.0-beta.33 or later.
Runs created by the 4.x release line always live in iad1.
Workflows locks each run's region at creation.
```

### 区域与代码执行的分离

> The region option controls where the run's data is stored and where its queue messages are dispatched from. It does not deploy your code to that region. For step execution to happen in the selected region, deploy your app there.

这意味着 `region` 参数只控制**状态存储位置**，不控制**代码执行位置**。要让步骤也在指定区域执行，需要同时配置 Function regions。这是一个重要的架构区分——状态可以独立于计算进行调度。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | Vercel Workflows 新增区域感知能力，说明主流云平台正在将 Agent 工作流的延迟和合规问题视为一等公民需求，这正是企业级采用的前置条件 |

---
[← Back to Deep Dives](./README.md)
