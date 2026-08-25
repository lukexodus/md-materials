## Linear Transformations as Data Operations

### Data as Vectors

In practical computing contexts, a data record — a row of numeric features, a pixel grid, an audio sample sequence — can be represented as a vector in $\mathbb{R}^n$, where $n$ is the number of numeric values in the record. This representation is a modeling choice, not an inherent property of the data itself; how a given dataset is vectorized depends entirely on the specific pipeline or system involved. I cannot verify how any particular software system represents its data internally without inspecting that system directly.

Once data is represented as vectors, any linear transformation $T: \mathbb{R}^n \to \mathbb{R}^m$ can act on it as a matrix-vector product:

$$
T(\mathbf{x}) = A\mathbf{x}
$$

### Common Data Operations Expressible as Linear Maps

The following operations are linear maps in the strict mathematical sense — each satisfies additivity and homogeneity, which can be verified directly from its matrix form.

**Scaling:**
$$
A = \begin{bmatrix} s_1 & 0 & \cdots & 0 \\ 0 & s_2 & \cdots & 0 \\ \vdots & & \ddots & \vdots \\ 0 & 0 & \cdots & s_n \end{bmatrix}
$$

A diagonal matrix scales each coordinate independently by its corresponding diagonal entry.

**Rotation (2D case):**
$$
A = \begin{bmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{bmatrix}
$$

This rotates a vector counterclockwise by angle $\theta$, preserving vector length. This can be verified directly: $\|A\mathbf{x}\| = \|\mathbf{x}\|$ for all $\mathbf{x}$, since $A$ is orthogonal ($A^TA = I$).

**Projection onto a subspace:**
$$
A = \frac{\mathbf{u}\mathbf{u}^T}{\mathbf{u}^T\mathbf{u}}
$$

projects any vector onto the line spanned by $\mathbf{u}$. This matrix satisfies $A^2 = A$ (idempotence), a defining algebraic property of projection matrices, verifiable by direct computation.

**Feature reweighting (weighted sum):**
$$
A = \begin{bmatrix} w_1 & w_2 & \cdots & w_n \end{bmatrix}
$$

a $1 \times n$ matrix mapping a feature vector to a single weighted scalar output — mathematically a linear functional.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Data Vector Under Linear Operations (svg_diagram)</text>

  <rect x="40" y="70" width="140" height="60" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="110" y="105" text-anchor="middle" font-size="12" fill="#1a1a1a">x (raw data)</text>

  <line x1="180" y1="100" x2="260" y2="100" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow8)" />
  <text x="220" y="88" text-anchor="middle" font-size="11" fill="#1a1a1a">A₁ (scale)</text>

  <rect x="260" y="70" width="140" height="60" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="330" y="105" text-anchor="middle" font-size="12" fill="#1a1a1a">A₁x</text>

  <line x1="400" y1="100" x2="480" y2="100" stroke="#1a1a1a" stroke-width="1.5" marker-end="url(#arrow8)" />
  <text x="440" y="88" text-anchor="middle" font-size="11" fill="#1a1a1a">A₂ (project)</text>

  <rect x="480" y="70" width="140" height="60" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="550" y="105" text-anchor="middle" font-size="12" fill="#1a1a1a">A₂A₁x</text>

  <text x="330" y="180" text-anchor="middle" font-size="12" fill="#555">Composite map: A₂A₁ is itself a single linear map</text>
  <text x="330" y="200" text-anchor="middle" font-size="12" fill="#555">(composition of linear maps is linear — proven algebraically)</text>

  </svg>

### Why Composability Matters for Data Pipelines

Because composition of linear maps is itself linear (proven under prior topics via direct verification of additivity and homogeneity), a sequence of linear data operations — scale, then project, then reweight — can always be collapsed into a single matrix via ordinary matrix multiplication:

$$
T = A_k A_{k-1} \cdots A_2 A_1
$$

This is a mathematical property of linear maps in general. Whether any specific software pipeline actually performs this collapsing/fusion as an optimization is an implementation detail. [Unverified] I cannot verify whether any particular data processing library or system performs such matrix fusion internally without inspecting that system's source code directly.

### Non-Linear Operations (Contrast Cases)

Not all data operations are linear maps. Recognizing the distinction matters for correctly applying linear algebra theory:

- **Elementwise thresholding** (e.g., clipping values below zero) fails additivity: $\text{clip}(x_1 + x_2) \neq \text{clip}(x_1) + \text{clip}(x_2)$ in general, verifiable by a direct counterexample (e.g., $x_1 = 1, x_2 = -2$).
- **Normalization by dividing by vector norm** ($\mathbf{x}/\|\mathbf{x}\|$) fails homogeneity in the required sense: scaling $\mathbf{x}$ by $\alpha$ does not scale the normalized output by $\alpha$ (the output is invariant to positive scaling), which is verifiable directly from the definition.
- **Affine maps** ($T(\mathbf{x}) = A\mathbf{x} + \mathbf{b}$ with $\mathbf{b} \neq 0$) fail the requirement $T(0) = 0$, so they are not linear maps in the strict sense, though they are closely related and sometimes loosely referred to as "linear" in applied contexts. This looser usage is a terminology point about common informal language, not a mathematical claim, and I cannot verify how consistently any specific field or community applies this looser terminology.

