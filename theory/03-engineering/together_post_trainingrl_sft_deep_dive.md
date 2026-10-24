---
auto_generated: true
generated_at: "2026-10-24T05:45:46Z"
source_url: "https://www.together.ai/blog/together-post-training"
signal_type: "significant_update"
---
# Together Post-Training：把后训练从「大厂专属」变成按 GPU 分钟计费的托管服务 (Together Post-Training: Hosted RL/SFT with a User-Defined Training Loop)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-24
>
> **项目/工具**: Together AI Post-Training
> **链接**: https://www.together.ai/blog/together-post-training
> **核心定位**: 一个「训练循环归你、基础设施归平台」的后训练托管服务：你用 SDK 在本地（哪怕笔记本）驱动循环，Together 远端负责分片训练器、采样引擎与权重同步；支持 RL（GRPO 等）与 SFT/DPO，按 GPU 分钟计费。

## ⚡ 快速判断 (30 秒读完这段就够了)

- **一句話定位**：把「RL 环境奖励 + SFT 监督数据」的后训练流程托管化，训练循环由用户代码定义，基础设施由平台接管。
- **現在值得用嗎**：看场景——你已经有明确的 reward 函数 / 多轮 agent 任务，且不想自建 RL infra，就很值得试；只想做标准 SFT+DPO 用现成 job 式微调更省事。
- **適合場景**：多轮 agentic 任务的 RL 后训练、专用小模型替代闭源模型、需要自定义 loss / 自定义课程的实验。
- **不適合場景**：数据规整、只需一次 SFT 的团队；需要绝对数据不出域的组织（远端 GPU 上跑 rollout 与训练器）。
- **與前版/竞品核心差異**：相对 Together 自家 job 式 fine-tuning，多了「训练循环自定义 + RL + 多 LoRA 共享资源」；相对 Tinker API，官方给出**一行 import 替换**的迁移路径。

## 是什么 / 解决什么问题

2026 年，为特定 AI 工作负载训练自有模型已不再是边缘话题。Together 在 blog 中给出的判断很直接：过去大家靠「上下文工程 / harness 工程」去修补模型行为，而现在越来越多 AI-native 公司改为直接训练「专用 agent 模型」，在成本与延迟只有前沿模型一小部分的前提下逼近前沿质量。附带的好处是所有权：产出的 checkpoint 可以部署在任何地方、继续微调、甚至本地跑。

但后训练真正的门槛不在「有没有 GPU」，而在工程细节。Together 自己列出的痛点：数据策展、训练算法、评估协议需要反复迭代；RL 基础设施越来越复杂，**「一次效率优化」和「一个拖慢所有 run 的静默 bug」之间的界限非常细**。前沿实验室各有整支团队分别解决这些问题——这导致很多本可以受益的公司「从未开始」或「开始了就卡住」。

Together Post-Training 的解法是把这些工作收编成服务：抽象的接口保留 ML 开发者熟悉的形状，底下所有计算由平台保证「快、省钱、且最重要的是正确」。

## 技术架构拆解

### 核心设计决策

- **训练循环归用户，重活归平台**：官方文档写明「Your loop runs on any machine, even a laptop」，而分片 trainer、采样引擎、权重同步在 Together 侧运行。这是与 job 式微调最本质的分野。
- **三级资源模型**：`Model Resource`（一组专属 GPU，不与他人抢优先级）→ `Training Session`（同一 base model 上的一次实验，例如一组 LoRA adapter）→ `Trainer` / `Generator` 实例。SFT 场景可以起 0 个 generator 来省钱。
- **异步 RL**：用户自行决定 trainer 参数何时同步给 generator；官方支持异步 RL 以提高两侧 GPU 利用率，特别针对长多轮 agentic rollout。
- **多 LoRA 共享**：多个 LoRA 实验共用一个 Model Resource，跑超参扫描不必为每个配置单独预留 GPU。Dedicated 服务栈也支持 multi-LoRA serving，一次部署内切换 adapter 做并排对比。
- **训练/推理数值对齐作为北极星**：官方点出 RL 结果最常见的坑——训练与推理引擎数值不一致导致策略漂移甚至整轮崩溃；使用 Rollout Routing Replay（引用 arXiv 2510.11370）等手段消除漂移源。
- **生产精度切换保质量**：从多 LoRA 采样切到 FP4 合并推理时，通过算法 + 系统优化保证 checkpoint 质量不塌。

