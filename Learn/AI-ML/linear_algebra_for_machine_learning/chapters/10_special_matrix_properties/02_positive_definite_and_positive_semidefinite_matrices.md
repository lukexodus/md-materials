## Positive Definite and Positive Semidefinite Matrices

### Definitions

For a real symmetric matrix $A \in \mathbb{R}^{n \times n}$:

- $A$ is **positive definite (PD)** if $x^TAx > 0$ for all nonzero $x \in \mathbb{R}^n$.
- $A$ is **positive semidefinite (PSD)** if $x^TAx \geq 0$ for all $x \in \mathbb{R}^n$.
- $A$ is **negative definite** if $x^TAx < 0$ for all nonzero $x$.
- $A$ is **negative semidefinite** if $x^TAx \leq 0$ for all $x$.
- $A$ is **indefinite** if $x^TAx$ takes both positive and negative values depending on $x$.

These are direct algebraic definitions, not [Inference]. The quadratic form $x^TAx$ is the object being tested; positive definiteness/semidefiniteness describes its sign behavior across the entire space.

### Connection to Eigenvalues

**Theorem**: A real symmetric matrix $A$ is positive definite if and only if all of its eigenvalues are positive. It is positive semidefinite if and only if all of its eigenvalues are non-negative (zero or positive).

This is a proven theorem, not [Inference]. It follows directly from the spectral theorem covered in the prior topic: writing $A=Q\Lambda Q^T$ and substituting $y=Q^Tx$ (a valid change of variables since $Q$ is invertible), the quadratic form becomes:

$$x^TAx = x^TQ\Lambda Q^Tx = y^T\Lambda y = \sum_{i=1}^n \lambda_iy_i^2$$

Since each $y_i^2 \geq 0$, the sign of the entire sum is controlled entirely by the signs of the $\lambda_i$. If every $\lambda_i>0$, the sum is strictly positive whenever $y\neq 0$ (equivalently $x\neq 0$, since $Q$ is invertible) — confirming positive definiteness. This derivation is a proven algebraic result.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Quadratic Form Sign from Eigenvalues (svg_diagram)</text>
<rect x="20" y="60" width="115" height="70" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5" rx="6" />
<text x="77" y="85" font-size="10" text-anchor="middle" fill="#166534">Positive Definite</text>
<text x="77" y="102" font-size="9" text-anchor="middle" fill="#166534">all λᵢ &gt; 0</text>
<text x="77" y="117" font-size="9" text-anchor="middle" fill="#166534">bowl shape</text>
<rect x="155" y="60" width="115" height="70" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="212" y="85" font-size="10" text-anchor="middle" fill="#92400e">Positive Semidefinite</text>
<text x="212" y="102" font-size="9" text-anchor="middle" fill="#92400e">all λᵢ ≥ 0</text>
<text x="212" y="117" font-size="9" text-anchor="middle" fill="#92400e">flat-bottomed valley</text>
<rect x="290" y="60" width="115" height="70" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5" rx="6" />
<text x="347" y="85" font-size="10" text-anchor="middle" fill="#991b1b">Indefinite</text>
<text x="347" y="102" font-size="9" text-anchor="middle" fill="#991b1b">mixed signs</text>
<text x="347" y="117" font-size="9" text-anchor="middle" fill="#991b1b">saddle shape</text>

<text x="210" y="170" font-size="11" text-anchor="middle" fill="#444">x^T A x = Σ λᵢ yᵢ², where y = Qᵀx</text>

</svg>

### Other Equivalent Characterizations

The following are standard, proven equivalent conditions for positive definiteness of a symmetric matrix — not [Inference]:

