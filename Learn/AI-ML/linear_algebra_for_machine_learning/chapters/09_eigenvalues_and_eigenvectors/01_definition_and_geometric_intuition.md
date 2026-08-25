## Definition and Geometric Intuition

### Formal Definition

Given a vector $v$ and a subspace $S$ (such as a line or plane through the origin), the **projection** of $v$ onto $S$ is the vector in $S$ closest to $v$, measured by Euclidean distance. For projection onto a single vector $u$ (a one-dimensional subspace), the formula is:

$$\text{proj}_u(v) = \frac{u^Tv}{u^Tu}\,u$$

If $u$ is already a unit vector ($\|u\|=1$), this simplifies to:

$$\text{proj}_u(v) = (u^Tv)\,u$$

The scalar $u^Tv$ (when $u$ is unit length) is called the **scalar projection** — it measures how far $v$ extends in the direction of $u$. Multiplying that scalar back by $u$ produces the **vector projection** — the actual vector lying along $u$.

### Geometric Intuition

Projection answers the question: *"If I could only move in the direction of $u$, how far along $u$ would I need to go to get as close as possible to $v$?"*

Picture $v$ as an arrow and $u$ as a direction (a line through the origin). Drop a perpendicular line from the tip of $v$ down to the line spanned by $u$. The point where that perpendicular line meets $u$ is the projection. The projection is the "shadow" $v$ casts onto the line, if a light source shone perpendicular to that line.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">
<text x="200" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Vector Projection onto a Line (svg_diagram)</text>
<line x1="40" y1="230" x2="360" y2="90" stroke="#999" stroke-width="1.5" />
<text x="365" y="88" font-size="12" fill="#666">u</text>
<line x1="80" y1="230" x2="220" y2="60" stroke="#dc2626" stroke-width="2.5" marker-end="url(#p1)" />
<text x="225" y="55" font-size="12" fill="#dc2626">v</text>
<line x1="80" y1="230" x2="210" y2="177" stroke="#2563eb" stroke-width="2.5" marker-end="url(#p2)" />
<text x="195" y="200" font-size="12" fill="#2563eb">proj_u(v)</text>
<line x1="220" y1="60" x2="210" y2="177" stroke="#16a34a" stroke-width="2" stroke-dasharray="4,3" />
<text x="235" y="120" font-size="11" fill="#16a34a">v − proj_u(v)</text>
<rect x="198" y="164" width="10" height="10" fill="none" stroke="#555" stroke-width="1" transform="rotate(-30 203 169)" />
</svg>

### Why the Perpendicular Condition Defines "Closest"

The key geometric fact is that the projection is the unique point on the line (or subspace) minimizing distance to $v$, and this minimum occurs exactly where the **residual vector** $v - \text{proj}_u(v)$ is orthogonal to $u$:

$$u^T\big(v - \text{proj}_u(v)\big) = 0$$

This is a direct algebraic consequence of the projection formula — substituting $\text{proj}_u(v) = \frac{u^Tv}{u^Tu}u$ into the expression above and simplifying yields zero, so this is not an inference but a verifiable algebraic identity.

**Derivation of the formula** (why it must look like this):

We want to find the scalar $c$ such that $cu$ is closest to $v$, i.e., minimizing $\|v - cu\|^2$. Taking the derivative with respect to $c$ and setting it to zero:

$$\frac{d}{dc}\|v-cu\|^2 = \frac{d}{dc}\big[(v-cu)^T(v-cu)\big] = -2u^Tv + 2cu^Tu = 0$$

Solving gives $c = \frac{u^Tv}{u^Tu}$, which is exactly the scalar in the projection formula above.

### Projection onto a Subspace (General Case)

When projecting onto a subspace $S$ spanned by multiple vectors (columns of a matrix $A$), the formula generalizes to:

$$\text{proj}_S(v) = A(A^TA)^{-1}A^Tv$$

This is the same projection matrix structure used in linear regression (see prior topic), where $S$ is the column space of the design matrix. The matrix $P = A(A^TA)^{-1}A^T$ satisfies $P^2 = P$ (idempotent) and $P^T = P$ (symmetric) — these are standard, provable algebraic properties of orthogonal projection matrices.

