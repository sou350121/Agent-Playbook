---
auto_generated: true
generated_at: "2026-07-16T09:08:34Z"
source_url: "https://usefeyn.com/blog/pulpie-pareto-optimal-models-for-cleaning-the-web/"
signal_type: "significant_update"
---
# Pulpie：Pareto 最优网页清洗模型，质量逼近 SOTA 但成本仅 1/20

> 🔍 本文由 Moltbot 自动生成 | 2026-07-16
>
> **项目/工具**: Pulpie (by Feyn)
> **链接**: https://usefeyn.com/blog/pulpie-pareto-optimal-models-for-cleaning-the-web/
> **核心定位**: 一个基于 Encoder 架构的 HTML 内容提取模型家族，用 210M 参数匹配 600M Dripper 的质量，同时将十亿页清洗成本从 $159K 降至 $7.9K

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：Pulpie 是一族 Pareto 最优的 HTML 网页内容提取模型——从充满导航、广告、侧栏的原始 HTML 中精准剥离正文，供 LLM 预训练和 RAG 检索使用。
- **現在值得用嗎**：是——如果你在做大规模网页数据清洗（预训练语料构建、RAG 文档解析），Pulpie Orange Small 是目前性价比最高的开源选择。小规模场景 Trafilatura 仍够用。
- **適合場景**：Common Crawl 级预训练语料清洗；RAG 系统的网页文档解析；需要批量处理百万/十亿级页面的数据工程团队。
- **不適合場景**：单页面或少量页面的手动提取（Trafilatura/readability 更简单）；需要提取结构化数据（表格、JSON-LD）而非正文内容的场景。
- **與 Dripper 核心差異**：Encoder 单次前向标注 vs Decoder 逐 token 生成——质量持平（0.862 vs 0.864 ROUGE-5），速度快 20 倍，成本低 20 倍。

## 是什么 / 解决什么问题

语言模型以两种方式消费互联网：预训练时学习世界知识，推理时拉取相关上下文。但两次输入的输入中，约 70% 的 HTML 块是导航、广告、侧栏、页脚等噪声——正文只占页面一小部分。而这"一小部分"直接决定了模型质量的两端。

AICC（Ma et al., 2025）的实验量化了这一点：从同一份 Common Crawl 快照构建两个语料，一个用启发式规则提取，一个用模型提取，其余管道完全相同。结果模型在 13 个 benchmark 上的平均准确率相差 **1.08 个百分点**。更惊人的是，这个模型还击败了用 FineWeb 和 RefinedWeb（两个最严格过滤的预训练语料）训练的模型。

另一方面，启发式提取器会破坏结构化内容。Trafilatura 对代码块的保真度仅 0.13（相似度），公式仅 0.61；而模型提取器分别达到 0.91 和 0.94。这意味着用启发式提取器清洗的语料训练出的模型，天生就会"继承"这些损坏。

问题在于：好的提取器太贵。Dripper（当前领先的提取器）在 L4 GPU 上仅 0.68 页/秒，清洗十亿页成本约 $159K。这阻止了大多数团队用模型级提取器做大规模数据清洗。

Pulpie 的突破在于：**用 Encoder 架构替代 Decoder 生成架构**，在质量几乎不降的前提下（0.862 vs 0.864 ROUGE-5 F1），将速度提升 20 倍、成本降低 20 倍。

## 技术架构拆解

### 核心设计决策

**1. Encoder vs Decoder：把瓶颈从内存带宽转移到计算**

这是 Pulpie 最核心的架构选择。现有提取器分两类：

| 类别 | 代表 | 原理 | 瓶颈 |
|------|------|------|------|
| 结构型 | Trafilatura, Readability, magic-html | 基于 HTML 标签、DOM 结构、文本密度的规则 | 无法理解语义，混淆导航表和数据表 |
| 阅读型（Decoder） | Dripper | Transformer 逐 token 生成标签 | 内存带宽受限——每步读完整模型 |
| 阅读型（Encoder） | Pulpie | 单次前向标注每个 HTML 块 | 计算受限——密集矩阵乘法 |

Decoder 的速度瓶颈在于：每生成一个标签 token，都要把完整模型从 GPU 内存读入。Dripper 600M 参数，每一步都要加载。而 Encoder 一次前向通过程标注所有块——瓶颈变成 Tensor Core 的计算能力，而非内存带宽。

这个差异在带宽/计算比不同的 GPU 上被放大：

| 维度 | NVIDIA A100 | NVIDIA L4 | 比值 |
|------|-------------|-----------|------|
| 内存带宽 | 2,039 GB/s | 300 GB/s | ~6.8x |
| Tensor Core TFLOPS | 312 | 120 | ~2.6x |

从 A100 降到 L4，带宽饥饿对 Decoder 的影响远大于 Encoder。这就是为什么 Dripper 在 L4 上仅 0.68 页/秒（带宽严重不足），而 Pulpie Small 仍有 13.7 页/秒。

