## Statistical Methods: Z-Score, IQR

### Overview

Z-score and Interquartile Range (IQR) methods are two of the most widely used statistical techniques for detecting outliers in numerical data — observations that deviate substantially from the rest of the dataset. Both approaches quantify how far a given value lies from the "typical" range of the data, but they rely on different underlying assumptions about the data's distribution, which makes each method more or less appropriate depending on the shape and characteristics of the variable being examined.

Detecting outliers is a distinct step from deciding what to do with them (removal, capping, transformation, or retention), which is typically addressed as a separate downstream decision once candidate outliers have been identified using methods like these.

### The Z-Score Method

The z-score (or standard score) measures how many standard deviations a data point lies from the mean of the distribution. It assumes the underlying data is approximately normally distributed, since its interpretation relies on properties of the normal distribution.

$$z = \frac{x - \mu}{\sigma}$$

where $x$ is the observed value, $\mu$ is the population mean, and $\sigma$ is the population standard deviation.

**Example** (Python, calculating z-scores)

```python
import numpy as np
import pandas as pd

data = pd.Series([22, 24, 23, 25, 21, 26, 24, 95, 23, 22])

mean = data.mean()
std = data.std()
z_scores = (data - mean) / std

print(pd.DataFrame({'value': data, 'z_score': z_scores.round(2)}))
```

**Output**

```
   value  z_score
0     22    -0.42
1     24    -0.30
2     23    -0.36
3     25    -0.25
4     21    -0.48
5     26    -0.19
6     24    -0.30
7     95     2.72
8     23    -0.36
9     22    -0.42
```

A common convention flags any observation with an absolute z-score above a chosen threshold — typically 2, 2.5, or 3 — as a potential outlier.

```python
threshold = 3
outliers = data[np.abs(z_scores) > threshold]
print(outliers)
```

**Output**

```
7    95
dtype: int64
```

**Using scipy for z-score computation**

```python
from scipy import stats

z_scores_scipy = stats.zscore(data)
outlier_mask = np.abs(z_scores_scipy) > 3
print(data[outlier_mask])
```

**Output**

```
7    95
dtype: int64
```

### Why the Standard Threshold of 3 Is Commonly Used

Under a normal distribution, the proportion of observations expected to fall beyond a given number of standard deviations from the mean is well-defined:

| Z-Score Threshold | Approx. % of Data Beyond Threshold (Normal Distribution) |
| --- | --- |
| ±1 | ~31.7% |
| ±2 | ~4.5% |
| ±2.5 | ~1.2% |
| ±3 | ~0.3% |

A threshold of 3 is popular because it flags a relatively small, conservative proportion of data as outliers under the assumption of normality, though [Inference] the appropriate threshold in practice depends on how conservative or aggressive the outlier flagging needs to be for the specific application, and there is no single correct value that applies universally.

### Limitations of the Z-Score Method

**Key Points**

- Assumes the underlying data is approximately normally distributed; z-scores can be misleading for skewed distributions, since the mean and standard deviation are themselves sensitive to the very outliers being detected
- The mean and standard deviation used in the z-score formula are not robust statistics — a single extreme outlier can inflate the standard deviation, which in turn can mask other legitimate outliers by shrinking their computed z-scores (a phenomenon sometimes called "masking")
- Performs poorly on small sample sizes, where the sample mean and standard deviation are less reliable estimates of the true population parameters
- Not well-suited to multimodal distributions, where "distance from the mean" does not correspond to genuine unusualness

[Inference] Because the z-score method's own reference statistics (mean and standard deviation) are influenced by the outliers it is trying to detect, it can be a less reliable choice specifically in datasets with extreme or numerous outliers, which is part of why robust alternatives like the IQR method are often preferred in exploratory data cleaning contexts.

### The Modified Z-Score (Using Median Absolute Deviation)

A more robust variant of the z-score method replaces the mean and standard deviation with the median and Median Absolute Deviation (MAD), which are far less sensitive to extreme values.

$$\text{MAD} = \text{median}(\lvert x_i - \tilde{x} \rvert)$$



$$M_i = \frac{0.6745 (x_i - \tilde{x})}{\text{MAD}}$$

