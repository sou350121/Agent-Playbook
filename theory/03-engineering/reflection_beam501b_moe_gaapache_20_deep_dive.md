---
auto_generated: true
generated_at: "2026-10-24T09:01:11Z"
source_url: "https://ollama.com/blog/reflection-beam"
signal_type: "significant_update"
---
# Reflection Beam：501B 开源权重 MoE 代理编码模型正式 GA（Apache 2.0）(Reflection Beam: A 501B-A23B Open-Weight MoE for Long-Horizon Agents)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-24
>
> **项目/工具**: Reflection Beam
> **链接**: https://reflection.ai/blog/beam-is-available
> **核心定位**: Reflection 的首个开源权重模型——501B 总参数 / 23B 激活参数的稀疏 MoE，主打「token 高效」的长程编码与 agentic 工作负载，Apache 2.0 释出权重 + 一套 40 家伙伴的「agent 开放操作系统」生态

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：一个以「省推理 token」为第一卖点的开源权重 agent 模型，配套自研 harness（Mirror CLI）与一整套推理/微调/RL 集成。
- **現在值得用嗎**：看場景。若你已经在跑本地或私有云的 coding agent、且对每任务 token 成本敏感，值得立刻做 A/B；如果只是想要一个「平替 GPT-6 Astra」的通用模型，先等等。
- **適合場景**：长程 agent 编排（多步工具调用）、SWE 类修 bug 任务、需要 1M 上下文吃下整个仓库、企业内网/air-gapped 部署、基于开源权重的后训练。
- **不適合場景**：纯中文/多语业务（模型「predominantly English」）、需要视觉/多模态输入（纯 text-in/text-out）、追求最低单次延迟的轻量问答。
- **與競品/前版核心差異**：官方口径是「达到头部开源模型同等解题质量，但推理阶段 token 用量约为其 1/3」——省 token 而非拼裸分，这是它真正想打的仗。

## 是什么 / 解决什么问题

开源权重模型这两年陷入一个隐性军备竞赛：每一代都把 benchmark 分数往上抬几个点，但代价是推理时「想得更多」——思维链越拉越长，token 消耗线性膨胀。对一次性的问答这不致命，对**长程 agent** 就变成了钱的问题：一个跑 200 步的 coding agent，每步多烧几千个思考 token，成本曲线是指数级的感受。

Reflection 的 Beam 就是冲着这个痛点来的。它是一个稀疏 MoE：501.3B 总参数，每 token 只激活 23.4B，52 层（3 层 dense + 49 层 MoE），256 个专家，152k 词表，1M 上下文，知识截止 2026-06-30。这几组数字本身不稀奇——稀奇的是它同时打出了三张牌：

1. **Token 效率**：官方模型卡明写「以约 3 倍更少的推理期推理 token 达到与头部开源模型相当的解题质量」。
2. **Apache 2.0 权重**：BF16 / FP8 / NVFP4 三种精度 + 一个投机解码 draft 模型一起放出来，不是"研究预览"式的半开放。
3. **Harness 与模型共同训练**：它跟自研的 Mirror CLI 一起训，同时也验证过 Pi、OpenCode、Hermes 等第三方 harness——这点很关键，因为 agent 能力很大一部分其实长在 harness 里。

2026-10-16 正式 GA，Ollama 作为 day-zero 伙伴提供限时免费云端端点（`ollama run beam:cloud`），且带零数据保留（ZDR）。

## 技术架构拆解

### 核心设计决策

