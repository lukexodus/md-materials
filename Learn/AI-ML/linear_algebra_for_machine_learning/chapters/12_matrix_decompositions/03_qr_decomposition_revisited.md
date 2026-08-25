## QR Decomposition Revisited

### Overview

QR decomposition factors a matrix $A$ into an orthogonal (or orthonormal-column) matrix $Q$ and an upper triangular matrix $R$, such that:

$$A = QR$$

This revisit consolidates the concept with a focus on computational methods, numerical stability, and its role in machine learning pipelines, extending beyond the basic definition to compare derivation techniques.

### Definition Recap

For a matrix $A \in \mathbb{R}^{m \times n}$ with $m \geq n$ and full column rank:

- $Q \in \mathbb{R}^{m \times n}$ has orthonormal columns, meaning $Q^T Q = I$
- $R \in \mathbb{R}^{n \times n}$ is upper triangular with non-negative diagonal entries (in the standard convention)

The columns of $Q$ form an orthonormal basis for the column space of $A$, and $R$ encodes how the original columns of $A$ are expressed as linear combinations of that basis.

### Three Computational Approaches

There are three principal methods for computing QR decomposition, each with different tradeoffs in stability, cost, and implementation complexity.

#### 1. Gram-Schmidt Process

The classical approach builds $Q$ column by column, orthogonalizing each new column of $A$ against all previously computed columns of $Q$.

Given columns $a_1, a_2, \dots, a_n$ of $A$:

$$u_1 = a_1, \quad q_1 = \frac{u_1}{\|u_1\|}$$

$$u_k = a_k - \sum_{i=1}^{k-1} (q_i^T a_k) q_i, \quad q_k = \frac{u_k}{\|u_k\|}$$

**Key Points**
- Classical Gram-Schmidt (CGS) is intuitive but numerically unstable, since rounding errors accumulate and orthogonality among computed $q_i$ vectors degrades.
- Modified Gram-Schmidt (MGS) reorders operations to subtract projections sequentially and immediately, improving numerical stability while producing mathematically equivalent results in exact arithmetic. [Unverified: exact stability margins depend on implementation and matrix conditioning]

#### 2. Householder Reflections

This method applies a sequence of orthogonal reflection matrices to zero out sub-diagonal entries of $A$, transforming it directly into upper triangular form.

A Householder reflector is defined as:

$$H = I - 2\frac{vv^T}{v^Tv}$$

where $v$ is chosen so that $H$ reflects a target vector onto a coordinate axis. Applying a sequence $H_n \cdots H_2 H_1 A = R$ yields:

$$Q = H_1 H_2 \cdots H_n$$

**Key Points**
- Householder reflections are generally considered the most numerically stable method for dense matrices, since they rely on orthogonal transformations that preserve norms exactly (up to floating-point precision).
- This is the default method in most production numerical libraries (e.g., LAPACK's `dgeqrf` routine). [Unverified: specific library internals may vary by version]

#### 3. Givens Rotations

Givens rotations zero out individual sub-diagonal entries one at a time using 2D rotation matrices embedded in the identity matrix. A single Givens rotation has the form:

$$G(i, j, \theta) = \begin{pmatrix} \cos\theta & \sin\theta \\ -\sin\theta & \cos\theta \end{pmatrix} \text{ acting on rows } i, j$$

**Key Points**
- Particularly efficient for sparse matrices, since rotations can target only nonzero entries without disturbing existing zeros elsewhere.
- Commonly used in updating QR decompositions incrementally, such as when rows are added or removed from $A$.

### Comparison of Methods

| Method | Stability | Cost (dense $m \times n$) | Best Use Case |
|---|---|---|---|
| Classical Gram-Schmidt | Poor | $O(mn^2)$ | Rarely used in practice |
| Modified Gram-Schmidt | Moderate | $O(mn^2)$ | Iterative methods (e.g., Arnoldi) |
| Householder | High | $O(mn^2 - n^3/3)$ | General dense factorization |
| Givens Rotations | High | $O(mn^2)$ (sparse-optimized) | Sparse or structured matrices |

[Inference: relative cost figures assume standard dense implementations; actual performance depends on hardware, BLAS backend, and matrix structure]

### Process Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 260">
  <text x="400" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">QR Decomposition Method Selection (svg_diagram)</text>

  <rect x="30" y="60" width="160" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="110" y="85" font-size="12" text-anchor="middle" fill="#1a1a1a">Input Matrix A</text>
  <text x="110" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">(m x n)</text>

  <rect x="260" y="20" width="180" height="55" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="350" y="42" font-size="12" text-anchor="middle" fill="#1a1a1a">Dense, general use</text>
  <text x="350" y="60" font-size="12" text-anchor="middle" fill="#1a1a1a">→ Householder</text>

  <rect x="260" y="100" width="180" height="55" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="350" y="122" font-size="12" text-anchor="middle" fill="#1a1a1a">Sparse / structured</text>
  <text x="350" y="140" font-size="12" text-anchor="middle" fill="#1a1a1a">→ Givens Rotations</text>

  <rect x="260" y="180" width="180" height="55" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="350" y="202" font-size="12" text-anchor="middle" fill="#1a1a1a">Iterative subspace</text>
  <text x="350" y="220" font-size="12" text-anchor="middle" fill="#1a1a1a">→ Modified Gram-Schmidt</text>

  <rect x="540" y="90" width="200" height="70" rx="8" fill="#f3e8fd" stroke="#a142f4" stroke-width="1.5" />
  <text x="640" y="115" font-size="12" text-anchor="middle" fill="#1a1a1a">Output: Q (orthonormal)</text>
  <text x="640" y="133" font-size="12" text-anchor="middle" fill="#1a1a1a">R (upper triangular)</text>
  <text x="640" y="151" font-size="12" text-anchor="middle" fill="#1a1a1a">A = QR</text>

  <line x1="190" y1="90" x2="255" y2="48" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow1)" />
  <line x1="190" y1="90" x2="255" y2="128" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow1)" />
  <line x1="190" y1="90" x2="255" y2="208" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow1)" />

  <line x1="440" y1="48" x2="535" y2="110" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow1)" />
  <line x1="440" y1="128" x2="535" y2="128" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow1)" />
  <line x1="440" y1="208" x2="535" y2="150" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow1)" />

  </svg>

