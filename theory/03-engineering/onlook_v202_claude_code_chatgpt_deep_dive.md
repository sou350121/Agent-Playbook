---
auto_generated: true
generated_at: "2026-11-20T11:00:51Z"
source_url: "https://github.com/onlook-dev/onlook/releases"
signal_type: "blog_post"
---
# Onlook 2.0：把 Claude Code / Codex 塞进设计师画布 (Onlook 2.0: A Visual Canvas That Runs Your Coding Agent)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-20
>
> **项目/工具**: Onlook v2.0.2（Onlook 2.0 桌面版）
> **链接**: https://github.com/onlook-dev/onlook/releases/tag/v2.0.2
> **核心定位**: 一个本地优先（local-first）的开源设计画布，不自带任何模型，而是把你已有的 Claude Code / ChatGPT(Codex) 订阅接进来，在真实 Git 仓库上直接改代码——设计师改的就是最终交付物，不是需要工程师重做一遍的 mockup。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Onlook 从「浏览器里编辑 Next.js + Tailwind 的在线编辑器」变成了「装在 Mac 上的 Electron 桌面应用 + 无限画布 + 可选自带编码 agent 的层」——这次 v2.0.2 是 2.0 桌面线的正式发布版。
- **現在值得用嗎**：看場景。只要你满足「Mac + 已有 Claude 或 ChatGPT 订阅 + 项目是可在本机 `dev` 起的 Web 前端」这三个条件，值得立刻试；否则先观望（Windows 尚未发布）。
- **適合場景**：设计驱动的前端迭代、同一页面多方案并排比较、需要在真实现有仓库而非空白项目上做视觉调整、想把 HTML/PNG/PDF 交付物直接导出给非工程同事。
- **不適合場景**：非 Mac 环境（官方只提供 macOS，Windows 官方标注「Coming soon」）；需要 Figma 级别的多人实时协作与设计系统管理；后端/非 Web 项目（画布价值体现在 `dev` server 渲染的前端页面）。
- **與 v1 核心差異**：v1 是浏览器里的 Next.js/Tailwind 在线编辑器，依赖 Onlook 云端；2.0 是本地 Electron 应用，源码构建不需要 Onlook 账号、云密钥或 `.env`，agent 由你自己已有的订阅承担。

## 是什么 / 解决什么问题

过去两年「AI 生成 UI」赛道基本分成两派：一派从自然语言直接吐出代码（v0、Replit Agent、各种 chat-to-UI），一派从设计稿出发（Figma 类工具 + 导出）。两派之间存在一个持续被抱怨的缝隙——**生成出来的东西是「另起一份」的产物**：它不在你真实的仓库里，你的字体、资产、原生组件、路由结构全部丢失，最后还是要一个工程师把它「移植」回产品里。

Onlook 的定位就是这条缝隙：把画布直接架在你本机的真实 Git 仓库之上，跑你自己的 `dev` server，把正在运行的真实应用渲染到无限画布上，然后让 agent 在这个上下文里改代码。官方 README 的表述很直白——「what you design is your actual product, not a mockup that someone has to rebuild later」。

按 v2.0.2 release notes（2026-11-19 发布），这次发布的是三件东西的组合：

1. **Electron 桌面应用**——不再是浏览器标签页里的编辑器；
2. **画布（canvas）**——实时应用、多设备 frame 并排、无限延展；
3. **运行 agent 的那一层**——「the layer that runs Claude Code or ChatGPT on your Mac」。

而真正让这次发布在工程上值得讨论的，是它**对 agent 的态度**：Onlook 不训练、也不打算自研模型。README 写得很清楚：「We don't ship our own model. Connect the Claude Code or ChatGPT/Codex account you already have.」这是一个与多数 AI 设计工具相反的方向选择——它们把模型当成产品护城河，Onlook 把模型当成可替换的外部依赖，自己做上下文与操作面。

## 技术架构拆解

### 核心设计决策

