## Hessian Matrix

### Definition

Given a twice-differentiable scalar-valued function $f: \mathbb{R}^n \to \mathbb{R}$, the Hessian matrix collects all second-order partial derivatives into a single $n \times n$ matrix:

$$H = \nabla^2 f = \begin{bmatrix} \dfrac{\partial^2 f}{\partial x_1^2} & \dfrac{\partial^2 f}{\partial x_1 \partial x_2} & \cdots & \dfrac{\partial^2 f}{\partial x_1 \partial x_n} \\ \dfrac{\partial^2 f}{\partial x_2 \partial x_1} & \dfrac{\partial^2 f}{\partial x_2^2} & \cdots & \dfrac{\partial^2 f}{\partial x_2 \partial x_n} \\ \vdots & \vdots & \ddots & \vdots \\ \dfrac{\partial^2 f}{\partial x_n \partial x_1} & \dfrac{\partial^2 f}{\partial x_n \partial x_2} & \cdots & \dfrac{\partial^2 f}{\partial x_n^2} \end{bmatrix}$$

Each entry is $H_{ij} = \dfrac{\partial^2 f}{\partial x_i \partial x_j}$.

### Symmetry (Schwarz's Theorem)

If $f$ has continuous second-order partial derivatives in a neighborhood of a point, then mixed partial derivatives are equal:

$$\frac{\partial^2 f}{\partial x_i \partial x_j} = \frac{\partial^2 f}{\partial x_j \partial x_i}$$

This makes $H$ symmetric ($H = H^T$) under these conditions. This is a standard calculus result (Schwarz's theorem / Clairaut's theorem), not an inference.

### Relationship to the Jacobian

The Hessian of a scalar function $f$ can be viewed as the Jacobian of its gradient vector field:

$$H = J(\nabla f)$$

[Inference] This framing — Hessian as the Jacobian of the gradient — is a common way of relating the two concepts across sources, but I cannot verify that every reference states it in exactly this form, so it should be read as a conceptual relationship rather than a universally quoted definition.

### Key Rules for Common Function Forms

#### Quadratic Form

For $f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x}$, where $A$ is a constant matrix:

$$H = A + A^T$$

If $A$ is symmetric:

$$H = 2A$$

#### Squared Euclidean Norm

For $f(\mathbf{x}) = \|\mathbf{x}\|_2^2$:

$$H = 2I$$

where $I$ is the identity matrix.

#### Sum of Squared Errors (Least Squares Form)

For $f(\mathbf{x}) = \|A\mathbf{x} - \mathbf{b}\|_2^2$:

$$H = 2A^T A$$

This Hessian is constant (independent of $\mathbf{x}$) since the function is quadratic.

### Summary Table

| Function $f(\mathbf{x})$ | Hessian $H$ |
|---|---|
| $\mathbf{x}^T A \mathbf{x}$ (general $A$) | $A + A^T$ |
| $\mathbf{x}^T A \mathbf{x}$ ($A$ symmetric) | $2A$ |
| $\|\mathbf{x}\|_2^2$ | $2I$ |
| $\|A\mathbf{x} - \mathbf{b}\|_2^2$ | $2A^T A$ |

### Second-Order Taylor Approximation

The Hessian appears in the second-order Taylor expansion of $f$ around a point $\mathbf{x}_0$:

$$f(\mathbf{x}) \approx f(\mathbf{x}_0) + \nabla f(\mathbf{x}_0)^T (\mathbf{x} - \mathbf{x}_0) + \frac{1}{2}(\mathbf{x} - \mathbf{x}_0)^T H(\mathbf{x}_0) (\mathbf{x} - \mathbf{x}_0)$$

This is the multivariable generalization of the single-variable second-order Taylor expansion.

### Using the Hessian to Classify Critical Points

At a critical point where $\nabla f(\mathbf{x}_0) = \mathbf{0}$, the eigenvalues of $H(\mathbf{x}_0)$ determine the nature of that point:

| Eigenvalues of $H$ | Classification |
|---|---|
| All positive | Local minimum |
| All negative | Local maximum |
| Mixed signs (some positive, some negative) | Saddle point |
| Some zero, rest same sign | Test is inconclusive |

This classification follows from the second-derivative test, a standard result in multivariable calculus.

### Example

Let $f(\mathbf{x}) = x_1^2 + 3x_1 x_2 + 2x_2^2$.

First partial derivatives:

$$\frac{\partial f}{\partial x_1} = 2x_1 + 3x_2, \qquad \frac{\partial f}{\partial x_2} = 3x_1 + 4x_2$$

Second partial derivatives:

