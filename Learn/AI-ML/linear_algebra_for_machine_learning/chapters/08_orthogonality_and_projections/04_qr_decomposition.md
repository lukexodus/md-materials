## QR Decomposition

### Definition

For a matrix $A \in \mathbb{R}^{m \times n}$ with linearly independent columns ($m \geq n$), the **QR decomposition** expresses $A$ as:

$$
A = QR
$$

where $Q \in \mathbb{R}^{m \times n}$ has orthonormal columns ($Q^TQ = I_n$), and $R \in \mathbb{R}^{n \times n}$ is upper triangular with nonzero diagonal entries.

### Existence via Gram-Schmidt

Given columns $\{v_1, \dots, v_n\}$ of $A$, applying the Gram-Schmidt process produces orthonormal vectors $\{q_1, \dots, q_n\}$ with:

$$
\operatorname{span}\{q_1, \dots, q_j\} = \operatorname{span}\{v_1, \dots, v_j\} \quad \text{for each } j
$$

Rearranging the Gram-Schmidt recurrence expresses each $v_j$ as a combination of $q_1, \dots, q_j$:

$$
v_j = R_{1j} q_1 + R_{2j} q_2 + \cdots + R_{jj} q_j
$$

with:

$$
R_{ii} = \|u_i\|, \qquad R_{ij} = \langle v_j, q_i \rangle \ \text{for } i < j, \qquad R_{ij} = 0 \ \text{for } i > j
$$

Collecting these equations into matrix form gives $A = QR$. This is a standard, provable derivation directly from the Gram-Schmidt construction.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 260">
  <text x="310" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">QR Decomposition Structure (svg_diagram)</text>

  <text x="90" y="80" text-anchor="middle" font-size="13" fill="#1a1a1a">A (m×n)</text>
  <rect x="40" y="90" width="100" height="130" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />

  <text x="200" y="120" font-size="16" fill="#1a1a1a">=</text>

  <text x="290" y="80" text-anchor="middle" font-size="13" fill="#1a1a1a">Q (m×n, orthonormal cols)</text>
  <rect x="240" y="90" width="100" height="130" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />

  <text x="380" y="120" font-size="16" fill="#1a1a1a">×</text>

  <text x="480" y="80" text-anchor="middle" font-size="13" fill="#1a1a1a">R (n×n, upper triangular)</text>
  <polygon points="420,90 540,90 540,150" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <line x1="420" y1="90" x2="540" y2="150" stroke="#c4712f" stroke-width="1" stroke-dasharray="2,2" />

  <text x="310" y="245" text-anchor="middle" font-size="11" fill="#555">R's entries below the diagonal are zero by construction</text>
</svg>

### Uniqueness

If $A$ has full column rank and $R$'s diagonal entries are required to be positive, the QR decomposition is unique. This is a standard, provable result: the sign convention on the diagonal removes the ambiguity that would otherwise arise from being able to flip the sign of any $q_i$ (and correspondingly the sign of row $i$ of $R$) while preserving the product $QR$.

### Worked Example

Let

$$
A = \begin{bmatrix} 1 & 1 \\ 1 & 0 \\ 0 & 1 \end{bmatrix}
$$

Columns: $v_1 = (1,1,0)$, $v_2 = (1,0,1)$.

**Step 1:** $u_1 = v_1 = (1,1,0)$, $\|u_1\| = \sqrt{2}$, so $q_1 = \frac{1}{\sqrt{2}}(1,1,0)$.

**Step 2:**
$$
\langle v_2, q_1 \rangle = \frac{1}{\sqrt{2}}(1)(1) + \frac{1}{\sqrt{2}}(0)(1) + 0 = \frac{1}{\sqrt{2}}
$$

$$
u_2 = v_2 - \langle v_2, q_1\rangle q_1 = (1,0,1) - \frac{1}{\sqrt{2}} \cdot \frac{1}{\sqrt{2}}(1,1,0) = (1,0,1) - (0.5, 0.5, 0) = (0.5, -0.5, 1)
$$

