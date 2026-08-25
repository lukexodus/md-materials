## Extension Development


Extension development encompasses the complete workflow of creating, testing, and distributing NumPy-compatible extensions, including packaging, documentation, and integration with the broader scientific Python ecosystem.

**Key points:**

- Comprehensive build systems supporting multiple platforms and Python versions
- Testing frameworks that validate numerical accuracy and performance characteristics
- Documentation generation and API compatibility maintenance
- Distribution through package repositories with proper dependency management
- Integration testing with downstream packages that depend on the extension

**Example:**

```python
# Project structure for a complete NumPy extension
"""
numpy_extension_project/
├── setup.py
├── pyproject.toml
├── README.md
├── src/
│   ├── numpy_extension/
│   │   ├── __init__.py
│   │   ├── core.py
│   │   ├── _core.pyx          # Cython implementation
│   │   └── tests/
│   │       ├── __init__.py
│   │       ├── test_core.py
│   │       └── test_performance.py
├── docs/
│   ├── source/
│   └── Makefile
└── benchmarks/
    └── benchmark_suite.py
"""

# setup.py - Comprehensive build configuration
import os
import sys
from setuptools import setup, find_packages, Extension
from Cython.Build import cythonize
import numpy

# Read version from package
def read_version():
    version_file = os.path.join('src', 'numpy_extension', '__init__.py')
    with open(version_file, 'r') as f:
        for line in f:
            if line.startswith('__version__'):
                return line.split('=')[1].strip().strip("'\"")
    raise RuntimeError('Version not found')

# Define extensions
extensions = [
    Extension(
        'numpy_extension._core',
        sources=['src/numpy_extension/_core.pyx'],
        include_dirs=[numpy.get_include()],
        extra_compile_args=['-O3', '-march=native', '-fopenmp'],
        extra_link_args=['-fopenmp'],
        language='c++'
    )
]

# Setup configuration
setup(
    name='numpy_extension',
    version=read_version(),
    author='Developer Name',
    author_email='developer@example.com',
    description='High-performance NumPy extension',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/username/numpy_extension',
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    ext_modules=cythonize(extensions, compiler_directives={'language_level': 3}),
    install_requires=[
        'numpy>=1.20.0',
        'scipy>=1.6.0',
    ],
    extras_require={
        'dev': ['pytest>=6.0', 'pytest-benchmark', 'black', 'flake8'],
        'docs': ['sphinx', 'sphinx-rtd-theme', 'numpydoc'],
        'test': ['pytest-cov', 'hypothesis'],
    },
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Topic :: Scientific/Engineering',
    ],
    python_requires='>=3.8',
    zip_safe=False,
)

# pyproject.toml - Modern Python packaging configuration
[build-system]
requires = ["setuptools>=45", "wheel", "Cython>=0.29", "numpy>=1.20.0"]
build-backend = "setuptools.build_meta"

[tool.black]
line-length = 88
target-version = ['py38']

[tool.pytest.ini_options]
testpaths = ["src/numpy_extension/tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "--strict-markers --benchmark-disable"

[tool.coverage.run]
source = ["src/numpy_extension"]
omit = ["*/tests/*", "*/benchmarks/*"]

# src/numpy_extension/__init__.py - Package initialization
"""
NumPy Extension Package
======================

High-performance extensions for NumPy providing specialized algorithms
and optimized implementations for scientific computing applications.
"""

__version__ = '0.1.0'
__author__ = 'Developer Name'

from .core import (
    fast_matrix_ops,
    optimized_algorithms,
    CustomArray,
    PerformanceTimer
)

# Import compiled extensions
try:
    from ._core import (
        compiled_functions,
        cython_implementations
    )
except ImportError:
    import warnings
    warnings.warn("Compiled extensions not available, using Python fallbacks")
    compiled_functions = None
    cython_implementations = None

# Define public API
__all__ = [
    'fast_matrix_ops',
    'optimized_algorithms', 
    'CustomArray',
    'PerformanceTimer',
    'compiled_functions',
    'cython_implementations'
]

# src/numpy_extension/core.py - Main implementation
import numpy as np
import time
from typing import Union, Tuple, Optional, List
import warnings

class PerformanceTimer:
    """Context manager for measuring execution time of NumPy operations."""
    
    def __init__(self, operation_name: str = "Operation"):
        self.operation_name = operation_name
        self.start_time = None
        self.end_time = None
        self.execution_time = None
    
    def __enter__(self):
        self.start_time = time.perf_counter()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.end_time = time.perf_counter()
        self.execution_time = self.end_time - self.start_time
        print(f"{self.operation_name} completed in {self.execution_time:.6f} seconds")

class CustomArray:
    """
    Extended array class with domain-specific optimizations and metadata support.
    """
    
    def __init__(self, data, metadata: Optional[dict] = None, validate: bool = True):
        self._data = np.asarray(data)
        self._metadata = metadata or {}
        
        if validate:
            self._validate_data()
    
    def _validate_data(self):
        """Validate input data consistency."""
        if self._data.size == 0:
            warnings.warn("Empty array provided", UserWarning)
        
        if np.any(np.isnan(self._data)):
            warnings.warn("Array contains NaN values", UserWarning)
            self._metadata['has_nan'] = True
    
    @property
    def data(self):
        """Access to underlying NumPy array."""
        return self._data
    
    @property
    def metadata(self):
        """Access to metadata dictionary."""
        return self._metadata.copy()
    
    def __array__(self, dtype=None):
        """NumPy array protocol implementation."""
        if dtype is None:
            return self._data
        return self._data.astype(dtype)
    
    def __array_ufunc__(self, ufunc, method, *inputs, **kwargs):
        """Handle universal function calls."""
        if method == '__call__':
            # Convert CustomArray inputs to NumPy arrays
            converted_inputs = []
            for input_ in inputs:
                if isinstance(input_, CustomArray):
                    converted_inputs.append(input_._data)
                else:
                    converted_inputs.append(input_)
            
            # Apply ufunc and wrap result
            result = ufunc(*converted_inputs, **kwargs)
            
            if isinstance(result, np.ndarray):
                # Combine metadata from all CustomArray inputs
                combined_metadata = {}
                for input_ in inputs:
                    if isinstance(input_, CustomArray):
                        combined_metadata.update(input_._metadata)
                
                return CustomArray(result, combined_metadata, validate=False)
            return result
        else:
            return NotImplemented
    
    def optimized_operation(self, operation: str, **kwargs):
        """
        Apply optimized operations based on array characteristics.
        """
        if operation == 'matrix_multiply' and self._data.ndim == 2:
            return self._optimized_matrix_multiply(**kwargs)
        elif operation == 'statistical_summary':
            return self._compute_statistical_summary(**kwargs)
        else:
            raise ValueError(f"Unknown operation: {operation}")
    
    def _optimized_matrix_multiply(self, other, **kwargs):
        """Optimized matrix multiplication with automatic method selection."""
        other_data = other._data if isinstance(other, CustomArray) else np.asarray(other)
        
        # Choose algorithm based on matrix characteristics
        if self._data.shape[0] > 1000 and self._data.shape[1] > 1000:
            # Use blocked algorithm for large matrices
            return self._blocked_matrix_multiply(other_data)
        else:
            # Use standard NumPy implementation for smaller matrices
            return CustomArray(np.dot(self._data, other_data))
    
    def _blocked_matrix_multiply(self, other, block_size: int = 256):
        """Cache-efficient blocked matrix multiplication."""
        m, k = self._data.shape
        n = other.shape[1]
        result = np.zeros((m, n), dtype=np.result_type(self._data.dtype, other.dtype))
        
        for i in range(0, m, block_size):
            for j in range(0, n, block_size):
                for l in range(0, k, block_size):
                    # Block boundaries
                    i_end = min(i + block_size, m)
                    j_end = min(j + block_size, n)
                    l_end = min(l + block_size, k)
                    
                    # Compute block multiplication
                    result[i:i_end, j:j_end] += np.dot(
                        self._data[i:i_end, l:l_end],
                        other[l:l_end, j:j_end]
                    )
        
        return CustomArray(result, self._metadata.copy())
    
    def _compute_statistical_summary(self, percentiles: List[float] = [25, 50, 75]):
        """Comprehensive statistical summary with metadata tracking."""
        summary = {
            'mean': np.mean(self._data),
            'std': np.std(self._data),
            'min': np.min(self._data),
            'max': np.max(self._data),
            'shape': self._data.shape,
            'dtype': str(self._data.dtype),
            'percentiles': {}
        }
        
        for p in percentiles:
            summary['percentiles'][f'{p}th'] = np.percentile(self._data, p)
        
        # Add metadata information
        if self._metadata:
            summary['metadata'] = self._metadata.copy()
        
        return summary

def fast_matrix_ops(matrices: List[np.ndarray], operation: str = 'chain_multiply'):
    """
    Optimized batch matrix operations with automatic algorithm selection.
    """
    if not matrices:
        raise ValueError("Empty matrix list provided")
    
    if operation == 'chain_multiply':
        return _optimal_chain_multiplication(matrices)
    elif operation == 'batch_inverse':
        return _batch_matrix_inverse(matrices)
    elif operation == 'batch_eigenvals':
        return _batch_eigenvalue_computation(matrices)
    else:
        raise ValueError(f"Unknown operation: {operation}")

def _optimal_chain_multiplication(matrices: List[np.ndarray]):
    """
    Optimal matrix chain multiplication using dynamic programming.
    """
    n = len(matrices)
    if n == 1:
        return matrices[0]
    
    # Get matrix dimensions
    dims = [matrices[0].shape[0]] + [m.shape[1] for m in matrices]
    
    # Dynamic programming for optimal parenthesization
    cost = np.zeros((n, n))
    split = np.zeros((n, n), dtype=int)
    
    for length in range(2, n + 1):
        for i in range(n - length + 1):
            j = i + length - 1
            cost[i][j] = float('inf')
            
            for k in range(i, j):
                temp_cost = (cost[i][k] + cost[k + 1][j] + 
                           dims[i] * dims[k + 1] * dims[j + 1])
                if temp_cost < cost[i][j]:
                    cost[i][j] = temp_cost
                    split[i][j] = k
    
    # Perform multiplication with optimal order
    def multiply_optimal(i: int, j: int) -> np.ndarray:
        if i == j:
            return matrices[i]
        else:
            k = split[i][j]
            left = multiply_optimal(i, k)
            right = multiply_optimal(k + 1, j)
            return np.dot(left, right)
    
    return multiply_optimal(0, n - 1)

def _batch_matrix_inverse(matrices: List[np.ndarray]):
    """Batch computation of matrix inverses with error handling."""
    results = []
    for i, matrix in enumerate(matrices):
        try:
            # Check for square matrix
            if matrix.shape[0] != matrix.shape[1]:
                raise ValueError(f"Matrix {i} is not square")
            
            # Compute inverse with condition number check
            cond_num = np.linalg.cond(matrix)
            if cond_num > 1e12:
                warnings.warn(f"Matrix {i} is ill-conditioned (cond={cond_num:.2e})")
            
            inv_matrix = np.linalg.inv(matrix)
            results.append(inv_matrix)
            
        except np.linalg.LinAlgError as e:
            warnings.warn(f"Failed to compute inverse for matrix {i}: {e}")
            results.append(None)
    
    return results

def _batch_eigenvalue_computation(matrices: List[np.ndarray]):
    """Batch eigenvalue computation with automatic algorithm selection."""
    results = []
    for matrix in matrices:
        # Check if matrix is symmetric for optimization
        if np.allclose(matrix, matrix.T):
            # Use specialized symmetric eigenvalue solver
            eigenvals = np.linalg.eigvalsh(matrix)
        else:
            # Use general eigenvalue solver
            eigenvals = np.linalg.eigvals(matrix)
        
        results.append(eigenvals)
    
    return results

def optimized_algorithms(data: np.ndarray, algorithm: str, **kwargs):
    """
    Collection of optimized algorithms for common scientific computing tasks.
    """
    if algorithm == 'fft_convolution':
        return _fft_convolution(data, kwargs.get('kernel'))
    elif algorithm == 'adaptive_threshold':
        return _adaptive_threshold(data, **kwargs)
    elif algorithm == 'robust_statistics':
        return _robust_statistics(data, **kwargs)
    else:
        raise ValueError(f"Unknown algorithm: {algorithm}")

def _fft_convolution(signal: np.ndarray, kernel: np.ndarray):
    """FFT-based convolution for large signals."""
    # Determine optimal size for FFT
    conv_size = signal.size + kernel.size - 1
    fft_size = 2 ** int(np.ceil(np.log2(conv_size)))
    
    # Perform convolution in frequency domain
    signal_fft = np.fft.fft(signal, fft_size)
    kernel_fft = np.fft.fft(kernel, fft_size)
    result_fft = signal_fft * kernel_fft
    
    # Transform back and trim to correct size
    result = np.fft.ifft(result_fft).real[:conv_size]
    return result

def _adaptive_threshold(image: np.ndarray, window_size: int = 15, c: float = 2):
    """Adaptive thresholding for image processing."""
    # Compute local mean using efficient filtering
    from scipy.ndimage import uniform_filter
    
    local_mean = uniform_filter(image.astype(np.float64), size=window_size)
    threshold = local_mean - c
    
    return (image > threshold).astype(np.uint8)

def _robust_statistics(data: np.ndarray, method: str = 'mad'):
    """Robust statistical estimators."""
    if method == 'mad':  # Median Absolute Deviation
        median = np.median(data)
        mad = np.median(np.abs(data - median))
        return {'median': median, 'mad': mad, 'robust_std': 1.4826 * mad}
    elif method == 'trimmed_mean':
        trim_percent = 0.1  # Trim 10% from each end
        sorted_data = np.sort(data)
        n = len(sorted_data)
        trim_count = int(n * trim_percent)
        trimmed = sorted_data[trim_count:n-trim_count]
        return {'trimmed_mean': np.mean(trimmed), 'trim_percent': trim_percent}
    else:
        raise ValueError(f"Unknown robust statistics method: {method}")

# src/numpy_extension/tests/test_core.py - Comprehensive test suite
import pytest
import numpy as np
from numpy.testing import assert_allclose, assert_array_equal
import sys
import os

# Add src directory to path for testing
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'src'))

from numpy_extension.core import (
    CustomArray,
    fast_matrix_ops,
    optimized_algorithms,
    PerformanceTimer
)

class TestCustomArray:
    """Test suite for CustomArray class."""
    
    def test_initialization(self):
        """Test CustomArray initialization and basic properties."""
        data = np.random.randn(10, 5)
        metadata = {'source': 'test', 'processed': True}
        
        arr = CustomArray(data, metadata)
        
        assert_array_equal(arr.data, data)
        assert arr.metadata == metadata
        assert arr.data.shape == (10, 5)
    
    def test_numpy_compatibility(self):
        """Test compatibility with NumPy functions."""
        data = np.random.randn(5, 5)
        arr = CustomArray(data)
        
        # Test that NumPy functions work
        mean_result = np.mean(arr)
        sum_result = np.sum(arr)
        
        assert np.isclose(mean_result, np.mean(data))
        assert np.isclose(sum_result, np.sum(data))
    
    def test_ufunc_operations(self):
        """Test universal function operations."""
        data1 = np.random.randn(3, 3)
        data2 = np.random.randn(3, 3)
        
        arr1 = CustomArray(data1, {'id': 1})
        arr2 = CustomArray(data2, {'id': 2})
        
        # Test addition
        result = arr1 + arr2
        expected = data1 + data2
        
        assert isinstance(result, CustomArray)
        assert_allclose(result.data, expected)
    
    def test_matrix_multiply_optimization(self):
        """Test optimized matrix multiplication."""
        # Small matrices (should use standard algorithm)
        small_a = CustomArray(np.random.randn(50, 30))
        small_b = CustomArray(np.random.randn(30, 40))
        
        result_small = small_a.optimized_operation('matrix_multiply', other=small_b)
        expected_small = np.dot(small_a.data, small_b.data)
        
        assert_allclose(result_small.data, expected_small, rtol=1e-10)
    
    @pytest.mark.parametrize("percentiles", [[25, 50, 75], [10, 90], [1, 99]])
    def test_statistical_summary(self, percentiles):
        """Test statistical summary computation."""
        data = np.random.randn(1000)
        arr = CustomArray(data, {'test': True})
        
        summary = arr.optimized_operation('statistical_summary', 
                                        percentiles=percentiles)
        
        assert 'mean' in summary
        assert 'std' in summary
        assert 'percentiles' in summary
        assert len(summary['percentiles']) == len(percentiles)
        assert summary['metadata']['test'] == True

class TestFastMatrixOps:
    """Test suite for fast matrix operations."""
    
    def test_chain_multiplication(self):
        """Test optimal matrix chain multiplication."""
        matrices = [
            np.random.randn(10, 15),
            np.random.randn(15, 5),
            np.random.randn(5, 20)
        ]
        
        result = fast_matrix_ops(matrices, 'chain_multiply')
        
        # Compare with sequential multiplication
        expected = matrices[0]
        for mat in matrices[1:]:
            expected = np.dot(expected, mat)
        
        assert_allclose(result, expected, rtol=1e-10)
        assert result.shape == (10, 20)
    
    def test_batch_inverse(self):
        """Test batch matrix inverse computation."""
        # Create well-conditioned test matrices
        matrices = []
        for i in range(5):
            # Generate symmetric positive definite matrix
            A = np.random.randn(4, 4)
            matrices.append(np.dot(A, A.T) + np.eye(4))
        
        inverses = fast_matrix_ops(matrices, 'batch_inverse')
        
        # Test that A * A^(-1) = I for each matrix
        for i, (mat, inv) in enumerate(zip(matrices, inverses)):
            if inv is not None:  # Skip failed inversions
                product = np.dot(mat, inv)
                assert_allclose(product, np.eye(4), atol=1e-10)
    
    def test_batch_eigenvals(self):
        """Test batch eigenvalue computation."""
        matrices = [
            np.random.randn(5, 5),
            np.array([[1, 2], [2, 1]]),  # Symmetric matrix
        ]
        # Make first matrix symmetric
        matrices[0] = (matrices[0] + matrices[0].T) / 2
        
        eigenvals_list = fast_matrix_ops(matrices, 'batch_eigenvals')
        
        assert len(eigenvals_list) == 2
        assert len(eigenvals_list[0]) == 5  # 5x5 matrix has 5 eigenvalues
        assert len(eigenvals_list[1]) == 2  # 2x2 matrix has 2 eigenvalues

class TestOptimizedAlgorithms:
    """Test suite for optimized algorithms."""
    
    def test_fft_convolution(self):
        """Test FFT-based convolution."""
        signal = np.array([1, 2, 3, 4, 5])
        kernel = np.array([0.5, -0.5])
        
        result = optimized_algorithms(signal, 'fft_convolution', kernel=kernel)
        
        # Compare with NumPy's convolution
        expected = np.convolve(signal, kernel, mode='full')
        assert_allclose(result, expected, rtol=1e-10)
    
    def test_adaptive_threshold(self):
        """Test adaptive thresholding algorithm."""
        # Create test image with known structure
        image = np.zeros((20, 20))
        image[5:15, 5:15] = 100  # Bright square in center
        
        result = optimized_algorithms(image, 'adaptive_threshold', 
                                    window_size=5, c=10)
        
        assert result.shape == image.shape
        assert result.dtype == np.uint8
        assert np.all((result == 0) | (result == 1))  # Binary output
    
    @pytest.mark.parametrize("method", ['mad', 'trimmed_mean'])
    def test_robust_statistics(self, method):
        """Test robust statistical estimators."""
        # Create data with outliers
        normal_data = np.random.randn(100)
        outliers = np.array([10, -10, 15, -15])  # Clear outliers
        data = np.concatenate([normal_data, outliers])
        
        result = optimized_algorithms(data, 'robust_statistics', method=method)
        
        assert isinstance(result, dict)
        if method == 'mad':
            assert 'median' in result
            assert 'mad' in result
            assert 'robust_std' in result
        elif method == 'trimmed_mean':
            assert 'trimmed_mean' in result
            assert 'trim_percent' in result

class TestPerformanceTimer:
    """Test suite for performance measurement utilities."""
    
    def test_timer_context_manager(self):
        """Test performance timer context manager."""
        with PerformanceTimer("Test operation") as timer:
            # Simulate some computation
            result = np.sum(np.random.randn(1000, 1000))
        
        assert timer.execution_time is not None
        assert timer.execution_time > 0
        assert timer.start_time is not None
        assert timer.end_time is not None

# src/numpy_extension/tests/test_performance.py - Performance benchmarks
import pytest
import numpy as np
import time
from numpy_extension.core import CustomArray, fast_matrix_ops

class TestPerformanceBenchmarks:
    """Performance benchmarks for extension components."""
    
    @pytest.mark.benchmark
    def test_matrix_multiplication_performance(self, benchmark):
        """Benchmark matrix multiplication performance."""
        a = np.random.randn(500, 400)
        b = np.random.randn(400, 300)
        
        custom_a = CustomArray(a)
        
        def matrix_multiply():
            return custom_a.optimized_operation('matrix_multiply', other=CustomArray(b))
        
        result = benchmark(matrix_multiply)
        assert result.data.shape == (500, 300)
    
    @pytest.mark.benchmark
    def test_chain_multiplication_vs_sequential(self, benchmark):
        """Compare optimized chain multiplication with sequential approach."""
        matrices = [
            np.random.randn(100, 80),
            np.random.randn(80, 60),
            np.random.randn(60, 40),
            np.random.randn(40, 20)
        ]
        
        def optimized_chain():
            return fast_matrix_ops(matrices, 'chain_multiply')
        
        result = benchmark(optimized_chain)
        assert result.shape == (100, 20)

if __name__ == "__main__":
    # Run basic functionality tests
    print("Testing CustomArray...")
    data = np.random.randn(10, 10)
    arr = CustomArray(data, {'test': True})
    print(f"Created CustomArray with shape {arr.data.shape}")
    
    print("\nTesting matrix operations...")
    matrices = [np.random.randn(50, 30), np.random.randn(30, 40)]
    result = fast_matrix_ops(matrices, 'chain_multiply')
    print(f"Chain multiplication result shape: {result.shape}")
    
    print("\nTesting optimized algorithms...")
    signal = np.random.randn(1000)
    kernel = np.array([1, 0, -1])
    conv_result = optimized_algorithms(signal, 'fft_convolution', kernel=kernel)
    print(f"FFT convolution result length: {len(conv_result)}")
    
    print("\nAll tests completed successfully!")
```

