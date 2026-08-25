## Unconstrained Optimization in Multiple Variables

### Overview

Unconstrained optimization in multiple variables addresses the problem of finding input vectors $\mathbf{x} \in \mathbb{R}^n$ that minimize or maximize a scalar-valued function $f(\mathbf{x})$, without any restrictions on the domain of $\mathbf{x}$. This is the mathematical foundation underlying most machine learning training procedures, where $f$ typically represents a loss or cost function and $\mathbf{x}$ represents model parameters (weights and biases).

This topic builds directly on gradient vectors, Jacobians, and Hessian matrices, extending single-variable optimization concepts (critical points, first and second derivative tests) into higher-dimensional space.

### Problem Formulation

The general unconstrained optimization problem is stated as:

$$\min_{\mathbf{x} \in \mathbb{R}^n} f(\mathbf{x})$$

where $f: \mathbb{R}^n \to \mathbb{R}$ is typically assumed to be twice continuously differentiable ($f \in C^2$) for the analysis that follows. Maximization problems are handled equivalently by minimizing $-f(\mathbf{x})$.

**Key Points**
- No constraints (equality, inequality, or bound) restrict the feasible region — the entire $\mathbb{R}^n$ space is searchable.
- Solutions rely on local information: gradients and curvature.
- In machine learning, $\mathbf{x}$ often has extremely high dimensionality (millions to billions of parameters in neural networks), making analytical solutions impractical and iterative numerical methods necessary.

### First-Order Necessary Condition: The Gradient

A point $\mathbf{x}^*$ is a candidate for a local extremum only if the gradient vanishes there:

$$\nabla f(\mathbf{x}^*) = \mathbf{0}$$

where the gradient is the vector of partial derivatives:

$$\nabla f(\mathbf{x}) = \begin{bmatrix} \dfrac{\partial f}{\partial x_1} \\ \dfrac{\partial f}{\partial x_2} \\ \vdots \\ \dfrac{\partial f}{\partial x_n} \end{bmatrix}$$

Points satisfying $\nabla f(\mathbf{x}^*) = \mathbf{0}$ are called **critical points** (or stationary points). This condition is necessary but not sufficient — it identifies candidates that could be minima, maxima, or saddle points.

### Second-Order Conditions: The Hessian Matrix

To classify a critical point, the Hessian matrix — the matrix of second-order partial derivatives — is examined:

$$H(\mathbf{x}) = \nabla^2 f(\mathbf{x}) = \begin{bmatrix}
\dfrac{\partial^2 f}{\partial x_1^2} & \dfrac{\partial^2 f}{\partial x_1 \partial x_2} & \cdots & \dfrac{\partial^2 f}{\partial x_1 \partial x_n} \\
\dfrac{\partial^2 f}{\partial x_2 \partial x_1} & \dfrac{\partial^2 f}{\partial x_2^2} & \cdots & \dfrac{\partial^2 f}{\partial x_2 \partial x_n} \\
\vdots & \vdots & \ddots & \vdots \\
\dfrac{\partial^2 f}{\partial x_n \partial x_1} & \dfrac{\partial^2 f}{\partial x_n \partial x_2} & \cdots & \dfrac{\partial^2 f}{\partial x_n^2}
\end{bmatrix}$$

For $f \in C^2$, the Hessian is symmetric by Clairaut's theorem (equality of mixed partials), assuming continuity of second partial derivatives. This is a well-established mathematical result, not an inference.

**Classification via definiteness at a critical point $\mathbf{x}^*$:**

| Hessian property at $\mathbf{x}^*$ | Classification |
|---|---|
| Positive definite ($\mathbf{v}^T H \mathbf{v} > 0$ for all $\mathbf{v} \neq \mathbf{0}$) | Local minimum |
| Negative definite ($\mathbf{v}^T H \mathbf{v} < 0$ for all $\mathbf{v} \neq \mathbf{0}$) | Local maximum |
| Indefinite (mixed positive/negative eigenvalues) | Saddle point |
| Positive/negative semidefinite (zero eigenvalue present) | Test inconclusive; higher-order analysis needed |

Definiteness is typically determined by examining the eigenvalues of $H(\mathbf{x}^*)$:
- All eigenvalues $> 0$ → positive definite
- All eigenvalues $< 0$ → negative definite
- Mixed signs → indefinite (saddle point)

