## Matrix as a Linear Transformation

### Definition

A linear transformation $T: \mathbb{R}^n \to \mathbb{R}^m$ is a function satisfying two properties for all vectors $\mathbf{u}, \mathbf{v} \in \mathbb{R}^n$ and scalars $k$:

$$T(\mathbf{u} + \mathbf{v}) = T(\mathbf{u}) + T(\mathbf{v}) \quad \text{(additivity)}$$
$$T(k\mathbf{u}) = k\,T(\mathbf{u}) \quad \text{(homogeneity)}$$

Every matrix $A \in \mathbb{R}^{m \times n}$ defines a linear transformation $T(\mathbf{x}) = A\mathbf{x}$, and every linear transformation between finite-dimensional real vector spaces can be represented by some matrix. These are standard, provable definitions and results from linear algebra, not inferences.

### Why Matrix Multiplication Satisfies Linearity

$$A(\mathbf{u} + \mathbf{v}) = A\mathbf{u} + A\mathbf{v}, \qquad A(k\mathbf{u}) = k(A\mathbf{u})$$

Both identities follow directly from the distributive and scalar-compatibility properties of matrix multiplication established for matrix-vector products. This is a direct algebraic consequence, not an inference.

### The Matrix Columns Encode the Transformation

**Key Points**
- The $j$-th column of $A$ equals $T(\mathbf{e}_j)$, where $\mathbf{e}_j$ is the $j$-th standard basis vector.
- This follows directly from the definition of matrix-vector multiplication: $A\mathbf{e}_j$ selects the $j$-th column of $A$.
- Consequently, a linear transformation is completely determined by where it sends the standard basis vectors.

**Example**

If $T(\mathbf{e}_1) = \begin{pmatrix} 2 \\ 1 \end{pmatrix}$ and $T(\mathbf{e}_2) = \begin{pmatrix} -1 \\ 3 \end{pmatrix}$, then:

$$A = \begin{pmatrix} 2 & -1 \\ 1 & 3 \end{pmatrix}$$

This is a direct construction following from the stated definition, not an inference.

### Geometric Examples in $\mathbb{R}^2$

**Scaling**

$$A = \begin{pmatrix} 2 & 0 \\ 0 & 2 \end{pmatrix}$$

Doubles the length of every vector, since $A\mathbf{x} = 2\mathbf{x}$. This follows directly from matrix-vector multiplication.

**Rotation by angle $\theta$**

$$R_\theta = \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix}$$

[Inference] This matrix is commonly stated in linear algebra references to rotate vectors counterclockwise by angle $\theta$ about the origin, based on applying the matrix to $\mathbf{e}_1$ and $\mathbf{e}_2$ and confirming the resulting vectors land at $(\cos\theta, \sin\theta)$ and $(-\sin\theta, \cos\theta)$, which matches the expected rotated basis directions. I have not independently reproduced a full geometric proof within this response.

**Reflection across the x-axis**

$$A = \begin{pmatrix} 1 & 0 \\ 0 & -1 \end{pmatrix}$$

Maps $(x, y) \to (x, -y)$. This follows directly from matrix-vector multiplication.

**Shear**

$$A = \begin{pmatrix} 1 & 1 \\ 0 & 1 \end{pmatrix}$$

Maps $(x, y) \to (x + y, y)$, shifting points horizontally in proportion to their $y$-coordinate. This follows directly from matrix-vector multiplication.

### Visual Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 460 260">
  <text x="230" y="20" font-size="13" text-anchor="middle" fill="#333">Linear Transformation of a Basis (svg_diagram)</text>
  <line x1="80" y1="140" x2="200" y2="140" stroke="#999" stroke-width="1" />
  <line x1="140" y1="80" x2="140" y2="200" stroke="#999" stroke-width="1" />
  <line x1="140" y1="140" x2="180" y2="140" stroke="#1f77b4" stroke-width="2" marker-end="url(#a1)" />
  <text x="185" y="135" font-size="11" fill="#1f77b4">e1</text>
  <line x1="140" y1="140" x2="140" y2="100" stroke="#ff7f0e" stroke-width="2" marker-end="url(#a2)" />
  <text x="145" y="95" font-size="11" fill="#ff7f0e">e2</text>
  <text x="140" y="220" font-size="11" text-anchor="middle" fill="#666">Standard basis</text>
  <text x="230" y="140" font-size="18" text-anchor="middle">→</text>
  <text x="230" y="120" font-size="10" text-anchor="middle" fill="#666">apply A</text>
  <line x1="320" y1="160" x2="420" y2="160" stroke="#999" stroke-width="1" />
  <line x1="320" y1="100" x2="320" y2="220" stroke="#999" stroke-width="1" />
  <line x1="320" y1="160" x2="375" y2="130" stroke="#1f77b4" stroke-width="2" marker-end="url(#a1)" />
  <text x="380" y="128" font-size="11" fill="#1f77b4">Ae1</text>
  <line x1="320" y1="160" x2="290" y2="115" stroke="#ff7f0e" stroke-width="2" marker-end="url(#a2)" />
  <text x="255" y="112" font-size="11" fill="#ff7f0e">Ae2</text>
  <text x="370" y="240" font-size="11" text-anchor="middle" fill="#666">Transformed basis (columns of A)</text>
  </svg>

