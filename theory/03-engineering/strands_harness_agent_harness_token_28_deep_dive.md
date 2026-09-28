---
auto_generated: true
generated_at: "2026-09-28T06:46:23Z"
source_url: "https://strandsagents.com/blog/introducing-strands-harness/"
signal_type: "significant_update"
---
# Strands Harness 开源：通用 Agent Harness 如何靠上下文管理把 token 成本压到同模型低 28% (Strands Harness: A General-Purpose Agent Harness with 28% Lower Token Cost)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-28
>
> **项目/工具**: Strands harness (strands-agents/harness-sdk)
> **链接**: https://strandsagents.com/blog/introducing-strands-harness/
> **核心定位**: 一个"装配好"的通用（非专用编码）agent harness —— 一行代码即可拿到带默认 prompt caching / 上下文管理的生产级 agent，官方声称在同模型六项 benchmark 上比 Claude Code / Codex 等省 28% 成本且精度基本持平。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：Strands harness = `create_harness()` 一行调用 → 自带 shell/文件/web 工具、上下文卸载、长期记忆、子 agent、skill 加载的通用 agent，覆盖从本地到云的部署。
- **現在值得用嗎**：**看场景**。如果你在自建 agent loop 且在意 token 账单，值得立刻做 A/B；如果你只是想要最好的编码 agent，直接用 Claude Code / Codex 更省事。
- **適合場景**：自研 agent 产品、需要在任意云/任意模型上跑、想把 token 成本作为一等问题来优化的团队。
- **不適合場景**：只想做纯 coding agent 的开发者；强依赖 Anthropic/OpenAI 官方 harness 生态工具链的用户；需要极致精度且不信任"截断式"上下文管理的场景。
- **與 Claude Code/Codex 核心差異**：Strands harness 是**通用目的**（general-purpose）而非编码专用，且**默认就把 prompt caching + 上下文管理打开**；官方数据是同模型下省 28% 成本。

## 是什么 / 解决什么问题

做 agent 的人有一个共同的落差体验：用 Claude Code 或 Codex 时，本地体验"just works"——工具、上下文、缓存、续跑全都替你调好了；可一旦自己动手写 agent，就得从零把一堆 primitives 接对，才能勉强复现那种"它自己就能跑起来"的感觉。Strands 团队把这件事总结为：builders 想要把 Claude Code / Codex 那套 harness 搬到云端，但"build your own agent = on your own"。

Strands harness 要解决的正是这个落差。它是一个**已经装配完成的 state-of-the-art agent harness**：目标是通用 agent，而不是编码 agent。你只需要一行 Python 或 TypeScript 就能让它跑起来，并且可以在本地或任意 provider 上部署。它开源，Apache 2.0 许可。核心卖点有两层：一是**省成本**（对照同模型下其他主流 harness，token 成本更低而精度大致持平），二是**默认值即最优**（prompt caching、上下文管理、记忆、会话全部预置好）。

背景上，Strands 是 AWS 的 agent SDK 生态（仓库内同时包含 `strands-py` / `strands-ts` SDK、`harness-py` / `harness-ts` harness、`strands-cli` 以及 MCP server）。这次发布的 harness 是把底层 SDK 的能力"打包成一个有明确定义的默认配置"，让你先用默认值跑通，再逐层下沉到 SDK 自定义。截至抓取时该 monorepo 约 8,498 stars。

## 技术架构拆解

### 核心设计决策

- **默认开启 prompt caching + 上下文管理**。这是省 28% 成本的直接来源。官方明确说"我们的默认 context management 大体上驱动了 token 效率和精度"。
- **上下文管理三件套（官方给的三个具体阈值）**：
  - **工具结果超过约 1500 token 就截断**；
  - **上下文窗口占用超过 85% 触发 summarization（compaction）**；
  - **溢出时在 loop 内做 context recovery**。
- **用"模型已经会用的 primitives"，而非每个任务定制工具**：内置 shell、file（read/write/edit）、web 工具——主张给模型它熟悉的原语，而不是为每个场景写 bespoke tool。
- **工厂函数 + 可逐层替换**：`create_harness()` 返回一个装配好的 agent；你可以覆盖任意默认值、换模型、加工具，甚至一路下沉到 Strands Harness SDK。官方强调"the code is yours"。
- **任意模型 / 任意云**：Bedrock、Anthropic、OpenAI、Google，以及本地 Ollama、LiteLLM；部署可在任何 Linux 容器上（Modal、Cloudflare Containers、Azure Container Apps、Google Cloud Run、Amazon ECS、Amazon Bedrock AgentCore）。
- **自管理上下文窗口**：把笨重的工具结果 offload 到文件，并缓存每次请求中可复用的部分，以省时间与成本。

