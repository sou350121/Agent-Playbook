---
auto_generated: true
generated_at: "2026-11-06T14:00:48Z"
source_url: "https://github.com/Balanov/uncut/releases/tag/v0.1.1"
signal_type: "significant_update"
---
# uncut：7 MB 单二进制 Go coding-agent harness，把「上下文被悄悄截断」当显式失败 (uncut: A 7 MB Static-Binary Go Coding-Agent Harness That Refuses Silent Context Cuts)

> 🔍 本文由 Moltbot 自动生成 | 2026-11-06
>
> **项目/工具**: uncut (Balanov/uncut)
> **链接**: https://github.com/Balanov/uncut/releases/tag/v0.1.1
> **核心定位**: 一个只有 837 行 Go、四个工具、纯 stdin/stdout 的无头 coding-agent harness —— 它不做摘要、不做滑窗、不做静默截断，任何「被裁掉的上下文」都必须以非零退出码暴露出来

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：不是给开发者用的 IDE Agent，而是给 pipeline 用的 agent「底座」——把一次 coding agent 运行变成可预测退出码的 Unix 命令
- **现在值得用吗**：看场景。你要的是 CI / shell pipeline / 本地小模型实验里的确定性 agent 步骤，那就值得；你要的是能自己规划长任务、自动重试、自动压缩上下文的成熟 Agent 产品，那它故意没做
- **适合场景**：CI 里的代码审查/修复步骤、`git diff | uncut ...` 这类管道用法、本地 Ollama + 小模型跑 tool-calling 实验、想 fork 一个 837 行实现来改协议的人
- **不适合场景**：长上下文大仓库重构（它不做 compaction，每轮全量重发，token 成本线性爆炸）、需要 TUI/多 agent 编排/后台任务的交互式开发
- **与主流 harness 核心差异**：Claude Code / Codex CLI / Pi 这类产品把「上下文管理」当成必须自己解决的工程问题（摘要、压缩、滑窗）；uncut 的立场是反过来的 —— 上下文管理是**调用方**的责任，harness 只负责**不许骗你**

## 是什么 / 解决什么问题

现代 coding agent CLI 有一个普遍但不显眼的设计倾向：为了让任务「跑完」，它会在你看不见的地方做妥协。上下文超了，压缩一下；provider 在 output limit 处截了响应，当作正常结果继续；管道输入里有非法 UTF-8，替换成 � 继续走；session 文件里有一行坏了，丢掉它让加载成功。

这些妥协对交互式使用很友好（人尽量不被打断），但对**机器调用方**是灾难。CI 里跑一个 agent 步骤，你拿到 exit 0，不代表代码是对的，只代表 harness 决定不告诉你哪里不对。

uncut 的全部设计就是围绕这一个判断展开的。项目自述（README）：

> "The entire conversation is sent on every model call. File contents and combined command output are never truncated by UNCUT. If the provider cuts a response at its output limit, UNCUT exits with an error instead of presenting a partial answer as success."

它的定位不是「更好的 coding agent」，而是「**lossless, headless coding agent harness**」——7 MB 静态二进制，四个工具，无 TUI、无遥测、无插件系统、无后台 agent、无自动重试、无 context compaction。0.1.1 是该项目当前的公开版本，README 与 BENCHMARKS 中的安装命令、测量数据均以 0.1.1 为准。

## 技术架构拆解

### 核心设计决策

- **每轮全量重发**：不做摘要、不做 pruning、不做 sliding window。代价是 token 随轮数线性增长，收益是模型看到的永远是完整真实历史，而不是某个压缩算法认为「重要」的版本。
- **只有四个工具**：README 明确「four tools」，从管道示例和 smoke test 推断包含 `read_file`、`replace`、`run_command` 等（第四项未在抓取到的 README 片段中列全，`> TODO: 补齐第四个工具名称，读 cmd/uncut 源码确认`）。工具少意味着 prompt 小、行为可预测、模型 tool-call 出错面窄。
- **无头 + 结构化事件**：最终文本走 stdout，`--json` 输出 NDJSON 事件流，事件类型为 `user` / `assistant` / `assistant_meta` / `tool` / `done|error`。usage（token 用量）与 finish reason 单独放在 `assistant_meta`，不与正文混在一起 —— 这对下游程序解析非常关键。
- **显式失败胜过部分成功**：五类边界全部以退出码暴露：provider 截断 `finish_reason=length` → exit 3 且 stdout 为 0 字节；步数超限 → exit 4；非法 UTF-8 → 拒绝而非替换；session 记录损坏 → 报错而非丢弃。
- **会话可恢复但只追加**：`--session work.jsonl` 追加写、每步 sync；文件存在即恢复完整历史。附录式设计让它天然可审计 —— 这也是「可 fork」的前提。
- **Provider 中立 + 本地友好**：只依赖 OpenAI-compatible Chat Completions 端点，`UNCUT_BASE_URL` 指向 Ollama（`http://localhost:11434/v1`）即可跑本地模型，默认不需要 API key。
- **零第三方 Go 依赖**：`go.mod` 无外部依赖，静态链接，`CGO_ENABLED=0` 交叉编译。7 MB 是完整可执行体，不是压缩包。

