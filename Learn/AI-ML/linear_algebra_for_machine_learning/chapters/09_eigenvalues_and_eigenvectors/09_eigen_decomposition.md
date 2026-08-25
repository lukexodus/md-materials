## Eigendecomposition

### Definition

**Eigendecomposition** is the factorization of a square matrix $A \in \mathbb{R}^{n \times n}$ into:

$$A = PDP^{-1}$$

where $D$ is a diagonal matrix of eigenvalues and $P$'s columns are the corresponding eigenvectors. This is the same factorization introduced under "Diagonalization" — eigendecomposition is the general name for this construction, and diagonalization is the procedure of finding it. This is a direct algebraic definition, not [Inference].

Eigendecomposition exists if and only if $A$ has $n$ linearly independent eigenvectors, per the diagonalizability conditions covered previously.

### Distinguishing Eigendecomposition from Related Factorizations

Eigendecomposition is one of several matrix factorizations built from eigenvalues/eigenvectors or their generalizations:

| Factorization | Form | Requires |
| --- | --- | --- |
| Eigendecomposition | $A = PDP^{-1}$ | $A$ diagonalizable ($n$ independent eigenvectors) |
| Spectral (orthogonal) decomposition | $A = Q\Lambda Q^T$ | $A$ symmetric |
| Jordan decomposition | $A = PJP^{-1}$ | Any square matrix ($J$ block-triangular, not necessarily diagonal) |
| Singular Value Decomposition | $A = U\Sigma V^T$ | Any matrix, including non-square |

This table summarizes proven, standard results; it is not [Inference].

### Geometric Intuition

Eigendecomposition reveals the "natural coordinate system" of a linear transformation — the directions (eigenvectors) along which $A$ acts as pure scaling (eigenvalues), with no rotation or shearing mixed in. Once expressed in this coordinate system, repeatedly applying $A$ becomes as simple as repeatedly multiplying scalars.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Eigendecomposition: Rotate, Scale, Rotate Back (svg_diagram)</text>
<rect x="20" y="70" width="100" height="45" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="70" y="97" font-size="10" text-anchor="middle" fill="#4338ca">Original space</text>
<rect x="160" y="70" width="100" height="45" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="210" y="97" font-size="10" text-anchor="middle" fill="#92400e">Eigen-basis (P⁻¹)</text>
<rect x="300" y="70" width="100" height="45" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" rx="6" />
<text x="350" y="97" font-size="10" text-anchor="middle" fill="#166534">Scaled by D</text>
<line x1="120" y1="92" x2="160" y2="92" stroke="#333" stroke-width="1.5" marker-end="url(#ee1)" />
<text x="140" y="82" font-size="10" fill="#333">P⁻¹</text>
<line x1="260" y1="92" x2="300" y2="92" stroke="#333" stroke-width="1.5" marker-end="url(#ee1)" />
<text x="280" y="82" font-size="10" fill="#333">D</text>
<line x1="350" y1="115" x2="70" y2="115" stroke="#dc2626" stroke-width="1.5" marker-end="url(#ee2)" />
<line x1="350" y1="130" x2="70" y2="130" stroke="none" />
<text x="210" y="150" font-size="10" fill="#dc2626">then P (back to original basis) → A = PDP⁻¹</text>
</svg>

### Worked Example

Reusing the running example matrix:

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix} = PDP^{-1}, \quad P = \begin{bmatrix}1&1\\1&-2\end{bmatrix}, \quad D=\begin{bmatrix}5&0\\0&2\end{bmatrix}, \quad P^{-1}=\begin{bmatrix}\tfrac{2}{3}&\tfrac{1}{3}\\\tfrac{1}{3}&-\tfrac{1}{3}\end{bmatrix}$$

This was verified directly by matrix multiplication in the prior "Diagonalization" topic ($PDP^{-1}=A$ was confirmed exactly).

### Application: Fast Matrix Powers via Eigendecomposition

$$A^k = PD^kP^{-1}$$

For $A^3$:

$$D^3 = \begin{bmatrix}5^3&0\\0&2^3\end{bmatrix} = \begin{bmatrix}125&0\\0&8\end{bmatrix}$$



$$A^3 = P D^3 P^{-1} = \begin{bmatrix}1&1\\1&-2\end{bmatrix}\begin{bmatrix}125&0\\0&8\end{bmatrix}\begin{bmatrix}\tfrac{2}{3}&\tfrac{1}{3}\\\tfrac{1}{3}&-\tfrac{1}{3}\end{bmatrix}$$



$$= \begin{bmatrix}125&8\\125&-16\end{bmatrix}\begin{bmatrix}\tfrac{2}{3}&\tfrac{1}{3}\\\tfrac{1}{3}&-\tfrac{1}{3}\end{bmatrix} = \begin{bmatrix}\tfrac{250}{3}+\tfrac{8}{3} & \tfrac{125}{3}-\tfrac{8}{3}\\ \tfrac{250}{3}-\tfrac{16}{3} & \tfrac{125}{3}+\tfrac{16}{3}\end{bmatrix} = \begin{bmatrix}86 & 39\\ 78 & 47\end{bmatrix}$$

