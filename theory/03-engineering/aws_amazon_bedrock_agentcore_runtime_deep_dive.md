---
auto_generated: true
generated_at: "2026-09-20T05:45:43Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/the-new-agentcore-runtime-elastic-optimized-and-consistently-fast-starts/"
signal_type: "blog_post"
---
# AWS 新版 Amazon Bedrock AgentCore Runtime：弹性内存回收 + 恒定冷启动 (The New AgentCore Runtime: Elastic, Optimized, and Consistently Fast Starts)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-20
>
> **项目/工具**: Amazon Bedrock AgentCore runtime (platformVersion V2)
> **链接**: https://aws.amazon.com/blogs/machine-learning/the-new-agentcore-runtime-elastic-optimized-and-consistently-fast-starts/
> **核心定位**: 把「无服务器 Agent 托管」的内存与冷启动两个老大难问题一起重做——内存按需分页、会话结束即回收，冷启动不再随镜像大小/并发变化。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：AgentCore runtime 的第二代（V2）实现，重写会话内存模型与实例启动路径，让长任务/突发型 Agent 的账单和响应延迟都可预测。
- **現在值得用嗎**：看场景——如果你已经在 AWS 上跑长时或突发型 Agent，且受够了「按峰值内存付费」和「冷启动随镜像膨胀」，值得立刻切 V2 试跑；如果只是短问答 bot，收益有限。
- **適合場景**：长时间运行或 bursty 的托管 Agent（coding agent、事件触发型 ambient agent）；镜像体积大（≥1GB）导致冷启动慢的团队。
- **不適合場景**：对成本极度敏感且负载稳定平坦的会话（新计费是「更高单价 × 更少 GB-hours」，平坦负载未必更便宜）；需要 x86 依赖而暂时只能用 microVM 的场景（x86 支持仍在 roadmap）。
- **與前版核心差異**：内存不再锁在会话峰值而是按需分页 + 空闲回收；冷启动从「每次 boot 新环境」改为「一次性初始化 → 快照 → 每实例恢复快照」，P75 恒定约 2 秒。

## 是什么 / 解决什么问题

Amazon Bedrock AgentCore 是 AWS 的 Agent 托管平台，runtime 是其中的受管计算层——开发者把 Agent 部署进去，不必自建或维护底层基础设施。据官方 blog，自发布以来已有「数千个团队」用它跑生产级 Agent（*thousands of teams*，来源：AWS ML Blog）。

问题在于 Agent 的形态变了。早期的 Agent 多是一次问答、几秒结束的 chatbot；随后是运行数分钟到数小时的 coding agent；现在正在变成「ambient、always-on、由事件触发、无人值守」的常驻 Agent，而且数量成倍增长、被其他 Agent 拉起。第一代 runtime 打下的地基（serverless、会话隔离、scale-to-zero、按用量付费）依然成立，但当负载从「短会话」转向「长会话 + 突发」时，两个结构性痛点被放大：

1. **内存按峰值计费**：会话一旦分配了内存，就一直持到会话结束，中途不回收。对一个偶尔尖峰、大部分时间闲置的长任务 Agent 来说，这就是「整天按峰值付费」与「按真实用量付费」之间的差距。
2. **启动时间不稳定**：会话必须先启动才能干活。落到已经初始化好的环境上，启动 <100ms；但要保证环境热着，就得预留算力。所以大多数会话走的还是冷启动——全新 boot 环境、拉镜像、初始化 Agent。这个延迟惩罚随镜像大小与并发增大，在突发流量下最糟，而突发正是最多会话涌入、就绪环境最少的时刻。

新版 runtime 同时针对这两点重做。

## 技术架构拆解

### 核心设计决策

