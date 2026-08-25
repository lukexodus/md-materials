## Module System and Parameter Management


**nn.Module Foundation**

The `torch.nn.Module` class serves as the base class for all neural network components in PyTorch. It provides a unified interface for defining, organizing, and managing neural network layers and their parameters.

```python
import torch.nn as nn

class CustomLayer(nn.Module):
    def __init__(self, input_size, output_size):
        super(CustomLayer, self).__init__()
        self.linear = nn.Linear(input_size, output_size)
        self.activation = nn.ReLU()
    
    def forward(self, x):
        return self.activation(self.linear(x))
```

**Parameter Registration**

PyTorch automatically registers parameters and sub-modules when they are assigned as attributes to a Module. This automatic registration enables parameter discovery, gradient computation, and state management.

**Parameter Types**

The Module system distinguishes between different types of stored values:

- **Parameters**: Learnable tensors that require gradients (weights, biases)
- **Buffers**: Non-learnable tensors that should be part of model state (running statistics, constants)
- **Sub-modules**: Nested Module instances that contain their own parameters and buffers

```python
class ModelWithBuffer(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = nn.Linear(10, 5)
        # Register buffer (non-learnable but part of model state)
        self.register_buffer('running_mean', torch.zeros(5))
        # Register parameter (learnable)
        self.register_parameter('custom_weight', nn.Parameter(torch.randn(5, 3)))
```

**Parameter Access and Manipulation**

The Module system provides comprehensive methods for parameter access and manipulation:

```python
# Access all parameters
for name, param in model.named_parameters():
    print(f"{name}: {param.shape}")

# Access specific parameter groups
optimizer = torch.optim.Adam([
    {'params': model.encoder.parameters(), 'lr': 1e-3},
    {'params': model.decoder.parameters(), 'lr': 1e-4}
])
```

**State Dictionary Management**

PyTorch uses state dictionaries to serialize and deserialize model states, enabling model saving, loading, and transfer learning:

```python
# Save model state
torch.save(model.state_dict(), 'model.pth')

# Load model state
model.load_state_dict(torch.load('model.pth'))

# Transfer learning with partial loading
pretrained_dict = torch.load('pretrained.pth')
model_dict = model.state_dict()
pretrained_dict = {k: v for k, v in pretrained_dict.items() if k in model_dict}
model_dict.update(pretrained_dict)
model.load_state_dict(model_dict)
```

**Module Modes and Context**

Modules support different execution modes that affect behavior during training versus inference:

```python
model.train()    # Set to training mode
model.eval()     # Set to evaluation mode

# Context managers for temporary mode changes
with model.eval():
    output = model(input)  # Inference mode temporarily
```

**Key Points:**

- All neural network components should inherit from nn.Module for proper integration
- Parameter registration happens automatically through attribute assignment
- State dictionaries provide a standardized way to serialize model parameters
- Module modes (train/eval) control layer behavior like dropout and batch normalization

