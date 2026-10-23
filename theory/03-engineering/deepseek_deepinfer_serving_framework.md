---
auto_generated: true
generated_at: "2026-10-23T12:41:44Z"
source_url: "https://github.com/deepseek-ai/DeepInfer"
signal_type: "significant_update"
---
# DeepSeek 开源 DeepInfer：把自家生产线推理栈放出来，但只放了一半 (DeepSeek Open-Sources DeepInfer: Its Production Serving Stack, Half of It)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-23
>
> **项目/工具**: DeepInfer (deepseek-ai/DeepInfer)
> **链接**: https://github.com/deepseek-ai/DeepInfer
> **核心定位**: DeepSeek 官方「支撑其大规模生产服务」的推理框架开源版——v0.1.0，只开放**离线批推理**，主打 DSpark 投机解码、SWA 有界回放、批不变性与确定性采样这些以往只写在技术报告里的机制。

## ⚡ 快速判断（30 秒读完这段就够）

- **一句话定位**：vLLM 血统的 DeepSeek 生产推理栈，开源出离线推理路径 + 若干「结果可复现」级工程特性，在线服务所需组件明确缺席。
- **现在值得用吗**：看场景 —— 有 SM100（B200/GB200 级）或昇腾 950 机器、且需要跑 DeepSeek-V4.1-Flash 离线批量评测/回归，值得一读代码；只是想本地跑推理，现在完全不要碰。
- **适合场景**：V4.1-Flash 的离线批量生成、Pass@1 评测流水线、多机 EP 拓扑实验、需要「同输入必同输出」的回归基线。
- **不适合场景**：单卡/消费级 GPU、需要在线低延迟服务、非 DeepSeek 模型、没有 SM100/昇腾 950 的团队。
- **与 vLLM 核心差异**：同一血统，但把 DeepSeek 自己的 kernel 栈（FlashMLA / DeepGEMM / DeepEP / TileKernels / DeepSelect）和 DSpark 投机解码直接焊进调度器，并补上 vLLM 通常不保证的批不变性与确定性采样。

## 是什么 / 解决什么问题

DeepInfer 的 README 第一句就是身份声明：

> "DeepInfer is the high-performance inference framework that powers DeepSeek's large-scale production services. This open-source release provides offline inference with the core features needed for serving at scale."

这句话里藏着这次开源真正的边界。它**不是**一个 vLLM 替代品，也不是一个可自托管的服务端——README 明确列出「完整推理服务所必需、但本次发布不包含」的三件事：

- 一套 KV cache 系统
- VE / Prefill / Decode 三段分离（disaggregation）
- 跨 DP 副本的 prefill 与 decode 负载均衡

也就是说，DeepSeek 放出来的是**引擎内核 + 离线批推理入口**，而那套让 1M 上下文在线上服务得起的缓存层和路由层，留在墙内。这个取舍本身比技术细节更值得读：它等于承认「推理性价比」的胜负手不在 kernel，而在 KV 层与调度层。

横向看，这条线的竞争已经不在「谁更快」而在「谁更可复现」。vLLM 长期默认「相同 prompt 不同 batch 组合，输出可能不同」；DeepInfer 把 **batch-invariant（批不变）** 和 **deterministic sampling（确定性采样）** 写成了一级特性并配了环境变量开关。对一个要跑 Pass@1 评测、要对比模型 A/B、要给客户复现 bug 的团队来说，这在工程上比多 10% 吞吐更有用。

## 技术架构拆解

### 核心设计决策

| 决策 | 内容 | 理由 / 影响 |
|------|------|------|
| 只发离线路径 | 不提供 KV cache 系统 / PD 分离 / 跨副本负载均衡 | 保留生产护城河，同时让外部能复现 kernel 与算子层的成果 |
| 全栈自研 kernel | FlashMLA、DeepGEMM、DeepEP、TileKernels、DeepSelect、TileLang 定制算子 | 从 attention 到 MoE 分发的每一层都可控；也意味着**深度绑定 DeepSeek 模型结构** |
| DSpark 置信度调度验证 | draft tokens 加速解码 + 用置信度决定验证调度 | 把投机解码的接受率问题交给模型侧置信度，而不是单纯加大 draft 长度 |
| SWA 有界回放 | decoder prefill 只重放有界后缀 | 用「窗口 + 最大回溯长度」换掉全量 prefill，直接压首 token 之前的工作量 |
| 异步调度 | CPU batch 调度与设备执行重叠，**默认开启** | 追求 zero-overhead batch scheduler；默认开也说明内部已足够稳定 |
| 批不变 + 确定性采样 | 环境变量开启，NVIDIA only | 让「同输入 → 同输出」成为可承诺的性质，是评测与回归的前提 |
| 双硬件后端 | NVIDIA SM100 / 华为昇腾 950 NPU 平级支持 | 昇腾不是「顺手适配」，而是有独立 requirements 与 CI marker 的一等后端 |

### 与前版/竞品的关键差异

