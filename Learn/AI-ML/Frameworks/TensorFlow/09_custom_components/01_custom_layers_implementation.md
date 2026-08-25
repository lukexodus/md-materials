## Custom Layers Implementation


Custom layers form the building blocks of specialized neural network architectures. TensorFlow provides multiple approaches for implementing custom layers, each suited to different complexity levels and use cases.

**Subclassing tf.keras.layers.Layer**

The most flexible approach involves inheriting from `tf.keras.layers.Layer`. This method requires implementing several key methods:

- `__init__`: Initialize layer parameters and configuration
- `build`: Create layer weights based on input shape
- `call`: Define the forward pass computation
- `get_config`: Enable layer serialization

```python
class DenseLayer(tf.keras.layers.Layer):
    def __init__(self, units, activation=None, **kwargs):
        super(DenseLayer, self).__init__(**kwargs)
        self.units = units
        self.activation = tf.keras.activations.get(activation)
    
    def build(self, input_shape):
        self.kernel = self.add_weight(
            shape=(input_shape[-1], self.units),
            initializer='glorot_uniform',
            trainable=True,
            name='kernel'
        )
        self.bias = self.add_weight(
            shape=(self.units,),
            initializer='zeros',
            trainable=True,
            name='bias'
        )
        super(DenseLayer, self).build(input_shape)
    
    def call(self, inputs):
        output = tf.matmul(inputs, self.kernel) + self.bias
        if self.activation is not None:
            output = self.activation(output)
        return output
```

**Lambda Layers for Simple Operations**

For straightforward mathematical operations, Lambda layers provide a concise solution:

```python
# Custom normalization layer
normalize_layer = tf.keras.layers.Lambda(
    lambda x: tf.nn.l2_normalize(x, axis=-1)
)

# Custom scaling operation
scale_layer = tf.keras.layers.Lambda(
    lambda x: x * 0.1
)
```

**Functional API Custom Layers**

The Functional API enables creating custom layers through function composition:

```python
def residual_block(x, filters):
    shortcut = x
    x = tf.keras.layers.Conv2D(filters, 3, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.ReLU()(x)
    x = tf.keras.layers.Conv2D(filters, 3, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.Add()([x, shortcut])
    return tf.keras.layers.ReLU()(x)
```

**Advanced Layer Features**

Custom layers can implement sophisticated functionality:

- **Masking Support**: Handle variable-length sequences
- **Regularization**: Add custom regularization terms
- **Constraints**: Apply weight constraints during training
- **Multi-input/output**: Process multiple tensors simultaneously

