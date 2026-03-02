# Tmux 进阶指南：打造不间断的 Agent 工作流

Tmux 是终端里的“多任务管理器”，它能让你在单个终端窗口中管理多个会话、窗口和面板。

## 1. 为什么 10x 工程师离不开它？

- **持久性 (Persistence)**：Agent 跑长任务时，你随时可以离线，任务在后台继续。
- **并行编排 (Swarm Orchestration)**：
  - 一个面板跑 **Claude Code** (写代码)。
  - 一个面板跑 **Tail -f logs** (看实时错误)。
  - 一个面板跑 **Pytest** (验证修复)。
- **共享会话**：通过 Tmux 结对编程，多方实时看到同一个终端。

## 2. 核心概念

1.  **Session (会话)**：一组窗口的集合，通常代表一个项目。
2.  **Window (窗口)**：类似浏览器的标签页。
3.  **Pane (面板)**：窗口的切分（分屏）。

## 3. 常用“保命”快捷键 (Prefix = `Ctrl+b`)

| 动作 | 快捷键 |
| :--- | :--- |
| **新建会话** | `tmux new -s <name>` (命令行输入) |
| **分离会话** | `Prefix + d` (后台运行，最重要！) |
| **接入会话** | `tmux attach -t <name>` (命令行输入) |
| **垂直分屏** | `Prefix + %` |
| **水平分屏** | `Prefix + "` |
| **关闭面板** | `Prefix + x` |
| **切换面板** | `Prefix + 方向键` |

## 4. Agent 时代最佳实践

### 4.1 命名你的会话
不要用默认数字。为每个项目起名：
```bash
tmux new -s shop-refactor
```
### 4.2 离线分析模式
如果你让 Agent 处理 3.5GB 的数据分析，执行命令后：
1.  按下 `Ctrl+b` 然后 `d` (Detach)。
2.  关掉电脑去喝咖啡。
3.  回来执行 `tmux a`，结果已经为你准备好了。

---

**关联阅读：**
- [3.5GB 数据分析案例](../../blog/2025-12-25-agentic-data-mining-apple-health-3gb.md)
- [CC Switch: 切换 CLI 配置工具](./cc-switch-guide.mdx)
