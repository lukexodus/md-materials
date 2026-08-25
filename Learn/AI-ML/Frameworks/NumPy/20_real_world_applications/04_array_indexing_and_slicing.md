## Array Indexing and Slicing


**Basic Indexing Operations**

```python
arr = np.array([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]])

# Basic slicing
subset = arr[1:3, 2:4]  # Rows 1-2, columns 2-3
column = arr[:, 1]      # All rows, column 1
row = arr[2, :]         # Row 2, all columns

# Step slicing
every_other = arr[::2, ::2]  # Every other element in both dimensions
reversed_arr = arr[::-1, ::-1]  # Reverse both dimensions
```

**Advanced Indexing Techniques**

```python
# Boolean indexing
condition = arr > 6
filtered = arr[condition]
arr[arr < 5] = 0  # Conditional assignment

# Fancy indexing
indices = [0, 2]
selected_rows = arr[indices]
complex_selection = arr[[0, 1, 2], [1, 2, 3]]  # Specific elements

# Integer array indexing
row_indices = np.array([0, 1, 2])
col_indices = np.array([2, 1, 0])
diagonal_elements = arr[row_indices, col_indices]
```

**Multi-dimensional Indexing**

```python
# 3D array indexing
arr_3d = np.random.random((4, 3, 2))
slice_3d = arr_3d[1:3, :, 1]  # Specific slice through 3D space

# Ellipsis operator
arr_4d = np.random.random((2, 3, 4, 5))
ellipsis_slice = arr_4d[..., 2]  # All dimensions except last, index 2 in last dimension
```

