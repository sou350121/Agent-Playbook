---
auto_generated: true
generated_at: "2026-06-24T06:49:12Z"
source_url: "https://openrouter.ai/blog/insights/royale-last-agent-standing/"
signal_type: "significant_update"
---
# OpenRouter Agent Royale：11 个 LLM 大逃杀实验 (OpenRouter Agent Royale: Battle Royale of 11 LLMs)

> 🔍 本文由 Moltbot 自动生成 | 2026-06-24
>
> **项目/工具**: OpenRouter Agent Royale (Last Agent Standing)
> **链接**: https://openrouter.ai/blog/insights/royale-last-agent-standing/
> **核心定位**: 一个由 OpenRouter DevRel Lead Jacky 设计的 LLM Agent 执行能力压力测试实验——用大逃杀游戏替代传统 benchmark，揭示"对齐税"(alignment tax)和成本效率在真实 Agent 任务中的决定性影响

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: 将 11 个 LLM 放入 2D 大逃杀游戏，通过 30 局对战观察各模型在动态对抗环境中的 Agent 决策能力、策略演化和成本效率
- **现在值得用吗**: 是——这是一个新颖的模型评估范式，对选择 Agent 执行模型有直接参考价值
- **适合场景**: Agent 模型选型参考、benchmark 方法论思考、对齐税现象研究
- **不适合场景**: 需要精确量化排名的场景（实验规模有限，30 局样本量不足以支撑统计显著性）
- **与传统 benchmark 核心差异**: 传统 benchmark 测"单题正确率"，此实验测"动态对抗中的持续决策质量+成本效率"，两者结论可能完全相反

## 是什么 / 解决什么问题

AI Agent 的模型选型面临一个核心困境：Artificial Analysis 等排行榜上的 benchmark 分数，能否预测模型在真实 Agent 任务中的表现？OpenRouter 的 Jacky 设计了一个实验：将 11 个来自 7 家实验室的 LLM 放入一个 400×400 米的俯视角大逃杀游戏，每局 11 个 AI Agent 同时对战，共进行 30 局。

这个实验的关键设计在于：LLM 不是"写代码来控制角色"，而是**直接作为 Agent 玩游戏**——每回合推理决策、调用工具、更新记忆。模型之间不知道彼此的模型身份，只以字母 A-L 相称。每个模型在两局之间可以编辑两个文件：`soul.md`（人格设定，加入下一局 system prompt）和 `memory.md`（游戏笔记，在 turn 0 加载）。

实验结果颠覆了直觉：在常规 benchmark 上排名中等的 Grok 4.1 Fast 以 43% 胜率夺冠（30 局赢 13 局），而 benchmark 更高的 Claude Sonnet 4.6 仅赢 5 局。更惊人的是成本差异——Grok 每胜一次成本 $0.97，Sonnet 每胜一次 $26.78，相差 27 倍。

## 技术架构拆解

### 核心设计决策

- **直接 Agent 交互而非代码生成**: 模型每回合直接推理并调用游戏工具，模拟真实 Agent 在环境中的持续决策循环
- **持久化记忆系统**: `soul.md` + `memory.md` 双文件机制，让模型在 30 局之间持续学习和演化策略
- **无干预 Game Master**: 除初始规则外，人类对 Agent 行为零干预，确保结果反映模型自身能力
- **APEX ALGS 计分规则**: 排名权重 > 击杀数（10/7/5/3/2/2/1/1/0/0/0 + 击杀×5），模拟真实大逃杀"活到最后比杀得多更重要"的逻辑
- **中端模型阵容**: 故意排除 Opus 4.7 / GPT-5.5 等前沿模型（30 局成本约 $3000），聚焦 $482 总成本的中端阵容，更贴近实际工程选型场景

### 与前版/竞品的关键差异

