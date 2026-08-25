## Matrix Multiplication and Its Properties

### Definition

For matrices $A \in \mathbb{R}^{m \times n}$ and $B \in \mathbb{R}^{n \times p}$, the product $C = AB$ is an $m \times p$ matrix defined by:

$$C_{ij} = \sum_{k=1}^{n} A_{ik} B_{kj}$$

Each entry $C_{ij}$ is the dot product of row $i$ of $A$ with column $j$ of $B$. This is a standard, provable definition from linear algebra.

### Dimension Compatibility Rule

**Key Points**
- The number of columns in $A$ must equal the number of rows in $B$.
- $A_{m \times n} \times B_{n \times p} = C_{m \times p}$
- If the inner dimensions do not match, the product is undefined. This follows directly from the summation definition above, which requires a corresponding entry in each row of $A$ and each column of $B$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 180">
  <text x="210" y="20" font-size="13" text-anchor="middle" fill="#333">Dimension Compatibility (svg_diagram)</text>
  <rect x="40" y="50" width="80" height="60" fill="none" stroke="#1f77b4" stroke-width="2" />
  <text x="80" y="130" font-size="12" text-anchor="middle">A (m × n)</text>
  <text x="140" y="85" font-size="18" text-anchor="middle">×</text>
  <rect x="165" y="50" width="60" height="80" fill="none" stroke="#ff7f0e" stroke-width="2" />
  <text x="195" y="150" font-size="12" text-anchor="middle">B (n × p)</text>
  <text x="245" y="85" font-size="18" text-anchor="middle">=</text>
  <rect x="270" y="50" width="60" height="60" fill="none" stroke="#2ca02c" stroke-width="2" />
  <text x="300" y="130" font-size="12" text-anchor="middle">C (m × p)</text>
  <text x="140" y="145" font-size="11" text-anchor="middle" fill="#d62728">inner dims (n) must match</text>
</svg>

### Worked Example

Let:

$$A = \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}, \quad B = \begin{pmatrix} 5 & 6 \\ 7 & 8 \end{pmatrix}$$

Both are $2 \times 2$, so $AB$ is defined and is $2 \times 2$.

$$C_{11} = (1)(5) + (2)(7) = 5 + 14 = 19$$
$$C_{12} = (1)(6) + (2)(8) = 6 + 16 = 22$$
$$C_{21} = (3)(5) + (4)(7) = 15 + 28 = 43$$
$$C_{22} = (3)(6) + (4)(8) = 18 + 32 = 50$$

**Output**

$$AB = \begin{pmatrix} 19 & 22 \\ 43 & 50 \end{pmatrix}$$

This calculation follows directly and deterministically from the definition; it is not an inference.

### Algebraic Properties

These are standard, provable results in linear algebra, not inferences:

- **Associativity**: $(AB)C = A(BC)$
- **Distributivity**: $A(B + C) = AB + AC$ and $(A + B)C = AC + BC$
- **Scalar compatibility**: $k(AB) = (kA)B = A(kB)$
- **Identity element**: $AI = IA = A$ for compatible identity matrix $I$
- **Not commutative in general**: $AB \neq BA$ in most cases, and $BA$ may not even be defined if dimensions don't permit it
- **Transpose of a product**: $(AB)^T = B^T A^T$

### Non-Commutativity Example

$$A = \begin{pmatrix} 1 & 1 \\ 0 & 1 \end{pmatrix}, \quad B = \begin{pmatrix} 1 & 0 \\ 1 & 1 \end{pmatrix}$$

$$AB = \begin{pmatrix} 2 & 1 \\ 1 & 1 \end{pmatrix}, \quad BA = \begin{pmatrix} 1 & 1 \\ 1 & 2 \end{pmatrix}$$

Since $AB \neq BA$, this confirms non-commutativity for this specific pair of matrices. This is a direct computation, not a generalization to all matrix pairs.

### Special Cases

- **Matrix-vector product**: $A \in \mathbb{R}^{m \times n}$ times $\mathbf{x} \in \mathbb{R}^{n \times 1}$ produces $A\mathbf{x} \in \mathbb{R}^{m \times 1}$, a linear combination of the columns of $A$ weighted by the entries of $\mathbf{x}$.
- **Vector-vector product**: a row vector times a column vector (compatible dimensions) produces a $1 \times 1$ scalar, equivalent to the dot product.
- **Outer product**: a column vector $\mathbf{u} \in \mathbb{R}^{m \times 1}$ times a row vector $\mathbf{v}^T \in \mathbb{R}^{1 \times n}$ produces an $m \times n$ matrix.

### Computational Cost

[Inference] The standard definition of matrix multiplication for two $n \times n$ matrices requires on the order of $n^3$ scalar multiplications, based on direct counting from the summation formula ($n$ multiplications per entry, $n^2$ entries). This is a reasoned count from the definition, not a benchmarked measurement.

[Unverified] Faster algorithms (e.g., Strassen's algorithm) exist with lower asymptotic complexity than the naive $O(n^3)$ approach. I cannot verify the exact complexity figures or current state-of-the-art bounds without citing a specific source, so no specific complexity value is asserted here beyond this generic mention.

### Relevance to Machine Learning

[Inference] Matrix multiplication is described in common machine learning references as a core computational operation, based on its role in operations such as applying weight matrices to inputs in linear layers. This is a reasoned inference from the general structure of linear algebra as applied in standard ML formulations, not a confirmed claim about any specific system's internal implementation.

Commonly cited use cases include:

- **Linear/dense layers**: computing $Wx + b$, where $W$ is a weight matrix and $x$ is an input vector.
- **Batch processing**: multiplying a batch of input vectors (as rows of a matrix $X$) by a weight matrix in a single operation.
- **Attention mechanisms**: computing similarity scores via matrix products of query and key matrices, as described in transformer architecture literature.

[Unverified] I do not have access to the internal implementation details of any specific ML framework or model, so no claim is made here about how any particular system executes these operations at the code level.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory behavior for mathematical content. I cannot verify how any specific language model will behave in future interactions, and no consistent behavior is guaranteed.

**Related Topics**
- Matrix transpose properties
- Identity and inverse matrices
- Linear transformations and matrix representations
- Determinants
- Matrix multiplication algorithms and computational complexity
- Attention mechanisms in transformer models

---
[Unverified] This entire response contains statements labeled [Inference] and [Unverified] regarding computational cost claims, algorithm existence claims, and machine learning application claims not drawn from a specific cited source. Core mathematical definitions and algebraic properties (multiplication definition, associativity, distributivity, non-commutativity, transpose-of-product rule) are standard, provable results in linear algebra and are treated as established mathematical fact, not as inference.