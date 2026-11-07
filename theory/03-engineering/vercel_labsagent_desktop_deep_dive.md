---
auto_generated: true
generated_at: "2026-11-07T08:00:43Z"
source_url: "https://github.com/vercel-labs/agent-desktop/releases/tag/v1.2.0"
signal_type: "significant_update"
---
# Agent Desktop：用无障碍树替代截图，让桌面操作变成可重试的确定性动作 (agent-desktop v1.2.0)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-07
>
> **项目/工具**: vercel-labs / agent-desktop
> **链接**: https://github.com/vercel-labs/agent-desktop/releases/tag/v1.2.0
> **核心定位**: 一个不带模型的 computer use CLI + C 库——它只负责把桌面应用的界面读成 JSON（每个可交互元素一个稳定 ref），由你的 agent 自己决定点哪里；v1.2.0 的主要新增是把全部 60 个命令暴露为 MCP 工具（`agent-desktop mcp`）。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**：把「computer use」从视觉模型猜像素坐标，换成了操作系统原生无障碍 API 返回的结构化元素引用。
- **现在值得用吗**：看场景——只有当你要操作的是**有正经无障碍树的原生桌面应用**（Finder、Slack、Office、系统设置等），且能接受 macOS/Windows/Linux 三平台各有一套适配差异时，才值得上手。
- **适合场景**：内部工具自动化、桌面 GUI 的回归测试、需要「操作后验证」的闭环 agent 流程、给已有的 coding agent 补上桌面手脚。
- **不适合场景**：纯 Web 自动化（用浏览器工具更划算）、画布类/游戏/自绘 GUI（无障碍树基本为空）、需要跨网络无头运行在 Linux 服务器上操作 macOS 应用的场景。
- **与竞品核心差異**：和基于截图的 computer use（视觉模型 + 坐标点击）相比，它的动作对象是 `@s8f3k2p9:e8` 这样的快照内 ref，而不是 `(x, y)`；UI 变了会明确抛出 `STALE_REF`，而不是让你静默点错地方。

## 是什么 / 解决什么问题

过去两年「computer use」的主流实现是：截屏 → 视觉模型判断该点哪里 → 输出像素坐标 → 点。这条路的天花板很明显：**坐标没有语义**。如果窗口移动了、DPI 变了、下一帧有个弹窗挡了一下，坐标就废了，而 agent 往往不知道自己点错了——它只看到"我点了"。

`agent-desktop` 走的是另一条路：直接读操作系统的无障碍树（macOS 的 AX API、Windows 的 UI Automation、Linux 的 AT-SPI），把界面序列化成 JSON 树，树里每个可交互元素带一个 `ref_id`。agent 后续的点击、输入都作用在这个 ref 上。

一个裁剪过的 snapshot 长这样（来自官方 README）：

```json
{
  "version": "2.6",
  "ok": true,
  "command": "snapshot",
  "data": {
    "app": "Finder",
    "snapshot_id": "s8f3k2p9",
    "ref_count": 59,
    "complete": true,
    "tree": {
      "role": "window",
      "name": "Downloads",
      "children": [
        { "role": "treeitem", "name": "Documents", "ref_id": "@s8f3k2p9:e8", "available_actions": ["Click"] }
      ]
    }
  }
}
```

注意 `available_actions`——这是无障碍树带来的额外红利：工具能告诉你**这个元素能干什么**，而不是让模型猜。这正是纯视觉方案永远拿不到的信息。

本次 v1.2.0 最核心的变化是 **MCP 支持**：`agent-desktop mcp` 在 stdio 上把每个命令暴露成一个 MCP 工具（`desktop_snapshot`、`desktop_click`、`desktop_session_start` 等），返回值就是那条 JSON envelope。这意味着任何支持 MCP 的客户端（Claude Desktop、各类 agent harness）可以不写适配层，直接把桌面操作当成一组工具调用。

## 技术架构拆解

### 核心设计决策

