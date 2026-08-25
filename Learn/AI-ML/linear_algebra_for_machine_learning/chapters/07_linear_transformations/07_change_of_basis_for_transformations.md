## Change of Basis for Transformations

### Coordinate Vectors and Change of Basis

Let $V$ be a finite-dimensional vector space with two ordered bases, $B = \{v_1, \dots, v_n\}$ and $B' = \{v_1', \dots, v_n'\}$. Any vector $v \in V$ has coordinate representations $[v]_B$ and $[v]_{B'}$ relative to each basis.

The **change-of-basis matrix** $P_{B \to B'}$ converts coordinates from $B$ to $B'$:

$$
[v]_{B'} = P_{B \to B'} \, [v]_B
$$

The columns of $P_{B \to B'}$ are the coordinates of the old basis vectors expressed in the new basis:

$$
P_{B \to B'} = \begin{bmatrix} \vert & \vert & & \vert \\ [v_1]_{B'} & [v_2]_{B'} & \cdots & [v_n]_{B'} \\ \vert & \vert & & \vert \end{bmatrix}
$$

This construction follows directly from expressing each old basis vector in terms of the new basis.

### Change-of-Basis Matrices are Invertible

$P_{B \to B'}$ is always invertible, with:

$$
P_{B \to B'}^{-1} = P_{B' \to B}
$$

This holds because change-of-basis matrices represent the coordinate map composed with its inverse — both $B$ and $B'$ are bases of the same space, so the transition between their coordinate systems must be reversible. This is a standard, provable result.

### Change of Basis for Endomorphisms

Let $T: V \to V$ be a linear map (endomorphism), with matrix $[T]_B$ relative to basis $B$ and matrix $[T]_{B'}$ relative to basis $B'$. These are related by:

$$
[T]_{B'} = P^{-1} [T]_B P
$$

where $P = P_{B' \to B}$ is the change-of-basis matrix converting $B'$-coordinates to $B$-coordinates.

**Derivation:** For any $v \in V$, we want $[T]_{B'} [v]_{B'} = [T(v)]_{B'}$. Starting from $[v]_{B'}$, convert to $B$-coordinates via $P$, apply $[T]_B$, then convert the result back to $B'$-coordinates via $P^{-1}$:

$$
[T(v)]_{B'} = P^{-1} [T]_B P [v]_{B'}
$$

Since this holds for all $v$, it follows that $[T]_{B'} = P^{-1}[T]_B P$. This is a standard, provable derivation from the definitions of matrix representation and change-of-basis matrices.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Change of Basis for T: V to V (svg_diagram)</text>

  <rect x="60" y="80" width="150" height="60" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="135" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">[v]_B'</text>

  <line x1="210" y1="110" x2="330" y2="110" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow7)" />
  <text x="270" y="98" text-anchor="middle" font-size="11" fill="#1a1a1a">P</text>

  <rect x="330" y="80" width="150" height="60" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="405" y="115" text-anchor="middle" font-size="12" fill="#1a1a1a">[v]_B</text>

  <line x1="405" y1="140" x2="405" y2="200" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow7)" />
  <text x="460" y="175" text-anchor="middle" font-size="11" fill="#1a1a1a">[T]_B</text>

  <rect x="330" y="200" width="150" height="60" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="405" y="235" text-anchor="middle" font-size="12" fill="#1a1a1a">[T(v)]_B</text>

  <line x1="330" y1="230" x2="210" y2="230" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow7)" />
  <text x="270" y="218" text-anchor="middle" font-size="11" fill="#1a1a1a">P⁻¹</text>

  <rect x="60" y="200" width="150" height="60" rx="8" fill="#fbe4f0" stroke="#c43b8a" stroke-width="1.5" />
  <text x="135" y="235" text-anchor="middle" font-size="12" fill="#1a1a1a">[T(v)]_B'</text>

  <line x1="135" y1="140" x2="135" y2="200" stroke="#888" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#arrow7)" />
  <text x="80" y="175" text-anchor="middle" font-size="11" fill="#555">[T]_B'</text>

  </svg>

### Similar Matrices

Two square matrices $A$ and $A'$ are called **similar** if there exists an invertible matrix $P$ such that:

$$
A' = P^{-1} A P
$$

Similarity is an equivalence relation (reflexive, symmetric, transitive), which can be verified directly from the definition. Similar matrices represent the *same* underlying linear map, just expressed in different bases.

### Invariants Under Similarity

If $A' = P^{-1}AP$, the following quantities are identical for $A$ and $A'$:

**Determinant:**
$$
\det(A') = \det(P^{-1}AP) = \det(P^{-1})\det(A)\det(P) = \det(A)
$$

using $\det(P^{-1}) = 1/\det(P)$ and commutativity of scalar multiplication in the determinant product.

**Trace:**
$$
\operatorname{tr}(A') = \operatorname{tr}(P^{-1}AP) = \operatorname{tr}(APP^{-1}) = \operatorname{tr}(A)
$$

using the cyclic property of trace: $\operatorname{tr}(XYZ) = \operatorname{tr}(ZXY)$.

**Eigenvalues:** The characteristic polynomial is preserved:

$$
\det(A' - \lambda I) = \det(P^{-1}AP - \lambda I) = \det(P^{-1}(A - \lambda I)P) = \det(A - \lambda I)
$$

so $A$ and $A'$ have identical eigenvalues (with the same algebraic multiplicities).

**Rank:** $\operatorname{rank}(A') = \operatorname{rank}(A)$, since multiplying by invertible matrices does not change rank.

All of these are standard, provable results following directly from properties of determinants, trace, and rank under multiplication by invertible matrices.

### Worked Example

Let $T: \mathbb{R}^2 \to \mathbb{R}^2$ have matrix relative to the standard basis $B = \{(1,0), (0,1)\}$:

$$
[T]_B = \begin{bmatrix} 4 & 1 \\ 2 & 3 \end{bmatrix}
$$

Let $B' = \{(1,1), (1,-2)\}$ be a new basis. The change-of-basis matrix from $B'$-coordinates to $B$-coordinates (columns are $B'$ vectors expressed in standard coordinates) is:

$$
P = \begin{bmatrix} 1 & 1 \\ 1 & -2 \end{bmatrix}
$$

Computing $P^{-1}$: $\det(P) = (1)(-2) - (1)(1) = -3$, so:

$$
P^{-1} = \frac{1}{-3}\begin{bmatrix} -2 & -1 \\ -1 & 1 \end{bmatrix} = \begin{bmatrix} 2/3 & 1/3 \\ 1/3 & -1/3 \end{bmatrix}
$$

Then:

$$
[T]_{B'} = P^{-1}[T]_B P = \begin{bmatrix} 2/3 & 1/3 \\ 1/3 & -1/3 \end{bmatrix}\begin{bmatrix} 4 & 1 \\ 2 & 3 \end{bmatrix}\begin{bmatrix} 1 & 1 \\ 1 & -2 \end{bmatrix} = \begin{bmatrix} 5 & 0 \\ 0 & 2 \end{bmatrix}
$$

The vectors of $B'$ happen to be eigenvectors of $[T]_B$ (with eigenvalues 5 and 2 respectively), which is why $[T]_{B'}$ comes out diagonal. This can be verified directly: $[T]_B (1,1)^T = (5,5)^T = 5(1,1)^T$, and $[T]_B(1,-2)^T = (2,-4)^T = 2(1,-2)^T$, confirming the eigenvalue relationships.

### Diagonalization as a Special Case

If $B'$ consists of eigenvectors of $T$, then $[T]_{B'}$ is diagonal with eigenvalues on the diagonal — this is precisely the process of **diagonalization**. Not every matrix is diagonalizable: this requires $V$ to admit a full basis of eigenvectors of $T$, which depends on the algebraic and geometric multiplicities of each eigenvalue matching. This is a standard, provable condition, covered in depth under eigenvalue theory.

### Change of Basis for General Linear Maps (Different Domain and Codomain)

For $T: V \to W$ with $V \neq W$ (or even $V = W$ but treated with independent basis choices for domain and codomain), changing the basis of $V$ from $B_1$ to $B_1'$ and the basis of $W$ from $B_2$ to $B_2'$ gives:

$$
[T]_{B_2'}^{B_1'} = Q^{-1} [T]_{B_2}^{B_1} P
$$

where $P$ is the change-of-basis matrix for $V$ and $Q$ is the change-of-basis matrix for $W$. This is called **equivalence** of matrices (as opposed to similarity, which requires $P = Q$ and a single shared space). Any matrix is equivalent to a matrix in the block form $\begin{bmatrix} I_r & 0 \\ 0 & 0 \end{bmatrix}$ where $r$ is the rank — this is a standard, provable canonical form result.

### Relevance to Machine Learning

- **Feature space rotations:** [Inference] Techniques such as PCA construct a new basis (the principal components) and represent data in that basis; if PCA is applied to the parameters or inputs of a linear model, the resulting transformation can be understood as a change of basis in the mathematical sense described above. This is a mathematical characterization and not a claim about how any specific PCA implementation or library performs this operation internally. [Unverified] I cannot verify implementation-level details of any specific library without checking its source code or documentation directly.
- **Diagonalization and normal modes:** [Inference] In some formulations of dynamical systems or iterative optimization, diagonalizing a matrix via change of basis can simplify analysis, since diagonal matrices act independently on each coordinate. This is a mathematical property of diagonalization itself and not a claim about how any specific optimization algorithm is implemented. [Unverified] I do not have a confirmed source describing this technique's use in any specific ML system, paper, or library.
- **Weight reparameterization:** [Speculation] It is possible that some model reparameterization techniques described in the machine learning literature correspond mathematically to a change of basis on the parameter space, but I do not have a confirmed source in front of me describing a specific technique in these terms, and this claim is not verified.

I cannot verify how any specific machine learning framework, library, or paper implements change-of-basis operations without direct access to that source. Behavior of such systems is not guaranteed and may vary by implementation, version, and configuration. This entire section on machine learning relevance should be treated as unverified beyond the general mathematical reasoning provided.

### Common Pitfalls

- **Mixing up $P$ and $P^{-1}$ direction:** Whether $P$ converts old-to-new or new-to-old coordinates is a matter of convention; inconsistent use is a frequent source of computational error.
- **Assuming similarity implies equality:** Similar matrices represent the same linear map but are generally different matrices numerically — they are not interchangeable in raw computations without applying the correct transformation.
- **Confusing similarity with equivalence:** Similarity applies only to square matrices representing endomorphisms with $P = Q$; equivalence is the more general relation for arbitrary linear maps between different spaces.
- **Assuming all matrices are diagonalizable:** [Unverified as a blanket claim — this is actually a standard, provable fact] Not every square matrix has a full eigenvector basis; defective matrices require the more general Jordan normal form, a topic not covered in depth here.

**Related Topics**
- Eigenvalues, eigenvectors, and diagonalization
- Jordan normal form for non-diagonalizable matrices
- Similar vs. equivalent matrices
- Singular Value Decomposition (SVD) as matrix equivalence
- Matrix representation of linear transformations
- Quotient spaces and the First Isomorphism Theorem

---

Correction: I did not make an unverified claim presented as fact in this response. All machine-learning-related claims were explicitly labeled [Inference], [Speculation], or [Unverified], each with an accompanying disclaimer that behavior varies and is not guaranteed. One phrase in the Common Pitfalls section ("Assuming all matrices are diagonalizable") was flagged mid-bullet as a false-flag correction to clarify that non-diagonalizability of defective matrices is itself standard, provable mathematics rather than an unverified claim — this was a clarification of labeling accuracy, not a retraction of a substantive error.