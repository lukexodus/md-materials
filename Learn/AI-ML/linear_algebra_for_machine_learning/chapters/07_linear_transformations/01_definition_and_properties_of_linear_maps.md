## Linear Maps: Definition and Properties

### Definition

Let $V$ and $W$ be vector spaces over the same field $F$. A function $T: V \to W$ is a **linear map** (or **linear transformation**) if for all $u, v \in V$ and all scalars $\alpha \in F$:

**Additivity:**
$$
T(u + v) = T(u) + T(v)
$$

**Homogeneity:**
$$
T(\alpha v) = \alpha T(v)
$$

These two conditions combine into a single equivalent condition:

$$
T(\alpha u + \beta v) = \alpha T(u) + \beta T(v)
$$

for all scalars $\alpha, \beta \in F$. This equivalence is a standard algebraic fact, provable directly from the two-part definition.

### Immediate Consequences

**Zero maps to zero:**
$$
T(0_V) = 0_W
$$

This follows because $T(0_V) = T(0 \cdot v) = 0 \cdot T(v) = 0_W$ for any $v$.

**Preservation of negatives:**
$$
T(-v) = -T(v)
$$

**Preservation of linear combinations:**
$$
T\left(\sum_{i=1}^n \alpha_i v_i\right) = \sum_{i=1}^n \alpha_i T(v_i)
$$

This generalizes additivity and homogeneity to arbitrary finite linear combinations, provable by induction.

### Matrix Representation

If $V = F^n$ and $W = F^m$, every linear map $T: F^n \to F^m$ can be represented by an $m \times n$ matrix $A$, such that:

$$
T(v) = Av
$$

The columns of $A$ are the images of the standard basis vectors:

$$
A = \begin{bmatrix} T(e_1) & T(e_2) & \cdots & T(e_n) \end{bmatrix}
$$

**Example:** Let $T: \mathbb{R}^2 \to \mathbb{R}^2$ be defined by $T(x, y) = (2x + y, \, x - y)$.

Check additivity: $T((x_1,y_1) + (x_2,y_2)) = T(x_1+x_2, y_1+y_2) = (2(x_1+x_2) + (y_1+y_2), \, (x_1+x_2) - (y_1+y_2))$, which equals $T(x_1,y_1) + T(x_2,y_2)$ by direct expansion. So $T$ is linear.

Its matrix representation:
$$
A = \begin{bmatrix} 2 & 1 \\ 1 & -1 \end{bmatrix}
$$

### Kernel and Image

**Kernel (null space):**
$$
\ker(T) = \{v \in V : T(v) = 0_W\}
$$

$\ker(T)$ is a subspace of $V$.

**Image (range):**
$$
\operatorname{im}(T) = \{T(v) : v \in V\}
$$

$\operatorname{im}(T)$ is a subspace of $W$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 300">
  <text x="310" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Kernel and Image of a Linear Map (svg_diagram)</text>

  <rect x="40" y="70" width="180" height="180" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="130" y="60" text-anchor="middle" font-size="13" fill="#1a1a1a">V</text>

  <ellipse cx="130" cy="180" rx="55" ry="40" fill="#c2d6ff" stroke="#3b5bdb" stroke-width="1" />
  <text x="130" y="185" text-anchor="middle" font-size="11" fill="#1a1a1a">ker(T)</text>
  <circle cx="130" cy="180" r="3" fill="#1a1a1a" />
  <text x="140" y="180" font-size="10" fill="#1a1a1a">0</text>

  <line x1="220" y1="150" x2="400" y2="150" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow2)" />
  <text x="300" y="140" font-size="13" fill="#1a1a1a">T</text>

  <rect x="400" y="50" width="180" height="200" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="490" y="40" text-anchor="middle" font-size="13" fill="#1a1a1a">W</text>

  <ellipse cx="490" cy="150" rx="70" ry="55" fill="#ffe0b0" stroke="#c4712f" stroke-width="1" />
  <text x="490" y="155" text-anchor="middle" font-size="11" fill="#1a1a1a">im(T)</text>
  <circle cx="490" cy="150" r="3" fill="#1a1a1a" />
  <text x="500" y="150" font-size="10" fill="#1a1a1a">0</text>

  </svg>

### Rank-Nullity Theorem

For a linear map $T: V \to W$ with $V$ finite-dimensional:

$$
\dim(V) = \dim(\ker(T)) + \dim(\operatorname{im}(T))
$$

The term $\dim(\ker(T))$ is called the **nullity**, and $\dim(\operatorname{im}(T))$ is called the **rank**. This theorem is a direct consequence of the First Isomorphism Theorem applied to $V/\ker(T) \cong \operatorname{im}(T)$, combined with the quotient space dimension formula $\dim(V/\ker T) = \dim V - \dim \ker T$.

### Injectivity, Surjectivity, and the Kernel

- $T$ is **injective** (one-to-one) if and only if $\ker(T) = \{0\}$.
- $T$ is **surjective** (onto) if and only if $\operatorname{im}(T) = W$.
- $T$ is a **bijection** (isomorphism) if and only if both hold, which — combined with rank-nullity — requires $\dim(V) = \dim(W)$ when both spaces are finite-dimensional.

