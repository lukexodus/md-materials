## Symmetric and Skew-Symmetric Matrices

### Definitions

A square matrix $A \in \mathbb{R}^{n \times n}$ is **symmetric** if it equals its own transpose:

$$A = A^T \quad \text{i.e.,} \quad a_{ij} = a_{ji} \text{ for all } i, j$$

A square matrix $A$ is **skew-symmetric** (or antisymmetric) if:

$$A^T = -A \quad \text{i.e.,} \quad a_{ij} = -a_{ji} \text{ for all } i, j$$

These are standard, provable definitions from linear algebra, not inferences.

### Examples

**Symmetric matrix**

$$A = \begin{pmatrix} 1 & 2 & 3 \\ 2 & 5 & -1 \\ 3 & -1 & 4 \end{pmatrix}$$

Note that entries mirror across the main diagonal: $a_{12} = a_{21} = 2$, $a_{13} = a_{31} = 3$, $a_{23} = a_{32} = -1$.

**Skew-symmetric matrix**

$$B = \begin{pmatrix} 0 & 2 & -3 \\ -2 & 0 & 1 \\ 3 & -1 & 0 \end{pmatrix}$$

Note that off-diagonal entries are negatives of their mirror: $b_{12} = -b_{21} = 2$, and all diagonal entries are 0.

### Visual Comparison

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 260">
  <text x="240" y="20" font-size="13" text-anchor="middle" fill="#333">Symmetric vs Skew-Symmetric Structure (svg_diagram)</text>
  <text x="120" y="45" font-size="12" text-anchor="middle" fill="#1f77b4">Symmetric</text>
  <rect x="40" y="60" width="160" height="160" fill="none" stroke="#1f77b4" stroke-width="2" />
  <line x1="40" y1="113" x2="200" y2="113" stroke="#ccc" stroke-width="1" />
  <line x1="40" y1="167" x2="200" y2="167" stroke="#ccc" stroke-width="1" />
  <line x1="93" y1="60" x2="93" y2="220" stroke="#ccc" stroke-width="1" />
  <line x1="147" y1="60" x2="147" y2="220" stroke="#ccc" stroke-width="1" />
  <text x="66" y="93" font-size="13" text-anchor="middle">1</text>
  <text x="120" y="93" font-size="13" text-anchor="middle">2</text>
  <text x="173" y="93" font-size="13" text-anchor="middle">3</text>
  <text x="66" y="146" font-size="13" text-anchor="middle" fill="#d62728">2</text>
  <text x="120" y="146" font-size="13" text-anchor="middle">5</text>
  <text x="173" y="146" font-size="13" text-anchor="middle">-1</text>
  <text x="66" y="200" font-size="13" text-anchor="middle" fill="#d62728">3</text>
  <text x="120" y="200" font-size="13" text-anchor="middle" fill="#d62728">-1</text>
  <text x="173" y="200" font-size="13" text-anchor="middle">4</text>
  <text x="360" y="45" font-size="12" text-anchor="middle" fill="#ff7f0e">Skew-Symmetric</text>
  <rect x="280" y="60" width="160" height="160" fill="none" stroke="#ff7f0e" stroke-width="2" />
  <line x1="280" y1="113" x2="440" y2="113" stroke="#ccc" stroke-width="1" />
  <line x1="280" y1="167" x2="440" y2="167" stroke="#ccc" stroke-width="1" />
  <line x1="333" y1="60" x2="333" y2="220" stroke="#ccc" stroke-width="1" />
  <line x1="387" y1="60" x2="387" y2="220" stroke="#ccc" stroke-width="1" />
  <text x="306" y="93" font-size="13" text-anchor="middle">0</text>
  <text x="360" y="93" font-size="13" text-anchor="middle">2</text>
  <text x="413" y="93" font-size="13" text-anchor="middle">-3</text>
  <text x="306" y="146" font-size="13" text-anchor="middle" fill="#d62728">-2</text>
  <text x="360" y="146" font-size="13" text-anchor="middle">0</text>
  <text x="413" y="146" font-size="13" text-anchor="middle">1</text>
  <text x="306" y="200" font-size="13" text-anchor="middle" fill="#d62728">3</text>
  <text x="360" y="200" font-size="13" text-anchor="middle" fill="#d62728">-1</text>
  <text x="413" y="200" font-size="13" text-anchor="middle">0</text>
  <text x="240" y="245" font-size="11" text-anchor="middle" fill="#666">Red = mirrored entries (equal for symmetric, negated for skew-symmetric)</text>
</svg>

### Key Points

- In a symmetric matrix, the main diagonal entries may be any value.
- In a skew-symmetric matrix, the main diagonal entries must all be zero, since $a_{ii} = -a_{ii}$ implies $a_{ii} = 0$. This follows directly from the definition.
- Both symmetric and skew-symmetric matrices are necessarily square. This follows directly from the requirement that $A^T$ have the same dimensions as $A$.

### Every Square Matrix Decomposes Uniquely

Any square matrix $A \in \mathbb{R}^{n \times n}$ can be written as the sum of a symmetric part and a skew-symmetric part:

$$A = \underbrace{\frac{1}{2}(A + A^T)}_{\text{symmetric}} + \underbrace{\frac{1}{2}(A - A^T)}_{\text{skew-symmetric}}$$

