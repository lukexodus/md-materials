## Creating Generalized Ufuncs (Gufuncs)


Generalized universal functions extend the ufunc concept to operate on array substructures rather than just scalar elements. Gufuncs enable vectorized operations on matrices, vectors, and higher-dimensional tensor slices while maintaining NumPy's broadcasting semantics.

**Key points:**

- Gufuncs operate on array cores (subarrays) rather than individual elements
- Signature strings define the dimensionality and relationship of inputs and outputs
- Automatic broadcasting applies to non-core dimensions
- Support for complex linear algebra operations and tensor manipulations
- Integration with NumPy's memory layout optimization for cache efficiency

**Example:**

```python
import numpy as np

# Method 1: Using numpy.vectorize with signature parameter
@np.vectorize(signature='(m,n),(n,k)->(m,k)')
def batch_matrix_multiply(A, B):
    return np.dot(A, B)

# Usage: multiply batches of matrices
batch_A = np.random.randn(100, 3, 4)  # 100 matrices of shape (3,4)
batch_B = np.random.randn(100, 4, 5)  # 100 matrices of shape (4,5)
result = batch_matrix_multiply(batch_A, batch_B)  # Shape: (100, 3, 5)

# Broadcasting with gufuncs
single_matrix = np.random.randn(4, 5)
broadcast_result = batch_matrix_multiply(batch_A, single_matrix)  # Broadcasts single matrix

# Method 2: Custom gufunc for statistical operations
@np.vectorize(signature='(n)->()')
def custom_variance(x):
    mean_x = np.mean(x)
    return np.mean((x - mean_x) ** 2)

# Apply to multiple vectors simultaneously
data_vectors = np.random.randn(1000, 50)  # 1000 vectors of length 50
variances = custom_variance(data_vectors)  # Shape: (1000,)

# Method 3: Complex gufunc for eigenvalue decomposition
@np.vectorize(signature='(m,m)->(m),(m,m)')
def batch_eigendecomposition(matrices):
    eigenvals, eigenvecs = np.linalg.eigh(matrices)
    return eigenvals, eigenvecs

# Process batch of symmetric matrices
symmetric_matrices = np.random.randn(200, 10, 10)
# Make them symmetric
symmetric_matrices = (symmetric_matrices + symmetric_matrices.transpose(0, 2, 1)) / 2
eigenvalues, eigenvectors = batch_eigendecomposition(symmetric_matrices)

# Advanced gufunc with multiple core dimensions
@np.vectorize(signature='(m,n),(m,n)->(m,n)')
def element_wise_outer_product(A, B):
    # Custom operation combining elements from two matrices
    return A[:, :, np.newaxis] * B[:, np.newaxis, :]

# Usage with complex broadcasting scenarios
tensor_A = np.random.randn(5, 8, 3, 4)
tensor_B = np.random.randn(5, 8, 3, 4)
result_tensor = element_wise_outer_product(tensor_A, tensor_B)
```

Gufuncs provide automatic parallelization opportunities and can leverage NumPy's internal optimization for memory access patterns. The signature system allows for flexible input/output relationships while maintaining type safety and dimensional consistency.

