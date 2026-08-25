## Out-of-Core Training Methods


Out-of-core training enables training models that exceed available GPU memory by streaming data and parameters between storage, CPU memory, and GPU memory. This approach trades memory for computation time and I/O bandwidth.

Parameter streaming loads model parameters on-demand during forward and backward passes, keeping only active layers in GPU memory. Activation streaming similarly manages intermediate activations by spilling them to CPU memory or storage when GPU memory pressure increases.

**Key Points:**

- Enables training arbitrarily large models with limited GPU memory
- Requires careful orchestration of data movement and computation
- I/O bandwidth becomes the primary bottleneck
- NVMe SSDs provide optimal storage backend for parameter streaming

**Example:**

```python
import torch
from torch.utils.data import DataLoader
import asyncio

class OutOfCoreModel(torch.nn.Module):
    def __init__(self, layers, device='cuda', cpu_offload=True):
        super().__init__()
        self.layers = torch.nn.ModuleList(layers)
        self.device = device
        self.cpu_offload = cpu_offload
        
        # Initially move all layers to CPU
        if cpu_offload:
            for layer in self.layers:
                layer.cpu()
    
    def forward(self, x):
        for i, layer in enumerate(self.layers):
            if self.cpu_offload:
                # Move layer to GPU before computation
                layer.to(self.device, non_blocking=True)
                torch.cuda.synchronize()
            
            x = layer(x)
            
            if self.cpu_offload and i < len(self.layers) - 1:
                # Move previous layer back to CPU
                layer.cpu()
                torch.cuda.empty_cache()
        
        return x

# Activation checkpointing with disk offload
class DiskCheckpoint:
    def __init__(self, temp_dir="./checkpoints"):
        self.temp_dir = Path(temp_dir)
        self.temp_dir.mkdir(exist_ok=True)
        self.checkpoint_id = 0
    
    def save_activation(self, tensor):
        filename = self.temp_dir / f"activation_{self.checkpoint_id}.pt"
        torch.save(tensor.cpu(), filename)
        self.checkpoint_id += 1
        return filename
    
    def load_activation(self, filename):
        return torch.load(filename, map_location='cuda')
```

Advanced out-of-core techniques include asynchronous parameter loading using CUDA streams to overlap computation and data movement, hierarchical memory management with multiple storage tiers (GPU memory → CPU memory → NVMe → HDD), and adaptive streaming policies that predict parameter usage patterns.

Pipeline parallelism combined with out-of-core training can achieve near-optimal utilization by overlapping computation stages across multiple GPUs while streaming parameters for each stage independently.

**Conclusion:** PyTorch memory management encompasses a broad spectrum of techniques from basic allocation optimization to sophisticated out-of-core training strategies. Successful large-model training requires combining multiple approaches: gradient checkpointing for activation memory reduction, memory-efficient attention for sequence models, strategic garbage collection, and comprehensive profiling to identify bottlenecks. The choice of techniques depends on specific model architectures, hardware constraints, and training objectives.

---

