## Matrix Inversions and Pseudo-Inverses


**Key Points**
Matrix inversion and pseudo-inversion are fundamental operations with different applications and numerical considerations. Direct inversion should be avoided when solving linear systems, while pseudo-inverses provide solutions for non-square or singular matrices.

**Standard Matrix Inversion**
```python
# Square, non-singular matrix inversion
A = np.array([[2, 1],
              [1, 1]])

A_inv = np.linalg.inv(A)
print("Inverse matrix:\n", A_inv)

# Verification: A @ A_inv should equal identity
identity_check = A @ A_inv
print("A @ A_inv:\n", identity_check)
print("Is identity?", np.allclose(identity_check, np.eye(2)))

# Check determinant (must be non-zero for invertibility)
det_A = np.linalg.det(A)
print("Determinant:", det_A)
```

**Numerical Stability Considerations**
```python
# Ill-conditioned matrix example
epsilon = 1e-12
A_ill = np.array([[1, 1],
                  [1, 1 + epsilon]])

print("Condition number:", np.linalg.cond(A_ill))

try:
    A_ill_inv = np.linalg.inv(A_ill)
    # Check inversion quality
    identity_test = A_ill @ A_ill_inv
    error = np.linalg.norm(identity_test - np.eye(2))
    print("Inversion error:", error)
except np.linalg.LinAlgError as e:
    print("Inversion failed:", e)
```

**Moore-Penrose Pseudo-Inverse**
```python
# For rectangular or singular matrices
A_rect = np.array([[1, 2, 3],
                   [4, 5, 6]])  # 2x3 matrix

A_pinv = np.linalg.pinv(A_rect)
print("Pseudoinverse shape:", A_pinv.shape)  # 3x2

# Properties of pseudoinverse
# For overdetermined case: A @ A_pinv @ A = A
reconstruction_error = np.linalg.norm(A_rect @ A_pinv @ A_rect - A_rect)
print("Reconstruction error:", reconstruction_error)

# For underdetermined systems, provides minimum norm solution
b = np.array([1, 2])
x_min_norm = A_pinv @ b
print("Minimum norm solution:", x_min_norm)
print("Solution norm:", np.linalg.norm(x_min_norm))
```

**Pseudo-Inverse via SVD**
```python
# Manual pseudoinverse computation using SVD
U, s, Vt = np.linalg.svd(A_rect, full_matrices=False)

# Compute pseudoinverse with tolerance for singular values
tolerance = 1e-10
s_inv = np.where(s > tolerance, 1/s, 0)
A_pinv_manual = Vt.T @ np.diag(s_inv) @ U.T

print("Manual vs NumPy pseudoinverse difference:", 
      np.linalg.norm(A_pinv_manual - A_pinv))
```

**Applications in Linear Regression**
```python
# Linear regression using pseudoinverse: x = (A.T @ A)^(-1) @ A.T @ b
# Generate synthetic data
np.random.seed(42)
n_samples, n_features = 100, 3
A = np.random.randn(n_samples, n_features)
true_x = np.array([2, -1, 0.5])
noise = 0.1 * np.random.randn(n_samples)
b = A @ true_x + noise

# Solution using pseudoinverse
x_estimated = np.linalg.pinv(A) @ b
print("True coefficients:", true_x)
print("Estimated coefficients:", x_estimated)
print("Estimation error:", np.linalg.norm(x_estimated - true_x))

# Compare with least squares
x_lstsq = np.linalg.lstsq(A, b, rcond=None)[0]
print("Least squares solution:", x_lstsq)
print("Solutions difference:", np.linalg.norm(x_estimated - x_lstsq))
```