### 与前版/竞品的关键差异

| 维度 | 主流 Agent CLI（如 Pi 1.4.0） | uncut 0.1.1 |
|------|------------|------------|
| 上下文超长 | 摘要 / 压缩 / 滑窗 | 不处理，全量重发；由调用方负责 |
| Provider 截断响应 | 尝试续写或降级返回 | exit 3，**stdout 零字节** |
| 非法 UTF-8 输入 | 常见做法是替换字符 | 显式拒绝 |
| 坏 session 记录 | 跳过让加载成功 | 报错，不丢数据 |
| 交互界面 | TUI / 富交互 | 无 TUI，只有 stdout + NDJSON |
| `--version` 启动中位数（Windows amd64，100 次） | 243.339 ms | 9.461 ms（25.7× 更低） |
| 安装体量 | 完整 node_modules 树 112,329,741 B（107.13 MiB，121 个包） | 完整可执行体 7,109,120 B（6.78 MiB） |
| 功能广度 | 明显更宽 | 故意收窄 |

上表后两行必须连同作者自己的免责声明一起读。BENCHMARKS.md 原文写得很清楚：

> "For this specific `--version` workload, UNCUT's median was 25.7× lower. This does **not** mean that UNCUT completes model-driven coding tasks 25.7× faster."

以及

> "The UNCUT footprint is its complete executable. Pi's footprint is the full local `node_modules` tree (121 packages), excluding the shared Node runtime. Pi also provides a substantially broader feature set."

这个 benchmark 测的是**进程启动开销与安装体积**，不测模型质量、token 数或端到端编码速度。它本身也非常小（100 次 `--version`），且 interleaved 取样、warm cache，跨平台不可外推（Pi 的测量只在 Windows 上做过）。

### 架构/信息流图

```
        stdin (prompt / git diff / log, 原文追加)
                        │
                        ▼
              ┌───────────────────┐
              │  agent loop       │  ← 无 compaction / 无 retry
              │  (837 行 Go)      │
              └─────────┬─────────┘
                        │ 每轮：完整历史 → provider
                        ▼
        OpenAI-compatible endpoint (cloud / Ollama)
                        │
        ┌───────────────┴────────────────┐
        │ 正常 finish                    │ finish_reason=length
        ▼                                ▼
   四个工具执行                      exit 3 + stdout 0 bytes
   (read/replace/run/…)                    │
        │                                  │
        ├──► stdout (最终文本)             │
        ├──► --json: NDJSON 事件流 ◄───────┘
        │     user/assistant/assistant_meta/tool/done|error
        └──► --session: append-only JSONL, 每步 sync
```

## 实用评估

### 什么场景值得用

- **CI / shell pipeline 里的 agent 步骤**：`git diff | uncut "Review this diff. Do not edit files."`，退出码可直接作为 gate。这是它最贴合的用法，也是「headless」两个字兑现价值的地方。
- **需要 agent 行为可复现与可审计**：append-only JSONL session 保留每条消息和每个工具结果，事后能逐条回放。相比「压缩后只剩摘要」的会话历史，这在排查 agent 为什么改错文件时有决定意义。
- **本地小模型 tool-calling 实验**：作者用它跑了 Ollama + `qwen3:8b` 的 smoke test，四条链路（read_file / replace / run_command / 恢复 session）在一个一次性工作区里跑通，并用文件系统断言核对改动字节。想比较不同本地模型的 tool-call 行为，这个 harness 够薄，不引入额外变量。
- **想 fork 一个 agent 实现的人**：837 行实现 Go、四个工具、一个 provider 协议、一个 agent loop，MIT 许可。要加一个新 provider 或新工具，改动面比读一个成熟 Agent CLI 小一个数量级。

### 什么场景不值得用

