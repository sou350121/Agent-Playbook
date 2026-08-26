---
auto_generated: true
generated_at: "2026-08-26T03:37:30Z"
source_url: "https://github.com/t8/hypura/releases/tag/v0.2.0"
signal_type: "significant_update"
---
# Hypura v0.2.0：Apple Silicon 上的存储层级感知 LLM 推理调度器 (Storage-Tier-Aware LLM Inference Scheduler for Apple Silicon)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-26
>
> **项目/工具**: Hypura
> **链接**: https://github.com/t8/hypura/releases/tag/v0.2.0
> **核心定位**: 一个 Rust 编写的 LLM 推理调度器，通过将模型张量智能分配到 GPU/RAM/NVMe 三个存储层级，让超出物理内存的模型在 Apple Silicon Mac 上运行而不崩溃。v0.2.0 新增 Gemma 4 稀疏 MoE 支持、M5 芯片兼容和自动 CPU 回退。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**: Hypura 是 Apple Silicon 专用的 LLM 推理调度器，通过存储层级感知（GPU → RAM → NVMe）让超出内存的模型"跑起来"——不是跑得快，而是从"跑不了"变成"能跑"。
- **现在值得用吗**: 看场景。如果你有一台 32GB Mac 想跑 70B 模型，它是唯一选择；如果你只需要跑 7B-14B 模型，llama.cpp / Ollama 就够了。
- **适合场景**: 32GB Mac 跑 30B+ 模型；MoE 模型本地推理；需要 Ollama 兼容 API 的本地 Agent 工作流。
- **不适合场景**: 需要高吞吐的生产推理（0.3 tok/s 不是给人用的）；非 Apple Silicon 平台；多模态 GGUF 模型（当前不支持）。
- **与 llama.cpp 核心差异**: llama.cpp 的 mmap 是"全量映射、让 OS 自己处理"，Hypura 是"理解模型架构 + 主动调度"——知道哪些张量每 token 都访问、哪些可以按需加载。

## 是什么 / 解决什么问题

### 背景痛点：Apple Silicon 的统一内存困境

Apple Silicon 的统一内存架构是一把双刃剑：M1 Max 32GB 的内存带宽高达 400GB/s（远超 NVMe 的 5-7GB/s），但容量固定不可扩展。当你试图加载一个 40GB 的 Llama 70B Q4 量化模型时，vanilla llama.cpp 会触发 swap thrash 直到 OOM killer 介入。

Hypura 的核心洞察是：**NVMe 不是"太慢的内存"，而是一个合法的、被低估的存储层级。** 通过理解模型架构（哪些张量访问频繁、哪些稀疏激活），Hypura 能将模型张量分配到 GPU（Metal）、RAM、NVMe 三个层级，让超出物理内存的模型仍可运行。

### v0.2.0 的核心变化

v0.2.0 是一次重大功能更新，三个主要增量：

1. **Gemma 4 稀疏 MoE 架构支持** — Google Gemma 4 26B-A4B（128 experts, 8 active）可在 M1 Max 32GB 上以 51 tok/s 运行
2. **SparseMoeMmap 极速路径** — 对激活率 ≤15% 的稀疏 MoE 模型，完全绕过路由拦截机制，让 OS 页缓存处理稀疏性
3. **M5 系列芯片支持** — 硬件 profiler 现在识别 M5/M5 Pro/M5 Max 并应用正确的参数

## 技术架构拆解

### 核心设计决策

**决策 1: 三层张量放置优化**

Hypura 读取 GGUF 文件后，先 profile 硬件（GPU working set、RAM、NVMe 带宽），然后求解一个放置优化问题，将每个张量分配到最优层级：

- **GPU (Metal)**: Attention 层、Norms、Embeddings — 每个 token 都访问，必须最快
- **RAM**: 放不下 GPU 的溢出层 — 通过 mmap 访问
- **NVMe**: 剩余层通过直接 I/O（F_NOCACHE + pread）按需加载，在 forward pass 前预取

