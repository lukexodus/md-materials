## Arithmetic Operations and Operators


**Basic Arithmetic Operators**

NumPy overloads standard Python operators to perform element-wise operations on arrays, providing intuitive syntax for mathematical computations.

```python
# Basic arithmetic
a = np.array([10, 20, 30, 40])
b = np.array([1, 2, 3, 4])

addition = a + b        # [11 22 33 44]
subtraction = a - b     # [9 18 27 36]
multiplication = a * b  # [10 40 90 160]
division = a / b        # [10. 10. 10. 10.]
floor_division = a // b # [10 10 10 10]
modulo = a % b          # [0 0 0 0]
power = a ** b          # [10 400 27000 2560000]
```

**Matrix vs Element-wise Operations**

NumPy distinguishes between element-wise operations using operators and matrix operations using dedicated functions or the `@` operator.

```python
# Element-wise multiplication
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])
elementwise = A * B
# [[5 12]
#  [21 32]]

# Matrix multiplication
matrix_mult = A @ B  # or np.dot(A, B)
# [[19 22]
#  [43 50]]

# Other matrix operations
transpose = A.T
inverse = np.linalg.inv(A.astype(float))
```

**Compound Assignment Operators**

Compound operators modify arrays in-place, providing memory-efficient operations for large arrays.

```python
# In-place operations
arr = np.array([1, 2, 3, 4])
arr += 5        # arr becomes [6, 7, 8, 9]
arr *= 2        # arr becomes [12, 14, 16, 18]
arr //= 3       # arr becomes [4, 4, 5, 6]
```

