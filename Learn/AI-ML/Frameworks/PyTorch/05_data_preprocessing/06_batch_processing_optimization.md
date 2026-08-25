## Batch Processing Optimization


**Efficient Batch Construction**

Optimizing batch construction improves training throughput and memory utilization:

```python
import torch
from torch.utils.data import DataLoader, Dataset
from collections import defaultdict

class OptimizedBatchSampler:
    """Batch sampler that groups samples by similar characteristics"""
    
    def __init__(self, dataset, batch_size, group_fn=None):
        self.dataset = dataset
        self.batch_size = batch_size
        self.group_fn = group_fn or (lambda x: 0)  # Default: no grouping
        
        # Group samples by characteristics
        self.groups = defaultdict(list)
        for idx in range(len(dataset)):
            sample = dataset[idx]
            group_key = self.group_fn(sample)
            self.groups[group_key].append(idx)
    
    def __iter__(self):
        """Generate batches with similar samples grouped together"""
        for group_indices in self.groups.values():
            # Shuffle within group
            random.shuffle(group_indices)
            
            # Create batches from group
            for i in range(0, len(group_indices), self.batch_size):
                batch_indices = group_indices[i:i + self.batch_size]
                if len(batch_indices) == self.batch_size:  # Only full batches
                    yield batch_indices

# Example usage for variable-length sequences
def sequence_length_grouping(sample):
    """Group samples by sequence length for efficient padding"""
    data, _ = sample
    return len(data) // 10  # Group by length buckets of 10

sampler = OptimizedBatchSampler(
    dataset, 
    batch_size=32, 
    group_fn=sequence_length_grouping
)
```

**Memory-Efficient Collation**

Custom collate functions optimize memory usage and processing efficiency:

```python
class MemoryEfficientCollator:
    """Collate function optimized for memory usage"""
    
    def __init__(self, max_length=None, pad_token_id=0):
        self.max_length = max_length
        self.pad_token_id = pad_token_id
    
    def __call__(self, batch):
        """Efficiently collate batch with minimal memory overhead"""
        # Separate data and labels
        data_list, label_list = zip(*batch)
        
        # Find optimal padding length for this batch
        if self.max_length is None:
            batch_max_length = max(len(seq) for seq in data_list)
        else:
            batch_max_length = min(self.max_length, max(len(seq) for seq in data_list))
        
        # Pre-allocate tensors
        batch_size = len(batch)
        padded_data = torch.full(
            (batch_size, batch_max_length), 
            self.pad_token_id, 
            dtype=torch.long
        )
        attention_masks = torch.zeros(
            (batch_size, batch_max_length), 
            dtype=torch.bool
        )
        
        # Fill tensors efficiently
        for i, seq in enumerate(data_list):
            seq_len = min(len(seq), batch_max_length)
            padded_data[i, :seq_len] = torch.tensor(seq[:seq_len])
            attention_masks[i, :seq_len] = True
        
        labels = torch.tensor(label_list)
        
        return {
            'input_ids': padded_data,
            'attention_mask': attention_masks,
            'labels': labels
        }

class AdaptiveCollator:
    """Collator that adapts strategy based on batch characteristics"""
    
    def __init__(self, strategies):
        """
        Args:
            strategies: Dict mapping condition functions to collator functions
        """
        self.strategies = strategies
        self.default_collator = torch.utils.data.default_collate
    
    def __call__(self, batch):
        # Determine appropriate strategy
        for condition_fn, collator_fn in self.strategies.items():
            if condition_fn(batch):
                return collator_fn(batch)
        
        # Fallback to default collation
        return self.default_collator(batch)

# Example strategies
def is_variable_length_batch(batch):
    """Check if batch contains variable-length sequences"""
    if not batch or not hasattr(batch[0][0], '__len__'):
        return False
    lengths = [len(item[0]) for item in batch]
    return len(set(lengths)) > 1

def is_image_batch(batch):
    """Check if batch contains images"""
    return hasattr(batch[0][0], 'shape') and len(batch[0][0].shape) >= 2

adaptive_collator = AdaptiveCollator({
    is_variable_length_batch: MemoryEfficientCollator(),
    is_image_batch: torch.utils.data.default_collate
})
```

