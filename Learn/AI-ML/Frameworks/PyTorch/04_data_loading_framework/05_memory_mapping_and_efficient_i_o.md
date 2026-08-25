## Memory Mapping and Efficient I/O


Memory mapping enables efficient access to large datasets by mapping file contents directly into virtual memory space. This approach reduces memory usage and enables fast random access to data stored on disk. PyTorch supports memory mapping through numpy's memmap functionality and custom tensor creation methods.

Efficient I/O patterns minimize disk access and maximize throughput through sequential reading, prefetching, and caching strategies. Understanding storage characteristics (SSD vs HDD, network storage, etc.) helps optimize access patterns and reduce latency.

Large dataset handling requires careful memory management and access pattern optimization. Techniques include hierarchical data formats (HDF5, Zarr), chunked data access, and lazy loading strategies that minimize memory footprint while maintaining performance.

Buffer management and caching strategies balance memory usage with access performance. LRU caches, write-back buffers, and asynchronous I/O operations can significantly improve data loading performance for large-scale applications.

**Key Points:**

- Memory mapping reduces memory usage and enables efficient random access
- I/O optimization requires understanding storage characteristics and access patterns
- Large datasets benefit from hierarchical formats and lazy loading strategies
- Caching and buffering balance memory usage with access performance

**Example:**

```python
import numpy as np
import torch
import h5py
from torch.utils.data import Dataset

class MemoryMappedDataset(Dataset):
    """Dataset using memory mapping for large data files."""
    
    def __init__(self, data_file, labels_file):
        # Memory map large data arrays
        self.data = np.memmap(data_file, dtype='float32', mode='r')
        self.labels = np.memmap(labels_file, dtype='int64', mode='r')
        
        # Determine data shape from file size
        data_size = self.data.shape[0]
        feature_size = data_size // len(self.labels)
        self.data = self.data.reshape(len(self.labels), feature_size)
    
    def __len__(self):
        return len(self.labels)
    
    def __getitem__(self, idx):
        # Memory mapping enables efficient access without loading entire file
        data_sample = torch.from_numpy(self.data[idx].copy())
        label = torch.from_numpy(np.array([self.labels[idx]]))
        return data_sample, label

class HDF5Dataset(Dataset):
    """Dataset using HDF5 for hierarchical data storage."""
    
    def __init__(self, hdf5_file):
        self.hdf5_file = hdf5_file
        with h5py.File(hdf5_file, 'r') as f:
            self.data_len = len(f['data'])
    
    def __len__(self):
        return self.data_len
    
    def __getitem__(self, idx):
        with h5py.File(self.hdf5_file, 'r') as f:
            data = f['data'][idx]
            label = f['labels'][idx]
            return torch.from_numpy(data), torch.from_numpy(np.array([label]))

class CachedDataset(Dataset):
    """Dataset with LRU caching for expensive data loading operations."""
    
    def __init__(self, data_source, cache_size=1000):
        self.data_source = data_source
        self.cache = {}
        self.cache_order = []
        self.cache_size = cache_size
    
    def __len__(self):
        return len(self.data_source)
    
    def __getitem__(self, idx):
        if idx in self.cache:
            # Move to end of cache order (most recently used)
            self.cache_order.remove(idx)
            self.cache_order.append(idx)
            return self.cache[idx]
        
        # Load data (expensive operation)
        data = self._load_data(idx)
        
        # Add to cache
        if len(self.cache) >= self.cache_size:
            # Remove least recently used item
            oldest_idx = self.cache_order.pop(0)
            del self.cache[oldest_idx]
        
        self.cache[idx] = data
        self.cache_order.append(idx)
        return data
    
    def _load_data(self, idx):
        # Simulate expensive data loading
        return torch.randn(1000), torch.randint(0, 10, (1,))

# Efficient data creation for memory mapping
def create_memory_mapped_data(output_file, data_shape, dtype='float32'):
    """Create memory-mapped array for efficient large data storage."""
    mmap_array = np.memmap(output_file, dtype=dtype, mode='w+', shape=data_shape)
    
    # Populate data in chunks to manage memory usage
    chunk_size = 1000
    for i in range(0, data_shape[0], chunk_size):
        end_idx = min(i + chunk_size, data_shape[0])
        mmap_array[i:end_idx] = np.random.randn(end_idx - i, *data_shape[1:])
    
    # Flush to disk
    del mmap_array
    return output_file
```

