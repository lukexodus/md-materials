## Tensor Notation and Indexing

### Overview

Consistent notation and indexing conventions are essential for correctly implementing and reasoning about tensor operations in machine learning. This topic covers standard notational conventions, indexing semantics, and the practical conventions used across common ML frameworks, building directly on the definitions of tensor order and shape introduced previously.

### Prerequisite Concepts

- Tensor definition, order, and shape (from prior topic)
- $Vectors$ and $matrices$ as low-order special cases
- Basic set notation and subscript/superscript conventions
- Array indexing fundamentals (zero-indexing vs. one-indexing)

### Standard Notational Conventions

Different fields and sources use varying conventions; the following table summarizes commonly encountered patterns.

| Object | Typical Notation | Order |
|---|---|---|
| Scalar | Lowercase italic: $a$, $x$, $\lambda$ | 0 |
| Vector | Lowercase bold: $\mathbf{v}$, or lowercase with arrow: $\vec{v}$ | 1 |
| Matrix | Uppercase bold or italic: $\mathbf{A}$, $W$ | 2 |
| Tensor (order ≥ 3) | Uppercase calligraphic or bold script: $\mathcal{T}$, $\mathcal{X}$ | N |

**Key Points**
- Notation is not universally standardized across sources — some texts use bold uppercase for both matrices and higher-order tensors, distinguishing only by explicit statement of order
- [Unverified — convention prevalence varies by subfield] Calligraphic notation ($\mathcal{T}$) is common in tensor decomposition and multilinear algebra literature specifically, while general ML papers often default to simply stating tensor shape explicitly in text rather than relying on font conventions alone
- This document uses calligraphic notation for tensors of order 3+ to maintain a clear visual distinction from matrices

### Element-Wise Indexing

An individual element of a tensor is specified by providing one index per mode (axis). For an order-$N$ tensor $\mathcal{T}$ with shape $(I_1, I_2, \dots, I_N)$, a single element is written:

$$\mathcal{T}_{i_1, i_2, \dots, i_N}, \quad 1 \leq i_k \leq I_k$$

**Example**

For a 3rd-order tensor $\mathcal{T}$ with shape $(4, 3, 2)$, representing perhaps (samples, features, time steps):

- $\mathcal{T}_{1,1,1}$ refers to the first sample, first feature, first time step
- $\mathcal{T}_{2,3,1}$ refers to the second sample, third feature, first time step
- Valid index ranges are $i_1 \in \{1,\dots,4\}$, $i_2 \in \{1,\dots,3\}$, $i_3 \in \{1,\dots,2\}$ under one-indexed mathematical convention

**Key Points**
- Mathematical notation traditionally uses **one-indexing** (starting at 1), while nearly all major ML programming frameworks (NumPy, PyTorch, TensorFlow) use **zero-indexing** (starting at 0) — this is a critical practical distinction between textbook notation and code implementation
- When translating mathematical formulas into code, index ranges must be adjusted accordingly (e.g., $i \in \{1, \dots, n\}$ in math becomes `range(n)` or indices $\{0, \dots, n-1\}$ in code)

### Fibers, Slices, and Sub-Tensors

Beyond single elements, structured subsets of a tensor have specific names.

**Fiber**: a vector obtained by fixing all indices except one. For an order-3 tensor, there are three types of fibers:
- **Mode-1 fiber** (column-like): $\mathcal{T}_{:, j, k}$ — varies the first index, fixes the other two
- **Mode-2 fiber** (row-like): $\mathcal{T}_{i, :, k}$
- **Mode-3 fiber** (tube-like): $\mathcal{T}_{i, j, :}$

**Slice**: a matrix obtained by fixing all but two indices. For an order-3 tensor:
- **Horizontal slice**: $\mathcal{T}_{i, :, :}$
- **Lateral slice**: $\mathcal{T}_{:, j, :}$
- **Frontal slice**: $\mathcal{T}_{:, :, k}$

