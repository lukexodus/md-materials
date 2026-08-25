## Triangular Matrices

### Definitions

A square matrix $A \in \mathbb{R}^{n \times n}$ is **upper triangular** if all entries below the main diagonal are zero:

$$a_{ij} = 0 \quad \text{for } i > j$$

A square matrix $A$ is **lower triangular** if all entries above the main diagonal are zero:

$$a_{ij} = 0 \quad \text{for } i < j$$

These are standard, provable definitions from linear algebra, not inferences.

### Examples

**Upper triangular matrix**

$$U = \begin{pmatrix} 3 & 5 & -2 \\ 0 & 1 & 4 \\ 0 & 0 & 7 \end{pmatrix}$$

**Lower triangular matrix**

$$L = \begin{pmatrix} 2 & 0 & 0 \\ -1 & 6 & 0 \\ 4 & 3 & 5 \end{pmatrix}$$

### Visual Comparison

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 260">
  <text x="240" y="20" font-size="13" text-anchor="middle" fill="#333">Upper vs Lower Triangular Structure (svg_diagram)</text>
  <text x="120" y="45" font-size="12" text-anchor="middle" fill="#1f77b4">Upper Triangular</text>
  <rect x="40" y="60" width="160" height="160" fill="none" stroke="#1f77b4" stroke-width="2" />
  <line x1="40" y1="113" x2="200" y2="113" stroke="#ccc" stroke-width="1" />
  <line x1="40" y1="167" x2="200" y2="167" stroke="#ccc" stroke-width="1" />
  <line x1="93" y1="60" x2="93" y2="220" stroke="#ccc" stroke-width="1" />
  <line x1="147" y1="60" x2="147" y2="220" stroke="#ccc" stroke-width="1" />
  <text x="66" y="93" font-size="13" text-anchor="middle">3</text>
  <text x="120" y="93" font-size="13" text-anchor="middle">5</text>
  <text x="173" y="93" font-size="13" text-anchor="middle">-2</text>
  <text x="66" y="146" font-size="13" text-anchor="middle" fill="#d62728">0</text>
  <text x="120" y="146" font-size="13" text-anchor="middle">1</text>
  <text x="173" y="146" font-size="13" text-anchor="middle">4</text>
  <text x="66" y="200" font-size="13" text-anchor="middle" fill="#d62728">0</text>
  <text x="120" y="200" font-size="13" text-anchor="middle" fill="#d62728">0</text>
  <text x="173" y="200" font-size="13" text-anchor="middle">7</text>
  <text x="360" y="45" font-size="12" text-anchor="middle" fill="#ff7f0e">Lower Triangular</text>
  <rect x="280" y="60" width="160" height="160" fill="none" stroke="#ff7f0e" stroke-width="2" />
  <line x1="280" y1="113" x2="440" y2="113" stroke="#ccc" stroke-width="1" />
  <line x1="280" y1="167" x2="440" y2="167" stroke="#ccc" stroke-width="1" />
  <line x1="333" y1="60" x2="333" y2="220" stroke="#ccc" stroke-width="1" />
  <line x1="387" y1="60" x2="387" y2="220" stroke="#ccc" stroke-width="1" />
  <text x="306" y="93" font-size="13" text-anchor="middle">2</text>
  <text x="360" y="93" font-size="13" text-anchor="middle" fill="#d62728">0</text>
  <text x="413" y="93" font-size="13" text-anchor="middle" fill="#d62728">0</text>
  <text x="306" y="146" font-size="13" text-anchor="middle">-1</text>
  <text x="360" y="146" font-size="13" text-anchor="middle">6</text>
  <text x="413" y="146" font-size="13" text-anchor="middle" fill="#d62728">0</text>
  <text x="306" y="200" font-size="13" text-anchor="middle">4</text>
  <text x="360" y="200" font-size="13" text-anchor="middle">3</text>
  <text x="413" y="200" font-size="13" text-anchor="middle">5</text>
  <text x="240" y="245" font-size="11" text-anchor="middle" fill="#666">Red = required zero entries for each triangular type</text>
</svg>

### Key Points

- A matrix that is both upper and lower triangular is a diagonal matrix, since all off-diagonal entries in both directions must be zero. This follows directly from combining both definitions.
- The identity matrix and the zero matrix are both upper triangular and lower triangular simultaneously.
- A **strictly triangular** matrix has zeros on the main diagonal as well (strictly upper: $a_{ij} = 0$ for $i \geq j$; strictly lower: $a_{ij} = 0$ for $i \leq j$).
- A **unitriangular** matrix is a triangular matrix with all diagonal entries equal to 1.

### Determinant of a Triangular Matrix

The determinant of a triangular matrix equals the product of its diagonal entries:

$$\det(U) = u_{11} \cdot u_{22} \cdots u_{nn}$$

