## Conditions for Diagonalizability

### Primary Criterion

A square matrix $A \in \mathbb{R}^{n \times n}$ is diagonalizable if and only if, for every eigenvalue $\lambda_i$, the geometric multiplicity equals the algebraic multiplicity:

$$\text{geometric multiplicity}(\lambda_i) = \text{algebraic multiplicity}(\lambda_i) \quad \text{for all } i$$

Equivalently, $A$ is diagonalizable if and only if it has $n$ linearly independent eigenvectors — enough to form a complete eigenbasis of $\mathbb{R}^n$. This is a proven equivalence in linear algebra, not [Inference].

### Sufficient (But Not Necessary) Condition: Distinct Eigenvalues

If a matrix $A$ has $n$ **distinct** eigenvalues, it is automatically diagonalizable. This is a proven result: eigenvectors corresponding to distinct eigenvalues are always linearly independent, so $n$ distinct eigenvalues guarantee $n$ independent eigenvectors.

Note that this condition is sufficient but not necessary — a matrix can still be diagonalizable with repeated eigenvalues, as long as each repeated eigenvalue's geometric multiplicity fully matches its algebraic multiplicity (as shown in the identity-matrix example from the prior topic).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 320">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Diagonalizability Decision Path (svg_diagram)</text>
<rect x="140" y="45" width="140" height="45" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="210" y="72" font-size="11" text-anchor="middle" fill="#4338ca">n distinct eigenvalues?</text>
<rect x="20" y="140" width="150" height="50" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" rx="6" />
<text x="95" y="162" font-size="11" text-anchor="middle" fill="#166534">Yes → automatically</text>
<text x="95" y="178" font-size="11" text-anchor="middle" fill="#166534">diagonalizable</text>
<rect x="250" y="140" width="150" height="50" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="325" y="162" font-size="11" text-anchor="middle" fill="#92400e">No → check each</text>
<text x="325" y="178" font-size="11" text-anchor="middle" fill="#92400e">repeated eigenvalue</text>
<rect x="250" y="230" width="150" height="60" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" rx="6" />
<text x="325" y="252" font-size="10" text-anchor="middle" fill="#166534">geo. mult = alg. mult</text>
<text x="325" y="268" font-size="10" text-anchor="middle" fill="#166534">for all → diagonalizable</text>
<line x1="170" y1="68" x2="95" y2="140" stroke="#16a34a" stroke-width="2" marker-end="url(#c1)" />
<line x1="250" y1="68" x2="325" y2="140" stroke="#d97706" stroke-width="2" marker-end="url(#c2)" />
<line x1="325" y1="190" x2="325" y2="230" stroke="#16a34a" stroke-width="2" marker-end="url(#c1)" />
</svg>

### Worked Example — Distinct Eigenvalues Guarantee Diagonalizability

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix}$$

From prior topics, this matrix has eigenvalues $\lambda_1=5$ and $\lambda_2=2$ — two distinct values for a $2\times 2$ matrix. By the sufficient condition above, $A$ is guaranteed diagonalizable without needing to separately check geometric multiplicities. This was already confirmed directly by explicit construction of $P$ and $D$ in the prior topic.

### Worked Example — Repeated Eigenvalue, Still Diagonalizable

$$A = \begin{bmatrix}3 & 0\\ 0 & 3\end{bmatrix}$$

Here $\lambda=3$ has algebraic multiplicity 2 (repeated root), so the distinct-eigenvalues shortcut does not apply. Checking directly: solving $(A-3I)v=0$ gives the zero matrix, meaning every vector in $\mathbb{R}^2$ is a solution, so geometric multiplicity is also 2. Since $2=2$, this matrix is diagonalizable — confirmed by direct computation, not by the shortcut condition.

### Worked Example — Repeated Eigenvalue, Not Diagonalizable

$$A = \begin{bmatrix}3 & 1\\ 0 & 3\end{bmatrix}$$

Again $\lambda=3$ has algebraic multiplicity 2. Solving $(A-3I)v=0$ gives $v_2=0$, so only a 1-dimensional eigenspace exists — geometric multiplicity 1. Since $1 \neq 2$, this matrix is **not** diagonalizable. This was verified directly by solving the linear system, not assumed.

### Necessary and Sufficient Condition, Restated

Combining the above, the complete diagonalizability criterion is:

$$A \text{ is diagonalizable} \iff \sum_i \text{geometric multiplicity}(\lambda_i) = n$$

That is, the eigenspaces across all eigenvalues, summed together, must account for the full dimension $n$ of the space. This is a proven, exact equivalence — not a heuristic or approximation.

