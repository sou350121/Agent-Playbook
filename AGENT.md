# AGENT.md（给 Claude Code / Codex / Cursor 等编码代理）

> **最高准则：** 在开始任何工作前，务必阅读并严格遵守 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)。
>
> **目标：** 让“编码代理”在本仓库里能**快速理解项目结构**、**按规范产出内容**、并能在需要时做**本地验证**（本仓库不承诺维护部署流水线）。

## 1. 这个项目是什么？

**Agent 经验库（Agent Experience Library）**：面向 GitHub 直读的知识库（Docusaurus 组织方式），用来把 X/Twitter 的碎片信号**提纯**成可执行的方法论与工程导轨，沉淀：

- Agent 使用方法（Cursor / Claude Code / Codex / Gemini CLI）
- 模型对比与实测（含复现要素）
- 能力边界与失败模式
- Prompt（含 UI/UX Prompt + 截图证据）
- 案例复盘（可复现）

核心专项（少而精）：

- **小白通关手册**：[`docs/beginner-guide/README.md`](./docs/beginner-guide/README.md)
- **架构治理（物理导轨/逻辑契约）**：[`docs/architecture-governance/README.mdx`](./docs/architecture-governance/README.mdx)
- **Agent 管理学（Playbook/编队/门禁/回滚）**：[`docs/agent-management/README.md`](./docs/agent-management/README.md)

## 2. 推荐阅读入口（按人群）

- **总入口 / 学习路径**：[`docs/README.md`](./docs/README.md)
- **新手**：[`docs/beginner-guide/README.md`](./docs/beginner-guide/README.md)
- **工程交付链路（Spec→PR）**：[`docs/agent-management/02-playbook-spec-to-pr.mdx`](./docs/agent-management/02-playbook-spec-to-pr.mdx)
- **大项目不熵增（物理导轨）**：[`docs/architecture-governance/01-physical-rails.mdx`](./docs/architecture-governance/01-physical-rails.mdx)
- **Hybrid DocOps + AgentOps**：[`docs/planning/hybrid-docops-agentops-best-practices.mdx`](./docs/planning/hybrid-docops-agentops-best-practices.mdx)
- **DNA 级交付标准**：[`docs/tools/agent-dna-workflow.mdx`](./docs/tools/agent-dna-workflow.mdx)

## 3. 目录拓扑（Directory Map）

仓库主入口：

- **文档（知识提纯）**：`docs/`
- **博客（日更动态）**：`blog/`
- **静态资源（截图/图片）**：`static/img/`
- **可复制脚手架**：`starter-kits/`

`docs/` 子目录（写作落点的“物理导轨”）：

- `beginner-guide/`：小白通关手册（从 0 到 1）
- `planning/`：心智模型/方法论/协作范式
- `architecture-governance/`：架构治理（物理导轨、逻辑契约、流程治理、自动化执法、ADR）
- `agent-management/`：Agent 管理（角色拆解、Spec→PR、多 Agent 编队、风险与回滚、Ralph Loop）
- `tools/`：工具链与工作流（NotebookLM、Docker、Kiro、Eigent、Cursor 方法论等）
- `prompt-library/`：可复用 Prompt 卡片与哲学
- `case-studies/`：案例复盘（证据链 + 可复现）
- `capabilities/`：能力边界与关键概念（穿透黑话）
- `model-comparisons/`：模型对比实测（按模板写）
- `security/`：安全与防御（环境隔离、攻击面）
- `resources/`：资源名录（情报源/影响力图谱）

`starter-kits/`（复用/迁移用）：

- `starter-kits/docops-agentops/`：DocOps + AgentOps 脚手架（含 `stories/`、`prompts/`、`sessions/` 示例与校验脚本）
- `starter-kits/aliyun-vibe-coding/`：云上部署模板与实践指南（含 Terraform / Docker 模板）

## 4. 工作流程与规范（给代理的“执行导轨”）

