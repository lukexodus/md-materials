## Exception Handling Patterns


**Structured Exception Management** Robust NumPy applications implement hierarchical exception handling. Catching specific exceptions like `ValueError`, `IndexError`, and `LinAlgError` enables targeted error responses. Generic `Exception` handling should be avoided except for logging purposes.

**Example:**

```python
import logging
from typing import Optional, Union

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NumPyOperationError(Exception):
    """Custom exception for NumPy operations"""
    def __init__(self, operation, original_error, context=None):
        self.operation = operation
        self.original_error = original_error
        self.context = context or {}
        super().__init__(f"NumPy operation '{operation}' failed: {original_error}")

def safe_array_operation(func, *args, operation_name="unknown", **kwargs):
    """Generic wrapper for safe NumPy operations"""
    try:
        return func(*args, **kwargs)
    
    except ValueError as e:
        logger.error(f"ValueError in {operation_name}: {e}")
        raise NumPyOperationError(operation_name, e, {
            'error_type': 'ValueError',
            'args_shapes': [getattr(arg, 'shape', 'scalar') for arg in args if hasattr(arg, 'shape')]
        })
    
    except IndexError as e:
        logger.error(f"IndexError in {operation_name}: {e}")
        raise NumPyOperationError(operation_name, e, {
            'error_type': 'IndexError',
            'args_info': [str(arg) for arg in args]
        })
    
    except LinAlgError as e:
        logger.error(f"LinAlgError in {operation_name}: {e}")
        raise NumPyOperationError(operation_name, e, {
            'error_type': 'LinAlgError',
            'matrix_shapes': [arg.shape for arg in args if hasattr(arg, 'shape')]
        })
    
    except MemoryError as e:
        logger.error(f"MemoryError in {operation_name}: {e}")
        raise NumPyOperationError(operation_name, e, {
            'error_type': 'MemoryError',
            'requested_memory': sum(getattr(arg, 'nbytes', 0) for arg in args if hasattr(arg, 'nbytes'))
        })

# Example usage with specific operations
def robust_matrix_multiply(a: np.ndarray, b: np.ndarray) -> Optional[np.ndarray]:
    """Robust matrix multiplication with comprehensive error handling"""
    try:
        # Validate inputs
        if a.ndim != 2 or b.ndim != 2:
            raise ValueError("Both inputs must be 2D matrices")
        
        if a.shape[1] != b.shape[0]:
            raise ValueError(f"Matrix dimensions incompatible: {a.shape} @ {b.shape}")
        
        # Perform operation
        result = safe_array_operation(np.dot, a, b, operation_name="matrix_multiply")
        return result
        
    except NumPyOperationError as e:
        logger.error(f"Matrix multiplication failed: {e}")
        logger.info(f"Error context: {e.context}")
        return None
    
    except Exception as e:
        logger.error(f"Unexpected error in matrix multiplication: {e}")
        return None

# Test robust operations
def test_robust_operations():
    """Test the robust operation handling"""
    print("Testing robust matrix multiplication...")
    
    # Valid operation
    a = np.random.random((3, 4))
    b = np.random.random((4, 5))
    result = robust_matrix_multiply(a, b)
    print(f"Valid operation result shape: {result.shape if result is not None else 'None'}")
    
    # Invalid dimensions
    c = np.random.random((3, 3))
    d = np.random.random((4, 4))
    result = robust_matrix_multiply(c, d)
    print(f"Invalid operation result: {result}")
    
    # 1D arrays (should fail)
    e = np.random.random(5)
    f = np.random.random(5)
    result = robust_matrix_multiply(e, f)
    print(f"1D array operation result: {result}")

test_robust_operations()
```

**Graceful Degradation Strategies** Production applications benefit from fallback mechanisms when NumPy operations fail. Alternative algorithms, reduced precision calculations, or cached results provide service continuity during error conditions. [Inference] Fallback strategies should be thoroughly tested to ensure reliability.

**Example:**

