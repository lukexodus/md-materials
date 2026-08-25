## `math` Module


### Overview

The math module is a built-in Python library that provides access to mathematical functions and constants defined by the C standard. It offers a comprehensive collection of mathematical operations including trigonometric functions, logarithms, exponentials, and various utility functions for numerical computations.

### Importing the Math Module

```python
import math
```

Once imported, all functions and constants are accessed using the `math.` prefix.

### Mathematical Constants

#### pi

The mathematical constant π (pi), approximately 3.14159.

```python
import math
print(math.pi)  # 3.141592653589793
```

#### e

The mathematical constant e (Euler's number), approximately 2.71828.

```python
print(math.e)  # 2.718281828459045
```

#### tau

The mathematical constant τ (tau), equal to 2π, approximately 6.28318.

```python
print(math.tau)  # 6.283185307179586
```

#### inf

Positive infinity as a floating-point value.

```python
print(math.inf)  # inf
```

#### nan

"Not a Number" (NaN) floating-point value.

```python
print(math.nan)  # nan
```

### Power and Logarithmic Functions

#### math.pow(x, y)

Returns x raised to the power y.

```python
result = math.pow(2, 3)  # 8.0
```

#### math.sqrt(x)

Returns the square root of x.

```python
result = math.sqrt(16)  # 4.0
```

#### math.log(x[, base])

Returns the natural logarithm of x, or logarithm to the given base.

```python
natural_log = math.log(math.e)  # 1.0
log_base_10 = math.log(100, 10)  # 2.0
```

#### math.log10(x)

Returns the base-10 logarithm of x.

```python
result = math.log10(1000)  # 3.0
```

#### math.log2(x)

Returns the base-2 logarithm of x.

```python
result = math.log2(8)  # 3.0
```

#### math.exp(x)

Returns e raised to the power x.

```python
result = math.exp(1)  # 2.718281828459045
```

#### math.exp2(x)

Returns 2 raised to the power x.

```python
result = math.exp2(3)  # 8.0
```

#### math.expm1(x)

Returns e^x - 1, providing better precision for small values of x.

```python
result = math.expm1(0.001)  # More accurate than math.exp(0.001) - 1
```

#### math.log1p(x)

Returns ln(1 + x), providing better precision for small values of x.

```python
result = math.log1p(0.001)  # More accurate than math.log(1 + 0.001)
```

### Trigonometric Functions

#### Basic Trigonometric Functions

```python
# Sine, cosine, and tangent
angle = math.pi / 4  # 45 degrees in radians
sin_val = math.sin(angle)    # 0.7071067811865476
cos_val = math.cos(angle)    # 0.7071067811865476
tan_val = math.tan(angle)    # 1.0
```

#### Inverse Trigonometric Functions

```python
# Arc sine, arc cosine, and arc tangent
value = 0.5
asin_val = math.asin(value)  # 0.5235987755982989
acos_val = math.acos(value)  # 1.0471975511965979
atan_val = math.atan(value)  # 0.4636476090008061
```

#### math.atan2(y, x)

Returns the arc tangent of y/x in radians, considering the signs of both arguments.

```python
result = math.atan2(1, 1)  # 0.7853981633974483 (45 degrees)
```

#### Hyperbolic Functions

```python
x = 1.0
sinh_val = math.sinh(x)  # 1.1752011936438014
cosh_val = math.cosh(x)  # 1.5430806348152437
tanh_val = math.tanh(x)  # 0.7615941559557649
```

#### Inverse Hyperbolic Functions

```python
x = 1.0
asinh_val = math.asinh(x)  # 0.8813735870195429
acosh_val = math.acosh(x)  # 0.0
atanh_val = math.atanh(0.5)  # 0.5493061443340549
```

### Rounding and Numeric Functions

#### math.ceil(x)

Returns the ceiling of x (smallest integer greater than or equal to x).

```python
result = math.ceil(4.2)   # 5
result = math.ceil(-4.2)  # -4
```

#### math.floor(x)

Returns the floor of x (largest integer less than or equal to x).

```python
result = math.floor(4.8)   # 4
result = math.floor(-4.8)  # -5
```

#### math.trunc(x)

Returns the truncated integer part of x.

```python
result = math.trunc(4.8)   # 4
result = math.trunc(-4.8)  # -4
```

#### math.fabs(x)

Returns the absolute value of x as a float.

```python
result = math.fabs(-5.5)  # 5.5
```

#### math.copysign(x, y)

Returns x with the sign of y.

```python
result = math.copysign(5, -1)  # -5.0
```

#### math.fmod(x, y)

Returns the floating-point remainder of x/y.

```python
result = math.fmod(10.5, 3)  # 1.5
```

#### math.remainder(x, y)

Returns the IEEE remainder of x with respect to y.

```python
result = math.remainder(10.5, 3)  # -1.5
```

#### math.modf(x)

Returns the fractional and integer parts of x as a tuple.

```python
fractional, integer = math.modf(4.75)  # (0.75, 4.0)
```

### Classification Functions

#### math.isfinite(x)

Returns True if x is finite (not infinite or NaN).

```python
result = math.isfinite(5.0)      # True
result = math.isfinite(math.inf) # False
```

#### math.isinf(x)

Returns True if x is positive or negative infinity.

```python
result = math.isinf(math.inf)  # True
result = math.isinf(5.0)       # False
```

#### math.isnan(x)

Returns True if x is NaN (Not a Number).

```python
result = math.isnan(math.nan)  # True
result = math.isnan(5.0)       # False
```

#### math.isclose(a, b, rel_tol=1e-09, abs_tol=0.0)

Returns True if values a and b are close to each other.

```python
result = math.isclose(0.1 + 0.2, 0.3)  # True
result = math.isclose(1.0, 1.01, rel_tol=0.1)  # True
```

### Distance and Norm Functions

#### math.dist(p, q)

Returns the Euclidean distance between points p and q.

```python
point1 = [1, 2, 3]
point2 = [4, 5, 6]
distance = math.dist(point1, point2)  # 5.196152422706632
```

#### math.hypot(*coordinates)

Returns the Euclidean norm (distance from origin).

```python
# 2D distance
distance = math.hypot(3, 4)  # 5.0

# 3D distance
distance = math.hypot(1, 2, 3)  # 3.7416573867739413
```

### Factorial and Combinatorial Functions

#### math.factorial(n)

Returns the factorial of n.

```python
result = math.factorial(5)  # 120
```

#### math.comb(n, k)

Returns the number of ways to choose k items from n items.

```python
result = math.comb(5, 2)  # 10
```

#### math.perm(n, k)

Returns the number of ways to arrange k items from n items.

```python
result = math.perm(5, 2)  # 20
```

### Angle Conversion Functions

#### math.degrees(x)

Converts angle x from radians to degrees.

```python
degrees = math.degrees(math.pi)  # 180.0
degrees = math.degrees(math.pi / 2)  # 90.0
```

#### math.radians(x)

Converts angle x from degrees to radians.

```python
radians = math.radians(180)  # 3.141592653589793
radians = math.radians(90)   # 1.5707963267948966
```

### Special Functions

#### math.gamma(x)

Returns the gamma function at x.

```python
result = math.gamma(5)  # 24.0 (equivalent to factorial(4))
```

#### math.lgamma(x)

Returns the natural logarithm of the gamma function at x.

```python
result = math.lgamma(5)  # 3.1780538303479458
```

#### math.erf(x)

Returns the error function at x.

```python
result = math.erf(1)  # 0.8427007929497149
```

#### math.erfc(x)

Returns the complementary error function at x.

```python
result = math.erfc(1)  # 0.15729920705028513
```

### Utility Functions

#### math.fsum(iterable)

Returns an accurate floating-point sum of values in the iterable.

```python
numbers = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
result = math.fsum(numbers)  # 1.0 (more accurate than sum())
```

#### math.prod(iterable, start=1)

Returns the product of all elements in the iterable.

```python
numbers = [1, 2, 3, 4, 5]
result = math.prod(numbers)  # 120
```

#### math.gcd(a, b)

Returns the greatest common divisor of a and b.

```python
result = math.gcd(48, 18)  # 6
```

#### math.lcm(*args)

Returns the least common multiple of the arguments.

```python
result = math.lcm(12, 18)  # 36
result = math.lcm(12, 18, 24)  # 72
```

#### math.frexp(x)

Returns the mantissa and exponent of x as a tuple.

```python
mantissa, exponent = math.frexp(8.0)  # (0.5, 4) because 8.0 = 0.5 * 2^4
```

#### math.ldexp(x, i)

Returns x * (2**i), the inverse of frexp().

```python
result = math.ldexp(0.5, 4)  # 8.0
```

#### math.nextafter(x, y)

Returns the next representable floating-point value after x in the direction of y.

```python
result = math.nextafter(1.0, 2.0)  # 1.0000000000000002
```

#### math.ulp(x)

Returns the value of the least significant bit of x.

```python
result = math.ulp(1.0)  # 2.220446049250313e-16
```

### Practical Examples

#### Distance Calculations

```python
import math

# Calculate distance between two points
def distance_2d(x1, y1, x2, y2):
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)

# Using hypot for better precision
def distance_2d_hypot(x1, y1, x2, y2):
    return math.hypot(x2 - x1, y2 - y1)

# 3D distance
def distance_3d(p1, p2):
    return math.dist(p1, p2)
```

#### Angle Calculations

```python
import math

# Convert between degrees and radians
def deg_to_rad(degrees):
    return math.radians(degrees)

def rad_to_deg(radians):
    return math.degrees(radians)

# Calculate angle between two vectors
def angle_between_vectors(v1, v2):
    dot_product = sum(a * b for a, b in zip(v1, v2))
    magnitude_v1 = math.hypot(*v1)
    magnitude_v2 = math.hypot(*v2)
    return math.acos(dot_product / (magnitude_v1 * magnitude_v2))
```

#### Statistical Calculations

```python
import math

# Calculate standard deviation
def standard_deviation(data):
    n = len(data)
    mean = sum(data) / n
    variance = sum((x - mean) ** 2 for x in data) / n
    return math.sqrt(variance)

# Calculate geometric mean
def geometric_mean(data):
    product = math.prod(data)
    return product ** (1 / len(data))
```

### Error Handling

The math module raises specific exceptions for invalid operations:

```python
import math

try:
    result = math.sqrt(-1)  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")

try:
    result = math.log(0)  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")

try:
    result = math.factorial(-1)  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")
```

### Performance Considerations

The math module functions are implemented in C and are highly optimized. However, for array operations, consider using NumPy for better performance:

```python
import math
import time

# Using math module (slower for large datasets)
def process_with_math(data):
    return [math.sqrt(x) for x in data]

# For large arrays, NumPy is more efficient
import numpy as np
def process_with_numpy(data):
    return np.sqrt(data)
```

### Common Pitfalls

#### Floating-Point Precision

```python
import math

# Avoid direct equality comparisons
result = math.sqrt(2) ** 2
print(result == 2)  # False due to floating-point precision

# Use isclose() instead
print(math.isclose(result, 2))  # True
```

#### Domain Errors

```python
import math

# Check for valid domains
def safe_sqrt(x):
    if x < 0:
        raise ValueError("Cannot compute square root of negative number")
    return math.sqrt(x)

def safe_log(x):
    if x <= 0:
        raise ValueError("Logarithm undefined for non-positive numbers")
    return math.log(x)
```

**Key points:** The math module provides essential mathematical functions and constants for Python programming. It offers comprehensive coverage of basic arithmetic, trigonometry, logarithms, and special functions. All functions operate on and return floating-point numbers, making it ideal for scientific computing and mathematical applications.

**Next steps:** For more advanced mathematical operations, consider exploring NumPy for array operations, SciPy for scientific computing, or the decimal module for precise decimal arithmetic.

---

