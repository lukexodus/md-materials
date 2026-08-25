## Spectral Theorem

### Statement

The **spectral theorem** for real symmetric matrices states: for every real symmetric matrix $A \in \mathbb{R}^{n \times n}$, there exists an orthogonal matrix $Q$ and a real diagonal matrix $\Lambda$ such that:

$$A = Q\Lambda Q^T$$

Equivalently: every real symmetric matrix has real eigenvalues, and its eigenvectors can be chosen to form an orthonormal basis of $\mathbb{R}^n$. This is a proven mathematical theorem, not [Inference].

### The Three Component Claims

The spectral theorem bundles together three results, each established individually in prior topics:

1. **Real eigenvalues**: every eigenvalue of a real symmetric matrix is real (proven in "Symmetric Matrices and Real Eigenvalues").
2. **Orthogonal eigenvectors for distinct eigenvalues**: eigenvectors corresponding to different eigenvalues are automatically orthogonal (proven in the same prior topic).
3. **No defectiveness**: geometric multiplicity always equals algebraic multiplicity for symmetric matrices, guaranteeing enough eigenvectors — even for repeated eigenvalues — to form a complete orthonormal basis (established in "Algebraic and Geometric Multiplicity" and "Eigenspaces").

Point 3 requires slightly more than points 1 and 2 alone; a full proof that repeated eigenvalues of a symmetric matrix are never defective typically proceeds by induction using orthogonal complements, which is a standard construction in linear algebra references. I am stating this proof strategy at a high level rather than reproducing the full inductive argument step by step, since a complete formal proof is lengthy; I cannot verify that any specific textbook's exact proof wording matches what is described here without quoting that source directly, which I am not doing.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Spectral Theorem: A = QΛQᵀ (svg_diagram)</text>
<rect x="30" y="90" width="70" height="70" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="65" y="130" font-size="16" text-anchor="middle" fill="#4338ca">A</text>
<text x="65" y="175" font-size="9" text-anchor="middle" fill="#666">symmetric</text>

<text x="120" y="130" font-size="16" fill="#333">=</text>

<rect x="145" y="90" width="70" height="70" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" rx="6" />
<text x="180" y="130" font-size="16" text-anchor="middle" fill="#166534">Q</text>
<text x="180" y="175" font-size="9" text-anchor="middle" fill="#666">orthogonal</text>
<rect x="230" y="90" width="70" height="70" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="265" y="130" font-size="16" text-anchor="middle" fill="#92400e">Λ</text>
<text x="265" y="175" font-size="9" text-anchor="middle" fill="#666">diagonal, real</text>
<rect x="315" y="90" width="70" height="70" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" rx="6" />
<text x="350" y="130" font-size="16" text-anchor="middle" fill="#166534">Qᵀ</text>
<text x="350" y="175" font-size="9" text-anchor="middle" fill="#666">orthogonal</text>

<text x="210" y="230" font-size="10" text-anchor="middle" fill="#444">Columns of Q are an orthonormal eigenbasis; Λ holds real eigenvalues</text>

</svg>

### Comparison to General (Non-Symmetric) Diagonalization

The prior "Diagonalization" topic established the general factorization $A=PDP^{-1}$, which requires only that $P$ be invertible. The spectral theorem is a **strictly stronger** guarantee for symmetric matrices specifically: it guarantees the change-of-basis matrix can always be chosen **orthogonal** ($Q^{-1}=Q^T$), not merely invertible. This is a proven distinction, not [Inference].

| Property | General diagonalizable matrix | Symmetric matrix |
| --- | --- | --- |
| Eigenvalues | May be complex | Always real |
| Change-of-basis matrix | Invertible ($P^{-1}$ needed) | Orthogonal ($Q^T=Q^{-1}$, no inversion needed) |
| Defectiveness possible | Yes | Never |
| Diagonalizable | Only if eigenspaces match | Always guaranteed |

### Worked Example

Reusing the matrix from the "Symmetric Matrices and Real Eigenvalues" topic:

$$A = \begin{bmatrix}2 & 1\\ 1 & 2\end{bmatrix}, \quad \lambda_1=3,\ \lambda_2=1$$

with normalized orthogonal eigenvectors already derived there:

$$Q = \begin{bmatrix}\tfrac{1}{\sqrt2} & \tfrac{1}{\sqrt2}\\ \tfrac{1}{\sqrt2} & -\tfrac{1}{\sqrt2}\end{bmatrix}, \quad \Lambda=\begin{bmatrix}3&0\\0&1\end{bmatrix}$$

**Verification that $Q$ is orthogonal** (i.e., $Q^TQ=I$):

$$Q^TQ = \begin{bmatrix}\tfrac{1}{\sqrt2}&\tfrac{1}{\sqrt2}\\\tfrac{1}{\sqrt2}&-\tfrac{1}{\sqrt2}\end{bmatrix}\begin{bmatrix}\tfrac{1}{\sqrt2}&\tfrac{1}{\sqrt2}\\\tfrac{1}{\sqrt2}&-\tfrac{1}{\sqrt2}\end{bmatrix} = \begin{bmatrix}\tfrac12+\tfrac12 & \tfrac12-\tfrac12\\ \tfrac12-\tfrac12 & \tfrac12+\tfrac12\end{bmatrix} = \begin{bmatrix}1&0\\0&1\end{bmatrix}=I \quad\checkmark$$

**Verification that $A=Q\Lambda Q^T$:**