$$\frac{\partial^2 f}{\partial x_1^2} = 2, \quad \frac{\partial^2 f}{\partial x_1 \partial x_2} = 3, \quad \frac{\partial^2 f}{\partial x_2^2} = 4$$

So the Hessian is:

$$H = \begin{bmatrix} 2 & 3 \\ 3 & 4 \end{bmatrix}$$

The eigenvalues of $H$ satisfy $\det(H - \lambda I) = 0$:

$$(2-\lambda)(4-\lambda) - 9 = 0 \implies \lambda^2 - 6\lambda - 1 = 0 \implies \lambda = \frac{6 \pm \sqrt{40}}{2}$$

This gives $\lambda \approx 6.16$ and $\lambda \approx -0.16$ — mixed signs, indicating the origin is a saddle point of $f$.

### Diagram: Curvature Types Indicated by the Hessian

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 660 260">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Curvature Classified by Hessian Eigenvalues (svg_diagram)</text>

  <text x="40" y="60" font-size="13" fill="#333">Local Minimum</text>
  <path d="M 20 150 Q 100 80 180 150" fill="none" stroke="#339933" stroke-width="2" />
  <text x="60" y="180" font-size="11" fill="#555">(all eigenvalues &gt; 0)</text>

  <text x="260" y="60" font-size="13" fill="#333">Local Maximum</text>
  <path d="M 240 90 Q 320 160 400 90" fill="none" stroke="#cc3333" stroke-width="2" />
  <text x="270" y="180" font-size="11" fill="#555">(all eigenvalues &lt; 0)</text>

  <text x="480" y="60" font-size="13" fill="#333">Saddle Point</text>
  <path d="M 460 150 Q 540 100 620 150" fill="none" stroke="#cc8800" stroke-width="2" />
  <path d="M 500 110 Q 540 150 580 110" fill="none" stroke="#cc8800" stroke-width="2" stroke-dasharray="4,3" />
  <text x="480" y="200" font-size="11" fill="#555">(mixed sign eigenvalues)</text>
</svg>

### Positive Definiteness and Optimization

A Hessian $H$ is:

- **Positive definite** if $\mathbf{v}^T H \mathbf{v} > 0$ for all nonzero $\mathbf{v}$ — indicates a strictly convex function locally and a local minimum at a critical point.
- **Negative definite** if $\mathbf{v}^T H \mathbf{v} < 0$ for all nonzero $\mathbf{v}$ — indicates local concavity and a local maximum at a critical point.
- **Indefinite** if it takes both positive and negative values depending on $\mathbf{v}$ — indicates a saddle point.

These definitions are standard in convex optimization theory (e.g., Boyd & Vandenberghe, *Convex Optimization*). [Unverified] I do not have access to confirm the exact page or section number of that reference within this conversation, so this should be treated as a commonly cited association rather than a verified quotation.

### Applications in Machine Learning

- **Newton's method**: The update rule $\mathbf{x} \leftarrow \mathbf{x} - H^{-1} \nabla f(\mathbf{x})$ uses the Hessian to incorporate curvature information, often converging in fewer iterations than gradient descent for suitable problems. [Inference] Whether Newton's method actually converges faster in practice depends on the specific loss landscape, problem conditioning, and computational cost of forming $H^{-1}$, so this should not be read as a general guarantee.
- **Convexity verification**: Checking whether a loss function is convex over a domain can be done by verifying that its Hessian is positive semi-definite everywhere on that domain.
- **Second-order optimization methods**: Quasi-Newton methods (e.g., BFGS, L-BFGS) approximate the Hessian or its inverse to accelerate convergence without computing the full Hessian explicitly.
- **Saddle point identification in deep learning**: [Inference] Some research literature discusses saddle points, rather than local minima, as a significant obstacle in high-dimensional non-convex optimization landscapes such as neural network training, but I do not have access to confirm the current consensus or specific findings on this topic without checking a specific source directly.

### Computational Considerations

- Computing the full Hessian for a function of $n$ variables requires $O(n^2)$ storage and is often computationally expensive for large $n$, which is why many large-scale machine learning optimizers (e.g., SGD, Adam) avoid computing it explicitly.
- [Unverified] Specific implementation details of how any given optimization library computes, approximates, or avoids Hessian computation would require checking that library's documentation directly, since this varies by software and version. No framework-specific behavioral claims are made here.

### Next Steps

- Newton's method and quasi-Newton optimization (BFGS, L-BFGS)
- Convexity, positive semi-definiteness, and optimization landscapes
- Saddle points in high-dimensional non-convex optimization
- Hessian-vector products for efficient second-order computation
- Eigenvalues and eigenvectors as a standalone topic
- Taylor series expansion in multiple variables