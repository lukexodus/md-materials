## Memory Architecture and Allocation


PyTorch uses a sophisticated memory management system that handles both CPU and GPU memory. The GPU memory allocator employs a caching mechanism that pre-allocates memory blocks to reduce allocation overhead. When tensors are created, PyTorch requests memory from CUDA, but when tensors are deleted, the memory isn't immediately returned to CUDA - instead, it's cached for future allocations.

The memory allocator uses a best-fit algorithm with splitting and coalescing to manage memory blocks efficiently. Large allocations (>20MB by default) bypass the cache and go directly to CUDA. This design minimizes allocation latency but can lead to memory fragmentation and apparent memory leaks where `nvidia-smi` shows high GPU usage even after model deletion.

Memory tracking in PyTorch involves several components: the autograd engine maintains computation graphs for backpropagation, requiring storage of intermediate activations. Forward pass activations consume significant memory, especially in deep networks where activations from early layers must be retained until the backward pass completes.

