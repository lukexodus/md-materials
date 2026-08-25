## Residual Networks (ResNet)


ResNet introduced skip connections to solve the vanishing gradient problem in deep networks. The core innovation involves residual blocks where the output is the sum of the input and a learned transformation, allowing gradients to flow directly through skip connections during backpropagation.

**Key Architecture Components:**

- Identity shortcuts that skip one or more layers
- Bottleneck blocks using 1×1, 3×3, 1×1 convolutions for efficiency
- Batch normalization after each convolution
- ReLU activation functions

**TensorFlow Implementation:**

```python
def residual_block(x, filters, stride=1):
    shortcut = x
    x = tf.keras.layers.Conv2D(filters, 3, strides=stride, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.ReLU()(x)
    x = tf.keras.layers.Conv2D(filters, 3, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    
    if stride != 1:
        shortcut = tf.keras.layers.Conv2D(filters, 1, strides=stride)(shortcut)
    
    return tf.keras.layers.ReLU()(x + shortcut)
```

**Variants and Applications:** ResNet-18, ResNet-34, ResNet-50, ResNet-101, and ResNet-152 offer different depth options. ResNet-50 remains popular for transfer learning due to its balance of performance and computational efficiency. Wide ResNets increase width instead of depth, while ResNeXt introduces cardinality as a third dimension beyond depth and width.

