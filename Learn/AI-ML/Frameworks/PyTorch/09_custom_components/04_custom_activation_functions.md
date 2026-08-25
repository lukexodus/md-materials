## Custom Activation Functions


Custom activation functions enable exploration of novel nonlinearities and can be tailored to specific problem domains or architectural requirements. PyTorch supports both functional implementations and parameterized activation functions with learnable parameters.

**Key Points:**

- Custom activations should maintain differentiability for gradient-based optimization
- Parameterized activations can adapt their behavior during training
- Activation functions should handle numerical stability considerations
- Custom activations can incorporate domain-specific constraints or properties

**Implementation Examples:**

```python
class SwishActivation(nn.Module):
    def __init__(self, beta=1.0, learnable=False):
        super().__init__()
        if learnable:
            self.beta = nn.Parameter(torch.tensor(beta))
        else:
            self.register_buffer('beta', torch.tensor(beta))
    
    def forward(self, x):
        return x * torch.sigmoid(self.beta * x)

class GatedLinearUnit(nn.Module):
    def __init__(self, input_dim):
        super().__init__()
        self.gate_projection = nn.Linear(input_dim, input_dim)
        
    def forward(self, x):
        gate = torch.sigmoid(self.gate_projection(x))
        return x * gate

# Functional implementation for stateless activations
def mish_activation(x):
    return x * torch.tanh(torch.nn.functional.softplus(x))
```

Advanced custom activations can incorporate adaptive thresholds, multi-modal behaviors, and specialized properties like monotonicity or bounded outputs depending on application requirements.