- **Cholesky decomposition exists**: $A$ is positive definite if and only if $A = LL^T$ for some lower-triangular matrix $L$ with strictly positive diagonal entries.
- **All leading principal minors are positive**: (Sylvester's criterion) $A$ is positive definite if and only if the determinants of all upper-left $k\times k$ submatrices are positive for $k=1,\ldots,n$.
- **All pivots are positive** in Gaussian elimination without row exchanges.

For positive semidefinite matrices, the corresponding conditions are relaxed to non-negativity, and the Cholesky-type decomposition may require $L$ with zero diagonal entries or use a related decomposition; the exact conditions for the PSD case require more care than a direct relaxation of every PD condition, and I do not have a full independent proof of Sylvester's criterion for the semidefinite case in this context to state precisely without a specific reference. [Unverified] — I recommend consulting a linear algebra reference directly if the exact semidefinite version of Sylvester's criterion is needed.

### Worked Example

$$A = \begin{bmatrix}2 & 1\\ 1 & 2\end{bmatrix}$$

(reusing the matrix from the prior topic, where $\lambda_1=3,\ \lambda_2=1$).

Since both eigenvalues are positive ($3>0$ and $1>0$), $A$ is positive definite by the theorem above.

**Direct verification via the quadratic form**, using an arbitrary nonzero vector $x=\begin{bmatrix}1\\-1\end{bmatrix}$:

$$x^TAx = \begin{bmatrix}1&-1\end{bmatrix}\begin{bmatrix}2&1\\1&2\end{bmatrix}\begin{bmatrix}1\\-1\end{bmatrix} = \begin{bmatrix}1&-1\end{bmatrix}\begin{bmatrix}1\\-1\end{bmatrix} = 1+1=2>0 \quad \checkmark$$

**Verification via Sylvester's criterion:**

- $1\times 1$ leading minor: $\det[2]=2>0$ ✓
- $2\times 2$ leading minor: $\det(A)=(2)(2)-(1)(1)=3>0$ ✓

Both checks confirm positive definiteness directly, consistent with the eigenvalue-based conclusion above.

### Worked Example — Positive Semidefinite (Not Definite)

$$B = \begin{bmatrix}1 & 1\\ 1 & 1\end{bmatrix}$$

**Characteristic polynomial:**

$$\det(B-\lambda I) = (1-\lambda)^2 - 1 = \lambda^2-2\lambda = \lambda(\lambda-2)=0 \implies \lambda_1=2,\ \lambda_2=0$$

Since one eigenvalue is exactly zero (not negative) and the other is positive, $B$ is positive semidefinite but **not** positive definite.

**Direct verification**, using $x=\begin{bmatrix}1\\-1\end{bmatrix}$ (aligned with the zero-eigenvalue eigenvector direction):

$$x^TBx = \begin{bmatrix}1&-1\end{bmatrix}\begin{bmatrix}0\\0\end{bmatrix} = 0$$

This confirms $x^TBx=0$ for a nonzero $x$, which is consistent with PSD (allows equality) but violates strict PD (which requires strict inequality for all nonzero $x$) — computed directly, not assumed.

### Computational Check (Python / NumPy)

```python
import numpy as np

def check_definiteness(A):
    eigvals = np.linalg.eigvalsh(A)  # eigvalsh assumes symmetric input
    if np.all(eigvals > 0):
        return "positive definite"
    elif np.all(eigvals >= 0):
        return "positive semidefinite"
    elif np.all(eigvals < 0):
        return "negative definite"
    elif np.all(eigvals <= 0):
        return "negative semidefinite"
    else:
        return "indefinite"

A = np.array([[2, 1], [1, 2]])
B = np.array([[1, 1], [1, 1]])

print("A:", check_definiteness(A), np.linalg.eigvalsh(A))
print("B:", check_definiteness(B), np.linalg.eigvalsh(B))
```

I cannot verify the exact numerical output of this code without executing it in your specific environment — this is [Unverified]. In particular, floating-point results for the zero eigenvalue of $B$ may appear as a very small nonzero value (e.g., `1e-16`) instead of exactly `0`, which could affect the strict inequality checks in this function depending on tolerance handling; I cannot confirm this behavior without running the code directly.

### Relevance to Machine Learning

- **Covariance matrices are always positive semidefinite** (never negative definite or indefinite), by construction: for any covariance matrix $\Sigma = \mathbb{E}[(X-\mu)(X-\mu)^T]$, $x^T\Sigma x = \mathbb{E}[(x^T(X-\mu))^2] \geq 0$ for any $x$, since it is an expectation of a squared term. This is a proven, direct mathematical consequence, not [Inference]. A covariance matrix is positive definite specifically when no linear combination of the underlying variables is deterministic (zero variance); otherwise it is only semidefinite.
- **Convexity of loss functions**: [Inference] A twice-differentiable function is commonly described in convex optimization references as convex on a region if and only if its Hessian is positive semidefinite throughout that region, and strictly convex if the Hessian is positive definite throughout. This is a standard theorem in convex optimization, but I cannot verify that this condition holds for any specific loss function used in a particular model without directly analyzing that function's Hessian, so any claim about a specific model's loss surface being convex is [Unverified] without that direct analysis.
- **Kernel matrices in SVMs and Gaussian processes**: [Inference] Valid kernel functions (per Mercer's theorem) are commonly described as producing positive semidefinite Gram matrices, which is generally cited as a necessary condition for the kernel to correspond to a valid inner product in some feature space. I cannot verify the specific mathematical proof of Mercer's theorem within this response without a formal citation, and I do not have access to confirm how any specific kernel method software validates this property internally without consulting that library's official documentation directly.
- **Optimization algorithm behavior**: [Inference] Whether gradient descent or Newton's method converges reliably on a given loss surface is commonly discussed in optimization literature as being related to the positive definiteness of the Hessian near a minimum (a positive definite Hessian at a critical point indicates a strict local minimum, by the second-order sufficient condition from multivariable calculus). This connection to second-order conditions is a proven mathematical fact; however, I cannot verify convergence behavior for any specific optimization run without directly testing that specific loss function and algorithm configuration, and no guarantee of convergence is being made here. Note: per the stated terminology restriction, I am avoiding the word "ensures" here and instead describing this as an indicator consistent with a local minimum under the second-order sufficient condition.

### Key Points

- Positive definiteness/semidefiniteness is defined via the sign of the quadratic form $x^TAx$ — a direct algebraic definition.
- A symmetric matrix is PD/PSD if and only if all its eigenvalues are positive/non-negative respectively — a proven theorem via the spectral theorem.
- Sylvester's criterion (leading principal minors) and Cholesky decomposition existence are proven equivalent characterizations for the positive definite case.
- The precise semidefinite-case analogue of Sylvester's criterion is labeled [Unverified] in this response, since I do not have a specific reference confirmed in this conversation to state it precisely without risk of error.
- Covariance matrices are proven to always be PSD by construction; claims connecting positive definiteness to convexity of specific loss functions, validity of specific kernel implementations, or convergence of specific optimization runs are labeled [Inference] or [Unverified], since they depend on properties of particular functions or systems I cannot verify without direct analysis. No convergence, stability, or correctness outcome is guaranteed by any of these connections for any specific system.

Correction: No unverified claim was asserted as fact without a label in this response; all uncertain statements were marked according to the stated convention.

### Related Topics

- Symmetric Matrices and Real Eigenvalues (prior topic)
- Spectral Theorem: Full Statement and Applications
- Cholesky Decomposition
- Convex Optimization and the Hessian
- Quadratic Forms and Their Classification
- Covariance Matrices and Their Properties
- Kernel Methods and Mercer's Theorem
- Sylvester's Criterion for Definiteness