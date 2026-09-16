---
auto_generated: true
generated_at: "2026-09-16T08:00:51Z"
source_url: "https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash"
signal_type: "significant_update"
---
# DeepSeek V4.1-Flash 正式发布：552B MoE、原生多模态、KV Cache 压到 1/4 (DeepSeek-V4.1-Flash: Pushing the Limits of KV Cache Compression)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-16
>
> **项目/工具**: DeepSeek-V4.1-Flash
> **链接**: https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
> **核心定位**: 一个 552B 参数、1M 上下文、原生多模态的 MoE 模型，把长上下文的 KV Cache 压到前代的约 1/4，并把「每 token 只激活 8B（prefill）/16B（decode）」做成了面向 Agent 输入密集型负载的成本武器。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：DeepSeek 用一套全新的 Causal Encoder-Decoder（CED）+ Compressed Sparse Attention 2（CSA2）架构，把 1M 上下文的 KV Cache 缩到约 890 bytes/token，官方称相对 V4-Flash 约 4× 压缩、相对 V1 约 437×。
- **現在值得用嗎**：值得——**如果你的负载是长输入 + 短输出的 Agent / RAG / 代码库理解场景**（prefill 每 token 只激活 8B）。纯长输出生成不是它的性价比甜区。
- **適合場景**：长上下文 Agent（代码 agent、仓库级问答）、多模态文档理解（DocVQA 类）、需要 1M 上下文的检索增强管线。
- **不適合場景**：对多模态视觉输出有强需求的场景（该模型原生处理图像输入、自回归生成文本，不做图像生成）；需要旧版 `deepseek-v4-flash` 行为完全一致的存量系统（该模型已被退役、请求被路由到 V4.1-Flash）。
- **與 V4-Flash 核心差異**：参数量 284B → 552B，激活参数 13B → 8B/16B，KV Cache 890 bytes/token（约 1/4），并首次原生支持视觉（`Vision ✓`）。

## 是什么 / 解决什么问题

DeepSeek-V4.1-Flash 是 DeepSeek 的新一代旗舰级 MoE 模型，官方在模型卡里给出的定位非常明确：**"Pushing the Limits of KV Cache Compression"**。它同时是三个方向上的换代——从 284B（V4-Flash）扩到 552B backbone、上下文拉到 1M token、以及首次把视觉能力做成原生（而非外挂）模块。

真正要解决的痛点不是"更大的模型"，而是 **长上下文推理的内存与成本墙**。Agent 类负载的典型特征是：一次任务要反复把大量上下文（仓库代码、工具返回、历史轨迹）喂进模型（prefill 极重），但每次只需要输出一小段决策或工具调用（decode 很轻）。传统 Transformer 的 KV Cache 会随上下文线性膨胀，1M token 级别的 Agent 负载几乎无法经济地承载——这正是 V4.1-Flash 架构改动的靶心。

> TODO: 监控日報信号称本次「最高降价 60%」，本文未能在官方一手页面核对到该百分比的口径（是相对 V4-Flash 还是相对某竞品、是否含峰谷时段差异）。官方定价页已给出 V4.1-Flash 的绝对值（见下），如需引用降幅数字请以官方公告为准。

## 技术架构拆解

### 核心设计决策

- **CED（Causal Encoder-Decoder）架构**：40 层 Transformer，拆成 20 层因果编码器 + 20 层解码器。关键点在于——**解码器的全局 KV Cache 是从编码器末层隐状态投影得到的，而不是从解码器各层自身隐状态推导**。这带来一个直接收益：prefill 阶段每 token 只激活 **8B** 参数，decode 阶段激活 **16B**。
- **SWA Bounded Replay**：对滑动窗口注意力（SWA）丢失的 KV 状态，只回放最近 `n_win` 个 token 来重建，**无需把 SWA KV 持久化到 SSD**，把持久化 KV 足迹进一步压到 V4-Flash 的约 **1/8**。
- **CSA2（Compressed Sparse Attention 2）**：给每个注意力层分配三种静态模式之一——**Full / Reindex / Reuse**，从而跨层共享主 KV 和 indexer K、复用 Top-K 稀疏注意力索引。解码器里的 **Hierarchical Sparse Indexer** 进一步把靠后的索引层限制在首个 Full Mode 层构建的候选池里，使更深层的索引成本**与上下文长度解耦**。
- **FP4 主 KV 缓存**：E2M1 格式，每 16 个通道一个 E4M3 scale。上述设计合起来把全局 KV Cache 降到 **890 bytes/token**。
- **Engram 条件记忆**：196B 参数的稀疏访问记忆，按 token 做 lookup。配合 1 个共享专家 + 384 个路由专家/层、每 token 激活 6 个路由专家的 MoE 结构。
- **DSpark 推测解码**：半自回归草稿生成 + 置信度调度的验证。
- **训练策略**：纯 from-scratch 多模态语料 45T token；稀疏注意力在 64K 序列长度训练，随后在 34T token 处扩展到 1M 上下文。后训练沿用标准 **SFT → RL → on-policy distillation (OPD)**，"所有实质性变化都在数据管线"——大规模自动化合成 agent 任务与环境。

