## Image Classification Networks


### Classic Architectures

**LeNet-5**: Pioneer CNN architecture for handwritten digit recognition, establishing fundamental CNN principles.

**AlexNet**: Breakthrough architecture that popularized deep learning in computer vision, introducing ReLU activations and dropout regularization.

**VGG**: Demonstrated effectiveness of very deep networks using small convolutional filters uniformly throughout the architecture.

**ResNet**: Revolutionary introduction of residual connections, enabling training of networks with 100+ layers.

### Modern Architectures

**DenseNet**: Dense connectivity pattern where each layer connects to every other layer in a feed-forward fashion.

**MobileNet**: Efficient architecture using depthwise separable convolutions for mobile and embedded deployment.

**EfficientNet**: State-of-the-art architecture achieving superior accuracy-efficiency trade-offs through compound scaling.

### TensorFlow Implementation Example

```python
def create_resnet_block(x, filters, stride=1):
    shortcut = x
    
    # First conv layer
    x = tf.keras.layers.Conv2D(filters, 3, strides=stride, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.ReLU()(x)
    
    # Second conv layer
    x = tf.keras.layers.Conv2D(filters, 3, padding='same')(x)
    x = tf.keras.layers.BatchNormalization()(x)
    
    # Adjust shortcut if needed
    if stride != 1:
        shortcut = tf.keras.layers.Conv2D(filters, 1, strides=stride)(shortcut)
        shortcut = tf.keras.layers.BatchNormalization()(shortcut)
    
    # Add shortcut and apply activation
    x = tf.keras.layers.Add()([x, shortcut])
    x = tf.keras.layers.ReLU()(x)
    return x
```