- **lib 里没有模型**：README 明确写 "The loop lives in your agent; agent-desktop has no model inside."。它是一个纯执行器，感知→决策→行动的闭环由调用方的 agent 实现。这让它可以被任意模型、任意 harness 复用，也意味着它自己不做任何"智能纠错"。
- **ref 绑定快照，而不是绑定坐标**：ref 的完整形式是 `@<snapshot_id>:<element>`。裸的 `@e8` 会被直接拒绝（`INVALID_ARGS`）。UI 变化后动作返回 `STALE_REF`，多个窗口返回 `AMBIGUOUS_TARGET`，错误详情里会列候选 window id，让你用 `--window-id` 指定。
- **默认 headless，不动鼠标**：ref 动作走无障碍 API，不移动指针、不抢焦点。需要物理输入时才加全局 `--headed`。这是从"自动化测试工具"而非"远程桌面"的角度做的取舍。
- **按需降噪**：密集应用支持先 `snapshot --skeleton --app Slack -i --compact` 拿骨架，再用 `--root @ref` 钻进某个区域。这是为了控制 token——完整无障碍树在 Slack 这类应用上可以大到没法塞进上下文。
- **Rust 核心 + 每平台一个 PlatformAdapter**：README 的开发章节里，macOS 侧要 `cargo test -p agent-desktop-core -p agent-desktop-macos -p agent-desktop -p agent-desktop-ffi`，Windows/Linux 各自替换 package。平台适配是编译期隔离的。
- **双形态：CLI + C 库**：每次 release 都带 `libagent_desktop_ffi`，程序可以 in-process 调用，避免每条命令 fork 一个进程的开销。C ABI 用 `AD_ABI_VERSION_MAJOR` 做版本校验。

### 与前版/竞品的关键差异

| 维度 | 基于截图的 computer use | agent-desktop |
|------|------------------------|---------------|
| 感知方式 | 截屏 + 视觉模型 | OS 无障碍树 → JSON |
| 动作目标 | 像素坐标 (x, y) | 快照内 ref `@snap:id` |
| 能否知道元素能力 | 否，靠模型推断 | 是，`available_actions` 直接给出 |
| UI 变化时 | 静默点错 | `STALE_REF` 显式报错 |
| 每步成本 | 一张图（token 重）+ 一次视觉推理 | 一棵可裁剪的 JSON 树 |
| 依赖 | 视觉能力强的模型 | 目标应用有无障碍支持 |
| 是否内置模型 | 是（整套方案隐含） | 否，纯执行器 |
| 集成形态（v1.2.0） | 各家自定义 | CLI / C 库 / MCP |

### 架构/信息流图

```
┌─────────────────────────────────────────────┐
│              Your Agent (has the model)      │
│   snapshot → 选择 ref → act → 再 snapshot 验证 │
└───────────────┬─────────────────────────────┘
                │ CLI / MCP(stdio) / C FFI
┌───────────────▼─────────────────────────────┐
│        agent-desktop core (Rust)             │
│   snapshot_id 绑定 · STALE_REF 校验 · 等待    │
└───────────────┬─────────────────────────────┘
                │ PlatformAdapter（编译期按 OS 隔离）
    ┌───────────┼────────────┐
┌───▼────┐ ┌────▼─────┐ ┌────▼────┐
│ macOS  │ │ Windows  │ │  Linux  │
│ AX API │ │ UIA      │ │ AT-SPI  │
└────────┘ └──────────┘ └─────────┘
```

一个典型的闭环（README quick start）：

```
agent-desktop snapshot --app Finder -i    # 拿到 ref 列表
agent-desktop click @s8f3k2p9:e8          # 对 ref 动作
agent-desktop snapshot --app Finder -i    # 再观察，验证结果
```

## 实用评估

### 什么场景值得用

- **桌面 GUI 的自动化回归测试**：ref 有语义、错误有分类（`STALE_REF` / `AMBIGUOUS_TARGET`），比截图比对稳得多，测试失败时也知道是"UI 变了"还是"逻辑错了"。
- **内部原生应用的 agent 化**：你在做 Agent + UI 方向，如果目标是让 agent 操作自家或第三方桌面客户端，无障碍树能省掉一层视觉方案的成本和不确定性。
- **已有 coding agent 补桌面手脚**：它通过 skills.sh 提供 skill（`npx skills add https://github.com/vercel-labs/agent-desktop --skill agent-desktop`），可以直接塞进 Claude Code / Codex / OpenCode 这类 harness，不用重写 agent loop。
- **MCP 生态接入**：v1.2.0 之后，配置三行 JSON 就能挂到任意 MCP 客户端：

```json
{ "mcpServers": { "agent-desktop": { "command": "agent-desktop", "args": ["mcp"] } } }
```