- **不带模型，只带上下文（bring your own agent）**：直接复用用户已有的 Claude Code / Codex 订阅。好处是成本与合规都甩给用户自己承担的 provider，产品不需要为大模型 API 成本做定价设计；代价是能力天花板、可用性、模型行为全部被上游绑定。据 release notes，桌面版「works with the Claude or ChatGPT subscription you already have」——这也意味着它没有免费额度或内置模型可选。
- **Local-first，代码不出本机**：桌面应用跑在用户电脑上，代码留在本地；源码构建路径下不需要 Onlook 账号、云密钥或 `.env`。这是与 v0/Replit 这类云端生成工具最根本的分野：它换来了隐私与仓库兼容性，也换掉了云端算力和多人协作能力。
- **在真实仓库上工作，而非导出代码**：打开任意本地 Git 仓库、启动用户自己的 dev server；README 明确写了「Safe worktree copy, so your folder is never touched」——用 worktree 副本隔离，agent 的改动不会直接污染工作目录。这是我在架构上最认可的一个决定：它把「agent 乱改文件」的风险用 Git 原语挡了一层。
- **画布作为 agent 的输出界面**：agent 不只写代码，还能「arrange the canvas for you (variations, states, flows)」——即让同一页面的多个变体、状态、流程并排出现在画布上供人选。这把「diff 审阅」换成了「视觉比较」，是面向设计师的交互取舍。
- **Telemetry 可彻底剥离，且承诺不采集敏感内容**：源码构建询问是否分享使用数据；正式构建与源码构建使用同一分析项目，但源码事件标记为 `build_kind: source`，且明示「never include session recordings, diagnostic logs, error reports, code, file paths, or chat messages」。可用 `STUDIO_TELEMETRY=0` 构建完全无遥测版本。

### 与前版/竞品的关键差异

| 维度 | Onlook v1 | Onlook 2.0（桌面） | 云端 chat-to-UI（v0 / Replit Agent 类） |
|------|-----------|-------------------|----------------------------------------|
| 运行形态 | 浏览器内在线编辑器 | macOS Electron 桌面应用 | 云端 sandbox |
| 项目类型 | 限定 Next.js + Tailwind | 任意可在本机 `dev` 起的 Web 项目（据 README） | 通常是新建项目或有限导入 |
| 模型来源 | Onlook 侧提供 | 用户自带 Claude Code / ChatGPT 订阅 | 平台内置，按量计费 |
| 代码位置 | 云端 | 本机（worktree 副本） | 云端 |
| 账号要求 | 需要 Onlook 账号 | 源码构建不需要账号/云密钥 | 必须 |
| 协作 | 侧重在线分享 | 画布 + 导出 HTML/PNG/JPEG/PDF | 链接分享 |
| 开源 | 开源 | Apache-2.0 | 闭源 |

> 注：表中「项目类型」一项来自 README 的功能描述，v1 的 Next.js/Tailwind 限定来自 release notes 对 v1 的说明（「Onlook v1, the browser-based editor for Next.js and Tailwind projects, is on the `v1` branch」）。2.0 是否对所有前端框架一视同仁，官方未给出框架兼容矩阵，属于待验证项。

### 架构/信息流图

```
┌────────────────────────────────────────────────────┐
│              Onlook Desktop (Electron, macOS)       │
│  bundle id: com.onlook.studio.source (源码构建)     │
│  数据目录: ~/Library/Application Support/...         │
├────────────────────────────────────────────────────┤
│  Canvas（无限画布）                                  │
│   ├─ 本地 dev server 渲染的真实应用（live）          │
│   ├─ 多设备 frame 并排（mobile / tablet / desktop）  │
│   ├─ 变体 / 状态 / 流程 排布（agent 可代排）         │
│   └─ 参考图、Artifacts（独立 HTML 草图）             │
├────────────────────────────────────────────────────┤
│  上下文层：选中元素 → 结构化描述（DOM/样式/资产）     │
├────────────────────────────────────────────────────┤
│  Agent Layer（不内置模型）                           │
│   ├─ Claude Code 账号                               │
│   ├─ ChatGPT / Codex 账号                           │
│   └─ MCP connectors（外部工具/上下文）               │
├────────────────────────────────────────────────────┤
│  写入层：safe worktree copy（不动用户工作目录）      │
│   └─ → 本机 Git 仓库 → 一鍵 PR（checks → merge）     │
└────────────────────────────────────────────────────┘
```

这张图里最关键的一条边是「画布元素 → agent 上下文」：Onlook 的价值不在模型，而在**把视觉上被点选的那个元素翻译成 agent 能精确操作的代码位置**。这一层做得好不好，决定了它到底是「设计师能用的工具」还是「又一个套壳 chat」。

## 实用评估

### 什么场景值得用

- **设计驱动的前端微调**：间距、层级、配色、状态变体这类改动，在画布上圈选 + 一句自然语言描述，比在终端里跟 agent 描述「第三张卡片的 padding」高效得多。
- **多方案比稿**：同一页面的三种布局并排渲染，直接给非工程方的同事看，比三个分支三张截图省事。
- **已有仓库的渐进式改造**：你不需要把项目迁到某个平台，打开本地仓库就能开工——这对维护多年历史项目的人是真需求。
- **交付物导出**：HTML/PNG/JPEG/PDF 四件套导出，做内部评审材料或快速原型分享都够用。

