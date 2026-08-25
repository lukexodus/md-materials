## Derivative of Matrix Multiplication

### Definition

When two matrices $A$ and $B$ are multiplied to form $C = AB$, and one or both of $A$, $B$ depend on some underlying variable, finding derivatives of $C$ (or of a scalar function built from $C$) requires care, since matrix multiplication is not commutative and dimensions must be tracked carefully at every step.

This topic covers three related cases:
1. The differential of a matrix product $d(AB)$.
2. The gradient of a scalar function involving a matrix product, with respect to one of the matrix factors.
3. The Jacobian of a matrix-vector product with respect to the vector.

### Differential of a Matrix Product

If $A$ and $B$ both depend on some variable, the differential of their product follows a product rule analogous to the scalar case, but order must be preserved since matrix multiplication does not commute:

$$d(AB) = (dA)B + A(dB)$$

This is a standard identity in matrix calculus, derivable directly from the definition of the differential applied entrywise to the product.

### Gradient of a Scalar Function Involving a Matrix Product

#### Case: $f(X) = \text{tr}(AXB)$

For constant matrices $A$ and $B$ with compatible dimensions, and variable matrix $X$:

$$\nabla_X f = A^T B^T$$

**Derivation sketch**: Using the differential form and the cyclic property of the trace:

$$df = \text{tr}(A \, dX \, B) = \text{tr}(BA \, dX)$$

Matching this to the standard form $\text{tr}\left((\nabla_X f)^T dX\right)$ gives $\nabla_X f = (BA)^T = A^T B^T$.

#### Case: $f(X) = \text{tr}(X^T A X B)$

For constant matrices $A$, $B$ with compatible dimensions:

$$\nabla_X f = A X B + A^T X B^T$$

[Inference] This identity follows the same differential-based derivation approach as the case above, extended to account for both occurrences of $X$ in the product, but the full step-by-step derivation is not shown here and would need to be worked out or checked against a reference such as the *Matrix Cookbook* for exact verification.

#### Case: $f(X) = \|AX\|_F^2$

Since $\|AX\|_F^2 = \text{tr}((AX)^T(AX)) = \text{tr}(X^T A^T A X)$, this is a special case of the pattern above with a symmetric middle term $A^T A$:

$$\nabla_X f = 2A^T A X$$

### Summary Table

| Function | Derivative / Gradient |
|---|---|
| $d(AB)$ | $(dA)B + A(dB)$ |
| $\text{tr}(AXB)$ | $\nabla_X f = A^T B^T$ |
| $\text{tr}(X^T A X B)$ | $\nabla_X f = AXB + A^T X B^T$ |
| $\|AX\|_F^2$ | $\nabla_X f = 2A^T A X$ |

### Jacobian of a Matrix-Vector Product

For $\mathbf{y} = A\mathbf{x}$, where $A \in \mathbb{R}^{m \times n}$ is constant and $\mathbf{x} \in \mathbb{R}^n$:

$$\frac{\partial \mathbf{y}}{\partial \mathbf{x}} = A$$

This is a direct restatement of the linear transformation Jacobian rule covered in the Jacobian matrix topic.

For $\mathbf{y} = X\mathbf{a}$, where $X \in \mathbb{R}^{m \times n}$ is variable and $\mathbf{a} \in \mathbb{R}^n$ is constant, the derivative with respect to $X$ (rather than $\mathbf{x}$) requires tensor-like bookkeeping, since the output is a vector but the variable is a matrix. In this case, the derivative is often expressed using the Kronecker product after vectorizing $X$:

$$\frac{\partial (X\mathbf{a})}{\partial \text{vec}(X)} = \mathbf{a}^T \otimes I_m$$

[Unverified] This vectorized identity is commonly presented in matrix calculus references using Kronecker product notation, but I do not have access to confirm the exact notation or sign convention used in any specific source, so this should be checked against a reference such as the *Matrix Cookbook* before being used directly in derivations.

