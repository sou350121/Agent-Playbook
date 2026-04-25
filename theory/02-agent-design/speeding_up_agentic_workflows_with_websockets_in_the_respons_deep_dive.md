---
auto_generated: true
generated_at: "2026-04-25T05:46:45Z"
source_url: "https://openai.com/index/speeding-up-agentic-workflows-with-websockets/"
signal_type: "blog_post"
---
# OpenAI Responses API WebSocket 模式：Agent 循环延迟降低 40% (Speeding up Agentic Workflows with WebSockets in the Responses API)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-25
>
> **项目/工具**: OpenAI Responses API — WebSocket Mode
> **链接**: https://openai.com/index/speeding-up-agentic-workflows-with-websockets/
> **核心定位**: OpenAI 为 Responses API 引入 WebSocket 持久连接，通过连接级状态缓存消除重复 API 开销，使 Agent 循环端到端延迟降低 40%，支撑 GPT-5.3-Codex-Spark 达到 1000 TPS 的推理速度。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Responses API 从每次请求独立处理改为 WebSocket 持久连接 + 连接级状态缓存，消除 Agent 多轮循环中的重复 API 开销
- **現在值得用嗎**：是 — 如果你的应用使用 Responses API 做多轮 Agent 循环，切换 WebSocket 模式即可获得延迟改善，无需修改输入输出格式
- **適合場景**：Codex 类 coding agent 多轮 tool-call 循环、多文件编辑工作流、长对话上下文的多轮交互
- **不適合場景**：单次请求/单次响应的简单补全场景（收益有限）；需要跨会话共享状态的场景（缓存是连接 scoped 的）
- **與之前版本核心差異**：之前每次 follow-up 请求都重建完整对话上下文；现在通过 WebSocket 连接缓存 previous response state，只处理增量变更

## 是什么 / 解决什么问题

### 背景痛点：推理变快了，但 API 开销成了瓶颈

2025 年 11 月之前，Responses API 的旗舰模型（GPT-5、GPT-5.2）推理速度约 65 tokens/秒（TPS）。此时 GPU 推理是整个 Agent 循环中最慢的环节，API 服务开销被掩盖在推理时间之下，不太显眼。

但随着 GPT-5.3-Codex-Spark 的发布（基于 Cerebras 专用硬件，目标 1000+ TPS），GPU 推理不再是瓶颈。**API 服务开销相对模型速度变得不可忽视**——用户需要等待运行 API 的 CPU 处理完请求，才能轮到 GPU 生成 token。

### 结构性问题：每次请求都被当作独立请求处理

更深层的问题在于架构设计：Responses API 将每次 Codex 请求视为独立事件。即使对话历史大部分没有变化，每次 follow-up 请求都要：
- 重新处理完整对话历史
- 重新做 tokenization
- 重新跑 safety classifiers
- 重新建立 HTTP 连接

随着对话变长，这些重复处理变得越来越昂贵。

### 解决方案：WebSocket 持久连接 + 连接级状态缓存

OpenAI 将 transport 协议从 HTTP 请求-响应改为 WebSocket 持久连接。在连接生命周期内，服务器维护一个**连接 scoped 的内存缓存**，存储 previous response state。后续请求通过 `previous_response_id` 引用缓存状态，只发送需要验证和处理的增量信息。

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| Transport 协议 | WebSocket（而非 gRPC bidirectional streaming） | 简单消息传输，用户无需修改 Responses API 的 input/output 格式，developer-friendly |
| API 交互模式 | 保持 `response.create` + `previous_response_id`（而非 prototype 中的 `response.append`） | 开发者已有集成无需重写，降低迁移成本 |
| 缓存粒度 | 连接 scoped（connection-scoped） | 简化一致性管理，连接断开即自动清理 |
| 缓存内容 | previous response object + input/output items + tool definitions + rendered tokens | 覆盖多轮请求中最重复的计算环节 |

### 设计演进：从 prototype 到 production

OpenAI 经历了两个设计阶段：

**Prototype 阶段**（更高效但 API 不友好）：
- Agent rollout 建模为单个长响应
- 模型采样到 tool call 后，API 异步阻塞，发送 `response.done` 给客户端
- 客户端执行 tool 后发送 `response.append` 带 tool result，恢复采样循环
- 优点：消除所有重复 API 工作（pre-inference 做一次，post-inference 做一次）
- 缺点：API 交互模式完全改变，开发者需要重写集成

**Production 阶段**（平衡效率与兼容性）：
- 保持 `response.create` + `previous_response_id` 的熟悉模式
- WebSocket 连接上服务器维护连接级内存缓存
- 后续请求引用缓存状态而非重建完整对话
- 优点：开发者无需修改集成代码
- 缺点：比 prototype 多一点点开销，但远优于每次独立请求

### 架构信息流

