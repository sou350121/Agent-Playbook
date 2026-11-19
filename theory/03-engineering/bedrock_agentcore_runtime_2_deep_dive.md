---
auto_generated: true
generated_at: "2026-11-19T05:45:52Z"
source_url: "https://aws.amazon.com/cn/about-aws/whats-new/2026/11/new-agentcore-runtime-default/"
signal_type: "significant_update"
---
# Bedrock AgentCore Runtime V2 成为默认：Agent 托管进入「快照恢复」时代 (Bedrock AgentCore Runtime V2 Goes Default: Agent Hosting Moves to Snapshot Restore)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-19
>
> **项目/工具**: Amazon Bedrock AgentCore Runtime
> **链接**: https://aws.amazon.com/cn/about-aws/whats-new/2026/11/new-agentcore-runtime-default/
> **核心定位**: 把 agent 冷启动从「每次重新初始化整个容器」改成「从已初始化 agent 的内存快照恢复」，2GB 镜像 P75 启动 29.7s → <2s，空闲缩零后多轮会话账单内存降 68%

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：AgentCore Runtime 的第二代平台版本（V2）从「容器启动」换成了「快照恢复」，把长尾冷启动和空闲计费两个老大难问题一起压下去了。
- **現在值得用嗎**：看場景——如果你在 AWS 上跑多轮、无状态之外的 agent 服务，且启动初始化（加载模型权重、导入依赖、读配置）超过 5 秒，立刻迁移；如果一次性的批处理脚本，收益有限。
- **適合場景**：长跑多轮对话 agent、带本地模型/大型依赖的 agent、突发流量型 agent API、需要浏览器/编译等重活会话。
- **不適合場景**：需要把外部可变状态（工具清单、凭证、配置）在启动时冻结的 agent（快照会让它固化到版本生命周期）；多天持久会话（要走 Instances 而非 microVM，见下文）。
- **與前版核心差異**：V1 是「启动一个新容器 → 跑初始化 → 服务」，V2 是「启动一个已初始化容器的快照副本 → 直接服务」。

## 是什么 / 解决什么问题

AgentCore Runtime 是 AWS 在 Bedrock 之上做的 agent 托管层：框架无关（LangGraph / Strands / CrewAI 或自研）、模型无关（Bedrock / Claude / Gemini / OpenAI）、协议支持 MCP 与 A2A，每个会话跑在独立的 Firecracker microVM 里（来源：AgentCore Runtime 官方文档）。

它解决的痛点很具体：**agent 的启动开销和它的「智能程度」成正比**。一个 RAG agent 启动要装 embedding 依赖；一个带本地小模型的 agent 启动要加载权重；一个浏览器 agent 启动要拉起 headless Chrome。在 V1 里，这些成本每次冷启动都要重付一遍。

V2 的做法是把「初始化」和「服务」拆成两个执行上下文：初始化在快照之前跑完，运行时对「一个已完全初始化、正在监听 8080 的 agent 进程」打快照；之后每个会话都是从这份快照恢复出来的副本，跳过全部启动逻辑。官方给出的数字是：**2GB 镜像 P75 启动时间从 29.7 秒降到 2 秒以内**，且「无论并发或镜像大小，冷启动都保持又快又稳」（来源：AWS What's New，2026-11）。

另一半收益在计费侧。V2 让空闲 agent 缩容到零，内存「在释放后几分钟内回收」，对多轮 agent 而言**每会话计费内存最多减少 68%**。这对「一天几百次对话但大部分时间在等 LLM 回复」的典型 agent 负载是结构性利好——官方文档明确写了 CPU 计费与实际活跃处理对齐，「通常在 agent 主要等待 LLM 响应的 I/O 等待期间不产生费用」。

## 技术架构拆解

### 核心设计决策

- **快照以「进程已初始化」为边界，而不是以「容器已启动」为边界**。SDK 用法是：模块级代码（import、加载权重、读静态配置）在 `app.run()` 之前完成；`app.run()` 才开始监听 8080。运行时规则是「8080 不监听 → /ping 不成功 → 不能打快照」，所以快照「在构造上就必然捕获一个完全初始化的 agent」，开发者不需要自己做 `/ping` 门控。这是很聪明的设计——把正确性约束编码进了启动时序，而不是靠文档提醒。
- **一个 agent 版本一份快照，快照寿命 = 版本寿命**。这是理解 V2 所有坑的总钥匙。每次创建或更新 agent 才会重新打快照。
- **计算与内存随之弹性**：会话可扩到 8 vCPU / 32 GB 内存，容器镜像上限 10 GB，足以在会话内编译大型代码库、驱动浏览器或加载本地模型。
- **安全隔离不降级**：恢复出来的仍是每会话独立的 Firecracker microVM，会话结束后整个 microVM 终止、内存清理。快照复用的是「初始化后的只读起点」，不是「进程实例」。
- **计算类型双轨**：microVM（全托管、秒级启动、按用付费、会话最长 8 小时）与 Instances（跑在自己账号的 AWS 托管 EC2 上、支持多天持久会话、GPU、共享实例上多 agent 协作、最长 14 天）。

