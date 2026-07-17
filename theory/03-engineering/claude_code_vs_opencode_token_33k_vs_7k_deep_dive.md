---
auto_generated: true
generated_at: "2026-07-17T13:22:59Z"
source_url: "https://systima.ai/blog/claude-code-vs-opencode-token-overhead"
signal_type: "significant_update"
---
# Claude Code vs OpenCode Token 开销实测：33k vs 7k 系统前缀
# (Claude Code vs OpenCode Token Overhead: 33k vs 7k System Prefix)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-17
>
> **项目/工具**: Claude Code (Anthropic) vs OpenCode
> **链接**: https://systima.ai/blog/claude-code-vs-opencode-token-overhead
> **核心定位**: Systima 团队在 API 边界对 Claude Code 和 OpenCode 进行了全量 token 流量审计，首次量化了两个主流编码 Agent 框架的系统前缀开销差异——Claude Code 每次请求比 OpenCode 多发送 4.7 倍的 token，缓存效率差距达 54 倍。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 这是目前最详尽的编码 Agent token 开销对比实测，量化了 Claude Code 和 OpenCode 在系统前缀、缓存效率、多轮交互、子 Agent 分发等场景下的 token 消耗差异。
- **现在值得用吗**: 如果你在生产环境大规模部署编码 Agent（尤其是按 token 计费的 API 模式），这篇文章的数据直接决定了你的成本结构——OpenCode 在单次请求开销上显著占优，但 Claude Code 在并行批处理场景下可能追平。
- **适合场景**: 成本敏感的大规模 Agent 部署；需要精细控制 token 预算的团队；评估 Agent 框架选型的技术负责人。
- **不适合场景**: 个人开发者单 session 使用（token 差异对体验影响不大）；使用 Claude Max 订阅不计 token 的场景。
- **与一般认知的核心差异**: 多数人认为 Claude Code 更"贵"是因为模型本身贵，但实测显示主要成本来自框架前缀开销（33k vs 7k），而非模型推理成本。

## 是什么 / 解决什么问题

编码 Agent（Claude Code、OpenCode、Cursor 等）正在快速进入生产环境，但一个关键问题一直被忽视：**Agent 框架本身在每次请求中发送了多少"非任务" token？**

每个 token 的框架前缀都是你不能用来处理实际任务的上下文窗口。如果你的 Agent 在用户输入之前就已经消耗了 33,000 个 token，那意味着每次请求都从 200k 窗口的 1/6 处开始。更隐蔽的是，这些前缀 token 中的缓存写入按溢价计费，而缓存读取只按 1/10 价格计费——框架的缓存友好度直接决定了你的账单。

Systima 团队（通过 Meridian 网关）在 API 边界对 Claude Code 2.1.207 和 OpenCode 1.17.18 进行了全量流量审计，用日志代理捕获每个请求的精确 JSON payload 和 API 返回的 usage block，首次给出了系统化的量化数据。

## 技术架构拆解

### 核心设计决策

Systima 的审计方法本身值得学习：

```
harness (Claude Code / OpenCode)
  → logging proxy (捕获 request payloads + response usage)
  → model endpoint (Anthropic API)
```

- **Payload 捕获** = 框架实际发送的内容（系统块、工具 schema、消息），这是 ground truth
- **Usage block** = API 实际计量的数字（input tokens、cache writes、cache reads、output tokens）
- 两者交叉验证：payload 告诉你"发了什么"，usage 告诉你"计了多少费"

测试条件严格控制：
- 双框架均锁定 `claude-sonnet-4-5`（2026-07）
- 基线隔离：空配置、无 MCP 服务器、无用户设置、无 memory、空工作区
- 任务矩阵：T1（一字回复，隔离固定开销）、T2（读文件摘要）、T3（写-跑-测-修循环）
- 零工具变体：剥离工具 schema，单独测量系统 prompt 重量

### 与前版/竞品的关键差异

#### Part I: 基线开销（"说 OK 的成本"）

| 组件 | Claude Code | OpenCode | 倍数差 |
|------|------------|----------|--------|
| System prompt | 27,344 chars, 3 blocks | 9,324 chars, 1 block | ~2.9x |
| Tool schemas | 27 tools, 99,778 chars | 10 tools, 20,856 chars | ~4.8x |
| 首消息 scaffolding | 7,997 chars (`<system-reminder>`) | 无 | ∞ |
| 用户实际 prompt | 22 chars | 22 chars | 1x |
| **首轮 payload（校准后）** | **~32,800 tokens** | **~6,900 tokens** | **~4.7x** |

**关键发现：工具 schema 是主导项。** Claude Code 的 ~33k token 中约 24,000 个来自工具定义，OpenCode 的 ~6,900 中约 4,800 个来自工具定义。Claude Code 的 27 个工具包含了编码核心 + 完整的后台 Agent 和编排套件（CronCreate、Monitor、Task 族、worktree 管理、推送通知），而 OpenCode 仅提供 10 个经典编码工具。

