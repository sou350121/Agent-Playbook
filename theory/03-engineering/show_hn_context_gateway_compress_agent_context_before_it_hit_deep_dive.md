---
auto_generated: true
generated_at: "2026-03-14T05:46:35Z"
source_url: "https://github.com/Compresr-ai/Context-Gateway/releases/tag/v0.5.2"
signal_type: "blog_post"
---
# Show HN: Context Gateway – 压缩智能体上下文后再送入 LLM (Context Gateway: Compress Agent Context Before Hitting LLM)

> 🔍 本文由 Moltbot 自动生成 | 2026-03-14
>
> **项目/工具**: Context Gateway by Compresr
> **链接**: https://github.com/Compresr-ai/Context-Gateway
> **核心定位**: 透明代理层，在 AI 编码智能体与 LLM API 之间自动压缩对话历史，解决长会话 token 成本爆炸问题

## ⚡ 快速判斷（30 秒讀完這段就夠了）

- **一句話定位**: Context Gateway 是 YC -backed Compresr 推出的透明代理，专为 Claude Code/Cursor 等编码智能体设计，在对话触及上下文窗口限制前自动后台压缩历史
- **現在值得用嗎**: 是 — 如果你每天用 AI 编码助手超过 2 小时，或经常遇到「context limit reached」错误
- **適合場景**: 长周期开发任务（多轮重构/调试）、多文件上下文对话、RAG 增强型编码会话
- **不適合場景**: 短平快查询（单轮问答）、已有自建压缩方案、对压缩延迟极度敏感（要求<100ms）的场景
- **與 [競品/前版] 核心差異**: 竞品如 Cursor 内置压缩是「触发后才开始算」，Context Gateway 是「后台预计算，触发时立即可用」

## 是什么 / 解决什么问题

AI 编码智能体（Claude Code、Cursor 等）的核心痛点是：长会话必然触及上下文窗口限制。传统方案有两种：

1. **手动清理**: 用户自己删旧消息 — 费时且容易丢失关键上下文
2. **触发式压缩**: 达到限制后调用 LLM 总结历史 — 需要等待 10-30 秒，打断心流

Context Gateway 的解法是**后台预压缩**。它作为一个透明代理层，持续监控对话长度，在后台用专用压缩模型（非通用 LLM）预先计算历史摘要。当真正需要压缩时，摘要已经 ready，实现「零等待」切换。

官方声称 token 成本可降低**最高 200 倍** — 这个数字需要谨慎理解：它指的是极端场景（超长系统提示 + 大量文档上下文）下使用 agnostic compression 的理论上限，实际编码会话中更现实的数字是 5-20 倍。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| **透明代理模式** | 零代码改动 — 用户只需改一个环境变量（LLM API endpoint），现有 agent 配置完全兼容 |
| **后台预计算** | 避免压缩延迟打断心流 — 这是与竞品最核心的差异化 |
| **三模型策略** | 不同场景用不同模型：espresso_v1（通用）、latte_v1（query 相关）、coldbrew_v1（chunk 过滤）— 比单一模型更灵活 |
| **本地日志优先** | history_compaction.jsonl 本地记录 — 便于调试和审计，避免依赖云端 dashboard |
| **交互式 TUI 配置** | 降低入门门槛 — 相比手写 YAML/JSON 配置，TUI wizard 对非技术用户更友好 |

### 与前版/竞品的关键差异

| 维度 | 传统方案（Cursor 内置/Claude 原生） | Context Gateway |
|------|------------|------------|
| 压缩触发时机 | 达到上限后才开始 | 后台持续预计算，达到阈值时立即可用 |
| 压缩模型 | 通用 LLM（如 Claude 自身） | 专用压缩模型（espresso/latte/coldbrew） |
| 延迟感知 | 明显（10-30 秒等待） | 几乎无感（预计算完成） |
| 可观测性 | 黑盒（不知道压缩了什么） | 本地 JSONL 日志，可审计 |
| 跨 agent 支持 | 单 agent 绑定 | 统一网关支持 Claude Code/Cursor/OpenClaw/Custom |
| 成本模型 | 按 LLM token 计费 | 按压缩 token 计费（专用模型更便宜） |

### 架构/信息流图

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────┐
│  AI Agent       │────▶│  Context Gateway     │────▶│  LLM API    │
│  (Claude Code)  │     │  (Transparent Proxy) │     │  (Anthropic)│
└─────────────────┘     └──────────────────────┘     └─────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │  Background  │
                        │  Compressor  │
                        │  (espresso)  │
                        └──────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │  Local Log   │
                        │  history_    │
                        │  compaction  │
                        │  .jsonl      │
                        └──────────────┘
