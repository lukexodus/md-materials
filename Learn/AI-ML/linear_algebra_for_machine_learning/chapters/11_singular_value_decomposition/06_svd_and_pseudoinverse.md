## SVD and the Pseudoinverse

### Definition

The Moore-Penrose pseudoinverse, denoted $A^+$, generalizes the concept of matrix inverse to matrices that are not square or not invertible. For any real matrix $A \in \mathbb{R}^{m \times n}$, the pseudoinverse is defined uniquely via the SVD:

$$A = U\Sigma V^T \implies A^+ = V\Sigma^+ U^T$$

where $\Sigma^+$ is formed by taking the reciprocal of each nonzero singular value in $\Sigma$, leaving zero entries as zero, and transposing the resulting shape. This is a standard, well-established definition in linear algebra, not an inference.

### Constructing $\Sigma^+$

If $\Sigma$ is $m \times n$ with diagonal entries $\sigma_1 \geq \sigma_2 \geq \cdots \geq \sigma_r > 0$ (and zeros elsewhere, where $r$ is the rank of $A$), then $\Sigma^+$ is $n \times m$ with:

$$(\Sigma^+)_{ii} = \begin{cases} 1/\sigma_i & \text{if } \sigma_i \neq 0 \\ 0 & \text{if } \sigma_i = 0 \end{cases}$$

This construction is standard and directly computable once the SVD is known.

### The Four Moore-Penrose Conditions

The pseudoinverse is the unique matrix $A^+$ satisfying all four of the following conditions, which is the formal defining property (the SVD-based formula above is a standard construction that satisfies them):

$$AA^+A = A$$

$$A^+AA^+ = A^+$$

$$(AA^+)^T = AA^+$$

$$(A^+A)^T = A^+A$$

These four conditions are the standard mathematical definition of the Moore-Penrose pseudoinverse, and their equivalence to the SVD-based construction is a proven theorem in linear algebra.

### Special Cases

**Case 1 — $A$ square and invertible:**

$$A^+ = A^{-1}$$

The pseudoinverse reduces to the ordinary inverse. This follows directly from the definition, since $\Sigma$ has no zero entries in this case.

**Case 2 — $A$ has full column rank ($m > n$, "tall" matrix, overdetermined system):**

$$A^+ = (A^TA)^{-1}A^T$$

This is the standard formula for the least-squares solution and is a provable identity derivable from the SVD-based definition when $A^TA$ is invertible.

**Case 3 — $A$ has full row rank ($m < n$, "wide" matrix, underdetermined system):**

$$A^+ = A^T(AA^T)^{-1}$$

This is a standard, provable analogous identity for the underdetermined case.

### Worked Example

Let:

$$A = \begin{bmatrix} 1 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix}$$

This is already in a diagonal-like form. Its SVD is directly readable: $\sigma_1 = 1$ (the only nonzero singular value), with:

$$U = I_3, \quad \Sigma = \begin{bmatrix} 1 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix}, \quad V = I_2$$

**Constructing $\Sigma^+$** (transpose shape, reciprocal of nonzero entries):

$$\Sigma^+ = \begin{bmatrix} 1 & 0 & 0 \\ 0 & 0 & 0 \end{bmatrix}$$

**Output**

$$A^+ = V\Sigma^+U^T = I_2 \begin{bmatrix} 1 & 0 & 0 \\ 0 & 0 & 0 \end{bmatrix} I_3 = \begin{bmatrix} 1 & 0 & 0 \\ 0 & 0 & 0 \end{bmatrix}$$

**Verification against Moore-Penrose condition 1** ($AA^+A = A$):

$$AA^+ = \begin{bmatrix} 1 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix}\begin{bmatrix} 1 & 0 & 0 \\ 0 & 0 & 0 \end{bmatrix} = \begin{bmatrix} 1 & 0 & 0 \\ 0 & 0 & 0 \\ 0 & 0 & 0 \end{bmatrix}$$

$$AA^+A = \begin{bmatrix} 1 & 0 & 0 \\ 0 & 0 & 0 \\ 0 & 0 & 0 \end{bmatrix}\begin{bmatrix} 1 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix} = \begin{bmatrix} 1 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix} = A$$

This confirms condition 1 holds for this example by direct computation.

### Solving Least Squares Problems

For an overdetermined system $Ax = b$ (more equations than unknowns, $m > n$), which typically has no exact solution, the pseudoinverse gives the solution that minimizes the residual:

$$x^* = A^+b = \arg\min_x \|Ax - b\|_2$$

This is a standard, provable result in linear algebra connecting the pseudoinverse directly to least-squares regression. When $A$ has full column rank, this matches the normal equations solution $x^* = (A^TA)^{-1}A^Tb$ shown above.

For an underdetermined system ($m < n$, more unknowns than equations), which typically has infinitely many exact solutions, the pseudoinverse gives the **minimum-norm solution**:

$$x^* = A^+b = \arg\min_{x: Ax=b} \|x\|_2$$

This is also a standard, provable property of the Moore-Penrose pseudoinverse.

### Table: Pseudoinverse by Matrix Shape