### Diagram: Critical Point Classification

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 780 320">
  <text x="390" y="28" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Critical Point Types via Hessian Eigenvalues (svg_diagram)</text>

  
  <g transform="translate(60,60)">
    <text x="100" y="15" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Local Minimum</text>
    <path d="M 20 180 Q 100 40 180 180" stroke="#2563eb" stroke-width="3" fill="none" />
    <circle cx="100" cy="88" r="5" fill="#2563eb" />
    <text x="100" y="210" font-size="12" text-anchor="middle" fill="#333">All eigenvalues &gt; 0</text>
    <text x="100" y="228" font-size="12" text-anchor="middle" fill="#333">Positive definite H</text>
  </g>

  
  <g transform="translate(300,60)">
    <text x="100" y="15" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Local Maximum</text>
    <path d="M 20 60 Q 100 200 180 60" stroke="#dc2626" stroke-width="3" fill="none" />
    <circle cx="100" cy="152" r="5" fill="#dc2626" />
    <text x="100" y="210" font-size="12" text-anchor="middle" fill="#333">All eigenvalues &lt; 0</text>
    <text x="100" y="228" font-size="12" text-anchor="middle" fill="#333">Negative definite H</text>
  </g>

  
  <g transform="translate(540,60)">
    <text x="100" y="15" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Saddle Point</text>
    <path d="M 20 70 Q 100 130 180 70" stroke="#16a34a" stroke-width="3" fill="none" />
    <path d="M 20 190 Q 100 130 180 190" stroke="#16a34a" stroke-width="3" fill="none" stroke-dasharray="5,3" />
    <circle cx="100" cy="130" r="5" fill="#16a34a" />
    <text x="100" y="210" font-size="12" text-anchor="middle" fill="#333">Mixed sign eigenvalues</text>
    <text x="100" y="228" font-size="12" text-anchor="middle" fill="#333">Indefinite H</text>
  </g>

  <text x="390" y="300" font-size="11" text-anchor="middle" fill="#666">Curves are schematic cross-sections; actual functions exist in n dimensions</text>
</svg>

### Convexity and Global Optima

A critical distinction in optimization theory: the conditions above identify only **local** extrema. Whether a local minimum is also a **global** minimum depends on the convexity of $f$.

A function $f$ is convex on $\mathbb{R}^n$ if, for all $\mathbf{x}, \mathbf{y}$ and $\lambda \in [0,1]$:

$$f(\lambda \mathbf{x} + (1-\lambda)\mathbf{y}) \leq \lambda f(\mathbf{x}) + (1-\lambda) f(\mathbf{y})$$

Equivalently, for twice-differentiable $f$, convexity holds if and only if $H(\mathbf{x})$ is positive semidefinite for all $\mathbf{x}$ in the domain.

**Key Points**
- If $f$ is convex, any local minimum is guaranteed to be a global minimum. This is a proven mathematical result under the stated convexity assumption, not a general claim about all optimization problems.
- Most machine learning loss surfaces (e.g., deep neural network loss landscapes) are **non-convex**, meaning gradient-based methods may converge to local minima, saddle points, or plateaus rather than the global minimum. [Inference] The practical impact of this non-convexity on final model performance varies by architecture, initialization, and dataset, and is an active area of empirical research rather than a settled theoretical conclusion.
- Convex problems (e.g., linear regression with squared error, logistic regression without regularization complications) have loss surfaces where local search methods are more mathematically reliable.

### Numerical Methods for Finding Critical Points

Because closed-form solutions to $\nabla f(\mathbf{x}) = \mathbf{0}$ are rarely available for complex ML models, iterative numerical methods are used.

#### Gradient Descent

The most widely used method in machine learning. Updates parameters in the direction of steepest descent:

$$\mathbf{x}_{k+1} = \mathbf{x}_k - \eta \nabla f(\mathbf{x}_k)$$

where $\eta > 0$ is the learning rate (step size).

**Key Points**
- Convergence behavior depends heavily on $\eta$: too large risks divergence or oscillation; too small results in slow convergence.
- [Inference] For convex, smooth functions with an appropriately chosen step size, gradient descent tends to converge toward a global minimum, though the exact rate depends on problem conditioning (e.g., the condition number of the Hessian).
- On non-convex surfaces, gradient descent may converge to a local minimum or saddle point; convergence to a global minimum is not guaranteed by the method itself.

#### Newton's Method

Uses second-order (curvature) information via the Hessian:

$$\mathbf{x}_{k+1} = \mathbf{x}_k - H(\mathbf{x}_k)^{-1} \nabla f(\mathbf{x}_k)$$

