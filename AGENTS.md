# AGENTS.md

系统治理文件 — 适用于 Claude Code、Codex、Cursor 等 AI 编码智能体

> **最高准则：** 在开始任何工作前，务必阅读并严格遵守 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)。

---

## 1. 系统心智模型

**Agent-Playbook = AI App 生态的工程级记忆库**

本仓库不是笔记集，而是一个**有结构的知识操作系统**，服务于对 AI 应用生态的持续跟踪与工程化理解。

三层架构：

```
landscape（生态地图）
    ↓ 知道有什么工具、谁在主导方向
theory（知识骨架）
    ↓ 理解底层架构、框架、方法论
playbooks（执行手册）
    ↓ 知道怎么做、有哪些模板和用例
```

**memory/ 目录由 Pulsar 流水线自动写入，智能体绝对不得触碰。**

---

## 2. 文件写权限矩阵

| 路径 | 操作 | 规则说明 |
|------|------|---------|
| `landscape/app-index.md` | **仅追加** | 禁止删除条目、禁止重排顺序、禁止批量重写 |
| `landscape/technology-landscape.md` | 完整编辑 | 可自由增改，保持 section 结构一致 |
| `landscape/influencers.mdx` | 完整编辑 | 可自由增改，保持人物卡片格式 |
| `theory/frameworks/*.mdx` | 新建 / 编辑 | 遵守 §6 写作规范 |
| `theory/architecture/*.mdx` | 新建 / 编辑 | 遵守 §6 写作规范 |
| `theory/methodology/**` | 新建 / 编辑 | 遵守 §6 写作规范 |
| `theory/deep-dive/*.md` | **Pulsar 自动写入** | 周二/四/六自动生成；同 slug 同天允许覆盖；不得手动删除 |
| `playbooks/tools/*.md` | 新建 / 编辑 | 保持 playbook 模板格式 |
| `playbooks/prompts/*.mdx` | 新建 / 编辑 | 包含示例输入输出 |
| `playbooks/use-cases/*.md` | 新建 / 编辑 | 附真实场景和结果 |
| `playbooks/onboarding/*.md` | 新建 / 编辑 | 面向新成员，步骤清晰 |
| `playbooks/security/**` | 新建 / 编辑 | 安全相关，需注明风险等级 |
| `playbooks/templates/**` | 新建 / 编辑 | 通用模板，注释充分 |
| `scaffolds/` | **仅新建** | 不得修改已有 scaffold，避免破坏下游依赖 |
| `reports/biweekly/` | 新建文件 | 文件名含日期范围；同一天内允许覆盖同名文件 |
| `reports/cross-domain/` | 新建文件 | Pulsar 跨域规则引擎自动写入 |
| `memory/` | ❌ 禁止 | Pulsar 流水线自动生成，任何手动写入均会被覆盖 |
| `monitoring/` | ❌ 禁止 | 监控配置由运维人员管理，智能体不得修改 |

---

## 3. Commit 消息格式

所有提交必须使用下表前缀，保持日志可机器解析。

| 场景 | 格式 | 示例 |
|------|------|------|
| 每日精选 | `📄 daily pick: YYYY-MM-DD (+N apps)` | `📄 daily pick: 2026-03-02 (+3 apps)` |
| 架构深潜 | `📝 deep dive: {slug}` | `📝 deep dive: mcp-tool-use-patterns` |
| 工具注册 | `🔧 app index: add {tool-name}` | `🔧 app index: add Cursor` |
| 双周报告 | `📈 report: YYYY-MM-DD ~ YYYY-MM-DD` | `📈 report: 2026-02-17 ~ 2026-03-02` |
| 理论新增 | `📚 theory: add {framework-name}` | `📚 theory: add ReAct-framework` |
| Playbook 更新 | `🛠️ playbook: update {guide-name}` | `🛠️ playbook: update prompt-chaining` |
| Scaffold 新增 | `🗂️ scaffold: add {template-name}` | `🗂️ scaffold: add agent-eval-template` |

---

## 4. 标注系统

### 重要性标注

| 标注 | 含义 | 使用场景 |
|------|------|---------|
| ⚡ | 战略级 — 影响方向、架构选择、行业范式 | 重大模型发布、范式转变、顶级论文 |
| 🔧 | 可操作 — 有实际工程价值，可立即应用 | 新工具、API 变更、最佳实践更新 |
| 📖 | 参考 — 背景知识，暂不需要行动 | 综述、历史回顾、补充读物 |
| ❌ | 不收录 — 噪音、重复、无关信息 | 营销内容、低质转载 |

### 方向标注

| 标注 | 含义 |
|------|------|
| 🎯 | 主方向 — 当前核心跟踪领域 |
| [方向名] | 专项追踪团队标签（如 `[coding-agent]`、`[multimodal]`） |
| ✍️ | 手动添加 — 非流水线自动录入，人工判断 |

---

## 5. landscape/app-index.md 追加格式

每个新工具条目严格遵循以下格式，**追加在文件末尾**：

```
| [Tool Name](URL) | ⚡/🔧/📖 | 🎯/[方向名] | 一句话简介 | YYYY-MM-DD |
```

示例：