**零工具变体**（剥离所有工具 schema）：
- Claude Code 系统 prompt：26,891 chars ≈ 6.5k tokens
- OpenCode 系统 prompt：8,811 chars ≈ 2.0k tokens
- 即使没有任何工具，Claude Code 的指令集仍是 OpenCode 的 3 倍以上——剩余部分是"行为教义"（语气规则、安全指导、任务管理指令、环境描述）。

#### Part II: 单轮任务 vs 多轮任务

| 指标 | Claude Code | OpenCode |
|------|------------|----------|
| T2（单文件摘要）请求数 | 6 | 4 (+1 标题调用) |
| T2 累计计量 input | ~199,000 tokens | ~41,000 tokens |
| T3（写-跑-测-修）请求数 | 3 | 9 (+1 标题调用) |
| T3 累计计量 input | ~121,000 tokens | ~132,000 tokens |

**反转点**：在多步任务 T3 中，Claude Code 的总开销反而略低于 OpenCode。原因是 Claude Code 将全部工作（2 个文件写入 + 2 个脚本执行）批处理为一次并行工具调用，而 OpenCode 每轮只做一次工具调用。

> **核心公式**: 整任务 input ≈ baseline × 请求数 + 对话增长。大 baseline 但激进批处理的框架，与小 baseline 但串行化的框架，可能落在相近的总成本。

#### 新模型的影响

在 Claude Fable 5 上重跑，差距缩小但模式不变：

| 维度 | Sonnet 4.5 | Fable 5 |
|------|-----------|---------|
| Claude Code 系统 prompt | 27,787 chars | 10,526 chars（减少 62%） |
| Claude Code 工具 schema | 99,778 chars | 82,283 chars |
| OpenCode payload | 跨模型 byte-identical | 跨模型 byte-identical |
| 基线差距 | 4.7x | ~3.3x |

**但多步任务的收敛优势在 Fable 上消失了**：Claude Code 在 Fable 上需要 6 次请求（而非 Sonnet 的 3 次），包括一次 85,686-token 的 mid-session 缓存重写，总开销 298,000 tokens vs OpenCode 的 133,000 tokens。

> **结论**: 批处理优势是模型行为，不是框架常量。

### 缓存效率：54x 差距

这是最被低估的发现：

- **OpenCode**: 请求前缀在每次运行中 byte-identical——只需缓存写入一次，后续读取按 1/10 价格计费
- **Claude Code**: 在 session 中间反复重写数万 token 的 prompt-cache，同一任务比 OpenCode 多写 **54 倍** 的缓存 token

缓存写入按溢价计费，这直接解释了为什么 Claude Code 的使用者仪表板数字持续攀升。

### 放大器（Multipliers）

#### 放大器 1: 指令文件

72KB 生产级 AGENTS.md 加入工作区后：
- 两个框架每次请求各增加 ~20,000 tokens
- OpenCode 计量总数从 13,152 → 33,336（2.5x）
- Claude Code 从 39,005 → 59,243（1.5x）

**陷阱**: Claude Code 2.1.207 忽略 AGENTS.md，只在重命名为 CLAUDE.md 时才读取。OpenCode 两者都认。

#### 放大器 2: MCP 服务器

| 配置 | Claude Code 增量 | OpenCode 增量 |
|------|-----------------|--------------|
| 1 个小服务器 | ~1,000-1,400 tokens/请求 | ~1,000-1,400 tokens/请求 |
| 5 个小服务器 | +4,900 tokens | +6,967 tokens（计量） |
| 工具数变化 | 27 → 69 | 10 → 52 |

#### 放大器 3: 框架模板

BMAD 等故事驱动工作流框架将 slash command 展开为大型 prompt 模板（人格、协议、检查清单）。一个 8,405-char 模板 ≈ 2,100 tokens，进入对话历史后每次请求都重新携带。**框架税 = 模板大小 × 请求数。**

#### 放大器 4: 子 Agent（最大成本放大器）

| 指标 | Claude Code |
|------|------------|
| 直接执行 | 121,000 tokens |
| 分发给 2 个子 Agent | 513,000 tokens |
| **放大倍数** | **4.2x** |

每个子 Agent 都是独立的 Agent，每次轮次都重新读取自己的系统 prompt（3,554 chars）和 24/27 个工具。父 Agent 只消费子 Agent 的返回结果（非完整 transcript），但成本在于子 Agent 自身的全量 bootstrap 被反复发送。

