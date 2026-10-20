---
auto_generated: true
generated_at: "2026-10-20T09:00:19Z"
source_url: "https://vercel.com/blog/introducing-vercel-drives-persistent-storage-for-agents"
signal_type: "significant_update"
---
# Vercel Drives 正式 GA：给 Agent 一块「跨沙箱可挂载」的持久盘 (Vercel Drives GA: Persistent, Mountable Storage for Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-20
>
> **项目/工具**: Vercel Drives
> **链接**: https://vercel.com/blog/introducing-vercel-drives-persistent-storage-for-agents
> **核心定位**: 把 Agent 的文件系统从「沙箱的私有副产物」变成「可独立挂载、可 fork 的一等公民资源」，让工作区与文件型记忆在沙箱销毁、运行时切换、并行 worker 之间活下来。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Drives 是 Vercel Sandbox 的持久化存储层——一个可以挂到任意沙箱某个挂载点的目录，沙箱停了文件还在，新沙箱挂上同一个 Drive 就地续跑。
- **現在值得用嗎**：**看场景**。如果你已经在 Vercel Sandbox（或 Vercel 的 eve agent 模板）上跑多轮/多阶段的 agent，答案是「是的，这正是你缺的那块」；如果你的 agent 跑在自建容器或本地，这次 GA 对你没有迁移理由。
- **適合場景**：跨 run 续跑的长任务 agent、跨沙箱共享数据集/模型/构建产物、需要并行试错分支的 worker fan-out。
- **不適合場景**：把 Drive 当作「真正的数据库」——没有事务、没有 merge；也不适合需要多人协同编辑同一份工作区的场景（fork 不回流）。
- **與前版的差異**：GA 之前是 preview 的受限能力；GA 之后三个形态差异很关键——**全 plan 可用**（Hobby/Pro/Enterprise）、**配额大幅放大**（Pro/Enterprise 默认 1 TiB，上限 16 TiB；Hobby 仅 1 GiB）、**fork 正式 GA**（每条分支独立可写且互不影响）。

## 是什么 / 解决什么问题

Agent 的工作形态正在从「一次性问答」变成「持续工作」：它会 clone 仓库、装依赖、跑测试、生成报告，然后可能因为换了一个任务需要不同的运行时（Node → Python、CPU → GPU 环境）而被换到新环境里。问题在于，**执行环境是易失的，而工作区不是**。

在传统 Serverless/Sandbox 模型里，沙箱停止 = 文件系统消失。工程上常见的三个补丁都不好看：

1. **外部对象存储**（S3/R2）——需要 agent 显式写代码上传下载，不是「文件系统语义」；
2. **自建持久卷**（EBS/PVC）——绑定固定机器或集群，和 serverless 的弹性相冲；
3. **把状态塞进 KV/DB**——只适合结构化小状态，不适合仓库、数据集、模型权重。

Vercel 这次把 Drives 从 preview 推到 GA，思路很直接：**给 agent 一个可挂载的目录，把「持久性」和「执行环境」解耦**。Drive 是一个独立资源，`Sandbox.create()` 时挂到某个路径上；这个路径下的东西归 Drive 所有，其他路径归沙箱所有。沙箱没了，Drive 还在；下个沙箱挂上同一个 Drive，agent 打开 `/workspace` 发现上次写的文件都还在。

一句话：**它把「agent 的记忆」从 prompt 里挪到了文件系统里，并且做成了可 fork 的。**

## 技术架构拆解

### 核心设计决策

- **挂载点而非 API**：Drive 不是 SDK 里的 `putObject/getObject`，而是 mount 到沙箱内的一个目录。这意味着 agent 不需要学新 API——已有的 `git clone`、`pip install`、`npm build`、写文件全都不改。这是这次设计里最聪明的一点：**兼容性来自 POSIX 语义，而不是来自适配层**。
- **路径边界即所有权边界**：文档说得很明确——「everything under `/workspace` persists on the drive. Everything else belongs to the sandbox」。这条规则让「什么是持久的」变成一个纯路径问题，没有隐式魔法，便于推理成本与数据泄露边界。
- **一 Drive 多沙箱**：同一个 Drive 可以被多个沙箱挂载。官方给出的典型用法是**一次构建、多次消费**：一个 agent 在 Drive 上把数据集建好，其他 agent 以只读方式挂载来分析/出报表，避免重复重建。
- **Fork 是一等操作，且单向**：`drive.fork()` 克隆源 Drive 的数据、region 和容量上限，新 fork 有独立可写层。两个 worker 从同一份基线出发各改各的，互不影响。
- **明确不做 merge**：官方写死「Forks don't merge back into the original drive」。这是一个刻意的范围收窄——省掉了合并冲突、并发写一致性、版本向量那一整套复杂度，代价是并行结果需要上层自己汇总（例如各自导出产物到第三个 Drive）。

