---
auto_generated: true
generated_at: "2026-09-14T06:45:37Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/deploying-qwen3-8-2-4t-a95b-on-amazon-sagemaker-hyperpod-with-vllm/"
signal_type: "significant_update"
---
# 在 SageMaker HyperPod 上用 vLLM 部署 Qwen3.8-2.4T-A95B (Deploying Qwen3.8-2.4T-A95B on Amazon SageMaker HyperPod with vLLM)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-14
>
> **项目/工具**: Amazon SageMaker HyperPod + vLLM (部署对象: Qwen3.8-2.4T-A95B)
> **链接**: https://aws.amazon.com/blogs/machine-learning/deploying-qwen3-8-2-4t-a95b-on-amazon-sagemaker-hyperpod-with-vllm/
> **核心定位**: 一份"从零到 OpenAI 兼容端点"的完整实操指南，回答一个问题——2.4 万亿参数的开源 MoE 模型，如何在单台 8 卡 B300 节点上以 NVFP4 量化跑起来，并开启推理 / 工具调用 / 投机解码。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句话定位**：把 Qwen3.8（首个以开源权重发布的 Qwen-Max 级模型）部署到 Amazon SageMaker HyperPod，用 vLLM + NVFP4 量化实现单节点 8 卡托管。
- **现在值得用吗**：看场景——如果你有合规 / 数据驻留要求、且规模化推理成本高于自建 GPU 成本，值得；如果你只是中低并发调用，直接用 API 更划算。
- **适合场景**：高并发、长上下文（累计工具输出 / 代码 / 推理轨迹）的 Agent 与代码类工作负载；需要数据不出内网的团队。
- **不适合场景**：低频调用、PoC 阶段、没有 committed GPU 预算的团队（该实例按 Flexible Training Plan 预留，不能按需开机）。
- **与"直接调 API"核心差异**：换取数据主权与无 per-token 费用，代价是要自备 2.1 TB GPU 显存的专用基础设施和一套运维栈。

## 是什么 / 解决什么问题

Qwen3.8-2.4T-A95B 是阿里 Qwen 团队于 **2026 年 8 月 12 日**发布的开源权重模型，也是**首次把 Qwen-Max 级别的模型以开放权重形式放出**。它拥有 2.4 万亿总参数、每 token 激活 95 亿参数，采用"线性注意力 + 全注意力"混合架构，原生上下文 262,144 tokens（可扩展至 1,010,000），面向最重的 Agentic 与推理工作负载——多步编码、长时程规划、自主工具调用。

选择开源自托管的核心动机是控制权：数据留在自己的基础设施内、推理行为可定制、规模化时没有 per-token API 费用。但代价是运维——托管一个 2.4T 参数的模型需要专用 GPU 基础设施和优化过的服务栈，这不是"下载权重就能跑"的事情。

这篇文章（系列第二篇，第一篇讲 Kimi K3）给出的正是一条可复制的落地路径：在 SageMaker HyperPod 上用 vLLM，在一台 `ml.p6-b300` 实例（8× NVIDIA B300 Blackwell Ultra）上把模型跑起来，并覆盖 NVFP4 量化、内置推理、工具调用、原生 MTP 投机解码等配置。对团队而言，它的价值不在"又一个部署教程"，而在于**把万亿参数 MoE 的显存预算、量化选择与 vLLM 启动参数一次性讲透**。

## 技术架构拆解

### 核心设计决策

