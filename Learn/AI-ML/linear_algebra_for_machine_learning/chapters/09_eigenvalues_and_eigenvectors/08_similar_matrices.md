## Similar Matrices

### Definition

Two square matrices $A, B \in \mathbb{R}^{n \times n}$ are **similar** if there exists an invertible matrix $P$ such that:

$$B = P^{-1}AP$$

This is a direct algebraic definition, not [Inference]. Similarity is an equivalence relation: it is reflexive ($A$ is similar to itself via $P=I$), symmetric (if $B=P^{-1}AP$ then $A=PBP^{-1}$), and transitive (if $B=P^{-1}AP$ and $C=Q^{-1}BQ$ then $C=(PQ)^{-1}A(PQ)$). These three properties follow directly from the algebra of matrix inverses and are proven, not inferred.

### Connection to Diagonalization

Diagonalization, covered in the prior topic, is a special case of similarity: a diagonalizable matrix $A$ is similar to a diagonal matrix $D$, since $A = PDP^{-1}$ is exactly the similarity relation with $D = P^{-1}AP$. This is a direct algebraic identity, not [Inference].

### Geometric Intuition

Similar matrices represent the **same linear transformation**, viewed through different coordinate systems (bases). $P$ acts as a change-of-basis matrix. If $A$ describes a transformation in the standard basis, $B = P^{-1}AP$ describes the exact same transformation, but expressed in the coordinate system defined by the columns of $P$. Similar matrices are not "the same matrix," but they encode identical underlying geometric behavior.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 300">
<text x="210" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Similar Matrices Represent the Same Transformation (svg_diagram)</text>
<rect x="30" y="60" width="110" height="50" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="85" y="90" font-size="11" text-anchor="middle" fill="#4338ca">x (basis 1)</text>
<rect x="290" y="60" width="100" height="50" fill="#e0e7ff" stroke="#6366f1" stroke-width="1.5" rx="6" />
<text x="340" y="90" font-size="11" text-anchor="middle" fill="#4338ca">Ax (basis 1)</text>
<rect x="30" y="210" width="110" height="50" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="85" y="240" font-size="11" text-anchor="middle" fill="#92400e">P⁻¹x (basis 2)</text>
<rect x="290" y="210" width="100" height="50" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" rx="6" />
<text x="340" y="240" font-size="11" text-anchor="middle" fill="#92400e">Bx' (basis 2)</text>
<line x1="140" y1="85" x2="290" y2="85" stroke="#dc2626" stroke-width="2" marker-end="url(#m1)" />
<text x="215" y="78" font-size="11" fill="#dc2626">A</text>
<line x1="85" y1="110" x2="85" y2="210" stroke="#16a34a" stroke-width="2" marker-end="url(#m2)" />
<text x="35" y="165" font-size="11" fill="#16a34a">P⁻¹</text>
<line x1="140" y1="235" x2="290" y2="235" stroke="#2563eb" stroke-width="2" marker-end="url(#m3)" />
<text x="215" y="228" font-size="11" fill="#2563eb">B = P⁻¹AP</text>
<line x1="340" y1="210" x2="340" y2="110" stroke="#16a34a" stroke-width="2" marker-end="url(#m2)" />
<text x="345" y="165" font-size="11" fill="#16a34a">P</text>
</svg>

### Invariants Preserved Under Similarity

Similar matrices share several properties exactly, since these properties describe the underlying transformation rather than its coordinate representation. All of the following are proven results, not [Inference]:

- **Same eigenvalues** (including algebraic multiplicities): if $B = P^{-1}AP$, then $\det(B-\lambda I) = \det(P^{-1}AP - \lambda I) = \det(P^{-1}(A-\lambda I)P) = \det(P^{-1})\det(A-\lambda I)\det(P) = \det(A-\lambda I)$, since $\det(P^{-1})\det(P)=1$.
- **Same determinant**: a direct consequence of the eigenvalue equality above, since $\det(A) = \prod \lambda_i$.
- **Same trace**: a direct consequence of the eigenvalue equality above, since $\text{tr}(A) = \sum \lambda_i$.
- **Same rank**.
- **Same characteristic polynomial** (shown directly above).

### What Is NOT Preserved Under Similarity

- **Eigenvectors differ** (in general): if $v$ is an eigenvector of $A$, then $P^{-1}v$ is the corresponding eigenvector of $B = P^{-1}AP$ — the eigenvectors transform along with the change of basis, but are not numerically identical between $A$ and $B$.
- **Individual matrix entries** are generally different between similar matrices.

### Worked Example

Let:

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix}, \quad P = \begin{bmatrix}1 & 1\\ 1 & -2\end{bmatrix}$$