**Parallel Processing Optimization**

Leveraging multiprocessing for preprocessing acceleration:

```python
class ParallelPreprocessor:
    """Parallel preprocessing with optimized worker management"""
    
    def __init__(self, transform, num_workers=4, prefetch_factor=2):
        self.transform = transform
        self.num_workers = num_workers
        self.prefetch_factor = prefetch_factor
    
    def create_dataloader(self, dataset, batch_size, shuffle=True):
        """Create optimized DataLoader with parallel preprocessing"""
        return DataLoader(
            dataset,
            batch_size=batch_size,
            shuffle=shuffle,
            num_workers=self.num_workers,
            prefetch_factor=self.prefetch_factor,
            pin_memory=torch.cuda.is_available(),  # Pin memory for GPU transfer
            persistent_workers=True,  # Keep workers alive between epochs
            collate_fn=self.optimized_collate
        )
    
    def optimized_collate(self, batch):
        """Apply transforms during collation for efficiency"""
        # Apply transforms in parallel during collation
        transformed_batch = []
        for item in batch:
            transformed_item = self.transform(item)
            transformed_batch.append(transformed_item)
        
        return torch.utils.data.default_collate(transformed_batch)

class StreamingBatchProcessor:
    """Process batches in streaming fashion for large datasets"""
    
    def __init__(self, dataset, batch_size, buffer_size=1000):
        self.dataset = dataset
        self.batch_size = batch_size
        self.buffer_size = buffer_size
        self.buffer = []
        self.buffer_index = 0
    
    def __iter__(self):
        """Stream batches with efficient buffering"""
        dataset_iter = iter(self.dataset)
        
        while True:
            # Fill buffer
            while len(self.buffer) < self.buffer_size:
                try:
                    item = next(dataset_iter)
                    self.buffer.append(item)
                except StopIteration:
                    break
            
            if not self.buffer:
                break
            
            # Create batch from buffer
            if len(self.buffer) >= self.batch_size:
                batch = self.buffer[:self.batch_size]
                self.buffer = self.buffer[self.batch_size:]
                yield batch
            else:
                # Return remaining items as final batch
                if self.buffer:
                    yield self.buffer
                break
```

**GPU Transfer Optimization**

Optimizing data transfer between CPU and GPU:

```python
class GPUOptimizedDataLoader:
    """DataLoader with optimized GPU transfer patterns"""
    
    def __init__(self, dataloader, device, non_blocking=True):
        self.dataloader = dataloader
        self.device = device
        self.non_blocking = non_blocking
        self.stream = torch.cuda.Stream() if torch.cuda.is_available() else None
    
    def __iter__(self):
        """Transfer data to GPU with overlapped execution"""
        iterator = iter(self.dataloader)
        
        # Preload first batch
        try:
            next_batch = self._transfer_batch(next(iterator))
        except StopIteration:
            return
        
        for batch in iterator:
            # Current batch is already on GPU, start loading next
            current_batch = next_batch
            
            if self.stream:
                with torch.cuda.stream(self.stream):
                    next_batch = self._transfer_batch(batch)
            else:
                next_batch = self._transfer_batch(batch)
            
            # Synchronize to ensure current batch is ready
            if self.stream:
                torch.cuda.current_stream().wait_stream(self.stream)
            
            yield current_batch
        
        # Yield the last batch
        yield next_batch
    
    def _transfer_batch(self, batch):
        """Transfer batch to GPU efficiently"""
        if isinstance(batch, dict):
            return {key: value.to(self.device, non_blocking=self.non_blocking) 
                   if isinstance(value, torch.Tensor) else value
                   for key, value in batch.items()}
        elif isinstance(batch, (list, tuple)):
            return type(batch)(
                item.to(self.device, non_blocking=self.non_blocking)
                if isinstance(item, torch.Tensor) else item
                for item in batch
            )
        elif isinstance(batch, torch.Tensor):
            return batch.to(self.device, non_blocking=self.non_blocking)
        return batch

class PrefetchingDataLoader:
    """DataLoader with background prefetching"""
    
    def __init__(self, dataloader, device, queue_size=2):
        self.dataloader = dataloader
        self.device = device
        self.queue_size = queue_size
        self.queue = None
        self.thread = None
    
    def _producer(self):
        """Background thread that prefetches batches"""
        try:
            for batch in self.dataloader:
                # Transfer to GPU in background
                gpu_batch = self._to_device(batch)
                self.queue.put(gpu_batch)
            self.queue.put(None)  # Signal end of iteration
        except Exception as e:
            self.queue.put(e)  # Signal error
    
    def __iter__(self):
        """Iterator with background prefetching"""
        import queue
        import threading
        
        self.queue = queue.Queue(maxsize=self.queue_size)
        self.thread = threading.Thread(target=self._producer)
        self.thread.start()
        
        try:
            while True:
                batch = self.queue.get()
                if batch is None:  # End of iteration
                    break
                elif isinstance(batch, Exception):  # Error occurred
                    raise batch
                yield batch
        finally:
            if self.thread.is_alive():
                self.thread.join()
    
    def _to_device(self, batch):
        """Transfer batch to device"""
        if isinstance(batch, torch.Tensor):
            return batch.to(self.device, non_blocking=True)
        elif isinstance(batch, dict):
            return {k: self._to_device(v) for k, v in batch.items()}
        elif isinstance(batch, (list, tuple)):
            return type(batch)(self._to_device(item) for item in batch)
        return batch
```

