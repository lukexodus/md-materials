## Cramer's Rule

### Definition

Cramer's Rule is a method for solving a system of linear equations $A\mathbf{x} = \mathbf{b}$ using determinants, applicable when $A$ is a square matrix with $\det(A) \neq 0$. This is a standard, well-established theorem in linear algebra.

For a system with $n$ equations and $n$ unknowns:

$$x_i = \frac{\det(A_i)}{\det(A)}$$

where $A_i$ is the matrix formed by replacing the $i$-th column of $A$ with the vector $\mathbf{b}$.

### Requirements

Cramer's Rule applies only when:

- $A$ is a square matrix ($n \times n$)
- $\det(A) \neq 0$ (i.e., $A$ is invertible)

If $\det(A) = 0$, Cramer's Rule does not apply, and the system either has no solution or infinitely many solutions, requiring other methods (e.g., row reduction) to characterize.

### 2×2 Case

For the system:

$$\begin{pmatrix} a & b \\ c & d \end{pmatrix}\begin{pmatrix} x_1 \\ x_2 \end{pmatrix} = \begin{pmatrix} e \\ f \end{pmatrix}$$

$$x_1 = \frac{\begin{vmatrix} e & b \\ f & d \end{vmatrix}}{\begin{vmatrix} a & b \\ c & d \end{vmatrix}}, \quad x_2 = \frac{\begin{vmatrix} a & e \\ c & f \end{vmatrix}}{\begin{vmatrix} a & b \\ c & d \end{vmatrix}}$$

### Diagram: Column Replacement

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 260" font-family="sans-serif">
  <text x="260" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Cramer's Rule Column Substitution (svg_diagram)</text>

  
  <g>
    <text x="90" y="50" font-size="12" text-anchor="middle" fill="#333">A</text>
    <rect x="40" y="60" width="100" height="100" fill="none" stroke="#333" stroke-width="1" />
    <line x1="90" y1="60" x2="90" y2="160" stroke="#333" stroke-width="1" />
    <text x="65" y="115" font-size="13" text-anchor="middle">a</text>
    <text x="65" y="145" font-size="13" text-anchor="middle">c</text>
    <text x="115" y="115" font-size="13" text-anchor="middle">b</text>
    <text x="115" y="145" font-size="13" text-anchor="middle">d</text>
  </g>

  <text x="180" y="115" font-size="16" text-anchor="middle">→</text>

  
  <g>
    <text x="270" y="50" font-size="12" text-anchor="middle" fill="#333">A1 (col 1 to b)</text>
    <rect x="220" y="60" width="100" height="100" fill="none" stroke="#333" stroke-width="1" />
    <line x1="270" y1="60" x2="270" y2="160" stroke="#333" stroke-width="1" />
    <rect x="220" y="60" width="50" height="100" fill="#a3c9f7" opacity="0.4" />
    <text x="245" y="115" font-size="13" text-anchor="middle">e</text>
    <text x="245" y="145" font-size="13" text-anchor="middle">f</text>
    <text x="295" y="115" font-size="13" text-anchor="middle">b</text>
    <text x="295" y="145" font-size="13" text-anchor="middle">d</text>
  </g>

  
  <g>
    <text x="450" y="50" font-size="12" text-anchor="middle" fill="#333">A2 (col 2 to b)</text>
    <rect x="400" y="60" width="100" height="100" fill="none" stroke="#333" stroke-width="1" />
    <line x1="450" y1="60" x2="450" y2="160" stroke="#333" stroke-width="1" />
    <rect x="450" y="60" width="50" height="100" fill="#f7c9a3" opacity="0.4" />
    <text x="425" y="115" font-size="13" text-anchor="middle">a</text>
    <text x="425" y="145" font-size="13" text-anchor="middle">c</text>
    <text x="475" y="115" font-size="13" text-anchor="middle">e</text>
    <text x="475" y="145" font-size="13" text-anchor="middle">f</text>
  </g>
</svg>

### Worked Example

Solve the system:

$$\begin{pmatrix} 2 & 1 \\ 1 & 3 \end{pmatrix}\begin{pmatrix} x_1 \\ x_2 \end{pmatrix} = \begin{pmatrix} 5 \\ 10 \end{pmatrix}$$

Step 1 — Compute $\det(A)$:

$$\det(A) = (2)(3) - (1)(1) = 6 - 1 = 5$$

Step 2 — Compute $\det(A_1)$ (replace column 1 with $\mathbf{b}$):

$$A_1 = \begin{pmatrix} 5 & 1 \\ 10 & 3 \end{pmatrix}, \quad \det(A_1) = (5)(3) - (1)(10) = 15 - 10 = 5$$

Step 3 — Compute $\det(A_2)$ (replace column 2 with $\mathbf{b}$):

$$A_2 = \begin{pmatrix} 2 & 5 \\ 1 & 10 \end{pmatrix}, \quad \det(A_2) = (2)(10) - (5)(1) = 20 - 5 = 15$$

Step 4 — Solve:

