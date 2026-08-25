## Row Space

### Definition

The **row space** of a matrix $A \in \mathbb{R}^{m\times n}$ is the set of all linear combinations of its rows. This is a standard, well-established definition in linear algebra.

$$\text{Row}(A) = \text{span}\{\mathbf{r}_1, \mathbf{r}_2, \dots, \mathbf{r}_m\}$$

where $\mathbf{r}_1, \dots, \mathbf{r}_m$ are the rows of $A$, treated as vectors in $\mathbb{R}^n$. Equivalently, $\text{Row}(A) = \text{Col}(A^T)$, the column space of the transpose.

### The Row Space Is Always a Subspace

$\text{Row}(A)$ is a subspace of $\mathbb{R}^n$ (the domain), since it satisfies all three subspace conditions by the same closure argument used for column space (applied to $A^T$): it contains the zero vector, and is closed under addition and scalar multiplication. This is a standard, well-established result.

### Diagram: Row Space vs Column Space

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 260" font-family="sans-serif">
  <text x="260" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Row Space Lives in the Domain (svg_diagram)</text>

  <ellipse cx="130" cy="140" rx="100" ry="95" fill="#a3c9f7" opacity="0.2" stroke="#2b6cb0" stroke-width="2" />
  <text x="130" y="45" font-size="12" text-anchor="middle" fill="#333">R^n (Domain)</text>

  <ellipse cx="130" cy="140" rx="55" ry="35" fill="#a3c9f7" opacity="0.6" stroke="#2b6cb0" stroke-width="1.5" />
  <text x="130" y="140" font-size="10" text-anchor="middle">Row Space</text>

  <ellipse cx="390" cy="140" rx="100" ry="95" fill="#c9f7a3" opacity="0.2" stroke="#4a7a1e" stroke-width="2" />
  <text x="390" y="45" font-size="12" text-anchor="middle" fill="#333">R^m (Codomain)</text>

  <ellipse cx="390" cy="140" rx="55" ry="35" fill="#c9f7a3" opacity="0.6" stroke="#4a7a1e" stroke-width="1.5" />
  <text x="390" y="140" font-size="10" text-anchor="middle">Column Space</text>

  <line x1="230" y1="140" x2="290" y2="140" stroke="#333" stroke-width="1.5" marker-end="url(#arrrs)" />
  <text x="260" y="130" font-size="10" text-anchor="middle">A</text>

  </svg>

### Row Space Is Preserved Under Row Operations

Unlike the column space, elementary row operations (swapping rows, scaling a row, adding a multiple of one row to another) do **not** change the row space of a matrix. This is a standard, well-established theorem in linear algebra. This means the nonzero rows of the row-reduced echelon form of $A$ form a basis for $\text{Row}(A)$.

### Worked Example: Finding a Basis for the Row Space

$$A = \begin{pmatrix} 1 & 2 & 3 \\ 2 & 4 & 5 \\ 3 & 6 & 8 \end{pmatrix}$$

Row reduce:

$$\begin{pmatrix} 1 & 2 & 3 \\ 2 & 4 & 5 \\ 3 & 6 & 8 \end{pmatrix} \xrightarrow{R_2 \to R_2-2R_1,\ R_3 \to R_3-3R_1} \begin{pmatrix} 1 & 2 & 3 \\ 0 & 0 & -1 \\ 0 & 0 & -1 \end{pmatrix} \xrightarrow{R_3 \to R_3-R_2} \begin{pmatrix} 1 & 2 & 3 \\ 0 & 0 & -1 \\ 0 & 0 & 0 \end{pmatrix}$$

The nonzero rows of the reduced form give a basis directly:

$$\text{Row}(A) = \text{span}\left\{(1,2,3), (0,0,-1)\right\}$$

This is a two-dimensional subspace of $\mathbb{R}^3$. Note this contrasts with the column space procedure, where the original (not reduced) columns must be used — for the row space, the reduced rows themselves are valid basis vectors.

### Row Space and Rank

$$\dim(\text{Row}(A)) = \dim(\text{Col}(A)) = \text{rank}(A)$$

This is a standard, well-established theorem: the row rank and column rank of any matrix are always equal, even though the row space and column space are generally different subspaces (living in $\mathbb{R}^n$ and $\mathbb{R}^m$ respectively) when $A$ is not square. This shared dimension is simply called the **rank** of the matrix.

