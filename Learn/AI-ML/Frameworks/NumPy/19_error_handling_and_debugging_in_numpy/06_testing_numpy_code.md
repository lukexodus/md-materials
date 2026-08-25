## Testing NumPy Code


**Unit Testing Framework Integration** NumPy integrates seamlessly with Python testing frameworks. The `numpy.testing` module provides specialized assertion functions like `assert_array_equal()`, `assert_allclose()`, and `assert_raises()` for numerical testing scenarios.

**Example:**

```python
import unittest
import numpy.testing as npt

class TestNumPyOperations(unittest.TestCase):
    """Comprehensive test suite for NumPy operations"""
    
    def setUp(self):
        """Set up test data"""
        self.test_array_1d = np.array([1, 2, 3, 4, 5])
        self.test_array_2d = np.array([[1, 2], [3, 4]])
        self.float_array = np.array([1.1, 2.2, 3.3])
        self.complex_array = np.array([1+2j, 3+4j, 5+6j])
    
    def test_basic_operations(self):
        """Test basic arithmetic operations"""
        # Test addition
        result = self.test_array_1d + 1
        expected = np.array([2, 3, 4, 5, 6])
        npt.assert_array_equal(result, expected, 
                              err_msg="Array addition failed")
        
        # Test multiplication
        result = self.test_array_2d * 2
        expected = np.array([[2, 4], [6, 8]])
        npt.assert_array_equal(result, expected)
    
    def test_floating_point_operations(self):
        """Test operations with floating point precision"""
        # Test with tolerance for floating point comparison
        result = np.sqrt(self.float_array ** 2)
        npt.assert_allclose(result, self.float_array, rtol=1e-10,
                           err_msg="Square root of squares should equal original")
        
        # Test trigonometric identity
        angles = np.array([0, np.pi/4, np.pi/2, np.pi])
        result = np.sin(angles)**2 + np.cos(angles)**2
        expected = np.ones_like(angles)
        npt.assert_allclose(result, expected, atol=1e-15,
                           err_msg="sin²+cos² should equal 1")
    
    def test_matrix_operations(self):
        """Test linear algebra operations"""
        matrix = np.array([[1, 2], [3, 4]])
        
        # Test matrix multiplication
        result = matrix @ matrix
        expected = np.array([[7, 10], [15, 22]])
        npt.assert_array_equal(result, expected)
        
        # Test determinant
        det = np.linalg.det(matrix)
        npt.assert_almost_equal(det, -2.0, decimal=10)
        
        # Test that inverse times original equals identity
        inv_matrix = np.linalg.inv(matrix)
        identity = matrix @ inv_matrix
        expected_identity = np.eye(2)
        npt.assert_allclose(identity, expected_identity, atol=1e-15)
    
    def test_error_conditions(self):
        """Test that appropriate errors are raised"""
        # Test dimension mismatch
        a = np.array([1, 2, 3])
        b = np.array([[1, 2], [3, 4]])
        
        with self.assertRaises(ValueError):
            result = a @ b  # Should raise ValueError for dimension mismatch
        
        # Test singular matrix inversion
        singular_matrix = np.array([[1, 1], [1, 1]])
        npt.assert_raises(LinAlgError, np.linalg.inv, singular_matrix)
        
        # Test index out of bounds
        def index_error_func():
            return self.test_array_1d[10]
        
        npt.assert_raises(IndexError, index_error_func)
    
    def test_complex_numbers(self):
        """Test complex number operations"""
        # Test magnitude
        magnitudes = np.abs(self.complex_array)
        expected = np.array([np.sqrt(5), 5, np.sqrt(61)])
        npt.assert_allclose(magnitudes, expected)
        
        # Test conjugate
        conjugates = np.conj(self.complex_array)
        expected = np.array([1-2j, 3-4j, 5-6j])
        npt.assert_array_equal(conjugates, expected)
    
    def test_statistical_operations(self):
        """Test statistical functions"""
        data = np.array([1, 2, 3, 4, 5])
        
        # Test mean
        mean = np.mean(data)
        npt.assert_equal(mean, 3.0)
        
        # Test standard deviation
        std = np.std(data, ddof=1)  # Sample standard deviation
        expected_std = np.sqrt(2.5)
        npt.assert_almost_equal(std, expected_std)
        
        # Test median
        median = np.median(data)
        npt.assert_equal(median, 3.0)

# Property-based testing example
def test_array_properties():
    """Example of property-based testing concepts"""
    
    def test_addition_commutivity(a, b):
        """Test that addition is commutative"""
        try:
            result1 = a + b
            result2 = b + a
            return np.allclose(result1, result2)
        except (ValueError, TypeError):
            # If operation fails, both should fail the same way
            try:
                b + a
                return False  # If this succeeds but a+b failed, property violated
            except:
                return True   # Both failed, property holds
    
    def test_multiplication_associativity(a, b, c):
        """Test that multiplication is associative"""
        try:
            result1 = (a * b) * c
            result2 = a * (b * c)
            return np.allclose(result1, result2)
        except:
            return True  # If operation fails, we can't test this property
    
    # Generate test cases
    test_cases = [
        (np.array([1, 2, 3]), np.array([4, 5, 6])),
        (np.random.random((3, 3)), np.random.random((3, 3))),
        (np.array([[1, 2], [3, 4]]), np.array([[5, 6], [7, 8]])),
    ]
    
    print("Running property-based tests...")
    for i, (a, b) in enumerate(test_cases):
        comm_result = test_addition_commutivity(a, b)
        print(f"Test case {i+1} - Addition commutativity: {comm_result}")
        
        # Test associativity with three arrays
        c = np.random.random(a.shape)
        assoc_result = test_multiplication_associativity(a, b, c)
        print(f"Test case {i+1} - Multiplication associativity: {assoc_result}")

# Performance regression testing
class PerformanceRegressionTests(unittest.TestCase):
    """Tests to prevent performance regressions"""
    
    def setUp(self):
        self.large_array = np.random.random((1000, 1000))
        self.medium_array = np.random.random((100, 100))
        
        # Performance thresholds (in seconds)
        self.thresholds = {
            'matrix_multiply_large': 1.0,
            'eigenvalue_medium': 0.1,
            'fft_large': 0.1
        }
    
    def time_operation(self, operation, threshold, *args, **kwargs):
        """Time an operation and check against threshold"""
        start = time.perf_counter()
        result = operation(*args, **kwargs)
        elapsed = time.perf_counter() - start
        
        self.assertLess(elapsed, threshold, 
                       f"Operation took {elapsed:.4f}s, threshold is {threshold}s")
        return result
    
    def test_matrix_multiplication_performance(self):
        """Test matrix multiplication stays within performance bounds"""
        self.time_operation(np.dot, 
                          self.thresholds['matrix_multiply_large'],
                          self.large_array, self.large_array.T)
    
    def test_eigenvalue_performance(self):
        """Test eigenvalue computation performance"""
        self.time_operation(np.linalg.eigvals,
                          self.thresholds['eigenvalue_medium'],
                          self.medium_array)
    
    def test_fft_performance(self):
        """Test FFT performance"""
        self.time_operation(np.fft.fft2,
                          self.thresholds['fft_large'],
                          self.large_array)

# Integration testing with real-world scenarios
class IntegrationTests(unittest.TestCase):
    """Integration tests for real-world NumPy usage scenarios"""
    
    def test_image_processing_pipeline(self):
        """Test a typical image processing pipeline"""
        # Simulate an image as a 2D array
        image = np.random.randint(0, 256, (100, 100), dtype=np.uint8)
        
        # Apply typical image processing operations
        # 1. Convert to float for processing
        float_image = image.astype(np.float32) / 255.0
        
        # 2. Apply Gaussian blur (simplified)
        kernel = np.array([[1, 2, 1], [2, 4, 2], [1, 2, 1]]) / 16.0
        # Simple convolution simulation
        blurred = np.zeros_like(float_image)
        for i in range(1, float_image.shape[0]-1):
            for j in range(1, float_image.shape[1]-1):
                blurred[i, j] = np.sum(float_image[i-1:i+2, j-1:j+2] * kernel)
        
        # 3. Edge detection (Sobel operator)
        sobel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
        sobel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]])
        
        edges_x = np.zeros_like(float_image)
        edges_y = np.zeros_like(float_image)
        
        for i in range(1, float_image.shape[0]-1):
            for j in range(1, float_image.shape[1]-1):
                edges_x[i, j] = np.sum(blurred[i-1:i+2, j-1:j+2] * sobel_x)
                edges_y[i, j] = np.sum(blurred[i-1:i+2, j-1:j+2] * sobel_y)
        
        edge_magnitude = np.sqrt(edges_x**2 + edges_y**2)
        
        # Verify results make sense
        self.assertEqual(edge_magnitude.shape, image.shape)
        self.assertTrue(np.all(edge_magnitude >= 0))
        self.assertTrue(np.all(np.isfinite(edge_magnitude)))
        
    def test_scientific_computation_pipeline(self):
        """Test a scientific computation pipeline"""
        # Simulate experimental data
        t = np.linspace(0, 10, 1000)
        signal = np.sin(2 * np.pi * t) + 0.1 * np.random.random(len(t))
        
        # 1. Remove DC component
        signal_ac = signal - np.mean(signal)
        
        # 2. Apply window function
        window = np.hanning(len(signal_ac))
        windowed_signal = signal_ac * window
        
        # 3. Compute FFT
        fft_result = np.fft.fft(windowed_signal)
        frequencies = np.fft.fftfreq(len(t), t[1] - t[0])
        
        # 4. Find dominant frequency
        power_spectrum = np.abs(fft_result)**2
        dominant_freq_idx = np.argmax(power_spectrum[:len(t)//2])
        dominant_frequency = frequencies[dominant_freq_idx]
        
        # Verify results
        npt.assert_allclose(abs(dominant_frequency), 1.0, rtol=0.1,
                           err_msg="Should detect 1 Hz signal")
        
        # 5. Filter signal (simple low-pass)
        cutoff_idx = len(t) // 10
        fft_filtered = fft_result.copy()
        fft_filtered[cutoff_idx:-cutoff_idx] = 0
        filtered_signal = np.fft.ifft(fft_filtered).real
        
        self.assertEqual(len(filtered_signal), len(signal))
        self.assertTrue(np.all(np.isfinite(filtered_signal)))

# Run the tests
if __name__ == '__main__':
    # Run unit tests
    print("Running NumPy unit tests...")
    unittest.main(argv=[''], exit=False, verbosity=2)
    
    # Run property-based tests
    test_array_properties()
    
    print("\nAll tests completed!")
```

**Key Points:**

- NumPy errors typically stem from shape mismatches, type incompatibilities, memory constraints, or mathematical invalidity
- Systematic debugging requires comprehensive array inspection, intermediate result verification, conditional analysis, and visual examination techniques
- Memory leak prevention focuses on proper reference management, view/copy understanding, garbage collection integration, and resource cleanup
- Performance debugging emphasizes accurate timing analysis, vectorization optimization, memory access pattern analysis, and broadcasting efficiency
- Exception handling should be hierarchical and specific, preserve error context, implement graceful degradation strategies, and include robust input validation
- Testing requires specialized numerical comparison functions, consideration of floating-point precision, property-based testing approaches, performance regression monitoring, and integration testing with real-world scenarios

**Next Steps:** Essential related topics include NumPy C API debugging techniques, advanced memory profiling with specialized tools, integration with scientific computing debuggers, and performance optimization using specialized BLAS libraries.

---

