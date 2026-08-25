## Array Manipulation and Transformation


**Shape Manipulation**

```python
original = np.array([[1, 2, 3, 4], [5, 6, 7, 8]])

# Reshaping
reshaped = original.reshape(4, 2)
flattened = original.flatten()
raveled = original.ravel()  # Flattened view when possible

# Dimension manipulation
expanded = np.expand_dims(original, axis=0)  # Add new axis
squeezed = np.squeeze(expanded)  # Remove single-dimensional entries

# Transposition
transposed = original.T
transpose_axes = np.transpose(original, (1, 0))
```

**Array Concatenation and Splitting**

```python
arr1 = np.array([[1, 2], [3, 4]])
arr2 = np.array([[5, 6], [7, 8]])

# Concatenation
horizontal_concat = np.hstack([arr1, arr2])
vertical_concat = np.vstack([arr1, arr2])
concatenate_axis0 = np.concatenate([arr1, arr2], axis=0)

# Splitting
large_array = np.random.random((6, 4))
split_arrays = np.split(large_array, 3, axis=0)  # Split into 3 equal parts
hsplit_result = np.hsplit(large_array, 2)  # Horizontal split
```

**Advanced Transformation Functions**

```python
# Rolling and shifting
arr = np.array([1, 2, 3, 4, 5])
rolled = np.roll(arr, 2)  # Circular shift

# Tiling and repeating
tiled = np.tile(arr, (2, 3))  # Tile array
repeated = np.repeat(arr, 3)  # Repeat each element

# Unique operations
data_with_duplicates = np.array([1, 2, 2, 3, 1, 4, 4, 5])
unique_values, indices, counts = np.unique(data_with_duplicates, 
                                         return_indices=True, 
                                         return_counts=True)
```