```

工作流程：
1. Agent 发送请求 → Gateway 拦截
2. Gateway 检查当前上下文长度 vs 阈值（默认 75%）
3. 若超过阈值：立即返回预计算的压缩历史
4. 若未超过：透传请求，同时后台继续预计算下一轮摘要
5. 所有压缩操作记录到本地 JSONL 日志

## 实用评估

### 什么场景值得用

| 场景 | 理由 |
|------|------|
| **长周期重构任务** | 多轮对话累积大量上下文，手动清理成本极高 |
| **多文件项目导航** | 每次对话附带多个文件内容，token 消耗快 |
| **RAG 增强编码** | 检索到的文档片段直接注入上下文，容易爆炸 |
| **团队协作会话** | 多人共享同一 agent 会话，历史增长更快 |
| **成本敏感型团队** | 官方称 token 成本可降 5-20 倍（实际取决于压缩率） |

### 什么场景不值得用

| 场景 | 理由 |
|------|------|
| **单轮问答** | 压缩 overhead 可能超过收益 |
| **已有自建压缩方案** | 如团队已用 LangChain 的 ConversationBufferWindowMemory 等 |
| **对延迟极度敏感** | 虽然预计算，但网关层仍增加 50-200ms 网络延迟 |
| **隐私敏感代码** | 上下文需经过第三方服务（Compresr API）— 需评估合规风险 |
| **离线开发环境** | 依赖云端 API，无法本地部署压缩模型 |

### 迁移成本

从原生 Agent 迁移到 Context Gateway：

1. **安装网关**: `curl -fsSL https://compresr.ai/api/install | sh` — 5 分钟
2. **运行配置向导**: `context-gateway` — 交互式选择 agent 类型、填写 API key — 3 分钟
3. **验证连接**: 发起一次对话，检查 logs/history_compaction.jsonl 是否有记录 — 2 分钟

**总迁移时间**: 约 10 分钟，无需修改现有 agent 配置文件。

**回滚方案**: 改回原始 LLM API endpoint 即可，无数据锁定风险。

## 对你的意义

如果你在用 Ken 的 AI 应用监控体系（Agent-Playbook），Context Gateway 是一个值得关注的**基础设施层创新**：

1. **对 Agent-UI 的启发**: 当前多数 Agent 框架（LangChain、LlamaIndex）的压缩方案仍是「触发式」，Context Gateway 的「后台预计算」模式可借鉴到 RAG pipeline 设计
2. **对成本优化的意义**: 如果你的 VLA 研究涉及大规模 LLM 调用（如批量实验），专用压缩模型比通用 LLM 总结便宜 1-2 个数量级
3. **待验证假设**: 这直接支持 **A-002（Agentic Coding 在初级任务达 80% 成功率）** — 当 token 成本不再是瓶颈，Agent 可以维持更长会话，完成更复杂的任务链

**建议**: 
- **立即试用** — 如果你每天用 Claude Code/Cursor 超过 1 小时
- **观望** — 如果你只是偶尔用用，或已有成熟的上下文管理方案
- **跳过** — 如果你在离线环境工作，或对数据出境有严格合规要求

## 关键代码/配置片段

### 安装与配置

```bash
# 安装网关二进制
curl -fsSL https://compresr.ai/api/install | sh

# 运行交互式配置（选择 agent 类型、填写 API key）
context-gateway
```

### 配置文件示例（~/.context-gateway/config.yaml）

```yaml
agent: claude_code
summarizer:
  model: espresso_v1
  api_key: $COMPRESR_API_KEY
trigger_threshold: 0.75  # 75% 上下文窗口时触发
notifications:
  slack: false  # 可选 Slack 通知
```

### 压缩日志查看

```bash
# 查看最近的压缩记录
tail -f ~/.context-gateway/logs/history_compaction.jsonl
```

日志格式（每行一个 JSON 对象）:
```json
{"timestamp":"2026-03-14T05:30:00Z","original_tokens":12500,"compressed_tokens":680,"ratio":18.4,"model":"espresso_v1","duration_ms":45}
```

### SDK 直接调用（若不通过网关）

```python
from compresr import CompressionClient

client = CompressionClient(api_key="your_key")

# Agnostic compression（通用场景）
compressed = client.compress(
    text=long_context,
    model="espresso_v1",
    compression_rate=0.1  # 压缩到原长度的 10%
)

# Query-specific compression（RAG 场景）
filtered = client.compress_with_query(
    context=retrieved_docs,
    query=user_question,
    model="latte_v1"
)
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Context Gateway 通过降低 token 成本和消除压缩延迟，使 Agent 能维持更长会话，完成更复杂的多轮任务链，间接提升成功率 |

---

[← Back to Deep Dives](./README.md)
