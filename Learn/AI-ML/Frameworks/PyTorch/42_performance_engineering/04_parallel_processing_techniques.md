## Parallel Processing Techniques


Parallel processing in PyTorch spans multiple dimensions: data parallelism distributes batches across devices, model parallelism partitions models across devices, and pipeline parallelism overlaps computation stages. Each approach addresses different scaling bottlenecks and hardware configurations.

Data parallelism replicates the complete model across multiple devices, synchronizing gradients after each backward pass. This approach scales effectively until communication overhead dominates, typically occurring when the parameter-to-computation ratio becomes unfavorable.

**Key Points:**

- DistributedDataParallel (DDP) provides efficient multi-GPU training
- Gradient compression reduces communication overhead
- Asynchronous communication overlaps computation with gradient synchronization
- Load balancing prevents stragglers from limiting overall throughput

**Example:**

```python
import torch
import torch.distributed as dist
import torch.multiprocessing as mp
from torch.nn.parallel import DistributedDataParallel as DDP
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP

def setup_distributed(rank, world_size):
    """Initialize distributed training environment"""
    dist.init_process_group("nccl", rank=rank, world_size=world_size)
    torch.cuda.set_device(rank)

def cleanup_distributed():
    """Clean up distributed training"""
    dist.destroy_process_group()

class DistributedTrainer:
    def __init__(self, model, rank, world_size):
        self.rank = rank
        self.world_size = world_size
        self.device = torch.device(f'cuda:{rank}')
        
        # Move model to device and wrap with DDP
        model = model.to(self.device)
        self.model = DDP(model, device_ids=[rank])
        
        # Gradient compression for communication efficiency
        self.model.register_comm_hook(None, self.gradient_compression_hook)
    
    def gradient_compression_hook(self, state, bucket):
        """Custom gradient compression to reduce communication overhead"""
        tensor = bucket.buffer()
        
        # Simple quantization example (can use more sophisticated compression)
        compressed = self.quantize_tensor(tensor)
        decompressed = self.dequantize_tensor(compressed)
        
        # All-reduce operation
        fut = dist.all_reduce(decompressed, async_op=True).get_future()
        return fut.then(lambda x: x.div_(self.world_size))
    
    def quantize_tensor(self, tensor, bits=8):
        """Quantize tensor to reduce communication volume"""
        min_val, max_val = tensor.min(), tensor.max()
        scale = (max_val - min_val) / (2**bits - 1)
        quantized = ((tensor - min_val) / scale).round().clamp(0, 2**bits - 1)
        return quantized, min_val, scale
    
    def dequantize_tensor(self, quantized_data):
        """Dequantize tensor"""
        quantized, min_val, scale = quantized_data
        return quantized * scale + min_val

# Pipeline parallelism implementation
class PipelineStage(nn.Module):
    def __init__(self, stage_modules, stage_id):
        super().__init__()
        self.stage_modules = nn.ModuleList(stage_modules)
        self.stage_id = stage_id
    
    def forward(self, x):
        for module in self.stage_modules:
            x = module(x)
        return x

class PipelineParallel(nn.Module):
    def __init__(self, stages, devices):
        super().__init__()
        self.stages = nn.ModuleList(stages)
        self.devices = devices
        self.num_stages = len(stages)
        
        # Move each stage to its designated device
        for stage, device in zip(self.stages, self.devices):
            stage.to(device)
    
    def forward(self, x, micro_batch_size=None):
        if micro_batch_size is None:
            return self._sequential_forward(x)
        else:
            return self._pipeline_forward(x, micro_batch_size)
    
    def _pipeline_forward(self, x, micro_batch_size):
        """Pipeline forward with micro-batching"""
        batch_size = x.size(0)
        num_micro_batches = batch_size // micro_batch_size
        
        # Split input into micro-batches
        micro_batches = x.split(micro_batch_size, dim=0)
        outputs = []
        
        # Pipeline execution with overlapping stages
        for i, micro_batch in enumerate(micro_batches):
            current_input = micro_batch.to(self.devices[0])
            
            # Forward through pipeline stages
            for stage_idx, stage in enumerate(self.stages):
                device = self.devices[stage_idx]
                current_input = current_input.to(device)
                current_input = stage(current_input)
            
            outputs.append(current_input)
        
        return torch.cat(outputs, dim=0)
```

Advanced parallel processing includes gradient accumulation across devices, asynchronous parameter updates, and dynamic load balancing that adapts to varying computational complexity across batch samples.