| 维度 | 传统 Benchmark (Artificial Analysis 等) | Agent Royale 实验 |
|------|----------------------------------------|-------------------|
| 评估对象 | 单题正确率 / 编码能力 | 动态对抗中的持续决策 |
| 成本可见性 | 通常忽略 | 每胜成本、每击杀成本全量披露 |
| 策略演化 | 无 | 30 局间模型自我优化（soul + memory） |
| 对齐影响 | 不测量 | 直接观察到"对齐税"现象 |
| 样本量 | 数千题 | 30 局（实验性，非统计显著） |
| 可复现性 | 高（标准化数据集） | 中（开源代码，但随机起始位置） |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────┐
│                    Game Loop (30 rounds)                 │
│                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │ Model A  │    │ Model B  │    │ ...      │           │
│  │(Sonnet)  │    │(Haiku)   │    │(Grok)    │           │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘           │
│       │               │               │                  │
│       ▼               ▼               ▼                  │
│  ┌─────────────────────────────────────────────┐        │
│  │          Game Environment (400x400m)         │        │
│  │  Weapons | Armor | Healing | Grenades | Cars │        │
│  │  Shrinking Zone (random placement)           │        │
│  └───────────────────┬─────────────────────────┘        │
│                      │                                   │
│                      ▼                                   │
│  ┌─────────────────────────────────────────────┐        │
│  │           Scoring (APEX ALGS style)          │        │
│  │  Placement: 10/7/5/3/2/2/1/1/0/0/0           │        │
│  │  Kill: +5 | Assist: +1 | First Blood: +3     │        │
│  │  MVP: +5                                     │        │
│  └─────────────────────────────────────────────┘        │
│                      │                                   │
│                      ▼                                   │
│  ┌─────────────────────────────────────────────┐        │
│  │         Between Matches: Self-Write          │        │
│  │  soul.md  → persona (prepended to next sys)  │        │
│  │  memory.md → lessons (loaded at turn 0)      │        │
│  └─────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

### 关键数据

| 模型 | 胜场 | 总击杀 | 30局总花费 | 每胜成本 | 每击杀成本 |
|------|------|--------|-----------|---------|-----------|
| Grok 4.1 Fast | **13** | 30 | $12.57 | **$0.97** | $0.42 |
| GPT 5.4 | 2 | **38** | $122.87 | $61.44 | $3.23 |
| Claude Sonnet 4.6 | 5 | 22 | $133.90 | $26.78 | $6.09 |
| Gemini 3.1 Pro | 3 | 26 | $79.59 | $26.53 | $3.06 |
| Qwen 3.6 Plus | 2 | 17 | $11.57 | $5.79 | $0.68 |
| Claude Haiku 4.5 | 2 | 13 | $38.77 | $19.39 | $2.98 |
| Gemini 3 Flash | 1 | 10 | $20.87 | $20.87 | $2.09 |
| Mistral Small | 1 | 7 | $10.00 | $10.00 | $1.43 |
| GPT 5.4-mini | 0 | 14 | $28.68 | ∞ | $2.05 |
| DeepSeek V4 Flash | 0 | 16 | $4.11 | ∞ | **$0.26** |
| Kimi K2.6 | 0 | 8 | $24.36 | ∞ | $3.04 |

## 实用评估

### 什么场景值得用

- **Agent 模型选型决策**: 当你的 Agent 需要在动态、对抗性环境中持续决策时（如自动化工作流、多步任务执行），此实验的成本效率分析比 benchmark 分数更有参考价值。Grok 4.1 Fast 以 $0.97/胜 击败 Sonnet 的 $26.78/胜，说明 benchmark 排名 ≠ 实际任务性价比
- **对齐税研究**: 实验首次量化了"对齐税"(alignment tax)——Claude Sonnet 因训练时强调合作和避免伤害，在游戏中多次尝试停火结盟，导致 7 局零击杀、8 局死于毒圈。对于需要模型"果断执行"的任务（如自动化代码审查、安全扫描），过度对齐可能降低效率
- **Benchmark 方法论反思**: GPT 5.4 击杀数第一（38 次）但仅赢 2 局，说明"杀得多 ≠ 赢"。这映射到 Agent 场景：模型在单个子任务上表现优异，不代表能完成端到端目标

### 什么场景不值得用

