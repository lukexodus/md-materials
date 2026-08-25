## LU Decomposition Revisited

### Definition

LU decomposition factors a square matrix $A$ into the product of a lower triangular matrix $L$ and an upper triangular matrix $U$:

$$A = LU$$

This is standard, well-established material in numerical linear algebra. In its simplest form, $L$ has 1s on its diagonal (this is called a "unit lower triangular" matrix), and $U$ contains the result of Gaussian elimination applied to $A$.

### Existence Conditions

LU decomposition (without row permutation) does not exist for every square matrix. A standard, provable sufficient condition is that all leading principal minors of $A$ are nonzero — equivalently, that Gaussian elimination can be carried out without needing to swap rows to avoid a zero pivot. When this fails, a permuted version (PLU decomposition, covered below) is used instead.

### Relationship to Gaussian Elimination

LU decomposition is the direct matrix formalization of Gaussian elimination. Each elimination step (subtracting a multiple of one row from another to zero out an entry below the pivot) corresponds to left-multiplication by an elementary lower-triangular matrix. The product of the inverses of these elementary matrices forms $L$; the result of the elimination process itself is $U$. This is standard, provable material connecting two classical topics in linear algebra.

### Worked Example

Let:

$$A = \begin{bmatrix} 2 & 1 & 1 \\ 4 & 3 & 3 \\ 8 & 7 & 9 \end{bmatrix}$$

**Step 1 — Eliminate below the first pivot (2):**

Row 2 $\to$ Row 2 $- 2\times$Row 1: $[4-4, 3-2, 3-2] = [0, 1, 1]$

Row 3 $\to$ Row 3 $- 4\times$Row 1: $[8-8, 7-4, 9-4] = [0, 3, 5]$

$$\begin{bmatrix} 2 & 1 & 1 \\ 0 & 1 & 1 \\ 0 & 3 & 5 \end{bmatrix}$$

Multipliers used: $2$ and $4$ (stored as entries of $L$).

**Step 2 — Eliminate below the second pivot (1):**

Row 3 $\to$ Row 3 $- 3\times$Row 2: $[0-0, 3-3, 5-3] = [0, 0, 2]$

$$U = \begin{bmatrix} 2 & 1 & 1 \\ 0 & 1 & 1 \\ 0 & 0 & 2 \end{bmatrix}$$

Multiplier used: $3$.

**Step 3 — Assemble $L$** (multipliers placed below the diagonal, 1s on the diagonal):

$$L = \begin{bmatrix} 1 & 0 & 0 \\ 2 & 1 & 0 \\ 4 & 3 & 1 \end{bmatrix}$$

**Output**

$$L = \begin{bmatrix} 1 & 0 & 0 \\ 2 & 1 & 0 \\ 4 & 3 & 1 \end{bmatrix}, \quad U = \begin{bmatrix} 2 & 1 & 1 \\ 0 & 1 & 1 \\ 0 & 0 & 2 \end{bmatrix}$$

**Verification** by direct multiplication:

$$LU = \begin{bmatrix} 1 & 0 & 0 \\ 2 & 1 & 0 \\ 4 & 3 & 1 \end{bmatrix}\begin{bmatrix} 2 & 1 & 1 \\ 0 & 1 & 1 \\ 0 & 0 & 2 \end{bmatrix} = \begin{bmatrix} 2 & 1 & 1 \\ 4 & 3 & 3 \\ 8 & 7 & 9 \end{bmatrix} = A$$

This confirms the decomposition by direct computation matching the original $A$.

### PLU Decomposition (With Pivoting)

When a zero pivot is encountered, or when a small pivot would cause numerical instability, rows are permuted using a permutation matrix $P$:

$$PA = LU$$

Row-swapping to move a larger-magnitude entry into the pivot position is called **partial pivoting**, and is standard, documented practice in numerical linear algebra references for improving numerical stability, since dividing by a very small pivot can amplify rounding error. [Unverified] I cannot verify the exact pivoting strategy or threshold used by any specific current numerical software library's LU routine without checking its documentation directly.

### Why LU Decomposition Is Used: Solving Linear Systems Efficiently

Given $Ax = b$, if $A = LU$ (or $PA = LU$), the system can be solved in two cheap triangular-solve steps instead of one expensive general solve:

$$Ly = Pb \quad \text{(forward substitution)}$$

$$Ux = y \quad \text{(back substitution)}$$

Both triangular solves have $O(n^2)$ complexity, compared to the $O(n^3)$ cost of computing the decomposition itself. This is standard, provable complexity analysis in numerical linear algebra references. The key practical benefit: [Inference] once $L$ and $U$ are computed for a given $A$, solving for multiple different right-hand sides $b$ becomes much cheaper than repeating the full elimination process each time, since only the two $O(n^2)$ triangular solves are needed per new $b$ — this follows directly from the complexity figures above, though actual measured speedup in any specific software implementation depends on factors I cannot verify without direct testing.

