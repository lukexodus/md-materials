## Tensor Manipulation and Reshaping


Tensor reshaping operations modify tensor dimensions without changing the underlying data order. The view() method creates a new tensor sharing the same data with a different shape, while reshape() provides similar functionality but may create a copy if the tensor is not contiguous. Understanding memory layout and contiguity is crucial for efficient reshaping operations.

Permutation operations like transpose() and permute() rearrange tensor dimensions, affecting memory layout and subsequent operation performance. The squeeze() and unsqueeze() methods remove or add dimensions of size 1, respectively, enabling dimension alignment for broadcasting operations.

Advanced manipulation includes torch.stack() for concatenating tensors along a new dimension, torch.cat() for concatenation along existing dimensions, and torch.split() for dividing tensors into chunks. These operations are fundamental for batch processing and data organization in deep learning workflows.

**Key Points:**

- view() requires tensors to be contiguous in memory
- reshape() automatically handles non-contiguous tensors but may create copies
- transpose() and permute() change dimension order but not data values
- contiguous() creates a contiguous copy when necessary for subsequent operations

**Example:**

```python
# Reshaping operations
x = torch.randn(2, 3, 4)
y = x.view(6, 4)  # Reshape to (6, 4)
z = x.reshape(-1, 4)  # Automatic dimension calculation

# Dimension manipulation
a = torch.randn(3, 1, 4)
b = a.squeeze(1)  # Remove dimension of size 1: (3, 4)
c = b.unsqueeze(0)  # Add dimension: (1, 3, 4)

# Tensor concatenation and splitting
tensors = [torch.randn(2, 3) for _ in range(4)]
stacked = torch.stack(tensors, dim=0)  # Shape: (4, 2, 3)
concatenated = torch.cat(tensors, dim=0)  # Shape: (8, 3)
chunks = torch.split(concatenated, 2, dim=0)  # List of (2, 3) tensors
```

