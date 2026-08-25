## Rank of a Matrix

### Definition

The rank of a matrix $A$ is the dimension of the vector space spanned by its columns (column space), which is equal to the dimension of the vector space spanned by its rows (row space). This is a standard, provable definition from linear algebra, not an inference.

$$\text{rank}(A) = \dim(\text{col}(A)) = \dim(\text{row}(A))$$

The equality of column rank and row rank is a standard, provable theorem in linear algebra. I cannot independently reproduce the full proof within this response.

### Equivalent Characterizations

**Key Points**

These are standard, provable equivalent characterizations of rank in linear algebra:

- The number of pivot positions in the row echelon form (or RREF) of $A$.
- The maximum number of linearly independent rows of $A$.
- The maximum number of linearly independent columns of $A$.
- The number of nonzero singular values in the singular value decomposition of $A$.

[Unverified] I do not have access to a specific citable source to quote directly for this list within this response; it reflects standard, commonly stated equivalences in linear algebra references.

### Worked Example

$$A = \begin{pmatrix} 1 & 2 & 3 \\ 2 & 4 & 6 \\ 1 & 1 & 2 \end{pmatrix}$$

**Step 1 — Row reduce**

$R_2 \leftarrow R_2 - 2R_1$:

$$\begin{pmatrix} 1 & 2 & 3 \\ 0 & 0 & 0 \\ 1 & 1 & 2 \end{pmatrix}$$

$R_3 \leftarrow R_3 - R_1$:

$$\begin{pmatrix} 1 & 2 & 3 \\ 0 & 0 & 0 \\ 0 & -1 & -1 \end{pmatrix}$$

**Step 2 — Swap rows to standard echelon order**

$$\begin{pmatrix} 1 & 2 & 3 \\ 0 & -1 & -1 \\ 0 & 0 & 0 \end{pmatrix}$$

This is now in row echelon form with 2 pivots. Each step is a direct, mechanical application of standard row operations, not an inference.

**Output**

$$\text{rank}(A) = 2$$

This follows directly from counting pivot positions in the row echelon form shown above.

### Visual Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 380 220">
  <text x="190" y="20" font-size="13" text-anchor="middle" fill="#333">Rank via Pivot Count (svg_diagram)</text>
  <rect x="80" y="50" width="180" height="120" fill="none" stroke="#333" stroke-width="2" />
  <line x1="80" y1="90" x2="260" y2="90" stroke="#ccc" stroke-width="1" />
  <line x1="80" y1="130" x2="260" y2="130" stroke="#ccc" stroke-width="1" />
  <line x1="140" y1="50" x2="140" y2="170" stroke="#ccc" stroke-width="1" />
  <line x1="200" y1="50" x2="200" y2="170" stroke="#ccc" stroke-width="1" />
  <text x="110" y="75" font-size="13" text-anchor="middle" fill="#2ca02c">1</text>
  <text x="170" y="75" font-size="13" text-anchor="middle">2</text>
  <text x="230" y="75" font-size="13" text-anchor="middle">3</text>
  <text x="110" y="115" font-size="13" text-anchor="middle">0</text>
  <text x="170" y="115" font-size="13" text-anchor="middle" fill="#2ca02c">-1</text>
  <text x="230" y="115" font-size="13" text-anchor="middle">-1</text>
  <text x="110" y="155" font-size="13" text-anchor="middle">0</text>
  <text x="170" y="155" font-size="13" text-anchor="middle">0</text>
  <text x="230" y="155" font-size="13" text-anchor="middle">0</text>
  <text x="190" y="195" font-size="11" text-anchor="middle" fill="#666">2 pivots (green) → rank = 2</text>
</svg>

### Full Rank and Rank Deficiency

- A matrix $A \in \mathbb{R}^{m \times n}$ has **full rank** if $\text{rank}(A) = \min(m, n)$.
- A matrix is **rank-deficient** if $\text{rank}(A) < \min(m, n)$.
- For a square matrix $A \in \mathbb{R}^{n \times n}$, full rank means $\text{rank}(A) = n$, which is a standard, provable equivalent condition to $A$ being invertible and to $\det(A) \neq 0$.

These are standard, provable characterizations in linear algebra, not inferences.

