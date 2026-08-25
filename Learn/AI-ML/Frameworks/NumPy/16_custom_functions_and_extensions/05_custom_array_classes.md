## Custom Array Classes


Custom array classes extend NumPy's array interface to support specialized data structures, domain-specific operations, and alternative memory layouts while maintaining compatibility with NumPy's ecosystem.

**Key points:**

- Implementation of the `__array_interface__` or `__array__` protocol for NumPy compatibility
- Custom memory management strategies for specialized data layouts
- Domain-specific operations and methods while inheriting NumPy's broadcasting
- Integration with existing NumPy functions through protocol implementation
- Support for specialized dtypes and metadata handling

**Example:**

```python
import numpy as np
from abc import ABC, abstractmethod

class CustomArrayBase(ABC):
    """
    Abstract base class for custom array implementations.
    """
    
    def __init__(self, data, metadata=None):
        self._data = np.asarray(data)
        self._metadata = metadata or {}
    
    @property
    def __array_interface__(self):
        """NumPy array interface for compatibility."""
        return self._data.__array_interface__
    
    def __array__(self, dtype=None):
        """Return the underlying NumPy array."""
        if dtype is None:
            return self._data
        return self._data.astype(dtype)
    
    def __array_wrap__(self, result, context=None):
        """Wrap array results to maintain custom class type."""
        return type(self)(result, self._metadata.copy())
    
    def __array_ufunc__(self, ufunc, method, *inputs, **kwargs):
        """Handle ufunc operations on custom arrays."""
        if method == '__call__':
            # Convert inputs to arrays
            args = []
            for input_ in inputs:
                if isinstance(input_, type(self)):
                    args.append(input_._data)
                else:
                    args.append(input_)
            
            # Apply ufunc to underlying data
            result = ufunc(*args, **kwargs)
            
            # Wrap result if it's an array
            if isinstance(result, np.ndarray):
                return self.__array_wrap__(result)
            return result
        else:
            return NotImplemented
    
    @property
    def shape(self):
        return self._data.shape
    
    @property
    def dtype(self):
        return self._data.dtype
    
    def __repr__(self):
        return f"{type(self).__name__}(\n{self._data!r},\nmetadata={self._metadata!r})"

class SparseArray(CustomArrayBase):
    """
    Custom sparse array implementation with COO format.
    """
    
    def __init__(self, data=None, coords=None, shape=None, fill_value=0):
        if data is not None and coords is not None:
            self._coords = np.asarray(coords)
            self._values = np.asarray(data)
            self._shape = shape or tuple(np.max(coords, axis=1) + 1)
        else:
            # Create from dense array
            dense = np.asarray(data)
            nonzero_coords = np.nonzero(dense)
            self._coords = np.column_stack(nonzero_coords).T
            self._values = dense[nonzero_coords]
            self._shape = dense.shape
        
        self._fill_value = fill_value
    
    def todense(self):
        """Convert to dense NumPy array."""
        dense = np.full(self._shape, self._fill_value, dtype=self._values.dtype)
        if self._coords.size > 0:
            dense[tuple(self._coords)] = self._values
        return dense
    
    def __array__(self, dtype=None):
        """Return dense representation for NumPy compatibility."""
        result = self.todense()
        if dtype is not None:
            result = result.astype(dtype)
        return result
    
    def __add__(self, other):
        """Custom addition for sparse arrays."""
        if isinstance(other, SparseArray):
            # Efficient sparse + sparse addition
            return SparseArray(data=self.todense() + other.todense())
        else:
            # Sparse + dense addition
            return SparseArray(data=self.todense() + other)
    
    def __mul__(self, scalar):
        """Scalar multiplication."""
        return SparseArray(
            data=self._values * scalar,
            coords=self._coords,
            shape=self._shape,
            fill_value=self._fill_value * scalar
        )
    
    @property
    def nnz(self):
        """Number of non-zero elements."""
        return len(self._values)

class TimeSeriesArray(CustomArrayBase):
    """
    Custom array class for time series data with automatic indexing.
    """
    
    def __init__(self, data, timestamps=None, frequency=None):
        super().__init__(data)
        
        if timestamps is not None:
            self._timestamps = np.asarray(timestamps)
        elif frequency is not None:
            self._timestamps = np.arange(len(data)) * frequency
        else:
            self._timestamps = np.arange(len(data))
        
        self._metadata.update({
            'timestamps': self._timestamps,
            'frequency': frequency
        })
    
    def resample(self, new_timestamps):
        """Resample time series to new timestamp grid."""
        resampled_data = np.interp(new_timestamps, self._timestamps, self._data)
        return TimeSeriesArray(resampled_data, new_timestamps)
    
    def rolling_window(self, window_size, func=np.mean):
        """Apply rolling window function."""
        if window_size > len(self._data):
            raise ValueError("Window size larger than data length")
        
        result = np.zeros(len(self._data) - window_size + 1)
        for i in range(len(result)):
            result[i] = func(self._data[i:i + window_size])
        
        return TimeSeriesArray(
            result, 
            self._timestamps[window_size-1:],
            self._metadata.get('frequency')
        )
    
    def correlate_with(self, other):
        """Cross-correlation with another time series."""
        if isinstance(other, TimeSeriesArray):
            other_data = other._data
        else:
            other_data = np.asarray(other)
        
        return np.correlate(self._data, other_data, mode='full')
    
    def __getitem__(self, key):
        """Support time-based indexing."""
        if isinstance(key, slice):
            start, stop, step = key.indices(len(self._data))
            return TimeSeriesArray(
                self._data[start:stop:step],
                self._timestamps[start:stop:step],
                self._metadata.get('frequency')
            )
        return self._data[key]

# Usage examples
def demonstrate_custom_arrays():
    # Sparse array example
    dense_data = np.array([[0, 2, 0], [1, 0, 3], [0, 0, 0]])
    sparse = SparseArray(dense_data)
    print(f"Sparse array nnz: {sparse.nnz}")
    
    # NumPy operations work automatically
    result = np.sum(sparse)  # Calls sparse.__array__() internally
    scaled = sparse * 2.5
    
    # Time series array example
    data = np.sin(np.linspace(0, 4*np.pi, 100)) + np.random.randn(100) * 0.1
    ts = TimeSeriesArray(data, frequency=0.1)
    
    # Custom operations
    smoothed = ts.rolling_window(5, func=np.median)
    resampled = ts.resample(np.linspace(0, 10, 50))
    
    # NumPy functions work on custom arrays
    fft_result = np.fft.fft(ts)  # Automatic conversion to NumPy array
    
    return sparse, ts, smoothed

sparse, ts, smoothed = demonstrate_custom_arrays()
```

Custom array classes enable domain-specific optimizations while maintaining full compatibility with NumPy's function ecosystem through the array protocol implementation.

