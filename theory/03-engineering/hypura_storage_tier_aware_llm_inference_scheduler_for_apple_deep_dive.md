---
auto_generated: true
generated_at: "2026-05-13T03:33:40Z"
source_url: "https://github.com/t8/hypura/releases/tag/v0.2.0"
signal_type: "significant_update"
---
# Hypura v0.2.0 — SparseMoeMmap 新模式 + Gemma 4 + M5 Pro 支持 (Hypura v0.2.0 — SparseMoeMmap Mode, Gemma 4 & M5 Pro Support)

> 🔍 本文由 Moltbot 自动生成 | 2026-05-13
>
> **项目/工具**: Hypura v0.2.0
> **链接**: https://github.com/t8/hypura/releases/tag/v0.2.0
> **核心定位**: Apple Silicon 专用 LLM 推理调度器，v0.2.0 引入全新的 SparseMoeMmap 超稀疏 MoE 直通路径，让 Gemma 4 26B-A4B 在 32GB Mac 上跑出 51 tok/s 的本地推理速度

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Hypura v0.2.0 为超稀疏 MoE 模型（激活比 ≤15%）新增了一条零开销直通推理路径——SparseMoeMmap，跳过所有路由拦截和流式加载，直接让 OS 页缓存处理稀疏性
- **现在值得用吗**: 是——如果你用 Apple Silicon Mac 跑 Gemma 4 26B-A4B 或类似超稀疏 MoE 模型，这是目前本地最快的方案
- **适合场景**: Gemma 4 系列推理、M5 Pro 系列新芯片、需要 CPU-only 降级运行的极端内存场景
- **不适合场景**: 非 Apple Silicon 平台、稠密大模型（已有 llama.cpp 等成熟方案）、多模态 GGUF 捆绑包（暂不支持）
- **与 v0.1.0 核心差异**: v0.1.0 的 MoE 走 expert-streaming（路由拦截 + NVMe 流式加载），v0.2.0 新增 SparseMoeMmap 直通路径——对超稀疏模型完全跳过流式引擎，速度提升显著

## 是什么 / 解决什么问题

Hypura 是一个用 Rust 编写的 Apple Silicon 专用 LLM 推理调度器。它的核心价值在于：让超出 Mac 物理内存的模型能跑起来，同时让能放入内存的模型跑得更快。

v0.1.0 已经建立了三层存储架构（GPU/RAM/NVMe）和三种推理模式（Full-resident / Expert-streaming / Dense FFN-streaming）。但 v0.1.0 的 MoE 处理有一个问题：即使模型的激活比极低（如 Gemma 4 26B-A4B 只有 6.25% 的专家被激活），它仍然要走路由拦截 + NVMe 流式加载的完整流程，引入了不必要的开销。

v0.2.0 的核心突破是意识到：**对于超稀疏 MoE 模型，OS 页缓存本身就足以处理稀疏性，不需要额外的流式引擎**。于是引入了 SparseMoeMmap 模式——完全绕过路由拦截 machinery，让 mmap 直接工作。Gemma 4 26B-A4B 在这个模式下跑出 51 tok/s，是 v0.1.0 expert-streaming 模式速度的数量级倍数。

此外，v0.2.0 还带来了 Google Gemma 4 架构支持、M5 Pro 芯片支持、CPU-only 降级回退机制，以及 benchmark 图表生成工具。

## 技术架构拆解

### 核心设计决策

**1. SparseMoeMmap 直通路径**

这是 v0.2.0 最重要的新特性。设计决策的逻辑链：

- MoE 模型的激活比如果 ≤15%，意味着每个 token 只需要加载极少量的专家张量
- 对于 Gemma 4 26B-A4B（128 专家选 8，激活比 6.25%），活跃工作集约 1GB，远小于 32GB 统一内存
- v0.1.0 的 expert-streaming 模式需要：拦截路由决策 → 从 NVMe 流式加载专家 → 重写张量指针 → eval 回调开销
- 如果活跃工作集已经能放进内存，这些步骤都是多余的
- 直接 mmap 整个模型，让 OS 页缓存按需加载被访问的页面——OS 的 LRU 策略天然适配 MoE 的稀疏访问模式

**2. Gemma 4 架构适配**

Gemma 4 26B-A4B 采用了与 Mixtral 不同的 MoE 设计：
- Mixtral 风格：分离 `ffn_gate_exps` 和 `ffn_up_exps` 张量
- Gemma 4 风格：融合 `ffn_gate_up_exps` 张量（门控和上投影合并）
- Gemma 4 使用交错滑动窗口注意力（interleaved sliding-window attention），每层 KV head 数量不同（数组形式）

