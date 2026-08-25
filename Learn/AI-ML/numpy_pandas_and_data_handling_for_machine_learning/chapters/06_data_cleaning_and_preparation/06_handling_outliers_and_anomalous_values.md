## Handling Outliers and Anomalous Values

### Overview

Outliers are data points that deviate substantially from the rest of a distribution. Handling them well requires two separate judgments: whether a value is statistically extreme, and whether that extremity reflects an error, a rare-but-valid event, or something worth preserving as signal. Pandas and NumPy provide the computational tools for detection; deciding what to do with detected outliers is a domain-specific judgment call.

### Statistical Detection: Z-Score Method

```python
import numpy as np
import pandas as pd

df = pd.DataFrame({"value": [10, 12, 11, 13, 200, 9, 14, -150]})

mean = df["value"].mean()
std = df["value"].std()
df["z_score"] = (df["value"] - mean) / std

outliers = df[df["z_score"].abs() > 3]
```

The z-score expresses each value's distance from the mean in units of standard deviation:

$$z = \frac{x - \mu}{\sigma}$$

A common convention flags values with $|z| > 3$ as outliers, based on the property that under a normal distribution, roughly 99.7% of values fall within 3 standard deviations of the mean.

**Key Points**
- The z-score method assumes an approximately normal distribution; [Inference] on heavily skewed data, this assumption is commonly noted as unreliable, since the mean and standard deviation themselves become distorted by the same outliers being detected — this reflects a well-documented limitation of the method's underlying assumption, not a claim tested on this specific dataset.
- The threshold of 3 is a convention, not a fixed rule; [Speculation] the appropriate threshold for a given dataset depends on domain context and how conservative the detection needs to be, and I don't have enough information about a specific use case to recommend a universal value.

### Statistical Detection: IQR (Interquartile Range) Method

```python
Q1 = df["value"].quantile(0.25)
Q3 = df["value"].quantile(0.75)
IQR = Q3 - Q1

lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR

outliers = df[(df["value"] < lower_bound) | (df["value"] > upper_bound)]
```

The IQR method identifies outliers based on the spread of the middle 50% of the data, rather than the mean/standard deviation, making it less sensitive to the extreme values it's trying to detect.

