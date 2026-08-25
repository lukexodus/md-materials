## Complex Model Architectures


### Non-Sequential Architecture Patterns

Complex architectures deviate from linear layer sequences through skip connections, attention mechanisms, and hierarchical feature extraction patterns. The Functional API enables explicit specification of layer relationships and data flow paths that create sophisticated computational graphs.

**Key Points:**

- Layer connectivity graphs represent arbitrary relationships between network components
- Skip connections enable gradient flow across multiple network depths through residual pathways
- Attention mechanisms create dynamic feature weighting based on input relationships
- Hierarchical architectures combine multiple resolution levels for comprehensive feature extraction
- Graph-based model representation enables visualization and analysis of network topology

### Advanced Architectural Components

Modern architectures incorporate specialized components including attention layers, normalization mechanisms, and activation functions that require precise connectivity control. The Functional API provides the flexibility to implement these components with custom connection patterns.

**Key Points:**

- Multi-head attention requires parallel processing paths with different learned parameters
- Layer normalization placement affects training dynamics and model performance
- Activation function positioning influences gradient flow and feature learning
- Dropout layer placement requires strategic positioning for effective regularization
- [Inference] Architecture complexity correlates with computational requirements and memory usage

**Examples:**

```python
# Complex architecture with skip connections
inputs = tf.keras.Input(shape=(224, 224, 3))

# Initial convolution block
x = tf.keras.layers.Conv2D(64, 7, strides=2, padding='same')(inputs)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.ReLU()(x)

# Residual block with skip connection
residual = x
x = tf.keras.layers.Conv2D(64, 3, padding='same')(x)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.ReLU()(x)
x = tf.keras.layers.Conv2D(64, 3, padding='same')(x)
x = tf.keras.layers.BatchNormalization()(x)

# Skip connection addition
x = tf.keras.layers.Add()([x, residual])
x = tf.keras.layers.ReLU()(x)

outputs = tf.keras.layers.GlobalAveragePooling2D()(x)
outputs = tf.keras.layers.Dense(1000, activation='softmax')(outputs)

model = tf.keras.Model(inputs=inputs, outputs=outputs)
```

