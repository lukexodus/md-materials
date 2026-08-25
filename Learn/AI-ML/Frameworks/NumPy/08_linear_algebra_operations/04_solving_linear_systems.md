## Solving Linear Systems


**Key Points**
Linear system solving involves finding solutions to equations of the form Ax = b. NumPy provides multiple approaches depending on matrix properties, system size, and desired accuracy. Understanding when to use each method is crucial for numerical stability and computational efficiency.

**Basic Linear System Solving**
```python
# Solve Ax = b
A = np.array([[3, 2, -1],
              [2, -2, 4],
              [-1, 0.5, -1]])
b = np.array([1, -2, 0])

# Direct solution
x = np.linalg.solve(A, b)
print("Solution:", x)

# Verification
residual = A @ x - b
print("Residual:", np.linalg.norm(residual))

# Check if A is well-conditioned
condition_number = np.linalg.cond(A)
print("Condition number:", condition_number)
```

**Multiple Right-Hand Sides**
```python
# Solve AX = B for multiple b vectors
A = np.random.rand(4, 4)
B = np.random.rand(4, 3)  # 3 different b vectors

X = np.linalg.solve(A, B)
print("Solution shape:", X.shape)  # (4, 3)

# Verification for all solutions
residuals = A @ X - B
print("Max residual:", np.max(np.linalg.norm(residuals, axis=0)))
```

**Least Squares Solutions**
```python
# For overdetermined systems (more equations than unknowns)
A = np.random.rand(10, 3)  # 10 equations, 3 unknowns
b = np.random.rand(10)

# Least squares solution: minimize ||Ax - b||²
x_lstsq, residuals, rank, s = np.linalg.lstsq(A, b, rcond=None)
print("Least squares solution:", x_lstsq)
print("Residual sum of squares:", residuals[0] if len(residuals) > 0 else "No residuals")
print("Matrix rank:", rank)
```

**Solving with Different Matrix Types**
```python
# Symmetric positive definite systems (use Cholesky)
A_spd = np.random.rand(5, 5)
A_spd = A_spd.T @ A_spd + np.eye(5)
b = np.random.rand(5)

# Method 1: General solver
x1 = np.linalg.solve(A_spd, b)

# Method 2: Using Cholesky decomposition manually
L = np.linalg.cholesky(A_spd)
y = np.linalg.solve(L, b)  # Forward substitution: Ly = b
x2 = np.linalg.solve(L.T, y)  # Backward substitution: L.T x = y

print("Solution difference:", np.linalg.norm(x1 - x2))
```

**Iterative Refinement and Numerical Stability**
```python
# For ill-conditioned systems, check solution quality
A = np.array([[1e10, 1],
              [1, 1]])
b = np.array([1e10 + 1, 2])

x = np.linalg.solve(A, b)
print("Solution:", x)
print("Condition number:", np.linalg.cond(A))

# Check solution accuracy
computed_b = A @ x
error = np.linalg.norm(computed_b - b) / np.linalg.norm(b)
print("Relative error:", error)
```

