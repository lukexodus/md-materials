## Derivative of Quadratic Forms

### Definition

A quadratic form is a scalar-valued function of a vector $\mathbf{x} \in \mathbb{R}^n$ defined by:

$$f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x} = \sum_{i=1}^n \sum_{j=1}^n A_{ij} x_i x_j$$

where $A \in \mathbb{R}^{n \times n}$ is a constant matrix. This section covers the gradient and Hessian of this function, along with related forms.

### Gradient of the General Quadratic Form

For $f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x}$, with $A$ not necessarily symmetric:

$$\nabla_{\mathbf{x}} f = (A + A^T)\mathbf{x}$$

**Derivation sketch**: Writing $f(\mathbf{x}) = \sum_{i,j} A_{ij} x_i x_j$ and differentiating with respect to a single component $x_k$:

$$\frac{\partial f}{\partial x_k} = \sum_j A_{kj} x_j + \sum_i A_{ik} x_i = (A\mathbf{x})_k + (A^T \mathbf{x})_k$$

Collecting all components into vector form gives $\nabla_{\mathbf{x}} f = A\mathbf{x} + A^T\mathbf{x} = (A + A^T)\mathbf{x}$.

### Gradient When $A$ Is Symmetric

If $A = A^T$, the general result simplifies:

$$\nabla_{\mathbf{x}} f = 2A\mathbf{x}$$

This case is common in practice, since many quadratic forms encountered in optimization (e.g., those built from covariance or Gram matrices) are symmetric by construction.

### Hessian of the Quadratic Form

Differentiating the gradient a second time:

$$H = \nabla^2_{\mathbf{x}} f = A + A^T$$

or, if $A$ is symmetric:

$$H = 2A$$

Note that the Hessian of a quadratic form is constant — it does not depend on $\mathbf{x}$. This reflects the fact that $f$ is a degree-2 polynomial in $\mathbf{x}$, so its second derivative is constant, consistent with single-variable calculus (where the second derivative of $x^2$ is a constant).

### Summary Table

| Quantity | General $A$ | Symmetric $A$ |
|---|---|---|
| $f(\mathbf{x})$ | $\mathbf{x}^T A \mathbf{x}$ | $\mathbf{x}^T A \mathbf{x}$ |
| $\nabla_{\mathbf{x}} f$ | $(A + A^T)\mathbf{x}$ | $2A\mathbf{x}$ |
| $H$ | $A + A^T$ | $2A$ |

### Special Case: Squared Euclidean Norm

Setting $A = I$ gives $f(\mathbf{x}) = \mathbf{x}^T \mathbf{x} = \|\mathbf{x}\|_2^2$:

$$\nabla_{\mathbf{x}} f = 2\mathbf{x}, \qquad H = 2I$$

### Special Case: Least Squares Objective

For $f(\mathbf{x}) = \|A\mathbf{x} - \mathbf{b}\|_2^2$, expanding gives:

$$f(\mathbf{x}) = \mathbf{x}^T A^T A \mathbf{x} - 2\mathbf{b}^T A \mathbf{x} + \mathbf{b}^T \mathbf{b}$$

This is a quadratic form in $\mathbf{x}$ with matrix $A^T A$ (symmetric), plus a linear term and a constant. Applying the identities above term by term:

$$\nabla_{\mathbf{x}} f = 2A^T A \mathbf{x} - 2A^T \mathbf{b} = 2A^T(A\mathbf{x} - \mathbf{b})$$

$$H = 2A^T A$$

Setting $\nabla_{\mathbf{x}} f = \mathbf{0}$ and solving yields the normal equations $A^T A \mathbf{x} = A^T \mathbf{b}$, the closed-form solution to ordinary least squares (assuming $A^T A$ is invertible).

### Definiteness and Convexity

The behavior of a quadratic form is determined by the definiteness of $A$ (or its symmetric part $\frac{1}{2}(A + A^T)$):

| Definiteness of $A$ | Shape of $f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x}$ | Convexity |
|---|---|---|
| Positive definite | Bowl-shaped, minimum at $\mathbf{x}=\mathbf{0}$ | Strictly convex |
| Positive semi-definite | Bowl-shaped, flat in some directions | Convex |
| Negative definite | Dome-shaped, maximum at $\mathbf{x}=\mathbf{0}$ | Strictly concave |
| Indefinite | Saddle-shaped | Neither convex nor concave |

