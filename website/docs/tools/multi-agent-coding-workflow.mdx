# 多 Agent AI Coding 工作流：PM/架构师 + Coder + Reviewer

## 目标
建立“需求澄清 -> Issue -> PR -> Review -> 修复 -> 合并”的闭环，并让每个 Agent 都只持有最小必要上下文。

## 适用场景
- 需求复杂、需要多轮澄清
- 需要并行推进多个 Issue
- 需要稳定的代码审查闭环

## 角色分工
- **需求 Agent（PM/架构师）**：只做需求澄清、架构方案与任务拆分，产出可执行的 GitHub Issue。
- **Coder Agent**：只基于 Issue 实现功能并提交 PR，不主动扩展范围。
- **Reviewer Agent**：对 PR 做审查并输出可定位的修改意见，推动 Coder 修复。

## 流程步骤

### 1. 需求澄清 -> Issue
- 与需求 Agent 对齐目标、边界、验收标准。
- 复杂功能拆成多个子 Issue，显式标注依赖关系。

### 2. Issue -> PR
- Coder Agent 仅根据 Issue 产出实现，输出 PR 和变更说明。
- 权限尽量一次性授予，避免频繁中断影响节奏。

### 3. Review -> 修复
- Reviewer Agent 使用 GitHub inline comment 输出可定位意见。
- 如果无法 inline，则必须附上 `文件路径:行号` 的精确指引。

### 4. 合并与并行
- 评审通过后合并，进入下一轮。
- 是否并行取决于 Issue 之间是否存在依赖。

## 常见坑与避雷
- **权限焦虑**：权限过大容易误操作。解决方案是用容器隔离 Coder Agent，并限制到仓库范围。
- **Review 粒度不足**：评论只给结论会阻塞修复。解决方案是强制输出 inline comment 或文件行号。
- **评论拉取被截断**：MCP/接口返回过长会丢失信息。解决方案是分页拉取并分段总结。

## 自动化方向
- 用容器封装 Coder Agent，减少对主机权限的担忧。
- 用 GitHub Actions 驱动 Issue -> PR -> Review -> 修复的流水线。
- Review Comments 采用分页抓取，避免上下文被截断。

## 提效检查清单
- [ ] Issue 包含验收标准与边界条件
- [ ] PR 说明包含改动范围与运行命令
- [ ] Review 意见可定位到文件与行号
- [ ] 修复后自动触发再次 Review

## 输出模板（示例）
```markdown
## Issue 概述
- 目标：
- 验收标准：
- 边界/限制：
- 依赖关系：

## Review 输出
- 文件路径:行号 - 问题描述
- 文件路径:行号 - 修改建议
```
