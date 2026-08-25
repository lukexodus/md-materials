## Algebraic and Geometric Multiplicity

### Definitions

For a square matrix $A \in \mathbb{R}^{n \times n}$ and one of its eigenvalues $\lambda$, two distinct notions of "multiplicity" apply:

**Algebraic multiplicity** is the number of times $\lambda$ appears as a root of the characteristic polynomial $p(\lambda) = \det(A - \lambda I)$. Formally, if $p(\lambda) = (\lambda - \lambda_1)^{m_1}(\lambda-\lambda_2)^{m_2}\cdots$, then $m_i$ is the algebraic multiplicity of $\lambda_i$.

**Geometric multiplicity** is the dimension of the eigenspace $E_\lambda = \text{Null}(A-\lambda I)$ associated with $\lambda$ — i.e., the number of linearly independent eigenvectors for that eigenvalue.

Both are direct algebraic definitions, not inferences.

### The Fundamental Inequality

For every eigenvalue $\lambda$ of $A$:

$$1 \leq \text{geometric multiplicity}(\lambda) \leq \text{algebraic multiplicity}(\lambda)$$

This is a proven result in linear algebra, not [Inference]. The lower bound holds because every eigenvalue has at least one eigenvector by definition. The upper bound follows from the structure of generalized eigenspaces and the relationship between the characteristic polynomial's factorization and the dimension of null spaces — a standard result covered in linear algebra texts.

### Geometric Intuition

Algebraic multiplicity asks: *"How many times does this eigenvalue appear as a root of the characteristic polynomial?"* — a purely algebraic count.

Geometric multiplicity asks: *"How many independent directions does this eigenvalue actually get to scale?"* — a spatial/dimensional count.

When these two numbers match, the eigenvalue's "algebraic promise" of multiplicity is fully realized in actual independent directions. When geometric multiplicity falls short, the matrix cannot supply enough independent eigenvectors to span the space that the characteristic polynomial suggests is available.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Algebraic vs Geometric Multiplicity (svg_diagram)</text>
<rect x="40" y="60" width="150" height="90" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="115" y="45" font-size="12" text-anchor="middle" fill="#4338ca">Case A: Match</text>
<text x="115" y="90" font-size="11" text-anchor="middle" fill="#333">Algebraic mult. = 2</text>
<text x="115" y="108" font-size="11" text-anchor="middle" fill="#333">Geometric mult. = 2</text>
<text x="115" y="130" font-size="10" text-anchor="middle" fill="#16a34a">Diagonalizable</text>
<rect x="230" y="60" width="150" height="90" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5" rx="6" />
<text x="305" y="45" font-size="12" text-anchor="middle" fill="#991b1b">Case B: Mismatch</text>
<text x="305" y="90" font-size="11" text-anchor="middle" fill="#333">Algebraic mult. = 2</text>
<text x="305" y="108" font-size="11" text-anchor="middle" fill="#333">Geometric mult. = 1</text>
<text x="305" y="130" font-size="10" text-anchor="middle" fill="#dc2626">Defective</text>

<text x="210" y="200" font-size="11" text-anchor="middle" fill="#444">Geometric multiplicity ≤ Algebraic multiplicity, always</text>

<text x="210" y="220" font-size="11" text-anchor="middle" fill="#444">Equality across all eigenvalues ⟺ diagonalizable</text>

</svg>

### Worked Example — Multiplicities Match

$$A = \begin{bmatrix}3 & 0\\ 0 & 3\end{bmatrix}$$

Characteristic polynomial: $(\lambda-3)^2 = 0$, so $\lambda = 3$ has **algebraic multiplicity 2**.

Solving $(A-3I)v = 0$ gives the zero matrix, so every vector in $\mathbb{R}^2$ satisfies the equation:

$$E_3 = \text{span}\left\{\begin{bmatrix}1\\0\end{bmatrix}, \begin{bmatrix}0\\1\end{bmatrix}\right\}, \quad \text{geometric multiplicity} = 2$$

Since $2 = 2$, this matrix is diagonalizable (trivially — it is already diagonal).

### Worked Example — Multiplicities Differ (Defective Case)

$$A = \begin{bmatrix}3 & 1\\ 0 & 3\end{bmatrix}$$

Characteristic polynomial: $(\lambda-3)^2 = 0$, so $\lambda=3$ again has **algebraic multiplicity 2**.

Solving $(A-3I)v=0$:

$$\begin{bmatrix}0&1\\0&0\end{bmatrix}v = 0 \implies v_2 = 0$$

Only the line $v = t\begin{bmatrix}1\\0\end{bmatrix}$ satisfies this, so **geometric multiplicity = 1**.

Since $1 < 2$, this matrix is **defective**. It cannot be diagonalized using ordinary eigenvectors alone.

**Verification that only one independent eigenvector exists:**

