## Module 3: Batch Normalization


### 3.1 Foundations & Motivation

- Internal covariate shift hypothesis
- Training instability in deep networks
- Gradient flow improvement
- Relationship to input normalization

### 3.2 Batch Normalization Mechanism

#### 3.2.1 Forward Pass

- Per-batch statistics: mean and variance computation
- Normalization: zero mean, unit variance
- Learnable affine parameters: γ (scale), β (shift)
- Complete transformation equations
- Numerical stability: epsilon term

#### 3.2.2 Backward Pass

- Gradient computation through normalization
- Chain rule application
- Gradient flow analysis
- Computational graph

#### 3.2.3 Inference Mode

- Running statistics: exponential moving average
- Momentum parameter for statistics update
- Fixed statistics during evaluation
- Train/eval mode switching

### 3.3 Placement & Architecture Integration

#### 3.3.1 Layer Positioning

- Before vs after activation function
- Original paper recommendation: before activation
- Common practice: debate and variations
- Impact on network expressiveness

#### 3.3.2 Architecture-Specific Considerations

- Batch normalization in CNNs: spatial statistics
- Batch normalization in RNNs: challenges
- Batch normalization in residual networks
- Interaction with skip connections

### 3.4 Benefits & Effects

#### 3.4.1 Training Improvements

- Higher learning rates: improved convergence
- Reduced sensitivity to initialization
- Gradient flow enhancement
- Acts as regularization [Inference]

#### 3.4.2 Regularization Effects

- Noise introduced by batch statistics
- Interaction between samples in batch
- Comparison to explicit regularization
- [Inference] Generalization improvement mechanisms

### 3.5 Limitations & Challenges

#### 3.5.1 Batch Size Dependency

- Small batch problems: noisy statistics
- Micro-batch training difficulties
- Distributed training complications
- Ghost batch normalization

#### 3.5.2 Domain-Specific Issues

- RNN training: different sequence lengths
- Online learning: single sample scenarios
- Domain shift: train/test distribution mismatch
- Style information loss in GANs

### 3.6 Batch Normalization Variants

#### 3.6.1 Layer Normalization

- Normalization across features, not batch
- Independence from batch size
- Application in transformers and RNNs
- Position in architecture

#### 3.6.2 Instance Normalization

- Per-sample, per-channel normalization
- Style transfer applications
- Image generation networks
- Independence from other samples

#### 3.6.3 Group Normalization

- Channel grouping strategy
- Middle ground: batch and layer norm
- Batch size independence
- Computer vision applications

#### 3.6.4 Weight Normalization

- Reparameterization: magnitude and direction
- Decoupling weight vector properties
- Convergence improvements
- Computational efficiency

#### 3.6.5 Other Variants

- Batch Renormalization: correcting batch statistics
- Switchable Normalization: learnable combination
- Filter Response Normalization (FRN)
- Adaptive Instance Normalization (AdaIN): style control
- Conditional Batch Normalization

### 3.7 Theoretical Analysis

#### 3.7.1 Why Batch Normalization Works

- Internal covariate shift debate
- Loss landscape smoothing [research perspective]
- Gradient predictiveness improvement
- Length-direction decoupling

#### 3.7.2 Optimization Perspective

- Effect on loss surface geometry
- Lipschitz constant reduction
- Second-order optimization connections

### 3.8 Implementation Details

#### 3.8.1 Framework Implementation

- PyTorch: nn.BatchNorm1d/2d/3d
- TensorFlow/Keras: BatchNormalization layer
- Parameter tracking: γ, β, running mean/var
- Training mode handling

#### 3.8.2 Computational Considerations

- Memory overhead
- Forward/backward pass costs
- Synchronization in distributed training
- Mixed precision training interactions

### 3.9 Practical Guidelines

- When to use batch normalization
- Initialization strategies with batch norm
- Learning rate adjustment recommendations
- Debugging batch normalization issues
- Batch size selection
- Replacing batch norm: when and why

---

