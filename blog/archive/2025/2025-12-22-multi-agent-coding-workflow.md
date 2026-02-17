---
slug: multi-agent-coding-workflow
title: 多 Agent AI Coding 工作流：从需求到 PR 的闭环
authors: [sou350121]
tags: [workflow, agents, github, automation]
---

jolestar 分享了一套多 Agent 的 AI Coding 流程，核心是把角色拆开，让上下文一直保持清晰。

### 核心发现
- **需求 Agent（PM/架构师）**：只负责澄清需求、拆分任务并写成可执行的 GitHub Issue；复杂功能拆成子 Issue。
- **Coder Agent**：直接吃 Issue 完成实现并提交 PR，过程中尽量避免二次确认打断节奏。
- **Reviewer Agent**：对 PR 做 Review，把问题清单回传给 Coder 修复，形成闭环。
- **协作痛点**：权限安全、Review 评论粒度不足、Review Comments 拉取易被截断。
- **自动化方向**：用容器跑 Coder Agent，再配合 GitHub Actions 固化流程。

<!-- truncate -->

### 给实践者的启示
1. **角色分离比模型更关键**：让不同 Agent 保持职责边界，比单 Agent 堆上下文更稳定。
2. **流程瓶颈在协作接口**：权限、Review 评论与 API 限制决定了自动化的上限。

[原文链接参考](https://x.com/jolestar)