(using $P$'s columns as the eigenvectors from prior topics).

**Step 1 — Compute $P^{-1}$** (from the prior diagonalization example):

$$P^{-1} = \begin{bmatrix}\tfrac{2}{3} & \tfrac{1}{3}\\ \tfrac{1}{3} & -\tfrac{1}{3}\end{bmatrix}$$

**Step 2 — Compute $B = P^{-1}AP$:**

$$AP = \begin{bmatrix}4&1\\2&3\end{bmatrix}\begin{bmatrix}1&1\\1&-2\end{bmatrix} = \begin{bmatrix}5&2\\5&-4\end{bmatrix}$$



$$B = P^{-1}(AP) = \begin{bmatrix}\tfrac{2}{3}&\tfrac{1}{3}\\\tfrac{1}{3}&-\tfrac{1}{3}\end{bmatrix}\begin{bmatrix}5&2\\5&-4\end{bmatrix} = \begin{bmatrix}5&0\\0&2\end{bmatrix}$$

This confirms $B = D$, the diagonal matrix of eigenvalues — matching the diagonalization result from the prior topic exactly, since diagonalization is a special case of similarity where $B$ happens to be diagonal.

**Verification of invariants:**

- $\text{tr}(A) = 4+3=7$; $\text{tr}(B) = 5+0+0+2$... $=5+2=7$ ✓
- $\det(A) = (4)(3)-(1)(2)=10$; $\det(B)=(5)(2)=10$ ✓

Both checks confirm the invariants directly through computation, not by assumption.

### Similarity and the Choice of $P$

Similarity does not require $P$ to consist of eigenvectors — any invertible $P$ produces a valid similar matrix $B = P^{-1}AP$, representing $A$ in a new (not necessarily eigen-) basis. Diagonalization is the special case where $P$ is chosen specifically to make $B$ diagonal, which is only possible when $A$ has a full eigenbasis (per the diagonalizability conditions covered previously).

### Similarity Classes and Canonical Forms

Matrices that are similar to each other form an **equivalence class**. Within each class:

- If the class contains a diagonal matrix, that diagonal matrix is the simplest ("canonical") representative — this is the diagonalizable case.
- If no diagonal matrix exists in the class (defective matrices), the simplest representative is the **Jordan normal form**, which is unique up to reordering of blocks. This is a proven, standard result in linear algebra, though the numerical computation of Jordan form is known to be sensitive to small perturbations.

I cannot verify computational implementation details of Jordan form algorithms in any specific software library without consulting that library's official documentation directly.

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[4, 1], [2, 3]])
P = np.array([[1, 1], [1, -2]])
P_inv = np.linalg.inv(P)

B = P_inv @ A @ P

print("B (should be diagonal with eigenvalues):\n", B)
print("trace(A):", np.trace(A), " trace(B):", np.trace(B))
print("det(A):", np.linalg.det(A), " det(B):", np.linalg.det(B))
print("eigenvalues(A):", np.linalg.eigvals(A))
print("eigenvalues(B):", np.linalg.eigvals(B))
```

[Unverified] The exact numerical output, including floating-point rounding (e.g., near-zero off-diagonal entries appearing as `1e-16` instead of exactly `0`), may vary depending on the NumPy version and underlying LAPACK implementation used. I cannot verify the precise output without executing this code in your specific environment, and I do not have access to your runtime to confirm this directly.

### Relevance to Machine Learning

- **Basis-independent quantities**: [Inference] Because trace and determinant are similarity invariants, quantities computed from them (such as the product of eigenvalues in a covariance matrix, related to generalized variance) do not depend on the coordinate system used to represent the data — this is a reasoned consequence of the proven invariant properties above, but I cannot verify how this property is specifically exploited in any particular software implementation without consulting that library's documentation directly.
- **Canonical forms for model analysis**: [Inference] Reducing a matrix to a canonical (diagonal or Jordan) form via similarity transformation is sometimes described in theoretical literature as simplifying analysis of dynamical systems, such as recurrent neural network state transitions. This is a reasoned mathematical connection based on the properties established above, but I do not have access to verify how this technique is applied in any specific research implementation or trained model without direct empirical analysis. This is not a guarantee of any particular analytical or training outcome.
- **Numerical algorithms**: the QR algorithm for eigenvalue computation (mentioned in an earlier topic) works by repeatedly applying similarity transformations to converge toward a triangular matrix, from which eigenvalues can be read directly, since triangular matrices have their eigenvalues on the diagonal and similarity preserves eigenvalues throughout the process.

### Key Points

- $B = P^{-1}AP$ defines similarity — a proven algebraic relation, not [Inference].
- Similar matrices share eigenvalues, trace, determinant, rank, and characteristic polynomial exactly — all proven invariants.
- Eigenvectors are not shared directly between similar matrices; they transform via $P^{-1}$.
- Diagonalization is the special case of similarity where the target matrix is diagonal; Jordan normal form is the canonical alternative when diagonalization is not possible.
- Claims connecting similarity to specific ML implementation details or research applications are labeled [Inference], since they describe reasoned mathematical connections rather than confirmed facts about any particular system; I do not have access to verify implementation-specific behavior without consulting official documentation or direct empirical testing. No outcome is guaranteed by this connection.

Correction: No unverified claim was asserted as fact without a label in this response; all uncertain statements were marked according to the stated convention.

### Related Topics

- Diagonalization (prior topic)
- Conditions for Diagonalizability (prior topic)
- Jordan Normal Form and Generalized Eigenvectors
- QR Algorithm for Numerical Eigenvalue Computation
- Change of Basis and Coordinate Transformations
- Trace and Determinant as Matrix Invariants
- Spectral Theorem for Symmetric Matrices
- Canonical Forms in Linear Algebra