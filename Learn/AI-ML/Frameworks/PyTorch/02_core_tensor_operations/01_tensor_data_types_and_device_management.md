## Tensor Data Types and Device Management


PyTorch tensors support multiple data types, each optimized for different computational scenarios. The primary data types include floating-point types (torch.float32, torch.float64, torch.float16, torch.bfloat16), integer types (torch.int8, torch.int16, torch.int32, torch.int64), boolean (torch.bool), and complex types (torch.complex64, torch.complex128). Data type selection significantly impacts memory usage, computational speed, and numerical precision.

Device management enables computation across CPUs, GPUs, and specialized hardware. Tensors can be moved between devices using .to(), .cuda(), .cpu() methods, or specified during creation with the device parameter. Mixed-precision training leverages different data types strategically, using float16 for forward passes and float32 for gradients to maintain numerical stability while reducing memory consumption.

**Key Points:**

- torch.float32 is the default floating-point type, balancing precision and performance
- torch.int64 is the default integer type for indexing operations
- Device placement affects memory locality and computational efficiency
- Automatic mixed precision (AMP) optimizes training by dynamically selecting appropriate data types

**Example:**

```python
# Data type specification and conversion
tensor_float = torch.tensor([1.0, 2.0, 3.0], dtype=torch.float16)
tensor_int = tensor_float.to(torch.int32)

# Device management
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
tensor_gpu = torch.tensor([1, 2, 3]).to(device)
tensor_cpu = tensor_gpu.cpu()

# Memory-efficient creation on specific device
large_tensor = torch.zeros(1000, 1000, device=device, dtype=torch.float16)
```

