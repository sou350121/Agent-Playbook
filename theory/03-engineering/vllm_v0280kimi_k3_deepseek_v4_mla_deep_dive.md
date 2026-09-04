---
auto_generated: true
generated_at: "2026-09-04T12:44:50Z"
source_url: "https://github.com/vllm-project/vllm/releases/tag/v0.28.0"
signal_type: "significant_update"
---
# vLLM v0.28.0：Kimi-K3 全栈优化 + DeepSeek V4 稀疏 MLA 端到端 (vLLM v0.28.0 — Full-Stack Kimi-K3 Optimization + DeepSeek V4 Sparse MLA End-to-End)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-04
>
> **项目/工具**: vLLM
> **链接**: https://github.com/vllm-project/vllm/releases/tag/v0.28.0
> **核心定位**: vLLM 是业界最活跃的开源 LLM 推理/服务引擎（2000+ 贡献者），v0.28.0 以 584 commits / 270 贡献者（76 位新贡献者）的体量，完成了 Kimi-K3 全栈优化与 DeepSeek V4 稀疏 MLA 端到端支持两大里程碑。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：vLLM v0.28.0 是一个超大规模版本，核心围绕 Kimi-K3 模型全栈性能优化和 DeepSeek V4 稀疏 MLA 架构的端到端支持，同时引入了 Tiered KV Cache Offloading、DFlash2 推测解码、Rust 前端 + gRPC 等架构级变化。
- **现在值得用吗**：是 — 如果你在生产环境运行 Kimi-K3、DeepSeek-V4 或需要大规模 KV cache offloading，立即升级；否则建议等 0.28.x 稳定版。
- **适合场景**：高吞吐 LLM 服务、MoE 模型推理、长上下文（128K+）、多模态推理、RLHF 训练回路
- **不适合场景**：需要 bitsandbytes 量化的用户（已迁移为 OOT 插件）；依赖旧版 Transformers API 的项目（需升级至 5.15.0）
- **与 v0.27.x 核心差异**：Kimi-K3 DCP + FlashKDA 融合内核、DeepSeek V4 稀疏 MLA 端到端、Tiered KV Cache 磁盘 offload、Rust 前端 + gRPC 多模态推理

## 是什么 / 解决什么问题

vLLM 自 2023 年 SOSP 论文发表以来，已成为 LLM 推理的事实标准基础设施。v0.28.0 是这个生态的一次"大版本"——584 个 commits 来自 270 位贡献者，其中 76 位是新贡献者，反映了社区的高速增长。

这个版本解决的核心问题有三个：

1. **Kimi-K3 推理效率**：Kimi-K3 作为月之暗面的最新模型，其架构包含 MegaMoE 和 FlashKDA 注意力机制，需要 vLLM 内核级别的适配才能实现高效推理。v0.28.0 通过 Decode Context Parallel (DCP)、融合 FlashKDA decode/prefail kernel、SiTU 激活、GEMM-RS 序列并行等手段，实现了全栈优化。
2. **DeepSeek V4 稀疏 MLA 端到端**：DeepSeek V4 的 Multi-Head Latent Attention (MLA) 采用稀疏化策略来降低长上下文推理的 KV cache 开销。v0.28.0 让稀疏 MLA 在 plain decode、MTP（Multi-Token Prediction）和 DSpark 推测解码三条路径上全部可用。
3. **大规模上下文场景的 KV cache 瓶颈**：通过 Tiered KV Cache Offloading（含磁盘 offload）和 Model Runner V2 的 E/P/D 解耦，vLLM 现在可以在有限的 GPU 显存下服务更长的上下文。

## 技术架构拆解

### 核心设计决策

**1. Kimi-K3 全栈优化路径**

Kimi-K3 的推理优化不是一个单一 PR，而是一条完整的技术栈：

