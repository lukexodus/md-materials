## Module 3: Adaptive Learning Rate Methods


### 3.1 AdaGrad

- Per-parameter learning rates
- Accumulation of squared gradients
- Sparse data optimization
- Learning rate decay behavior
- Limitations and failure modes

### 3.2 RMSProp

- Exponential moving average of squared gradients
- Addressing AdaGrad's decay problem
- Hyperparameter selection (decay rate)
- Non-stationary objectives
- Hinton's lecture notes context

### 3.3 AdaDelta

- Adaptive learning rate without manual tuning
- Accumulation window approach
- Unit correction mechanism
- Hyperparameter-free motivation
- Practical performance

### 3.4 Adam (Adaptive Moment Estimation)

- First and second moment estimates
- Bias correction mechanism
- Hyperparameter defaults (β₁, β₂, ε)
- Theoretical foundations
- Widespread adoption reasons

### 3.5 Adam Variants and Improvements

- AdamW (decoupled weight decay)
- AMSGrad (fixing convergence issues)
- AdaBound (adaptive to SGD transition)
- RAdam (rectified Adam with warmup)
- Nadam (Nesterov-accelerated Adam)
- AdamP (projected Adam)
- Adafactor (memory-efficient Adam)

### 3.6 Comparison and Selection

- Convergence speed comparisons
- Generalization performance
- Memory requirements
- Domain-specific preferences
- Empirical benchmark results

### 3.7 Theoretical Analysis

- Convergence proofs and counterexamples
- Regret bounds
- Non-convex convergence guarantees
- Adaptive methods limitations

### 3.8 Implementation Details

- Efficient computation strategies
- Memory layout optimization
- Mixed precision considerations
- Distributed training adaptations

---