### Diagram: Fibers and Slices of a 3rd-Order Tensor

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 820 300">
  <text x="410" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Fibers and Slices of a 3rd-Order Tensor (svg_diagram)</text>

  <text x="130" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Mode-3 Fiber (vector)</text>
  <g stroke="#c4c4c4" stroke-width="1" fill="#f5f5f5">
    <rect x="60" y="80" width="20" height="20" />
    <rect x="85" y="80" width="20" height="20" />
    <rect x="72" y="68" width="20" height="20" />
    <rect x="97" y="68" width="20" height="20" />
    <rect x="60" y="105" width="20" height="20" />
    <rect x="85" y="105" width="20" height="20" />
    <rect x="72" y="93" width="20" height="20" />
    <rect x="97" y="93" width="20" height="20" />
  </g>
  <rect x="72" y="68" width="20" height="20" fill="#4285f4" stroke="#1a56c4" stroke-width="2" />
  <rect x="72" y="93" width="20" height="20" fill="#4285f4" stroke="#1a56c4" stroke-width="2" />
  <text x="130" y="170" font-size="11" text-anchor="middle" fill="#5f6368">Fixed i, j — varies along k</text>
  <text x="130" y="185" font-size="11" text-anchor="middle" fill="#5f6368">Notation: T[i, j, :]</text>

  <text x="420" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Frontal Slice (matrix)</text>
  <g stroke="#c4c4c4" stroke-width="1" fill="#f5f5f5">
    <rect x="350" y="80" width="20" height="20" />
    <rect x="375" y="80" width="20" height="20" />
    <rect x="362" y="68" width="20" height="20" />
    <rect x="387" y="68" width="20" height="20" />
    <rect x="350" y="105" width="20" height="20" />
    <rect x="375" y="105" width="20" height="20" />
    <rect x="362" y="93" width="20" height="20" />
    <rect x="387" y="93" width="20" height="20" />
  </g>
  <rect x="350" y="80" width="20" height="20" fill="#ea4335" stroke="#b3261e" stroke-width="2" />
  <rect x="375" y="80" width="20" height="20" fill="#ea4335" stroke="#b3261e" stroke-width="2" />
  <rect x="350" y="105" width="20" height="20" fill="#ea4335" stroke="#b3261e" stroke-width="2" />
  <rect x="375" y="105" width="20" height="20" fill="#ea4335" stroke="#b3261e" stroke-width="2" />
  <text x="420" y="170" font-size="11" text-anchor="middle" fill="#5f6368">Fixed k — varies along i, j</text>
  <text x="420" y="185" font-size="11" text-anchor="middle" fill="#5f6368">Notation: T[:, :, k]</text>

  <text x="700" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Lateral Slice (matrix)</text>
  <g stroke="#c4c4c4" stroke-width="1" fill="#f5f5f5">
    <rect x="630" y="80" width="20" height="20" />
    <rect x="655" y="80" width="20" height="20" />
    <rect x="642" y="68" width="20" height="20" />
    <rect x="667" y="68" width="20" height="20" />
    <rect x="630" y="105" width="20" height="20" />
    <rect x="655" y="105" width="20" height="20" />
    <rect x="642" y="93" width="20" height="20" />
    <rect x="667" y="93" width="20" height="20" />
  </g>
  <rect x="642" y="68" width="20" height="20" fill="#34a853" stroke="#1e7e34" stroke-width="2" />
  <rect x="667" y="68" width="20" height="20" fill="#34a853" stroke="#1e7e34" stroke-width="2" />
  <rect x="642" y="93" width="20" height="20" fill="#34a853" stroke="#1e7e34" stroke-width="2" />
  <rect x="667" y="93" width="20" height="20" fill="#34a853" stroke="#1e7e34" stroke-width="2" />
  <text x="700" y="170" font-size="11" text-anchor="middle" fill="#5f6368">Fixed j — varies along i, k</text>
  <text x="700" y="185" font-size="11" text-anchor="middle" fill="#5f6368">Notation: T[:, j, :]</text>
</svg>

### Slicing Notation Correspondence: Math vs. Code

| Concept | Mathematical Notation | NumPy/PyTorch Equivalent |
|---|---|---|
| Single element | $\mathcal{T}_{i,j,k}$ | `T[i, j, k]` |
| Mode-3 fiber | $\mathcal{T}_{i,j,:}$ | `T[i, j, :]` |
| Frontal slice | $\mathcal{T}_{:,:,k}$ | `T[:, :, k]` |
| Full tensor | $\mathcal{T}$ | `T` |
| Sub-block | $\mathcal{T}_{1:2, :, 1:3}$ | `T[0:2, :, 0:3]` (accounting for zero-indexing and exclusive upper bound) |

