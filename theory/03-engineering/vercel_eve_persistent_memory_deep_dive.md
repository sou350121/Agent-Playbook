---
auto_generated: true
generated_at: "2026-09-11T12:40:47Z"
source_url: "https://vercel.com/changelog/persistent-memory-for-eve-agents"
signal_type: "blog_post"
---
# Vercel eve 推出持久记忆：把 Agent 记忆做成「可插拔插槽」 (Persistent Memory for eve Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-11
>
> **项目/工具**: Vercel eve (Agent 框架)
> **链接**: https://vercel.com/changelog/persistent-memory-for-eve-agents
> **核心定位**: 给 eve agent 加上跨会话的持久记忆，并把「记忆怎么存、怎么取」抽象成一个可替换的 provider 插槽，让文件、托管语义记忆服务、自有数据库都能接入同一套生命周期。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：eve agent 以前每次对话都从零开始；现在可以声明 memory slot，让 agent 在会话之间记住用户偏好与事实，并在每一轮自动召回。
- **現在值得用嗎**：看你是否已经在用 eve。若你在自建 agent 记忆层（手写向量库 + 摘要），eve 的 slot/provider 边界值得抄；若你没用 eve，则只有「借鉴架构」的价值。
- **適合場景**：多用户、需要按租户隔离记忆的 agent；想无痛试水记忆功能（内置 file provider 零外部依赖）；想换记忆后端但不改业务代码。
- **不適合場景**：单次无状态任务（聊天机器人一次性问答）；对记忆写入延迟/成本极敏感；需要 eve 之外的运行时。
- **與前版核心差異**：从「无记忆」到「slot + provider + scope」三层抽象——eve 管生命周期与隔离，provider 只管存储与检索。

## 是什么 / 解决什么问题

Agent「没有记忆」是一个被反复讨论的老问题：绝大多数 agent 框架把上下文窗口当作唯一记忆，会话一结束，用户说过什么、偏好什么、上次做到哪一步，全部蒸发。开发者通常的补救方式是自己在业务层堆一套 RAG——写向量库、做摘要压缩、拼 prompt 注入。问题是这套东西每个项目重写一遍，而且和 agent 的调用生命周期是脱节的。