### 与前版/竞品的关键差异

| 维度 | DeepSeek-V4-Flash（前代） | DeepSeek-V4.1-Flash（本次） |
|------|--------------------------|------------------------------|
| Backbone 参数 | 284B | **552B** |
| 激活参数 | 13B | **8B（prefill）/ 16B（decode）** |
| 上下文 | — | **1M** |
| KV Cache / token | 基准 | **890 bytes（约 1/4）** |
| 持久化 KV 足迹 | 基准 | **约 1/8** |
| 多模态 | 无原生视觉 | **原生视觉（Vision ✓）** |
| 注意力 | — | CSA2（Full/Reindex/Reuse）+ 层级稀疏索引器 |
| 推理强度控制 | — | **连续可调 reasoning_effort（整数 1–100）** |

> 数据来源：DeepSeek 官方模型卡（Hugging Face）与 DeepSeek API 定价页。

### 架构/信息流图

```
 图像 ──► DeepSeek-ViT ──► 2-layer MLP Projector ─┐
  (2D-RoPE, 3×3 pixel-unshuffle)                    │
                                                    ▼
 文本 ──────────────────────────────────────► 联合嵌入
                                                    │
        ┌───────────────────────────────────────────┘
        ▼
 ┌──────────────── 20 层 Causal Encoder ────────────────┐
 │  每 token 仅激活 8B 参数（prefill）                    │
 │  CSA2: Full / Reindex / Reuse 模式跨层共享 KV          │
 └───────────────────────┬──────────────────────────────┘
                         │ 投影出全局 KV Cache
                         │ (FP4 E2M1, ~890 bytes/token)
                         ▼
 ┌──────────────── 20 层 Decoder ───────────────────────┐
 │  Hierarchical Sparse Indexer（候选池受限，成本与       │
 │  上下文长度解耦）; DSpark 推测解码; Engram 条件记忆     │
 │  (196B, 稀疏 lookup)                                  │
 └───────────────────────┬──────────────────────────────┘
                         ▼
                  自回归文本生成

  MoE: 1 shared expert + 384 routed experts/层，每 token 激活 6 个
  SWA Bounded Replay: 只回放最近 n_win token，无需 SSD 持久化 SWA KV
```

## 实用评估

### 什么场景值得用

- **仓库级 / 长上下文代码 Agent**：官方在代码 agent 基准上给出 Terminal-Bench 2.1 **90.6**、Terminal-Bench 3.0 **30.0**、Terminal-Bench 4.0 **31.2**、DeepSWE v1.1 **74.2**、CyberGym **88.1**。其中 DeepSWE v1.1 用 mini-SWE harness 拿到 74.2，已接近 Opus-5.0 的 74.0（官方数据，N=8）。
- **输入密集型 Agent 工作流**：prefill 每 token 激活 8B 是成本杠杆——上下文越长、输出越短，越划算。AutomationBench 拿到 **54.8**（对比 DS-V4-Flash 的 37.7），Agent's Last Exam **31.8**。
- **多模态文档理解**：DocVQA 95.6、CVBench 77.9、MMMU-Pro 56.5、RefCOCO-avg 86.0，且定价页明确 `Vision ✓`。

### 什么场景不值得用

