## Parallel Array Operations


NumPy's array operations can be parallelized at multiple levels, from vectorized operations that leverage hardware parallelism to explicit parallel algorithms that distribute work across multiple threads or processes.

**Key points:**

- Vectorized operations automatically utilize SIMD instructions and multi-core processing
- Array broadcasting enables efficient parallel computation patterns
- Memory-bound vs. compute-bound operations require different parallelization strategies
- Parallel algorithms must consider cache locality and memory bandwidth limitations
- Integration with parallel libraries extends NumPy's native capabilities

**Example:**

```python
import numpy as np
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import multiprocessing as mp
from functools import partial
import time

class ParallelArrayOperations:
    """Comprehensive parallel array operations framework."""
    
    def __init__(self, backend='threads', n_workers=None):
        self.backend = backend
        self.n_workers = n_workers or mp.cpu_count()
        
        if backend == 'threads':
            self.executor = ThreadPoolExecutor(max_workers=self.n_workers)
        elif backend == 'processes':
            self.executor = ProcessPoolExecutor(max_workers=self.n_workers)
        else:
            raise ValueError("Backend must be 'threads' or 'processes'")
    
    def parallel_apply_along_axis(self, func, axis, arr, *args, **kwargs):
        """Parallel version of numpy.apply_along_axis."""
        if axis != 0:
            # Move target axis to first position
            arr = np.moveaxis(arr, axis, 0)
        
        # Split array along first axis
        chunks = np.array_split(arr, self.n_workers, axis=0)
        
        # Apply function to each chunk in parallel
        futures = []
        for chunk in chunks:
            future = self.executor.submit(
                lambda x: np.array([func(row, *args, **kwargs) for row in x]),
                chunk
            )
            futures.append(future)
        
        # Collect results
        results = [future.result() for future in futures]
        combined = np.concatenate(results, axis=0)
        
        # Restore original axis order if needed
        if axis != 0:
            combined = np.moveaxis(combined, 0, axis)
        
        return combined
    
    def parallel_ufunc_reduce(self, ufunc, arrays, axis=None):
        """Parallel reduction using universal functions."""
        def chunk_reduce(chunk_arrays):
            if len(chunk_arrays) == 1:
                return ufunc.reduce(chunk_arrays[0], axis=axis)
            else:
                # Reduce across multiple arrays
                result = chunk_arrays[0]
                for arr in chunk_arrays[1:]:
                    result = ufunc(result, arr)
                return ufunc.reduce(result, axis=axis) if axis is not None else result
        
        # Split arrays into chunks
        chunk_size = max(1, len(arrays) // self.n_workers)
        chunks = [arrays[i:i + chunk_size] for i in range(0, len(arrays), chunk_size)]
        
        # Process chunks in parallel
        futures = [self.executor.submit(chunk_reduce, chunk) for chunk in chunks]
        results = [future.result() for future in futures]
        
        # Final reduction
        if len(results) == 1:
            return results[0]
        else:
            final_result = results[0]
            for result in results[1:]:
                final_result = ufunc(final_result, result)
            return final_result
    
    def parallel_element_wise_transform(self, arrays, transform_func, output_dtype=None):
        """Apply element-wise transformations in parallel."""
        def process_chunk(array_chunk):
            return [transform_func(arr) for arr in array_chunk]
        
        # Determine output dtype
        if output_dtype is None:
            sample_output = transform_func(arrays[0][:1])
            output_dtype = sample_output.dtype
        
        # Split arrays into chunks
        chunk_size = max(1, len(arrays) // self.n_workers)
        chunks = [arrays[i:i + chunk_size] for i in range(0, len(arrays), chunk_size)]
        
        # Process in parallel
        futures = [self.executor.submit(process_chunk, chunk) for chunk in chunks]
        
        # Collect and combine results
        all_results = []
        for future in futures:
            all_results.extend(future.result())
        
        return all_results
    
    def parallel_pairwise_operations(self, arrays, operation_func):
        """Compute pairwise operations between arrays in parallel."""
        n_arrays = len(arrays)
        n_pairs = n_arrays * (n_arrays - 1) // 2
        
        # Generate all pairs
        pairs = []
        for i in range(n_arrays):
            for j in range(i + 1, n_arrays):
                pairs.append((i, j))
        
        def compute_pair_operation(pair_indices):
            i, j = pair_indices
            return operation_func(arrays[i], arrays[j])
        
        # Process pairs in parallel
        futures = [self.executor.submit(compute_pair_operation, pair) for pair in pairs]
        results = [future.result() for future in futures]
        
        # Organize results into matrix form
        result_matrix = np.zeros((n_arrays, n_arrays), dtype=object)
        pair_idx = 0
        for i in range(n_arrays):
            for j in range(i + 1, n_arrays):
                result_matrix[i, j] = results[pair_idx]
                result_matrix[j, i] = results[pair_idx]  # Symmetric
                pair_idx += 1
        
        return result_matrix

# Advanced parallel algorithms
class ParallelNumericalAlgorithms:
    """Implementation of parallel numerical algorithms."""
    
    def __init__(self, n_workers=None):
        self.n_workers = n_workers or mp.cpu_count()
    
    def parallel_monte_carlo_integration(self, func, bounds, n_samples=1000000):
        """Parallel Monte Carlo integration."""
        def monte_carlo_chunk(n_chunk_samples, random_seed):
            np.random.seed(random_seed)
            
            # Generate random samples within bounds
            samples = np.random.uniform(
                low=[b[0] for b in bounds],
                high=[b[1] for b in bounds],
                size=(n_chunk_samples, len(bounds))
            )
            
            # Evaluate function at sample points
            values = np.array([func(*sample) for sample in samples])
            
            # Compute volume and integral estimate
            volume = np.prod([b[1] - b[0] for b in bounds])
            integral_estimate = volume * np.mean(values)
            
            return integral_estimate, n_chunk_samples
        
        # Split samples across workers
        samples_per_worker = n_samples // self.n_workers
        
        with ProcessPoolExecutor(max_workers=self.n_workers) as executor:
            futures = []
            for i in range(self.n_workers):
                random_seed = np.random.randint(0, 2**31, dtype=np.int32)
                future = executor.submit(
                    monte_carlo_chunk,
                    samples_per_worker,
                    random_seed
                )
                futures.append(future)
            
            # Collect results and compute final estimate
            total_integral = 0
            total_samples = 0
            
            for future in futures:
                integral_chunk, n_chunk = future.result()
                total_integral += integral_chunk * n_chunk
                total_samples += n_chunk
            
            final_estimate = total_integral / total_samples
            return final_estimate
    
    def parallel_eigenvalue_computation(self, matrices):
        """Compute eigenvalues for multiple matrices in parallel."""
        def compute_eigenvals(matrix_batch):
            results = []
            for matrix in matrix_batch:
                try:
                    if np.allclose(matrix, matrix.T):
                        # Use specialized symmetric solver
                        eigenvals = np.linalg.eigvalsh(matrix)
                    else:
                        eigenvals = np.linalg.eigvals(matrix)
                    results.append(eigenvals)
                except np.linalg.LinAlgError:
                    results.append(None)
            return results
        
        # Batch matrices for parallel processing
        batch_size = max(1, len(matrices) // self.n_workers)
        batches = [matrices[i:i + batch_size] for i in range(0, len(matrices), batch_size)]
        
        with ThreadPoolExecutor(max_workers=self.n_workers) as executor:
            futures = [executor.submit(compute_eigenvals, batch) for batch in batches]
            
            # Collect all eigenvalue results
            all_eigenvals = []
            for future in futures:
                all_eigenvals.extend(future.result())
            
            return all_eigenvals
    
    def parallel_convolution_2d(self, images, kernels):
        """Parallel 2D convolution for multiple image-kernel pairs."""
        from scipy.signal import convolve2d
        
        def convolve_batch(image_kernel_pairs):
            results = []
            for image, kernel in image_kernel_pairs:
                convolved = convolve2d(image, kernel, mode='same', boundary='symm')
                results.append(convolved)
            return results
        
        # Pair images with kernels
        if len(kernels) == 1:
            # Broadcast single kernel to all images
            pairs = [(img, kernels[0]) for img in images]
        else:
            # Assume one-to-one correspondence
            pairs = list(zip(images, kernels))
        
        # Batch pairs for parallel processing
        batch_size = max(1, len(pairs) // self.n_workers)
        batches = [pairs[i:i + batch_size] for i in range(0, len(pairs), batch_size)]
        
        with ThreadPoolExecutor(max_workers=self.n_workers) as executor:
            futures = [executor.submit(convolve_batch, batch) for batch in batches]
            
            # Collect convolution results
            all_results = []
            for future in futures:
                all_results.extend(future.result())
            
            return all_results

# Performance comparison utilities
def compare_parallel_performance():
    """Compare performance of parallel vs sequential operations."""
    # Generate test data
    test_arrays = [np.random.randn(500, 500) for _ in range(16)]
    
    # Sequential processing
    start_time = time.time()
    sequential_results = [np.fft.fft2(arr).real for arr in test_arrays]
    sequential_time = time.time() - start_time
    
    # Parallel processing with threads
    parallel_ops = ParallelArrayOperations(backend='threads', n_workers=4)
    start_time = time.time()
    parallel_results = parallel_ops.parallel_element_wise_transform(
        test_arrays, lambda x: np.fft.fft2(x).real
    )
    parallel_time = time.time() - start_time
    
    print(f"Sequential time: {sequential_time:.3f} seconds")
    print(f"Parallel time: {parallel_time:.3f} seconds")
    print(f"Speedup: {sequential_time / parallel_time:.2f}x")
    
    # Verify results are equivalent
    for seq, par in zip(sequential_results, parallel_results):
        assert np.allclose(seq, par, rtol=1e-10)
    
    parallel_ops.executor.shutdown()

# Usage example
if __name__ == "__main__":
    # Test parallel array operations
    parallel_ops = ParallelArrayOperations(backend='threads', n_workers=4)
    
    # Test parallel apply along axis
    test_data = np.random.randn(1000, 100)
    result = parallel_ops.parallel_apply_along_axis(np.mean, axis=1, arr=test_data)
    print(f"Parallel apply_along_axis result shape: {result.shape}")
    
    # Test parallel Monte Carlo integration
    algorithms = ParallelNumericalAlgorithms(n_workers=4)
    
    def integrand(x, y):
        return np.exp(-(x**2 + y**2))  # 2D Gaussian
    
    integral_estimate = algorithms.parallel_monte_carlo_integration(
        integrand, [(-3, 3), (-3, 3)], n_samples=1000000
    )
    print(f"Monte Carlo integral estimate: {integral_estimate:.6f}")
    
    # Compare with analytical result (π for 2D Gaussian)
    analytical_result = np.pi
    error = abs(integral_estimate - analytical_result) / analytical_result
    print(f"Relative error: {error:.4f}")
    
    parallel_ops.executor.shutdown()
```

The parallel array operations framework automatically handles work distribution, load balancing, and result aggregation while preserving NumPy's array semantics and numerical accuracy.

