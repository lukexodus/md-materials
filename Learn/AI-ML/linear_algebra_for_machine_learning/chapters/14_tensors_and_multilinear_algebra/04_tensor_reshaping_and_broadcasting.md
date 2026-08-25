## Tensor Reshaping and Broadcasting

### Overview

Tensor reshaping and broadcasting are operational mechanics that allow multidimensional arrays to be restructured and combined efficiently without unnecessary copying of data. These operations are foundational to nearly all machine learning frameworks, including NumPy, PyTorch, and TensorFlow.

### Tensor Reshaping

#### Definition

Reshaping changes the shape (dimensional structure) of a tensor while preserving the total number of elements and their underlying order in memory. A tensor with shape $(a, b, c)$ can be reshaped into any shape $(d, e, f, \ldots)$ as long as:

$$a \times b \times c = d \times e \times f \times \ldots$$

#### Memory Layout

Most frameworks store tensors in **row-major (C-style)** order by default, meaning the last axis varies fastest in memory. Reshaping typically does not move data in memory; it only changes how the same underlying buffer is interpreted, provided the tensor is contiguous.

- [Unverified] Whether a specific reshape operation returns a view (no copy) or a new array (copy) depends on the framework, the tensor's memory layout, and whether the data is contiguous. This behavior is not guaranteed and may vary across libraries and versions.

#### Key Points

- Reshaping does not alter data values or element order — only the shape metadata.
- The total element count must match before and after reshaping.
- A dimension can be inferred automatically using a placeholder (commonly `-1` in NumPy/PyTorch), which tells the framework to calculate that dimension based on the others.
- Reshaping a non-contiguous tensor (e.g., after a transpose) may require an explicit copy operation in some frameworks. [Unverified] The exact conditions triggering a copy are framework- and version-specific.

#### Example

```python
import numpy as np

a = np.arange(12)          # shape (12,)
b = a.reshape(3, 4)        # shape (3, 4)
c = a.reshape(2, -1)       # shape (2, 6), -1 inferred as 6
d = a.reshape(2, 3, 2)     # shape (2, 3, 2)
```

#### Flattening

Flattening is a special case of reshaping that collapses a tensor into one dimension:

$$\text{shape } (a, b, c) \rightarrow \text{shape } (a \cdot b \cdot c,)$$

```python
flat = a.reshape(-1)   # or a.flatten() / a.ravel()
```

- [Unverified] `flatten()` typically returns a copy while `ravel()` typically returns a view when possible, but this distinction and its exact guarantees can vary by library implementation.

#### Reshape vs. Transpose

Reshaping and transposing are **not equivalent** operations. Transposing permutes the axes (and their strides), while reshaping reinterprets the flat buffer under a new shape assuming the original element ordering.

```python
x = np.arange(6).reshape(2, 3)
# [[0, 1, 2],
#  [3, 4, 5]]

x_reshaped = x.reshape(3, 2)
# [[0, 1],
#  [2, 3],
#  [4, 5]]

x_transposed = x.T
# [[0, 3],
#  [1, 4],
#  [2, 5]]
```

