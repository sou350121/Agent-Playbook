---
auto_generated: true
generated_at: "2026-10-18T09:01:56Z"
source_url: "https://vercel.com/changelog/ai-gateway-logs-now-show-session-affinity"
signal_type: "blog_post"
---
# Perplexity 开源 SPACE：可自托管的 Firecracker agent 沙箱 (Perplexity SPACE: Self-Hosted Firecracker Sandboxes for Agent Code Execution)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-18
>
> **项目/工具**: Perplexity SPACE (Sandboxed Platform for Agentic Code Execution)
> **链接**: https://github.com/perplexityai/SPACE
> **核心定位**: Apache-2.0 的 agent 代码执行沙箱平台——每个沙箱是独立 Firecracker microVM，控制面与命令流数据面彻底分离，并附 E2B 兼容层（ECW）让现有 E2B 客户端零改代码切换后端

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Perplexity 把驱动 Perplexity Computer 全量 agent 会话的沙箱底座开源了，Rust 实现，跑在 Firecracker microVM 上。
- **現在值得用嗎**：看場景——有 K8s 或自有裸机、且在意「代码和数据不出自己的网」，值得花半天做本地 Kind 实测；只跑几行 Python 就别上这套。
- **適合場景**：多租户 agent 平台、需要挂起/恢复的长时会话、想脱离第三方沙箱供应商但不愿重写 SDK 的团队。
- **不適合場景**：单机实验、无 K8s 运维能力、需要开箱即用 SLA/计费、依赖 E2B 高级 create 能力（mcp/volumeMounts/iam）的场景。
- **與 E2B / Docker 沙箱核心差異**：不是「又一个 Firecracker 封装」，而是把沙箱当成有状态资源来建模——异步 operation、Paused/Suspended 两级冻结、控制面与命令流两条独立生命线。

## 是什么 / 解决什么问题

Agent 要落到生产，绕不开代码执行这一层：隔离、启动快、会话能持久，三件事互相拉扯。Docker 容器共享内核隔离不够硬，进程级沙箱跑不了任意二进制，托管沙箱则意味着把用户代码交出去。

Perplexity 的做法是把内部平台开源。README 的定义很直接：SPACE 是「a sandbox platform for running code in isolated Firecracker microVMs」，应用通过 HTTP API 创建 Linux 环境、执行命令、收集输出、管理生命周期。一个 template 定义起始文件系统，一个 sandbox 是该 template 的实例，拥有自己的 VM 和可写文件系统，一个沙箱内可跑多条命令。

真正让它区别于市面上其他沙箱的，是**生命周期建模的严谨度**。架构文档开篇第一句就定调：「A sandbox, a lifecycle operation, and a command stream have separate lifetimes. A sandbox can outlive both the request that created it and the connection carrying its output.」

> TODO: 每日情报条目标注的「60ms 启动、~118 次对抗零逃逸」在本次抓取的 README / architecture / ECW 文档中均未出现，数据来源待确认（可能在 Perplexity 官方博客而非仓库文档）。

## 技术架构拆解

### 核心设计决策

- **控制面 / 数据面分离**：管理请求走 API → PostgreSQL → Controller → K8s sandbox pod → runtime shim → worker services；命令输出则走独立的 data plane，用 session 级 scoped token 鉴权。控制面被命令流拖垮是最常见的自建沙箱失败模式，SPACE 从结构上避开了它。
- **Desired state 驱动**：API 只把期望状态写进 PostgreSQL，控制器再 reconcile。因此「请求被接受」不是「沙箱就绪」的信号——调用方必须轮询 operation、确认 sandbox running、再拿到可连的 process endpoint。牺牲易用性，换取崩溃后可恢复。
- **所有生命周期操作异步化**：create / pause / suspend / wake / delete 都返回 operation ID。文档明确区分三种状态：operation 状态描述生命周期请求，sandbox 状态描述环境，两者都不是命令的 exit status。
- **两级冻结语义**：`Paused` 保留 VM 内存驻留与 worker 上的文件系统（非持久快照）；`Suspended` 对 VM 内存、运行时状态、rootfs 做快照并释放 VM 资源。真正需要跨节点/跨时间恢复，用 suspend。
- **Template 与 sandbox 解耦**：template 可被多个 sandbox 共用而不被修改；支持 `seed:latest` 这类 tag 引用或 digest 引用，sandbox 响应会回报解析后的 digest，便于审计「到底跑了什么镜像」。
- **两种 worker 调度**：direct adapter 直接调 worker 服务（不创建 K8s pod），或走 Kubernetes adapter（Kind 参考部署用后者）。给了从小规模到集群的过渡路径。
- **ECW 定位诚实**：文档写明「ECW is a compatibility target maintained by SPACE, not an implementation of a versioned open E2B specification」，测试基线锁定 `e2b==2.21.1` 与 `e2b-code-interpreter==2.6.2`。
- **默认空闲回收**：经 API 创建的沙箱默认 6 小时无访问/无命令活动后 suspend——这是空闲上限，不是最大存活时间。

### 与前版/竞品的关键差异

| 维度 | E2B（典型用法） | Docker 容器自建 | SPACE |
|------|------------|------------|------------|
| 隔离粒度 | MicroVM / 托管沙箱 | 容器（共享内核） | Firecracker microVM |
| 控制面/数据面 | 托管，不暴露 | 自己拼 | 显式分离，独立 token 鉴权 |
| 生命周期操作 | SDK 内同步感知 | 由编排器决定 | 异步 operation + 轮询 |
| 冻结语义 | pause/resume | stop/start（丢内存） | Paused（驻留）/ Suspended（快照） |
| 客户端接入 | 原生 SDK | 需自写 | 原生 HTTP/SSE + ECW 兼容 E2B Python SDK |
| 部署形态 | 托管优先 | 自托管 | 自托管 K8s（Kind + EKS 参考） |
| 许可 | — | — | Apache-2.0 |

