## Module 6: Learning Rate Scheduling


### 6.1 Foundations & Motivation

- Learning rate as critical hyperparameter
- Fixed learning rate limitations
- Training phase-dependent requirements
- Convergence vs exploration trade-off

### 6.2 Basic Scheduling Strategies

#### 6.2.1 Step Decay

- Discrete learning rate reduction
- Drop factor: γ (commonly 0.1)
- Step intervals: fixed epoch counts
- Manual vs automatic scheduling
- Multi-step decay: multiple reduction points

#### 6.2.2 Exponential Decay

- Continuous exponential reduction
- Formula: lr(t) = lr₀ × γᵗ
- Decay rate selection
- Smooth vs step-based comparison

#### 6.2.3 Linear Decay

- Linear reduction to minimum
- Formula: lr(t) = lr₀ × (1 - t/T)
- Minimum learning rate floor
- Training duration dependency

#### 6.2.4 Polynomial Decay

- Generalization of linear decay
- Formula: lr(t) = lr₀ × (1 - t/T)ᵖ
- Power parameter: p (commonly 0.5 or 2.0)
- Shape control: convex vs concave

### 6.3 Advanced Scheduling Methods

#### 6.3.1 Cosine Annealing

- Formula: lr(t) = lr_min + 0.5(lr_max - lr_min)(1 + cos(πt/T))
- Smooth decay curve
- Non-monotonic option with restarts
- SGDR: Stochastic Gradient Descent with Warm Restarts
- T_0 and T_mult parameters

#### 6.3.2 Warm Restarts (SGDR)

- Periodic learning rate resets
- Restart schedule: geometric or linear
- Snapshot ensembles opportunity
- Escaping local minima mechanism

#### 6.3.3 One Cycle Policy

- Three phases: warmup, annealing, fine-tuning
- Momentum scheduling: inverse to learning rate
- Fast convergence claims [empirical]
- Maximum learning rate determination via LR range test

#### 6.3.4 Cyclical Learning Rates (CLR)

- Triangular, triangular2, exp_range policies
- Base and maximum learning rate
- Step size: half-cycle length
- Mode variations: constant, linear, exponential

### 6.4 Warmup Strategies

#### 6.4.1 Linear Warmup

- Gradual increase from low learning rate
- Warmup steps/epochs: typically 1-10% of training
- Motivation: gradient instability early in training
- Formula: lr(t) = lr₀ × min(1, t/warmup_steps)

#### 6.4.2 Exponential Warmup

- Exponential increase to target learning rate
- Smoother transition
- Formula: lr(t) = lr₀ × (target_lr/lr₀)^(t/warmup_steps)

#### 6.4.3 Constant Warmup

- Fixed low learning rate initially
- Abrupt transition to target rate
- Simpler implementation

#### 6.4.4 Warmup Rationale

- Large batch training stability
- Adam/AdamW with transformers
- [Inference] Batch normalization statistics stabilization
- Gradient accumulation scenarios

### 6.5 Adaptive Learning Rate Methods

#### 6.5.1 ReduceLROnPlateau

- Validation metric-based reduction
- Patience parameter: epochs to wait
- Reduction factor: multiplicative decrease
- Mode: min or max metric monitoring
- Cooldown period: waiting after reduction

#### 6.5.2 Performance-Based Scheduling

- Dynamic adjustment based on loss curves
- Gradient magnitude monitoring
- Training/validation gap consideration
- [Implementation-dependent] Framework-specific methods

### 6.6 Optimizer-Specific Considerations

#### 6.6.1 SGD with Momentum

- Learning rate and momentum interaction
- Typical schedules: step decay, cosine annealing
- Momentum warming strategies

#### 6.6.2 Adam/AdamW

- Built-in adaptive rates
- External scheduling still beneficial
- Warmup importance for transformers
- Cosine annealing common practice
- Inverse square root schedule: lr(t) = lr₀ / √t

#### 6.6.3 Other Adaptive Optimizers

- RMSprop: external scheduling less common
- Adadelta: learning rate-free design
- Adagrad: automatic decay property
- [Inference] Adaptive + external scheduling redundancy

### 6.7 Architecture-Specific Schedules

#### 6.7.1 Convolutional Neural Networks

- Step decay popular: ImageNet-style
- Cosine annealing for longer training
- Multi-step milestones: [30, 60, 80] typical

#### 6.7.2 Transformers/Language Models

- Warmup crucial: prevents instability
- Inverse square root schedule
- Linear decay with warmup
- Cosine with warmup
- Polynomial decay

#### 6.7.3 Recurrent Neural Networks

- Gradient clipping interaction
- Conservative scheduling
- Teacher forcing schedule coordination

### 6.8 Theoretical Perspectives

#### 6.8.1 Optimization Landscape

- Learning rate effects on convergence
- Sharp vs flat minima
- [Research perspective] Generalization relationship

#### 6.8.2 Convergence Analysis

- Learning rate decay necessity for convergence
- Rate of decay requirements
- [Theoretical] Regret bounds in online learning

#### 6.8.3 Escaping Saddle Points

- Learning rate magnitude effects
- Noise interaction: batch size
- [Research area] Non-convex optimization theory

### 6.9 Practical Implementation

#### 6.9.1 Framework APIs

- PyTorch: torch.optim.lr_scheduler
    - StepLR, MultiStepLR, ExponentialLR
    - CosineAnnealingLR, CosineAnnealingWarmRestarts
    - ReduceLROnPlateau, OneCycleLR, CyclicLR
    - LambdaLR for custom schedules
- TensorFlow/Keras: tf.keras.optimizers.schedules
    - ExponentialDecay, PiecewiseConstantDecay
    - PolynomialDecay, InverseTimeDecay
    - CosineDecay, CosineDecayRestarts

#### 6.9.2 Custom Schedulers

- LambdaLR for arbitrary functions
- Learning rate logging
- Manual step() calling
- Scheduler state saving/loading

#### 6.9.3 Debugging & Monitoring

- Learning rate logging: TensorBoard, wandb
- Loss landscape visualization
- Convergence curve analysis
- Scheduler timing verification

### 6.10 Hyperparameter Selection

#### 6.10.1 Initial Learning Rate

- Grid search: powers of 10
- Learning rate range test (LR finder)
- Rule of thumb: 0.1 for SGD, 1e-3 for Adam
- Task and architecture dependency

#### 6.10.2 Schedule-Specific Hyperparameters

- Step decay: step size, gamma
- Cosine: T_max, eta_min
- OneCycle: max_lr, pct_start, div_factor
- Warmup: warmup_steps/epochs

#### 6.10.3 Tuning Strategies

- Start simple: step decay or cosine
- Warmup for transformers/large models
- Validation-based: ReduceLROnPlateau
- [Inference] Combined with early stopping

### 6.11 Advanced Topics

#### 6.11.1 Layer-Wise Learning Rates

- Discriminative fine-tuning
- Lower rates for earlier layers
- Transfer learning applications
- Implementation: parameter groups

#### 6.11.2 Learning Rate Rewinding

- Periodic resets in continual learning
- Catastrophic forgetting mitigation
- Multi-task learning applications

#### 6.11.3 Automated Scheduling

- Meta-learning for schedule discovery
- Population-based training (PBT)
- Neural architecture search integration
- [Research area] Learned optimizers

#### 6.11.4 Gradient-Based Adaptation

- Hypergradient descent
- Online learning rate adaptation
- [Advanced] Second-order information usage

---

