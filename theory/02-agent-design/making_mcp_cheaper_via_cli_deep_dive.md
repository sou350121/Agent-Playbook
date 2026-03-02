---
auto_generated: true
generated_at: "2026-02-26T01:45:50Z"
source_url: "https://kanyilmaz.me/2026/02/23/cli-vs-mcp.html"
signal_type: "blog_post"
---
# 让 MCP 便宜 94%：用 CLI 替代完整 Schema 注入 (I Made MCP 94% Cheaper via CLI)

> 🔍 本文由 Moltbot 自动生成 | 2026-02-26
>
> **项目/工具**: CLIHub + MCP (Model Context Protocol)
> **链接**: https://kanyilmaz.me/2026/02/23/cli-vs-mcp.html
> **核心定位**: 通过懒加载工具定义而非全量注入 JSON Schema，将 MCP Agent 的 token 开销降低 94%

## 一句话摘要

**MCP 的 token 税不在 API 调用本身，而在「说明书」**——将 84 个工具的完整 JSON Schema 全量注入会话（15,540 tokens）改为轻量级 CLI 技能列表（300 tokens），可实现 94% 的 token 节省，且适用于任何模型。

## 是什么 / 解决什么问题

MCP (Model Context Protocol) 是当前 AI Agent 连接外部工具的标准协议。但几乎所有 MCP 实现都有一个隐性成本：**在会话开始时，必须将所有可用工具的完整 JSON Schema 注入上下文**。

典型场景：6 个 MCP 服务器，每个 14 个工具，共 84 个工具。每个工具的 schema 约 185 tokens，总计 **15,540 tokens** 在 agent 做任何有用工作之前就被消耗了。

这篇文章的作者 Kan Yilmaz 提出了一个反直觉的方案：**用 CLI 包装 MCP 工具**。核心洞察是：
- MCP 的「全量注入」假设 agent 需要预先知道所有工具的完整签名
- 但实际上 agent 可以像人类开发者一样，先用 `--help` 发现可用命令，再按需查询详情
- CLI 的懒加载模式将 session start 开销从 15,540 tokens 降至 300 tokens（98% 节省）

这个问题对重度使用 MCP 的开发者影响巨大：假设每天运行 100 次 agent 会话，每次 15K tokens 的固定开销相当于 **每天 1.5M tokens 的「税」**，一个月就是 45M tokens——这还不包括实际工具调用的消耗。

## 理论好用，实践陷阱

### ✅ 理论优势

| 优势 | 说明 |
|------|------|
| **Token 效率** | 94% 节省，重度用户月省 45M+ tokens |
| **模型无关** | 不依赖 function calling，任何文本模型都能用 |
| **人类工作流映射** | CLI 发现模式与开发者习惯一致 |
| **离线友好** | CLI 可本地运行，无需远程 MCP 服务器 |
| **调试简单** | Shell 命令可直接在终端测试 |

### ⚠️ 实践陷阱

| 陷阱 | 表现 | 规避方法 |
|------|------|----------|
| **首次调用延迟** | `--help` 查询增加首调用延迟 (~600 tokens) | 预热常用工具的 help 输出到缓存 |
| **类型验证缺失** | CLI 参数是字符串，无 schema 验证 | 在 CLI 包装层添加参数校验 |
| **错误解析复杂** | stderr 输出格式不统一，agent 难解析 | 标准化 CLI 错误输出格式（JSON 模式） |
| **工具发现失败** | agent 忘记 `--help` 直接调用 | 提示词中明确「未知命令先查 help」 |
| **并发冲突** | 多个 agent 会话同时调用同一 CLI | 用文件锁或队列序列化 CLI 调用 |
| **环境依赖** | CLI 需要安装到 PATH，部署复杂度增加 | 用容器/venv 封装 CLI 环境 |

### ❌ 错误使用示例

```
❌ 错误：Agent 跳过 --help 直接调用
$ notion search-my-query  # 错误：命令不存在

✅ 正确：先发现后执行
$ notion --help
$ notion search "my query"
```

```
❌ 错误：CLI 输出非结构化错误
Error: couldn't connect to notion, pls check ur token lol

✅ 正确：结构化错误输出
{
  "error": "authentication_failed",
  "message": "Invalid Notion API token",
  "suggestion": "Check NOTION_TOKEN environment variable"
}
```

```
❌ 错误：100 个工具仍用懒加载
# 每次调用都 --help，累积开销超过预加载

✅ 正确：高频工具预加载，低频工具懒加载
# 80% 调用集中在 20% 工具，这些工具预加载 schema
```

## MCP 与 Claude Code 的盲区

