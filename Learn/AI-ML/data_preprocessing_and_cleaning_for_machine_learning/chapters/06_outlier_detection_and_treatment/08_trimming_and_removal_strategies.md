## Trimming and Removal Strategies

### Overview

Trimming (also called truncation) is an outlier treatment approach that removes observations falling outside defined bounds entirely, rather than capping them to a threshold value as in Winsorization. This section covers when and how to remove outlier rows, the tradeoffs versus capping, and practical implementation patterns.

### Trimming vs. Capping: Core Distinction

- **Trimming/Removal**: Observations outside the defined bounds are deleted from the dataset entirely, reducing the sample size (n).
- **Capping/Winsorization** (covered previously): Observations outside the bounds are replaced with the boundary value, preserving sample size.

The choice between them affects downstream statistics differently. [Inference] Trimming tends to reduce variance more aggressively than capping because it removes the data point's contribution entirely rather than bounding it — this is a reasoned consequence of the arithmetic involved, not a claim verified against a specific benchmark or dataset.

### When Trimming Is Preferred Over Capping

**Key Points**
- The outlier is confirmed to be a data error (e.g., impossible value such as negative age, a sensor malfunction reading) rather than a legitimate extreme observation.
- The number of affected rows is small relative to the total dataset, so removal does not meaningfully reduce statistical power.
- The feature in question is not critical to other rows' usability — i.e., removing the row does not discard otherwise valuable data from unrelated columns.
- Domain knowledge indicates the observation falls outside the population of interest (e.g., a B2B transactions dataset accidentally containing a consumer transaction).

[Inference] Whether removal is "safe" for a given dataset depends on sample size, missingness patterns, and how the outlier rows correlate with other variables — this is a general reasoning principle, not a guarantee applicable to any specific dataset without checking it directly.

### When Trimming Is Risky

- Small datasets, where removing rows can materially shrink an already limited sample and increase estimator variance.
- Cases where the outlier reflects a genuine rare event relevant to the modeling task (e.g., fraud detection, where extreme values are often the signal of interest, not noise to discard).
- Non-random outlier patterns — if outliers are concentrated in a particular subgroup (e.g., a specific customer segment or time period), removing them can introduce selection bias into the resulting dataset.
- Pipelines where reproducibility across train/validation/test splits matters; removal thresholds must be computed consistently to avoid inconsistent row counts across runs.

[Unverified] The specific magnitude of bias introduced by non-random outlier removal in any given dataset cannot be stated generically — it depends on the underlying data-generating process and would need to be assessed empirically for each case.

### Common Trimming Methods

#### 1. Percentile-Based Trimming

Rows with a feature value below the $p$-th percentile or above the $(100-p)$-th percentile are removed.

$$
\text{Keep row if } P_{lower} \leq x \leq P_{upper}
$$

#### 2. IQR-Based Trimming

Using the same IQR convention as capping, but removing rather than clipping:

$$
IQR = Q_3 - Q_1
$$

$$
\text{Remove if } x < Q_1 - k \times IQR \text{ or } x > Q_3 + k \times IQR
$$

with $k = 1.5$ as a common convention for standard outliers, and $k = 3$ for extreme outliers.

#### 3. Standard-Deviation-Based Trimming

$$
\text{Remove if } |x - \mu| > k\sigma
$$

typically with $k = 3$. [Inference] As with capping, this method's reliability depends on the data being approximately normally distributed, since both $\mu$ and $\sigma$ are themselves distorted by the outliers they are meant to detect — this is a mathematical property of the mean and standard deviation, not a claim about any specific dataset's behavior.

#### 4. Domain-Rule-Based Trimming

Removing rows based on logical or physical constraints rather than statistical thresholds — for example, removing rows where age is negative or greater than 130, or where a percentage field falls outside 0–100.

### Diagram: Trimming Decision Process

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 460" font-family="sans-serif">
  <text x="400" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Trimming / Removal Decision Flow (svg_diagram)</text>

  <rect x="310" y="55" width="180" height="50" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="400" y="85" text-anchor="middle" font-size="13" fill="#1a1a1a">Candidate outlier row</text>

  <line x1="400" y1="105" x2="400" y2="140" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />

  <polygon points="400,140 500,180 400,220 300,180" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="400" y="176" text-anchor="middle" font-size="11" fill="#1a1a1a">Confirmed data</text>
  <text x="400" y="192" text-anchor="middle" font-size="11" fill="#1a1a1a">error or invalid?</text>

  <line x1="300" y1="180" x2="150" y2="180" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />
  <text x="225" y="170" text-anchor="middle" font-size="11" fill="#333">Yes</text>
  <rect x="50" y="155" width="150" height="50" rx="8" fill="#f8d7da" stroke="#dc3545" stroke-width="1.5" />
  <text x="125" y="177" text-anchor="middle" font-size="12" fill="#1a1a1a">Remove row</text>
  <text x="125" y="193" text-anchor="middle" font-size="12" fill="#1a1a1a">(trim)</text>

  <line x1="400" y1="220" x2="400" y2="255" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />
  <text x="415" y="240" text-anchor="middle" font-size="11" fill="#333">No</text>

  <polygon points="400,255 500,295 400,335 300,295" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="400" y="291" text-anchor="middle" font-size="11" fill="#1a1a1a">Likely a rare</text>
  <text x="400" y="307" text-anchor="middle" font-size="11" fill="#1a1a1a">but real event?</text>

  <line x1="500" y1="295" x2="650" y2="295" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />
  <text x="575" y="285" text-anchor="middle" font-size="11" fill="#333">Yes</text>
  <rect x="650" y="270" width="150" height="50" rx="8" fill="#d4edda" stroke="#28a745" stroke-width="1.5" />
  <text x="725" y="292" text-anchor="middle" font-size="12" fill="#1a1a1a">Keep or cap</text>
  <text x="725" y="308" text-anchor="middle" font-size="12" fill="#1a1a1a">(do not remove)</text>

  <line x1="400" y1="335" x2="400" y2="370" stroke="#555" stroke-width="1.5" marker-end="url(#arrow2)" />
  <text x="415" y="355" text-anchor="middle" font-size="11" fill="#333">No / unsure</text>

  <rect x="290" y="370" width="220" height="60" rx="8" fill="#e2e3e5" stroke="#6c757d" stroke-width="1.5" />
  <text x="400" y="395" text-anchor="middle" font-size="12" fill="#1a1a1a">Prefer capping over</text>
  <text x="400" y="412" text-anchor="middle" font-size="12" fill="#1a1a1a">removal; investigate further</text>

  </svg>

