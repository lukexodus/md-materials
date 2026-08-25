## Tensor Operations


Tensor operations in NumPy encompass mathematical computations that respect the multidimensional structure of arrays, including linear algebra operations, tensor contractions, and advanced mathematical transformations that operate across multiple dimensions simultaneously.

Matrix operations extend naturally to tensor operations through functions like numpy.tensordot, which performs generalized matrix multiplication across specified axes. This operation enables computation of tensor contractions, batch matrix multiplications, and complex linear algebra operations on multidimensional arrays.

Einstein summation (numpy.einsum) provides a powerful notation system for expressing complex tensor operations using Einstein's summation convention. This function enables specification of arbitrary tensor contractions, transpositions, and reductions using compact string notation that describes index relationships.

Tensor decomposition and analysis utilize NumPy's linear algebra capabilities extended to multidimensional contexts. Operations include singular value decomposition of matrix collections, eigenvalue computations across tensor slices, and norm calculations along specified dimensions.

Advanced tensor operations include outer products between multidimensional arrays, tensor products that combine arrays along new dimensions, and kronecker products that create structured tensor patterns from smaller tensor components.

**Example:**

```python
# Batch matrix operations
batch_matrices = np.random.rand(100, 5, 5)  # 100 matrices of size 5x5
batch_vectors = np.random.rand(100, 5, 1)   # 100 column vectors

# Batch matrix-vector multiplication using einsum
results = np.einsum('bij,bjk->bik', batch_matrices, batch_vectors)

# Tensor contraction along specific axes
tensor_a = np.random.rand(10, 15, 20)
tensor_b = np.random.rand(15, 25, 30)

# Contract along second axis of tensor_a and first axis of tensor_b
contracted = np.tensordot(tensor_a, tensor_b, axes=([1], [0]))  # Shape: (10, 20, 25, 30)

# Complex einsum operations
# Batch outer product
batch_a = np.random.rand(50, 8)
batch_b = np.random.rand(50, 12)
outer_products = np.einsum('bi,bj->bij', batch_a, batch_b)  # Shape: (50, 8, 12)

# Multi-dimensional trace operations
tensor_cube = np.random.rand(10, 10, 10)
diagonal_trace = np.einsum('iii', tensor_cube)  # Trace along all three dimensions
```