- **长上下文 / 大仓库任务**：没有 compaction 是**特性**也是**硬伤**。每个模型调用都携带完整历史，token 消耗随步数线性上升，大仓库探索很快就会撞上 provider 的窗口上限 —— 而它的应对方式是报错退出，不是帮你压缩。这是设计意图，不是 bug。
- **需要交互式开发的日常场景**：无 TUI、无后台 agent、无自动重试，跑长任务中途失败就是失败，得自己接住重跑。
- **依赖多 agent 编排或插件生态的团队**：它明确没有 plugin system 和 background agents，任何围绕这些能力的架构预期都落空。
- **对二进制自签名/供应链有硬要求的环境**：README 承认 "The binaries are not code-signed yet, so SmartScreen or Gatekeeper may warn"，需要自行核对 `checksums.txt`，macOS 上还要手动清 quarantine。
- **需要 provider 端上下文保证的场景**：proof 套件只证明了 uncut 的传输与控制流行为，不证明 provider 内部保留了上下文，也不证明任意大的请求会被接受。

### 迁移成本

- **从 npm 系 Agent CLI 迁过来**：几乎不存在「配置迁移」概念（只有三个环境变量 `UNCUT_MODEL` / `UNCUT_BASE_URL` / `UNCUT_API_KEY`），但**能力迁移是主要成本** —— 原来依赖的摘要、重试、TUI、多命令快捷键全部需要自己在外面用 shell / CI 补。粗估：单步 CI gate 场景半天可用；把现有交互式工作流整个搬过来不现实。
- **从零接入**：`curl` 下载二进制 → `install -m 0755` → 设三个 env 变量，Linux/macOS/PowerShell 各有官方命令，5 分钟内可跑通。
- **回到主流 harness 的成本**：低（它没有产生私有状态格式，session 是纯 JSONL）。

## 对你的意义

对一个「把日报/情报流水线全部脚本化」的人来说，uncut 的价值不在于「比 Claude Code 强」，而在于它把 agent 运行降级成一个**普通 Unix 命令**这件事做得足够认真。

具体判断：

- **值得立刻试的**：把双周/每周报告生成里那些「调 LLM 审一段 diff 或总结一份日志」的步骤，换成 `cat x.log | uncut "…" --json`，用退出码做失败判定。这类步骤目前最容易出现「静默截断但 exit 0」的假成功，而 exit 3 + 零字节 stdout 正好堵住这个洞。
- **值得借鉴的设计**：`assistant_meta` 把 usage 与 finish reason 单独成事件，而不是塞进正文。任何自己写 LLM 调用封装的人都该抄这一条 —— 它让「这次到底有没有被截断」变成可编程判断，而不是靠肉眼读。
- **不建议现在做的**：不要在长上下文任务上替换现有 harness。它不会帮你压上下文，一旦撞墙就是硬失败。
- **可观望**：二进制造者未签名、0.1.x 早期版本、benchmark 样本窄（单机单次 100 次 `--version`）。作为 pipeline 组件长期依赖前，建议锁定版本 + 核对 SHA-256。

这是一个「立场先行」的项目：它先决定「不许骗人」，然后接受由此带来的所有不便。这类项目对基础设施维护者的吸引力，通常远大于对普通开发者的吸引力。

## 关键代码/配置片段

以下均引自官方 README（Balanov/uncut，0.1.1）：

基础调用：

```bash
export UNCUT_API_KEY="your-api-key"
export UNCUT_MODEL="your-model-id"
uncut "Inspect this repository and fix the failing tests"
```

管道用法（piped input 原文追加到 prompt）：

```bash
git diff | uncut "Review this diff. Do not edit files."
cat failing-test.log | uncut "Find the likely cause"
```

本地 Ollama（作者实测配置，模型 `qwen3:8b`）：

```bash
ollama pull qwen3:8b
export UNCUT_BASE_URL="http://localhost:11434/v1"
export UNCUT_MODEL="qwen3:8b"
uncut "Explain this repository"
```

结构化事件流与可恢复会话：

```bash
uncut --json "Run the tests and fix the failure"

uncut --session .uncut/work.jsonl "Start the refactor"
uncut --session .uncut/work.jsonl "Continue with the tests"
```

校验发布件：

```bash
VERSION=0.1.1
ARCH=amd64
curl -fSLO "https://github.com/Balanov/uncut/releases/download/v${VERSION}/checksums.txt"
grep "uncut-linux-`{ARCH}`" checksums.txt | sha256sum -c -
```

安全提醒（引自 README）：session 文件可能包含源代码、命令输出与密钥，需按此保管、不要误提交。

---
[← Back to Deep Dives](./README.md)
