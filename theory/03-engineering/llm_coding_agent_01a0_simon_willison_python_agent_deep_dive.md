---
auto_generated: true
generated_at: "2026-07-07T05:48:07Z"
source_url: "https://simonwillison.net/2026/Jul/2/llm-coding-agent/"
signal_type: "significant_update"
---
# llm-coding-agent 0.1a0 — Simon Willison 的 Python 编码 Agent
(llm-coding-agent 0.1a0 — Simon Willison's Python Coding Agent)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-07
>
> **项目/工具**: llm-coding-agent
> **链接**: https://simonwillison.net/2026/Jul/2/llm-coding-agent/
> **核心定位**: 基于 Simon Willison 的 llm 库构建的 Claude Code 风格编码 Agent，支持文件编辑、命令执行、glob 搜索，同时提供 CLI 和 Python API 两种使用方式

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**: 它是 Simon Willison 用 Fable 5 从零构建的 Claude Code 风格编码 Agent，底层复用其成熟的 llm 库（插件体系、模型路由、SQLite 日志），支持任何 tool-capable 模型。
- **现在值得用吗**: 看场景。0.1a0 是 alpha 预发布版，适合 Python 生态用户尝鲜和嵌入自己的应用；生产环境建议等 0.1+ stable。
- **适合场景**: Python 项目内的快速代码修改、测试驱动开发辅助、嵌入到其他 Python 应用作为 agent 组件
- **不适合场景**: 需要沙箱隔离的生产环境、Windows 平台、需要 MCP 工具集成的复杂工作流
- **与 Claude Code 核心差异**: 不绑定单一模型（支持任何 llm 插件模型），无 IDE 集成，无 MCP 支持，但提供干净的 Python API 可嵌入

## 是什么 / 解决什么问题

Simon Willison 是 llm 命令行工具的作者——一个围绕 LLM API 的通用 CLI 框架，支持插件扩展、多模型路由、对话持久化。随着 llm 库逐渐演变成一个 agent 框架（引入了 `model.chain()`、`llm.Toolbox`、`llm.PauseChain` 等 API），他决定用 Fable 5 从零构建一个编码 Agent 来验证这套 API 的能力边界。

llm-coding-agent 的核心价值主张很清晰：**让任何支持 tool calling 的模型都能变成一个编码 Agent**，而不像 Claude Code 那样绑定 Anthropic 模型。它通过 llm 插件体系分发，安装后自动获得 `llm code` 子命令，同时工具集也可以被 `llm chat --tool CodingTools` 复用。

这个项目由 Fable 5 全程编写——Simon 只给了两个 prompt：先让 Fable 5 写 spec.md，再让 Fable 5 用 red/green TDD 构建整个项目。这本身就是一个 meta 示范：用 AI 构建 AI 编码工具。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 |
|------|------|
| 基于 llm 插件体系分发 | 复用已有的模型路由、日志、配置体系，零额外依赖 |
| 模型无关 | 支持任何 tool-capable 模型（GPT-5.5、Fable 5、Gemini、本地模型等） |
| 沙箱目录隔离 | 所有文件操作限制在 session root 内，路径穿越返回错误而非抛异常 |
| 安全默认 | 只读工具自由执行；写文件、编辑、命令执行需要用户审批 |
| 无容器/无沙箱 | 非目标——安全性来自审批流程而非进程隔离（明确列为 non-goal） |
| SQLite 日志 | 复用 llm 的对话持久化机制，支持 `llm logs` 查看和 `--continue` 恢复 |

### 与前版/竞品的关键差异

| 维度 | Claude Code | llm-coding-agent 0.1a0 |
|------|-------------|------------------------|
| 模型绑定 | 仅 Anthropic | 任意 llm 插件模型 |
| 安装方式 | npm 全局安装 | pip / uvx 安装，llm 插件 |
| Python API | 无 | `CodingAgent(model, root, approve).run()` |
| 审批机制 | 交互式 / YOLO 模式 | 交互式 / YOLO / callable 函数 / PauseChain |
| MCP 支持 | 有 | 无（列为 future work） |
| IDE 集成 | VS Code / JetBrains | 无（纯终端） |
| 对话持久化 | 本地文件 | SQLite（llm 统一日志） |
| 模型切换 | 不支持 | `!model MODEL` 会话中切换 |
| 链式执行上限 | 无明确限制 | `--chain-limit N`（默认 25 轮） |

### 架构/信息流图

```
用户输入 prompt
       │
       ▼
┌──────────────────────────────────────┐
│  llm code CLI (click)                │
│  ├─ 解析 --yolo / --allow / -m 等    │
│  └─ 构造 CodingAgent(model, root)    │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  CodingAgent.run(prompt)             │
│  ├─ conversation.chain()             │
│  │   ├─ before_call() 审批回调       │
│  │   │   ├─ 只读工具 → 直接执行      │
│  │   │   ├─ 写/编辑/命令 → 用户审批  │
│  │   │   └─ !yolo / --allow → 自动  │
│  │   └─ 执行 CodingTools            │
│  ├─ chain_limit 检查 (默认 25 轮)    │
│  └─ 返回 result (text + tool_calls)  │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  CodingTools (llm.Toolbox)           │
│  ├─ read_file / write_file           │
│  ├─ edit_file (exact string replace) │
│  ├─ list_files (glob + .gitignore)   │
│  ├─ search_files (ripgrep fallback)  │
│  └─ execute_command (timeout + kill) │
└──────────────────────────────────────┘
```

### 工具集详解

| 工具 | 功能 | 审批要求 | 关键特性 |
|------|------|----------|----------|
| `read_file` | 读取文件，返回带行号的内容 | 否 | offset/limit 分页，长行截断 2000 字符，50KB 上限 |
| `write_file` | 创建/覆盖文件 | 是 | 自动创建父目录 |
| `edit_file` | 精确字符串替换 | 是 | 返回 unified diff 供模型验证，重复出现时报错 |
| `list_files` | glob 文件列表 | 否 | 按修改时间排序，最多 200 条，尊重 .gitignore |
| `search_files` | 正则内容搜索 | 否 | ripgrep 优先，纯 Python 回退，glob 过滤 |
| `execute_command` | 运行 shell 命令 | 是 | 超时默认 120s/上限 600s，kill 整个进程树 |

## 实用评估

### 什么场景值得用

1. **Python 项目的快速修改**: 如果你有一个 Python 项目，需要快速修复 bug 或添加功能，`llm code --yolo` 可以直接在终端里对话式地完成。支持任何模型这一点特别有价值——你可以用 GPT-5.5、Fable 5 或本地模型。

2. **嵌入到自己的 Python 应用**: `CodingAgent` 的 Python API 非常干净。如果你的应用需要一个编码 agent 组件（比如在线 IDE、代码评审工具），可以直接 import 使用。`approve=callable` 支持自定义审批逻辑。

3. **模型对比实验**: 因为支持 `-m` 切换模型，你可以方便地对比不同模型在编码任务上的表现。`!model MODEL` 甚至支持在同一个会话中切换模型。

4. **TDD 辅助开发**: Simon 自己就是用 `llm code --yolo` 让 Fable 5 完成了整个项目的 TDD 开发。对于熟悉的项目，指定初始任务后 agent 可以自主完成多轮编辑-测试循环。

### 什么场景不值得用

1. **生产环境自动化**: 明确没有沙箱/容器化，agent 以调用用户权限运行。对于不受信任的代码或高风险操作，这是硬伤。

2. **Windows 平台**: 命令通过 `subprocess.run(shell=True)` 执行，目标是 POSIX shell。Windows 用户需要额外处理。

3. **需要 MCP 工具集成的工作流**: 当前版本不支持 MCP。如果你的项目依赖 MCP 服务器（数据库查询、API 调用等），需要等 future work。

4. **大型代码库的深度重构**: chain_limit 默认 25 轮，对于涉及多个文件的大规模重构可能不够。而且 edit_file 的精确字符串匹配在大型文件中容易因 whitespace 差异失败。

### 迁移成本

从 Claude Code 迁移到 llm-coding-agent：
- **安装**: `pip install --pre llm-coding-agent`（需要 llm 已安装）
- **模型配置**: 需要配置对应的 llm 插件（`llm install llm-gpt5` 等）
- **工作流适配**: CLI 命令语法不同（`llm code` vs `claude`），但核心交互模式相似
- **估算工作量**: 个人用户 30 分钟内可完成环境搭建；团队嵌入需要额外适配审批流程

## 对你的意义

这个项目对你（Ken，AI 应用开发者）有几个值得关注的点：

1. **llm 库的 agent 化趋势**: Simon Willison 的 llm 库正在从 CLI 工具演变为 agent 框架。`model.chain()`、`llm.Toolbox`、`llm.PauseChain` 等 API 的引入表明，轻量级 agent 框架是一个真实需求。如果你的 Agent-Playbook 中需要覆盖这个方向，llm 库值得收录。

2. **模型无关的编码 Agent**: 与 Claude Code 绑定 Anthropic 不同，llm-coding-agent 支持任何 tool-capable 模型。这意味着你可以用本地模型运行编码 agent——对于隐私敏感的场景或成本敏感的团队，这是一个差异化优势。

3. **Python API 可嵌入性**: `CodingAgent(model, root, approve).run()` 的 API 设计非常简洁。如果你的项目中需要嵌入一个编码 agent 组件（比如构建 AI 辅助开发工具），这是一个可以直接复用的基础模块。

4. **Fable 5 自举示范**: 整个项目由 Fable 5 用两个 prompt 从零构建（spec → TDD → 发布），是 AI 辅助开发的 meta 案例。这验证了 Fable 5 在代码生成方面的能力——值得在你的 AI 应用监控中持续关注。

**建议**: 值得试用。用 `uvx --prerelease=allow --with llm-coding-agent llm code` 即可零安装体验。对于 Python 项目内的日常修改，它的模型灵活性是一个真实优势。

## 关键代码/配置片段

### CLI 使用

```bash
# 零安装试用
uvx --prerelease=allow --with llm-coding-agent llm code

# 指定模型和目录
llm code -m gpt-4.1 -d ~/dev/myproject

# YOLO 模式（自动批准所有操作）
llm code --yolo

# 预批准特定命令模式
llm code --allow "pytest*" --allow "git diff*"

# 恢复上次会话
llm code -c
```

### Python API 嵌入

```python
from llm_coding_agent import CodingAgent

# 基础用法
agent = CodingAgent(
    model="gpt-5.5",           # 任意 llm 模型 ID
    root="/path/to/project",
    approve=True,              # 自动批准所有工具调用
)
result = agent.run("Fix the failing test in tests/test_parser.py")
print(result.text)             # 模型的最终回答
for tool_call, tool_result in result.tool_calls:
    print(tool_call.name, tool_call.arguments)

# 自定义审批逻辑
def my_approval(tool, tool_call):
    # 拒绝 execute_command，允许其他操作
    return tool.name != "execute_command"

agent = CodingAgent(model="gpt-5.5", root="/path", approve=my_approval)

# 暂停模式（适合无终端的嵌入场景）
agent = CodingAgent(model="gpt-5.5", root="/path", approve=None)
result = agent.run("Add changelog")
if result.paused:
    # 在 UI 中展示 pending_tool_calls，用户确认后继续
    for call in result.pending_tool_calls:
        print(f"Model wants to: {call.name}({call.arguments})")
    agent.resume()  # 批准并继续
```

### 工具直接调用

```python
from llm_coding_agent import CodingTools

tools = CodingTools("/path/to/project")
print(tools.read_file("README.md"))                          # 带行号
print(tools.read_file("big.log", offset=100, limit=50))      # 分页
tools.write_file("notes/todo.md", "- ship it\n")             # 创建文件
print(tools.edit_file("app.py", "DEBUG = True", "DEBUG = False"))  # 精确替换
print(tools.list_files("**/*.py"))                           # glob 搜索
print(tools.search_files("TODO", glob="*.py"))               # 内容搜索
print(tools.execute_command("pytest -x", timeout=300))       # 运行命令
```

---
[← Back to Deep Dives](./README.md)
