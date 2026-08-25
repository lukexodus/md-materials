## Searching and Finding Elements


NumPy provides various methods for locating elements and their positions within arrays.

**Basic Element Search:**

```python
arr = np.array([1, 3, 5, 7, 9, 11])

# Binary search in sorted array
index = np.searchsorted(arr, 5)  # Returns 2
indices_multiple = np.searchsorted(arr, [4, 6, 10])  # [2, 3, 5]

# Search with side parameter
left_insert = np.searchsorted(arr, 5, side='left')   # 2
right_insert = np.searchsorted(arr, 5, side='right') # 3
```

**Finding Specific Values:**

```python
arr = np.array([1, 2, 3, 2, 4, 2, 5])

# Find indices where condition is True
indices = np.where(arr == 2)  # Returns (array([1, 3, 5]),)
values = arr[indices]  # [2, 2, 2]

# Conditional selection
result = np.where(arr > 3, arr, 0)  # [0, 0, 0, 0, 4, 0, 5]
```

**Boolean Indexing:**

```python
arr = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9])

# Boolean mask
mask = arr > 5
filtered = arr[mask]  # [6, 7, 8, 9]

# Complex conditions
complex_mask = (arr > 3) & (arr < 8)
filtered_complex = arr[complex_mask]  # [4, 5, 6, 7]
```

**Finding Extrema:**

```python
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])

# Find maximum and minimum values
max_val = np.max(arr)  # 9
min_val = np.min(arr)  # 1

# Find indices of extrema
max_index = np.argmax(arr)  # 5
min_index = np.argmin(arr)  # 1

# Multi-dimensional extrema
arr_2d = np.array([[3, 1, 4], [1, 5, 9]])
max_axis0 = np.argmax(arr_2d, axis=0)  # [0, 1, 1]
max_axis1 = np.argmax(arr_2d, axis=1)  # [2, 2]
```

