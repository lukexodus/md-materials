## CNN Architecture Patterns


### Basic Building Blocks

**Convolutional Block**: Sequential combination of convolution, batch normalization, and activation layers.

**Residual Block**: Introduces skip connections allowing information to bypass layers, addressing vanishing gradient problem.

**Inception Block**: Parallel convolutions with different kernel sizes, capturing multi-scale features simultaneously.

**Depthwise Separable Block**: Factorizes standard convolution into depthwise and pointwise operations for efficiency.

### Common Architecture Families

**VGG Pattern**: Deep networks using small (3x3) filters with increasing channel depth.

**ResNet Pattern**: Residual connections enabling very deep networks (50+ layers).

**DenseNet Pattern**: Dense connections where each layer receives inputs from all previous layers.

**EfficientNet Pattern**: Compound scaling of depth, width, and resolution with neural architecture search optimization.

### Design Principles

Networks typically follow patterns of increasing channel depth while decreasing spatial dimensions. Feature map sizes commonly follow powers of 2 (224→112→56→28→14→7) for computational efficiency.