$$x_1 = \frac{\det(A_1)}{\det(A)} = \frac{5}{5} = 1, \quad x_2 = \frac{\det(A_2)}{\det(A)} = \frac{15}{5} = 3$$

Verification: $2(1) + 1(3) = 5$ ✓ and $1(1) + 3(3) = 10$ ✓

### 3×3 Case

For $A\mathbf{x} = \mathbf{b}$ with:

$$A = \begin{pmatrix} a_{11} & a_{12} & a_{13} \\ a_{21} & a_{22} & a_{23} \\ a_{31} & a_{32} & a_{33} \end{pmatrix}, \quad \mathbf{b} = \begin{pmatrix} b_1 \\ b_2 \\ b_3 \end{pmatrix}$$

each unknown is computed as:

$$x_1 = \frac{\det(A_1)}{\det(A)}, \quad x_2 = \frac{\det(A_2)}{\det(A)}, \quad x_3 = \frac{\det(A_3)}{\det(A)}$$

where $A_i$ replaces column $i$ of $A$ with $\mathbf{b}$, requiring four $3\times 3$ determinant computations in total.

### Computational Complexity

Cramer's Rule requires computing $n+1$ determinants of $n \times n$ matrices (one for $\det(A)$, plus one for each $A_i$). Using cofactor expansion, each determinant computation is $O(n!)$, making the overall method highly inefficient for large $n$.

[Inference] Based on this complexity, Gaussian elimination (with $O(n^3)$ complexity) is generally considered more computationally efficient for solving linear systems as $n$ grows, and this is a commonly cited comparison in numerical linear algebra references. I do not have a specific primary source confirmed in this conversation for this exact comparison.

For this reason, Cramer's Rule is rarely used in production numerical software for solving large linear systems. [Inference] This is a widely repeated statement in linear algebra teaching materials and numerical computing references, reasoned from the complexity comparison above, but I do not have a specific primary source confirmed in this conversation.

### When Cramer's Rule Is Still Useful

- **Small systems** ($n = 2$ or $n = 3$): direct, symbolic, and easy to hand-compute.
- **Symbolic/theoretical work**: useful for deriving closed-form expressions for solutions in terms of matrix entries, which is valuable in proofs and symbolic computation.
- **Sensitivity analysis**: the determinant-based formula can make it easier to see, symbolically, how a solution component depends on a specific entry of $A$ or $\mathbf{b}$. [Inference] This is a reasoned extension of the closed-form nature of the rule; I do not have a specific primary source confirmed in this conversation describing this as a named standard use case.

### Case: No Unique Solution

If $\det(A) = 0$, Cramer's Rule cannot produce a solution via division. In this case:

- If additionally $\det(A_i) = 0$ for all $i$, the system may have infinitely many solutions (consistent, dependent system).
- If $\det(A_i) \neq 0$ for at least one $i$, the system has no solution (inconsistent system).

I cannot verify without additional context whether a specific system falls into either case beyond applying this general determinant-based test directly to that system. [Unverified]

### Relevance to Machine Learning

- **Small-scale closed-form solutions**: In low-dimensional settings (e.g., fitting a line through 2 points, or small symbolic derivations in textbook-style ML derivations), Cramer's Rule can provide an explicit formula. [Inference] This is a reasonable pedagogical application based on the method's structure, but I do not have a specific primary source confirmed in this conversation describing this as a standard ML teaching practice.
- **Deriving normal equations**: Cramer's Rule is sometimes used in introductory treatments to derive closed-form solutions to small linear regression problems (e.g., simple linear regression with one feature) before generalizing to matrix inverse notation. [Speculation] I do not have a confirmed source verifying this as a standard, named pedagogical sequence in machine learning textbooks; this is a plausible but unconfirmed instructional pattern.
- **Not used in practice for large-scale ML systems**: Real-world ML pipelines solving linear systems (e.g., normal equations, least squares) generally rely on numerically stable factorization methods such as QR decomposition or SVD rather than Cramer's Rule. [Inference] This is a widely cited practice in numerical linear algebra and machine learning literature, reasoned from the computational complexity and numerical stability concerns discussed above, but I do not have a specific primary source confirmed in this conversation.

### Common Pitfalls

- Attempting to apply Cramer's Rule to non-square systems — it is only defined for square, invertible $A$.
- Using Cramer's Rule for large $n$ in actual code, resulting in severe performance problems due to $O(n!)$ determinant computations. [Inference] This follows directly from the stated complexity of cofactor-expansion-based determinant computation described above.
- Assuming Cramer's Rule is numerically stable for ill-conditioned matrices. Even when $\det(A) \neq 0$, division by a very small determinant can amplify numerical error. I cannot verify specific error bounds or thresholds without a specific numerical context and primary source. [Unverified]

I cannot verify the internal implementation details or numerical behavior of any specific software library or system that may implement Cramer's Rule, and any such behavior may vary by implementation and version. [Unverified]

**Related Topics**
- Determinant and invertibility relationship
- Gaussian elimination and LU decomposition
- Matrix inverse via the adjugate formula
- QR decomposition for solving least squares problems
- Numerical stability and condition number
- Systems of linear equations: consistency and solution types