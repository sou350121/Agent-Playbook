---
auto_generated: true
generated_at: "2026-10-01T05:45:56Z"
source_url: "https://claude.com/blog/claude-code-on-the-web"
signal_type: "significant_update"
---
# Claude Code 云端会话正式 GA：从「浏览器里的 Coding Agent」到跨端会话层 (Claude Code Cloud Sessions Reach General Availability)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-01
>
> **项目/工具**: Claude Code 云端会话 (Cloud Sessions, 前称 Claude Code on the web)
> **链接**: https://claude.com/blog/claude-code-on-the-web
> **核心定位**: Anthropic 把「在云上跑的 coding agent」从 2025 年 10 月的浏览器 beta，升级为跨浏览器/终端/桌面/移动端的正式产品能力，解决「任务要脱离本机持续运行、还要能跨设备接管」的问题。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Claude Code 现在能把一次编码会话放到 Anthropic 托管的云容器里跑，关掉笔记本任务继续，浏览器、手机、桌面、终端任意一处都能查看和接管。
- **現在值得用嗎**：看場景。如果你的痛点是「并行处理 bug backlog / 例行修复 / 后端改动」，且团队已在用 Claude Code，值得试；如果任务需要本机文件系统的私有依赖或强离线环境，观望。
- **適合場景**：批量 bugfix、例行的 well-defined 任务、跨仓库并行改动、后端 TDD 流程、移动端随手派发/查看任务。
- **不適合場景**：需要访问本机私有资源/内网服务的任务、对 Anthropic 托管凭证存储有硬合规限制的团队、完全没有 GitHub 仓库的纯本地项目（`--cloud` 只处理单个 repo）。
- **與前版核心差異**：beta 时期（Claude Code on the web, 2025-10-20）只有浏览器入口；GA 后改名 Cloud sessions，并把入口扩展到 5 个 surface（浏览器 / 移动 / 桌面 / 终端 `--cloud` / Routines 定时触发），引入可配置的 cloud environments 与 `--teleport` 双向迁移。

## 是什么 / 解决什么问题

Claude Code 最初是一个跑在开发者本机终端里的 agent：你在自己的机器上开一个会话，它读写你本地的代码。这个模型的问题很直接——**会话被绑死在本机**。你关掉笔记本，任务就断了；你想同时处理三个 repo 的 bug backlog，就得开三个终端本地并行，吃满本机 CPU 和上下文。

2025 年 10 月 20 日，Anthropic 发布了 Claude Code on the web 的 beta（研究预览），把会话搬到 Anthropic 托管的云基础设施上运行，浏览器即可派发任务、自动开 PR。2026 年 9 月 23 日，Anthropic 在博客顶部更新：**Cloud sessions（即此前的 Claude Code on the web）正式 GA**，覆盖 Pro、Max、Team 用户，以及持有 premium seats 或 Chat + Claude Code seats 的 Enterprise 用户（来源：官方 blog 更新，2026-09-23）。

也就是说，这次 GA 的核心不是「加了一个新功能」，而是**把云会话从一个实验性的浏览器入口，升级为一个统一的「会话层」**：同一套 cloud environments、同一套 GitHub 鉴权、同一套会话生命周期，被浏览器、终端、桌面 App、移动 App 和定时任务（Routines）共享。对用户的实际意义是——你可以「在本机规划、在云上执行、在手机上接管」。

## 技术架构拆解

### 核心设计决策