$$Q\Lambda = \begin{bmatrix}\tfrac{1}{\sqrt2}&\tfrac{1}{\sqrt2}\\\tfrac{1}{\sqrt2}&-\tfrac{1}{\sqrt2}\end{bmatrix}\begin{bmatrix}3&0\\0&1\end{bmatrix} = \begin{bmatrix}\tfrac{3}{\sqrt2}&\tfrac{1}{\sqrt2}\\\tfrac{3}{\sqrt2}&-\tfrac{1}{\sqrt2}\end{bmatrix}$$



$$Q\Lambda Q^T = \begin{bmatrix}\tfrac{3}{\sqrt2}&\tfrac{1}{\sqrt2}\\\tfrac{3}{\sqrt2}&-\tfrac{1}{\sqrt2}\end{bmatrix}\begin{bmatrix}\tfrac{1}{\sqrt2}&\tfrac{1}{\sqrt2}\\\tfrac{1}{\sqrt2}&-\tfrac{1}{\sqrt2}\end{bmatrix} = \begin{bmatrix}\tfrac32+\tfrac12 & \tfrac32-\tfrac12\\ \tfrac32-\tfrac12 & \tfrac32+\tfrac12\end{bmatrix} = \begin{bmatrix}2&1\\1&2\end{bmatrix}=A \quad\checkmark$$

Both checks were computed directly above through explicit matrix multiplication, confirming the theorem for this specific example rather than merely asserting it.

### Spectral Decomposition as a Sum of Rank-1 Projections

An equivalent and often useful way to write the spectral theorem is:

$$A = \sum_{i=1}^n \lambda_i q_iq_i^T$$

where $q_i$ are the orthonormal columns of $Q$. Each term $q_iq_i^T$ is a rank-1 projection matrix onto the eigenvector direction $q_i$ (satisfying $(q_iq_i^T)^2=q_iq_i^T$, connecting directly to the projection topic covered earlier). This is a proven algebraic identity, following directly from expanding $Q\Lambda Q^T$ in terms of $Q$'s columns and $\Lambda$'s diagonal entries — not [Inference].

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[2, 1], [1, 2]])

eigvals, Q = np.linalg.eigh(A)  # eigh guarantees orthonormal output for symmetric input
Lambda = np.diag(eigvals)

A_reconstructed = Q @ Lambda @ Q.T
print("Q^T Q (should be identity):\n", Q.T @ Q)
print("Reconstructed A:\n", A_reconstructed)
print("Matches original:", np.allclose(A_reconstructed, A))
```

I cannot verify the exact numerical output of this code without executing it in your specific environment. [Unverified] — floating-point rounding may cause small deviations from exact values (e.g., `2.0000000000000004` instead of `2.0`), and the precise output depends on NumPy version and underlying LAPACK implementation, which I am not able to confirm directly.

### Relevance to Machine Learning

- **PCA is a direct application of the spectral theorem**: the covariance matrix (always symmetric) is decomposed as $\Sigma=Q\Lambda Q^T$, where columns of $Q$ are the principal component directions and diagonal entries of $\Lambda$ are the variances explained along each direction. This is a proven, direct application, not [Inference].
- **Low-rank approximation**: [Inference] Using the rank-1 sum form $A=\sum\lambda_iq_iq_i^T$, keeping only the terms with the largest $|\lambda_i|$ is commonly described in dimensionality-reduction references as producing the best rank-$k$ approximation to $A$ in a specific matrix-norm sense (related to the Eckart–Young theorem, which is more directly stated for SVD but has a symmetric-matrix analogue via the spectral theorem). I cannot verify the precise optimality guarantee's exact statement or proof without quoting a specific formal reference, which I am not doing here, so this specific optimality claim is labeled [Unverified] beyond the general low-rank approximation concept.
- **Whitening transformations**: [Inference] The spectral decomposition is sometimes described in preprocessing/feature-engineering references as enabling "whitening" — transforming data so its covariance becomes the identity matrix, via $\Sigma^{-1/2}=Q\Lambda^{-1/2}Q^T$ (using the matrix-function definition from the "Eigendecomposition" topic). I cannot verify that this specific technique is implemented identically across different software libraries without consulting each library's official documentation directly, and this is not a guarantee of any specific numerical outcome for any given dataset.

### Key Points

- The spectral theorem guarantees $A=Q\Lambda Q^T$ for every real symmetric matrix, with $Q$ orthogonal and $\Lambda$ real diagonal — a proven theorem combining three previously established results.
- This is strictly stronger than general diagonalizability: symmetric matrices never require matrix inversion for the change of basis, and are never defective.
- The equivalent sum-of-rank-1-projections form $A=\sum\lambda_iq_iq_i^T$ is a proven algebraic identity.
- PCA is a direct, proven application of this theorem to covariance matrices.
- Claims regarding the exact optimality statement of low-rank approximation (Eckart–Young-type results) and the specific implementation details of whitening transformations in software libraries are labeled [Inference] or [Unverified], since I do not have a specific formal reference or documentation quoted in this conversation to confirm their precise statement or implementation. No numerical outcome is guaranteed for any specific dataset or software system by these connections.

Correction: No unverified claim was asserted as fact without a label in this response; all uncertain statements were marked according to the stated convention.

### Related Topics

- Symmetric Matrices and Real Eigenvalues (prior topic)
- Positive Definite and Positive Semidefinite Matrices (prior topic)
- Quadratic Forms (prior topic)
- Principal Component Analysis (PCA) via Spectral Decomposition
- Singular Value Decomposition (SVD) and the Eckart–Young Theorem
- Whitening Transformations in Data Preprocessing
- Low-Rank Matrix Approximation
- Projection Matrices and Rank-1 Decompositions