**Batch Size Optimization**

Dynamic batch size adjustment based on memory constraints:

```python
class AdaptiveBatchSizer:
    """Automatically adjust batch size based on memory usage"""
    
    def __init__(self, initial_batch_size=32, max_memory_gb=8):
        self.initial_batch_size = initial_batch_size
        self.max_memory_bytes = max_memory_gb * 1024**3
        self.current_batch_size = initial_batch_size
        self.memory_measurements = []
    
    def find_optimal_batch_size(self, model, sample_input, device):
        """Find optimal batch size through binary search"""
        model.eval()
        
        def test_batch_size(batch_size):
            """Test if batch size fits in memory"""
            try:
                # Create test batch
                if isinstance(sample_input, dict):
                    test_batch = {
                        k: v.repeat(batch_size, *([1] * (v.dim() - 1)))
                        for k, v in sample_input.items()
                    }
                else:
                    test_batch = sample_input.repeat(batch_size, *([1] * (sample_input.dim() - 1)))
                
                test_batch = self._to_device(test_batch, device)
                
                # Clear cache and measure baseline
                if torch.cuda.is_available():
                    torch.cuda.empty_cache()
                    torch.cuda.synchronize()
                    start_memory = torch.cuda.memory_allocated()
                
                # Forward pass
                with torch.no_grad():
                    _ = model(test_batch)
                
                if torch.cuda.is_available():
                    torch.cuda.synchronize()
                    peak_memory = torch.cuda.max_memory_allocated()
                    memory_used = peak_memory - start_memory
                    
                    return memory_used < self.max_memory_bytes
                
                return True  # Assume success for CPU
                
            except RuntimeError as e:
                if "out of memory" in str(e).lower():
                    return False
                raise e
        
        # Binary search for optimal batch size
        low, high = 1, self.initial_batch_size * 4
        optimal_batch_size = self.initial_batch_size
        
        while low <= high:
            mid = (low + high) // 2
            if test_batch_size(mid):
                optimal_batch_size = mid
                low = mid + 1
            else:
                high = mid - 1
        
        self.current_batch_size = optimal_batch_size
        return optimal_batch_size
    
    def _to_device(self, batch, device):
        """Helper to move batch to device"""
        if isinstance(batch, dict):
            return {k: v.to(device) for k, v in batch.items()}
        return batch.to(device)

class GradientAccumulationOptimizer:
    """Optimize gradient accumulation for effective large batch training"""
    
    def __init__(self, target_batch_size, actual_batch_size):
        self.target_batch_size = target_batch_size
        self.actual_batch_size = actual_batch_size
        self.accumulation_steps = target_batch_size // actual_batch_size
        self.step_count = 0
    
    def should_step(self):
        """Determine if optimizer step should be taken"""
        self.step_count += 1
        return self.step_count % self.accumulation_steps == 0
    
    def scale_loss(self, loss):
        """Scale loss for gradient accumulation"""
        return loss / self.accumulation_steps
    
    def reset_step_count(self):
        """Reset step counter"""
        self.step_count = 0
```

