# 拒绝调包：纯 NumPy 手搓 Ilya 推荐的 30 篇论文复现，连反向传播都是手写的

面试官让你手写 Attention？别只会背公式。看看这个 **纯 NumPy** 项目：从底层彻底告别“调包侠”。

（图片：项目总览/Notebook 列表截图，建议放 `static/img/sutskever-30-implementations/cover.jpg`）

Ilya Sutskever 曾给 John Carmack 开出一份 30 篇论文的书单：如果你能真正吃透这些，你就掌握了当今 AI 领域很大一部分精髓。

但这份清单跨度太广：从早期的复杂性理论、热力学与元胞自动机，一路延伸到 RNN/LSTM，再到奠定 Transformer 基石的 Seq2Seq 和 Attention。对于多数人来说，数学公式枯燥、代码实现缺位——最后往往躺在收藏夹里吃灰。

更尴尬的是：你可能用 PyTorch 写了很多年模型，`nn.LSTM`、`nn.MultiheadAttention` 调得飞起，但只要追问一句——“loss 到底怎么传回去的？”脑子里还是一团浆糊。

---

## 项目：sutskever-30-implementations

最近 GitHub 上出现了一个项目：`pageman/sutskever-30-implementations`。它不使用任何深度学习框架，仅用 NumPy，从零复现书单中的 30 个主题（以 Notebook 形式组织）。

- 项目地址：[`https://github.com/pageman/sutskever-30-implementations`](https://github.com/pageman/sutskever-30-implementations)

（图片：GitHub 首页截图，建议放 `static/img/sutskever-30-implementations/repo.jpg`）

---

## 为什么它很硬核？四条铁律

这个项目最“硬”的不是选题，而是自我约束：

- **纯粹性（Pure NumPy）**：拒绝 PyTorch / TensorFlow / JAX。没有 autograd 黑魔法。前向是矩阵乘法，反向是手推链式法则。
- **零依赖数据（Synthetic Data）**：大量使用合成数据/自举数据，不需要下载巨型数据集；你专注的是模型逻辑，而不是数据管线。
- **可视化（Visualizations）**：Notebook 里配了大量图表，把公式变成你能“看到”的 loss 曲线、attention map、梯度流动。
- **交互式（Interactive）**：全仓库以 Jupyter Notebook 组织，适合逐行调试和观察中间变量。

---

## 30 篇论文的复现路径（四阶段）

项目把 30 个主题按学习曲线拆成四个阶段（并做了面向 LLM 时代的微调补全）：

### 第一阶段：基础概念

聚焦物理与数学基础，覆盖复杂性理论、RNN 字符生成、LSTM 等。

看点：你会被迫直面 LSTM 的门控梯度——Forget Gate / Input Gate 的梯度更新到底怎么写出来的？梯度消失/爆炸在代码里长什么样？

### 第二阶段：架构演进

从 CNN 到 Transformer 的跃迁：ResNet、Pointer Networks、GNN、Attention Is All You Need。

看点：纯 NumPy 实现 Multi-head Self-Attention：你必须手动处理 Q/K/V 投影、mask、softmax 数值稳定性，以及每一步的维度变化。

### 第三阶段：高阶推理

涉及长期记忆与推理：NTM、关系推理、CTC Loss 等。

看点：工程难点通常在“时序反向传播”——你会意识到：真正难的不是写 forward，而是写对 backward。

### 第四阶段：理论与现代架构

补齐更贴近现代大模型的拼图：多 token 预测、RAG、长上下文“Lost in the Middle”等。

---

## 工程与面试价值：你会从“背答案”变成“会推导”

### 案例 1：手写 Self-Attention（维度与 mask）

面试常见题是写公式/解释 mask。但很多人卡在“维度变化”和“数值稳定性”。

当你亲手写过这种代码，你会真正理解 softmax 为什么要减 max、mask 为什么要加上一个极大负数、以及注意力复杂度从哪来：

```python
def scaled_dot_product_attention(Q, K, V, mask=None):
    d_k = Q.shape[-1]
    scores = np.dot(Q, K.T) / np.sqrt(d_k)
    if mask is not None:
        scores = scores + (mask * -1e9)
    attention_weights = softmax(scores, axis=-1)
    output = np.dot(attention_weights, V)
    return output, attention_weights
```

### 案例 2：手动反向传播（把链式法则写进代码）

真正拉开差距的，是“你能不能把梯度写对”。有些章节会定义 `Tensor` 类追踪梯度，并为运算实现 `backward`，用手写的梯度把模型跑起来。

当你看到 loss 稳步下降，你会第一次对“反向传播不是玄学”产生体感。

### 案例 3：多 Token 预测（样本效率的直觉）

多 token 预测（multi-token prediction）是理解“样本效率/训练效率”的好入口。相比 next token prediction，它能提供更丰富的梯度信号，让你对“为什么一些训练范式收敛更快”有更具体的把握。

---

## 快速上手（最低门槛）

```bash
git clone https://github.com/pageman/sutskever-30-implementations
pip install numpy matplotlib scipy
jupyter notebook 02_char_rnn_karpathy.ipynb
```

别光收藏不练。哪怕只跑通最简单的 char-rnn，你对 AI 底层原理的理解都会上一个台阶。

---

## 进一步沉淀（对应 Docs）

我把“怎么用它学到东西、怎么避免走偏、怎么为面试做一条训练路径”整理到 Docs：

- `docs/tools/sutskever-30-implementations-numpy.md`

