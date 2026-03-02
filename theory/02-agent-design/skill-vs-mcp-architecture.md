# 架构分析：Skill 与 MCP 的边界与配合

> **文章定位**：本文系统梳理 Skill（技能）与 MCP（Model Context Protocol）两种 Agent 能力扩展范式的本质差异、协议细节、设计规范与生产级实践指南，面向希望构建生产级 AI Agent 系统的工程师与架构师。

---

## 1. 核心差异对比表（原始基础）

| 维度 | Claude Skill | MCP (Model Context Protocol) |
| :--- | :--- | :--- |
| **本质** | **工作流与专家指令集** | **标准化资源调用协议** |
| **作用目标** | 改变 AI 的"思考逻辑"和"操作步骤" | 扩展 AI 的"感知边界"和"执行能力" |
| **注入方式** | 通过 `.md` 或特定格式注入 Prompt 上下文 | 通过 JSON-RPC 协议连接远程/本地服务器 |
| **典型场景** | 代码重构规范、特定框架的最佳实践、SEO 检查流 | 读写数据库、连接 Notion、实时气象数据查询 |
| **优势** | 轻量、无需维护服务器、易于分享 | 跨模型通用、支持复杂权限控制、连接海量外部工具 |

---

## 2. 深度解析：Skill 是工作流的替代

正如 @wquguru 所言，"Skill 是工作流的替代"。
一个高质量的 Skill 包含：
- **Persona（人格）**：该领域的专家形象。
- **Rules（规则）**：必须遵守的工程规范。
- **Examples（示例）**：Few-shot 学习，告诉 AI 什么是"好"的产出。
- **Task Decomposition（任务拆解）**：面对复杂需求时，AI 应该分几步走。

---

## 3. 深度解析：MCP 是外部资源的入口

MCP 的强大在于它的**标准化**。
一旦一个资源（如 GitHub Repo, Slack Channel, SQL Database）被封装成 MCP Server，任何支持 MCP 协议的 Agent（Claude, Cursor, Z Code 等）都可以立即调用，无需重复编写逻辑。

---

## 4. 最佳实践：如何配合使用？（原始场景）

**场景示例：自动修复数据库性能问题**

1. **使用 MCP**：连接到数据库监控 Server，获取慢查询日志。
2. **使用 Skill**：注入一份"SQL 性能优化专家技能包"，里面包含针对该数据库版本的索引策略和重写规则。
3. **协同执行**：AI 通过 MCP 获取原始数据，根据 Skill 提供的逻辑进行分析，最后再通过 MCP 执行优化后的 SQL 命令。

---

## 5. MCP 协议深度解析（2026 版）

### 5.1 协议架构总览

MCP（Model Context Protocol）是 Anthropic 于 2024 年末发布、2025 年正式推广的开放标准，目标是让 LLM 与外部工具/数据源之间的交互标准化，类似于 LSP（Language Server Protocol）对编辑器生态的作用。

```
+----------------------------------------------------------+
|                    MCP 完整架构图                          |
+----------------------------------------------------------+
|                                                          |
|   +---------------+        +--------------------------+ |
|   |  MCP Client   |        |      MCP Server          | |
|   |  (LLM Host)   |        |  (Tool/Resource Provider)| |
|   |               |        |                          | |
|   |  +---------+  |        |  +---------+             | |
|   |  | Claude  |  |        |  | Tools   | list/call   | |
|   |  | Cursor  |  |        |  +---------+             | |
|   |  | etc.    |  |        |  |Resources| list/read   | |
|   |  +---------+  |        |  +---------+             | |
|   |               |        |  |Prompts  | list/get    | |
|   |  MCP Client   |<------>|  +---------+             | |
|   |  Layer        |        |                          | |
|   +---------------+        +--------------------------+ |
|                                                          |
|   Transport Layer Options:                               |
|   +------------+------------------+------------------+  |
|   |  stdio     |  HTTP + SSE      |  HTTP Streamable  |  |
|   |  (local)   |  (remote)        |  (MCP 1.x new)   |  |
|   +------------+------------------+------------------+  |
+----------------------------------------------------------+
```

### 5.2 传输层详解

MCP 1.x 支持三种传输方式：