**Key Points**
- Converges faster (quadratically, near a solution, under standard smoothness assumptions) than gradient descent when it converges.
- Requires computing and inverting the Hessian, which is computationally expensive — $O(n^3)$ for inversion — making it impractical for high-dimensional ML models with millions of parameters.
- Can fail or behave erratically if the Hessian is not positive definite at the current iterate.

#### Quasi-Newton Methods (e.g., BFGS, L-BFGS)

Approximate the Hessian (or its inverse) iteratively without computing it exactly, reducing computational cost relative to full Newton's method while retaining some curvature information. L-BFGS (limited-memory BFGS) is commonly used for moderate-scale ML optimization problems where full gradient descent variants are too slow but full Newton's method is too expensive.

### Worked Example

Consider the function:

$$f(x_1, x_2) = x_1^2 + 2x_2^2 - 2x_1 x_2 - 2x_1$$

**Step 1 — Compute the gradient:**

$$\nabla f(\mathbf{x}) = \begin{bmatrix} 2x_1 - 2x_2 - 2 \\ 4x_2 - 2x_1 \end{bmatrix}$$

**Step 2 — Set gradient to zero:**

$$2x_1 - 2x_2 - 2 = 0 \quad \Rightarrow \quad x_1 - x_2 = 1$$
$$4x_2 - 2x_1 = 0 \quad \Rightarrow \quad x_1 = 2x_2$$

Substituting: $2x_2 - x_2 = 1 \Rightarrow x_2 = 1$, so $x_1 = 2$.

Critical point: $\mathbf{x}^* = (2, 1)$.

**Step 3 — Compute the Hessian:**

$$H = \begin{bmatrix} 2 & -2 \\ -2 & 4 \end{bmatrix}$$

**Step 4 — Check definiteness:**

Leading principal minors: $2 > 0$, and $\det(H) = (2)(4) - (-2)(-2) = 8 - 4 = 4 > 0$. Both leading principal minors are positive, so by Sylvester's criterion, $H$ is positive definite.

**Output**

$\mathbf{x}^* = (2, 1)$ is a local minimum. Since $H$ is positive definite everywhere (it is constant and does not depend on $\mathbf{x}$ in this quadratic example), $f$ is convex, so $(2,1)$ is also the global minimum.

### Relevance to Machine Learning Training

**Key Points**
- Training a model by minimizing a loss function $L(\mathbf{w})$ over weights $\mathbf{w}$ is a direct application of unconstrained multivariable optimization.
- Linear regression with mean squared error produces a convex quadratic loss surface, analytically solvable and well-suited to the theory above.
- Neural network loss surfaces are generally non-convex, high-dimensional, and may contain many saddle points. [Unverified] The specific claim that saddle points are more numerous than local minima in high-dimensional neural network loss landscapes originates from theoretical and empirical work in the optimization literature; the precise prevalence in any given architecture is not something this response can confirm without citing a specific verified source.
- Optimizers used in practice (SGD, Adam, RMSProp) are variations and extensions of the gradient descent framework, incorporating momentum, adaptive learning rates, or stochastic approximations of the gradient using mini-batches rather than the full dataset.

### Common Pitfalls

- **Mistaking a critical point for a minimum without checking the Hessian.** A vanishing gradient alone does not distinguish minima, maxima, and saddle points.
- **Assuming convexity where none exists.** Applying global-optimum reasoning to non-convex ML loss surfaces without qualification is a frequent conceptual error.
- **Ignoring step size sensitivity in gradient descent.** Divergence or slow convergence is a direct, mathematically explainable consequence of poor learning rate choice, not a mysterious failure of the algorithm.
- **Numerical instability in Hessian-based methods.** Ill-conditioned or near-singular Hessians can cause Newton's method updates to behave unpredictably; behavior in such cases can vary by implementation and numerical precision.

### Next Steps

- Convex Optimization Fundamentals — convex sets, convex functions, and their optimization properties
- Gradient Descent Variants — stochastic gradient descent, mini-batch methods, momentum
- Second-Order Optimization Methods — deeper treatment of Newton's method and quasi-Newton approaches
- Constrained Optimization — Lagrange multipliers and Karush-Kuhn-Tucker (KKT) conditions
- Eigenvalues and Eigenvectors — foundational linear algebra for Hessian analysis
- Learning Rate Scheduling and Adaptive Optimizers — Adam, RMSProp, AdaGrad
- Saddle Points in High-Dimensional Loss Landscapes — theoretical and empirical perspectives