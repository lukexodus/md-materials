## GPU Acceleration Integration


GPU acceleration dramatically improves NumPy array processing performance for suitable workloads through libraries like CuPy, Numba, and PyTorch. Integration patterns enable seamless transitions between CPU and GPU computing while maintaining NumPy's familiar interface.

**Key points:**

- CuPy provides GPU-accelerated NumPy-compatible arrays with minimal code changes
- Numba enables just-in-time compilation of NumPy code for both CPU and GPU execution
- Memory transfer optimization minimizes data movement between CPU and GPU
- Hybrid processing strategies leverage both CPU and GPU resources efficiently
- Integration with deep learning frameworks extends capabilities for scientific computing

**Example:**

```python
import numpy as np
import time
from typing import Union, List, Optional, Tuple
import warnings

# [Unverified] GPU acceleration requires appropriate hardware and drivers
class GPUArrayProcessor:
    """GPU-accelerated array processing with fallback to CPU."""
    
    def __init__(self, prefer_gpu=True, gpu_memory_limit=None):
        self.prefer_gpu = prefer_gpu
        self.gpu_available = False
        self.gpu_memory_limit = gpu_memory_limit
        
        # Initialize GPU libraries
        self._setup_gpu_libraries()
    
    def _setup_gpu_libraries(self):
        """[Unverified] Initialize available GPU acceleration libraries."""
        # Try to import CuPy
        try:
            import cupy as cp
            self.cp = cp
            self.cupy_available = True
            print(f"CuPy available - GPU: {cp.cuda.get_device_name()}")
        except ImportError:
            self.cupy_available = False
            print("CuPy not available")
        
        # Try to import Numba with CUDA support
        try:
            from numba import cuda, jit
            self.numba_cuda = cuda
            self.numba_jit = jit
            self.numba_available = cuda.is_available()
            if self.numba_available:
                print(f"Numba CUDA available - GPU count: {len(cuda.gpus)}")
        except ImportError:
            self.numba_available = False
            print("Numba CUDA not available")
        
        # Try to import PyTorch for GPU operations
        try:
            import torch
            self.torch = torch
            self.pytorch_available = torch.cuda.is_available()
            if self.pytorch_available:
                print(f"PyTorch CUDA available - GPU: {torch.cuda.get_device_name()}")
        except ImportError:
            self.pytorch_available = False
            print("PyTorch not available")
        
        # Set overall GPU availability
        self.gpu_available = (self.cupy_available or self.numba_available or 
                             self.pytorch_available)
    
    def to_gpu(self, array: np.ndarray, library='cupy') -> Union[np.ndarray, object]:
        """Transfer NumPy array to GPU memory."""
        if not self.gpu_available:
            warnings.warn("GPU not available, returning CPU array")
            return array
        
        if library == 'cupy' and self.cupy_available:
            return self.cp.asarray(array)
        elif library == 'pytorch' and self.pytorch_available:
            return self.torch.from_numpy(array).cuda()
        elif library == 'numba' and self.numba_available:
            return self.numba_cuda.to_device(array)
        else:
            warnings.warn(f"Library {library} not available, returning CPU array")
            return array
    
    def to_cpu(self, gpu_array, library='cupy') -> np.ndarray:
        """Transfer array from GPU to CPU memory."""
        if isinstance(gpu_array, np.ndarray):
            return gpu_array  # Already on CPU
        
        if library == 'cupy' and hasattr(gpu_array, 'get'):
            return gpu_array.get()
        elif library == 'pytorch' and hasattr(gpu_array, 'cpu'):
            return gpu_array.cpu().numpy()
        elif library == 'numba' and hasattr(gpu_array, 'copy_to_host'):
            return gpu_array.copy_to_host()
        else:
            # Try to convert to numpy if possible
            try:
                return np.asarray(gpu_array)
            except:
                warnings.warn("Could not convert GPU array to CPU")
                return gpu_array
    
    def gpu_matrix_multiply(self, A: np.ndarray, B: np.ndarray, 
                          library='cupy') -> np.ndarray:
        """GPU-accelerated matrix multiplication."""
        if not self.gpu_available:
            return np.dot(A, B)
        
        if library == 'cupy' and self.cupy_available:
            # CuPy implementation
            gpu_A = self.cp.asarray(A)
            gpu_B = self.cp.asarray(B)
            gpu_result = self.cp.dot(gpu_A, gpu_B)
            return gpu_result.get()  # Transfer result back to CPU
        
        elif library == 'pytorch' and self.pytorch_available:
            # PyTorch implementation
            gpu_A = self.torch.from_numpy(A).cuda()
            gpu_B = self.torch.from_numpy(B).cuda()
            gpu_result = torch.mm(gpu_A, gpu_B)
            return gpu_result.cpu().numpy()
        
        elif library == 'numba' and self.numba_available:
            # Numba CUDA implementation
            return self._numba_matrix_multiply(A, B)
        
        else:
            # Fallback to CPU
            return np.dot(A, B)
    
    def _numba_matrix_multiply(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """[Unverified] Matrix multiplication using Numba CUDA."""
        from numba import cuda
        import math
        
        @cuda.jit
        def matmul_kernel(A, B, C):
            # Thread coordinates
            row, col = cuda.grid(2)
            
            if row < C.shape[0] and col < C.shape[1]:
                tmp = 0.0
                for k in range(A.shape[1]):
                    tmp += A[row, k] * B[k, col]
                C[row, col] = tmp
        
        # Allocate result array
        C = np.zeros((A.shape[0], B.shape[1]), dtype=np.float64)
        
        # Transfer arrays to GPU
        d_A = cuda.to_device(A)
        d_B = cuda.to_device(B)
        d_C = cuda.to_device(C)
        
        # Configure grid and block dimensions
        threads_per_block = (16, 16)
        blocks_per_grid_x = math.ceil(C.shape[0] / threads_per_block[0])
        blocks_per_grid_y = math.ceil(C.shape[1] / threads_per_block[1])
        blocks_per_grid = (blocks_per_grid_x, blocks_per_grid_y)
        
        # Launch kernel
        matmul_kernel[blocks_per_grid, threads_per_block](d_A, d_B, d_C)
        
        # Transfer result back to CPU
        return d_C.copy_to_host()
    
    def gpu_element_wise_operations(self, arrays: List[np.ndarray], 
                                  operation_func, library='cupy') -> List[np.ndarray]:
        """GPU-accelerated element-wise operations."""
        if not self.gpu_available:
            return [operation_func(arr) for arr in arrays]
        
        if library == 'cupy' and self.cupy_available:
            # CuPy implementation
            gpu_arrays = [self.cp.asarray(arr) for arr in arrays]
            
            # Apply operation (assuming it works with CuPy arrays)
            try:
                gpu_results = [operation_func(gpu_arr) for gpu_arr in gpu_arrays]
                return [result.get() for result in gpu_results]
            except Exception as e:
                warnings.warn(f"GPU operation failed: {e}, falling back to CPU")
                return [operation_func(arr) for arr in arrays]
        
        elif library == 'numba' and self.numba_available:
            return self._numba_element_wise_operations(arrays, operation_func)
        
        else:
            # Fallback to CPU
            return [operation_func(arr) for arr in arrays]
    
    def _numba_element_wise_operations(self, arrays: List[np.ndarray], 
                                     operation_func) -> List[np.ndarray]:
        """[Unverified] Element-wise operations using Numba CUDA."""
        from numba import cuda
        import math
        
        # Create CUDA kernel for element-wise operation
        @cuda.jit
        def elementwise_kernel(input_arr, output_arr, operation_id):
            idx = cuda.grid(1)
            if idx < input_arr.size:
                # Flatten array access
                flat_idx = idx
                if operation_id == 0:  # Square
                    output_arr.flat[flat_idx] = input_arr.flat[flat_idx] ** 2
                elif operation_id == 1:  # Sin
                    output_arr.flat[flat_idx] = math.sin(input_arr.flat[flat_idx])
                elif operation_id == 2:  # Exp
                    output_arr.flat[flat_idx] = math.exp(input_arr.flat[flat_idx])
                # Add more operations as needed
        
        results = []
        for arr in arrays:
            # Allocate output array
            output = np.zeros_like(arr)
            
            # Transfer to GPU
            d_input = cuda.to_device(arr)
            d_output = cuda.to_device(output)
            
            # Configure kernel launch
            threads_per_block = 256
            blocks_per_grid = math.ceil(arr.size / threads_per_block)
            
            # Launch kernel (simplified - assumes square operation)
            elementwise_kernel[blocks_per_grid, threads_per_block](
                d_input, d_output, 0
            )
            
            # Transfer result back
            results.append(d_output.copy_to_host())
        
        return results
    
    def hybrid_processing(self, arrays: List[np.ndarray], 
                         cpu_operations: List, gpu_operations: List) -> List[np.ndarray]:
        """Hybrid CPU-GPU processing pipeline."""
        if not self.gpu_available:
            # Process all operations on CPU
            results = arrays.copy()
            for operation in cpu_operations + gpu_operations:
                results = [operation(arr) for arr in results]
            return results
        
        # Start with CPU operations
        cpu_results = arrays.copy()
        for operation in cpu_operations:
            cpu_results = [operation(arr) for arr in cpu_results]
        
        # Transfer to GPU for GPU operations
        if gpu_operations and self.cupy_available:
            gpu_arrays = [self.cp.asarray(arr) for arr in cpu_results]
            
            for operation in gpu_operations:
                try:
                    gpu_arrays = [operation(gpu_arr) for gpu_arr in gpu_arrays]
                except Exception as e:
                    warnings.warn(f"GPU operation failed: {e}, falling back to CPU")
                    # Transfer back to CPU and continue there
                    cpu_results = [gpu_arr.get() for gpu_arr in gpu_arrays]
                    for remaining_op in gpu_operations[gpu_operations.index(operation):]:
                        cpu_results = [remaining_op(arr) for arr in cpu_results]
                    return cpu_results
            
            # Transfer final results back to CPU
            return [gpu_arr.get() for gpu_arr in gpu_arrays]
        
        else:
            # Process GPU operations on CPU as fallback
            for operation in gpu_operations:
                cpu_results = [operation(arr) for arr in cpu_results]
            return cpu_results

class BatchGPUProcessor:
    """Batch processing optimized for GPU memory management."""
    
    def __init__(self, batch_size=None, gpu_memory_fraction=0.8):
        self.gpu_processor = GPUArrayProcessor()
        self.batch_size = batch_size
        self.gpu_memory_fraction = gpu_memory_fraction
        
        # Estimate optimal batch size based on GPU memory
        if batch_size is None:
            self.batch_size = self._estimate_batch_size()
    
    def _estimate_batch_size(self) -> int:
        """[Inference] Estimate optimal batch size based on available GPU memory."""
        if not self.gpu_processor.cupy_available:
            return 32  # Conservative default for CPU processing
        
        try:
            # Get GPU memory info
            mempool = self.gpu_processor.cp.get_default_memory_pool()
            total_memory = mempool.total_bytes()
            available_memory = total_memory * self.gpu_memory_fraction
            
            # Estimate memory per array (assuming float64, 1MB arrays)
            estimated_array_size = 1024 * 1024 * 8  # 1M elements * 8 bytes
            estimated_batch_size = int(available_memory // estimated_array_size)
            
            return max(1, min(estimated_batch_size, 128))  # Reasonable bounds
            
        except Exception as e:
            warnings.warn(f"Could not estimate batch size: {e}")
            return 32
    
    def process_large_batch(self, arrays: List[np.ndarray], 
                          operation_func, progress_callback=None) -> List[np.ndarray]:
        """Process large batch of arrays with automatic batching."""
        results = []
        total_batches = (len(arrays) + self.batch_size - 1) // self.batch_size
        
        for batch_idx in range(total_batches):
            start_idx = batch_idx * self.batch_size
            end_idx = min(start_idx + self.batch_size, len(arrays))
            
            batch_arrays = arrays[start_idx:end_idx]
            
            # Process batch
            if self.gpu_processor.gpu_available:
                batch_results = self.gpu_processor.gpu_element_wise_operations(
                    batch_arrays, operation_func
                )
            else:
                batch_results = [operation_func(arr) for arr in batch_arrays]
            
            results.extend(batch_results)
            
            # Progress callback
            if progress_callback:
                progress = (batch_idx + 1) / total_batches
                progress_callback(progress, batch_idx + 1, total_batches)
        
        return results

# Performance comparison utilities
def compare_gpu_cpu_performance():
    """Compare GPU vs CPU performance for various NumPy operations."""
    print("Comparing GPU vs CPU performance...")
    
    processor = GPUArrayProcessor()
    
    # Test matrix multiplication performance
    sizes = [500, 1000, 2000, 4000]
    
    for size in sizes:
        print(f"\nTesting matrix multiplication - size: {size}x{size}")
        
        A = np.random.randn(size, size).astype(np.float64)
        B = np.random.randn(size, size).astype(np.float64)
        
        # CPU timing
        start_time = time.time()
        cpu_result = np.dot(A, B)
        cpu_time = time.time() - start_time
        
        # GPU timing (if available)
        if processor.gpu_available:
            start_time = time.time()
            gpu_result = processor.gpu_matrix_multiply(A, B)
            gpu_time
```

---

