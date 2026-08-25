## Learning Rate Scheduling


Learning rate scheduling adjusts the learning rate during training to improve convergence and final performance. Proper scheduling can significantly impact training dynamics and model quality.

**Key Points:**

- Learning rate scheduling can improve convergence stability and final model performance
- Different scheduling strategies suit different problem types and training durations
- Schedulers can be step-based, time-based, or performance-based
- [Inference] Optimal scheduling often requires domain knowledge and empirical validation

**Common Scheduling Strategies:**

```python
# Step decay scheduler
step_scheduler = optim.lr_scheduler.StepLR(
    optimizer, 
    step_size=30, 
    gamma=0.1
)

# Exponential decay
exp_scheduler = optim.lr_scheduler.ExponentialLR(
    optimizer, 
    gamma=0.95
)

# Cosine annealing
cosine_scheduler = optim.lr_scheduler.CosineAnnealingLR(
    optimizer, 
    T_max=100, 
    eta_min=1e-6
)

# Reduce on plateau
plateau_scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, 
    mode='min', 
    factor=0.5, 
    patience=10,
    threshold=1e-4
)
```

**Advanced Scheduling Patterns:**

```python
# Warmup followed by cosine annealing
class WarmupCosineScheduler:
    def __init__(self, optimizer, warmup_epochs, max_epochs, base_lr, min_lr=1e-6):
        self.optimizer = optimizer
        self.warmup_epochs = warmup_epochs
        self.max_epochs = max_epochs
        self.base_lr = base_lr
        self.min_lr = min_lr
        
    def step(self, epoch):
        if epoch < self.warmup_epochs:
            lr = self.base_lr * (epoch + 1) / self.warmup_epochs
        else:
            progress = (epoch - self.warmup_epochs) / (self.max_epochs - self.warmup_epochs)
            lr = self.min_lr + (self.base_lr - self.min_lr) * 0.5 * (1 + math.cos(math.pi * progress))
        
        for param_group in self.optimizer.param_groups:
            param_group['lr'] = lr
```

**Cyclical Learning Rates:** Cyclical approaches alternate between low and high learning rates, potentially helping escape local minima and improving generalization.

