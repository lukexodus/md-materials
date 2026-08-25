## Handling NaN and Infinite Values in Numerical Arrays

### Overview

NumPy represents missing or undefined numerical data using special floating-point values: `NaN` (Not a Number) and `inf`/`-inf` (positive/negative infinity). These values follow the IEEE 754 floating-point standard. [Unverified: exact compliance details may vary by platform and NumPy version; behavior should be confirmed against the installed NumPy version's documentation.]

Handling these values correctly is a core part of data cleaning for machine learning, since most algorithms cannot process NaN or infinite values directly and will raise errors or produce invalid results if they are not addressed.

### Sources of NaN and Infinite Values

- Division by zero: `1.0 / 0.0` produces `inf`; `0.0 / 0.0` produces `NaN`
- Logarithm of zero or negative numbers: `np.log(0)` produces `-inf`; `np.log(-1)` produces `NaN`
- Square root of negative numbers: `np.sqrt(-1)` produces `NaN`
- Overflow in floating-point computations
- Missing data explicitly encoded as `np.nan` during array construction
- Type coercion issues when converting from data sources containing missing values

### Creating and Recognizing These Values

```python
import numpy as np

arr = np.array([1.0, np.nan, np.inf, -np.inf, 5.0])
print(arr)
# [  1.  nan  inf -inf   5.]
```

**Key Points**
- `np.nan` is a float constant representing an undefined value
- `np.inf` and `-np.inf` represent positive and negative infinity
- `NaN` is not equal to itself: `np.nan == np.nan` evaluates to `False`
- Arrays containing `NaN` or `inf` must be dtype `float` (or complex); integer arrays cannot hold these values natively [Unverified: this is standard NumPy dtype behavior as commonly documented, but exact error messages may differ across versions]

### Detecting NaN and Infinite Values

```python
arr = np.array([1.0, np.nan, np.inf, -np.inf, 5.0])

np.isnan(arr)
# array([False,  True, False, False, False])

np.isinf(arr)
# array([False, False,  True,  True, False])

np.isfinite(arr)
# array([ True, False, False, False,  True])
```

`np.isfinite()` is often the most practical check, since it returns `False` for both `NaN` and infinite values simultaneously, allowing a single mask to identify all problematic entries.

### Counting Invalid Values

```python
nan_count = np.sum(np.isnan(arr))
inf_count = np.sum(np.isinf(arr))
invalid_count = np.sum(~np.isfinite(arr))

print(nan_count, inf_count, invalid_count)
# 1 2 3
```

### Removing Invalid Values

```python
arr = np.array([1.0, np.nan, np.inf, -np.inf, 5.0])

clean_arr = arr[np.isfinite(arr)]
print(clean_arr)
# [1. 5.]
```

This approach filters out all non-finite entries, retaining only valid numerical data. It reduces the array's length, which may not be appropriate when positional alignment with other arrays (e.g., corresponding labels) must be preserved.

### Replacing Invalid Values

**Replacing NaN with a fixed value:**

```python
arr = np.array([1.0, np.nan, 3.0])
filled = np.where(np.isnan(arr), 0.0, arr)
print(filled)
# [1. 0. 3.]
```

**Using `np.nan_to_num()`:**

```python
arr = np.array([1.0, np.nan, np.inf, -np.inf])
result = np.nan_to_num(arr)
print(result)
# [1.00000000e+000 0.00000000e+000 1.79769313e+308 -1.79769313e+308]
```

By default, `np.nan_to_num()` replaces `NaN` with `0`, positive infinity with a very large finite float (near the maximum representable float value), and negative infinity with a very large negative finite float. [Unverified: exact default replacement values are documented behavior in NumPy's official documentation but should be checked against the specific version in use, as defaults have had configurable parameters added in some releases.]

Custom replacement values can be specified:

```python
result = np.nan_to_num(arr, nan=-1.0, posinf=1000.0, neginf=-1000.0)
print(result)
# [   1.   -1. 1000. -1000.]
```

### NaN-Aware Aggregate Functions

Standard aggregation functions propagate `NaN` through the entire result. NumPy provides `nan`-prefixed variants that ignore `NaN` values during computation.

```python
arr = np.array([1.0, np.nan, 3.0, 4.0])

np.sum(arr)      # nan
np.nansum(arr)   # 8.0

np.mean(arr)     # nan
np.nanmean(arr)  # 2.6666666666666665

np.max(arr)      # nan
np.nanmax(arr)   # 4.0

np.std(arr)      # nan
np.nanstd(arr)   # approx 1.247
```

**Key Points**
- Available NaN-aware functions include `nansum`, `nanmean`, `nanmax`, `nanmin`, `nanstd`, `nanvar`, `nanmedian`, `nanpercentile`, and related functions [Unverified: this list reflects commonly documented NumPy functions; the complete set should be confirmed against current NumPy documentation, as it may change between versions]
- These functions do not have direct equivalents for handling `inf` values; infinite values must be masked or replaced separately before using these functions if they are also present

### Handling Infinite Values Separately from NaN

Since `np.isnan()` does not detect `inf`, and aggregate functions like `np.nansum()` do not ignore `inf`, a combined masking strategy is often required:

```python
arr = np.array([1.0, np.nan, np.inf, 4.0])

mask = np.isfinite(arr)
valid_values = arr[mask]
total = np.sum(valid_values)
print(total)
# 5.0
```

### Why This Matters for Machine Learning

Most machine learning algorithms and libraries (including scikit-learn estimators) [Unverified: this is a general characteristic of many, but not necessarily all, machine learning libraries and should not be assumed universal without checking specific library documentation] raise errors when given input containing `NaN` or infinite values. Feature scaling, normalization, and distance-based algorithms are particularly sensitive, since a single infinite or undefined value can distort computed statistics (mean, variance, min-max ranges) across an entire dataset.

Common practical strategies in ML preprocessing pipelines include:
- Imputation (replacing missing values with mean, median, or a constant)
- Removal of rows or columns exceeding a missing-value threshold
- Flagging invalid values as a separate binary feature before imputation
- Clipping extreme values that produce `inf` during computation (e.g., after exponentiation)

These strategies are common practice [Inference: based on widely referenced data preprocessing conventions in machine learning literature], but the optimal strategy depends on the dataset and modeling context, and no single approach is universally correct.

### Visual Summary

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 360">
  <text x="380" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">NaN and Infinite Value Handling Workflow (svg_diagram)</text>

  <rect x="30" y="60" width="160" height="60" rx="8" fill="#e8f0fe" stroke="#4a86e8" stroke-width="1.5" />
  <text x="110" y="85" font-size="12" text-anchor="middle" fill="#1a1a1a">Raw Array</text>
  <text x="110" y="102" font-size="11" text-anchor="middle" fill="#444">May contain NaN/inf</text>

  <line x1="190" y1="90" x2="240" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow1)" />

  <rect x="240" y="60" width="160" height="60" rx="8" fill="#fef7e0" stroke="#e0a800" stroke-width="1.5" />
  <text x="320" y="82" font-size="12" text-anchor="middle" fill="#1a1a1a">Detect</text>
  <text x="320" y="99" font-size="11" text-anchor="middle" fill="#444">isnan / isinf / isfinite</text>

  <line x1="400" y1="90" x2="450" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow1)" />

  <rect x="450" y="60" width="160" height="60" rx="8" fill="#fce8e6" stroke="#d93025" stroke-width="1.5" />
  <text x="530" y="82" font-size="12" text-anchor="middle" fill="#1a1a1a">Decide Strategy</text>
  <text x="530" y="99" font-size="11" text-anchor="middle" fill="#444">Remove / Replace / Impute</text>

  <line x1="530" y1="120" x2="530" y2="160" stroke="#666" stroke-width="1.5" marker-end="url(#arrow1)" />

  <rect x="380" y="160" width="150" height="55" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="455" y="182" font-size="12" text-anchor="middle" fill="#1a1a1a">Remove Rows</text>
  <text x="455" y="198" font-size="11" text-anchor="middle" fill="#444">arr[np.isfinite(arr)]</text>

  <line x1="450" y1="160" x2="230" y2="120" stroke="#666" stroke-width="1.5" marker-end="url(#arrow1)" />

  <rect x="130" y="160" width="150" height="55" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="205" y="182" font-size="12" text-anchor="middle" fill="#1a1a1a">Replace Values</text>
  <text x="205" y="198" font-size="11" text-anchor="middle" fill="#444">np.nan_to_num()</text>

  <line x1="530" y1="215" x2="530" y2="255" stroke="#666" stroke-width="1.5" marker-end="url(#arrow1)" />
  <line x1="205" y1="215" x2="205" y2="255" stroke="#666" stroke-width="1.5" marker-end="url(#arrow1)" />

  <rect x="130" y="255" width="450" height="60" rx="8" fill="#f3e8fd" stroke="#9334e6" stroke-width="1.5" />
  <text x="355" y="278" font-size="12" text-anchor="middle" fill="#1a1a1a">Clean Numeric Array</text>
  <text x="355" y="296" font-size="11" text-anchor="middle" fill="#444">Ready for aggregation, scaling, or model input</text>

  </svg>

### Common Pitfalls

- Assuming `np.isnan()` also detects `inf` — it does not; use `np.isfinite()` for combined checks
- Using `==` to compare against `np.nan`, which always evaluates to `False` regardless of the value being compared
- Applying `np.nan_to_num()` without specifying custom bounds, which may introduce very large finite values that distort downstream statistical computations [Inference: based on the mathematical effect of replacing infinity with near-maximum float values in subsequent calculations]
- Forgetting that integer-dtype arrays cannot store `NaN`, causing silent upcasting to float or raising a `ValueError` depending on context [Unverified: exact behavior may depend on the operation and NumPy version; should be verified empirically for the specific use case]

**Next Steps**
- Handling missing data in Pandas DataFrames (`isna()`, `fillna()`, `dropna()`)
- Imputation strategies using scikit-learn (`SimpleImputer`, `KNNImputer`)
- Detecting and handling outliers in numerical arrays
- Data type casting and overflow handling in NumPy
- Feature scaling and normalization techniques for ML pipelines
- Vectorized conditional operations using `np.where()` and `np.select()`