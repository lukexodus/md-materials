## Numerical Optimization Tricks


Numerical optimization in PyTorch benefits from various mathematical techniques that enhance convergence stability and training robustness. These approaches address common numerical challenges while improving optimization landscape navigation.

Learning rate scheduling prevents optimization instabilities caused by inappropriate step sizes. Adaptive schedules reduce learning rates when training progress stagnates, while warm-up phases gradually increase learning rates to prevent early training instabilities.

```python
import torch.optim.lr_scheduler as lr_scheduler

# Combined warm-up and decay scheduling
class WarmupCosineScheduler:
    def __init__(self, optimizer, warmup_steps, total_steps, max_lr=1e-3, min_lr=1e-6):
        self.optimizer = optimizer
        self.warmup_steps = warmup_steps
        self.total_steps = total_steps
        self.max_lr = max_lr
        self.min_lr = min_lr
        self.current_step = 0
    
    def step(self):
        if self.current_step < self.warmup_steps:
            # Linear warmup
            lr = self.max_lr * (self.current_step / self.warmup_steps)
        else:
            # Cosine decay
            progress = (self.current_step - self.warmup_steps) / (self.total_steps - self.warmup_steps)
            lr = self.min_lr + (self.max_lr - self.min_lr) * 0.5 * (1 + math.cos(math.pi * progress))
        
        for param_group in self.optimizer.param_groups:
            param_group['lr'] = lr
        
        self.current_step += 1
        return lr
```

Numerical stability in loss computation requires careful handling of mathematical operations prone to overflow or underflow. Log-softmax computations benefit from numerical stabilization techniques that prevent intermediate overflow while maintaining mathematical correctness.

```python
# Numerically stable implementations
def stable_log_softmax(logits, dim=-1):
    # Subtract max for numerical stability
    max_logits = torch.max(logits, dim=dim, keepdim=True)[0]
    stable_logits = logits - max_logits
    log_sum_exp = torch.logsumexp(stable_logits, dim=dim, keepdim=True)
    return stable_logits - log_sum_exp

def stable_cross_entropy(predictions, targets, epsilon=1e-8):
    # Clip predictions to prevent log(0)
    predictions = torch.clamp(predictions, epsilon, 1.0 - epsilon)
    return -torch.sum(targets * torch.log(predictions))
```

Optimizer-specific numerical considerations affect training stability. Adam's adaptive learning rates can become extremely small due to accumulated gradient statistics, leading to effective learning rate collapse. AMSGrad addresses this issue by maintaining maximum gradient statistics rather than exponential moving averages.

```python
# Robust Adam configuration
optimizer = torch.optim.Adam(
    model.parameters(),
    lr=1e-3,
    betas=(0.9, 0.999),  # Conservative momentum parameters
    eps=1e-8,  # Numerical stability constant
    weight_decay=1e-4,  # L2 regularization
    amsgrad=True  # Maintain max gradient statistics
)
```

Second-order optimization methods provide enhanced numerical properties through curvature information utilization. L-BFGS offers quasi-Newton optimization with improved convergence properties, though computational requirements limit its applicability to smaller models or specific training phases.

```python
def lbfgs_training_step(model, data, target, optimizer):
    def closure():
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        loss.backward()
        return loss
    
    optimizer.step(closure)
```