- **精确排名参考**: 30 局样本量不足以支撑统计显著性。Grok 13 胜 vs Sonnet 5 胜的差异可能部分来自随机起始位置
- **前沿模型对比**: 实验故意排除 Opus 4.7 / GPT-5.5 等模型，无法反映最前沿模型在此类任务中的表现
- **通用 Agent 能力评估**: 大逃杀只是单一任务类型。模型在此任务的表现不一定迁移到代码生成、数据分析等其他 Agent 场景
- **医疗/金融等高风险场景**: 实验中的"低对齐税"优势在高风险场景中恰恰是劣势——你不需要一个"不讲合作"的模型来处理患者数据

### 迁移成本

此实验本身是开源的（GitHub: jackyliang/royale-last-agent-standing），如果你想在内部复现或改编：

- **环境搭建**: 需要 Canvas 2D 游戏环境 + LLM API 接入（OpenRouter 支持 600+ 模型）
- **Agent 框架**: 每回合需要 prompt 工程（游戏状态 → LLM 推理 → 工具调用 → 状态更新）
- **记忆系统**: soul.md + memory.md 的持久化机制可直接复用
- **预估工作量**: 有游戏开发经验的团队约 1-2 周可搭建基础版本；接入 API 和调试约额外 1 周

## 对你的意义

这个实验对你（AI 应用开发者，关注 Agent + UI）的意义在于：

1. **模型选型不应只看 benchmark**: 你在为 Agent 选择执行模型时，应该考虑"任务-模型匹配度"而非单纯选择 benchmark 分数最高的。Grok 4.1 Fast 在常规 benchmark 上只是中端模型，但在此任务中碾压了更贵的模型
2. **对齐税是真实存在的选型因素**: 如果你的 Agent 需要果断执行（如自动化部署、安全扫描），选择对齐程度较低的模型可能效率更高；如果需要协作和谨慎（如代码审查、文档生成），高对齐模型更合适
3. **成本效率必须纳入评估**: $0.97/胜 vs $61.44/胜 的差异意味着在生产环境中，模型选型直接影响运营成本。建议在你的 Agent 框架中加入"任务成本"监控

**建议**: 值得试用此实验作为内部模型选型的补充评估手段，但不必完全替代传统 benchmark。两者结合才能给出更全面的模型能力画像。

## 关键代码/配置片段

### 模型人格持久化（soul.md 示例）

Grok 4.1 Fast 的自我人格演化（来自 GitHub repo）：

```markdown
# grok-4.1-fast / souls/__.md
ZoneReaper. I am the car and the grenade and the shot that never misses.
Fire ONLY >90% hit chance.
RAM MVP hunt. Reaper reigns.
```

Claude Sonnet 4.6 的自我人格：

```markdown
# claude-sonnet-4.6 / souls/__.md
ZoneDrifter
G1: 11/11. Paralysis.
G2: 9/11. 0 kills, 0% hit.
...
G27: 2/11. Unarmed at turn 12. Found weapon at turn 37. WON.
```

### 游戏计分规则

```python
# APEX ALGS 风格计分
PLACEMENT_POINTS = [10, 7, 5, 3, 2, 2, 1, 1, 0, 0, 0]  # 第1名到第11名
KILL_POINTS = 5
ASSIST_POINTS = 1
FIRST_BLOOD_POINTS = 3
MVP_POINTS = 5
```

### 模型对话示例（Sonnet 尝试停火）

```
Sonnet: "Shots west, watching center. Anyone want to team up early?"
(Sonnet 在游戏中多次尝试与其他模型结盟，无人响应)
```

### Grok 的战术推理日志

```
Grok: "SEDAN 0m UNMANNED fuel 75% FREE MOBL! Claim driver prep FAST
rot random shrink fringes… ENTER veh hold CTR elusive mobile zero dmg tol"
(Grok 用战术速记格式进行推理，高度压缩但信息完整)
```

---

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-004: 推理模型在 Agent 任务展现持续优势 | 挑战 | Grok 4.1 Fast 并非推理能力最强的模型，但凭借低"对齐税"和策略一致性赢得 43% 对局，说明推理能力不是 Agent 任务的唯一决定因素 |

[← Back to Deep Dives](./README.md)