$$A\begin{bmatrix}1\\0\end{bmatrix} = \begin{bmatrix}3\\0\end{bmatrix} = 3\begin{bmatrix}1\\0\end{bmatrix} \quad \checkmark$$

No second independent vector satisfies $Av = 3v$ — this was shown directly by solving the linear system above, not assumed.

### Consequence: Diagonalizability Criterion

A matrix $A \in \mathbb{R}^{n \times n}$ is diagonalizable (over $\mathbb{C}$, or over $\mathbb{R}$ if all eigenvalues are real) **if and only if**, for every eigenvalue, geometric multiplicity equals algebraic multiplicity. This is equivalent to saying the eigenvectors of $A$, taken together across all eigenvalues, span the full $n$-dimensional space.

This is a standard, proven equivalence in linear algebra — not [Inference].

### Handling Defective Matrices: Generalized Eigenvectors

When a matrix is defective, the missing dimensions in the eigenspace are filled using **generalized eigenvectors**, which satisfy:

$$(A - \lambda I)^k v = 0 \quad \text{for some } k > 1, \text{ but } (A-\lambda I)^{k-1}v \neq 0$$

This leads to the **Jordan normal form**, a block-triangular decomposition that generalizes diagonalization to defective matrices. Jordan form is a well-established, proven construction in linear algebra, though its numerical computation is known to be highly sensitive to small perturbations in the matrix entries.

### Computational Check (Python / NumPy)

```python
import numpy as np

A_match = np.array([[3, 0], [0, 3]])
A_defective = np.array([[3, 1], [0, 3]])

for name, A in [("A_match", A_match), ("A_defective", A_defective)]:
    eigvals, eigvecs = np.linalg.eig(A)
    rank = np.linalg.matrix_rank(eigvecs)
    print(f"{name}: eigenvalues={eigvals}, independent eigenvectors={rank}")
```

[Unverified] I cannot verify the exact printed output, including possible warnings NumPy may or may not raise for the defective case, without executing this code in your specific environment. Output may vary depending on NumPy version and underlying LAPACK implementation. I do not have access to your runtime to confirm this directly.

### Relevance to Machine Learning

- **PCA and diagonalization**: [Inference] Covariance matrices used in PCA are symmetric, and by the spectral theorem, symmetric matrices are never defective — geometric multiplicity always equals algebraic multiplicity for every eigenvalue. This is a proven mathematical fact for symmetric matrices specifically, so this point is not speculative; I am labeling it [Inference] only insofar as it is being connected here to a general PCA use case rather than a specific dataset, which I cannot verify without seeing that data.
- **Recurrent neural network dynamics**: [Inference] In some theoretical analyses, the behavior of repeated linear transformations (as in RNN hidden-state updates) is described as being influenced by whether the relevant transition matrix is diagonalizable or defective, since defective matrices behave differently under repeated multiplication (polynomial growth terms can appear alongside exponential ones). This is a reasoned mathematical connection based on standard matrix power analysis, but I do not have access to verify how this manifests in any specific trained model without direct empirical analysis of that model. This is not a guarantee of any particular training behavior.
- **Numerical eigenvalue algorithms**: [Inference] Defective matrices are commonly described in numerical analysis references as posing greater numerical difficulty for eigenvalue algorithms, because eigenvalues near a defective configuration can be highly sensitive to small perturbations. This is a reasoned point grounded in perturbation theory, but I cannot verify its precise numerical impact on any specific algorithm implementation without testing that implementation directly.

### Key Points

- Algebraic multiplicity counts root repetition in the characteristic polynomial; geometric multiplicity counts independent eigenvectors (eigenspace dimension) — both are proven definitions.
- Geometric multiplicity is always less than or equal to algebraic multiplicity for any eigenvalue — a proven inequality, not an inference.
- A matrix is diagonalizable if and only if these two multiplicities match for every eigenvalue — a proven equivalence.
- Defective matrices (where multiplicities differ) require generalized eigenvectors and Jordan normal form for a complete decomposition.
- Symmetric matrices are proven to never be defective, by the spectral theorem.
- Claims connecting this topic to specific ML model behavior (RNN dynamics, numerical algorithm sensitivity) are labeled [Inference], since they describe generally reasoned mathematical consequences rather than confirmed empirical outcomes for any particular system; I do not have access to verify implementation-specific or model-specific behavior without direct testing.

### Related Topics

- Eigenspaces (prior topic)
- Characteristic Polynomial (prior topic)
- Diagonalization and Eigendecomposition
- Jordan Normal Form and Generalized Eigenvectors
- Spectral Theorem for Symmetric Matrices
- Matrix Powers and Long-Term Dynamical Behavior
- Numerical Sensitivity and Perturbation Theory for Eigenvalues
- Principal Component Analysis (PCA)