OpenCode 的子 Agent 设计更精简：1,379-char 系统 prompt + 5 个工具。

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Token 成本结构                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  固定成本（每请求必付）                                    │
│  ├── System Prompt    CC: ~6.5k  │ OC: ~2.0k            │
│  ├── Tool Schemas     CC: ~24k   │ OC: ~4.8k            │
│  └── Scaffolding      CC: ~3k    │ OC: 0                │
│  ─────────────────────────────────────────────────────  │
│  基线总计            CC: ~33k    │ OC: ~7k   (4.7x)     │
│                                                         │
│  可变成本（按场景叠加）                                    │
│  ├── 指令文件          +~20k/请求                         │
│  ├── MCP 服务器        +1-1.4k/服务器/请求                │
│  ├── 框架模板          +模板大小 × 请求数                   │
│  └── 子 Agent          +4.2x 总成本（每个子 Agent 独立 bootstrap）│
│                                                         │
│  缓存效率                                              │
│  ├── OpenCode: byte-stable → 一次写入，多次 1/10 读取      │
│  └── Claude Code: mid-session 重写 → 54x 缓存写入溢价      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **大规模生产部署**: 如果你的 Agent 每天处理数千次请求，OpenCode 的 7k 基线 vs Claude Code 的 33k 基线，在 1000 次/天的规模下差异约 26M tokens/天——按 Sonnet 的 input 费率计算，这是显著的月度成本差异。
- **长上下文任务**: 33k 的基线意味着每次请求从 200k 窗口的 1/6 处开始。对于需要大量代码上下文的任务，OpenCode 为你保留了更多可用窗口。
- **预算可控场景**: OpenCode 的 byte-stable 前缀让缓存效率极高，每次请求的实际增量成本可预测。

### 什么场景不值得用

- **个人开发者单 session**: 如果你每天只跑几次 session，token 差异对体验和成本的影响都微乎其微。选你习惯的工具即可。
- **Claude Max 订阅用户**: 如果你使用 Max 订阅（按席位计费而非按 token），token 开销不直接影响你的成本——但上下文窗口占用仍然是约束。
- **需要 Claude Code 独占功能的场景**: Claude Code 的 27 个工具（后台 Agent、worktree 管理、推送通知等）在 OpenCode 中不存在。如果你依赖这些功能，换框架的成本可能超过 token 节省。
- **多步批处理场景（Sonnet 上）**: 在 Sonnet 模型上，Claude Code 的并行批处理能力可能让总成本追平甚至低于 OpenCode。如果你的工作流天然适合批处理，这个优势值得考虑。

### 迁移成本

从 Claude Code 迁移到 OpenCode：
1. **配置迁移**: OpenCode 读取 AGENTS.md 和 CLAUDE.md，Claude Code 仅读 CLAUDE.md——如果你用 AGENTS.md 命名，迁移到 Claude Code 时需注意
2. **MCP 配置**: Claude Code 在 print 模式下会静默忽略 `.mcp.json`，需要显式传 `--mcp-config` 标志
3. **工具差异**: 27 → 10 个工具，失去后台 Agent、worktree 管理等高级功能
4. **子 Agent 行为**: OpenCode 子 Agent 更精简但未在本次测试中完整跑通（通过网关时有问题）

## 对你的意义

作为 Agent 应用开发者，这篇文章的数据直接影响了几个决策：

1. **Agent 框架选型**: 如果你在构建基于 Agent 的生产系统，token 前缀开销是一个可量化的选型维度。OpenCode 在单次请求成本上显著领先，但 Claude Code 在特定场景（Sonnet + 批处理）下可能追平。

2. **指令文件策略**: 72KB 的 AGENTS.md 让基线开销翻了 2.5-4 倍。这意味着你的 prompt 工程不仅要关注质量，还要关注大小。精简指令文件 = 直接降低成本。

3. **子 Agent 的成本意识**: 4.2x 的放大倍数意味着子 Agent 不是免费的并行化——每次分发都是一次全量 bootstrap 的复制。只有在子任务足够复杂、能摊薄 bootstrap 成本时才值得使用。

4. **缓存友好的重要性**: OpenCode 的 byte-stable 前缀设计是一个架构选择的结果——它选择简单性而非灵活性。Claude Code 的动态 scaffolding 注入（随轮次增长）提供了更多上下文但牺牲了缓存效率。这是一个典型的 trade-off。

**建议**: 如果你在用 Claude Code 做生产部署，先跑一次类似的 token 审计（可以用类似的日志代理方法），看看你的实际开销分布。33k 的基线是一个参考点，但你的实际配置（MCP 服务器、指令文件、框架模板）可能让这个数字翻倍。

## 关键数据引用

> "Roughly 24,000 of Claude Code's ~33,000 tokens are tool definitions, versus roughly 4,800 of OpenCode's ~6,900."
> — Systima, Claude Code vs OpenCode Token Overhead Study

> "A 33k-token baseline means every turn starts a sixth of the way into a 200k window before any code enters the conversation."

> "Cumulative metered input reached 513,000 tokens, against 121,000 for the same work done directly. That is a 4.2x multiplier for one modest fan-out."

> "OpenCode's request prefix was byte-identical in every run we captured; it paid to cache its payload once per session and read it back for pennies. Claude Code on the other hand re-wrote tens of thousands of prompt-cache tokens mid-session, run after run, and on the same task wrote up to 54x more cache tokens than OpenCode."

---
[← Back to Deep Dives](./README.md)
