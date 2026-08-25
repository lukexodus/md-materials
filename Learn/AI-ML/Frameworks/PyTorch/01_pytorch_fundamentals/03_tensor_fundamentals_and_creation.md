## Tensor Fundamentals and Creation


**Tensor Concept**

Tensors are the fundamental data structure in PyTorch, representing multi-dimensional arrays that can be processed on both CPUs and GPUs. They are similar to NumPy arrays but with additional capabilities for automatic differentiation and GPU acceleration.

**Tensor Creation Methods**

PyTorch provides multiple approaches for tensor creation:

```python
import torch

# Direct creation from data
tensor_from_list = torch.tensor([1, 2, 3, 4])
tensor_from_numpy = torch.from_numpy(numpy_array)

# Factory functions
zeros_tensor = torch.zeros(3, 4)
ones_tensor = torch.ones(2, 3)
random_tensor = torch.randn(2, 3)  # Normal distribution
uniform_tensor = torch.rand(2, 3)   # Uniform distribution

# Range creation
range_tensor = torch.arange(0, 10, 2)
linspace_tensor = torch.linspace(0, 1, 100)
```

**Tensor Properties**

Every tensor has several important attributes that define its characteristics:

- **shape/size**: Dimensions of the tensor
- **dtype**: Data type (float32, int64, etc.)
- **device**: Location (CPU or specific GPU)
- **requires_grad**: Whether to track gradients for automatic differentiation

**Tensor Operations**

PyTorch supports extensive tensor operations including element-wise operations, linear algebra functions, and broadcasting. Operations can be performed in-place or create new tensors.

**Key Points:**

- Tensors support broadcasting similar to NumPy arrays
- In-place operations end with underscore (e.g., `tensor.add_()`)
- Memory sharing between tensors can be controlled and monitored
- Tensor operations are optimized for both CPU and GPU execution