### MCP 固有局限

| 盲区 | 表现 | CLI 方案的补救 |
|------|------|---------------|
| **Schema 膨胀** | 工具多时 token 开销线性增长 | 懒加载，只加载需要的 |
| **模型锁定** | Tool Search 仅限 Anthropic | CLI 通用，任何模型可用 |
| **热更新困难** | 工具变更需重新注入 schema | CLI 独立更新，不影响会话 |
| **类型过度约束** | 严格 schema 限制灵活调用 | CLI 参数更宽松，agent 自适应 |

### Claude Code 使用 MCP 时的典型问题

```
❌ 错误场景：Claude 在未查 help 的情况下猜测参数
$ notion search --query "test" --type page  # --type 参数不存在

✅ 补救：提示词中强制「未知命令先 --help」
Before calling any CLI tool, always run <tool> --help first to discover 
available subcommands and their exact parameter names.
```

```
❌ 错误场景：Claude 忽略 CLI 错误输出继续执行
$ notion create-page "test"  # 返回认证错误
Claude: "Page created successfully"  # 幻觉

✅ 补救：要求检查 exit code 和 stderr
After running any CLI command, check the exit code. If non-zero or 
stderr is non-empty, report the error and do not hallucinate success.
```

```
❌ 错误场景：并发会话同时写入同一文件
Session A: $ notion add "task 1"
Session B: $ notion add "task 2"
Result: Race condition, one task lost

✅ 补救：CLI 包装层添加文件锁或队列
# 使用 flock 或 redis 队列序列化写操作
```

## 并发与安全考量

### 并发场景的处理

| 场景 | 风险 | 应对 |
|------|------|------|
| **多会话并发** | 多个 agent 同时调用 CLI 导致资源竞争 | 用 flock 或 redis 锁序列化 |
| **CLI 状态共享** | CLI 缓存/配置文件被并发修改 | 每会话独立 temp dir |
| **API 限流** | 并发调用触发第三方 API 限流 | CLI 层添加速率限制 |
| **输出解析冲突** | 并发解析同一 CLI 输出 | 每会话独立解析管道 |

### 安全边界

**不应通过 CLI 暴露的内容**：
- API 密钥硬编码在 CLI 脚本中
- 数据库直连凭证
- 内部服务地址（应通过反向代理）

**建议的安全实践**：
- CLI 从环境变量读取敏感配置（`NOTION_TOKEN` 而非硬编码）
- CLI 命令添加审计日志（记录谁在何时调用了什么）
- 限制 CLI 可访问的文件系统路径（chroot 或容器隔离）
- CLI 输出过滤敏感信息（自动脱敏 token/密钥）

### 长会话的并发安全实践

```
✅ 推荐：每会话独立工作目录
session_1/
  .cli_cache/
  notion_state.json
session_2/
  .cli_cache/
  notion_state.json
```

```
✅ 推荐：CLI 调用加锁
flock -x /tmp/notion.lock notion search "query"
```

```
❌ 避免：全局状态共享
~/.notion_cache/  # 多会话并发读写会冲突
```

## 技术架构拆解

### 架构本质

这套方案的核心架构转变是**从「预加载全部知识」到「按需发现」**。

传统 MCP 架构：
```
会话启动 → 注入所有工具 schema (15,540 tokens) → Agent 选择工具 → 调用工具 (30 tokens)
```

CLI 包装架构：
```
会话启动 → 注入轻量技能列表 (300 tokens) → Agent 发现需求 → --help 查询详情 (~600 tokens) → 执行命令 (6 tokens)
```

关键设计哲学：
- **懒加载优于预加载**：除非确定会用到，否则不加载完整定义
- **发现与执行分离**：第一步发现「有什么」，第二步查询「怎么用」，第三步执行
- **人类工作流映射**：开发者也是先 `ls` 看有什么，再 `man` 查用法，最后执行命令

### 核心设计决策

| 决策 | MCP 方案 | CLI 方案 | 理由 |
|------|---------|---------|------|
| **Session Start** | 注入全部 84 个工具的完整 JSON Schema | 注入 6 个 CLI 的名称/描述/路径 | 98% token 节省，agent 按需发现 |
| **工具发现** | 无需额外步骤（已全量加载） | `cli --help` 返回所有子命令详情 | 按需付费，只用一次 |
| **工具调用** | JSON-RPC 风格，参数内联 | Shell 命令风格，参数扁平 | CLI 调用更简洁（6 tokens vs 30 tokens） |
| **错误处理** | MCP 服务器返回结构化错误 | CLI 返回 stdout/stderr | CLI 错误信息更人类可读 |
| **模型兼容性** | 需要支持 function calling 的模型 | 任何能理解文本的模型 | CLI 方案不依赖特定 API |

