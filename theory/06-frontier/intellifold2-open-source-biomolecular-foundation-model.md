# IntelliFold 2：开源生物基石模型的“工程化落地”信号（FoldBench 语境）

> **定位**：这不是“论文复述”，而是一份给工程团队的 **评估与落地清单**：当你要把 biomolecular structure prediction 模型接进真实研发/计算流水线时，哪些点必须先讲清楚、先做对。

---

## 1) TL;DR（你应该记住的三句话）

- **不要只看参数量/宣传图**：这类模型的核心难点是“物理约束下的可控性 + 可复现的推理/采样/排序链路”。  
- **FoldBench 是关键参照系**：它提供跨任务、统一口径的 all-atom benchmark，让“可比较”成为可能。  
- **IntelliFold 2 的信号在于开源与可用**：官方声明它是最早一批在 FoldBench 上超过 AlphaFold 3 的开源模型之一，并提供 CLI/Server 形态降低试用门槛。

---

## 2) 一手来源（可引用）

- IntelliFold GitHub：`https://github.com/IntelliGen-AI/IntelliFold`  
  - README 明确提到 2026-02-07 发布 **IntelliFold 2**，默认使用 `v2-Flash`，可指定 `--model v2`，并宣称在 FoldBench 上超过 AlphaFold 3（细节在 release note/technical report）。
- 技术报告（arXiv）：`https://arxiv.org/abs/2507.02025`  
  - 摘要强调：高性能 attention kernel、可控性（adapters/约束）、亲和力估计、训练外排序方法。
- FoldBench 论文：`https://www.nature.com/articles/s41467-025-67127-3`  
  - 提供 1522 assemblies / 9 tasks 的 all-atom benchmark；并说明 DockQ 成功阈值（≥0.23）与部分基线结果口径。
- IntelliFold Server：`https://server.intfold.com/`

---

## 3) 评估 IntelliFold 2 时，最容易踩的 6 个坑

1. **把“能跑通 demo”当成“可用”**  
   - 你需要的是：固定输入 → 固定采样配置 → 可复现输出 → 可解释置信度/失败模式。

2. **忽略采样与排序（ranking）**  
   - 在复杂体系（抗体/配体/柔性界面）里，“采样空间”与“如何选 best pose”往往决定了实际成功率。

3. **只看总体分数，不看子任务**  
   - 真实落地里你关心的是：抗体-抗原、蛋白-配体、核酸相关任务是否达标，而不是平均值。

4. **基准与业务分布不一致**  
   - FoldBench 是统一口径，但你的 in-house 分布可能更难（新配体、别构位点、长尾修饰）。

5. **把模型当黑盒，没做“约束注入”接口**  
   - 结构预测在工业链路里常常需要：口袋/表位约束、构象偏好、已知片段固定等“可控输入”。

6. **忘了算“工程账”**  
   - 速度、显存、吞吐、失败重试成本、版本可回滚，往往比 1-2 个百分点更重要。

---

## 4) 最小可跑通（Quick Start）

官方 CLI（建议从默认 `v2-Flash` 开始）：

```bash
pip install intellifold
intellifold predict ./examples/5S8I_A.yaml --out_dir ./output
```

使用 v2：

```bash
intellifold predict your_input.yaml --out_dir ./results --model v2
```

---

## 5) 落地清单：把它接进“可审计的结构预测流水线”

把系统拆成 5 层（每层都可验证/可替换）：

1) **输入层**：序列/修饰/配体（CCD/SMILES）/链信息/约束  
2) **推理层**：模型版本、采样策略、随机种子、资源配额  
3) **排序层**：ranking 策略（模型自带/训练外相似性等）  
4) **验证层**：几何合理性检查、碰撞/能量、关键残基约束满足度  
5) **审计层**：记录输入、版本、采样配置、输出结构、置信度与失败原因（可回放）

配图建议（占位）：

- `static/img/generative-science/intellifold2/pipeline.png`

