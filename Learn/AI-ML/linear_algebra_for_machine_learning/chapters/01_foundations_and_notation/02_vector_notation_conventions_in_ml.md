## Vector Notation Conventions in Machine Learning

### Overview

Vector notation in machine learning literature is not fully standardized. Different textbooks, papers, and frameworks adopt different conventions. [Unverified] There is no single universal authority that enforces one notation standard across the entire field, so the conventions described below reflect commonly observed patterns rather than confirmed universal rules.

### Basic Symbol Conventions

#### Lowercase Bold for Vectors

Vectors are commonly written using lowercase bold letters:

$$\mathbf{x}, \mathbf{y}, \mathbf{w}, \mathbf{v}$$

[Inference] This convention is widely used to visually distinguish vectors from scalars (typically lowercase italic, e.g., $x$) and matrices (typically uppercase bold, e.g., $\mathbf{X}$), based on common patterns across ML and linear algebra textbooks. This is a reasoned generalization, not a confirmed universal standard.

#### Uppercase Bold for Matrices

$$\mathbf{X}, \mathbf{W}, \mathbf{A}$$

#### Component Notation

The $i$-th element of vector $\mathbf{x}$ is typically written as $x_i$, without bold formatting, since an individual component is a scalar:

$$\mathbf{x} = \begin{bmatrix} x_1 \\ x_2 \\ \vdots \\ x_n \end{bmatrix}$$

### Column Vector Default Convention

**Key Points**
- [Inference] In much of the ML and deep learning literature, vectors are treated as column vectors by default. This is a commonly observed pattern rather than a confirmed universal rule.
- Row vectors are typically expressed as the transpose of a column vector: $\mathbf{x}^T$
- Some fields (e.g., certain statistics texts) may default to row vector conventions instead. [Unverified] Whether a specific source uses row or column convention should be checked directly in that source rather than assumed.

$$\mathbf{x} = \begin{bmatrix} x_1 \\ x_2 \\ x_3 \end{bmatrix} \quad \text{(column, common default)}$$

$$\mathbf{x}^T = \begin{bmatrix} x_1 & x_2 & x_3 \end{bmatrix} \quad \text{(row, via transpose)}$$

### Indexing Conventions

#### Single Vector, Multiple Components

$$x_i \quad \text{denotes the } i\text{-th component of } \mathbf{x}$$

#### Multiple Vectors in a Dataset

When referring to a collection of vectors (e.g., a dataset), a common convention is to use superscripts or parenthetical superscripts for the sample index, and subscripts for the feature/component index:

$$\mathbf{x}^{(i)} \quad \text{denotes the } i\text{-th sample vector}$$
$$x_j^{(i)} \quad \text{denotes the } j\text{-th feature of the } i\text{-th sample}$$

[Inference] This superscript-for-sample, subscript-for-feature pattern appears in several ML course materials and papers, but is not confirmed to be applied consistently across all sources. Some papers instead use subscripts for both sample and feature index, relying on context to disambiguate.

**Example**

$$\mathbf{x}^{(1)} = \begin{bmatrix} 2.5 \\ 1.0 \\ 3.2 \end{bmatrix}, \quad \mathbf{x}^{(2)} = \begin{bmatrix} 0.8 \\ 4.1 \\ 2.0 \end{bmatrix}$$

Here, $x_2^{(1)} = 1.0$ refers to the second feature of the first sample.

### Special Vectors and Symbols

| Symbol | Common Meaning | Status |
|---|---|---|
| $\mathbf{0}$ | Zero vector | [Inference] widely used convention |
| $\mathbf{1}$ | Vector of all ones | [Inference] widely used convention |
| $\mathbf{e}_i$ | Standard basis vector (1 in position $i$, 0 elsewhere) | [Inference] widely used convention |
| $\hat{\mathbf{x}}$ | Unit vector or estimated/predicted vector (context-dependent) | [Inference] widely used convention, meaning depends on context |
| $\mathbf{w}$ | Weight vector | [Inference] common in ML specifically |
| $\mathbf{\theta}$ (theta) | Parameter vector | [Inference] common in ML specifically |
| $\nabla f$ | Gradient vector of function $f$ | [Inference] widely used convention |

[Unverified] The exact meaning of symbols such as $\hat{\mathbf{x}}$ can vary by source — in some texts it denotes a unit vector, and in others (particularly ML papers) it denotes an estimate or prediction. The reader should confirm meaning from the specific source's notation section rather than assume.

