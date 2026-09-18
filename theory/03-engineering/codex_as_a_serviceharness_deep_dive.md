---
auto_generated: true
generated_at: "2026-09-18T12:41:01Z"
source_url: "https://www.36kr.com/p/3979785466730377"
signal_type: "significant_update"
---
# Codex as a Service：Harness 层浮现两条路线之争 (Codex as a Service: Two Camps Emerge at the Harness Layer)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-18
>
> **项目/工具**: OpenAI Agents API / Codex Harness
> **链接**: https://www.36kr.com/p/3979785466730377
> **核心定位**: OpenAI 把 Codex 背后的 Agent Harness 抽出来做成托管云服务——开发者只需说明「任务 / 模型 / 工具 / 运行环境」四件事，长会话上下文压缩、工具调度与 subagent 协作全部由 OpenAI 托管。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：把「藏在 Codex 背后、负责让 Agent 持续工作」的那层 Harness 单独打包成云端 API，交付给所有开发者。
- **現在值得用嗎**：看場景。如果你能接受把 Agent 运行时交给供应商托管，它省掉一整层基础设施；如果要求完全自托管或深度定制，先别急。
- **適合場景**：想把 Coding Agent 稳定跑成线上服务、又不想自建长会话管理 / 沙盒 / 调度的团队；快速验证多 Agent 编排的产品团队。
- **不適合場景**：对 Harness 内部有强定制需求、数据必须留在自有基础设施、或不想被单一供应商绑定的团队。
- **與 DeepSeek Harness 核心差異**：OpenAI 把 Harness 做成「像 AWS」的托管服务；DSH 把 Harness 做成「像 Linux」的插件化开放框架。

## 是什么 / 解决什么问题

过去一年多，OpenAI 一直在做同一件事：把 Codex 从「一个具体产品」一层层拆成「可被复用的能力」。这条路线的终点，在美国时间 2026-09-10 正式落地——**Agents API 开放公测**。

同一天 OpenAI 一口气打出四张牌：Agents API、GPT-Live-1 API、Data agent、ChatGPT for Financial Services，横跨 Agent、语音、数据、金融四条产品线。其中技术含量最高、也最能说明战略意图的，是 Agents API。

痛点很清楚：在这之前，SDK 主要适合在程序里调用 Codex，适合后台工作流和服务端程序，但想做完整客户端仍很困难；App Server 虽然把 Harness 接口开放给了 JetBrains、Xcode 等客户端，但它本身是一个需要开发者自己启动和维护的常驻进程。也就是说——「把 Codex 接进产品」这件事解决了，但「把它稳定地跑成一个线上服务」还差一层。

Agents API 填的就是这一层。**开发者只需要告诉 API 四件事——任务、模型、工具、运行环境——就可以直接创建一个 Agent**，负责长会话上下文压缩、工具调度和 subagent 协作的 Codex Harness 由 OpenAI 自己托管和维护。

## 技术架构拆解

### 核心设计决策

- **Harness 与执行环境解耦**：Agent 真正干活的机器可以由开发者自选——OpenAI 自家沙盒、自己的基础设施、或 Cloudflare / E2B / Modal 等第三方环境。官方口径是「Harness 由 OpenAI 提供，执行环境由开发者决定」。
- **不计平台费，按用量计费**：官方明确 Agents API 本身不额外收费——Harness 托管、长会话管理等能力不再单独收一层「Agent 平台费」。开发者按实际使用的模型 Token 和工具付费；若使用 OpenAI 托管沙盒，计算资源另算。
- **渐进式拆解，而非一次性发布**：从 CLI（2025-04 开源）→ 云端版（2025-05）→ SDK（2025-10）→ App Server（2026-02）→ 平台叙事（2026-08-19）→ Agents API（2026-09-10），每一步都在把 Codex 的一层能力外化。
- **平台化定位**：2026-08-19 OpenAI 把此前陆续开放的 CLI、SDK、App Server 统一放进「开放 Codex Harness」的平台叙事，明确把 Codex 从一个产品提升成平台。

### 与前版/竞品的关键差异

| 维度 | 之前（SDK / App Server） | 现在（Agents API） |
|------|------------------------|-------------------|
| 运行方式 | 开发者自行启动、维持常驻进程 | OpenAI 托管 Harness，作为云服务调用 |
| 开发者职责 | 自建长会话管理、调度、基础设施 | 只决定「做什么 / 用什么工具 / 在哪里跑」 |
| 执行环境 | 本地或自建 | 可选 OpenAI 沙盒 / 自建 / Cloudflare / E2B / Modal |
| 适用边界 | 后台脚本、服务端程序 | 线上服务、完整客户端、多 Agent 编排 |
| 计费 | 自行承担 | 按模型 Token + 工具付费，平台能力不计费 |

| 维度 | DeepSeek Harness (DSH) | OpenAI Agents API |
|------|----------------------|-------------------|
| 哲学 | 「一切皆插件」，开放生态（像 Linux） | 「钱和需求给到位，剩下的我帮你解决」（像 AWS） |
| Harness | 模型/工具/Skills/Session/沙盒/存储/Agent Loop/调度/UI 全可替换 | 由 OpenAI 托管与持续维护 |
| 心智模型 | Agent = Model + Harness，开发者自己组装 | Harness 可自取开源、也可完全托管 |

