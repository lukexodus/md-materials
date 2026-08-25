## Dense Layers and Activation Functions


Dense (fully-connected) layers form the foundation of most Sequential models, connecting every input to every output neuron.

**Dense Layer Configuration** Dense layers require specification of output dimensionality and optional parameters:

```python
# Basic dense layer
Dense(units=64, activation='relu')

# Dense layer with additional parameters
Dense(
    units=128,
    activation='relu',
    use_bias=True,
    kernel_initializer='glorot_uniform',
    bias_initializer='zeros',
    kernel_regularizer=tf.keras.regularizers.l2(0.01),
    bias_regularizer=None,
    activity_regularizer=None
)
```

**Weight Initialization Strategies** Proper weight initialization affects training convergence:

```python
# Common initializers
Dense(64, kernel_initializer='glorot_uniform')      # Xavier uniform
Dense(64, kernel_initializer='he_normal')           # He initialization
Dense(64, kernel_initializer='random_normal')       # Random normal
Dense(64, kernel_initializer=tf.keras.initializers.TruncatedNormal(stddev=0.1))
```

**Activation Functions** Activation functions introduce non-linearity enabling complex pattern learning:

```python
# Built-in activation functions
Dense(64, activation='relu')        # Rectified Linear Unit
Dense(64, activation='tanh')        # Hyperbolic tangent
Dense(64, activation='sigmoid')     # Sigmoid function
Dense(64, activation='softmax')     # Softmax for classification
Dense(64, activation='swish')       # Swish activation
Dense(64, activation='gelu')        # Gaussian Error Linear Unit

# Custom activation functions
def custom_activation(x):
    return tf.nn.leaky_relu(x, alpha=0.1)

Dense(64, activation=custom_activation)

# Separate activation layers
model = Sequential([
    Dense(64),
    tf.keras.layers.ReLU(),
    Dense(32),
    tf.keras.layers.LeakyReLU(alpha=0.1)
])
```

**Regularization in Dense Layers** Regularization techniques prevent overfitting:

```python
# L1/L2 regularization
Dense(64, kernel_regularizer=tf.keras.regularizers.l1(0.01))
Dense(64, kernel_regularizer=tf.keras.regularizers.l2(0.01))
Dense(64, kernel_regularizer=tf.keras.regularizers.l1_l2(l1=0.01, l2=0.01))

# Dropout regularization (separate layer)
model = Sequential([
    Dense(128, activation='relu'),
    Dropout(0.5),                    # 50% dropout rate
    Dense(64, activation='relu'),
    Dropout(0.3),
    Dense(10, activation='softmax')
])
```