### 与前版/竞品的关键差异

官方文档给出了一张明确的对照表（来源：docs.together.ai/docs/post-training/overview）：

| 维度 | 标准微调（job 式） | Post-Training |
|------|------------------|---------------|
| 运行位置 | Together 跑完整循环（tokenize、batching、loss、LR schedule、checkpoint） | 你的代码驱动循环，远端 GPU 只跑 forward/backward、optim step、sampling |
| 计费 | 按处理 token | 按 GPU 分钟 |
| 数据 | 固定格式 JSONL / 预 tokenize Parquet，上传即校验 | 自建 token 序列与 loss mask，任意形状，运行中可改 |
| 中途控制 | 无（除非取消或早停） | 全量：逐 step 指标、改 LR、重洗数据、自定义停止条件 |
| 损失函数 | 内置 SFT / DPO | 内置 cross-entropy 与 policy-gradient，外加用户代码内自定义 loss |
| 强化学习 | 不支持 | GRPO 及相关 policy-gradient，单轮与多轮皆可 |
| 适用 | 数据规整、要最少代码 | 需要 step 级控制、自定义 loss/课程，或 RL |

### 架构/信息流图

```text
[你的机器 / 笔记本]                         [Together 专属 GPU Model Resource]
 ┌──────────────────────┐                  ┌───────────────────────────────┐
 │ 你的 training loop   │                  │  Trainer（forward/backward,  │
 │  create_session ─────┼─── API ─────────▶│  optimizer step, 权重更新）   │
 │  sample_batch ───────┼─── 请求 ────────▶│  Generator × N（rollout 采样）│
 │  （你的 reward 打分）│                  │  同一 base model 冻结         │
 │  forward_backward ───┼─── loss/grad ───▶│  多 Session ⇒ 多 LoRA adapter │
 │  optim_step ─────────┼─────────────────▶│  weights_sync（参数下发）     │
 └──────────────────────┘                  └───────────────┬───────────────┘
          │                                                 │
          │ 可选：本地算梯度 / 自定义 loss                     ▼
          │                                    checkpoint → Dedicated 部署
          └──────────────────────────────────▶  (multi-LoRA 对比 → 合并 FP4 上线)
```

一次 RL step 的调用序列（文档原文）：`sample_batch` → 本地打分 → `forward_backward` → `optim_step` → `weights_sync`。SFT 与 DPO 不采样补全，因此跳过 `sample_batch` 与 `weights_sync`。

## 实用评估

### 什么场景值得用

- **多轮 agentic RL**：需要模型在多轮环境中调用工具、完成任务后用 verifier 打分。官方明确支持多轮环境训练，且 rollout 引擎复用其 serving 栈（智能缓存与路由降低冗余计算、内存成本有界）。
- **想降低 serving 成本的专用模型**：早期客户 Jack & Jill 的反馈是——用开源模型后训练出的模型在离线评估中「matched a closed-source model's quality」，且 serving 明显更便宜。
- **需要自定义目标函数**：可以在本地 PyTorch 里算 loss，把梯度发回 Trainer；或写自己的 loss 函数基于 log-prob 计算。
- **并行跑大量实验的团队**：多 LoRA 共享 Model Resource，sweep 不按配置数翻倍 GPU。

### 什么场景不值得用