### Special Guaranteed Case: Symmetric Matrices

Every real symmetric matrix ($A = A^T$) is diagonalizable, and more specifically **orthogonally diagonalizable**:

$$A = Q\Lambda Q^T, \quad Q \text{ orthogonal}$$

This is guaranteed by the spectral theorem — a proven result, not [Inference]. Symmetric matrices are never defective; geometric multiplicity always equals algebraic multiplicity for every eigenvalue of a symmetric matrix.

### Other Guaranteed Diagonalizable Classes

- **Matrices with $n$ distinct eigenvalues** (covered above) — always diagonalizable.
- **Real symmetric matrices** — always orthogonally diagonalizable, by the spectral theorem.
- **Normal matrices** (satisfying $A^TA = AA^T$, over the complex numbers with conjugate transpose $A^*A=AA^*$) — diagonalizable via a unitary matrix. This is a proven generalization of the spectral theorem to a broader matrix class.

I cannot verify claims about diagonalizability holding for matrix classes beyond these proven cases without a specific theorem reference; any broader generalization would need to be checked against a formal source.

### Computational Check (Python / NumPy)

```python
import numpy as np

def check_diagonalizable(A, tol=1e-8):
    eigvals, eigvecs = np.linalg.eig(A)
    rank = np.linalg.matrix_rank(eigvecs, tol=tol)
    return rank == A.shape[0]

A_distinct = np.array([[4, 1], [2, 3]])
A_repeated_ok = np.array([[3, 0], [0, 3]])
A_defective = np.array([[3, 1], [0, 3]])

for name, A in [("distinct", A_distinct), ("repeated_ok", A_repeated_ok), ("defective", A_defective)]:
    print(name, "diagonalizable:", check_diagonalizable(A))
```

[Unverified] The exact output of this code, including whether NumPy's `eig` function returns numerically distinguishable eigenvectors for the defective case (rather than two nearly-parallel vectors due to floating-point approximation), may vary depending on the NumPy version and underlying LAPACK implementation. I cannot verify the precise output without executing this code in your specific environment. This function's rank-based check is also an approximate numerical test and is not a substitute for the exact symbolic criterion described above.

### Relevance to Machine Learning

- **PCA**: covariance matrices are always symmetric, so diagonalizability is guaranteed by the spectral theorem in every case — this is a proven mathematical fact for symmetric matrices, not situational.
- **Iterative optimization methods**: [Inference] Whether a Hessian encountered during optimization is diagonalizable relates to whether it is symmetric — and Hessians of twice-differentiable functions are symmetric by Clairaut's/Schwarz's theorem (under standard smoothness conditions) — so in principle Hessians are diagonalizable via the spectral theorem in typical cases. I cannot verify that this holds for every specific loss function or model architecture without directly checking the relevant smoothness conditions for that function.
- **Weight matrices in deep learning**: [Inference] Generic (non-symmetric) weight matrices in neural networks are not guaranteed to be diagonalizable, since they need not have distinct eigenvalues or matching multiplicities. I do not have access to verify the diagonalizability of any specific trained model's weight matrices without direct numerical analysis of those matrices, and this is not a guaranteed property of neural network weights in general.

### Key Points

- Diagonalizability holds exactly when geometric multiplicity equals algebraic multiplicity for every eigenvalue — a proven necessary and sufficient condition.
- $n$ distinct eigenvalues is a sufficient (not necessary) condition for diagonalizability — proven, not inferred.
- Real symmetric matrices are always diagonalizable (orthogonally), guaranteed by the spectral theorem.
- A matrix is diagonalizable if and only if the sum of geometric multiplicities across all eigenvalues equals $n$.
- Claims about diagonalizability of Hessians or neural network weight matrices for specific models are labeled [Inference], since they depend on properties (smoothness, actual eigenvalue structure) that I cannot verify without direct analysis of that specific function or matrix. No behavior is guaranteed here for any particular system.

Correction: No unverified claim was asserted as fact in this response without a label; all uncertain statements were marked according to the stated convention.

### Related Topics

- Diagonalization (prior topic)
- Algebraic and Geometric Multiplicity (prior topic)
- Spectral Theorem for Symmetric Matrices
- Normal Matrices and Unitary Diagonalization
- Jordan Normal Form for Non-Diagonalizable Matrices
- Hessian Matrices and Smoothness Conditions in Optimization
- Principal Component Analysis (PCA)
- Numerical Rank and Floating-Point Considerations in Eigendecomposition