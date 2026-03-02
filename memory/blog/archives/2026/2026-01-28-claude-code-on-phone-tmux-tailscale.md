# 陪女朋友逛街时，我带上了 Claude Code：手机 1:1 还原电脑端体验（tmux + Tailscale）

上周在浦东机场候机，旁边的人在刷抖音，我在用手机让 Claude Code 帮我改 bug。

（图片：机场候机时手机终端截图，建议放 `static/img/mobile-claude-code/airport.jpg`）

这事要从出发前说起。

要出去旅游，不能带电脑，但实在舍不得家里的 Claude Code。于是花了一晚上研究怎么能用手机也玩上它。

我对比了常见的 3 种方案，最后选了能在手机上 **1:1 还原电脑端 Claude Code 体验** 的版本。出门在外、地铁通勤、躺在沙发上看电视、甚至陪女朋友逛街等她试衣服的时候，都能随时掏出手机让 Claude 帮我干活。

今天把这套配置分享给大家。

---

## 三种方案要怎么选？

### 方案一：Claude 官方 App（云端沙盒）

直接用手机上的 Claude App 也能跑 Claude Code，但通常只能跑托管在 GitHub 上的项目：在云端沙盒环境跑，不支持你的本地项目；需要连真机调试的 iOS/Android 开发也不太友好。

这个方案我还没系统实测，等我补齐证据链后再单独写一篇。

### 方案二：tmux + Tailscale（推荐：1:1 还原电脑体验）

简单说就是：让手机远程连接到家里的电脑，然后操作电脑上正在跑的 Claude Code。

最大的优势是能 **1:1 还原电脑上的体验**。因为你控制的就是电脑上跑的那个终端，你在电脑上配置的 skills、commands、subagents 全都能用，跟在电脑上操作一模一样。

另一个优势是 **会话无缝接力**。你跟电脑上的 Claude Code 对话聊到一半，拿起手机就能接着聊，上下文不会丢；电脑终端开的所有会话，手机上都能继续。

而且不只是 Claude Code，Codex、Gemini CLI、OpenCode 这些 Agent 也都能用同一套方法跑。

门槛主要在：配置更复杂一点；手机屏幕小，tmux 多窗口/分屏的快捷键需要适应。但一旦上手，这基本就是移动端的最强形态。

### 方案三：Happy Coder（开箱即用的移动端客户端）

一个专门为手机设计的 Claude Code 客户端（开源），会话支持端到端加密，GitHub 上有不少关注。

如果你只是想随时查看进度、补一句指令、快速做一个不依赖复杂本地配置的任务，它完全够用；但多会话时连接稳定性可能不如 tmux 方案。

---

## 我的选择：tmux + Tailscale

旅游的时候我实测了一下，体验比想象的好很多，我还发到好几个 AI 群里炫耀。

在机场候机的时候，让 Claude 帮我重构一个组件，等登机的时候已经写完了。飞机上没网，但落地后连回去一看，发现 Claude 已经把剩下的活干完了。

最有意思的是逛街的时候。女朋友在试衣服，我在外面等，顺手让 Claude 改了个 bug。她出来问我在干嘛，我说在回消息。

（图片：逛街/试衣间外手机终端截图，建议放 `static/img/mobile-claude-code/mall.jpg`）

配合 Jump Desktop、ToDesk 这类远程桌面软件，还能直接看到改完代码之后 build 出来的效果。网站也好，App 也好，都能在手机上预览。

（图片：远程桌面预览效果截图，建议放 `static/img/mobile-claude-code/remote-desktop.jpg`）

---

## 实测：1:1 还原电脑端体验

配置好之后，我特意验证了一下：手机上的体验和电脑上完全一致——

- 电脑上配置的 `/commit` 命令
- 自定义 subagent
- 终端脚本指令
- 官方/中转站的 Claude 接口

在手机上都是一样使用。

（图片：Termius + tmux + Claude Code 会话截图，建议放 `static/img/mobile-claude-code/cli.jpg`）

---

## 详细配置教程（tmux + Tailscale）


这里先给一份可复现的快速步骤。

### 一、准备工作

1) **Mac 开启远程登录（SSH）**  
系统设置 → 通用 → 共享 → 打开「远程登录」

2) **安装 tmux**

```bash
brew install tmux
```

3) **手机装 SSH 客户端 Termius**  
iOS / Android 都有，免费版一般够用。

4) **安装 Tailscale（电脑 + 手机）**  
两端登录同一个账号，外网也能像内网一样访问家里的电脑。

注：iOS 的“魔法通道”一次只能开一个，Tailscale 会占用它；需要时切一下即可。

### 二、详细步骤

**Step 1：在电脑上创建一个 tmux 会话**

```bash
tmux new -s claude
```

然后在这个会话里启动 Claude Code（或其它 Agent）。

**Step 2：记下电脑的地址**

- 同一 WiFi：找 `192.168.x.x`
- 外网：用 Tailscale 分配的地址（在 Tailscale App 里能看到）

**Step 3：手机连接**

用 Termius 新建连接（地址/IP、用户名、密码/密钥），连上后：

```bash
tmux attach -t claude
```

搞定。你现在在手机上看到的，就是电脑上正在跑的 Claude Code。

---

## 手机体验优化（强烈建议）

### 1) 触控滑动滚动（tmux）

在电脑上创建/编辑 `~/.tmux.conf`，加入：

```bash
set -g mouse on
set -sg escape-time 0
```

然后重新加载：

```bash
tmux source-file ~/.tmux.conf
```

### 2) 多会话切换

Termius 辅助键盘输入 tmux 快捷键：

- 新建窗口：`Ctrl-b` 然后按 `c`
- 切换窗口：`Ctrl-b` 然后按 `n`（下一个）或 `p`（上一个）

### 3) 电脑防睡眠（否则出门连不上）

```bash
caffeinate -dimsu
```

---

## 小 Tips

1) **语音输入**：在手机上打 prompt 太慢，就用语音输入法（识别英文术语很省心）。  
2) **所有终端任务都放 tmux**：Claude Code / Codex / 普通开发任务都放进去，手机随时接管。  
3) **iTerm2 + tmux 进阶**：多窗口/分屏并行跑多个任务，吞吐直接上去。  

---

> 结论：tmux 方案的本质是——手机只是一个窗口，真正跑的是家里那台电脑。所以你电脑上的一切配置，手机端都天然复用。

