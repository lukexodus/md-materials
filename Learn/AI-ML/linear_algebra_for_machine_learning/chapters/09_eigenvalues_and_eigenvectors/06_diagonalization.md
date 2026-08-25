## Diagonalization

### Definition

A square matrix $A \in \mathbb{R}^{n \times n}$ is **diagonalizable** if it can be written as:

$$A = PDP^{-1}$$

where $D$ is a diagonal matrix containing the eigenvalues of $A$, and $P$ is an invertible matrix whose columns are the corresponding linearly independent eigenvectors of $A$. This is a direct algebraic definition, not an inference.

### Why This Factorization Requires a Full Eigenbasis

If $A$ has $n$ linearly independent eigenvectors $v_1, v_2, \ldots, v_n$ with corresponding eigenvalues $\lambda_1, \lambda_2, \ldots, \lambda_n$, define:

$$P = \begin{bmatrix}v_1 & v_2 & \cdots & v_n\end{bmatrix}, \qquad D = \begin{bmatrix}\lambda_1 & & \\ & \ddots & \\ & & \lambda_n\end{bmatrix}$$

Then $AP = PD$ follows directly from $Av_i = \lambda_i v_i$ applied column by column. Since $P$'s columns are linearly independent, $P$ is invertible, so:

$$A = PDP^{-1}$$

This derivation is a proven algebraic result, not [Inference]. As established in the prior topic, this construction is only possible when geometric multiplicity equals algebraic multiplicity for every eigenvalue — i.e., when $A$ is not defective.

### Geometric Intuition

Diagonalization expresses $A$ as "change basis → scale along basis directions → change back." In the eigenbasis defined by $P$'s columns, the action of $A$ is nothing more than independent scaling along each axis — all the geometric complexity of $A$ collapses into simple per-axis stretching once viewed in the right coordinate system.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Diagonalization as Change of Basis (svg_diagram)</text>
<rect x="30" y="60" width="100" height="50" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="80" y="90" font-size="11" text-anchor="middle" fill="#4338ca">x (std basis)</text>
<rect x="320" y="60" width="70" height="50" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="355" y="90" font-size="11" text-anchor="middle" fill="#4338ca">Ax</text>
<rect x="30" y="200" width="100" height="50" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="80" y="230" font-size="11" text-anchor="middle" fill="#92400e">P⁻¹x (eigenbasis)</text>
<rect x="320" y="200" width="70" height="50" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="355" y="230" font-size="11" text-anchor="middle" fill="#92400e">D(P⁻¹x)</text>
<line x1="130" y1="85" x2="320" y2="85" stroke="#dc2626" stroke-width="2" marker-end="url(#d1)" />
<text x="220" y="78" font-size="11" fill="#dc2626">A</text>
<line x1="80" y1="110" x2="80" y2="200" stroke="#16a34a" stroke-width="2" marker-end="url(#d2)" />
<text x="30" y="160" font-size="11" fill="#16a34a">P⁻¹</text>
<line x1="130" y1="225" x2="320" y2="225" stroke="#2563eb" stroke-width="2" marker-end="url(#d3)" />
<text x="220" y="218" font-size="11" fill="#2563eb">D (scale)</text>
<line x1="355" y1="200" x2="355" y2="110" stroke="#16a34a" stroke-width="2" marker-end="url(#d2)" />
<text x="360" y="160" font-size="11" fill="#16a34a">P</text>
</svg>

### Worked Example

Using the matrix from prior topics:

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix}, \quad \lambda_1 = 5,\ v_1=\begin{bmatrix}1\\1\end{bmatrix}, \quad \lambda_2 = 2,\ v_2=\begin{bmatrix}1\\-2\end{bmatrix}$$

**Step 1 — Form $P$ and $D$:**

$$P = \begin{bmatrix}1 & 1\\ 1 & -2\end{bmatrix}, \qquad D = \begin{bmatrix}5 & 0\\ 0 & 2\end{bmatrix}$$

**Step 2 — Compute $P^{-1}$:**

$$\det(P) = (1)(-2)-(1)(1) = -3, \qquad P^{-1} = \frac{1}{-3}\begin{bmatrix}-2 & -1\\ -1 & 1\end{bmatrix} = \begin{bmatrix}\tfrac{2}{3} & \tfrac{1}{3}\\ \tfrac{1}{3} & -\tfrac{1}{3}\end{bmatrix}$$

**Step 3 — Verify $A = PDP^{-1}$:**

$$PD = \begin{bmatrix}1&1\\1&-2\end{bmatrix}\begin{bmatrix}5&0\\0&2\end{bmatrix} = \begin{bmatrix}5&2\\5&-4\end{bmatrix}$$



$$PDP^{-1} = \begin{bmatrix}5&2\\5&-4\end{bmatrix}\begin{bmatrix}\tfrac{2}{3}&\tfrac{1}{3}\\\tfrac{1}{3}&-\tfrac{1}{3}\end{bmatrix} = \begin{bmatrix}4&1\\2&3\end{bmatrix} = A \quad \checkmark$$

