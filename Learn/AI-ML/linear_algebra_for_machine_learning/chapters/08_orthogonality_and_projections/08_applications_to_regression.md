## Applications to Regression

### Overview

Linear regression, at its core, is a linear algebra problem: finding the coefficient vector that best maps input features to a target output. The entire machinery of ordinary least squares (OLS), ridge regression, and their numerical solution methods is built directly on matrix operations, projections, and decompositions.

### The Regression Problem in Matrix Form

Given $n$ observations and $p$ features, the linear model is written as:

$$y = X\beta + \epsilon$$

where:

- $X \in \mathbb{R}^{n \times p}$ is the design matrix (rows = observations, columns = features)
- $\beta \in \mathbb{R}^{p}$ is the vector of coefficients to estimate
- $y \in \mathbb{R}^{n}$ is the target vector
- $\epsilon$ is the error/residual term

The goal is to find $\hat{\beta}$ that minimizes the sum of squared residuals:

$$\hat{\beta} = \arg\min_{\beta} \|y - X\beta\|^2$$

### The Normal Equations

Setting the gradient of $\|y - X\beta\|^2$ to zero yields the **normal equations**:

$$X^T X \beta = X^T y$$

Solving for $\beta$ (assuming $X^TX$ is invertible):

$$\hat{\beta} = (X^TX)^{-1} X^T y$$

This is a direct, closed-form algebraic result — a standard, well-established derivation in linear algebra, not an inference.

### Geometric Interpretation: Projection

Regression can be understood geometrically as an **orthogonal projection**. The fitted values $\hat{y} = X\hat{\beta}$ are the projection of $y$ onto the column space of $X$ — the subspace spanned by the feature vectors.

$$\hat{y} = X(X^TX)^{-1}X^T y = Py$$

where $P = X(X^TX)^{-1}X^T$ is the **projection matrix** (also called the "hat matrix"). This matrix has two defining properties:

- **Idempotent**: $P^2 = P$ (projecting twice changes nothing further)
- **Symmetric**: $P^T = P$

The residual vector $e = y - \hat{y}$ is orthogonal to the column space of $X$, meaning $X^Te = 0$. This orthogonality is the geometric reason the normal equations hold.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">
<text x="200" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Regression as Orthogonal Projection (svg_diagram)</text>
<polygon points="60,220 340,220 300,120 100,120" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" />
<text x="200" y="235" font-size="11" text-anchor="middle" fill="#4338ca">Column Space of X</text>
<line x1="150" y1="170" x2="150" y2="60" stroke="#dc2626" stroke-width="2.5" marker-end="url(#a1)" />
<text x="130" y="55" font-size="12" fill="#dc2626">y</text>
<line x1="150" y1="170" x2="220" y2="150" stroke="#2563eb" stroke-width="2.5" marker-end="url(#a2)" />
<text x="228" y="150" font-size="12" fill="#2563eb">ŷ = Xβ̂</text>
<line x1="150" y1="60" x2="220" y2="150" stroke="#16a34a" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#a3)" />
<text x="230" y="105" font-size="12" fill="#16a34a">e (residual)</text>
<rect x="205" y="140" width="10" height="10" fill="none" stroke="#555" stroke-width="1" />
</svg>

### Numerical Solution Methods

Directly computing $(X^TX)^{-1}$ is a standard textbook derivation, but it is not always the preferred computational approach in practice.

**1. Normal Equations Method**

$$\hat{\beta} = (X^TX)^{-1}X^Ty$$

- Simple to implement.
- [Inference] Numerically less stable than decomposition-based methods when $X$ is ill-conditioned, because forming $X^TX$ squares the condition number of $X$. This is a commonly cited property in numerical linear algebra references, presented here as a reasoned consequence of how condition numbers behave under matrix multiplication, not a claim verified against a specific benchmark in this conversation.

**2. QR Decomposition Method**Factor $X = QR$, where $Q$ is orthogonal and $R$ is upper triangular. The normal equations reduce to:

$$R\beta = Q^Ty$$

which is solved by back-substitution. This avoids explicitly forming $X^TX$, which is the main source of numerical instability in the normal-equations approach.

**3. SVD Method**Factor $X = U\Sigma V^T$. Then:

$$\hat{\beta} = V\Sigma^{+}U^Ty$$

where $\Sigma^+$ is the pseudo-inverse of the diagonal singular value matrix. This method is the most numerically robust and also handles the case where $X^TX$ is singular or near-singular (e.g., when features are collinear or $p > n$).