Hypura 需要新增 `ExpertTensorType::GateUp` 变体来支持融合张量，并修复 `attention.head_count_kv` 的数组值解析。

**3. CPU-only 降级回退**

当模型超出 Metal 工作集限制时，v0.2.0 不再崩溃，而是自动回退到 `n_gpu_layers=0`（纯 CPU 模式）。OS 页缓存仍然工作，速度虽慢但可用。这是一个重要的鲁棒性改进。

**4. M5 Pro 芯片支持**

硬件 profiler 新增 M5 / M5 Pro / M5 Max 芯片识别，应用正确的工作集、带宽和 SLC 参数。修复了 M5 Pro 被错误分类导致的 placement 回归。

### 与前版的关键差异

| 维度 | Hypura v0.1.0 | Hypura v0.2.0 |
|------|--------------|--------------|
| MoE 推理路径 | Expert-streaming（路由拦截 + NVMe 流式） | 新增 SparseMoeMmap 直通路径（≤15% 激活比） |
| Gemma 4 支持 | ❌ 不支持 | ✅ 完整支持（融合门控张量 + 交错 SWA） |
| M5 Pro 支持 | ❌ 不支持 | ✅ 硬件 profiler 已适配 |
| CPU-only 回退 | ❌ 超限崩溃 | ✅ 自动降级为 CPU-only |
| Benchmark 可视化 | 无 | ✅ 图表生成（matplotlib + ASCII fallback） |
| 支持芯片 | M1/M2/M3/M4 | M1/M2/M3/M4/M5 |
| Gemma 4 26B-A4B 速度 | N/A | 51 tok/s (M1 Max 32GB) |

### 架构/信息流图

```
v0.2.0 推理路径选择决策树:

模型加载
    │
    ├── 模型大小 ≤ GPU+RAM 容量？
    │   ├── 是 → Full-resident（完整 Metal 速度）
    │   └── 否 ↓
    │
    ├── MoE 模型 且 激活比 ≤15% 且 活跃工作集 ≤ 统一内存？
    │   ├── 是 → SparseMoeMmap ★ 新增 ★（OS 页缓存处理稀疏性，零开销）
    │   └── 否 ↓
    │
    ├── MoE 模型（激活比 >15%）？
    │   ├── 是 → Expert-streaming（路由拦截 + NVMe 流式加载）
    │   └── 否 ↓
    │
    ├── 稠密大模型？
    │   ├── 是 → Dense FFN-streaming（注意力层驻留 GPU，FFN 从 NVMe 流式）
    │   └── 否 ↓
    │
    └── 超出 Metal 工作集？
        └── CPU-only fallback ★ 新增 ★（n_gpu_layers=0，OS 页缓存兜底）

SparseMoeMmap 内部流程（与 v0.1.0 expert-streaming 对比）:

  v0.1.0 expert-streaming:
  [路由决策] → [拦截] → [NVMe 加载专家] → [重写张量指针] → [Eval 回调] → [输出]
              ↑ 开销点 ↑                    ↑ 开销点 ↑          ↑ 开销点 ↑

  v0.2.0 SparseMoeMmap:
  [mmap 整个模型] → [OS 页缓存按需加载] → [直接输出]
                    ↑ 零额外开销 ↑
```

### Benchmark 数据对比

| 模型 | 大小 | 模式 | 硬件 | v0.1.0 速度 | v0.2.0 速度 |
|------|------|------|------|------------|------------|
| Gemma 4 26B-A4B Q4_K_M | 15.6 GB | SparseMoeMmap | M1 Max 32GB | N/A（不支持） | **51 tok/s** |
| Qwen3-Coder-Next 80B-A3B | varies | Expert-streaming | M1 Max 32GB | ~1.0 tok/s | 1.3 tok/s |
| Phi-3.5-MoE Q4_K_M | — | Full-resident | M5 Pro 24GB | N/A（不支持） | 2.2 tok/s |
| Llama 3.3 70B Q4_K_M | 39.6 GB | Dense FFN-streaming | M5 Pro 24GB | N/A（不支持） | improved |

Gemma 4 26B-A4B 的 51 tok/s 是消费级 Apple Silicon 上目前最快的本地 MoE 推理速度之一。作为对比，v0.1.0 的 expert-streaming 模式对类似规模 MoE 模型通常在 1-3 tok/s 范围。

## 实用评估

### 什么场景值得用

