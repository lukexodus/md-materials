## Matrix Decompositions (SVD, QR, Cholesky)


**Key Points**
Matrix decompositions factorize matrices into products of simpler matrices with specific properties. These decompositions are fundamental to numerical algorithms, dimensionality reduction, and solving linear systems efficiently.

**Singular Value Decomposition (SVD)**
```python
# SVD: A = U @ S @ V.T
A = np.random.rand(6, 4)

U, s, Vt = np.linalg.svd(A, full_matrices=True)
print("U shape:", U.shape)    # (6, 6) - left singular vectors
print("s shape:", s.shape)    # (4,) - singular values
print("Vt shape:", Vt.shape)  # (4, 4) - right singular vectors (transposed)

# Reconstruction
S = np.zeros_like(A)
S[:min(A.shape), :min(A.shape)] = np.diag(s)
A_reconstructed = U @ S @ Vt
print("Reconstruction error:", np.linalg.norm(A - A_reconstructed))

# Compact SVD (economy-size)
U_compact, s_compact, Vt_compact = np.linalg.svd(A, full_matrices=False)
print("Compact U shape:", U_compact.shape)  # (6, 4)
```

**SVD Applications**
```python
# Low-rank approximation
k = 2  # Keep top k singular values
A_k = U_compact[:, :k] @ np.diag(s_compact[:k]) @ Vt_compact[:k, :]

# Pseudoinverse using SVD
A_pinv = Vt_compact.T @ np.diag(1/s_compact) @ U_compact.T
print("Pseudoinverse error:", np.linalg.norm(A_pinv - np.linalg.pinv(A)))

# Matrix rank determination
rank = np.sum(s_compact > 1e-10)  # Count significant singular values
```

**QR Decomposition**
```python
# QR: A = Q @ R (Q orthogonal, R upper triangular)
A = np.random.rand(5, 3)

Q, R = np.linalg.qr(A)
print("Q shape:", Q.shape)  # (5, 5) for full, (5, 3) for reduced
print("R shape:", R.shape)  # (5, 3) for full, (3, 3) for reduced

# Verify orthogonality of Q
print("Q orthogonality:", np.allclose(Q.T @ Q, np.eye(Q.shape[1])))

# Reconstruction
A_reconstructed = Q @ R
print("QR reconstruction error:", np.linalg.norm(A - A_reconstructed))

# Reduced QR decomposition
Q_reduced, R_reduced = np.linalg.qr(A, mode='reduced')
print("Reduced Q shape:", Q_reduced.shape)  # (5, 3)
print("Reduced R shape:", R_reduced.shape)  # (3, 3)
```

**Cholesky Decomposition**
```python
# Cholesky: A = L @ L.T (for positive definite matrices)
# Create a positive definite matrix
A = np.random.rand(4, 4)
A_pos_def = A.T @ A + np.eye(4)  # Ensure positive definiteness

try:
    L = np.linalg.cholesky(A_pos_def)
    print("Cholesky factor L:\n", L)
    
    # Verification
    reconstructed = L @ L.T
    print("Cholesky reconstruction error:", np.linalg.norm(A_pos_def - reconstructed))
    
except np.linalg.LinAlgError:
    print("Matrix is not positive definite")

# Upper triangular Cholesky factor
L_upper = np.linalg.cholesky(A_pos_def).T
```

**LU Decomposition via SciPy Integration**
```python
# NumPy doesn't have built-in LU, but can be accessed through SciPy
# [Inference] SciPy provides LU decomposition: P @ A = L @ U
# This requires scipy.linalg for complete LU functionality
```

