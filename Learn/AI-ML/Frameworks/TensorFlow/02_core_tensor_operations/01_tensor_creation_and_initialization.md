## Tensor Creation and Initialization


TensorFlow provides multiple methods for creating tensors with different initialization patterns. The `tf.constant()` function creates immutable tensors with fixed values, while `tf.Variable()` creates mutable tensors that can be updated during training. Specialized creation functions include `tf.zeros()` and `tf.ones()` for uniform initialization, `tf.random.normal()` for Gaussian distributions, and `tf.random.uniform()` for uniform random values.

**Key Points:**

- `tf.constant()` creates immutable tensors from Python lists, NumPy arrays, or scalar values
- `tf.Variable()` creates trainable parameters that maintain state across operations
- Random initialization functions accept shape parameters and distribution parameters
- `tf.eye()` creates identity matrices, while `tf.fill()` creates tensors filled with specified values
- Data type specification through the `dtype` parameter controls memory usage and computational precision

**Examples:**

```python
# Constant tensor creation
const_tensor = tf.constant([[1, 2], [3, 4]], dtype=tf.float32)
zero_tensor = tf.zeros((3, 3))
random_tensor = tf.random.normal((2, 4), mean=0.0, stddev=1.0)

# Variable creation
weights = tf.Variable(tf.random.normal((784, 10)))
bias = tf.Variable(tf.zeros((10,)))
```

