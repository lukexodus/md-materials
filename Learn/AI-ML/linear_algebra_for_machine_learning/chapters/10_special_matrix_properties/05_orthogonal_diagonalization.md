## Orthogonal Diagonalization

### Definition

A square matrix $A$ is **orthogonally diagonalizable** if there exists an orthogonal matrix $Q$ (i.e., $Q^{-1} = Q^T$) and a diagonal matrix $D$ such that:

$$A = QDQ^T$$

The columns of $Q$ are orthonormal eigenvectors of $A$, and the diagonal entries of $D$ are the corresponding eigenvalues.

### The Spectral Theorem

The central result governing this topic: a real square matrix $A$ is orthogonally diagonalizable if and only if $A$ is symmetric ($A = A^T$).

This is a two-directional (if and only if) statement:

- If $A$ is symmetric, then $A$ is orthogonally diagonalizable.
- If $A$ is orthogonally diagonalizable, then $A$ is symmetric.

This is a standard, well-established result in linear algebra (commonly called the Spectral Theorem for real symmetric matrices).

### Why Symmetry Matters

Three properties of real symmetric matrices make orthogonal diagonalization possible:

1. **All eigenvalues are real.** Non-symmetric real matrices can have complex eigenvalues; symmetric matrices cannot.
2. **Eigenvectors from distinct eigenvalues are orthogonal.** If $Av_1 = \lambda_1 v_1$ and $Av_2 = \lambda_2 v_2$ with $\lambda_1 \neq \lambda_2$, then $v_1 \cdot v_2 = 0$.
3. **The matrix is always diagonalizable**, even in the presence of repeated eigenvalues — the eigenspaces always supply enough independent (and orthogonalizable) eigenvectors to reach full dimension. This avoids the "defective matrix" problem that can occur with general square matrices.

### Step-by-Step Procedure

**Given:** a symmetric matrix $A$.

1. Find the eigenvalues of $A$ by solving $\det(A - \lambda I) = 0$.
2. For each eigenvalue, find a basis for its eigenspace by solving $(A - \lambda I)v = 0$.
3. If an eigenvalue has multiplicity greater than 1, apply the Gram-Schmidt process to its eigenspace basis to obtain orthogonal eigenvectors within that eigenspace. (Eigenvectors from *different* eigenvalues are automatically orthogonal; eigenvectors *within* the same eigenspace are not automatically orthogonal and require this step.)
4. Normalize all eigenvectors to unit length.
5. Assemble the normalized, orthogonal eigenvectors as columns of $Q$.
6. Assemble the corresponding eigenvalues, in matching order, as the diagonal entries of $D$.
7. Verify: $A = QDQ^T$.

### Worked Example

Let:

$$A = \begin{bmatrix} 2 & 1 \\ 1 & 2 \end{bmatrix}$$

**Step 1 — Eigenvalues:**

$$\det(A - \lambda I) = (2-\lambda)^2 - 1 = \lambda^2 - 4\lambda + 3 = (\lambda - 1)(\lambda - 3) = 0$$

So $\lambda_1 = 1$, $\lambda_2 = 3$.

**Step 2 — Eigenvectors:**

For $\lambda_1 = 1$: $(A - I)v = 0 \Rightarrow \begin{bmatrix} 1 & 1 \\ 1 & 1 \end{bmatrix} v = 0 \Rightarrow v_1 = \begin{bmatrix} 1 \\ -1 \end{bmatrix}$

For $\lambda_2 = 3$: $(A - 3I)v = 0 \Rightarrow \begin{bmatrix} -1 & 1 \\ 1 & -1 \end{bmatrix} v = 0 \Rightarrow v_2 = \begin{bmatrix} 1 \\ 1 \end{bmatrix}$

