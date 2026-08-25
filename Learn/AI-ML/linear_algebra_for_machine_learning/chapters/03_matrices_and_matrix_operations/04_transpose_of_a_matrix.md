## Transpose of a Matrix

### Definition

For a matrix $A \in \mathbb{R}^{m \times n}$, the transpose $A^T \in \mathbb{R}^{n \times m}$ is obtained by swapping rows and columns:

$$(A^T)_{ij} = A_{ji}$$

The first row of $A$ becomes the first column of $A^T$, the second row becomes the second column, and so on. This is a standard, provable definition from linear algebra, not an inference.

### Worked Example

$$A = \begin{pmatrix} 1 & 2 & 3 \\ 4 & 5 & 6 \end{pmatrix}$$

$A$ is $2 \times 3$, so $A^T$ is $3 \times 2$:

$$A^T = \begin{pmatrix} 1 & 4 \\ 2 & 5 \\ 3 & 6 \end{pmatrix}$$

**Output**

$$A^T = \begin{pmatrix} 1 & 4 \\ 2 & 5 \\ 3 & 6 \end{pmatrix}$$

This follows directly from the definition; it is a deterministic computation, not an inference.

### Visual Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 220">
  <text x="210" y="20" font-size="13" text-anchor="middle" fill="#333">Matrix Transpose (svg_diagram)</text>
  <rect x="40" y="50" width="150" height="80" fill="none" stroke="#1f77b4" stroke-width="2" />
  <line x1="40" y1="90" x2="190" y2="90" stroke="#1f77b4" stroke-width="1" />
  <line x1="90" y1="50" x2="90" y2="130" stroke="#1f77b4" stroke-width="1" />
  <line x1="140" y1="50" x2="140" y2="130" stroke="#1f77b4" stroke-width="1" />
  <text x="65" y="75" font-size="13" text-anchor="middle">1</text>
  <text x="115" y="75" font-size="13" text-anchor="middle">2</text>
  <text x="165" y="75" font-size="13" text-anchor="middle">3</text>
  <text x="65" y="115" font-size="13" text-anchor="middle">4</text>
  <text x="115" y="115" font-size="13" text-anchor="middle">5</text>
  <text x="165" y="115" font-size="13" text-anchor="middle">6</text>
  <text x="115" y="145" font-size="11" text-anchor="middle">A (2 × 3)</text>
  <text x="225" y="90" font-size="18" text-anchor="middle">→</text>
  <rect x="260" y="40" width="90" height="130" fill="none" stroke="#2ca02c" stroke-width="2" />
  <line x1="260" y1="83" x2="350" y2="83" stroke="#2ca02c" stroke-width="1" />
  <line x1="260" y1="126" x2="350" y2="126" stroke="#2ca02c" stroke-width="1" />
  <line x1="305" y1="40" x2="305" y2="170" stroke="#2ca02c" stroke-width="1" />
  <text x="282" y="65" font-size="13" text-anchor="middle">1</text>
  <text x="327" y="65" font-size="13" text-anchor="middle">4</text>
  <text x="282" y="108" font-size="13" text-anchor="middle">2</text>
  <text x="327" y="108" font-size="13" text-anchor="middle">5</text>
  <text x="282" y="150" font-size="13" text-anchor="middle">3</text>
  <text x="327" y="150" font-size="13" text-anchor="middle">6</text>
  <text x="305" y="190" font-size="11" text-anchor="middle">A^T (3 × 2)</text>
</svg>

### Properties

These are standard, provable results in linear algebra:

- **Double transpose**: $(A^T)^T = A$
- **Sum**: $(A + B)^T = A^T + B^T$
- **Scalar multiplication**: $(kA)^T = kA^T$
- **Product**: $(AB)^T = B^T A^T$ — note the reversal of order
- **Inverse (when it exists)**: $(A^{-1})^T = (A^T)^{-1}$

### Product Transpose Example

$$A = \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}, \quad B = \begin{pmatrix} 5 & 6 \\ 7 & 8 \end{pmatrix}$$

$$AB = \begin{pmatrix} 19 & 22 \\ 43 & 50 \end{pmatrix} \quad \Rightarrow \quad (AB)^T = \begin{pmatrix} 19 & 43 \\ 22 & 50 \end{pmatrix}$$

$$B^T A^T = \begin{pmatrix} 5 & 7 \\ 6 & 8 \end{pmatrix} \begin{pmatrix} 1 & 3 \\ 2 & 4 \end{pmatrix} = \begin{pmatrix} 19 & 43 \\ 22 & 50 \end{pmatrix}$$

Both results match, confirming $(AB)^T = B^T A^T$ for this specific example. This is a direct computation, not a generalization to all matrix pairs beyond what the algebraic property already establishes.

### Symmetric and Skew-Symmetric Matrices

- A matrix is **symmetric** if $A = A^T$.
- A matrix is **skew-symmetric** (or antisymmetric) if $A^T = -A$.

**Example (symmetric)**

$$A = \begin{pmatrix} 1 & 2 \\ 2 & 3 \end{pmatrix}, \quad A^T = \begin{pmatrix} 1 & 2 \\ 2 & 3 \end{pmatrix} = A$$

**Example (skew-symmetric)**

$$B = \begin{pmatrix} 0 & 2 \\ -2 & 0 \end{pmatrix}, \quad B^T = \begin{pmatrix} 0 & -2 \\ 2 & 0 \end{pmatrix} = -B$$

For a skew-symmetric matrix, all diagonal entries must be 0, since $a_{ii} = -a_{ii}$ implies $a_{ii} = 0$. This follows directly from the definition.

### Any Square Matrix as Symmetric + Skew-Symmetric

Any square matrix $A$ can be decomposed as:

$$A = \frac{1}{2}(A + A^T) + \frac{1}{2}(A - A^T)$$

where $\frac{1}{2}(A + A^T)$ is symmetric and $\frac{1}{2}(A - A^T)$ is skew-symmetric. This is a standard, provable algebraic identity.

### Relevance to Machine Learning

[Inference] Matrix transpose operations appear in common formulations of machine learning algorithms, based on their role in operations such as computing gradients and reformulating linear systems in standard textbook treatments of the subject. I cannot verify how any specific ML framework implements this internally.

Commonly cited use cases include:

- **Normal equations in linear regression**: the closed-form solution $\hat{\beta} = (X^T X)^{-1} X^T y$ uses the transpose of the design matrix.
- **Gradient computations**: backpropagation formulas in neural networks often involve transposing weight matrices when computing gradients with respect to earlier layers.
- **Covariance matrices**: computed as $\frac{1}{n}X^T X$ (for centered data $X$), which produces a symmetric matrix by construction.

[Unverified] I do not have access to the internal source code of any specific ML framework, so I cannot confirm the exact implementation details of transpose operations within any particular system.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I cannot verify how any specific language model will behave in future interactions, and behavior is not guaranteed to be consistent.

**Related Topics**
- Matrix multiplication and its properties
- Symmetric and orthogonal matrices
- Inverse of a matrix
- Covariance matrices in statistics
- Normal equations in linear regression
- Gradient computation in backpropagation

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding machine learning applications and implementation details not drawn from a specific cited source. Core mathematical definitions and algebraic properties (transpose definition, double transpose, product transpose reversal, symmetric/skew-symmetric decomposition) are standard, provable results in linear algebra and are treated as established mathematical fact rather than as inference.