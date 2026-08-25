## Adaptive Learning Rate Methods


Adaptive optimizers automatically adjust learning rates based on historical gradient information, eliminating the need for manual learning rate tuning and providing parameter-specific adaptation.

**Key Points:**

- Adaptive methods maintain per-parameter learning rate adjustments
- These optimizers typically require additional memory to store gradient statistics
- Different adaptive methods use various approaches to estimate appropriate learning rates
- [Inference] Adaptive optimizers often converge faster initially but may have different generalization properties compared to SGD

**Adam Optimizer:**

```python
# Adam with default parameters
adam_optimizer = optim.Adam(
    model.parameters(),
    lr=0.001,
    betas=(0.9, 0.999),
    eps=1e-8,
    weight_decay=0
)

# AdamW (Adam with decoupled weight decay)
adamw_optimizer = optim.AdamW(
    model.parameters(),
    lr=0.001,
    betas=(0.9, 0.999),
    eps=1e-8,
    weight_decay=0.01
)
```

**RMSprop Implementation:**

```python
rmsprop_optimizer = optim.RMSprop(
    model.parameters(),
    lr=0.01,
    alpha=0.99,
    eps=1e-8,
    weight_decay=0,
    momentum=0,
    centered=False
)
```

**AdaGrad and Variants:** AdaGrad accumulates squared gradients over time, leading to diminishing learning rates. Variants like AdaDelta and RMSprop address this limitation by using exponential moving averages instead of cumulative sums.

**Advanced Adaptive Optimizers:**

```python
# Adabound - bridges gap between adaptive methods and SGD
# Note: Requires third-party implementation
# adabound_optimizer = AdaBound(model.parameters(), lr=0.001, final_lr=0.1)

# RAdam (Rectified Adam) - addresses Adam's warmup issues
# Available in some PyTorch extensions
```