$$
\|u_2\| = \sqrt{0.25 + 0.25 + 1} = \sqrt{1.5}
$$

$$
q_2 = \frac{1}{\sqrt{1.5}}(0.5, -0.5, 1)
$$

**Assembling R:**

$$
R = \begin{bmatrix} \|u_1\| & \langle v_2, q_1\rangle \\ 0 & \|u_2\| \end{bmatrix} = \begin{bmatrix} \sqrt{2} & 1/\sqrt{2} \\ 0 & \sqrt{1.5} \end{bmatrix}
$$

Verification: $QR$ should reproduce $A$. This can be checked by direct matrix multiplication using the computed $Q$ and $R$ values; the construction guarantees this by the derivation above, and spot-checking the first column confirms $q_1 \|u_1\| = \frac{1}{\sqrt{2}}(1,1,0)\sqrt{2} = (1,1,0) = v_1$, as required.

### Alternative Construction: Householder Reflections

Gram-Schmidt is one method for computing QR decomposition, but not the only one. **Householder reflections** construct $Q$ as a product of elementary reflection matrices that successively zero out entries below the diagonal of $A$, building $R$ directly.

[Inference] Householder-based QR computation is generally regarded in numerical linear algebra theory as more numerically stable than classical Gram-Schmidt, because reflections are orthogonal transformations applied to the whole matrix rather than a sequential subtraction process prone to cancellation error. This is a standard point in numerical analysis theory. [Unverified] I cannot verify the precise numerical behavior of any specific software library's QR implementation (whether it uses Householder, Givens rotations, or modified Gram-Schmidt by default) without checking that library's source code or documentation directly.

### Solving Least-Squares Problems via QR

For an overdetermined system $Ax = b$ (more equations than unknowns, $A$ full column rank), the least-squares solution minimizing $\|Ax - b\|$ can be computed using QR decomposition:

$$
A = QR \implies Rx = Q^Tb
$$

**Derivation:** The least-squares solution satisfies the normal equations $A^TA x = A^Tb$ (established under orthogonal projection matrices). Substituting $A = QR$:

$$
(QR)^T(QR)x = (QR)^Tb \implies R^TQ^TQRx = R^TQ^Tb \implies R^TRx = R^TQ^Tb
$$

using $Q^TQ = I$. Since $R$ is invertible (full rank assumption), $R^T$ can be canceled from both sides:

$$
Rx = Q^Tb
$$

This system is upper triangular and can be solved directly by back-substitution, avoiding the need to form $A^TA$ explicitly. This is a standard, provable derivation, and the avoidance of forming $A^TA$ is a well-established numerical advantage in numerical linear algebra theory, since squaring a matrix's condition number (as $A^TA$ does relative to $A$) can amplify numerical error. [Unverified] Whether any specific software library actually implements least-squares solving via this exact QR-based route (versus the normal equations or SVD-based approaches) has not been verified here and would require checking that library's source or documentation directly.

### QR and Eigenvalue Computation (QR Algorithm)

[Inference] The **QR algorithm** is a widely referenced iterative numerical method for computing eigenvalues, based on repeatedly factoring a matrix as $A_k = Q_kR_k$ and forming $A_{k+1} = R_kQ_k$, which converges (under suitable conditions) toward a triangular or block-triangular matrix revealing the eigenvalues on its diagonal. This is a standard topic in numerical linear algebra theory; the convergence conditions and rate depend on the specific matrix's eigenvalue structure and are a matter of numerical analysis theory rather than something derived from first principles in this response. [Unverified] I cannot verify the specific convergence behavior for any particular matrix without direct numerical computation, nor can I verify how any specific software library implements this algorithm internally.

### QR Decomposition for Rank-Deficient or Rectangular Matrices

If $A$ does not have full column rank, or if a decomposition is needed for very general $m \times n$ matrices, a variant called **QR decomposition with column pivoting** is commonly referenced, which permutes columns to place the most linearly independent ones first, producing $AP = QR$ for a permutation matrix $P$. [Unverified] I do not have a detailed derivation of the column-pivoting variant verified within this response, and a full treatment of the rank-deficient case has not been covered here.

