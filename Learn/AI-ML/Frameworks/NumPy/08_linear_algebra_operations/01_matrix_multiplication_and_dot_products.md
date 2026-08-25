## Matrix Multiplication and Dot Products


**Key Points**
Matrix multiplication in NumPy can be performed using multiple methods, each with specific use cases and performance characteristics. The choice of method depends on the dimensionality of arrays, desired broadcasting behavior, and computational requirements.

**Basic Dot Products and Matrix Multiplication**
```python
import numpy as np

# Vector dot product
a = np.array([1, 2, 3])
b = np.array([4, 5, 6])
dot_product = np.dot(a, b)  # Output: 32
# Alternative: a @ b or np.inner(a, b)

# Matrix-vector multiplication
matrix = np.array([[1, 2, 3],
                   [4, 5, 6]])
vector = np.array([1, 2, 3])
result = np.dot(matrix, vector)  # Output: [14, 32]
result = matrix @ vector  # Equivalent using @ operator
```

**Matrix-Matrix Multiplication**
```python
A = np.array([[1, 2],
              [3, 4]])
B = np.array([[5, 6],
              [7, 8]])

# Standard matrix multiplication
C = np.dot(A, B)  # Output: [[19, 22], [43, 50]]
C = A @ B  # Equivalent using @ operator
C = np.matmul(A, B)  # Explicit matrix multiplication

# Element-wise multiplication (different operation)
element_wise = A * B  # Output: [[5, 12], [21, 32]]
```

**Multi-Dimensional Array Operations**
```python
# Batch matrix multiplication
batch_A = np.random.rand(5, 3, 4)  # 5 matrices of shape (3, 4)
batch_B = np.random.rand(5, 4, 2)  # 5 matrices of shape (4, 2)
batch_result = np.matmul(batch_A, batch_B)  # Shape: (5, 3, 2)

# Broadcasting in matrix multiplication
A = np.random.rand(3, 4)
B = np.random.rand(10, 4, 5)
result = A @ B  # Broadcasting: (3, 4) @ (10, 4, 5) -> (10, 3, 5)
```

**Specialized Dot Product Operations**
```python
# Inner product (sum of element-wise products)
inner = np.inner(a, b)  # Same as dot for 1D arrays

# Outer product
outer = np.outer(a, b)  # Shape: (3, 3)

# Tensor dot product with axis specification
A = np.random.rand(3, 4, 5)
B = np.random.rand(4, 6, 7)
result = np.tensordot(A, B, axes=([1], [0]))  # Contract over axis 1 of A and axis 0 of B
```

**Performance Considerations**
The `@` operator and `np.matmul` are generally preferred over `np.dot` for matrix multiplication as they provide clearer semantics and better performance optimization. These methods also handle multi-dimensional broadcasting more predictably.

