## Composition of Linear Transformations

### Definition

Let $T: U \to V$ and $S: V \to W$ be linear maps. The **composition** $S \circ T: U \to W$ is defined by:

$$
(S \circ T)(u) = S(T(u))
$$

for all $u \in U$. The composition applies $T$ first, then $S$, matching standard function composition order.

### Composition is Linear

If $T$ and $S$ are both linear, then $S \circ T$ is also linear. This follows directly from the definitions:

**Additivity:**
$$
(S \circ T)(u_1 + u_2) = S(T(u_1 + u_2)) = S(T(u_1) + T(u_2)) = S(T(u_1)) + S(T(u_2)) = (S\circ T)(u_1) + (S \circ T)(u_2)
$$

**Homogeneity:**
$$
(S \circ T)(\alpha u) = S(T(\alpha u)) = S(\alpha T(u)) = \alpha S(T(u)) = \alpha (S \circ T)(u)
$$

Both steps rely only on the linearity of $T$ and then of $S$; this is a direct algebraic consequence of the definitions and is a standard, provable result.

### Matrix Representation of Composition

If $U$, $V$, $W$ are finite-dimensional with chosen bases, and $T$ has matrix $A$ (relative to bases of $U$ and $V$) while $S$ has matrix $B$ (relative to bases of $V$ and $W$), then $S \circ T$ has matrix:

$$
[S \circ T] = BA
$$

Note the order: matrix $B$ (for $S$) is applied on the left, matrix $A$ (for $T$) on the right, reflecting that $T$ acts first on the input vector.

**Example:** Let $T: \mathbb{R}^2 \to \mathbb{R}^2$ with matrix

$$
A = \begin{bmatrix} 1 & 2 \\ 0 & 1 \end{bmatrix}
$$

and $S: \mathbb{R}^2 \to \mathbb{R}^2$ with matrix

$$
B = \begin{bmatrix} 3 & 0 \\ 1 & 1 \end{bmatrix}
$$

Then:

$$
BA = \begin{bmatrix} 3 & 0 \\ 1 & 1 \end{bmatrix}\begin{bmatrix} 1 & 2 \\ 0 & 1 \end{bmatrix} = \begin{bmatrix} 3 & 6 \\ 1 & 3 \end{bmatrix}
$$

Applying to a vector $(1,1)$: $T(1,1) = (3,1)$, then $S(3,1) = (9,4)$. Direct matrix product check: $BA \cdot (1,1)^T = (3+6, 1+3) = (9,4)$. This matches, confirming the composition rule for this example.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Composition of Linear Maps (svg_diagram)</text>

  <rect x="30" y="90" width="140" height="60" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="100" y="125" text-anchor="middle" font-size="13" fill="#1a1a1a">U</text>

  <line x1="170" y1="120" x2="270" y2="120" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow4)" />
  <text x="220" y="108" text-anchor="middle" font-size="12" fill="#1a1a1a">T (matrix A)</text>

  <rect x="270" y="90" width="140" height="60" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="340" y="125" text-anchor="middle" font-size="13" fill="#1a1a1a">V</text>

  <line x1="410" y1="120" x2="510" y2="120" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow4)" />
  <text x="460" y="108" text-anchor="middle" font-size="12" fill="#1a1a1a">S (matrix B)</text>

  <rect x="510" y="90" width="140" height="60" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="575" y="125" text-anchor="middle" font-size="13" fill="#1a1a1a">W</text>

  <path d="M100,90 C100,40 575,40 575,90" stroke="#888" stroke-width="1.3" stroke-dasharray="5,4" fill="none" marker-end="url(#arrow4)" />
  <text x="340" y="35" text-anchor="middle" font-size="12" fill="#555">S ∘ T (matrix BA)</text>

  </svg>

### Associativity

Composition of linear maps is associative:

$$
(R \circ S) \circ T = R \circ (S \circ T)
$$

This mirrors associativity of matrix multiplication: $(CB)A = C(BA)$. Both are standard, provable facts and hold for any compatible linear maps or matrices.

### Non-Commutativity

In general:

$$
S \circ T \neq T \circ S
$$

even when both compositions are defined (e.g., when $U = V = W$). Order matters. This is a standard fact about linear maps and matrix multiplication, easily demonstrated by counterexample — the matrices $A$ and $B$ above do not commute in general.

### Kernel and Image Under Composition