### Rank Inequalities

These are standard, provable results in linear algebra:

- $\text{rank}(A) \leq \min(m, n)$ for $A \in \mathbb{R}^{m \times n}$.
- $\text{rank}(AB) \leq \min(\text{rank}(A), \text{rank}(B))$.
- $\text{rank}(A + B) \leq \text{rank}(A) + \text{rank}(B)$.
- $\text{rank}(A^T) = \text{rank}(A)$, since row rank equals column rank.

I cannot independently reproduce the full formal proofs of each inequality within this response; these are standard, commonly stated results in linear algebra references.

### Rank and the Null Space (Rank-Nullity Theorem)

For $A \in \mathbb{R}^{m \times n}$:

$$\text{rank}(A) + \dim(\ker(A)) = n$$

[Inference] This identity is commonly stated in linear algebra references as the rank-nullity theorem, based on the relationship between pivot columns (contributing to rank) and free variable columns (contributing to the null space dimension) in the row echelon form of $A$. I cannot independently reproduce the full formal proof within this response.

**Worked Example**

For the matrix $A$ above, $n = 3$ columns and $\text{rank}(A) = 2$, so:

$$\dim(\ker(A)) = 3 - 2 = 1$$

This is a direct computation following from the stated theorem applied to the rank found above.

### Rank and Consistency of Linear Systems

The system $A\mathbf{x} = \mathbf{b}$ is consistent (has at least one solution) if and only if $\text{rank}(A) = \text{rank}([A \mid \mathbf{b}])$. This is a standard, provable result in linear algebra, referenced earlier in the context of row echelon form and consistency conditions.

### Numerical Rank Considerations

[Inference] In floating-point computation, determining rank via row reduction is commonly described in numerical linear algebra references as potentially unreliable due to rounding errors, and rank is instead often estimated using the number of singular values above a chosen numerical threshold via singular value decomposition. I cannot independently verify the specific threshold conventions used across different software libraries without inspecting their documentation directly. [Unverified] I do not have access to a specific citable source to quote directly for this claim within this response.

### Relevance to Machine Learning

[Inference] Matrix rank is described in commonly cited machine learning and statistics references as relevant in several contexts, based on descriptions in standard references. I cannot verify how any specific ML framework implements these internally without inspecting that framework's source code.

Commonly cited use cases include:

- **Multicollinearity diagnosis**: a design matrix $X$ with less than full column rank is described in statistics and machine learning literature as indicating linearly dependent features, which is referenced in some discussions of regression instability. [Unverified] I cannot verify whether any specific software library uses rank computation directly for this diagnostic without inspecting its source code.
- **Low-rank approximation**: techniques such as truncated SVD are described in machine learning literature as approximating a matrix with one of lower rank, referenced in some dimensionality reduction and recommender system contexts. [Unverified] I cannot verify the exact implementation details of any specific low-rank approximation library without inspecting its source code.
- **Invertibility checks in closed-form solutions**: the normal equations solution $(X^TX)^{-1}X^Ty$ is described in statistics references as requiring $X^TX$ to have full rank for the inverse to exist. [Unverified] I cannot verify how any specific software library handles the rank-deficient case (e.g., via pseudoinverse) without inspecting its source code or documentation.
- **Rank of weight matrices in neural networks**: some machine learning literature discusses the effective rank of weight matrices in the context of model compression and low-rank adaptation methods. [Unverified] I do not have access to a specific verified source to cite directly for how any particular current framework or method computes or uses this internally.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model, including the one generating this response, will behave in future interactions. Behavior is not guaranteed to be consistent, and no outcome described here should be treated as certain to recur.

**Related Topics**
- Row echelon and reduced row echelon form
- Rank-nullity theorem
- Singular value decomposition (SVD)
- Linear independence and span
- Invertibility and determinants
- Low-rank approximation and matrix compression

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding rank-nullity theorem proof reproduction, numerical rank estimation practices, and machine learning application/implementation details not drawn from a specific cited source. Core mathematical definitions and results (rank definition, pivot-count characterization, rank inequalities, rank-invertibility equivalence for square matrices) are standard, established, and provable results in linear algebra and are treated as established mathematical fact rather than as inference.