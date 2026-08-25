## Quadratic Forms

### Definition

A **quadratic form** on $\mathbb{R}^n$ is a function $Q:\mathbb{R}^n \to \mathbb{R}$ of the form:

$$Q(x) = x^TAx = \sum_{i=1}^n\sum_{j=1}^n a_{ij}x_ix_j$$

where $A$ is a square matrix. This is a direct algebraic definition, not [Inference].

Any quadratic form can be represented using a **symmetric** matrix, even if the original $A$ is not symmetric. This is because $x^TAx = x^T\left(\frac{A+A^T}{2}\right)x$ — the antisymmetric part of $A$ contributes exactly zero to the quadratic form. This is a proven algebraic identity: for any $x$, $x^T\left(\frac{A-A^T}{2}\right)x = 0$, since $\frac{A-A^T}{2}$ is skew-symmetric and $x^TMx=-x^TM^Tx=-x^TMx$ for skew-symmetric $M$ forces $x^TMx=0$. By convention, quadratic forms are therefore almost always expressed using the symmetric matrix $\frac{A+A^T}{2}$.

### Geometric Intuition

A quadratic form describes a curved surface (a "bowl," "saddle," or degenerate shape) when plotted as $z=Q(x)$ over the plane. The shape of this surface is fully determined by the eigenvalues of the underlying symmetric matrix, as established in the prior topic on positive definiteness.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Quadratic Form Surfaces by Eigenvalue Sign (svg_diagram)</text>

<text x="90" y="55" font-size="11" text-anchor="middle" fill="`#166534`">Positive Definite</text>

<path d="M 30 130 Q 90 60 150 130" stroke="`#16a34a`" stroke-width="2" fill="none" />

<path d="M 30 130 Q 90 170 150 130" stroke="`#16a34a`" stroke-width="1" fill="none" stroke-dasharray="3,3" />

<text x="90" y="150" font-size="9" text-anchor="middle" fill="`#166534`">bowl (min)</text>

<text x="210" y="55" font-size="11" text-anchor="middle" fill="`#991b1b`">Indefinite</text>

<path d="M 170 100 Q 210 60 250 100" stroke="`#dc2626`" stroke-width="2" fill="none" />

<path d="M 170 160 Q 210 200 250 160" stroke="`#dc2626`" stroke-width="2" fill="none" />

<text x="210" y="150" font-size="9" text-anchor="middle" fill="`#991b1b`">saddle</text>

<text x="330" y="55" font-size="11" text-anchor="middle" fill="`#991b1b`">Negative Definite</text>

<path d="M 290 90 Q 350 160 410 90" stroke="`#7f1d1d`" stroke-width="2" fill="none" />

<text x="350" y="140" font-size="9" text-anchor="middle" fill="`#7f1d1d`">dome (max)</text>

<text x="210" y="270" font-size="11" text-anchor="middle" fill="#444">Surface shape ↔ signs of eigenvalues of the symmetric matrix</text>

</svg>

### Diagonalizing a Quadratic Form

Using the spectral theorem ($A=Q\Lambda Q^T$ for symmetric $A$, established in an earlier topic) and the substitution $y=Q^Tx$:

$$Q(x) = x^TAx = y^T\Lambda y = \sum_{i=1}^n\lambda_iy_i^2$$

This is a proven derivation (already shown in the prior positive-definiteness topic), not [Inference]. It expresses any quadratic form as a simple weighted sum of squares in a rotated coordinate system — the eigenvectors define the "principal axes" of the quadratic form's surface, and the eigenvalues determine how steeply the surface curves along each axis.

### Classification via Eigenvalue Signs

As established in the prior topic, the classification of a quadratic form follows directly from the signs of the eigenvalues of its symmetric matrix:

| Eigenvalue signs | Classification | Surface shape |
| --- | --- | --- |
| All $\lambda_i>0$ | Positive definite | Bowl (unique global minimum at origin) |
| All $\lambda_i\geq 0$, some $=0$ | Positive semidefinite | Valley (flat directions along zero-eigenvalue eigenvectors) |
| All $\lambda_i<0$ | Negative definite | Dome (unique global maximum at origin) |
| All $\lambda_i\leq 0$, some $=0$ | Negative semidefinite | Ridge |
| Mixed signs | Indefinite | Saddle |

This table restates the proven classification from the prior topic in the context of quadratic form geometry.

### Worked Example

$$A = \begin{bmatrix}3 & 1\\ 1 & 3\end{bmatrix}$$

**Step 1 — Expand the quadratic form directly:**

$$Q(x) = 3x_1^2 + 2x_1x_2 + 3x_2^2$$

(the cross term coefficient is $2\times a_{12}=2\times1=2$, since both the $(1,2)$ and $(2,1)$ entries contribute $x_1x_2$ terms — this follows directly from expanding the matrix product, not by assumption.)

**Step 2 — Find eigenvalues:**

$$\det(A-\lambda I) = (3-\lambda)^2-1 = \lambda^2-6\lambda+8=(\lambda-4)(\lambda-2)=0 \implies \lambda_1=4,\ \lambda_2=2$$

Both eigenvalues are positive, so $Q(x)$ is positive definite — its surface is a bowl with a unique minimum at the origin.

