## Normalization Layer Types


**BatchNorm1d/2d/3d** Normalizes inputs across batch dimension, reducing internal covariate shift. Includes learnable scale and shift parameters. Different variants handle 1D (linear layers), 2D (images), and 3D (volumetric) data.

**LayerNorm** Normalizes across feature dimension instead of batch dimension. More stable for variable batch sizes and essential for transformer architectures. Maintains independence between samples.

**GroupNorm** Divides channels into groups and normalizes within each group. Bridges gap between LayerNorm and InstanceNorm, offering batch-size independence while maintaining spatial relationships.

**InstanceNorm1d/2d/3d** Normalizes each sample independently across spatial dimensions. Particularly effective for style transfer and generative models where batch statistics are unreliable.

**LocalResponseNorm** Implements local response normalization across nearby channels, inspired by biological neurons. Less commonly used in modern architectures.

