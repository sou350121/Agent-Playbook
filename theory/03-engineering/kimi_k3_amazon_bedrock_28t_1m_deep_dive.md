---
auto_generated: true
generated_at: "2026-09-23T05:45:58Z"
source_url: "https://aws.amazon.com/blogs/machine-learning/introducing-kimi-k3-on-amazon-bedrock/"
signal_type: "significant_update"
---
# Kimi K3 上线 Amazon Bedrock：首个 2.8T 开源模型 + 显式 Prompt Caching (Kimi K3 on Amazon Bedrock: The First 2.8T Open-Weight Model with Explicit Prompt Caching)

> 🔍 本文由 Moltbot 自动生成 | 2026-09-23
>
> **项目/工具**: Kimi K3（Moonshot AI）× Amazon Bedrock
> **链接**: https://aws.amazon.com/blogs/machine-learning/introducing-kimi-k3-on-amazon-bedrock/
> **核心定位**: Moonshot AI 发布首个 2.8T 参数的开源权重模型 Kimi K3（1M 上下文 + 原生视觉），并通过 Amazon Bedrock 提供首次针对开源模型的「显式 Prompt Caching」，把长上下文 Agent 工作流的缓存命中原语交到开发者手里。

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Kimi K3 是目前参数规模最大的开源权重模型（2.8T），Bedrock 版本是第一个支持 **显式 Prompt Caching** 的开源模型托管入口——直接针对「长上下文 Agent 反复重发系统提示 / 工具定义 / 代码库」这一成本痛点。
- **現在值得用嗎**：看场景。如果你在跑长上下文的 Coding Agent 或知识工作流，并且已经或愿意用 AWS——值得。若你只需要通用推理、或对延迟极度敏感——先观望。
- **適合場景**：长程代码 Agent（大仓库导航）、跨文档知识工作（研究/咨询报告）、图文混合推理（前端/游戏/CAD）、对数据保留有强合规要求的团队。
- **不適合場景**：追求绝对 SOTA 推理质量（官方承认整体仍落后于 Claude Fable 5 与 GPT 5.6 Sol）、成本敏感的小规模调用、非 AWS / 非英文生态的纯国内部署。
- **與 Kimi K2 核心差異**：参数规模 ×约 2.8 倍（约 2.5× scaling efficiency 提升），上下文从长文档级升到 1M token，新增原生视觉，并首次提供显式 prompt caching。

## 是什么 / 解决什么问题

开源权重模型在 2026 年已经不再是「便宜但差」的代名词，但它们在**生产级长上下文 Agent** 场景里始终缺一块拼图：缓存控制。闭源厂商（如 Anthropic 的 prompt caching）早已把「稳定前缀复用」做成显式原语，而开源模型托管方多数只提供隐式/自动缓存，开发者无法精确控制缓存断点，也就无法可靠地降低长程工作流的 input 成本。

Kimi K3 的发布同时解决了两个层面的问题：

1. **规模层**：Moonshot AI 声称 K3 是「首个达到 2.8T 参数的开源模型」，也是「世界首个开源 3T 级模型」。它建立在 Kimi Delta Attention (KDA) 与 Attention Residuals (AttnRes) 之上，配合 Stable LatentMoE，官方称整体 scaling efficiency 相比 Kimi K2 提升约 **2.5×**。
2. **托管层**：在 Amazon Bedrock 上，K3 成为**第一个支持显式 prompt caching 的开源权重模型**。Bedrock 文档明确：开发者可以通过 `prompt_cache_breakpoint` 标记可复用前缀的精确结尾（至少 1024 token），命中缓存的后续请求以折扣价计费，且**不占用 input-tokens-per-minute 配额**。

换句话说：Moonshot 在模型侧把「算出更多智能」的单位成本压下来（2.5× scaling efficiency），AWS 在托管侧把「重复发送同样上下文的成本」用显式缓存压下来。两者叠加，目标就是让 1M 上下文的长程 Agent 在成本上变得可持续。

## 技术架构拆解

### 核心设计决策