- **真实性与噪音**：不确定的事实必须标注“待核实”，严禁编造（详见 [AGENT_CONSTITUTION.md](./AGENT_CONSTITUTION.md)）。
- **Blog→Docs 的升华**：Blog 记录“动态”，Docs 沉淀“方法论”；严禁只写 Blog 不提炼 Docs。
- **Spec-driven（先 Proposal，后施工）**：
  - 涉及复杂改动/新模块：先把需求与验收写清，再实现。
  - 参考：[`docs/agent-management/02-playbook-spec-to-pr.mdx`](./docs/agent-management/02-playbook-spec-to-pr.mdx)
- **架构治理优先**：任何新增内容/目录调整，先确保符合物理导轨与逻辑契约。
  - 参考：[`docs/architecture-governance/README.mdx`](./docs/architecture-governance/README.mdx)

## 5. 内容产出规范（写到哪里 + 怎么写）

### 5.1 Blog（日更动态）

- **目录**：`blog/`
- **命名**：`YYYY-MM-DD-title.md`
- **用途**：记录快讯/观察/碎片信号（必须包含“启示 + 原始链接/证据”）

### 5.2 Docs（结构化沉淀）

- **目录**：`docs/`（按上面的 Directory Map 选择子目录）
- **强烈建议用模板**：`docs/_templates/`（见 [`docs/_templates/README.md`](./docs/_templates/README.md)）
  - `model-comparison.mdx`：模型对比
  - `workflow.mdx`：工作流
  - `prompt-card.mdx`：Prompt 卡片
  - `prompt-vcs.mdx`：Prompt 版本控制
  - `failure-log.mdx`：失败路径记录
  - `case-study.mdx`：案例复盘
- **命名规范**：英文小写 + 连字符（例如 `cursor-refactor-workflow.mdx`；见模板说明）

### 5.3 Prompt 版本控制（VCS）怎么落地？

本仓库根目录**不强制**存在 `stories/ prompts/ sessions/`；如要在真实工程中落地 Prompt VCS，请直接复用脚手架：

- 参考：`starter-kits/docops-agentops/`（包含目录结构、示例 Story、以及校验脚本）

## 6. 图片/截图怎么放？

- **存储目录**：`static/img/<topic>/...`（例如 `static/img/prompts/`、`static/img/comparisons/`）
- **引用方式**：在 MD/MDX 中用相对路径引用（见 [`docs/_templates/README.md`](./docs/_templates/README.md)）

## 7. GitHub 直读模式约定

- 以目录结构组织内容：`docs/`、`blog/`、`static/img/`
- `_category_.json` 等文件保留不影响 GitHub 阅读（用于 Docusaurus/侧边栏组织）

## 8. 提交规范

- 小步提交，commit message 参考：
  - `feat: ...`（新增文章/文档）
  - `docs: ...`（纯文档修订）
  - `fix: ...`（修复构建/配置问题）

## 9. 快速链接（常用入口）

- 根 README：[`README.md`](./README.md)
- 文档总入口：[`docs/README.md`](./docs/README.md)
- 小白通关手册：[`docs/beginner-guide/README.md`](./docs/beginner-guide/README.md)
- 架构治理：[`docs/architecture-governance/README.mdx`](./docs/architecture-governance/README.mdx)
- Agent 管理学：[`docs/agent-management/README.md`](./docs/agent-management/README.md)
- Spec→PR Playbook：[`docs/agent-management/02-playbook-spec-to-pr.mdx`](./docs/agent-management/02-playbook-spec-to-pr.mdx)
- Prompt 索引（开发全生命周期 Cheat Sheet）：[`docs/prompt-library/dev-lifecycle-cheat-sheet.mdx`](./docs/prompt-library/dev-lifecycle-cheat-sheet.mdx)
- UI/UX 增强工具：[`docs/tools/ui-ux-design-enhancement.mdx`](./docs/tools/ui-ux-design-enhancement.mdx)
- 模板目录：[`docs/_templates/`](./docs/_templates/)
