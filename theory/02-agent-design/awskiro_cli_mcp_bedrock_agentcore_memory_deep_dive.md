---
auto_generated: true
generated_at: "2026-05-21T03:34:28Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/extending-conversational-memory-in-kiro-cli-using-amazon-bedrock-agentcore-memory/"
signal_type: "blog_post"
---
# Kiro CLI 通过 MCP 集成 Bedrock AgentCore Memory 实现跨会话记忆 (Extending Conversational Memory in Kiro CLI via MCP + Bedrock AgentCore Memory)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-21
>
> **项目/工具**: Kiro CLI + Amazon Bedrock AgentCore Memory + 自定义 MCP Server
> **链接**: https://aws.amazon.com/blogs/machine-learning/extending-conversational-memory-in-kiro-cli-using-amazon-bedrock-agentcore-memory/
> **源码**: https://github.com/aws-samples/sample-amazon-bedrock-agentcore-memory-mcp-server
> **核心定位**: 通过自定义 MCP Server 将 Bedrock AgentCore Memory 接入 Kiro CLI，实现跨会话的对话历史持久化、语义搜索和记忆管理，解决 Agentic IDE 每次新会话丢失上下文的核心痛点。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 这是 AWS 官方提供的一个 MCP Server 实现，让 Kiro CLI（AWS 的 AI 编程 IDE 终端版）拥有跨会话持久记忆能力——记住你上周讨论过的架构决策、项目偏好、技术选型。
- **现在值得用吗**: 是——如果你已经在使用 Kiro CLI 且拥有 AWS 账号。对非 Kiro 用户的通用 MCP 客户端也有参考价值，但需要适配。
- **适合场景**: 长期项目中的 AI 辅助编程（需要反复引用历史决策）、团队协作场景（项目级记忆隔离）、需要跨多天/多周保持上下文连贯性的开发工作流。
- **不适合场景**: 一次性代码片段查询、不需要跨会话记忆的场景（增加复杂度无收益）、非 AWS 生态用户（依赖 Bedrock AgentCore Memory 托管服务）。
- **与 Cursor/Continue 等竞品核心差异**: Cursor 的记忆限于当前 session 内上下文窗口；Kiro+AgentCore 方案将记忆外置到托管向量数据库，支持语义搜索和长期持久化，突破 session 边界。

## 是什么 / 解决什么问题

Agentic IDE 的核心痛点之一是**健忘**。你在一个大型代码库上工作了数天甚至数周，讨论过架构决策、技术选型、项目偏好，但每次打开新 session，IDE 从零开始——你不得不重复提供相同的上下文信息。这不仅影响效率，更导致 AI 助手的输出质量因上下文缺失而大幅下降。

AWS 的解决方案由三个组件构成：

1. **Kiro CLI** — AWS 的 AI 编程终端工具（类似 Cursor 的终端版），通过 AI Agent 辅助编码。
2. **Amazon Bedrock AgentCore Memory** — AWS 的托管记忆服务，提供短期工作记忆和长期语义记忆的存储与检索。
3. **自定义 MCP Server** — 开源的 Model Context Protocol 服务端，作为 Kiro CLI 与 AgentCore Memory 之间的桥梁。

这个方案的核心创新不在于单个组件，而在于**用 MCP 协议将记忆能力标准化为可插拔工具**——任何支持 MCP 的客户端（不只是 Kiro CLI）都可以接入 AgentCore Memory，实现跨会话记忆。

## 技术架构拆解

### 核心设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 协议层 | MCP (Model Context Protocol) | 标准化、跨客户端兼容；任何 MCP 客户端都能复用 |
| 传输层 | STDIO | 与 Kiro CLI 本地进程通信，低延迟、无网络开销 |
| 记忆存储 | Bedrock AgentCore Memory（托管） | 免运维、内置语义搜索、自动向量化 |
| 检索策略 | 两阶段级联检索 | 语义搜索优先 + 事件级全文回退，确保可靠性 |
| 身份隔离 | User ID / Project ID 双模式 | 个人用 User ID，团队用 Project ID，灵活隔离 |
| 自动触发 | Kiro Hooks（shell 脚本） | 每次对话结束后自动存储，无需手动干预 |

### 两阶段检索策略（核心创新）

