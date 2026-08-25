## Integration with Scientific Python Ecosystem


**SciPy Integration**

```python
import scipy.stats as stats
import scipy.optimize as optimize
import scipy.integrate as integrate

# Statistical distributions
data = np.random.normal(100, 15, 1000)
distribution = stats.norm
params = distribution.fit(data)

# Optimization problems
def objective(x):
    return x[0]**2 + x[1]**2

result = optimize.minimize(objective, [1, 1])

# Numerical integration
def integrand(x):
    return np.sin(x) * np.exp(-x)

integral, error = integrate.quad(integrand, 0, np.inf)
```

**Pandas Interoperability**

```python
import pandas as pd

# Convert between NumPy and Pandas
numpy_array = np.random.random((100, 5))
df = pd.DataFrame(numpy_array, columns=['A', 'B', 'C', 'D', 'E'])

# Back to NumPy
numpy_from_pandas = df.values
```

**Matplotlib Visualization**

```python
import matplotlib.pyplot as plt

# Create sample data
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(x, y1, label='sin(x)')
plt.plot(x, y2, label='cos(x)')
plt.legend()
plt.grid(True)
```