### 什么场景不值得用

- **Web 自动化**：浏览器有自己的 CDP / Playwright 生态，无障碍树这条路的成熟度远不如它。
- **自绘界面 / 游戏 / Electron 里没做无障碍的应用**：树可能是空的，或者只有几个大容器节点。这类界面仍然得回到视觉方案。
- **跨平台一致性的幻想**：三个平台是三套 API、三套能力边界。官方明说每个平台页面会列"什么能 headless 跑、什么必须 `--headed`、什么直接拒绝"。别指望写一次跑三个平台。
- **安全敏感的多用户机器**：README 自己警告：snapshots、clipboard、screenshots、命令输出都可能包含隐私内容，要远离公开日志和上传。
- **需要"一次调用完成任务"的简单需求**：它是执行器不是解决方案，来回 snapshot 的 token 与延迟成本要你自己付。

### 迁移成本

- **从截图文案迁移**：核心是把"点 (x, y)"改写成"对 ref 动作"，并补上"动作后重新 snapshot 验证"这一步。agent loop 的骨架可以留，但重试策略要重写——以前是"再截一帧看看"，现在是"读 `error.disposition.retry` 判断能不能重试"。
- **从别的桌面自动化库迁移**：命令层有 60 个命令名（56 个可运行，`key-down` / `key-up` / `mouse-down` / `mouse-up` 在 daemon 能释放按住状态前会拒绝运行），覆盖面够，但需要重新对齐语义。
- **工程侧**：每条命令输出一条 JSON envelope，解析成本低。`type` / `set-value` / `clipboard-set` 都支持 `--stdin`，正是为了让敏感文本不进入进程参数——这个细节值得抄进你自己工具的密钥处理里。

## 对你的意义

对你的 Agent + UI 主线，这个东西的价值不在"又一个 computer use 工具"，而在于它**把 computer use 拆成了两个可独立替换的层**：感知+执行（确定性，无模型）与决策（模型，在 agent 里）。这个分层对做 RAG 工具链和评估的人很关键——因为只有确定性层才可测：同样的快照，同样的 ref，动作结果可复现，你才能给"agent 操作 UI 的正确率"定义指标。

具体建议：**观望中的轻量试**。花半小时在 macOS 上 `npm install -g agent-desktop` 跑一遍 Finder 的 quick start，感受一下 snapshot 的 JSON 体积和 ref 的稳定性。如果你的场景里目标应用有正经无障碍树，它可能直接替代你现在会想写的视觉方案；如果你的场景是 Web 或自绘界面，看完就放下，别硬套。

一个必须记住的限制：**它是无模型的执行器**。它能告诉你哪个元素能点，但"该点哪个、点完算不算成功"的判断完全在你这边。它省下的是感知的不确定性，不是决策的。

## 关键代码/配置片段

安装与权限（macOS 需要 Accessibility 授权）：

```bash
npm install -g agent-desktop
agent-desktop status            # 平台、权限、支持的 surface
agent-desktop permissions --guide   # macOS: 引导授权
```

给 agent 注入使用规范（README 推荐写进 AGENTS.md）：

```
Use `agent-desktop` to see and operate desktop apps. Before the first use, run
`agent-desktop skills get desktop` and `agent-desktop skills get platform`, and follow them.
```

Windows 下的一个真实坑（README 原文提示）：PowerShell 里 **每个 ref 都要加引号**，因为裸 `@token` 是 splatting 操作符：

```powershell
agent-desktop click '@s8f3k2p9:e8'
```

C 库 in-process 调用（来自 README 的 FFI 示例）：

```python
import ctypes
lib = ctypes.CDLL("./lib/libagent_desktop_ffi.dylib")
lib.ad_adapter_create.restype = ctypes.c_void_p
lib.ad_adapter_destroy.argtypes = [ctypes.c_void_p]
assert lib.ad_init(7) == 0   # AD_RESULT_OK（header 的 ABI major 版本需匹配）
adapter = lib.ad_adapter_create()
lib.ad_adapter_destroy(adapter)
```

> TODO: v1.2.0 的具体性能数据（snapshot 延迟、ref 命中率、与视觉方案的成本对比）官方 release notes 未提供 benchmark，待后续实测或有官方数据时补充。

---
[← Back to Deep Dives](./README.md)