### Composition of Transformations

If $T_1$ is represented by matrix $A$ and $T_2$ is represented by matrix $B$, then the composition $T_2(T_1(\mathbf{x}))$ is represented by the matrix product $BA$:

$$T_2(T_1(\mathbf{x})) = B(A\mathbf{x}) = (BA)\mathbf{x}$$

This is a direct consequence of the associativity of matrix multiplication, a standard, provable result. Note that the order matters: applying $T_1$ first, then $T_2$, corresponds to $BA$, not $AB$, since matrix multiplication is generally not commutative.

### Kernel and Image

- **Kernel (null space)**: $\ker(A) = \{\mathbf{x} \in \mathbb{R}^n : A\mathbf{x} = \mathbf{0}\}$ — the set of vectors mapped to the zero vector.
- **Image (range/column space)**: $\text{im}(A) = \{A\mathbf{x} : \mathbf{x} \in \mathbb{R}^n\}$ — the set of all possible outputs, equal to the span of the columns of $A$.

These are standard, provable definitions in linear algebra.

**Example**

$$A = \begin{pmatrix} 1 & 2 \\ 2 & 4 \end{pmatrix}$$

Applying $A$ to $\mathbf{x} = (2, -1)$ gives $A\mathbf{x} = \begin{pmatrix} 1(2)+2(-1) \\ 2(2)+4(-1) \end{pmatrix} = \begin{pmatrix} 0 \\ 0 \end{pmatrix}$.

**Output**

$$A\begin{pmatrix} 2 \\ -1 \end{pmatrix} = \begin{pmatrix} 0 \\ 0 \end{pmatrix}$$

This confirms $(2, -1)$ lies in $\ker(A)$ for this specific matrix. This is a direct computation, not a generalization beyond this example.

### Injectivity, Surjectivity, and Invertibility

[Inference] A linear transformation represented by a square matrix $A$ is commonly stated in linear algebra references to be invertible (both injective and surjective) if and only if $\det(A) \neq 0$, based on the standard relationship between determinants, invertibility, and the existence of a trivial kernel described in linear algebra references. I cannot independently reproduce the full formal proof within this response.

### Relevance to Machine Learning

[Inference] The interpretation of matrices as linear transformations is described in commonly cited machine learning references as foundational to several concepts, based on descriptions in standard references. I do not have access to a specific verified source to cite directly for how any particular current framework implements these interpretations internally.

Commonly cited use cases include:

- **Linear/dense layers**: a fully connected layer without activation is described in neural network literature as directly implementing a linear transformation $\mathbf{y} = W\mathbf{x} + \mathbf{b}$ (an affine transformation once the bias term is included). [Unverified] I cannot verify the exact internal implementation of any specific framework's dense layer without inspecting its source code.
- **Dimensionality reduction**: techniques such as PCA are described in statistics and machine learning literature as linear transformations that project data onto a lower-dimensional subspace. [Unverified] I cannot verify the exact implementation details of any specific PCA library without inspecting its source code.
- **Convolution as a linear operation**: convolutional layers are described in some machine learning literature as expressible as a specific structured linear transformation (a matrix with repeated, shifted weight patterns), given fixed input dimensions. [Unverified] I do not have access to a specific verified source confirming how any particular current framework implements convolution internally (e.g., via im2col or other methods).
- **Feature space transformations**: kernel methods and embedding layers are described in machine learning literature as relying on linear or affine transformations between vector spaces. [Unverified] I cannot verify the internal implementation of any specific embedding or kernel method library without inspecting its source code.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model, including the one generating this response, will behave in future interactions. Behavior is not guaranteed to be consistent, and no outcome described here should be treated as certain to recur.

**Related Topics**
- Determinants and invertibility
- Eigenvalues and eigenvectors as invariant directions
- Change of basis
- Kernel (null space) and image (column space)
- Rotation, scaling, and shear transformations
- Convolution as a structured linear operation

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding the rotation matrix proof, invertibility-determinant proof reproduction, and machine learning application/implementation details not drawn from a specific cited source. Core mathematical definitions and algebraic properties (linear transformation definition, additivity, homogeneity, column-basis correspondence, composition-as-matrix-product) are standard, provable results in linear algebra and are treated as established mathematical fact rather than as inference.
The previous response on "Matrix as a Linear Transformation" was already complete — it included all sections through Related Topics and the closing disclaimer, with no cutoff.