This classification follows directly from the sign of the Hessian eigenvalues, consistent with the general second-derivative test for critical points.

### Example

Let:

$$A = \begin{bmatrix} 3 & 1 \\ 1 & 2 \end{bmatrix}$$

which is symmetric. Then $f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x} = 3x_1^2 + 2x_1x_2 + 2x_2^2$.

Gradient:

$$\nabla_{\mathbf{x}} f = 2A\mathbf{x} = \begin{bmatrix} 6x_1 + 2x_2 \\ 2x_1 + 4x_2 \end{bmatrix}$$

Hessian:

$$H = 2A = \begin{bmatrix} 6 & 2 \\ 2 & 4 \end{bmatrix}$$

Eigenvalues of $H$ satisfy $(6-\lambda)(4-\lambda) - 4 = 0 \implies \lambda^2 - 10\lambda + 20 = 0 \implies \lambda = 5 \pm \sqrt{5}$.

Both eigenvalues are positive ($\lambda \approx 7.24$ and $\lambda \approx 2.76$), so $H$ is positive definite, and $f$ is strictly convex with a unique global minimum at $\mathbf{x} = \mathbf{0}$.

### Diagram: Quadratic Form Surface Shapes by Definiteness

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 660 240">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Quadratic Form Shapes by Definiteness (svg_diagram)</text>

  <text x="30" y="60" font-size="13" fill="#333">Positive Definite</text>
  <path d="M 10 150 Q 90 80 170 150" fill="none" stroke="#339933" stroke-width="2" />
  <circle cx="90" cy="140" r="3" fill="#339933" />
  <text x="30" y="180" font-size="11" fill="#555">unique minimum</text>

  <text x="250" y="60" font-size="13" fill="#333">Negative Definite</text>
  <path d="M 230 90 Q 310 160 390 90" fill="none" stroke="#cc3333" stroke-width="2" />
  <circle cx="310" cy="130" r="3" fill="#cc3333" />
  <text x="250" y="180" font-size="11" fill="#555">unique maximum</text>

  <text x="470" y="60" font-size="13" fill="#333">Indefinite</text>
  <path d="M 450 150 Q 530 100 610 150" fill="none" stroke="#cc8800" stroke-width="2" />
  <path d="M 490 110 Q 530 150 570 110" fill="none" stroke="#cc8800" stroke-width="2" stroke-dasharray="4,3" />
  <text x="470" y="200" font-size="11" fill="#555">saddle point</text>
</svg>

### Applications in Machine Learning

- **Ordinary least squares regression**: The normal equations derivation depends directly on the gradient and Hessian of the least squares quadratic form shown above.
- **Ridge regression**: Adding an L2 penalty $\lambda \|\mathbf{x}\|_2^2$ modifies the objective to $\|A\mathbf{x} - \mathbf{b}\|_2^2 + \lambda \|\mathbf{x}\|_2^2$, a quadratic form with matrix $A^TA + \lambda I$, which is positive definite whenever $\lambda > 0$, guaranteeing (in the mathematical sense of a formal proof, not as a general claim about all software behavior) a unique minimizer.
- **Support vector machines**: The dual optimization problem in SVMs involves a quadratic form in the Lagrange multipliers, whose positive semi-definiteness (via the kernel matrix) relates to the convexity of the optimization problem.
- **Second-order optimization**: Newton's method locally models a general nonlinear objective as a quadratic form using its Hessian, then jumps to the minimum of that local quadratic approximation.

[Inference] These applications are commonly presented together as illustrative connections between quadratic form theory and machine learning optimization, but I do not have access to confirm that any single canonical source presents them in exactly this combination, so this should be read as a practical illustration rather than a verified reproduction of one specific source.

### Behavioral Disclaimer

[Unverified] Claims about how any specific optimization library or solver numerically handles quadratic form minimization (e.g., choice of algorithm, numerical stability safeguards) would require checking that library's documentation directly. Library behavior may vary by implementation and version, and no such claims are made here beyond the general mathematical theory.

### Next Steps

- Positive definiteness: formal tests and criteria
- Convex optimization theory and quadratic programming
- Ridge regression derivation in full
- Support vector machines and the dual quadratic program
- Newton's method as local quadratic approximation
- Eigenvalues and eigenvectors as a standalone topic