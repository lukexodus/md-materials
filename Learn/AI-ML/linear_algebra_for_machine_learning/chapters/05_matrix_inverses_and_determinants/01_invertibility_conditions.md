## Invertibility Conditions

### Definition

A square matrix $A \in \mathbb{R}^{n \times n}$ is called **invertible** (or nonsingular) if there exists a matrix $A^{-1}$ such that:

$$AA^{-1} = A^{-1}A = I$$

where $I$ is the identity matrix. If no such matrix exists, $A$ is called **singular** or **non-invertible**.

### Key Equivalent Conditions for Invertibility

**Key Points**

The following conditions are mathematically equivalent for a square matrix $A$. If one holds, all hold; if one fails, all fail.

- $A$ is invertible
- $\det(A) \neq 0$
- The rank of $A$ equals $n$ (full rank)
- The columns of $A$ are linearly independent
- The rows of $A$ are linearly independent
- The null space of $A$ contains only the zero vector: $N(A) = \{0\}$
- $A$ has no zero eigenvalues
- The system $Ax = 0$ has only the trivial solution $x = 0$
- The system $Ax = b$ has a unique solution for every $b$
- The reduced row echelon form of $A$ is the identity matrix $I$

These equivalences are a standard result in linear algebra theory, commonly presented as the "Invertible Matrix Theorem" in linear algebra textbooks.

### Determinant Test

The most commonly used practical test for invertibility is the determinant:

$$\det(A) \neq 0 \implies A \text{ is invertible}$$

$$\det(A) = 0 \implies A \text{ is singular}$$

For a $2 \times 2$ matrix:

$$A = \begin{bmatrix} a & b \\ c & d \end{bmatrix}, \quad \det(A) = ad - bc$$

**Example**

$$A = \begin{bmatrix} 2 & 1 \\ 4 & 3 \end{bmatrix}$$

$$\det(A) = (2)(3) - (1)(4) = 6 - 4 = 2$$

Since $\det(A) = 2 \neq 0$, $A$ is invertible.

**Counter-Example**

$$B = \begin{bmatrix} 2 & 4 \\ 1 & 2 \end{bmatrix}$$

$$\det(B) = (2)(2) - (4)(1) = 4 - 4 = 0$$

Since $\det(B) = 0$, $B$ is singular and has no inverse.

### Rank-Based Condition

A matrix $A$ of size $n \times n$ is invertible if and only if:

$$\text{rank}(A) = n$$

This is described in standard linear algebra references as equivalent to the statement that $A$ has "full rank." [Inference] This is a restatement of the Invertible Matrix Theorem rather than an independently derived claim, so it is labeled as inference from that established theorem rather than a separately confirmed fact.

### Eigenvalue Condition

A matrix $A$ is invertible if and only if none of its eigenvalues are zero:

$$\lambda_i \neq 0 \quad \text{for all } i$$

This follows from the relationship:

$$\det(A) = \prod_{i=1}^{n} \lambda_i$$

If any $\lambda_i = 0$, then $\det(A) = 0$, making $A$ singular. [Inference] This conclusion follows directly from the determinant-eigenvalue product formula, which is a standard identity in linear algebra; it is labeled as inference because it is a derived consequence rather than a restated axiom.

### Null Space Condition

A matrix $A$ is invertible if and only if its null space is trivial:

$$N(A) = \{x : Ax = 0\} = \{0\}$$

If $N(A)$ contains any nonzero vector, $A$ is singular, since this indicates linear dependence among columns.

### Non-Square Matrices

Invertibility, in the strict sense defined above, applies only to square matrices. Non-square matrices ($m \times n$, $m \neq n$) do not have a two-sided inverse. [Unverified] I cannot verify without further specification whether a given non-square matrix context refers to a left inverse, right inverse, or pseudoinverse, as this depends on the specific dimensions and rank of the matrix in question.

