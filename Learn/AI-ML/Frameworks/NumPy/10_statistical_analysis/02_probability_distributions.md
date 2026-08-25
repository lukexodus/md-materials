## Probability Distributions


**Random Number Generation from Distributions**

NumPy's random module provides sampling from various probability distributions, enabling Monte Carlo simulations and probabilistic modeling.

```python
# Set random seed for reproducibility
np.random.seed(42)

# Uniform distribution
uniform_samples = np.random.uniform(0, 1, size=1000)
uniform_range = np.random.uniform(-5, 5, size=500)

# Normal (Gaussian) distribution
normal_samples = np.random.normal(0, 1, size=1000)      # Standard normal
normal_custom = np.random.normal(100, 15, size=1000)    # Custom mean and std

# Other continuous distributions
exponential_samples = np.random.exponential(2, size=1000)  # Scale parameter
gamma_samples = np.random.gamma(2, 2, size=1000)          # Shape, scale
beta_samples = np.random.beta(2, 5, size=1000)            # Alpha, beta parameters
```

**Discrete Distributions**

```python
# Binomial distribution
binomial_samples = np.random.binomial(10, 0.3, size=1000)  # n trials, p probability

# Poisson distribution
poisson_samples = np.random.poisson(3, size=1000)          # Lambda parameter

# Discrete uniform (integers)
discrete_uniform = np.random.randint(1, 7, size=1000)      # Dice rolls

# Multinomial distribution
multinomial_samples = np.random.multinomial(100, [0.2, 0.3, 0.5], size=50)
```

**Distribution Properties Analysis**

```python
# Analyze generated samples
samples = np.random.normal(50, 10, size=10000)

# Empirical distribution properties
empirical_mean = np.mean(samples)           # Should approximate 50
empirical_std = np.std(samples, ddof=1)     # Should approximate 10
empirical_var = np.var(samples, ddof=1)     # Should approximate 100

# Distribution shape analysis
sample_min, sample_max = np.min(samples), np.max(samples)
sample_range = np.ptp(samples)
```

