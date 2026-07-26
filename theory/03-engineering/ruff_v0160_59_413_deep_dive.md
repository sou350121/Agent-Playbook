---
auto_generated: true
generated_at: "2026-07-26T05:47:28Z"
source_url: "https://simonwillison.net/2026/Jul/25/ruff/"
signal_type: "blog_post"
---
# Ruff v0.16.0：默认检查规则从 59 条暴增至 413 条 (Ruff v0.16.0: Default Rules Explode from 59 to 413)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-26
>
> **项目/工具**: Ruff (Astral)
> **链接**: https://github.com/astral-sh/ruff/releases/tag/0.16.0
> **核心定位**: Python 生态最大的 lint 工具发布破坏性更新，默认启用规则数膨胀 7 倍，大量 CI 管线因新默认规则失败——这是 Python 代码质量基础设施的一次范式转移。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Ruff v0.16.0 将默认启用的检查规则从 59 条激增至 413 条（总规则数 708→968），是 v0.1.0 以来首次修改默认规则集。
- **现在值得用吗**: 看场景。如果你的项目有完善的 CI 测试覆盖且依赖版本锁定，升级收益远大于成本；如果是遗留项目或依赖未锁定 pin，CI 可能大面积失败。
- **适合场景**: 新项目零配置即用、CI 管线质量门禁、AI 编码助手（输出包含修复所需全部上下文）
- **不适合场景**: 遗留代码库（无测试覆盖）、依赖版本未 pin 的 CI、不想处理数百个新 lint 报错的团队
- **与前版核心差异**: 从"最小默认集 + 手动扩展"变为"最大默认集 + 按需收缩"，配置哲学完全翻转。

## 是什么 / 解决什么问题

Ruff 是由 Astral（现位于 OpenAI 旗下）开发的极速 Python linter 和 formatter，用 Rust 编写，速度比 Flake8 + Black + isort + pydocstyle + pyupgrade 等工具加起来还快数十到数百倍。它已经成为 Python 生态中最主流的代码质量工具之一。

自 v0.1.0 以来，Ruff 的规则总数从 708 条增长到 968 条，但默认启用的规则一直停留在 59 条（E4/E7/E9/F 四个类别）。这意味着大量能捕获严重问题（语法错误、运行时错误）的规则，用户必须手动 `select` 或 `extend-select` 才能启用。

v0.16.0 彻底改变了这一策略：**默认启用 413 条规则**，覆盖 flake8-bugbear (B)、pyupgrade (UP)、Ruff 自有 RUF 类别等。官方声明："即使你已经在用 select，我们也希望这能让你发现以前没注意到的有用规则。"

这一变化对 Python 生态的影响是立竿见影的。Simon Willison 在实测中报告：他的三个大型项目（Datasette、sqlite-utils、LLM）CI 全部因新默认规则失败。sqlite-utils 项目发现了 1618 个错误，其中 1538 个被 `--fix --unsafe-fixes` 自动修复，剩余 80 个需要人工处理。

## 技术架构拆解

### 核心设计决策