- **3:1 混合注意力（69 层 Gated DeltaNet + 23 层 Gated Attention）**：这是长上下文高效推理的关键。Gated DeltaNet 层用带界递归状态（bounded recurrent state）替代不断增长的 KV-cache，即固定大小记忆；Gated Attention 层保留完整二次注意力以保证高保真 token 交互。层布局为 `3 × (Gated DeltaNet → MoE) → 1 × (Gated Attention → MoE)` 循环。结果是上下文逼近 1M token 时，计算与显存都保持有界——这正是多轮 Agent 工作负载（累积工具输出与代码）最需要的性质。
- **细粒度 MoE（512 路由专家 + 1 共享专家，每 token 激活 10 个路由专家）**：把容量分散到大量小专家而非少数大专家，提升路由效率与专业化程度。每前向仅约 95B 参数激活，**服务成本跟随激活参数而非 2.4T 总量**。
- **原生 MTP（Multi-Token Prediction）draft heads**：投机解码的草稿头直接打包在模型权重里，无需额外下载独立的 draft 模型，草稿步复用已有 hidden states，额外延迟极小。
- **内置推理控制（`reasoning_effort`: low/medium/high）**：按请求粒度在"推理深度"和"吞吐"之间取舍，难题调高、高吞吐任务调低。
- **量化是单节点部署的前提**：BF16 下 2.4T 参数权重约需 **4.8 TB**，超过单节点；NVFP4（W4A4）压到约 **4 位/参数**，权重总量降至约 **1.2 TB**，恰好塞进 p6-b300 的 2.1 TB 聚合显存。

### 与前版/竞品的关键差异

| 维度 | BF16 原生精度 | 本方案（NVFP4 + 单节点） |
|------|------------|------------|
| 权重显存 | ~4.8 TB | ~1.2 TB |
| 单节点可否容纳 | 否（需跨节点） | 是（p6-b300 8 卡，2.1 TB） |
| 投机解码 | 需外挂 draft 模型 | 原生 MTP 头，零额外下载 |
| 上下文扩展性 | KV-cache 随上下文线性增长 | 69/92 层固定递归状态，仅 23 层随上下文增长 |
| 采购方式 | —— | 需 Flexible Training Plan 预留，无法按需开机 |

### 架构/信息流图

```
                SageMaker HyperPod (EKS 编排)
                          │
        InferenceEndpointConfig (CRD) ── 声明 model / image / GPU / vLLM args
                          │
              ┌───────────┴───────────┐
              │  Inference Operator    │  model 下载 / 调度 / 健康检查 /
              │  (v3.x)                │  rolling update / KEDA 自动扩缩
              └───────────┬───────────┘
                          │
              ┌───────────┴───────────┐
              │  ml.p6-b300.48xlarge   │  8× B300 / 288GB HBM3e each
              │  vLLM + NVFP4 (TP=8)   │  ~1.2TB 权重常驻
              └───────────┬───────────┘
                          │
              OpenAI 兼容端点  /v1/chat/completions
              (reasoning_content 与 content 分流)
```

## 实用评估

### 什么场景值得用

- **数据不出内网的合规场景**：权重、推理全在自己的 VPC / 集群内，适合金融、医疗、以及有数据驻留硬约束的团队。
- **高并发长上下文 Agent 流水线**：混合注意力的固定递归状态让 1M 级上下文的内存增长可控，适合累积工具输出、代码与推理轨迹的多轮任务；配合 `--enable-prefix-caching` 复用共享前缀的 KV-cache，多轮对话收益明显。
- **规模化成本已被 API 费用反超时**：无 per-token 费用，长期高频调用的成本模型更优。

### 什么场景不值得用

- **低频 / PoC**：`ml.p6-b300.48xlarge` 需通过 Flexible Training Plan 预留，没有按需实例、冷启动受限，为偶发调用自建不划算。
- **不愿承担运维复杂度**：需要维护 EKS 集群、Inference Operator、GPU 驱动、节点故障自愈与扩缩策略——这是一套持续运维成本，不是一次性投入。
- **对量化精度极敏感的评测场景**：NVFP4 是 W4A4 量化，虽然面向生产推理，但若你的任务对数值精度极度敏感，需自行验证质量回归。

### 迁移成本

- 从 API 调用迁到自托管：需要新建 HyperPod 集群（EKS）、申请 Flexible Training Plan、部署 p6-b300 worker group 并等待节点健康，然后应用 `InferenceEndpointConfig`。客户端侧几乎零改动——端点暴露 OpenAI 兼容 API，直接用官方 OpenAI SDK 即可，只需把 `base_url` 指向服务端点、`api_key` 填 `unused`（vLLM 默认不鉴权）。
- 冷启动：全新部署（无缓存权重）约需 **15–30 分钟**（先下载约 1.2 TB 权重，再加载到显存）；有本地 NVMe 缓存后重启显著更快。