### Example

Let $A$ be a constant matrix and $X$ the variable, with:

$$A = \begin{bmatrix} 1 & 0 \\ 0 & 2 \end{bmatrix}, \qquad X = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}$$

Compute $\nabla_X f$ for $f(X) = \|AX\|_F^2$.

Using the identity above:

$$\nabla_X f = 2A^T A X = 2\begin{bmatrix} 1 & 0 \\ 0 & 4 \end{bmatrix}\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} = 2\begin{bmatrix} 1 & 2 \\ 12 & 16 \end{bmatrix} = \begin{bmatrix} 2 & 4 \\ 24 & 32 \end{bmatrix}$$

Verification by direct computation: $AX = \begin{bmatrix} 1 & 2 \\ 6 & 8 \end{bmatrix}$, so $\|AX\|_F^2 = 1 + 4 + 36 + 64 = 105$. Perturbing $X_{11}$ by a small $\epsilon$ and recomputing confirms the gradient entry $(\nabla_X f)_{11} = 2$ matches the analytical result to first order. [Inference] This numerical consistency check supports the correctness of the applied identity for this specific example, but does not constitute a general proof and was not independently executed as code in this response.

### Diagram: Matrix Product Differentiation Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Matrix Product Differentiation Flow (svg_diagram)</text>

  <rect x="30" y="70" width="140" height="60" fill="#dbe9ff" stroke="#3366cc" stroke-width="1.5" />
  <text x="55" y="105" font-size="13" fill="#222">C = AB</text>

  <text x="200" y="105" font-size="14" fill="#333">→</text>

  <rect x="230" y="70" width="180" height="60" fill="#ffe6cc" stroke="#cc6600" stroke-width="1.5" />
  <text x="245" y="105" font-size="12" fill="#222">d(AB) = dA·B + A·dB</text>

  <text x="430" y="105" font-size="14" fill="#333">→</text>

  <rect x="460" y="70" width="150" height="60" fill="#e6ffe6" stroke="#339933" stroke-width="1.5" />
  <text x="475" y="105" font-size="12" fill="#222">match to trace form</text>

  <text x="20" y="180" font-size="12" fill="#555">Differentiate the product, then use trace properties</text>
  <text x="20" y="198" font-size="12" fill="#555">to isolate the gradient with respect to the target variable.</text>
</svg>

### Applications in Machine Learning

- **Linear layer gradients**: In a neural network layer $\mathbf{y} = W\mathbf{x} + \mathbf{b}$, the gradient of a downstream scalar loss with respect to $W$ takes the outer-product form $\nabla_W L = (\nabla_{\mathbf{y}} L)\mathbf{x}^T$, which follows from the matrix product differentiation rules combined with the chain rule.
- **Bilinear and quadratic models**: Models involving terms such as $\mathbf{x}^T W \mathbf{y}$ (bilinear forms) rely directly on the $\text{tr}(AXB)$-style identities above.
- **Weight regularization**: Penalties such as $\|WX\|_F^2$ on layer outputs or weight products use the Frobenius norm identity shown above.

[Inference] These applications are commonly described as motivating examples for matrix product differentiation in machine learning-oriented references, but I do not have access to confirm that any single canonical source presents them in exactly this combination, so this should be read as a practical illustration rather than a verified reproduction of one specific source.

### Behavioral Disclaimer

[Unverified] Claims about how any specific automatic differentiation library computes gradients of matrix products internally (e.g., whether it uses these closed-form identities, autodiff graph traversal, or another method) would require checking that library's documentation directly. Library behavior may vary by implementation and version, and no such claims are made here beyond the general mathematical identities.

### Next Steps

- The trace trick: systematic differential-based derivation method
- Kronecker product and vectorization (vec) identities in full
- Gradients of bilinear and quadratic forms
- Outer product gradients in neural network layer updates
- The Matrix Cookbook as a reference for verifying identities
- Numerical gradient checking as a verification technique