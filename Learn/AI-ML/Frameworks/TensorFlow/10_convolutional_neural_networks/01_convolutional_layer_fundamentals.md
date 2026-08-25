## Convolutional Layer Fundamentals


### Core Operations

The convolutional layer performs a mathematical convolution operation between input data and learnable filters (kernels). Each filter slides across the input, computing dot products to produce feature maps that highlight specific patterns.

**Key components:**

- **Filters/Kernels**: Small matrices (typically 3x3, 5x5, or 7x7) containing learnable weights
- **Stride**: Step size for moving filters across input (commonly 1 or 2)
- **Padding**: Border handling strategy (valid, same, or custom padding)
- **Activation functions**: Non-linear transformations applied after convolution (ReLU, Leaky ReLU, etc.)

### Feature Detection Mechanisms

Convolutional layers detect hierarchical features through multiple filter applications. Early layers typically identify low-level features like edges and textures, while deeper layers combine these into complex patterns and objects.

**Mathematical foundation:**

```
Output[i,j] = Σ(Input[i+m, j+n] × Kernel[m,n]) + bias
```

### TensorFlow Implementation

```python
# Basic convolutional layer
conv_layer = tf.keras.layers.Conv2D(
    filters=32,
    kernel_size=(3, 3),
    strides=(1, 1),
    padding='same',
    activation='relu'
)

# Depthwise separable convolution
depthwise_conv = tf.keras.layers.SeparableConv2D(
    filters=64,
    kernel_size=(3, 3),
    padding='same'
)
```

