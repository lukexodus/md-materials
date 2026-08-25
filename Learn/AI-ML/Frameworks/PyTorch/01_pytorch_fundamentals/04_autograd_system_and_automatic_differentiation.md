## Autograd System and Automatic Differentiation


**Automatic Differentiation Concept**

PyTorch's autograd system provides automatic differentiation capabilities that enable gradient-based optimization algorithms. This system tracks operations performed on tensors and builds a computational graph for efficient gradient computation.

**Gradient Tracking**

Gradient tracking is controlled through the `requires_grad` attribute. When set to True, PyTorch tracks all operations performed on the tensor and enables gradient computation.

```python
x = torch.tensor([2.0], requires_grad=True)
y = x ** 2
z = y * 3

z.backward()  # Compute gradients
print(x.grad)  # Access computed gradient
```

**Gradient Computation Process**

The autograd system uses reverse-mode automatic differentiation (backpropagation) to compute gradients efficiently. This process involves:

1. Forward pass: Computing function values while building computational graph
2. Backward pass: Traversing graph in reverse to compute gradients using chain rule
3. Gradient accumulation: Storing computed gradients in tensor's `.grad` attribute

**Context Management**

PyTorch provides context managers for controlling gradient computation:

```python
# Disable gradient computation
with torch.no_grad():
    output = model(input)

# Enable gradient computation for inference-only tensors
with torch.enable_grad():
    output = model(input)
```

**Key Points:**

- Gradients accumulate by default; call `.zero_grad()` to clear them
- Only floating-point tensors can require gradients
- Autograd is thread-safe but not process-safe
- Custom gradient functions can be implemented using `torch.autograd.Function`