Vercel eve 这次推出的 [Persistent memory](https://eve.dev/docs/memory)，本质上是在框架层面把这件事标准化：agent 声明一个 memory slot，eve 负责在每一轮对话之前召回相关记忆、注入模型上下文，并在对话之后让 provider 捕获发生的事。用官方定义说，就是「eve 拥有 slot、scope 与生命周期，provider 拥有存储与检索」。

关键不是「又一个记忆功能」，而是它把**记忆拆成了可替换的 provider**。同一个 `defineMemory()` 声明，把 provider 从内置文件换成 Supermemory、Upstash AgentKit 或你自己写的实现，「其余定义保持不变」。这意味着记忆后端不再和 agent 逻辑耦合——这是一个工程分层决策，而非单点功能。

## 技术架构拆解

### 核心设计决策

- **职责边界固定**：eve 和 provider 之间划了一条明确的线。eve 管「slot 名、namespace/scope 解析、何时召回与捕获（含 compaction）、召回消息的归属与迭代、把 provider 工具限定为 `<slot>__<tool>`」；provider 管「存储与索引、检索/排序/格式化、抽取什么与如何捕获、保留与删除、向模型暴露哪些工具」。
- **召回内容以 user-role 消息注入**：官方明确「Recalled content enters model context as user-role messages attributed to the slot, never as system instructions」。这是一个安全决策——记忆以用户身份进入，不会伪装成系统指令去劫持 agent 行为。
- **scope 承载租户隔离**：scope 决定「谁/什么共享这个 slot 的记忆」，是「你会最常改的字段」，也是多租户隔离的落点。内置 file provider 默认 `byPrincipal`，即按认证调用方分桶。
- **namespace 默认含 slot 名**：即便 `profile` 和 `workspace` 两个 slot 落到同一个 scope 值，默认 namespace 也会带上 slot 名，因此两者不会串味。slot 之间相互独立，可复用同一 provider 而不合并召回上下文。
- **扩展不能贡献 slot**：subagent 在自己的目录下声明 slot；extensions 不允许贡献 slot，因为「scope 与生命周期所有权留在消费方 agent」。这是对隔离性的强硬保护。
- **两种声明形态互斥**：`agent/memory.ts` 声明单个名为 `memory` 的 slot，`agent/memory/<slot>.ts` 声明一个或多个具名 slot，二者不能混用。

### 与前版/竞品的关键差异

| 维度 | 之前（eve 无记忆） / 手写 RAG | 现在（eve memory slot） |
|------|------------|------------|
| 记忆声明 | 业务代码里手写注入逻辑 | 一个 `defineMemory()` 文件声明 |
| 后端替换 | 重写调用与存储代码 | 换 `provider` 字段，其余不变 |
| 召回时机 | 自己控制，易与轮次脱节 | 每轮前自动召回，轮后自动/工具捕获 |
| 隔离 | 自己实现，易漏 | scope + namespace + slot 三层 |
| 注入身份 | 常被拼进 system prompt | 固定为 user-role 消息 |
| 部署持久性 | 取决于自己接的存储 | Vercel 上用私有 Vercel Blob，跨重启/部署保留 |

### 架构/信息流图

```
                 ┌────────────────────────────────────────────┐
                 │                  eve (框架)                 │
                 │  owns: slot 名 / namespace / scope 解析      │
                 │        召回 & 捕获时机 (含 compaction)       │
                 │        召回消息归属 / 工具命名 <slot>__<tool> │
                 └───────────────┬────────────────────────────┘
       before each turn          │           after each turn
       召回 relevant memory      │       provider capture / tools
                 ┌───────────────▼────────────────────────────┐
                 │                Memory Provider             │
                 │  owns: 存储&索引 / 检索排序格式化 / 抽取规则  │
                 │        保留&删除 / 暴露哪些模型工具          │
                 └───────────────┬────────────────────────────┘
                                 │ 二选一/组合
      ┌──────────────┬───────────┼──────────────┬────────────────┐
      ▼              ▼           ▼              ▼                ▼
  fileMemory     Supermemory  Upstash       Kybernesis      自建 provider
 (内置, 每 scope  (托管语义     AgentKit      Arcana          (Postgres /
  一份受控文档)    记忆服务)    (Redis)       (语义+笔记)      vector / KV / HTTP)
```

provider 能力对照（来自官方文档）：

| Provider | 提供服务 | 召回 | 捕获 |
|----------|----------|------|------|
| File memory | 内置 eve | 每 scope 一份受控文档 | 模型驱动 save_memory / remove_memory |
| Supermemory | `@supermemory/eve` | 语义搜索 | 每轮后自动 + 工具 |
| Upstash AgentKit | `@upstash/agentkit-eve` | Redis 排序召回 / 文档后端 | 默认自动捕获用户消息或模型驱动 |
| Kybernesis Arcana | `@kybernesis/arcana` | 语义搜索 + brain notes | 模型工具（可选自动捕获） |
| 自建 | 你的代码 | 由你的存储决定 | 由你的规则决定 |

## 实用评估

### 什么场景值得用

- **多租户 SaaS agent**：scope 直接映射到认证用户，`byPrincipal` 开箱即用，隔离逻辑不必自己写。
- **快速试水记忆功能**：`eve add memory/file` 一条命令，无需外部服务，dev 环境即可跑通。
- **后端可替换诉求强**：今天用文件、明天换 Supermemory 或自有 Postgres，业务声明不变。
- **Vercel 部署**：file memory 自动落到私有 Vercel Blob，跨重启与部署保留，省掉自己接存储。

### 什么场景不值得用

- **单次无状态调用**：如果你的 agent 每次都是独立任务（如一次性代码转换），记忆是负担而非收益。
- **非 eve 运行时**：这是 eve 框架内建能力，脱离 eve 无法直接使用，只能借鉴其设计。
- **对成本/延迟极敏感**：每轮前召回意味着额外的检索调用与上下文注入，会推高 token 与响应延迟；file provider 是「一份有界文档」，容量有上限（具体尺寸限制见 [File memory 文档](/docs/memory/file)，此处未展开）。
- **依赖自动事实抽取**：内置 file provider 不自动抽取事实，由模型决定存什么——质量取决于模型判断，需自行评估。

### 迁移成本

若你已在 eve 里手写记忆注入：把逻辑收敛为一个 `agent/memory/<slot>.ts` 文件，选择 provider 与 scope，删除业务层的注入与存储代码。若你从零开始：一条 `eve add memory/<provider>` 命令即生成骨架。主要工作量在**选定 scope 语义**（谁共享记忆）与**provider 选型**，而非代码量。

## 对你的意义

结合 Agent + UI / RAG 工具链 / LLMOps 的关切，这个更新有三层价值：

1. **架构可借鉴**：把「框架管生命周期、provider 管存储」这条边界拆得干净，是自建 agent 记忆层时值得直接抄的分层。它回答了一个常被含糊的问题——记忆的**归属与召回时机**应该由框架负责，而**存储格式与检索策略**应该可插拔。
2. **provider 生态信号**：Supermemory、Upstash AgentKit、Kybernesis Arcana 作为首批第三方 provider 出现，说明「记忆即插槽」正在形成一个小型集成生态。这与你关注的 MCP 式「工具集成标准化」是同构的——从「工具可插拔」延伸到「记忆可插拔」。
3. **Landscape 层面**：如果你在整理 Agent 记忆方案（向量库 / 记忆服务 / 框架内建），eve memory 是一个值得入库的条目，建议**观望其 provider 生态扩散速度**，而非立即迁移到 eve 运行时。

建议动作：**借鉴架构、观望生态**。若手头有自建 agent 记忆项目，可参考 `defineMemory()` 的 provider/scope 心智模型；若无 eve 使用场景，不必为了这个功能切框架。

## 关键代码/配置片段

内置 file provider——按认证调用方分桶的 slot（官方 changelog 原文）：

```ts
import { defineMemory } from "eve/memory";
import { fileMemory } from "eve/memory/file";
import { byPrincipal } from "eve/memory/scope";

export default defineMemory({
  description: "Remember useful details from previous conversations.",
  provider: fileMemory(),
  scope: byPrincipal,
});
```

托管语义记忆（Supermemory）：

```ts
import supermemory from "@supermemory/eve";
import { defineMemory } from "eve/memory";
import { byPrincipal } from "eve/memory/scope";

export default defineMemory({
  description: "Recall and manage durable context for the current user.",
  provider: supermemory({
    apiKey: process.env.SUPERMEMORY_API_KEY!,
  }),
  scope: byPrincipal,
});
```

slot 声明文件布局（两种形态互斥）：

```text
agent/
  memory.ts            # 单 slot，名为 memory
# 或
agent/
  memory/
    profile.ts         # 具名 slot: profile
    workspace.ts       # 具名 slot: workspace
```

`defineMemory()` 字段（官方文档）：

| 字段 | 必填 | 作用 |
|------|------|------|
| provider | 是 | 存储与检索该 slot 记忆的 MemoryProvider |
| scope | 是 | 谁/什么共享该 slot 的记忆（含租户隔离） |
| description | 否 | 追加到 provider 工具描述，告诉模型该 slot 存什么 |
| namespace | 否 | scope 所属的应用域 |
| visibility | 否 | scope 会话中途变化后模型可见的内容 |

> 待验证：各 provider 的召回延迟、token 开销与 file provider 的具体容量上限，官方本次公告未给出量化数据，建议实测。

---
[← Back to Deep Dives](./README.md)
