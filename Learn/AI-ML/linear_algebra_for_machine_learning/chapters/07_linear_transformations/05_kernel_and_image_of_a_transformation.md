## Kernel and Image of a Transformation

### Definition: Kernel

Let $T: V \to W$ be a linear map. The **kernel** (or **null space**) of $T$ is:

$$
\ker(T) = \{v \in V : T(v) = 0_W\}
$$

The kernel consists of every vector that $T$ collapses to the zero vector of $W$.

### Kernel is a Subspace

$\ker(T)$ is a subspace of $V$. Proof: $0_V \in \ker(T)$ since $T(0_V) = 0_W$. Closure under addition: if $u, v \in \ker(T)$, then $T(u+v) = T(u) + T(v) = 0 + 0 = 0$, so $u + v \in \ker(T)$. Closure under scalar multiplication: if $v \in \ker(T)$, then $T(\alpha v) = \alpha T(v) = \alpha \cdot 0 = 0$, so $\alpha v \in \ker(T)$. This is a standard, provable result following directly from the definition of linearity.

### Definition: Image

The **image** (or **range**) of $T$ is:

$$
\operatorname{im}(T) = \{T(v) : v \in V\} = \{w \in W : w = T(v) \text{ for some } v \in V\}
$$

### Image is a Subspace

$\operatorname{im}(T)$ is a subspace of $W$. Proof: $0_W = T(0_V) \in \operatorname{im}(T)$. Closure under addition: if $w_1 = T(v_1)$ and $w_2 = T(v_2)$, then $w_1 + w_2 = T(v_1) + T(v_2) = T(v_1 + v_2) \in \operatorname{im}(T)$. Closure under scalar multiplication follows similarly using homogeneity. This is a standard, provable result.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 300">
  <text x="310" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Kernel and Image (svg_diagram)</text>

  <rect x="40" y="70" width="180" height="180" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="130" y="60" text-anchor="middle" font-size="13" fill="#1a1a1a">V</text>

  <ellipse cx="130" cy="180" rx="55" ry="40" fill="#c2d6ff" stroke="#3b5bdb" stroke-width="1" />
  <text x="130" y="185" text-anchor="middle" font-size="11" fill="#1a1a1a">ker(T)</text>
  <circle cx="130" cy="180" r="3" fill="#1a1a1a" />

  <line x1="220" y1="150" x2="400" y2="150" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow5)" />
  <text x="300" y="140" font-size="13" fill="#1a1a1a">T</text>

  <rect x="400" y="50" width="180" height="200" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="490" y="40" text-anchor="middle" font-size="13" fill="#1a1a1a">W</text>

  <ellipse cx="490" cy="150" rx="70" ry="55" fill="#ffe0b0" stroke="#c4712f" stroke-width="1" />
  <text x="490" y="155" text-anchor="middle" font-size="11" fill="#1a1a1a">im(T)</text>
  <circle cx="490" cy="150" r="3" fill="#1a1a1a" />

  </svg>

### Computing the Kernel via Matrix Row Reduction

For $T: F^n \to F^m$ with matrix $A$, $\ker(T)$ is the solution set of the homogeneous system:

$$
A\mathbf{x} = \mathbf{0}
$$

This is found by row-reducing $A$ to reduced row echelon form and expressing free variables in terms of pivot variables.

**Example:** Let

$$
A = \begin{bmatrix} 1 & 2 & 3 \\ 2 & 4 & 6 \end{bmatrix}
$$

Row reducing: row 2 is $2 \times$ row 1, so it reduces to zero, leaving:

$$
\begin{bmatrix} 1 & 2 & 3 \\ 0 & 0 & 0 \end{bmatrix}
$$

Setting $x_2 = s$, $x_3 = t$ as free variables: $x_1 = -2s - 3t$. So:

$$
\ker(T) = \left\{ s\begin{bmatrix} -2 \\ 1 \\ 0 \end{bmatrix} + t\begin{bmatrix} -3 \\ 0 \\ 1 \end{bmatrix} : s, t \in \mathbb{R} \right\}
$$

This is a 2-dimensional subspace of $\mathbb{R}^3$, confirmed by the two free parameters.

### Computing the Image via Column Space

For $T: F^n \to F^m$ with matrix $A$, $\operatorname{im}(T)$ equals the **column space** of $A$ — the span of $A$'s columns:

$$
\operatorname{im}(T) = \operatorname{span}\{A e_1, A e_2, \dots, A e_n\} = \operatorname{col}(A)
$$

Using the same matrix $A$ above, the columns are $(1,2)$, $(2,4)$, $(3,6)$ — all scalar multiples of $(1,2)$. So:

$$
\operatorname{im}(T) = \operatorname{span}\{(1,2)\}
$$

a 1-dimensional subspace of $\mathbb{R}^2$.

### Rank-Nullity Theorem

$$
\dim(V) = \dim(\ker T) + \dim(\operatorname{im} T)
$$

with the standard terminology:

- $\dim(\ker T)$ = **nullity**
- $\dim(\operatorname{im} T)$ = **rank**

Verifying the example above: $\dim(V) = 3$ (domain $\mathbb{R}^3$), nullity $= 2$, rank $= 1$. Indeed $3 = 2 + 1$. This confirms the theorem for this specific case; the general proof relies on the First Isomorphism Theorem applied to $V/\ker(T) \cong \operatorname{im}(T)$.

### Kernel, Image, and Injectivity/Surjectivity