```
| [Cursor](https://cursor.com) | ⚡ | 🎯 | 意图驱动的 AI 编程 IDE，Karpathy 推荐范式代表 | 2026-03-02 |
| [Lovable](https://lovable.dev) | 🔧 | [vibe-coding] | 自然语言生成全栈 Web App，零代码门槛 | 2026-03-02 |
```

### 铁律（违反将导致数据损坏）

- **只追加，不删除** — 已录入工具即使停服也保留条目，加注 `[停服 YYYY-MM-DD]`
- **不重排** — 顺序反映录入时间，是历史证据
- **不批量重写** — 每次修改最多新增一批，不得替换现有行
- **格式一致** — 列数、分隔符、标注符号必须与现有条目完全一致

---

## 6. theory/ 写作规范

适用于 `theory/frameworks/`、`theory/architecture/`、`theory/methodology/` 下的新文件。

### 文件头部

```markdown
# 中文标题 (English Title)

> **来源**: [论文/文章标题](URL)
> **日期**: YYYY-MM-DD
> **定位**: 一句话说明该框架/架构解决什么问题
```

### 强制开场：X-Ray 开场（2-3 句）

每篇 theory 文档必须以 **X-Ray 开场** 作为正文第一段，回答三个问题：

1. 它在解决什么问题？
2. 它发现/提出了什么？
3. 为什么对 AI 应用工程师重要？

### 推荐 Section 结构

| Section | 说明 | 是否必须 |
|---------|------|---------|
| 系统对比表 | 与同类方案横向对比（至少 3 列） | 推荐 |
| 核心原理 | 关键算法或设计原则，可用伪代码 | 视内容 |
| 工程实战 | 具体实现步骤、配置示例、踩坑记录 | 强烈推荐 |
| 失效模式 | 在哪些场景下该方案会失效 | 推荐 |
| 相关项目 | 引用 `landscape/app-index.md` 中的工具 | 推荐 |

### 语言规范

- **主语言**：中文；专有名词保留英文原文
- **引用**：每篇至少一个外部链接，指向原始论文或官方文档
- **长度**：超过 800 行时考虑拆分子文件

---

## 7. reports/biweekly/ 格式

文件命名：`YYYY-MM-DD_YYYY-MM-DD.md`（起止日期）

```markdown
# Agent Playbook 双周报 | YYYY-MM-DD ~ YYYY-MM-DD

## 本期要点
- 要点一（一句话，附标注 ⚡/🔧）
- 要点二

## AI 工具动态

## 架构深潜

## 社区情报

## 范式观察

## 预测与验证

| 预测 | 状态 | 说明 |
|------|------|------|
| （上期预测内容） | ✅/❌/⏳ | 验证依据 |

---
[返回索引](../README.md)
```

**写作要求：**

- `本期要点` 不超过 5 条，每条一句话，直接给结论
- `预测与验证` 必须包含上期所有预测的状态更新
- 不写「本期暂无」，如某 section 确实无内容则整体省略

---

## 8. 查询提示

| 我想知道… | 去哪里找 |
|---------|---------|
| 某类工具有哪些？ | `landscape/app-index.md` |
| 某个架构模式的原理？ | `theory/frameworks/` 或 `theory/architecture/` |
| 某种方法论如何落地？ | `theory/methodology/` |
| 某个工具怎么用？ | `playbooks/tools/` |
| 如何写高质量 Prompt？ | `playbooks/prompts/` |
| 有没有现成模板？ | `playbooks/templates/` 或 `scaffolds/` |
| 某个场景的完整案例？ | `playbooks/use-cases/` |
| 过去两周发生了什么？ | `reports/biweekly/` — 找最新日期文件 |
| 今日 AI 精选？ | `memory/blog/ai-daily-pick/` — 只读 |
| 谁在主导 AI App 方向？ | `landscape/influencers.mdx` |
| 有没有安全注意事项？ | `playbooks/security/` |

---

## 9. 错误处理

| 错误 | 原因 | 处理方式 |
|------|------|---------|
| `409 Conflict`（auto-generated 文件） | Pulsar 流水线并发写入 | 重试一次；若仍冲突则跳过 |
| `401 / 403` | `GITHUB_TOKEN` 缺失或过期 | 检查环境变量；需 `contents:write` 权限 |
| `app-index.md` 格式异常 | 历史条目格式不一致 | 保留现有内容，在最后一个合法条目之后追加 |
| `reports/biweekly/` 文件已存在 | 同日重复运行 | 同一天内允许覆盖；跨天不得覆盖已有报告 |
| `memory/` 写入被拒 | 流水线保护 | 预期行为；停止写入，记录日志 |

---

## 10. 快速核查清单

提交前确认：

- [ ] commit 消息格式符合 §3 表格
- [ ] `landscape/app-index.md` 若有改动，是追加而非修改现有行
- [ ] `memory/` 目录未被触碰
- [ ] `monitoring/` 目录未被触碰
- [ ] theory 文档包含 X-Ray 开场（§6）
- [ ] 双周报包含预测与验证 section（§7）

---

*本文件由 Pulsar 系统维护，修订需同步更新 [Pulsar-KenVersion](https://github.com/sou350121/Pulsar-KenVersion) 中的对应模板。*
