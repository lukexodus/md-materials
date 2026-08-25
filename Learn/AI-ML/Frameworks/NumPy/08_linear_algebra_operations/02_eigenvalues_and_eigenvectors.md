## Eigenvalues and Eigenvectors


**Key Points**
Eigenvalue decomposition reveals fundamental properties of linear transformations represented by matrices. NumPy provides functions to compute eigenvalues, eigenvectors, and related decompositions for both general and specialized matrix types.

**Basic Eigenvalue Computation**
```python
# Standard eigenvalue decomposition
A = np.array([[4, 2],
              [1, 3]])

eigenvalues, eigenvectors = np.linalg.eig(A)
print("Eigenvalues:", eigenvalues)
print("Eigenvectors:\n", eigenvectors)

# Verification: A @ v = λ * v
for i in range(len(eigenvalues)):
    lambda_i = eigenvalues[i]
    v_i = eigenvectors[:, i]
    print(f"A @ v_{i} =", A @ v_i)
    print(f"λ_{i} * v_{i} =", lambda_i * v_i)
```

**Symmetric Matrix Eigendecomposition**
```python
# For symmetric matrices, use eigh for better numerical stability
S = np.array([[4, 2, 1],
              [2, 3, 0],
              [1, 0, 2]])

eigenvals, eigenvecs = np.linalg.eigh(S)
# eigenvals are real and sorted in ascending order
# eigenvecs are orthonormal

# Verify orthogonality
print("Orthogonality check:", np.allclose(eigenvecs.T @ eigenvecs, np.eye(3)))
```

**Generalized Eigenvalue Problems**
```python
# Solve A @ x = λ * B @ x
A = np.array([[2, 1],
              [1, 2]])
B = np.array([[1, 0],
              [0, 1]])

eigenvals, eigenvecs = np.linalg.eig(A, B)
# Note: B must be invertible for standard form
```

**Applications in Principal Component Analysis**
```python
# Example: PCA using eigendecomposition
data = np.random.randn(100, 5)  # 100 samples, 5 features

# Center the data
centered_data = data - np.mean(data, axis=0)

# Compute covariance matrix
cov_matrix = np.cov(centered_data.T)

# Eigendecomposition for PCA
eigenvals, eigenvecs = np.linalg.eigh(cov_matrix)

# Sort by eigenvalues (descending)
idx = np.argsort(eigenvals)[::-1]
eigenvals = eigenvals[idx]
eigenvecs = eigenvecs[:, idx]

# Project data onto principal components
projected_data = centered_data @ eigenvecs
```

