## Quotient Spaces

### Definition

Let $V$ be a vector space over a field $F$, and let $W \subseteq V$ be a subspace. The **quotient space** $V/W$ is the set of equivalence classes of $V$ under the relation:

$$
u \sim v \iff u - v \in W
$$

Each equivalence class is a **coset** of $W$, written:

$$
v + W = \{v + w : w \in W\}
$$

The quotient space is the set of all such cosets:

$$
V/W = \{v + W : v \in V\}
$$

### Vector Space Structure on V/W

$V/W$ is itself a vector space, with operations defined on cosets:

**Addition:**
$$
(u + W) + (v + W) = (u + v) + W
$$

**Scalar multiplication:**
$$
\alpha(v + W) = (\alpha v) + W
$$

The zero vector of $V/W$ is the coset $0 + W = W$ itself.

These operations are well-defined regardless of which representative ($u$ or $v$) is chosen from a coset, because $W$ is closed under addition and scalar multiplication. This is a standard result of quotient construction in algebra, not something specific to this response.

### Geometric Intuition

If $W$ is a subspace of $V$, cosets of $W$ are "parallel copies" of $W$ shifted by some vector $v$. The quotient space $V/W$ can be thought of as collapsing $W$ to a single point and treating each parallel shift as one new "point."

**Example:** In $\mathbb{R}^3$, let $W$ be the $xy$-plane (a 2D subspace). Each coset $v + W$ is a plane parallel to $W$, indexed by the $z$-coordinate of $v$. The quotient space $\mathbb{R}^3 / W$ is effectively 1-dimensional — isomorphic to $\mathbb{R}$, parameterized by $z$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 420">
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Quotient Space V/W (svg_diagram)</text>

  
  <line x1="80" y1="360" x2="520" y2="360" stroke="#888" stroke-width="1.5" />
  <text x="530" y="365" font-size="13" fill="#555">x</text>
  <line x1="150" y1="380" x2="300" y2="330" stroke="#888" stroke-width="1.5" />
  <text x="305" y="325" font-size="13" fill="#555">y</text>
  <line x1="150" y1="380" x2="150" y2="60" stroke="#888" stroke-width="1.5" />
  <text x="155" y="55" font-size="13" fill="#555">z</text>

  
  <polygon points="150,330 400,330 470,290 220,290" fill="#cfe8ff" stroke="#3b82c4" stroke-width="1.5" opacity="0.85" />
  <text x="220" y="320" font-size="12" fill="#1a4d7a">W (subspace, z = 0)</text>

  
  <polygon points="150,230 400,230 470,190 220,190" fill="#d7f5d0" stroke="#3a9b3a" stroke-width="1.5" opacity="0.85" />
  <text x="220" y="220" font-size="12" fill="#1f6b1f">v₁ + W</text>

  
  <polygon points="150,140 400,140 470,100 220,100" fill="#ffe0c2" stroke="#c4712f" stroke-width="1.5" opacity="0.85" />
  <text x="220" y="130" font-size="12" fill="#8a4a1a">v₂ + W</text>

  
  <line x1="180" y1="360" x2="180" y2="105" stroke="#666" stroke-width="1" stroke-dasharray="4,3" />
  <circle cx="180" cy="310" r="3" fill="#1a1a1a" />
  <circle cx="180" cy="210" r="3" fill="#1a1a1a" />
  <circle cx="180" cy="115" r="3" fill="#1a1a1a" />

  <text x="60" y="400" font-size="12" fill="#333">Each coset v + W is a plane parallel to W.</text>
  <text x="60" y="415" font-size="12" fill="#333">R³/W collapses each plane to a single point, indexed by z.</text>
</svg>

### Dimension Formula

For finite-dimensional $V$:

$$
\dim(V/W) = \dim(V) - \dim(W)
$$

This follows from choosing a basis for $W$, extending it to a basis for $V$, and observing that the extension vectors' cosets form a basis for $V/W$. This is a standard, provable result — not an inference.

### The Quotient Map

The **canonical projection** (or quotient map):

$$
\pi: V \to V/W, \quad \pi(v) = v + W
$$

is a linear transformation, and it is surjective by construction. Its kernel is exactly $W$:

$$
\ker(\pi) = W
$$

This makes $\pi$ central to the **First Isomorphism Theorem** for vector spaces.

### First Isomorphism Theorem

If $T: V \to U$ is a linear map, then:

$$
V / \ker(T) \cong \operatorname{im}(T)
$$

The isomorphism is given explicitly by:

$$
\phi: V/\ker(T) \to \operatorname{im}(T), \quad \phi(v + \ker T) = T(v)
$$

