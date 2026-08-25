## Jacobian Matrix

### Definition

Given a vector-valued function $\mathbf{f}: \mathbb{R}^n \to \mathbb{R}^m$ that maps a vector $\mathbf{x} = [x_1, \ldots, x_n]^T$ to an output vector $\mathbf{f}(\mathbf{x}) = [f_1(\mathbf{x}), \ldots, f_m(\mathbf{x})]^T$, the Jacobian matrix collects all first-order partial derivatives into a single $m \times n$ matrix:

$$J = \frac{\partial \mathbf{f}}{\partial \mathbf{x}} = \begin{bmatrix} \dfrac{\partial f_1}{\partial x_1} & \dfrac{\partial f_1}{\partial x_2} & \cdots & \dfrac{\partial f_1}{\partial x_n} \\ \dfrac{\partial f_2}{\partial x_1} & \dfrac{\partial f_2}{\partial x_2} & \cdots & \dfrac{\partial f_2}{\partial x_n} \\ \vdots & \vdots & \ddots & \vdots \\ \dfrac{\partial f_m}{\partial x_1} & \dfrac{\partial f_m}{\partial x_2} & \cdots & \dfrac{\partial f_m}{\partial x_n} \end{bmatrix}$$

Each entry is $J_{ij} = \dfrac{\partial f_i}{\partial x_j}$: the rate of change of the $i$-th output with respect to the $j$-th input. Row $i$ of $J$ is the transpose of the gradient $\nabla_{\mathbf{x}} f_i$.

### Relationship to the Gradient

The Jacobian generalizes the gradient of a scalar function. If $m = 1$ (i.e., $\mathbf{f}$ is scalar-valued), the Jacobian reduces to a single row vector, which is the transpose of the gradient:

$$J = (\nabla_{\mathbf{x}} f)^T$$

This is a direct consequence of the definitions and not an inference.

### Key Rules for Common Function Forms

#### Linear Transformation

For $\mathbf{f}(\mathbf{x}) = A\mathbf{x}$, where $A \in \mathbb{R}^{m \times n}$ is a constant matrix:

$$J = A$$

#### Elementwise Function

For $\mathbf{f}(\mathbf{x})$ applied elementwise, i.e., $f_i(\mathbf{x}) = g(x_i)$ for some scalar function $g$:

