---
auto_generated: true
generated_at: "2026-04-20T06:48:24Z"
source_url: "https://code.claude.com/docs/en/routines"
signal_type: "significant_update"
---
# Claude Code Routines：云端自动化任务的新范式 (Claude Code Routines: A New Paradigm for Cloud-Automated Tasks)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-20
>
> **项目/工具**: Claude Code Routines
> **链接**: https://code.claude.com/docs/en/routines
> **核心定位**: 将 Claude Code 会话封装为可触发、可调度、可 API 调用的云端自动化任务单元

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Claude Code Routines 是把 Claude Code 会话打包成云端自动化任务的系统，支持定时/API/GitHub 事件三种触发方式
- **現在值得用嗎**：是 —— 如果你已有 Claude Code Pro/Max/Team/Enterprise 订阅且需要自动化重复性开发任务
- **適合場景**：定期代码审查、Alert 自动响应、部署验证、文档同步、多 SDK 同步更新
- **不適合場景**：需要本地文件访问的任务、高频触发（最低间隔 1 小时）、预算有限的个人项目
- **與 [本地 Scheduled Tasks] 核心差異**：Routines 在云端运行（笔记本关闭也能工作），本地任务依赖本地机器

## 是什么 / 解决什么问题

在 Routines 出现之前，Claude Code 用户只能通过 CLI 或 Web 界面手动启动会话。这意味着：
- 定期任务（如每周代码审查）需要人工记得执行
- 事件驱动任务（如 PR 自动审查）无法自动触发
- 会话无法在笔记本关闭后继续运行

Routines 解决了这些问题。它是一个**云端会话封装系统**：用户定义一次配置（prompt + 仓库 + 连接器 + 触发器），之后可以自动运行，无需人工干预。

核心突破在于**触发器系统**：
- **Scheduled**：按固定频率运行（每小时/每天/每周）
- **API**：通过 HTTP POST 触发，可集成到告警系统/部署流水线
- **GitHub**：响应 PR/Release 事件自动运行

这意味着 Claude Code 从一个交互式工具变成了一个**可编程的自动化引擎**。

## 技术架构拆解

### 核心设计决策

1. **云端执行模型**
   - Routines 在 Anthropic 管理的云基础设施上运行，而非用户本地机器
   - 优势：笔记本关闭也能工作；环境一致；不占用本地资源
   - 代价：无法访问本地文件；依赖网络；受云端配额限制

2. **触发器组合设计**
   - 单个 Routine 可绑定多个触发器（如：每晚运行 + PR 事件 + API 手动触发）
   - 每个匹配事件启动独立会话，会话之间不共享状态
   - 设计哲学：简单性优先于复杂编排

3. **权限隔离**
   - 默认只能推送到 `claude/` 前缀分支，防止意外修改主分支
   - 可针对特定仓库解除限制（需显式启用）
   - API Token 按 Routine 隔离，可单独撤销

4. **连接器继承**
   - 创建时默认包含所有已连接的 MCP 连接器
   - 用户需手动移除不需要的连接器（最小权限原则）
   - 连接器动作以用户身份执行（PR/Slack 消息显示为用户）

### 与前版/竞品的关键差异

| 维度 | 之前/Claude Code 本地任务 | Routines | GitHub Actions + AI |
|------|------------------------|----------|---------------------|
| 执行环境 | 本地机器 | 云端 | CI/CD Runner |
| 触发方式 | 手动/本地 cron | 定时/API/GitHub | 事件驱动 |
| 会话持续性 | 本地终端会话 | 云端会话（可网页查看） | 无状态执行 |
| 连接器支持 | 本地 MCP | 云端 MCP | 需自定义 Action |
| 配额计算 | 计入订阅用量 | 计入订阅用量 + 每日运行上限 | 单独计费 |
| 最低触发间隔 | 无限制 | 1 小时 | 无限制 |
| 本地文件访问 | 支持 | 不支持 | 支持（在 Runner 上） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Routines                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │  Scheduled   │    │     API      │    │   GitHub     │   │
│  │   Trigger    │    │   Trigger    │    │   Trigger    │   │
│  │  (cron 定时)  │    │  (HTTP POST) │    │ (PR/Release) │   │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘   │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                                │
│                    ┌────────▼────────┐                       │
│                    │  Routine Core   │                       │
│                    │  (云端会话引擎)   │                       │
│                    └────────┬────────┘                       │
│                             │                                │
│         ┌───────────────────┼───────────────────┐           │
│         │                   │                   │           │
│  ┌──────▼───────┐   ┌──────▼───────┐   ┌──────▼───────┐   │
│  │  Repository  │   │  Connectors  │   │  Environment │   │
│  │   (克隆代码)  │   │  (MCP 服务)   │   │  (网络/变量)  │   │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘   │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                                │
│                    ┌────────▼────────┐                       │
│                    │   Claude Code   │                       │
│                    │   Cloud Session │                       │
│                    └────────┬────────┘                       │
│                             │                                │
│              ┌──────────────┼──────────────┐                │
│              │              │              │                │
│       ┌──────▼──────┐ ┌─────▼──────┐ ┌────▼───────┐       │
│       │  Push PR    │ │ Slack 消息  │ │ 创建 Issue │       │
│       └─────────────┘ └────────────┘ └────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **定期代码审查**
   - 场景：团队希望每晚自动审查当天所有 PR
   - 配置：GitHub trigger (pull_request.opened) + 审查 checklist prompt
   - 价值：人类审查者只需关注设计，机械检查由 Routine 完成

