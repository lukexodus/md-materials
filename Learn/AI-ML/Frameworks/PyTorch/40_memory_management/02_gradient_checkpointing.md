## Gradient Checkpointing


Gradient checkpointing trades computation for memory by selectively storing only certain activations during the forward pass and recomputing others during backpropagation. This technique can reduce memory usage from O(n) to O(√n) where n is the number of layers.

PyTorch provides `torch.utils.checkpoint.checkpoint()` which wraps model segments and automatically handles the recomputation logic. The checkpointing function saves inputs to the wrapped segment and discards intermediate activations, recomputing them when gradients flow backward.

**Key Points:**

- Reduces peak memory usage by 30-80% depending on model architecture
- Increases training time by 15-25% due to recomputation overhead
- Most effective on models with high activation memory relative to parameter memory
- Works best with uniform layer architectures like transformers

**Example:**

```python
import torch
import torch.utils.checkpoint as checkpoint

class CheckpointedLayer(torch.nn.Module):
    def __init__(self, layer):
        super().__init__()
        self.layer = layer
    
    def forward(self, x):
        return checkpoint.checkpoint(self.layer, x, use_reentrant=False)

# Apply to transformer blocks
model = torch.nn.Sequential(*[
    CheckpointedLayer(TransformerBlock()) for _ in range(24)
])
```

Strategic checkpoint placement involves identifying memory bottlenecks through profiling and placing checkpoints at layers with high activation memory. Transformer models benefit from per-layer checkpointing, while CNNs often checkpoint at block boundaries.