### Decomposition Interpretation

Any vector $v$ can be split into two orthogonal components relative to a subspace $S$:

$$v = \underbrace{\text{proj}_S(v)}_{\text{component in } S} + \underbrace{(v - \text{proj}_S(v))}_{\text{component orthogonal to } S}$$

This decomposition is unique, and the two components satisfy $\text{proj}_S(v)^T(v - \text{proj}_S(v)) = 0$. This orthogonal-decomposition property is the mathematical foundation behind least-squares regression, Gram-Schmidt orthogonalization, and Fourier-type basis expansions.

### Worked Example

Let $v = \begin{bmatrix}3\\4\end{bmatrix}$ and project it onto $u = \begin{bmatrix}1\\0\end{bmatrix}$ (the x-axis direction).

$$\text{proj}_u(v) = \frac{u^Tv}{u^Tu}u = \frac{(1)(3)+(0)(4)}{1^2+0^2}\begin{bmatrix}1\\0\end{bmatrix} = 3\begin{bmatrix}1\\0\end{bmatrix} = \begin{bmatrix}3\\0\end{bmatrix}$$

This matches geometric intuition: projecting $(3,4)$ onto the x-axis simply drops the y-component, giving $(3,0)$.

**Verification of orthogonality of the residual:**

$$v - \text{proj}_u(v) = \begin{bmatrix}3\\4\end{bmatrix} - \begin{bmatrix}3\\0\end{bmatrix} = \begin{bmatrix}0\\4\end{bmatrix}$$



$$u^T(v-\text{proj}_u(v)) = (1)(0)+(0)(4) = 0 \quad \checkmark$$

The residual is indeed perpendicular to $u$, confirmed directly by this computation.

### Computational Check (Python / NumPy)

```python
import numpy as np

v = np.array([3, 4])
u = np.array([1, 0])

proj = (np.dot(u, v) / np.dot(u, u)) * u
residual = v - proj

print("Projection:", proj)
print("Residual:", residual)
print("Orthogonality check (should be ~0):", np.dot(u, residual))
```

[Unverified] The exact printed output may vary in formatting (e.g., integer vs. float display) depending on the NumPy version used to run this code; behavior is not guaranteed across all environments.

### Relevance to Machine Learning

- **Least squares regression**: the fitted values are the projection of the target vector onto the column space of the feature matrix (covered in the previous topic).
- **Principal Component Analysis (PCA)**: projects data onto lower-dimensional subspaces spanned by top eigenvectors of the covariance matrix, preserving maximal variance.
- **Gram-Schmidt process**: repeatedly projects vectors to construct an orthonormal basis, which underlies QR decomposition.
- **Attention mechanisms in neural networks**: [Inference] Some descriptions of attention frame query-key similarity computations as related to projection-like operations in a geometric sense, since dot products underlie both. This is a conceptual analogy drawn from the shared use of dot products, not a formal mathematical equivalence, and I cannot verify that this framing is used consistently across all technical sources.

### Key Points

- Projection finds the closest point in a subspace to a given vector, minimizing Euclidean distance — this is a provable geometric/algebraic fact.
- The residual (error) vector is always orthogonal to the subspace being projected onto; this orthogonality is what defines the minimum-distance solution.
- The projection formula $\frac{u^Tv}{u^Tu}u$ follows directly from calculus-based minimization, not from an assumption.
- Projection matrices are idempotent ($P^2=P$) and symmetric ($P^T=P$) — both are proven algebraic properties, not empirical observations.
- The connection to attention mechanisms is labeled [Inference] because it is a conceptual analogy rather than a confirmed formal equivalence; I do not have access to a specific verified source establishing that equivalence in this conversation.

### Related Topics

- Orthogonal Matrices and Their Properties (prior topic)
- Applications to Regression (prior topic)
- Gram-Schmidt Orthogonalization Process
- Projection Matrices: Idempotence and Symmetry Proofs
- Principal Component Analysis (PCA) via Eigendecomposition
- QR Decomposition
- Orthogonal Complement and Subspace Decomposition
- Least Squares Approximation in Function Spaces