### 与前版/竞品的关键差异

| 维度 | AgentCore Runtime V1 | AgentCore Runtime V2 |
|------|------------|------------|
| 冷启动模型 | 每次启动容器并重新执行初始化 | 从已初始化 agent 的快照恢复 |
| 2GB 镜像启动时间 | 29.7s（P75） | <2s（P75，官方数据） |
| 空闲处理 | 常驻占资源 | 缩容到零，内存数分钟内回收 |
| 多轮会话计费内存 | 基线 | 最多 -68% |
| 启动初始化窗口 | 常规启动超时 | 明确 120 秒（health check 失败即不健康）；lifecycle hook 的 memory + disk 调用共享 120s |
| 每请求状态 | 常规获取 | 必须自行在 handler 内生成（随机数、时间、凭证、实例 ID） |
| 升级方式 | — | 建/改 runtime 时 `platformVersion: V2` |

> 与「Serverless 容器」（如 Lambda / Cloud Run）的差别在于：那些产品的快照能力通常是「启动时缓存到磁盘」或「预热池」，而 AgentCore V2 冻结的是**进程内存态**，因此不必在恢复后重放「把 3 GB 权重读回内存」这一步。

### 架构/信息流图

```
       ┌────────────── 构建/版本生命周期（每版本一次） ──────────────┐
       │                                                           │
  agent bundle ──► 容器启动 ──► 启动期初始化（模块级代码）           │
   (≤10GB 镜像)                  ├─ import 依赖                     │
                                 ├─ 加载模型权重                     │
                                 ├─ 读静态配置 / agent.json          │
                                 └─（lifecycle hook: memory → disk）  │
                                        │  ≤120s 内就绪              │
                                        ▼                            │
                                  app.run() @ :8080                 │
                                        │ /ping 通                   │
                                        ▼                            │
                                  ★ 打内存快照（per version）★       │
       └───────────────────────────────────────────────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                会话 A               会话 B               会话 C
            Firecracker VM       Firecracker VM       Firecracker VM
            从快照恢复 <2s        从快照恢复           从快照恢复
               │                     │                     │
        /invocations handler（每请求都跑，必须重算易变值）
        ├─ uuid/urandom/secrets ← 必须在 handler 内
        ├─ 当前时间、耗时基准   ← 必须在 handler 内
        ├─ 凭证 token 过期刷新  ← 必须在 handler 内
        └─ 实例标识             ← 必须每请求生成
               │
          空闲 → 缩容到零，内存数分钟内回收
          会话结束时整台 microVM 终止
```

## 实用评估

### 什么场景值得用

- **重初始化型 agent**：本地模型推理 agent、需加载大量 Python 包或大二进制的 agent、需预拉 headless 浏览器的 agent。这类场景 V2 的收益最大——官方直接点名的就是「编译大型代码库、驱动浏览器、加载本地模型」。
- **多轮、突发型对话 agent**：缩零 + 按活跃 CPU 计费，把「夜间无人用」和「白天一波流量」的成本曲线都抚平了。-68% 的计费内存数字正是针对多轮场景给出的。
- **需要强隔离的多租户 agent 服务**：每会话独立 microVM + 会话结束内存清理，比在同进程里靠命名空间隔离更可审计。
- **MCP / A2A 服务端**：AgentCore 文档中 MCP、A2A、AG-UI 都有独立部署路径，V2 的快照模型对「工具目录固定、但调用高频」的 MCP server 相当合适。

### 什么场景不值得用

- **启动时缓存「会变的东西」的 agent**。官方明确警告：从 AgentCore Gateway 拉工具目录看似是理想的启动期缓存目标（慢且贵），但**在快照里缓存它等于把工具清单冻结到快照时刻**。如果你的工具每周新增，你会得到一个「看不见新工具」的 agent。
- **会话超过 8 小时的 agent**：microVM 上限 8 小时；多天会话必须走 Instances（最长 14 天），而 Instances 是另一套计费与容量模型（需配置 capacity provider）。
- **依赖启动时随机数/时间/凭证的既有代码**：迁移不是零成本，见下节。
- **非 AWS 栈**：这是 Bedrock 绑定服务，跨云或本地部署无从谈起；若你在自建 K8s 上跑 agent，V2 的设计思路可借鉴，产品不可用。

### 迁移成本

V2 的迁移成本几乎全在「审计启动期代码」，而不是在改配置。配置本身只是一行：

```python
# 迁移现有 runtime 或在新区域启用 V2
# create_runtime / update_runtime 时传入：
#   platformVersion = "V2"
# 反向：想让新建 runtime 留在旧版
#   platformVersion = "V1"
```

真正的工作量在于按官方规则逐项审计。官方给出一张「必须在 handler 里算」的对照表，可以当成检查清单：