- **内存按需分页 + 空闲回收（page-in on demand, reclaim when cold）**：新 runtime 让每个会话从一个「小而高效的 memory profile」起步，而非完整的预置 footprint。额外内存随负载触碰按需分配/paged in。官方称基于「数十亿次会话的分配模式分析」调优了回收策略：当内存变冷、不太可能再被访问时就回收，而不是持到会话结束。
- **加载一次，快照复用（load once, then snapshot）**：创建或更新一个新 runtime 实例时，AgentCore 启动容器、等待健康检查通过，然后对运行环境**拍快照**。此时代码的一次性初始化（加载模型产物、拉静态配置）已经完成，因此被「烤进」快照。之后每个新实例从恢复快照开始，而非从零初始化——昂贵的启动工作只付一次，每个实例瞬间继承。
- **快照保持小且稳定（small & steady snapshot）**：朴素地对运行进程拍快照会连缓存与瞬态内存一起抓走，导致快照被撑大、恢复时间随镜像膨胀。新 runtime 剥掉这些多余部分，只保留恢复所需的工作状态，因此快照大小随容器镜像增长「大致保持平坦」——这正是恢复延迟能横跨大范围镜像尺寸保持稳定的原因。
- **计费模型**：按 Agent 实际使用、按需加载、空闲回收的内存计费，而不是整个会话都按住整个容器镜像。**单价更高，但 GB-hours 少得多**；官方判断多数 Agent 的 footprint 降幅大于单价升幅，因此总账单下降。

### 与前版/竞品的关键差异

| 维度 | 旧版 AgentCore runtime | 新版（V2） |
|------|----------------------|-----------|
| 内存模型 | 会话内按**峰值**持有，不回收 | 小 baseline + 按需分页，冷内存回收 |
| 冷启动路径 | 每次 boot 新环境 + 拉镜像 + 初始化 | 一次初始化 → 快照 → 每实例恢复快照 |
| 冷启动 vs 镜像大小 | 随镜像增大显著变慢（~5.4s → ~30s） | 基本无关（P75 恒定 ~2s，200MB–2GB 均如此） |
| 冷启动 vs 并发 | 并发越高越不稳定 | 据官方称与并发无关，落在窄区间 |
| 计费 | 按持有内存（含峰值） | 更高单价 × 更少 GB-hours |
| 计费粒度 | 会话级持有 | 跟随会话生命周期内的实际内存变化 |

> 说明：上表的冷启动数字来自官方在特定测试条件下的测量（见下），并非通用保证，实际值受客户网络与区域往返影响。

### 架构/信息流图

```text
【旧版】每次冷启动
  request → boot 全新环境 → pull image → 初始化 agent → 处理请求
            (延迟 ~5.4s @200MB ... ~30s @2GB，随镜像/并发上升)

【新版】一次初始化 + 快照复用
  创建/更新实例:
      launch container → health OK → [一次性初始化: 加载模型产物/静态配置]
                                    → snapshot(仅工作状态, 小且稳定)
  每个新会话:
      request → restore snapshot → 处理请求   (P75 ≈ 2s，与镜像大小无关)

【内存生命周期】
  会话开始 → 小 profile 起步
     ├─ 负载触碰 → page in 更多内存（按需）
     └─ 内存变冷/释放 → 平台回收（hooks: 释放 per-request buffer、让缓存过期）
  计费 = 实际分页/持有的内存，而非峰值 footprint
```

### 关键数据（来源：AWS ML Blog 官方测量）

测试设计（官方披露）：

- 用一个「空 echo agent」（返回输入，不调用任何模型或工具）隔离平台自身的启动开销。
- 客户端：us-west-2 上的 EC2 实例，用 boto3 SDK 经公网调用 us-east-1 的 agent，无 VPC peering——因此每个数字都**包含跨区往返**在内。
- 每版本、每种镜像尺寸发送 **5,000 次冷调用**，覆盖 **5 种镜像尺寸**，在默认账户配额内。

结果：

- **新版**：P75 冷启动延迟约 **2 秒**，从 200 MB 到 2 GB 镜像都一样（镜像尺寸无影响）。
- **旧版**：延迟随镜像增大，从约 **5.4 秒**（200MB）升到接近 **30 秒**（2GB）。
- 作为参照：该 echo 测试中 Agent 自身代码在 P75 只跑了约 **34ms**，所以测到的几乎全是平台启动时间。

> ⚠️ 这些是「客户端侧」数字（含跨区往返），不是纯平台内部耗时，官方在 blog 中明确说明。

## 实用评估

### 什么场景值得用

