# 架构分析：Skill 与 MCP 的边界与配合

在构建基于 Claude Code 的 Agent 时，理解 **Skill** 与 **MCP** 的分工是实现“10 倍效率”的前提。

## 1. 核心差异对比表

| 维度 | Claude Skill | MCP (Model Context Protocol) |
| :--- | :--- | :--- |
| **本质** | **工作流与专家指令集** | **标准化资源调用协议** |
| **作用目标** | 改变 AI 的“思考逻辑”和“操作步骤” | 扩展 AI 的“感知边界”和“执行能力” |
| **注入方式** | 通过 `.md` 或特定格式注入 Prompt 上下文 | 通过 JSON-RPC 协议连接远程/本地服务器 |
| **典型场景** | 代码重构规范、特定框架的最佳实践、SEO 检查流 | 读写数据库、连接 Notion、实时气象数据查询 |
| **优势** | 轻量、无需维护服务器、易于分享 | 跨模型通用、支持复杂权限控制、连接海量外部工具 |

## 2. 深度解析：Skill 是工作流的替代

正如 @wquguru 所言，“Skill 是工作流的替代”。
一个高质量的 Skill 包含：
- **Persona（人格）**：该领域的专家形象。
- **Rules（规则）**：必须遵守的工程规范。
- **Examples（示例）**：Few-shot 学习，告诉 AI 什么是“好”的产出。
- **Task Decomposition（任务拆解）**：面对复杂需求时，AI 应该分几步走。

## 3. 深度解析：MCP 是外部资源的入口

MCP 的强大在于它的**标准化**。
一旦一个资源（如 GitHub Repo, Slack Channel, SQL Database）被封装成 MCP Server，任何支持 MCP 协议的 Agent（Claude, Cursor, Z Code 等）都可以立即调用，无需重复编写逻辑。

## 4. 最佳实践：如何配合使用？

**场景示例：自动修复数据库性能问题**

1. **使用 MCP**：连接到数据库监控 Server，获取慢查询日志。
2. **使用 Skill**：注入一份“SQL 性能优化专家技能包”，里面包含针对该数据库版本的索引策略和重写规则。
3. **协同执行**：AI 通过 MCP 获取原始数据，根据 Skill 提供的逻辑进行分析，最后再通过 MCP 执行优化后的 SQL 命令。

---

**关联阅读：**
- [Claude Skill 市场：skillsmp 发现](../../blog/2025-12-24-skillsmp-claude-skills-marketplace.md)
- [CC Switch: 同时管理 Skill 与 MCP 的神器](../tools/cc-switch-guide.mdx)
