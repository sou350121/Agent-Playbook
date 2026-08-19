---
auto_generated: true
generated_at: "2026-08-19T06:47:44Z"
source_url: "https://simonwillison.net/2026/Aug/14/dont-classify-hallucinate/"
signal_type: "significant_update"
---
# 别分类，去幻觉 (Don't Classify. Hallucinate!)

> 🔍 本文由 Moltbot 自动生成 | 2026-08-19
>
> **项目/工具**: Hypothetical Classifications（幻觉分类法）
> **链接**: https://softwaredoug.com/blog/2026/08/10/hypothetical-classifications
> **核心定位**: 利用 LLM 的"幻觉"能力生成虚构分类标签，再通过向量嵌入映射到真实分类体系，绕过传统结构化输出的 Token 限制与成本瓶颈

## ⚡ 快速判断（30 秒读完这段就够了）

- **一句話定位**：让 LLM 自由"幻觉"出分类标签，然后用向量嵌入将幻觉标签映射到真实分类体系，替代传统的结构化输出约束
- **現在值得用嗎**：是 — 当你的分类体系超过几百个类别时，这个方案比结构化输出更便宜、更灵活
- **適合場景**：大规模分类体系（电商品类、内容标签、文档归档）、低成本批量分类、标签体系频繁变化的场景
- **不適合場景**：分类体系极小（<50 个类别）、需要精确逻辑规则判断的分类（如合规/法律分类）、实时性要求极高的场景
- **與傳統結構化輸出核心差異**：不向 LLM 发送完整词表（避免 Token 膨胀），而是让 LLM 自由生成后通过向量相似度"反向查找"真实标签

## 是什么 / 解决什么问题

在 AI 应用开发中，用 LLM 做分类已经是"无聊但有效"的标准操作。但当你面对一个拥有数百甚至上千个类别的分类体系时，传统方法会遇到两个硬约束：

1. **Token 预算爆炸**：结构化输出（如 OpenAI 的 `text_format` / Pydantic `Literal`）要求你把所有合法分类值塞进 prompt。Wayfair 的 WANDS 电商数据集有数百个品类层级，每个层级路径如 `Furniture / Living Room Furniture / Coffee Tables & End Tables / Coffee Tables`，完整词表可能长达数千 Token。
2. **API 上限限制**：OpenAI 等平台的结构化输出有明确的长度上限，超出后直接报错。

Doug Turnbull（搜索与向量检索领域的知名工程师）提出了一种反直觉的解决方案：**不约束 LLM 的输出，反而让它"幻觉"**。具体流程是——让 LLM 自由生成"看似合理但实际不存在"的分类标签，然后用向量嵌入（MiniLM）将这些幻觉标签与真实分类体系的预计算嵌入做余弦相似度匹配，找到最接近的真实标签。

这个方法的巧妙之处在于：**它把"LLM 会幻觉"这个通常被视为缺陷的特性，反转成了优势**。你不再需要把庞大的词表塞给 LLM，而是用轻量级嵌入模型做后处理映射。

## 技术架构拆解

### 核心设计决策

| 决策点 | 传统结构化输出 | 幻觉分类法 |
|--------|--------------|-----------|
| 词表传递 | 每次请求都发送完整分类列表 | 完全不发送词表 |
| LLM 角色 | 从合法集合中选择 | 自由生成"虚构"分类 |
| 映射机制 | LLM 内部约束（JSON Schema / Pydantic Literal） | 向量嵌入 + 余弦相似度 |
| 模型要求 | 需支持结构化输出（通常是大模型） | 任意小模型即可 |
| Token 成本 | 随分类数量线性增长 | 固定，与分类数量无关 |
| 可扩展性 | 受 API 上限限制 | 理论上无上限 |

### 工作流程

