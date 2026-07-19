---
auto_generated: true
generated_at: "2026-07-19T03:33:02Z"
source_url: "https://mindgard.ai/blog/cursor-0day-when-full-disclosure-becomes-the-only-protection-left"
signal_type: "significant_update"
---
# Cursor 0day：当全面披露成为唯一防线 (Cursor 0day: When Full Disclosure Becomes the Only Protection Left)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-19
>
> **项目/工具**: Cursor (AI 辅助开发环境)
> **链接**: https://mindgard.ai/blog/cursor-0day-when-full-disclosure-becomes-the-only-protection-left
> **核心定位**: AI 安全公司 Mindgard 对 Cursor IDE 发起全面漏洞披露——一个可远程执行任意代码的简单漏洞在 7 个月、197+ 个版本后仍未修复，暴露了 AI 编码工具安全治理的系统性真空。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Cursor 在 Windows 上加载项目时会自动执行工作区内的 git.exe，无需用户交互，导致任意代码执行。Mindgard 披露后 7 个月 Cursor 未修复也未回应。
- **現在值得用嗎**：看場景。个人开发者在非 Windows 或非企业环境可继续使用；**企业/受管 Windows 环境需立即评估风险**。
- **適合場景**：个人开发者在非敏感项目中使用；macOS/Linux 用户（此漏洞仅影响 Windows）
- **不適合場景**：企业 Windows 环境打开不受信任的第三方仓库；任何需要隔离执行环境的场景
- **與傳統 IDE 核心差異**：VS Code 等不会自动执行工作区内的可执行文件；Cursor 的 git 路径解析逻辑将工作区纳入了搜索范围

## 是什么 / 解决什么问题

Cursor 是目前最主流的 AI 辅助开发环境之一——700 万+活跃用户、100 万+日活、100 万+付费用户、5 万+企业使用，估值 600 亿美元。然而，这样一个体量和使用量的产品，存在一个极其简单却致命的漏洞。

**漏洞本质**：Cursor 在加载项目时，会在多个位置搜索 Git 二进制文件，其中一个位置就是工作区本身。如果攻击者在仓库根目录放置一个恶意的 `git.exe`，Cursor 会自动执行它——无需用户点击、无需弹窗确认、无需任何交互。

更严重的是，这不是一次性执行。Cursor 会在项目打开期间**反复执行**该二进制文件，持续产生任意代码执行。

该漏洞于 2025 年 12 月 15 日被 Mindgard 发现并报告，经过 7 个月、197+ 个新版本后，在最新测试版本（Cursor 3.2.16，2026-04-30 验证）中仍然存在。

## 技术架构拆解

### 核心设计决策

Cursor 将工作区纳入 Git 二进制搜索路径，初衷是为了支持项目级 Git 配置（例如企业内部的自定义 Git 构建或特定版本）。但这一设计决策带来了一个关键安全问题：**工作区内的可执行文件被当作系统级工具执行，且没有任何沙箱或签名验证机制**。

### 与 VS Code 等 IDE 的关键差异

| 维度 | VS Code | Cursor |
|------|---------|--------|
| 工作区可执行文件搜索 | 不搜索工作区内的可执行文件 | 搜索工作区根目录 |
| 自动执行行为 | 需用户显式触发 | 加载项目时自动执行，且反复执行 |
| 用户确认 | 无静默执行 | 无弹窗、无警告、无审批对话框 |
| 沙箱机制 | 有 Remote Container 等隔离方案 | 无工作区级沙箱 |
| 漏洞影响面 | 不适用 | 700 万+用户，Windows 平台 |

### 攻击路径 / 信息流图

```
┌─────────────────────────────────────────────────────┐
│  攻击者：在公开仓库根目录放置恶意 git.exe            │
│  （例如：GitHub 上的开源项目、企业 fork 的第三方库）  │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  开发者：在 Windows 上用 Cursor 打开该仓库           │
│  （正常操作，无任何异常感知）                         │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  Cursor.exe：加载项目 → 搜索 git 二进制              │
│  搜索路径包含工作区根目录 → 找到 git.exe → 执行       │
│  命令: git rev-parse --show-toplevel                 │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  恶意代码执行：以当前用户权限运行                      │
│  可窃取凭证、访问源码、安装后门、横向移动              │
│  Cursor 持续反复执行，窗口不断弹出                     │
└─────────────────────────────────────────────────────┘
```

### Process Monitor 日志（真实证据）

```
4:25:12.6209706 PM  Cursor.exe  54880  Process Create
  c:\Users\aport\Documents\Audits\cursor\test_repos\git_exec0001\git.exe
  SUCCESS  PID: 48972
  Command line: git rev-parse --show-toplevel
  Parent: "C:\Users\aport\AppData\Local\Programs\cursor\Cursor.exe"
```

## 披露流程为何失效

这是一个标准的协调披露（Coordinated Disclosure）失败的案例。Mindgard 的 7 个月时间线揭示了整个安全生态链路的断裂：