1. **"零配置即高质量"**: 新用户的 `ruff check .` 默认就能捕获绝大多数常见问题，无需阅读文档手动启用规则。
2. **规则分类重组织的前奏**: 官方明确表示这与长期的 [rule recategorization](https://github.com/astral-sh/ruff/issues/1774) 目标紧密相关，未来规则分类体系将进一步调整。
3. **向后兼容降级路径**: 提供一行配置即可回退到旧默认集 `select = ["E4", "E7", "E9", "F"]`，降低迁移阻力。
4. **AI 编码助手友好**: lint 输出包含规则代码、问题描述、修复建议，天然适配 Codex/Claude Code 等 AI 编码工具。

### 与前版/竞品的关键差异

| 维度 | Ruff < v0.16 | Ruff v0.16.0 | Flake8 (参考) |
|------|-------------|-------------|---------------|
| 默认规则数 | 59 | 413 | ~50 (依赖插件) |
| 总规则数 | 968 | 968 | 取决于插件生态 |
| 默认哲学 | 最小集 + 手动扩展 | 最大集 + 按需收缩 | 最小集 |
| Markdown 格式化 | 不支持 | 原生支持 | 不支持 |
| 执行速度 | 极快 (Rust) | 极快 (Rust) | 慢 (Python) |
| AI 编码输出 | 完整诊断上下文 | 完整诊断上下文 + diff | 基础错误信息 |
| 回退路径 | N/A | 一行配置 | N/A |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Ruff v0.16.0 Pipeline                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  输入: Python 源码 / Markdown (.md) / Quarto (.qmd)       │
│       │                                                  │
│       ▼                                                  │
│  ┌──────────────┐    ┌──────────────┐                    │
│  │  Linter      │    │  Formatter   │                    │
│  │  413 rules   │    │  + Markdown  │                    │
│  │  (default)   │    │  code blocks │                    │
│  └──────┬───────┘    └──────┬───────┘                    │
│       │                   │                              │
│       ▼                   ▼                              │
│  ┌──────────────────────────────────┐                    │
│  │  Output: Diagnostic + Diff       │                    │
│  │  - Terminal (colored diff)       │                    │
│  │  - GitHub/GitLab annotation      │                    │
│  │  - JSON (null-safe fields)       │                    │
│  │  - AI Agent ready                │                    │
│  └──────────────────────────────────┘                    │
│       │                                                  │
│       ▼                                                  │
│  ┌──────────────┐    ┌──────────────┐                    │
│  │ Auto-fix     │    │ Manual fix   │                    │
│  │ --fix        │    │ AI-assisted  │                    │
│  │ --unsafe-fix │    │ (Codex/Code) │                    │
│  └──────────────┘    └──────────────┘                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 本次新增/稳定的关键功能

| 功能 | 类型 | 影响 |
|------|------|------|
| 默认规则 59→413 | Breaking | CI 可能大面积失败 |
| Markdown 代码块格式化 | New | README/文档中的 Python 代码自动格式化 |
| `ruff: ignore` 注释 | New | 替代 `# noqa` 的新抑制语法 |
| `--check` 输出显示 diff | New | CI 中直接看到修复差异 |
| `format --check` 支持 GitHub/GitLab 输出 | New | CI annotation 集成 |
| 12 条 Preview 规则稳定化 | Stabilization | 不再需要 `--preview` 标志 |
| JSON 输出 null-safe | Breaking | 字段可能为 null 而非空字符串 |

## 实用评估

### 什么场景值得用

- **新项目/新团队**: 零配置即可获得 413 条规则的质量保障，无需花时间研究该启用哪些规则。
- **CI 质量门禁升级**: 配合 `--output-format github` 可在 PR 中直接标注问题，提升 code review 效率。
- **AI 编码工作流**: Simon Willison 实测用 Codex (GPT-5.6 Sol high) 和 Claude Code (Opus 5) 自动修复了大部分问题——lint 输出包含了 AI 修复所需的全部上下文（规则代码、问题描述、位置信息）。
- **文档维护**: Markdown 代码块格式化让 README 和文档中的示例代码保持一致风格。

### 什么场景不值得用

- **遗留代码库无测试覆盖**: sqlite-utils 有 1618 个 lint 错误被扫出来，其中 80 个无法自动修复。如果没有测试覆盖，自动修复可能引入 bug。
- **依赖版本未锁定的 CI**: Simon 正是因为 unpinned 的 `"ruff"` dev 依赖导致 CI 突然失败。生产环境应 pin 版本。
- **不想处理 lint 噪音的团队**: 413 条规则中有些是风格偏好（如 N803 参数命名、PLR0917 位置参数过多），可能产生大量"技术上正确但实践中不重要"的报错。
- **Quarto/Notebook 用户需注意**: Markdown 格式化默认开启，可能需要 `extend-exclude` 排除特定文件。

### 迁移成本

| 项目规模 | 预估工作量 | 关键步骤 |
|----------|-----------|---------|
| 小项目 (<10k LOC) | 5-30 分钟 | `uvx ruff@latest check . --fix --unsafe-fixes` + 手动处理剩余 |
| 中型项目 (10k-100k LOC) | 1-4 小时 | 同上 + 审查 AI 自动修复 + 处理无法自动修复的 |
| 大型项目 (>100k LOC) | 半天-1 天 | 分批处理、可能需要临时 `extend-ignore` 过渡 |
| 不想处理 | 1 分钟 | 在 `pyproject.toml` 加 `select = ["E4", "E7", "E9", "F"]` 回退 |

## 对你的意义

如果你维护 Python 项目（特别是像 Ken 这样的 AI 应用开发者，项目通常包含 Datasette/LLM 等工具链）：

1. **立即行动**: 在 CI 中 pin  Ruff 版本，避免自动升级导致意外失败。
2. **渐进升级**: 先在本地跑 `uvx ruff@latest check .` 看看有多少问题，再用 `--fix --unsafe-fixes` 自动修复，最后人工审查剩余问题。
3. **AI 辅助修复**: 利用 Codex/Claude Code 等工具处理剩余问题——Ruff 的输出格式天然适配 AI 编码助手。
4. **长期收益**: 升级后，新代码默认享受 413 条规则保护，代码质量基线显著提升。

## 关键代码/配置片段

### 回退到旧默认规则集

```toml
# pyproject.toml
[tool.ruff.lint]
select = ["E4", "E7", "E9", "F"]
```

### 尝试新版本的单行命令

```bash
uvx ruff@latest check .
uvx ruff@latest check . --fix --unsafe-fixes
```

### 新 `ruff: ignore` 语法（替代 `# noqa`）

```python
import math  # ruff: ignore[F401]

# ruff: ignore[N803]
def foo(
    legacyArg1,
    legacyArg2,
): ...

# ruff: file-ignore[F401] Allow unused imports in this file
import foo
import bar
```

### Simon Willison 实测数据（sqlite-utils 项目）

```
Found 1618 errors (1538 fixed, 80 remaining)
```

典型无法自动修复的错误示例：

```
DTZ005 `datetime.datetime.now()` called without a `tz` argument
--> tests/test_duplicate.py:17:10
help: Pass a `datetime.timezone` object to the `tz` parameter

BLE001 Do not catch blind exception: `Exception`
--> tests/test_plugins.py:16:12
help: Use a more specific exception type

B018 Found useless attribute access
--> tests/test_update.py:46:5
help: Either assign it to a variable or remove it
```

---
[← Back to Deep Dives](./README.md)