这是该方案最值得关注的设计。检索不是单一策略，而是**级联回退**：

```
Stage 1: 语义搜索（Semantic Search）
  ├─ 调用 Bedrock AgentCore Memory API: retrieve_memory_records
  ├─ 基于向量嵌入的语义匹配
  ├─ 优点: 概念级匹配，"Lambda" 能匹配到 "无服务器函数"
  └─ 缺点: 语义策略处理有延迟，新存储的对话可能尚未向量化
         ↓ (Stage 1 无结果或结果不足)
Stage 2: 事件级全文匹配（Direct Event Matching）
  ├─ 直接扫描 AgentCore Memory session 中存储的原始对话载荷
  ├─ 子串匹配 + 多词独立匹配（不要求顺序）
  ├─ 优点: 存储立即可检索，零延迟
  └─ 缺点: 精确匹配，缺乏语义泛化能力
```

这种设计保证了**无论语义策略是否已完成处理，对话都能被检索到**。这是一个典型的工程权衡——用两层策略覆盖彼此的盲区。

### 架构信息流图

```
┌──────────────┐     STDIO      ┌──────────────────────────┐
│  Kiro CLI    │◄──────────────►│  Custom MCP Server        │
│  (终端 IDE)  │  MCP Protocol  │  (Python)                 │
│              │                │                           │
│  Hooks:      │                │  Tools (9个):             │
│  - store_    │                │  - search_conversation_   │
│    convers-  │                │    history                │
│    ation.sh  │                │  - search_memories        │
│  - load_     │                │  - store_conversation     │
│    preferen- │                │  - get_direct_convers-    │
│    ces.sh    │                │    ation_history          │
│  - cache_    │                │  - list_sessions          │
│    prompt.sh │                │  - get_memory_stats       │
└──────────────┘                │  - delete_session         │
                                │  - clear_all_data         │
                                │  - get_server_config      │
                                └───────────┬───────────────┘
                                            │
                                AWS SDK / API
                                            │
                                ┌───────────▼───────────────┐
                                │  Bedrock AgentCore Memory │
                                │  (托管记忆服务)            │
                                │                           │
                                │  ├─ 短期工作记忆           │
                                │  ├─ 长期语义记忆           │
                                │  ├─ 向量索引              │
                                │  └─ 事件存储              │
                                └──────────────────────────┘
```

### 与前版/竞品的关键差异

| 维度 | Cursor / Copilot（原生记忆） | Kiro + AgentCore Memory |
|------|---------------------------|------------------------|
| 记忆范围 | 当前 session 内上下文窗口 | 跨 session 持久化 |
| 存储位置 | 本地/云端临时缓存 | AWS 托管向量数据库 |
| 检索方式 | 上下文窗口内的注意力机制 | 语义搜索 + 全文回退 |
| 记忆容量 | 受限于模型上下文窗口 | 理论上无限（托管服务） |
| 协议标准化 | 闭源，厂商锁定 | MCP 开放协议，可移植 |
| 身份隔离 | 无 | User ID / Project ID 双模式 |
| 自动触发 | 内置 | 通过 Hooks 脚本实现 |
| 部署复杂度 | 零 | 需配置 AWS 凭证 + 运行 MCP Server |

## 实用评估

### 什么场景值得用

- **长期项目中的 AI 辅助编程**: 如果你在同一个代码库上工作数周，AI 记住你之前的架构决策和技术选型，能显著减少重复解释的成本。
- **团队协作场景**: Project ID 模式让团队成员共享同一份记忆空间——新成员加入时 AI 可以直接引用项目历史讨论。
- **复杂技术栈的持续探索**: 当你的项目涉及多个 AWS 服务（如 Lambda + EMR + Bedrock），AI 能记住每个服务的配置和集成细节。
- **MCP 生态的参考实现**: 即使你不用 Kiro CLI，这个 MCP Server 也是将 AgentCore Memory 接入任何 MCP 客户端的参考模板。

### 什么场景不值得用