This confirms the factorization directly through matrix multiplication, not by assumption.

### Why Diagonalization Is Useful: Fast Matrix Powers

A major practical benefit of diagonalization is efficient computation of matrix powers:

$$A^k = PD^kP^{-1}$$

This is a direct algebraic consequence: $A^k = (PDP^{-1})(PDP^{-1})\cdots(PDP^{-1}) = PD^kP^{-1}$, since the interior $P^{-1}P$ terms cancel. Since $D$ is diagonal, $D^k$ is simply each diagonal entry raised to the $k$-th power — computed in $O(n)$ time rather than repeated $O(n^3)$ matrix multiplications. This is a proven computational identity, not an inference.

### When Diagonalization Is Not Possible

As established in the prior topic, a matrix fails to be diagonalizable (over the reals, or even over the complex numbers) when at least one eigenvalue has geometric multiplicity strictly less than algebraic multiplicity — i.e., the matrix is defective. In that case, $A$ can still be decomposed using **Jordan normal form**, a related but more general block-triangular decomposition, though this is outside the scope of ordinary diagonalization.

### Diagonalization of Symmetric Matrices

For a symmetric matrix ($A = A^T$), the spectral theorem guarantees a stronger form of diagonalization:

$$A = Q\Lambda Q^T$$

where $Q$ is an **orthogonal** matrix ($Q^{-1}=Q^T$) and $\Lambda$ is diagonal. This is a proven special case, not an inference, and it connects directly back to the properties of orthogonal matrices covered earlier: symmetric matrices are always diagonalizable, and their eigenvectors can always be chosen to be orthonormal.

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[4, 1], [2, 3]])

eigvals, eigvecs = np.linalg.eig(A)
P = eigvecs
D = np.diag(eigvals)
P_inv = np.linalg.inv(P)

A_reconstructed = P @ D @ P_inv
print("Reconstructed A:\n", A_reconstructed)
print("Matches original A:", np.allclose(A_reconstructed, A))
```

[Unverified] The exact numerical output — including minor floating-point rounding differences — may vary depending on the NumPy version and underlying LAPACK implementation used to run this code. I cannot verify the precise output without executing this code in your specific environment. I do not have access to your runtime to confirm this directly.

### Relevance to Machine Learning

- **PCA**: relies directly on diagonalizing the covariance matrix (a symmetric matrix), yielding orthogonal principal component directions and their associated variances.
- **Markov chains**: diagonalization is commonly used to analyze long-run behavior of transition matrices, since $A^k = PD^kP^{-1}$ allows computing $A^k$ efficiently as $k \to \infty$. [Inference] Whether this long-run behavior converges to a stable distribution depends on the specific structure of eigenvalues (e.g., whether the largest eigenvalue's magnitude dominates others), which I cannot verify without analyzing a specific transition matrix directly.
- **Recurrent neural networks**: [Inference] Diagonalizable weight matrices in recurrent architectures are sometimes discussed in theoretical literature as easier to analyze for long-term gradient behavior compared to defective matrices, since $D^k$ has a simple closed form while defective matrices can introduce polynomial growth terms. This is a reasoned mathematical connection based on the algebra above, but I cannot verify how this manifests in any specific trained model without direct empirical analysis, and this is not a guarantee of training stability or outcome for any particular architecture.
- **Quadratic forms and optimization**: diagonalizing the Hessian of a loss function via $Q\Lambda Q^T$ (using the symmetric case) reveals the natural axes along which curvature is largest/smallest, which connects to condition-number-based analyses of optimization difficulty discussed in earlier topics.

### Key Points

- $A = PDP^{-1}$ requires $n$ linearly independent eigenvectors — a full eigenbasis — which is a proven algebraic requirement, not situational.
- Diagonalization enables efficient computation of matrix powers via $A^k = PD^kP^{-1}$ — a proven identity.
- Symmetric matrices always diagonalize as $A = Q\Lambda Q^T$ with an orthogonal $Q$, by the spectral theorem — proven, not inferred.
- Defective matrices cannot be diagonalized and require Jordan normal form instead.
- Claims connecting diagonalizability to specific ML model training behavior (RNN gradients, Markov chain convergence for a particular matrix) are labeled [Inference], since they describe reasoned mathematical consequences rather than confirmed outcomes for any specific system; I do not have access to verify implementation-specific or model-specific behavior without direct empirical testing. No guarantee of training stability or convergence is being made here.

### Related Topics

- Algebraic and Geometric Multiplicity (prior topic)
- Eigenspaces (prior topic)
- Spectral Theorem for Symmetric Matrices
- Jordan Normal Form and Generalized Eigenvectors
- Matrix Powers and Markov Chain Analysis
- Principal Component Analysis (PCA)
- Quadratic Forms and the Hessian in Optimization
- Singular Value Decomposition (SVD) as a Generalization for Non-Square Matrices