## Indexing, Slicing, and Advanced Selection


PyTorch tensor indexing supports multiple paradigms including basic slicing, integer indexing, boolean masking, and advanced indexing with tensor indices. Basic slicing uses Python slice notation (start:stop:step) and supports negative indices for reverse indexing. Multi-dimensional tensors can be indexed along multiple axes simultaneously.

Boolean indexing enables conditional selection using boolean tensors as masks, creating powerful filtering mechanisms. Advanced indexing with integer tensors allows for non-contiguous element selection and sophisticated data gathering operations. The torch.gather() and torch.scatter() functions provide optimized implementations for common indexing patterns.

Fancy indexing combines multiple indexing methods, enabling complex data selection patterns. The ellipsis (...) notation allows indexing specific dimensions while leaving others unchanged, particularly useful for high-dimensional tensors.

**Key Points:**

- Boolean masking creates views of tensor subsets based on conditions
- Advanced indexing may create copies rather than views of original data
- torch.gather() and torch.scatter() are optimized for batch-wise indexing operations
- Negative indices count from tensor end, enabling reverse indexing

**Example:**

```python
# Basic indexing and slicing
tensor = torch.randn(4, 5, 6)
subset = tensor[1:3, :, ::2]  # Slice multiple dimensions
single_element = tensor[0, 2, 4]  # Single element access

# Boolean indexing
x = torch.randn(3, 4)
mask = x > 0
positive_elements = x[mask]  # 1D tensor of positive values
x[mask] = 0  # Set positive elements to zero

# Advanced indexing
indices = torch.tensor([0, 2, 1])
selected_rows = tensor[indices]  # Select specific rows
gathered = torch.gather(tensor, dim=1, index=torch.tensor([[0, 2], [1, 3], [0, 1], [2, 4]]))
```