### 与前版/竞品的关键差异

| 维度 | Claude Code / Codex（参照） | Strands harness |
|------|--------------------------|-----------------|
| 定位 | 编码 agent | **通用目的** agent（非编码专用） |
| 同模型六项 benchmark 成本 | 基准 | **低 28%**（官方，跨 Claude/GPT 同模型对比） |
| Fable 5 上 vs Claude Code | 基准 | **成本低 77%，Terminal Bench 2.1 分数更高** |
| 上下文管理 | 各自实现 | 默认：>1500 token 工具结果截断、>85% 触发压缩、loop 内 recovery |
| Prompt caching | 依 provider/harness | 默认 `caching="auto"` 打开 |
| 部署形态 | 本地优先 | 本地 or 任意支持 Linux 容器的云 |
| 模型锁定 | 偏自家 | 模型无关（Bedrock/Anthropic/OpenAI/Google/Ollama/LiteLLM） |
| 许可 | 闭源产品 | **Apache 2.0 开源** |

> 数据来源：官方 blog（`strandsagents.com/blog/introducing-strands-harness/`）与 GitHub release notes。这些 benchmark 为**团队自报**，官方承诺后续会发跟进论文；在论文出现前，28% / 77% 这两个数字应视为**待第三方复现**。

### 架构/信息流图

```text
                    ┌───────────────────────────────────────────┐
                    │           create_harness() / CLI           │
                    │  (Python: create_harness  ·  TS: createHarness) │
                    └───────────────────┬───────────────────────┘
                                        │ 装配默认值
              ┌─────────────────────────┼─────────────────────────────┐
              ▼                         ▼                               ▼
   ┌──────────────────┐   ┌───────────────────────────┐   ┌────────────────────┐
   │  Model Provider  │   │   Built-in Tools          │   │  Context Manager   │
   │ Bedrock/Anthropic│   │ shell · read · write ·    │   │ · >~1500 token 截断 │
   │ OpenAI/Google/   │   │ edit · web_fetch ·        │   │ · >85% 触发 compaction│
   │ Ollama/LiteLLM   │   │ web_search · programmatic │   │ · 溢出则 loop 内 recovery│
   └──────────────────┘   │ _tool_caller · subagent   │   └────────────────────┘
                          └───────────────────────────┘
                                        │
              ┌─────────────────────────┼─────────────────────────────┐
              ▼                         ▼                               ▼
   ┌──────────────────┐   ┌───────────────────────────┐   ┌────────────────────┐
   │ Memory (默认 on) │   │ Sessions / Skills         │   │ Built-in Plugins   │
   │ ./.agent/memory  │   │ ./.agent/sessions         │   │ todos · environment│
   │                  │   │ ./.agent/skills           │   │                    │
   └──────────────────┘   └───────────────────────────┘   └────────────────────┘
                                        │
                                        ▼
              ┌──────────────────────────────────────────────────┐
              │  部署：任意 Linux 容器（Modal / Cloudflare /      │
              │  Azure Container Apps / Cloud Run / ECS / AgentCore）│
              └──────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

- **自建 agent 且 token 成本敏感**：如果你现在手写 agent loop，先拿 `create_harness()` 和你现有实现做同任务 A/B，重点对比 token 消耗与任务成功率。省 28% 在长会话、长工具输出场景里会放大。
- **需要在多云/多模型间迁移**：模型无关 + 容器部署意味着后端可换、代码不变。这对"先在 Bedrock 上验证，再迁到自建 OpenAI 栈"的团队很实用。
- **要把 Claude Code/Codex 那种体验搬到云上**：harness 提供了"本地跑通、再远程启动"的路径（官方演示里有人基于它做了远程唤起 harness 的桌面 app）。
- **喜欢"先默认后自定义"的迭代方式**：一行起跑，再逐层替换组件，降低早期搭建成本。

### 什么场景不值得用

- **只做纯编码 agent**：博客自己也说它是 general-purpose 而非 coding agent。若你就是要最好的编码 agent，Claude Code / Codex 的专用调优未必输。
- **对精度极度敏感、不接受截断**：>1500 token 工具结果被截断、>85% 触发压缩，本质是用信息损失换成本。需要完整保留长文档/长日志的场景要先验证是否会丢关键信息。
- **强依赖 AWS 生态之外的东西**：虽 Apache 2.0 开源，但项目出身 AWS/Strands 生态，默认模型是 Bedrock 路径（见下），团队若刻意避免 AWS 依赖需额外评估。
- **benchmark 数字要用于对外决策**：28% / 77% 目前是团队自报、论文未出，**不要直接写进采购/路线文档**，等第三方复现。

### 迁移成本

- **从零自建 loop → Strands harness**：低。`pip install strands-harness` 后 `create_harness()` 即可跑；把现有工具接进来用 `tools=` 参数，MCP 用 `mcp_servers=`。
- **从 Claude Code / Codex → Strands harness（作为库嵌入）**：中等。要重写"运行环境"逻辑（会话目录、记忆目录、权限干预），但工具原语（shell/file/web）概念相通。
- **从 Strands SDK 老代码 → harness**：低到中。harness 是 SDK 的上层封装，可以先把 harness 默认值覆盖成你的现有配置，再逐步下沉。

## 对你的意义

结合你的两条线：

- **AI 应用开发（Agent + UI 方向）**：这个工具正好落在你的主战场。它把"harness 即产品"这件事做成了一行调用的组件，对你的 agent builder / visual workflow 思路有直接借鉴价值——尤其是**把上下文管理的三个默认阈值（1500 token 截断 / 85% 压缩 / 溢出 recovery）产品化成可见、可调的配置项**这个做法。建议**立刻试跑**：用你手头一个长上下文 agent 任务，对比 token 账单。
- **跨领域交叉（VLA × Agent）**：harness 的"工具原语 + loop 内 context recovery + subagent"设计，与你在看的 VLA / 具身 agent 系统在**执行循环与上下文预算管理**上是同一类问题。世界模型 + VLA 的后训练若涉及长轨迹规划，这里关于"什么时候截断、什么时候压缩、什么时候恢复"的工程经验值得借鉴。
- **是否落地**：**观望但动手验证**。先复现它的成本声明，再决定是否引入；benchmark 论文出来前，把它当"值得借鉴的架构样本"而非"已证实的省钱方案"。

## 关键代码/配置片段

安装（官方）：

```bash
# Python
pip install strands-harness
# TypeScript
npm install @strands-agents/harness
# 交互式 CLI
npm install -g @strands-agents/cli
```

最小用法（官方 README）：

```python
from strands_harness import create_harness