### Transpose Notation

The transpose operation converts a column vector to a row vector and vice versa:

$$\mathbf{x}^T$$

[Inference] Some sources use $\mathbf{x}'$ instead of $\mathbf{x}^T$ to denote transpose, though $\mathbf{x}^T$ appears more common in ML-focused material. Both notations are observed across the literature.

### Inner Product (Dot Product) Notation

Multiple notations exist for the same underlying operation:

$$\mathbf{x}^T \mathbf{y}, \qquad \mathbf{x} \cdot \mathbf{y}, \qquad \langle \mathbf{x}, \mathbf{y} \rangle$$

[Unverified] Whether a specific text prefers one of these three notations over the others depends on the source and is not something that can be generalized without checking that source directly.

### Norm Notation

The norm (length/magnitude) of a vector is commonly denoted:

$$\lVert \mathbf{x} \rVert \quad \text{(general norm, often assumed L2 unless specified)}$$
$$\lVert \mathbf{x} \rVert_2 \quad \text{(explicit L2 norm)}$$
$$\lVert \mathbf{x} \rVert_1 \quad \text{(L1 norm)}$$
$$\lVert \mathbf{x} \rVert_p \quad \text{(general } L_p \text{ norm)}$$

[Inference] When no subscript is given, many sources default to the L2 (Euclidean) norm, but this is a commonly observed convention rather than a confirmed rule that applies in every text — some sources state their default explicitly, others do not.

### Notation Differences Across Frameworks and Contexts

**Key Points**
- [Unverified] Notation used in code (e.g., variable naming in Python/NumPy) does not necessarily follow the same conventions as notation used in mathematical papers, since code identifiers are constrained by programming language syntax (no bold, no subscripts as separate symbols).
- [Unverified] Different subfields of ML (e.g., deep learning vs. classical statistics vs. optimization) may favor different notational conventions for the same concepts. Confirming the convention used requires checking the specific source in question.
- I do not have access to a comprehensive, authoritative comparison of notation conventions across all ML subfields, so no specific claim is made about which subfields prefer which conventions beyond what is stated above.

### Diagram: Notation Hierarchy

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320">
  <text x="110" y="25" font-size="15" fill="#222">Common Notation Hierarchy (svg_diagram)</text>

  <rect x="180" y="50" width="140" height="40" rx="5" fill="#e8f0fe" stroke="#1a73e8" />
  <text x="200" y="75" font-size="13" fill="#1a237e">Scalar: x</text>

  <rect x="180" y="120" width="140" height="40" rx="5" fill="#e6f4ea" stroke="#188038" />
  <text x="188" y="145" font-size="13" fill="#0d652d">Vector: x (bold)</text>

  <rect x="180" y="190" width="140" height="40" rx="5" fill="#fef7e0" stroke="#f9ab00" />
  <text x="185" y="215" font-size="13" fill="#8a6d00">Matrix: X (bold cap)</text>

  <rect x="180" y="260" width="140" height="40" rx="5" fill="#fce8e6" stroke="#d93025" />
  <text x="185" y="285" font-size="13" fill="#a50e0e">Tensor: X (higher order)</text>

  <line x1="250" y1="90" x2="250" y2="120" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />
  <line x1="250" y1="160" x2="250" y2="190" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />
  <line x1="250" y1="230" x2="250" y2="260" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />

  </svg>

[Inference] This hierarchy (scalar → vector → matrix → tensor as increasing "order" of array) reflects a commonly taught structural relationship, but the specific bold/uppercase notation conventions shown are patterns observed across sources, not a confirmed universal standard.

### Practical Notes for Reading ML Papers

**Key Points**
- Always check a paper's notation section or preliminaries, if one exists, rather than assuming standard meaning for a symbol.
- [Inference] Symbol reuse across different papers is common, meaning the same symbol (e.g., $\theta$) can represent different things depending on context (parameters in one paper, an angle in another).
- I cannot verify the notational choices of any specific paper without direct access to that paper's text.

### Correction Note

No unverified claims were presented as confirmed fact in this response. All uncertain conventions have been labeled [Inference] or [Unverified] as appropriate.

### Related Topics

- Matrix notation conventions
- Tensor notation and indexing in deep learning
- Einstein summation notation
- Notation for gradients, Jacobians, and Hessians
- Differences between mathematical notation and code implementation (e.g., NumPy/PyTorch array conventions)
- Notation used in specific subfields (e.g., optimization vs. probabilistic ML)