- **纯长输出生成**：output 定价按 token 计（见下），且模型优势集中在 prefill 的 KV 压缩；长输出不是它的性价比甜区。
- **需要旧行为完全兼容的存量系统**：`deepseek-v4-flash` 和 `deepseek-v4-flash-vision-exp` 旧模型名仍被接受，但**对应模型已退役，请求会被 V4.1-Flash 接管并按 Flash 价格计费**——行为可能有差异。
- **依赖非 Jinja 模板的严格复现**：本次发布**不包含 Jinja 格式 chat template**，依赖该模板做对齐的管线需自行适配。
- **HLE 等最难题的极高位需求**：HLE (Pass@1) 为 36.8（纯文本子集 39.1），低于 Opus-5.0 的 56.3、GPT-5.6 Sol 的 44.5，属于"够用但非第一梯队"。

### 迁移成本

- **模型名**：只需把 model 名换成 `deepseek-flash` 即可（OpenAI 兼容 base URL：`https://api.deepseek.com`；Anthropic 兼容：`https://api.deepseek.com/anthropic`）。
- **上下文**：1M context、最大输出 384K、并发上限 2500。
- **成本结构变化**：引入峰谷定价（详见下节），需要重新估算账单；off-peak 是 peak 的一半，把非实时任务挪到 off-peak 时段可直接省一半。
- **工作量**：对于标准 API 调用方，**接近零成本**（仅换 model 名）；对于自己写 prompt 模板 / 依赖视觉能力的管线，需要额外适配。

## 对你的意义

对 Ken 的 AI 应用线（Agent + UI / RAG 工具链），这次更新的价值点不在"模型更强"，而在**成本曲线被重画**：

1. **RAG / 长上下文管线**：890 bytes/token 的 KV 让"把整个代码库/文档集塞进 1M 上下文"从理论可行变成预算可行。如果你的 RAG 管线现在还靠重度 retrieval + rerank 压缩上下文，V4.1-Flash 给了"少检索、多塞上下文"的另一条路——值得做一次 A/B。
2. **Agent 编排**：prefill 8B 激活 + 1M 上下文 + 2500 并发，意味着工具调用密、上下文长的编排型 Agent 的单位成本明显下降。跨域交叉信号：这与 AI 应用侧"Agent harness 统一接口"（如 Vercel AI SDK 接入多编码 Agent）正好呼应——**harness 层抽象 + 便宜的长上下文模型 = 长程 Agent 的工程可行性**。
3. **建议动作**：**立即小规模试用**。用一两个长上下文真实任务（仓库问答 / 多文档综合）替换现用模型跑对比，重点看 **cache hit 成本 + off-peak 排程** 后的实际账单。视觉能力对以文本为主的 Agent UI 项目暂非刚需，可延后评估。

## 关键代码/配置片段

官方定价页给出的规格（DeepSeek API Docs，2026-09 口径）：使用 `deepseek-flash` 作为模型名，1M 上下文，最大输出 384K，支持 JSON Output / Tool Calls / Responses API / Anthropic API / Vision。

| 计费项（每 1M token） | Off-peak | Peak |
|---|---|---|
| 输入（Cache Hit） | $0.003 | $0.006 |
| 输入（Cache Miss） | $0.15 | $0.3 |
| 输出 | $0.6 | $1.2 |

> 来源：DeepSeek API Docs《Models & Pricing》。Off-peak 费率为 Peak 的一半；Peak 时段为 UTC 周一至周五 01:00–04:00 与 06:00–10:00，其余时间为 off-peak。

最小调用示意（OpenAI 兼容格式，模型名来自官方文档）：

```python
from openai import OpenAI

client = OpenAI(
    api_key="<YOUR_KEY>",
    base_url="https://api.deepseek.com",   # Anthropic 兼容端点: https://api.deepseek.com/anthropic
)

resp = client.chat.completions.create(
    model="deepseek-flash",   # 官方模型名；legacy: deepseek-v4-flash（已被路由到 V4.1-Flash）
    messages=[{"role": "user", "content": "..."}],
    # 官方支持 continuously controllable reasoning effort（整数 1–100）
)
```

> 备注：官方模型卡称推理强度在 instruct 评测中使用最大值 `reasoning_effort=100`，评测参数为 temperature=1.0、top_p=0.95。具体 API 参数名与传参方式请以 DeepSeek 官方 thinking mode 文档为准。

---
[← Back to Deep Dives](./README.md)
