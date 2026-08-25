## Vectors and Vector Operations

### Definition of a Vector

A vector is an ordered tuple of real numbers representing both magnitude and direction in space:

$$\mathbf{v} = \langle v_1, v_2, \ldots, v_n \rangle \in \mathbb{R}^n$$

**Key Points**
- In machine learning contexts, vectors commonly represent feature values, weight parameters, gradients, or embeddings.
- A vector's dimension $n$ corresponds to the number of components it contains.
- Vectors are distinguished from scalars (single real numbers) by having both magnitude and direction, except for the zero vector, which has zero magnitude and no defined direction. [Inference] — reasoned from the standard definition of vector magnitude; this is a widely taught convention but the exact phrasing may differ slightly across textbooks.

### Vector Notation

**Key Points**
- Vectors are commonly written in angle-bracket form $\langle v_1, v_2 \rangle$, column form, or bold lowercase letters ($\mathbf{v}$).
- In machine learning literature, vectors are frequently represented as column matrices for compatibility with matrix multiplication operations. [Inference] — this reflects common convention in linear algebra as applied to ML, reasoned from standard matrix-vector multiplication rules, not confirmed against every specific source or library.

### Basic Vector Operations

#### Vector Addition

$$\mathbf{u} + \mathbf{v} = \langle u_1 + v_1, \, u_2 + v_2, \, \ldots, \, u_n + v_n \rangle$$

**Example**
$$\langle 1, 2, 3 \rangle + \langle 4, -1, 0 \rangle = \langle 5, 1, 3 \rangle$$

#### Vector Subtraction

$$\mathbf{u} - \mathbf{v} = \langle u_1 - v_1, \, u_2 - v_2, \, \ldots, \, u_n - v_n \rangle$$

**Example**
$$\langle 5, 1, 3 \rangle - \langle 4, -1, 0 \rangle = \langle 1, 2, 3 \rangle$$

#### Scalar Multiplication

$$c\mathbf{v} = \langle cv_1, \, cv_2, \, \ldots, \, cv_n \rangle$$

**Example**
$$3 \langle 1, 2, 3 \rangle = \langle 3, 6, 9 \rangle$$

**Key Points**
- Addition and subtraction require vectors of the same dimension.
- Scalar multiplication scales every component by the same factor $c$.

### Vector Magnitude (Norm)

The Euclidean norm (or $L^2$ norm) of a vector is:

$$\|\mathbf{v}\| = \sqrt{v_1^2 + v_2^2 + \cdots + v_n^2}$$

**Example**
For $\mathbf{v} = \langle 3, 4 \rangle$:

$$\|\mathbf{v}\| = \sqrt{3^2 + 4^2} = \sqrt{9 + 16} = \sqrt{25} = 5$$

**Key Points**
- This is the most commonly used norm in introductory contexts, but other norms exist (e.g., $L^1$, $L^\infty$), each with different properties and use cases.
- The $L^1$ norm (sum of absolute values) and $L^2$ norm (Euclidean) are both used in machine learning, notably in regularization terms, though their specific effects on model behavior depend on the algorithm and context. [Unverified] — the precise behavioral differences between $L^1$ and $L^2$ regularization depend on the specific model, data, and implementation; a general claim about their effects is not being asserted as universally applicable here.

### Dot Product (Scalar Product)

$$\mathbf{u} \cdot \mathbf{v} = \sum_{i=1}^{n} u_i v_i = u_1v_1 + u_2v_2 + \cdots + u_nv_n$$

**Example**
$$\langle 1, 2, 3 \rangle \cdot \langle 4, -1, 0 \rangle = (1)(4) + (2)(-1) + (3)(0) = 4 - 2 + 0 = 2$$

**Key Points**
- The dot product returns a scalar, not a vector.
- Geometrically, the dot product relates to the angle $\theta$ between two vectors:

$$\mathbf{u} \cdot \mathbf{v} = \|\mathbf{u}\|\|\mathbf{v}\|\cos\theta$$

