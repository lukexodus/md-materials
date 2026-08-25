## Gradient Explosion Handling


Gradient explosion occurs when gradients grow exponentially during backpropagation, leading to parameter updates that destabilize training. This phenomenon particularly affects deep networks, recurrent architectures, and models with multiplicative connections where gradients compound through multiple layers.

Gradient clipping provides the primary defense against gradient explosion. PyTorch implements both global norm clipping and individual parameter clipping strategies. Global norm clipping scales all gradients proportionally when their collective norm exceeds a threshold, preserving gradient directions while limiting magnitude.

```python
# Global gradient norm clipping
import torch.nn.utils as utils

def train_step(model, data, target, optimizer, clip_value=1.0):
    optimizer.zero_grad()
    output = model(data)
    loss = criterion(output, target)
    loss.backward()
    
    # Clip gradients by global norm
    utils.clip_grad_norm_(model.parameters(), clip_value)
    
    optimizer.step()
    return loss.item()
```

Individual parameter clipping applies thresholds to each parameter's gradient independently, useful when specific layers consistently produce problematic gradients. This approach may alter gradient directions but provides more granular control over parameter updates.

```python
# Individual gradient value clipping
utils.clip_grad_value_(model.parameters(), clip_value=0.5)
```

Gradient explosion detection enables dynamic response to training instabilities. Monitoring gradient norms and implementing adaptive clipping thresholds can prevent catastrophic parameter updates while maintaining training efficiency.

```python
def adaptive_gradient_clipping(model, base_clip=1.0, scale_factor=2.0):
    total_norm = 0
    for p in model.parameters():
        if p.grad is not None:
            param_norm = p.grad.data.norm(2)
            total_norm += param_norm.item() ** 2
    total_norm = total_norm ** (1. / 2)
    
    # Adaptive threshold based on current gradient norm
    clip_value = base_clip * (1 + total_norm / scale_factor)
    utils.clip_grad_norm_(model.parameters(), clip_value)
    
    return total_norm
```

Architecture-specific considerations influence gradient explosion susceptibility. Residual connections in ResNet architectures provide gradient highways that mitigate explosion risks. Attention mechanisms in transformers require careful weight initialization and layer normalization to prevent gradient instabilities. LSTM and GRU cells incorporate gating mechanisms that naturally regulate gradient flow but remain vulnerable to explosion in certain configurations.

