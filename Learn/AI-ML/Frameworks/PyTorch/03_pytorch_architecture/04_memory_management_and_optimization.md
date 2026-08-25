## Memory Management and Optimization


**Memory Architecture**

PyTorch manages memory across different devices (CPU, GPU) and maintains separate memory pools for different data types. Understanding memory allocation patterns is crucial for optimizing large-scale training.

**GPU Memory Management**

CUDA memory management in PyTorch involves several key concepts:

```python
# Monitor memory usage
print(f"Allocated: {torch.cuda.memory_allocated() / 1024**2:.2f} MB")
print(f"Reserved: {torch.cuda.memory_reserved() / 1024**2:.2f} MB")

# Clear unused cache
torch.cuda.empty_cache()

# Set memory fraction limit [Inference - may vary by PyTorch version]
torch.cuda.set_per_process_memory_fraction(0.8)
```

**Memory Optimization Strategies**

Several techniques can reduce memory usage during training:

**Gradient Accumulation**: Simulates larger batch sizes without proportional memory increase:

```python
optimizer.zero_grad()
for i, (data, target) in enumerate(dataloader):
    output = model(data)
    loss = criterion(output, target) / accumulation_steps
    loss.backward()
    
    if (i + 1) % accumulation_steps == 0:
        optimizer.step()
        optimizer.zero_grad()
```

**Mixed Precision Training**: Reduces memory usage while maintaining numerical stability:

```python
from torch.cuda.amp import GradScaler, autocast

scaler = GradScaler()
optimizer.zero_grad()

with autocast():
    output = model(input)
    loss = criterion(output, target)

scaler.scale(loss).backward()
scaler.step(optimizer)
scaler.update()
```

**Memory-Efficient Attention**: Implements attention mechanisms with reduced memory footprint [Inference]:

```python
# Using checkpoint for memory-compute tradeoff
from torch.utils.checkpoint import checkpoint

def forward_with_checkpoint(self, x):
    return checkpoint(self.expensive_function, x)
```

**Tensor Memory Sharing**

PyTorch tensors can share underlying memory storage, which affects memory usage and modification behavior:

```python
# Tensors sharing memory
a = torch.randn(5, 3)
b = a.view(3, 5)  # b shares memory with a
c = a.clone()     # c has separate memory

print(a.storage().data_ptr() == b.storage().data_ptr())  # True
print(a.storage().data_ptr() == c.storage().data_ptr())  # False
```

**Memory Profiling**

PyTorch provides tools for memory profiling and optimization:

```python
# Memory profiler
from torch.profiler import profile, record_function, ProfilerActivity

with profile(activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA], 
             record_shapes=True, 
             profile_memory=True) as prof:
    model(input)

print(prof.key_averages().table(sort_by="self_cuda_memory_usage", row_limit=10))
```

**Key Points:**

- GPU memory is managed through CUDA memory pools with caching for efficiency
- Mixed precision training can significantly reduce memory usage with minimal accuracy impact
- Gradient accumulation enables training with larger effective batch sizes
- Memory profiling tools help identify optimization opportunities