### 什么场景不值得用

- **非 macOS**：官方只提供 macOS（Apple silicon + Intel）下载，Windows 标注「Coming soon」。没有日期承诺，别把团队流程建在等待上。
- **需要内置模型能力的团队**：如果你没有 Claude / ChatGPT 订阅，或公司政策不允许多账号接入个人订阅，这套「自带 agent」的设计对你等于不可用。
- **强多人协作场景**：README 没有提到实时多人协同编辑；Figma 的核心价值（评论、组件库、设计系统版本管理）在 Onlook 上找不到对应物，也不该指望它替代 Figma。
- **对 agent 行为零容忍的受监管环境**：agent 直接在你的仓库上改代码，虽然有 worktree 隔离和 PR 流程兜底，但「agent 产生的改动进入 code review」本身就要求团队有审阅机制。

### 迁移成本

- **从 v1 迁移**：v1 的代码保留在 `v1` 分支，说明 2.0 是一次**不连续的重构**，没有平滑升级路径。v1 用户需要重新在桌面版里打开项目。
- **从零开始**：下载 app（onlook.com/install）→ 首次启动选择遥测偏好 → 连接 Claude Code 或 Codex → 建 Project。整条链路不需要 `.env`、不需要云密钥。
- **从源码构建**：需要 macOS（含 Xcode Command Line Tools）、Git、Node.js 24、Bun 1.4.2；流程是 `bun install --frozen-lockfile --cpu='*'` → `bun run build` → `bun dev`，打包用 `bun run build:dmg`。注意源码构建自带独立 bundle id 与数据目录，不读取官方版数据、不接收官方更新，每次更新需重新拉取并重装依赖。
- **一个已经暴露的坑**：SOURCE_BUILD.md 明确提到，编译原生依赖时可能报 `unknown architecture arm64e.x1`，需要手动指定 SDK，例如：
  ```sh
  export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk
  ```
  这说明新 macOS SDK 的兼容性问题尚未被构建脚本完全吸收，源码构建用户要做好一次手动排障的准备。

## 对你的意义

这条线跟你关注的「Agent + UI」方向直接对上：Onlook 代表的是 **agent 作为可替换执行器、产品价值转移到「上下文工程 + 操作面」** 的一类架构。这类设计的可复用结论有三条，我认为值得记进 handbook：

1. **上下文层才是护城河**。谁把「用户所指的那个视觉对象」准确翻译成代码位置，谁就赢；模型可以换，这层翻译不能。做自己的 Agent UI 时，元素级上下文捕获（DOM/样式/资产/路由）应该比 prompt 工程投入更多。
2. **Git 原语就是 agent 的安全护栏**。worktree 副本 + PR 流程，成本极低却把风险隔离得很干净——这个模式比任何自研沙箱都便宜，也比你想象的通用。
3. **本地优先 + 自带订阅**是一种新的成本模型。它把「AI 工具毛利」问题从「按 token 加价」转成「订阅用户的存量价值变现」，代价是失去云端协作与横跨平台。

**建议**：先花 30 分钟用现有的一个前端仓库试。如果画布选元素 → agent 改代码这条链路足够准，就把它纳入日常视觉迭代工具；如果它对你们的组件抽象或设计系统理解不到位，就跳过——这类工具的价值全在「准」，一旦需要反复纠正就还不如直接跟 agent 对话。

## 关键代码/配置片段

以下均摘自官方 `SOURCE_BUILD.md` 与 v2.0.2 release notes，未做改动。

源码构建全流程：

```sh
git clone https://github.com/onlook-dev/onlook.git
cd onlook
bun install --frozen-lockfile --cpu='*'
bun run build
bun dev
```

打包成 DMG（同时构建两种 Mac 架构，无需签名凭证）：

```sh
bun run build:dmg
# 仅构建 app bundle，不生成安装器
bun run build:dmg --dir
```

完全关闭遥测的构建：

```sh
STUDIO_TELEMETRY=0 bun run build
```

> 按文档：该构建「has no telemetry question, ingestion key, analytics code or replay SDK, and sends nothing even if a key is supplied at runtime」。

release notes 中的安装入口与限定条件：

- 下载：https://www.onlook.com/install
- 平台：macOS · Apple silicon · Intel
- 授权：Apache-2.0

---
[← Back to Deep Dives](./README.md)