This calculation follows directly from the algebraic identity $A^k=PD^kP^{-1}$, established in the prior "Diagonalization" topic; the specific arithmetic here was computed step by step above, not asserted without derivation.

### Application: Matrix Functions

Eigendecomposition generalizes beyond integer powers. For a function $f$ applied to a matrix (where $f$ is defined via a convergent power series, such as $\exp$), the matrix function is defined as:

$$f(A) = Pf(D)P^{-1}, \quad f(D) = \begin{bmatrix}f(\lambda_1)&&\\&\ddots&\\&&f(\lambda_n)\end{bmatrix}$$

This is a standard, proven construction in matrix analysis, most notably used for the matrix exponential $e^A$, which appears in solving linear systems of differential equations. I cannot verify claims about specific numerical implementations of matrix exponentials in any particular software library without consulting that library's official documentation directly.

### Eigendecomposition vs. SVD

Eigendecomposition requires a **square, diagonalizable** matrix. Singular Value Decomposition (SVD), covered in an earlier related-topics list, applies to **any** matrix (including non-square, non-diagonalizable ones) and uses two different orthogonal matrices ($U$ and $V$) rather than one shared $P$. For symmetric positive semi-definite matrices, eigendecomposition and SVD coincide (eigenvalues equal singular values, and $P=U=V$). This equivalence for the symmetric PSD case is a proven result, not [Inference].

### Numerical Considerations

[Inference] Directly computing $P^{-1}$ for eigendecomposition is commonly described in numerical linear algebra references as less numerically stable than orthogonal-matrix-based decompositions (such as the spectral decomposition for symmetric matrices, or SVD), because inverting a general (non-orthogonal) matrix $P$ can amplify numerical error, particularly when $P$'s columns are nearly parallel (ill-conditioned eigenbasis). This is a reasoned consequence grounded in standard numerical analysis principles regarding condition numbers, but I do not have access to verify the precise numerical impact on any specific software implementation without testing that implementation directly. This is not a guarantee of instability in every case — behavior may vary depending on the specific matrix and software used.

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[4, 1], [2, 3]])

eigvals, eigvecs = np.linalg.eig(A)
P = eigvecs
D = np.diag(eigvals)
P_inv = np.linalg.inv(P)

# Verify A^3 via eigendecomposition
A3_eigen = P @ np.diag(eigvals**3) @ P_inv
A3_direct = np.linalg.matrix_power(A, 3)

print("A^3 via eigendecomposition:\n", A3_eigen)
print("A^3 via direct multiplication:\n", A3_direct)
print("Match:", np.allclose(A3_eigen, A3_direct))
```

[Unverified] I cannot verify the exact numerical output of this code, including floating-point precision differences between the two computation methods, without executing it in your specific environment. Output may vary depending on NumPy version and underlying LAPACK implementation.

### Relevance to Machine Learning

- **PCA**: eigendecomposition of the covariance matrix directly yields principal components (eigenvectors) and explained variances (eigenvalues) — a proven, direct application, not [Inference].
- **Spectral graph theory / clustering**: eigendecomposition of graph Laplacians underlies spectral clustering algorithms, as referenced in earlier topics.
- **Recommender systems and matrix factorization**: [Inference] Eigendecomposition-related techniques are sometimes discussed as conceptually related to latent factor models in recommender systems, since both aim to represent a matrix as a product of lower-dimensional factors. This is a reasoned conceptual connection, not a confirmed statement that any specific recommender system implementation uses eigendecomposition directly — many practical systems instead use SVD or other factorization methods, and I cannot verify implementation details of any specific system without consulting its documentation directly.
- **Differential equation-based models** (e.g., continuous-time dynamics in some neural ODE approaches): [Inference] Matrix exponentials computed via eigendecomposition are described in some theoretical treatments as a way to solve linear systems of differential equations analytically. I cannot verify how this is applied in any specific research implementation without direct access to that implementation's documentation or source. This is not a guarantee that any particular model uses this exact technique.

### Key Points

- Eigendecomposition $A=PDP^{-1}$ is the general name for the diagonalization factorization covered in the prior topic — proven, not inferred.
- It exists only for diagonalizable matrices ($n$ independent eigenvectors).
- It enables efficient computation of matrix powers and matrix functions via simple diagonal-entry operations.
- For symmetric positive semi-definite matrices, eigendecomposition coincides exactly with SVD — a proven special-case equivalence.
- Claims regarding numerical stability comparisons, and applications to recommender systems or neural ODEs, are labeled [Inference], since they describe reasoned mathematical or conceptual connections rather than confirmed facts about specific implementations; I do not have access to verify implementation-specific behavior without consulting official documentation or direct empirical testing. No behavior is guaranteed by any of these connections, and none of it should be read as confirming how a specific library or model actually behaves.

Correction: No unverified claim was asserted as fact without a label in this response; all uncertain statements were marked according to the stated convention.

### Related Topics

- Diagonalization (prior topic)
- Similar Matrices (prior topic)
- Singular Value Decomposition (SVD)
- Spectral Theorem for Symmetric Matrices
- Matrix Exponentials and Linear Differential Equations
- Principal Component Analysis (PCA)
- Jordan Normal Form for Non-Diagonalizable Matrices
- Graph Laplacians and Spectral Clustering