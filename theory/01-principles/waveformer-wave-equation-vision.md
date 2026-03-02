# WaveFormer：用欠阻尼波动方程做全局视觉建模（Frequency-Time 解耦）

论文：[`https://arxiv.org/abs/2601.08602`](https://arxiv.org/abs/2601.08602)  

---

## 1. 核心命题：把“特征传播”当作物理过程

WaveFormer 的视角是：

- feature map 是二维空间信号场
- 网络深度对应内部传播时间
- 语义在空间上的传播遵循欠阻尼波动方程（而非纯扩散）

这给视觉 backbone 引入了一种“物理可解释”的 inductive bias：  
**信息不是被相似度匹配出来的，而是被传播出来的。**

---

## 2. 为什么它可能比 heat-based 方法更保细节？

热方程（扩散）天然是低通：时间越长，高频越快衰减，易过平滑。

欠阻尼波动方程包含“衰减 + 振荡”：不同空间频率的成分可以保留相位与幅度的动态演化，更容易维持边缘纹理等高频信息。

论文摘要指出 wave propagation 与 heat-based 方法具有互补偏置：同时捕获全局一致性与高频细节。

---

## 3. 工程化落地：频域闭式解 → WPO（Wave Propagation Operator）

WaveFormer 通过在频域推导闭式解析解，实现：

- **频率–时间显式解耦**（frequency-time decoupled）
- 用 FFT 做空间域 ↔ 频域映射
- 全局交互的计算复杂度降低到 **O(N log N)**（相对注意力的 O(N²)）

因此 WPO 可以被视为一种“轻量全局交互模块”，作为 ViT/CNN 的 drop-in 结构替换。

---

## 4. 与注意力机制对照：两种全局建模协议

你可以用一句话对照：

- **Attention**：通过 QK 相似度决定“看谁”（content addressing）
- **Wave propagation**：通过传播动力学决定“怎么传”（physical propagation）

两者代表不同归纳偏置：  
attention 擅长内容寻址；wave 擅长传播与频率结构的显式建模。

---

## 5. 什么时候该关注这种路线？

当你的痛点是：

- 需要全局交互，但 **token 数太大**（注意力 N² 成本顶不住）
- 不想过度平滑，想要 **高频细节** 与 **全局一致性** 同时存在
- 想要更“可解释”的 backbone 演化机制（而不是纯相似度黑盒）

WaveFormer / WPO 这类“PDE inductive bias”路线值得优先阅读。

---

## 6. 关联阅读（本仓库）

- 1X World Model（视频生成式世界模型范式）：`cognition/frameworks/1x-world-model-paradigm.mdx`
- Emu3（统一 token prediction 的多模态主干）：`cognition/frameworks/emu3-next-token-multimodal-world-model-route.mdx`

