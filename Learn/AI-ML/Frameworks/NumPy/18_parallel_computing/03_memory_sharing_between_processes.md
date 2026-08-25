## Memory Sharing Between Processes


Efficient memory sharing enables parallel processing without data duplication overhead. NumPy arrays can share memory between processes through various mechanisms, including shared memory arrays, memory-mapped files, and specialized inter-process communication patterns.

**Key points:**

- Shared memory arrays eliminate data copying between processes
- Memory-mapped files enable efficient access to large datasets from multiple processes
- Process synchronization mechanisms prevent race conditions during shared array access
- Copy-on-write semantics optimize memory usage for read-heavy workloads
- Advanced sharing patterns support complex parallel algorithms with minimal memory overhead

**Example:**

```python
import numpy as np
import multiprocessing as mp
from multiprocessing import shared_memory, Process, Lock, Event
import mmap
import os
import time
import tempfile
from contextlib import contextmanager

class SharedArrayManager:
    """Manager for shared NumPy arrays across processes."""
    
    def __init__(self):
        self.shared_blocks = {}
        self.locks = {}
    
    def create_shared_array(self, name, shape, dtype=np.float64):
        """Create a shared memory array accessible by multiple processes."""
        # Calculate total size in bytes
        total_size = np.prod(shape) * np.dtype(dtype).itemsize
        
        # Create shared memory block
        try:
            shm = shared_memory.SharedMemory(create=True, size=total_size, name=name)
        except FileExistsError:
            # If already exists, connect to existing block
            shm = shared_memory.SharedMemory(name=name)
        
        # Create NumPy array backed by shared memory
        shared_array = np.ndarray(shape, dtype=dtype, buffer=shm.buf)
        
        # Store reference for cleanup
        self.shared_blocks[name] = shm
        self.locks[name] = Lock()
        
        return shared_array
    
    def connect_to_shared_array(self, name, shape, dtype=np.float64):
        """Connect to an existing shared memory array."""
        try:
            shm = shared_memory.SharedMemory(name=name)
            shared_array = np.ndarray(shape, dtype=dtype, buffer=shm.buf)
            return shared_array, shm
        except FileNotFoundError:
            raise ValueError(f"Shared memory block '{name}' not found")
    
    def cleanup_shared_array(self, name):
        """Clean up shared memory resources."""
        if name in self.shared_blocks:
            shm = self.shared_blocks[name]
            shm.close()
            shm.unlink()  # Remove from system
            del self.shared_blocks[name]
            del self.locks[name]
    
    def cleanup_all(self):
        """Clean up all shared memory resources."""
        for name in list(self.shared_blocks.keys()):
            self.cleanup_shared_array(name)

class MemoryMappedArray:
    """Memory-mapped array for efficient file-based sharing."""
    
    def __init__(self, filename, shape, dtype=np.float64, mode='r+'):
        self.filename = filename
        self.shape = shape
        self.dtype = dtype
        self.mode = mode
        
        # Calculate file size
        self.itemsize = np.dtype(dtype).itemsize
        self.total_size = np.prod(shape) * self.itemsize
        
        # Create or open memory-mapped file
        self._create_or_open_file()
        
        # Create memory-mapped array
        self.array = np.memmap(
            self.filename,
            dtype=dtype,
            mode=mode,
            shape=shape
        )
    
    def _create_or_open_file(self):
        """Create file if it doesn't exist, or verify size if it does."""
        if not os.path.exists(self.filename):
            # Create new file with correct size
            with open(self.filename, 'wb') as f:
                f.seek(self.total_size - 1)
                f.write(b'\0')
        else:
            # Verify existing file size
            current_size = os.path.getsize(self.filename)
            if current_size != self.total_size:
                raise ValueError(f"File size mismatch: expected {self.total_size}, got {current_size}")
    
    def flush(self):
        """Ensure changes are written to disk."""
        if hasattr(self.array, 'flush'):
            self.array.flush()
    
    def close(self):
        """Close memory-mapped array."""
        if hasattr(self.array, '_mmap'):
            del self.array
    
    def __enter__(self):
        return self.array
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.flush()
        self.close()

class ParallelArrayProcessor:
    """Process arrays in parallel with shared memory optimization."""
    
    def __init__(self, n_processes=None):
        self.n_processes = n_processes or mp.cpu_count()
        self.shared_manager = SharedArrayManager()
    
    def parallel_process_shared_array(self, array_data, process_func, chunk_overlap=0):
        """Process large array in parallel using shared memory."""
        # Create shared memory array
        shared_name = f"shared_array_{os.getpid()}_{int(time.time() * 1000000)}"
        shared_array = self.shared_manager.create_shared_array(
            shared_name, array_data.shape, array_data.dtype
        )
        
        # Copy data to shared memory
        shared_array[:] = array_data
        
        # Calculate chunk boundaries with overlap
        total_size = array_data.shape[0]
        chunk_size = total_size // self.n_processes
        
        # Define worker function
        def worker(process_id, start_idx, end_idx, shared_name, shape, dtype):
            # Connect to shared memory in worker process
            worker_array, shm = self.shared_manager.connect_to_shared_array(
                shared_name, shape, dtype
            )
            
            try:
                # Apply processing function to chunk
                if array_data.ndim == 1:
                    chunk = worker_array[start_idx:end_idx]
                else:
                    chunk = worker_array[start_idx:end_idx, :]
                
                result = process_func(chunk)
                
                # Write result back to shared memory
                if array_data.ndim == 1:
                    worker_array[start_idx:end_idx] = result
                else:
                    worker_array[start_idx:end_idx, :] = result
                
            finally:
                # Clean up worker connection
                shm.close()
        
        # Launch worker processes
        processes = []
        for i in range(self.n_processes):
            start_idx = i * chunk_size
            if i == self.n_processes - 1:
                end_idx = total_size  # Last process handles remainder
            else:
                end_idx = (i + 1) * chunk_size + chunk_overlap
                end_idx = min(end_idx, total_size)
            
            process = Process(
                target=worker,
                args=(i, start_idx, end_idx, shared_name, 
                      array_data.shape, array_data.dtype)
            )
            processes.append(process)
            process.start()
        
        # Wait for all processes to complete
        for process in processes:
            process.join()
        
        # Copy result back
        result_array = shared_array.copy()
        
        # Clean up shared memory
        self.shared_manager.cleanup_shared_array(shared_name)
        
        return result_array
    
    def parallel_reduce_shared_arrays(self, arrays, reduce_func):
        """Perform reduction across multiple shared arrays."""
        if not arrays:
            raise ValueError("No arrays provided for reduction")
        
        # Create shared memory for all input arrays
        shared_arrays = []
        shared_names = []
        
        for i, arr in enumerate(arrays):
            name = f"reduce_input_{i}_{os.getpid()}_{int(time.time() * 1000000)}"
            shared_arr = self.shared_manager.create_shared_array(name, arr.shape, arr.dtype)
            shared_arr[:] = arr
            shared_arrays.append(shared_arr)
            shared_names.append(name)
        
        # Create shared array for result
        result_name = f"reduce_result_{os.getpid()}_{int(time.time() * 1000000)}"
        result_shape = arrays[0].shape  # Assume all arrays have same shape
        result_array = self.shared_manager.create_shared_array(
            result_name, result_shape, arrays[0].dtype
        )
        
        # Worker function for reduction
        def reduction_worker(start_idx, end_idx, shared_names, result_name, 
                           array_shape, array_dtype):
            # Connect to all shared arrays
            worker_arrays = []
            shm_blocks = []
            
            try:
                for name in shared_names:
                    arr, shm = self.shared_manager.connect_to_shared_array(
                        name, array_shape, array_dtype
                    )
                    worker_arrays.append(arr)
                    shm_blocks.append(shm)
                
                # Connect to result array
                result_arr, result_shm = self.shared_manager.connect_to_shared_array(
                    result_name, array_shape, array_dtype
                )
                
                # Perform reduction on assigned slice
                if len(array_shape) == 1:
                    chunk_arrays = [arr[start_idx:end_idx] for arr in worker_arrays]
                    result_arr[start_idx:end_idx] = reduce_func(chunk_arrays, axis=0)
                else:
                    chunk_arrays = [arr[start_idx:end_idx, :] for arr in worker_arrays]
                    result_arr[start_idx:end_idx, :] = reduce_func(chunk_arrays, axis=0)
                
            finally:
                # Clean up worker connections
                for shm in shm_blocks:
                    shm.close()
                result_shm.close()
        
        # Launch reduction workers
        chunk_size = result_shape[0] // self.n_processes
        processes = []
        
        for i in range(self.n_processes):
            start_idx = i * chunk_size
            end_idx = start_idx + chunk_size if i < self.n_processes - 1 else result_shape[0]
            
            process = Process(
                target=reduction_worker,
                args=(start_idx, end_idx, shared_names, result_name,
                      result_shape, arrays[0].dtype)
            )
            processes.append(process)
            process.start()
        
        # Wait for completion
        for process in processes:
            process.join()
        
        # Get final result
        final_result = result_array.copy()
        
        # Clean up all shared memory
        for name in shared_names:
            self.shared_manager.cleanup_shared_array(name)
        self.shared_manager.cleanup_shared_array(result_name)
        
        return final_result

# Advanced shared memory patterns
class AdvancedSharedMemoryPatterns:
    """Advanced patterns for shared memory usage in parallel NumPy operations."""
    
    def __init__(self, n_processes=None):
        self.n_processes = n_processes or mp.cpu_count()
        self.manager = mp.Manager()
    
    def producer_consumer_pattern(self, data_generator, consumer_func, buffer_size=10):
        """Producer-consumer pattern with shared memory buffers."""
        # Create circular buffer using shared memory
        buffer_arrays = []
        buffer_ready = []
        buffer_locks = []
        
        # Get sample data to determine shape and dtype
        sample_data = next(data_generator())
        
        for i in range(buffer_size):
            # Create shared memory for each buffer slot
            shm = shared_memory.SharedMemory(
                create=True,
                size=sample_data.nbytes,
                name=f"buffer_{os.getpid()}_{i}"
            )
            
            # Create NumPy array backed by shared memory
            buffer_array = np.ndarray(
                sample_data.shape,
                dtype=sample_data.dtype,
                buffer=shm.buf
            )
            
            buffer_arrays.append((buffer_array, shm))
            buffer_ready.append(Event())
            buffer_locks.append(Lock())
        
        # Producer process
        def producer():
            buffer_idx = 0
            for data in data_generator():
                # Wait for buffer slot to be available
                with buffer_locks[buffer_idx]:
                    buffer_arrays[buffer_idx][0][:] = data
                    buffer_ready[buffer_idx].set()
                
                buffer_idx = (buffer_idx + 1) % buffer_size
        
        # Consumer processes
        def consumer(consumer_id):
            buffer_idx = 0
            results = []
            
            while True:
                # Wait for data to be ready
                if buffer_ready[buffer_idx].wait(timeout=1.0):
                    with buffer_locks[buffer_idx]:
                        if buffer_ready[buffer_idx].is_set():
                            # Process data
                            data = buffer_arrays[buffer_idx][0].copy()
                            result = consumer_func(data)
                            results.append(result)
                            
                            # Mark buffer as consumed
                            buffer_ready[buffer_idx].clear()
                
                buffer_idx = (buffer_idx + 1) % buffer_size
            
            return results
        
        # Start producer and consumers
        producer_process = Process(target=producer)
        consumer_processes = [
            Process(target=consumer, args=(i,)) 
            for i in range(self.n_processes)
        ]
        
        producer_process.start()
        for consumer_process in consumer_processes:
            consumer_process.start()
        
        # Wait for completion (simplified for demonstration)
        producer_process.join(timeout=10)
        for consumer_process in consumer_processes:
            consumer_process.join(timeout=5)
        
        # Cleanup shared memory
        for buffer_array, shm in buffer_arrays:
            shm.close()
            shm.unlink()
    
    def parallel_stencil_computation(self, grid, stencil_func, iterations=1):
        """Parallel stencil computation with ghost cell communication."""
        h, w = grid.shape
        
        # Create shared memory arrays for current and next grid states
        current_shm = shared_memory.SharedMemory(
            create=True,
            size=grid.nbytes,
            name=f"current_grid_{os.getpid()}"
        )
        next_shm = shared_memory.SharedMemory(
            create=True,
            size=grid.nbytes,
            name=f"next_grid_{os.getpid()}"
        )
        
        current_grid = np.ndarray(grid.shape, dtype=grid.dtype, buffer=current_shm.buf)
        next_grid = np.ndarray(grid.shape, dtype=grid.dtype, buffer=next_shm.buf)
        
        # Initialize current grid
        current_grid[:] = grid
        
        # Create synchronization barriers
        iteration_barrier = mp.Barrier(self.n_processes)
        
        def stencil_worker(process_id, start_row, end_row):
            """Worker process for stencil computation."""
            # Connect to shared memory in worker
            worker_current, current_shm_worker = self._connect_to_shared_memory(
                f"current_grid_{os.getpid()}", grid.shape, grid.dtype
            )
            worker_next, next_shm_worker = self._connect_to_shared_memory(
                f"next_grid_{os.getpid()}", grid.shape, grid.dtype
            )
            
            try:
                for iteration in range(iterations):
                    # Compute stencil for assigned rows
                    for i in range(max(1, start_row), min(h-1, end_row)):
                        for j in range(1, w-1):
                            # Apply stencil function
                            worker_next[i, j] = stencil_func(
                                worker_current[i-1:i+2, j-1:j+2]
                            )
                    
                    # Synchronize all processes before swapping grids
                    iteration_barrier.wait()
                    
                    # Swap grid references (conceptually)
                    if process_id == 0:  # Only one process does the swap
                        worker_current[:], worker_next[:] = worker_next[:], worker_current[:]
                    
                    iteration_barrier.wait()  # Wait for swap to complete
            
            finally:
                current_shm_worker.close()
                next_shm_worker.close()
        
        # Launch worker processes
        rows_per_process = h // self.n_processes
        processes = []
        
        for i in range(self.n_processes):
            start_row = i * rows_per_process
            end_row = start_row + rows_per_process if i < self.n_processes - 1 else h
            
            process = Process(
                target=stencil_worker,
                args=(i, start_row, end_row)
            )
            processes.append(process)
            process.start()
        
        # Wait for all processes to complete
        for process in processes:
            process.join()
        
        # Get final result
        result = current_grid.copy()
        
        # Cleanup
        current_shm.close()
        current_shm.unlink()
        next_shm.close()
        next_shm.unlink()
        
        return result
    
    def _connect_to_shared_memory(self, name, shape, dtype):
        """Helper method to connect to existing shared memory."""
        shm = shared_memory.SharedMemory(name=name)
        array = np.ndarray(shape, dtype=dtype, buffer=shm.buf)
        return array, shm

# Memory-mapped file operations for large-scale parallel processing
class LargeScaleMemoryMappedOperations:
    """Operations on memory-mapped arrays for datasets larger than RAM."""
    
    def __init__(self, temp_dir=None):
        self.temp_dir = temp_dir or tempfile.gettempdir()
    
    @contextmanager
    def create_temp_memmap(self, shape, dtype=np.float64, prefix="temp_array"):
        """Create temporary memory-mapped array."""
        # Generate unique filename
        fd, filename = tempfile.mkstemp(
            suffix='.dat',
            prefix=prefix,
            dir=self.temp_dir
        )
        os.close(fd)  # Close file descriptor, we'll use memory mapping
        
        try:
            # Create memory-mapped array
            memmap_array = np.memmap(
                filename,
                dtype=dtype,
                mode='w+',
                shape=shape
            )
            yield memmap_array
        finally:
            # Cleanup
            if 'memmap_array' in locals():
                del memmap_array
            if os.path.exists(filename):
                os.remove(filename)
    
    def parallel_large_matrix_multiply(self, A_file, B_file, output_file, 
                                     A_shape, B_shape, block_size=1024):
        """Parallel multiplication of large matrices stored as memory-mapped files."""
        # Open memory-mapped arrays
        A = np.memmap(A_file, dtype=np.float64, mode='r', shape=A_shape)
        B = np.memmap(B_file, dtype=np.float64, mode='r', shape=B_shape)
        
        # Create output memory-mapped array
        output_shape = (A_shape[0], B_shape[1])
        C = np.memmap(output_file, dtype=np.float64, mode='w+', shape=output_shape)
        
        def compute_block_worker(i_start, i_end, j_start, j_end, k_start, k_end):
            """Worker function for block matrix multiplication."""
            # Load required blocks into memory
            A_block = A[i_start:i_end, k_start:k_end].copy()
            B_block = B[k_start:k_end, j_start:j_end].copy()
            
            # Compute block multiplication
            C_block = np.dot(A_block, B_block)
            
            # Accumulate result (thread-safe for non-overlapping blocks)
            C[i_start:i_end, j_start:j_end] += C_block
        
        # Generate block computation tasks
        tasks = []
        for i in range(0, A_shape[0], block_size):
            for j in range(0, B_shape[1], block_size):
                for k in range(0, A_shape[1], block_size):
                    i_end = min(i + block_size, A_shape[0])
                    j_end = min(j + block_size, B_shape[1])
                    k_end = min(k + block_size, A_shape[1])
                    
                    tasks.append((i, i_end, j, j_end, k, k_end))
        
        # Execute tasks in parallel
        with ProcessPoolExecutor(max_workers=self.n_processes) as executor:
            futures = [
                executor.submit(compute_block_worker, *task)
                for task in tasks
            ]
            
            # Wait for all tasks to complete
            for future in futures:
                future.result()
        
        # Ensure all data is written to disk
        C.flush()
        
        return C
    
    def parallel_array_chunk_processing(self, input_file, output_file,
                                      input_shape, process_func, 
                                      chunk_size=10000, dtype=np.float64):
        """Process large arrays in chunks across multiple processes."""
        # Open input and output memory-mapped arrays
        input_array = np.memmap(input_file, dtype=dtype, mode='r', shape=input_shape)
        output_array = np.memmap(output_file, dtype=dtype, mode='w+', shape=input_shape)
        
        def process_chunk_worker(start_idx, end_idx):
            """Worker function to process array chunk."""
            # Load chunk into memory
            chunk = input_array[start_idx:end_idx].copy()
            
            # Apply processing function
            processed_chunk = process_func(chunk)
            
            # Write result back to memory-mapped file
            output_array[start_idx:end_idx] = processed_chunk
        
        # Generate chunk boundaries
        total_size = input_shape[0]
        chunk_tasks = []
        
        for start in range(0, total_size, chunk_size):
            end = min(start + chunk_size, total_size)
            chunk_tasks.append((start, end))
        
        # Process chunks in parallel
        with ProcessPoolExecutor(max_workers=self.n_processes) as executor:
            futures = [
                executor.submit(process_chunk_worker, start, end)
                for start, end in chunk_tasks
            ]
            
            # Wait for completion
            for future in futures:
                future.result()
        
        # Ensure all data is written
        output_array.flush()
        
        return output_array

# Usage examples and performance demonstrations
def demonstrate_shared_memory_operations():
    """Demonstrate various shared memory operations."""
    
    # Example 1: Basic shared array processing
    print("Testing shared array processing...")
    processor = ParallelArrayProcessor(n_processes=4)
    
    # Create test data
    large_array = np.random.randn(100000, 10)
    
    # Define processing function
    def normalize_rows(chunk):
        return (chunk - np.mean(chunk, axis=1, keepdims=True)) / np.std(chunk, axis=1, keepdims=True)
    
    # Process in parallel with shared memory
    start_time = time.time()
    result = processor.parallel_process_shared_array(large_array, normalize_rows)
    shared_memory_time = time.time() - start_time
    
    # Process sequentially for comparison
    start_time = time.time()
    sequential_result = normalize_rows(large_array)
    sequential_time = time.time() - start_time
    
    print(f"Shared memory time: {shared_memory_time:.3f} seconds")
    print(f"Sequential time: {sequential_time:.3f} seconds")
    print(f"Speedup: {sequential_time / shared_memory_time:.2f}x")
    print(f"Results match: {np.allclose(result, sequential_result, rtol=1e-10)}")
    
    # Example 2: Memory-mapped file operations
    print("\nTesting memory-mapped operations...")
    
    with tempfile.NamedTemporaryFile(suffix='.dat', delete=False) as temp_file:
        temp_filename = temp_file.name
    
    try:
        # Create large memory-mapped array
        large_shape = (50000, 100)
        with MemoryMappedArray(temp_filename, large_shape, dtype=np.float64, mode='w+') as mmap_array:
            # Initialize with random data
            chunk_size = 10000
            for i in range(0, large_shape[0], chunk_size):
                end_idx = min(i + chunk_size, large_shape[0])
                mmap_array[i:end_idx] = np.random.randn(end_idx - i, large_shape[1])
        
        # Process using memory-mapped operations
        large_ops = LargeScaleMemoryMappedOperations()
        
        with tempfile.NamedTemporaryFile(suffix='.dat', delete=False) as output_file:
            output_filename = output_file.name
        
        try:
            def square_and_normalize(chunk):
                squared = chunk ** 2
                return squared / np.mean(squared, axis=1, keepdims=True)
            
            start_time = time.time()
            result_mmap = large_ops.parallel_array_chunk_processing(
                temp_filename, output_filename, large_shape,
                square_and_normalize, chunk_size=5000
            )
            mmap_time = time.time() - start_time
            
            print(f"Memory-mapped processing time: {mmap_time:.3f} seconds")
            print(f"Processed {large_shape[0] * large_shape[1]} elements")
            print(f"Throughput: {(large_shape[0] * large_shape[1]) / mmap_time / 1e6:.2f} M elements/second")
        
        finally:
            if os.path.exists(output_filename):
                os.remove(output_filename)
    
    finally:
        if os.path.exists(temp_filename):
            os.remove(temp_filename)

if __name__ == "__main__":
    demonstrate_shared_memory_operations()
```