| 传输方式 | 适用场景 | 优点 | 缺点 |
| :--- | :--- | :--- | :--- |
| **stdio** | 本地进程（桌面应用、CLI） | 零网络延迟，无需认证 | 不可远程访问 |
| **HTTP + SSE** | 远程服务，需要实时推送 | 支持流式响应，防火墙友好 | 连接维护成本高 |
| **HTTP Streamable** | MCP 1.1+ 新标准，替代 SSE | 更简洁，支持断线重连 | 需客户端升级 |

### 5.3 能力协商流程（ASCII 时序图）

```
Client                              Server
  |                                    |
  |------ initialize ----------------->|
  |     {protocolVersion: "2024-11-05",|
  |      capabilities: {               |
  |        roots: {listChanged: true}, |
  |        sampling: {}                |
  |      }}                            |
  |                                    |
  |<------ initialize result ----------|
  |     {protocolVersion: "2024-11-05",|
  |      capabilities: {               |
  |        tools: {listChanged: true}, |
  |        resources: {},              |
  |        prompts: {}                 |
  |      },                            |
  |      serverInfo: {name, version}}  |
  |                                    |
  |------ initialized (notify) ------->|
  |                                    |
  |------ tools/list ----------------->|
  |<------ tools/list result ----------|
  |     {tools: [{name, description,   |
  |               inputSchema},...]}   |
  |                                    |
  |------ tools/call ----------------->|
  |     {name: "query_db",             |
  |      arguments: {sql: "..."}}      |
  |                                    |
  |<------ tools/call result ----------|
  |     {content: [{type: "text",      |
  |                 text: "results"}]} |
  |                                    |
```

### 5.4 MCP 1.x 规范重点更新

- **OAuth 2.1 授权框架**（1.1+）：远程 MCP Server 可使用标准 OAuth 流程，而非自定义认证。
- **Elicitation API**：Server 可主动向用户请求额外信息（如缺少参数时的交互补全）。
- **Streamable HTTP**：统一替代 SSE，单一端点处理请求/响应/通知流。
- **Tool Annotations**：工具元数据扩展（`readOnly`, `destructive`, `idempotent` 标记），帮助客户端做风险评估。
- **Resource Subscriptions**：客户端可订阅资源变更通知，实现实时数据推送。

---

## 6. Skill vs MCP 决策矩阵

### 6.1 八维度全面对比

| 维度 | Skill（技能） | MCP（协议） | 推荐选择 |
| :--- | :--- | :--- | :--- |
| **耦合度** | 与 Prompt 强耦合，换模型需适配 | 标准协议，模型无关 | 跨模型场景选 MCP |
| **可发现性** | 手动注入，依赖用户感知 | 自动 `tools/list` 发现 | 工具数量多时选 MCP |
| **版本管理** | .md 文件版本控制 | Server 版本 + 能力协商 | 复杂版本演进选 MCP |
| **安全边界** | 无沙箱，完全依赖 Prompt 约束 | Server 进程隔离，可加权限控制 | 涉及敏感操作必选 MCP |
| **延迟** | 零延迟（Prompt 注入） | 网络/IPC 调用延迟 10ms~500ms | 高频轻量操作选 Skill |
| **有/无状态** | 无状态（每次对话重建） | 可有状态（Server 维护会话） | 需要持久状态选 MCP |
| **跨 Agent 共享** | 不可直接共享，需手动分发 | 任意客户端即插即用 | 多 Agent 协作必选 MCP |
| **生态支持** | 社区 Skill 市场（skillsmp等） | 官方 + 社区 500+ Server | 标准化集成选 MCP |

### 6.2 决策流程图

```
                  新能力需求
                      |
         +------------+------------+
         v                         v
    是否需要访问               是否改变 AI
    外部系统/数据?              的推理方式?
         |                         |
    是   |                    是   |
         v                         v
      使用 MCP              使用 Skill
    (协议 + Server)         (.md 指令集)
         |                         |
         +------------+------------+
                      v
              两者都需要？
              -> 混合架构
               (见第 10 节)
```

### 6.3 快速选择建议

- **只用 Skill**：任务纯粹是推理/写作/代码生成，不需要外部数据，Skill 越轻越好。
- **只用 MCP**：工具集标准化，多个 Agent 共享，需要数据库/API 集成。
- **Skill + MCP**：生产级 Agent，内部推理逻辑靠 Skill 约束，外部资源靠 MCP 接入。

