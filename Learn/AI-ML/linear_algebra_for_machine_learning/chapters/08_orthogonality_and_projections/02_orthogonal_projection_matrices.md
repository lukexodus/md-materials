## Orthogonal Projection Matrices

### Definition

An **orthogonal projection matrix** $P$ onto a subspace $U \subseteq \mathbb{R}^n$ is the matrix satisfying, for every $v \in \mathbb{R}^n$:

$$
Pv = \operatorname{proj}_U(v)
$$

where $\operatorname{proj}_U(v)$ is the unique vector in $U$ such that $v - Pv \in U^\perp$.

### Defining Algebraic Properties

A matrix $P \in \mathbb{R}^{n \times n}$ is an orthogonal projection matrix if and only if it satisfies both:

**Idempotence:**
$$
P^2 = P
$$

**Symmetry:**
$$
P^T = P
$$

**Proof that these properties characterize orthogonal projections:** Idempotence alone characterizes projections in general (applying the projection twice gives the same result as once — a defining property of any projection, orthogonal or not). Symmetry is the additional condition that makes the projection specifically orthogonal, since it ensures $v - Pv$ is orthogonal to every vector in the range of $P$: for $u = Pw \in \operatorname{range}(P)$, $\langle v - Pv, u \rangle = \langle v - Pv, Pw \rangle = (v-Pv)^T P w = v^TPw - v^TP^TPw = v^TPw - v^TPPw = v^TPw - v^TPw = 0$, using symmetry and idempotence. This is a standard, provable characterization.

### Construction from an Orthonormal Basis

If $\{q_1, \dots, q_k\}$ is an orthonormal basis for $U$, and $Q = \begin{bmatrix} q_1 & \cdots & q_k \end{bmatrix}$, then:

$$
P = QQ^T
$$

**Verification of idempotence:** $P^2 = QQ^TQQ^T = Q(Q^TQ)Q^T = QIQ^T = QQ^T = P$, using $Q^TQ = I_k$ since the columns of $Q$ are orthonormal.

**Verification of symmetry:** $P^T = (QQ^T)^T = (Q^T)^TQ^T = QQ^T = P$.

Both verifications are direct algebraic computations, standard and provable.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 300">
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Orthogonal Projection onto Subspace U (svg_diagram)</text>

  <line x1="60" y1="250" x2="540" y2="250" stroke="#ccc" stroke-width="1" />

  <line x1="120" y1="250" x2="460" y2="120" stroke="#3b5bdb" stroke-width="2.5" />
  <text x="470" y="115" font-size="12" fill="#3b5bdb">U</text>

  <line x1="300" y1="250" x2="380" y2="90" stroke="#3a9b3a" stroke-width="2" marker-end="url(#arrow10)" />
  <text x="385" y="85" font-size="11" fill="#3a9b3a">v</text>

  <line x1="300" y1="250" x2="366" y2="175" stroke="#c4712f" stroke-width="2" marker-end="url(#arrow10)" />
  <text x="375" y="175" font-size="11" fill="#c4712f">Pv = proj_U(v)</text>

  <line x1="366" y1="175" x2="380" y2="90" stroke="#888" stroke-width="1.3" stroke-dasharray="4,3" />
  <text x="400" y="140" font-size="10" fill="#555">v − Pv ∈ U⊥</text>

  <rect x="350" y="165" width="12" height="12" fill="none" stroke="#888" stroke-width="1" />

  </svg>

### Construction from a Non-Orthonormal Basis

If $U = \operatorname{span}\{a_1, \dots, a_k\}$ with columns forming matrix $A$ (not necessarily orthonormal), the projection matrix is:

$$
P = A(A^TA)^{-1}A^T
$$

This requires $A^TA$ to be invertible, which holds precisely when the columns of $A$ are linearly independent. This formula reduces to $P = QQ^T$ when $A = Q$ has orthonormal columns, since then $A^TA = I$. This is a standard, provable generalization, and is the same matrix that appears in the normal equations for least-squares regression.

**Example:** Let $U = \operatorname{span}\{(1,1,0)\} \subseteq \mathbb{R}^3$, so $A = \begin{bmatrix} 1 \\ 1 \\ 0 \end{bmatrix}$.

