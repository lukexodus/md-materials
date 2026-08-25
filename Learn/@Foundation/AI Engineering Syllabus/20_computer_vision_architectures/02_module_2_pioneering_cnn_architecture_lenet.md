## Module 2: Pioneering CNN Architecture - LeNet


### 2.1 Historical Context

- Gradient-based learning history
- Character recognition challenges pre-CNN
- Yann LeCun's contributions
- MNIST dataset introduction

### 2.2 LeNet-5 Architecture

- Network structure (Conv-Pool-Conv-Pool-FC-FC-Output)
- Layer specifications:
    - C1: 6 feature maps, 5×5 kernels
    - S2: Subsampling (pooling) layer
    - C3: 16 feature maps with selective connectivity
    - S4: Second subsampling layer
    - C5: 120 feature maps
    - F6: 84 fully connected units
    - Output: 10 classes
- Activation functions used (Tanh)
- Training methodology
- Parameter count analysis

### 2.3 Key Innovations

- Sparse connectivity patterns
- Weight sharing across spatial locations
- Subsampling for spatial invariance
- End-to-end learning

### 2.4 Limitations and Historical Impact

- Limited to small images (32×32)
- Shallow architecture
- Computational constraints of era
- Foundation for modern CNNs
- Practical applications (check reading)

---