---

## 7. MCP Server 实现模板

以下是使用 Python FastMCP 框架实现生产级 MCP Server 的完整模板：

```python
"""
production_mcp_server.py
MCP Server template using FastMCP
"""
from __future__ import annotations

import logging
import os
from typing import Any

from mcp.server.fastmcp import FastMCP, Context

logger = logging.getLogger(__name__)

mcp = FastMCP(
    name="production-server",
    version="1.0.0",
)

# --- Auth helper ---
API_KEY = os.environ.get("MCP_API_KEY", "")

def _verify_key(provided: str) -> bool:
    return provided == API_KEY if API_KEY else True


# --- Tool registration (avoid anyOf/oneOf; use Literal for enums) ---

@mcp.tool(
    description="Query database records. Returns JSON list."
)
def query_database(
    table: str,
    limit: int = 20,
    order_by: str = "created_at",
) -> list[dict[str, Any]]:
    """
    Design principles:
    - Each param has clear description via docstring/Annotated
    - Avoid Union[str, int]; use str and convert internally
    - limit has safe default to prevent LLM omitting it
    """
    allowed_tables = {"articles", "signals", "entities"}
    if table not in allowed_tables:
        raise ValueError(f"table must be one of {sorted(allowed_tables)}")

    logger.info("query_database table=%s limit=%d", table, limit)
    # rows = db.execute(f"SELECT * FROM {table} ORDER BY {order_by} LIMIT {limit}")
    return [{"id": 1, "table": table, "note": "example row"}]


@mcp.tool(
    description="Send message to a Telegram channel. Text only."
)
def send_notification(
    channel_id: str,
    message: str,
    dry_run: bool = False,
) -> dict[str, Any]:
    """
    destructive=True: has external side effects.
    dry_run=True: log only, no actual send.
    """
    if len(message) > 4096:
        raise ValueError("message exceeds 4096-char limit")

    if dry_run:
        logger.info("[DRY RUN] would send to %s: %s", channel_id, message[:80])
        return {"status": "dry_run", "channel_id": channel_id}

    logger.info("send_notification channel=%s", channel_id)
    return {"status": "sent", "channel_id": channel_id}


# --- Resource registration ---

@mcp.resource("memory://signals/latest")
def get_latest_signals() -> str:
    return "Today signals: 3 VLA updates, 2 AI Agent paradigm shifts."


@mcp.resource("memory://config/{domain}")
def get_domain_config(domain: str) -> str:
    configs = {
        "vla": '{"keywords": ["VLA", "video-language"]}',
        "ai_app": '{"keywords": ["agent", "MCP", "skill"]}',
    }
    return configs.get(domain, '{"error": "unknown domain"}')


# --- Entry point ---
if __name__ == "__main__":
    import sys

    transport = sys.argv[1] if len(sys.argv) > 1 else "stdio"
    if transport == "stdio":
        mcp.run(transport="stdio")
    elif transport == "http":
        mcp.run(transport="streamable-http", host="0.0.0.0", port=8080)
    else:
        print(f"Unknown transport: {transport}", file=sys.stderr)
        sys.exit(1)
```

**关键设计要点**：
1. 每个工具的 `description` 字段必须精准，LLM 靠它决策是否调用该工具。
2. 输入参数白名单校验（`allowed_tables`），防止 Prompt Injection 经由工具参数渗透。
3. `dry_run` 模式是破坏性工具的标配安全阀。
4. 资源路径使用 URI 模板（`memory://config/{domain}`），支持参数化访问。

---

## 8. Skill 系统设计规范

### 8.1 原子 Skill vs 复合 Skill

```
Skill 粒度层级：

  原子 Skill（Atomic）
  +-- 单一职责，100~300 行 Markdown
  +-- 例：sql-index-optimizer.md
  +-- 例：code-review-security.md
  +-- 例：arxiv-abstract-summarizer.md

  复合 Skill（Composite）
  +-- 组合多个原子 Skill，通过 include 语法或 prompt 引用
  +-- 例：full-stack-debug.md（包含 sql + network + log 三个原子）
  +-- 最大建议深度：2 层（避免 Prompt 膨胀）
```

### 8.2 Skill 组合模式