- **稀疏 MoE 而非 dense**：501B 总容量换知识广度，23B 激活换单 token 成本。这是当下开源前沿模型的标准解法，Beam 只是把激活比例压在 4.7% 左右。
- **Gated GQA + Sliding Window Attention**：1M 上下文的工程基础。滑窗注意力让长上下文的 KV 开销可控，门控 GQA 则在质量与显存之间折中。
- **token 效率作为第一目标**：模型卡把「token-efficient reasoning」放在 Primary capabilities 第一位，说明训练目标里显式加了对推理长度的惩罚/奖励——这通常意味着更激进的 RL 奖励设计，而不是简单的 SFT。
- **三种数值格式同时首发**：BF16/FP8/NVFP4 都给出完整 benchmark，等于把「量化后掉多少分」这个黑箱提前公开了（见下表）。
- **harness 优先**：Mirror CLI 用 Python 前端 + Rust agent core 的分离架构，官方理由很坦诚——「保持 core 最小化，让它同时充当干净的评估面（evaluation surface）」。换句话说，他们想避免"harness 把模型分数抬上去"的评估污染。
- **RL 规模**：官方披露最大规模 RL 训练跑了约 **13 亿个 sandbox**（训练 + 评估 + 消融）。这个数字量级说明 agentic RL 已经是重资产工程，不是小团队能复现的。

### 与前版/竞品的关键差异

| 维度 | 主流开源前沿模型（普遍做法） | Reflection Beam |
|------|--------------------------|-----------------|
| benchmark 叙事 | 拼 SWE-bench 裸分 | 拼「同等质量下的 token 用量」 |
| 推理长度 | 随思考深度线性膨胀 | 官方称约 1/3 token 达到同等质量 |
| 权重开放 | 多为 BF16 为主，量化第三方做 | BF16/FP8/NVFP4 一并给出 + draft 模型 |
| 部署路径 | 权重 + 少数推理框架 | 40+ 伙伴，含 Dell/HPE 的本地 air-gapped 交付 |
| Harness 关系 | 模型与 harness 解耦 | 与 Mirror CLI 共训，另验证 Pi/OpenCode/Hermes |
| 上下文 | 128k–1M 不等 | 1M |
| 语言覆盖 | 多语 | 主要英文（明确写在模型卡） |

### 架构/信息流图

```
                  ┌─────────────────────────────┐
  开发者终端 ───▶  │  Mirror CLI                 │
                  │  ├─ Python 前端（prompt/    │
                  │  │   skills/extensions）    │
                  │  └─ Rust agent core ────────┼──▶ 模型调用
                  └─────────────────────────────┘    （本地 / 托管 /
                          │  审批 / steer /          三方云 / 私有）
                          ▼  cancel
             ┌────────────────────────────────────────┐
             │  Beam 501B-A23B MoE                    │
             │  49 层 MoE + 3 层 dense，256 experts   │
             │  1M ctx · Gated GQA + Sliding Window   │
             └────────────────────────────────────────┘
                          │
        ┌─────────────────┼──────────────────┐
        ▼                 ▼                  ▼
   vLLM / SGLang    Transformers /        NVIDIA Dynamo
   TokenSpeed       Unsloth / Axolotl     （day-zero 支持）
                          │
                          ▼
             后训练：NeMo RL / Miles / TRL / SkyRL
             环境标准：OpenEnv（未来 RL 采用）
```

## 实用评估

### 什么场景值得用

- **长程 coding agent**：官方 Terminal Bench v2.1 拿 80.1%（BF16），SWE-bench Verified 81.6%。如果你的 agent 动辄几十上百步，token 效率的收益会直接体现为账单下降——这是可量化的。
- **吃整个仓库的代码问答**：1M 上下文 + SWE Atlas Codebase QnA 31.8%。注意这个分数不高，说明「塞进去」和「答得准」是两回事。
- **企业内部/信创环境**：Apache 2.0 + Dell/HPE 防火墙内交付 + NVFP4 低精度部署，这条线在国内私有化场景里是少有的完整路径。
- **要自己 post-train 的团队**：NeMo RL / Miles / TRL / SkyRL 全套集成，加上官方会放出自蒸馏食谱。

### 什么场景不值得用

- **中文/多语为主的业务**：模型卡白纸黑字「developed predominantly for English」。中文能力很可能明显弱于同代国产开源模型，不要用英文 benchmark 外推。
- **多模态需求**：Supported Modalities 只有 Text。视觉、截图驱动 computer-use 这类场景直接排除。
- **单次短问答的极低延迟场景**：501B MoE 即使只激活 23B，冷启动与显存占用摆在那里（NVFP4 也需要可观的多卡配置）。轻量任务用大模型是亏的。
- **想要「开箱即用的 SaaS」**：Ollama 上是**限时免费**，Reflection 平台是 public beta。长期成本与 SLA 尚无公开承诺。

