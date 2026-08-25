## Tensors, Operations, and Sessions


**Tensors** Tensors are the fundamental data structure in TensorFlow - multidimensional arrays with uniform data types. They represent the data flowing through computational graphs.

Tensor properties:

- **Rank**: Number of dimensions (scalar=0, vector=1, matrix=2, etc.)
- **Shape**: Size of each dimension
- **Data type**: Type of elements (float32, int32, bool, etc.)

```python
# Creating tensors
scalar = tf.constant(5)                    # Rank 0
vector = tf.constant([1, 2, 3])           # Rank 1
matrix = tf.constant([[1, 2], [3, 4]])    # Rank 2
```

**Operations** Operations (ops) are the computational units that transform tensors. TensorFlow provides hundreds of built-in operations including mathematical functions, linear algebra operations, and neural network primitives.

Common operation categories:

- Arithmetic: add, subtract, multiply, divide
- Linear algebra: matmul, transpose, inverse
- Reduction: reduce_sum, reduce_mean, reduce_max
- Neural network: conv2d, relu, softmax

**Sessions (TensorFlow 1.x)** In TensorFlow 1.x, sessions managed graph execution and resource allocation. Sessions provided the runtime environment for executing operations:

```python
# TensorFlow 1.x session usage
with tf.Session() as sess:
    result = sess.run(operation)
```

TensorFlow 2.x eliminated explicit sessions in favor of eager execution, simplifying the development experience.

