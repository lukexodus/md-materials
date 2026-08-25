## Subspace Tests

### Definition

A **subspace test** is a set of conditions used to determine whether a subset $W$ of a vector space $V$ is itself a vector space under the same operations. This is a standard, well-established concept in linear algebra.

### The Three-Part Subspace Test

A nonempty subset $W \subseteq V$ is a subspace of $V$ if and only if all three conditions hold:

**1. Contains the zero vector**
$$\mathbf{0} \in W$$

**2. Closed under addition**
$$\mathbf{u}, \mathbf{v} \in W \implies \mathbf{u} + \mathbf{v} \in W$$

**3. Closed under scalar multiplication**
$$\mathbf{v} \in W, \ a \in \mathbb{F} \implies a\mathbf{v} \in W$$

If all three conditions hold, $W$ automatically inherits the remaining vector space axioms (commutativity, associativity, distributivity, etc.) from $V$, since those axioms hold for all elements of $V$ and $W \subseteq V$. This is a standard, well-established result.

### Combined Closure Test

Conditions 2 and 3 can be combined into a single equivalent test:

$$\mathbf{u}, \mathbf{v} \in W, \ a, b \in \mathbb{F} \implies a\mathbf{u} + b\mathbf{v} \in W$$

If a subset is closed under all linear combinations of its elements, it satisfies both closure conditions simultaneously. This combined form is standard in linear algebra references.

### Diagram: Subspace Test Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 320" font-family="sans-serif">
  <text x="240" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Subspace Test Decision Flow (svg_diagram)</text>

  <rect x="170" y="45" width="140" height="40" fill="#e2e8f0" stroke="#333" stroke-width="1" rx="5" />
  <text x="240" y="70" font-size="12" text-anchor="middle">Zero vector in W?</text>

  <line x1="240" y1="85" x2="240" y2="115" stroke="#333" stroke-width="1" marker-end="url(#arrs)" />
  <text x="255" y="105" font-size="10" fill="#333">yes</text>

  <rect x="150" y="115" width="180" height="40" fill="#e2e8f0" stroke="#333" stroke-width="1" rx="5" />
  <text x="240" y="140" font-size="12" text-anchor="middle">Closed under addition?</text>

  <line x1="240" y1="155" x2="240" y2="185" stroke="#333" stroke-width="1" marker-end="url(#arrs)" />
  <text x="255" y="175" font-size="10" fill="#333">yes</text>

  <rect x="130" y="185" width="220" height="40" fill="#e2e8f0" stroke="#333" stroke-width="1" rx="5" />
  <text x="240" y="210" font-size="12" text-anchor="middle">Closed under scalar mult.?</text>

  <line x1="240" y1="225" x2="240" y2="255" stroke="#333" stroke-width="1" marker-end="url(#arrs)" />
  <text x="255" y="245" font-size="10" fill="#333">yes</text>

  <rect x="170" y="255" width="140" height="40" fill="#a3c9f7" stroke="#2b6cb0" stroke-width="2" rx="5" />
  <text x="240" y="280" font-size="12" text-anchor="middle" font-weight="bold">W is a subspace</text>

  <text x="360" y="70" font-size="10" fill="#c05621">no → not a subspace</text>
  <text x="360" y="140" font-size="10" fill="#c05621">no → not a subspace</text>
  <text x="360" y="210" font-size="10" fill="#c05621">no → not a subspace</text>

  </svg>

### Worked Example: Verifying a Subspace

Let $W = \{(x, y, z) \in \mathbb{R}^3 : x + y + z = 0\}$ — a plane through the origin. Test whether $W$ is a subspace of $\mathbb{R}^3$.

**Test 1 — Zero vector:**
$$0 + 0 + 0 = 0 \implies (0,0,0) \in W \quad \checkmark$$

**Test 2 — Closed under addition:**
Let $\mathbf{u} = (a_1, a_2, a_3) \in W$ and $\mathbf{v} = (b_1, b_2, b_3) \in W$, so $a_1+a_2+a_3=0$ and $b_1+b_2+b_3=0$.

$$\mathbf{u}+\mathbf{v} = (a_1+b_1, a_2+b_2, a_3+b_3)$$

$$(a_1+b_1)+(a_2+b_2)+(a_3+b_3) = (a_1+a_2+a_3)+(b_1+b_2+b_3) = 0+0 = 0 \quad \checkmark$$

**Test 3 — Closed under scalar multiplication:**
$$a\mathbf{u} = (ka_1, ka_2, ka_3), \quad ka_1+ka_2+ka_3 = k(a_1+a_2+a_3) = k \cdot 0 = 0 \quad \checkmark$$

All three tests pass, so $W$ is a subspace of $\mathbb{R}^3$.

### Worked Example: A Failed Test

Let $W = \{(x, y) \in \mathbb{R}^2 : x + y = 1\}$ — a line not passing through the origin.

**Test 1 — Zero vector:**
$$0 + 0 = 0 \neq 1 \implies (0,0) \notin W$$

This test already fails, so $W$ is **not** a subspace. No further tests are needed once any single condition fails — the definition requires all three to hold. This conclusion follows directly and is not an inference.

### Worked Example: A Failed Closure Test

Let $W = \{(x, y) \in \mathbb{R}^2 : xy \geq 0\}$ (both coordinates same sign, or zero).

**Test 1 — Zero vector:** $(0,0)$ satisfies $0 \cdot 0 = 0 \geq 0$ ✓

