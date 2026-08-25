## Norms and Determinants


**Key Points**
Norms measure the "size" or "length" of vectors and matrices, while determinants provide scalar measures of matrix properties including invertibility and volume scaling. These fundamental concepts appear throughout linear algebra applications and numerical analysis.

**Vector Norms**
```python
# Various vector norms
v = np.array([3, 4, 5])

# L1 norm (Manhattan distance)
l1_norm = np.linalg.norm(v, ord=1)
print("L1 norm:", l1_norm)  # |3| + |4| + |5| = 12

# L2 norm (Euclidean distance) - default
l2_norm = np.linalg.norm(v)
l2_norm_explicit = np.linalg.norm(v, ord=2)
print("L2 norm:", l2_norm)  # sqrt(3² + 4² + 5²) = sqrt(50)

# Infinity norm (maximum absolute value)
inf_norm = np.linalg.norm(v, ord=np.inf)
print("Infinity norm:", inf_norm)  # max(|3|, |4|, |5|) = 5

# p-norm for arbitrary p
p = 3
p_norm = np.linalg.norm(v, ord=p)
print(f"L{p} norm:", p_norm)  # (3³ + 4³ + 5³)^(1/3)
```

**Matrix Norms**
```python
A = np.array([[1, 2, 3],
              [4, 5, 6],
              [7, 8, 9]])

# Frobenius norm (default for matrices)
frob_norm = np.linalg.norm(A)
frob_norm_explicit = np.linalg.norm(A, ord='fro')
print("Frobenius norm:", frob_norm)

# Spectral norm (2-norm, largest singular value)
spectral_norm = np.linalg.norm(A, ord=2)
print("Spectral norm:", spectral_norm)

# Nuclear norm (sum of singular values)
nuclear_norm = np.linalg.norm(A, ord='nuc')
print("Nuclear norm:", nuclear_norm)

# 1-norm (maximum column sum)
one_norm = np.linalg.norm(A, ord=1)
print("1-norm:", one_norm)

# Infinity-norm (maximum row sum)
inf_norm_matrix = np.linalg.norm(A, ord=np.inf)
print("Infinity-norm:", inf_norm_matrix)
```

**Determinant Computation**
```python
# Determinant for square matrices
A_2x2 = np.array([[2, 3],
                  [1, 4]])
det_2x2 = np.linalg.det(A_2x2)
print("2x2 determinant:", det_2x2)  # 2*4 - 3*1 = 5

# Larger matrix determinant
A_3x3 = np.array([[1, 2, 3],
                  [0, 1, 4],
                  [5, 6, 0]])
det_3x3 = np.linalg.det(A_3x3)
print("3x3 determinant:", det_3x3)

# Properties of determinants
A = np.random.rand(4, 4)
B = np.random.rand(4, 4)

# det(AB) = det(A) * det(B)
det_A = np.linalg.det(A)
det_B = np.linalg.det(B)
det_AB = np.linalg.det(A @ B)
print("det(A) * det(B):", det_A * det_B)
print("det(AB):", det_AB)
print("Multiplicative property holds:", np.isclose(det_A * det_B, det_AB))
```

**Sign of Determinant and Matrix Properties**
```python
# Determinant sign indicates orientation
# Positive: preserves orientation
# Negative: reverses orientation
# Zero: singular (non-invertible)

matrices = [
    np.array([[2, 0], [0, 3]]),      # Positive definite
    np.array([[2, 0], [0, -3]]),     # Indefinite
    np.array([[1, 2], [2, 4]])       # Singular
]

for i, mat in enumerate(matrices):
    det = np.linalg.det(mat)
    print(f"Matrix {i+1} determinant: {det:.6f}")
    if abs(det) < 1e-10:
        print("  → Singular (non-invertible)")
    elif det > 0:
        print("  → Positive determinant")
    else:
        print("  → Negative determinant")
```

**Condition Numbers and Numerical Stability**
```python
# Condition number relates to numerical stability
# cond(A) = ||A|| * ||A^(-1)||

A_well = np.array([[2, 0],
                   [0, 1]])
A_ill = np.array([[1, 1],
                  [1, 1.0001]])

cond_well = np.linalg.cond(A_well)
cond_ill = np.linalg.cond(A_ill)

print("Well-conditioned matrix condition number:", cond_well)
print("Ill-conditioned matrix condition number:", cond_ill)

# Condition number with different norms
cond_1 = np.linalg.cond(A_ill, p=1)
cond_2 = np.linalg.cond(A_ill, p=2)  # Spectral condition number
cond_inf = np.linalg.cond(A_ill, p=np.inf)

print("Condition numbers (1, 2, inf):", cond_1, cond_2, cond_inf)
```

**Relationship Between Norms and Matrix Properties**
```python
# Spectral radius and matrix norms
A = np.array([[0.5, 0.3],
              [0.2, 0.4]])

# Spectral radius (largest absolute eigenvalue)
eigenvals = np.linalg.eigvals(A)
spectral_radius = np.max(np.abs(eigenvals))
print("Spectral radius:", spectral_radius)

# Various norms
norms = {
    'Spectral (2-norm)': np.linalg.norm(A, ord=2),
    'Frobenius': np.linalg.norm(A, ord='fro'),
    '1-norm': np.linalg.norm(A, ord=1),
    'Inf-norm': np.linalg.norm(A, ord=np.inf)
}

print("Matrix norms:")
for name, value in norms.items():
    print(f"  {name}: {value:.6f}")

# For normal matrices: spectral norm equals spectral radius
print("Spectral radius ≤ any matrix norm:", 
      all(spectral_radius <= norm_val for norm_val in norms.values()))
```

**Output**
NumPy's linear algebra operations provide a comprehensive foundation for scientific computing and mathematical analysis. Matrix multiplication operations support efficient computation of dot products, matrix products, and tensor contractions with proper broadcasting semantics. Eigenvalue decomposition reveals intrinsic matrix properties essential for dimensionality reduction and stability analysis.

Matrix decompositions including SVD, QR, and Cholesky factorizations enable efficient algorithms for least squares problems, orthogonalization, and positive definite system solving. Linear system solving capabilities range from direct methods for well-conditioned problems to least squares approaches for overdetermined systems, with proper consideration of numerical stability through condition number analysis.

Matrix inversion and pseudo-inverse operations provide tools for solving inverse problems, with pseudo-inverses extending applicability to rectangular and singular matrices. Norms and determinants offer fundamental measures of vector and matrix properties, supporting convergence analysis, stability assessment, and geometric interpretation of linear transformations.

These linear algebra operations form the computational backbone of scientific computing applications, enabling efficient implementation of algorithms in fields ranging from machine learning and signal processing to numerical simulation and optimization.

---