### 迁移成本

| 迁移方向 | 需要做什么 | 粗估工作量 |
|---------|-----------|-----------|
| 自托管 GPU 路径 | 选精度（NVFP4 更适合新卡）→ vLLM/SGLang 起服务 → 配 chat template（**Modified Harmony format**，非 OpenAI 默认） | 0.5–1 人日调通，模板适配可能踩坑 |
| 从其他 harness 迁到 Mirror | 重写 skills / MCP 配置 / project instructions；好处是可复用 | 1–3 天 |
| 从 Mirror 走到其他 harness | 官方称 Pi/OpenCode/Hermes 已验证，但个人项目适配情况待确认 | 待验证 |
| API 路径 | 直接打 `platform.reflection.ai` 或 OpenRouter/Together 等托管端点 | 几小时 |

## 对你的意义

按 Agent-Playbook 的视角，Beam 最值得记录的不是分数，而是它把「**agent 开放操作系统**」这个说法第一次做成了具体的工程组合：模型（kernel）+ harness + 推理集成 + RL 食谱 + 部署容器。这和 Vercel / AWS AgentCore 那套「runtime + gateway」讲的是同一个故事，只是 Reflection 从模型端切入。

给你的建议：
1. **先跑 API 做 token 效率 A/B**，不必急着自托管。方法很朴素——同一批 SWE 任务，分别用 Beam 和当前主力模型跑，统计**每任务实际计费 token × 单价**。官方「1/3 token」是自报口径，值得独立验证。
2. **不要指望它做中文深度分析**。这条线仍然交给国产模型。
3. **Mirror CLI 的 Rust core 设计思路值得抄**——把 agent core 做薄，让它可以同时当评估面，这是解决「harness 污染 benchmark」的优雅答案。这个设计模式可以进 `theory/`。

## 关键代码/配置片段

Ollama 入口（来源：Ollama Blog，2026-10-16）：

```bash
# 直接把 Beam 接到常见 agent harness
ollama run beam:cloud

# Claude Code
ollama launch claude --model beam:cloud

# Codex
ollama launch codex --model beam:cloud

# OpenCode
ollama launch opencode --model beam:cloud
```

模型卡给出的规格（来源：Reflection Beam Model Card）：

```text
Total parameters : 501.3B
Active Parameters: 23.4B
Layers           : 52 (3 dense + 49 MoE)
Attention        : Gated GQA + Sliding Window Attention
Context Length   : 1M
Vocabulary       : 152k tokens
Expert Count     : 256
Modalities       : Text
Chat Template    : Modified Harmony format
Numerics         : BF16, FP8, NVFP4
Knowledge cutoff : 2026-06-30
```

官方 benchmark（来源：Reflection Beam Model Card，temp=0.7, top_p=0.99）：

| 评测项 | BF16 | FP8 | NVFP4 |
|--------|------|-----|-------|
| Terminal Bench v2.1 | 80.1% | 78.9% | 78.4% |
| SWE-bench Verified | 81.6% | 80.2% | 80.7% |
| SWE-bench Pro v1 | 66.1% | 65.9% | 65.6% |
| SWE-bench Pro v2-Hard | 76.5% | 78.4% | 78.6% |
| SWE-bench Multilingual | 78.3% | 78.1% | 77.5% |
| DeepSWE v1.1 | 43.3% | 43.0% | 42.7% |
| SWE Atlas Codebase QnA | 31.8% | 32.2% | 31.4% |

> 值得注意的反常点：SWE-bench Pro v2-Hard 上 FP8/NVFP4 **反超** BF16（78.4%/78.6% vs 76.5%）。差异在 2 个点以内，更可能是评测噪声而非量化真的变强——不要把它当成"量化提升性能"的证据。
>
> TODO: 官方模型卡未能给出与具体竞品模型的逐项对比表；「3x fewer tokens」缺少实验设置细节（对照模型、任务分布、采样参数），需待社区独立复现。

---

[← Back to Deep Dives](./README.md)
