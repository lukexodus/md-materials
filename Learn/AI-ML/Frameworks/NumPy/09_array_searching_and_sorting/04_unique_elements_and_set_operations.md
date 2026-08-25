## Unique Elements and Set Operations


NumPy provides comprehensive set operations for finding unique elements and performing set algebra.

**Finding Unique Elements:**

```python
arr = np.array([1, 2, 2, 3, 3, 3, 4, 4, 4, 4])

# Basic unique elements
unique_vals = np.unique(arr)  # [1, 2, 3, 4]

# Unique with additional information
unique_vals, indices, inverse, counts = np.unique(arr, 
                                                  return_index=True,
                                                  return_inverse=True, 
                                                  return_counts=True)
# indices: first occurrence indices [0, 1, 3, 6]
# inverse: reconstruction indices [0, 1, 1, 2, 2, 2, 3, 3, 3, 3]
# counts: occurrence counts [1, 2, 3, 4]
```

**Multi-dimensional Unique:**

```python
arr_2d = np.array([[1, 2], [3, 4], [1, 2], [5, 6]])

# Unique rows
unique_rows = np.unique(arr_2d, axis=0)
# [[1, 2], [3, 4], [5, 6]]
```

**Set Operations:**

```python
arr1 = np.array([1, 2, 3, 4, 5])
arr2 = np.array([3, 4, 5, 6, 7])

# Intersection
intersection = np.intersect1d(arr1, arr2)  # [3, 4, 5]

# Union
union = np.union1d(arr1, arr2)  # [1, 2, 3, 4, 5, 6, 7]

# Set difference (elements in arr1 not in arr2)
setdiff = np.setdiff1d(arr1, arr2)  # [1, 2]

# Symmetric difference (elements in either array but not both)
sym_diff = np.setxor1d(arr1, arr2)  # [1, 2, 6, 7]
```

**Membership Testing:**

```python
arr = np.array([1, 2, 3, 4, 5])
test_vals = np.array([2, 6, 4, 8])

# Test membership
is_member = np.isin(test_vals, arr)  # [True, False, True, False]

# Invert membership test
not_member = np.isin(test_vals, arr, invert=True)  # [False, True, False, True]
```