- **Gemma 4 26B-A4B 本地推理**: v0.2.0 的 SparseMoeMmap 模式让 Gemma 4 在 32GB Mac 上跑出 51 tok/s，这是 llama.cpp 等通用方案难以达到的速度（llama.cpp 对 Gemma 4 的支持可能还在早期阶段）
- **M5 Pro 系列新芯片用户**: v0.2.0 首次支持 M5 Pro，硬件 profiler 已适配正确的参数。如果你刚入手 M5 Pro Mac，Hypura 是本地推理的首选方案之一
- **超稀疏 MoE 模型（激活比 ≤15%）**: 任何符合这个条件的 MoE 模型都能从 SparseMoeMmap 路径受益——不仅是 Gemma 4
- **极端内存场景的降级运行**: CPU-only fallback 让原本会崩溃的场景变为"慢但可用"，对实验性大模型加载很有价值

### 什么场景不值得用

- **多模态 GGUF 捆绑包**: 明确不支持。Ollama 的 gemma4 pull 会打包 LLM + 视觉 + 音频 + projector，Hypura 的纯 LLM loader 会报错。必须使用 text-only GGUF
- **非 Apple Silicon 平台**: 仅支持 M1/M2/M3/M4/M5，x86 Mac 和 Linux/Windows 不适用
- **需要自动 chat template 应用**: v0.2.0 的 `hypura run` 还不支持自动 chat template，需要手动构造（如 `user\n...\nmodel\n` 格式）。这对快速实验不太友好
- **稠密大模型生产部署**: 对于 Llama 70B 等稠密模型，v0.2.0 的 dense FFN-streaming 速度仍然有限（0.3 tok/s 级别），不适合生产环境

### 迁移成本

- **从 v0.1.0 升级**: `git pull && cargo build --release`，无需配置变更。SparseMoeMmap 路径会自动触发（当模型满足条件时）
- **从 llama.cpp 迁移**: 需要 Rust 1.75+ 和 CMake 编译环境。命令语法不同（`hypura run --prompt ...` vs `llama-cli -p ...`），但 GGUF 格式兼容。迁移工作量约半天到一天
- **从 Ollama 迁移**: 需要放弃 Ollama 的自动管理（模型下载、服务管理），改用手动 GGUF 文件 + 命令行。但换来的是更高的推理速度和更低的资源占用

## 对你的意义

Hypura v0.2.0 的 SparseMoeMmap 模式代表了一个重要的设计趋势：**针对特定模型架构的专用优化路径，比通用流式引擎更高效**。

这对 Agent 开发的启示：
- 当你在 Mac 上本地运行 AI 模型做 Agent 推理时，Hypura v0.2.0 让 Gemma 4 26B-A4B 这样的中等规模 MoE 模型变得真正可用（51 tok/s 已经接近实时交互的体验）
- SparseMoeMmap 的设计思路——利用 OS 原生能力而非自建引擎——值得在 Agent 基础设施设计中借鉴：有时最简单的方案就是最优方案

**建议**: 如果你使用 Apple Silicon Mac 且关注本地模型推理，立即试用 v0.2.0。Gemma 4 26B-A4B 的 51 tok/s 表现是目前消费级硬件上最好的本地 MoE 推理体验之一。

## 关键代码/配置片段

### SparseMoeMmap 触发条件（来自 release notes 描述）

```
// 伪代码：v0.2.0 推理路径选择逻辑
if model.activation_ratio <= 0.15           // ≤15% 激活比
   && model.active_working_set <= unified_memory  // 活跃工作集 ≤ 统一内存
   && model.type == MoE:
    use SparseMoeMmap  // 跳过流式引擎，直接 mmap
else if model.type == MoE:
    use ExpertStreaming  // v0.1.0 的路由拦截 + NVMe 流式
else if model.type == Dense && model.size > gpu_ram:
    use DenseFFNStreaming
else:
    use FullResident
```

### Gemma 4 安装与运行（text-only GGUF）

```bash
# 克隆并编译
git clone --recurse-submodules https://github.com/t8/hypura.git
cd hypura
cargo build --release

# 运行 Gemma 4 26B-A4B（需手动构造 chat template）
hypura run --prompt "$(printf 'user\nWhat is the capital of France?\nmodel\n')" \
  --max-tokens 100 \
  ./gemma-4-26B-A4B-it-Q4_K_M.gguf
```

> TODO: Auto-template-application 功能已在计划中，后续版本将支持自动 chat template 应用。

### Gemma 4 架构适配的关键变更

```
- ExpertTensorType::GateUp variant
  → 支持 Gemma 4 融合的 ffn_gate_up_exps 张量
  → Mixtral 风格分离 gate/up，Gemma 4 融合

- attention.head_count_kv 数组值解析
  → Gemma 4 使用交错滑动窗口注意力
  → 每层 KV head 数量不同，需数组形式解析

- parse_special=true in tokenize wrapper
  → chat-template tokens 按 vocab ID 而非 raw bytes 分词
```

---
[← Back to Deep Dives](./README.md)