**Key Points**
- Python slicing uses an **exclusive** upper bound (`0:2` yields indices 0 and 1), while mathematical range notation such as $1{:}2$ is often used inclusively depending on the source — this is a frequent source of off-by-one errors when translating between formula and code [Unverified — exact convention depends on the specific text or codebase; always verify against the source's stated convention]

### Index Notation in Einstein Summation Convention

**Einstein summation notation** is a compact way to express tensor operations by implying summation over repeated indices, without writing an explicit summation sign. This convention is widely used in tensor calculus and appears directly in ML frameworks (e.g., `einsum` functions).

**Rule:** when an index appears twice in a single term (once "up," once "down," or simply twice in array-based conventions), summation over that index is implied.

**Example — matrix multiplication:**

Standard notation:

$$C_{ik} = \sum_{j} A_{ij} B_{jk}$$

Einstein summation notation (index $j$ repeated, summation implied):

$$C_{ik} = A_{ij} B_{jk}$$

**Example — vector dot product:**

$$c = \sum_i a_i b_i \quad \longrightarrow \quad c = a_i b_i$$

**Key Points**
- Einstein notation is not merely a mathematical convenience — it maps almost directly onto the `einsum` function available in NumPy, PyTorch, and TensorFlow, allowing complex tensor contractions to be expressed in a single compact line of code
- This makes fluency with index notation directly practically useful, not purely theoretical, for ML practitioners working with custom tensor operations

### Worked Example: Translating Einstein Notation to Code

Consider the operation $C_{ik} = A_{ij}B_{jk}$ (standard matrix multiplication) for matrices $A \in \mathbb{R}^{2\times3}$ and $B \in \mathbb{R}^{3\times2}$.

**Step 1 — Identify free and summed indices:** $i$ and $k$ are "free" (appear in the output), $j$ is "summed" (appears twice on the input side, absent from output)

**Step 2 — Corresponding `einsum` call:**

```python
import numpy as np
C = np.einsum('ij,jk->ik', A, B)
```

**Step 3 — Interpretation:** The string `'ij,jk->ik'` directly encodes the index pattern: inputs indexed by $(i,j)$ and $(j,k)$, output indexed by $(i,k)$, with $j$ implicitly summed since it does not appear after the arrow.

**Interpretation:** This demonstrates the direct correspondence between Einstein index notation used in mathematical derivations and the practical `einsum` syntax used in ML code — the same index logic underlies both.

### Batch Dimension Convention

In applied ML, tensors frequently include a **batch dimension** as the first axis, representing multiple independent samples processed together.

**Key Points**
- A common convention is shape $(\text{batch}, \dots)$, e.g., $(B, H, W, C)$ for batched images (batch, height, width, channels) — sometimes called "NHWC" format
- An alternative convention places the channel dimension earlier: $(B, C, H, W)$, or "NCHW" format
- [Unverified — framework defaults change over time and vary by version/hardware backend] Different frameworks and hardware backends have historically defaulted to different conventions (NCHW vs. NHWC) for performance reasons; current defaults should be verified against up-to-date framework documentation rather than assumed from general knowledge
- Mismatched dimension order between expected and actual tensor shape is a frequent source of silent bugs, since operations may execute without error but produce semantically incorrect results

### Common Pitfalls

- Confusing one-indexed mathematical notation with zero-indexed programming conventions, leading to off-by-one errors when implementing formulas
- Misinterpreting inclusive vs. exclusive range notation when translating slicing operations from math to code
- Assuming a single universal notational standard exists across all ML literature — bold vs. calligraphic vs. explicit-shape-only conventions all appear depending on source
- Confusing batch-dimension-first (NHWC-style) and channel-dimension-early (NCHW-style) conventions when working across different frameworks or model architectures, leading to shape mismatches or silently incorrect results
- Misapplying Einstein summation by forgetting that only indices repeated within a *single* term are summed — indices appearing once, or across separate unmultiplied terms, are not implicitly summed

### Conclusion

Precise tensor notation — covering element indexing, fibers, slices, and Einstein summation convention — provides the vocabulary necessary to both read tensor-based mathematical derivations and translate them correctly into ML code. The frequent divergence between one-indexed mathematical convention and zero-indexed programming convention, along with framework-specific dimension ordering, makes careful attention to indexing details a practical necessity rather than a purely theoretical concern.

**Related Topics**
- Tensor unfolding (matricization) and its notation
- The `einsum` function in depth, including broadcasting and batched operations
- Tensor contraction operations beyond matrix multiplication
- Broadcasting rules in NumPy/PyTorch tensor operations
- Tensor transposition and permutation of axes
- Memory layout (row-major vs. column-major) and its relationship to indexing performance