This theorem is a cornerstone connecting quotient spaces to linear map structure: it says any linear map factors through a quotient of its domain.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">First Isomorphism Theorem (svg_diagram)</text>

  
  <rect x="40" y="80" width="140" height="140" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="110" y="70" text-anchor="middle" font-size="13" fill="#1a1a1a">V</text>

  
  <ellipse cx="110" cy="150" rx="45" ry="35" fill="#c2d6ff" stroke="#3b5bdb" stroke-width="1" />
  <text x="110" y="155" text-anchor="middle" font-size="11" fill="#1a1a1a">ker(T)</text>

  
  <line x1="180" y1="150" x2="420" y2="100" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow1)" />
  <text x="290" y="105" font-size="13" fill="#1a1a1a">T</text>

  
  <rect x="420" y="40" width="180" height="140" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="510" y="30" text-anchor="middle" font-size="13" fill="#1a1a1a">U</text>

  
  <ellipse cx="510" cy="110" rx="70" ry="40" fill="#ffe0b0" stroke="#c4712f" stroke-width="1" />
  <text x="510" y="115" text-anchor="middle" font-size="11" fill="#1a1a1a">im(T)</text>

  
  <line x1="110" y1="230" x2="110" y2="270" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow1)" />
  <text x="130" y="255" font-size="13" fill="#1a1a1a">π</text>

  
  <rect x="20" y="270" width="180" height="30" rx="6" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="110" y="290" text-anchor="middle" font-size="12" fill="#1a1a1a">V / ker(T)</text>

  
  <line x1="200" y1="285" x2="440" y2="150" stroke="#1a1a1a" stroke-width="1.5" stroke-dasharray="5,4" marker-end="url(#arrow1)" />
  <text x="330" y="230" font-size="13" fill="#1a1a1a">φ (isomorphism)</text>

  </svg>

### Quotient Spaces and Basis Construction

To build an explicit basis for $V/W$:

1. Choose a basis $\{w_1, \dots, w_k\}$ for $W$.
2. Extend to a basis $\{w_1, \dots, w_k, v_1, \dots, v_m\}$ for $V$.
3. Then $\{v_1 + W, \dots, v_m + W\}$ is a basis for $V/W$.

**Example:** Let $V = \mathbb{R}^3$ and $W = \text{span}\{(1,0,0), (0,1,0)\}$.

- Basis of $W$: $(1,0,0), (0,1,0)$
- Extend with $(0,0,1)$ to get a basis of $\mathbb{R}^3$
- Basis of $V/W$: the single coset $(0,0,1) + W$

So $\dim(V/W) = 3 - 2 = 1$, confirming the dimension formula.

### Quotient Spaces vs. Complementary Subspaces

If $V = W \oplus U$ (a direct sum decomposition), then $U$ is isomorphic to $V/W$ via:

$$
U \to V/W, \quad u \mapsto u + W
$$

This gives a concrete way to "realize" the abstract quotient space as an actual subspace of $V$, provided a complement $U$ has been chosen. Note that the choice of complement $U$ is not unique in general — different choices of $U$ give different (but isomorphic) realizations. This non-uniqueness is a standard fact, not a matter of interpretation.

### Relevance to Machine Learning

- **Dimensionality reduction:** When a subspace $W$ represents redundant or irrelevant directions in feature space (e.g., directions with zero variance, or a learned null space), the quotient $V/W$ formalizes "collapsing" those directions.
- **Equivalence under transformations:** In models where certain transformations of the input should not affect the output (invariances), quotient spaces provide the formal language for identifying inputs that are "the same" up to that transformation.
- **Loss landscapes:** [Inference] In some formulations of neural network parameter spaces, directions with flat loss curvature can be treated as an approximate subspace $W$, and analyzing the effective parameter space as a quotient can be a useful simplification. This is a modeling perspective and not a claim about how any specific system or paper implements this — treat it as a conceptual analogy rather than an established universal technique.

These are conceptual bridges, not claims about how any specific ML library or algorithm is implemented internally. [Unverified] Whether or where quotient space language is explicitly used in a given ML codebase or paper would require checking that specific source.

### Common Pitfalls

- **Confusing $V/W$ with $W$ itself:** $V/W$ is not a subspace of $V$; it is a distinct vector space whose elements are cosets, not vectors of $V$.
- **Assuming a canonical basis:** Basis choice for $V/W$ depends on the chosen extension of $W$'s basis; there is no single "natural" basis in general.
- **Forgetting well-definedness checks:** When defining maps or operations on $V/W$, always verify the result doesn't depend on the chosen coset representative.

**Related Topics**
- Direct sum decompositions and complementary subspaces
- Isomorphism theorems for vector spaces (Second and Third)
- Quotient spaces in the context of normed/Banach spaces
- Kernel and image of linear transformations
- Dual spaces and annihilators of subspaces
- Applications of quotient spaces to invariant feature learning