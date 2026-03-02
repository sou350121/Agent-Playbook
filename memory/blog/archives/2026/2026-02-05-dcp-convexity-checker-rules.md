# DCP：凸性检测规则（为什么数学上凸，CVX/CVXPY 还是会报错？）

很多工程问题，我们都希望尽可能改写成 **凸优化**，原因很简单：

> **凸优化的任意局部最优解都是全局最优解。**

但现实里最常见的坑是：你已经在纸面上证明了“这个目标/约束是凸的”，结果一写进 CVX / CVXPY，直接报：

> Disciplined convex programming error

这不是你证明错了，而是你踩到了一个关键事实：

> **DCP 是充分条件，不是必要条件。**  
> 它保证“你写得出来的表达式一定是凸的”，但不会识别“所有凸函数”。

---

## 1) DCP 到底是什么？

DCP（Disciplined Convex Programming，规范凸规划）是一套“凸性语法规则”：

- 你只能使用库里已标注曲率/单调性的 **原子函数（atoms）**
- 你只能用被允许的组合规则（非负加权和、仿射变换、复合规则、透视函数等）去拼表达式
- 系统用**规则推理**判断 convex/concave/affine
- 如果不满足规则：**直接拒绝建模**（即使数学上它确实是凸的）

官方 DCP 教程与 analyzer：

- `https://dcp.stanford.edu/home`

---

## 2) CVX / CVXPY 是怎么“检测凸性”的？

核心点：**它们不做 Hessian 符号计算，也不做数值检验**。它们做的是：

1. 每个 atom 都有预定义的属性：
   - **curvature**：constant / affine / convex / concave
   - **monotonicity**：对每个参数是 nondecreasing / nonincreasing / nonmonotonic
2. 对复合表达式从内到外递归分析（composition rule）
3. 对目标与约束再套“问题形式”的规则：
   - minimize：目标必须 convex
   - maximize：目标必须 concave
   - equality：两边必须 affine
   - inequality：\(f(x) \le g(x)\) 要求左 convex、右 concave

CVX 的 atom 文档（遇到报错先查这里）：

- `https://cvxr.com/cvx/doc/funcref.html`

---

## 3) 一个经典坑：你证明凸，但 DCP 不承认

你给的例子非常典型：

\[
\min_x \; \tfrac12 \|x-u\|_2^2 + \|x\|_2^2 + \rho/(1+\|x\|_2^2)
\]

从数学上，你可以对 \(g(z)=\rho/(1+z)\) 在合适参数范围内讨论凸性（或者更直接地：把它改写成 DCP 可识别的形式）。

但在 CVX 的眼里，它看到的是：

- 分子是正常数（positive constant）
- 分母是凸表达式（convex）
- 于是触发典型报错：

> `{positive constant} ./ {convex}` 不允许

原因是：在 DCP 规则中，“常数除以凸函数”一般不能被判定为凸（即便在特定域/特定参数下可能是凸）。

---

## 4) 遇到 DCP error 怎么办？三条工程策略

### 4.1 用等价的 DCP 原子函数替换（最优先）

很多看似“自己写的表达式”，其实有等价的 atom：

- 二次项：优先用 `sum_squares` / `quad_over_lin` / `norm` 族
- `log-sum-exp`：用 `log_sum_exp`
- 分式二次：用 `quad_over_lin`

### 4.2 引入辅助变量，把“不可识别结构”拆开

这就是“把数学证明转译成 DCP 语法”的核心技巧：

- 先把复杂表达式拆成几段
- 用新变量承接中间量
- 用一组 DCP 允许的约束把它们连接起来

（你文中举的 `quad_over_lin` 思路就是典型套路。）

### 4.3 接受“这不是凸”，换求解器/换表述

如果你确实需要非凸结构：

- 用 Ipopt/KNITRO 等非凸 NLP
- 或做凸松弛 / 近似 / 分段线性化

---

## 5) 最重要的结论（给建模者）

- **DCP 是一套“可证明正确”的语法系统**：它宁可错杀，也不放过。
- 你的工作不是“证明凸性”就结束，而是要把证明翻译成 **atoms + 组合规则**。
- 遇到 DCP 报错，优先做“结构重写”，而不是跟报错对抗。

---

## 参考链接

- DCP 教程与 analyzer：`https://dcp.stanford.edu/home`
- CVX atom library：`https://cvxr.com/cvx/doc/funcref.html`
- CVXPY：`https://github.com/cvxpy/cvxpy`

> 我把这篇整理成可复用的“报错→重构”手册，放到 Docs：`docs/tools/dcp-convexity-checking-rules.md`。

