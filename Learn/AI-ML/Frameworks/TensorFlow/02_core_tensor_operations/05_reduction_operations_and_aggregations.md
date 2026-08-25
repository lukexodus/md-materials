## Reduction Operations and Aggregations


Reduction operations collapse tensor dimensions by applying aggregation functions across specified axes. Common reductions include sum, mean, maximum, minimum, and standard deviation calculations. These operations can be applied globally across all elements or selectively along particular dimensions.

**Key Points:**

- `tf.reduce_sum()`, `tf.reduce_mean()`, `tf.reduce_max()`, and `tf.reduce_min()` perform statistical aggregations
- `axis` parameter specifies which dimensions to reduce
- `keepdims=True` preserves reduced dimensions as size-1 axes
- `tf.argmax()` and `tf.argmin()` return indices of extreme values
- Reduction operations are essential for loss function calculations and model evaluation

**Examples:**

```python
# Reduction operations
matrix = tf.constant([[1, 2, 3], [4, 5, 6], [7, 8, 9]], dtype=tf.float32)

# Global reductions
total_sum = tf.reduce_sum(matrix)      # 45.0
mean_value = tf.reduce_mean(matrix)    # 5.0

# Axis-specific reductions
row_sums = tf.reduce_sum(matrix, axis=1)     # [6, 15, 24]
col_means = tf.reduce_mean(matrix, axis=0)   # [4.0, 5.0, 6.0]

# Index-based reductions
max_indices = tf.argmax(matrix, axis=1)      # [2, 2, 2]
```