### 架构/信息流图

```
开发者                     Agents API                 Codex Harness (OpenAI 托管)
  │                            │                              │
  │  ① 提交四要素               │                              │
  │  ─ task ─────────────────► │                              │
  │  ─ model ────────────────► │ ─── Agent Loop ───────────►  │
  │  ─ tools ────────────────► │ ─── Thread / 长会话压缩 ───►  │
  │  ─ runtime env ──────────► │ ─── 工具调度 / subagent ──►  │
  │                            │                              │
  │                            │ ◄── 执行环境（可选其一）─────  │
  │                            │      OpenAI 沙盒             │
  │                            │      自建基础设施             │
  │                            │      Cloudflare / E2B / Modal│
```

## 实用评估

### 什么场景值得用

- **想快速把 Coding Agent 做成产品**：前端已用 App Server 接上 Codex，但「用户点下『修复这个仓库』之后」的大量运行与基础设施问题，过去要自己解决；现在交给 Agents API 托管。
- **需要多 Agent 编排 / 长任务**：subagent 协作、长会话上下文压缩内置，省掉自研协调层。
- **基础设施不想自建，但执行环境想自控**：可以把执行放在自有集群或第三方沙盒，Harness 仍由 OpenAI 维护。

### 什么场景不值得用

- **强定制 Harness**：需要改 Agent Loop、Thread 语义或私有调度策略的团队，托管服务是黑盒。
- **数据/合规约束**：要求运行时全自托管、数据不出自有基础设施的场景，托管 Harness 是硬伤。
- **避免供应商绑定**：把核心运行时绑定到单一供应商，长期议价与迁移风险需自行评估。
- **想白嫖「零成本」**：API 本身不计费，但模型 Token、工具调用、托管沙盒计算资源都产生成本。

### 迁移成本

从 SDK / App Server 迁移到 Agents API，理论上主要是把「自己维持的常驻进程 + 调度逻辑」换成「一次 API 调用 + 四要素声明」。难点不在代码，而在**长会话状态与工具权限模型的对齐**——原本自管的 Thread、认证、状态需要映射到 OpenAI 托管语义。原文字面未给出迁移工具或兼容层，具体工作量待确认。可用开源 Codex Harness 作为过渡对照。

## 对你的意义

如果你在做 Agent + UI 方向：这次更新把「Harness」这一层从隐性变成显性的采购/架构决策点。一个可操作的判断框架是——

- 你的产品差异化在 **UI 与工作流编排**，而非 Agent Loop 本身 → 托管 Harness 是加速器，值得尽早试用。
- 你的护城河在 **对 Harness 的控制**（上下文策略、工具权限、成本） → 观察 DSH 这类插件化框架，保持可替换性。

更深一层的信号是：竞争的维度正在从「智力」（模型能力）转向「执行力」（Harness 能否把活干完）。原文指出，一旦执行力成为核心，**最占优势的未必是模型最强的公司**——因为 Agent 干活需要的邮件、文档、会议、通讯、账号权限等，多掌握在传统平台公司手里。原文以 Google 为例：其 TPU / 云 / Gemini / Search / Workspace / Chrome / Android 覆盖全栈，且 Gemini Spark、Gemini API 的 Managed Agents、Search 中的部分 Agent 体验正逐渐共享同一套 Antigravity Harness——但用户端产品仍显混乱（Gemini Spark、Workspace Studio、Antigravity、Gemini Enterprise、Search Information agents 并存），缺一个统一的「产品答案」。

对开发者而言，这条路线之争的直接含义是：**Harness 层会成为未来 12 个月最激烈的绑定战场**。建议现在就把「Harness 是否可替换」作为选型硬指标。

## 关键代码/配置片段

> 原文为媒体报道，未包含可引用的官方 SDK 代码。以下为根据原文描述归纳的**概念性调用契约**，非官方示例，请以官方文档为准。

```
# 概念性结构（非官方 SDK 代码，待验证）
create_agent(
    task       = "...",          # 要 Agent 完成什么
    model      = "...",          # 指定模型
    tools      = [...],          # 可调用的工具
    runtime    = "openai" | "self-hosted" | "cloudflare" | "e2b" | "modal"
)
# Harness（长会话压缩 / 工具调度 / subagent 协作）由 OpenAI 托管
# TODO: 官方 Agents API 的确切请求字段、认证方式与配额，请核对官方文档
```

时间线速览（据原文）：

- 2025-04　Codex CLI 开源（随 o3 / o4-mini）
- 2025-05　Codex 云端版上线
- 2025-10　Codex SDK 发布
- 2026-02　Codex App Server 公开，Harness 首次被系统讲清（双向 JSON-RPC）
- 2026-08-19　CLI / SDK / App Server 统一为「开放 Codex Harness」平台叙事
- 2026-09-10　Agents API 公测

---
[← Back to Deep Dives](./README.md)