### Implementation Example — IQR-Based Trimming (Python / pandas)

```python
import pandas as pd
import numpy as np

data = pd.DataFrame({
    'income': [32000, 41000, 39000, 45000, 1250000, 38000, -500, 43000, 47000, 990000]
})

def trim_by_iqr(df, column, k=1.5):
    Q1 = df[column].quantile(0.25)
    Q3 = df[column].quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - k * IQR
    upper_bound = Q3 + k * IQR
    mask = (df[column] >= lower_bound) & (df[column] <= upper_bound)
    return df[mask]

trimmed_data = trim_by_iqr(data, 'income')
print(trimmed_data)
```

**Output**
```
   income
0   32000
1   41000
2   39000
3   45000
5   38000
7   43000
8   47000
```
[Inference] The exact rows retained depend on the computed Q1/Q3/IQR values for this specific array; the output above reflects a reasoned calculation based on the input data shown, not a value confirmed by an external source.

### Implementation Example — Domain-Rule Trimming

```python
# Remove physically impossible or invalid values
data_clean = data[(data['income'] >= 0)]
```

This pattern requires explicit domain knowledge about valid ranges rather than relying purely on the observed distribution.

### Train/Test Split Considerations

- Trimming thresholds (percentile, IQR, or standard-deviation bounds) should be computed on the training set only.
- The same fixed thresholds are then applied to validation/test sets — but note that this means test rows exceeding the threshold are typically either removed too (changing test set size) or left capped/flagged instead, depending on the pipeline design.
- [Unverified] There is no single universally agreed convention for how test-set outliers should be handled once training-set thresholds are fixed; practices vary across teams and problem domains, and this should be confirmed against your own project's evaluation requirements rather than assumed.
- Trimming performed before a train/test split (i.e., on the full combined dataset) risks leaking distributional information from the test set into the threshold calculation.

### Impact on Dataset Size and Class Balance

- In classification tasks, trimming rows can inadvertently shift class balance if outliers are correlated with a particular class (e.g., fraud cases are often extreme values in transaction amount).
- [Inference] Because rare-event classes are often statistically represented by tail values in one or more features, aggressive trimming can disproportionately remove the minority class — this is a reasoned risk based on how trimming interacts with class distribution, not a measured outcome for any particular dataset.
- Logging the number and proportion of rows removed at each preprocessing step is a widely used practice for auditing pipeline impact, though the specific reporting format is implementation-dependent.

### Common Pitfalls

- Removing outliers without recording how many rows were dropped, making it difficult to audit whether the trimming step introduced unintended bias.
- Applying trimming thresholds derived from one dataset version to a differently distributed dataset in production, without re-validation.
- Conflating a statistically extreme value with an erroneous one — not all statistical outliers are data errors, and not all data errors are statistical outliers.
- Performing trimming after feature engineering steps that themselves depend on the full (untrimmed) distribution, creating inconsistent intermediate states in the pipeline.

I cannot verify how any specific third-party library's internal implementation handles edge cases (e.g., ties at exact quantile boundaries) without testing against the exact installed version, so behavior described above should be confirmed directly in your environment before being relied upon in production code.

### Conclusion

Trimming removes outlier rows entirely rather than bounding their values, which reduces sample size but eliminates the outlier's influence completely rather than partially. It is generally considered more appropriate when outliers are confirmed data errors or fall outside the population of interest, while capping is often preferred when the extreme values are legitimate but disruptive to model training. [Inference] The decision between the two approaches depends on dataset size, the nature of the outlier, and the modeling goal — this is a general framework for reasoning about the tradeoff, not a rule confirmed to apply uniformly across all cases.

**Related Topics**
- Winsorization and Capping (previous topic)
- Outlier Detection Methods — Z-score, Modified Z-score, IQR
- Class Imbalance Handling After Outlier Removal
- Robust Statistical Estimators (median, MAD) as Alternatives to Mean/SD-Based Thresholds
- Auditing and Logging Data Transformation Pipelines
- Domain-Rule-Based Data Validation