Check orthogonality: $v_1 \cdot v_2 = (1)(1) + (-1)(1) = 0$ ✓ (confirms the theorem's prediction for distinct eigenvalues)

**Step 3 — Normalize:**

$$q_1 = \frac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ -1 \end{bmatrix}, \quad q_2 = \frac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ 1 \end{bmatrix}$$

**Step 4 — Assemble:**

$$Q = \frac{1}{\sqrt{2}}\begin{bmatrix} 1 & 1 \\ -1 & 1 \end{bmatrix}, \quad D = \begin{bmatrix} 1 & 0 \\ 0 & 3 \end{bmatrix}$$

**Output**

$$A = QDQ^T = \frac{1}{\sqrt{2}}\begin{bmatrix} 1 & 1 \\ -1 & 1 \end{bmatrix}\begin{bmatrix} 1 & 0 \\ 0 & 3 \end{bmatrix}\frac{1}{\sqrt{2}}\begin{bmatrix} 1 & -1 \\ 1 & 1 \end{bmatrix}$$

This can be verified directly by matrix multiplication to reproduce the original $A$.

### Geometric Interpretation

Orthogonal diagonalization decomposes a symmetric matrix's action into three geometrically simple steps: a rotation/reflection into a new orthonormal basis ($Q^T$), independent scaling along each new axis ($D$), and a rotation/reflection back ($Q$). Because $Q$ is orthogonal, the "change of basis" step preserves lengths and angles — it does not distort space, only reorients it. All the distortion (stretching/compressing) is isolated in the diagonal matrix $D$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 300">
  <text x="240" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">Orthogonal Diagonalization (svg_diagram)</text>

  <text x="60" y="60" font-size="12" fill="#333">Original space</text>
  <line x1="30" y1="150" x2="130" y2="150" stroke="#888" stroke-width="1" />
  <line x1="80" y1="100" x2="80" y2="200" stroke="#888" stroke-width="1" />
  <line x1="50" y1="180" x2="110" y2="120" stroke="#2563eb" stroke-width="2.5" />
  <line x1="55" y1="125" x2="105" y2="175" stroke="#dc2626" stroke-width="2.5" />
  <text x="80" y="220" text-anchor="middle" font-size="11" fill="#555">A</text>

  <path d="M140,150 L175,150" stroke="#1a1a2e" stroke-width="2" marker-end="url(#arrow)" />
  <text x="157" y="140" text-anchor="middle" font-size="10" fill="#1a1a2e">Q^T</text>

  <text x="245" y="60" font-size="12" fill="#333">Aligned to eigenbasis</text>
  <line x1="195" y1="150" x2="295" y2="150" stroke="#888" stroke-width="1" />
  <line x1="245" y1="100" x2="245" y2="200" stroke="#888" stroke-width="1" />
  <line x1="245" y1="150" x2="285" y2="150" stroke="#2563eb" stroke-width="2.5" />
  <line x1="245" y1="150" x2="245" y2="115" stroke="#dc2626" stroke-width="2.5" />
  <text x="245" y="220" text-anchor="middle" font-size="11" fill="#555">scale by D</text>

  <path d="M305,150 L340,150" stroke="#1a1a2e" stroke-width="2" marker-end="url(#arrow)" />
  <text x="322" y="140" text-anchor="middle" font-size="10" fill="#1a1a2e">Q</text>

  <text x="410" y="60" font-size="12" fill="#333">Back to original basis</text>
  <line x1="360" y1="150" x2="460" y2="150" stroke="#888" stroke-width="1" />
  <line x1="410" y1="100" x2="410" y2="200" stroke="#888" stroke-width="1" />
  <line x1="380" y1="185" x2="445" y2="115" stroke="#2563eb" stroke-width="2.5" />
  <line x1="390" y1="120" x2="435" y2="180" stroke="#dc2626" stroke-width="2.5" />
  <text x="410" y="220" text-anchor="middle" font-size="11" fill="#555">Av (final)</text>

  </svg>

### Relationship to the Spectral Decomposition

Orthogonal diagonalization can be rewritten as a sum of rank-1 matrices, known as the spectral decomposition:

$$A = \sum_{i=1}^n \lambda_i q_i q_i^T$$

where each $q_i$ is a unit eigenvector and $q_i q_i^T$ is the projection matrix onto the line spanned by $q_i$. This expresses $A$ as a weighted sum of orthogonal projections, weighted by the eigenvalues.

### Why This Matters for Machine Learning

- **Principal Component Analysis (PCA)** relies directly on orthogonal diagonalization of the covariance matrix (which is always symmetric). The eigenvectors become principal component directions, and eigenvalues indicate variance explained along each direction.
- **Positive semi-definite matrices** (covariance matrices, Gram matrices, Hessians at a minimum) are symmetric, so this decomposition always applies to them.
- **Quadratic forms**, such as those appearing in loss functions, can be simplified into a sum of independent squared terms via orthogonal diagonalization, which is useful for analyzing curvature and convexity.
- **Singular Value Decomposition (SVD)** for general (non-symmetric, even non-square) matrices is derived using orthogonal diagonalization applied to $A^TA$ and $AA^T$, both of which are symmetric by construction.

[Inference] The practical numerical stability of orthogonal diagonalization in specific ML library implementations (e.g., NumPy, PyTorch eigendecomposition routines) depends on the algorithm and matrix conditioning used, and behavior may vary across versions and library implementations — this is not something I can confirm generally without checking specific documentation.

### Key Points

- Orthogonal diagonalization applies precisely to real symmetric matrices — this is an if-and-only-if relationship, not a one-directional sufficient condition.
- All eigenvalues of a real symmetric matrix are real; eigenvectors from distinct eigenvalues are automatically orthogonal.
- Repeated eigenvalues require Gram-Schmidt orthogonalization within the eigenspace before normalization.
- The decomposition $A = QDQ^T$ separates rotation/reflection ($Q$) from pure scaling ($D$).
- This concept is foundational to PCA, SVD, and the analysis of quadratic forms in ML.

**Related Topics**

- Singular Value Decomposition (SVD) and its relationship to orthogonal diagonalization
- Positive definite and positive semi-definite matrices
- Principal Component Analysis derivation from the covariance matrix
- Quadratic forms and their canonical (diagonal) form
- Gram-Schmidt orthogonalization process
- Rayleigh quotients and variational characterization of eigenvalues
- Symmetric matrices and the Courant-Fischer min-max theorem