| 优化层 | 技术方案 | 效果 |
|--------|---------|------|
| 并行策略 | Decode Context Parallel (DCP) [#50484] | 长上下文 decode 阶段可跨 GPU 并行 |
| 注意力内核 | 融合 FlashKDA decode + prefill kernel [#50654/#51311/#52458] | 减少 kernel launch 开销 |
| 激活函数 | SiTU activation for MegaMoE [#50510] | 适配 Kimi-K3 的 MoE 架构 |
| 序列并行 | GEMM-RS (Reduce-Scatter) [#52079] | 张量并行下的通信优化 |
| All-Reduce | 合并 all-gathers [#51070] | kernel 级别 1.5~3x 加速 |
| 推测解码 | 自适应 speculative token budget [#51725] | DSpark TTFT 提升 ~60% |
| 显存优化 | shared-expert sharding [#50912] | 每 GPU 节省 ~17 GiB |
| 硬件扩展 | ROCm V2 model runner [#51653] | Kimi-K3 现在可在 AMD GPU 运行 |

**2. DeepSeek V4 稀疏 MLA 端到端**

稀疏 MLA 是 DeepSeek 系列的核心创新——通过将 attention 的 key/value 投影到潜在空间，大幅降低 KV cache 的存储需求。v0.28.0 让这条路径在三种推理模式下全部打通：

```
                    ┌─────────────────────────────────────┐
                    │         DeepSeek V4 Sparse MLA       │
                    └──────────────┬────────────────────────┘
                                   │
           ┌───────────────────────┼───────────────────────┐
           │                       │                       │
    ┌──────▼──────┐        ┌───────▼───────┐       ┌──────▼──────┐
    │ Plain Decode │        │   MTP Path    │       │ DSpark Spec │
    │ (标准解码)    │        │ (多token预测)  │       │ (推测解码)   │
    └─────────────┘        └───────────────┘       └─────────────┘
           │                       │                       │
           └───────────────────────┼───────────────────────┘
                                   │
                    ┌──────────────▼────────────────────────┐
                    │  Sparse Top-k Metadata Kernel Opt     │
                    │  [#52084, #51967]                     │
                    └───────────────────────────────────────┘
```

**3. Tiered KV Cache Offloading — 分层 KV Cache 卸载**

这是 vLLM 在扩展性方面的重大架构变化。KV cache 不再局限于 GPU 显存，而是可以分层卸载到 CPU 甚至磁盘：

```
  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
  │  GPU HBM     │ →  │  CPU Memory  │ →  │   Disk SSD   │
  │  (L0 - Hot)  │    │  (L1 - Warm) │    │  (L2 - Cold) │
  └──────────────┘    └──────────────┘    └──────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                  ┌───────────▼───────────┐
                  │  Tiered Cache Manager  │
                  │  - module_path 插件机制 │
                  │  - 并行感知 CPU layout  │
                  │  - tiering metrics     │
                  └───────────────────────┘
```

关键 PR：
- 磁盘 offload 支持 [#49644]
- 外部 tier manager 插件机制 [#51007]
- 并行无关的 CPU layout [#48414]
- tiering metrics 暴露 [#48798]

**4. Model Runner V2 成熟化**

V2 model runner 是 vLLM 的下一代模型执行引擎，v0.28.0 中多项关键能力在 V2 上落地：

- E/P/D 解耦（Encode/Prefill/Decode 分离部署）[#38390]
- 权重卸载（weight offloading）[#51413]
- 多层 MTP KV cache 支持 [#50062]
- Encoder CUDA graphs [#49852]
- Attention-free 模型支持 [#52374]

**5. Rust 前端 + gRPC**

vLLM 开始用 Rust 重写部分前端组件，并通过 gRPC 暴露多模态推理接口：

- 独立渲染器 [#50289]
- 多模态图像推理 over gRPC [#50368]
- 显式 DP rank 路由 [#51178]
- RL 生命周期控制 [#51316]
- Protobuf schemas 发布到 Buf [#51276]

### 与前版的关键差异

| 维度 | v0.27.x | v0.28.0 |
|------|---------|---------|
| Kimi-K3 支持 | 基础推理 | DCP + FlashKDA 融合 + 全栈优化，TTFT ~60% 改善 |
| DeepSeek V4 MLA | 部分支持 | 端到端（plain decode + MTP + DSpark） |
| KV Cache | GPU 内管理 | Tiered offloading（GPU→CPU→Disk） |
| 推测解码 | DFlash / EAGLE | DFlash2 + DSpark confidence-scheduled + 自适应 budget |
| Model Runner | V1 为主 | V2 成熟化，支持 E/P/D 解耦 |
| 前端接口 | HTTP only | Rust 前端 + gRPC 多模态 |
| bitsandbytes | 内置 | 迁移为 OOT 插件（Breaking） |
| Transformers 最低版本 | 旧版 | 5.15.0（Breaking） |
| max_num_batched_tokens 默认值 | 8192 | 16384 |
| AMD ROCm 支持 | 部分模型 | Kimi-K3 / DeepSeek-V4 / Qwen3.8 全面支持 |

### 推测解码演进时间线

```
v0.26.x        v0.27.x        v0.28.0
  │              │              │
  ├─ n-gram ─────┤              │
  ├─ suffix ─────┤              │
  ├─ EAGLE ──────┼──────────────┤
  │              ├─ DFlash ─────┼──→ DFlash2 (local conv + candidate selector)
  │              │              ├─ DSpark (confidence-scheduled verification)
  │              │              └─ 自适应 speculative token budget
  │              │                 (~60% DSpark TTFT 改善)
```

## 实用评估

### 什么场景值得用

- **Kimi-K3 生产部署**：如果你在生产中使用 Kimi-K3，v0.28.0 的 DCP + FlashKDA 融合内核带来的 ~60% TTFT 改善和每 GPU ~17 GiB 显存节省是直接的 ROI。
- **DeepSeek V4 长上下文推理**：稀疏 MLA 端到端支持意味着你可以在 vLLM 上以更低 KV cache 开销运行 DeepSeek V4 的长上下文场景。
- **超大规模服务（需要 KV cache offload）**：Tiered KV cache offloading 让你可以用 CPU 内存甚至磁盘 SSD 扩展 KV cache 容量，适合上下文长度 >128K 的场景。
- **RLHF 训练回路**：E/P/D 解耦 + NCCL stateful trainer send + CuMemAllocator.discard() 让 vLLM 在 RL 训练回路中的集成更顺畅。
- **AMD GPU 用户**：Kimi-K3 on ROCm + DeepSeek-V4 on gfx11 + Qwen3.8 on ROCm，AMD 生态支持大幅扩展。
- **多模态服务**：gRPC 多模态推理 + Vision encoder CUDA graph 支持（Kimi-K2.5, Ernie-4.5-VL, Qwen3-VL）。

### 什么场景不值得用 / 需谨慎

- **依赖 bitsandbytes 量化**：bitsandbytes 已迁移为 OOT 插件，如果你的 pipeline 强依赖 bitsandbytes，需要额外的迁移工作（Breaking Change）。
- **旧版 Transformers 项目**：Transformers 最低版本升至 5.15.0，旧项目可能需要适配。
- **使用了已删除 API 的项目**：`calculate_kv_scales` 和 `override_attention_dtype` 已移除，需检查代码。
- **追求极致稳定性的生产环境**：大版本升级（584 commits）通常伴随早期 bug，建议先在 staging 环境验证。
- **小规模推理场景**：如果你只是跑几个并发请求，Tiered KV cache offloading 和 DCP 等高级特性不会带来明显收益。

### 迁移成本

| 迁移项 | 工作量 | 说明 |
|--------|--------|------|
| 常规升级 | 低 | `pip install vllm==0.28.0`，注意 CUDA 13.0 默认 |
| bitsandbytes 用户 | 中 | 需安装 OOT 插件，参考 PR #43529 |
| Transformers <5.15.0 | 中 | 升级 Transformers 并测试兼容性 |
| 使用 calculate_kv_scales | 低 | 该 API 已移除，需改用预计算 kv_scales |
| 使用 override_attention_dtype | 低 | 该 API 已移除 |
| Kimi-K3 用户 | 低 | 直接升级即可享受优化，无需代码变更 |
| DeepSeek-V4 用户 | 低 | 稀疏 MLA 现在端到端可用，无需额外配置 |

### 安装方式

```bash
# CUDA 13.0 (默认)
pip install vllm

# CUDA 12.9
docker pull vllm/vllm-openai:v0.28.0-cu129

# ROCm (AMD)
pip install vllm --extra-index-url https://wheels.vllm.ai/rocm/0.28.0/rocm722

# CPU
docker pull vllm/vllm-openai-cpu:v0.28.0
```

## 对你的意义

作为 AI 应用开发者/研究者，这个版本值得关注的信号：

1. **vLLM 正在从"推理引擎"进化为"AI 服务基础设施平台"**。Rust 前端 + gRPC + Tiered Cache + E/P/D 解耦，这些变化让 vLLM 的定位超越了单纯的 LLM 推理，更接近一个完整的 AI 服务运行时。

2. **Kimi-K3 和 DeepSeek V4 的全栈优化反映了开源社区对国产模型的支持力度**。vLLM 2000+ 贡献者中，来自 Moonshot AI（月之暗面）和 DeepSeek 的贡献者占比显著增长。

3. **推测解码进入"多方案并存"阶段**。DFlash2、DSpark、EAGLE3 同时活跃开发，自适应 budget 调度表明 vLLM 正在尝试智能选择最优推测策略。

4. **AMD ROCm 生态在加速追赶**。Kimi-K3、DeepSeek-V4、Qwen3.8 在 ROCm 上的支持，配合 AITER 和 FP8 inference on GFX120x，AMD GPU 作为推理硬件的竞争力在提升。

**建议**：如果你的生产环境运行 Kimi-K3 或 DeepSeek-V4，立即升级。否则建议在 staging 验证 1-2 周后再推生产。

## 关键代码/配置片段

### Tiered KV Cache Offloading 配置（概念性）

```python
# v0.28.0 引入的 tiered cache 支持
# 通过 module_path 注册外部 tier manager
VLLM_KVCACHE_TIER_MANAGER="my_module:CustomTierManager"
```

### Kimi-K3 推理（自动优化，无需额外配置）

```bash
# v0.28.0 自动启用 Kimi-K3 全栈优化
vllm serve moonshotai/Kimi-K3 \
  --tensor-parallel-size 8 \
  --max-num-batched-tokens 16384  # v0.28.0 新默认值（原 8192）
```

### gRPC 多模态推理（新接口）

```protobuf
// Protobuf schemas 已发布到 Buf
// 支持多模态图像推理 over gRPC
// 参考: https://buf.build/vllm
```

### 新默认值变更

```python
# v0.27.x → v0.28.0 默认值变化
max_num_batched_tokens: 8192 → 16384
prefix_caching (Mamba): disabled → enabled by default
blackwell_cuda_graph_capture_max_seq_len: 512 → 1024
```

---
[← Back to Deep Dives](./README.md)
