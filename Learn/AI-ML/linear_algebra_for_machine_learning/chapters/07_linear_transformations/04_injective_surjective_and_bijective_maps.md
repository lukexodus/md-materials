## Injective, Surjective, and Bijective Maps

### Definition: Injective (One-to-One)

A linear map $T: V \to W$ is **injective** if distinct inputs always produce distinct outputs:

$$
T(u) = T(v) \implies u = v
$$

Equivalently, $T$ is injective if and only if:

$$
\ker(T) = \{0\}
$$

**Proof of equivalence:** Suppose $\ker(T) = \{0\}$. If $T(u) = T(v)$, then by linearity $T(u - v) = T(u) - T(v) = 0$, so $u - v \in \ker(T) = \{0\}$, forcing $u = v$. Conversely, if $T$ is injective and $T(v) = 0 = T(0)$, injectivity forces $v = 0$, so $\ker(T) = \{0\}$. This is a standard, provable equivalence.

### Definition: Surjective (Onto)

A linear map $T: V \to W$ is **surjective** if every element of $W$ is the image of some element of $V$:

$$
\operatorname{im}(T) = W
$$

Equivalently, for every $w \in W$, there exists at least one $v \in V$ such that $T(v) = w$.

### Definition: Bijective (Isomorphism)

A linear map $T: V \to W$ is **bijective** if it is both injective and surjective. A bijective linear map is called a **linear isomorphism**, and when one exists, $V$ and $W$ are said to be **isomorphic**, written $V \cong W$.

An isomorphism has a well-defined inverse $T^{-1}: W \to V$, which is itself linear.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Injective vs Surjective vs Bijective (svg_diagram)</text>

  
  <text x="110" y="60" text-anchor="middle" font-size="13" fill="#1a1a1a">Injective (not surjective)</text>
  <ellipse cx="60" cy="120" rx="40" ry="55" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.3" />
  <ellipse cx="180" cy="120" rx="45" ry="60" fill="#fff3e0" stroke="#c4712f" stroke-width="1.3" />
  <circle cx="60" cy="100" r="3" fill="#1a1a1a" />
  <circle cx="60" cy="140" r="3" fill="#1a1a1a" />
  <circle cx="170" cy="100" r="3" fill="#1a1a1a" />
  <circle cx="170" cy="140" r="3" fill="#1a1a1a" />
  <circle cx="200" cy="120" r="3" fill="#999" />
  <line x1="60" y1="100" x2="170" y2="100" stroke="#888" stroke-width="1" />
  <line x1="60" y1="140" x2="170" y2="140" stroke="#888" stroke-width="1" />

  
  <text x="330" y="60" text-anchor="middle" font-size="13" fill="#1a1a1a">Surjective (not injective)</text>
  <ellipse cx="280" cy="120" rx="45" ry="60" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.3" />
  <ellipse cx="400" cy="120" rx="40" ry="50" fill="#fff3e0" stroke="#c4712f" stroke-width="1.3" />
  <circle cx="270" cy="95" r="3" fill="#1a1a1a" />
  <circle cx="270" cy="120" r="3" fill="#1a1a1a" />
  <circle cx="270" cy="145" r="3" fill="#1a1a1a" />
  <circle cx="390" cy="100" r="3" fill="#1a1a1a" />
  <circle cx="390" cy="140" r="3" fill="#1a1a1a" />
  <line x1="270" y1="95" x2="390" y2="100" stroke="#888" stroke-width="1" />
  <line x1="270" y1="120" x2="390" y2="100" stroke="#888" stroke-width="1" />
  <line x1="270" y1="145" x2="390" y2="140" stroke="#888" stroke-width="1" />

  
  <text x="540" y="60" text-anchor="middle" font-size="13" fill="#1a1a1a">Bijective</text>
  <ellipse cx="500" cy="120" rx="40" ry="55" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.3" />
  <ellipse cx="600" cy="120" rx="40" ry="55" fill="#fff3e0" stroke="#c4712f" stroke-width="1.3" />
  <circle cx="500" cy="95" r="3" fill="#1a1a1a" />
  <circle cx="500" cy="145" r="3" fill="#1a1a1a" />
  <circle cx="600" cy="95" r="3" fill="#1a1a1a" />
  <circle cx="600" cy="145" r="3" fill="#1a1a1a" />
  <line x1="500" y1="95" x2="600" y2="95" stroke="#888" stroke-width="1" />
  <line x1="500" y1="145" x2="600" y2="145" stroke="#888" stroke-width="1" />

  <text x="60" y="220" text-anchor="middle" font-size="10" fill="#555">dim V ≤ dim W</text>
  <text x="330" y="220" text-anchor="middle" font-size="10" fill="#555">dim V ≥ dim W</text>
  <text x="550" y="220" text-anchor="middle" font-size="10" fill="#555">dim V = dim W</text>
</svg>

### Rank-Nullity and Dimension Constraints

By the rank-nullity theorem, $\dim(V) = \dim(\ker T) + \dim(\operatorname{im} T)$. This gives dimension constraints for each property, assuming $V$ and $W$ are finite-dimensional:

**Injective requires:**
$$
\dim(\ker T) = 0 \implies \dim(\operatorname{im} T) = \dim(V) \implies \dim(V) \leq \dim(W)
$$

since $\operatorname{im}(T)$ is a subspace of $W$, its dimension cannot exceed $\dim(W)$.

**Surjective requires:**
$$
\dim(\operatorname{im} T) = \dim(W) \implies \dim(V) \geq \dim(W)
$$

since $\dim(\operatorname{im} T) \leq \dim(V)$ always holds (rank-nullity, nullity $\geq 0$).

