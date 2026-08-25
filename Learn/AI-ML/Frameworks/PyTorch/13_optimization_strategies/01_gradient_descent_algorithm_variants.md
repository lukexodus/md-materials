## Gradient Descent Algorithm Variants


Gradient descent variants differ primarily in how they utilize training data and compute parameter updates. Each variant presents trade-offs between computational efficiency, memory requirements, and convergence properties.

**Key Points:**

- Batch gradient descent uses the entire dataset for each update, providing stable but computationally expensive updates
- Stochastic gradient descent (SGD) uses single samples, offering fast updates with higher variance
- Mini-batch gradient descent balances computational efficiency with gradient estimate quality
- Momentum-based variants accumulate gradient information across iterations to improve convergence

**Stochastic Gradient Descent Implementation:**

```python
import torch
import torch.nn as nn
import torch.optim as optim

# Basic SGD with momentum
optimizer = optim.SGD(
    model.parameters(),
    lr=0.01,
    momentum=0.9,
    weight_decay=1e-4,
    nesterov=True
)

# Training loop with mini-batch SGD
for epoch in range(num_epochs):
    for batch_idx, (data, targets) in enumerate(dataloader):
        optimizer.zero_grad()
        outputs = model(data)
        loss = criterion(outputs, targets)
        loss.backward()
        optimizer.step()
```

**Momentum Variants:**

- Classical momentum: $v_t = \gamma v_{t-1} + \eta \nabla_\theta J(\theta)$
- Nesterov momentum: Computes gradients at the anticipated future position
- [Inference] Momentum typically improves convergence speed and helps navigate ravines in the loss landscape

Mini-batch gradient descent requires careful batch size selection, as larger batches provide more stable gradients but may reduce generalization capability and increase memory requirements.