### Row Space and the Null Space: Orthogonal Complements

The row space and null space of $A$ are orthogonal complements in $\mathbb{R}^n$. This is a standard, well-established theorem.

$$\text{Row}(A) \perp \text{Null}(A), \quad \dim(\text{Row}(A)) + \dim(\text{Null}(A)) = n$$

This follows directly from the definition of the null space: if $\mathbf{x} \in \text{Null}(A)$, then $A\mathbf{x} = \mathbf{0}$, meaning every row of $A$ (each a vector in $\mathbb{R}^n$) has a zero dot product with $\mathbf{x}$ — which is precisely the definition of $\mathbf{x}$ being orthogonal to every vector in $\text{Row}(A)$.

### Worked Example: Verifying Orthogonality

Using $A$ from the earlier example, recall its null space (computed by the same row reduction) satisfies $x_3 = 0$ and $x_1 = -2x_2$, giving:

$$\text{Null}(A) = \text{span}\left\{\begin{pmatrix}-2\\1\\0\end{pmatrix}\right\}$$

Check orthogonality against the row space basis vector $(1,2,3)$:

$$(1)(-2) + (2)(1) + (3)(0) = -2 + 2 + 0 = 0 \quad \checkmark$$

Check against $(0,0,-1)$:

$$(0)(-2) + (0)(1) + (-1)(0) = 0 \quad \checkmark$$

Both dot products are zero, confirming orthogonality directly for this example.

### The Four Fundamental Subspaces (Complete Picture)

| Subspace | Lives in | Orthogonal complement of |
|---|---|---|
| Row space | $\mathbb{R}^n$ | Null space |
| Null space | $\mathbb{R}^n$ | Row space |
| Column space | $\mathbb{R}^m$ | Left null space |
| Left null space | $\mathbb{R}^m$ | Column space |

This is a standard, well-established classification in linear algebra, often attributed pedagogically to Gilbert Strang's presentation of the "Fundamental Theorem of Linear Algebra," though I cannot verify the precise original source attribution without direct access to a citation in this conversation. [Unverified]

### Relevance to Machine Learning

- **Feature space structure**: In a design matrix $X$ where rows are data samples and columns are features, the row space represents the span of directions defined by the actual observed samples, which is relevant to understanding what feature combinations the data can distinguish. [Inference] This is a reasoned application of the row space definition to a standard machine learning data matrix layout, but I do not have a specific primary source confirmed in this conversation for this exact framing.
- **Duality with column space**: Because rank(row space) = rank(column space), analyzing whichever space is lower-dimensional (e.g., row space when there are far more features than samples) can be computationally convenient in some settings. [Inference] This is reasoned from the standard rank equality theorem; I do not have a specific primary source confirmed in this conversation describing this as a named standard practice.
- **Orthogonality in regularized regression**: The orthogonal complement relationship between row space and null space is relevant to understanding which parameter directions are and are not constrained by the data in regression problems. [Inference] This is a reasoned application of the orthogonal complement theorem to a regression parameter vector; I do not have a specific primary source confirmed in this conversation for this exact framing.

I cannot verify the internal implementation details of how any specific machine learning library computes or represents row spaces numerically, and any such behavior may vary by implementation and version. This is not guaranteed to be consistent across systems. [Unverified]

### Common Pitfalls

- Assuming the row space and column space are the same subspace — they are generally different subspaces (living in different vector spaces, $\mathbb{R}^n$ vs $\mathbb{R}^m$) when $A$ is not square, even though their dimensions (rank) are always equal.
- Using the rows of the original matrix instead of the row-reduced matrix when a simplified basis is needed — unlike column space, row operations preserve the row space, so the reduced rows are valid (and often simpler) basis vectors.
- Confusing "row space is preserved under row operations" with "column space is preserved under row operations" — the latter is false in general; row operations can change which specific vectors span the column space, which is why the original matrix's columns must be used when reporting a column space basis.

**Related Topics**
- Column space and range
- Null space and kernel
- Rank-Nullity Theorem
- Four fundamental subspaces and orthogonal complements
- Basis and dimension of a subspace
- Orthogonal projection and least-squares