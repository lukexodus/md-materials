## Sequence Generation


**arange**

`numpy.arange()` generates arithmetic sequences similar to Python's range function but returns NumPy arrays. The function accepts start, stop, and step parameters, supporting floating-point increments.

```python
# Basic integer sequence
seq1 = np.arange(10)  # [0 1 2 3 4 5 6 7 8 9]

# With start and stop
seq2 = np.arange(2, 10)  # [2 3 4 5 6 7 8 9]

# With step
seq3 = np.arange(0, 10, 2)  # [0 2 4 6 8]

# Floating point sequences
seq4 = np.arange(0, 1, 0.1)  # [0.  0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]
```

**linspace**

`numpy.linspace()` creates linearly spaced sequences between specified endpoints, dividing the interval into equal parts. Unlike arange, linspace specifies the number of points rather than step size.

```python
# Linear spacing between 0 and 10
linear = np.linspace(0, 10, 5)  # [0. 2.5 5. 7.5 10.]

# Exclude endpoint
linear_no_end = np.linspace(0, 10, 5, endpoint=False)  # [0. 2. 4. 6. 8.]

# Return step size
linear_with_step = np.linspace(0, 10, 5, retstep=True)  # (array, step_size)
```

**logspace**

`numpy.logspace()` generates logarithmically spaced sequences, useful for scientific computing where logarithmic scaling is required.

```python
# Logarithmic spacing (base 10)
log_seq = np.logspace(0, 3, 4)  # [1. 10. 100. 1000.]

# Different base
log_base2 = np.logspace(0, 3, 4, base=2)  # [1. 2. 4. 8.]
```

**geomspace**

`numpy.geomspace()` creates geometrically spaced sequences, where each element is a constant ratio from the previous element.

```python
# Geometric spacing
geom = np.geomspace(1, 1000, 4)  # [1. 10. 100. 1000.]
```

