## Mathematical Operations and Broadcasting


PyTorch implements comprehensive mathematical operations covering basic arithmetic, trigonometric functions, exponential and logarithmic operations, statistical functions, and linear algebra primitives. Broadcasting enables operations between tensors of different shapes by automatically expanding dimensions according to specific rules, eliminating the need for explicit reshaping in many cases.

Broadcasting rules follow NumPy conventions: dimensions are aligned from the rightmost position, dimensions of size 1 can be expanded to match larger dimensions, and missing dimensions are treated as size 1. Element-wise operations include addition, subtraction, multiplication, division, and power operations, while reduction operations like sum, mean, max, and min can operate across specified dimensions or the entire tensor.

Advanced mathematical operations include matrix multiplication (torch.mm, torch.matmul, @ operator), eigenvalue decomposition, singular value decomposition, and Cholesky decomposition. These operations leverage optimized BLAS and LAPACK libraries for high-performance computation.

**Key Points:**

- Broadcasting eliminates explicit tensor reshaping for compatible operations
- In-place operations (+=, *=, etc.) modify tensors directly, saving memory
- torch.matmul handles batched matrix multiplication and broadcasting simultaneously
- Reduction operations support keepdim parameter to preserve tensor dimensions

**Example:**

```python
# Broadcasting demonstration
a = torch.tensor([[1, 2, 3]])  # Shape: (1, 3)
b = torch.tensor([[1], [2], [3]])  # Shape: (3, 1)
c = a + b  # Broadcasting result: (3, 3)

# Mathematical operations
x = torch.randn(3, 4)
y = torch.randn(4, 5)
z = torch.matmul(x, y)  # Matrix multiplication: (3, 5)

# Reduction operations
tensor = torch.randn(2, 3, 4)
mean_all = tensor.mean()  # Scalar
mean_dim = tensor.mean(dim=1, keepdim=True)  # Shape: (2, 1, 4)
```