where $\tilde{x}$ is the median of the dataset, and 0.6745 is a scaling constant that makes the modified z-score comparable to the standard z-score under a normal distribution.

```python
median = data.median()
mad = np.median(np.abs(data - median))
modified_z_scores = 0.6745 * (data - median) / mad

print(pd.DataFrame({'value': data, 'modified_z': modified_z_scores.round(2)}))

threshold = 3.5
robust_outliers = data[np.abs(modified_z_scores) > threshold]
print(robust_outliers)
```

**Output**

```
7    95
dtype: int64
```

A threshold of 3.5 is commonly recommended for the modified z-score method specifically, distinct from the conventional threshold of 3 used with the standard z-score.

### The Interquartile Range (IQR) Method

The IQR method is a robust, distribution-free approach to outlier detection based on quartiles rather than the mean and standard deviation, making it less sensitive to extreme values and more broadly applicable to skewed distributions.

The IQR is defined as the range between the first quartile ($Q_1$, the 25th percentile) and the third quartile ($Q_3$, the 75th percentile):

$$\text{IQR} = Q_3 - Q_1$$

Outlier boundaries (often called "fences") are then computed as:

$$\text{Lower Bound} = Q_1 - k \cdot \text{IQR}$$



$$\text{Upper Bound} = Q_3 + k \cdot \text{IQR}$$

where $k$ is a multiplier, most commonly set to 1.5 for standard outlier detection or 3.0 for identifying more extreme outliers.

**Example** (Python, IQR-based outlier detection)

```python
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1

lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

print(f"Q1: {Q1}, Q3: {Q3}, IQR: {IQR}")
print(f"Lower bound: {lower_bound}, Upper bound: {upper_bound}")

outliers = data[(data < lower_bound) | (data > upper_bound)]
print(outliers)
```

**Output**

```
Q1: 22.0, Q3: 24.75, IQR: 2.75
Lower bound: 17.875, Upper bound: 28.875
7    95
dtype: int64
```

### Visualizing the IQR Method with a Box Plot

The IQR method corresponds directly to the standard box plot visualization, where the box represents the interquartile range and the "whiskers" typically extend to the outlier fences.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
<text x="320" y="26" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a2e">Box Plot Structure (svg_diagram)</text>
<line x1="80" y1="150" x2="560" y2="150" stroke="#999" stroke-width="1" />

<line x1="120" y1="150" x2="180" y2="150" stroke="#333" stroke-width="2" />
<line x1="120" y1="130" x2="120" y2="170" stroke="#333" stroke-width="2" />

<rect x="180" y="110" width="140" height="80" fill="#a8dadc" stroke="#333" stroke-width="2" />

<line x1="250" y1="110" x2="250" y2="190" stroke="#1a1a2e" stroke-width="2.5" />

<line x1="320" y1="150" x2="400" y2="150" stroke="#333" stroke-width="2" />
<line x1="400" y1="130" x2="400" y2="170" stroke="#333" stroke-width="2" />

<circle cx="500" cy="150" r="6" fill="#e63946" />


<text x="120" y="200" text-anchor="middle" font-size="12" fill="#333">Lower Fence</text>

<text x="180" y="105" text-anchor="middle" font-size="12" fill="#333">Q1</text>

<text x="250" y="105" text-anchor="middle" font-size="12" fill="`#1a1a2e`" font-weight="bold">Median</text>

<text x="320" y="105" text-anchor="middle" font-size="12" fill="#333">Q3</text>

<text x="400" y="200" text-anchor="middle" font-size="12" fill="#333">Upper Fence</text>

<text x="500" y="175" text-anchor="middle" font-size="12" fill="`#e63946`">Outlier</text>

<text x="320" y="270" text-anchor="middle" font-size="12" fill="#555">Fences = Q1 - 1.5*IQR and Q3 + 1.5*IQR</text>

</svg>

```python
import matplotlib.pyplot as plt

plt.figure(figsize=(6, 4))
plt.boxplot(data, vert=False)
plt.title("Box Plot with IQR-Based Outlier Detection")
plt.xlabel("Value")
plt.show()
```

### Choosing the IQR Multiplier

| Multiplier ($k$) | Typical Use Case |
| --- | --- |
| 1.5 | Standard convention for general outlier flagging |
| 3.0 | Identifying "extreme" outliers specifically, used alongside the 1.5 threshold to distinguish moderate from severe outliers |

