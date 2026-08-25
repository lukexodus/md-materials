## Mathematical Operations and Broadcasting


**Universal Functions (ufuncs)**

```python
arr = np.array([1, 2, 3, 4, 5])

# Basic mathematical operations
add_result = np.add(arr, 10)
multiply_result = np.multiply(arr, 2)
power_result = np.power(arr, 2)

# Trigonometric functions
sin_arr = np.sin(arr)
cos_arr = np.cos(arr)
tan_arr = np.tan(arr)

# Logarithmic and exponential functions
log_arr = np.log(arr)
exp_arr = np.exp(arr)
sqrt_arr = np.sqrt(arr)

# Statistical functions
mean_val = np.mean(arr)
std_val = np.std(arr)
median_val = np.median(arr)
```

**Broadcasting Rules and Applications**

```python
# Broadcasting with different shapes
arr_2d = np.array([[1, 2, 3], [4, 5, 6]])
arr_1d = np.array([10, 20, 30])

# Broadcasting addition
broadcast_result = arr_2d + arr_1d  # (2,3) + (3,) -> (2,3)

# Complex broadcasting scenarios
arr_a = np.random.random((5, 1, 3))
arr_b = np.random.random((1, 4, 1))
broadcast_complex = arr_a * arr_b  # Results in (5, 4, 3)

# Manual broadcasting
expanded_a = np.broadcast_to(arr_1d, (2, 3))
```

**Linear Algebra Operations**

```python
# Matrix operations
matrix_a = np.random.random((3, 4))
matrix_b = np.random.random((4, 2))

# Matrix multiplication
dot_product = np.dot(matrix_a, matrix_b)
matmul_result = np.matmul(matrix_a, matrix_b)  # Preferred for matrix multiplication

# Square matrix operations
square_matrix = np.random.random((4, 4))
determinant = np.linalg.det(square_matrix)
eigenvalues, eigenvectors = np.linalg.eig(square_matrix)
inverse_matrix = np.linalg.inv(square_matrix)

# Solving linear systems
A = np.array([[3, 1], [1, 2]])
b = np.array([9, 8])
solution = np.linalg.solve(A, b)
```