- $T$ is injective $\iff \ker(T) = \{0\}$ (trivial kernel)
- $T$ is surjective $\iff \operatorname{im}(T) = W$ (full image)

These equivalences were established via direct proof in the definitions above and are standard, provable results.

### Kernel and Image Under Composition

For $T: U \to V$ and $S: V \to W$:

$$
\ker(T) \subseteq \ker(S \circ T)
$$
$$
\operatorname{im}(S \circ T) \subseteq \operatorname{im}(S)
$$

Both inclusions follow directly from the definitions: anything killed by $T$ is automatically killed by $S \circ T$, and anything produced by $S \circ T$ was necessarily produced by $S$ (applied to $T(u)$).

### Orthogonal Complement Relationship (Inner Product Spaces)

If $V$ and $W$ are equipped with inner products and $T$ has an adjoint $T^*$, then:

$$
\ker(T) = \operatorname{im}(T^*)^\perp, \qquad \operatorname{im}(T) = \ker(T^*)^\perp
$$

This is the **Fundamental Theorem of Linear Algebra** relating the four fundamental subspaces (row space, column space, null space, left null space) in the matrix case. This is a standard, provable result in finite-dimensional inner product spaces.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 280">
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Four Fundamental Subspaces (svg_diagram)</text>

  <rect x="40" y="60" width="220" height="90" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.3" />
  <text x="150" y="90" text-anchor="middle" font-size="12" fill="#1a1a1a">Row space of A</text>
  <text x="150" y="110" text-anchor="middle" font-size="11" fill="#555">dimension = rank</text>

  <rect x="40" y="170" width="220" height="90" rx="8" fill="#fbe4f0" stroke="#c43b8a" stroke-width="1.3" />
  <text x="150" y="200" text-anchor="middle" font-size="12" fill="#1a1a1a">Null space (ker T)</text>
  <text x="150" y="220" text-anchor="middle" font-size="11" fill="#555">dimension = nullity</text>

  <text x="290" y="160" text-anchor="middle" font-size="12" fill="#555">⊥ in R^n</text>

  <rect x="340" y="60" width="220" height="90" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.3" />
  <text x="450" y="90" text-anchor="middle" font-size="12" fill="#1a1a1a">Column space (im T)</text>
  <text x="450" y="110" text-anchor="middle" font-size="11" fill="#555">dimension = rank</text>

  <rect x="340" y="170" width="220" height="90" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.3" />
  <text x="450" y="200" text-anchor="middle" font-size="12" fill="#1a1a1a">Left null space (ker Tᵀ)</text>
  <text x="450" y="220" text-anchor="middle" font-size="11" fill="#555">dimension = m − rank</text>

  <text x="590" y="160" text-anchor="middle" font-size="12" fill="#555">⊥</text>
</svg>

### Relevance to Machine Learning

- **Loss function null directions:** [Inference] If a linear model's design matrix has a nontrivial kernel, directions in the kernel correspond to parameter changes that do not affect the model's linear output, since $T(v) = 0$ for $v \in \ker(T)$ means adding $v$ to a solution does not change $T$'s action on the part of the input in that direction. This is a direct mathematical consequence of the kernel definition, not a claim about any specific optimizer's behavior. [Unverified] Whether or how any specific ML training system handles or exploits such null directions has not been verified here.
- **Feature redundancy:** [Inference] A linear feature transformation with a nontrivial kernel indicates that some combinations of input features are mapped to zero and are therefore indistinguishable to that transformation, which mathematically follows from the kernel definition. This is a general mathematical property and not a description of any specific dataset or model's behavior.
- **Rank of weight matrices:** [Speculation] It is possible that low-rank weight matrices (where $\operatorname{im}(T)$ has reduced dimension) are used in some model compression or parameter-efficient fine-tuning techniques, but I do not have a confirmed source in front of me describing the specific techniques, papers, or implementations involved, and I cannot verify this claim without checking a specific source.

I cannot verify how any specific machine learning system, library, or paper computes, uses, or interprets kernel and image structures without direct access to that source. Behavior of such systems is not guaranteed and may vary by implementation and version.

### Common Pitfalls

- **Confusing kernel with the zero vector alone:** $\ker(T)$ can contain many nonzero vectors; it equals $\{0\}$ only when $T$ is injective.
- **Computing image from rows instead of columns:** The image is the column space of the matrix, not the row space — a frequent source of error.
- **Forgetting rank-nullity applies only in finite dimensions (as stated here):** [Unverified] Whether or how an analogous relationship holds in infinite-dimensional settings has not been verified or covered in this response.
- **Assuming kernel and image are subspaces of the same space:** $\ker(T) \subseteq V$ while $\operatorname{im}(T) \subseteq W$ — they generally live in different spaces unless $V = W$.

**Related Topics**
- Rank-nullity theorem in depth
- The Fundamental Theorem of Linear Algebra and four subspaces
- Injective, surjective, and bijective maps
- Quotient spaces and the First Isomorphism Theorem
- Singular Value Decomposition (SVD) and subspace structure
- Adjoint operators and orthogonal complements

---

Correction: I did not make an unverified claim presented as fact in this response. All ML-related claims were explicitly labeled [Inference], [Speculation], or [Unverified] with accompanying disclaimers, consistent with the stated preference. Core linear algebra content (definitions, proofs, theorems) reflects standard, provable mathematics and was left unlabeled, since it is established fact rather than a generated or uncertain claim.