```
┌─────────────────────────────────────────────────────────────┐
│                    离线预处理（一次性）                       │
│                                                             │
│  真实分类体系 ──→ MiniLM Embedding ──→ 嵌入向量库（内存）     │
│  (如 500+ 品类路径)    (预计算)         (dot product ready)  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    在线推理（每次请求）                       │
│                                                             │
│  用户查询 ──→ LLM（幻觉 Prompt）──→ 虚构分类字符串           │
│  "wood coffee              (如 "Furniture /                 │
│   table"                    Living Room / Tables / Coffee") │
│                              │                              │
│                              ▼                              │
│                    MiniLM Embedding                         │
│                              │                              │
│                              ▼                              │
│              余弦相似度匹配 → 最接近的真实分类                │
│              "Furniture / Living Room Furniture /            │
│               Coffee Tables & End Tables / Coffee Tables"   │
└─────────────────────────────────────────────────────────────┘
```

### 关键代码解析

**Step 1: 幻觉 Prompt**

```python
hallucination_prompt = """
Your task is to create novel, never seen before, furniture, 
home goods, or hardware classification that best fit a search query.

Product classifications might look like:
Furniture / Living Room Furniture / Coffee Tables & End Tables / Coffee Tables
Décor & Pillows / Decorative Pillows & Blankets / Throw Pillows
...

Here's the query to generate classifications for:
brown coffee table
"""

response = client.responses.parse(
    model="gpt-5.4-mini",  # 小模型即可
    input=hallucination_prompt,
    text_format=list[str],  # 只需输出字符串列表，无需约束词表
)
# 输出示例: ["Furniture / Living Room / Tables / Coffee"]
```

**Step 2: 向量映射**

```python
# 预计算：真实分类体系的嵌入（离线一次性完成）
real_embeddings = {
    category: minilm_embed(category) 
    for category in real_taxonomy
}

# 在线：对幻觉输出做嵌入并查找最近邻
hallucinated = response.output_parsed.message  # ["Furniture / Living Room / Tables / Coffee"]
hallucinated_embed = minilm_embed(hallucinated[0])

# 余弦相似度匹配
best_match = max(
    real_embeddings.items(),
    key=lambda x: cosine_similarity(x[1], hallucinated_embed)
)
# 结果: ("Furniture / Living Room Furniture / Coffee Tables & End Tables / Coffee Tables", score)
```

### 与前版/竞品的关键差异

| 维度 | Pydantic Literal 约束 | 幻觉分类法 |
|------|----------------------|-----------|
| Prompt 长度 | O(分类数量) — 500 类 ≈ 数千 Token | O(1) — 固定 ~500 Token |
| 模型选择 | 需支持结构化输出的大模型 | 任意模型（含小模型/本地模型） |
| 每次请求成本 | 高（Token 随分类数增长） | 低（固定 Token + 轻量嵌入计算） |
| 分类体系变更 | 需更新 Prompt + 重新部署 | 只需重新计算嵌入向量 |
| 精度 | 高（硬约束，不会输出非法值） | 中高（依赖嵌入质量，可能映射偏差） |
| 适用规模 | <200 类别 | 数百至数千类别 |

## 实用评估

### 什么场景值得用

- **电商品类分类**：Wayfair 场景的直接应用。数百到数千个品类层级，查询模式多样，对分类精度要求"足够好"而非"绝对精确"
- **内容标签系统**：博客、新闻、文档的自动标签推荐。标签体系可能随时间演变，幻觉法允许灵活映射
- **大规模文档归档**：企业知识库的文档分类，类别数量庞大且可能新增
- **低成本批量处理**：当需要处理百万级文本分类时，每次请求节省的 Token 成本会累积成显著优势
- **标签体系频繁变更**：新增类别只需更新嵌入向量库，无需修改 Prompt 或重新部署

### 什么场景不值得用

- **小型分类体系（<50 类）**：Token 成本本身就不高，结构化输出更直接、精度更高
- **合规/法律/医疗分类**：这些场景需要确定性的逻辑规则，嵌入相似度的"模糊匹配"可能带来风险
- **需要多级细粒度区分**：当两个类别语义极其接近（如 "Accent Chairs" vs "Dining Chairs"），MiniLM 的嵌入分辨率可能不够
- **实时性极高的场景**：增加了嵌入计算和相似度搜索的额外延迟（虽然通常在毫秒级）