| 模式 | 描述 | 适用场景 |
| :--- | :--- | :--- |
| **顺序链** | Skill A -> Skill B -> Skill C | 流水线处理，步骤固定 |
| **条件分支** | 根据输入类型选择 Skill | 多领域问题路由 |
| **并行聚合** | 多个 Skill 独立运行后合并结果 | 多角度分析 |
| **回退降级** | 主 Skill 失败时调用简化版 | 容错设计 |

### 8.3 Skill 版本策略

```
skill-registry/
+-- sql-optimizer/
|   +-- v1.0.md        # 稳定版
|   +-- v1.1.md        # 修订版（小改）
|   +-- v2.0-beta.md   # 重构版（实验中）
+-- CHANGELOG.md       # 记录每次 Skill 变更的 prompt 效果变化
```

- **语义化版本**：`MAJOR.MINOR`（行为兼容改动用 MINOR，破坏性重构用 MAJOR）。
- **灰度发布**：先在 10% Agent 上切换新版，对比关键指标（输出质量评分）后全量。
- **回滚保留**：至少保留上一个 MAJOR 版本，用于回滚。

### 8.4 冲突解决

当多个 Skill 同时被加载时，可能出现规则冲突（如两个 Skill 对同一情况有不同建议）：

1. **显式优先级声明**：每个 Skill 头部添加 `priority: high/medium/low`。
2. **最后加载优先**：后注入的 Skill 覆盖前者（类似 CSS 层叠）。
3. **冲突检测**：维护 Skill Registry 时，对关键词重叠的规则做静态检测并告警。

---

## 9. Tool Schema 设计陷阱

### 9.1 常见错误模式

**错误 1：过度使用 Union 类型**

```json
// 错误示例 — anyOf 会让部分 LLM 客户端拒绝 schema
{
  "name": "search",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "anyOf": [
          {"type": "string"},
          {"type": "array", "items": {"type": "string"}}
        ]
      }
    }
  }
}
```

```json
// 正确示例 — 拆成两个独立工具，各自职责清晰
// 工具 1: search_by_text
{
  "name": "search_by_text",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {"type": "string", "description": "单条搜索词"}
    },
    "required": ["query"]
  }
}
```

**错误 2：参数名含义模糊**

```python
# 错误：LLM 不知道 "data" 里应该填什么
def process(data: str) -> str: ...

# 正确：名称 + description 双重说明
def analyze_article(
    article_markdown: str,
    # description: "完整的 Markdown 格式文章内容，不超过 10000 字符"
) -> str: ...
```

**错误 3：过深嵌套**

```json
// 错误：3 层嵌套，LLM 容易填错层级
{
  "config": {
    "database": {
      "connection": {"host": "localhost"}
    }
  }
}

// 正确：扁平化，最多 2 层
{
  "db_host": "localhost",
  "db_port": 5432,
  "db_name": "mydb"
}
```

**错误 4：缺少 required 字段声明**

```json
// 错误：LLM 不知道哪些参数必填，可能遗漏
{"properties": {"query": {}, "limit": {}}}

// 正确：明确声明必填项
{"properties": {"query": {}, "limit": {}}, "required": ["query"]}
```

### 9.2 Schema 设计检查清单

- [ ] 无 `anyOf` / `oneOf` / `allOf`（改用独立工具或 string enum）
- [ ] 每个参数有 `description` 字段
- [ ] 参数名英文自解释（`article_url` 优于 `url`）
- [ ] `required` 字段准确声明
- [ ] 嵌套深度不超过 2 层
- [ ] 枚举值用 `enum: ["val1", "val2"]` 声明，不用 `pattern` 正则
- [ ] 无 `format` 作为顶级属性名（部分验证器将其作为保留关键字）

---

## 10. 混合架构模式

### 10.1 生产级混合系统架构图

