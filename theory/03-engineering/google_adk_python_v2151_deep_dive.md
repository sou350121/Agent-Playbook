---
auto_generated: true
generated_at: "2026-11-27T11:00:50Z"
source_url: "https://github.com/google/adk-python/releases/tag/v2.15.1"
signal_type: "blog_post"
---
# Google ADK Python v2.15.1：一次「反模式修正」的稳定版 (ADK Python v2.15.1: A Stability Release That Reverses a Streaming Change)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-27
>
> **项目/工具**: Google Agent Development Kit (ADK) for Python
> **链接**: https://github.com/google/adk-python/releases/tag/v2.15.1
> **核心定位**: 这是一次纯稳定性补丁版本——没有新能力，只有四个针对多模型兼容、A2A 流式持久化、工具参数校验、动态指令路由的 bug 修复；其中一项是明确的回滚（revert）。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：把 Claude 采样配置、RemoteA2aAgent 流式输出、Apigee 工具参数校验、动态指令门控这四处的「会出错」修成「不出错」。
- **現在值得用嗎**：**看你是否踩过这四个坑**。用 Anthropic 2.x SDK 配 Claude、或用 RemoteA2aAgent 做 multi-agent 编排的团队应当立即升级；纯本地单 agent 项目可以等下次功能版。
- **適合場景**：跨厂商模型混用（Gemini + Claude）、agent-to-agent 远程调用、Apigee 工具链、`include_contents` / 动态指令门控等高级路由。
- **不適合場景**：期待新 feature（Memory、Evaluation 新能力、新工具协议）的人——这个版本一个都没有。
- **與前一版核心差異**：修正了 v2.15.0 引入的 RemoteA2aAgent「无 last_chunk 也落盘」行为，回滚到更保守的持久化语义（issue #7255）。

## 是什么 / 解决什么问题

ADK（Agent Development Kit）是 Google 开源的 agent 开发框架，Python 版是其中主力实现。它试图解决的是「agent 不该每次都从零手写工具循环、session 管理、多 agent 编排」这件事——提供 LlmAgent、Tool、Session、Runner、A2A 等一层抽象。

v2.15.1 是一个典型的 **patch 版本**：release notes 的 Highlights 原文写得很清楚——「This release focuses on stability and integration bug fixes across model sampling, agent-to-agent streaming, tool call validation, and instruction routing.」四个面，四个 commit，零新 API。

这类版本的价值不在「能多做什么」，而在「少炸什么」。对已经在生产里跑 ADK 的团队，它回答的是四个具体问题：

1. **同时支持 Anthropic SDK 1.x 和 2.x** —— 升级 SDK 后 Claude 的 sampling 参数（temperature / top_p / top_k 等）是否还能正确透传。
2. **RemoteA2aAgent 的流式输出到底该不该在没有 `last_chunk` 时落盘** —— 这是一个明确的取舍，v2.15.1 选择了「不落」。
3. **工具参数不是 JSON object 时要静默失败还是显式报错** —— 走显式报错。
4. **transient instruction 被误当成持久 instruction 而导致门控错乱** —— 改为正确追踪。

## 技术架构拆解

### 核心设计决策

- **取向一：宁可回滚，不留半成品状态**。A2A 的 bug fix commit 标题直接就是 `revert persisting streamed RemoteA2aAgent output without last_chunk`（c4bdc84，关闭 issue #7255）。说明 v2.15.0 加入的「流结束后即使没收到 last_chunk 也把累积内容写入 session」是一个过于激进的优化：它让部分 remote agent 实现「看起来能用」，但会在真正的错误/截断场景下把**不完整的输出当作完整结果**持久化下来，污染后续轮次的上下文。回滚是承认：不完整比没有更糟。
- **取向二：跨 SDK 版本的兼容层放在框架里，不推给用户**。`handle Claude sampling settings on anthropic 1.x and 2.x`（debf43d）意味着 ADK 内部对不同 Anthropic SDK 的 sampling 配置字段差异做了适配，而不是让用户按 SDK 版本写 if/else。
- **取向三：错误要显式，不要猜**。`report Apigee tool calls whose arguments are not a JSON object`（6a4ba6a，issue #7740）——过去模型给出的 tool arguments 若是一个裸数组或字符串，可能被静默吞掉或触发难以定位的下游错误；现在直接报错。对 agent 调试来说，**错误的可观测性**比错误的自愈更重要。
- **取向四：区分「本轮临时指令」与「持久指令」**。`track transient instructions and gate dynamic instruction routing`（347dca6，issue #8217）——动态指令门控依赖对 instruction 生命周期的准确理解；把 transient 混进持久集合，会导致门控条件在多轮之后仍然生效，产生「莫名其妙还在守旧规则」的行为漂移。

### 与前版/竞品的关键差异

从版本层面看，v2.15.1 与 v2.15.0 的差异非常窄：

| 维度 | v2.15.0（前一版） | v2.15.1（本版） |
|------|------------|------------|
| Claude sampling 配置 | 按某一代 Anthropic SDK 字段处理 | 兼容 SDK 1.x 与 2.x 两套字段 |
| RemoteA2aAgent 流式落盘 | 无 `last_chunk` 也持久化累积输出 | **回滚**：无 `last_chunk` 不落盘（#7255） |
| 工具参数非 JSON object | 静默 / 下游随机报错 | Apigee tool call 显式报错（#7740） |
| 动态指令门控 | transient instruction 未被正确追踪 | 正确追踪并门控（#8217） |
| 新增 API | — | 无 |
| 破坏性变更 | — | 仅行为语义修正（对依赖旧落盘行为者有影响） |

