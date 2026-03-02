# 学习工具：用纯 NumPy 吃透 Ilya 推荐的 30 篇论文（从 forward 到 backward）

> **一句话**：如果你想从“会调包”升级到“会推导 + 会实现”，`pageman/sutskever-30-implementations` 是一条非常硬核、但回报极高的路径。

项目地址：[`https://github.com/pageman/sutskever-30-implementations`](https://github.com/pageman/sutskever-30-implementations)

---

## 为什么推荐它？

- **把抽象变成手感**：你会亲手写出 Q/K/V、mask、softmax 稳定性、以及每一步维度变化。
- **把“反向传播”从传说变成代码**：很多人卡在“知道链式法则，但写不出来”。这里用 NumPy 强迫你把梯度写出来，并用训练曲线验证“写对了”。
- **学习摩擦低**：大量章节用合成数据/自举数据，不需要大型数据集和 GPU。
- **适配面试**：面试问 Attention/LSTM，不再只是背公式，而是能讲“实现细节 + 为什么这么做”。

---

## 快速上手（最小可跑）

```bash
git clone https://github.com/pageman/sutskever-30-implementations
pip install numpy matplotlib scipy
jupyter notebook 02_char_rnn_karpathy.ipynb
```

建议你先做一个最小闭环：

1. 让 Notebook 能跑通
2. 读懂每个张量的 shape（用纸写出来）
3. 把一个关键函数抽出来重写一遍（尤其是 softmax / layernorm / attention）

---

## 推荐学习路径（从“能跑”到“吃透”）

### 第 1 步：先建立“时序反传”的直觉

- 从最基础的 RNN/char-rnn 开始
- 核心目标不是 SOTA，而是回答：**梯度怎么沿时间反传？为什么会爆/会消？**

### 第 2 步：把 LSTM 的门控梯度写到你脑子里

你需要能解释并实现：

- Forget Gate / Input Gate 的梯度如何影响长期记忆
- 为什么 LSTM 能缓解梯度消失（不是“因为大家都这么说”）

### 第 3 步：Attention（面试高频）

你至少要做到：

- 能写出 scaled dot-product attention 的计算步骤
- 能解释 mask 的实现（为什么用极大负数；以及它对 softmax 的影响）
- 能解释 softmax 数值稳定性（减 max）

### 第 4 步：高级章节当作“工程训练场”

一些章节会让你真正意识到：工程难点在 backward，而不是 forward。建议你把它当作“写对梯度”的训练场，而不是“看完就算”。

---

## 常见坑（建议提前规避）

- **shape 管理**：每一步都写清楚输入/输出 shape；不清楚就画图，不要赌运气。
- **数值稳定性**：softmax、log-sum-exp、mask 的实现细节是第一类 bug 来源。
- **梯度验证**：遇到难章节，优先做简单的有限差分（gradient check）来验证局部算子，而不是整网盲调。
- **不要追求一次性通关**：最有效的方法是“跑通一章 → 抽出一个算子复写 → 用曲线证明有效”，重复几轮。

---

## 搭配阅读（把学习变成可迁移能力）

- 如果你是为了面试：建议把你手写的 Attention / LSTM 梯度推导整理成自己的“口述稿”（能讲清楚比能写出来更稀缺）。
- 如果你是为了工程：建议把其中一个 notebook 改造成一个最小可复用的 `numpy_nn` 小库（算子 + forward/backward + 简单训练循环）。

