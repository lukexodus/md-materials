## Orthogonal Matrices and Their Properties

### Definition

A square matrix $Q \in \mathbb{R}^{n \times n}$ is **orthogonal** if its columns (and rows) form an orthonormal set — each column has unit length and is perpendicular to every other column. Formally:

$$Q^T Q = Q Q^T = I$$

This is equivalent to saying $Q^{-1} = Q^T$, which is a defining computational shortcut: inverting an orthogonal matrix costs nothing beyond a transpose.

### Core Algebraic Properties

- **Inverse equals transpose**: $Q^{-1} = Q^T$. This holds exactly for orthogonal matrices by definition, not as an approximation.
- **Determinant is ±1**: Since $\det(Q^T Q) = \det(I) = 1$ and $\det(Q^T) = \det(Q)$, it follows that $\det(Q)^2 = 1$, so $\det(Q) = \pm 1$.
  - $\det(Q) = +1$ corresponds to a **rotation**.
  - $\det(Q) = -1$ corresponds to a **reflection** (or rotation combined with reflection).
- **Preserves inner products**: $(Qx)^T(Qy) = x^T Q^T Q y = x^T y$. Dot products between vectors are unchanged after transformation.
- **Preserves norms (lengths)**: Since $\|Qx\|^2 = (Qx)^T(Qx) = x^Tx = \|x\|^2$, applying $Q$ never stretches or shrinks a vector.
- **Preserves angles**: Because both norms and inner products are preserved, the angle $\cos\theta = \frac{x^Ty}{\|x\|\|y\|}$ between any two vectors is unchanged.
- **Eigenvalues have magnitude 1**: Every eigenvalue $\lambda$ of an orthogonal matrix satisfies $|\lambda| = 1$. Eigenvalues may be complex (occurring in conjugate pairs) for rotation components.
- **Product of orthogonal matrices is orthogonal**: If $Q_1, Q_2$ are orthogonal, then $Q_1 Q_2$ is also orthogonal. The set of orthogonal matrices forms a group under multiplication (the orthogonal group $O(n)$).
- **Condition number is 1**: Orthogonal matrices are perfectly conditioned with respect to the 2-norm, meaning they introduce no numerical amplification of error — a property that makes them numerically favorable, though this does not by itself remove all sources of numerical error in a computation involving other ill-conditioned factors.

### Geometric Interpretation

Multiplying a vector by an orthogonal matrix is a **rigid transformation** — it rotates and/or reflects vectors without distorting shape, length, or angle. This is why orthogonal matrices are the natural mathematical model for rotations in computer graphics, robotics, and physics simulations.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 320">
<text x="200" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Orthogonal Transformation Preserves Length and Angle (svg_diagram)</text>
<line x1="60" y1="160" x2="340" y2="160" stroke="#999" stroke-width="1" />
<line x1="200" y1="40" x2="200" y2="280" stroke="#999" stroke-width="1" />
<line x1="200" y1="160" x2="280" y2="110" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrow1)" />
<text x="288" y="105" font-size="12" fill="#2563eb">x</text>
<line x1="200" y1="160" x2="150" y2="90" stroke="#dc2626" stroke-width="2.5" marker-end="url(#arrow2)" />
<text x="120" y="85" font-size="12" fill="#dc2626">Qx</text>
<path d="M 220 145 A 20 20 0 0 1 210 122" stroke="#555" stroke-width="1.2" fill="none" />
<text x="228" y="132" font-size="11" fill="#555">θ</text>
<line x1="200" y1="160" x2="80" y2="200" stroke="#16a34a" stroke-width="2.5" marker-end="url(#arrow3)" />
<text x="55" y="215" font-size="12" fill="#16a34a">y</text>
<line x1="200" y1="160" x2="240" y2="250" stroke="#ea580c" stroke-width="2.5" marker-end="url(#arrow4)" />
<text x="245" y="265" font-size="12" fill="#ea580c">Qy</text>

<text x="200" y="305" font-size="11" text-anchor="middle" fill="#444">‖x‖ = ‖Qx‖, ‖y‖ = ‖Qy‖, angle θ unchanged</text>

</svg>

### Relationship to Orthonormal Bases

The columns of an orthogonal matrix $Q = [q_1, q_2, \ldots, q_n]$ form an **orthonormal basis** of $\mathbb{R}^n$:

$$q_i^T q_j = \begin{cases} 1 & i = j \\ 0 & i \neq j \end{cases}$$

