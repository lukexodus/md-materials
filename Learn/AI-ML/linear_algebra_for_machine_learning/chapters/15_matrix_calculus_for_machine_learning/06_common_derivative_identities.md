## Common Derivative Identities

### Scalar-by-Scalar Identities

Standard single-variable derivative rules, included here as a foundation for the vector and matrix identities that follow:

| Function | Derivative |
|---|---|
| $c$ (constant) | $0$ |
| $x^n$ | $nx^{n-1}$ |
| $e^x$ | $e^x$ |
| $\ln x$ | $1/x$ |
| $\sin x$ | $\cos x$ |
| $\cos x$ | $-\sin x$ |

These are standard results from single-variable calculus.

### Scalar-by-Vector Identities

For $\mathbf{x} \in \mathbb{R}^n$, $\mathbf{a}, \mathbf{b}$ constant vectors, $A$ a constant matrix:

| Function $f(\mathbf{x})$ | Gradient $\nabla_{\mathbf{x}} f$ |
|---|---|
| $\mathbf{a}^T \mathbf{x}$ | $\mathbf{a}$ |
| $\mathbf{x}^T \mathbf{a}$ | $\mathbf{a}$ |
| $\mathbf{x}^T \mathbf{x}$ | $2\mathbf{x}$ |
| $\mathbf{x}^T A \mathbf{x}$ (general $A$) | $(A + A^T)\mathbf{x}$ |
| $\mathbf{x}^T A \mathbf{x}$ ($A$ symmetric) | $2A\mathbf{x}$ |
| $\|\mathbf{x}\|_2^2$ | $2\mathbf{x}$ |
| $\|A\mathbf{x} - \mathbf{b}\|_2^2$ | $2A^T(A\mathbf{x} - \mathbf{b})$ |
| $\mathbf{a}^T X \mathbf{b}$ (matrix $X$, treating $X$ as variable) | see Scalar-by-Matrix section |

### Vector-by-Vector Identities (Jacobians)

| Function $\mathbf{f}(\mathbf{x})$ | Jacobian $\partial \mathbf{f}/\partial \mathbf{x}$ |
|---|---|
| $A\mathbf{x}$ | $A$ |
| $\mathbf{x}$ | $I$ |
| Elementwise $g(x_i)$ | $\text{diag}(g'(x_1), \ldots, g'(x_n))$ |
| $\mathbf{g}(\mathbf{h}(\mathbf{x}))$ | $J_{\mathbf{g}} J_{\mathbf{h}}$ |

### Scalar-by-Matrix Identities

For $X \in \mathbb{R}^{m \times n}$, $A$ a constant matrix of compatible dimensions:

| Function $f(X)$ | Gradient $\nabla_X f$ |
|---|---|
| $\text{tr}(A^T X)$ | $A$ |
| $\text{tr}(AX)$ | $A^T$ |
| $\text{tr}(X^T A X)$ (general $A$) | $(A + A^T)X$ |
| $\text{tr}(X^T A X)$ ($A$ symmetric) | $2AX$ |
| $\|X\|_F^2$ | $2X$ |
| $\ln \det(X)$ (square, invertible $X$) | $(X^{-1})^T$ |
| $\text{tr}(X)$ | $I$ |
| $\mathbf{a}^T X \mathbf{b}$ | $\mathbf{a}\mathbf{b}^T$ |

The identity $\nabla_X (\mathbf{a}^T X \mathbf{b}) = \mathbf{a}\mathbf{b}^T$ follows from writing $\mathbf{a}^T X \mathbf{b} = \text{tr}(\mathbf{a}^T X \mathbf{b}) = \text{tr}(\mathbf{b}\mathbf{a}^T X)$ and applying the trace-of-linear-form rule above.

### Product Rule Forms

For scalar functions $u(\mathbf{x})$ and $v(\mathbf{x})$:

$$\nabla_{\mathbf{x}} (uv) = u \nabla_{\mathbf{x}} v + v \nabla_{\mathbf{x}} u$$

For a matrix product $f(X) = \text{tr}(A(X) B(X))$, where $A$ and $B$ both depend on $X$:

$$dL = \text{tr}(dA \cdot B) + \text{tr}(A \cdot dB)$$

followed by matching each term to the standard trace-differential form to extract $\nabla_X f$. [Inference] This differential-based product rule is a standard technique in matrix calculus derivations, but the specific algebraic steps required depend on the particular forms of $A(X)$ and $B(X)$ in a given problem, and are not spelled out further here.

### Quotient and Chain Forms

For composite functions, the chain rule (covered in the previous topic) applies:

$$\nabla_{\mathbf{x}} f(g(\mathbf{x})) = f'(g(\mathbf{x})) \, \nabla_{\mathbf{x}} g(\mathbf{x})$$

