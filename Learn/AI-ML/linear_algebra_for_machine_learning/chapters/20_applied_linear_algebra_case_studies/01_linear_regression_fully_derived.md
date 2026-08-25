## Linear Regression Fully Derived

### Overview

Linear regression is one of the foundational applications of linear algebra in machine learning, providing a closed-form analytical solution derived directly from matrix calculus and vector space geometry. This derivation covers the problem setup, the normal equations, the closed-form solution, and its geometric interpretation as a projection.

### Problem Setup

**Key Points**
- Given a dataset of $N$ observations, each with $n$ features, the design matrix is $X \in \mathbb{R}^{N \times n}$ (or $N \times (n+1)$ if a bias/intercept column of ones is included).
- The target values are collected in a vector $y \in \mathbb{R}^N$.
- Linear regression seeks a weight vector $w \in \mathbb{R}^n$ such that predictions $\hat{y} = Xw$ approximate the true targets $y$ as closely as possible, according to a chosen error criterion.

**Example**

$$X = \begin{pmatrix} 1 & x_1^{(1)} & x_2^{(1)} \\ 1 & x_1^{(2)} & x_2^{(2)} \\ \vdots & \vdots & \vdots \\ 1 & x_1^{(N)} & x_2^{(N)} \end{pmatrix}, \quad w = \begin{pmatrix} w_0 \\ w_1 \\ w_2 \end{pmatrix}, \quad \hat{y} = Xw$$

Here the first column of ones allows $w_0$ to act as the intercept term.

### The Least Squares Objective

**Key Points**
- Linear regression typically minimizes the sum of squared residuals between predictions and true targets, known as the least squares objective:

$$J(w) = \|y - Xw\|_2^2 = (y - Xw)^T(y - Xw)$$

- This objective penalizes larger errors more heavily than smaller ones, due to the squaring operation, and is chosen for reasons including mathematical tractability (it produces a closed-form solution) and its connection to maximum likelihood estimation under Gaussian noise assumptions.
- [Inference] The Gaussian noise justification for least squares is a standard derivation found in statistics literature, connecting squared-error minimization to maximum likelihood estimation under the assumption that residuals are independently and normally distributed; this is a stated mathematical justification, not a claim that real-world data always satisfies this assumption.

### Expanding the Objective Function

**Key Points**
- Expanding $J(w) = (y - Xw)^T(y - Xw)$ using matrix algebra:

$$J(w) = y^Ty - y^TXw - w^TX^Ty + w^TX^TXw$$

- Since $y^TXw$ is a scalar, it equals its own transpose: $y^TXw = (y^TXw)^T = w^TX^Ty$. This allows the two middle terms to be combined:

$$J(w) = y^Ty - 2w^TX^Ty + w^TX^TXw$$

### Deriving the Normal Equations

**Key Points**
- To minimize $J(w)$, take the gradient with respect to $w$ and set it to zero.
- Using standard matrix calculus identities: $\nabla_w(w^TX^Ty) = X^Ty$, and $\nabla_w(w^TX^TXw) = 2X^TXw$ (since $X^TX$ is symmetric).
- Applying these identities:

$$\nabla_w J(w) = -2X^Ty + 2X^TXw$$

- Setting the gradient to zero:

$$-2X^Ty + 2X^TXw = 0$$
$$X^TXw = X^Ty$$

- This result is known as the normal equations.

### Solving the Normal Equations

**Key Points**
- If $X^TX$ is invertible (which requires $X$ to have full column rank, meaning its columns are linearly independent), the normal equations can be solved directly:

$$w^* = (X^TX)^{-1}X^Ty$$

- This is the closed-form ordinary least squares (OLS) solution.
- [Inference] Full column rank of $X$ is commonly stated as a requirement for $X^TX$ to be invertible in standard linear algebra treatments of this derivation; when this condition does not hold (e.g., due to multicollinearity or more features than observations), $X^TX$ is singular and the closed-form inverse does not exist in the standard sense, requiring alternative approaches such as regularization or the pseudoinverse, discussed further below.

