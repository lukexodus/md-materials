## Column Space and Range

### Definition

The **column space** of a matrix $A \in \mathbb{R}^{m\times n}$ is the set of all linear combinations of its columns, equivalently the set of all possible outputs of $A\mathbf{x}$ as $\mathbf{x}$ ranges over $\mathbb{R}^n$. This is a standard, well-established definition in linear algebra.

$$\text{Col}(A) = \{A\mathbf{x} : \mathbf{x} \in \mathbb{R}^n\} = \text{span}\{\mathbf{a}_1, \mathbf{a}_2, \dots, \mathbf{a}_n\}$$

where $\mathbf{a}_1, \dots, \mathbf{a}_n$ are the columns of $A$.

The term **range** is used interchangeably with column space when referring to a linear transformation $T: V \to W$, defined as $\text{Range}(T) = \{T(\mathbf{v}) : \mathbf{v} \in V\}$.

### The Column Space Is Always a Subspace

$\text{Col}(A)$ satisfies all three subspace conditions and is a subspace of $\mathbb{R}^m$ (the codomain). This is a standard, well-established theorem.

**Zero vector:** $A\mathbf{0} = \mathbf{0} \in \text{Col}(A)$.

**Closed under addition:** If $\mathbf{y}_1 = A\mathbf{x}_1$ and $\mathbf{y}_2 = A\mathbf{x}_2$ for some $\mathbf{x}_1, \mathbf{x}_2 \in \mathbb{R}^n$, then:
$$\mathbf{y}_1 + \mathbf{y}_2 = A\mathbf{x}_1 + A\mathbf{x}_2 = A(\mathbf{x}_1+\mathbf{x}_2) \in \text{Col}(A)$$

**Closed under scalar multiplication:** If $\mathbf{y} = A\mathbf{x}$, then:
$$k\mathbf{y} = k(A\mathbf{x}) = A(k\mathbf{x}) \in \text{Col}(A)$$

Both proofs follow directly from the linearity of matrix multiplication and hold generally for any matrix $A$.

### Diagram: Column Space as Span of Columns

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 260" font-family="sans-serif">
  <text x="250" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Column Space as Span of Columns (svg_diagram)</text>

  <g stroke="#888" stroke-width="1">
    <line x1="60" y1="230" x2="440" y2="230" />
    <line x1="60" y1="230" x2="60" y2="40" />
  </g>

  
  <line x1="60" y1="230" x2="180" y2="120" stroke="#2b6cb0" stroke-width="3" marker-end="url(#arrc)" />
  <text x="190" y="115" font-size="11" fill="#2b6cb0">a1</text>

  <line x1="60" y1="230" x2="260" y2="160" stroke="#c05621" stroke-width="3" marker-end="url(#arrc)" />
  <text x="270" y="165" font-size="11" fill="#c05621">a2</text>

  
  <polygon points="60,230 180,120 260,160 140,230" fill="#a3c9f7" opacity="0.3" />
  <text x="150" y="200" font-size="11" fill="#333">Col(A) = span{a1, a2}</text>

  </svg>

### Worked Example: Computing the Column Space

Find $\text{Col}(A)$ for:

$$A = \begin{pmatrix} 1 & 2 & 3 \\ 2 & 4 & 5 \\ 3 & 6 & 8 \end{pmatrix}$$

Row reduce to identify pivot columns:

$$\begin{pmatrix} 1 & 2 & 3 \\ 2 & 4 & 5 \\ 3 & 6 & 8 \end{pmatrix} \xrightarrow{R_2 \to R_2 - 2R_1,\ R_3 \to R_3 - 3R_1} \begin{pmatrix} 1 & 2 & 3 \\ 0 & 0 & -1 \\ 0 & 0 & -1 \end{pmatrix} \xrightarrow{R_3 \to R_3 - R_2} \begin{pmatrix} 1 & 2 & 3 \\ 0 & 0 & -1 \\ 0 & 0 & 0 \end{pmatrix}$$