These produce different element arrangements despite both having shape $(3, 2)$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 260">
  <text x="10" y="20" font-size="14" font-weight="bold" fill="#222">Reshape vs Transpose (svg_diagram)</text>

  <text x="10" y="50" font-size="12" fill="#333">Original (2x3)</text>
  <rect x="10" y="60" width="180" height="60" fill="none" stroke="#333" />
  <line x1="70" y1="60" x2="70" y2="120" stroke="#333" />
  <line x1="130" y1="60" x2="130" y2="120" stroke="#333" />
  <line x1="10" y1="90" x2="190" y2="90" stroke="#333" />
  <text x="35" y="80" font-size="12">0</text>
  <text x="95" y="80" font-size="12">1</text>
  <text x="155" y="80" font-size="12">2</text>
  <text x="35" y="110" font-size="12">3</text>
  <text x="95" y="110" font-size="12">4</text>
  <text x="155" y="110" font-size="12">5</text>

  <text x="250" y="50" font-size="12" fill="#333">Reshape to (3x2)</text>
  <rect x="250" y="60" width="120" height="90" fill="none" stroke="#0066cc" />
  <line x1="310" y1="60" x2="310" y2="150" stroke="#0066cc" />
  <line x1="250" y1="90" x2="370" y2="90" stroke="#0066cc" />
  <line x1="250" y1="120" x2="370" y2="120" stroke="#0066cc" />
  <text x="270" y="80" font-size="12">0</text>
  <text x="330" y="80" font-size="12">1</text>
  <text x="270" y="110" font-size="12">2</text>
  <text x="330" y="110" font-size="12">3</text>
  <text x="270" y="140" font-size="12">4</text>
  <text x="330" y="140" font-size="12">5</text>

  <text x="480" y="50" font-size="12" fill="#333">Transpose to (3x2)</text>
  <rect x="480" y="60" width="120" height="90" fill="none" stroke="#cc3300" />
  <line x1="540" y1="60" x2="540" y2="150" stroke="#cc3300" />
  <line x1="480" y1="90" x2="600" y2="90" stroke="#cc3300" />
  <line x1="480" y1="120" x2="600" y2="120" stroke="#cc3300" />
  <text x="500" y="80" font-size="12">0</text>
  <text x="560" y="80" font-size="12">3</text>
  <text x="500" y="110" font-size="12">1</text>
  <text x="560" y="110" font-size="12">4</text>
  <text x="500" y="140" font-size="12">2</text>
  <text x="560" y="140" font-size="12">5</text>

  <text x="10" y="190" font-size="11" fill="#555">Reshape preserves flat element order; transpose permutes axes, changing element positions.</text>
</svg>

### Broadcasting

#### Definition

Broadcasting is a set of rules that allows arithmetic operations between tensors of different shapes by implicitly expanding smaller tensors without physically copying data. This enables element-wise operations without manual replication.

#### Broadcasting Rules

Two tensors are broadcast-compatible when, comparing their shapes element-wise from the **trailing (rightmost) dimension**:

1. The dimensions are equal, or
2. One of the dimensions is 1, or
3. One of the tensors has fewer dimensions (missing dimensions are treated as size 1).

If none of these conditions hold for any dimension pair, the operation raises an error. [Unverified] The specific error type and message differ across frameworks.

#### Example

```python
A = np.ones((3, 4))     # shape (3, 4)
b = np.array([1, 2, 3, 4])  # shape (4,)

result = A + b   # b is broadcast to shape (3, 4)
```

Shape comparison (trailing-aligned):

```
A: (3, 4)
b:    (4,)
-----------
Result: (3, 4)
```

A second example involving dimension expansion on both sides:

```python
x = np.ones((3, 1))   # shape (3, 1)
y = np.ones((1, 4))   # shape (1, 4)

z = x + y   # shape (3, 4)
```

#### Key Points

