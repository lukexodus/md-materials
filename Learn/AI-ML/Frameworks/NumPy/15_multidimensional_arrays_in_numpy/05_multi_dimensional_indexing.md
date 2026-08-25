## Multi-dimensional Indexing


Multi-dimensional indexing in NumPy extends beyond simple coordinate-based access to encompass advanced selection patterns, conditional indexing across multiple dimensions, and sophisticated data extraction techniques that leverage the full power of NumPy's indexing system.

Coordinate-based indexing utilizes tuples of indices to specify exact element locations within multidimensional arrays. Each element in the index tuple corresponds to a position along the respective axis, enabling precise element selection and modification within complex data structures.

Advanced slicing in multiple dimensions combines slice objects, fancy indexing, and boolean indexing across different axes simultaneously. This approach enables extraction of complex data subsets that follow arbitrary patterns defined by combinations of sequential, non-sequential, and conditional selection criteria.

Boolean indexing in multidimensional contexts requires careful consideration of mask dimensionality and broadcasting behavior. Boolean masks can have fewer dimensions than target arrays, leading to broadcasting-based selection, or can match target dimensionality for element-wise filtering.

Index array combinations enable sophisticated selection patterns where different indexing methods apply to different dimensions. These combinations can mix integer arrays, boolean arrays, and slice objects to create highly specific data access patterns.

**Example:**

```python
# Multi-dimensional indexing examples
data_4d = np.random.rand(8, 6, 10, 12)

# Mixed indexing: specific indices for first two axes, slicing for last two
subset = data_4d[[0, 2, 4], 1:4, ::2, :]  # Shape depends on selection

# Boolean indexing across multiple dimensions
condition_3d = data_4d > 0.5
high_values = data_4d[condition_3d]  # Flattened array of values > 0.5

# Advanced boolean mask with dimension preservation
mask_2d = np.random.rand(8, 6) > 0.3  # 2D mask for first two dimensions
filtered_4d = data_4d[mask_2d]  # Shape: (n_true_values, 10, 12)

# Coordinate-based fancy indexing
row_indices = np.array([1, 3, 5])
col_indices = np.array([2, 4, 6])
depth_indices = np.array([0, 5, 9])

# Select specific coordinates from 3D subspace
selected_points = data_4d[row_indices[:, np.newaxis, np.newaxis], 
                         col_indices[np.newaxis, :, np.newaxis], 
                         depth_indices[np.newaxis, np.newaxis, :], 
                         :]

# Conditional indexing with multiple criteria
complex_condition = (data_4d > 0.3) & (data_4d < 0.7)
conditional_subset = data_4d[complex_condition]
```