| 维度 | vLLM（通用） | DeepInfer（本次） |
|------|-------------|------------------|
| 模型覆盖 | 广，几乎全生态 | 仅 DeepSeek-V4.1-Flash |
| 优化目标 | 通用吞吐与延迟 | DeepSeek 自家模型 + 自家 kernel 栈的最优解 |
| 批不变性 | 一般不保证 | `DEEPINFER_BATCH_INVARIANT=1` 显式保证 |
| 确定性采样 | 受限 | 需同时关闭 MTP 变长 + 固定 `seq_seed`（NVIDIA only） |
| 结构化输出 | 支持（插件） | 内建 regex / JSON schema / EBNF，走 `SamplingParams(so_args=...)` |
| 在线服务 | 支持 | **不包含**（无 KV cache 系统、无 PD 分离） |
| 硬件 | 广泛 CUDA | SM100 GPU / 昇腾 950 NPU |
| 代码血缘 | 自身 | README 明示「原初主要建立在 vLLM 之上」，并致谢 SGLang、TensorRT-LLM |

### 架构 / 信息流图

```
                 ┌──────────────────────────────────────────┐
                 │  examples/offline_inference.py (入口)     │
                 │  --ep / --dp / --cp / --long_context      │
                 └───────────────────┬──────────────────────┘
                                     │ launch_dp() 按 DP rank 分裂
   ┌─────────────────────────────────┴─────────────────────────────────┐
   │                      DeepInfer Engine                              │
   │                                                                    │
   │  Scheduler (异步 CPU batch 调度，与设备执行重叠)                     │
   │        │                                                           │
   │        ├── Prefill: chunked + SWA 有界回放(compact, keep=140)       │
   │        └── Decode : DSpark draft → 置信度调度验证 → 采样            │
   │                                                                    │
   │  Kernel 层: FlashMLA | DeepGEMM | DeepEP(+EPLB) | TileKernels      │
   │             DeepSelect | TileLang 定制算子                          │
   │                                                                    │
   │  横切性质: batch-invariant | deterministic sampling | 结构化输出     │
   └─────────────────────────────────┬─────────────────────────────────┘
                                     │
                      NVIDIA SM100 (CUDA 13)  /  昇腾 950 (CANN 9.2)
```

并行策略上，README 给的是「Attention DP / balanced CP，MoE EP + EPLB」：attention 侧按数据并行切、按序列做均衡上下文并行；MoE 侧专家并行并挂 EPLB（专家负载均衡）。离线示例的默认就是 `--ep 8`，且 `--disable_eplb` 是显式关闭项——说明 EPLB 在生产里是默认开着的。

### 性能数据（README 声称，未独立验证）

README 只给了两张 Pareto 图，**没有任何数值摘要**：

| 项 | 测量条件 | 指标 |
|----|---------|------|
| Prefill | 4 × SM100 GPU（同一 scale-up 域内） | non-cached input throughput vs. latency |
| Decode | 64 × SM100 GPU（同一 scale-up 域内） | output throughput vs. per-user speed |

复现入口是 `examples/sweep/run_sweep.sh`。这里有两点必须说清楚：第一，**本文不引用任何具体吞吐/TPS 数字**，因为 README 没写，我不编；第二，这两张图是 Pareto 曲线而非单点数字，遮住了「在哪个延迟约束下赢多少」这个关键前提。要看真实数字得自己跑 sweep。

评测侧倒是给了明确规模（`eval/README.md`）：AIME 2026（30 题 × 32 采样）、HLE（2500 题，2158 文本 + 342 图像，单采样）、GPQA Diamond（198 题 × 8 采样），统一按 **Pass@1** 计分，且生成与打分两阶段分离——可以用不同 judge 重打分而不用重新生成。这套设计比很多开源项目严谨。

## 实用评估

### 什么场景值得用

- **V4.1-Flash 离线批量评测**：eval 目录直接提供三套 benchmark 的两阶段驱动脚本，`run_eval.py` 单批提交 + `score.py` 独立打分，适合做自家评测基线。
- **多机 EP 拓扑实验**：`--ep / --dp / --cp` 三个轴加上 EPLB 开关，配上 `_launch.run_dp` 的跨节点分裂，是研究 MoE 专家并行负载分布的现成实验台。
- **需要可复现输出的回归测试**：batch-invariant + 固定 `seq_seed` 的组合，让「同输入同输出」成为可断言的性质；项目自己就靠这个维护 `tests/models/offline_decode_ppl.json` 的逐样本 PPL 黄金基线。
- **昇腾 950 早期探索**：这是少数把 Ascend 950 写成一等后端（独立 requirements、`ci_npu` marker、CANN 9.2）而非「社区适配」的主流模型方推理栈。

### 什么场景不值得用

- **消费级卡 / 单卡**：只支持 SM100 与昇腾 950。A100、H100、4090 一律不在支持列表里。
- **想自托管在线服务**：缺 KV cache 系统、PD 分离和跨副本负载均衡，这三块是「能跑」和「能服务」的分水岭。README 自己没有粉饰这一点。
- **跑别的模型**：只支持 DeepSeek-V4.1-Flash。kernel 栈（FlashMLA / DeepSelect 等）与 MoE 结构强绑定，不是改个 config 就能换模型。
- **需要非 NVIDIA 上的确定性采样**：`DEEPINFER_BATCH_INVARIANT=1` 与确定性采样都标注 **NVIDIA only**，昇腾用户拿不到这个保证。
- **对稳定性要求高的生产初期**：v0.1.0、`Development Status :: 4 - Beta`，无 release tag、无 changelog。上线前需要自己承担版本漂移风险。