This means any orthogonal matrix can be interpreted as a change of basis between two orthonormal coordinate systems.

### Why Orthogonal Matrices Matter in Machine Learning

- **Numerical stability**: Because $\|Qx\| = \|x\|$, orthogonal transformations do not amplify numerical error during matrix operations. This makes them a preferred computational tool in algorithms such as QR decomposition and Householder reflections used for solving least-squares problems.
- **QR Decomposition**: Any matrix $A$ can be factored as $A = QR$, where $Q$ is orthogonal and $R$ is upper triangular. This is widely used to solve linear regression via least squares more stably than the normal-equations approach.
- **Singular Value Decomposition (SVD)**: $A = U\Sigma V^T$, where $U$ and $V$ are orthogonal matrices. SVD underlies PCA, dimensionality reduction, pseudo-inverse computation, and recommender systems.
- **Weight initialization in neural networks**: Orthogonal initialization is used in some architectures — particularly RNNs — to help maintain gradient magnitude during backpropagation across many layers/time steps. [Inference] This is proposed as one contributing factor toward mitigating vanishing/exploding gradients, but overall training stability depends on many other factors (activation functions, learning rate, architecture depth), so orthogonal initialization does not ensure that gradient issues are eliminated, and behavior may vary across specific architectures and datasets.
- **Rotation-invariant feature transformations**: In signal processing and some ML preprocessing pipelines, orthogonal transforms (e.g., DCT, wavelet-related transforms) preserve energy/norm, which can aid feature extraction.

### Orthogonal vs. Orthonormal — Clarifying Terminology

| Term | Meaning |
| --- | --- |
| Orthogonal vectors | Vectors with zero dot product (perpendicular), no length requirement |
| Orthonormal vectors | Orthogonal **and** each has unit length |
| Orthogonal matrix | Square matrix whose columns are orthonormal (not merely orthogonal) |

This naming is a common source of confusion: an "orthogonal matrix" technically requires *orthonormal* columns, not merely orthogonal ones.

### Worked Example

Consider the 2D rotation matrix by angle $\theta$:

$$Q = \begin{bmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{bmatrix}$$

**Verification that $Q$ is orthogonal:**

$$Q^T Q = \begin{bmatrix} \cos\theta & \sin\theta \\ -\sin\theta & \cos\theta \end{bmatrix} \begin{bmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{bmatrix} = \begin{bmatrix} \cos^2\theta + \sin^2\theta & 0 \\ 0 & \sin^2\theta + \cos^2\theta \end{bmatrix} = I$$

This confirms $Q^TQ = I$ using the Pythagorean identity $\cos^2\theta + \sin^2\theta = 1$. The determinant is $\cos^2\theta + \sin^2\theta = 1$, confirming this is a pure rotation (no reflection).

### Computational Check (Python / NumPy)

```python
import numpy as np

theta = np.pi / 4
Q = np.array([
    [np.cos(theta), -np.sin(theta)],
    [np.sin(theta),  np.cos(theta)]
])

print(np.allclose(Q.T @ Q, np.eye(2)))   # True -> confirms orthogonality
print(np.linalg.det(Q))                   # ~1.0 -> confirms rotation, not reflection
print(np.linalg.norm(Q @ np.array([3,4]))) # 5.0 -> length preserved
```

[Unverified] The exact numerical output may vary slightly (e.g., 0.9999999999... instead of exactly 1.0) due to floating-point precision, depending on the NumPy version and hardware used.

### Key Points

- $Q^TQ = QQ^T = I$ is the defining property; everything else follows from it.
- Orthogonal matrices preserve length, angle, and inner products exactly, by mathematical definition.
- $\det(Q) = \pm 1$ distinguishes rotations ($+1$) from reflections ($-1$).
- They are central to numerically stable algorithms: QR decomposition, SVD, Householder/Givens transformations.
- "Orthogonal matrix" implies orthonormal columns, not just orthogonal ones — a frequent terminology trap.

### Related Topics

- QR Decomposition and Gram-Schmidt Orthogonalization
- Singular Value Decomposition (SVD) and its use in PCA
- Householder Reflections and Givens Rotations
- Eigenvalues and Eigenvectors of Symmetric Matrices
- Change of Basis and Coordinate Transformations
- Orthogonal Projections onto Subspaces
- The Orthogonal Group $O(n)$ and Special Orthogonal Group $SO(n)$
- Numerical Stability and Conditioning in Linear Algebra Algorithms