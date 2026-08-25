## NumPy Array Operations


**ndarray** serves as the foundational data structure for numerical computing in Python, providing homogeneous multidimensional arrays with efficient storage and vectorized operations. NumPy arrays store elements of the same data type in contiguous memory blocks, enabling fast mathematical computations through optimized C and Fortran libraries.

**Array creation** supports multiple methods including explicit construction, range generation, and special matrices. The `dtype` parameter controls memory usage and numerical precision, while shape manipulation allows flexible data organization. Broadcasting rules enable operations between arrays of different shapes without explicit loops.

**Key Points:**

- Memory-efficient storage with homogeneous data types
- Vectorized operations eliminate explicit Python loops
- Broadcasting enables operations on differently-shaped arrays
- Universal functions (ufuncs) provide element-wise operations
- Linear algebra operations through optimized BLAS/LAPACK libraries

**Example:**

```python
import numpy as np

# Array creation methods
arr1 = np.array([1, 2, 3, 4, 5])
arr2 = np.arange(0, 10, 2)
arr3 = np.linspace(0, 1, 100)
arr4 = np.zeros((3, 4))
arr5 = np.random.normal(0, 1, (1000,))

# Broadcasting and vectorized operations
matrix = np.random.random((5, 3))
row_means = matrix.mean(axis=1)  # Shape: (5,)
centered = matrix - row_means[:, np.newaxis]  # Broadcasting

# Advanced indexing and slicing
mask = arr5 > 0
positive_values = arr5[mask]
arr5[arr5 < -2] = -2  # Clip outliers

# Linear algebra operations
A = np.random.random((100, 50))
B = np.random.random((50, 25))
C = A @ B  # Matrix multiplication
eigenvals, eigenvecs = np.linalg.eig(A.T @ A)
```

**Mathematical operations** leverage optimized implementations for common computations including trigonometric functions, logarithms, and statistical measures. Reduction operations along specified axes enable flexible data aggregation, while universal functions apply element-wise transformations efficiently.

**Advanced indexing** supports boolean masking, fancy indexing with integer arrays, and multi-dimensional slicing. These techniques enable complex data selection and modification patterns without explicit iteration. Structured arrays provide record-like functionality for heterogeneous data types.

