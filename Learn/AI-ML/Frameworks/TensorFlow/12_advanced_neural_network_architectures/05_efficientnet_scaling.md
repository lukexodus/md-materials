## EfficientNet Scaling


EfficientNet introduces compound scaling that uniformly scales network depth, width, and resolution with a set of fixed scaling coefficients. This systematic approach achieves superior accuracy-efficiency trade-offs compared to arbitrary scaling methods.

**Compound Scaling Formula:**

- Depth: d = α^φ
- Width: w = β^φ
- Resolution: r = γ^φ
- Constraint: α · β² · γ² ≈ 2

**EfficientNet Building Blocks:** Mobile inverted bottleneck convolutions (MBConv) serve as the primary building block, combining depthwise separable convolutions with squeeze-and-excitation optimization and residual connections.

**TensorFlow Implementation:**

```python
def squeeze_excitation(x, ratio=0.25):
    channels = x.shape[-1]
    squeeze = tf.keras.layers.GlobalAveragePooling2D()(x)
    squeeze = tf.keras.layers.Dense(int(channels * ratio), activation='relu')(squeeze)
    squeeze = tf.keras.layers.Dense(channels, activation='sigmoid')(squeeze)
    squeeze = tf.keras.layers.Reshape((1, 1, channels))(squeeze)
    return tf.keras.layers.Multiply()([x, squeeze])

def mbconv_block(x, output_filters, expansion_ratio, stride, se_ratio=0.25):
    input_filters = x.shape[-1]
    expanded_filters = input_filters * expansion_ratio
    
    # Expansion phase
    if expansion_ratio != 1:
        expanded = tf.keras.layers.Conv2D(expanded_filters, 1, activation='swish')(x)
        expanded = tf.keras.layers.BatchNormalization()(expanded)
    else:
        expanded = x
    
    # Depthwise convolution
    depthwise = tf.keras.layers.DepthwiseConv2D(3, strides=stride, padding='same')(expanded)
    depthwise = tf.keras.layers.BatchNormalization()(depthwise)
    depthwise = tf.keras.layers.Activation('swish')(depthwise)
    
    # Squeeze and excitation
    if se_ratio > 0:
        depthwise = squeeze_excitation(depthwise, se_ratio)
    
    # Output projection
    output = tf.keras.layers.Conv2D(output_filters, 1)(depthwise)
    output = tf.keras.layers.BatchNormalization()(output)
    
    # Skip connection
    if stride == 1 and input_filters == output_filters:
        return tf.keras.layers.Add()([x, output])
    return output
```

**Scaling Strategy Benefits:** Compound scaling maintains optimal balance between computational resources and model capacity across different scales. EfficientNet-B0 through B7 demonstrate consistent accuracy improvements with systematic resource scaling.