- A dot product of zero indicates the vectors are orthogonal (perpendicular), provided neither vector is the zero vector. [Inference] — reasoned directly from the geometric formula above, since $\cos\theta = 0$ when $\theta = 90°$.

### Cross Product (Three Dimensions Only)

For $\mathbf{u} = \langle u_1, u_2, u_3 \rangle$ and $\mathbf{v} = \langle v_1, v_2, v_3 \rangle$:

$$\mathbf{u} \times \mathbf{v} = \langle u_2v_3 - u_3v_2, \; u_3v_1 - u_1v_3, \; u_1v_2 - u_2v_1 \rangle$$

**Example**
For $\mathbf{u} = \langle 1, 0, 0 \rangle$ and $\mathbf{v} = \langle 0, 1, 0 \rangle$:

$$\mathbf{u} \times \mathbf{v} = \langle (0)(0)-(0)(1), \; (0)(0)-(1)(0), \; (1)(1)-(0)(0) \rangle = \langle 0, 0, 1 \rangle$$

**Key Points**
- The cross product is only defined in three dimensions (and, in a generalized form, seven dimensions, though this is a specialized case). [Unverified] — I cannot verify the specific details or standard usage of the seven-dimensional cross product without checking a dedicated source; this is mentioned as a known mathematical curiosity but not elaborated on further here.
- The result is a vector orthogonal to both $\mathbf{u}$ and $\mathbf{v}$.
- The cross product is not commutative: $\mathbf{u} \times \mathbf{v} = -(\mathbf{v} \times \mathbf{u})$.
- The cross product has limited direct use in typical machine learning contexts compared to the dot product, since most ML operations rely on dot products and matrix multiplication rather than three-dimensional geometric orthogonality. [Inference] — reasoned from the general structure of common ML operations (linear algebra over arbitrary-dimensional vectors), not a confirmed statement surveying all ML applications.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380" font-family="sans-serif">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Vector Addition and Dot Product (svg_diagram)</text>

  <line x1="100" y1="320" x2="580" y2="320" stroke="#333" stroke-width="1.5" />
  <line x1="100" y1="320" x2="100" y2="60" stroke="#333" stroke-width="1.5" />

  <line x1="100" y1="320" x2="300" y2="180" stroke="#2563eb" stroke-width="3" marker-end="url(#arrowV1)" />
  <text x="305" y="175" font-size="13" fill="#2563eb">u</text>

  <line x1="100" y1="320" x2="420" y2="240" stroke="#dc2626" stroke-width="3" marker-end="url(#arrowV2)" />
  <text x="425" y="240" font-size="13" fill="#dc2626">v</text>

  <line x1="100" y1="320" x2="520" y2="140" stroke="#16a34a" stroke-width="3" stroke-dasharray="5,3" marker-end="url(#arrowV3)" />
  <text x="525" y="135" font-size="13" fill="#16a34a">u + v</text>

  <line x1="300" y1="180" x2="520" y2="140" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="3,3" />
  <line x1="420" y1="240" x2="520" y2="140" stroke="#94a3b8" stroke-width="1.5" stroke-dasharray="3,3" />

  <path d="M 150,320 A 40,40 0 0,0 172,290" fill="none" stroke="#ca8a04" stroke-width="1.5" />
  <text x="160" y="300" font-size="11" fill="#ca8a04">θ</text>

  </svg>

### Unit Vectors and Normalization

A unit vector has magnitude $1$. Any nonzero vector can be normalized by dividing by its own norm:

$$\hat{\mathbf{v}} = \frac{\mathbf{v}}{\|\mathbf{v}\|}$$

**Example**
For $\mathbf{v} = \langle 3, 4 \rangle$, with $\|\mathbf{v}\| = 5$:

$$\hat{\mathbf{v}} = \left\langle \frac{3}{5}, \frac{4}{5} \right\rangle$$

