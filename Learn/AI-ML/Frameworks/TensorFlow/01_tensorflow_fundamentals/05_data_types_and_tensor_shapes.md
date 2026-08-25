## Data Types and Tensor Shapes


**Data Types** TensorFlow supports various data types optimized for different computational needs:

Floating point types:

- `tf.float16`: Half precision (memory efficient)
- `tf.float32`: Single precision (most common)
- `tf.float64`: Double precision (high accuracy)

Integer types:

- `tf.int8`, `tf.int16`, `tf.int32`, `tf.int64`
- `tf.uint8`, `tf.uint16` (unsigned integers)

Other types:

- `tf.bool`: Boolean values
- `tf.string`: String data
- `tf.complex64`, `tf.complex128`: Complex numbers

**Shape Handling** Tensor shapes define the size of each dimension. TensorFlow provides flexible shape handling including dynamic shapes and shape inference.

```python
# Shape operations
tensor = tf.constant([[1, 2, 3], [4, 5, 6]])
print(tensor.shape)        # Static shape: (2, 3)
print(tf.shape(tensor))    # Dynamic shape tensor

# Shape manipulation
reshaped = tf.reshape(tensor, [3, 2])
expanded = tf.expand_dims(tensor, axis=0)
```

**Broadcasting** TensorFlow supports NumPy-style broadcasting for operations between tensors of different shapes, following specific rules for dimension compatibility.

