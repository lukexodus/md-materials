## Sorting Algorithms and Methods


NumPy implements multiple sorting algorithms with different performance characteristics and stability properties.

**Basic Sorting with sort():**

```python
import numpy as np

# In-place sorting (modifies original array)
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])
arr.sort()  # arr becomes [1, 1, 2, 3, 4, 5, 6, 9]

# Return sorted copy without modifying original
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])
sorted_arr = np.sort(arr)  # Original arr unchanged
```

**Multi-dimensional Array Sorting:**

```python
arr_2d = np.array([[3, 1, 4], [1, 5, 9], [2, 6, 5]])

# Sort along axis 0 (columns)
sorted_cols = np.sort(arr_2d, axis=0)

# Sort along axis 1 (rows)
sorted_rows = np.sort(arr_2d, axis=1)

# Sort flattened array
sorted_flat = np.sort(arr_2d, axis=None)
```

**Algorithm Selection:** NumPy allows specification of sorting algorithms:

```python
arr = np.random.randint(0, 100, 1000)

# Quicksort (default, unstable, O(n log n) average)
quick_sorted = np.sort(arr, kind='quicksort')

# Mergesort (stable, O(n log n) guaranteed)
merge_sorted = np.sort(arr, kind='mergesort')

# Heapsort (unstable, O(n log n) guaranteed)
heap_sorted = np.sort(arr, kind='heapsort')

# Timsort (stable, adaptive, O(n) to O(n log n))
tim_sorted = np.sort(arr, kind='stable')
```

**Sorting Order:**

```python
arr = np.array([3, 1, 4, 1, 5, 9])

# Ascending order (default)
ascending = np.sort(arr)  # [1, 1, 3, 4, 5, 9]

# Descending order
descending = np.sort(arr)[::-1]  # [9, 5, 4, 3, 1, 1]
# Alternative: -np.sort(-arr) for numeric arrays
```