**2. 块级标注 + 8K token 分块**

Pulpie 不逐页处理，而是将页面拆分为 HTML 块，用 `<|sep|>` 标记分隔，打包进最多 8,192 token 的 chunk。约 80% 的页面只需一个 chunk。这解决了 Dripper 的 32K token 上下文窗口溢出问题——Dripper 在 WebMainBench 上有 135 页返回空结果（全部因溢出），Pulpie 仅 45 页。

**3. 蒸馏策略：2.1B 教师 → 610M/210M 学生**

Pulpie 的训练采用经典的知识蒸馏（Hinton et al., 2015）：

- 教师：EuroBERT-2.1B 微调，ROUGE-5 F1 = 0.873
- 学生 Base：610M，蒸馏后 0.863（仅降 1.0 点）
- 学生 Small：210M，蒸馏后 0.862（仅降 1.1 点）

蒸馏损失 = 0.7 × KL 散度（教师软化输出）+ 0.3 × 硬标签交叉熵，温度 2.0。210M 模型仅损失 1.1 个 F1 点，性价比最优。

**4. 训练数据构建**

没有现成的块级标注数据集，Feyn 团队自建了：
- 从 Common Crawl 采样 16,670 英文页面（每域名限 1 页）
- 用 MinerU-HTML 分块，DeepSeek V3.2 标注
- 用 Dripper 0.6B 交叉验证，双方一致率 93.3%
- 保留双方 ≥70% 一致的 14,959 页作为训练集
- 类别权重设为内容率 28.6% 的倒数，对抗类别不平衡

### 与前版/竞品的关键差异

| 维度 | Trafilatura (启发式) | Dripper 0.6B (Decoder) | Pulpie Small 210M (Encoder) |
|------|---------------------|------------------------|---------------------------|
| ROUGE-5 F1 | 0.619 | 0.864 | 0.862 |
| 参数量 | 0（规则） | 600M | 210M |
| L4 吞吐量 | N/A（CPU） | 0.68 页/秒 | **13.7 页/秒** |
| 1B 页成本 (L4) | 低（但质量差） | ~$159K | **~$7,900** |
| 1B 页成本 (A100) | 低（但质量差） | ~$210K | **~$29,000** |
| 上下文溢出 | 无限制 | 135 页失败 | 45 页失败 |
| 代码块保真度 | 0.13 | TODO | 0.91（模型级提取器共性） |
| 许可证 | BSD | 开源 | 开源 |

### 架构/信息流图

```
┌─────────────────────────────────────────────────────────────┐
│                    Pulpie Pipeline                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Raw HTML]                                                 │
│      │                                                      │
│      ▼                                                      │
│  ┌───────────┐   Simplify: 移除 script/style/噪声           │
│  │  Simplify  │   给每个块打唯一 ID                          │
│  └─────┬─────┘                                              │
│      │                                                      │
│      ▼                                                      │
│  ┌───────────┐   拆分块 → Tokenize → 打包 ≤ 8192 tokens     │
│  │  Chunking  │   (~80% 页面单 chunk 搞定)                    │
│  └─────┬─────┘                                              │
│      │                                                      │
│      ▼                                                      │
│  ┌───────────────────┐                                      │
│  │   EuroBERT Encoder │   单次前向 → 每个块标注              │
│  │  (210M/610M/2.1B) │   content vs boilerplate             │
│  └─────┬─────────────┘                                      │
│      │                                                      │
│      ▼                                                      │
│  ┌───────────┐   输出保留的块 → HTML 或 Markdown             │
│  │  Return   │                                              │
│  └───────────┘                                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 训练流程

```
              ┌──────────────────────────────┐
              │   16,670 pages (Common Crawl) │
              │   每域名限 1 页               │
              └──────────────┬───────────────┘
                             │
              ┌──────────────▼───────────────┐
              │  MinerU-HTML 分块             │
              │  DeepSeek V3.2 标注           │
              └──────────────┬───────────────┘
                             │
              ┌──────────────▼───────────────┐
              │  Dripper 0.6B 交叉验证        │
              │  一致率 93.3%                 │
              │  保留 ≥70% 一致的 14,959 页    │
              └──────────────┬───────────────┘
                             │
            ┌────────────────▼────────────────┐
            │   Teacher: EuroBERT-2.1B         │
            │   LR=2e-5, Batch=8               │
            │   Class-weighted CE              │
            │   4x A100                        │
            │   ROUGE-5 F1 = 0.873             │
            └────────────────┬─────────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     ┌────────▼────────┐          ┌────────▼────────┐
     │  Base 610M      │          │  Small 210M     │
     │  KL(0.7)+CE(0.3)│          │  KL(0.7)+CE(0.3)│
     │  T=2.0          │          │  T=2.0          │
     │  F1=0.863       │          │  F1=0.862       │
     └─────────────────┘          └─────────────────┘
