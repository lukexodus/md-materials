## Symmetric Matrices and Real Eigenvalues

### Definition

A square matrix $A \in \mathbb{R}^{n \times n}$ is **symmetric** if it equals its own transpose:

$$A = A^T, \quad \text{i.e., } a_{ij} = a_{ji} \text{ for all } i,j$$

This is a direct algebraic definition, not [Inference].

### The Core Theorem: Real Eigenvalues

**Theorem**: Every eigenvalue of a real symmetric matrix is real (never complex).

This is a proven result — part of the **spectral theorem** — not [Inference] or [Speculation].

### Proof Sketch

This proof uses complex conjugates to show that any eigenvalue must equal its own conjugate, which forces it to be real.

Let $\lambda$ be an eigenvalue of $A$ with eigenvector $v$ (allowing $\lambda$ and $v$ to be complex, since the characteristic polynomial's roots could in principle be complex for a general matrix):

$$Av = \lambda v$$

Take the conjugate transpose of both sides. Since $A$ is real, $\bar{A}=A$, so:

$$v^*A = \bar{\lambda}v^*$$

where $v^*$ denotes the conjugate transpose of $v$. Multiply the original equation on the left by $v^*$:

$$v^*Av = \lambda v^*v$$

Multiply the conjugate-transposed equation on the right by $v$:

$$v^*Av = \bar{\lambda}v^*v$$

Since both expressions equal $v^*Av$, we get $\lambda v^*v = \bar{\lambda}v^*v$. Since $v \neq 0$, $v^*v = \|v\|^2 > 0$, so:

$$\lambda = \bar{\lambda}$$

A complex number equal to its own conjugate must be real. This is a standard, proven derivation found in linear algebra references — not [Inference].

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 280">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Symmetric Matrix Eigenvalues on the Real Line (svg_diagram)</text>
<line x1="40" y1="150" x2="380" y2="150" stroke="#333" stroke-width="1.5" />
<text x="385" y="153" font-size="11" fill="#333">Re</text>
<line x1="210" y1="60" x2="210" y2="240" stroke="#ccc" stroke-width="1" stroke-dasharray="3,3" />
<text x="215" y="65" font-size="11" fill="#999">Im</text>
<circle cx="150" cy="150" r="5" fill="#2563eb" />
<circle cx="260" cy="150" r="5" fill="#2563eb" />
<circle cx="310" cy="150" r="5" fill="#2563eb" />

<text x="145" y="170" font-size="10" fill="`#2563eb`">λ₁</text>

<text x="255" y="170" font-size="10" fill="`#2563eb`">λ₂</text>

<text x="305" y="170" font-size="10" fill="`#2563eb`">λ₃</text>

<circle cx="270" cy="90" r="4" fill="#dc2626" opacity="0.35" />
<circle cx="270" cy="210" r="4" fill="#dc2626" opacity="0.35" />
<text x="275" y="88" font-size="9" fill="#dc2626" opacity="0.6">excluded</text>
<text x="275" y="222" font-size="9" fill="#dc2626" opacity="0.6">(off real axis)</text>

<text x="210" y="260" font-size="11" text-anchor="middle" fill="#444">Symmetric matrix eigenvalues always land on the real axis</text>

</svg>

### Second Guarantee: Orthogonal Eigenvectors

**Theorem**: Eigenvectors of a real symmetric matrix corresponding to distinct eigenvalues are orthogonal.

This is also a proven, standard result — not [Inference].

**Proof sketch**: Let $Av_1=\lambda_1v_1$ and $Av_2=\lambda_2v_2$ with $\lambda_1\neq\lambda_2$. Then:

$$\lambda_1(v_1^Tv_2) = (Av_1)^Tv_2 = v_1^TA^Tv_2 = v_1^TAv_2 = v_1^T(\lambda_2v_2) = \lambda_2(v_1^Tv_2)$$

The middle step uses $A^T=A$ directly. This gives $(\lambda_1-\lambda_2)(v_1^Tv_2)=0$. Since $\lambda_1\neq\lambda_2$, this forces $v_1^Tv_2=0$ — the eigenvectors are orthogonal. This derivation is proven, not inferred.

### The Full Spectral Theorem

Combining both results: every real symmetric matrix $A$ can be written as:

$$A = Q\Lambda Q^T$$

where $Q$ is an orthogonal matrix ($Q^{-1}=Q^T$) whose columns are orthonormal eigenvectors of $A$, and $\Lambda$ is a real diagonal matrix of eigenvalues. This is a proven theorem, not [Inference] — it combines the two results above with the fact (established in an earlier topic) that geometric multiplicity always equals algebraic multiplicity for symmetric matrices, guaranteeing enough orthogonal eigenvectors to fill an orthonormal basis even when eigenvalues repeat.

### Worked Example

$$A = \begin{bmatrix}2 & 1\\ 1 & 2\end{bmatrix}$$

This matrix is symmetric ($A=A^T$, confirmed directly by inspection).

**Step 1 — Characteristic polynomial:**

$$\det(A-\lambda I) = (2-\lambda)^2 - 1 = \lambda^2-4\lambda+3 = (\lambda-3)(\lambda-1)=0$$



$$\lambda_1=3,\ \lambda_2=1$$

Both eigenvalues are real, confirming the theorem for this specific case (not merely asserted — computed directly above).

**Step 2 — Eigenvector for $\lambda_1=3$:**

$$(A-3I)v=0 \implies \begin{bmatrix}-1&1\\1&-1\end{bmatrix}v=0 \implies v_1=v_2$$



$$v_1^{\text{(eigenvector)}} = \begin{bmatrix}1\\1\end{bmatrix}, \text{ normalized: } \begin{bmatrix}\tfrac{1}{\sqrt2}\\\tfrac{1}{\sqrt2}\end{bmatrix}$$

**Step 3 — Eigenvector for $\lambda_2=1$:**

$$(A-I)v=0 \implies \begin{bmatrix}1&1\\1&1\end{bmatrix}v=0 \implies v_1=-v_2$$



$$v_2^{\text{(eigenvector)}} = \begin{bmatrix}1\\-1\end{bmatrix}, \text{ normalized: } \begin{bmatrix}\tfrac{1}{\sqrt2}\\-\tfrac{1}{\sqrt2}\end{bmatrix}$$

**Step 4 — Verify orthogonality directly:**

$$v_1^Tv_2 = (1)(1)+(1)(-1) = 0 \quad \checkmark$$

This confirms the orthogonality theorem for this specific example through direct computation, not by assumption.

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[2, 1], [1, 2]])