| 时间 | 事件 |
|------|------|
| 2025-12-15 | 漏洞发现并报告至 security-reports@cursor.com |
| 2025-12-18 | 跟进请求确认，无回复 |
| 2026-01-13 | LinkedIn 公开求助联系 |
| 2026-01-15 | Cursor CISO 回复：内部自动化故障导致 HackerOne 流程未触发 |
| 2026-01-15 | 通过 HackerOne 重新提交 |
| 2026-01-16 | 报告被标记为 "Informative / out of scope" |
| 2026-01-16 | Mindgard 挑战判定，报告重新打开 |
| 2026-01-20 | HackerOne 确认已送达 Cursor |
| 2026-02 ~ 04 | 多次请求更新，无回复 |
| 2026-06 | Mindgard 通知 HackerOne 将公开披露 |
| 2026-07-14 | 文章正式发布 |

**关键断裂点**：
1. **初始渠道失效**：Cursor 的 security.txt 指定的邮箱流程存在自动化故障
2. **Bug Bounty 误判**：首次判定为 "out of scope"，低估了严重性
3. **工程团队失联**：HackerOne 确认送达后，Cursor 工程团队 6 个月无回应
4. **持续发布不受影响**：70+ 个新版本发布，功能持续迭代，但漏洞未修复

## 实用评估

### 什么场景值得用

- **个人开发者在非敏感项目中使用**：不涉及企业凭证、不访问核心 IP 的场景下，风险可控
- **macOS/Linux 用户**：此漏洞利用的是 Windows 上的 `git.exe` 执行机制，macOS/Linux 使用 `git` 二进制，不受此路径解析逻辑影响
- **仅打开自己完全信任的仓库**：如果是个人项目或内部私有仓库，攻击面为零

### 什么场景不值得用

- **企业 Windows 环境打开第三方仓库**：这是最高风险场景。攻击者只需在 npm 包、开源库、fork 项目中植入 git.exe，即可在开发者打开项目时执行任意代码
- **Cursor 作为企业标准 IDE 但无 EDR 保护**：缺乏终端安全产品的企业环境，无法检测或阻断此类执行
- **依赖 Cursor 的 bug bounty 机制**：此案例表明，即使有 HackerOne 流程，也无法保证漏洞得到及时响应和修复

### 临时缓解措施

| 场景 | 措施 |
|------|------|
| 企业 Windows（受管） | 使用 AppLocker / Windows Defender Application Control 阻止 `%USERPROFILE%\source\repos\*\git.exe` 执行 |
| 企业 Windows（有 EDR） | 配置父进程感知规则，阻止 Cursor.exe 从工作区目录执行子进程 |
| 个人 Windows | 在隔离 VM / Windows Sandbox 中打开不受信任的仓库 |
| 所有场景 | 不要依赖文件哈希黑名单（攻击者二进制哈希可变） |

### 迁移成本

如果决定从 Cursor 迁移到 VS Code + Copilot 或其他替代方案：
- **配置迁移**：Cursor 的 AI 提示历史、自定义规则需重新配置（约 2-4 小时）
- **工作流适应**：Cursor 的 Chat + Edit 工作流与 VS Code + Copilot 有差异，适应期约 1-2 周
- **团队培训**：企业级迁移需考虑团队培训成本

## 对你的意义

这个漏洞对 Ken 的双重身份都有直接意义：

**作为 AI 应用开发者**：
- Cursor 是你日常使用的工具之一。如果你使用 Windows 或团队中有 Windows 开发者，需要立即评估此风险
- 这个案例揭示了一个更大的趋势：**AI 编码工具的安全治理滞后于产品增长速度**。Cursor 估值 600 亿美元，但安全流程连基本标准都未达到
- 建议关注 Mindgard 等安全公司的持续研究——他们正在系统性地测绘 AI 工具的安全边界

**作为研究者**：
- 这是 A-002（Agentic Coding 在初级任务达 80% 成功率）假设的**反面教材**——当 coding agent 获得文件系统执行权限时，安全风险的量级也在同步增长
- 值得追踪的方向：AI 编码工具的安全标准是否会成为企业采购的硬要求（类似 A-001 中 MCP 成为事实标准的逻辑）

## 关键代码/配置片段

### 漏洞触发路径（来自 Process Monitor 日志）

```
父进程: "C:\Users\aport\AppData\Local\Programs\cursor\Cursor.exe"
子进程: c:\Users\aport\Documents\Audits\cursor\test_repos\git_exec0001\git.exe
命令:   git rev-parse --show-toplevel
结果:   SUCCESS (PID: 48972)
```

Cursor 在加载项目时执行了 `git rev-parse --show-toplevel` 命令来定位 Git 仓库根目录，但搜索路径包含了工作区，导致恶意二进制被当作 Git 执行。

### 企业缓解配置示例（AppLocker 路径规则）

```
规则类型: 可执行规则
路径:     %USERPROFILE%\source\repos\*\*.exe
操作:     拒绝
说明:     阻止工作区根目录下的任何可执行文件被运行
```

> TODO: Cursor 是否已在此文章发布后修复？需持续关注 Cursor 官方 release notes 或安全公告。

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 挑战 | Cursor 700 万用户、600 亿估值，但存在 7 个月未修复的任意代码执行漏洞——agentic coding 工具的普及速度远超其安全成熟度，企业采纳可能因安全信任问题受阻 |

---
[← Back to Deep Dives](./README.md)