The injectivity criterion follows from linearity: if $T(u) = T(v)$, then $T(u-v) = 0$, so $u - v \in \ker(T)$. If $\ker(T) = \{0\}$, this forces $u = v$.

### Composition of Linear Maps

If $T: V \to W$ and $S: W \to U$ are linear maps, the composition $S \circ T: V \to U$ is also linear:

$$
(S \circ T)(v) = S(T(v))
$$

In matrix terms, if $T$ corresponds to matrix $A$ and $S$ corresponds to matrix $B$, then $S \circ T$ corresponds to the matrix product $BA$.

### Types of Linear Maps

**Isomorphism:** A bijective linear map. If one exists between $V$ and $W$, the spaces are structurally identical ("isomorphic"), meaning every vector space property that depends only on linear structure is shared between them.

**Endomorphism:** A linear map $T: V \to V$ (domain and codomain are the same space).

**Automorphism:** A bijective endomorphism.

**Linear functional:** A linear map $T: V \to F$, mapping into the underlying field itself (a special case where $W = F$, viewed as a 1-dimensional vector space over itself).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Types of Linear Maps (svg_diagram)</text>

  <rect x="40" y="60" width="220" height="80" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="150" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Linear Map</text>
  <text x="150" y="115" text-anchor="middle" font-size="11" fill="#555">T: V → W</text>

  <rect x="340" y="20" width="220" height="60" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="450" y="45" text-anchor="middle" font-size="12" fill="#1a1a1a">Isomorphism</text>
  <text x="450" y="62" text-anchor="middle" font-size="10" fill="#555">bijective, V ≅ W</text>

  <rect x="340" y="100" width="220" height="60" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="450" y="125" text-anchor="middle" font-size="12" fill="#1a1a1a">Endomorphism</text>
  <text x="450" y="142" text-anchor="middle" font-size="10" fill="#555">T: V → V</text>

  <rect x="340" y="180" width="220" height="60" rx="8" fill="#fbe4f0" stroke="#c43b8a" stroke-width="1.5" />
  <text x="450" y="205" text-anchor="middle" font-size="12" fill="#1a1a1a">Linear Functional</text>
  <text x="450" y="222" text-anchor="middle" font-size="10" fill="#555">T: V → F</text>

  <line x1="260" y1="100" x2="340" y2="50" stroke="#888" stroke-width="1" />
  <line x1="260" y1="100" x2="340" y2="130" stroke="#888" stroke-width="1" />
  <line x1="260" y1="100" x2="340" y2="210" stroke="#888" stroke-width="1" />
</svg>

### Linear Maps and Change of Basis

If $B_1$ and $B_2$ are two bases for $V$, and $[T]_{B_1}$ is the matrix of $T$ relative to $B_1$, then the matrix relative to $B_2$ is related by a **similarity transformation**:

$$
[T]_{B_2} = P^{-1} [T]_{B_1} P
$$

where $P$ is the change-of-basis matrix from $B_2$ to $B_1$. This relationship underlies eigenvalue decomposition and diagonalization, since similar matrices share the same eigenvalues, trace, and determinant.

### Relevance to Machine Learning

- **Neural network layers:** A fully connected layer without a nonlinearity/bias is precisely a linear map, represented by a weight matrix. [Inference] The composition of multiple such layers without nonlinearities is itself a single linear map, since composition of linear maps is linear — this is a mathematical consequence of the definitions above, not a claim about any specific framework's internal implementation.
- **Feature transformations:** Techniques such as PCA use linear maps (projections) to transform data into a new coordinate system.
- **Convolution operations:** [Inference] A convolution with fixed weights can be expressed as a linear map represented by a structured (e.g., Toeplitz or circulant) matrix, though this is a mathematical characterization and not a description of how any specific library implements convolution internally. [Unverified] Whether a specific deep learning framework's convolution implementation is literally structured as matrix multiplication internally depends on that framework's source code, which has not been checked here.

I cannot verify implementation-level details of specific ML libraries or frameworks without consulting their source code or documentation directly.

### Common Pitfalls

- **Confusing linear maps with affine maps:** A map of the form $T(v) = Av + b$ with $b \neq 0$ is *affine*, not linear — it fails $T(0) = 0$ unless $b = 0$.
- **Assuming all matrix-representable operations are linear:** Only operations satisfying additivity and homogeneity qualify; elementwise nonlinear functions (e.g., ReLU) are not linear maps.
- **Conflating rank with matrix size:** Rank is the dimension of the image, which can be strictly less than the number of rows or columns.

**Related Topics**
- Eigenvalues, eigenvectors, and diagonalization
- Matrix representations and change of basis in depth
- Dual spaces and dual maps
- Singular Value Decomposition (SVD) as a structured linear map
- Linear functionals and the dual basis
- Adjoint and transpose operators

---

Correction: this response contains no unverified factual claims about confirmed sources, but two points were explicitly marked [Inference] and [Unverified] regarding ML framework internals, since those cannot be confirmed without checking specific source code. All core linear algebra content (definitions, theorems, matrix representations) reflects standard, provable mathematics and is not speculative.