---
auto_generated: true
generated_at: "2026-08-26T06:48:57Z"
source_url: "https://www.36kr.com/p/3947852851664512"
signal_type: "significant_update"
---
# DeepSeek Harness v0.1.0-rc.8：将 Claude Code 与 Codex 收编为子代理（续报）

> 🔍 本文由 Moltbot 自动生成 | 2026-08-26
>
> **项目/工具**: DeepSeek Harness (dsh)
> **链接**: https://github.com/deepseek-ai/deepseek-harness/releases/tag/dsh-v0.1.0-rc.8
> **核心定位**: 一个"一切皆插件"的 Agent 运行时框架，让竞对的闭源 Agent（Claude Code、Codex）变成自己工作流里的可调度零件

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：DeepSeek Harness 是一个 MIT 开源的 Agent 调度层，Model + Harness = Agent，模型负责思考，Harness 负责所有工程化工作
- **現在值得用嗎**：观望。v0.1-rc.8 仍是预发布版本，官方明确警告"将有破坏性变更"，但架构方向值得跟踪
- **適合場景**：需要在一个工作台中调度多个 Agent（Claude Code + Codex + DeepSeek 模型）的团队；需要离线部署、模型可替换的 Agent 环境
- **不適合場景**：追求稳定生产环境的场景（rc 版本 + 每天数百次提交 + SQLite 数据结构已有一次不兼容变更）；对遥测敏感的场景（UUID 随请求发送且遥测开关不影响）
- **與 Claude Code / Codex 核心差異**：Claude Code 绑定 Anthropic 模型、Codex 绑定 OpenAI 模型，都是闭源成品；Harness 是 MIT 开源、模型随便换、还能把 Claude Code 和 Codex 当子代理调度

## 是什么 / 解决什么问题

Agent 时代的入口之争正在从"哪个模型最强"转向"哪个框架最好用"。Claude Code 和 Codex 分别绑定了 Anthropic 和 OpenAI 的模型生态——它们是好工具，但你被锁死在单一模型提供商里。

DeepSeek Harness 走了一条不同的路：**不绑定模型，反而把竞对的 Agent 收编为自己的子代理**。RC.8 版本中，Claude Code 和 Codex 可以作为 Profile Bundle 按需安装，在 Harness 的工作流里当具体任务的执行者。Codex 还支持非交互权限模式和多个命名实例——一个任务里可以同时挂好几个 Codex 干不同的活。

架构上最激进的设计是"一切皆插件"：模型、工具、技能、会话、沙箱、存储、调度、UI，甚至 Agent 主循环本身，全部是插件，全部可替换。底层微内核 Cordis 的启动清单只有 129 行，Agent 主循环和计时器插件的格式一模一样——没有任何零件是焊死的。

这个项目从 2026 年 6 月 10 日第一条提交到 8 月 13 日公开，64 天里完成了 12,293 次提交，附带 683 篇设计笔记，连被否决的 11 条方案都摊在仓库里。首日 GitHub Star 破 3 万、登顶 Hacker News，创下史上最快破 2 万 Star 的纪录。

## 技术架构拆解

### 核心设计决策

| 设计决策 | 理由 |
|---------|------|
| 一切皆插件（包括 Agent 主循环） | 避免任何组件成为不可替换的"特权层"，保持架构开放性 |
| 基于 Cordis 微内核 | Cordis 是成熟的插件化框架，DeepSeek 改了 18 处后直接嵌入 |
| MIT 协议开源 | 最大化生态 adoption，降低企业集成门槛 |
| Profile Bundle 机制 | 让 Claude Code / Codex 等外部 Agent 以标准化方式接入，而非硬编码集成 |
| 分时计价 + 默认路由自家 API | 商业化策略：开源框架引流，模型 API 变现 |

### 与前版/竞品的关键差异