| Matrix Shape | Rank Condition | Formula | Interpretation |
|---|---|---|---|
| Square, invertible | Full rank | $A^{-1}$ | Exact solution |
| Tall ($m>n$) | Full column rank | $(A^TA)^{-1}A^T$ | Least-squares (best fit) |
| Wide ($m<n$) | Full row rank | $A^T(AA^T)^{-1}$ | Minimum-norm solution |
| Any shape | Rank-deficient | SVD-based formula only | Combines both properties |

This table reflects standard, provable relationships in linear algebra.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 460 260">
  <text x="230" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">Pseudoinverse Solution Types (svg_diagram)</text>

  <text x="115" y="55" text-anchor="middle" font-size="12" fill="#333">Overdetermined (m &gt; n)</text>
  <line x1="60" y1="150" x2="170" y2="150" stroke="#888" stroke-width="1" />
  <line x1="115" y1="90" x2="115" y2="210" stroke="#888" stroke-width="1" />
  <line x1="70" y1="180" x2="160" y2="115" stroke="#ccc" stroke-width="1.5" />
  <circle cx="90" cy="130" r="3" fill="#2563eb" />
  <circle cx="105" cy="170" r="3" fill="#2563eb" />
  <circle cx="130" cy="140" r="3" fill="#2563eb" />
  <circle cx="145" cy="165" r="3" fill="#2563eb" />
  <text x="115" y="230" text-anchor="middle" font-size="10" fill="#555">Best-fit line (least squares)</text>

  <text x="345" y="55" text-anchor="middle" font-size="12" fill="#333">Underdetermined (m &lt; n)</text>
  <line x1="290" y1="150" x2="400" y2="150" stroke="#888" stroke-width="1" />
  <line x1="345" y1="90" x2="345" y2="210" stroke="#888" stroke-width="1" />
  <line x1="300" y1="180" x2="390" y2="115" stroke="#dc2626" stroke-width="2" />
  <circle cx="345" cy="147" r="4" fill="#059669" />
  <line x1="345" y1="150" x2="345" y2="147" stroke="#059669" stroke-width="2" />
  <text x="345" y="230" text-anchor="middle" font-size="10" fill="#555">Closest point on solution line to origin</text>
</svg>

### Relationship to Rank-Deficient Cases

When $A$ does not have full row or column rank (i.e., it is "rank-deficient"), neither $A^TA$ nor $AA^T$ is invertible, so the simplified formulas above do not apply. In this situation, the SVD-based construction is the only general approach that reliably produces the pseudoinverse in every case, since it uses only the reciprocals of the nonzero singular values and naturally excludes the zero ones. This is a standard justification found in linear algebra references for why the SVD-based definition is the general-purpose formula.

### Why This Matters for Machine Learning

- **Linear regression**: ordinary least-squares regression can be solved directly via the pseudoinverse, $\hat{\beta} = X^+y$, which is mathematically equivalent to the normal equations approach when $X^TX$ is invertible, and remains well-defined even when $X^TX$ is singular (e.g., due to collinear features). This is a standard, provable connection between pseudoinverse and regression.
- **Handling multicollinearity**: [Inference] because the pseudoinverse handles rank-deficient matrices gracefully via the SVD construction (excluding near-zero singular values rather than dividing by them), it is often discussed as a more numerically stable alternative to directly inverting $X^TX$ when features are highly correlated — though I cannot verify the specific numerical stability improvement for any given dataset without testing it directly. This should not be read as a claim that the pseudoinverse eliminates all issues arising from multicollinearity, since interpretability and variance of coefficient estimates can still be affected.
- **Underdetermined systems in deep learning**: [Speculation] some neural network contexts involve underdetermined linear systems, and the minimum-norm solution property of the pseudoinverse is conceptually related to certain regularization behaviors, but I do not have a confirmed source connecting this directly to standard training procedures, so I am labeling this connection as speculative rather than established.
- **Regularized alternatives**: [Inference] in practice, rather than computing a pseudoinverse for ill-conditioned problems, practitioners often use regularized alternatives such as ridge regression (which adds $\lambda I$ before inverting), since this avoids relying on very small singular values that can amplify noise — this reasoning follows from the condition number material covered earlier, but I cannot verify current common practice preferences across the field without checking a specific, current source.

I cannot verify how any specific current machine learning library implements pseudoinverse computation internally (e.g., exact algorithm, default tolerance for treating small singular values as zero) without checking that library's current, specific documentation directly.

### Key Points

- The Moore-Penrose pseudoinverse generalizes matrix inversion to any matrix shape via $A^+ = V\Sigma^+U^T$, using reciprocals of nonzero singular values only.
- It uniquely satisfies four standard defining conditions and reduces to the ordinary inverse when $A$ is square and invertible.
- For overdetermined systems, it produces the least-squares solution; for underdetermined systems, it produces the minimum-norm solution — both are proven properties, not inferences.
- The SVD-based formula is the general-purpose approach that remains valid even for rank-deficient matrices, where simplified formulas involving $(A^TA)^{-1}$ or $(AA^T)^{-1}$ do not apply.

**Related Topics**

- Singular values and singular vectors (direct prerequisite)
- Computing the SVD (numerical methods)
- Low-rank matrix approximation (related SVD application)
- Linear regression and the normal equations
- Ridge regression and Tikhonov regularization
- Condition number and numerical stability of matrix inversion
- Overdetermined and underdetermined linear systems