| 要做的事 | 必须放在 handler | 原因（官方说明） |
|---|---|---|
| 生成随机值/标识/token | 每请求调 `os.urandom()` / `secrets` / `uuid.uuid4()`；Node.js 每请求读 `/dev/urandom` | 启动时读到的熵会被复制进快照，每个实例都相同；`random` 模块在启动时播种，恢复的实例会重复同一序列 |
| 读当前时间 | 每请求计算 | 启动时的时间戳被固定在快照时刻 |
| 测量耗时 | 在 handler 内取基准时间 | `time.monotonic()` 跨恢复不推进，用启动基准算出的时长「错了还看不出来」 |
| 使用凭证/token | 到期时刷新 | 启动时加载的凭证可能在实例启动前就过期 |
| 标识实例/worker | 每请求生成 | 所有恢复实例的 hostname 都是 `localhost`、PID 都是 `1`，用它们做 ID 会把指标、日志流、锁持有者全糊在一起 |

按经验，一个中型 agent 项目的迁移工作量大致是「半天到两天」：改模块级代码的组织方式、把易变逻辑搬进 `/invocations`、补一次全链路压测。用自研 HTTP server（而非 AgentCore SDK）的项目还要额外处理 `/ping` 语义——要么「初始化完才报 healthy」，要么「立即报 healthy 并在 lifecycle hook 的 memory 调用里做初始化」。

## 对你的意义

对 Ken 这边的 AI App 线，这条更新值得单独立项的**不是「Bedrock 又发新功能」，而是「agent 托管的成本模型换了基底」**。

过去两年 agent 基础设施的竞争点是「能否跑起来」（框架集成、MCP、多模型）。V2 暗示竞争点已经移到「空闲时花多少钱」和「冷启动能不能当交互延迟看」。当一个 agent 的冷启动进了 2 秒，它就不再必须常驻——这会直接改变 agent builder / visual workflow 类产品的架构假设：**工作流里每个节点可以是一个被快照恢复的独立 agent，按次唤醒**，而不必共享一个长期驻留的进程。

具体建议：

1. **观望为主，但要建一个测试 branch**。只要你的 agent 托管在 AWS，这个迁移迟早要做，且拖下去的成本是「旧版停留在 V1 语义上」。
2. **如果团队有 RAG / 本地模型 agent**，值得做一次对照测量：把你真实的镜像按 V2 规则重组，量一下 P75 启动和每会话计费内存，验证官方 29.7s→<2s、-68% 这两组数字在你自己负载上的实际形状。官方数字是 P75 且以 2GB 镜像为基准，镜像越大、启动期越重的项目收益越明显，反之可能远低于这个幅度——**待验证**。
3. **把「快照安全」当成一条代码规范**，而不是一次迁移动作。今天的初始化代码里如果藏着 `random.seed()` 或启动时抓取的配置，等哪天升级 V2 就会变成隐蔽的线上事故。

## 关键代码/配置片段

官方文档给出的 V2 推荐结构（直接引用）：

```python
import json, pathlib

from bedrock_agentcore.runtime import BedrockAgentCoreApp

# Runs once at import, before app.run() starts the server and before the
# snapshot. Every restored instance inherits these objects.
MODEL = load_model_weights()
SETTINGS = json.loads((pathlib.Path(__file__).parent / "agent.json").read_text())

app = BedrockAgentCoreApp()

@app.entrypoint
def invoke(payload):
    # Per-request work runs here on every instance.
    ...

app.run()  # starts listening on 8080; the snapshot is taken after this
```

lifecycle hook 的两个 warmup 调用（官方说明）：运行时先调 `memory` 再调 `disk`，两次调用共享 120 秒；HTTP action 下，两者都打到同一 path/port，用请求头 `X-Amzn-Bedrock-AgentCore-Runtime-Warmup-Type` 区分。

| Warmup 类型 | 准备什么 | 用来做什么 |
|---|---|---|
| `memory` | 每个会话启动时都带着的内存 | 需要 server 已运行才能做的初始化，或在 /ping 报健康之后想做的事 |
| `disk` | 会话启动时读取的文件 | 预读这些文件，让新会话启动更快 |

已默认 V2 的区域（官方列表）：us-east-1、us-east-2、us-west-2、ca-central-1、sa-east-1、eu-central-1、eu-west-1、eu-west-2、eu-south-1、eu-west-3、eu-south-2、eu-north-1、ap-southeast-5、ap-south-1、ap-northeast-2、ap-southeast-1、ap-southeast-2、ap-southeast-7、ap-northeast-1。其他区域需显式指定 `platformVersion: V2`；现有 runtime 不会自动迁移。

> TODO: 68% 计费内存降幅与 P75 启动数据的口径（采样窗口、会话长度分布）官方未在 What's New 页面展开，需查 AWS Blog 原文确认。

---
[← Back to Deep Dives](./README.md)
