## Exponential and Logarithmic Functions


**Exponential Functions**

```python
# Natural exponential
x = np.array([0, 1, 2, 3])
exp_vals = np.exp(x)              # [1. 2.718 7.389 20.086]

# Base-2 exponential
exp2_vals = np.exp2(x)            # [1. 2. 4. 8.]

# Exponential minus 1 (more accurate for small x)
small_x = np.array([1e-10, 1e-5, 1e-3])
expm1_vals = np.expm1(small_x)
```

**Logarithmic Functions**

```python
# Natural logarithm
pos_vals = np.array([1, np.e, np.e**2, np.e**3])
log_vals = np.log(pos_vals)       # [0. 1. 2. 3.]

# Base-10 logarithm
log10_vals = np.log10([1, 10, 100, 1000])  # [0. 1. 2. 3.]

# Base-2 logarithm
log2_vals = np.log2([1, 2, 4, 8])          # [0. 1. 2. 3.]

# Log(1 + x) for better accuracy with small x
small_vals = np.array([1e-10, 1e-5, 1e-3])
log1p_vals = np.log1p(small_vals)
```

**Special Exponential Functions**

```python
# Power function
bases = np.array([2, 3, 4])
exponents = np.array([2, 3, 0.5])
power_vals = np.power(bases, exponents)  # [4. 27. 2.]

# Square root and cube root
numbers = np.array([4, 9, 16, 25])
sqrt_vals = np.sqrt(numbers)      # [2. 3. 4. 5.]
cbrt_vals = np.cbrt([8, 27, 64])  # [2. 3. 4.]
```

