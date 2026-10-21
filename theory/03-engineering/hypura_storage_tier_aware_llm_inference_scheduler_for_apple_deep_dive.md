---
auto_generated: true
generated_at: "2026-10-21T03:31:00Z"
source_url: "https://github.com/t8/hypura/releases/tag/v0.2.0"
signal_type: "significant_update"
---

# Hypura v0.2.0：把「存储层级」当作一等公民的 Apple Silicon LLM 调度器 (Hypura v0.2.0: A Storage-Tier-Aware LLM Inference Scheduler for Apple Silicon)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-21
>
> **项目/工具**: Hypura（Rust 编写，Apple Silicon 专用本地 LLM 推理运行时）
> **链接**: https://github.com/t8/hypura/releases/tag/v0.2.0
> **核心定位**: 一个不假设「模型能塞进统一内存」的本地推理运行时——按存储层级（内存 / SSD 流式 / mmap 页缓存）自动决定每一层权重放在哪、每条 token 怎么走，让 15 GB～40 GB 的模型在 24～32 GB 的 Mac 上跑得起来。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：本地推理不再「要么全驻留、要么跑不动」，Hypura 用统一的 placement 引擎在统一内存、SSD 流式和 mmap 稀疏路径之间自动切换。
- **現在值得用嗎**：看场景——你有一台 M 系列 Mac、想跑本地 30B 级以下的量化模型、且接受「慢但能跑」优先于「快但跑不了」，就值得试。
- **適合場景**：把大模型留在本机做隐私敏感任务、Apple Silicon 上的个人 agent 后端、稀疏 MoE 模型实验。
- **不適合場景**：低延迟交互、批量生产吞吐、多模态模型、服务器 / NVIDIA 环境。
- **與 llama.cpp / Ollama 核心差異**：llama.cpp 的 offload 更像「显存不够就丢几层到 CPU/内存」的曲线救济；Hypura 把 SSD 流式、mmap 稀疏跳过和 CPU 兜底整合成一套有等级决策的调度器，并在此基础上做 benchmark 记录。

## 是什么 / 解决什么问题

本地跑大模型的核心矛盾一直没变：**统一内存是硬上限**。Apple Silicon 的统一内存带宽很高（M1 Max 约 400 GB/s 级别），但容量固定且不可升级；24 GB 的机器跑 Llama 3.3 70B Q4_K_M（约 39.6 GB）在传统方案里只有两个结局——OOM，或者被 swap 拖死。

Hypura 的立场很明确：不要假装内存够。它把「权重从哪一层读出来」「哪一部分常驻」「哪一部分按需流式」变成调度器的一等决策对象，而不是让用户在启动参数里手工调 `n_gpu_layers`。v0.2.0 是这个思路第一次被完整落到一个「有名字的架构模式」上，并同时给出了可复核的数字。

这次更新的三个实质变化：

1. **新增 `SparseMoeMmap` placement 路径**——面向激活率极低（≤ 15%）的稀疏 MoE，直接绕开 Hypura 自己的 router 拦截机制，把稀疏性交给操作系统页缓存；
2. **新增 Gemma 4 架构支持**（Google 的 26B-A4B 稀疏 MoE），并把上游 llama.cpp 子模块升级到 `66c4f9ded`；
3. **新增 CPU-only 兜底 + M5 系列硬件识别**——从「要么 GPU 路径、要么崩溃」变成「降级但可用」。

这不是一个「+5% 速度」的版本，而是把一个之前会直接失败的模型类，变成了可运行。

## 技术架构拆解

### 核心设计决策

- **Placement 优先于 Kernel 优化**：Hypura 的杠杆不在算子层，而在「每层权重放哪里、怎么读」。它把模型执行抽象为若干 placement mode（`full-resident`、`dense-FFN-streaming`、`expert-streaming`、`SparseMoeMmap`），由 placement engine 依据硬件 profile（working set limit / 带宽 / SLC）与模型结构选择。
- **稀疏 MoE 的两种截然不同的处理**：
  - `expert-streaming`：Hypura 自己拦截 router，只把本次被选中的专家从 SSD 流式读入。这是通用路径，但每次 forward 都有拦截与指针重写开销。
  - `SparseMoeMmap`：当激活率足够低（≤ 15%）且活跃工作集能装进统一内存时，**完全跳过 router 拦截**，直接 mmap，让 OS 页缓存负责把真正被触碰的页拉进来。「no pool slot allocation, no tensor pointer rewriting, no eval-callback overhead」——这是 v0.2.0 里最快的一条路径。
