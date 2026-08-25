## Diagonal Matrices

### Definition

A diagonal matrix is a square matrix in which all off-diagonal entries are zero:

$$(D)_{ij} = 0 \text{ for all } i \neq j$$

Diagonal entries $d_{11}, d_{22}, \ldots, d_{nn}$ may be any value, including zero. This is a standard, provable definition from linear algebra, not an inference.

**Example**

$$D = \begin{pmatrix} 4 & 0 & 0 \\ 0 & -2 & 0 \\ 0 & 0 & 7 \end{pmatrix}$$

### Notation

A diagonal matrix is often written compactly as:

$$D = \text{diag}(d_1, d_2, \ldots, d_n)$$

where $d_1, \ldots, d_n$ are the diagonal entries in order.

### Visual Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 260">
  <text x="150" y="20" font-size="13" text-anchor="middle" fill="#333">Diagonal Matrix Structure (svg_diagram)</text>
  <rect x="60" y="40" width="180" height="180" fill="none" stroke="#333" stroke-width="2" />
  <line x1="60" y1="100" x2="240" y2="100" stroke="#ccc" stroke-width="1" />
  <line x1="60" y1="160" x2="240" y2="160" stroke="#ccc" stroke-width="1" />
  <line x1="120" y1="40" x2="120" y2="220" stroke="#ccc" stroke-width="1" />
  <line x1="180" y1="40" x2="180" y2="220" stroke="#ccc" stroke-width="1" />
  <rect x="60" y="40" width="60" height="60" fill="#2ca02c" opacity="0.25" />
  <rect x="120" y="100" width="60" height="60" fill="#2ca02c" opacity="0.25" />
  <rect x="180" y="160" width="60" height="60" fill="#2ca02c" opacity="0.25" />
  <text x="90" y="75" font-size="15" text-anchor="middle">4</text>
  <text x="150" y="75" font-size="15" text-anchor="middle">0</text>
  <text x="210" y="75" font-size="15" text-anchor="middle">0</text>
  <text x="90" y="135" font-size="15" text-anchor="middle">0</text>
  <text x="150" y="135" font-size="15" text-anchor="middle">-2</text>
  <text x="210" y="135" font-size="15" text-anchor="middle">0</text>
  <text x="90" y="195" font-size="15" text-anchor="middle">0</text>
  <text x="150" y="195" font-size="15" text-anchor="middle">0</text>
  <text x="210" y="195" font-size="15" text-anchor="middle">7</text>
  <text x="150" y="245" font-size="11" text-anchor="middle" fill="#666">Only shaded diagonal entries may be nonzero</text>
</svg>

### Key Points

- The identity matrix $I_n$ is a special case of a diagonal matrix where all diagonal entries equal 1.
- The zero matrix $O$ is a special case of a diagonal matrix where all diagonal entries equal 0.
- A diagonal matrix is automatically symmetric, since $(D)_{ij} = (D)_{ji} = 0$ for all $i \neq j$. This follows directly from the definition, not an inference.

### Diagonal Matrix Multiplication

Multiplying two diagonal matrices of the same size produces another diagonal matrix, where corresponding diagonal entries are simply multiplied:

$$\text{diag}(a_1, \ldots, a_n) \cdot \text{diag}(b_1, \ldots, b_n) = \text{diag}(a_1 b_1, \ldots, a_n b_n)$$

This is a standard, provable result that follows directly from the general matrix multiplication definition applied to matrices with zero off-diagonal entries.

**Example**

$$\text{diag}(2, 3) \cdot \text{diag}(5, 4) = \text{diag}(10, 12) = \begin{pmatrix} 10 & 0 \\ 0 & 12 \end{pmatrix}$$

### Diagonal Matrices Commute

Unlike general matrices, two diagonal matrices of the same size always commute:

$$D_1 D_2 = D_2 D_1$$

This follows directly from the entry-wise multiplication rule shown above, since scalar multiplication of the diagonal entries is itself commutative. This is a standard, provable result, not an inference.

### Effect on Vectors (Scaling Interpretation)

Multiplying a vector $\mathbf{x} = (x_1, \ldots, x_n)$ by a diagonal matrix scales each component independently:

$$D\mathbf{x} = \text{diag}(d_1, \ldots, d_n) \begin{pmatrix} x_1 \\ \vdots \\ x_n \end{pmatrix} = \begin{pmatrix} d_1 x_1 \\ \vdots \\ d_n x_n \end{pmatrix}$$

**Example**

$$\text{diag}(2, -1, 3) \begin{pmatrix} 5 \\ 4 \\ 1 \end{pmatrix} = \begin{pmatrix} 10 \\ -4 \\ 3 \end{pmatrix}$$

**Output**

$$D\mathbf{x} = \begin{pmatrix} 10 \\ -4 \\ 3 \end{pmatrix}$$

This is a direct computation following from the definition, not an inference.

### Powers of a Diagonal Matrix

Raising a diagonal matrix to an integer power $k$ is computed by raising each diagonal entry to that power:

$$D^k = \text{diag}(d_1^k, d_2^k, \ldots, d_n^k)$$

This is a standard, provable result that follows from repeated application of the diagonal multiplication rule above.

### Inverse of a Diagonal Matrix

If all diagonal entries $d_i \neq 0$, the inverse exists and is given by:

$$D^{-1} = \text{diag}\left(\frac{1}{d_1}, \frac{1}{d_2}, \ldots, \frac{1}{d_n}\right)$$

If any diagonal entry equals zero, the matrix is singular and no inverse exists. This is a standard, provable result in linear algebra.

### Determinant of a Diagonal Matrix

The determinant of a diagonal matrix equals the product of its diagonal entries:

$$\det(D) = d_1 \cdot d_2 \cdots d_n$$

This is a standard, provable result in linear algebra, not an inference.

### Eigenvalues of a Diagonal Matrix

[Inference] The eigenvalues of a diagonal matrix are commonly stated in linear algebra references to be exactly its diagonal entries, based on the fact that $D\mathbf{e}_i = d_i \mathbf{e}_i$ for each standard basis vector $\mathbf{e}_i$, which follows directly from the definition of diagonal matrix multiplication shown above. This specific algebraic consequence is not itself uncertain; the labeling here reflects that a full formal eigenvalue proof is not reproduced within this response.

### Relevance to Machine Learning

[Inference] Diagonal matrices are described in commonly cited machine learning and statistics references as useful in several contexts, based on their computational simplicity relative to general matrices. I cannot verify how any specific ML framework implements these internally without inspecting that framework's source code.

Commonly cited use cases include:

- **Covariance matrices under independence assumptions**: when features are assumed uncorrelated, the covariance matrix is diagonal, with variances on the diagonal. [Unverified] I cannot verify from within this response whether any specific dataset or model satisfies this independence assumption.
- **Scaling transformations**: diagonal matrices are described in linear algebra references as representing coordinate-wise scaling, relevant to feature normalization procedures. [Unverified] I cannot verify the exact normalization implementation of any specific software library without inspecting its source code.
- **Eigendecomposition**: diagonal matrices appear in the factorization $A = PDP^{-1}$, where $D$ contains eigenvalues, as described in standard linear algebra references. [Unverified] I cannot verify whether any specific numerical library computes this decomposition using this exact formulation without inspecting that library's documentation or source.
- **Diagonal approximations in optimization**: some optimization algorithms reportedly use diagonal approximations of the Hessian matrix to reduce computational cost, according to descriptions in optimization literature. [Unverified] I do not have access to a specific verified source confirming which optimizers currently implement this by default.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model will behave in future interactions. Behavior is not guaranteed to be consistent.

**Related Topics**
- Identity matrix
- Eigenvalues and eigenvectors
- Matrix diagonalization and eigendecomposition
- Covariance matrices in statistics
- Orthogonal and symmetric matrices
- Singular value decomposition (SVD)

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding machine learning applications, eigenvalue proof reproduction, and framework/library implementation details not drawn from a specific cited source. Core mathematical definitions and algebraic properties (diagonal matrix definition, entry-wise multiplication, commutativity, inverse, determinant) are standard, provable results in linear algebra and are treated as established mathematical fact rather than as inference.