## Tensor Manipulation and Reshaping


Tensor reshaping operations modify tensor dimensions without changing the underlying data. The `tf.reshape()` function reorganizes tensor elements into new dimensional structures, while `tf.transpose()` reorders tensor axes. Dynamic reshaping capabilities allow shape modifications based on runtime conditions.

**Key Points:**

- `tf.reshape()` requires the total number of elements to remain constant
- `tf.transpose()` accepts perm parameter to specify axis reordering
- `tf.expand_dims()` adds singleton dimensions at specified positions
- `tf.squeeze()` removes dimensions of size 1
- Dynamic shapes can be manipulated using `tf.shape()` and tensor operations

**Examples:**

```python
# Reshaping operations
original = tf.constant([[1, 2, 3, 4], [5, 6, 7, 8]])
reshaped = tf.reshape(original, (4, 2))  # Shape: (4, 2)
flattened = tf.reshape(original, (-1,))  # Shape: (8,)

# Transpose and dimension manipulation
matrix = tf.random.normal((3, 4, 5))
transposed = tf.transpose(matrix, perm=[2, 0, 1])  # Shape: (5, 3, 4)
expanded = tf.expand_dims(matrix, axis=0)  # Shape: (1, 3, 4, 5)
```

