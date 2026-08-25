## Numerical Integration


Numerical integration in NumPy and SciPy provides computational methods for evaluating definite integrals, solving differential equations, and performing quadrature operations that approximate continuous mathematical operations using discrete computational techniques.

Trapezoidal rule implementation divides integration intervals into trapezoids and approximates integral values using trapezoidal areas. This method provides first-order accuracy and handles irregular spacing between data points, making it suitable for integrating empirical data.

Simpson's rule utilizes quadratic approximations between data points, providing higher-order accuracy compared to trapezoidal methods. The method requires evenly spaced points and odd numbers of intervals but delivers superior accuracy for smooth functions.

Adaptive quadrature methods automatically adjust subdivision strategies based on local function behavior, concentrating computational effort in regions requiring higher resolution while maintaining overall accuracy guarantees. These methods provide robust integration for functions with varying smoothness characteristics.

Multi-dimensional integration extends integration concepts to higher-dimensional domains, enabling computation of volume integrals, surface integrals, and multi-variable function integration. These operations prove essential for physics simulations, probability computations, and engineering applications.

Specialized integration techniques include Monte Carlo integration for high-dimensional problems, Gaussian quadrature for optimal polynomial approximation, and contour integration for complex analysis applications.

**Example:**

```python
from scipy import integrate

# Basic numerical integration
def integrand(x):
    return np.sin(x) * np.exp(-x/10)

# Trapezoidal rule
x_trap = np.linspace(0, 10, 1000)
y_trap = integrand(x_trap)
integral_trap = np.trapz(y_trap, x_trap)

# Simpson's rule
integral_simp = integrate.simps(y_trap, x_trap)

# Adaptive quadrature (most accurate)
integral_quad, error = integrate.quad(integrand, 0, 10)

print(f"Trapezoidal: {integral_trap:.6f}")
print(f"Simpson's: {integral_simp:.6f}")
print(f"Adaptive: {integral_quad:.6f} ± {error:.2e}")

# Multi-dimensional integration
def integrand_2d(x, y):
    return np.sin(x) * np.cos(y) * np.exp(-(x**2 + y**2)/4)

# Double integration
result_2d, error_2d = integrate.dblquad(integrand_2d, 0, 2, 0, 2)

# Triple integration
def integrand_3d(x, y, z):
    return x * y * z * np.exp(-(x**2 + y**2 + z**2))

result_3d, error_3d = integrate.tplquad(integrand_3d, 0, 1, 0, 1, 0, 1)

# Monte Carlo integration for high dimensions
def monte_carlo_integration(func, bounds, n_samples=100000):
    """Simple Monte Carlo integration"""
    ndim = len(bounds)
    volume = np.prod([b[1] - b[0] for b in bounds])
    
    # Generate random samples
    samples = np.random.uniform(
        [b[0] for b in bounds],
        [b[1] for b in bounds],
        (n_samples, ndim)
    )
    
    # Evaluate function at samples
    values = func(*samples.T)
    
    return volume * np.mean(values), volume * np.std(values) / np.sqrt(n_samples)

# Example usage
bounds = [(0, 1), (0, 1), (0, 1)]
mc_result, mc_error = monte_carlo_integration(integrand_3d, bounds)
```

