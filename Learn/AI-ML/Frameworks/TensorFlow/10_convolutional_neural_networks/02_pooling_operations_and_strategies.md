## Pooling Operations and Strategies


### Pooling Types

Pooling layers reduce spatial dimensions while retaining important information, providing translation invariance and computational efficiency.

**Max Pooling**: Selects maximum value from each pooling window, preserving strongest activations and providing robustness to small translations.

**Average Pooling**: Computes mean of pooling window values, providing smoother feature maps with less aggressive dimensionality reduction.

**Global Pooling**: Reduces entire feature map to single value per channel, commonly used before final classification layers.

### Advanced Pooling Techniques

**Adaptive Pooling**: Adjusts pooling window size to produce fixed output dimensions regardless of input size.

**Fractional Pooling**: Uses non-integer stride values for more gradual dimensionality reduction.

**Stochastic Pooling**: Randomly selects values based on activation probabilities during training.

### TensorFlow Implementation

```python
# Max pooling
max_pool = tf.keras.layers.MaxPool2D(
    pool_size=(2, 2),
    strides=(2, 2),
    padding='valid'
)

# Global average pooling
global_avg_pool = tf.keras.layers.GlobalAveragePooling2D()

# Adaptive pooling using resize
adaptive_pool = tf.keras.layers.Lambda(
    lambda x: tf.image.resize(x, [output_height, output_width])
)
```

