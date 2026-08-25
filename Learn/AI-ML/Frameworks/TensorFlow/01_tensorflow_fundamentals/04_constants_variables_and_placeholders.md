## Constants, Variables, and Placeholders


**Constants** Constants hold immutable values throughout graph execution. They're embedded directly into the graph definition and cannot be modified during execution.

```python
# Creating constants
const_tensor = tf.constant([1, 2, 3, 4])
const_matrix = tf.constant([[1, 2], [3, 4]], dtype=tf.float32)
```

**Variables** Variables represent mutable state in TensorFlow graphs, primarily used for model parameters like weights and biases that need updating during training.

Key variable characteristics:

- Persistent across graph executions
- Require explicit initialization
- Support assignment operations
- Automatically tracked for gradient computation

```python
# Creating and using variables
weight = tf.Variable(tf.random.normal([10, 5]))
bias = tf.Variable(tf.zeros([5]))

# Variable assignment
weight.assign(new_values)
weight.assign_add(increment_values)
```

**Placeholders (TensorFlow 1.x)** Placeholders in TensorFlow 1.x represented inputs that would be fed during session execution. They defined the structure of input data without containing actual values.

```python
# TensorFlow 1.x placeholder usage
input_placeholder = tf.placeholder(tf.float32, shape=[None, 784])
```

TensorFlow 2.x replaced placeholders with function arguments and tf.data API for more intuitive data handling.

