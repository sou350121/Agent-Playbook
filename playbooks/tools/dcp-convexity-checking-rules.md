# DCP：凸性检测规则速查（CVX/CVXPY 的“为什么不让写？”）

> **目标**：把“数学上凸”翻译成“DCP 语法上可接受”。  
> 适用：CVX / CVXPY / Convex.jl / CVXR 一类 DCP 建模语言。

---

## 1. DCP 是什么？（一句话）

**DCP 是一套语法规则系统**：用带有已知曲率/单调性的原子函数（atoms）去拼表达式，保证你写出来的优化问题一定是凸的。

官方教程（含 analyzer）：

- `https://dcp.stanford.edu/home`

关键提醒：

- **DCP 是充分条件，不是必要条件**：数学上凸 ≠ DCP 能识别
- DCP 的目的不是“识别一切凸函数”，而是“确保不会把非凸问题当凸问题交给凸求解器”

---

## 2. CVX/CVXPY 怎么判凸？（机制）

它们不做 Hessian 符号计算，也不做数值验证。它们做的是规则推理：

### 2.1 原子函数（atoms）带属性

每个 atom 都预先标注：

- **curvature**：constant / affine / convex / concave
- **monotonicity**：对每个参数是 nondecreasing / nonincreasing / nonmonotonic

CVX Atom Library（遇错优先查）：

- `https://cvxr.com/cvx/doc/funcref.html`

### 2.2 复合规则（composition rules）

对表达式从内到外递归分析，典型规则是：

- 外层函数 convex 且 nondecreasing + 内层 convex → 结果 convex
- 外层函数 convex 且 nonincreasing + 内层 concave → 结果 convex
- 如果外层 nonmonotonic（例如 `square`），则内层通常必须 affine，否则拒绝

### 2.3 问题形式规则（objective/constraints）

- minimize：目标必须 convex
- maximize：目标必须 concave
- equality：两边必须 affine
- inequality：\(f(x) \le g(x)\) 要求左 convex、右 concave

---

## 3. 经典报错：`{positive constant} ./ {convex}`

很多人会写出类似：

- `rho / (1 + sum(x.^2))`

在 DCP 规则里，“常数除以凸表达式”通常**无法被判定为凸**（除非它能被重写为某个已知 atom 的组合）。所以建模器会直接拒绝。

这是最关键的误区之一：你以为系统在判断数学凸性；实际上它在判断 **表达式是否落在 DCP 允许的语法子集**。

---

## 4. 处理 DCP error 的三步法（工程落地）

### Step 1：先找等价 atom（最优先）

常见替换：

- 二次项：`sum_squares` / `quad_form` / `quad_over_lin` / `norm`
- softmax/稳定对数：`log_sum_exp`
- PSD 约束：`semidefinite` / `log_det` 等

目标：把“你自己写的数学表达式”改写成“库里认识的原子函数”。

### Step 2：用辅助变量拆结构（把证明翻译成语法）

当一个表达式整体不可识别时，把它拆成若干段：

- 引入 \(t\) 承接中间量
- 用 DCP 允许的约束链接 \(t\) 与原变量
- 把原来的目标/约束写成 \(t\) 的凸表达式

这本质上是：**把数学推导转换成 DCP 可检查的图结构**。

### Step 3：如果必须非凸，就别硬塞 DCP

如果结构本质非凸（或你不想做松弛/近似），就应该：

- 换非凸求解器（例如 Ipopt）
- 或做凸松弛 / 近似 / 分段线性化

---

## 5. 实战清单（你可以直接照着排查）

- [ ] 报错发生在哪个子表达式？（从内到外逐段注释/拆分）
- [ ] 这个子表达式能否用 atom 替换？（先查 atom library）
- [ ] 是否踩到“nonmonotonic 外层”规则？（例如 `square`）
- [ ] 是否存在“除以凸 / 乘以变量 / 变量相乘”等禁区？
- [ ] 是否可通过辅助变量 + 约束等价改写？

---

## 参考链接

- DCP 教程与 analyzer：`https://dcp.stanford.edu/home`
- CVX Atom Library：`https://cvxr.com/cvx/doc/funcref.html`
- CVXPY：`https://github.com/cvxpy/cvxpy`