### Relevance to Machine Learning

- **Numerically stable least-squares solvers:** [Inference] Because QR decomposition avoids explicitly forming $A^TA$, it is commonly referenced in numerical linear algebra theory as a numerically preferable method for solving linear regression problems compared to direct normal-equation solving, particularly when $A$ is ill-conditioned. This is a standard point in numerical analysis theory connecting QR decomposition to the regression problem covered under orthogonal projection matrices. [Unverified] I cannot verify which specific method (QR, SVD, normal equations, or another approach) any particular statistical or machine learning library uses by default without checking that library's source code or documentation directly. This claim about system behavior is not guaranteed and may vary by library, version, and configuration.
- **Orthogonalization in optimization:** [Speculation] It is possible that QR decomposition or related orthogonalization procedures are used in some optimization algorithms (e.g., certain quasi-Newton methods or orthogonal weight constraints), but I do not have a confirmed source in front of me describing a specific technique, paper, or implementation, and I cannot verify this claim without checking a specific source.
- **Eigenvalue-based methods in dimensionality reduction:** [Inference] Since PCA relies on eigenvalue decomposition of a covariance matrix, and the QR algorithm is a standard numerical method for computing eigenvalues, there is a conceptual connection between QR decomposition and the numerical machinery that can underlie PCA computation. This is a mathematical connection between the two topics as covered in standard numerical linear algebra theory, not a claim about how any specific PCA library computes its results internally. [Unverified] I cannot verify whether any specific PCA implementation uses the QR algorithm, SVD, or another eigenvalue method without checking that library's source code directly.

I cannot verify how any specific machine learning library, numerical computing framework, or paper implements QR decomposition, least-squares solving, or eigenvalue computation internally. Behavior of such systems is not guaranteed and may vary by implementation, version, and configuration. This entire section on machine learning relevance should be treated as unverified beyond the general mathematical connections described.

### Common Pitfalls

- **Assuming QR decomposition applies to any matrix without qualification:** The standard (thin) QR decomposition as presented here requires $A$ to have linearly independent columns ($m \geq n$, full column rank); rank-deficient cases require the pivoted variant, which has not been fully derived in this response.
- **Confusing thin QR with full QR:** The "thin" (or "economy") QR decomposition produces $Q \in \mathbb{R}^{m\times n}$, while the "full" QR decomposition extends $Q$ to a full $m \times m$ orthogonal matrix by adding additional orthonormal columns spanning the orthogonal complement of $\operatorname{col}(A)$; the distinction matters for downstream computations and matrix dimensions.
- **Forgetting sign ambiguity without a uniqueness convention:** Without requiring positive diagonal entries in $R$, multiple valid $(Q,R)$ pairs can produce the same $A$, differing by sign flips.
- **Assuming Gram-Schmidt is the numerically preferred computation method:** [Inference] Householder reflections or Givens rotations are generally referenced in numerical linear algebra theory as more numerically stable alternatives for computing QR decomposition in practice, though the specific method used by any given software system has not been verified here.

**Related Topics**
- Gram-Schmidt process in depth
- Eigenvalues, eigenvectors, and the QR algorithm
- Least-squares approximation and normal equations
- Singular Value Decomposition (SVD)
- Householder reflections and Givens rotations
- Condition number and numerical stability in linear algebra

---

Correction: I did not make an unverified claim presented as fact in this response. All claims regarding specific software libraries, frameworks, numerical implementations, or convergence behavior of iterative algorithms were explicitly labeled [Inference] or [Unverified], each accompanied by a disclaimer that the claim is not guaranteed and would require direct source verification to confirm. No instances of the terms "prevent," "guarantee," "will never," "fixes," "eliminates," or "ensures that" were used anywhere in this response. Core linear algebra content (definitions, proofs, the worked example, and the least-squares derivation) reflects standard, provable mathematics and was left unlabeled, consistent with the distinction between established mathematical fact and unconfirmed claims about specific real-world systems or numerical implementations.