agent = create_harness()
agent("Find the slowest test in this repo and explain why it's slow")
```

```typescript
import { createHarness } from '@strands-agents/harness'

const agent = await createHarness()
await agent.invoke("Find the slowest test in this repo and explain why it's slow")
```

指定 provider（官方 blog 示例）：

```python
from strands_harness import create_harness

agent = create_harness(model="bedrock/global.anthropic.claude-opus-5")
agent("Research the top three vector databases, compare pricing and limits, and write it up in comparison.md")
```

工厂默认值一览（来源：官方配置参考页 `docs/user-guide/harness/reference/configuration/`）：

| 参数 | 默认值 | 作用 |
|------|--------|------|
| `model` | `bedrock/global.anthropic.claude-opus-4-8` | provider/模型名或 Model 实例 |
| `effort` | `"auto"` | 推理力度；`low/medium/high/off` |
| `builtin_tools` | `shell, read, write, edit, web_fetch, web_search, programmatic_tool_caller, subagent` | 内置工具集 |
| `builtin_plugins` | `["todos", "environment"]` | 内置功能插件 |
| `caching` | `"auto"`（开） | prompt caching（provider 支持时） |
| `context_manager` | `"auto"` | 上下文管理与卸载 |
| `memory` | `on`（`./.agent/memory`） | 文件式长期记忆 |
| `session` / `skills` | `./.agent/sessions` / `./.agent/skills` | 会话持久化 / Agent Skills 扫描目录 |

> TODO: 默认模型 id 在官方文档写作 `...claude-opus-4-8`，而 blog 示例用 `...claude-opus-5`，两处命名不一致，**待确认**官方当前默认值。
> TODO: 内置工具 `programmatic_tool_caller` 与 `subagent` 的具体行为，官方配置页未展开，需查阅 tools 指南后再写入。

---
[← Back to Deep Dives](./README.md)