**Key Points**
- The `1.5 × IQR` multiplier is the conventional threshold used in box-plot outlier detection (as popularized by Tukey's original formulation); a multiplier of `3` is sometimes used for a more conservative ("extreme outlier only") threshold.
- [Inference] IQR-based detection is commonly described as more robust than z-score detection for skewed distributions, since quartiles are less influenced by extreme values than the mean is — this is a general property of the statistics involved, not a benchmarked comparison on this specific data.

### Visualizing Outliers

```python
df.boxplot(column="value")
```

Box plots visually represent the IQR method's logic directly — the box spans Q1 to Q3, whiskers extend to the bounds, and points beyond the whiskers are plotted individually as candidate outliers.

```python
import matplotlib.pyplot as plt

plt.scatter(range(len(df)), df["value"])
plt.axhline(upper_bound, color="red", linestyle="--")
plt.axhline(lower_bound, color="red", linestyle="--")
plt.show()
```

### Multivariate Outlier Detection

Univariate methods (z-score, IQR) examine one column at a time and can miss outliers that are only unusual in combination with other features. Mahalanobis distance accounts for correlations between features:

```python
from scipy.spatial.distance import mahalanobis
import numpy as np

data = df[["feature1", "feature2"]].values
cov = np.cov(data, rowvar=False)
inv_cov = np.linalg.inv(cov)
mean_vec = data.mean(axis=0)

distances = [mahalanobis(row, mean_vec, inv_cov) for row in data]
df["mahalanobis_dist"] = distances
```

$$D_M(x) = \sqrt{(x - \mu)^T \Sigma^{-1} (x - \mu)}$$

**Key Points**
- Mahalanobis distance measures how many "standard deviations" a point is from the mean, accounting for the covariance structure between features, unlike Euclidean distance which treats all dimensions independently.
- [Unverified] The appropriate distance threshold for flagging multivariate outliers depends on the number of features and desired sensitivity (often related to the chi-squared distribution for a formal statistical test), and I do not have a general threshold to recommend without more context about the specific application.

### Model-Based Detection: Isolation Forest

```python
from sklearn.ensemble import IsolationForest

iso = IsolationForest(contamination=0.05, random_state=0)
df["is_outlier"] = iso.fit_predict(df[["feature1", "feature2"]])
```

`IsolationForest` flags outliers based on how easily a point can be "isolated" from the rest of the data using random partitioning — outliers, being less similar to surrounding points, tend to be isolated in fewer partitioning steps.

**Key Points**
- The `contamination` parameter is an estimate of the expected proportion of outliers in the data, used to set the decision threshold; it is a user-supplied assumption, not something the algorithm derives independently.
- `fit_predict()` returns `-1` for detected outliers and `1` for inliers.

### Handling Detected Outliers: Removal

```python
df_clean = df[df["z_score"].abs() <= 3]
```

Removing outlier rows discards them from subsequent analysis entirely. [Speculation] Whether removal is appropriate depends on whether the outliers represent data errors versus legitimate rare events relevant to the analysis goal — I don't have enough context about the source or meaning of outliers in any specific dataset to recommend removal generally.

### Handling Detected Outliers: Capping (Winsorization)

```python
df["value_capped"] = df["value"].clip(lower=lower_bound, upper=upper_bound)
```

`clip()` replaces values outside the given bounds with the bound value itself, rather than removing the row — a technique commonly referred to as winsorization.

**Key Points**
- Capping preserves row count and avoids losing information from other columns in the same row, at the cost of distorting the true value of the capped observations.

### Handling Detected Outliers: Transformation

```python
df["value_log"] = np.log1p(df["value"])
```

Log transformation compresses the scale of large values relative to small ones, reducing the influence of extreme values without removing or altering them as directly as capping does. `log1p` (log of 1 + x) handles zero values gracefully, since $\log(0)$ is undefined.

[Inference] Log transformation is commonly applied to right-skewed distributions with large positive outliers, based on this being a widely documented technique for stabilizing variance and reducing skew — whether it's appropriate for a specific feature depends on the data's actual distribution and whether negative or zero values are present, which requires checking the specific column.

### Handling Detected Outliers: Flagging Instead of Modifying

```python
df["is_outlier_flag"] = (df["z_score"].abs() > 3).astype(int)
```

As with missing-data handling, adding an indicator column preserves the information that a value was flagged as extreme, without directly altering the original value — leaving the modeling process to use or ignore that signal explicitly.

### Comparison of Detection Methods

| Method | Assumes normality | Handles multivariate | Sensitive to existing outliers |
|---|---|---|---|
| Z-score | Yes | No | High (mean/std distorted by outliers) |
| IQR | No | No | Low (quartile-based) |
| Mahalanobis distance | Approximately | Yes | Moderate |
| Isolation Forest | No | Yes | Low (structural, not distributional) |

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| Legitimate rare events removed as "errors" | Outlier removal applied without domain investigation into why values are extreme |
| Distorted mean/std used for z-score | Z-score computed on data that already contains extreme outliers, which skew the very statistics used to detect them |
| Over-aggressive capping | Bounds set too tight, distorting a substantial portion of the legitimate distribution |
| Outlier handling before train/test split | Statistics (e.g., IQR bounds, `contamination` fitting) computed on the full dataset, leaking test-set information into preprocessing decisions |

### Diagram: Outlier Detection and Handling Workflow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 280">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Outlier Detection and Handling Workflow (svg_diagram)</text>

  <rect x="300" y="45" width="160" height="45" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="380" y="72" text-anchor="middle" font-size="11">Detect candidates</text>

  <line x1="330" y1="90" x2="150" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow11)" />
  <line x1="380" y1="90" x2="380" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow11)" />
  <line x1="430" y1="90" x2="610" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow11)" />

  <rect x="60" y="135" width="180" height="40" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="150" y="159" text-anchor="middle" font-size="10">Z-score / IQR</text>

  <rect x="290" y="135" width="180" height="40" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="380" y="159" text-anchor="middle" font-size="10">Mahalanobis / Isolation Forest</text>

  <rect x="520" y="135" width="180" height="40" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="610" y="159" text-anchor="middle" font-size="10">Domain review</text>

  <line x1="150" y1="175" x2="150" y2="200" stroke="#333" stroke-width="1" marker-end="url(#arrow11)" />
  <line x1="380" y1="175" x2="380" y2="200" stroke="#333" stroke-width="1" marker-end="url(#arrow11)" />
  <line x1="610" y1="175" x2="610" y2="200" stroke="#333" stroke-width="1" marker-end="url(#arrow11)" />

  <text x="150" y="220" text-anchor="middle" font-size="10" fill="#555">Remove</text>
  <text x="380" y="220" text-anchor="middle" font-size="10" fill="#555">Cap / transform</text>
  <text x="610" y="220" text-anchor="middle" font-size="10" fill="#555">Flag only</text>

  </svg>

### Related Topics

- Robust scaling techniques (RobustScaler) as an alternative to outlier removal for model training
- Domain-specific anomaly detection (fraud detection, sensor data, time series spikes)
- One-Class SVM as an alternative model-based outlier detection method
- Outlier handling within cross-validation pipelines to prevent leakage
- Distinguishing outliers from legitimate heavy-tailed distributions (e.g., income, city population)
- Statistical tests for outlier significance (Grubbs' test, Dixon's Q test)