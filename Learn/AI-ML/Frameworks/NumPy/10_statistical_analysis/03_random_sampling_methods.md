## Random Sampling Methods


**Basic Sampling Techniques**

```python
# Population data
population = np.arange(1, 1001)  # Population of 1000 elements

# Simple random sampling without replacement
sample_without_replacement = np.random.choice(population, size=100, replace=False)

# Simple random sampling with replacement
sample_with_replacement = np.random.choice(population, size=100, replace=True)

# Weighted sampling
weights = np.exp(-0.001 * population)  # Exponential weights favoring smaller values
weighted_sample = np.random.choice(population, size=100, p=weights/np.sum(weights))
```

**Stratified and Systematic Sampling**

```python
# [Inference] Stratified sampling implementation
def stratified_sample(data, strata_column, sample_size):
    """Stratified sampling based on categorical variable"""
    unique_strata = np.unique(strata_column)
    samples = []
    
    for stratum in unique_strata:
        stratum_mask = strata_column == stratum
        stratum_data = data[stratum_mask]
        stratum_sample_size = int(sample_size * np.sum(stratum_mask) / len(data))
        
        if len(stratum_data) >= stratum_sample_size:
            stratum_sample = np.random.choice(len(stratum_data), 
                                            size=stratum_sample_size, 
                                            replace=False)
            samples.extend(stratum_data[stratum_sample])
    
    return np.array(samples)

# [Inference] Systematic sampling implementation
def systematic_sample(data, sample_size):
    """Systematic sampling with fixed interval"""
    population_size = len(data)
    interval = population_size // sample_size
    start = np.random.randint(0, interval)
    indices = np.arange(start, population_size, interval)[:sample_size]
    return data[indices]
```

**Bootstrap Sampling**

```python
# Bootstrap resampling
original_data = np.random.normal(25, 5, size=100)

def bootstrap_sample(data, n_samples=1000):
    """Generate bootstrap samples"""
    bootstrap_means = []
    for _ in range(n_samples):
        sample = np.random.choice(data, size=len(data), replace=True)
        bootstrap_means.append(np.mean(sample))
    return np.array(bootstrap_means)

bootstrap_means = bootstrap_sample(original_data)
bootstrap_ci = np.percentile(bootstrap_means, [2.5, 97.5])  # 95% confidence interval
```

