## Isomorphisms

### Definition

A linear map $T: V \to W$ is an **isomorphism** if it is bijective — both injective and surjective. When such a map exists between $V$ and $W$, the two vector spaces are said to be **isomorphic**, denoted:

$$
V \cong W
$$

An isomorphism preserves all linear-algebraic structure: vector addition, scalar multiplication, linear independence, spanning sets, and dimension.

### The Inverse of an Isomorphism

If $T: V \to W$ is an isomorphism, its inverse $T^{-1}: W \to V$ exists and is also linear. Proof of linearity of $T^{-1}$: let $w_1, w_2 \in W$ with $T(v_1) = w_1$, $T(v_2) = w_2$. Then $T^{-1}(w_1 + w_2) = T^{-1}(T(v_1) + T(v_2)) = T^{-1}(T(v_1 + v_2)) = v_1 + v_2 = T^{-1}(w_1) + T^{-1}(w_2)$, using linearity of $T$. A similar argument holds for scalar multiplication. This is a standard, provable result.

### Isomorphism Preserves Dimension

If $V \cong W$ and both are finite-dimensional, then:

$$
\dim(V) = \dim(W)
$$

This follows from the rank-nullity theorem: since $T$ is injective, $\ker(T) = \{0\}$, so $\dim(\operatorname{im} T) = \dim(V)$; since $T$ is also surjective, $\operatorname{im}(T) = W$, giving $\dim(V) = \dim(W)$.

**Converse (finite dimensions only):** If $\dim(V) = \dim(W) = n$ over the same field $F$, then $V \cong W$. Both are isomorphic to $F^n$ via coordinate maps relative to any chosen bases, and isomorphism is transitive, so $V \cong F^n \cong W$. This is a standard, provable result specific to finite-dimensional spaces over the same field.

### Every Finite-Dimensional Space is Isomorphic to $F^n$

If $\dim(V) = n$ and $B = \{v_1, \dots, v_n\}$ is a basis, the **coordinate map**:

$$
\phi_B: V \to F^n, \quad \phi_B(v) = [v]_B
$$

is an isomorphism. This is a direct consequence of the definition of basis: every vector has a unique representation as a linear combination of basis vectors, so $\phi_B$ is well-defined, linear, injective, and surjective by construction.

**Practical implication:** Any finite-dimensional vector space "looks like" $F^n$ once a basis is fixed — this is why abstract vector space results can be verified using concrete coordinate/matrix computations.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 260">
  <text x="310" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Isomorphism via Coordinate Map (svg_diagram)</text>

  <rect x="60" y="80" width="180" height="120" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="150" y="70" text-anchor="middle" font-size="13" fill="#1a1a1a">V (abstract, dim n)</text>
  <text x="150" y="145" text-anchor="middle" font-size="12" fill="#1a1a1a">v</text>

  <line x1="240" y1="140" x2="380" y2="140" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow6)" />
  <text x="310" y="128" text-anchor="middle" font-size="12" fill="#1a1a1a">φ_B (isomorphism)</text>

  <rect x="380" y="80" width="180" height="120" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="470" y="70" text-anchor="middle" font-size="13" fill="#1a1a1a">Fⁿ (coordinates)</text>
  <text x="470" y="145" text-anchor="middle" font-size="12" fill="#1a1a1a">[v]_B</text>

  <line x1="380" y1="170" x2="240" y2="170" stroke="#888" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#arrow6)" />
  <text x="310" y="190" text-anchor="middle" font-size="11" fill="#555">φ_B⁻¹</text>

  </svg>

### Matrix Criterion for Isomorphism

For $T: F^n \to F^n$ (same finite dimension on both sides) with matrix $A$, $T$ is an isomorphism if and only if any one of the following equivalent conditions holds:

- $\det(A) \neq 0$
- $\operatorname{rank}(A) = n$
- The columns of $A$ are linearly independent
- The columns of $A$ span $F^n$
- $A$ is invertible
- $\ker(T) = \{0\}$

These equivalences are standard, provable results connecting determinants, rank, and invertibility.

**Example:** Let $V = P_2(\mathbb{R})$ (polynomials of degree $\leq 2$) and $W = \mathbb{R}^3$. Define $T: V \to W$ by:

$$
T(a + bx + cx^2) = (a, b, c)
$$

This is the coordinate map relative to the basis $\{1, x, x^2\}$ of $P_2(\mathbb{R})$. It is linear, injective (only the zero polynomial maps to $(0,0,0)$), and surjective (every triple $(a,b,c)$ arises from some polynomial), so $T$ is an isomorphism. This confirms $P_2(\mathbb{R}) \cong \mathbb{R}^3$, consistent with both having dimension 3.

