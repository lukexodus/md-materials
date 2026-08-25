## Cython Optimization Techniques


Cython provides a bridge between Python and C, enabling high-performance implementations with Python-like syntax while generating optimized C code. Cython extensions can achieve near-C performance for numerical computations while maintaining NumPy compatibility.

**Key points:**

- Static typing eliminates Python object overhead for numerical operations
- Direct memory access to NumPy arrays without Python API calls
- Automatic generation of optimized C code with compiler optimizations
- Integration with OpenMP for parallel processing capabilities
- Seamless interoperability with existing Python and NumPy code

**Example:**

```cython
# custom_cython.pyx - Cython implementation
import numpy as np
cimport numpy as cnp
cimport cython
from cython.parallel import prange
from libc.math cimport exp, sqrt, fabs

# Enable NumPy support
cnp.import_array()

@cython.boundscheck(False)
@cython.wraparound(False)
def fast_distance_matrix(cnp.ndarray[cnp.float64_t, ndim=2] points):
    """
    Compute pairwise Euclidean distances between points.
    """
    cdef int n = points.shape[0]
    cdef int d = points.shape[1]
    cdef cnp.ndarray[cnp.float64_t, ndim=2] distances = np.zeros((n, n), dtype=np.float64)
    
    cdef int i, j, k
    cdef double dist, diff
    
    # Parallel computation using OpenMP
    with nogil:
        for i in prange(n, schedule='dynamic'):
            for j in range(i + 1, n):
                dist = 0.0
                for k in range(d):
                    diff = points[i, k] - points[j, k]
                    dist += diff * diff
                distances[i, j] = sqrt(dist)
                distances[j, i] = distances[i, j]  # Symmetric matrix
    
    return distances

@cython.boundscheck(False)
@cython.wraparound(False)
def optimized_convolution_2d(cnp.ndarray[cnp.float64_t, ndim=2] image,
                            cnp.ndarray[cnp.float64_t, ndim=2] kernel):
    """
    Fast 2D convolution implementation.
    """
    cdef int img_h = image.shape[0]
    cdef int img_w = image.shape[1]
    cdef int ker_h = kernel.shape[0]
    cdef int ker_w = kernel.shape[1]
    
    cdef int pad_h = ker_h // 2
    cdef int pad_w = ker_w // 2
    
    cdef cnp.ndarray[cnp.float64_t, ndim=2] result = np.zeros_like(image)
    
    cdef int i, j, ki, kj
    cdef double pixel_value
    cdef int img_i, img_j
    
    with nogil:
        for i in prange(img_h, schedule='static'):
            for j in range(img_w):
                pixel_value = 0.0
                for ki in range(ker_h):
                    for kj in range(ker_w):
                        img_i = i + ki - pad_h
                        img_j = j + kj - pad_w
                        if 0 <= img_i < img_h and 0 <= img_j < img_w:
                            pixel_value += image[img_i, img_j] * kernel[ki, kj]
                result[i, j] = pixel_value
    
    return result

# Advanced example: Custom numerical integration
@cython.boundscheck(False)
@cython.wraparound(False)
def adaptive_simpson_rule(object func, double a, double b, double tol=1e-10):
    """
    Adaptive Simpson's rule for numerical integration.
    """
    cdef double fa = func(a)
    cdef double fb = func(b)
    cdef double fc = func((a + b) / 2.0)
    
    return _adaptive_simpson_recursive(func, a, b, tol, fa, fb, fc, (b - a) / 6.0 * (fa + 4*fc + fb))

@cython.cdivision(True)
cdef double _adaptive_simpson_recursive(object func, double a, double b, double tol,
                                       double fa, double fb, double fc, double s):
    """
    Recursive helper for adaptive Simpson's rule.
    """
    cdef double c = (a + b) / 2.0
    cdef double h = (b - a) / 2.0
    cdef double d = (a + c) / 2.0
    cdef double e = (c + b) / 2.0
    
    cdef double fd = func(d)
    cdef double fe = func(e)
    
    cdef double s1 = h / 3.0 * (fa + 4*fd + fc)
    cdef double s2 = h / 3.0 * (fc + 4*fe + fb)
    cdef double s_new = s1 + s2
    
    if fabs(s_new - s) <= 15 * tol:
        return s_new + (s_new - s) / 15.0
    else:
        return (_adaptive_simpson_recursive(func, a, c, tol/2.0, fa, fc, fd, s1) +
                _adaptive_simpson_recursive(func, c, b, tol/2.0, fc, fb, fe, s2))

# Memory views for even faster array access
@cython.boundscheck(False)
@cython.wraparound(False)
def matrix_power_optimized(double[:, :] matrix, int power):
    """
    Fast matrix power computation using memory views.
    """
    cdef int n = matrix.shape[0]
    cdef double[:, :] result = np.eye(n, dtype=np.float64)
    cdef double[:, :] base = np.array(matrix, copy=True)
    cdef double[:, :] temp = np.zeros((n, n), dtype=np.float64)
    
    cdef int i, j, k
    cdef double sum_val
    
    while power > 0:
        if power % 2 == 1:
            # result = result @ base
            with nogil:
                for i in prange(n):
                    for j in range(n):
                        sum_val = 0.0
                        for k in range(n):
                            sum_val += result[i, k] * base[k, j]
                        temp[i, j] = sum_val
            result, temp = temp, result
        
        power //= 2
        if power > 0:
            # base = base @ base
            with nogil:
                for i in prange(n):
                    for j in range(n):
                        sum_val = 0.0
                        for k in range(n):
                            sum_val += base[i, k] * base[k, j]
                        temp[i, j] = sum_val
            base, temp = temp, base
    
    return np.asarray(result)
```

```python
# setup.py for Cython compilation
from setuptools import setup
from Cython.Build import cythonize
import numpy

setup(
    ext_modules=cythonize("custom_cython.pyx",
                         compiler_directives={'language_level': "3"}),
    include_dirs=[numpy.get_include()]
)

# Usage example
import numpy as np
import custom_cython

# Test optimized distance matrix
points = np.random.randn(1000, 10)
distances = custom_cython.fast_distance_matrix(points)

# Test optimized convolution
image = np.random.randn(512, 512)
kernel = np.array([[-1, -1, -1], [-1, 8, -1], [-1, -1, -1]], dtype=np.float64)
convolved = custom_cython.optimized_convolution_2d(image, kernel)

# Test numerical integration
def test_function(x):
    return np.exp(-x**2) * np.cos(x)

integral = custom_cython.adaptive_simpson_rule(test_function, 0, 5)
```

Cython optimizations can achieve 10-100x speedups over pure Python implementations while maintaining readable code structure and full NumPy compatibility.

