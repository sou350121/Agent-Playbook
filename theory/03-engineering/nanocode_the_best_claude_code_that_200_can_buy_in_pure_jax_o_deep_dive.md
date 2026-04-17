---
auto_generated: true
generated_at: "2026-04-17T14:06:08Z"
source_url: "https://github.com/salmanmohammadi/nanocode/discussions/1"
signal_type: "significant_update"
---
# Nanocode：用$200 训练你自己的 Claude Code 风格 Agent (Nanocode: The best Claude Code that $200 can buy in pure JAX on TPUs)

> 🔍 本文由 Moltbot 自动生成 | 2026-04-17
>
> **项目/工具**: nanocode
> **链接**: https://github.com/salmanmohammadi/nanocode/discussions/1
> **核心定位**: 一个用纯 JAX 编写的端到端训练框架，教你从预训练到 SFT 再到 RLHF（DPO）完整复刻 Claude Code 风格的编程 Agent，1.3B 模型成本约$200

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: nanocode 是一个极简的 agentic coding 模型训练框架，用 JAX+TPU 端到端训练你的专属 Claude Code 风格编程助手
- **现在值得用吗**: 是 — 如果你想深入理解 Constitutional AI 训练流程、或需要低成本定制专属编程 Agent
- **适合场景**: 研究 CAI 训练方法、定制特定风格的编程助手、学习 JAX 训练基础设施、低成本实验 agentic behavior
- **不适合场景**: 生产环境直接使用（模型太小）、需要 SOTA 编程能力、无 TPU 访问权限且 GPU 预算有限
- **与 Claude Code 核心差异**: Claude Code 是 Anthropic 的闭源产品；nanocode 是开源训练框架，让你从零训练自己的小型版本

## 是什么 / 解决什么问题

