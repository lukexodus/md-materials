## Matrix Representation of Linear Transformations

### Motivation

A linear map $T: V \to W$ between abstract vector spaces is defined without reference to coordinates. Once bases are chosen for $V$ and $W$, however, $T$ can be represented concretely as a matrix, turning abstract linear map evaluation into ordinary matrix-vector multiplication. This concreteness is what makes linear maps computationally tractable.

### Constructing the Matrix

Let $V$ be $n$-dimensional with ordered basis $B = \{v_1, \dots, v_n\}$, and let $W$ be $m$-dimensional with ordered basis $C = \{w_1, \dots, w_m\}$.

For each basis vector $v_j$, its image $T(v_j)$ lies in $W$ and can be written uniquely as a linear combination of $C$:

$$
T(v_j) = \sum_{i=1}^m a_{ij} w_i
$$

The **matrix of $T$ relative to bases $B$ and $C$**, denoted $[T]_C^B$, is the $m \times n$ matrix whose $j$-th column consists of the coordinates $(a_{1j}, a_{2j}, \dots, a_{mj})$:

$$
[T]_C^B = \begin{bmatrix} \vert & \vert & & \vert \\ [T(v_1)]_C & [T(v_2)]_C & \cdots & [T(v_n)]_C \\ \vert & \vert & & \vert \end{bmatrix}
$$

This construction is the standard definition of a matrix representation and follows directly from expressing each $T(v_j)$ in the target basis.

### Using the Matrix to Evaluate T

If $v \in V$ has coordinate vector $[v]_B$ relative to $B$, then:

$$
[T(v)]_C = [T]_C^B \, [v]_B
$$

This equation is the entire point of the construction: matrix-vector multiplication in coordinates reproduces the abstract action of $T$.

**Example:** Let $T: \mathbb{R}^2 \to \mathbb{R}^3$ be defined by $T(x, y) = (x + y, \, 2x - y, \, 3y)$.

Using standard bases $B = \{(1,0), (0,1)\}$ for $\mathbb{R}^2$ and $C = \{(1,0,0),(0,1,0),(0,0,1)\}$ for $\mathbb{R}^3$:

$$
T(1,0) = (1, 2, 0), \quad T(0,1) = (1, -1, 3)
$$

$$
[T]_C^B = \begin{bmatrix} 1 & 1 \\ 2 & -1 \\ 0 & 3 \end{bmatrix}
$$

Check: $T(2, 3) = (5, 1, 9)$. Using the matrix:

$$
\begin{bmatrix} 1 & 1 \\ 2 & -1 \\ 0 & 3 \end{bmatrix} \begin{bmatrix} 2 \\ 3 \end{bmatrix} = \begin{bmatrix} 5 \\ 1 \\ 9 \end{bmatrix}
$$

This matches direct evaluation, confirming the construction for this example.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Matrix Representation Process (svg_diagram)</text>

  <rect x="30" y="70" width="150" height="60" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="105" y="105" text-anchor="middle" font-size="12" fill="#1a1a1a">v ∈ V</text>

  <line x1="180" y1="100" x2="250" y2="100" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow3)" />
  <text x="215" y="90" text-anchor="middle" font-size="11" fill="#1a1a1a">[·]_B</text>

  <rect x="250" y="70" width="150" height="60" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="325" y="105" text-anchor="middle" font-size="12" fill="#1a1a1a">[v]_B (coords)</text>

  <line x1="325" y1="130" x2="325" y2="190" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow3)" />
  <text x="380" y="165" text-anchor="middle" font-size="11" fill="#1a1a1a">multiply by [T]</text>

  <rect x="250" y="190" width="150" height="60" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="325" y="225" text-anchor="middle" font-size="12" fill="#1a1a1a">[T(v)]_C (coords)</text>

  <line x1="250" y1="220" x2="180" y2="220" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow3)" />
  <text x="215" y="210" text-anchor="middle" font-size="11" fill="#1a1a1a">[·]_C⁻¹</text>

  <rect x="30" y="190" width="150" height="60" rx="8" fill="#fbe4f0" stroke="#c43b8a" stroke-width="1.5" />
  <text x="105" y="225" text-anchor="middle" font-size="12" fill="#1a1a1a">T(v) ∈ W</text>

  <line x1="105" y1="130" x2="105" y2="190" stroke="#888" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#arrow3)" />
  <text x="55" y="165" text-anchor="middle" font-size="11" fill="#555">T (direct)</text>

  </svg>

### Dependence on Basis Choice