### 迁移成本

从传统结构化输出迁移到幻觉分类法：

| 步骤 | 工作量 | 说明 |
|------|--------|------|
| 预计算嵌入向量库 | 1-2 小时 | 对现有分类体系批量计算 MiniLM 嵌入，存入内存/Redis |
| 修改 Prompt | 30 分钟 | 将"从列表中选择"改为"自由生成分类" |
| 添加后处理逻辑 | 1-2 小时 | 实现嵌入计算 + 余弦相似度匹配 |
| 精度验证 | 2-4 小时 | 在测试集上对比两种方法的准确率，调整阈值 |
| **总计** | **约 1 个工作日** | 主要是嵌入库建设和精度验证 |

## 对你的意义

这个模式与 AI 应用开发中的 **RAG 后处理** 和 **Agent 输出规范化** 直接相关：

1. **RAG 分类/路由场景**：如果你的 Agent 需要根据用户查询路由到不同的知识域或工具集，当路由目标超过几十个时，幻觉分类法可以显著降低每次路由的 Token 成本
2. **标签/分类体系的"开放词汇"问题**：传统方法要求 LLM 从封闭词表中选择，但真实世界中用户查询的表达方式千变万化。幻觉法实际上是一种"开放词汇 → 封闭词表"的桥接方案
3. **与 Agent-Playbook 的关联**：这个模式可以抽象为一种通用的 **LLM 输出规范化模式**——不约束 LLM 的输出格式，而是让 LLM 自由表达后用确定性/半确定性方法后处理。这与 "Tool Calling + Parser" 模式有异曲同工之妙

**建议**：如果你的项目中存在"分类体系较大 + 成本敏感"的场景，值得试用这个模式。可以用 1-2 天做一个 POC，在现有测试集上验证精度损失是否在可接受范围内。

## 关键代码/配置片段

以下代码均来自 Doug Turnbull 的原文和配套 GitHub 仓库：

**幻觉 Prompt 模板**（原文引用）：

```python
hallucination_prompt = f"""
Your task is to create novel, never seen before, furniture, 
home goods, or hardware classification that best fit a search query.

Product classifications might look like:
Furniture / Living Room Furniture / Coffee Tables & End Tables / Coffee Tables
Décor & Pillows / Decorative Pillows & Blankets / Throw Pillows
Furniture / Bedroom Furniture / Dressers & Chests
Kitchen & Tabletop / Kitchen Organization / Food Storage & Canisters
School Furniture and Supplies / School Furniture / School Chairs & Seating / Stackable Chairs
Baby & Kids / Toddler & Kids Bedroom Furniture / Kids Beds

Here's the query to generate classifications for:
brown coffee table
"""
```

**传统结构化输出对比**（原文引用）：

```python
from typing import Literal
from pydantic import BaseModel, Field

FullyQualifiedClassifications = Literal[
    'Furniture / Bedroom Furniture / Beds & Headboards / Beds',
    'Furniture / Living Room Furniture / Chairs & Seating / Accent Chairs',
    'Rugs / Area Rugs',
    # ... 500+ 行
]

class QueryClassification(BaseModel):
    classifications: list[FullyQualifiedClassifications] = Field(
        description="A possible classification for the product."
    )
```

**配套工具**：
- Google Colab Notebook: https://colab.research.google.com/drive/1ljk72SBRuqWIijuEusCnDbhG1WAfZFcC
- GitHub 工具库: https://github.com/softwaredoug/cheat-at-search/blob/main/cheat_at_search/enrich/vocabulary.py

---

> TODO: 原文未提供具体的精度对比数据（幻觉分类法 vs 结构化输出的准确率差异）。待在实际数据集上验证。
> TODO: MiniLM 嵌入的分辨率极限未经验证——在语义极其接近的类别区分上表现如何？

---
[← Back to Deep Dives](./README.md)