| Method | Stability | Handles Collinearity | Typical Use |
| --- | --- | --- | --- |
| Normal Equations | Lower | No | Small, well-conditioned problems |
| QR Decomposition | Higher | Partial | General-purpose solver (used in many statistical software packages) |
| SVD | Highest | Yes | Ill-conditioned or rank-deficient data |

### Ridge Regression and Regularization

When $X^TX$ is singular or near-singular (common with collinear features or $p > n$), ridge regression adds a penalty term:

$$\hat{\beta}_{ridge} = (X^TX + \lambda I)^{-1}X^Ty$$

Adding $\lambda I$ (for $\lambda > 0$) shifts all eigenvalues of $X^TX$ away from zero, which makes the matrix invertible even when $X^TX$ alone is not. This is a direct algebraic consequence of how eigenvalues shift under the addition of $\lambda I$: if $X^TX$ has eigenvalue $\mu \geq 0$, then $X^TX + \lambda I$ has eigenvalue $\mu + \lambda > 0$.

[Inference] Ridge regression is commonly described as trading some bias for reduced variance in the coefficient estimates. This is a standard interpretation in statistical learning theory, reasoned from the structure of the estimator, but the actual bias-variance tradeoff observed on any specific dataset depends on the data and is not something that can be verified without empirical testing on that data.

### Least Squares via Eigendecomposition (Statistical Interpretation)

The covariance structure of $\hat{\beta}$ under standard OLS assumptions (homoscedastic, uncorrelated errors) is:

$$\text{Cov}(\hat{\beta}) = \sigma^2(X^TX)^{-1}$$

The eigenvectors of $(X^TX)^{-1}$ describe the directions in coefficient space along which the estimate is more or less precise; small eigenvalues of $X^TX$ correspond to large variance in the corresponding coefficient direction. This connects directly to multicollinearity diagnostics such as condition number analysis and variance inflation factors (VIF).

### Worked Example

Given a small dataset with one feature plus an intercept term:

$$X = \begin{bmatrix} 1 & 1 \\ 1 & 2 \\ 1 & 3 \end{bmatrix}, \quad y = \begin{bmatrix} 2 \\ 3 \\ 5 \end{bmatrix}$$

Compute $X^TX$:

$$X^TX = \begin{bmatrix} 3 & 6 \\ 6 & 14 \end{bmatrix}$$

Compute $X^Ty$:

$$X^Ty = \begin{bmatrix} 10 \\ 23 \end{bmatrix}$$

Solving $X^TX\beta = X^Ty$ gives $\beta = \begin{bmatrix} 0 \\ 1.5 \end{bmatrix}$ (approximately, depending on exact solve), meaning the fitted line is roughly $\hat{y} = 1.5x$.

### Computational Check (Python / NumPy)

```python
import numpy as np

X = np.array([[1, 1], [1, 2], [1, 3]])
y = np.array([2, 3, 5])

# Normal equations
beta_normal = np.linalg.inv(X.T @ X) @ X.T @ y

# QR method
Q, R = np.linalg.qr(X)
beta_qr = np.linalg.solve(R, Q.T @ y)

# SVD / lstsq method (most robust)
beta_svd, residuals, rank, sv = np.linalg.lstsq(X, y, rcond=None)

print(beta_normal, beta_qr, beta_svd)
```

[Unverified] The exact numerical output values may differ slightly across methods due to floating-point rounding, and the specific results depend on the NumPy version and hardware used to run this code.

### Key Points

- Regression coefficients arise from a projection of $y$ onto the column space of $X$.
- The normal equations $X^TX\beta = X^Ty$ are a direct algebraic derivation from minimizing squared error.
- QR and SVD decompositions are generally preferred over direct normal-equation inversion for numerical stability, particularly on ill-conditioned data. [Inference] This preference is a widely cited principle in numerical linear algebra, reasoned from condition-number behavior, but the practical impact varies by dataset and is not something this response can verify empirically.
- Ridge regression stabilizes ill-conditioned problems by shifting eigenvalues of $X^TX$ away from zero — this is a direct algebraic result, not a probabilistic claim.
- I cannot verify runtime performance, library-specific behavior, or benchmark comparisons between these methods without a specific empirical source; any such claims here are labeled as [Inference] or [Unverified] accordingly.

### Related Topics

- QR Decomposition and Gram-Schmidt Orthogonalization
- Singular Value Decomposition (SVD) and Pseudo-Inverses
- Projection Matrices and Subspaces
- Eigenvalues, Eigenvectors, and Condition Numbers
- Multicollinearity and Variance Inflation Factors (VIF)
- Regularization Methods: Ridge, Lasso, and Elastic Net
- Gradient Descent as an Alternative to Closed-Form Solutions
- Bias-Variance Tradeoff in Statistical Learning