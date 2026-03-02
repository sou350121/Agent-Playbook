# 講透最強參數估計：貝葉斯估計（Bayesian Estimation）深度解析

> **信號來源**：cos大壯 - 參數估計系列分享
> **核心關鍵詞**：不確定性傳播、共軛先驗、層級模型、模型選擇（奧卡姆剃刀）

---

哈嘍，我是 cos 大壯~ 今兒和大家分享一個在參數估計方法涉及到的：**貝葉斯估計**。

在參數估計中，傳統的頻率學派方法主要使用最大似然估計（MLE）或正則化的最大後驗估計（MAP）。與之不同，**貝葉斯估計將參數視為隨機變量**，使用先驗分布表達我們的先驗知識，通過數據的似然函數更新到後驗分布，並最終基於後驗進行推斷與預測。

## 🧠 貝葉斯估計的核心：Bayes 定理

\[ P(\theta | D) = \frac{P(D | \theta) P(\theta)}{P(D)} \]

其中：
- **\( P(\theta) \)**：先驗（Prior）。
- **\( P(D | \theta) \)**：似然（Likelihood）。
- **\( P(\theta | D) \)**：後驗（Posterior）。
- **\( P(D) \)**：證據（Evidence），用於模型比較。

與 MLE/MAP 不同的是，貝葉斯估計通過後驗分布反映參數不確定性，預測時進一步將參數不確定性傳播到輸出，得到 **後驗預測分布**。這使我們能夠嚴格地給出置信區間，並進行穩健的模型比較。

---

## 🛠️ 案例模型：貝葉斯線性回歸

我們考慮一維輸入 \( x \)、標量輸出 \( y \)，採用非線性特徵映射（例如多項式基）。

### 1. 似然函數 (Likelihood)
在給定 \(\mathbf{w}\) 和 \(\sigma^2\) 情況下，似然為高斯：
\[ P(\mathbf{y} | \mathbf{X}, \mathbf{w}, \beta) = \mathcal{N}(\mathbf{y} | \mathbf{\Phi}\mathbf{w}, \beta^{-1}\mathbf{I}) \]
其中 \(\beta = 1/\sigma^2\) 是噪聲精度。

### 2. 先驗選擇 (Prior)
- **權重先驗**：\( P(\mathbf{w} | \alpha) = \mathcal{N}(\mathbf{w} | \mathbf{0}, \alpha^{-1}\mathbf{I}) \)。
- **層級先驗 (NIG)**：對 \(\sigma^2\) 使用 Inverse-Gamma 分布，形成層級貝葉斯模型，在小樣本下更穩健。

### 3. 後驗預測分布 (Posterior Predictive)
對於新輸入 \(\mathbf{x}_*\)，預測分布仍為高斯：
\[ P(y_* | \mathbf{x}_*, D) = \mathcal{N}(y_* | \mu_* , \sigma^2_*) \]
其中預測方差 \(\sigma^2_*\) 由 **噪聲** 與 **參數不確定性** 共同貢獻。

---

## 💻 完整代碼實現 (PyTorch & Sklearn)

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import BayesianRidge
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import Pipeline
import torch
from torch.distributions import MultivariateNormal

np.random.seed(42)
torch.manual_seed(42)

# 1) 合成數據
N = 80
X = np.linspace(-3, 3, N)
def f_true(x):
    return np.sin(1.5*x) + 0.3*(x**2) - 0.5*x

sigma = 0.5 
y = f_true(X) + np.random.normal(0, sigma, size=N)

# 2) 構造多項式特徵
M = 7  
poly = PolynomialFeatures(degree=M, include_bias=True)
Phi = poly.fit_transform(X.reshape(-1, 1))  
M_eff = Phi.shape[1]  

# 3) PyTorch 計算後驗 (共軛公式)
alpha = 1.0   
beta = 1.0 / (sigma**2)  

Phi_t = torch.tensor(Phi, dtype=torch.float64)
y_t = torch.tensor(y, dtype=torch.float64).reshape(-1, 1)

A = alpha * torch.eye(M_eff, dtype=torch.float64) + beta * (Phi_t.T @ Phi_t)
Sigma = torch.linalg.inv(A)
mu = beta * (Sigma @ (Phi_t.T @ y_t))  

# 後驗預測函數
def posterior_predict(x_grid, mu, Sigma, poly, beta):
    Phi_star = poly.transform(x_grid.reshape(-1, 1))
    Phi_star_t = torch.tensor(Phi_star, dtype=torch.float64)
    mean = (Phi_star_t @ mu).numpy().flatten()
    var = (1.0/beta) + torch.sum(Phi_star_t @ Sigma * Phi_star_t, dim=1)
    return mean, var.numpy()

# 4) 可視化
X_test = np.linspace(-3.5, 3.5, 400)
mean_post, var_post = posterior_predict(X_test, mu, Sigma, poly, beta)
std_post = np.sqrt(var_post)

plt.figure(figsize=(12, 8))
plt.scatter(X, y, color='#e41a1c', s=35, alpha=0.8, label='觀測數據')
plt.plot(X_test, f_true(X_test), '--', color='black', label='真實函數')
plt.plot(X_test, mean_post, color='#377eb8', lw=2.5, label='後驗預測均值')
plt.fill_between(X_test, mean_post - 1.96*std_post, mean_post + 1.96*std_post, color='#4daf4a', alpha=0.2, label='95%可信區間')
plt.title('貝葉斯線性回歸：不確定性傳播')
plt.legend()
plt.show()

# 打印 sklearn 估計結果
br_model = Pipeline([("poly", poly), ("bayes", BayesianRidge())])
br_model.fit(X.reshape(-1, 1), y)
print(f"Sklearn Alpha (權重精度): {br_model.named_steps['bayes'].alpha_}")
```

---

## 📊 核心啟示：為什麼貝葉斯更強？

1.  **不確定性量化**：它不只給你一個「點」，還給你一個「範圍」。這在 Agent 決策（如自動駕駛、風控）中至關重要。
2.  **自動奧卡姆剃刀**：邊緣似然（Evidence）會自動懲罰過於複雜的模型，天然平衡擬合度與複雜度。
3.  **參數相關性**：後驗協方差矩陣揭示了參數間的協作關係，幫你識別哪些特徵是「危險」或不穩定的。

詳細理論與層級模型推導，請參閱：
- **[不確定性處理與貝葉斯估計](../../cognition/frameworks/bayesian-estimation-and-uncertainty.md)**
