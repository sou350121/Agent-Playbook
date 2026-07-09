---
auto_generated: true
generated_at: "2026-07-09T05:48:54Z"
source_url: "https://github.com/t8/hypura/releases/tag/v0.2.0"
signal_type: "significant_update"
---
# Hypura：让 Mac 跑超大模型的存储感知推理调度器 (Hypura — Storage-Tier-Aware LLM Inference Scheduler for Apple Silicon)

> 🔍 本文由 Moltbot 自动生成 | 2026-07-09
>
> **项目/工具**: Hypura (t8/hypura)
> **链接**: https://github.com/t8/hypura/releases/tag/v0.2.0
> **核心定位**: 一个 Apple Silicon 专用的 LLM 推理调度器，通过将模型张量智能分配到 GPU / RAM / NVMe 三层存储，让物理内存装不下的模型也能在 Mac 上运行而不崩溃。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句话定位**: Hypura 是 Apple Silicon 上的"超大模型运行器"——通过感知 GPU、统一内存、NVMe SSD 三层存储的带宽和容量差异，自动调度模型张量，让 32 GB Mac 跑 40 GB 模型成为可能。
- **现在值得用吗**: 是，如果你有一台 Apple Silicon Mac 且想本地运行超出物理内存的模型。目前仅限 Apple Silicon（M1-M5），不支持 x86。
- **适合场景**: 本地跑 70B+ 模型做推理实验；MoE 模型（Mixtral、Gemma 4）在 Mac 上的本地部署；需要 Ollama 兼容 API 的工具链集成。
- **不适合场景**: 需要高吞吐的生产部署（NVMe 流式推理速度 0.3-2.2 tok/s）；非 Apple Silicon 硬件；多模态 GGUF 模型（v0.2.0 尚不支持）。
- **与 llama.cpp 核心差异**: llama.cpp 要求模型完全装入内存（否则 OOM）；Hypura 通过 NVMe 按需流式加载，让超出内存的模型"能跑"但速度显著降低。

## 是什么 / 解决什么问题

Apple Silicon Mac 的统一内存架构有一个根本矛盾：内存带宽极高（M1 Max 约 400 GB/s），但容量有限。消费级 Mac 最高 128 GB（M 系列），而主流大模型（Llama 3.3 70B Q4_K_M 约 39.6 GB、Mixtral 8x7B Q5_K_M 约 30.9 GB）加上运行时开销很容易突破这个上限。naive 加载（如 llama.cpp 默认行为）会导致 OS swap thrash 直至 OOM killer 介入。

Hypura 的核心洞察是：**NVMe SSD 虽然慢（~5 GB/s 顺序读），但它是只读冷存储，不是 working memory**。模型推理时，Attention 层和 Norm 张量每个 token 都要访问（必须放 GPU/RAM），而 MoE 专家张量或 Dense FFN 权重可以按需从 NVMe 流式加载。通过理解模型架构和硬件能力，Hypura 自动求解张量放置优化问题，让"跑不了"变成"跑得慢但能跑"。

v0.2.0 版本（2026-07-09 发布）是该项目的一个重要里程碑：新增 Gemma 4 稀疏 MoE 架构支持、SparseMoeMmap 极速路径、M5 系列芯片支持，以及自动 CPU-only 降级。

## 技术架构拆解

### 核心设计决策

1. **三层存储感知放置**: GPU (Metal) → RAM → NVMe，每层有不同的带宽/容量特征。调度器根据张量角色（Attention/Norm/Embedding/Expert/FFN）和硬件 profile 自动分配。

2. **架构感知的稀疏性利用**: MoE 模型只有少量专家在每个 token 被激活（如 Mixtral 2/8、Gemma 4 4/128）。Hypura 不加载全部专家，而是通过 router 拦截 + neuron cache（99.5% 命中率）+ co-activation 预测来最小化 I/O。

3. **零开销路径**: 模型能装入内存时，Hypura 走 full-resident 模式，与 llama.cpp 性能完全一致（21 tok/s vs ~21 tok/s，Qwen 2.5 14B）。