### Worked Example (Householder)

Given:

$$A = \begin{pmatrix} 1 & -1 \\ 0 & 1 \\ 1 & 0 \end{pmatrix}$$

**Step 1** — Compute the Householder vector for the first column $a_1 = (1, 0, 1)^T$:

$$\alpha = -\text{sign}(a_{11}) \|a_1\| = -\sqrt{2}$$

$$v = a_1 - \alpha e_1 = (1 + \sqrt{2}, 0, 1)^T$$

**Step 2** — Form $H_1 = I - 2\frac{vv^T}{v^Tv}$ and apply it to $A$ to zero out entries below the first pivot.

**Step 3** — Repeat for the trailing submatrix to zero out remaining sub-diagonal entries, accumulating $Q = H_1 H_2 \cdots$.

**Output**

$$R \approx \begin{pmatrix} -\sqrt{2} & 0.71 \\ 0 & -1.22 \end{pmatrix}, \quad Q \approx \begin{pmatrix} -0.71 & -0.41 \\ 0 & -0.82 \\ -0.71 & 0.41 \end{pmatrix}$$

[Unverified: values rounded to two decimal places; exact computation depends on sign conventions used]

### Applications in Machine Learning

**Key Points**
- **Linear regression**: QR decomposition solves least-squares problems $\min_x \|Ax - b\|_2$ more stably than the normal equations approach ($A^TAx = A^Tb$), since it avoids explicitly forming $A^TA$, which can worsen conditioning.
- **Eigenvalue algorithms**: The QR algorithm (iterative use of QR decomposition) underlies many eigenvalue solvers used in dimensionality reduction techniques like PCA.
- **Gram-Schmidt in optimization**: Orthogonalization steps appear in methods such as conjugate gradient and Krylov subspace techniques used for large-scale optimization in training pipelines.
- **Neural network weight initialization**: Orthogonal initialization schemes sometimes use QR decomposition on random matrices to produce orthogonal weight matrices, which [Inference] may help mitigate vanishing/exploding gradient issues in deep networks, though this does not eliminate such issues in all architectures.

### Numerical Stability Considerations

- Householder-based QR is preferred in most numerical libraries because it maintains orthogonality of $Q$ closely under floating-point arithmetic, reducing drift compared to classical Gram-Schmidt.
- When $A$ is rank-deficient or nearly rank-deficient, standard QR may produce an $R$ with very small diagonal entries; **pivoted QR** (column-pivoting QR) reorders columns to improve stability and can help reveal numerical rank, though it does not guarantee an exact rank determination in the presence of floating-point noise.
- Behavior of specific solver implementations may vary across libraries (NumPy, SciPy, LAPACK, cuSOLVER), and results should be validated empirically for critical applications.

### Relationship to Other Decompositions

$$A = QR \quad \text{vs.} \quad A = U\Sigma V^T \text{ (SVD)} \quad \text{vs.} \quad A = LU$$

- QR is generally cheaper than SVD and is preferred when only an orthogonal basis (not singular values) is needed.
- Unlike LU decomposition, QR does not require pivoting for numerical stability in the Householder formulation, since orthogonal transformations preserve conditioning.
- SVD provides more information (singular values, rank, best low-rank approximations) at higher computational cost, making QR a common precursor step or lighter-weight alternative depending on the task.

### Conclusion

QR decomposition remains a foundational tool bridging theoretical linear algebra and practical numerical computing in machine learning. Its three main computational routes — Gram-Schmidt, Householder, and Givens — offer different tradeoffs in stability, cost, and applicability to dense versus sparse data, with Householder reflections generally serving as the default choice for general-purpose dense factorization.

**Related Topics**
- Least Squares via QR Decomposition
- The QR Algorithm for Eigenvalue Computation
- Singular Value Decomposition (SVD)
- Pivoted QR and Numerical Rank Determination
- Orthogonal Matrices and Their Properties
- Krylov Subspace Methods and Arnoldi Iteration
- Cholesky Decomposition for Positive Definite Matrices
- Condition Numbers and Numerical Stability in Linear Systems