### 架构/信息流图

```text
                        ┌──────────── 管理面 ────────────┐
Application ──HTTP──▶ API ──▶ PostgreSQL(desired state)
                               │
                               ▼
                       Cluster Controller ──▶ Kubernetes sandbox pod
                                                    │
                                              SPACE runtime shim
                                                    │
                                              Worker services ──▶ Firecracker microVM
                                                    │                     │
                                              Object storage         Guest process
                                              (templates/snapshots)      │
                        └──────────── 数据面 ────────────────────────────┤
Application ──command stream──▶ Data plane ◀──────────────────────────────┘
```

在 Kind 参考部署里，sandbox pod 位于独立 `sandboxes` namespace，NetworkPolicy 只放行 API 与 cluster controller 的端口，出网限制在公网 IPv4 与集群 DNS。这些默认值是自托管时最容易被忽略、也最容易出事的部分。

## 实用评估

### 什么场景值得用

- **数据不出网的企业 agent 平台**：自托管 + template/snapshot 存自有 S3 兼容存储，并提供 `SPACE_TRUSTED_TEMPLATE_STORAGE_BUCKETS` 白名单拒绝非授权桶与 endpoint 覆盖。
- **长时 agent 的工作区**：suspend 快照内存与 rootfs 并释放资源，wake 恢复；「用户隔天回来继续」的语义比一断就死合理得多。
- **已有 E2B 代码想换后端**：改 `E2B_DOMAIN` / `E2B_API_KEY` 即可，Python SDK 调用方式不变。
- **平台方需要按 agent 计量与隔离**：独立 VM + ingress protection + access-wake 策略，能做细粒度权限管控。

### 什么场景不值得用

- **单机实验**：部署链路是 Kind 集群 / EKS + PostgreSQL + 对象存储（Kind 用 versitygw）+ 控制面/pods/shims/workers 一整套，跑几段代码完全不成比例。
- **期待开箱即用**：文档自己就提示本地部署要跑 smoke suites、处理 host 路径与非 dev 用户的坑；ECW 的 `seed-api-key.sh --execute` 被明确标注为「administrative database operation」。
- **需要 ECW 全兼容 E2B**：`mcp`、`volumeMounts`、`iam` 三类 create 能力直接 400 拒绝；`autoPauseMemory=false` 被拒；JS SDK 未纳入兼容测试；team/template tagged alias 不支持；`code-interpreter-v1` 别名的 template 必须预先存在。
- **需要强事务性文件语义**：写入在生命周期边界持久化，非逐次落盘——「an acknowledged one is not guaranteed to survive a sandbox crash, forced stop or host failure」。关键产物必须立刻导出。

### 迁移成本

| 迁移方向 | 需要做什么 | 粗略工作量 |
|---|---|---|
| E2B → SPACE（Python） | 部署 SPACE + 发布 template + 配 `SPACE_ECW_HOSTS` 与凭据密钥 + 改域名 | 半天到一天（不含集群搭建） |
| 自建 Docker 沙箱 → SPACE | 重写为 create → poll operation → command session → attach | 1–3 天，取决于已有封装 |
| 集群层面 | Kind 本地验证 → EKS 参考部署（`infra/space/aws/reference`） | 取决于平台团队 |

## 对你的意义

值得抄的不是 Firecracker，而是**状态模型**：operation / sandbox / process 三态分离，加上「断连不等于沙箱死」这条假设。做多 agent 编排时，把这三条状态线混成一个「running/idle」的粗粒度状态，几乎一定会在大规模并发下炸掉。

具体建议：
- **立即试用**：本地 Kind 起一遍，重点测 suspend → wake 的恢复延迟与 template publication 流程。
- **观望**：已在 E2B 上稳定运行且无数据合规压力，没有立刻搬的理由——ECW 的价值在你被锁定或被涨价时才兑现。
- **跳过**：只跑 agent 生成的少量脚本，进程级/QuickJS 沙箱成本低一个数量级。

## 关键代码/配置片段

ECW 接入（摘自 `docs/ecw.md`）：

```bash
export E2B_DOMAIN=sandbox.example.test
export E2B_API_KEY=<raw-key>
```

```python
import os
from e2b import Sandbox

sandbox = Sandbox.create(
    api_key=os.environ["E2B_API_KEY"],
    domain=os.environ["E2B_DOMAIN"],
    template="seed",
    timeout=60,
)
try:
    print(sandbox.commands.run("printf 'Hello from SPACE\\n'").stdout)
finally:
    sandbox.kill()
```

ECW 服务端配置（API 与 data plane 均需设置）：

```json
[{"apiHost": "api.sandbox.example.test", "host": "sandbox.example.test"}]
```

生命周期语义速查：

```text
Running   -> 可执行；保留 live VM memory + 可写文件系统
Paused    -> 停止执行；内存驻留、文件系统留在 worker；非持久快照
Suspended -> 停止执行；快照 VM 内存 + 运行时状态 + rootfs；释放 VM 资源
Deleted   -> 不再可通过 API 访问
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | SPACE 把沙箱工程化为带异步生命周期、挂起恢复与租户隔离的基础设施，是多 agent 并发的落地前提 |

---
[← Back to Deep Dives](./README.md)