与竞品横向对比意义不大——这类补丁版本本质是「框架自身一致性维护」，不是能力竞争。真正值得对比的是「框架对 A2A 流式语义的处理哲学」：ADK 选择了严格（缺 last_chunk 即视为未完成），而不是宽容（尽力而为）。

### 架构/信息流图

```
               ┌─────────────────────────────────────────┐
               │              ADK Runner                 │
               └───────┬───────────────┬─────────────────┘
                       │               │
        ┌──────────────▼──┐      ┌─────▼──────────────────┐
        │   LlmAgent      │      │  RemoteA2aAgent        │
        │  ┌───────────┐  │      │  (A2A over HTTP)       │
        │  │ Models    │  │      │  streaming chunks      │
        │  │ layer     │  │      └─────┬──────────────────┘
        │  │ • Gemini  │  │            │ last_chunk?
        │  │ • Claude  │◄─┼─ sampling   ├── yes ─► persist to Session
        │  │  1.x/2.x  │  │   settings  └── no  ─► DISCARD (v2.15.1 回滚点)
        │  └───────────┘  │
        │  ┌───────────┐  │
        │  │ Tools     │  │  args must be JSON object
        │  │ • Apigee  │──┼── if not ─► explicit error (#7740)
        │  └───────────┘  │
        │  ┌───────────┐  │
        │  │Instruction│  │  transient vs persistent
        │  │  gating   │──┼── track transient → correct gating (#8217)
        │  └───────────┘  │
        └─────────────────┘
```

## 实用评估

### 什么场景值得用

- **CLI / 服务端里跑 Claude**：如果你的 ADK 项目用 Anthropic provider，且近期升级过 `anthropic` SDK 大版本，v2.15.1 直接消除了「sampling 配置被忽略或报 TypeError」这一整类问题。
- **A2A 多 agent 编排**：官方把「无 last_chunk 不落盘」当作正确语义。如果你的架构依赖 remote agent 的输出必须完整才能进入下一 agent，这个版本是必须的——否则你会拿到「看似成功、实际截断」的上下文。
- **Apigee 工具接入**：参数校验显式化能显著缩短「模型为什么一直调错」的排查时间。
- **依赖动态指令门控的高级路由**：多角色 / 多阶段 agent 里，transient instruction 泄漏会让状态机悄悄退化，这版修的是隐性 bug。

### 什么场景不值得用

- **期待功能升级**：本版没有 New Features 章节。想用新工具协议、新 memory 后端、新 evaluation 能力，等下一个 minor。
- **依赖「宽松落盘」的自研 Remote agent**：如果你的 remote agent 本来就不发 `last_chunk`，v2.15.1 会让你「突然拿不到输出」。这不是 bug，是语义收紧——**升级前先确认对端 A2A server 是否正确发送终止 chunk**。
- **纯 Gemini + 本地 tool 的简单项目**：无 Claude 采样、无 A2A、无 Apigee，本版对你的实际行为零变化。升级无风险，但也无收益。

### 迁移成本

- **版本号替换**：`pip install -U google-adk==2.15.1`，通常零代码改动。
- **A2A 对端检查**：这是唯一有真实工作量的地方。需要验证 A2A 服务端在正常结束时确实发送 `last_chunk`。工作量视对端实现而定——若对端是自研 server，可能需要 0.5–1 天排查协议实现。
- **Apigee 工具**：若过去就依赖「静默忽略非法参数」的行为，可能出现以前不报错、现在报错的情况——这属于要修的 bug，不是阻阻升级的理由。

## 对你的意义

对 Agent + UI 方向的实践，这个版本给出几条可直接借用的工程判断：

1. **流式持久化应当以「显式终止信号」为准**。ADK 的回滚告诉我们：在 agent 系统里，「尽力而为地保存」往往比「什么都不保存」更危险，因为下游无法区分「完整」与「截断」。你自己写 Chat UI 的流式渲染 / 消息落库时，如果拿不到终止事件，应当标记为 incomplete 而不是正常入库。
2. **transient vs persistent 的区分是 agent 状态机的常见漏洞**。你的 RAG / workflow 系统里若有「临时指令」（如本次请求的格式要求）混在会话级 system prompt 里，多轮后会累积漂移。ADK 在框架层分离这两类 instruction，值得在架构文档里抄这一条。
3. **工具参数校验放到入口处**。模型给出的 tool call args 不做类型守卫，错误会漂移到很远的地方才爆。这与 MCP 工具生态的趋势一致——工具层要自己守边界（呼应假设 A-001：工具集成标准化/A2A 与 MCP 共同推动协议层收敛）。

**建议**：如果现在跑 ADK 且有 A2A 或 Claude，立即升级；如果还只在概念验证阶段，把这个版本当作「ADK 对 A2A 语义的定义」来读，比当作变更日志更有价值。

## 关键代码/配置片段

release notes 中给出的升级路径（非编造，来自 v2.15.1 changelog）：

```bash
pip install -U google-adk==2.15.1
```

本版涉及的四个 commit（可按需 diff 阅读实现细节）：

```text
A2A revert:      c4bdc84  revert persisting streamed RemoteA2aAgent output without last_chunk  (#7255)
Models:          debf43d  handle Claude sampling settings on anthropic 1.x and 2.x
Tools:           6a4ba6a  report Apigee tool calls whose arguments are not a JSON object  (#7740)
Routing:         347dca6  track transient instructions and gate dynamic instruction routing  (#8217)
```

> TODO: 官方未给出各修复的具体 benchmark 或回归测试数据；如需量化「A2A 截断污染率」，需自行在本地 A2A 链路上做对照实验。

---
[← Back to Deep Dives](./README.md)