| 维度 | Claude Code | Codex CLI | DeepSeek Harness rc.8 |
|------|------------|-----------|----------------------|
| 协议 | 闭源 | 闭源 | MIT 开源 |
| 模型绑定 | 仅 Anthropic | 仅 OpenAI | 任意（含本地部署） |
| 子代理调度 | 不支持 | 不支持 | Claude Code + Codex 作为 Profile Bundle |
| 原生多模态 | 支持 | 支持 | rc.8 新增（含"土法视觉"兜底） |
| 并发工具调用 | 不支持 | 不支持 | web_search 并发查询 |
| 离线部署 | 不支持 | 不支持 | 支持 |
| 定价 | 订阅制 | 按 API 用量 | 框架免费，V4-Flash 2 元/百万 token |
| 稳定性 | 生产级 | 生产级 | rc 预发布，有破坏性变更警告 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    DeepSeek Harness                      │
│  ┌───────────────────────────────────────────────────┐   │
│  │              Cordis 微内核 (129行)                 │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │   │
│  │  │调度插件  │ │会话插件  │ │工具插件  │ │UI 插件   │ │   │
│  │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ │   │
│  └───────┼───────────┼───────────┼───────────┼───────┘   │
│          │           │           │           │            │
│  ┌───────▼───────────▼───────────▼───────────▼───────┐   │
│  │              Model Adapters 层                     │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐           │   │
│  │  │DeepSeek  │ │OpenAI兼容 │ │本地模型   │           │   │
│  │  │V4-Flash  │ │Gateway   │ │(Ollama等) │           │   │
│  │  └──────────┘ └──────────┘ └──────────┘           │   │
│  └───────────────────────────────────────────────────┘   │
│          │           │           │                        │
│  ┌───────▼───────────▼───────────▼───────┐              │
│  │           Profile Bundles             │              │
│  │  ┌──────────────┐  ┌──────────────┐  │              │
│  │  │ Claude Code  │  │    Codex     │  │              │
│  │  │ (子代理)      │  │  (子代理,     │  │              │
│  │  │              │  │   多实例)     │  │              │
│  │  └──────────────┘  └──────────────┘  │              │
│  └───────────────────────────────────────┘              │
│          │                                              │
│  ┌───────▼───────────────────────────────┐              │
│  │        工具层 / 沙箱 / 存储            │              │
│  │  web_search(并发) | PTY终端 | SQLite  │              │
│  └───────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
```

RC.8 中新增的 **reportDelivery 机制** 是关键信息流改进：子代理完成任务后及时回传结果并唤醒等待中的父任务，多 Agent 协作不再需要干等轮询。

### RC.8 十四条变更的四条主线

| 主线 | 关键变更 | 技术意义 |
|------|---------|---------|
| 原生看图 | DeepSeek 适配器支持原生图片请求；/goal、/plan 支持图文混合输入 | 对不支持图像输入的模型，Harness 用 OCR + 颜色统计 + 像素扫描拼出"土法视觉" |
| 子代理收编 | Claude Code / Codex 作为 Profile Bundle 按需安装；Codex 支持非交互权限 + 多命名实例 | 竞对产品变成自己的零件，卡位调度层 |
| 工具链提速 | web_search 并发查询；Windows PTY 持久 PowerShell 会话；大历史会话分叉性能优化 | 多 Agent 并行工作的基础设施就绪 |
| 立规矩 | "DeepSeek Harness"标注为注册商标，发布品牌使用指南 | 开源归开源，品牌攥自己手里——为生态位做准备 |

## 实用评估

### 什么场景值得用

- **多模型 Agent 编排**：如果你需要同时调度 Claude Code（处理复杂编码任务）、Codex（处理标准化任务）和 DeepSeek 模型（处理低成本推理），Harness 提供了一个统一的工作台
- **离线部署需求**：MIT 开源 + 模型可替换 + 支持本地部署，适合对数据隐私有严格要求的场景
- **Agent 框架研究者**：Cordis 微内核 + "一切皆插件"的架构是研究 Agent 运行时设计的优秀案例；683 篇设计笔记和 11 条被否决的方案本身就是宝贵的工程文档
- **成本敏感场景**：V4-Flash 2 元/百万 token 的定价 + 框架免费，对于大量使用 Agent 的团队可以显著降低成本

### 什么场景不值得用

- **生产环境**：rc 版本 + 官方破坏性变更警告 + SQLite 数据结构已有一次不兼容变更，不适合生产部署
- **对遥测敏感**：跑起来后本机会生成 UUID 随每次请求发送，遥测开关不影响它——这对企业安全合规可能是个问题
- **只需要单一模型**：如果你只用 Claude 或只用 GPT，Claude Code 或 Codex CLI 的体验目前远好于 Harness（内测开发者证实）
- **插件生态成熟度**："一切皆插件"是双刃剑——插件之间的兼容性迟早会出问题，生态碎片化是这个路线自带的风险

### 迁移成本

从 Claude Code 迁移到 Harness：
- **学习成本**：需要理解 Profile Bundle 机制和插件化架构，约 1-2 天
- **配置成本**：安装 Claude Code Profile Bundle，配置非交互权限模式，约 30 分钟
- **风险**：SQLite 数据结构不兼容，已有 Harness 数据需备份；rc 版本可能随时 breaking change

从 Codex CLI 迁移到 Harness：
- **学习成本**：类似，需理解 Harness 的 Job Panel 统一管理界面
- **额外收益**：多 Codex 实例并行 + reportDelivery 机制可以显著提升批量任务效率

## 对你的意义

对 Ken 的 Agent + UI 方向来说，这个动态值得关注的核心信号是：**Agent 调度层正在成为独立赛道**。

过去 Agent 框架和模型绑定（Claude Code → Anthropic，Codex → OpenAI），但 Harness 证明了一个可能性：调度层可以独立于模型层存在，并且通过"收编"竞对 Agent 来建立自己的生态位。这类似于安卓的打法——自己不造手机，但让所有厂商都跑在自己的系统上。

**建议**：
- **立即跟踪，暂不试用**：rc 版本稳定性不够，但架构方向值得持续观察
- **关注插件生态**：如果 Harness 的插件生态在接下来 2-3 个月内成熟起来，可能成为 Agent 工作流的默认选择
- **注意遥测问题**：如果考虑在企业场景使用，需评估 UUID 遥测的合规风险

## 关键代码/配置片段

RC.8 的启动清单（129 行，Agent 主循环与计时器插件格式一致）：

```
# 启动清单节选 — 展示"一切皆插件"的平等性
# Agent 主循环插件和计时器插件使用相同格式：

plugin agent_main_loop {
  source = "./plugins/agent-main-loop"
  priority = 100
}

plugin timer {
  source = "./plugins/timer"
  priority = 50
}
```

Codex 子代理的多实例配置（据 release notes）：

```
# Codex 支持多个命名实例，在同一个任务中并行
profile codex-instance-1 {
  type = "codex"
  mode = "non-interactive"
  name = "refactor"
}

profile codex-instance-2 {
  type = "codex"
  mode = "non-interactive"
  name = "test"
}
```

> TODO: 以上配置片段基于 release notes 描述推断，具体语法请以官方文档为准。

---
[← Back to Deep Dives](./README.md)
