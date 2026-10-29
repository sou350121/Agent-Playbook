---
auto_generated: true
generated_at: "2026-10-29T05:45:47Z"
source_url: "https://github.com/NVIDIA/OpenShell/releases/tag/v0.1.6"
signal_type: "significant_update"
---
# NVIDIA OpenShell v0.1.6：把 agent 舰队关进内核级沙箱，策略变更先形式化验证 (NVIDIA OpenShell v0.1.6 — Kernel-Level Sandboxing and Formally Verified Policy Changes for Agent Fleets)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-29
>
> **项目/工具**: NVIDIA OpenShell
> **链接**: https://github.com/NVIDIA/OpenShell/releases/tag/v0.1.6
> **核心定位**: 一个专为「自主 agent 舰队」设计的安全运行时——用内核级拦截限制文件/系统调用/网络访问，并在策略变更生效前做形式化验证；v0.1.6 补上了强制网关认证、沙箱挂起/恢复与共享 supervisor 三块企业级拼图

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：让 agent 能读文件、装包、调 API、用凭证，但**永远拿不到不受限的访问权**——权限写进 policy，运行时由内核强制。
- **現在值得用嗎**：看场景。如果你已经在跑「多 agent 长时间自主执行 + 手里有生产凭证」的组合，这是目前少数把这个威胁模型当一等公民处理的运行时；如果只是单人本地写代码，Docker + 人工确认就够。
- **適合場景**：多 agent 舰队、需要给 agent 真凭证但又不能让它滥用、需要审计流量的 agent 平台
- **不適合場景**：单机单 agent 的轻量脚本任务、无法接受「网关 + supervisor + sandbox」三层部署心智负担的团队、纯 Windows 原生（仍为 experimental，WSL2 / MXC 路线）
- **與 Docker 沙箱核心差異**：Docker 给你隔离，OpenShell 在隔离之上加了**策略形式化验证 + 凭证注入只在批准端点生效 + OCSF 审计事件**——解决的是「agent 自己把自己提权了怎么办」

## 是什么 / 解决什么问题

AI agent 的有用程度，和它被授予的权限成正比。过去一年里工程侧的默认解法是「给 agent 一个容器」——但容器只回答「能不能碰到宿主机文件」，不回答更关键的问题：**这个 agent 这次该不该调用这个 API？它拿着这个 token 还能打到哪里去？今天它申请的这条新权限，明天会不会变成数据外泄的口子？**

NVIDIA 的 OpenShell 走的是另一条路。它的 README 把定位写得很直白：OpenShell 是 *"the safe, private runtime for fleets of autonomous AI agents"*。关键动词是 **fleets**（舰队）——不是单个 agent 的沙箱，而是一群 agent 的治理平面。

它用的两条手段值得单独抠出来看：

1. **内核级强制（kernel-level enforcement）**——每个 agent 跑在独立 sandbox 里，内核控制限制它能读哪些文件、能发哪些系统调用，**每一条网络连接在离开 sandbox 之前都要过一遍 policy 检查**。更关键的一句是：「agent 永远看不到真实凭证；OpenShell 只在发往已批准端点的请求上注入它们。」
2. **策略形式化验证（formally verified policy changes）**——策略变更在批准之前，先跑形式化验证，把「这次变更会新授予哪些风险访问」标出来，比如「用凭证去连一个新 host」或「调用一个新的 API method」，这些变更会卡住等人审。

换句话说，它把 agent 权限从「事后审计」推到「事前可证明 + 运行时强制」。这比「把 agent 丢进容器」要高一个抽象层级。

## 技术架构拆解

### 核心设计决策

- **控制面 / 数据面分离**：`gateway` 是控制面（管 sandbox、policy、access），`supervisor` 是每个 sandbox 的本地守护，sandbox 本身只是工作负载。这个三段式在 README 的 Architecture 文档里有明确描述。
- **凭证代理而非凭证分发**：agent 侧看不到明文 token，凭证以 provider 形式存在，仅在目标端点匹配策略时注入。这是防「agent 被 prompt injection 骗走 token」的最有效结构——token 根本不在 agent 的地址空间里。
- **策略变更走形式化验证闸门**：`advisor`（给建议）+ `prover`（证明）两个组件配合，可疑的新权限进入人工复核队列。注意：这拦的是**策略变更**，不是每次运行时调用——运行时靠内核拦截，两者分工不同。
- **多驱动抽象**：Kubernetes / Docker / Podman / VM 都是 compute driver，同一套 policy 语义在不同隔离强度上落地。VM driver 在 v0.1.6 里实现了 digest-pinned 镜像从本地缓存直启。
- **扩展面开放**：middleware、interceptor、compute driver 三类扩展点，允许外部接入自定义的请求检查逻辑。

### v0.1.6 的三个实质性变化