Pivots appear in columns 1 and 3. The column space is spanned by the **original** columns 1 and 3 of $A$ (not the reduced ones):

$$\text{Col}(A) = \text{span}\left\{\begin{pmatrix}1\\2\\3\end{pmatrix}, \begin{pmatrix}3\\5\\8\end{pmatrix}\right\}$$

This is a two-dimensional subspace (a plane through the origin) in $\mathbb{R}^3$. Column 2 is redundant since it equals $2\times$ column 1.

### Rank as the Dimension of the Column Space

The **rank** of $A$ is defined as the dimension of its column space:

$$\text{rank}(A) = \dim(\text{Col}(A))$$

This is a standard, well-established definition. In the example above, $\text{rank}(A) = 2$, matching the number of pivot columns found during row reduction.

### Column Space and Consistency of $A\mathbf{x} = \mathbf{b}$

A system $A\mathbf{x} = \mathbf{b}$ has a solution if and only if $\mathbf{b} \in \text{Col}(A)$. This is a standard, well-established result, following directly from the definition of column space as the set of all possible outputs $A\mathbf{x}$.

$$A\mathbf{x} = \mathbf{b} \text{ is consistent} \iff \mathbf{b} \in \text{Col}(A)$$

If $\mathbf{b}$ lies outside $\text{Col}(A)$, no exact solution exists, which is the standard motivation for least-squares approximation (finding the closest point in $\text{Col}(A)$ to $\mathbf{b}$).

### Column Space vs. Row Space vs. Null Space

| Subspace | Lives in | Defined as |
|---|---|---|
| Column space | $\mathbb{R}^m$ (codomain) | span of columns of $A$ |
| Row space | $\mathbb{R}^n$ (domain) | span of rows of $A$ |
| Null space | $\mathbb{R}^n$ (domain) | $\{\mathbf{x} : A\mathbf{x}=\mathbf{0}\}$ |
| Left null space | $\mathbb{R}^m$ (codomain) | $\{\mathbf{y} : A^T\mathbf{y}=\mathbf{0}\}$ |

This is a standard, well-established classification, often referred to collectively as the **four fundamental subspaces** of a matrix.

A key standard theorem: the row space and null space are orthogonal complements in $\mathbb{R}^n$, and the column space and left null space are orthogonal complements in $\mathbb{R}^m$.

### Diagram: The Four Fundamental Subspaces

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 260" font-family="sans-serif">
  <text x="260" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Four Fundamental Subspaces (svg_diagram)</text>

  
  <ellipse cx="130" cy="140" rx="100" ry="95" fill="#a3c9f7" opacity="0.2" stroke="#2b6cb0" stroke-width="2" />
  <text x="130" y="45" font-size="12" text-anchor="middle" fill="#333">R^n (Domain)</text>

  <ellipse cx="100" cy="110" rx="55" ry="35" fill="#a3c9f7" opacity="0.5" stroke="#2b6cb0" stroke-width="1.5" />
  <text x="100" y="110" font-size="10" text-anchor="middle">Row Space</text>

  <ellipse cx="160" cy="180" rx="55" ry="35" fill="#f7c9a3" opacity="0.5" stroke="#c05621" stroke-width="1.5" />
  <text x="160" y="180" font-size="10" text-anchor="middle">Null Space</text>

  
  <ellipse cx="390" cy="140" rx="100" ry="95" fill="#c9f7a3" opacity="0.2" stroke="#4a7a1e" stroke-width="2" />
  <text x="390" y="45" font-size="12" text-anchor="middle" fill="#333">R^m (Codomain)</text>

  <ellipse cx="360" cy="110" rx="55" ry="35" fill="#c9f7a3" opacity="0.5" stroke="#4a7a1e" stroke-width="1.5" />
  <text x="360" y="110" font-size="10" text-anchor="middle">Column Space</text>

  <ellipse cx="420" cy="180" rx="55" ry="35" fill="#e2c9f7" opacity="0.5" stroke="#7a4ea6" stroke-width="1.5" />
  <text x="420" y="180" font-size="10" text-anchor="middle">Left Null Space</text>

  <line x1="230" y1="130" x2="290" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrf)" />
  <text x="260" y="120" font-size="10" text-anchor="middle">A</text>

  </svg>