```
+--------------------------------------------------------------------+
|                     生产级 Agent 系统架构                            |
+--------------------------------------------------------------------+
|                                                                    |
|  +-------------------------------------------------------------+   |
|  |                    Agent Core (LLM)                          |   |
|  |                                                              |   |
|  |  +--------------------------------------------------+       |   |
|  |  |              Skill Layer（内部能力）                |       |   |
|  |  |  sql-expert.md | code-review.md | seo.md         |       |   |
|  |  |  (Prompt 注入，塑造推理逻辑)                        |       |   |
|  |  +--------------------------------------------------+       |   |
|  |                          |                                   |   |
|  |                    推理 + 决策                                |   |
|  |                          |                                   |   |
|  |  +--------------------------------------------------+       |   |
|  |  |              MCP Client Layer                     |       |   |
|  |  +------+------------------+------------------+-----+       |   |
|  +----------|-----------------|--------------------|----------+   |
|             |                 |                    |              |
|     +-------v------+  +-------v------+  +----------v---+         |
|     |  DB MCP      |  |  GitHub MCP  |  |  Slack MCP   |  ...   |
|     |  Server      |  |  Server      |  |  Server      |         |
|     |  (stdio)     |  |  (HTTP)      |  |  (HTTP)      |         |
|     +--------------+  +--------------+  +--------------+         |
|                                                                    |
+--------------------------------------------------------------------+
```

### 10.2 内外分工原则

| 能力类型 | 实现方式 | 理由 |
| :--- | :--- | :--- |
| 领域推理规则、工程规范 | Skill (.md) | 轻量，快速迭代，无网络依赖 |
| 数据库读写 | MCP Server | 安全隔离，权限可控 |
| 第三方 API（GitHub/Slack） | MCP Server | 官方实现，开箱即用 |
| 文件系统操作 | MCP Server (filesystem) | 沙箱化路径访问 |
| 计算/格式转换 | Skill 或内置 Tool | 无需外部服务 |

### 10.3 Skill 指导 MCP 调用的模式

Skill 不仅提供推理规范，还可以**指导 Agent 如何使用 MCP 工具**：

```markdown
# SQL 优化专家 Skill

## 工具使用规范
在调用 `query_database` MCP 工具前，必须：
1. 先用 EXPLAIN 语法分析查询计划
2. 每次 limit 不超过 100 行
3. 禁止在生产库执行 DROP/TRUNCATE

## 输出规范
优化建议必须包含：预计性能提升百分比 + 回滚方案
```

---

## 11. 安全边界设计

### 11.1 工具权限分级

```
权限等级（从低到高）：

  READ_ONLY    — 只读查询，无副作用
  +-- 示例：search, list, get
  +-- 审计要求：低（抽样记录）

  WRITE        — 写入操作，可撤销
  +-- 示例：create_file, update_record
  +-- 审计要求：中（全量记录 + diff）

  DESTRUCTIVE  — 不可撤销操作
  +-- 示例：delete, send_email, deploy
  +-- 审计要求：高（全量 + 人工确认）

  PRIVILEGED   — 系统级操作
  +-- 示例：exec_shell, modify_config
  +-- 审计要求：极高（审批工作流）
```

### 11.2 输入净化模式

LLM 生成的工具参数可能包含 Prompt Injection 攻击或意外的危险值：

```python
import re
import shlex

SHELL_TOOLS = {"run_command", "exec_script"}
SHELL_ARG_KEYS = {"cmd", "args", "script"}

def sanitize_tool_args(tool_name: str, args: dict) -> dict:
    sanitized = {}
    for key, value in args.items():
        if isinstance(value, str):
            # 1. Truncate overly long strings
            value = value[:4096]
            # 2. Strip control characters (prevent terminal injection)
            value = re.sub(r"[\x00-\x08\x0b-\x1f\x7f]", "", value)
            # 3. Shell-quote args destined for shell tools
            if tool_name in SHELL_TOOLS and key in SHELL_ARG_KEYS:
                value = shlex.quote(value)
        sanitized[key] = value
    return sanitized
```

### 11.3 速率限制与熔断

```python
from collections import defaultdict
from time import time

class ToolRateLimiter:
    def __init__(self, max_calls: int = 10, window_sec: int = 60):
        self.max_calls = max_calls
        self.window_sec = window_sec
        self._history: dict[str, list[float]] = defaultdict(list)

    def allow(self, tool_name: str) -> bool:
        now = time()
        self._history[tool_name] = [
            t for t in self._history[tool_name]
            if now - t < self.window_sec
        ]
        if len(self._history[tool_name]) >= self.max_calls:
            return False
        self._history[tool_name].append(now)
        return True
```

### 11.4 审计日志结构