- **失败必须降级，不许崩**：超过 Metal working set 上限时自动切 `n_gpu_layers=0`（纯 CPU），页缓存仍然有效，代价是速度而非可用性。
- **硬件知识内建**：profiler 显式识别 M5 / M5 Pro / M5 Max，并套用对应的 working-set、带宽、SLC 参数——Apple 每代芯片的 SLC 与大核配置差异足以改变最优 placement。
- **诚实记录副作用**：文档专门加了 SSD 磨损 FAQ，承认流式路径消耗写入/读取寿命，这是不少「跑起来了」的方案会刻意略过的部分。

### 与前版/竞品的关键差异

| 维度 | llama.cpp / Ollama（典型用法） | Hypura v0.2.0 |
|------|------------------------------|---------------|
| 超内存模型 | 手工调 `n_gpu_layers`，部分 offload 到 CPU | Placement engine 自动选择内存 / SSD 流式 / mmap 等级 |
| 稀疏 MoE | 视作普通权重，全量参与访问 | `expert-streaming` 或 `SparseMoeMmap` 两级稀疏路径 |
| 激活率极低模型 | 无专门路径 | ≤15% 激活率走 mmap，让 OS 页缓存处理稀疏性 |
| 超限失败行为 | 常表现为慢、swap 抖动或直接 OOM | 自动降级 CPU-only 而非崩溃 |
| 新硬件适配 | 随上游更新 | profiler 内建 M1–M5 参数表（含 M5 Pro 误分类修复） |
| 多模态 GGUF | 支持情况视上游而定 | **明确不支持**打包式多模态 GGUF（见局限性） |
| 聊天模板 | 多数前端自动套用 | **v0.2.0 仍需手工构造**，自动套用列为后续计划 |

### 架构/信息流图

```
               ┌─────────────────────────────┐
   GGUF  ───▶  │   Hardware Profiler         │
               │  M1..M5 / working set /     │
               │  bandwidth / SLC            │
               └──────────────┬──────────────┘
                              │
               ┌──────────────▼──────────────┐
               │   Placement Engine          │
               │  (决定每层权重放哪里)        │
               └───┬───────┬───────┬─────────┘
                   │       │       │
        ┌──────────▼─┐ ┌───▼────┐ ┌▼──────────────┐
        │full-resident│ │stream  │ │SparseMoeMmap  │
        │ 全驻留内存   │ │SSD 流式 │ │mmap + 页缓存  │
        └────────────┘ └───┬────┘ └───────────────┘
                           │
                    ┌──────▼───────┐
                    │ 超 Metal 上限 │──▶ CPU-only 兜底 (n_gpu_layers=0)
                    └──────────────┘
```

## 实用评估

### 什么场景值得用

- **本机隐私敏感 agent**：把文档解析、代码补全、内网数据问答放在本地，模型越大越需要 Hypura 这类调度层来避免一次性买满内存。
- **稀疏 MoE 模型实验**：Gemma 4 26B-A4B 在 M1 Max 32 GB 上 51 tok/s 的官方数字，是「小而快」这条路线第一次在消费级 Mac 上被明确量化。6.25% 激活率（约 1 GB 活跃 / 15.6 GB 总权重）正是 `SparseMoeMmap` 的目标形态。
- **想在老机器上继续用大模型**：39.6 GB 的 Llama 3.3 70B Q4_K_M 在 24 GB 的 M5 Pro 上能跑，靠的就是流式路径——这是它的存在意义。

### 什么场景不值得用

- **交互式低延迟**：官方 benchmark 里最诚实的数字是 Qwen3-Coder-Next 80B-A3B（512 experts）在 M1 Max 上 **1.3 tok/s**、Qwen 2.5 Coder 32B Q8_0 **0.3 tok/s**。这些是「能跑」而非「能用」。流式路径的本质是拿 SSD 延迟换内存容量。
- **多模态**：打包式多模态 GGUF 直接加载失败，报错来自 `llama_model_load` 不消费 projector 张量。需要视觉/音频的必须另找方案。
- **生产吞吐 / 多并发**：没有 serving 层的 batching、调度、KV cache 复用设计，也不支持非 Apple Silicon。
- **SSD 寿命敏感的设备**：持续流式读取会累积磨损，作者自己写了 FAQ 提示权衡。