### Isomorphism is an Equivalence Relation

Isomorphism between vector spaces satisfies:

- **Reflexivity:** $V \cong V$ via the identity map.
- **Symmetry:** If $V \cong W$, then $W \cong V$, since the inverse of an isomorphism is itself an isomorphism.
- **Transitivity:** If $V \cong W$ and $W \cong U$, then $V \cong U$, since the composition of two isomorphisms is an isomorphism.

These properties are direct, provable consequences of the definitions established above, confirming isomorphism is a genuine equivalence relation on the class of vector spaces (over a fixed field).

### What Isomorphisms Preserve

Because an isomorphism $T: V \to W$ is a structure-preserving bijection, the following transfer between $V$ and $W$:

- **Linear independence:** $\{v_1, \dots, v_k\}$ is linearly independent in $V$ if and only if $\{T(v_1), \dots, T(v_k)\}$ is linearly independent in $W$.
- **Spanning sets:** $\{v_1, \dots, v_k\}$ spans $V$ if and only if $\{T(v_1), \dots, T(v_k)\}$ spans $W$.
- **Bases:** $T$ maps a basis of $V$ to a basis of $W$.
- **Subspace structure:** $U \subseteq V$ is a subspace if and only if $T(U) \subseteq W$ is a subspace, and $\dim(U) = \dim(T(U))$.

These preservation properties follow from the definitions of injectivity, surjectivity, and linearity, and are standard, provable results.

### What Isomorphisms Do Not Preserve

An isomorphism preserves *linear* structure only. It does not necessarily preserve:

- **Additional structure**, such as an inner product, unless $T$ is specifically required to be an isometry (in which case it is called an *isometric isomorphism* or *orthogonal/unitary transformation*, a stricter condition).
- **Specific numeric values** of coordinates, since coordinates are basis-dependent and an isomorphism can map between spaces with entirely different natural coordinate systems (e.g., polynomials vs. tuples).

This distinction is a standard point of caution in linear algebra: "isomorphic" means "the same up to linear structure," not "identical in every respect."

### Non-Isomorphism

If $\dim(V) \neq \dim(W)$ (finite-dimensional case), then $V \not\cong W$ — no isomorphism between them can exist, since isomorphisms preserve dimension. This is a direct, provable consequence of the dimension-preservation property established above.

For infinite-dimensional spaces, dimension comparison is more subtle. I cannot verify a complete general treatment of infinite-dimensional isomorphism criteria within this response, and any such claim would require a separate, carefully sourced treatment.

### Relevance to Machine Learning

- **Equivalent parameterizations:** [Inference] If a model's parameter space admits a linear change of basis that is bijective, the reparameterized model is related to the original by a vector space isomorphism, meaning the two parameterizations share identical linear structure (dimension, independence relations). This is a direct mathematical consequence of the isomorphism properties described above, not a claim about how any specific model or framework is implemented. [Unverified] I cannot verify whether any specific ML paper, library, or framework explicitly frames its reparameterizations in these terms without checking that specific source.
- **Embedding spaces:** [Speculation] It is possible that some descriptions of embedding spaces in machine learning informally invoke the idea that two representations are "equivalent" when a suitable transformation between them exists, which loosely parallels the mathematical notion of isomorphism, but I do not have a confirmed source describing this connection explicitly, and I cannot verify this claim. This is not a formal mathematical statement about any specific embedding technique.

I cannot verify how any specific machine learning system, library, or paper uses or references isomorphism concepts without direct access to that source. Behavior of such systems is not guaranteed and may vary by implementation.

### Common Pitfalls

- **Assuming same dimension implies a "natural" isomorphism:** Dimension equality guarantees *an* isomorphism exists, but not a canonical or uniquely preferred one — many isomorphisms can exist between spaces of equal dimension.
- **Confusing isomorphism with equality:** $V \cong W$ means structurally identical, not that $V$ and $W$ are the same set of objects.
- **Assuming isomorphisms preserve inner products by default:** A generic linear isomorphism need not preserve length or angle; that requires the stricter condition of being an isometry.
- **Misapplying finite-dimensional criteria to infinite-dimensional spaces:** [Unverified] The equivalences involving determinant and rank apply only in the finite-dimensional case; extending them without modification to infinite dimensions is not verified here and would require separate justification.

**Related Topics**
- Rank-nullity theorem in depth
- Coordinate maps and change of basis
- Quotient spaces and the First Isomorphism Theorem
- Injective, surjective, and bijective maps
- Isometries and orthogonal/unitary transformations
- Dual spaces and natural vs. non-natural isomorphisms