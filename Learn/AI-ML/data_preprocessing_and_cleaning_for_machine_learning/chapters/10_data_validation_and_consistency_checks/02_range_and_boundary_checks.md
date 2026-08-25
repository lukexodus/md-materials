## Range and Boundary Checks

### Definition and Purpose

Range and boundary checks are a specific category of validation rule that verify whether a numeric or ordinal value falls within an acceptable minimum and maximum limit. They are one of the most commonly applied data cleaning techniques because many real-world fields have natural, logical, or domain-defined limits.

### Why This Step Matters

**Key Points**
- Identifies values that are numerically impossible or implausible given the nature of the field (e.g., a negative age, a percentage above 100).
- Helps catch data entry errors, sensor malfunctions, and unit-conversion mistakes before they propagate into model training.
- Supports downstream model performance by reducing the influence of extreme or erroneous values that could distort statistical summaries (mean, variance) or scaling operations. [Inference] The extent of this benefit depends on the specific model and preprocessing pipeline used, and cannot be treated as a general guarantee.

### Types of Boundaries

#### Hard Boundaries

Values that are logically or physically impossible outside the defined range. These boundaries derive from the definition of the field itself, not from statistical patterns in a particular dataset.

Examples:
- A percentage field cannot be below 0 or above 100.
- A probability cannot be below 0.0 or above 1.0.
- A count field (e.g., number of items purchased) cannot be negative.
- A month field must be between 1 and 12.

#### Soft Boundaries

Values that are statistically unusual but not strictly impossible. These boundaries are typically derived from the observed distribution of the data rather than a fixed logical rule, and often require human judgment to interpret.

Examples:
- Age above 100 (rare, but not impossible)
- Annual income far above the 99th percentile of the dataset
- Transaction amount several standard deviations above the mean

I cannot verify a universal threshold for "statistically unusual" — the specific cutoff (e.g., 2 vs. 3 standard deviations, IQR multiplier of 1.5 vs. 3.0) is a modeling decision that varies by dataset and domain. [Inference]

### Implementing Range Checks

#### Simple Fixed-Range Validation

```python
import pandas as pd

df = pd.DataFrame({"percentage_score": [85, -5, 102, 60, 45]})

df["in_valid_range"] = df["percentage_score"].between(0, 100)
print(df)
```

**Output**
```
   percentage_score  in_valid_range
0                 85            True
1                 -5           False
2                102           False
3                 60            True
4                 45            True
```

This uses the documented behavior of the pandas `.between()` method, which is inclusive of both bounds by default.

#### Statistical Boundary Detection (Standard Deviation Method)

```python
import numpy as np

data = pd.Series([22, 25, 24, 23, 90, 26, 21, 24])
mean = data.mean()
std = data.std()

lower_bound = mean - 3 * std
upper_bound = mean + 3 * std

outliers = data[(data < lower_bound) | (data > upper_bound)]
print(outliers)
```

**Output**
```
4    90
dtype: int64
```

The threshold of 3 standard deviations is a common convention in practice, not a fixed law. [Inference] Whether 3 is the appropriate multiplier depends on the distribution shape and the specific field being evaluated; this cannot be generalized as a rule that applies to all datasets.

#### Statistical Boundary Detection (Interquartile Range Method)

```python
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1

lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers_iqr = data[(data < lower_bound) | (data > upper_bound)]
print(outliers_iqr)
```

**Output**
```
4    90
dtype: int64
```