2. **告警自动响应**
   - 场景：监控系统检测到错误阈值，需要自动分析并生成修复建议
   - 配置：API trigger + Sentry/监控工具 webhook
   - 价值：On-call 工程师收到的是带修复建议的 PR，而非空白终端

3. **部署验证**
   - 场景：生产部署后需要自动运行冒烟测试和日志扫描
   - 配置：API trigger（CD 流水线调用）+ 仓库访问
   - 价值：部署窗口内自动完成验证，无需人工等待

4. **文档同步**
   - 场景：API 变更后文档需要更新
   - 配置：Scheduled trigger（每周）+ 扫描合并的 PR
   - 价值：防止文档漂移，减少人工维护成本

5. **多 SDK 同步**
   - 场景：维护多个语言的 SDK，需要保持功能同步
   - 配置：GitHub trigger（PR merged）+ 自动移植代码
   - 价值：减少重复劳动，确保跨语言一致性

### 什么场景不值得用

1. **需要本地文件访问的任务**
   - 原因：Routines 在云端运行，无法访问本地文件系统
   - 替代：使用本地 Scheduled Tasks（`/loop` 或 Desktop 本地任务）

2. **高频触发任务（<1 小时）**
   - 原因：最低触发间隔为 1 小时
   - 替代：GitHub Actions 或自定义轮询脚本

3. **预算敏感的个人项目**
   - 原因：Routines 计入订阅用量，且有每日运行上限
   - 替代：手动运行或本地自动化

4. **需要人类审批的流程**
   - 原因：Routines 运行时没有审批提示（完全自动化）
   - 替代：本地会话或手动触发

### 迁移成本

从现有工作流迁移到 Routines：

| 原工作流 | 迁移步骤 | 预估工作量 |
|---------|---------|-----------|
| 手动定期审查 | 创建 Scheduled Routine，配置 prompt 和仓库 | 15 分钟 |
| 本地 cron + CLI | 改用 `/schedule` 命令创建云端任务 | 10 分钟 |
| GitHub Actions + AI | 重写为 Routine + API trigger | 1-2 小时 |
| 自定义脚本 | 封装为 Routine prompt + 连接器 | 30 分钟 -1 小时 |

关键依赖：
- 需要 Claude Code Pro/Max/Team/Enterprise 订阅
- 需要 GitHub 账号连接（用于仓库访问和 PR 创建）
- 需要配置 MCP 连接器（如需访问外部服务）

## 对你的意义

如果你已经在用 Claude Code 进行开发辅助，Routines 是一个自然的升级：

**应该立即试用**，如果：
- 你有重复性开发任务（定期审查、部署验证）
- 你希望告警响应更自动化
- 你维护多个仓库/SDK，需要同步更新

**可以观望**，如果：
- 你主要用 Claude Code 做一次性探索任务
- 你的工作流高度依赖本地文件
- 你对云端执行有安全顾虑

**建议跳过**，如果：
- 你使用免费版 Claude Code（Routines 需要付费订阅）
- 你需要分钟级高频触发

具体行动建议：
1. 从一个简单的 Scheduled Routine 开始（如每周文档检查）
2. 熟悉运行日志和配额消耗
3. 逐步添加 API/GitHub 触发器
4. 将成功的 Routine 模板化，复用到其他仓库

## 关键代码/配置片段

### API 触发示例

```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/trig_01ABCDEFGHJKLMNOPQRSTUVW/fire \
 -H "Authorization: Bearer sk-ant-oat01-xxxxx" \
 -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
 -H "anthropic-version: 2023-06-01" \
 -H "Content-Type: application/json" \
 -d '{"text": "Sentry alert SEN-4521 fired in prod. Stack trace attached."}'
```

响应：
```json
{
 "type": "routine_fire",
 "claude_code_session_id": "session_01HJKLMNOPQRSTUVWXYZ",
 "claude_code_session_url": "https://claude.ai/code/session_01HJKLMNOPQRSTUVWXYZ"
}
```

### CLI 创建定时任务

```bash
/schedule daily PR review at 9am
```

### GitHub 触发器过滤示例

- **仅审查 Auth 模块 PR**：base branch = `main`, head branch contains `auth-provider`
- **仅审查非草稿 PR**：is draft = `false`
- **仅审查带特定标签的 PR**：labels include `needs-backport`

### 分支推送限制

默认情况下，Routines 只能推送到 `claude/` 前缀分支：
```
✅ claude/fix-bug-123
✅ claude/auto-update-docs
❌ main
❌ develop
```

如需解除限制，需在创建 Routine 时显式启用 "Allow unrestricted branch pushes"。

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-003: 多 Agent 协作框架从实验走向工程实践 | 支持 | Routines 将 AI 编码能力封装为可编排的自动化单元，是 Agentic Engineering 的基础设施 |
| A-005: AI 工作流自动化成为企业 AI 最快增长场景 | 支持 | Routines 直接针对企业工作流自动化场景（告警响应、部署验证、代码审查） |

---

[← Back to Deep Dives](./README.md)
