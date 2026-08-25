## Hadamard Product

### Definition

The Hadamard product, denoted $\odot$ or sometimes $*$, is the element-wise multiplication of two matrices or tensors of identical shape. For matrices $A$ and $B$ of size $(m, n)$:

$$(A \odot B)_{ij} = a_{ij} \cdot b_{ij}$$

The resulting matrix $A \odot B$ has the same dimensions $(m, n)$ as the two operands.

### Key Points

- Unlike standard matrix multiplication, the Hadamard product requires both operands to have exactly the same shape, or shapes that are compatible via broadcasting.
- It is commutative: $A \odot B = B \odot A$.
- It is associative: $(A \odot B) \odot C = A \odot (B \odot C)$.
- It is distributive over addition: $A \odot (B + C) = A \odot B + A \odot C$.
- The identity element for the Hadamard product is a matrix of all ones of matching shape, not the identity matrix used in standard matrix multiplication.

### Example

$$A = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}, \quad B = \begin{bmatrix} 5 & 6 \\ 7 & 8 \end{bmatrix}$$

$$A \odot B = \begin{bmatrix} 1\cdot5 & 2\cdot6 \\ 3\cdot7 & 4\cdot8 \end{bmatrix} = \begin{bmatrix} 5 & 12 \\ 21 & 32 \end{bmatrix}$$

```python
import numpy as np

A = np.array([[1, 2],
              [3, 4]])
B = np.array([[5, 6],
              [7, 8]])

result = A * B   # NumPy's default * operator performs Hadamard product
```

- [Unverified] The exact operator symbol used for the Hadamard product (`*` vs. a dedicated function) differs across libraries and versions; NumPy's `*` operator behavior described above reflects standard elementwise semantics, but syntax should be confirmed against the specific library documentation in use.

### Distinction from Matrix Multiplication

The Hadamard product is fundamentally different from standard (dot-product-based) matrix multiplication:

| Operation | Symbol | Shape Requirement | Result |
|---|---|---|---|
| Hadamard product | $\odot$ | Identical shapes (or broadcastable) | Element-wise product, same shape |
| Matrix multiplication | (none, or $\cdot$) | Inner dimensions must match | Row-by-column dot products, new shape |

```python
A = np.array([[1, 2],
              [3, 4]])
B = np.array([[5, 6],
              [7, 8]])

hadamard = A * B        # element-wise
matmul = A @ B           # standard matrix multiplication
```

These two operations generally produce different numeric results even when both are defined for the same pair of square matrices.

### Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 220">
  <text x="10" y="20" font-size="14" font-weight="bold" fill="#222">Hadamard Product: Element-wise Multiplication (svg_diagram)</text>

  <text x="10" y="55" font-size="12" fill="#333">A</text>
  <rect x="10" y="65" width="80" height="80" fill="none" stroke="#0066cc" />
  <line x1="50" y1="65" x2="50" y2="145" stroke="#0066cc" />
  <line x1="10" y1="105" x2="90" y2="105" stroke="#0066cc" />
  <text x="25" y="90" font-size="12">1</text>
  <text x="60" y="90" font-size="12">2</text>
  <text x="25" y="130" font-size="12">3</text>
  <text x="60" y="130" font-size="12">4</text>

  <text x="110" y="105" font-size="16">⊙</text>

  <text x="140" y="55" font-size="12" fill="#333">B</text>
  <rect x="140" y="65" width="80" height="80" fill="none" stroke="#cc3300" />
  <line x1="180" y1="65" x2="180" y2="145" stroke="#cc3300" />
  <line x1="140" y1="105" x2="220" y2="105" stroke="#cc3300" />
  <text x="155" y="90" font-size="12">5</text>
  <text x="190" y="90" font-size="12">6</text>
  <text x="155" y="130" font-size="12">7</text>
  <text x="190" y="130" font-size="12">8</text>

  <text x="240" y="105" font-size="16">=</text>

  <text x="270" y="55" font-size="12" fill="#333">Result</text>
  <rect x="270" y="65" width="80" height="80" fill="none" stroke="#009933" />
  <line x1="310" y1="65" x2="310" y2="145" stroke="#009933" />
  <line x1="270" y1="105" x2="350" y2="105" stroke="#009933" />
  <text x="280" y="90" font-size="12">5</text>
  <text x="320" y="90" font-size="12">12</text>
  <text x="280" y="130" font-size="12">21</text>
  <text x="315" y="130" font-size="12">32</text>

  <text x="10" y="180" font-size="11" fill="#555">Each output entry is the product of the corresponding entries in A and B (same position).</text>
</svg>

### Applications in Machine Learning

- **Gating mechanisms**: Recurrent architectures such as LSTMs and GRUs use the Hadamard product to apply learned gate values (typically outputs of sigmoid activations, ranging between 0 and 1) element-wise to hidden states or candidate values, controlling how much information passes through. [Inference] This is a widely documented pattern in the original LSTM and GRU formulations, though exact gating implementations can vary across specific model variants.
- **Masking**: Attention masks, dropout masks, and padding masks are commonly applied to tensors using the Hadamard product, zeroing out or scaling specific elements without altering tensor shape.
- **Backpropagation through activation functions**: The chain rule applied to element-wise activation functions (such as ReLU or sigmoid) during backpropagation typically involves a Hadamard product between the upstream gradient and the local derivative of the activation function.
- **Regularization and pruning**: Element-wise multiplication with a binary or continuous mask is a common mechanism in structured and unstructured pruning techniques to zero out specific weights. [Inference] This is a general pattern observed across pruning literature, though specific pruning algorithms differ in how masks are computed and applied.

### Relationship to Broadcasting

The Hadamard product is often combined with broadcasting rules when operand shapes are not identical but are broadcast-compatible:

```python
A = np.ones((3, 4))
b = np.array([1, 2, 3, 4])   # shape (4,)

result = A * b   # b is broadcast to (3, 4), then Hadamard product applied
```

This combination is extremely common in practice, since exact shape matches are less frequent than broadcastable shape pairs in real ML pipelines.

### Relationship to the Kronecker Product

The Hadamard product and Kronecker product are distinct operations often introduced together for contrast:

- Hadamard product: requires identical shapes, produces a result of the same shape.
- Kronecker product: works on matrices of any shape, produces a much larger block-structured result.

There is a known identity connecting the two through the diagonal extraction operator, though this is a more specialized algebraic relationship. [Unverified] The precise form and conditions of this identity depend on the specific formulation and are not restated here without direct verification against a primary reference.

### Computational Considerations

- The Hadamard product has the same computational complexity as basic element-wise operations: $O(mn)$ for an $(m,n)$ matrix, since each output element requires exactly one multiplication.
- It is highly parallelizable and maps efficiently onto vectorized hardware instructions (SIMD, GPU kernels), which is part of why gating and masking mechanisms built on it are computationally inexpensive relative to matrix multiplication. [Inference] This reflects general characteristics of element-wise operations on modern hardware, though actual performance depends on specific hardware, framework implementation, and tensor size, and no specific benchmark is asserted here.

### Conclusion

The Hadamard product performs element-wise multiplication between tensors of matching (or broadcast-compatible) shape and is algebraically simpler than standard matrix multiplication. It plays a central role in gating mechanisms, masking, and gradient computation throughout machine learning architectures.

**Related Topics**
- Kronecker product (contrast in structure and shape requirements)
- Broadcasting rules and their interaction with element-wise operations
- Gating mechanisms in LSTM and GRU architectures
- Chain rule and gradient computation in backpropagation
- Masking techniques in attention mechanisms and dropout regularization