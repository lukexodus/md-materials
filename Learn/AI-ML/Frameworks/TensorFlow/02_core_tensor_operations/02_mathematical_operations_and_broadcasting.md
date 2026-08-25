## Mathematical Operations and Broadcasting


TensorFlow implements element-wise mathematical operations that automatically handle tensors of different shapes through broadcasting rules. Basic arithmetic operations include addition (`tf.add`), subtraction (`tf.subtract`), multiplication (`tf.multiply`), and division (`tf.divide`). Advanced mathematical functions encompass trigonometric operations, exponentials, logarithms, and power functions.

Broadcasting allows operations between tensors of compatible but different shapes, following NumPy-style broadcasting semantics. When tensor dimensions don't match, TensorFlow automatically expands the smaller tensor along singleton dimensions to match the larger tensor's shape.

**Key Points:**

- Element-wise operations preserve tensor shapes when dimensions match exactly
- Broadcasting rules enable operations between tensors of different but compatible shapes
- Mathematical functions include `tf.sin()`, `tf.cos()`, `tf.exp()`, `tf.log()`, `tf.pow()`, and `tf.sqrt()`
- Matrix operations like `tf.matmul()` perform linear algebra computations
- Comparison operations return boolean tensors that can be used for conditional logic

**Examples:**

```python
# Element-wise operations
a = tf.constant([1, 2, 3])
b = tf.constant([4, 5, 6])
sum_result = tf.add(a, b)  # [5, 7, 9]

# Broadcasting example
matrix = tf.constant([[1, 2], [3, 4]])
scalar = tf.constant(10)
broadcast_result = tf.multiply(matrix, scalar)  # [[10, 20], [30, 40]]

# Matrix multiplication
x = tf.random.normal((32, 784))
w = tf.random.normal((784, 128))
output = tf.matmul(x, w)
```