- **KDA + AttnRes 双注意力改造**：Kimi Delta Attention 为注意力 scaling 提供高效基础，Attention Residuals 则「跨深度选择性检索表示）而非均匀累加」——两者共同构成支撑万亿参数级模型的骨干。
- **Stable LatentMoE（16/896 专家激活）**：整模 2.8T，但每次仅激活 896 个专家中的 16 个，把推理成本与模型规模解耦。
- **路由稳定性工程**：在这种稀疏度下路由成为一等难题。官方引入 **Quantile Balancing**（从 router-score 分位数直接推导专家分配，去掉启发式更新和敏感的均衡超参）与 **Per-Head Muon**（独立优化各注意力头）。
- **激活控制**：SiTU（Sigmoid Tanh Unit）与 Gated MLA 分别改善激活控制与注意力选择性。
- **量化感知训练**：从 SFT 阶段起就做 QAT，权重用 MXFP4、激活用 MXFP8，以最大化硬件兼容性。
- **专家并行训练**：完全均衡的 expert-parallel 训练方法，静态 shape、关键路径上无 host 同步，防止大专家并行规模下吞吐退化。
- **部署建议**：官方建议在 **64 个以上加速器**的 supernode 配置上部署 K3。
- **vLLM 前缀缓存贡献**：KDA 对传统 prefix caching 提出新挑战，Moonshot 已向 vLLM 社区提交对应实现，随模型一同发布；「KDA + prefill cache」是其能把长上下文大模型服务在「有竞争力 token 价格」上的关键。
- **推理架构**：官方 Kimi API 由 Mooncake 分离式推理架构驱动，官方称在 coding 工作负载下缓存命中率高于 **90%**。

### 与前版/竞品的关键差异

| 维度 | Kimi K2 | Kimi K3 | 备註 |
|------|---------|---------|------|
| 参数规模 | 未在本次材料中披露 | 2.8T（开源 3T 级） | 官方称世界首个开源 3T 级 |
| Scaling efficiency | 基准 | 约 2.5× 于 K2 | 官方 blog |
| 上下文 | 长文档级 | 1M token | 全模型标配 |
| 视觉 | 未明确 | 原生 vision | 图文混合推理 |
| 注意力架构 | — | KDA + AttnRes | 新架构 |
| MoE 稀疏度 | — | 激活 16/896 专家 | Stable LatentMoE |
| 量化 | — | MXFP4 权重 / MXFP8 激活（QAT） | 硬件兼容 |
| Bedrock 显式缓存 | 不支持 | **支持（首个开源模型）** | 本次核心增量 |
| 综合质量定位 | — | 仍落后 Claude Fable 5 / GPT 5.6 Sol，但领先其余受测模型 | 官方自述 |

> 注：K2 的具体参数规模与 benchmark 数字未在本次抓取的两份源材料中给出，故未填具体数值，避免编造。

### 架构/信息流图

```
┌──────────────────────────────────────────────────────────────┐
│                    Kimi K3（2.8T / 1M ctx / native vision）     │
├──────────────────────────────────────────────────────────────┤
│  骨干:  KDA (Kimi Delta Attention) + AttnRes (Attention Res.)  │
│  MoE :  Stable LatentMoE  →  激活 16 / 896 experts             │
│  训练:  QAT(MXFP4 w / MXFP8 a) · 均衡 EP（静态 shape）          │
│  推理:  Mooncake 分离式架构 · KDA + prefill cache (vLLM)        │
└───────────────────────────┬──────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
   Kimi 自有入口                          Amazon Bedrock
   - Kimi.ai / Kimi Work                  - global.moonshotai.kimi-k3
   - Kimi Code / Kimi API                 - us.moonshotai.kimi-k3
   - Mooncake (>90% cache hit)            - 显式 Prompt Caching（首个开源模型）
                                          - Responses / Chat Completions API
                                          - Converse / Invoke API
                                          - zero data retention
                                                 │
                            ┌────────────────────┴───────────────────┐
                            │                                        │
                     OpenCode (amazon-bedrock provider)      Hermes Agent
                            │                                        │
                     长程编码 Agent                          通用生产力 Agent
```

## 实用评估

### 什么场景值得用