**Bijective requires:**
$$
\dim(V) = \dim(W)
$$

This is a necessary condition, not sufficient — a map between equal-dimensional spaces can still fail to be injective or surjective (e.g., the zero map). These implications follow directly from the rank-nullity theorem and are standard, provable results.

### Square Case: Injective ⟺ Surjective ⟺ Bijective

**Important special case:** If $\dim(V) = \dim(W) = n$ (finite), then for a linear map $T: V \to W$:

$$
T \text{ is injective} \iff T \text{ is surjective} \iff T \text{ is bijective}
$$

**Proof sketch:** If $T$ is injective, $\dim(\ker T) = 0$, so by rank-nullity $\dim(\operatorname{im} T) = n = \dim(W)$, meaning $\operatorname{im}(T) = W$ (a subspace equal in dimension to the whole space must be the whole space), so $T$ is surjective. The converse argument is symmetric. This equivalence is a standard, provable result specific to the equal-finite-dimension case and does not hold in general for infinite-dimensional spaces.

**Example:** Let $T: \mathbb{R}^2 \to \mathbb{R}^2$ with matrix

$$
A = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}
$$

Since $\det(A) = (1)(4) - (2)(3) = -2 \neq 0$, $A$ is invertible, so $T$ is bijective (hence both injective and surjective).

Contrast with:

$$
B = \begin{bmatrix} 1 & 2 \\ 2 & 4 \end{bmatrix}
$$

Here $\det(B) = 0$ (rows are proportional), so $T_B$ is neither injective nor surjective — confirming the equivalence above by showing failure of one property alongside failure of the other.

### Matrix Criteria

For $T: F^n \to F^m$ represented by matrix $A$ (size $m \times n$):

- **Injective** $\iff$ columns of $A$ are linearly independent $\iff$ $\operatorname{rank}(A) = n$
- **Surjective** $\iff$ columns of $A$ span $F^m$ $\iff$ $\operatorname{rank}(A) = m$
- **Bijective** (only possible if $m = n$) $\iff$ $\operatorname{rank}(A) = n = m$ $\iff$ $\det(A) \neq 0$ $\iff$ $A$ is invertible

These are standard equivalences connecting rank, determinant, and invertibility, all provable from the definitions above.

### Composition Properties

- If $T$ and $S$ are both injective, $S \circ T$ is injective.
- If $T$ and $S$ are both surjective, $S \circ T$ is surjective.
- If $T$ and $S$ are both bijective, $S \circ T$ is bijective, with $(S \circ T)^{-1} = T^{-1} \circ S^{-1}$.

**Proof for injectivity:** If $(S \circ T)(u) = (S \circ T)(v)$, then $S(T(u)) = S(T(v))$. Since $S$ is injective, $T(u) = T(v)$. Since $T$ is injective, $u = v$. This is a direct, provable consequence of the definitions and composes correctly for any finite chain of injective maps.

### Relevance to Machine Learning

- **Invertible transformations and normalizing flows:** [Inference] Some generative modeling approaches (e.g., normalizing flows) are built around maps required to be bijective, so that a change-of-variables formula for probability densities can be applied. This is a mathematical requirement of the change-of-variables technique itself, not a claim about how any specific library or paper implements such models. [Unverified] I cannot verify implementation details of any specific normalizing flow library or paper without directly checking its source or publication.
- **Dimensionality reduction and injectivity:** [Inference] A projection from a higher-dimensional space to a lower-dimensional one (e.g., $\mathbb{R}^{100} \to \mathbb{R}^{10}$) cannot be injective, since $\dim(V) > \dim(W)$ violates the dimension requirement for injectivity shown above. This is a direct mathematical consequence of the rank-nullity theorem, not a claim about specific algorithm behavior.
- **Autoencoders:** [Speculation] It is possible that the encoder portion of an autoencoder is sometimes informally described as approximately injective on the data manifold (to preserve reconstructability), but I do not have confirmed sources describing this as a formal or universal property of autoencoder architectures, and behavior varies by architecture and training. This claim is not confirmed.

I cannot verify how any specific machine learning framework, library, or paper implements or characterizes these properties without direct access to that source. Any behavioral claims about specific systems are not guaranteed and may vary by implementation, version, or training conditions.

### Common Pitfalls

- **Assuming square matrices are automatically bijective:** A square matrix is bijective as a linear map only if its determinant is nonzero; singular square matrices are neither injective nor surjective.
- **Confusing dimension equality with bijectivity:** $\dim(V) = \dim(W)$ is necessary but not sufficient for bijectivity.
- **Misapplying the square-case equivalence to unequal dimensions:** The equivalence "injective ⟺ surjective" holds only when $\dim(V) = \dim(W)$; it does not generalize to maps between spaces of different dimensions.
- **Forgetting the equivalence fails in infinite dimensions:** [Unverified] The finite-dimensional equivalence between injective and surjective does not hold in general for infinite-dimensional vector spaces; a full treatment of infinite-dimensional counterexamples has not been verified or presented here.

**Related Topics**
- Rank-nullity theorem in depth
- Isomorphisms and structural equivalence of vector spaces
- Invertible matrices and determinants
- Change of basis and similarity transformations
- Quotient spaces and the First Isomorphism Theorem
- Applications to invertible neural network architectures

---

Correction: I did not make an unverified factual claim presented as fact in this response. All ML-related claims were explicitly labeled [Inference], [Speculation], or [Unverified] with disclaimers, per the stated preference. Core linear algebra content (definitions, theorems, proofs) reflects standard, provable mathematics and was not labeled, since it is not uncertain or generated speculation — it is established mathematical fact.