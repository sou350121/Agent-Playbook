---
auto_generated: true
generated_at: "2026-10-16T12:40:45Z"
source_url: "https://vercel.com/changelog/liquid-ais-d1-ultra-now-available-on-ai-gateway"
signal_type: "blog_post"
---
# Liquid AI d1-ultra 登陆 Vercel AI Gateway：输出校准概率的决策模型 (Liquid AI d1-ultra on Vercel AI Gateway: A Decision Model That Returns Calibrated Probabilities)

> 🔍 本文由 Moltbot 自动生成 | 2026-10-16
>
> **项目/工具**: Liquid AI d1-ultra
> **链接**: https://vercel.com/changelog/liquid-ais-d1-ultra-now-available-on-ai-gateway
> **核心定位**: 一个不生成文本、只输出结构化概率的多模态「决策模型」，把分类 / 路由 / 打分这类判定任务从「让 LLM 吐字符串再解析」变成「一次前向传播直接拿到校准概率」。

## ⚡ 快速判断（30 秒讀完這段就夠了）

- **一句話定位**：d1-ultra 是一个多模态决策模型，输入文本 / 图像 + 一组问题，输出 yes/no、选择题、量表三类结构化答案及其概率，**不生成任何 output token**。
- **現在值得用嗎**：看场景。如果你的管线里存在「LLM 输出自由文本 → 正则/JSON 解析 → 阈值判断」的环节，值得试；如果只是普通生成任务，没必要。
- **適合場景**：视觉质检（电路板缺陷）、保险理赔照片核验、内容分类、请求路由、rubric 打分、自动化验证。
- **不適合場景**：需要生成解释性文字、多轮对话、复杂推理链的任务——它根本不生成文本。
- **與前版 d1 核心差異**：d1-ultra 基于更大的 open-weight 模型 + Liquid 定制训练，主打**更可靠的校准概率**（官方称多数决策模型「过度自信」），并在 Artificial Analysis Decision Index 上领先其他决策模型至少 8 分。

## 是什么 / 解决什么问题

「decision model（决策模型）」这个品类解决的问题是：很多 AI 应用其实不需要「生成一段话」，而需要「给出一个判断 + 一个置信度」。

传统做法是让通用 LLM 输出文本（"Yes, this is a defect."），再用关键词匹配或 JSON schema 解析，最后靠人为设定的阈值决定是否自动化。这条链路有三层损耗：解析可能失败、置信度是模型幻觉出来的（并非真实概率）、多问题需要多次调用。

d1-ultra 把整件事收敛成一次前向传播：你传入一个 `state`（字符串 / 对象 / 数组，可以是结构化记录或消息历史）+ 一组 `questions`，模型直接返回每个问题的答案和概率。官方强调它「reads this input in one forward pass and returns the probabilities, without generating any tokens」——**没有输出 token，也没有解析层**。

值得注意的是，此次 Vercel AI Gateway 的接入并非 d1-ultra 首发。该模型首发于 Liquid AI 自己的 Console / API（官方 blog 标注 Oct 2026，定价 $0.042/百万 input token），Vercel 这次是把它带进统一的 Gateway 生态，并提供 AI SDK / OpenAI 兼容 / TypeSafe 兼容三条调用路径。

## 技术架构拆解

### 核心设计决策

- **概率直出，而非文本生成**：模型不产生自然语言，直接输出概率分布。这消除了「文本 → 结构化数据」的解析脆弱性。
- **单次前向传播多问题**：多个不同类型的问题（boolean / Choice / Score）可以共享同一个 `state`，在一次 round trip 内并行回答，而非串行多次调用。
- **输入计费、无输出费**：因为不生成 token，计费只按 input。图像与文本同价：官方给出 1.5 token / 32×32 像素 patch，即 1024×1024 图片 = 1,536 tokens。每个问题按各自 prompt 单独计费（含其文本与全部图像）。
- **主打校准（calibration）而非单纯 accuracy**：Liquid 官方明确指出「most decision models are overconfident」，d1-ultra 专门针对概率可靠性做了训练——这是它区别于「拿分类器刷准确率」的关键卖点。
- **三类问题原语**：
  - `noul`（boolean）：返回 0–1 的概率，需用 instructions 定义 true/false 的含义。
  - `Choice`：从命名集合中选一个，返回选项 + 每个选项的概率。
  - `Score`：在有序量表上打分，返回插值分数 + 各档位概率。

### 与前版 d1 / 竞品的关键差异

| 维度 | d1 | d1-ultra |
|------|----|----------|
| 底层模型 | 基础 open-weight | 更大的 open-weight + Liquid 重度定制 |
| 概率校准 | 一般 | 专门训练以产出更可靠概率（官方称改善过度自信） |
| 知识类任务 | 基线 | 「significant gains ... especially on knowledge-related tasks」 |
| 基准表现 | — | 在 112 项评测中优于 Jev 1.14；Artificial Analysis Decision Index 领先其他决策模型 ≥ 8 分 |
| 问题类型 | noul / Choice / Score | 相同三类（沿用） |

> 注：以上对比来自 Liquid AI 官方 blog，属厂商自述数据，**未经第三方独立复现**，引用时请注明来源。

### 架构/信息流图

```
         ┌─────────────────────────────────────────┐
         │  state (string | object | array)         │
         │  例：文本记录 / 消息历史 / 图像+文本      │
         └───────────────────┬─────────────────────┘
                             │
         ┌───────────────────▼─────────────────────┐
         │  questions（可多个，不同类型混合）        │
         │   ├─ boolean: "是否有缺陷?"               │
         │   ├─ Choice : 类别集合                    │
         │   └─ Score  : 有序量表                    │
         └───────────────────┬─────────────────────┘
                             │  一次前向传播（无 output token）
         ┌───────────────────▼─────────────────────┐
         │  answers                                 │
         │   ├─ boolean → probability 0..1          │
         │   ├─ Choice  → 选中项 + 各选项概率        │
         │   └─ Score   → 插值分 + 各档位概率        │
         └───────────────────┬─────────────────────┘
                             │
              ┌──────────────▼───────────────┐
              │  Decision Fallback（可选）    │
              │  低置信度 → 换模型重跑一次     │
              └──────────────────────────────┘
```