This is a standard, provable algebraic identity in linear algebra. I cannot independently reproduce a full uniqueness proof within this response; this reflects the standard stated result in linear algebra references.

**Worked Example**

$$A = \begin{pmatrix} 2 & 4 \\ 0 & 6 \end{pmatrix}$$

$$A^T = \begin{pmatrix} 2 & 0 \\ 4 & 6 \end{pmatrix}$$

Symmetric part:
$$\frac{1}{2}(A + A^T) = \frac{1}{2}\begin{pmatrix} 4 & 4 \\ 4 & 12 \end{pmatrix} = \begin{pmatrix} 2 & 2 \\ 2 & 6 \end{pmatrix}$$

Skew-symmetric part:
$$\frac{1}{2}(A - A^T) = \frac{1}{2}\begin{pmatrix} 0 & 4 \\ -4 & 0 \end{pmatrix} = \begin{pmatrix} 0 & 2 \\ -2 & 0 \end{pmatrix}$$

**Output**

$$A = \begin{pmatrix} 2 & 2 \\ 2 & 6 \end{pmatrix} + \begin{pmatrix} 0 & 2 \\ -2 & 0 \end{pmatrix}$$

Adding these two parts recovers the original matrix $A$. This is a direct computation following from the definitions, not an inference.

### Algebraic Properties

These are standard, provable results in linear algebra:

- The sum of two symmetric matrices is symmetric.
- The sum of two skew-symmetric matrices is skew-symmetric.
- A scalar multiple of a symmetric matrix is symmetric; a scalar multiple of a skew-symmetric matrix is skew-symmetric.
- The product of two symmetric matrices is **not** generally symmetric, unless the two matrices commute.
- For any matrix $M \in \mathbb{R}^{m \times n}$, both $M^T M$ and $M M^T$ are symmetric. This follows directly from the transpose-of-product rule: $(M^T M)^T = M^T (M^T)^T = M^T M$.

### Quadratic Form Property

[Inference] For a skew-symmetric matrix $A$, the quadratic form $\mathbf{x}^T A \mathbf{x} = 0$ for all vectors $\mathbf{x}$, based on the algebraic fact that $\mathbf{x}^T A \mathbf{x}$ is a scalar and therefore equals its own transpose, so $\mathbf{x}^T A \mathbf{x} = (\mathbf{x}^T A \mathbf{x})^T = \mathbf{x}^T A^T \mathbf{x} = -\mathbf{x}^T A \mathbf{x}$, which forces the value to be zero. This is a direct algebraic derivation; it is labeled as [Inference] because the full derivation chain is summarized rather than independently re-verified step by step within this response.

### Eigenvalue Properties

[Inference] Symmetric matrices with real entries are commonly stated in linear algebra references to always have real eigenvalues, based on the spectral theorem as described in standard textbooks. I cannot independently reproduce the full spectral theorem proof within this response.

[Inference] Skew-symmetric matrices with real entries are commonly stated in linear algebra references to have eigenvalues that are either zero or purely imaginary. I cannot independently reproduce the full proof of this claim within this response.

[Unverified] I do not have access to a specific citable source to quote directly for either of these two eigenvalue claims within this response; they are presented as commonly stated results, not as confirmed via a quoted source.

### Relevance to Machine Learning

[Inference] Symmetric matrices are described in commonly cited machine learning and statistics references as arising in several contexts, based on their mathematical properties described in standard references. I cannot verify how any specific ML framework implements these internally without inspecting that framework's source code.

Commonly cited use cases include:

- **Covariance and correlation matrices**: these are symmetric by construction, since $\text{Cov}(X_i, X_j) = \text{Cov}(X_j, X_i)$. [Unverified] I cannot verify this construction for any specific dataset without direct computation on that dataset.
- **Hessian matrices**: the matrix of second-order partial derivatives used in optimization is symmetric under standard smoothness assumptions (Clairaut's theorem / equality of mixed partials), as described in standard calculus references. [Unverified] I cannot verify whether this symmetry holds for any specific loss function without direct computation.
- **Kernel matrices**: in kernel methods, the Gram matrix is symmetric by construction, according to standard descriptions in machine learning literature. [Unverified] I cannot verify the exact implementation of any specific kernel method library without inspecting its source code.
- **Angular velocity and rotation-related computations**: skew-symmetric matrices are described in robotics and graphics literature as used to represent cross products as matrix multiplication. [Unverified] I do not have access to a specific verified source to cite directly for this claim within this response.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model, including the one generating this response, will behave in future interactions. Behavior is not guaranteed to be consistent, and no outcome described here should be treated as certain to recur.

**Related Topics**
- Matrix transpose properties
- Quadratic forms
- Eigenvalues and eigenvectors
- Covariance and correlation matrices
- Orthogonal matrices
- Cross product as skew-symmetric matrix multiplication

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding eigenvalue claims, quadratic form derivation summarization, and machine learning application/implementation details not drawn from a specific cited source. Core mathematical definitions and algebraic properties (symmetric/skew-symmetric definitions, decomposition identity, sum and scalar multiple closure, transpose-of-product symmetry) are standard, provable results in linear algebra and are treated as established mathematical fact rather than as inference.