---
auto_generated: true
generated_at: "2026-05-25T08:03:42Z"
source_url: "https://www.together.ai/blog/coding-agent-benchmarks"
signal_type: "significant_update"
---
# Together AI 推理基准：Coding Agent 场景下 TPS 超 TensorRT-LLM 31% (Together AI Coding Agent Inference Benchmark)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-25
>
> **项目/工具**: Together Inference Engine + Kimi K2.5/K2.6
> **链接**: https://www.together.ai/blog/coding-agent-benchmarks
> **核心定位**: Together AI 发布了一份面向 Coding Agent 生产负载的推理引擎基准测试，证明其自研引擎在高并发长上下文场景下，TPS 比 TensorRT-LLM 高 31%，TTFT 降低一半，且成本仅为 Claude Opus 4.6 的 24%。

## ⚡ 快速判断

- **一句话定位**: 一份针对 Coding Agent 生产负载的推理引擎横向对比基准，聚焦高并发+长上下文下的 TTFT 和 TPS 表现。
- **现在值得用吗**: 是——如果你在用或考虑用 Kimi K2.5/K2.6 跑 Coding Agent，Together Inference Engine 在当前基准中是性能/成本最优解。
- **适合场景**: 高并发 Coding Agent 服务（数十到数百用户同时请求，每个请求携带 45k-200k token 上下文）；对 TTFT < 1s 有硬性要求的交互式编码工具。
- **不适合场景**: 长 decode 为主的生成任务（如文档摘要、长文写作）——该引擎针对 prefill-heavy 负载优化，长 decode 场景未必最优；需要开源引擎自行部署的团队（Together IE 目前不开放源码）。
- **与竞品核心差异**: 在 2.5M TPM 负载下，Together IE 是唯一保持 p50 TTFT < 1s 的引擎（0.71s vs TensorRT-LLM 1.1s vs SGLang 5.1s），且用 4 块 B200 达到了 SGLang 用 8 块 B200 都没能达到的水平。

## 是什么 / 解决什么问题

绝大多数推理基准测试测量的是「单用户打独享端点」的理想场景——数字好看，但对生产环境毫无参考价值。在实际生产中，数十到数百个并发请求共享同一组 GPU，竞争 KV cache、内存带宽和 GPU 周期。每个用户的实际体验会随负载上升而显著恶化，而单用户基准完全无法反映这一点。

Together AI 这份基准测试的核心价值在于：**它模拟了真实 Coding Agent 的生产负载特征**——长输入（45k-200k token）、高并发、短输出（平均 ~450 token），并测量了三个关键指标：TPM（输入 token/分钟）、每用户 TPS（输出 token/秒）、p50 TTFT（首 token 延迟）。

对于 Coding Agent 而言，TTFT 是决定工具「快还是卡」的核心指标。开发者提交请求后，在第一个 token 到达之前看到的是一片空白——这个间隙决定了信任的建立或崩塌。输出速度固然重要，但一旦 token 开始流动，即使生成速率中等，体验也是流畅的。

第二个约束是并发长上下文。数十个开发者同时携带 80k+ token 上下文 hitting 同一端点，产生的 KV cache 压力是单用户基准永远无法暴露的。随着 cache 填满，调度空间缩小，prefill 延迟攀升，TTFT 恶化。

第三个约束是输出形态。Coding Agent 生成的是一个函数，不是一篇文章——生成长度有界（p50: 293, p99: 2,230 token）。这意味着系统承受的是持续的 prefill 压力，而非持续的 decode 压力。为长 decode 运行优化的引擎在这里未必能赢。

## 技术架构拆解

### 核心设计决策

Together AI 将推理视为一个**全栈优化问题**，而非单纯调参：