```
┌─────────────────────────────────────────────────────────────┐
│                      Client (Agent)                         │
│  Codex / Cline / Vercel AI SDK / Cursor                     │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
    WebSocket Persistent Connection (持久连接)
    ┌──────────┴──────────────────────────────┴───────────┐
    │                                                     │
    │  ┌─────────────┐    ┌──────────────────────────┐   │
    │  │  Request    │    │  Connection-Scoped Cache  │   │
    │  │  Validator  │───▶│  - Previous response obj  │   │
    │  │  & Safety   │    │  - Input/Output items     │   │
    │  │  Stack      │    │  - Tool definitions       │   │
    │  └──────┬──────┘    │  - Rendered tokens        │   │
    │         │           │  - Model routing state    │   │
    │         ▼           └──────────┬────────────────┘   │
    │  ┌─────────────┐              │                    │
    │  │  Tokenizer  │─────────────▶│ (skip if cached)   │
    │  │  (incremental)              │                    │
    │  └──────┬──────┘              │                    │
    │         │                     ▼                    │
    │  ┌─────────────┐    ┌──────────────────┐          │
    │  │  Model      │    │  Inference       │          │
    │  │  Resolver   │───▶│  (Cerebras GPU)  │          │
    │  │  (cached)   │    └──────────────────┘          │
    │  └──────┬──────┘                                  │
    │         │                                         │
    │         ▼                                         │
    │  ┌─────────────┐    ┌──────────────────┐          │
    │  │  Post-      │    │  Billing (overlapped│        │
    │  │  inference  │───▶│  w/ next request) │         │
    │  └─────────────┘    └──────────────────┘          │
    └─────────────────────────────────────────────────────┘
```

### 与前版的关键差异

| 维度 | 之前（HTTP 独立请求） | 现在（WebSocket 持久连接） |
|------|----------------------|--------------------------|
| 连接方式 | 每次请求新建 HTTP 连接 | 单一 WebSocket 连接持久保持 |
| 对话状态 | 每次重建完整上下文 | 缓存 previous response state，增量处理 |
| Tokenization | 每次对完整历史做 | 缓存 rendered tokens，仅增量 append |
| Safety 检查 | 每次跑完整历史 | 仅检查新输入 |
| Model routing | 每次重新解析 | 缓存成功的路由结果 |
| TTFT 改善 | ~45%（单请求优化） | 端到端 Agent 循环 ~40% |
| 推理速度上限 | ~65 TPS（GPT-5/5.2） | ~1000 TPS 峰值 4000 TPS（GPT-5.3-Codex-Spark） |
| API 兼容性 | — | 完全兼容，input/output 格式不变 |

## 实用评估

### 什么场景值得用

- **Coding Agent 多轮循环**：Codex、Cline 类工具需要数十轮 tool-call → 执行 → 反馈循环，WebSocket 模式直接命中痛点。Cline 多文件工作流实测快 39%
- **长对话 Agent**：对话历史越长，重复处理的开销越大，WebSocket 缓存的收益越显著
- **高并发 Agent 部署**：减少每个请求的 CPU 开销意味着同等硬件可以服务更多并发连接
- **实时交互场景**：TTFT 降低对用户体验有直接感知影响的产品

### 什么场景不值得用

- **单次请求补全**：如果应用只是发一次请求拿一次响应，没有多轮循环，WebSocket 模式几乎没有额外收益
- **跨会话状态共享**：缓存是连接 scoped 的，连接断开即失效。如果需要跨连接共享状态，需要自行实现持久化层
- **非 Responses API 用户**：此优化仅适用于 Responses API，Completion API 用户不受影响
- **网络不稳定环境**：WebSocket 连接断开后需要重建，在移动网络等不稳定环境下可能频繁重连

### 迁移成本

**极低**。OpenAI 刻意保持了 API 兼容性：
- 输入输出格式完全不变
- 继续使用 `response.create` + `previous_response_id`
- 开发者只需在客户端 SDK 层面切换到 WebSocket transport
- Vercel AI SDK 已集成支持，Cursor 已适配

根据 alpha 用户反馈，集成工作量主要在 transport 层切换，业务逻辑无需改动。

## 对你的意义

如果你在用 Responses API 构建 Agent 应用（特别是 coding agent 或多轮 tool-use 场景），这个更新值得立即关注：

1. **延迟改善是实打实的**：40% 端到端加速不是 benchmark 数字，而是 Codex、Cline、Cursor 等真实产品的生产环境数据
2. **迁移成本极低**：API 形状不变，只需切换 transport 层
3. **信号意义**：当推理速度从 65 TPS 跳到 1000 TPS，"围绕推理的服务层"也必须跟上。这是一个行业趋势信号——**Agent 基础设施的竞争焦点正在从模型本身扩展到 API 层、传输层、缓存层**

建议：如果你的 Agent 工作流对延迟敏感，尽快评估切换到 WebSocket 模式。

## 关键数据引用

以下是源材料中引用的具体数据：

- **端到端延迟改善**：Agent 循环快 40%（OpenAI 官方数据）
- **TTFT 改善**：单请求优化阶段 ~45%（2025 年 11 月 sprint 成果）
- **推理速度**：GPT-5.3-Codex-Spark 达到 1000 TPS，峰值 4000 TPS
- **Vercel AI SDK**：延迟降低 up to 40%（来源：[@aisdk on X](https://x.com/aisdk/status/2026031263925039591)）
- **Cline**：多文件工作流快 39%（来源：[@cline on X](https://x.com/cline/status/2026031848791630033)）
- **Cursor**：OpenAI 模型推理快 up to 30%（来源：[@leerob on X](https://x.com/leerob/status/2026030244407468259)）
- **开发周期**：从 idea 到 production 仅数周（2025 年 11 月 sprint → 2026 年初 alpha → 正式发布）

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | WebSocket 模式专门优化 Agent 循环延迟，OpenAI 投入工程资源解决 Agent 工作流的性能瓶颈，说明 Agent 自动化场景的重要性已被基础设施层验证 |

---
[← Back to Deep Dives](./README.md)