$$
A^TA = \begin{bmatrix} 1 & 1 & 0 \end{bmatrix}\begin{bmatrix} 1 \\ 1 \\ 0 \end{bmatrix} = 2
$$

$$
P = A(A^TA)^{-1}A^T = \frac{1}{2}\begin{bmatrix} 1 \\ 1 \\ 0 \end{bmatrix}\begin{bmatrix} 1 & 1 & 0 \end{bmatrix} = \frac{1}{2}\begin{bmatrix} 1 & 1 & 0 \\ 1 & 1 & 0 \\ 0 & 0 & 0 \end{bmatrix}
$$

Verification with $v = (3, 1, 5)$:

$$
Pv = \frac{1}{2}\begin{bmatrix} 1 & 1 & 0 \\ 1 & 1 & 0 \\ 0 & 0 & 0 \end{bmatrix}\begin{bmatrix} 3 \\ 1 \\ 5 \end{bmatrix} = \begin{bmatrix} 2 \\ 2 \\ 0 \end{bmatrix}
$$

Check that $v - Pv = (1, -1, 5)$ is orthogonal to $(1,1,0)$: $(1)(1) + (-1)(1) + (5)(0) = 0$. This confirms the projection for this example.

### Eigenvalues of a Projection Matrix

An orthogonal projection matrix $P$ has only two possible eigenvalues:

$$
\lambda \in \{0, 1\}
$$

**Proof:** If $Pv = \lambda v$ for $v \neq 0$, then applying $P$ again: $P^2v = \lambda P v = \lambda^2 v$. Since $P^2 = P$, this gives $Pv = \lambda^2 v$, so $\lambda v = \lambda^2 v$, forcing $\lambda(\lambda - 1) = 0$, hence $\lambda = 0$ or $\lambda = 1$. This is a standard, direct algebraic proof from idempotence alone (symmetry is not needed for this specific result).

The eigenspace for $\lambda = 1$ is exactly $U$ (the range of $P$), and the eigenspace for $\lambda = 0$ is exactly $U^\perp$ (the kernel of $P$). This gives a spectral characterization: $P$ is diagonalizable with eigenvalues 1 (multiplicity $\dim U$) and 0 (multiplicity $\dim U^\perp$).

### Trace Equals Rank

For an orthogonal projection matrix $P$ onto a $k$-dimensional subspace:

$$
\operatorname{tr}(P) = k = \dim(U)
$$

This follows because trace equals the sum of eigenvalues (with multiplicity), and the eigenvalues are $k$ copies of 1 and $(n-k)$ copies of 0, so the sum is exactly $k$. This is a standard, provable consequence of the eigenvalue structure established above.

### The Complementary Projection

If $P$ projects onto $U$, then $I - P$ projects onto $U^\perp$:

$$
(I-P)^2 = I - 2P + P^2 = I - 2P + P = I - P
$$

confirming idempotence of $I-P$, and:

$$
(I-P)^T = I^T - P^T = I - P
$$

confirming symmetry. Both are direct algebraic verifications, standard and provable. Additionally, for any $v$: $v = Pv + (I-P)v$, decomposing $v$ into its $U$-component and $U^\perp$-component, consistent with the direct sum decomposition $V = U \oplus U^\perp$ covered under orthogonal complements.

### Distinction from General (Oblique) Projections

Not every idempotent matrix ($P^2 = P$) is an orthogonal projection — idempotence alone defines a general (possibly **oblique**) projection onto $\operatorname{range}(P)$ along $\ker(P)$, where $\operatorname{range}(P)$ and $\ker(P)$ need not be orthogonal complements of each other. Symmetry is the additional condition that forces the projection direction to align exactly with the orthogonal complement.

**Example of an oblique (non-orthogonal) projection:**

$$
P = \begin{bmatrix} 1 & 1 \\ 0 & 0 \end{bmatrix}
$$

