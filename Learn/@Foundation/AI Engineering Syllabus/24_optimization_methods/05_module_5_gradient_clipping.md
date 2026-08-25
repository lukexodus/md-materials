## Module 5: Gradient Clipping


### 5.1 Motivation and Problem Statement

- Exploding gradients in RNNs
- Gradient magnitude distributions
- Training instability symptoms
- When clipping is necessary

### 5.2 Clipping Strategies

- Value clipping (element-wise)
- Norm clipping (global)
- Adaptive clipping thresholds
- Per-layer vs. global clipping

### 5.3 Norm-Based Clipping

- L2 norm clipping derivation
- Threshold selection
- Gradient direction preservation
- Impact on convergence

### 5.4 Gradient Clipping Variants

- Adaptive gradient clipping (AGC)
- Clipping by value
- Clipping by percentile
- Layer-wise adaptive clipping

### 5.5 Theoretical Analysis

- Effect on convergence guarantees
- Bias introduction
- Interaction with optimization algorithms
- Gradient noise and clipping

### 5.6 Implementation

- PyTorch torch.nn.utils.clip_grad_norm_
- TensorFlow tf.clip_by_global_norm
- Custom clipping implementations
- Performance considerations

### 5.7 Best Practices

- Setting clip thresholds
- Monitoring gradient norms
- Clipping + learning rate scheduling
- Domain-specific guidelines (NLP, vision, RL)

### 5.8 Alternatives to Clipping

- Gradient normalization
- Batch normalization effects
- Layer normalization
- Careful initialization

---

