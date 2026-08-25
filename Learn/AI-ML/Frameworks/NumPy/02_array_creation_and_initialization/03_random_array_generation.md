## Random Array Generation


NumPy's random module provides comprehensive random array generation capabilities through various probability distributions.

**Basic Random Generation**

```python
# Random floats between 0 and 1
rand_arr = np.random.random((3, 3))

# Random integers
rand_int = np.random.randint(0, 10, size=(2, 4))  # Integers between 0-9

# Random choice from array
choices = np.random.choice([1, 2, 3, 4, 5], size=10)
```

**Distribution-Based Generation**

```python
# Normal distribution
normal = np.random.normal(0, 1, size=(1000,))  # mean=0, std=1

# Uniform distribution
uniform = np.random.uniform(-1, 1, size=(500,))  # Between -1 and 1

# Exponential distribution
exponential = np.random.exponential(2, size=(100,))  # scale=2
```

**Random Seed Control**

```python
# Set seed for reproducibility
np.random.seed(42)
reproducible = np.random.random(5)

# Using Generator (recommended approach)
rng = np.random.default_rng(42)
reproducible_gen = rng.random(5)
```