### 迁移成本

从 llama.cpp / Ollama 迁过来并不便宜：

- 安装需要 `git clone --recurse-submodules` + `cargo build --release`（Rust 1.75+、CMake），没有预编译包（v0.2.0 的 assets 为空）。
- **聊天模板要自己拼**：`hypura run` 尚未自动套用模板，instruct 模型必须手写 `<|turn>user\n...<turn|>` 这类特殊 token；v0.2.0 特别把 `parse_special=true` 打开，让模板 token 按 vocab ID 切分而不是原始字节。
- 工具链只覆盖 CLI 级别，没有 OpenAI 兼容 API、没有 Ollama 那种 `Modelfile` 与模型库。

粗略工作量：熟悉 Rust 工具链的人半小时内能跑通一个 demo；要接到现有应用里，需要自己包一层 HTTP 服务，按半天到一天估算。

## 对你的意义

对 Ken 的 AI App 线，这东西的价值不在这条 release 本身，而在它揭示的一个工程模式：**当模型规模的增长快于硬件容量时，调度层的价值会超过推理内核的微优化**。Hypura 的 placement engine 与 `SparseMoeMmap` 的分层思路，和你在 Agent 侧做的「模型能力路由」（快模型做简单步骤、强模型兜底）是同一个抽象——都是按成本分层、按需拉起。这条类比值得写进 Agent 设计笔记。

对 VLA 线则更直接：机器人端侧部署的算力约束比 Mac 更紧。稀疏 MoE + 极低激活率 + 页缓存/存储层级调度，是「在有限内存里放一个大 VLA 主干」的现实路径之一——虽然 VLA 的视觉编码器与动作头往往是 dense 的，MoE 化程度决定这套能否迁移。**建议：观望为主，抽半天跑一次 Gemma 4 demo 验证 51 tok/s 是否可复现；除非端侧部署需求提速，否则不必现在接入。**

## 关键代码/配置片段

安装（来自 release notes）：

```sh
git clone --recurse-submodules https://github.com/t8/hypura.git
cd hypura
cargo build --release
```

手工构造聊天模板运行 Gemma 4（v0.2.0 尚未自动套用模板）：

```sh
hypura run --prompt "$(printf '<|turn>user\nWhat is the capital of France?<turn|>\n<|turn>model\n')" \
  --max-tokens 100 ./gemma-4-26B-A4B-it-Q4_K_M.gguf
```

官方 benchmark（best-on-machine，来自 release notes）：

| 模型 | 大小 | 模式 | 硬件 | tok/s |
|---|---|---|---|---|
| Gemma 4 26B-A4B Q4_K_M | 15.6 GB | SparseMoeMmap | M1 Max 32 GB | 51 |
| Qwen3-Coder-Next 80B-A3B（512 experts） | — | expert-streaming | M1 Max 32 GB | 1.3 |
| Phi-3.5-MoE Q4_K_M | — | full-resident | M5 Pro 24 GB | 2.2 |
| Llama 3.3 70B Q4_K_M | 39.6 GB | dense-FFN-streaming | M5 Pro 24 GB | 有提升（未给具体值） |
| Qwen 2.5 Coder 32B Q8_0 | — | dense-FFN-streaming | — | 0.3 |

> TODO: release notes 中 Llama 3.3 70B 在 M5 Pro 上的数值仅标注 "improved"，无具体 token/s；Phi-3.5-MoE 的 "full-resident" 在 24 GB 机器上如何装下未说明，建议实测确认。

---
## 📌 AI Agent 假设追踪

| 假设 | 方向 | 关联说明 |
|------|------|----------|
| A-001: MCP 成为 AI Agent 工具集成事实标准 | 间接支持 | 本地推理运行时是 Agent 的模型层基础设施；Hypura 这类工具降低了「agent 走本地模型」的门槛，与 MCP 生态形成互补而非竞争。 |

---
[← Back to Deep Dives](./README.md)
