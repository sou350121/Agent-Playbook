---
auto_generated: true
generated_at: "2026-10-31T05:45:39Z"
source_url: "https://github.com/google/elephant-goldfish-model/releases/tag/v0.1.0"
signal_type: "significant_update"
---
# Google 开源 Elephant-Goldfish Model：先写规格，再让「零上下文金鱼」攻击它 (Elephant-Goldfish Model: Spec-Driven Development with Zero-Context Subagent Review)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-31
>
> **项目/工具**: Elephant-Goldfish Model (EGM)
> **链接**: https://github.com/google/elephant-goldfish-model
> **核心定位**: 把「规格先行开发（Spec-Driven Development）」封装成可安装 skill 插件——大象（带着完整项目上下文的 agent）写规格，金鱼（零上下文 subagent）盲审规格，人类做架构取舍。

## ⚡ 快速判断（30 秒读这段就够了）

（快速判断：一句话定位、值得用吗、适合/不适合场景、与竞品差异）

- **一句話定位**：Google 官方开源的 coding-agent 插件，把「先设计文档、后写代码」变成 `/egm-brainstorm` → `/egm-draft` → `/egm-review` 三步可复用流程。
- **現在值得用嗎**：看场景——如果你的 agent 经常「一上来就写代码、然后改到崩」，并且功能确实需要架构决策，值得试；如果只是修一个小 bug，官方自己说别用。
- **適合場景**：中大型功能的规格设计、多轮返工的功能、需要留下「为什么这样设计」文档的团队。
- **不適合場景**：小范围明确的 bug fix、时间只有 20 分钟的紧急修复、没有 subagent 能力的轻量 IDE 插件。
- **與「直接让 agent 写代码」核心差異**：把「评审」从同一个上下文里做，改为**在新会话、零上下文**里由一个专门的 reviewer persona 攻击设计稿——这是它能暴露盲点的关键机制。

## 是什么 / 解决什么问题

Coding agent 有一个结构性缺陷：一旦对话变长，模型会**顺着自己前面的假设继续推理**。前面草率定下的一个决策，会被后面所有代码继承，而模型自己几乎不会回头质疑它。结果就是 Ken 很熟悉的那种体验——agent 交了 300 行代码，你在 review 时发现方向从一开始就错了。

EGM 是一个针对这个缺陷的工程化答案。它是 Dave Rensin 的 Spec-Driven Development（SDD）方法论的实现，被 Google 打包成可安装到 **Antigravity、Claude Code、Claude Cowork、OpenAI Codex、ChatGPT Work** 的插件。README 的说法是「Thousands of Google engineers use EGM」（官方表述，未给出精确数字）。

它把角色拆成三个：

- **Elephant（大象）**：持有项目上下文，负责澄清需求、起草规格。
- **Goldfish（金鱼）**：在新会话里、**不携带之前对话**地审视草稿与引用的源材料，专门找未言明的假设和盲点。
- **人类**：做架构取舍、批准规格，然后才允许实现。

这个拆法的价值在于：**规格文档成为唯一的载体**，人类判断、agent 上下文、reviewer 质疑，都只通过这份 Markdown 交互，而不是通过一段越来越长的聊天记录。

## 技术架构拆解

### 核心设计决策

- **零上下文评审（zero-context review）**：reviewer 只拿到设计草稿和被引用的源材料，拿不到「你是怎么做决定的」这段历史。这是故意的——如果 reviewer 知道你的推理过程，它就会倾向于接受你的推理，而不是独立判断。这是整个项目最有价值的一条设计。
- **Skill 而非 SaaS**：以 plugin/skill 形式分发（`claude plugin marketplace add google/elephant-goldfish-model`），跑在用户自己的 coding agent 里，不自建后端。
- **Persona 与 skill 分离**：`skills/` 放可调用的斜杠命令，`agents/` 放 subagent 的隔离 system prompt。这意味着 reviewer 的人格是可替换、可定制的。
- **1 次 brainstorm 配 6 个视角的 Goldfish swarm**：`/egm-brainstorm` 会 spawn 一个「6-lens Goldfish swarm」对概念做压力测试，产出结构化的 `concepts_brief.md`。
- **产出即文档资产**：规格落在 `docs/designs/` 下，并维护 `SITEMAP.md` 索引。代码只是设计的实现，文档解释「为什么代码长这样」。
- **不强制流程**：官方明确说「Do not forcibly use the design-first process if you believe you can one-shot a simple bug fix」，且各 skill 可乱序使用。

### 与前版/竞品的关键差异

| 维度 | 直接在聊天里让 code agent 写 | EGM |
|------|--------------------------|-----|
| 需求澄清 | 混在实现对话里，容易被忽略 | 独立 stage，产出 `concepts_brief.md` |
| 评审上下文 | 与被评审者同一上下文 | 新会话、零上下文，只看草稿+引用材料 |
| 产出物 | 代码 + 一段聊天记录 | `docs/designs/*.md` + `SITEMAP.md` 索引 |
| 返工成本 | 出错后发现于 code review | 出错时只在 Markdown 里返工 |
| 规格腐化 | 无机制 | `/egm-drift-report` 每周扫描设计与代码漂移 |
| 人机分工 | 人做点评 | 人做批准 + 架构取舍，机器做质疑 |

### 架构/信息流图

