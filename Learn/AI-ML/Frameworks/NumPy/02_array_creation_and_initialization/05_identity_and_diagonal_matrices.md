## Identity and Diagonal Matrices


**Identity Matrices**

`numpy.eye()` creates identity matrices with ones on the diagonal and zeros elsewhere.

```python
# 3x3 identity matrix
identity = np.eye(3)
# [[1. 0. 0.]
#  [0. 1. 0.]
#  [0. 0. 1.]]

# Non-square identity
non_square = np.eye(3, 4)  # 3 rows, 4 columns

# Offset diagonal
offset = np.eye(3, k=1)  # Diagonal shifted right
```

**Identity-like Arrays**

```python
# Identity with same shape as existing array
reference = np.array([[1, 2], [3, 4]])
same_shape_identity = np.eye(*reference.shape)
```

**Diagonal Arrays**

`numpy.diag()` creates diagonal matrices from 1D arrays or extracts diagonals from 2D arrays.

```python
# Create diagonal matrix
diag_matrix = np.diag([1, 2, 3, 4])
# [[1 0 0 0]
#  [0 2 0 0]
#  [0 0 3 0]
#  [0 0 0 4]]

# Extract diagonal
matrix = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
diagonal = np.diag(matrix)  # [1 5 9]

# Offset diagonals
upper_diag = np.diag(matrix, k=1)  # [2 6]
lower_diag = np.diag(matrix, k=-1)  # [4 8]
```

