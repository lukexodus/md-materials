## C/C++ Integration with NumPy


Direct C/C++ integration provides maximum performance for computationally intensive operations while maintaining full compatibility with NumPy's array interface. The NumPy C API enables creation of extension modules that handle NumPy arrays natively.

**Key points:**

- Direct access to NumPy array data pointers eliminates Python overhead
- Custom memory management and cache optimization strategies
- Integration with existing C/C++ libraries and high-performance computing frameworks
- Support for complex data types and custom dtypes
- Thread safety and parallel processing capabilities

**Example:**

```c
// custom_extension.c - C extension example
#define PY_SARRAY_UNIQUE_SYMBOL cool_ARRAY_API
#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
#include <Python.h>
#include <numpy/arrayobject.h>
#include <math.h>

// Fast matrix multiplication implementation
static PyObject* fast_matrix_multiply(PyObject* self, PyObject* args) {
    PyArrayObject *a, *b, *result;
    
    // Parse input arguments
    if (!PyArg_ParseTuple(args, "OO", &a, &b)) {
        return NULL;
    }
    
    // Ensure arrays are contiguous and of correct type
    a = (PyArrayObject*)PyArray_GETCONTIGUOUS(a);
    b = (PyArrayObject*)PyArray_GETCONTIGUOUS(b);
    
    // Get dimensions
    int m = PyArray_DIM(a, 0);
    int k = PyArray_DIM(a, 1);
    int n = PyArray_DIM(b, 1);
    
    // Create output array
    npy_intp dims[2] = {m, n};
    result = (PyArrayObject*)PyArray_SimpleNew(2, dims, NPY_DOUBLE);
    
    // Get data pointers
    double *a_data = (double*)PyArray_DATA(a);
    double *b_data = (double*)PyArray_DATA(b);
    double *result_data = (double*)PyArray_DATA(result);
    
    // Optimized matrix multiplication with cache blocking
    int block_size = 64;  // Optimize for cache line size
    for (int ii = 0; ii < m; ii += block_size) {
        for (int jj = 0; jj < n; jj += block_size) {
            for (int kk = 0; kk < k; kk += block_size) {
                for (int i = ii; i < fmin(ii + block_size, m); i++) {
                    for (int j = jj; j < fmin(jj + block_size, n); j++) {
                        double sum = 0.0;
                        for (int l = kk; l < fmin(kk + block_size, k); l++) {
                            sum += a_data[i * k + l] * b_data[l * n + j];
                        }
                        result_data[i * n + j] += sum;
                    }
                }
            }
        }
    }
    
    Py_DECREF(a);
    Py_DECREF(b);
    return (PyObject*)result;
}

// Custom ufunc implementation in C
static void custom_sigmoid_loop(char **args, npy_intp *dimensions,
                               npy_intp* steps, void* data) {
    npy_intp n = dimensions[0];
    char *in = args[0], *out = args[1];
    npy_intp in_step = steps[0], out_step = steps[1];
    
    for (npy_intp i = 0; i < n; i++) {
        double x = *(double*)in;
        double result = 1.0 / (1.0 + exp(-fmax(-500.0, fmin(500.0, x))));
        *(double*)out = result;
        
        in += in_step;
        out += out_step;
    }
}

// Method definitions
static PyMethodDef module_methods[] = {
    {"fast_matrix_multiply", fast_matrix_multiply, METH_VARARGS,
     "Fast matrix multiplication implementation"},
    {NULL, NULL, 0, NULL}
};

// Module initialization
static struct PyModuleDef moduledef = {
    PyModuleDef_HEAD_INIT,
    "custom_extension",
    NULL,
    -1,
    module_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyMODINIT_FUNC PyInit_custom_extension(void) {
    PyObject *m;
    
    // Initialize NumPy
    import_array();
    if (PyErr_Occurred()) {
        return NULL;
    }
    
    m = PyModule_Create(&moduledef);
    if (m == NULL) {
        return NULL;
    }
    
    // Create and register custom ufunc
    static char types[2] = {NPY_DOUBLE, NPY_DOUBLE};
    static PyUFuncGenericFunction funcs[1] = {&custom_sigmoid_loop};
    static void *data[1] = {NULL};
    
    PyObject *sigmoid_ufunc = PyUFunc_FromFuncAndData(
        funcs, data, types, 1, 1, 1,
        PyUFunc_None, "custom_sigmoid",
        "Fast sigmoid implementation", 0);
    
    PyModule_AddObject(m, "sigmoid", sigmoid_ufunc);
    
    return m;
}
```

```python
# setup.py for building the C extension
from distutils.core import setup, Extension
import numpy

module = Extension('custom_extension',
                  sources=['custom_extension.c'],
                  include_dirs=[numpy.get_include()],
                  extra_compile_args=['-O3', '-march=native'])

setup(name='CustomExtension',
      ext_modules=[module])

# Usage in Python
import numpy as np
import custom_extension

# Use the optimized matrix multiplication
a = np.random.randn(1000, 500)
b = np.random.randn(500, 800)
result = custom_extension.fast_matrix_multiply(a, b)

# Use the custom sigmoid ufunc
x = np.linspace(-10, 10, 1000000)
sigmoid_result = custom_extension.sigmoid(x)
```

The C API integration supports advanced features like custom iterators, memory-mapped files, and integration with parallel processing libraries like OpenMP for multi-threaded operations.