这一版（[release notes](https://github.com/NVIDIA/OpenShell/releases/tag/v0.1.6)）不是补丁堆叠，有三条会直接影响部署架构：

| 变化 | 内容 | 为什么重要 |
|------|------|-----------|
| **网关强制认证** | Gateway 现在**拒绝启动**，除非配置了 OIDC / mTLS 用户或 operator 认证 / gateway JWT。仅可信本地开发可设 `allow_unauthenticated_users = true`（PR #4821） | 把「默认无认证」这个最常见的裸奔模式从架构上删掉了。这是 breaking change，升级必须重新配 auth |
| **沙箱控制连接方向反转** | 新建 sandbox 的 control connection 改为 **从 sandbox 连向 supervisor**；已运行的 sandbox 保持原方向。旧二进制会拒绝新 sandbox，**supervisor 与 sandbox runtime 必须同步升级**（PR #4656） | 方向反转意味着 gateway/supervisor 侧不再需要主动 dial 进沙箱——对 NAT、Pod 网络策略、零信任网络更友好，但升级必须成套进行 |
| **沙箱挂起/恢复 + 共享 supervisor** | `openshell sandbox suspend` / `resume` 可用（需 compute driver 支持，否则返回 unimplemented）；Kubernetes 上可用实验性共享 supervisor，一个进程托管多个 sandbox，设 `supervisor_topology = "gateway"`（PR #4765、#4695） | 前者让「长跑 agent 闲时冻结」变得可计费/可回收；后者把「每 sandbox 一个进程」的常驻开销压下来 |

**安全面值得单独点名**：gateway 现在会输出 OCSF 格式审计事件，覆盖授权拒绝、凭证接受、SSH session token、sandbox token 检查，并在凭证疑似被滥用时抛出 High-severity finding（PR #4728/#4761/#4762）。同时本版更新 webpki 停止信任被攻破的 emSign CA（CVE-2026-111943，PR #4794）、russh 升到 0.64.1 修 GHSA-4wc5-f2rc-q74m（CVE-2026-111061，PR #4742）。对一个「安全运行时」项目来说，把自己依赖链的 CVE 修掉是最基本的可信度凭证。

### 与前版/竞品的关键差异

| 维度 | Docker / 普通容器沙箱 | OpenShell v0.1.6 |
|------|------------|------------|
| 隔离粒度 | 文件系统 + namespace | 文件访问 + 系统调用 + 每条网络连接 |
| 凭证处理 | 环境变量/挂载进容器（agent 可见） | agent 不可见，仅在批准端点注入 |
| 权限变更路径 | 改 compose/k8s manifest，直接生效 | policy diff → 形式化验证 → 人工复核风险项 |
| 多 agent 治理 | 各自为政，无统一平面 | gateway 统一管理 policy / access / audit |
| 审计 | 依赖外部日志采集 | 网关写 OCSF 事件，凭证滥用提 High finding |
| 高可用 | 依赖编排层 | v0.1.6 实验性 supervisor pool，可接管故障 supervisor 的 sandbox |

### 架构/信息流图

```
                 ┌──────────────────────────────────────┐
   agent 请求 ──▶ │  sandbox (内核拦截: 文件/syscall)     │
                 │    ├─ 文件访问 → policy check        │
                 │    └─ 出站请求 → policy check        │
                 └───────────────┬──────────────────────┘
                                 │ control connection
                                 │ (v0.1.6: sandbox → supervisor)
                    ┌────────────▼────────────┐
                    │   supervisor            │
                    │  (每 sandbox 一个进程    │
                    │   或 K8s 共享 pool)      │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   gateway (控制面)       │
                    │  ├─ auth: OIDC/mTLS/JWT │
                    │  ├─ policy 存储          │
                    │  ├─ advisor + prover    │
                    │  │    (策略变更前验证)   │
                    │  ├─ credential provider │
                    │  │    (仅在批准端点注入) │
                    │  └─ OCSF 审计事件        │
                    └────────────┬────────────┘
                                 │
                          外部 API / 数据源
```

策略变更的生命周期则是另一条独立链路：

```
policy diff 提交
      │
      ▼
  prover 形式化验证 ──▶ 标记风险项
      │                (新 host + 凭证 / 新 API method)
      ▼
  人工复核队列 ──▶ 批准 ──▶ 写入 gateway ──▶ 内核侧生效
              └─▶ 拒绝
```

## 实用评估

### 什么场景值得用

- **多 agent 平台型产品**：你有一个 gateway 统一管几十上百个 agent，每个的权限不同。OpenShell 的 policy + gateway 模型天然匹配这个形态，而 Docker 需要你自己搭一层编排逻辑。
- **agent 需要真凭证**：比如要读内部数据库、要调云厂商 API。凭证代理注入是这里唯一能让你睡得着的方案——agent 即使被 prompt injection 控制，偷到的也是「对已批准端点有效的一次性代理」，不是长期密钥。
- **合规/审计要求**：OCSF 事件 + authorization denial 记录 + High-severity finding，对需要向安全团队交付「agent 做了什么」证据的组织很实用。
- **成本敏感的长时间 agent**：`suspend`/`resume` 让空闲 agent 可以被冻结回收，这对「agent 等着人审」这种场景省资源。

### 什么场景不值得用

- **单机单 agent**：为了跑一个 coding agent 就部署 gateway + supervisor + sandbox 三层，收益远小于心智成本。Claude Code 自带的权限确认弹窗就够。
- **以 Windows 原生为主的环境**：Native Windows 仍是实验路线（走 Microsoft MXC），README 明确指向 `windows` 分支的 WINDOWS.md 说明「当前构建与运行时限制」。WSL2 可用但多一层钝化。
- **需要 Kubernetes 高可用但只有单副本**：实验性 shared supervisor 在 `replicas = 1` 时**没有备用实例可立即接管**。官方 note 说得很清楚：接管期间工作负载会短暂冻结、存量代理连接与交互 session 必须重连、恢复超时内未恢复则工作负载终止。把这当生产 HA 用会踩坑。
- **需要绝对轻量**：v0.1.6 把 Docker supervisor healthcheck 从 250ms 调到 30s（PR #4802），说明项目自己在往「别太吵」的方向调，但整体仍是一个有相当常驻开销的系统。
- **不想接受 breaking upgrade**：本版 gateway 强制认证、control connection 方向反转、`ResumeBoundaryRequest` 字段 3 从 `allow_cold_start_fallback` 改名 `restart_if_restore_fails`（外部隔离后端需同步）——升级不是 `pip install -U` 就完事。

### 迁移成本

从零上手：`curl -LsSf https://raw.githubusercontent.com/NVIDIA/OpenShell/main/install.sh | OPENSHELL_VERSION=v0.1.6 sh`，然后 `openshell sandbox create --name demo`。默认镜像是 minimal Ubuntu，**不含任何 agent**——要按 "Run Your First Agent" 教程接 OpenCode + OpenRouter 免费模型走一遍。

从 Docker 迁过来：主要工作不在镜像，而在**把散落在 compose/env 里的权限意图翻译成 policy**。这是纯脑力活，量级取决于你有多少个 agent 和多少条出站依赖。官方提供 `npx skills add NVIDIA/OpenShell` 安装 skills，教 coding agent 帮你写 policy 和调 gateway，这条能省不少。

SDK 侧：Python (`uv add openshell`)、TypeScript (`@nvidia/openshell-sdk`)、Go、Rust 四语言齐备。v0.1.6 起 Go SDK 模块按 `sdk/go/vX.Y.Z` 打 tag（PR #4262），Python SDK 开始自带 credential driver 与 extension protocol bindings，可以**用 Python 写凭证驱动**（PR #4760）——对不想碰 Rust 的团队是个实质减负。

## 对你的意义

Ken 的两个方向里，这条对 **Agent + UI 的工程线**更有直接价值，对 VLA 研究线是间接的。

**建议：观望为主，做一次 90 分钟的试探性评估。**

理由：
1. 你的 Agent-Playbook 场景目前是「单 agent 追信息 + 写报告」，权限模型简单，跑 OpenShell 属过度设计。
2. 但**凭证代理这个模式值得直接抄进你自己的架构**——不是抄代码，是抄结构。你现在 cron 任务里的 GitHub token、Telegram bot token 都是直接给进程的，一旦某个任务的 prompt 被污染，token 就暴露。把「token 只在出站请求时由代理注入」作为一个设计原则记下来，即使不用 OpenShell 也应该在自己脚本里做同构的事。
3. 如果未来要做**多 agent 协作**（A-003 方向），gateway 的 policy 模型是一个现成的参考实现——比你从零设计一套 agent 权限体系快得多。

具体动作建议：读一下官方 Architecture 文档和 Policy 的 advisor/prover 两节，重点看「策略 diff 怎么被形式化验证」。这部分思想可以迁移到你自己的配置管理里，不一定需要部署整个运行时。

## 关键代码/配置片段

以下均引自 v0.1.6 release notes 与 README，未做改写：

**安装（锁定版本）**
```bash
curl -LsSf https://raw.githubusercontent.com/NVIDIA/OpenShell/main/install.sh | OPENSHELL_VERSION=v0.1.6 sh
```

**创建沙箱 / 生命周期操作**
```bash
openshell sandbox create --name demo
openshell sandbox suspend <name>
openshell sandbox resume <name>
```

**可信本地开发：绕过强制认证（仅本地）**
```toml
[openshell.gateway.auth]
allow_unauthenticated_users = true
```

**Kubernetes 共享 supervisor（实验性，需 gateway TLS）**
```toml
[openshell.drivers.kubernetes]
supervisor_topology = "gateway"
```

**middleware 绑定策略（operator 可要求 middleware 提供指定绑定）**
```
binding_policy = "allowlist"   # 或 "exact"
```

**给 coding agent 装上 OpenShell skills**
```bash
npx skills add NVIDIA/OpenShell
```

> TODO: `binding_policy` 的完整配置示例（所在配置块名称与可选值）在 release notes 中只给出片段，需查 docs.nvidia.com/openshell 的 Extensibility 章节确认。
> TODO: 沙箱 `suspend`/`resume` 具体支持哪些 compute driver，未在 release notes 列出名单，需查 Sandboxes 文档。
> TODO: 共享 supervisor pool 的 `supervisor.replicas` 推荐值与资源占用未公开具体数字。

---
[← Back to Deep Dives](./README.md)