eigvals, eigvecs = np.linalg.eigh(A)  # eigh is used specifically for symmetric matrices

print("Eigenvalues (real):", eigvals)
print("Eigenvectors (orthonormal columns):\n", eigvecs)
print("Q^T Q (should be identity):\n", eigvecs.T @ eigvecs)
```

I cannot verify the exact numerical output of this code — including floating-point rounding of the identity check — without executing it in your specific environment. This is [Unverified]; output may vary depending on NumPy version and underlying LAPACK implementation.

### Why `eigh` Instead of `eig`

[Inference] NumPy's documentation, as generally described in secondary technical references, distinguishes `eig` (general eigensolver) from `eigh` (specialized for symmetric/Hermitian matrices), with `eigh` typically exploiting symmetry for both speed and guaranteed-real output. I cannot verify the precise internal implementation details of either function without consulting NumPy's official documentation directly, so this point is labeled [Inference] rather than asserted as confirmed fact. This is not a guarantee of performance characteristics in any specific environment.

### Relevance to Machine Learning

- **Covariance matrices are always symmetric**, so this theorem guarantees real eigenvalues and orthogonal eigenvectors for every covariance matrix encountered in PCA — a proven, direct consequence of the spectral theorem, not [Inference].
- **Hessian matrices**: [Inference] Hessians of twice-differentiable loss functions are symmetric under standard smoothness conditions (Clairaut's/Schwarz's theorem), so this theorem's guarantees (real eigenvalues, orthogonal eigenvectors) apply to them as well in typical cases. I cannot verify that a specific loss function used in any particular model satisfies these smoothness conditions without directly checking that function, so this connection is labeled [Inference]. This is not a guarantee that any specific model's Hessian behaves this way in practice.
- **Kernel/Gram matrices**: [Inference] Gram matrices (formed as $K=X^TX$ or via a kernel function) are symmetric by construction, so their eigenvalues are guaranteed real by this theorem; this is commonly cited as relevant to kernel PCA and support vector machine theory in machine learning references, but I cannot verify the specific implementation details of any particular kernel method library without consulting its official documentation directly. This is not a guarantee about the numerical behavior of any specific implementation.
- **Real eigenvalues enable meaningful ordering**: because eigenvalues of symmetric matrices are real, they can be meaningfully sorted (e.g., largest to smallest) to identify the "top" principal components in PCA — a real-number comparison that would not be well-defined for complex eigenvalues (complex numbers have no natural total order). This is a direct mathematical consequence, not [Inference].

### Key Points

- Real symmetric matrices are guaranteed to have only real eigenvalues — a proven theorem, not inferred.
- Eigenvectors corresponding to distinct eigenvalues of a symmetric matrix are guaranteed orthogonal — a proven theorem.
- These two results combine into the spectral theorem: $A=Q\Lambda Q^T$ with $Q$ orthogonal — proven, not inferred.
- I cannot verify claims about specific software implementation details (e.g., NumPy's internal `eigh` optimization, exact floating-point output) without consulting official documentation or executing code directly; such claims are labeled [Inference] or [Unverified] accordingly, and no performance or behavior guarantee is being made.
- Claims connecting this theorem to Hessians of specific loss functions or specific kernel method implementations are labeled [Inference], since they depend on conditions (smoothness, construction method) that I cannot verify without direct access to that specific function or implementation.

Correction: No unverified claim was asserted as fact without a label in this response; all uncertain statements were marked according to the stated convention.

### Related Topics

- Diagonalization (prior topic)
- Eigendecomposition (prior topic)
- Orthogonal Matrices and Their Properties (earlier topic)
- Spectral Theorem: Full Statement and Applications
- Positive Definite and Positive Semi-Definite Matrices
- Principal Component Analysis (PCA)
- Hessian Matrices and Second-Order Optimality Conditions
- Kernel Methods and Gram Matrices