**Output:** The extension development framework provides a complete foundation for creating high-performance NumPy extensions. The comprehensive build system supports cross-platform compilation, automated testing validates both correctness and performance characteristics, and the modular architecture enables easy maintenance and extension.

Key development practices include rigorous testing at multiple levels (unit tests, integration tests, performance benchmarks), comprehensive documentation with examples, and careful attention to backward compatibility and API stability. The extension leverages NumPy's array protocol system to ensure seamless integration with the broader scientific Python ecosystem.

**Conclusion:** NumPy's custom functions and extensions framework enables developers to create highly optimized, domain-specific functionality while maintaining full compatibility with the NumPy ecosystem. The combination of ufuncs, gufuncs, C/C++ integration, Cython optimization, custom array classes, and comprehensive extension development practices provides a complete toolkit for building high-performance scientific computing solutions.

These extension capabilities support a wide range of use cases, from simple custom mathematical functions to complex domain-specific array classes with specialized algorithms. The consistent API design and automatic integration with NumPy's broadcasting, type promotion, and memory management systems ensure that custom extensions behave predictably and efficiently within larger computational workflows.

The performance benefits of well-implemented extensions can be substantial, often achieving 10-100x speedups over pure Python implementations while maintaining code clarity and scientific correctness. This makes NumPy's extension framework essential for applications requiring both high performance and maintainable, testable code.

---