4. **自动模式选择**: 根据模型大小、架构和可用内存自动选择推理模式，无需手动调参。

### 与前版/竞品的关键差异

| 维度 | llama.cpp (naive) | Hypura v0.1.0 | Hypura v0.2.0 |
|------|-------------------|---------------|---------------|
| 超出内存的模型 | OOM 崩溃 | 能跑 (expert-streaming / dense-FFN-streaming) | 能跑 + SparseMoeMmap 极速路径 |
| Gemma 4 支持 | ✅ (上游 llama.cpp) | ❌ | ✅ 原生支持 |
| M5 系列芯片 | ❌ (需上游更新) | ❌ | ✅ 原生支持 |
| MoE 低激活比优化 | 无 | router 拦截 + neuron cache | 新增 bypass 路径：直接 mmap，跳过 router |
| CPU-only 降级 | 手动指定 | 无 | 自动 fallback |
| 基准图表 | 无 | 无 | ✅ matplotlib + ASCII fallback |
| Ollama 兼容 API | ❌ | ✅ | ✅ |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────┐
│                    Hypura CLI/API                    │
│  hypura run | hypura serve | hypura bench | inspect  │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│              Placement Optimizer                     │
│  输入: GGUF 模型 + 硬件 profile (GPU/RAM/NVMe)       │
│  输出: 每个张量 → GPU/RAM/NVMe 分配方案               │
└──┬──────────┬──────────┬────────────────────────────┘
   │          │          │
   ▼          ▼          ▼
┌─────┐  ┌──────┐  ┌────────┐
│GPU  │  │ RAM  │  │ NVMe   │
│Metal│  │mmap  │  │pread() │
│     │  │      │  │F_NOCACHE│
│Attention│   │Expert/FFN   │
│Norms  │  │Overflow│      │
│Embeds │  │layers │       │
└─────┘  └──────┘  └────────┘
   │          │          │
   └──────────┴──────────┘
              │
       Forward Pass
              │
   ┌──────────┴──────────┐
   │  Neuron Cache (99.5%)│
   │  Co-activation Pred  │
   │  Speculative Prefetch│
   └─────────────────────┘