$$J = \text{diag}(g'(x_1), g'(x_2), \ldots, g'(x_n))$$

The Jacobian is diagonal because each output depends only on the corresponding input.

#### Composition (Chain Rule)

For $\mathbf{f}(\mathbf{x}) = \mathbf{g}(\mathbf{h}(\mathbf{x}))$, where $\mathbf{h}: \mathbb{R}^n \to \mathbb{R}^k$ and $\mathbf{g}: \mathbb{R}^k \to \mathbb{R}^m$:

$$J_{\mathbf{f}} = J_{\mathbf{g}} \, J_{\mathbf{h}}$$

The Jacobian of a composition is the matrix product of the individual Jacobians, evaluated at the appropriate points. This is the multivariate chain rule and is the mathematical basis of backpropagation through multiple layers.

### Summary Table

| Function $\mathbf{f}(\mathbf{x})$ | Jacobian $J$ |
|---|---|
| $A\mathbf{x}$ | $A$ |
| Elementwise $g(x_i)$ | $\text{diag}(g'(x_1), \ldots, g'(x_n))$ |
| $\mathbf{g}(\mathbf{h}(\mathbf{x}))$ | $J_{\mathbf{g}} J_{\mathbf{h}}$ |

### The Jacobian Determinant

When $m = n$ (square Jacobian), the determinant $\det(J)$ is called the Jacobian determinant. It describes the local scaling factor of volume (or area, in 2D) under the transformation $\mathbf{f}$.

$$\det(J) = 0 \implies \text{the transformation is locally non-invertible at that point}$$

This determinant appears directly in the change-of-variables formula for multivariable integration:

$$\int_{\mathbf{f}(\Omega)} g(\mathbf{y}) \, d\mathbf{y} = \int_{\Omega} g(\mathbf{f}(\mathbf{x})) \, |\det(J)| \, d\mathbf{x}$$

### Example

Let $\mathbf{f}: \mathbb{R}^2 \to \mathbb{R}^2$ be defined by:

$$f_1(x_1, x_2) = x_1^2 x_2, \qquad f_2(x_1, x_2) = x_1 + x_2^2$$

The partial derivatives are:

$$\frac{\partial f_1}{\partial x_1} = 2x_1 x_2, \quad \frac{\partial f_1}{\partial x_2} = x_1^2, \quad \frac{\partial f_2}{\partial x_1} = 1, \quad \frac{\partial f_2}{\partial x_2} = 2x_2$$

So the Jacobian is:

$$J = \begin{bmatrix} 2x_1 x_2 & x_1^2 \\ 1 & 2x_2 \end{bmatrix}$$

At the point $(x_1, x_2) = (1, 2)$:

$$J = \begin{bmatrix} 4 & 1 \\ 1 & 4 \end{bmatrix}, \qquad \det(J) = (4)(4) - (1)(1) = 15$$

### Diagram: Jacobian as a Map Between Vector Spaces

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 280">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Jacobian Mapping Between Spaces (svg_diagram)</text>

  <text x="40" y="70" font-size="14" fill="#333">Input space (R^n)</text>
  <rect x="40" y="90" width="140" height="120" fill="#dbe9ff" stroke="#3366cc" stroke-width="1.5" />
  <circle cx="110" cy="150" r="4" fill="#cc0000" />
  <text x="60" y="175" font-size="12" fill="#333">x</text>

  <text x="230" y="150" font-size="14" fill="#333">f(x), J = ∂f/∂x</text>
  <line x1="185" y1="150" x2="400" y2="150" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />

  <text x="440" y="70" font-size="14" fill="#333">Output space (R^m)</text>
  <rect x="440" y="90" width="140" height="120" fill="#e6ffe6" stroke="#339933" stroke-width="1.5" />
  <circle cx="510" cy="150" r="4" fill="#cc0000" />
  <text x="460" y="175" font-size="12" fill="#333">f(x)</text>

  <text x="20" y="250" font-size="12" fill="#555">J is the best local linear approximation of f near x.</text>
  <text x="20" y="268" font-size="12" fill="#555">It maps small perturbations in input space to perturbations in output space.</text>
</svg>

### First-Order (Linear) Approximation

Near a point $\mathbf{x}_0$, the Jacobian provides the best local linear approximation of $\mathbf{f}$:

$$\mathbf{f}(\mathbf{x}) \approx \mathbf{f}(\mathbf{x}_0) + J(\mathbf{x}_0)(\mathbf{x} - \mathbf{x}_0)$$

This is the multivariable generalization of the single-variable first-order Taylor approximation $f(x) \approx f(x_0) + f'(x_0)(x - x_0)$.

### Applications in Machine Learning

- **Backpropagation**: Each layer of a neural network computes a Jacobian (with respect to its inputs and parameters), and the chain rule for Jacobians combines these across layers to compute gradients of a scalar loss with respect to earlier parameters.
- **Change of variables in probability**: The Jacobian determinant appears in the transformation of probability density functions when applying a change of variables (e.g., in normalizing flow models). [Inference] Normalizing flows are commonly described as relying on this identity to keep the transformed distribution valid, but I cannot verify implementation-level details of any specific normalizing flow library without checking its documentation directly.
- **Sensitivity analysis**: The Jacobian quantifies how sensitive a multi-output system's outputs are to small changes in each input, which is used in analyzing model robustness.
- **Newton's method for systems of equations**: Solving $\mathbf{f}(\mathbf{x}) = \mathbf{0}$ iteratively often uses the Jacobian in the update rule $\mathbf{x} \leftarrow \mathbf{x} - J^{-1}\mathbf{f}(\mathbf{x})$, assuming $J$ is invertible at each step.

[Unverified] I do not have access to information confirming how any specific deep learning framework internally computes or caches Jacobians (e.g., whether it forms them explicitly or uses Jacobian-vector products), and behavior in this regard is not guaranteed to be consistent across frameworks or versions. Any such claim would need to be checked against that framework's documentation directly.

### Distinction from the Hessian

The Jacobian contains first-order partial derivatives of a vector-valued function. This is distinct from the Hessian, which contains second-order partial derivatives of a scalar-valued function. [Inference] The Hessian can be understood as the Jacobian of the gradient (i.e., $H = J(\nabla f)$) when $f$ is scalar-valued and twice differentiable, though this framing is a way of relating the two concepts rather than a formal definition found verbatim in every source, and I cannot verify that all references phrase it this exact way.

### Next Steps

- Hessian matrices and second-order optimization
- Chain rule for Jacobians in multi-layer neural networks
- Jacobian-vector products and vector-Jacobian products in automatic differentiation
- Change of variables and the Jacobian determinant in probability
- Newton's method and quasi-Newton optimization methods
- Jacobians in normalizing flow models