## Indexing and Slicing Tensors


TensorFlow supports advanced indexing and slicing operations for extracting tensor subsets. Basic slicing uses Python slice notation with start:stop:step syntax, while advanced indexing employs integer arrays and boolean masks. Conditional indexing with `tf.where()` enables data filtering based on logical conditions.

**Key Points:**

- Slice notation `tensor[start:stop:step]` extracts tensor subsequences
- Multi-dimensional slicing applies independent slice operations to each axis
- `tf.gather()` extracts elements at specified indices along given axes
- Boolean indexing uses condition tensors to filter elements
- `tf.where()` performs conditional element selection between two tensors

**Examples:**

```python
# Basic slicing
tensor = tf.constant([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]])
slice_result = tensor[1:3, 0:2]  # [[5, 6], [9, 10]]
step_slice = tensor[::2, :]      # [[1, 2, 3, 4], [9, 10, 11, 12]]

# Advanced indexing
indices = tf.constant([0, 2])
gathered = tf.gather(tensor, indices, axis=0)  # Rows 0 and 2

# Conditional indexing
condition = tf.greater(tensor, 6)
filtered = tf.where(condition, tensor, tf.zeros_like(tensor))
```