Vercel 侧的一个工程亮点是 **Decision Fallbacks**：当 Choice / Score 置信度低、或 boolean 概率落入「不确定带」、或复合条件命中时，可以自动用另一个模型重跑一次成功的决策。该机制 opt-in，支持单级 fallback，两阶段分别计费、延迟叠加。

## 实用评估

### 什么场景值得用

- **视觉质检**：官方给出的典型例子——对照 spec 检测电路板缺陷。图像与文本同价输入，且不需要模型生成解释，直接用概率驱动「自动放行 / 转人工」。
- **保险理赔核验**：把「理赔主张 vs 客户照片」作为 state，用 boolean 问「照片是否支持该主张」。
- **请求路由 / 内容分类**：用 Choice 类型做多分类，概率天然可用于灰区路由。
- **rubric 打分 / 自动化验证**：Score 类型把人工评分标准显式化（criteria 为有序标签数组）。
- **多问题单次调用**：同一张图 / 同一段记录上问多个判定问题，省掉多次调用与解析。

### 什么场景不值得用

- **需要生成解释文字**：它不生成 output token，任何「让模型说明理由」的需求都不适用。
- **多轮对话 / 复杂推理链**：它是单次判定型模型，不做 agentic 推理。
- **对校准未验证就上生产**：厂商自述「更好的校准」需在自己的数据分布上验证——决策模型的校准高度依赖领域分布，**待确认**。
- **非主流 endpoint 用户**：Vercel 文档明确指出，决策调用**不支持** Chat Completions、Responses，以及 Anthropic-compatible / Cohere-compatible 端点。若你的管线绑定这些接口，迁移成本会很高。

### 迁移成本

- 若已在用 OpenAI 的 Decisions API：只需把 SDK base 指向 `https://ai-gateway.vercel.sh/v1`，继续调 `decisions.create` 即可，Vercel 会兼容返回 OpenAI 的响应形状。
- 若在用 TypeSafe SDK：指向 `https://ai-gateway.vercel.sh/typesafe`，请求 / 响应形状保持 TypeSafe 自己的格式（含 boolean 问题的 `noul`）。
- 若用 AI SDK：决策功能要求 **ai 7.0.128 或更高**，更早的 AI SDK 7 版本需用 `experimental_evaluate`。
- 术语变更注意：决策模型此前叫 **evaluation models**，`experimental_evaluate` 与 `gateway.evaluationModel()` 作为**弃用别名**仍可用，形状不变。

## 对你的意义

对 Ken 的 Agent + UI / RAG 工具链方向，d1-ultra 的意义在于**给「判定类环节」提供了一条更干净的抽象**：

1. **替代脆弱的 verdict 解析**。如果现有 pipeline 里存在「让 LLM 输出 JSON verdict → 解析 → 阈值」的步骤，决策模型是更合适的原语——没有解析层，概率可直接喂给路由逻辑（「概率 > 0.9 自动放行，0.6–0.9 转人工」）。
2. **校准概率 = 可运营的置信门控**。Decision Fallbacks 把「低置信度自动升级到更强模型」变成了框架级能力，这正好呼应 Ken 关注的评估与安全方向——不确定性可以被显式处理，而不是藏在 prompt 里。
3. **多模态同价是个实用细节**。图像按 1.5 token/32×32 patch 计费、每个问题独立计费——做视觉质检类 demo 时，成本模型比「生成式 + 解析」更可预测。

**建议**：观望偏试用。如果你手上正好有一个分类 / 路由 / 质检的环节，值得拿 d1-ultra 与现有「LLM 生成 + 解析」方案做一次 A/B，重点对比**校准质量**而非单纯准确率。纯生成任务无需迁移。

## 关键代码/配置片段

Liquid API 侧（多模态，电路板缺陷检测，来自 Liquid AI 官方 blog）：

```python
import base64, os, requests

image = base64.b64encode(open("board.jpg", "rb").read()).decode()
response = requests.post(
    "https://api.liquid.ai/decisions/v1/systemone",
    headers={"Authorization": f"Bearer {os.environ['LIQUID_API_KEY']}"},
    json={
        "model": "d1-ultra",
        "images": [f"data:image/jpeg;base64,{image}"],
        "state": "Camera image of a circuit board on the production line.",
        "questions":
            {"defect": {
                "type": "noul",
                "instructions": "Does this circuit board have a defect?"
             }
         },
    },
)
print(response.json()["answers"]["defect"]["noul"])
```

Vercel AI Gateway 侧（AI SDK，来自 Vercel 模型页）：

```javascript
import { experimental_decide as decide } from 'ai';

const result = await decide({
  model: 'liquid/d1-ultra',
  state: 'The support agent issued a full refund to the customer.',
  questions: {
    refunded: {
      type: 'boolean',
      instructions: 'Was a refund issued?',
    },
  },
});
```

模型名统一使用 `liquid/d1-ultra`。三个问题原语的 `criteria` 约定：

```text
boolean : 提供 criteria 定义 true / false 各代表什么
Choice  : criteria 是「选项名 → 描述」的映射，返回选中项 + 各选项概率
Score   : criteria 是至少两个有序标签（从低到高），返回插值分数 + 各档位概率
```

---
[← Back to Deep Dives](./README.md)
