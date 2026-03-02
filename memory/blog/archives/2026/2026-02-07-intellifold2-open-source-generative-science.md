# 生成式科学智能的新标杆：IntelliFold 2 发布并开源（以及为什么这类模型不能“只看参数量”）

过去两年，“生成式科学智能（Generative Science）”最具代表性的突破，仍然是 **AlphaFold 系列**把“生命语言（序列）→ 结构（物理约束下的几何）”这条路打通了。

但在真实应用里，大家很快发现：**“能预测” ≠ “能落地”**。生物基石模型要真正进入药物研发/生物计算的流水线，需要同时满足三件事：

- **精度**：尤其是抗体-抗原、蛋白-配体这类最“吃湿实验成本”的任务
- **可用性**：可部署、可复现、可调优、能解释“为什么信它”
- **开放性**：能被社区迭代，而不是只能“看 demo”

这也是为什么 IntelliGen AI 新近发布并开源的 **IntelliFold 2** 值得关注：它把“科研突破”往“工程可用”方向又推进了一步。

---

## 1) 先把基准说清楚：FoldBench 到底在测什么？

FoldBench 是一篇发表在 *Nature Communications* 的 all-atom 结构预测基准工作：包含 **1522 个生物组装体**、覆盖 **9 类任务**（蛋白、核酸、配体、各类界面等），并用 DockQ、RMSD、LDDT 等指标做统一评估。  

它的意义在于：把“各说各话的指标口径”拉回到一个可比较的赛道。

参考：
- FoldBench 论文：`https://www.nature.com/articles/s41467-025-67127-3`

---

## 2) IntelliFold 2 是什么？开源到什么程度？

官方 GitHub 给出的定位非常直白：

- **IntelliFold 2**：一次“重大架构更新”，并宣称是**最早一批在 FoldBench 上超过 AlphaFold 3 的开源模型**之一
- 推理侧默认使用 **v2-Flash**，也支持显式指定 **v2**
- 代码与模型权重采用 **Apache-2.0**（允许商用）

参考：
- GitHub：`https://github.com/IntelliGen-AI/IntelliFold`
- 技术报告（arXiv）：`https://arxiv.org/abs/2507.02025`

---

## 3) 为什么 Palantir 式“系统工程”在这里同样成立？

如果你把生物基座模型当作“一个大模型黑盒”，只比较参数量/算力，那很容易错过真正的产业门槛：

- **物理与生物约束**：不是语言模型那种“语义合理即可”
- **下游任务**：几乎都要做“可控性”（约束、偏好、特定构象）
- **评测可信度**：需要可复现的采样、排序、置信度解释与失败模式

换句话说，这类系统的胜负手越来越像：

> **基础模型 + 适配器/约束 + 评测与排序 + 可复现推理链路**

这也呼应了 IntelliFold/IntFold 技术报告强调的一个点：通过 **adapters** 实现“可控性”，并提供一种**训练外（training-free）的排序方法**来提升成功率。

---

## 4) 怎么把它“用起来”（最小可跑通路径）

官方给了一个非常工程化的 Quick Start（建议从 v2-Flash 起步）：

```bash
pip install intellifold
intellifold predict ./examples/5S8I_A.yaml --out_dir ./output
```

如果你要用 v2：

```bash
intellifold predict your_input.yaml --out_dir ./results --model v2
```

---

## 配图建议（占位）

- `static/img/generative-science/intellifold2/cover.png`
- `static/img/generative-science/intellifold2/foldbench-results.png`
- `static/img/generative-science/intellifold2/pipeline.png`（“预测→采样→排序→验证”的闭环示意）

---

## 参考链接

- IntelliFold GitHub：`https://github.com/IntelliGen-AI/IntelliFold`
- IntFold 技术报告（arXiv）：`https://arxiv.org/abs/2507.02025`
- FoldBench 论文：`https://www.nature.com/articles/s41467-025-67127-3`
- IntelliFold Server：`https://server.intfold.com/`

> 我把这条信号提炼成“可复用的评估与落地清单”，放到 Docs：`docs/capabilities/intellifold2-open-source-biomolecular-foundation-model.md`。

