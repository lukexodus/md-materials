## Module 5: Residual Learning - ResNet


### 5.1 The Degradation Problem

- Training deeper networks difficulty
- Degradation vs overfitting
- Plain networks performance plateau
- Identity mapping concept

### 5.2 Residual Learning Framework

- Residual blocks/shortcuts
- Skip connections theory
- Identity mapping H(x) = F(x) + x
- Learning residual function F(x) = H(x) - x
- Easier optimization hypothesis

### 5.3 ResNet Architecture Variants

- ResNet-18, ResNet-34 (Basic blocks)
- ResNet-50, ResNet-101, ResNet-152 (Bottleneck blocks)

### 5.4 Building Blocks

**Basic Block (ResNet-18/34):**

- 3×3 conv → BN → ReLU → 3×3 conv → BN → (+) → ReLU
- Skip connection adds input

**Bottleneck Block (ResNet-50+):**

- 1×1 conv (reduce) → 3×3 conv → 1×1 conv (expand) → BN → (+) → ReLU
- 1×1 convolutions reduce/restore dimensions
- Computational efficiency

### 5.5 ResNet-50 Detailed Architecture

- Conv1: 7×7, 64, stride 2
- MaxPool: 3×3, stride 2
- Stage 2: 3 bottleneck blocks (64-64-256 channels)
- Stage 3: 4 bottleneck blocks (128-128-512)
- Stage 4: 6 bottleneck blocks (256-256-1024)
- Stage 5: 3 bottleneck blocks (512-512-2048)
- Global Average Pooling
- FC 1000
- ~25 million parameters

### 5.6 Technical Details

- Batch normalization placement
- Projection shortcuts for dimension matching
- No dropout used
- Data augmentation strategy
- Training hyperparameters

### 5.7 Key Innovations and Analysis

- Enables training 100+ layer networks
- Gradient flow through skip connections
- Identity mappings preserve information
- Ensemble interpretation [Inference]
- Feature reuse across layers

### 5.8 ResNet Variants and Extensions

- Pre-activation ResNet (BN-ReLU-Conv ordering)
- Wide ResNet (wider blocks, fewer layers)
- ResNeXt (grouped convolutions, cardinality)
- ResNet-D (improved downsampling)
- Squeeze-and-Excitation ResNet (SE-ResNet)

### 5.9 Impact and Applications

- Won ILSVRC 2015 (3.57% top-5 error)
- Standard backbone for detection/segmentation
- Transfer learning effectiveness
- Theoretical implications for deep learning

---