### 与前版/竞品的关键差异

| 维度 | 标准 MCP | Anthropic Tool Search | CLI 方案 |
|------|---------|----------------------|---------|
| **Session Start** | ~15,540 tokens (84 工具) | ~500 tokens (搜索索引) | ~300 tokens (6 CLI) |
| **首次工具调用** | ~30 tokens | ~3,530 tokens (搜索 + 获取) | ~910 tokens (--help + 执行) |
| **10 次调用总开销** | ~15,840 tokens | ~3,800 tokens | ~964 tokens |
| **100 次调用总开销** | ~18,540 tokens | ~12,500 tokens | ~1,504 tokens |
| **相比 MCP 节省** | - | 85% | 94% |
| **相比 Tool Search 节省** | - | - | 74-88% |
| **模型限制** | 需 function calling | 仅 Anthropic | 无限制 |
| **实现复杂度** | 低（标准协议） | 中（需 API 支持） | 中（需 CLI 包装） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────────┐
│                    MCP 标准架构                                  │
├─────────────────────────────────────────────────────────────────┤
│  Session Start:                                                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ { "name": "notion-search",                              │     │
│  │   "description": "Search for pages...",                 │     │
│  │   "inputSchema": { "type": "object", ... } }           │     │
│  │ ... (84 tools × ~185 tokens = 15,540 tokens) ...       │     │
│  └────────────────────────────────────────────────────────┘     │
│                              ↓                                   │
│  Tool Call:                                                      │
│  { "tool_call": { "name": "notion-search",                       │
│                   "arguments": { "query": "..." } } }           │
│  (~30 tokens per call)                                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    CLI 包装架构                                  │
├─────────────────────────────────────────────────────────────────┤
│  Session Start:                                                 │
│  <available_tools>                                              │
│    <tool><name>notion</name><location>~/bin/notion</location>   │
│    <tool><name>linear</name><location>~/bin/linear</location>   │
│    ... (6 CLIs × ~50 tokens = 300 tokens) ...                   │
│  </available_tools>                                             │
│                              ↓                                   │
│  Discovery (on first use):                                      │
│  $ notion --help                                                │
│  notion search <query> [--filter-property ...]                  │
│    Search for pages and databases                               │
│  notion create-page <title> [--parent-id ID]                    │
│    Create a new page                                            │
│  ... (~600 tokens for 14 subcommands)                           │
│                              ↓                                   │
│  Execution:                                                      │
│  $ notion search "my search"                                    │
│  (~6 tokens)                                                    │
└─────────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

| 场景 | 理由 | 预期节省 |
|------|------|---------|
| **多工具 Agent** | 工具数量越多，MCP 的固定开销越大 | 50+ 工具时节省 >90% |
| **短会话高频调用** | 会话短则固定开销占比高，如客服 bot、快速查询 | 每次会话省 15K tokens |
| **非 Anthropic 模型** | Tool Search 仅限 Anthropic，CLI 通用 | 无模型锁定 |
| **成本敏感项目** | 个人项目/初创公司 token 预算有限 | 月省 45M+ tokens |
| **本地/私有部署** | CLI 可离线运行，无需 MCP 服务器 | 降低基础设施依赖 |

### 什么场景不值得用

| 场景 | 理由 | 建议 |
|------|------|------|
| **单次会话调用 100+ 工具** | MCP 的预加载摊销后成本降低 | 评估实际调用频率 |
| **需要复杂类型验证** | CLI 参数是字符串，MCP schema 有类型约束 | 保留 MCP 用于关键工具 |
| **团队已有 MCP 基础设施** | 迁移成本可能超过 token 节省 | 渐进式迁移，优先高频率工具 |
| **工具动态变化频繁** | CLI 需要重新生成，MCP 可热更新 | 评估工具变更频率 |
| **需要工具组合/链式调用** | MCP 支持工具间数据流，CLI 需手动管道 | 混合架构：MCP 编排 + CLI 执行 |

### 迁移成本

从标准 MCP 迁移到 CLI 包装方案：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| **安装 CLIHub** | 5 分钟 | `pip install clihub` 或从源码构建 |
| **生成 CLI** | 10 分钟/服务器 | `clihub generate <mcp-server>` |
| **修改 Agent 提示词** | 30 分钟 | 将工具注入格式从 JSON Schema 改为 CLI 列表 |
| **测试工具发现** | 1-2 小时 | 验证 agent 能正确 `--help` 并解析输出 |
| **回归测试** | 2-4 小时 | 确保所有工具调用行为一致 |
| **监控 token 使用** | 持续 | 对比迁移前后的实际消耗 |

