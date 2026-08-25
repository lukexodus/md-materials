## Module 6: Multi-Scale Features - Inception Networks


### 6.1 Inception Philosophy

- Multi-scale feature extraction
- Computational efficiency
- Network-in-network concept
- "Going deeper with convolutions"

### 6.2 Inception Module Design

**Naive Inception:**

- Parallel pathways: 1×1, 3×3, 5×5 convolutions, 3×3 pooling
- Concatenate outputs
- Computational explosion problem

**Inception v1 (GoogLeNet) Module:**

- 1×1 convolutions for dimensionality reduction
- Four parallel branches:
    1. 1×1 conv
    2. 1×1 conv → 3×3 conv
    3. 1×1 conv → 5×5 conv
    4. 3×3 MaxPool → 1×1 conv
- Channel concatenation
- Reduced parameters and computation

### 6.3 GoogLeNet (Inception v1) Architecture

- 22 layers deep
- 9 Inception modules
- Stem: initial convolutions and pooling
- Auxiliary classifiers (training only)
- Global average pooling (no FC layers)
- ~7 million parameters (12× fewer than AlexNet)
- Top-5 error: 6.67% (ILSVRC 2014)

### 6.4 Auxiliary Classifiers

- Attached at intermediate layers
- Combat vanishing gradient
- Act as regularizers
- Weighted loss contribution
- Removed during inference

### 6.5 Inception v2 and v3 Improvements

**Inception v2 innovations:**

- Batch normalization throughout
- Factorized convolutions (n×n → n×1 and 1×n)
- 5×5 replaced with two 3×3
- Asymmetric factorization (1×7, 7×1)

**Inception v3 additions:**

- RMSprop optimizer
- Label smoothing regularization
- Factorized 7×7 convolutions
- Auxiliary classifier batch norm
- Refined module designs

### 6.6 Inception v4 and Inception-ResNet

**Inception v4:**

- Uniform simplified architecture
- More Inception modules
- Cleaner design without compromises

**Inception-ResNet:**

- Residual connections + Inception modules
- Inception-ResNet-v1 and v2 variants
- Faster training convergence
- Scaling factors for residuals

### 6.7 Design Principles

- Avoid representational bottlenecks
- Higher dimensional representations before reductions
- Spatial aggregation over lower dimensions
- Balance width and depth

### 6.8 Computational Efficiency Analysis

- FLOPs comparison with VGG
- Parameter efficiency
- Inference speed considerations

### 6.9 Practical Applications

- When to use Inception architectures
- Transfer learning with Inception
- Modifications for different domains

---