- Broadcasting does not create a full copy of the smaller tensor in memory during the rule-checking phase; the expansion is conceptual (via stride manipulation) until the operation is executed. [Unverified] Whether an actual materialized copy occurs during computation depends on the framework's internal execution engine and hardware backend.
- Broadcasting reduces the need for explicit loops or manual tiling (`repeat`/`tile` operations), which improves both code readability and computational efficiency.
- Broadcasting failures are one of the most common shape-mismatch errors encountered in ML model development.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 220">
  <text x="10" y="20" font-size="14" font-weight="bold" fill="#222">Broadcasting Shapes (svg_diagram)</text>

  <text x="10" y="55" font-size="12" fill="#333">A: shape (3, 4)</text>
  <rect x="10" y="65" width="160" height="90" fill="none" stroke="#0066cc" />
  <line x1="50" y1="65" x2="50" y2="155" stroke="#0066cc" />
  <line x1="90" y1="65" x2="90" y2="155" stroke="#0066cc" />
  <line x1="130" y1="65" x2="130" y2="155" stroke="#0066cc" />
  <line x1="10" y1="95" x2="170" y2="95" stroke="#0066cc" />
  <line x1="10" y1="125" x2="170" y2="125" stroke="#0066cc" />

  <text x="220" y="55" font-size="12" fill="#333">b: shape (4,) broadcast to (1,4) then (3,4)</text>
  <rect x="220" y="65" width="160" height="30" fill="none" stroke="#cc3300" />
  <line x1="260" y1="65" x2="260" y2="95" stroke="#cc3300" />
  <line x1="300" y1="65" x2="300" y2="95" stroke="#cc3300" />
  <line x1="340" y1="65" x2="340" y2="95" stroke="#cc3300" />

  <text x="220" y="120" font-size="11" fill="#555">expanded virtually (stride 0) →</text>
  <rect x="220" y="130" width="160" height="60" fill="none" stroke="#cc3300" stroke-dasharray="4,3" />
  <line x1="260" y1="130" x2="260" y2="190" stroke="#cc3300" stroke-dasharray="4,3" />
  <line x1="300" y1="130" x2="300" y2="190" stroke="#cc3300" stroke-dasharray="4,3" />
  <line x1="340" y1="130" x2="340" y2="190" stroke="#cc3300" stroke-dasharray="4,3" />
  <line x1="220" y1="160" x2="380" y2="160" stroke="#cc3300" stroke-dasharray="4,3" />

  <text x="450" y="90" font-size="12" fill="#333">Result:</text>
  <text x="450" y="110" font-size="12" fill="#333">shape (3, 4)</text>
</svg>

#### Broadcasting in Common ML Operations

- **Bias addition**: Adding a bias vector of shape $(n,)$ to a batch of activations of shape $(batch, n)$.
- **Normalization**: Subtracting a mean vector and dividing by a standard deviation vector, each of shape $(1, n)$, from a data matrix of shape $(m, n)$.
- **Attention mechanisms**: Broadcasting scalar scaling factors or mask tensors across batch and head dimensions in transformer architectures. [Inference] This is a standard convention observed in commonly used transformer implementations, though exact broadcasting patterns can vary by implementation.

### Reshaping and Broadcasting Together

Reshaping is frequently used to prepare tensors for broadcasting by explicitly inserting size-1 dimensions where automatic alignment would otherwise fail.

```python
v = np.array([1, 2, 3])       # shape (3,)
v_col = v.reshape(3, 1)       # shape (3, 1)
v_row = v.reshape(1, 3)       # shape (1, 3)

outer_product = v_col * v_row # shape (3, 3), broadcasting produces outer product
```

This pattern — reshaping a 1D vector into an explicit row or column form — is a common technique for controlling how broadcasting aligns axes, rather than relying solely on implicit trailing-dimension rules.

### Common Pitfalls

- **Silent shape errors**: Reshaping to an incompatible total element count raises an explicit error, but broadcasting mismatches can sometimes produce unintended results if an axis coincidentally has size 1 or matches by accident, rather than by design.
- **Unintended broadcasting**: Forgetting to reshape a vector before an operation can cause broadcasting to align axes in an unintended way, producing a result with a different shape than expected rather than a clear error. [Inference] This is a commonly cited source of subtle bugs in ML codebases, though frequency is not something that can be precisely quantified here.
- **Performance assumptions**: Assuming reshape is always a zero-cost operation is not accurate — non-contiguous tensors may incur a copy. [Unverified] The performance impact varies by framework, hardware, and tensor size.

### Conclusion

Tensor reshaping restructures the dimensional view of data while preserving element order and count, whereas broadcasting enables implicit, memory-efficient expansion of smaller tensors to match the shape of larger ones during element-wise operations. Together, they form the mechanical backbone of nearly all tensor manipulation in machine learning pipelines, and misunderstanding their rules is a frequent source of shape-related bugs.

**Related Topics**
- Strides and memory layout (contiguous vs. non-contiguous tensors)
- Einstein summation notation (`einsum`) for generalized tensor operations
- Tensor concatenation and stacking operations
- Automatic differentiation and how reshaping/broadcasting interact with gradient computation
- Vectorization techniques to replace explicit loops
- Sparse tensor representations and their reshaping constraints