```

### v0.2.0 新增：SparseMoeMmap 极速路径

这是 v0.2.0 最有趣的技术创新。对于激活比 ≤ 15% 的 MoE 模型（如 Gemma 4 26B-A4B，激活比仅 6.25%），Hypura 发现 router 拦截机制本身带来了不必要的开销。新的 SparseMoeMmap 路径直接绕过 router-interception  machinery：

- **不做** pool slot 分配
- **不做** tensor pointer 重写
- **不做** eval callback 拦截
- **让 OS page cache 处理稀疏性**——通过 mmap，OS 自动只加载被访问的页面

Gemma 4 26B-A4B 在 M1 Max 32 GB 上达到 **51 tok/s**（SparseMoeMmap），这是 v0.2.0 最快的推理路径。作为对比，同模型在 expert-streaming 模式下会慢得多。

### Gemma 4 架构适配细节

Gemma 4 26B-A4B 的稀疏 MoE 架构有一些特殊之处，Hypura 做了针对性适配：

- **Fused FFN gate/up**: Mixtral 分离 gate/up 专家张量，Gemma 4 融合在一起 → 新增 `ExpertTensorType::GateUp` variant
- **Per-layer KV head counts**: Gemma 4 使用 interleaved sliding-window attention，每层 KV head 数量不同 → 需要 array-valued `attention.head_count_kv` 解析
- **Chat template tokenization**: 需要 `parse_special=true` 让 chat template token 被正确解析为 vocab ID 而非 raw bytes

## 实用评估

### 什么场景值得用

- **本地跑 70B+ 模型做实验/原型**: 在 32 GB Mac 上跑 Llama 70B Q4_K_M（39.6 GB）虽然只有 0.3 tok/s，但"能跑"本身就有价值——你可以验证 prompt、测试输出质量，而不需要租云 GPU。
- **MoE 模型本地部署**: Mixtral 8x7B 在 M1 Max 32 GB 上 2.2 tok/s，这是接近可用的交互速度。Gemma 4 26B-A4B 更是达到 51 tok/s。
- **工具链集成**: Ollama 兼容 API 意味着任何支持 Ollama 的工具（如 OpenClaw）都可以直接对接 Hypura，无需修改。
- **SSD 寿命顾虑**: FAQ 明确说明 Hypura 只做 read-only pread()，不写 NVMe，SSD 磨损可忽略。

### 什么场景不值得用

- **生产部署高吞吐**: 0.3-2.2 tok/s 的速度不适合生产。这是"能用"而非"好用"的方案。
- **非 Apple Silicon**: 仅支持 M1-M5 系列，x86 Mac 或 Linux 服务器不适用。
- **多模态 GGUF**: v0.2.0 的 LLM-only loader 无法处理包含 vision/audio/projector 张量的多模态 GGUF 文件（如 Ollama 的 gemma4 pull 包）。
- **chat template 自动应用**: v0.2.0 尚未支持，需要手动构造 prompt template（作者标注为 planned follow-up）。

### 迁移成本

从 llama.cpp 迁移到 Hypura：

1. **环境要求**: Rust 1.75+ 和 CMake（编译 vendored llama.cpp）。如果你已有 Rust 工具链，`cargo build --release` 约 5-10 分钟。
2. **模型格式**: 与 llama.cpp 完全兼容 GGUF 格式，无需转换。但需注意多模态 GGUF 的限制。
3. **使用方式**: CLI 命令类似（`hypura run` vs `llama-cli`），但多了 `hypura profile`（硬件探测，首次运行一次）和 `hypura inspect`（查看放置方案）。
4. **API 兼容**: 如果通过 Ollama API 使用，只需改 baseUrl 指向 Hypura 的 serve 端口（默认 8080），无需改代码。

**总体迁移成本**: 低。模型文件不变，CLI 语义相似，主要额外步骤是 `hypura profile` 和了解放置模式。

## 对你的意义

如果你有一台 Apple Silicon Mac 并且：
- 想本地测试 70B+ 模型但不想租云 GPU → Hypura 让你"跑起来"，哪怕速度慢
- 关注 MoE 架构的本地部署效率 → v0.2.0 的 SparseMoeMmap 路径（51 tok/s for Gemma 4）是目前 Apple Silicon 上最快的 MoE 推理方案之一
- 需要 Ollama 兼容的本地推理后端 → Hypura serve 可以直接替换 Ollama

**建议**: 如果你的 Mac 统一内存 ≥ 32 GB 且经常需要跑超出内存的模型，值得试用。从 `hypura bench` 开始，用 --max-tokens 10 测试新模型。

## 关键代码/配置片段

### 安装与运行

```bash
git clone --recurse-submodules https://github.com/t8/hypura.git
cd hypura
cargo build --release

# 首次运行：硬件探测（结果缓存）
hypura profile

# 运行推理
hypura run ./model.gguf --prompt "Hello, world"

# Ollama 兼容 API 服务
hypura serve ./model.gguf
# Endpoint: http://127.0.0.1:8080
```

### OpenClaw 集成配置

```json
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

### Gemma 4 手动 chat template（v0.2.0 暂不支持自动）

```bash
hypura run --prompt "$(printf 'user\nWhat is the capital of France?\nmodel\n')" \
  --max-tokens 100 ./gemma-4-26B-A4B-it-Q4_K_M.gguf
```

### 核心模块结构

```
hypura/
├── scheduler/placement.rs    # LP + greedy 张量放置优化
├── compute/inference.rs      # 推理引擎 + 服务器
├── compute/nvme_backend.rs   # NVMe 流式后端 + neuron cache
├── model/tensor_role.rs      # 张量角色分类
├── profiler/                 # 硬件检测
├── cli/bench.rs              # A/B 基准测试
└── server/routes.rs          # Ollama 兼容 HTTP API
```

---
[← Back to Deep Dives](./README.md)