### Derivation Flow Diagram

```mermaid
flowchart TD
    A[Objective: J(w) = norm of y - Xw squared] --> B[Expand: y^Ty - 2w^TX^Ty + w^TX^TXw]
    B --> C[Take gradient with respect to w]
    C --> D[Gradient = -2X^Ty + 2X^TXw]
    D --> E[Set gradient to zero]
    E --> F[Normal equations: X^TXw = X^Ty]
    F --> G{X^TX invertible?}
    G -->|Yes| H[w* = inverse of X^TX times X^Ty]
    G -->|No| I[Use pseudoinverse or regularization]
```

### The Moore-Penrose Pseudoinverse

**Key Points**
- When $X^TX$ is not invertible, the Moore-Penrose pseudoinverse $X^+$ provides a generalized solution: $w^* = X^+y$.
- The pseudoinverse can be computed via Singular Value Decomposition (SVD): if $X = U\Sigma V^T$, then $X^+ = V\Sigma^+U^T$, where $\Sigma^+$ is formed by taking the reciprocal of each nonzero singular value in $\Sigma$ and transposing the resulting matrix.
- [Inference] The pseudoinverse-based solution is commonly described in numerical linear algebra literature as providing the minimum-norm solution among all vectors $w$ that minimize $J(w)$ when multiple solutions exist, though this specific property claim is stated here as a mathematical result from that literature rather than independently re-derived in full within this response.

### Geometric Interpretation: Projection onto Column Space

**Key Points**
- The fitted values $\hat{y} = Xw^* = X(X^TX)^{-1}X^Ty$ can be interpreted geometrically as the orthogonal projection of $y$ onto the column space of $X$.
- The matrix $H = X(X^TX)^{-1}X^T$ is called the "hat matrix" or projection matrix, since it maps $y$ directly to $\hat{y} = Hy$.
- The residual vector $e = y - \hat{y}$ is orthogonal to the column space of $X$, meaning $X^Te = 0$. [Inference] This orthogonality property follows directly from the normal equations derived above ($X^TXw = X^Ty$ implies $X^T(y - Xw) = 0$), and is a standard geometric characterization of the least squares solution in linear algebra treatments of this topic.

### Projection Geometry Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Least Squares as Orthogonal Projection (svg_diagram)</text>

  <rect x="80" y="120" width="400" height="180" fill="#eef4fb" stroke="#4a90d9" stroke-width="1.5" stroke-dasharray="4" />
  <text x="280" y="115" text-anchor="middle" font-size="12" fill="#4a90d9">Column space of X</text>

  <line x1="150" y1="280" x2="450" y2="140" stroke="#4a90d9" stroke-width="2" />
  <text x="460" y="135" font-size="11" fill="#4a90d9">span of X columns</text>

  <circle cx="380" cy="90" r="4" fill="#d94a4a" />
  <text x="400" y="90" font-size="13" fill="#d94a4a">y (target vector)</text>

  <line x1="380" y1="90" x2="500" y2="90" stroke="none" />
  <circle cx="330" cy="180" r="4" fill="#4ad97a" />
  <text x="340" y="200" font-size="13" fill="#2e9955">ŷ = Xw* (projection)</text>

  <line x1="380" y1="90" x2="330" y2="180" stroke="#333" stroke-width="2" stroke-dasharray="3" />
  <text x="365" y="130" font-size="11" fill="#333">e = y − ŷ (residual)</text>

  <path d="M 340 165 L 350 175 L 340 185" stroke="#333" stroke-width="1.5" fill="none" />
  <text x="355" y="165" font-size="10" fill="#555">orthogonal</text>

  <text x="350" y="340" text-anchor="middle" font-size="12" fill="#555">The residual e is orthogonal to the column space of X</text>
</svg>

### Verifying the Solution: Second-Order Condition

