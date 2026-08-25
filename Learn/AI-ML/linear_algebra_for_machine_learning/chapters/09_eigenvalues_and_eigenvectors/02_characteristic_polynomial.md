## Characteristic Polynomial

### Definition

For a square matrix $A \in \mathbb{R}^{n \times n}$, the **characteristic polynomial** is defined as:

$$p(\lambda) = \det(A - \lambda I)$$

This is a degree-$n$ polynomial in $\lambda$. Its roots are precisely the **eigenvalues** of $A$ — this is a direct algebraic definition, not an inference.

Expanded, the characteristic polynomial has the general form:

$$p(\lambda) = (-1)^n\lambda^n + (-1)^{n-1}\text{tr}(A)\lambda^{n-1} + \cdots + \det(A)$$

The coefficients of this polynomial are related to invariants of $A$ — most notably, the coefficient structure connects the trace and determinant of $A$ to sums and products of eigenvalues (detailed below).

### Why This Definition Produces Eigenvalues

An eigenvalue-eigenvector pair satisfies:

$$Av = \lambda v, \quad v \neq 0$$

Rearranging:

$$(A - \lambda I)v = 0$$

For a nonzero vector $v$ to satisfy this equation, the matrix $(A - \lambda I)$ must be **singular** (non-invertible) — otherwise the only solution would be $v = 0$. A matrix is singular exactly when its determinant is zero:

$$\det(A - \lambda I) = 0$$

This is why solving the characteristic polynomial for its roots gives the eigenvalues of $A$. This derivation follows directly from the definition of eigenvalues and standard properties of determinants — it is a proven mathematical result, not [Inference].

### Geometric Intuition

Each root $\lambda$ of the characteristic polynomial identifies a direction (or directions) in which $A$ acts as pure scaling — stretching or compressing space along an eigenvector, without rotating it off its own line. The characteristic polynomial is the algebraic tool that locates these special scaling directions.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 280">
<text x="200" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Eigenvalues as Roots of the Characteristic Polynomial (svg_diagram)</text>
<line x1="40" y1="150" x2="360" y2="150" stroke="#999" stroke-width="1" />
<line x1="200" y1="40" x2="200" y2="240" stroke="#999" stroke-width="1" />
<text x="365" y="148" font-size="11" fill="#666">λ</text>
<text x="205" y="50" font-size="11" fill="#666">p(λ)</text>
<path d="M 60 60 C 120 220, 160 220, 200 150 C 240 80, 280 80, 340 210" stroke="#2563eb" stroke-width="2.5" fill="none" />
<circle cx="120" cy="150" r="4" fill="#dc2626" />
<circle cx="200" cy="150" r="4" fill="#dc2626" />
<circle cx="300" cy="150" r="4" fill="#dc2626" />

<text x="115" y="170" font-size="11" fill="`#dc2626`">λ₁</text>

<text x="195" y="170" font-size="11" fill="`#dc2626`">λ₂</text>

<text x="295" y="170" font-size="11" fill="`#dc2626`">λ₃</text>

<text x="200" y="265" font-size="11" text-anchor="middle" fill="#444">Roots of p(λ) = det(A − λI) are the eigenvalues</text>

</svg>

### Coefficients and Matrix Invariants

For a $2\times 2$ matrix $A = \begin{bmatrix}a & b\\ c & d\end{bmatrix}$, the characteristic polynomial is:

$$p(\lambda) = \lambda^2 - \text{tr}(A)\lambda + \det(A)$$

where $\text{tr}(A) = a+d$ is the trace (sum of diagonal entries) and $\det(A) = ad-bc$.

This generalizes: for an $n \times n$ matrix, if $\lambda_1, \lambda_2, \ldots, \lambda_n$ are the eigenvalues (counted with multiplicity, including complex ones), then:

$$\text{tr}(A) = \sum_{i=1}^n \lambda_i, \qquad \det(A) = \prod_{i=1}^n \lambda_i$$

These two identities are standard, provable results in linear algebra — the trace equals the sum of eigenvalues, and the determinant equals their product.

### Algebraic vs. Geometric Multiplicity

- **Algebraic multiplicity**: how many times a given root $\lambda$ appears in the characteristic polynomial (its multiplicity as a root).
- **Geometric multiplicity**: the dimension of the eigenspace associated with $\lambda$ (i.e., the number of linearly independent eigenvectors for that eigenvalue).

A standard, provable fact is that geometric multiplicity is always less than or equal to algebraic multiplicity for any given eigenvalue. When they differ, the matrix is called **defective** and cannot be diagonalized. This distinction is foundational for understanding when diagonalization is possible.

### Worked Example

Let:

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix}$$

**Step 1 — Form $A - \lambda I$:**

$$A - \lambda I = \begin{bmatrix}4-\lambda & 1\\ 2 & 3-\lambda\end{bmatrix}$$