```
┌─────────────────────────────────────────────────────┐
│                    Apple Silicon                     │
│                                                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────┐ │
│  │  GPU     │   │  RAM     │   │  NVMe SSD        │ │
│  │ (Metal)  │   │          │   │                  │ │
│  │          │   │ 溢出层    │   │ 按需加载层        │ │
│  │ Attention│   │ mmap     │   │ F_NOCACHE+pread  │ │
│  │ Norms    │   │          │   │ 预取 ahead       │ │
│  │ Embeds   │   │          │   │                  │ │
│  │          │   │          │   │                  │ │
│  │ ~400 GB/s│   │ ~100 GB/s│   │ ~5 GB/s          │ │
│  └──────────┘   └──────────┘   └──────────────────┘ │
│         ▲               ▲                  ▲        │
│         │               │                  │        │
│  ┌──────┴───────────────┴──────────────────┴──────┐ │
│  │          Hypura Placement Engine               │ │
│  │  模型架构感知 + 硬件 profile → 张量级调度       │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

**决策 2: 三种推理模式自动选择**

| 模式 | 适用场景 | 工作原理 |
|------|---------|---------|
| Full-resident | 模型 fits GPU+RAM | 无 NVMe I/O，全 Metal 速度 |
| Expert-streaming | MoE 模型（如 Mixtral） | 仅非 expert 张量（~1GB）驻留 GPU，expert 张量按需从 NVMe 流式加载，neuron cache 达 99.5% 命中率 |
| Dense FFN-streaming | 大型稠密模型（如 Llama 70B） | Attention + norms 驻留 GPU（~8GB），FFN 张量（~32GB）通过动态 pool buffer 从 NVMe 流式加载 |

**决策 3: v0.2.0 新增 SparseMoeMmap 极速路径**

对激活率 ≤15% 的稀疏 MoE 模型（如 Gemma 4 26B-A4B，仅 6.25% 激活率），Hypura 发现路由拦截机制（router interception）本身成了瓶颈。v0.2.0 引入 SparseMoeMmap 模式：

- 完全跳过 router-interception machinery
- 不做 pool slot 分配、不做 tensor pointer 重写、不做 eval callback 开销
- 让 OS 页缓存通过 mmap 直接处理稀疏性
- Gemma 4 26B-A4B 在此模式下达到 **51 tok/s**（M1 Max 32GB）

### 与前版 / 竞品的关键差异

| 维度 | llama.cpp (mmap) | Hypura v0.1.x | Hypura v0.2.0 |
|------|-----------------|---------------|---------------|
| 张量放置策略 | 全量 mmap，OS 自行处理 | 架构感知三层放置 | + SparseMoeMmap 极速路径 |
| MoE 支持 | 基础支持 | Expert-streaming（路由拦截） | + SparseMoeMmap（绕过路由） |
| Gemma 4 | 不支持 | 不支持 | ✅ 原生支持 |
| M5 芯片 | 部分支持 | 不支持 | ✅ 完整支持 |
| CPU 回退 | 需手动指定 | 崩溃 | 自动 fallback |
| 32GB Mac 跑 70B | OOM | 0.3 tok/s | 0.3 tok/s（改进） |
| 32GB Mac 跑 Mixtral 8x7B | OOM | 2.2 tok/s | 2.2 tok/s |
| 32GB Mac 跑 Gemma 4 26B | OOM | N/A | **51 tok/s** |

### 性能数据（官方 benchmark）

| 模型 | 大小 | 硬件 | 模式 | Hypura tok/s | llama.cpp |
|------|------|------|------|-------------|-----------|
| Gemma 4 26B-A4B Q4_K_M | 15.6 GB | M1 Max 32GB | SparseMoeMmap | **51** | N/A |
| Mixtral 8x7B Q5_K_M | 30.9 GB | M1 Max 32GB | Expert-streaming | 2.2 | OOM |
| Llama 3.3 70B Q4_K_M | 39.6 GB | M5 Pro 24GB | Dense FFN-streaming | 改进 | OOM |
| Qwen 2.5 14B Q4_K_M | 8.4 GB | M1 Max 32GB | Full-resident | 21 | ~21 |

关键结论：对 fits 内存的模型，Hypura 零开销（与 llama.cpp 持平）；对超出内存的模型，Hypura 是"能跑"和"崩溃"的区别。

## 实用评估

### 什么场景值得用

**1. 32GB Mac 跑 30B+ 模型**
这是 Hypura 的核心价值主张。如果你的 M1/M2/M3/M4/M5 Mac 只有 32GB 内存但需要跑 Mixtral 8x7B 或 Llama 70B，Hypura 几乎是唯一选择。

**2. MoE 模型本地推理**
Hypura 对 MoE 架构的优化（99.5% neuron cache hit rate + co-activation 预测预取）使其在 MoE 模型上表现突出。Gemma 4 26B-A4B 达到 51 tok/s，接近原生速度。

**3. 本地 Agent 工作流的 Ollama 兼容后端**
Hypura 提供完整的 Ollama 兼容 HTTP API（/api/generate、/api/chat），可作为 OpenClaw 等工具的 drop-in 替换。对于需要本地运行大模型的 Agent 工作流，这是一个低摩擦的选择。

### 什么场景不值得用

**1. 需要高吞吐的生产推理**
0.3 tok/s 的 Llama 70B 推理速度只适合交互式对话，不适合批量处理或低延迟场景。

**2. 7B-14B 模型（fits 内存）**
这些模型用 llama.cpp 或 Ollama 即可，Hypura 不会带来任何性能提升。

**3. 非 Apple Silicon 平台**
Hypura 明确标注 "Apple Silicon only (M1/M2/M3/M4/M5)"，不支持 x86 或 NVIDIA GPU。

**4. 多模态 GGUF 模型**
v0.2.0 不支持多模态 GGUF bundle（如 Ollama 的 gemma4 pull 打包了 LLM + vision + audio + projector），LLM-only loader 会因为无法消费多模态 projector tensors 而报错。

### 迁移成本

从 llama.cpp / Ollama 迁移到 Hypura：

- **安装**: `git clone --recurse-submodules` + `cargo build --release`，需要 Rust 1.75+ 和 CMake。约 10-15 分钟编译时间。
- **使用**: CLI 命令简洁（`hypura run`、`hypura serve`、`hypura bench`），与 llama.cpp 的使用习惯类似。
- **兼容性**: Ollama API 兼容意味着已有工具链（如 OpenClaw）只需修改 baseUrl 配置即可切换。
- **注意事项**: 需使用 text-only GGUF（非多模态 bundle）；instruction-tuned 模型需手动构造 chat template（auto-template 计划中）。

总迁移成本：**低**。对于已有 llama.cpp 经验的用户，迁移主要工作是编译安装和确认 GGUF 格式兼容。

## 关键代码/配置片段

### 安装与使用

```bash
git clone --recurse-submodules https://github.com/t8/hypura.git
cd hypura
cargo build --release