The matrix $[T]_C^B$ depends entirely on the chosen bases $B$ and $C$. The same linear map $T$ has different matrix representations under different bases. This is a defining feature of the construction, not a flaw — the abstract map $T$ is basis-independent, but its matrix form is not.

### Change of Basis for Endomorphisms

For $T: V \to V$ (an endomorphism, using the same basis for domain and codomain), if $B_1$ and $B_2$ are two bases for $V$ and $P$ is the change-of-basis matrix from $B_2$-coordinates to $B_1$-coordinates, then:

$$
[T]_{B_2} = P^{-1} [T]_{B_1} P
$$

Matrices related this way are called **similar matrices**. Similar matrices represent the same linear map under different bases, and they share the same:

- Determinant
- Trace
- Eigenvalues
- Rank
- Characteristic polynomial

These invariance properties follow algebraically from the similarity relation and are standard, provable results.

### Composition and Matrix Multiplication

If $T: V \to W$ has matrix $A$ (relative to bases $B_V, B_W$) and $S: W \to U$ has matrix $B$ (relative to bases $B_W, B_U$), then $S \circ T: V \to U$ has matrix:

$$
[S \circ T] = BA
$$

This is the algebraic justification for why matrix multiplication is defined the way it is: it mirrors composition of linear maps. This is frequently cited as the primary motivation behind the (otherwise non-obvious) matrix multiplication rule.

### Invertibility and Inverse Matrices

$T: V \to W$ is invertible (an isomorphism) if and only if its matrix $[T]_C^B$ is square and invertible, in which case:

$$
[T^{-1}]_B^C = \left([T]_C^B\right)^{-1}
$$

A square matrix is invertible if and only if its determinant is nonzero, equivalently if and only if its columns are linearly independent, equivalently if and only if its rank equals its dimension. These equivalences are standard results in linear algebra.

### Special Matrix Representations

**Diagonal matrices:** If $B$ consists of eigenvectors of $T$ (assuming $T: V \to V$ is diagonalizable), then $[T]_B$ is diagonal, with eigenvalues on the diagonal. Not every endomorphism is diagonalizable — this depends on whether $V$ admits a basis of eigenvectors of $T$.

**Orthogonal/unitary matrices:** If $B$ and $C$ are orthonormal bases and $T$ preserves inner products (an isometry), $[T]_C^B$ is orthogonal (real case) or unitary (complex case), satisfying $A^T A = I$ or $A^* A = I$ respectively.

**Symmetric matrices:** If $T$ is self-adjoint with respect to an inner product and $B$ is orthonormal, $[T]_B$ is symmetric (real case) or Hermitian (complex case).

### Rectangular vs. Square Matrices

- If $\dim(V) \neq \dim(W)$, the matrix $[T]_C^B$ is necessarily rectangular ($m \times n$ with $m \neq n$), and $T$ cannot be invertible in the standard bijective sense.
- If $\dim(V) = \dim(W)$, the matrix is square, but this alone does not guarantee invertibility — the matrix must also be full rank.

### Relevance to Machine Learning

- **Weight matrices:** In a neural network layer, the weight matrix is exactly the matrix representation of a linear map between the input space (basis = input feature coordinates) and output space (basis = output/hidden unit coordinates).
- **Basis changes in preprocessing:** Techniques like PCA construct a new basis (principal components) and represent data in that basis; the transformation matrix used for this change is a matrix representation of a linear map between the original feature space and the PCA-derived space.
- [Inference] When practitioners describe "reparameterizing" a model or "rotating" a representation space, this can often be understood as applying a change-of-basis matrix to an underlying linear map, though the precise terminology and implementation vary by context and are not confirmed here for any specific method or paper.

I cannot verify how any specific ML framework, library, or paper implements matrix representations internally without consulting their source code or documentation directly.

### Common Pitfalls

- **Forgetting matrices are basis-dependent:** Comparing matrices from different bases without accounting for the change-of-basis transformation leads to incorrect conclusions about the underlying map.
- **Assuming square implies invertible:** A square matrix can still be singular (non-invertible) if it lacks full rank.
- **Mixing up row and column conventions:** Whether $T(v_j)$ coordinates form columns (standard convention used here) or rows depends on convention; inconsistency causes computational errors.
- **Conflating similarity with equality:** Similar matrices represent the same abstract map but are generally different matrices numerically.

**Related Topics**
- Eigenvalues, eigenvectors, and diagonalization
- Change of basis in depth
- Orthogonal and unitary transformations
- Singular Value Decomposition (SVD)
- Quotient spaces and the First Isomorphism Theorem
- Dual spaces and dual maps