- **会话跑在云 VM，而非本机进程**：默认跑在 Anthropic 托管的基础设施上，也可以通过 self-hosted environment 路由到组织自建环境（来源：docs「Use Claude Code in the cloud」）。
- **会话与「入口」解耦**：会话是一个后端实体，浏览器、移动端 Code tab、桌面 App 的 Cloud 模式、终端、Routines 都只是不同的接入面。同一会话可以在多个 surface 之间被观察和控制。
- **`--cloud` 以「推送后的远端分支」为准**：云端 VM 克隆的是你在当前目录的 GitHub remote 在当前分支上的版本，**不是你的本地 checkout**。本地有未推送的 commit 必须先 push（来源：docs）。
- **凭证不进 VM**：在 Anthropic 托管环境下，GitHub 凭证加密存储在 Anthropic 服务器上，永远不进入会话的 VM；VM 内的 GitHub 操作走 GitHub proxy，由服务端在请求上附加凭证（来源：docs）。
- **沙箱网络白名单**：每个任务跑在隔离沙箱里，有网络和文件系统限制；可以通过自定义网络配置指定 Claude 能连接哪些域名（例如允许从公网拉 npm 包以便跑测试）（来源：官方 blog）。
- **Plan mode 做「本地规划 → 云上执行」的分工**：官方推荐先用 plan mode 在本机和 Claude 对齐方案（只读文件、不写代码），满意后把 plan 存进 repo、commit、push，再开云会话做自主执行（来源：docs "Tips for cloud tasks"）。
- **两种 GitHub 鉴权路径**：GitHub App 授权（web onboarding，可访问任意 public repo + 已安装 App 的 private repo，并启用 Auto-fix）；或 `/web-setup`（把本地 `gh` CLI token 传给 Claude 账号，可访问 gh token 能碰到的任意 repo）。

### 与前版 / 竞品的关键差异

| 维度 | beta（Claude Code on the web, 2025-10） | 现在（Cloud sessions GA, 2026-09） |
|------|------|------|
| 产品命名 | Claude Code on the web | Cloud sessions（浏览器入口仍叫 claude.ai/code） |
| 入口面 | 仅浏览器（+ iOS 早期预览） | 浏览器 / 移动 Code tab / 桌面 Cloud 模式 / 终端 `--cloud` / Routines |
| 环境配置 | 基础沙箱 | Cloud environments（网络访问、环境变量、setup script 可配） |
| 本机↔云迁移 | 无 | `claude --cloud` 上传任务、`--teleport` 拉回终端 |
| GitHub 鉴权 | GitHub App | GitHub App 或 `/web-setup`（gh token） |
| PR 自动化 | 自动开 PR | 自动开 PR + Auto-fix（自动响应 CI 失败与 review 评论） |
| 可用范围 | Pro / Max（研究预览） | Pro / Max / Team；Enterprise（premium seats 或 Chat + Claude Code seats） |

（注：竞品侧本文未做横向 benchmark 对比，避免在没有一手数据的情况下下结论。）

### 架构 / 信息流图

```text
             ┌───────────────────────── 入口 (Surfaces) ─────────────────────────┐
             │  Browser claude.ai/code   Mobile (Code tab)   Desktop (Cloud)      │
             │  Terminal: claude --cloud  Routines (scheduled/triggered)          │
             └───────────────────────────────┬───────────────────────────────────┘
                                             │  (同一会话实体, 可跨端观察/接管)
                                             ▼
                              ┌──────────────────────────────┐
                              │   Cloud Session (云 VM)       │
                              │  - 克隆远端已 push 分支        │
                              │  - 隔离沙箱 (网络/文件系统限制) │
                              │  - 运行 setup script / 环境变量│
                              └───────┬──────────────┬────────┘
                                      │              │
                       GitHub proxy ──┘              └── 自定义网络白名单 (如 npm)
                    (服务端附加凭证, 凭证不进 VM)
                                      │
                                      ▼
                          GitHub repo → 分支 → 自动 PR → Auto-fix (CI/评论)
```

## 实用评估

### 什么场景值得用

- **批量、定义清晰的修复**：bug backlog、例行修复。官方明确点名这是 beta 阶段的目标场景，且每个 `--cloud` 命令独立成一个会话，可以并行推进。
- **后端改动 + TDD**：官方指出后端改动的场景尤其适合，因为 Claude Code 可以用测试驱动开发来验证改动（来源：官方 blog）。
- **跨仓库并行**：从一个界面同时跑不同 repo 的任务，比开多个本地终端更省本机资源。
- **移动端随手派发/查看**：Code tab 让开发者「在移动中」也能派发任务和查看进度。
- **跨设备接管长任务**：关掉笔记本后会话继续跑，回来后可从任意设备接管。