- **长任务 / 无人值守 Agent**：内存按需分页 + 空闲回收，直接打击「按峰值付费」的浪费。运行数小时的 coding agent 或事件触发的 ambient agent 受益最大。
- **大镜像团队**：镜像 ≥1GB 导致冷启动从几秒飙到几十秒的场景，新版的「恢复快照」路径能把它压到恒定约 2 秒级别（官方测量口径）。
- **会话数多但多数空闲**：scale-to-zero + 按会话计费组合，让「养着很多空闲 Agent」的成本维持很低。
- **交互式 Agent 的体验优化**：官方给了一个实操技巧——在用户「一打开聊天界面」就起会话（而非等他们敲完提交），让会话在问候和打字期间预热，等真正发消息时环境已就绪，几乎隐藏掉启动时间。

### 什么场景不值得用

- **平坦、稳定、低峰值的负载**：新计费是「更高单价 × 更少 GB-hours」。如果一个 Agent 内存占用长期稳定且接近峰值，GB-hours 降不下来，反而可能更贵。这类负载更适合等 **committed baseline 定价**（见下）。
- **x86 硬依赖**：官方明确 x86 microVM 支持仍在 roadmap（"coming soon"），当前若你的代码/依赖锁定 x86 且不能用 ARM，需要等待。
- **需要超大会话内存/存储**：更大 RAM、vCPU、会话存储同样在 roadmap，尚未上线。
- **对精确成本预测要求极高的稳态服务**：consumption 定价天生弹性、随负载浮动；要可预测成本需要 baseline 定价，而它「即将推出」。

### 迁移成本

官方给出的切换动作极小：

- 创建或更新 runtime 时把 **`platformVersion` 参数设为 `V2`** 即可。
- 参考文档：[AgentCore Developer Guide — runtime platform versions](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html#runtime-platform-versions)。
- 样例仓库：`awslabs/agentcore-samples` 的 hosting-agents 示例，以及一个附带的 **load test 示例**（"05-measure-your-runtime"），可在自己的 AWS 账户里复现新 runtime 的恒定冷启动。
- 潜在适配点：为让内存回收生效，Agent 代码最好「显式释放 per-request buffer、让缓存按需过期」——即按新 runtime 的内存生命周期来写，而不是假设内存会一路被持有。

## 对你的意义

如果你的 Agent 架构偏「平台托管 + 长任务」，这是一次值得认真评估的基础设施升级，而且迁移面很窄（一个 `platformVersion=V2` 参数）。几个具体建议：

1. **立即试用**：在测试账户里用官方 load test 样例跑一遍，把「自己镜像 + 自己区域」的真实 P75 冷启动测出来，而不是照抄 blog 的跨区数字。
2. **重审成本模型**：在切换前，用你自己的内存分配曲线估算 GB-hours 变化——新计费对 bursty 负载友好，对平坦负载可能更贵。别默认「一定更省」。
3. **改 Agent 内存写法**：利用新 runtime 的回收语义，主动释放 per-request 缓冲、让缓存过期，否则你享受不到回收带来的账单下降。
4. **关注 roadmap 三件事**：baseline 定价（稳态成本可预测）、x86 支持（迁移存量容器）、session suspend/resume + scoped identity（无人值守 agent 的权限最小化）。对企业落地而言，**scoped identity（每个会话自己的受限身份）** 尤其关键——它直接对应「无人看管时这个 agent 被允许做什么」这个安全问题。

## 关键代码/配置片段

切换平台版本（官方 Getting Started 指示）：

```text
# 创建或更新 runtime 时，将 platformVersion 参数设为 V2
platformVersion = "V2"
```

官方示例仓库路径（用于复现与测量）：

```text
# 托管 Agent（HTTP 协议）
github.com/awslabs/agentcore-samples/tree/main/01-features/02-host-your-agent/01-runtime/01-hosting-agents/01-http-protocol

# 在你自己的 AWS 账户中测量新 runtime 的冷启动一致性
github.com/awslabs/agentcore-samples/tree/main/01-features/02-host-your-agent/01-runtime/05-measure-your-runtime
```

Roadmap 能力清单（官方 What's next）:

```text
- Committed baseline discounts  (reserve memory floor + burst on demand)
- Larger compute and storage    (more RAM / vCPU / session storage)
- x86 support                   (x86 microVMs)
- Greater lifecycle control      (suspend/resume sessions with memory snapshotting)
- Scoped identity for unattended agents (session context keys)
```

> TODO: 新版 runtime 的具体单价（$ / GB-hour）与 baseline 定价档位尚未在 blog 中给出，需查阅 AgentCore 定价页确认后再做精确成本对比。

---
[← Back to Deep Dives](./README.md)
