## CNN Building Blocks


The fundamental components of CNNs in PyTorch extend beyond basic convolution layers to include sophisticated building blocks that enable complex architectural designs.

**Core Layer Types:**

_Convolution Variants:_

- `nn.Conv2d`: Standard 2D convolution with configurable kernel size, stride, padding, and dilation
- `nn.Conv1d` and `nn.Conv3d`: Handle temporal and volumetric data respectively
- `nn.ConvTranspose2d`: Transposed convolutions for upsampling and generative tasks
- `nn.DepthwiseConv2d`: Separable convolutions for efficiency gains
- Dilated convolutions: Expand receptive fields without increasing parameters

_Pooling Operations:_

- `nn.MaxPool2d` and `nn.AvgPool2d`: Spatial downsampling with different aggregation strategies
- `nn.AdaptiveMaxPool2d`: Output-size-aware pooling for variable input dimensions
- Global pooling: Reduces spatial dimensions to single values per channel
- Fractional pooling: Non-integer stride pooling for fine-grained size control

_Normalization Layers:_

- `nn.BatchNorm2d`: Normalizes activations across batch dimension
- `nn.LayerNorm`: Channel-wise normalization independent of batch size
- `nn.GroupNorm`: Groups channels for normalization, balancing batch and layer norms
- `nn.InstanceNorm2d`: Per-sample normalization for style transfer applications

**Advanced Building Blocks:**

_Residual Connections:_

- Skip connections that enable gradient flow in deep networks
- Identity mappings that preserve information across layers
- Bottleneck designs that reduce computational complexity
- Dense connections that reuse feature representations

_Squeeze-and-Excitation Blocks:_

- Channel attention mechanisms that recalibrate feature responses
- Global pooling followed by channel-wise scaling
- Lightweight modules that improve representational capacity

_Separable Convolutions:_

- Depthwise separable convolutions that factorize standard convolutions
- Significant parameter and computation reductions
- Mobile-optimized designs for resource-constrained deployment

