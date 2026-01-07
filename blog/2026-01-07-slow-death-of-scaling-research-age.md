# 告别 Scaling 暴力美学：算力不再是唯一答案，我们进入 Research Age

2020-2025 这段时间，AI 行业最强的“信仰”几乎只有一句话：**Scale it.**

但今天越来越清楚：Scaling 依然重要，但它不再是“唯一方向”。我们正在从 **Scaling Age** 过渡到 **Research Age** ——从堆料时代进入“更聪明地使用算力”的时代。

---

## 1) Ilya 的转向：从 Scaling Hypothesis 到 Research Age

Ilya Sutskever 在 2025 年末的一次公开访谈被广泛转述为一个信号：
- **继续无限堆算力/数据的边际收益在下降**
- 未来差距更取决于“研究洞察”而非“集群大小”

> 注：这里引用的是公开媒体对访谈的二手转述（非原始逐字稿）。

---

## 2) Sara Hooker 的论文：用数据讲清楚“Scaling 的慢性死亡”

Sara Hooker 在 SSRN 发布的文章《On the Slow Death of Scaling》提供了一个更系统的框架：
- 我们过去依赖“简单公式”：模型更大 + 数据更多 + 算力更猛
- 但训练 compute 与性能之间的关系 **并不稳定**，而且正在变化
- 只靠 scaling 会错过更关键的杠杆（算法、数据、推理侧系统能力）

论文信息：
- 标题：On the Slow Death of Scaling
- 作者：Sara Hooker
- SSRN：`https://ssrn.com/abstract=5877662`
- Posted: 12 Dec 2025；Last revised: 6 Jan 2026

---

## 3) “登月梯子”隐喻：为什么这条路越来越贵

我们为了学到长尾、低频、但高价值的知识，被迫训练越来越大的网络。
这像是：

> 为了登月而造了一把梯子。

成本上升带来的副作用不只是“贵”，而是：
- 研究权力向少数拥有大集群的机构集中
- 学术界与资源不足的团队更难参与核心进展

---

## 4) Research Age 的路线图：未来不止一种“正确的缩放”

在“后训练（post-training）时代”，更值得押注的是 **Scale the right thing**：

### 4.1 无梯度优化/推理时扩展（Inference-time Scaling）
- Best-of-N / rerank
- Tool use
- Multi-agent
- RAG（让模型“查资料”而非“死记硬背”）

### 4.2 可塑数据空间（从被动采集到主动合成）
- 合成数据（Synthetic Data）面向长尾场景
- 数据不再是“矿藏”，而是可设计的“燃料”

### 4.3 轻量级计算（榨干每一分算力）
- 数据质量 > 数量：去重、修剪、优先级
- 知识蒸馏：用强模型教小模型

---

## 5) 对 Agent 开发者的现实含义：系统层会成为性能放大器

当模型本身的边际收益下降，你的优势会来自：
- **路由层**：不同请求去不同模型（成本/安全/质量）
- **推理侧**：inference-time scaling + tool use
- **治理**：幂等安全墙，把高风险动作关进可审计脚本

如果你想把这篇动态提纯成“可执行工程清单”，请看：
- `docs/capabilities/post-scaling-research-age-playbook.mdx`（本仓库新增）

---

*本文首发于 [Agent 经验库](https://github.com/sou350121/agent-experience-library)*