Andrej Karpathy 的 [nanochat](https://github.com/karpathy/nanochat) 项目展示了如何用极简代码训练聊天模型，但 nanochat 专注于通用对话。nanocode 在此基础上做了关键改造：**专门针对 agentic coding 行为进行训练**。

核心问题：预训练的 LLM 只是 next-token-generator，它们压缩了大量知识，但不会遵循指令、不会使用工具、不会与文件系统交互。要让模型成为有用的编程助手，需要：

1. **Templating（模板化）**: 定义特殊 token 来结构化输入输出（user/assistant/tool_call/tool_result）
2. **Tool Interface（工具接口）**: 设计模型可调用的工具（Read/Edit/Grep/Bash）
3. **Constitutional AI（宪法式 AI）**: 用 SOUL 文档定义模型性格，通过 SFT+DPO 对齐行为

nanocode 的价值在于：它把整个流程压缩到约 5.5K 行代码，让你能在 9 小时内、用$200 成本完整跑通从预训练到 DPO 的全流程。这不是一个"开箱即用"的产品，而是一个**教学框架 + 训练基础设施**。

## 技术架构拆解

### 核心设计决策

| 决策 | 理由 | 权衡 |
|------|------|------|
| 纯 JAX 实现 | XLA 编译器性能优秀，TPU 原生支持，代码简洁 | GPU 也能跑但优化较少，学习曲线陡峭 |
| 4 个专用工具（Read/Edit/Grep/Bash） | 覆盖 80% 编程 Agent 操作，降低模型学习难度 | Bash 工具预期模型难以完全掌握 |
| 1:5 代码数据混合比（The Stack-V2 : FineWeb-EDU） | 强化代码 tokenization 效率，牺牲通用文本换取编程能力 | CORE 指标略低于纯通用模型 |
| 4096 context length（vs nanochat 2048） | 支持多轮 agentic 对话 | 训练成本翻倍 |
| Constitutional SFT + DPO 两阶段 | 先教工具使用，再对齐性格 | DPO 对小模型收益有限（作者自述） |
| 小写 + 友好 + 不谄媚的 SOUL | 差异化定位，避免常见 AI 助手话术 | 需要额外数据生成和 critique 循环 |

### 工具调用模板设计

nanocode 定义了 4 个专用工具，每个都有特殊 token 模板：

```
Read:  <|tool_call_start|>Read<|tool_arg|>file_path<|tool_val|>...
                          <|tool_arg|>offset<|tool_val|>...
                          <|tool_arg|>limit<|tool_val|>...<|tool_call_end|>

Edit:  <|tool_call_start|>Edit<|tool_arg|>file_path<|tool_val|>...
                          <|tool_arg|>old_string<|tool_val|>...
                          <|tool_arg|>new_string<|tool_val|>...<|tool_call_end|>

Grep:  <|tool_call_start|>Grep<|tool_arg|>pattern<|tool_val|>...
                          <|tool_arg|>path<|tool_val|>...<|tool_call_end|>

Bash:  <|tool_call_start|>Bash<|tool_arg|>command<|tool_val|>...<|tool_call_end|>
```

关键洞察：工具调用模板嵌套在 assistant 回复内部，模型可以"解释自己在做什么"后再执行工具调用：

```
<|assistant_start|>
i'll search for TODO.
<|tool_call_start|>Bash<|tool_arg|>command<|tool_val|>grep -rn "TODO" src/<|tool_call_end|>
<|assistant_end|>
```

### 与前版/竞品的关键差异

| 维度 | nanochat（前版） | nanocode（本版） | Claude Code（竞品） |
|------|-----------------|-----------------|-------------------|
| 目标 | 通用聊天模型 | 编程 Agent | 生产级编程助手 |
| 上下文长度 | 2048 | 4096 | 200K+ |
| 工具接口 | 无 | 4 个专用工具 | 丰富工具集 |
| 训练数据 | FineWeb 为主 | FineWeb + The Stack-V2 (1:5) | 未公开 |
| 对齐方法 | 无 | Constitutional SFT + DPO | Constitutional AI（多轮迭代） |
| 模型规模 | 124M-1.3B | 124M-1.3B | 未公开（估计数十 B） |
| 成本 | $3-$200 | $3-$200 | 订阅制 $20/mo |
| 代码量 | ~5K 行 | ~5.5K 行 | 闭源 |

### 训练流程架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 1: Tokenizer Training                  │
│  FineWeb-EDU (300 shards) + The Stack-V2 (60 shards)           │
│  → scripts.tok_train (2B chars) → vocab size 32768             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Phase 2: Base Pre-training                     │
│  scripts.base_train --config=configs.d24                       │
│  1.3B params, 10.7B tokens, 10241 steps, ~467 min              │
│  Output: base checkpoint with world knowledge                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│            Phase 3: Constitutional SFT                          │
│  Generator → Critique (SOUL alignment) → Chosen/Rejected pairs │
│  Datasets: tulu-3-sft-personas-code, self-oss-instruct,        │
│            evol-codealpaca, + 2000 long-context rollouts       │
│  scripts.agentic_sft → teaches tool usage + SOUL personality   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                Phase 4: Direct Preference Optimization          │
│  scripts.dpo on preference pairs (chosen vs rejected)          │
│  Accuracy: 0.45 → 0.88, no meaningful BPB regression           │
│  Final output: SOUL-aligned agentic coding model               │
└─────────────────────────────────────────────────────────────────┘
```

## 实用评估

### 什么场景值得用

1. **研究 Constitutional AI 训练流程**: 这是目前最完整的开源 CAI 实现，从数据生成到 DPO 全流程可复现
2. **定制专属编程助手风格**: 你可以写自己的 SOUL.md，定义模型的语气、价值观、行为准则
3. **学习 JAX 训练基础设施**: 代码极简（5.5K 行），适合从 PyTorch 转 JAX 的开发者
4. **低成本实验 agentic behavior**: $34 可训练 477M 模型（1.5 小时），$200 可训练 1.3B 模型（9 小时）
5. **教学/演示用途**: 完整展示"从预训练到 Agent"的全流程，适合课程或 workshop

### 什么场景不值得用

1. **生产环境直接使用**: 1.3B 模型能力有限，作者明确说"struggle with complex bug-fixes"
2. **需要 SOTA 编程能力**: CORE 指标 0.227（vs GPT-2 XL 0.257），且为代码优化牺牲了通用能力
3. **无 TPU 访问且 GPU 预算有限**: 虽然支持 GPU，但优化主要针对 TPU；$200 是 TPU 成本，GPU 可能更高
4. **需要快速上线**: 从训练到部署至少需要数天，且需要调试数据混合比、超参数等
5. **期望"开箱即用"**: 这是训练框架，不是产品；你需要自己跑完整训练流程

### 迁移成本

从其他框架迁移到 nanocode：

| 来源 | 迁移工作 | 预计工作量 |
|------|---------|-----------|
| nanochat | 修改数据混合比、添加工具模板、定义 SOUL | 1-2 天 |
| PyTorch 训练脚本 | 学习 JAX 语法、重写训练循环 | 1-2 周 |
| 直接使用 Claude Code | 需完整训练流程 + 部署基础设施 | 2-4 周 |

从 nanocode 迁移到其他用途：
- 代码库设计为"hackable"，可修改工具接口、SOUL、数据生成逻辑
- 但训练基础设施耦合较紧，拆分需要一定工作量

## 对你的意义

如果你关注 **Agent + UI** 方向（如 Agent-Playbook 追踪的领域），nanocode 提供了几个关键启发：

1. **工具接口设计是 agentic behavior 的核心**: nanocode 的 4 个工具覆盖了 80% 编程操作，这提示我们：好的 Agent 不需要无限工具，而是精心设计的核心工具集
2. **SOUL 文档是性格对齐的 SSOT**: Anthropic 用 SOUL 指导 Claude 训练，nanocode 证明小模型也能通过 SOUL 获得一致性格 — 这对定制垂直领域 Agent 有借鉴意义
3. **Constitutional SFT 的 critique 循环是关键**: 当 generator 无法一次生成对齐输出时，critique → revise 循环能显著提升质量 — 这可以应用到任何需要风格对齐的 Agent 训练
4. **DPO 对小模型收益有限**: 作者观察到 DPO 后 accuracy 从 0.45→0.88，但实际行为改善不明显 — 这提示我们：对于小型垂直模型，SFT 可能比 DPO 更重要

**建议**: 如果你有 TPU 访问权限（Google TRC 提供免费额度），值得跑一次完整流程来理解 CAI 训练细节。如果仅想学习架构，阅读代码 + 文档已足够。

## 关键代码/配置片段

### 训练配置（d24, 1.3B）

```bash
export NANOCODE_BASE_DIR="$HOME/.cache/nanocode"
export MODEL_TAG=d24

# Tokenizer training
python -m scripts.tok_train --max-chars=2000000000
python -m scripts.tok_eval

# Base pre-training
python -u -m scripts.base_train \
  --batch-size=32 \
  --minibatch-size=1 \
  --config=configs.d24 \
  --eval-every=500 \
  --sample-every=500

# Agentic SFT
python -u -m scripts.agentic_sft \
  --batch-size=32 \
  --minibatch-size=1 \
  --eval-every=500 \
  --sample-every=500

# DPO
python -u -m scripts.dpo \
  --batch-size=32 \
  --minibatch-size=1 \
  --eval-every=100 \
  --sample-every=100
```

### 模型规模与成本对照表

| depth | params | CORE | cost | time | MFU | fwe bpb | sv2 bpb |
|-------|--------|------|------|------|-----|---------|---------|
| d12 | 135M | 0.090 | $3 | 9 min | 17.4% | 0.956 | 0.689 |
| d20 | 477M | 0.170 | $30 | 1.4 hrs | 45.2% | 0.838 | 0.533 |
| d24 | 1.3B | 0.227 | $200 | 9.3 hrs | 52.5% | 0.759 | 0.445 |

### SOUL 文档示例（节选）

作者的 SOUL 定义（[完整链接](https://gist.github.com/salmanmohammadi/7583d2c47998570ab50a7196dbb53c55)）：
- 只用小写（专有名词除外）
- 温暖友好但不谄媚
- 只遵循精确指令，不主动扩展
- 简短解释行动，不冗长

---
[← Back to Deep Dives](./README.md)
