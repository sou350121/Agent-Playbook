# Emu3：Next-Token Prediction 统一多模态的“世界模型路线”

> 这篇不是新闻复述，而是把 Emu3 抽象成“可复用的路线图”：当你想做原生多模态助手、世界模型、VLA（vision-language-action），这条路径告诉你工程重心应该放在哪里。

论文：[`https://www.nature.com/articles/s41586-025-10041-x`](https://www.nature.com/articles/s41586-025-10041-x)  
代码：[`https://github.com/baaivision/Emu3`](https://github.com/baaivision/Emu3)

---

## 1. 核心命题

把多模态学习“还原”为一件事：

1) 把文本/图像/视频/动作都变成离散 token  
2) 用一个 decoder-only Transformer  
3) 只训练 next-token prediction（NTP）

这条命题的价值不在“又一个模型”，而在“统一范式”：它降低了架构复杂度，并最大化复用 LLM 基础设施。

---

## 2. 为什么这条路线对“世界模型”友好？

世界模型通常要求同时满足：

- **理解**（perception）
- **生成**（generation）
- **时间一致性**（video / future prediction）
- **行动建模**（VLA）

NTP 的统一序列建模天然提供了一条连续主干：  
文本 token → 视觉 token → 视频 token → 行动 token

在统一序列里，预测“下一个 token”就是预测“下一步世界状态/下一步动作”的最小形式。

---

## 3. 工程拆解：真正难的 4 个地方

### 3.1 统一 tokenizer（决定上限）

你可以把它理解为：给视觉/视频发明一种“语言”。它决定：

- 压缩率（token 成本）
- 重建质量（生成上限）
- 可学习性（训练稳定性）

### 3.2 数据组织（决定泛化）

统一多模态不仅是“把数据混起来”，而是：

- 统一格式（元信息、边界 token、交错顺序）
- 长视频的时序一致性
- 多任务分布的采样比例与课程策略

### 3.3 训练稳定性（决定能不能跑到收敛）

多模态联合训练比纯文本更敏感：loss weighting、dropout、packing、并行策略一旦不对，就会 collapse。

### 3.4 推理与对齐（决定产品化）

统一范式最大的优势之一是能继承 LLM 推理生态，但视觉/视频生成仍需要：

- CFG 等技巧（让自回归生成更可控）
- 任务格式对齐（post-training）
- 偏好对齐（例如 DPO）

---

## 4. 你可以如何使用这条路线（实践建议）

如果你做的是：

- **多模态助手**：优先验证“统一 tokenization + VLM understanding + interleaved generation”的闭环
- **世界模型/预测**：优先验证长视频 tokenization + next-token 续写的时序一致性
- **具身/机器人（VLA）**：优先验证 action tokenization + 交错序列训练 + 长时序 rollout

一句话：**别先卷结构，先把 tokenizer/数据/稳定训练/推理后端这四件事做成体系。**

---

## 5. 关联阅读

- 1X World Model（扩散式世界模型范式）：`cognition/frameworks/1x-world-model-paradigm.mdx`