### 什么场景不值得用

- **依赖本机私有上下文的任务**：`--cloud` 是基于 GitHub remote 克隆的，本地未推送的改动不会被带上（除非走「非 GitHub 本地仓库上传」的特殊路径）。
- **强合规/凭证敏感的团队**：虽然凭证在 Anthropic 侧加密、不进 VM，但「把 repo 授权给第三方托管执行」这件事对某些组织仍是硬门槛——self-hosted environment 是缓解路径，但配置成本更高。
- **完全没有 GitHub 的项目**：`--cloud` 一次只处理一个 repo，且主线依赖 GitHub 连接。
- **额度焦虑场景**：云会话与所有其他 Claude Code 用量**共享 rate limit**（来源：docs 「Limitations」），并行越多越容易撞限额。

### 迁移成本

- 已经在用 Claude Code CLI 的用户：几乎零迁移——用同一个 claude.ai 账号登录，加一个 `--cloud` 即可开始。旧的 `--remote` 拼写仍作为 deprecated alias 可用。
- 团队接入：需要决定 GitHub 鉴权走 GitHub App 还是 `/web-setup`；若要用 Auto-fix 与 project 内的跨 repo 克隆，需要在每个目标仓库安装 Claude GitHub App。
- Team/Enterprise：`/web-setup`（Quick web setup）在 Team 与 Enterprise 上**默认关闭**，需要 Owner 在 Admin settings > Claude Code 打开。这是一个容易被忽略的开关。

## 对你的意义

对 Ken 这类「Agent + 工程实践」双线关注的人，这次 GA 的信号价值大于功能价值：

1. **「会话」正在取代「界面」成为一等公民**。Anthropic 把浏览器、终端、桌面、移动、定时任务统一到同一个 cloud session 实体上——这与 AI App 领域「agent 平台解耦执行与交互」的趋势一致。值得放进 Agent-Playbook 的架构模式里观察。
2. **agentic coding 的工程化护栏被拉齐了**：沙箱隔离、网络白名单、GitHub proxy 服务端附加凭证、Auto-fix 回应 CI/评论——这些不是「模型更强」，而是「让 agent 可以安全放手跑」的基础设施。这比跑分更能说明 agentic coding 在往生产走。
3. **建议**：可以立即试用（低成本，兼容现有 Claude Code 账号），重点验证两件事——(a) 并行会话撞 rate limit 的实际体感；(b) 沙箱网络白名单对拉取私有依赖的限制。若你团队偏本地/内网开发，先观望 self-hosted environment 的成熟度。

> TODO: 候选标题提到「老用户最高赠 250 美元额度」，本次可核实的一手来源（官方 blog / docs）中未见该促销细节，故不作为结论。待确认后补充。

## 关键代码/配置片段

从终端把当前目录的任务发到云端（云 VM 克隆的是远端已 push 的分支，本地未提交改动请先 push）：

```bash
claude --cloud
```

官方推荐的「本地规划 → 云上执行」工作流：先在 plan mode 与 Claude 对齐方案，再把 plan 存入 repo、commit、push，然后开云会话执行（来源：docs "Tips for cloud tasks"）。

从终端连接 GitHub 的另一种方式——把本地 `gh` CLI token 交给 Claude 账号：

```text
/web-setup
```

（`--cloud` 一次只处理一个仓库；旧的 `--remote` 仍作为 deprecated alias 可用。）

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Cloud sessions GA + Auto-fix（自动响应 CI 失败与 review 评论）+ 官方主推「bug backlog / 例行修复 / 后端 TDD」等初级任务场景，说明 Anthropic 认为 agentic coding 在这些任务上已具备可放手的生产成熟度。 |

---
[← Back to Deep Dives](./README.md)