1. **ThunderMLA 融合内核**: Kimi K2.5 使用 DeepSeek 的 MLA（Multi-head Latent Attention）架构。标准实现每个 decode step 需要两次 kernel launch。Together 的 ThunderMLA（来自 ThunderKittens 内核库）将两次 launch 融合为一个 mega-kernel，消除了 launch 开销和尾部效应。在代表性 decode 负载上，ThunderMLA 比 DeepSeek 官方的 FlashMLA 快 20-35%。

2. **EAGLE 推测解码**: 使用 3 个 draft token，~70% 接受率。接受率来自真实合成 prompt 数据，非人为强制。

3. **低延迟配置优先**: 所有引擎均配置为低延迟模式（区别于吞吐优化模式——后者会增加 max decode batch size 并使用 prefill-decode 分离，以输出 TPS 换取更高输入 TPM）。

4. **公平对比原则**: SGLang 配置尽量匹配；未做穷举调参。作者坦承 Together IE 可能仍有边际改进空间。

### 与前版/竞品的关键差异

| 维度 | TensorRT-LLM (4×B200) | SGLang (8×B200) | Together IE (4×B200) |
|------|----------------------|-----------------|---------------------|
| p50 TTFT @ 2.5M TPM | 1.1s | 5.1s | **0.71s** |
| TPS @ 2.5M TPM | 基准 | 更低 | **+31% vs TRT-LLM** |
| GPU 用量 | 4 块 | 8 块 | 4 块 |
| EAGLE 兼容性 | ✅ | TP4 OOM，需 TP8 | ✅ |
| 开源 | ✅ | ✅ | ❌ (托管服务) |
| 每请求成本 (K2.6) | — | — | $0.108 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│  Coding Agent 生产负载特征                           │
│                                                     │
│  输入: 45k-200k token/prompt (长上下文)              │
│  并发: 数十-数百用户同时请求                          │
│  输出: ~450 token/次 (短 burst)                      │
│                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │ Prefill  │───▶│ KV Cache │───▶│ Decode   │      │
│  │ 压力大   │    │ 竞争激烈  │    │ burst 短  │      │
│  └──────────┘    └──────────┘    └──────────┘      │
└─────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│  Together Inference Engine 优化栈                    │
│                                                     │
│  Layer 1: ThunderMLA (融合 MLA kernel, +20-35%)     │
│  Layer 2: EAGLE 推测解码 (3 draft, ~70% accept)     │
│  Layer 3: 全栈 profiling → 消除瓶颈                  │
│  Layer 4: 自定义 kernel (超越 TRT-LLM 开源等价物)    │
└─────────────────────────────────────────────────────┘
```

### 退化曲线：比单点数据更重要

每个推理引擎最终都会饱和——KV cache 填满、调度压力增加、TTFT 攀升。不同引擎的区别在于**何时发生**以及**多快恶化**。

在 2.5M TPM 负载下（所有引擎都已超出舒适区）：

```
TTFT (p50)
  │
5s│                              █ SGLang (8×B200)
  │
2s│              █ TensorRT-LLM (4×B200)
  │
1s│  █ Together IE (4×B200)  ← < 1s 阈值
  │
0s└────────────────────────────────
      TRT-LLM    Together IE    SGLang