**Step 2 — Compute the determinant:**

$$\det(A-\lambda I) = (4-\lambda)(3-\lambda) - (1)(2) = \lambda^2 - 7\lambda + 12 - 2 = \lambda^2 - 7\lambda + 10$$

**Step 3 — Factor and solve:**

$$\lambda^2 - 7\lambda + 10 = (\lambda-5)(\lambda-2) = 0 \implies \lambda_1 = 5, \ \lambda_2 = 2$$

**Verification using trace/determinant identities:**

- $\text{tr}(A) = 4+3 = 7 = 5+2$ ✓
- $\det(A) = (4)(3)-(1)(2) = 10 = (5)(2)$ ✓

Both checks confirm the computed eigenvalues directly through algebraic identities.

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[4, 1], [2, 3]])

eigenvalues = np.linalg.eigvals(A)
print("Eigenvalues:", eigenvalues)

# Manual characteristic polynomial coefficients
coeffs = np.poly(A)
print("Characteristic polynomial coefficients:", coeffs)
print("Roots of polynomial:", np.roots(coeffs))
```

[Unverified] The exact numerical output (e.g., ordering of eigenvalues, floating-point precision, or minor formatting differences) may vary depending on the NumPy version and hardware used to run this code. I cannot verify the precise output without executing it in your specific environment.

### Complex and Repeated Roots

The characteristic polynomial of a real matrix can have:

- **Real, distinct roots** — the typical well-behaved case, diagonalizable with a real eigenbasis.
- **Repeated real roots** — may or may not be diagonalizable, depending on whether geometric multiplicity matches algebraic multiplicity.
- **Complex conjugate pairs** — occur for matrices representing rotations or oscillatory dynamics; eigenvalues appear as $a \pm bi$.

This trichotomy is a standard, provable classification from the fundamental theorem of algebra applied to real-coefficient polynomials — it is not situational or inferred.

### Relevance to Machine Learning

- **PCA and covariance matrices**: the characteristic polynomial of a covariance matrix determines the eigenvalues that quantify variance along principal component directions.
- **Stability analysis in optimization**: in analyzing convergence of iterative algorithms (e.g., gradient descent on quadratic loss surfaces), the eigenvalues of the Hessian — found via its characteristic polynomial — determine whether the loss surface is convex, and influence how convergence behaves.
- [Inference] The conditioning of an optimization problem is commonly described as being influenced by the ratio of the largest to smallest eigenvalue of the Hessian (the condition number). This is a widely cited relationship in numerical optimization literature, reasoned from the structure of gradient-based updates, but the practical effect on any specific training run depends on many additional factors and cannot be verified without empirical testing on that specific model and dataset. This claim does not constitute a guarantee about training behavior.
- **Spectral clustering**: relies on eigenvalues of graph Laplacian matrices, found via characteristic polynomials in principle (though computed via numerical methods in practice, not literal polynomial root-finding — see note below).

### Practical Note: Characteristic Polynomials Are Rarely Computed Directly

[Inference] In practice, numerical linear algebra libraries generally do not compute eigenvalues by explicitly forming and solving the characteristic polynomial, because root-finding for high-degree polynomials is numerically unstable. This is a well-established point in numerical analysis reasoning (small coefficient errors can cause large root errors for higher-degree polynomials), but I cannot verify the specific internal implementation details of every library without consulting each library's documented source. Instead, methods such as QR algorithm-based iterative techniques are commonly used. I do not have access to confirm the exact implementation of any particular software version without checking that library's official documentation directly.

### Key Points

- The characteristic polynomial $p(\lambda) = \det(A-\lambda I)$ is a direct algebraic definition whose roots are the eigenvalues of $A$ — this is proven, not inferred.
- Trace equals the sum of eigenvalues; determinant equals their product — both are standard, provable identities.
- Algebraic multiplicity (root multiplicity) is always greater than or equal to geometric multiplicity (eigenspace dimension); this is a proven structural fact, not an empirical observation.
- Complex conjugate eigenvalue pairs arise for matrices without a full real eigenbasis, such as pure rotation matrices.
- Claims about optimization conditioning and library implementation details are labeled [Inference] because they describe generally reasoned behavior rather than confirmed facts about any specific system; I do not have access to verify implementation-level details of specific software without consulting official documentation directly.

### Related Topics

- Eigenvalues and Eigenvectors: Full Derivation and Properties
- Diagonalization and Eigendecomposition
- Trace and Determinant as Matrix Invariants
- Defective Matrices and Jordan Normal Form
- QR Algorithm for Numerical Eigenvalue Computation
- Spectral Theorem for Symmetric Matrices
- Hessian Matrices and Convexity in Optimization
- Graph Laplacians and Spectral Clustering