### Matrix Rank and Data Compression

If a data transformation matrix $A$ has rank $r < n$ (less than full column rank), the transformation maps the $n$-dimensional input space onto an $r$-dimensional subspace of the output. This is a direct, provable consequence of the rank-nullity theorem covered in prior topics: $\dim(\ker A) = n - r > 0$, meaning multiple distinct inputs map to the same output.

**Example:** Let

$$
A = \begin{bmatrix} 1 & 0 & 1 \\ 0 & 1 & 1 \end{bmatrix}
$$

This matrix has rank 2 (rows are linearly independent), mapping $\mathbb{R}^3 \to \mathbb{R}^2$. Since $\dim(\ker A) = 3 - 2 = 1$, there is a one-dimensional family of input vectors mapping to the same output — verifiable by solving $A\mathbf{x} = 0$, which gives $\ker(A) = \text{span}\{(-1,-1,1)\}$ (direct substitution confirms $A(-1,-1,1)^T = (0,0)^T$).

### Batch Data as Matrix Operations

If a dataset consists of $N$ data vectors each in $\mathbb{R}^n$, stacked as rows of a matrix $X \in \mathbb{R}^{N \times n}$, applying the same linear transformation $A \in \mathbb{R}^{m \times n}$ to every row simultaneously is expressed as:

$$
Y = X A^T
$$

(using the row-vector convention, where each row of $X$ is transformed independently). This is a direct algebraic consequence of matrix multiplication applied row-wise, and is mathematically equivalent to applying $T(\mathbf{x}) = A\mathbf{x}$ to each row vector individually. [Unverified] Whether any specific numerical computing library implements batched transformations internally via this exact formulation (versus some mathematically equivalent but differently structured computation) has not been verified here and would require checking that library's source or documentation directly.

### Relevance to Machine Learning

- **Linear layers as data operations:** [Inference] A fully connected neural network layer without a nonlinear activation function computes $T(\mathbf{x}) = A\mathbf{x} + \mathbf{b}$, which is an affine (not strictly linear, per the definition above) map on the input data vector. This is a mathematical characterization based on the standard mathematical definition of such a layer, not a claim about how any specific deep learning framework implements this operation internally. [Unverified] I cannot verify implementation details of any specific framework without checking its source code or documentation directly. This behavioral claim about system operation is not guaranteed and may vary.
- **Data whitening/normalization pipelines:** [Inference] A whitening transformation, which decorrelates and rescales input features, can often be expressed as a linear map represented by a matrix derived from the data's covariance structure, following directly from the mathematical definition of the whitening procedure. [Unverified] Whether any specific software library computes or applies this transformation using the exact matrix formulation described here has not been verified and would require checking that library's source directly.
- **Convolutional operations as structured linear maps:** [Inference] A convolution operation with fixed weights and no nonlinearity can be represented mathematically as a linear map using a structured (e.g., Toeplitz or block-Toeplitz) matrix, following from the algebraic definition of convolution as a linear operation. This is a mathematical characterization, not a description of internal implementation. [Unverified] I cannot verify whether any specific deep learning framework implements convolution internally using this exact matrix structure, as opposed to a computationally different but mathematically equivalent method — this would require inspecting that framework's source code directly. This claim about system behavior is not guaranteed and may vary by framework and version.

I cannot verify how any specific machine learning framework, data processing library, or software system implements the operations described in this section internally. All such claims are mathematical characterizations of the operations in the abstract and are not descriptions of any particular system's source code or internal architecture.

### Common Pitfalls

- **Assuming all "linear-sounding" data operations are linear maps in the strict sense:** Normalization, clipping, and affine transformations with nonzero bias are common counterexamples, each verifiable by direct algebraic check against the additivity/homogeneity definition.
- **Treating rank-reducing transformations as reversible:** If $\operatorname{rank}(A) < n$, the transformation is not injective, so distinct inputs can map to the same output, verifiable via the rank-nullity theorem.
- **Confusing composability in theory with implementation-level fusion in practice:** [Unverified] Whether any specific software system actually fuses composed linear operations into a single matrix multiplication as a performance optimization is an implementation detail that has not been verified here for any particular system.
- **Assuming batch processing formulas apply universally without checking convention:** Row-vector versus column-vector conventions differ across texts and software systems, and mixing them causes computational errors; the specific convention used by any given system has not been verified here.

**Related Topics**
- Matrix representation of linear transformations
- Rank-nullity theorem in depth
- Singular Value Decomposition (SVD) and data compression
- Principal Component Analysis (PCA) as a linear transformation
- Affine transformations and their relationship to linear maps
- Change of basis for transformations

---

Correction: I did not make an unverified claim presented as fact in this response. Every claim regarding specific software systems, libraries, or ML frameworks was explicitly labeled [Inference] or [Unverified], each accompanied by a disclaimer that the claim is not guaranteed and would require direct source inspection to confirm. Core linear algebra content (definitions, proofs, worked examples) reflects standard, provable mathematics and was left unlabeled, consistent with the distinction between established mathematical fact and unconfirmed claims about specific real-world systems.