**总迁移成本**：约 4-8 小时（6 个 MCP 服务器）。对于重度 MCP 用户，ROI 通常在 1-2 周内收回（按 token 节省计算）。

## 对你的意义

### 与现有系统的关联

如果你正在维护或开发以下系统，这个方案有直接价值：

1. **Moltbot Gateway**：当前使用 MCP 连接外部服务？CLI 包装可降低每次会话的固定开销。

2. **Agent-Playbook 中的 RAG 工具链**：如果 agent 需要调用多个检索/嵌入工具，CLI 懒加载可显著降低启动成本。

3. **VLA 研究的工具调用模块**：机器人系统中的工具调用（如抓取规划 API）也可以用 CLI 包装，降低 onboard 开销。

### 具体建议

| 行动 | 优先级 | 理由 |
|------|--------|------|
| **评估当前 MCP 使用** | 高 | 计算每月 token 开销中有多少是「说明书税」 |
| **试点 1-2 个高频工具** | 高 | 用 CLIHub 生成 CLI，对比 token 使用和响应时间 |
| **修改 agent 提示词模板** | 中 | 支持 CLI 风格的工具发现和调用 |
| **保留 MCP 用于复杂工具** | 中 | 需要类型验证/复杂 schema 的工具仍用 MCP |
| **监控 Tool Search 成本** | 低 | 如果用 Anthropic，对比 Tool Search vs CLI |

### 长期影响

这个方案的深层意义在于**重新思考 Agent 与工具的契约**：
- MCP 假设「agent 需要完整知识才能工作」
- CLI 假设「agent 可以像人类一样探索和学习」

这不仅仅是 token 优化，而是**Agent 交互范式的转变**。未来可能会出现更多「人类工作流映射」的工具集成方案。

## 关键代码/配置片段

### CLIHub 生成 CLI

```bash
# 从 MCP 服务器生成 CLI
clihub generate --mcp-server notion-mcp --output ~/bin/notion

# 生成的 CLI 支持标准 help 格式
~/bin/notion --help
```

### Session Start 注入格式（MCP）

```json
{
  "tools": [
    {
      "name": "notion-search",
      "description": "Search for pages and databases",
      "inputSchema": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "The search query text"
          },
          "filter": {
            "type": "object",
            "properties": {
              "property": { "type": "string", "enum": ["object"] },
              "value": { "type": "string", "enum": ["page", "database"] }
            }
          }
        }
      }
    }
    // ... 83 more tools
  ]
}
```

### Session Start 注入格式（CLI）

```xml
<available_tools>
  <tool>
    <name>notion</name>
    <description>CLI for Notion API</description>
    <location>~/bin/notion</location>
  </tool>
  <tool>
    <name>linear</name>
    <description>CLI for Linear issue tracking</description>
    <location>~/bin/linear</location>
  </tool>
  <!-- ... 4 more CLIs -->
</available_tools>
```

### 工具发现（CLI --help 输出）

```bash
$ notion --help

notion search <query> [--filter-property PROPERTY] [--filter-value VALUE]
  Search for pages and databases in Notion

notion create-page <title> [--parent-id PARENT_ID] [--content CONTENT]
  Create a new page in Notion

notion fetch-page <page_id>
  Fetch a specific page by ID

# ... 11 more commands
```

### 工具调用对比

**MCP 调用**（30 tokens）：
```json
{
  "tool_call": {
    "name": "notion-search",
    "arguments": {
      "query": "my search",
      "filter": {
        "property": "object",
        "value": "page"
      }
    }
  }
}
```

**CLI 调用**（6 tokens）：
```bash
$ notion search "my search" --filter-property object --filter-value page
```

### Token 消耗对比表

| 场景 | MCP | CLI | 节省 |
|------|-----|-----|------|
| Session Start | 15,540 | 300 | 98% |
| 1 次工具调用 | 15,570 | 910 | 94% |
| 10 次工具调用 | 15,840 | 964 | 94% |
| 100 次工具调用 | 18,540 | 1,504 | 92% |

### Anthropic Tool Search 对比

| 场景 | MCP | Tool Search | CLI | CLI vs TS 节省 |
|------|-----|-------------|-----|---------------|
| Session Start | 15,540 | 500 | 300 | 40% |
| 1 次调用 | 15,570 | 3,530 | 910 | 74% |
| 10 次调用 | 15,840 | 3,800 | 964 | 75% |
| 100 次调用 | 18,540 | 12,500 | 1,504 | 88% |

---
[← Back to Deep Dives](./README.md)