- **只做一次标准 SFT**：job 式微调「upload → submit → 等」，代码量小得多；Post-Training 的自由度在这里是纯负担。
- **数据必须不出域**：训练 token 只能上传到远端 GPU 侧执行，这是结构性的前提，不是配置项。
- **RL 经验为零的团队**：抽象层降低了 infra 门槛，但 reward 设计、策略漂移、课程安排等「算法侧」问题并未被消除；官方也强调很多公司是「开始了然后卡住」。
- **模型可选范围有限**：首发仅覆盖 Muse Spark Open、GLM 5.3、Kimi K3、Qwen 3.8-27B（官方称未来数周扩充）；multi-LoRA 部署仅支持部分 base model（文档：仅部分模型）。若你的目标 base model 不在其中，现在用不了。
- **成本敏感的小实验**：按 GPU 分钟计费（B200 首发八周 $9/GPU-hour），小规模实验下「比 token 计价便宜」的说法只在实验规模扩大后才成立（官方原话：costs drop below token-based pricing **as soon as you scale up**）。

### 迁移成本

官方给出的迁移路径非常干脆：若你已经在用 Tinker API 一类的后训练服务，脚本里只需换一行：

```python
-import tinker
+import together.post_training.tinker as tinker
```

其余保持不动（详见 Tinker migration guide）。若从 Together 自家 job 式微调迁移，则要重写训练循环——不是配置搬家的量级，但 SDK 只有少数几个方法（`create` / `create_session` / `sample_batch` / `forward_backward` / `optim_step` / `weights_sync`），概念负担可控。官方还提供了 cookbook（GRPO on GSM8K、DPO as custom loss、单资源多 LoRA 三个现成配方），首次跑通的上手成本应低于自研。

## 对你的意义

对 Ken 的 AI App 线（RAG 工具链、Agent 工程），这件事的意义不在「要不要立刻后训练」，而在于**「模型塑造」正在从 harness 工程的花钱选项变成可计价的工程环节**。过去团队在 prompt / tool schema / 路由上死磕，很多本质是「这个行为模型学不会，只能靠调用堆」；现在可以量化地比较：继续堆 harness 的边际成本 vs 一次 LoRA RL run 的成本。

具体建议：

1. **观望为主，但先做一个 2 小时实验**。选一个已有明确 verifier 的窄任务（例如基于固定 schema 的工具调用正确率），用 cookbook 的 GRPO 配方跑一次，目的不是出成绩，而是建立内部成本感——GPU 分钟到底怎么花。
2. **先看 Tinker 迁移案例**。如果团队已有社区里成熟的 Tinker 配方，按一行 import 切换，几乎零迁移风险地横向比价。
3. **短期不要把它当作「替代前沿模型」的方案**。它的价值在「专用窄任务上以更低成本逼近前沿质量」，这一点有客户背书；通用能力上仍在追赶。

一点自己的判断：这类服务真正改变的其实是**团队分工**。以前要招一个懂 RL infra 的人才能碰后训练；现在这个位置可以由平台承担，而「领域专家写 reward」变成了新增的瓶颈。瓶颈转移不等于消失——如果 reward 写不好，托管服务只会让你的失败实验跑得更快。

## 关键代码/配置片段

最小 SFT 示例的执行语义（来自官方文档，Python SDK）：

```python
# 伪代码骨架，方法名与调用顺序来自 docs.together.ai/docs/post-training/overview
model = client.create(...)          # 申请 Model Resource（GPU + base model），按 GPU 分钟计费
session = model.create_session(...) # 同一 base model 上的一次实验

for batch in data:
    # RL: completions = session.sample_batch(prompts)
    #     rewards     = your_reward_fn(completions)   # 你的代码打分
    loss = session.forward_backward(batch_or_scored_completions)
    session.optim_step(...)
    # RL 需额外：session.weights_sync() 把新权重下发给 generator
```

官方说明的关键行为：程序退出时 Together 释放 GPU，计费停止——也就是说「忘了关」导致的空转浪费在这种模型下是被设计规避的。

支持的损失：cross-entropy、GRPO、CISPO、DPPO，以及本地自定义目标（算梯度后发回 Trainer）。

部署阶段：checkpoint 可下载、可 fork 到新 session，或推到 Dedicated endpoint；对 GLM-5.3 与 Kimi-K3，需先执行 FP4 推理准备步骤。

> TODO: 首发定价仅披露「前八周 B200 $9/GPU-hour 优惠价」，正式价与各模型吞吐未公布，无法做单位任务成本估算。

---
[← Back to Deep Dives](./README.md)