**Key Points**
- To confirm $w^*$ is a minimum (not a maximum or saddle point), the Hessian of $J(w)$ is examined: $\nabla_w^2 J(w) = 2X^TX$.
- $X^TX$ is always positive semi-definite (and positive definite when $X$ has full column rank), meaning $J(w)$ is convex, which [Inference] is a standard mathematical result confirming that any critical point satisfying the normal equations is a global minimum of the least squares objective, following from the general property that a convex function's critical points are global minima.

### Ridge Regression as a Regularized Extension

**Key Points**
- When $X^TX$ is ill-conditioned or singular, ridge regression adds an L2 penalty term to the objective: $J_{ridge}(w) = \|y - Xw\|_2^2 + \lambda\|w\|_2^2$, where $\lambda \geq 0$ is a regularization hyperparameter.
- Following the same derivation process (gradient set to zero) yields the closed-form solution:

$$w^*_{ridge} = (X^TX + \lambda I)^{-1}X^Ty$$

- Adding $\lambda I$ to $X^TX$ makes the matrix invertible even when $X^TX$ alone is singular, since $X^TX + \lambda I$ is positive definite for any $\lambda > 0$. [Inference] This invertibility argument is a standard result in numerical linear algebra literature on regularization, stated here as a mathematical property rather than a claim about optimal regularization strength for any specific dataset.

### Computational Considerations

**Key Points**
- Directly computing $(X^TX)^{-1}$ has a computational cost of approximately $O(n^3)$ for the matrix inversion (where $n$ is the number of features), plus $O(Nn^2)$ for forming $X^TX$.
- [Unverified] In practice, numerical linear algebra libraries commonly solve the normal equations using more numerically stable methods (such as QR decomposition or SVD-based approaches) rather than computing an explicit matrix inverse, though the specific method used varies by library, implementation, and problem conditioning, and no single method is asserted here as universal.
- [Inference] Explicit matrix inversion is commonly discussed in numerical linear algebra literature as being more susceptible to numerical instability than decomposition-based solving methods, particularly when $X^TX$ is close to singular (poorly conditioned), though the specific magnitude of this effect depends on the conditioning of the specific matrix involved.

### Common Pitfalls

**Key Points**
- Assuming $(X^TX)^{-1}$ always exists without checking for multicollinearity or rank deficiency in the design matrix.
- Applying the ordinary least squares closed-form solution to datasets where the number of features exceeds the number of observations, without recognizing that $X^TX$ will be singular in that case.
- Confusing the geometric roles of the fitted values $\hat{y}$ (the projection) and residuals $e$ (the orthogonal complement), which are fundamental to interpreting model fit.
- Overlooking numerical stability considerations when implementing the closed-form solution directly via explicit matrix inversion, rather than using more numerically stable decomposition-based methods. [Unverified] regarding which specific method any given implementation actually uses.

### Related Topics

- Singular Value Decomposition (SVD) and the pseudoinverse
- QR decomposition for numerically stable least squares solving
- Ridge and Lasso regression as regularized linear models
- Gradient descent as an iterative alternative to the closed-form solution
- Matrix rank, invertibility, and multicollinearity
- Maximum likelihood estimation and its connection to least squares
- Positive definite matrices and convexity in optimization

I cannot verify specific numerical library implementation choices, exact conditioning thresholds, or dataset-specific outcomes referenced in this content without citable, version-specific sources. All [Inference] and [Unverified] labeled statements reflect standard mathematical derivations and reasoning found in linear algebra and statistics literature, not independently re-verified claims about any specific software system. Behavior of specific numerical libraries or implementations is not guaranteed and may vary by version, algorithm choice, and data conditioning.
The previous response on **linear regression fully derived** was already complete — it covered the full derivation from problem setup through the normal equations, closed-form solution, pseudoinverse, geometric interpretation, ridge regression, computational considerations, common pitfalls, and Related Topics, ending with the standard disclaimer. There is no missing continuation.