No separate "quotient rule" table is typically presented in matrix calculus references distinct from combining the product rule with $\nabla(1/v) = -\nabla v / v^2$; [Unverified] I do not have access to confirm whether any specific reference presents a distinct named quotient rule for matrix calculus, so this statement should be treated as a general observation rather than a confirmed claim about all sources.

### Summary Diagram: Identity Categories by Input/Output Type

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Derivative Identity Categories (svg_diagram)</text>

  <rect x="30" y="60" width="160" height="80" fill="#dbe9ff" stroke="#3366cc" stroke-width="1.5" />
  <text x="45" y="90" font-size="12" fill="#222">Scalar by Scalar</text>
  <text x="45" y="110" font-size="11" fill="#333">df/dx</text>

  <rect x="240" y="60" width="160" height="80" fill="#ffe6cc" stroke="#cc6600" stroke-width="1.5" />
  <text x="255" y="90" font-size="12" fill="#222">Scalar by Vector</text>
  <text x="255" y="110" font-size="11" fill="#333">∇x f (gradient)</text>

  <rect x="450" y="60" width="160" height="80" fill="#e6ffe6" stroke="#339933" stroke-width="1.5" />
  <text x="465" y="90" font-size="12" fill="#222">Vector by Vector</text>
  <text x="465" y="110" font-size="11" fill="#333">∂f/∂x (Jacobian)</text>

  <rect x="240" y="180" width="160" height="80" fill="#f0d9ff" stroke="#8833cc" stroke-width="1.5" />
  <text x="255" y="210" font-size="12" fill="#222">Scalar by Matrix</text>
  <text x="255" y="230" font-size="11" fill="#333">∇X f</text>

  <text x="20" y="290" font-size="12" fill="#555">Each category has its own identity table above; shapes must always match.</text>
</svg>

### Verification Approach: Dimension Checking

A practical way to check whether a derivative identity is plausible (though not a proof of correctness) is to verify that the shapes match:

- $\nabla_{\mathbf{x}} f$ must have the same shape as $\mathbf{x}$.
- $\nabla_X f$ must have the same shape as $X$.
- The Jacobian $\partial \mathbf{f}/\partial \mathbf{x}$ must have shape (output dimension) × (input dimension).

[Inference] Dimension checking is a widely used sanity check in applying matrix calculus identities, but it only rules out shape-inconsistent errors — it does not confirm that an identity is numerically correct, so it should be treated as a partial check rather than full verification.

### Example: Applying Multiple Identities Together

Let $f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x} + \mathbf{b}^T \mathbf{x} + c$, where $A$ is symmetric, $\mathbf{b}$ is a constant vector, and $c$ is a constant scalar. This is the general quadratic form.

Applying identities term by term:

$$\nabla_{\mathbf{x}} (\mathbf{x}^T A \mathbf{x}) = 2A\mathbf{x}, \qquad \nabla_{\mathbf{x}} (\mathbf{b}^T \mathbf{x}) = \mathbf{b}, \qquad \nabla_{\mathbf{x}} (c) = \mathbf{0}$$

So:

$$\nabla_{\mathbf{x}} f = 2A\mathbf{x} + \mathbf{b}$$

Setting this to zero and solving gives the critical point $\mathbf{x}^* = -\dfrac{1}{2}A^{-1}\mathbf{b}$, assuming $A$ is invertible. This is the closed-form solution used in deriving results such as the normal equations in linear regression.

### Applications in Machine Learning

- **Linear and ridge regression**: Closed-form solutions rely directly on the quadratic form gradient identity above.
- **Backpropagation**: Layer-wise gradients in neural networks are built by combining these identities (linear transformation Jacobians, elementwise activation Jacobians, and the chain rule) repeatedly.
- **Regularization terms**: L2 penalties use the $\|X\|_F^2$ or $\|\mathbf{x}\|_2^2$ identities directly.
- **Maximum likelihood estimation**: The log-determinant identity appears in derivations involving Gaussian log-likelihoods with respect to covariance matrices.

[Inference] These identities are commonly presented together as a reference set in machine learning-oriented matrix calculus material, but I do not have access to confirm that any single canonical source lists exactly this set, so this should be read as a practical compilation rather than a verified reproduction of one specific reference.

### Behavioral Disclaimer

[Unverified] Any claim about how a specific software library (e.g., NumPy, PyTorch, JAX, symbolic algebra systems) implements or verifies these identities internally would require checking that library's documentation directly. Library behavior may vary and is not confirmed here.

### Next Steps

- The Matrix Cookbook as a comprehensive identity reference
- Differentials and the trace trick: full derivation method
- Kronecker product and vectorization identities
- Second-order identities: Hessians of common forms
- Applying these identities in a full backpropagation derivation
- Numerical gradient checking to verify analytical identities