```json
{
  "event_type": "tool_call",
  "timestamp": "2026-03-02T09:30:00Z",
  "agent_id": "reports-agent",
  "tool_name": "query_database",
  "args_hash": "sha256:abc123",
  "args_preview": {"table": "articles", "limit": 20},
  "result_size_bytes": 1024,
  "duration_ms": 45,
  "permission_level": "READ_ONLY",
  "approved_by": "auto"
}
```

---

## 12. 2026 生态现状

### 12.1 MCP 采用现状（2026 Q1）

MCP 在 2025 年下半年迎来爆发式增长，截至 2026 年初：

- **官方支持客户端**：Claude Desktop、Claude Code CLI、Cursor、Windsurf、Cody、Continue、Zed 等 20+ 主流工具
- **社区 MCP Server 数量**：GitHub `modelcontextprotocol/servers` 收录 500+，第三方生态超 2000+
- **企业采用**：Cloudflare、Stripe、MongoDB 等发布官方 MCP Server

### 12.2 主要 MCP Server 生态

| 类别 | 代表 Server | 功能 |
| :--- | :--- | :--- |
| **代码协作** | GitHub MCP | Issues、PR、文件读写、代码搜索 |
| **通讯** | Slack MCP | 消息发送、频道历史、用户查询 |
| **数据库** | PostgreSQL/SQLite MCP | SQL 查询、Schema 探索 |
| **浏览器** | Playwright/Puppeteer MCP | 网页抓取、截图、表单填写 |
| **文件系统** | Filesystem MCP | 沙箱化本地文件读写 |
| **搜索** | Brave Search / Exa MCP | 实时网页搜索 |
| **知识库** | Notion / Obsidian MCP | 笔记读写、数据库查询 |
| **监控** | Sentry / Datadog MCP | 错误追踪、指标查询 |

### 12.3 新兴标准动态

| 标准/协议 | 状态 | 影响 |
| :--- | :--- | :--- |
| **A2A（Agent-to-Agent）** | Google 提出，2025 Q4 发布 | Agent 之间直接协作，MCP 偏向 Agent-Tool |
| **OpenAI Function Calling 兼容层** | 社区适配层存在 | MCP Tool 可适配为 OpenAI function 格式 |
| **MCP Registry（官方目录）** | 2025 Q4 上线 Beta | 标准化 Server 发现与评级 |
| **Elicitation API** | MCP 1.1 草案 | Server 主动请求用户输入，闭环交互 |
| **Tool Annotations** | MCP 1.1+ | 工具风险标记，客户端 UI 差异化展示 |

### 12.4 H1 2026 值得关注

1. **MCP 多租户模式**：同一 Server 服务多个 Agent，配合 OAuth 做用户级权限隔离。
2. **Skill 与 MCP 融合趋势**：部分框架（如 LangGraph）开始将 Skill 逻辑编译为 MCP 工具，实现统一调用接口。
3. **边缘部署 MCP**：在 IoT/移动端运行轻量 MCP Server（stdio 传输），无需云端。
4. **MCP 测试框架成熟**：官方 Inspector 工具 + 社区测试套件，降低 Server 开发门槛。

---

## 13. 总结：架构选择的核心原则

```
+========================================================+
|              Skill vs MCP 选择备忘录                     |
+========================================================+
|                                                        |
|  SKILL 适合：                                           |
|  [+] 固化领域专家知识（规则/示例/风格）                    |
|  [+] 不依赖外部系统的纯推理任务                           |
|  [+] 快速迭代、轻量分发、单个 Agent 使用                  |
|                                                        |
|  MCP 适合：                                             |
|  [+] 访问外部系统（数据库/API/文件）                       |
|  [+] 需要权限控制和审计的操作                             |
|  [+] 多 Agent/多工具共享的标准化接口                      |
|                                                        |
|  混合使用（生产推荐）：                                    |
|  [+] Skill 定义"怎么思考"                               |
|  [+] MCP 提供"怎么执行"                                 |
|  [+] 两者互不替代，相互增强                               |
|                                                        |
+========================================================+
```

---

**关联阅读：**
- [Claude Skill 市场：skillsmp 发现](/landscape/app-index)
- [CC Switch: 同时管理 Skill 与 MCP 的神器](/theory/02-agent-design/cc-switch-guide)
- [Agent 失败分类：T1-T6 故障模式](/theory/03-engineering/agent-failure-taxonomy)
- [Context 工程实战指南](/theory/03-engineering/context-engineering-field-guide)