```

## 实用评估

### 什么场景值得用

- **大规模预训练语料清洗**：这是 Pulpie 的核心战场。如果你从 Common Crawl 或类似来源构建训练语料，Pulpie Small 在 L4 上清洗十亿页仅需 $7,900——比 Dripper 便宜 20 倍，质量几乎持平。AICC 论文已证明，仅改进提取器就能带来 1.08 个百分点的 benchmark 提升。
- **RAG 系统的网页文档解析**：Shi et al. (ICML 2023) 证明单个不相关段落就足以误导模型回答。Pulpie 能从网页中干净地提取正文，减少 RAG 检索中的噪声干扰。
- **低成本 GPU 环境**：如果你只有 L4 或类似带宽受限的 GPU，Pulpie 的 Encoder 架构优势更加明显（20x 差距 vs A100 上的 7.1x）。
- **需要处理超长页面**：Dripper 的 32K token 窗口会在 135/6,647 页上溢出失败，Pulpie 的 8K chunk 打包策略仅 45 页失败。

### 什么场景不值得用

- **小规模提取（<10K 页）**：Trafilatura 或 Readability 更简单，无需 GPU。Pulpie 的优势在规模上体现。
- **结构化数据提取**：Pulpie 提取的是"正文 vs 噪声"的二分类——它不解析表格结构、不提取 JSON-LD、不识别产品属性。这些需要专门的提取器。
- **多语言场景（非欧洲语言）**：Pulpie 基于 EuroBERT，训练数据仅英文页面。多语言支持待验证。
- **对许可证敏感的企业**：TODO: 博客未明确说明 Pulpie 的开源许可证类型，需确认。

### 迁移成本

从 Trafilatura/Dripper 迁移到 Pulpie：

```bash
pip install pulpie
```

```python
from pulpie import Extractor

extractor = Extractor()  # 默认 Pulpie Orange Small
result = extractor.extract(html)
print(result.markdown)           # 干净 Markdown
print(result.n_main, result.n_other)  # 保留 vs 丢弃的块数
```

**批量处理**：

```python
from pulpie import Pipeline, PageInput

pipeline = Pipeline(model="small")
results = pipeline.extract_batch(
    [PageInput(html=h, page_id=i) for i, h in enumerate(pages)]
)
```

迁移工作量估算：
- 从 Trafilatura 迁移：API 类似，替换 `extract()` 调用即可，约 1-2 小时
- 从 Dripper 迁移：需切换依赖和 API，约 2-4 小时
- 从自定义启发式规则迁移：需重写提取逻辑，约 1-2 天
- 硬件要求：需 GPU（L4/A100 均可），CPU 推理速度未公布

## 对你的意义

Pulpie 对 AI 应用开发有直接意义：

1. **RAG 数据质量**：如果你的 Agent 系统从网页抓取文档做 RAG，Pulpie 可以显著提升检索上下文的质量。噪声减少 = 回答更准确。
2. **数据工程成本**：如果你团队在构建自定义预训练语料，Pulpie 把模型级提取的成本从"只有大厂负担得起"降到"中等团队也能做"。$7,900/十亿页 vs $159K/十亿页，这个差距足以让很多项目重新考虑数据策略。
3. **架构启示**：Encoder vs Decoder 的选择是一个经典的"正确工具做正确事"案例——当任务可以并行化标注（每个 HTML 块独立）时，Encoder 比 Decoder 高效得多。这个思路可以迁移到其他数据清洗/标注任务。

**建议**：如果你在做 RAG 或数据工程，立即试用 Pulpie Orange Small。pip install 一行命令就能跑，验证成本极低。

## 关键代码/配置片段

**基础提取（来自官方博客）**：

```python
from pulpie import Extractor

extractor = Extractor()  # defaults to Pulpie Orange Small
result = extractor.extract(html)

print(result.markdown)  # clean markdown
print(result.n_main, result.n_other)  # blocks kept vs dropped
```

**选择更大模型（追求质量）**：

```python
extractor = Extractor(model="large")  # "small" (default), "base", or "large"
```

**批量处理管道**：

```python
from pulpie import Pipeline, PageInput

pipeline = Pipeline(model="small")
results = pipeline.extract_batch(
    [PageInput(html=h, page_id=i) for i, h in enumerate(pages)]
)
```

**模型家族对比**：

| 模型 | Hugging Face | 参数 | ROUGE-5 F1 | 备注 |
|------|-------------|------|------------|------|
| Orange Small | feyninc/pulpie-orange-small-v1 | 210M | 0.862 | **推荐** |
| Orange Base | feyninc/pulpie-orange-base-v1 | 610M | 0.863 | 从 Large 蒸馏 |
| Orange Large | feyninc/pulpie-orange-large-v1 | 2.1B | 0.873 | 教师模型 |

---
[← Back to Deep Dives](./README.md)
