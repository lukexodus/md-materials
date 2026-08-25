## MobileNet Architectures


MobileNet architectures prioritize computational efficiency for mobile and embedded deployment while maintaining reasonable accuracy. The core innovation involves depthwise separable convolutions that dramatically reduce computational cost.

**Depthwise Separable Convolutions:** Standard convolution operations are factorized into depthwise convolution followed by pointwise convolution, reducing parameters and computations by factors of 8-9 compared to standard convolutions.

**MobileNet v1 Features:**

- Depthwise separable convolutions throughout the network
- Width multiplier (α) for scaling model size
- Resolution multiplier (ρ) for input image scaling
- Global average pooling instead of fully connected layers

**MobileNet v2 Improvements:**

- Inverted residual blocks with linear bottlenecks
- Expansion layers that increase dimensionality before depthwise convolution
- Linear activation in bottleneck layers to preserve information

**TensorFlow Implementation:**

```python
def depthwise_separable_conv(x, filters, stride=1):
    # Depthwise convolution
    x = tf.keras.layers.DepthwiseConv2D(3, strides=stride, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.ReLU()(x)
    
    # Pointwise convolution
    x = tf.keras.layers.Conv2D(filters, 1)(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.ReLU()(x)
    return x

def inverted_residual_block(x, expansion_factor, output_dim, stride):
    input_dim = x.shape[-1]
    
    # Expansion
    expanded = tf.keras.layers.Conv2D(input_dim * expansion_factor, 1, activation='relu')(x)
    
    # Depthwise
    depthwise = tf.keras.layers.DepthwiseConv2D(3, strides=stride, padding='same')(expanded)
    depthwise = tf.keras.layers.BatchNormalization()(depthwise)
    depthwise = tf.keras.layers.ReLU()(depthwise)
    
    # Projection
    projection = tf.keras.layers.Conv2D(output_dim, 1)(depthwise)
    projection = tf.keras.layers.BatchNormalization()(projection)
    
    # Skip connection
    if stride == 1 and input_dim == output_dim:
        return tf.keras.layers.Add()([x, projection])
    return projection
```

**MobileNet v3 Enhancements:**

- Neural Architecture Search (NAS) for optimal layer configurations
- Squeeze-and-excitation blocks for channel attention
- Hard-swish activation function replacing ReLU in deeper layers
- Platform-aware optimization for different hardware targets