For non-square matrices, related concepts include:
- **Left inverse**: exists if $A$ has full column rank ($m > n$, rank $= n$)
- **Right inverse**: exists if $A$ has full row rank ($m < n$, rank $= m$)
- **Moore-Penrose pseudoinverse**: a generalized inverse that exists for any matrix, computed via Singular Value Decomposition (SVD)

### Relevance to Machine Learning

**Key Points**

- Invertibility of $X^TX$ is required in the closed-form solution of ordinary least squares linear regression:

$$\hat{\beta} = (X^TX)^{-1}X^Ty$$

- If $X^TX$ is singular (e.g., due to multicollinearity among features), this closed-form solution cannot be computed directly. [Inference] This is a widely stated consequence in statistical learning references, but it is labeled as inference here because it depends on the specific numerical method used, and I cannot verify the exact behavior of any particular software library without directly checking its documentation.
- Regularization methods (e.g., ridge regression) add a term to make $X^TX$ invertible even when the original matrix is singular or near-singular:

$$\hat{\beta} = (X^TX + \lambda I)^{-1}X^Ty$$

[Unverified] I cannot verify, without a specific cited source, the exact claim that ridge regularization always restores invertibility in every numerical implementation; this is a commonly stated mathematical property in regularization theory, but exact behavior may depend on the value of $\lambda$ and the implementation used.

### Near-Singularity and Numerical Invertibility

In computational settings, a matrix may be technically invertible (nonzero determinant) but **numerically ill-conditioned**, meaning its inverse is highly sensitive to small input errors. This is measured by the condition number:

$$\kappa(A) = \|A\| \cdot \|A^{-1}\|$$

A high condition number indicates that although $A$ is invertible in the strict mathematical sense, computing $A^{-1}$ in floating-point arithmetic may produce large numerical errors. [Inference] This is a standard caution in numerical linear algebra literature regarding the difference between theoretical invertibility and practical numerical stability; it is labeled as inference because the degree of error depends on the specific matrix, hardware, and algorithm used, none of which are specified here.

### Diagram: Invertibility Decision Path

```mermaid
flowchart TD
    A["Square Matrix A (svg_diagram)"] --> B{det(A) = 0?}
    B -->|Yes| C[Singular / Not Invertible]
    B -->|No| D[Invertible]
    D --> E["rank(A) = n"]
    D --> F["N(A) = {0}"]
    D --> G["All eigenvalues nonzero"]
    C --> H["rank(A) < n"]
    C --> I["N(A) contains nonzero vectors"]
    C --> J["At least one eigenvalue = 0"]
```

### Illustration: Invertible vs Singular Matrix Geometry

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 460 220">
<text x="10" y="20" font-size="14" font-weight="bold">Invertible vs Singular Transformation (svg_diagram)</text>

<text x="30" y="45" font-size="12">Invertible A</text>
<rect x="20" y="55" width="100" height="100" fill="none" stroke="#333" />
<polygon points="20,55 120,55 120,155 20,155" fill="#e8eef7" opacity="0.5" />
<line x1="20" y1="155" x2="120" y2="55" stroke="#3366cc" stroke-width="2" />
<line x1="20" y1="55" x2="120" y2="155" stroke="#3366cc" stroke-width="2" />
<text x="20" y="185" font-size="10">Maps to full-dimensional space</text>

<text x="270" y="45" font-size="12">Singular B</text>
<rect x="260" y="55" width="100" height="100" fill="none" stroke="#333" />
<line x1="260" y1="105" x2="360" y2="105" stroke="#cc3333" stroke-width="3" />
<text x="260" y="185" font-size="10">Collapses to a line (loses dimension)</text>
</svg>

### Correction Note on Prior Terminology

Earlier responses in this conversation used terms such as "guarantee," "ensures," and similar absolute language. Per current instructions, such terms are avoided going forward unless directly quoting a verifiable source. No fake sources have been cited in this response.

**Related Topics**
- Determinants and Cofactor Expansion
- Rank and Null Space
- Eigenvalues and Eigenvectors
- Moore-Penrose Pseudoinverse
- Singular Value Decomposition (SVD)
- Condition Number and Numerical Stability
- Ridge Regression and Regularization