```

Together IE 在负载更高的情况下仍保持功能可用，而其他引擎已经不可用。

## 实用评估

### 什么场景值得用

- **高并发 Coding Agent 服务**: 如果你的产品是面向开发者的 AI 编码助手（如 Cursor/Copilot 类），且用户量在数十到数百级别，Together IE 的 TTFT 表现直接决定了用户体验。0.71s vs 1.1s 的差距在交互场景中感知明显。
- **成本敏感的团队**: Kimi K2.6 在 SWE-Bench Verified (80.2 vs 80.8)、SWE-Bench Pro (58.6 vs 53.4)、LiveCodeBench v6 (89.6 vs 88.8) 上全面匹敌甚至超越 Claude Opus 4.6，但每请求成本仅为 $0.108 vs $0.451——**便宜 76%**。一个 30 人工程团队每天跑 5 小时（250 工作日/年）可节省约 **$44 万/年**。
- **需要 Kimi K2.6 能力的场景**: K2.6 在编码基准上已匹敌 Claude Opus 4.6，且可通过 Together 直接调用。

### 什么场景不值得用

- **长文本生成**: 该引擎针对 prefill-heavy 负载优化。如果你的主要 workload 是文档生成、摘要等长 decode 任务，吞吐优化型引擎（如 TRT-LLM 的 throughput 配置）可能更合适。
- **需要自托管/开源方案**: Together IE 目前是托管服务，不开放源码。如果你的合规要求或技术栈要求自托管，TensorRT-LLM 或 SGLang 仍是唯一选择。
- **单用户/低并发场景**: 在低并发下，各引擎的 TTFT 差异不大。这份基准的价值在于高并发压力测试。

### 迁移成本

- **从 Claude API 迁移到 Kimi K2.6 on Together**: 主要是 API 适配（端点切换、token 计数调整）。如果当前使用 OpenAI 兼容格式，Together 支持相同接口，迁移工作量估计在 **1-2 人周**。
- **从 TensorRT-LLM 自托管迁移到 Together IE**: 从自托管转为托管服务，需要重新评估数据隐私、网络延迟、供应商锁定风险。工程迁移成本低（API 层），但架构决策成本高。

## 对你的意义

这份基准对 AI Agent 工程有几个直接启示：

1. **推理引擎正在成为 Agent 体验的关键变量**。同一个模型在不同引擎上的 TTFT 差异可达 5-7 倍（0.71s vs 5.1s），这直接决定了 Agent 工具是「流畅」还是「不可用」。选择 Agent 框架时，底层推理引擎应该纳入评估。

2. **Kimi K2.6 的编码能力已匹敌 Claude Opus 4.6，成本仅 24%**。如果你的 Agent pipeline 使用 Claude 跑编码任务，切换到 Kimi K2.6 on Together 可能带来显著的成本优化。但需要验证：(a) 你的具体任务是否在 benchmark 覆盖范围内；(b) API 兼容性是否平滑。

3. **ThunderMLA 等内核优化代表了推理优化的新前沿**。当模型能力趋同时，底层 kernel 级别的优化（融合 MLA、自定义 kernel）可能成为差异化竞争的关键。值得持续关注 ThunderKittens 项目的进展。

> TODO: 验证 Kimi K2.6 在非编码任务（如推理、对话）上的表现是否与 Claude Opus 4.6 匹敌。
> TODO: 确认 Together IE 是否支持 Kimi K2.6 的 EAGLE 推测解码。

## 关键代码/配置片段

ThunderMLA 融合内核的核心思想（来自官方博客引用）：

```
# ThunderMLA: 将两次 kernel launch 融合为一次 mega-kernel
# 标准 MLA 实现: 2 次 launch/decode step
# ThunderMLA: 1 次 launch/decode step → 消除 launch overhead + tail effects
# 性能提升: 20-35% vs DeepSeek FlashMLA (代表性 decode 负载)
```

EAGLE 推测解码配置：

```
# EAGLE speculative decoding
# draft tokens: 3
# acceptance rate: ~70% (自然涌现，非人为强制)
# 效果: 在 Kimi K2.5 上显著提升有效 TPS
```

成本计算（官方博客数据）：

```
# 典型请求: ~80k-100k input tokens, ~450 output tokens
# Kimi K2.6 on Together: $0.108/request
# Claude Opus 4.6:        $0.451/request
# 节省: 76%
#
# 30 人团队, 1.5M TPM, 5h/day, 250 days/year:
# 年节省 ≈ $440,000
```

## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-002: Agentic Coding 在初级任务达 80% 成功率 | 支持 | Kimi K2.6 在 SWE-Bench Verified 达 80.2%、LiveCodeBench v6 达 89.6%，直接支撑「编码 Agent 在标准任务上达 80% 成功率」的假设 |

---
[← Back to Deep Dives](./README.md)
