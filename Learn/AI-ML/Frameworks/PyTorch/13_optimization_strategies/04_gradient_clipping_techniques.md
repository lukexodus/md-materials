## Gradient Clipping Techniques


Gradient clipping prevents exploding gradients by constraining gradient magnitudes, which is particularly important for recurrent networks and deep architectures.

**Key Points:**

- Gradient clipping stabilizes training in networks prone to exploding gradients
- Clipping can be applied by norm or by value
- Proper clipping thresholds depend on network architecture and problem characteristics
- [Inference] Gradient clipping is essential for training very deep networks and RNNs

**Gradient Clipping Implementation:**

```python
# Clip gradients by norm
def clip_gradients_by_norm(model, max_norm=1.0):
    torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm)

# Clip gradients by value
def clip_gradients_by_value(model, clip_value=0.5):
    torch.nn.utils.clip_grad_value_(model.parameters(), clip_value)

# Training loop with gradient clipping
for epoch in range(num_epochs):
    for batch in dataloader:
        optimizer.zero_grad()
        loss = compute_loss(model, batch)
        loss.backward()
        
        # Apply gradient clipping
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        
        optimizer.step()
```

**Adaptive Gradient Clipping:**

```python
class AdaptiveGradientClipper:
    def __init__(self, model, percentile=10):
        self.model = model
        self.percentile = percentile
        self.gradient_history = []
        
    def clip_gradients(self, max_history=1000):
        # Calculate current gradient norm
        current_norm = torch.nn.utils.clip_grad_norm_(self.model.parameters(), float('inf'))
        
        # Update history
        self.gradient_history.append(current_norm.item())
        if len(self.gradient_history) > max_history:
            self.gradient_history.pop(0)
        
        # Determine adaptive threshold
        if len(self.gradient_history) > 10:
            threshold = np.percentile(self.gradient_history, 100 - self.percentile)
            torch.nn.utils.clip_grad_norm_(self.model.parameters(), threshold)
```