# Profile 硬件（首次运行，结果缓存）
hypura profile

# 运行推理
hypura run ./gemma-4-26B-A4B-it-Q4_K_M.gguf --prompt "Hello, world"

# 启动 Ollama 兼容服务
hypura serve ./model.gguf --host 127.0.0.1 --port 8080
```

### 与 OpenClaw 集成

```json
// ~/.openclaw/openclaw.json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:8080",
        "api": "ollama"
      }
    }
  }
}
```

### Gemma 4 手动 chat template（当前必须）

```bash
hypura run --prompt "$(printf 'user\nWhat is the capital of France?\nmodel\n')" \
  --max-tokens 100 ./gemma-4-26B-A4B-it-Q4_K_M.gguf
```

### 核心架构模块

```
scheduler/placement.rs    — LP + greedy 张量跨 GPU/RAM/NVMe 三层放置
compute/inference.rs      — 推理引擎：generate_blocking, generate_with_nvme_scheduling
compute/nvme_backend.rs   — 自定义 GGML buffer、pool-based expert/FFN 流式、neuron cache
model/tensor_role.rs      — 张量分类（norms, attention, MoE experts）用于放置评分
profiler/                 — 硬件检测（CPU、GPU、内存带宽、NVMe 吞吐）
```

## 对你的意义

Hypura 代表了本地 LLM 推理的一个有趣方向：**不是追求极致速度，而是追求"能让跑不了的模型跑起来"**。

对于 Ken 的 AI 应用开发工作：

- **如果团队有 Apple Silicon Mac 且需要本地跑大模型**，Hypura 是一个值得关注的工具。特别是 MoE 模型（如 Mixtral、Gemma 4）的推理能力，在 32GB Mac 上达到可用速度。
- **Ollama 兼容 API** 意味着它可以无缝接入现有的 Agent 工具链（如 OpenClaw），不需要额外的适配层。
- **SparseMoeMmap 路径**的设计思路（理解模型架构 → 绕过不必要的中间层 → 让 OS 处理稀疏性）对任何本地推理系统都有启发价值。

**建议**: 如果团队有 32GB+ Mac 且需要跑 30B+ 模型，值得试用。如果只需要跑 7B-14B 模型，暂不需要迁移。

---
[← Back to Deep Dives](./README.md)