### 与前版/竞品的关键差异

| 维度 | Preview 期 / 传统 Sandbox 快照 | GA 后的 Drives |
|------|------------|------------|
| 持久化单元 | 单次运行的文件系统 / 手动快照 | 独立命名资源，可被多个沙箱挂载 |
| 跨运行时切换 | 需重新 clone/安装/重建 | 挂载同一 Drive，工作区原样续跑 |
| 并行尝试 | 各自从零开始，或共享写 → 互相污染 | `fork()` 复制基线，隔离可写层 |
| 共享只读输入 | 需外部对象存储 + 显式下载 | 多沙箱挂载同一 Drive |
| 配额 | 受限（preview） | 默认 1 TiB；Pro/Enterprise 上限 16 TiB；Hobby 1 GiB |
| 可用 plan | 受限 | Hobby / Pro / Enterprise 全覆盖 |
| 写回合并 | — | 不提供，fork 单向 |

（注：上表中「传统更早方式」一列是基于一般 Sandbox 实践归纳的对比，非 Vercel 官方声明。）

### 架构/信息流图

```text
                    ┌──────────────────────────┐
                    │   Drive: agent-workspace │  ← 持久、独立于执行环境
                    │   /repo  /data  /out     │
                    └────────▲──────────┬──────┘
                             │ mount    │ mount
             ┌───────────────┴──┐   ┌───┴──────────────┐
             │ Sandbox A        │   │ Sandbox B        │
             │ runtime: node22  │   │ runtime: python  │
             │ /workspace ←drive│   │ /workspace ←drive│
             │ 其余路径 = 易失   │   │ 其余路径 = 易失   │
             └────────┬─────────┘   └────────┬─────────┘
                      │ 沙箱停止                │
                      ▼                        ▼
                 [文件仍在 Drive] ──→ 新沙箱挂载，续跑

  并行分支：
       Drive(base) ──fork──→ worker-0 (可写、独立)
                   ──fork──→ worker-1 (可写、独立)
       结果各自导出；fork 不回写 base
```

## 实用评估

### 什么场景值得用

- **多阶段、跨运行时 agent**：先用 CPU 沙箱做检索与数据清洗，再换到 GPU 或不同 language runtime 做训练/验证。**不需要搬迁工作区**，这是最直接的收益。
- **数据集/模型/依赖的共享缓存**：官方明确点名的场景——把 dataset、models、dependencies、build artifacts 放到 Drive 上，多个沙箱复用。对 CI 类 agent（反复装依赖）来说，这一步能直接砍掉冷启动开销。⚠️ 具体能省多少秒，官方未给 benchmark 数据，`> TODO: 待实测冷启动对比`。
- **Fan-out 式并行探索**：一个 agent 想试 3 种重构方案，用 `fork()` 起 3 个 worker，各自跑测试，最后比结果。这在纯 sandbox 模型里几乎是硬做不了的。
- **文件型记忆**：如果你的 agent 用「写笔记到文件、下轮再读」的方式做记忆（而不是向量库），Drives 就是把这件事变成基础设施。

### 什么场景不值得用