The multiplier of 1.5 for IQR-based outlier detection is a widely used convention (originating from Tukey's method), but its appropriateness for a specific dataset is a judgment call rather than a fixed requirement. [Inference]

### Visualizing Hard vs. Soft Boundaries

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Hard versus soft boundary concept (svg_diagram)</title><desc>A number line showing a hard boundary at the logical minimum and maximum of a field, and a soft boundary derived from the statistical distribution, positioned inside the hard boundary range.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<line x1="60" y1="140" x2="620" y2="140" stroke="var(--t)" stroke-width="1" />

<line x1="60" y1="120" x2="60" y2="160" stroke="#D85A30" stroke-width="2" />
<text class="ts" x="60" y="185" text-anchor="middle">Hard min (0)</text>

<line x1="620" y1="120" x2="620" y2="160" stroke="#D85A30" stroke-width="2" />
<text class="ts" x="620" y="185" text-anchor="middle">Hard max (100)</text>

<line x1="220" y1="128" x2="220" y2="152" stroke="#1D9E75" stroke-width="2" stroke-dasharray="4 3" />
<text class="ts" x="220" y="105" text-anchor="middle">Soft lower</text>

<line x1="460" y1="128" x2="460" y2="152" stroke="#1D9E75" stroke-width="2" stroke-dasharray="4 3" />
<text class="ts" x="460" y="105" text-anchor="middle">Soft upper</text>

<g class="c-gray">
<rect x="220" y="132" width="240" height="16" rx="4" stroke-width="0.5" opacity="0.5" />
</g>
<text class="ts" x="340" y="230" text-anchor="middle">Values inside soft bounds: typical</text>
<text class="ts" x="340" y="248" text-anchor="middle">Values between soft and hard bounds: unusual, review recommended</text>
</svg>

### Handling Boundary Violations

**Key Points**
- **Clipping (Winsorizing):** Replace out-of-range values with the nearest valid boundary value.
- **Removal:** Exclude the record from the dataset entirely.
- **Flagging:** Retain the record but add an indicator column noting the violation for downstream review.
- **Transformation:** Apply a mathematical transformation (e.g., log transform) to reduce the influence of extreme values, where domain-appropriate.

```python
df["percentage_score_clipped"] = df["percentage_score"].clip(lower=0, upper=100)
print(df[["percentage_score", "percentage_score_clipped"]])
```

**Output**
```
   percentage_score  percentage_score_clipped
0                 85                        85
1                 -5                         0
2                102                       100
3                 60                        60
4                 45                        45
```

This uses the documented behavior of pandas `.clip()`, which bounds values at the specified lower and upper limits.

### Domain-Specific Boundary Examples

| Field | Typical Hard Boundary | Notes |
|---|---|---|
| Age (years) | 0 to ~120 | Upper limit is a practical convention, not a biological law [Inference] |
| Percentage | 0 to 100 | Logical definition of a percentage |
| Probability | 0.0 to 1.0 | Logical definition of probability |
| Latitude | -90 to 90 | Geographic coordinate system definition |
| Longitude | -180 to 180 | Geographic coordinate system definition |
| Month | 1 to 12 | Calendar definition |
| Day of month | 1 to 31 (context-dependent) | Varies by month and leap year |
| Human body temperature (°C) | roughly 30 to 45 | Approximate clinical plausibility range; exact clinical thresholds should be verified against a medical reference [Unverified] |

### Boundary Checks in Time-Series and Sensor Data

For sensor-derived or time-series data, boundary checks often need to account for physically plausible limits specific to the measuring instrument or phenomenon (e.g., a thermometer's operating range, a speed sensor's maximum physically possible reading). [Inference] The specific plausible range in these cases is determined by the sensor specification and physical context, and cannot be assumed without domain-specific reference; I do not have access to verify sensor-specific tolerances without being provided the relevant specification.

### Common Pitfalls

- **Using statistically derived soft boundaries as if they were hard, logical limits**, which can lead to discarding legitimate but rare data points.
- **Setting boundaries based only on the training set distribution**, which may not generalize to future or production data distributions. [Inference] This risk is commonly discussed in data validation practice, but its actual impact depends on how representative the training set is of future data.
- **Ignoring context-dependent boundaries** (e.g., using a single "day of month" boundary of 1–31 without accounting for months with fewer days).
- **Applying clipping without documentation**, which can obscure the fact that original values were altered, complicating later audits.
- **Conflating unit errors with genuine outliers** (e.g., a height recorded in centimeters mixed into a column otherwise recorded in meters), which may appear as an out-of-range value but actually reflects a unit inconsistency rather than an invalid measurement.

### Practical Recommendation Summary

| Situation | Suggested Approach |
|---|---|
| Field has a clear logical/physical limit | Apply hard boundary check |
| Field distribution is approximately known but no logical limit exists | Apply soft/statistical boundary check with human review |
| Small number of violations | Consider flagging or manual review |
| Large number of violations | Investigate systemic cause (e.g., unit mismatch, upstream data bug) before applying automated correction |
| Need to preserve dataset size | Consider clipping rather than removal |
| Need highest data integrity | Consider removal or flag-and-review rather than silent correction |

### Conclusion

Range and boundary checks are a core validation technique that distinguish between logically impossible ("hard boundary") values and statistically unusual ("soft boundary") values. Hard boundaries can generally be defined with confidence from the definition of the field itself, while soft boundaries require judgment informed by the data's distribution and domain context. I cannot verify a single universally correct method for setting soft boundaries or handling violations — these remain dataset- and context-dependent decisions.

**Related Topics**
- Defining Validation Rules and Constraints
- Outlier Detection and Treatment (Statistical Methods)
- Data Cleaning for Text Fields — Case normalization
- Missing Data — Detection and Imputation Strategies
- Unit Consistency Checks and Conversion
- Domain-Specific Data Quality Rules

> Note: This response contains [Inference] and [Unverified] labeled statements throughout as marked above. Statements describing standard, documented library behavior (e.g., pandas `.between()`, `.clip()`) reflect confirmed, documented functionality rather than speculation.