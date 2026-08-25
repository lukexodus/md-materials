## Broadcasting Examples and Patterns


Broadcasting patterns enable elegant solutions for common array manipulation scenarios, from simple arithmetic to complex mathematical transformations.

**Scalar Broadcasting** Scalar values broadcast with arrays of any shape, enabling uniform operations across entire arrays. This pattern applies mathematical constants, scaling factors, and threshold values without explicit iteration or array construction.

**Vector-Matrix Broadcasting** Row and column vectors broadcast with matrices to perform operations along specific axes. Row vectors (shape `(1, n)` or `(n,)`) broadcast across matrix rows, while column vectors (shape `(m, 1)`) broadcast across columns, enabling efficient linear transformations and normalization operations.

**Multi-dimensional Broadcasting** Higher-dimensional arrays follow the same broadcasting principles, enabling complex operations on tensors and multi-dimensional datasets. Common patterns include applying operations along specific axes while preserving other dimensions.

**Conditional Broadcasting** Boolean arrays broadcast with numerical arrays in conditional operations, enabling element-wise filtering and selection without explicit indexing. This pattern supports complex logical operations across array dimensions.

**Outer Product Patterns** Broadcasting naturally creates outer products between vectors by ensuring compatible shapes through dimension expansion. This pattern generates distance matrices, correlation grids, and combinatorial arrays efficiently.

**Examples**

```python
# Matrix normalization using broadcasting
matrix = np.random.random((100, 50))
column_means = matrix.mean(axis=0, keepdims=True)  # Shape: (1, 50)
normalized = matrix - column_means                 # Broadcasting across rows

# Distance matrix calculation
points = np.random.random((20, 3))
distances = np.sqrt(((points[:, np.newaxis] - points) ** 2).sum(axis=2))

# Conditional operations with broadcasting
data = np.random.random((10, 10))
mask = data > 0.5
filtered = np.where(mask, data, 0)  # Broadcasting boolean condition
```

