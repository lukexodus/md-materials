## Index-based Operations


Index-based operations provide powerful tools for array manipulation using sorting indices.

**argsort() Function:** Returns indices that would sort an array:

```python
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])
sort_indices = np.argsort(arr)  # [1, 3, 6, 0, 2, 7, 4, 5]
sorted_arr = arr[sort_indices]  # [1, 1, 2, 3, 4, 6, 5, 9]
```

**Multi-dimensional argsort:**

```python
arr_2d = np.array([[3, 1, 4], [1, 5, 9], [2, 6, 5]])

# Sort indices along axis 0
indices_axis0 = np.argsort(arr_2d, axis=0)

# Sort indices along axis 1
indices_axis1 = np.argsort(arr_2d, axis=1)
```

**Lexicographic Sorting:** Sorting by multiple criteria using lexsort():

```python
# Sort by secondary key first, then primary
names = np.array(['Alice', 'Bob', 'Charlie', 'Alice'])
scores = np.array([95, 87, 92, 88])

# Sort by name, then by score
indices = np.lexsort((scores, names))
sorted_names = names[indices]
sorted_scores = scores[indices]
```

**Advanced Index Operations:**

```python
arr = np.array([10, 20, 30, 40, 50])

# Take elements at specific indices
indices = np.array([0, 2, 4])
selected = np.take(arr, indices)  # [10, 30, 50]

# Multi-dimensional take
arr_2d = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
taken = np.take(arr_2d, [0, 2], axis=0)  # [[1, 2, 3], [7, 8, 9]]
```