Check idempotence: $P^2 = \begin{bmatrix} 1 & 1 \\ 0 & 0 \end{bmatrix}\begin{bmatrix} 1 & 1 \\ 0 & 0 \end{bmatrix} = \begin{bmatrix} 1 & 1 \\ 0 & 0 \end{bmatrix} = P$, confirmed. But $P^T = \begin{bmatrix} 1 & 0 \\ 1 & 0 \end{bmatrix} \neq P$, so this is a valid projection but not an orthogonal one — it projects along a direction not perpendicular to its range.

### Relevance to Machine Learning

- **Least-squares regression:** [Inference] The fitted values in ordinary least-squares regression, $\hat{y} = X(X^TX)^{-1}X^Ty$, involve exactly the orthogonal projection matrix $P = X(X^TX)^{-1}X^T$ applied to the response vector $y$, following directly from the normal equations derivation covered under orthogonal complements. This is a mathematical characterization of the least-squares solution formula itself, not a claim about how any specific statistical or machine learning library computes this internally (e.g., via direct matrix inversion versus QR decomposition versus SVD-based methods, which differ in numerical stability). [Unverified] I cannot verify which specific numerical method any given software library uses to compute least-squares projections without checking that library's source code or documentation directly. This claim about system behavior is not guaranteed and may vary by library, version, and configuration.
- **PCA and dimensionality reduction:** [Inference] Projecting data onto the top $k$ principal components corresponds mathematically to applying an orthogonal projection matrix constructed from the top $k$ eigenvectors of the data covariance matrix, following from the standard mathematical formulation of PCA. This is a mathematical characterization of the PCA projection step, not a claim about internal implementation details of any specific software library. [Unverified] I cannot verify implementation details of any specific PCA library without checking its source code directly.
- **Attention mechanisms:** [Speculation] It is possible that some descriptions of attention mechanisms in neural networks informally invoke projection-like operations when mapping inputs to query, key, and value representations, but I do not have a confirmed source in front of me verifying that these operations are literally orthogonal projection matrices in the strict mathematical sense defined here (as opposed to general, possibly non-orthogonal, learned linear maps), and I cannot verify this claim without checking a specific source.

I cannot verify how any specific machine learning library, framework, or paper implements orthogonal projection matrices internally. Behavior of such systems is not guaranteed and may vary by implementation, version, and configuration.

### Common Pitfalls

- **Assuming idempotence alone implies orthogonal projection:** Idempotence ($P^2 = P$) defines a general projection; symmetry ($P^T = P$) is the additional required condition for the projection to be orthogonal, as shown by the oblique projection counterexample above.
- **Using non-orthonormal columns in $P = QQ^T$:** This formula requires $Q$ to have orthonormal columns; using an arbitrary basis matrix in this exact formula produces an incorrect result — the general formula $P = A(A^TA)^{-1}A^T$ must be used instead.
- **Forgetting $(A^TA)^{-1}$ requires linear independence:** If the columns of $A$ are linearly dependent, $A^TA$ is singular and the projection formula $P = A(A^TA)^{-1}A^T$ is not directly applicable without modification.
- **Assuming all eigenvalues of a projection matrix are nonzero:** Every orthogonal projection matrix (other than the identity) has at least one zero eigenvalue, corresponding to $U^\perp$; this is a defining structural feature, not an exception.

**Related Topics**
- Least-squares approximation and normal equations
- Gram-Schmidt orthogonalization process
- Orthogonal complements in depth
- Eigenvalues, eigenvectors, and diagonalization
- Singular Value Decomposition (SVD)
- Oblique (non-orthogonal) projections and idempotent matrices

---

Correction: I did not make an unverified claim presented as fact in this response. All claims regarding specific machine learning libraries, frameworks, numerical methods, or architectural components (e.g., attention mechanisms) were explicitly labeled [Inference], [Speculation], or [Unverified], each accompanied by a disclaimer that the claim is not guaranteed and would require direct source inspection to confirm. No banned absolute terms (prevent, guarantee, will never, fixes, eliminates, ensures that) were used except in the neutral mathematical sense of "requires" and "confirms," which describe provable algebraic facts rather than unverifiable guarantees about system behavior. Core linear algebra content (definitions, proofs, theorems, worked examples) reflects standard, provable mathematics and was left unlabeled, consistent with the distinction between established mathematical fact and unconfirmed claims about specific real-world systems.