```
[人类需求]
    │
    ▼
/egm-brainstorm  ──►  Elephant 澄清概念
    │                    │
    │                    └──► 6-lens Goldfish swarm 压力测试
    ▼
concepts_brief.md
    │
    ▼
/egm-draft  ──►  design_draft.md（逐节暂停，等人反馈）
    │
    ▼
/egm-review  ──►  零上下文会话 + Goldfish persona
    │              检查：完整性 / 清晰度 / 自包含性 / 与代码契合度 / 实施计划
    ▼
人挑选用哪些 findings 处理
    │
    ▼
人类 PR Review（官方：EGM 不替代人工 oversight）
    │
    ▼
Implement（按设计文档施工）
    │
    ▼
/egm-drift-report（每周）──►  检测 doc 与 code 漂移 ──► 人决定改 doc 还是改 code
```

### 项目推荐目录结构

官方建议把设计文档放进固定的 `docs/designs/`，并用一个自定义的 elephant skill 加载项目上下文：

```text
path/to/project
├── _agents/                   # (optional, but recommended)
│   └── skills
│       └── <project>_elephant # Custom skill to load project context.
│           └── SKILL.md
└── docs/
    └── designs/               # EGM design directory
        ├── SITEMAP.md         # An index of design artifacts
        └── FEATURE.md         # A detailed design specification
```

## 实用评估

### 什么场景值得用

- **多轮返工的功能**：如果你发现某个功能在 agent 手里来回改了三四轮还没收敛，说明需求本身没想清楚。EGM 的 brainstorm stage 正好卡在这。
- **需要留下决策解释的代码**：`docs/designs/*.md` 是「为什么」，代码是「什么」。半年后调的人（包括未来的你）读文档比读 diff 快。
- **多人协作**：设计稿走 PR 流程，human review 前置到代码之前，review 成本远低于读一个大 diff。
- **已经用 Claude Code / Codex 的团队**：安装成本近乎零，就是加两个 marketplace 命令。

### 什么场景不值得用

- **小 bug fix**：官方自己说了别用。为一行修复写两份设计文档是浪费。
- **没有 subagent 能力的 harness**：README 明确「Brainstorming and review require a session that can create fresh subagents」。轻量 IDE 插件或纯 chat 界面跑不了。
- **只有十分钟的环境**：整条链路至少 3 次人机往返，紧急热修场景不成立。
- **把 EGM 当质量保证**：它降低方向性错误的概率，但不保证代码正确。测试策略、profiling、可读性规范官方都明说「EGM is not opinionated here」，需要自己接。

### 迁移成本

- **从裸用 coding agent 迁移**：加 plugin → 把既有设计文档整理进 `docs/designs/` → 写一个加载项目上下文的 `<project>_elephant` SKILL.md。官方对既有代码库给了 bootstrapping 章节，实际工作量取决于历史文档的整理情况。
- **从其他 SDD 方案迁移**：低——`concepts_brief.md` → `design_draft.md` → 评审 是通用 artifact 流，主要是文件命名和目录约定对齐。
- **日常成本**：每次功能设计多 2-3 次往返，换来的是实现阶段的返工减少。收益与功能复杂度强相关。

## 对你的意义

Agent-Playbook 一直在收「agent 架构与工程实践」的东西，EGM 是一个少见的、把**人机职责边界**写死在流程里的官方实现。三个可借鉴的点：

1. **零上下文评审是可直接移植的技巧**。无论你用不用 EGM，下次想让另一个 agent 审自己写的东西，**千万不要把推理过程给它**。只给产出物和源材料。这一条比整个插件都值钱。
2. **`/egm-drift-report` 思路**：文档和代码的漂移检测，本质是「拿设计稿去对代码」，很适合写成一个周期性 cron 任务，而不是靠人记。
3. **对 GSD（get shit done）型工作流的提醒**：Ken 自己也经常让 agent 直接一把梭。EGM 的克制点在官方文档那句「Use the right tool for the job」——设计先行是工具，不是信仰。

建议：**观望 + 抽半天试一次**。不用整套接入项目，挑一个你最近返工过的功能，按 `/egm-brainstorm` → `/egm-review` 跑一遍，看金鱼能不能挑出你自己漏掉的假设。能挑出来，就值得正式引入；挑不出来，就只保留「零上下文评审」这一个习惯。

## 关键代码/配置片段

安装（Claude Code）：

```sh
claude plugin marketplace add google/elephant-goldfish-model
claude plugin install egm@egm
```

安装（Codex）：

```sh
codex plugin marketplace add google/elephant-goldfish-model
codex plugin add egm@egm
```

安装（Antigravity CLI）：

```sh
agy plugin install https://github.com/google/elephant-goldfish-model
```

核心三步（Antigravity / Claude Code 需加 `/egm:` 前缀）：

```text
/egm-brainstorm Add webhook delivery to this project.
/egm-draft
/egm-review design_draft.md
```

> 注：AGY CLI 1.4.8 不会自动补全前缀（issue #196），1.4.10 会（issue #220）——官方建议无论如何都带前缀。

每周一次的漂移检查：

```text
/egm-drift-report
```

配置文件与各 harness 的安装细节见仓库 `docs/harnesses.md` 与 `docs/getting_started.md`。

> ⚠️ 版本事实：本文基于仓库 main 分支的 README 与 `docs/getting_started.md`（2026-10-31 读取）。`v0.1.0` release notes 未能成功抓取（GitHub release 页面返回的是 JS 渲染壳），因此本文**未引用任何 v0.1.0 的具体 changelog 条目或性能数据**。如需版本级变更细节：`> TODO: 抓取 https://github.com/google/elephant-goldfish-model/releases/tag/v0.1.0 的实际渲染内容`。

---
[← Back to Deep Dives](./README.md)