- **需要事务/强一致的业务状态**：文件系统语义 + 多挂载方 = 并发写的语义你要自己负责。会话状态、订单、权限这类数据请照旧放数据库。
- **把 fork 当 git 用**：fork 不 merge、不 rebase、不 diff。它是「分叉试验」而不是「版本控制」。
- **Hobby 的 1 GiB 配额**：如果你要放模型权重或真实数据集，1 GiB 根本不够；上限虽可到 16 TiB，但那是 Pro/Enterprise 的默认量级。
- **非 Vercel 平台**：Drives 依附于 Vercel Sandbox。自建 K8s + PVC 或 Fly.io/E2B 等方案有自己的持久化路径，这次更新不构成迁移理由。
- **成本敏感的高频小任务**：长时间保留高容量 Drive 是否比「每次重建」更便宜，取决于你的镜像构建速度和 Drive 存储计费，官方博客未给价格明细。`> TODO: 查阅 Vercel 定价页确认存储与 I/O 计费模型`

### 迁移成本

对已在 Vercel Sandbox 上的项目，**改动其实是外科手术级的**：

1. 创建/复用 Drive（CLI `sandbox drives get-or-create <name>` 或 SDK `Drive.getOrCreate`）；
2. `Sandbox.create()` 里加 `mounts: { '/workspace': drive }`；
3. **审计写入路径**：任何原本写到 `/workspace` 外的东西（比如 `/tmp` 下的缓存、`~/.cache`）现在都不会持久化。这一步最容易踩坑；
4. 如果依赖并行，把「一个沙箱跑所有分支」改成「fork N 个 Drive + N 个沙箱」。

工作量估算：单仓库、单一沙箱的单一路径挂载，**半天以内**；多阶段流水线 + 并行分支 + 缓存路径治理，**1-3 天**（主要是找那些隐式写到 `/tmp` 的代码）。

## 对你的意义

对 Agent-Playbook 这类「信号 → 资产」的两段式系统，Drives 的最大价值不是性能，而是**让 agent 的工作产物成为可挂载的资产**。

具体到你的使用：

- **RSS 采集 + 日报生成**这种 DAG 结构，天然适合「一个 Drive 挂多个 worker 沙箱」：采集 worker 写原始 JSON，分析 worker 只读挂载出报告。现在你是在单机上用脚本串行，容错靠重跑；Drives 提供的是一种**标准化的工作区边界**，未来如果要拆到 serverless 会更顺。
- **并行候选评估**（比如同时试 3 个 prompt 版本跑同一批样本）原本要自己搞隔离目录，`fork()` 直接给了干净的隔离语义。
- **但要克制**：你现在这台 2GB 的机器跑得好好的，Drives 解决的痛（跨沙箱持久化）你当下并没有。**建议：观望 + 拿一个小项目试挂载语义**，而不是立刻迁移整条管线。

我的判断：这次 GA 的真正意义在于**形态确认**——「agent storage」被平台厂商当作独立基建来做，而不是附属于 compute。这跟你追踪的 A-003（多 Agent 从实验走向工程）是同一条线上的基础设施补丁。

## 关键代码/配置片段

创建并挂载（官方 blog 示例）：

```bash
sandbox drives get-or-create agent-workspace
sandbox create --mount agent-workspace:/workspace
```

```typescript
import { Sandbox, Drive } from '@vercel/sandbox';

const drive = await Drive.getOrCreate({ name: 'agent-workspace' });

const sandbox = await Sandbox.create({
  mounts: { '/workspace': drive },
});

await sandbox.runCommand('git', ['clone', repoUrl, '/workspace/repo']);
```

Fork 出并行 worker（官方 changelog 示例）：

```typescript
import { Sandbox, Drive } from '@vercel/sandbox';

const drive = await Drive.get({ name: 'base-drive' })

for (let i = 0; i < 2; i++) {
  const fork = await drive.fork({ name: `worker-${i}` })
  const sandbox = await Sandbox.create({
    mounts: {
      '/data': fork,
    },
  })
  // Run the session, then delete the fork
  await fork.delete()
}
```

要点注释：
- `fork.delete()` 出现在示例里——**fork 是临时资源，要显式清理**，否则并行分支会持续占配额。
- fork 继承源 Drive 的 **region** 和 **最大容量**，因此创建 base Drive 时选 region 是有后续影响的决定。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | `fork()` + 只读共享挂载给了并行 agent 一个**原生隔离的共享基线**，把「多 agent 并行」从自建目录管理升级为平台原语；但不提供 merge，说明工程化还停留在「分叉」而非「协作收敛」阶段 |

---
[← Back to Deep Dives](./README.md)
