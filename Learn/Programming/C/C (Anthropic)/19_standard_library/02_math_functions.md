## Math Functions


The math library provides comprehensive mathematical operations including trigonometric, logarithmic, exponential, and power functions.

**Header File:** `math.h`

**Trigonometric Functions:**

- `sin(x)`, `cos(x)`, `tan(x)`: Basic trigonometric functions
- `asin(x)`, `acos(x)`, `atan(x)`: Inverse trigonometric functions
- `atan2(y, x)`: Two-argument arctangent
- `sinh(x)`, `cosh(x)`, `tanh(x)`: Hyperbolic functions
- `asinh(x)`, `acosh(x)`, `atanh(x)`: Inverse hyperbolic functions (C99)

**Exponential and Logarithmic Functions:**

- `exp(x)`: Exponential function (e^x)
- `exp2(x)`: Base-2 exponential (2^x) (C99)
- `expm1(x)`: exp(x) - 1, accurate for small x (C99)
- `log(x)`: Natural logarithm
- `log10(x)`: Base-10 logarithm
- `log2(x)`: Base-2 logarithm (C99)
- `log1p(x)`: log(1 + x), accurate for small x (C99)

**Power and Root Functions:**

- `pow(x, y)`: x raised to power y
- `sqrt(x)`: Square root
- `cbrt(x)`: Cube root (C99)
- `hypot(x, y)`: sqrt(x² + y²) without overflow (C99)

**Rounding and Remainder Functions:**

- `ceil(x)`: Ceiling function (smallest integer ≥ x)
- `floor(x)`: Floor function (largest integer ≤ x)
- `round(x)`: Round to nearest integer (C99)
- `trunc(x)`: Truncate to integer (C99)
- `fmod(x, y)`: Floating-point remainder
- `remainder(x, y)`: IEEE remainder (C99)

**Absolute Value and Sign Functions:**

- `fabs(x)`: Floating-point absolute value
- `copysign(x, y)`: Copy sign from y to magnitude of x (C99)
- `signbit(x)`: Test sign bit (C99)

**Classification Functions (C99):**

- `fpclassify(x)`: Classify floating-point value
- `isfinite(x)`: Test for finite value
- `isinf(x)`: Test for infinity
- `isnan(x)`: Test for NaN
- `isnormal(x)`: Test for normal value

**Special Constants:**

- `M_PI`: π value [Unverified - non-standard extension]
- `M_E`: e value [Unverified - non-standard extension]
- `HUGE_VAL`: Positive infinity representation

**Error Handling:**

- Functions set `errno` for domain and range errors
- May return special values (NaN, infinity) for invalid inputs
- Some implementations provide additional error information

**Precision Variants:**

- Most functions have `float` and `long double` versions
- Suffix `f` for float versions: `sinf()`, `cosf()`
- Suffix `l` for long double versions: `sinl()`, `cosl()`