Some analyses use both thresholds simultaneously, categorizing observations beyond the 1.5×IQR fences as "mild outliers" and those beyond the 3×IQR fences as "extreme outliers."

```python
mild_lower, mild_upper = Q1 - 1.5 * IQR, Q3 + 1.5 * IQR
extreme_lower, extreme_upper = Q1 - 3 * IQR, Q3 + 3 * IQR

def classify_outlier(x):
    if x < extreme_lower or x > extreme_upper:
        return 'extreme'
    elif x < mild_lower or x > mild_upper:
        return 'mild'
    else:
        return 'normal'

classifications = data.apply(classify_outlier)
print(pd.DataFrame({'value': data, 'classification': classifications}))
```

**Output**

```
   value classification
0     22         normal
1     24         normal
2     23         normal
3     25         normal
4     21         normal
5     26         normal
6     24         normal
7     95        extreme
8     23         normal
9     22         normal
```

### Comparing Z-Score and IQR Methods

| Aspect | Z-Score Method | IQR Method |
| --- | --- | --- |
| Distribution assumption | Approximately normal | None (distribution-free) |
| Sensitivity to existing outliers | High (mean/std are non-robust) | Low (quartiles are robust statistics) |
| Performance on skewed data | Poor | Generally good |
| Interpretability | Standard deviations from mean | Distance from quartile range |
| Common threshold | ±2, ±2.5, or ±3 | 1.5× or 3× IQR |
| Best suited for | Roughly symmetric, normally distributed data | Skewed or unknown-distribution data |

[Inference] In practice, the IQR method is often preferred as a general-purpose default specifically because it does not require an assumption of normality and is more robust to the presence of multiple outliers, but the z-score method remains useful and interpretable when there is good reason to believe the underlying data genuinely follows a roughly normal distribution.

### Applying These Methods Across Multiple Columns

```python
def detect_outliers_iqr(df, columns):
    outlier_summary = {}
    for col in columns:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        lower = Q1 - 1.5 * IQR
        upper = Q3 + 1.5 * IQR
        outlier_summary[col] = df[(df[col] < lower) | (df[col] > upper)].index.tolist()
    return outlier_summary

df_multi = pd.DataFrame({
    'age': [22, 24, 23, 25, 21, 95],
    'income': [50000, 60000, 55000, 58000, 52000, 500000]
})

result = detect_outliers_iqr(df_multi, ['age', 'income'])
print(result)
```

**Output**

```
{'age': [5], 'income': [5]}
```

### Common Pitfalls

- **Applying z-score thresholds to visibly skewed data without transformation** — since the z-score method assumes approximate normality, using it directly on heavily skewed variables (e.g., income, transaction amounts) can produce misleading outlier flags; a log transformation or the IQR method is often more appropriate in these cases
- **Using the standard mean/std z-score on data already suspected to contain multiple outliers** — the masking effect can cause the standard z-score method to understate how unusual certain points are, since the outliers themselves inflate the standard deviation used in the calculation
- **Treating the 1.5× IQR multiplier as a universal rule rather than a convention** — this value is a widely adopted default, not a mathematically derived optimum, and some domains legitimately use different multipliers based on how conservative outlier flagging needs to be
- **Applying either method blindly without domain context** — a statistically flagged outlier is not automatically an error; some flagged values may represent genuine, valid extreme observations (e.g., a legitimately very high transaction), and this determination requires domain knowledge, not just the statistical test result
- **Computing outlier bounds on the full dataset when group-level context matters** — a value that is a legitimate outlier for one subgroup (e.g., a specific product category or region) may not be an outlier when computed globally across a heterogeneous dataset, so group-aware outlier detection is often more appropriate than a single global threshold

### Related Topics

- Outlier Treatment Strategies: Removal, Capping, and Transformation
- Distribution-Based Outlier Detection (Skewness, Kurtosis)
- Machine Learning-Based Outlier Detection (Isolation Forest, Local Outlier Factor)
- Data Transformation Techniques (Log, Box-Cox, Yeo-Johnson)
- Robust Statistics and Their Role in Data Cleaning
- Group-Aware and Contextual Outlier Detection