## 对你的意义

从 Ken 的双线视角看，这篇的价值更多在"Agent 运行时的成本结构"，而非模型本身：

- **工程线（AI App）**：Agent 产品的成本瓶颈正在从 prompt 转移到推理基础设施。当模型可自托管、且激活参数仅 95B 时，"per-token 定价"这一层被绕过，SaaS 的毛利模型会重写。做 Agent 工具链时，值得把"可自托管权重"作为架构分叉点提前预留。
- **研究线（VLA）**：混合线性注意力 + 固定递归状态这套"让上下文不爆显存"的设计，正是长时程具身 Agent（累积感知 / 动作历史）最缺的能力。Qwen3.8 的 3:1 DeltaNet 布局可作为 VLA 长上下文骨干的一个参考实现。

**建议**：观望为主。除非你确有合规或高频调用需求，否则现在为单模型自建 B300 集群的性价比一般。但请把**原生 MTP 投机解码**与**混合注意力内存预算**这两个设计存进知识库。

## 关键代码/配置片段

vLLM 基础启动命令（来自官方 vLLM recipe for Qwen3.8 on B300 / NVFP4）：

```bash
vllm serve Inferact/Qwen3.8-2.4T-A95B-NVFP4 \
  --tensor-parallel-size 8 \
  --quantization nvfp4 \
  --load-format fastsafetensors \
  --trust-remote-code \
  --enable-prefix-caching \
  --moe-backend auto \
  --reasoning-parser qwen3 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3 \
  --speculative-config '{"method":"mtp","num_speculative_tokens":1}' \
  --served-model-name Qwen3.8
```

SageMaker HyperPod 的 `InferenceEndpointConfig` 清单（节选）：

```yaml
apiVersion: inference.sagemaker.aws.amazon.com/v1
kind: InferenceEndpointConfig
metadata:
  name: qwen38
spec:
  modelName: qwen38
  instanceType: ml.p6-b300.48xlarge
  invocationEndpoint: v1/chat/completions
  replicas: 1
  modelSourceConfig:
    huggingFaceModel:
      modelId: Inferact/Qwen3.8-2.4T-A95B-NVFP4
      modelSourceType: huggingface
  worker:
    image: vllm/vllm-openai:qwen38
    modelInvocationPort:
      containerPort: 8000
      name: http
    resources:
      limits:
        nvidia.com/gpu: 8
```

按请求关闭思考模式（保留最终答案、去掉推理轨迹）：

```python
response = client.chat.completions.create(
    model="Qwen3.8",
    messages=[{"role": "user", "content": "What is 2+2?"}],
    extra_body={"chat_template_kwargs": {"enable_thinking": False}},
)
```

> 补充事实（来源均为该 AWS 官方 blog，标注为"据官方"）：
> - 据厂商 benchmark，Qwen3.8-2.4T-A95 在 PaperBench 93.0、IFBench 82.8、终端编码 86.6；在 SWE-bench Pro 与 Toolathlon 等更难任务上仍有提升空间。
> - 显存预算（单 p6-b300）：权重 ~1.2 TB、递归状态固定 ~50–100 GB、激活与开销 ~100–200 GB，剩余 headroom 约 500–700 GB。
> - 吞吐参考：NVIDIA 在 GB300 NVL72（FP8、72 卡）Day-0 数据为 >4K tokens/sec/GPU、>350 tokens/sec/user；单台 8 卡 NVFP4 节点吞吐按比例更低。
> - 实例规格：8× B300，288 GB HBM3e/卡（合计 2.1 TB），8 TB/s/卡带宽，NVLink+NVSwitch 14.4 TB/s 对分带宽，FP4 约 15 PFLOPS/卡，192 vCPU，4096 GiB 内存，6,400 Gbps EFA，3.8 TB 本地 NVMe。
> - 完整清单与脚本见 aws-samples/sagemaker-genai-hosting-examples 仓库的 Qwen3.8-2.4T-A95B 目录。

---
[← Back to Deep Dives](./README.md)