### Column Space and Full Rank

For $A \in \mathbb{R}^{m\times n}$:

- If $\text{rank}(A) = n$ (full column rank), the columns are linearly independent, and $\text{Null}(A) = \{\mathbf{0}\}$.
- If $\text{rank}(A) = m$ (full row rank), $\text{Col}(A) = \mathbb{R}^m$, meaning $A\mathbf{x}=\mathbf{b}$ has a solution for every $\mathbf{b}$.
- If $A$ is square and $\text{rank}(A) = n$, both conditions hold simultaneously, $\text{Col}(A) = \mathbb{R}^n$, and $A$ is invertible.

This is a standard, well-established set of results connecting rank, column space, and invertibility.

### Relevance to Machine Learning

- **Linear regression fit**: In $X\theta = y$, if $y \notin \text{Col}(X)$, no exact solution exists, which is the standard motivation for least-squares regression, i.e., finding $\hat\theta$ such that $X\hat\theta$ is the projection of $y$ onto $\text{Col}(X)$. [Inference] This follows from the standard definition of column space applied to the linear regression prediction equation; I do not have a specific primary source confirmed in this conversation for this exact phrasing.
- **Neural network layer expressiveness**: The column space of a weight matrix describes the set of outputs a linear layer can produce from all possible inputs, which relates to representational capacity at that layer. [Inference] This is a reasoned application of the column space definition to a linear layer's weight matrix. I do not have a specific primary source confirmed in this conversation describing this as a standard, named concept in neural network literature.
- **Low-rank approximations**: Techniques such as truncated SVD approximate a matrix using a lower-dimensional column space, which underlies dimensionality reduction methods like PCA. [Inference] This is a reasoned connection based on the standard definition of column space and rank; I do not have a specific primary source confirmed in this conversation for this precise framing.
- **Feature redundancy**: A design matrix with linearly dependent columns has $\text{rank}(X) < n$, meaning the column space does not span the full parameter space, which relates to multicollinearity issues in regression. [Inference] This follows from the standard definition of rank and column space, but I do not have a specific primary source confirmed in this conversation describing this exact connection in these terms.

I cannot verify the internal implementation details of how any specific machine learning library computes or represents column spaces numerically (e.g., via QR or SVD-based rank/column space functions), and any such behavior may vary by implementation and version and is not guaranteed. [Unverified]

### Common Pitfalls

- Using the columns of the **row-reduced** matrix instead of the original matrix when reporting a basis for the column space — row reduction identifies which columns are pivot columns, but the actual spanning vectors must come from the original matrix, since row operations can change column relationships in ways that alter the space spanned by the reduced columns. [Inference] This follows from the standard method for finding a column space basis via row reduction, reasoned from the fact that row operations preserve null space and row space relationships but not column space directly.
- Confusing $\text{Col}(A) = \mathbb{R}^m$ with $A$ being invertible — full row rank ensures every $\mathbf{b}$ is reachable, but this alone does not imply invertibility unless $A$ is also square with full column rank.
- Assuming the column space and row space have the same dimension count in general only refers to their common value as the rank — this is true for the **dimensions** (rank), but the two spaces themselves live in different vector spaces ($\mathbb{R}^m$ vs $\mathbb{R}^n$) when $A$ is not square, and are not the same space.

**Related Topics**
- Null space and kernel
- Row space and the four fundamental subspaces
- Rank-Nullity Theorem
- Least-squares approximation and orthogonal projection
- Singular Value Decomposition (SVD) and low-rank approximation
- Basis and dimension of a subspace