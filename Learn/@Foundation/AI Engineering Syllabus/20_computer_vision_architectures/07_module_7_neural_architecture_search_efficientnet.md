## Module 7: Neural Architecture Search - EfficientNet


### 7.1 Model Scaling Problem

- Traditional scaling dimensions: width, depth, resolution
- Ad-hoc scaling methods
- Compound scaling motivation
- Accuracy vs efficiency tradeoff

### 7.2 Compound Scaling Method

- Unified scaling of depth, width, resolution
- Scaling coefficient φ
- Depth: d = α^φ
- Width: w = β^φ
- Resolution: r = γ^φ
- Constraint: α · β² · γ² ≈ 2 (FLOP constraint)
- Grid search for α, β, γ

### 7.3 Neural Architecture Search (NAS)

- Search space definition (MBConv blocks)
- Multi-objective optimization (accuracy + efficiency)
- Platform-aware NAS
- EfficientNet-B0 baseline discovery
- AutoML framework overview

### 7.4 MBConv Building Block

- Mobile Inverted Bottleneck Convolution
- Expansion phase (1×1 conv, expand channels)
- Depthwise convolution (3×3 or 5×5)
- Squeeze-and-Excitation block
- Projection phase (1×1 conv, reduce channels)
- Skip connection (if dimensions match)
- Swish activation function

### 7.5 EfficientNet Architecture Family

**EfficientNet-B0 (baseline):**

- 7 MBConv stages
- Progressive channel expansion
- Varying kernel sizes (3×3, 5×5)
- SE ratio: 0.25
- ~5.3M parameters

**Scaling to B1-B7:**

- B0: baseline (224×224)
- B1: φ=1 (240×240)
- B2: φ=1.1 (260×260)
- B3: φ=1.2 (300×300)
- B4: φ=1.4 (380×380)
- B5: φ=1.6 (456×456)
- B6: φ=1.8 (528×528)
- B7: φ=2.0 (600×600)

### 7.6 Key Innovations

- Systematic compound scaling
- MBConv efficiency
- Squeeze-and-Excitation attention
- Swish activation (smooth, non-monotonic)
- Balanced scaling across dimensions

### 7.7 Performance Analysis

- Parameter efficiency (fewer params, better accuracy)
- FLOP efficiency
- Transfer learning performance
- Comparison with ResNet, Inception
- Accuracy-efficiency Pareto frontier

### 7.8 EfficientNet Variants

- EfficientNet-Lite (on-device inference)
- EfficientNet-EdgeTPU (hardware-specific)
- EfficientNetV2 improvements:
    - Training-aware NAS
    - Progressive learning
    - Fused-MBConv blocks
    - Faster training

### 7.9 Depthwise Separable Convolutions

- Depthwise convolution (per-channel spatial)
- Pointwise convolution (1×1 cross-channel)
- Computational savings analysis
- Parameter reduction

### 7.10 Practical Considerations

- Training recipes and augmentation
- Regularization strategies (dropout, stochastic depth)
- Transfer learning best practices
- Hardware deployment optimization

---