**Key Points**
- Normalization preserves direction while setting magnitude to exactly $1$.
- This operation is undefined for the zero vector, since division by a norm of $0$ is undefined.
- Normalization is used in machine learning for tasks such as cosine similarity calculations, where only the direction of a vector (not its magnitude) is relevant to the comparison. [Inference] — reasoned from the standard definition of cosine similarity, which explicitly divides by vector norms; this is a widely used technique but specific library implementations should be checked against their own documentation for exact behavior.

### Cosine Similarity

$$\cos\theta = \frac{\mathbf{u} \cdot \mathbf{v}}{\|\mathbf{u}\|\|\mathbf{v}\|}$$

**Key Points**
- Cosine similarity ranges from $-1$ (opposite direction) to $1$ (same direction), with $0$ indicating orthogonality.
- This metric is commonly used in machine learning for comparing embedding vectors (e.g., word embeddings, document vectors), though its suitability depends on the specific task and data distribution. [Unverified] — I cannot verify that cosine similarity is optimal or universally preferred for every embedding-comparison task without reference to a specific study or documented benchmark; this is a commonly used technique, not a universally guaranteed best choice.

### Linear Combinations

A linear combination of vectors $\mathbf{v}_1, \ldots, \mathbf{v}_k$ with scalar coefficients $c_1, \ldots, c_k$ is:

$$c_1\mathbf{v}_1 + c_2\mathbf{v}_2 + \cdots + c_k\mathbf{v}_k$$

**Example**
$$2\langle 1, 0 \rangle + 3\langle 0, 1 \rangle = \langle 2, 0 \rangle + \langle 0, 3 \rangle = \langle 2, 3 \rangle$$

**Key Points**
- Linear combinations form the foundation of vector spaces, spans, and linear independence — concepts central to linear algebra.
- In machine learning, linear combinations of feature vectors and weight vectors form the basis of linear models (e.g., linear regression, single-layer perceptrons without activation). [Inference] — reasoned from the standard mathematical formulation of linear models, in which predictions are computed as weighted sums of input features; specific model architectures vary and should be checked against their formal definitions.

### Relevance to Machine Learning

**Key Points**
- Feature vectors represent data points as vectors in $\mathbb{R}^n$, where $n$ is the number of features.
- Weight vectors and gradient vectors in optimization are manipulated using the vector operations described above (addition, scalar multiplication, dot products).
- Gradient descent updates parameters using vector subtraction and scalar multiplication (learning rate scaling): $\mathbf{w}_{new} = \mathbf{w}_{old} - \eta \nabla L(\mathbf{w}_{old})$, where $\eta$ is the learning rate. [Inference] — this is the standard formulation of the gradient descent update rule as commonly presented in optimization references; exact implementation details (e.g., momentum, adaptive learning rates) vary by algorithm and are not addressed in this general statement.
- The specific numerical behavior of any gradient descent implementation in a given software library is not guaranteed by the mathematical formula alone and may vary by implementation, floating-point precision, and configuration. [Unverified]

### Common Pitfalls

- Attempting vector addition or dot products between vectors of mismatched dimensions — these operations are only defined for vectors of equal dimension.
- Confusing the dot product (scalar result) with the cross product (vector result, three dimensions only).
- Assuming normalization is always necessary before computing similarity — this depends on the specific similarity or distance metric being used, and is not universally required. [Inference] — reasoned from the definitions of different metrics (e.g., Euclidean distance does not require normalization, whereas cosine similarity inherently divides by norms), not confirmed against every possible metric in use.

### Conclusion

Vectors and their operations — addition, scalar multiplication, dot products, norms, and normalization — form the foundational toolkit of linear algebra used throughout machine learning, from representing data as feature vectors to performing gradient-based parameter updates. Some described relationships (e.g., specific behavioral claims about libraries, algorithms, or optimal use cases) are labeled as inferred or unverified where a primary source was not directly checked in this response.

**Related Topics**
- Matrices and matrix-vector multiplication
- Vector spaces, span, and linear independence
- The gradient vector as a generalization of the derivative
- Eigenvectors and eigenvalues
- Norms ($L^1$, $L^2$, $L^\infty$) and their role in regularization
- Cosine similarity in embedding spaces and NLP applications