### 迁移成本

| 项目 | 工作量 |
|------|--------|
| 环境 | Linux + GCC ≥ 13 + Python 3.12 + CUDA 13（或 CANN 9.2）；`./build.sh` 从源码构建 vendor 算子与 in-tree 扩展 |
| 依赖 | `requirements-nvidia.txt` 钉死 `torch==2.13.0+cu132` 与 `flash-attn-4==4.0.0b34`（beta 版本）；昇腾走 `torch==2.13.0+cpu` + `torch-npu==2.13.0rc1` |
| 模型 | 默认 `deepseek-ai/DeepSeek-V4.1-Flash-1017`，首跑自动下载；离线场景用 `DEEPINFER_HF_MODEL_DIR` 指本地 |
| 从 vLLM 迁移 | 调用面相似（`create_llm` + `SamplingParams`），但 kernel 与模型绑定意味着迁移实际是「换引擎」而不是「换 config」 |
| 评测迁移 | 需自备数据集并转 JSONL（HLE、GPQA 都是 gated 数据集，要先在 HF 接受条款） |

## 对你的意义

对我们的 Pulsar 系统：**现在没有直接收益，但有两处该抄的设计。**

第一处是**生成与打分分离**。我们的 AI 日报、VLA Hotspots、Deep Dive 都是「一次跑完就写文件」，想换 judge 或改评分标准就必须重跑整条链路，花的是模型钱。DeepInfer eval 的两阶段结构——生成阶段把所有请求一次性提交、原始输出落盘，打分阶段只读落盘结果——正是我们缺的那层解耦。这对 VLA 日报的「论文质量打分」尤其适用：抓取与初评分离后，评分标准迭代就不再需要重抓。

第二处是**黄金基线 + 逐样本比对**。他们用 `tests/models/offline_decode_ppl.json` 存每个 DP rank 的样本级 PPL 基线，测试时逐样本严格比对，一旦数字变了必须显式确认「是预期变化」才刷新基线。我们的确定性脚本（RSS 采集、去重、分类）目前只有「跑通/报错」两种状态，没有「输出数值漂移」这一维。给 daily-stats 这类脚本加一层输出指纹基线，比再加一个 watchdog 检查更根本。

至于「要不要试 DeepInfer 本身」——不试。我们没有 SM100，没有昇腾 950，跑的是 Claude/DeepSeek API 而不是自托管 V4.1-Flash。真正值得读的是这个仓库的**代码组织**（`csrc/` 与 `vendor/` 的边界、`deep_cluster/hardware.py` 的硬件抽象），那是「怎么让一套引擎同时伺候两种完全不同的加速器」的教科书样本。

## 关键代码/配置片段

构建（NVIDIA 平台；昇腾把值换成 `ascend`）：

```bash
# Keep it exported in the environment where you run DeepInfer
export DEEPINFER_ACCELERATOR=nvidia
./build.sh
```

离线推理（来自 `examples/README.md`）：

```bash
python examples/offline_inference.py --ep 8
python examples/offline_inference.py --ep 2 --dp 8
python examples/offline_inference.py --ep 2 --cp 8
```

关键环境变量（全部来自 README 特性说明）：

| 变量 | 作用 | 备注 |
|------|------|------|
| `DEEPINFER_ENABLE_MTP_VARLEN=1` | 启用 DSpark + 置信度调度验证 | `DEEPINFER_USE_NEXTN_DECODE` 控制最大 draft 长度，默认 5 |
| `DEEPINFER_YOCO_PREFILL_TRUNCATION_MODE=compact` + `DEEPINFER_YOCO_PREFILL_KEEP_TOKENS=140` | SWA 有界回放默认 V4.1 配置 | 保留后缀必须覆盖 SWA 窗口 + 最大回溯长度 |
| `DEEPINFER_BATCH_INVARIANT=1` | 批不变推理 | NVIDIA only |
| `DEEPINFER_BATCH_INVARIANT=1 DEEPINFER_ENABLE_MTP_VARLEN=0` + 固定 `seq_seed` | 确定性采样 | 两个变量必须同时设，NVIDIA only |
| `DEEPINFER_HF_MODEL_DIR` | 指向本地权重目录 | 不覆盖显式传入的 `--model_name` |

结构化输出走 `SamplingParams` 参数而非全局配置：

```python
# 约束到 regex / JSON schema / EBNF
SamplingParams(so_args={"schema_type": ..., "schema": ...})
```

完整示例见 `examples/_structured_output.py`。离线示例默认在 NVIDIA 上 `os.environ.setdefault("DEEPINFER_BATCH_INVARIANT", "1")`，也就是**默认就要求批不变**——这不是可选项，是他们对「结果可信」的默认立场。

License：Apache 2.0。

---
[← Back to Deep Dives](./README.md)
