## Custom Activation Functions


Activation functions determine the output characteristics of neural network layers. Custom activation functions enable domain-specific transformations and experimental architectures.

**Mathematical Function Definition**

Custom activations can be implemented as mathematical functions:

```python
def swish(x):
    return x * tf.nn.sigmoid(x)

def gelu(x):
    return 0.5 * x * (1.0 + tf.math.erf(x / tf.sqrt(2.0)))

def mish(x):
    return x * tf.nn.tanh(tf.nn.softplus(x))
```

**Parameterized Activation Functions**

Some activations require learnable parameters:

```python
class ParametricReLU(tf.keras.layers.Layer):
    def __init__(self, alpha_initializer='zeros', **kwargs):
        super(ParametricReLU, self).__init__(**kwargs)
        self.alpha_initializer = tf.keras.initializers.get(alpha_initializer)
    
    def build(self, input_shape):
        self.alpha = self.add_weight(
            shape=input_shape[1:],
            initializer=self.alpha_initializer,
            trainable=True,
            name='alpha'
        )
        super(ParametricReLU, self).build(input_shape)
    
    def call(self, inputs):
        return tf.maximum(0.0, inputs) + self.alpha * tf.minimum(0.0, inputs)
```

**Piecewise and Complex Activations**

Complex activation functions can combine multiple operations:

```python
def hard_swish(x):
    return x * tf.nn.relu6(x + 3) / 6

def snake(x, a=1.0):
    return x + tf.sin(a * x) ** 2 / a
```

**Integration with Keras**

Custom activations integrate seamlessly with Keras layers:

```python
# Register custom activation
tf.keras.utils.get_custom_objects()['swish'] = swish

# Use in layer definition
model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, activation=swish),
    tf.keras.layers.Dense(10, activation='softmax')
])
```