**Kernel relationship:**
$$
\ker(T) \subseteq \ker(S \circ T)
$$

This holds because if $T(u) = 0$, then $S(T(u)) = S(0) = 0$, so $u \in \ker(S \circ T)$.

**Image relationship:**
$$
\operatorname{im}(S \circ T) \subseteq \operatorname{im}(S)
$$

This holds because every output of $S \circ T$ is, by definition, $S$ applied to something, hence lies in $S$'s image.

**Rank inequality:**
$$
\operatorname{rank}(S \circ T) \leq \min(\operatorname{rank}(S), \operatorname{rank}(T))
$$

This follows from the two subset relationships above combined with the fact that dimension is monotonic under subspace inclusion. This is a standard, provable inequality — not an approximation or heuristic.

### Composition and Invertibility

If $T: V \to V$ and $S: V \to V$ are both invertible, then $S \circ T$ is invertible, with:

$$
(S \circ T)^{-1} = T^{-1} \circ S^{-1}
$$

Note the order reversal — this is analogous to $(BA)^{-1} = A^{-1}B^{-1}$ for invertible matrices. This is provable directly by checking $(S\circ T) \circ (T^{-1} \circ S^{-1}) = \text{id}$ and the reverse composition.

### Identity and Inverse Maps

The **identity map** $\text{id}_V: V \to V$, defined by $\text{id}_V(v) = v$, acts as a two-sided identity for composition:

$$
T \circ \text{id}_U = T, \qquad \text{id}_V \circ T = T
$$

A linear map $T: V \to V$ is invertible if and only if there exists $T^{-1}: V \to V$ such that:

$$
T \circ T^{-1} = T^{-1} \circ T = \text{id}_V
$$

### Powers of an Endomorphism

For $T: V \to V$, composing $T$ with itself repeatedly defines powers:

$$
T^k = \underbrace{T \circ T \circ \cdots \circ T}_{k \text{ times}}
$$

In matrix terms, $[T^k] = A^k$ (ordinary matrix power). This is directly relevant to eigenvalue theory: if $v$ is an eigenvector of $T$ with eigenvalue $\lambda$, then:

$$
T^k(v) = \lambda^k v
$$

This follows by induction from the definition of eigenvector and repeated application of $T$.

### Relevance to Machine Learning

- **Layer stacking:** [Inference] A deep neural network without nonlinear activation functions can be understood as a single composed linear map, since the composition of linear maps is itself linear (a mathematical consequence proven above). This is a mathematical characterization of the idealized case and is not a description of how any specific framework implements layer stacking internally. [Unverified] I cannot verify implementation details of any specific deep learning library without consulting its source code directly.
- **Backpropagation and the chain rule:** [Inference] The chain rule used in backpropagation has a structural resemblance to composition of linear maps when derivatives are treated as their local linear (Jacobian) approximations, though this is a conceptual analogy from calculus and not a claim about the literal algorithmic implementation of backpropagation in any specific system. [Unverified] Behavior of specific autodiff systems is not confirmed here and would require checking their documentation or source code directly.
- **Sequential transformations:** Pipelines involving multiple linear transformations (e.g., successive projections, whitening followed by rotation) compose according to the rules above, since each stage is itself a linear map.

I cannot verify how any specific machine learning library, framework, or paper implements composed transformations internally. Any claims about specific system behavior would require direct inspection of that system's source code or documentation, which has not been done here.

### Common Pitfalls

- **Assuming commutativity:** $S \circ T$ and $T \circ S$ are generally different maps, even when both are defined.
- **Reversing matrix order:** The matrix of $S \circ T$ is $BA$, not $AB$ — a common source of computational error.
- **Assuming composed maps are always invertible:** $S \circ T$ is invertible only if both $S$ and $T$ are invertible (in the finite-dimensional, same-space case); composing a non-invertible map with anything yields a non-invertible result.
- **Misapplying the rank inequality:** $\operatorname{rank}(S \circ T)$ can be strictly less than both $\operatorname{rank}(S)$ and $\operatorname{rank}(T)$, not just bounded by their minimum.

**Related Topics**
- Eigenvalues, eigenvectors, and diagonalization
- Matrix representation of linear transformations
- Invertibility and isomorphisms
- Rank-nullity theorem
- Change of basis and similarity transformations
- Chain rule and Jacobians in multivariable calculus