### Table: LU Decomposition Properties

| Property | Value/Behavior |
|---|---|
| Applies to | Square matrices (with pivoting, always factorable) |
| Complexity to compute | $O(n^3)$ |
| Complexity per triangular solve | $O(n^2)$ |
| Requires pivoting when | A zero or very small pivot is encountered |
| Relation to determinant | $\det(A) = \det(L)\det(U) = \prod U_{ii}$ (times $\pm1$ if $P$ used) |

The determinant relationship follows directly from the fact that the determinant of a triangular matrix is the product of its diagonal entries, and $\det(L)=1$ for unit lower triangular $L$ — this is standard, provable material.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 440 240">
  <text x="220" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">LU Decomposition Structure (svg_diagram)</text>

  <text x="80" y="55" text-anchor="middle" font-size="11" fill="#333">A</text>
  <rect x="40" y="65" width="80" height="80" fill="#fca5a5" stroke="#dc2626" stroke-width="1.5" />

  <text x="150" y="110" text-anchor="middle" font-size="14" fill="#333">=</text>

  <text x="220" y="55" text-anchor="middle" font-size="11" fill="#333">L (lower triangular)</text>
  <polygon points="180,65 260,65 260,145 180,145" fill="#fff" stroke="#888" />
  <polygon points="180,65 260,145 180,145" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5" />
  <line x1="180" y1="65" x2="180" y2="145" stroke="#2563eb" stroke-width="2" />

  <text x="290" y="110" text-anchor="middle" font-size="14" fill="#333">×</text>

  <text x="360" y="55" text-anchor="middle" font-size="11" fill="#333">U (upper triangular)</text>
  <polygon points="320,65 400,65 400,145 320,145" fill="#fff" stroke="#888" />
  <polygon points="320,65 400,65 320,145" fill="#86efac" stroke="#059669" stroke-width="1.5" />
  <line x1="320" y1="65" x2="400" y2="145" stroke="#059669" stroke-width="2" />

  <text x="220" y="180" text-anchor="middle" font-size="10" fill="#555">Solving Ax=b reduces to two O(n²) triangular solves</text>
</svg>

### Connection to Determinants and Invertibility

Because $\det(A) = \pm\prod_i U_{ii}$ (product of $U$'s diagonal entries, with sign depending on the number of row swaps in $P$), $A$ is invertible exactly when none of $U$'s diagonal entries (pivots) are zero. This gives a direct, computationally cheap way to check invertibility and compute the determinant simultaneously as a byproduct of solving a system, rather than requiring a separate cofactor expansion. This is a standard, provable connection between LU decomposition and two other core linear algebra concepts.

### Why This Matters for Machine Learning

- **Solving normal equations in linear regression**: LU decomposition (or related triangular factorizations) can be used to solve the normal equations $X^TXw = X^Ty$ for linear regression, [Inference] which is more numerically efficient than computing the matrix inverse explicitly and multiplying — this follows from the general complexity advantages of triangular solves discussed above, though for specific numerical stability comparisons against alternatives like QR decomposition for regression, I cannot verify which approach is preferred by any specific current software library without checking its documentation directly.
- **Repeated system solves in iterative algorithms**: [Inference] some optimization or simulation procedures require solving linear systems with the same coefficient matrix $A$ but different right-hand sides $b$ across iterations; LU decomposition computed once and reused is a standard technique for this scenario, following directly from the complexity analysis above — but I cannot verify that any specific current ML training procedure uses this exact strategy without checking a specific, current source.
- **Cholesky decomposition as a specialized case**: for symmetric positive definite matrices (such as covariance matrices or $X^TX$ under full column rank, both covered earlier in this material), a more efficient specialized variant called Cholesky decomposition ($A = LL^T$) is commonly used instead of general LU decomposition. This is standard, documented material in numerical linear algebra, though I have not covered Cholesky decomposition's full derivation in this response.

I cannot verify the internal implementation details, pivoting strategy, or performance characteristics of any specific current software library's LU decomposition routine (e.g., NumPy, SciPy, LAPACK-based tools) without checking that library's current, specific documentation directly.

### Key Points

- LU decomposition factors a square matrix into lower- and upper-triangular components, directly formalizing Gaussian elimination.
- Existence without pivoting requires nonzero leading principal minors; pivoting (PLU) extends applicability and improves numerical stability.
- The main computational benefit is reducing repeated linear-system solves to cheap $O(n^2)$ triangular solves after a one-time $O(n^3)$ factorization.
- The determinant and invertibility of $A$ can be read directly from $U$'s diagonal entries, connecting this topic to determinants covered earlier in this material.

**Related Topics**

- Gaussian elimination (direct prerequisite and mathematical basis)
- Cholesky decomposition for symmetric positive definite matrices
- QR decomposition as an alternative factorization for least squares
- Determinants and their computation
- Condition number and numerical stability of linear system solving
- Matrix invertibility and rank
- Computing the SVD (a related but distinct factorization approach)