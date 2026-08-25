## Complex Indexing Patterns


Complex indexing in NumPy encompasses advanced techniques that go beyond simple slicing to include fancy indexing, multi-dimensional index arrays, and sophisticated selection patterns that enable powerful data manipulation and analysis capabilities.

Fancy indexing utilizes integer arrays or lists as indices, enabling non-sequential element selection and arbitrary reordering. This technique supports both single-axis and multi-axis indexing, where different index arrays can be applied to different dimensions simultaneously.

Index broadcasting applies NumPy's broadcasting rules to index arrays, enabling efficient selection of regular patterns without explicit loop construction. When index arrays have compatible shapes, broadcasting creates implicit meshgrids that define multi-dimensional selection patterns.

Advanced index combinations merge fancy indexing with boolean indexing and slice objects, creating hybrid selection mechanisms that combine the flexibility of arbitrary selection with the efficiency of vectorized operations. These combinations enable complex data extraction patterns that would be difficult to achieve through individual indexing methods.

Index array manipulation includes techniques like argsort for indirect sorting, argmax/argmin for extrema location, and searchsorted for efficient value location in sorted arrays. These functions return index arrays that can be used for subsequent fancy indexing operations.

**Example:**

```python
# Multi-dimensional fancy indexing
arr = np.arange(20).reshape(4, 5)
row_indices = np.array([0, 2, 3])
col_indices = np.array([1, 3, 4])
selected = arr[row_indices[:, np.newaxis], col_indices]  # Broadcasting indices

# Complex index combinations
bool_mask = arr > 10
fancy_indices = np.array([1, 3])
combined_result = arr[bool_mask][fancy_indices]

# Indirect operations using index arrays
sorted_indices = np.argsort(arr.flatten())
top_k_indices = np.argpartition(arr.flatten(), -5)[-5:]  # Top 5 elements
top_k_values = arr.flatten()[top_k_indices]
```