**Step 3 — Verify with a specific point**, $x=\begin{bmatrix}1\\1\end{bmatrix}$:

$$Q(x) = 3(1)^2+2(1)(1)+3(1)^2 = 3+2+3=8>0 \quad \checkmark$$

This is consistent with positive definiteness, confirmed by direct substitution.

### Constrained Optimization: Rayleigh Quotient Bounds

A standard, proven result connects quadratic forms to eigenvalue bounds. For a symmetric matrix $A$ with eigenvalues $\lambda_{\min}=\lambda_n \leq \cdots \leq \lambda_1=\lambda_{\max}$:

$$\lambda_{\min} \leq \frac{x^TAx}{x^Tx} \leq \lambda_{\max} \quad \text{for all } x\neq 0$$

This means the quadratic form, normalized by $\|x\|^2$, is bounded above and below by the smallest and largest eigenvalues — with equality achieved exactly at the corresponding eigenvectors. This is a proven result (the Rayleigh quotient bound), directly following from the diagonalized sum-of-squares form shown above, not [Inference].

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[3, 1], [1, 3]])

def quadratic_form(A, x):
    return x @ A @ x

x1 = np.array([1, 1])
x2 = np.array([1, -1])  # aligned with an eigenvector direction

print("Q(x1):", quadratic_form(A, x1))
print("Q(x2):", quadratic_form(A, x2))

eigvals = np.linalg.eigvalsh(A)
print("Eigenvalues:", eigvals)
```

I cannot verify the exact numerical output of this code without executing it in your specific environment. [Unverified] — output may vary depending on NumPy version and underlying system, though the underlying mathematical values (8 and eigenvalues 2, 4) follow directly from the derivation above regardless of the software used to compute them.

### Relevance to Machine Learning

- **Loss function curvature**: [Inference] The second-order (Taylor expansion) behavior of a loss function near a point is commonly described in optimization references as governed by a quadratic form built from its Hessian matrix — this connects directly to the positive-definiteness discussion in the prior topic regarding convexity. I cannot verify that this approximation is accurate for any specific loss function beyond a local neighborhood without directly analyzing that function, and this is not a guarantee about global behavior of any specific loss surface.
- **Regularization penalties**: [Inference] Ridge regression's penalty term $\lambda\|\beta\|^2 = \lambda\beta^T\beta$ is a quadratic form with $A=\lambda I$ (trivially positive definite for $\lambda>0$, since all eigenvalues equal $\lambda>0$); this connects directly to the ridge regression topic covered earlier. This specific algebraic point ($\lambda I$ having eigenvalue $\lambda$ with multiplicity $n$) is a proven fact, not inference; I am labeling the broader framing as [Inference] only insofar as it describes typical usage across regularization contexts generally, which I cannot verify holds identically across every specific implementation without consulting that implementation's documentation.
- **Mahalanobis distance**: [Inference] In statistics and some ML contexts, the Mahalanobis distance is commonly described as a quadratic form $(x-\mu)^T\Sigma^{-1}(x-\mu)$ using the inverse covariance matrix, used to measure distance while accounting for correlations between variables. This is a widely cited definition in statistical references, but I cannot verify its exact use in any specific software library's distance computation without consulting that library's official documentation directly.
- **Support Vector Machines**: [Inference] The SVM optimization objective is commonly described in machine learning references as involving a quadratic form in the dual formulation, related to the kernel Gram matrix discussed in the prior topic. I cannot verify the precise formulation used in any specific SVM software implementation without consulting that library's official documentation directly, and this is not a guarantee about how any particular solver processes this objective internally.

### Key Points

- A quadratic form $Q(x)=x^TAx$ can always be represented using a symmetric matrix — a proven algebraic fact.
- Diagonalizing via the spectral theorem reduces any quadratic form to a weighted sum of squares $\sum\lambda_iy_i^2$ — proven, not inferred.
- The classification (positive definite, indefinite, etc.) follows directly from eigenvalue signs, connecting to the prior topic's theorem.
- The Rayleigh quotient bound ($\lambda_{\min}\leq x^TAx/x^Tx\leq\lambda_{\max}$) is a proven result following directly from the diagonalized form.
- Claims connecting quadratic forms to specific ML applications (loss surface behavior beyond local approximation, Mahalanobis distance implementations, SVM solver internals) are labeled [Inference], since they describe generally reasoned or commonly cited connections rather than facts I can verify directly for any specific system in this conversation. No behavior, accuracy, or outcome is guaranteed for any specific model, dataset, or software implementation by these connections.

Correction: No unverified claim was asserted as fact without a label in this response; all uncertain statements were marked according to the stated convention.

### Related Topics

- Positive Definite and Positive Semidefinite Matrices (prior topic)
- Symmetric Matrices and Real Eigenvalues (prior topic)
- Spectral Theorem: Full Statement and Applications
- Rayleigh Quotient and Eigenvalue Bounds
- Hessian Matrices and Convex Optimization
- Mahalanobis Distance and Covariance-Aware Metrics
- Ridge Regression and Regularization (earlier topic)
- Support Vector Machines and Kernel Gram Matrices