**Performance Monitoring and Profiling**

Tools for monitoring batch processing performance:

```python
class BatchProcessingProfiler:
    """Profile batch processing performance"""
    
    def __init__(self):
        self.metrics = {
            'batch_times': [],
            'transfer_times': [],
            'processing_times': [],
            'memory_usage': []
        }
    
    def profile_dataloader(self, dataloader, num_batches=10):
        """Profile DataLoader performance"""
        import time
        
        start_time = time.time()
        
        for i, batch in enumerate(dataloader):
            if i >= num_batches:
                break
            
            batch_start = time.time()
            
            # Measure GPU transfer time if applicable
            if torch.cuda.is_available():
                transfer_start = time.time()
                if isinstance(batch, torch.Tensor):
                    batch = batch.cuda()
                elif isinstance(batch, dict):
                    batch = {k: v.cuda() if isinstance(v, torch.Tensor) else v 
                            for k, v in batch.items()}
                torch.cuda.synchronize()
                transfer_time = time.time() - transfer_start
                self.metrics['transfer_times'].append(transfer_time)
            
            # Measure memory usage
            if torch.cuda.is_available():
                memory_used = torch.cuda.memory_allocated() / 1024**2  # MB
                self.metrics['memory_usage'].append(memory_used)
            
            batch_time = time.time() - batch_start
            self.metrics['batch_times'].append(batch_time)
        
        total_time = time.time() - start_time
        
        return {
            'total_time': total_time,
            'avg_batch_time': sum(self.metrics['batch_times']) / len(self.metrics['batch_times']),
            'avg_transfer_time': sum(self.metrics['transfer_times']) / len(self.metrics['transfer_times']) if self.metrics['transfer_times'] else 0,
            'peak_memory_mb': max(self.metrics['memory_usage']) if self.metrics['memory_usage'] else 0,
            'batches_per_second': len(self.metrics['batch_times']) / total_time
        }
    
    def generate_report(self):
        """Generate performance report"""
        if not self.metrics['batch_times']:
            return "No profiling data available"
        
        report = f"""
        Batch Processing Performance Report:
        ====================================
        Average batch time: {sum(self.metrics['batch_times']) / len(self.metrics['batch_times']):.4f}s
        """
        
        if self.metrics['transfer_times']:
            report += f"Average transfer time: {sum(self.metrics['transfer_times']) / len(self.metrics['transfer_times']):.4f}s\n"
        
        if self.metrics['memory_usage']:
            report += f"Peak memory usage: {max(self.metrics['memory_usage']):.2f} MB\n"
        
        return report
```

**Key Points:**

- Batch construction optimization through intelligent sampling and grouping improves efficiency
- Memory-efficient collation reduces memory overhead and processing time
- Parallel processing and GPU transfer optimization significantly impact training throughput
- Adaptive batch sizing and gradient accumulation enable training with memory constraints
- Performance profiling helps identify bottlenecks in the preprocessing pipeline

**Output**

Data preprocessing optimization in PyTorch requires a comprehensive understanding of transform systems, hardware utilization, and memory management. Effective preprocessing pipelines balance data quality, computational efficiency, and memory constraints while providing the flexibility needed for diverse machine learning applications.

The combination of well-designed transforms, efficient batch processing, and performance monitoring creates robust preprocessing systems that can handle large-scale datasets across computer vision, natural language processing, and audio domains. These optimizations become increasingly critical as model sizes and dataset scales continue to grow in modern deep learning applications.

---

