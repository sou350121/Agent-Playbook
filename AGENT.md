# AGENT.md（给 Claude Code / Codex / Cursor 等编码代理）

> **最高准则：** 在开始任何工作前，务必阅读并严格遵守 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)。

> 目标：让“编码代理”在这个仓库里能**快速理解项目结构**、**按规范产出内容**、并**正确构建/部署** GitHub Pages。

## 1. 这个项目是什么？

**Agent 经验库（Agent Experience Library）**：一个用 Docusaurus 搭建的 GitHub Pages 知识库，用来沉淀：
- Agent 使用方法（Cursor / Claude Code / Codex / Gemini CLI）
- 模型对比与实测（如 GPT-5.2 vs Claude Opus 4.5）
- 能力边界与失败模式
- Prompt（含 UI/UX Prompt + 截图）
- 案例复盘（可复现）

仓库入口：
- **文档**：`docs/`
- **博客（日更动态）**：`blog/`
- **小白手册**：`docs/beginner-guide/`
- **静态资源（截图/图片）**：`static/img/`

## 2. 内容写到哪里？

### 2.1 日更动态（Blog）
- **目录**：`blog/`
- **命名**：`YYYY-MM-DD-title.md`
- **用途**：记录 X（Twitter）看到的瞬间动态、技术快讯或碎片化观察。
- **约束**：Blog 是“动态”，不是“真相”。

### 2.2 深度文档（Docs）
- **目录**：`docs/`
- **分类**：
  - `beginner-guide/`：小白通关手册（降维版入门知识）
  - `planning/`：框架、心智模型、方法论
  - `model-comparisons/`：模型对比（按模板写）
  - `tools/`：工具链/工作流（Cursor、MCP、Claude Code...）
  - `prompt-library/`：Prompt 卡片（可复用）
  - `case-studies/`：案例复盘（有证据、可复现）
  - `capabilities/`：能力边界、关键概念架构（RAG、zkML...）
  - `architecture-governance/`：架构治理、物理导轨与契约

### 2.3 模板（强烈建议使用）
模板在：`docs/_templates/`
- `model-comparison.mdx`
- `workflow.mdx`
- `prompt-card.mdx`
- `case-study.mdx`
- `prompt-vcs.mdx`（Prompt 版本控制模板）
- `failure-log.mdx`（失败路径记录模板）

模板说明：`docs/_templates/README.md`

### 2.4 Prompt 版本控制 (VCS)
为了解决“只看代码 diff 无法理解 AI 意图”的问题，建议在进行复杂任务时采用以下目录结构：

```text
stories/         # 需求故事单元
  S-xxxx-title.md
prompts/         # 核心提示词库
  S-xxxx.md
sessions/        # 过程记录与失败路径
  S-xxxx/
    2025-xx-xx-model-name.md
    failures.md
```

- **`prompts/S-xxxx.md`**：记录最终生效的提示词、关键上下文和模型配置。
- **`sessions/S-xxxx/failures.md`**：记录“此路不通”的尝试，防止 AI 重蹈覆辙。

## 3. 图片/截图怎么放？

- **存储目录**：`static/img/<topic>/...`
  - 例如：`static/img/prompts/`、`static/img/comparisons/`
- **引用方式**：在 MDX 中用相对路径引用（参考模板 README）。

## 4. GitHub 直读模式约定

- 以目录结构组织内容：`docs/`、`blog/`、`static/img/`。
- `_category_.json` 等文件保留不影响 GitHub 阅读（用于历史兼容/未来可选导出）。

## 5. 贡献与交付（给代理执行）

- 目标是让 PR **可读、可审、可追溯**：Story/Prompt/Failures/验证命令要齐全。
- 不再维护 Docusaurus/GitHub Pages 构建与部署流程。

## 7. 工作约定（非常重要）

### 7.1 写作与事实性
- **简体中文为主**（必要时可保留英文术语）
- 对比/结论尽量可复现：模型版本、Prompt、关键输入、截图证据
- 避免“空泛结论”，写清楚：适用条件、失败模式、替代方案

### 7.2 产出模式：方法论提纯
- **Blog 记录动态**：快速响应 X/Twitter 的技术快讯。
- **Docs 沉淀方法论**：严禁只发 Blog 而不更新 Docs。必须将动态中的规律提纯为 `docs/` 下的结构化文档。
- **Spec-driven 执行**：涉及复杂改动或新功能，必须遵循“先 Proposal，后施工”的原则。

### 7.3 提交规范
- 小步提交，commit message 参考：
  - `feat: ...`（新增文章/文档）
  - `docs: ...`（纯文档修订）
  - `fix: ...`（修复构建/配置问题）

## 8. 快速链接

- 根 README：`README.md`
- 贡献指南：`CONTRIBUTING.md`
- Prompt 索引（开发全生命周期 Cheat Sheet）：`docs/prompt-library/dev-lifecycle-cheat-sheet.mdx`
- 模板目录：`docs/_templates/`