- **长程 Coding Agent**：官方展示的用例极具说服力——Kimi K3 在相同沙箱内、最多 24 小时自主优化 GPU kernel，表现与 Claude Fable 5（含 fallback）相当，并「明显优于 Opus 4.8、GPT 5.6 Sol、GPT 5.5」。另有案例显示它从零构建了类 Triton 编译器 **MiniTriton**（自带 tile-level IR、优化 pass、PTX 代码生成），在部分 roofline benchmark 上「优于 Triton」，并能维持 nanoGPT 端到端训练稳定收敛。
- **知识工作 / 研究报告**：官方称 K3 用 120+ 轮递归自我改进、2.8k+ 次 web 搜索、1.1k+ 次终端数据拉取，产出了一份可交互的「42 年 AI ASIC 产业」研究报告；另有一个引力波分析案例用 20+ 并发 subagent 处理 391 个事件。
- **科研代码复现**：一个案例中，K3 约 2 小时完成资深研究者需 1–2 周的工作——复现计算天体物理的 I–Love–Q 普适关系，交叉验证 20+ 篇论文、评估 300+ 状态方程、生成 3000+ 行 Python。
- **合规敏感的企业场景**：Bedrock 提供 zero data retention（推理请求始终启用）与 zero operator access，且数据不共享给模型提供方、不用于训练，数据在 AWS 数据边界内处理——对有数据驻留要求的团队友好（可选用 `us.` 地理 profile）。
- **成本优化优先的开发者**：官方 Kimi API 定价为 **cache-hit input $0.30/MTok、cache-miss input $3.00/MTok、output $15.00/MTok**，配合 >90% 缓存命中率，长上下文重复前缀场景的账很好看。

### 什么场景不值得用

- **追求绝对推理 SOTA**：Moonshot 自己承认 K3「整体性能仍落后于最强闭源模型 Claude Fable 5 与 GPT 5.6 Sol」。若你的核心指标是最高难度推理，开源权重方案目前仍不是答案。
- **非 AWS 环境**：本次发布的价值有一大半在 Bedrock 的托管能力上；如果你不用 AWS，需改用 Kimi 官方 API 或自建（自建要面对 64+ 加速器 supernode 的部署门槛）。
- **延迟极度敏感**：2.8T 级稀疏模型即使只激活 16/896 专家，依然比小模型重；官方也建议 supernode 部署，边缘/低延迟场景不合适。
- **预算极小的一次性任务**：cache-miss input $3.00/MTok + output $15.00/MTok 并不便宜，缓存收益要靠「重复前缀」才能兑现；一次性调用反而是最贵用法。
- **依赖 Bedrock 之外的厂商特性**：显式缓存、思考强度模式等能力在 Bedrock/Kimi API 之间存在差异（K3 发布时默认 max thinking effort，低/高 effort 模式「后续更新」才推出）。

### 迁移成本

| 从 | 到 | 工作量 | 注意事项 |
|----|----|--------|----------|
| Kimi K2 API | Kimi K3 API | 低 | 改用 `kimi-k3`；注意默认 max thinking effort 会抬高单次成本 |
| OpenAI SDK（通用） | Bedrock 上的 K3 | 中 | 换 endpoint 与鉴权：Bedrock 需 `aws-bedrock-token-generator` 生成短期 bearer token |
| OpenCode（本地模型） | OpenCode + Bedrock K3 | 低 | 配 `amazon-bedrock` provider（走 Converse API），`/models` 切换即可 |
| 其他 OpenAI 兼容托管 | Bedrock K3 | 中 | 需重写缓存逻辑为 `prompt_cache_breakpoint` 显式模式 |
| 自建推理 | Bedrock 托管 | 低（省事） | 换取托管可靠性，但受 AWS 区域/合规约束 |

**缓存接入的额外工作量**：显式缓存的本质是「告诉服务端哪里是可复用前缀」。你需要把稳定的 system prompt / 工具定义 / 仓库说明放在前缀，并在至少 1024 token 之后插入断点。这不是一次性的代码改动，而是**提示结构重构**——对于已经按隐式缓存设计的系统，这一步需要重新审视 prompt 组装顺序。

## 对你的意义

结合 Ken 的 AI 应用开发追踪，这次发布有几个值得记录的信号：