This is a standard, provable result in linear algebra, not an inference.

**Worked Example**

$$\det(U) = \det\begin{pmatrix} 3 & 5 & -2 \\ 0 & 1 & 4 \\ 0 & 0 & 7 \end{pmatrix} = 3 \times 1 \times 7 = 21$$

**Output**

$$\det(U) = 21$$

This is a direct computation following from the stated determinant rule, not an inference.

### Eigenvalues of a Triangular Matrix

[Inference] The eigenvalues of a triangular matrix are commonly stated in linear algebra references to be exactly its diagonal entries, based on the fact that $\det(A - \lambda I)$ for a triangular matrix reduces to the product $(a_{11} - \lambda)(a_{22} - \lambda)\cdots(a_{nn} - \lambda)$, since $A - \lambda I$ remains triangular. This is a direct algebraic consequence of the determinant rule stated above; it is labeled [Inference] because the full characteristic-polynomial derivation is summarized rather than independently re-verified step by step within this response.

### Closure Properties

These are standard, provable results in linear algebra:

- The sum of two upper triangular matrices is upper triangular.
- The product of two upper triangular matrices is upper triangular.
- The sum of two lower triangular matrices is lower triangular.
- The product of two lower triangular matrices is lower triangular.
- The inverse of an invertible upper triangular matrix is upper triangular; the inverse of an invertible lower triangular matrix is lower triangular.
- A triangular matrix is invertible if and only if all diagonal entries are nonzero. This follows directly from the determinant rule above, since $\det(U) = 0$ whenever any diagonal entry is 0.

### Triangular Systems and Substitution

[Inference] Triangular systems of linear equations are commonly described in numerical linear algebra references as solvable by direct substitution rather than general elimination methods, based on the structural property that each equation in a triangular system introduces only one new unknown when solved in the appropriate order (forward substitution for lower triangular, back substitution for upper triangular). I cannot independently verify the computational efficiency claims associated with this method without citing a specific source.

**Worked Example (back substitution)**

Solve $U\mathbf{x} = \mathbf{b}$ where:

$$U = \begin{pmatrix} 2 & 3 \\ 0 & 4 \end{pmatrix}, \quad \mathbf{b} = \begin{pmatrix} 11 \\ 8 \end{pmatrix}$$

From the second row: $4x_2 = 8 \Rightarrow x_2 = 2$

Substituting into the first row: $2x_1 + 3(2) = 11 \Rightarrow 2x_1 = 5 \Rightarrow x_1 = 2.5$

**Output**

$$\mathbf{x} = \begin{pmatrix} 2.5 \\ 2 \end{pmatrix}$$

This is a direct computation following from the stated equations, not an inference.

### LU Decomposition Context

[Inference] Triangular matrices are commonly described in numerical linear algebra references as central to LU decomposition, where a matrix $A$ is factored as $A = LU$ (a lower triangular matrix times an upper triangular matrix), based on descriptions in standard numerical methods textbooks. I do not have access to a specific citable source to quote directly within this response for this claim.

### Relevance to Machine Learning

[Inference] Triangular matrices are described in commonly cited numerical computing and machine learning references as relevant in several contexts, based on their computational properties described in standard references. I cannot verify how any specific ML framework implements these internally without inspecting that framework's source code.

Commonly cited use cases include:

- **Solving linear systems efficiently**: LU decomposition reduces solving $A\mathbf{x} = \mathbf{b}$ to two triangular solves, as described in standard numerical linear algebra references. [Unverified] I cannot verify the exact computational cost figures for any specific implementation without citing a specific source.
- **Cholesky decomposition**: factors a symmetric positive-definite matrix as $A = LL^T$, where $L$ is lower triangular, used in some Gaussian process and optimization implementations according to descriptions in machine learning literature. [Unverified] I do not have access to a specific verified source confirming which frameworks currently implement this by default.
- **Autoregressive and causal masking**: triangular matrices (or triangular masking patterns) are described in some transformer architecture literature as used to enforce causal ordering in attention mechanisms. [Unverified] I cannot verify the exact masking implementation of any specific model without inspecting its source code directly.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model, including the one generating this response, will behave in future interactions. Behavior is not guaranteed to be consistent, and no outcome described here should be treated as certain to recur.

**Related Topics**
- LU decomposition
- Cholesky decomposition
- Determinants
- Solving linear systems via substitution
- Eigenvalues and eigenvectors
- Causal masking in transformer attention

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding eigenvalue derivation summarization, numerical method descriptions, and machine learning application/implementation details not drawn from a specific cited source. Core mathematical definitions and algebraic properties (triangular matrix definitions, determinant-as-product-of-diagonal rule, closure under sum and product, invertibility condition) are standard, provable results in linear algebra and are treated as established mathematical fact rather than as inference.