## Popular Architecture Implementations


PyTorch's torchvision library provides reference implementations of landmark CNN architectures, each representing significant advances in computer vision.

**Classic Architectures:**

_LeNet and AlexNet:_

- Historical significance in establishing CNN effectiveness
- Simple sequential designs with alternating convolution and pooling
- ReLU activations and dropout for regularization

_VGG Networks:_

- Uniform architecture with small 3x3 convolutions
- Deep networks (11, 13, 16, 19 layers) with consistent design principles
- Demonstrates the importance of depth in representation learning

_ResNet Family:_

- Residual learning framework enabling extremely deep networks
- Skip connections that address vanishing gradient problems
- Variants: ResNet-18, 34, 50, 101, 152 with different depths and complexities
- Bottleneck designs in deeper variants for efficiency

**Modern Architectures:**

_DenseNet:_

- Dense connectivity pattern where each layer receives inputs from all preceding layers
- Feature reuse and parameter efficiency through concatenation
- Alleviates vanishing gradient and strengthens feature propagation

_EfficientNet:_

- Compound scaling that uniformly scales depth, width, and resolution
- Neural architecture search-derived base architecture
- State-of-the-art efficiency across multiple model sizes
- Systematic approach to scaling network dimensions

_Vision Transformers (ViT) Integration:_

- Transformer architectures adapted for vision tasks
- Patch-based tokenization of images
- Self-attention mechanisms for global context modeling
- Hybrid approaches combining CNN features with transformer processing

**Implementation Patterns:**

```python
# ResNet block implementation
class BasicBlock(nn.Module):
    def __init__(self, inplanes, planes, stride=1):
        super().__init__()
        self.conv1 = nn.Conv2d(inplanes, planes, 3, stride, 1, bias=False)
        self.bn1 = nn.BatchNorm2d(planes)
        self.conv2 = nn.Conv2d(planes, planes, 3, 1, 1, bias=False)
        self.bn2 = nn.BatchNorm2d(planes)
        self.shortcut = nn.Sequential()
        if stride != 1 or inplanes != planes:
            self.shortcut = nn.Sequential(
                nn.Conv2d(inplanes, planes, 1, stride, bias=False),
                nn.BatchNorm2d(planes)
            )
    
    def forward(self, x):
        out = F.relu(self.bn1(self.conv1(x)))
        out = self.bn2(self.conv2(out))
        out += self.shortcut(x)
        return F.relu(out)
```