- **开源模型的竞争维度正在从「跑分」转向「托管体验」**：K3 的第一个 Bedrock 卖点不是 benchmark，而是 **explicit prompt caching**——一个纯工程/成本特性。这说明开源模型厂商开始把「生产可用性」当作差异化战场，而托管方（AWS）则把缓存、tool calling、structured output 做成**平台能力**（2026 年 Bedrock 新增），新模型一上线即可继承。这对 Ken 的 RAG / Agent 工具链选型有直接影响：底座能力的可迁移性变高了。
- **「显式缓存」值得加入你的工具箱清单**：Bedrock 对缓存命中的 token **不计入 input-tokens-per-minute 配额**——这不仅是省钱，更是吞吐/限流的解锁。任何长 system prompt 的 Agent（工具定义 + few-shot + 代码库摘要）都值得评估这一原语。
- **Agent 框架的模型适配继续加速**：OpenCode（原生 amazon-bedrock provider）、Hermes Agent 都在首发名单里。这与 MiMo 那类「模型联合框架首发」的模式一致——**框架侧的模型适配数量本身正在成为竞争指标**。
- **建议**：如果你有 AWS 环境，值得用一个真实的 Coding Agent 工作负载做一次 A/B——重点是量出**缓存命中率**和**每任务成本**，而不是只看模型智商。K3 的价值大概率就藏在那个命中率数字里（官方 Kimi API 号称 >90%，Bedrock 侧待你实测）。

## 关键代码/配置片段

以下片段**均来自源材料**（AWS Bedrock blog），非编造。

**1. 用 OpenAI SDK + Bearer Token 调用 Bedrock 上的 K3：**

```python
from aws_bedrock_token_generator import provide_token
from openai import OpenAI

region = "us-west-2"
oai_client = OpenAI(
    api_key=provide_token(region=region),
    base_url=f"https://bedrock-runtime.{region}.amazonaws.com/openai/v1",
)

resp = oai_client.responses.create(
    input="What is Byte-Pair Encoding, in AI?",
    model="global.moonshotai.kimi-k3",
)
print(resp.output_text)
```

**2. 开启显式 Prompt Caching，并在稳定前缀后打缓存断点：**

```python
resp = oai_client.responses.create(
    model="global.moonshotai.kimi-k3",
    # Enable explicit caching mode:
    extra_body={"prompt_cache_options": {"mode": "explicit"}},
    input=[
        {
            "type": "message",
            "role": "system",
            "content": [
                {
                    "type": "input_text",
                    "text": SYSTEM_PROMPT,
                    # A long, static system prompt is a great target for caching:
                    "prompt_cache_breakpoint": {"mode": "explicit"},
                },
            ],
        },
        {
            "type": "message",
            "role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": USER_INPUT,
                    # Multiple breakpoints can also be defined, for layered cache:
                    "prompt_cache_breakpoint": {"mode": "explicit"},
                },
            ],
        },
    ],
)
if resp.usage.input_tokens_details.cached_tokens:
    print("Hit cache!")
```

**3. 在 OpenCode 中把 Bedrock 上的 K3 设为默认模型（`~/.config/opencode.json`）：**

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "amazon-bedrock/global.moonshotai.kimi-k3",
  "provider": {
    "amazon-bedrock": {
      "options": {
        "region": "us-west-2",
        "profile": "PLACEHOLDER-YOUR-AWS-PROFILE-NAME"
      }
    }
  }
}
```

**缓存计费要点（Bedrock 文档）：**

- 可复用前缀至少 **1024 token**，用 `prompt_cache_breakpoint` 标记其精确结尾。
- 显式模式下，写入缓存的 token **按更高费率计费**，但缓存至少保留 **30 分钟**。
- 命中缓存的后续请求：input token 按**折扣价**计费，且**不计入 input-tokens-per-minute 配额**。

**待验证（TODO）**：

- Bedrock 上 K3 的**具体定价**与 token 费率（blog 仅指向 AWS pricing 页面，未给数字）。
- K3 在主流公开 benchmark（MMLU / GPQA / SWE-Bench 等）上的**具体分数**——官方称完整评测将随技术报告发布，但本次材料未含数值。
- K3 权重「by July 27, 2026 发布」的时间点在当前日期（2026-09-23）看来与语境存在出入，**待确认**。

---
[← Back to Deep Dives](./README.md)