- **一次性代码查询**: 如果只是让 AI 帮忙写一个函数或 debug 一个 snippet，跨会话记忆是过度工程。
- **非 AWS 生态用户**: 依赖 Bedrock AgentCore Memory 托管服务，需要 AWS 账号和 IAM 权限。非 AWS 用户迁移成本高。
- **对数据主权敏感的场景**: 对话历史上传到 AWS 托管服务，需评估合规性（GDPR、数据驻留等）。
- **Kiro CLI 以外的 IDE**: 目前方案紧密绑定 Kiro CLI 的 Hooks 机制。虽然 MCP 协议本身通用，但自动存储触发器是 Kiro 特有的。

### 迁移成本

从原生 Kiro CLI（无记忆）迁移到 AgentCore Memory 增强版：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 安装 Python 依赖 | ~5 分钟 | `pip install -r requirements.txt` |
| 运行 setup 脚本 | ~5 分钟 | 自动创建 AgentCore Memory 资源 |
| 配置 Hooks | ~5 分钟 | 复制 4 个 shell 脚本到 `~/.kiro/hooks/` |
| 配置默认 Agent | ~1 分钟 | 在 `cli.json` 添加一行配置 |
| 验证登录 | ~5 分钟 | AWS Builder ID 或组织订阅 |
| **总计** | **~20 分钟** | 一次性配置，之后自动运行 |

如果要从零开始安装 Kiro CLI，额外增加 10-15 分钟。

## 对你的意义

这个方案对 AI Agent 开发有两个值得关注的信号：

**1. MCP 作为记忆标准化的载体正在落地**

MCP 协议最初被定位为"工具调用协议"，但这个实现展示了 MCP 更广泛的潜力——**任何 Agent 能力（记忆、文件操作、搜索）都可以通过 MCP 标准化为可插拔工具**。这意味着未来你可能用一个通用的"记忆 MCP Server"服务多个不同的 Agent 框架，而不是每个框架自建记忆系统。

**2. 两阶段检索是工程模式的参考**

语义搜索 + 全文回退的级联策略是一个通用的检索模式。如果你在构建自己的 Agent 记忆系统，这个模式值得借鉴——不要依赖单一检索策略，用回退层覆盖盲区。

**建议**: 如果你在使用 Kiro CLI，立即配置。如果你在用其他 MCP 客户端，把这个 MCP Server 作为参考实现，评估能否适配到你的工具链。

## 关键代码/配置片段

### MCP Server 配置（kiro_memory.json）

```json
{
  "mcpServers": {
    "agentcore-memory-mcp-server": {
      "command": "/path/to/venv/bin/python",
      "args": ["/path/to/bedrock_agentcore_memory_mcp_server.py"],
      "env": {
        "AWS_REGION": "us-east-1",
        "AGENTCORE_MEMORY_ID": "your-memory-id",
        "ACTOR_ID_TYPE": "userid",
        "PROJECT_ID": "",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

### 命名空间策略

```
/strategy/semanticMemoryStrategy/actor/{actorId}/session/{sessionId}
```

其中 `actorId` 可以是系统用户名（User ID 模式）或自定义项目标识（Project ID 模式），`sessionId` 按小时自动生成，确保同一小时内的对话归入同一会话。

### Hooks 自动存储机制

```bash
# ~/.kiro/hooks/store-conversation.sh
# 每次对话结束后由 Kiro CLI 自动触发
# 调用 MCP Server 的 store_conversation 工具
# 将完整对话内容写入 AgentCore Memory
```

### 可用工具列表（9 个 MCP Tools）

| 工具 | 类别 | 功能 |
|------|------|------|
| `search_conversation_history` | 核心 | 按主题/时间搜索对话历史（事件级匹配） |
| `search_memories` | 核心 | 语义搜索长期记忆（向量匹配） |
| `store_conversation` | 核心 | 存储对话（触发语义策略） |
| `get_direct_conversation_history` | 核心 | 获取指定 session 的完整对话 |
| `list_sessions` | 核心 | 列出已存储的所有 session |
| `get_memory_stats` | 监控 | 记忆使用统计（sessions/events/memories 数量） |
| `get_server_config` | 诊断 | 获取 MCP Server 完整配置 |
| `delete_session` | 管理 | 删除指定 session（不可逆） |
| `clear_all_data` | 管理 | 清空所有数据（需 confirm=True） |

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 支持 | AWS 官方选择 MCP 作为记忆能力的标准化接口，而非私有协议——这是 MCP 生态地位的重要背书 |

---
[← Back to Deep Dives](./README.md)
