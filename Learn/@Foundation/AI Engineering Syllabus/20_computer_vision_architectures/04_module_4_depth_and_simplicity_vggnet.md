## Module 4: Depth and Simplicity - VGGNet


### 4.1 Design Philosophy

- Simplicity through uniformity
- Small receptive fields (3×3 convolutions)
- Increased depth hypothesis
- Homogeneous architecture

### 4.2 VGG Architecture Variants

- VGG-11, VGG-13, VGG-16, VGG-19
- VGG-16 detailed structure:
    - Block 1: 2× Conv(64, 3×3) + MaxPool
    - Block 2: 2× Conv(128, 3×3) + MaxPool
    - Block 3: 3× Conv(256, 3×3) + MaxPool
    - Block 4: 3× Conv(512, 3×3) + MaxPool
    - Block 5: 3× Conv(512, 3×3) + MaxPool
    - 3× FC layers (4096, 4096, 1000)
- Parameter count: ~138 million (VGG-16)

### 4.3 Key Design Choices

- Consistent 3×3 convolutions with stride 1
- 2×2 max pooling with stride 2
- Channel doubling after pooling
- Multiple 3×3 convs equivalent to larger receptive field
- Benefits of stacking small filters:
    - More non-linearity
    - Fewer parameters
    - Deeper networks

### 4.4 Ablation Studies

- Effect of depth (11 vs 16 vs 19 layers)
- 1×1 convolutions experiments
- Small filter superiority demonstration

### 4.5 Advantages and Limitations

- Strong transfer learning performance
- Feature extraction capability
- Limitations:
    - Large memory footprint
    - Slow training and inference
    - Massive FC layer parameters
    - Gradient flow challenges

### 4.6 VGG Impact

- Established "deeper is better" trend
- Standard backbone for many tasks
- Simplicity aids understanding and modification

---