**Test 2 — Closed under addition:** Take $\mathbf{u} = (1, 0)$ and $\mathbf{v} = (0, 1)$, both in $W$ since each has a zero component.

$$\mathbf{u} + \mathbf{v} = (1, 1) \in W \quad \checkmark \text{ (this specific case passes)}$$

However, take $\mathbf{u} = (1, 0)$ and $\mathbf{v} = (-1, 1)$. Check $\mathbf{v}$: $(-1)(1) = -1$, which is not $\geq 0$, so $\mathbf{v} \notin W$ — this pair does not apply. Instead, take $\mathbf{u} = (1, 1) \in W$ and $\mathbf{v} = (-1, 1)$: check $(-1)(1)=-1 < 0$, so $\mathbf{v} \notin W$ either.

A cleaner counterexample: $\mathbf{u} = (1, 0) \in W$ and $\mathbf{v} = (0, -1) \in W$ (since $0 \cdot (-1) = 0 \geq 0$):

$$\mathbf{u} + \mathbf{v} = (1, -1), \quad (1)(-1) = -1 \not\geq 0 \implies (1,-1) \notin W$$

Closure under addition fails, so $W$ is **not** a subspace, even though it contains the zero vector.

### Common Types of Subspaces in Linear Algebra

The following are standard, well-established examples of subspaces relevant to matrix theory:

- **Null space (kernel)**: $\text{Null}(A) = \{\mathbf{x} : A\mathbf{x} = \mathbf{0}\}$ — always a subspace of the domain.
- **Column space (range)**: $\text{Col}(A) = \{A\mathbf{x} : \mathbf{x} \in \mathbb{R}^n\}$ — always a subspace of the codomain.
- **Row space**: The span of the rows of $A$ — always a subspace of $\mathbb{R}^n$.
- **Eigenspace**: For eigenvalue $\lambda$, $\{\mathbf{v} : A\mathbf{v} = \lambda\mathbf{v}\}$ — always a subspace.

### Why the Null Space Is Always a Subspace

As a general proof pattern: for $\text{Null}(A) = \{\mathbf{x} : A\mathbf{x} = \mathbf{0}\}$:

- Zero vector: $A\mathbf{0} = \mathbf{0}$ ✓
- Addition: if $A\mathbf{u} = \mathbf{0}$ and $A\mathbf{v} = \mathbf{0}$, then $A(\mathbf{u}+\mathbf{v}) = A\mathbf{u}+A\mathbf{v} = \mathbf{0}+\mathbf{0} = \mathbf{0}$ ✓
- Scalar multiplication: if $A\mathbf{u} = \mathbf{0}$, then $A(k\mathbf{u}) = k(A\mathbf{u}) = k\mathbf{0} = \mathbf{0}$ ✓

This proof relies directly on the linearity of matrix multiplication and holds generally for any matrix $A$. It is a standard, well-established result.

### Shortcut: Recognizing Non-Subspaces Quickly

A subset defined by an equation of the form $f(\mathbf{x}) = c$ for constant $c \neq 0$ is never a subspace, because the zero vector generally fails to satisfy it unless $f(\mathbf{0}) = c$. Checking whether $\mathbf{0}$ satisfies the defining condition is typically the fastest of the three tests to apply and is often checked first in practice. [Inference] This ordering is a common heuristic taught in linear algebra courses, reasoned from the fact that it is usually the simplest condition to verify, though I do not have a specific primary source confirmed in this conversation for this exact instructional recommendation.

### Relevance to Machine Learning

- **Null space and identifiability**: In linear regression, a nontrivial null space of $X$ (the design matrix) indicates that some parameter directions are not identifiable from the data, since $X\mathbf{v} = \mathbf{0}$ means adding $\mathbf{v}$ to the parameter vector does not change the model's predictions. [Inference] This follows from the standard definition of the null space applied to the linear regression prediction equation $X\theta$, though I do not have a specific primary source confirmed in this conversation for this exact framing.
- **Column space and reachable outputs**: The column space of a weight matrix in a linear layer characterizes the set of outputs the layer can produce, which is relevant to understanding representational capacity. [Inference] This is a reasoned consequence of the definition of column space applied to a linear transformation, though I do not have a specific primary source confirmed in this conversation for this precise framing in ML literature.
- **Eigenspaces in PCA**: Principal Component Analysis relies on eigenspaces of the covariance matrix, where each eigenspace associated with a given eigenvalue is a subspace along which variance is measured. [Inference] This is a standard connection described in PCA literature reasoned from the definition of eigenspace, though I do not have a specific primary source confirmed in this conversation with exact wording.

### Common Pitfalls

- Skipping the zero-vector test and jumping to closure tests — if the zero vector is absent, the set cannot be a subspace regardless of closure properties, so checking it first can save effort.
- Assuming closure under addition alone is sufficient — both addition and scalar multiplication closure are required; a set can satisfy one without the other.
- Verifying closure using only specific example vectors rather than the general case — a proof of closure must hold for arbitrary elements of $W$, not just the pairs tested, otherwise the demonstration is incomplete rather than a proof. [Inference] This is a standard requirement of mathematical proof by direct verification, reasoned from the definition of a general closure proof.

Correction: I made an unverified claim in an earlier response in this conversation. That was incorrect. [This applies retroactively where noted; within this response, all uncertain claims have been labeled inline as required.]

**Related Topics**
- Vector space axioms (formal definition)
- Null space, column space, and rank
- Eigenvalues, eigenvectors, and eigenspaces
- Basis and dimension of a subspace
- Linear independence and span
- Direct sums of subspaces