```python
from functools import lru_cache
import pickle
import os

class RobustNumericalProcessor:
    """Processor with multiple fallback strategies"""
    
    def __init__(self, cache_dir="./cache"):
        self.cache_dir = cache_dir
        os.makedirs(cache_dir, exist_ok=True)
    
    def _cache_key(self, operation, *args):
        """Generate cache key for operation and arguments"""
        # Simple hash-based key (in production, use more robust hashing)
        key_parts = [operation]
        for arg in args:
            if hasattr(arg, 'shape'):
                key_parts.append(f"array_{arg.shape}_{hash(arg.tobytes())}")
            else:
                key_parts.append(str(hash(str(arg))))
        return "_".join(key_parts)
    
    def _load_from_cache(self, cache_key):
        """Load result from cache if available"""
        cache_file = os.path.join(self.cache_dir, f"{cache_key}.pkl")
        if os.path.exists(cache_file):
            try:
                with open(cache_file, 'rb') as f:
                    return pickle.load(f)
            except Exception as e:
                logger.warning(f"Failed to load from cache: {e}")
        return None
    
    def _save_to_cache(self, cache_key, result):
        """Save result to cache"""
        cache_file = os.path.join(self.cache_dir, f"{cache_key}.pkl")
        try:
            with open(cache_file, 'wb') as f:
                pickle.dump(result, f)
        except Exception as e:
            logger.warning(f"Failed to save to cache: {e}")
    
    def robust_eigenvalue_computation(self, matrix):
        """Compute eigenvalues with multiple fallback strategies"""
        cache_key = self._cache_key("eigenvalues", matrix)
        
        # Strategy 1: Try to load from cache
        cached_result = self._load_from_cache(cache_key)
        if cached_result is not None:
            logger.info("Using cached eigenvalue result")
            return cached_result
        
        # Strategy 2: Standard eigenvalue computation
        try:
            eigenvalues = np.linalg.eigvals(matrix)
            if np.all(np.isfinite(eigenvalues)):
                self._save_to_cache(cache_key, eigenvalues)
                return eigenvalues
            else:
                raise ValueError("Non-finite eigenvalues detected")
        
        except (LinAlgError, ValueError) as e:
            logger.warning(f"Standard eigenvalue computation failed: {e}")
        
        # Strategy 3: Try with different algorithm (QR decomposition)
        try:
            logger.info("Trying alternative eigenvalue algorithm")
            # Use scipy if available, otherwise fall back to power iteration
            try:
                from scipy.linalg import eigvals
                eigenvalues = eigvals(matrix)
                if np.all(np.isfinite(eigenvalues)):
                    return eigenvalues
            except ImportError:
                pass
        
        except Exception as e:
            logger.warning(f"Alternative algorithm failed: {e}")
        
        # Strategy 4: Power iteration for dominant eigenvalue
        try:
            logger.info("Using power iteration for dominant eigenvalue")
            dominant_eigenvalue = self._power_iteration(matrix)
            # Return array with just the dominant eigenvalue
            result = np.array([dominant_eigenvalue])
            return result
        
        except Exception as e:
            logger.warning(f"Power iteration failed: {e}")
        
        # Strategy 5: Return approximation based on trace and determinant
        logger.warning("All eigenvalue methods failed, returning approximation")
        if matrix.shape[0] == 2:
            # For 2x2 matrices, use quadratic formula
            trace = np.trace(matrix)
            det = np.linalg.det(matrix)
            discriminant = trace**2 - 4*det
            
            if discriminant >= 0:
                sqrt_disc = np.sqrt(discriminant)
                eigenvalues = np.array([(trace + sqrt_disc)/2, (trace - sqrt_disc)/2])
                return eigenvalues
        
        # Final fallback: estimate from trace
        trace = np.trace(matrix)
        n = matrix.shape[0]
        estimated_eigenvalue = trace / n
        return np.full(n, estimated_eigenvalue)
    
    def _power_iteration(self, matrix, max_iterations=1000, tolerance=1e-6):
        """Power iteration to find dominant eigenvalue"""
        n = matrix.shape[0]
        x = np.random.random(n)
        x = x / np.linalg.norm(x)
        
        for _ in range(max_iterations):
            x_new = matrix @ x
            eigenvalue = x @ x_new
            x_new = x_new / np.linalg.norm(x_new)
            
            if np.linalg.norm(x_new - x) < tolerance:
                return eigenvalue
            x = x_new
        
        raise ValueError("Power iteration did not converge")
    
    def robust_linear_solve(self, A, b):
        """Solve linear system with fallback strategies"""
        cache_key = self._cache_key("linear_solve", A, b)
        
        # Try cache first
        cached_result = self._load_from_cache(cache_key)
        if cached_result is not None:
            return cached_result
        
        strategies = [
            ("direct_solve", lambda: np.linalg.solve(A, b)),
            ("least_squares", lambda: np.linalg.lstsq(A, b, rcond=None)[0]),
            ("pseudo_inverse", lambda: np.linalg.pinv(A) @ b),
            ("iterative_solve", lambda: self._iterative_solve(A, b))
        ]
        
        for strategy_name, strategy_func in strategies:
            try:
                result = strategy_func()
                if np.all(np.isfinite(result)):
                    logger.info(f"Linear system solved using {strategy_name}")
                    self._save_to_cache(cache_key, result)
                    return result
            except Exception as e:
                logger.warning(f"{strategy_name} failed: {e}")
                continue
        
        raise RuntimeError("All linear solve strategies failed")
    
    def _iterative_solve(self, A, b, max_iterations=1000):
        """Simple Jacobi iteration for solving linear systems"""
        n = len(b)
        x = np.zeros(n)
        
        for _ in range(max_iterations):
            x_new = np.zeros(n)
            for i in range(n):
                sum_ax = sum(A[i][j] * x[j] for j in range(n) if i != j)
                x_new[i] = (b[i] - sum_ax) / A[i][i]
            
            if np.linalg.norm(x_new - x) < 1e-6:
                return x_new
            x = x_new
        
        raise ValueError("Iterative solve did not converge")

# Test robust processor
processor = RobustNumericalProcessor()

# Test with well-conditioned matrix
well_conditioned = np.array([[4, 1], [1, 3]])
eigenvals = processor.robust_eigenvalue_computation(well_conditioned)
print(f"Eigenvalues of well-conditioned matrix: {eigenvals}")

# Test with ill-conditioned matrix
ill_conditioned = np.array([[1, 1], [1, 1.0000001]])
eigenvals = processor.robust_eigenvalue_computation(ill_conditioned)
print(f"Eigenvalues of ill-conditioned matrix: {eigenvals}")
```

