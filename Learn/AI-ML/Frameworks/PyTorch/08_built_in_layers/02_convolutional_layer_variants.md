## Convolutional Layer Variants


**1D Convolution (torch.nn.Conv1d)** Applies convolution over temporal or sequential data. Used in time series analysis, audio processing, and text classification. Configurable kernel size, stride, padding, dilation, and groups.

**2D Convolution (torch.nn.Conv2d)** Standard convolution for image processing and computer vision tasks. Supports various kernel sizes, multiple input/output channels, stride patterns, padding modes (zero, reflect, replicate), and grouped convolutions for efficiency.

**3D Convolution (torch.nn.Conv3d)** Extends convolution to volumetric data like video sequences or medical imaging. Maintains temporal/depth dimension relationships while applying spatial convolutions.

**Transposed Convolution Layers** Conv1d/2d/3dTranspose perform upsampling through learnable deconvolution. Essential for generative models, segmentation networks, and encoder-decoder architectures.

**Depthwise and Separable Convolutions** Achieved through groups parameter in standard convolution layers. Reduces computational cost while maintaining representational capacity, particularly valuable for mobile and embedded applications.

