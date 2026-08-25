## Imputation Strategies for Numerical and Categorical Data

### Overview

Imputation replaces missing values with estimated substitutes so that downstream analysis or model training can proceed without discarding incomplete rows entirely. Strategy choice differs meaningfully between numerical and categorical data, since the two have different notions of "central tendency" and different sensitivity to distortion.

### Basic Numerical Imputation Strategies

**Mean imputation:**

```python
df["age"] = df["age"].fillna(df["age"].mean())
```

**Median imputation:**

```python
df["income"] = df["income"].fillna(df["income"].median())
```

**Key Points**
- Mean imputation is sensitive to outliers, since the mean itself shifts with extreme values.
- Median imputation is more robust to skewed distributions and outliers, since the median depends only on rank order, not magnitude.
- [Inference] Median is commonly preferred over mean for skewed numerical features in general statistical practice, based on the median's documented robustness to outliers — this is a general property of the statistic, not a claim benchmarked on any specific dataset here.

**Constant-value imputation:**

```python
df["score"] = df["score"].fillna(0)
```

Using a constant is sometimes used deliberately when the missingness itself has meaning that a fixed sentinel is meant to preserve — see the flagging approach below.

### Basic Categorical Imputation Strategies

**Mode (most frequent value) imputation:**

```python
df["category"] = df["category"].fillna(df["category"].mode()[0])
```

`mode()` returns a Series (there can be multiple values tied for most frequent), so `[0]` selects the first.

**Constant-label imputation:**

```python
df["category"] = df["category"].fillna("Missing")
```

Introducing an explicit `"Missing"` category rather than imputing with the mode preserves the fact that a value was absent, which the mode-fill approach discards.

[Speculation] Whether an explicit "Missing" label or mode-imputation is preferable for a specific categorical feature depends on whether missingness itself is informative for the target variable — I don't have enough context about any specific dataset or task to state a general preference here.

### Using scikit-learn's `SimpleImputer`

```python
from sklearn.impute import SimpleImputer
import pandas as pd

num_imputer = SimpleImputer(strategy="median")
df[["age", "income"]] = num_imputer.fit_transform(df[["age", "income"]])

cat_imputer = SimpleImputer(strategy="most_frequent")
df[["category"]] = cat_imputer.fit_transform(df[["category"]])
```

`SimpleImputer` supports `strategy` values of `"mean"`, `"median"`, `"most_frequent"`, and `"constant"` (with `fill_value` specified separately for the constant case).

**Key Points**
- `fit_transform()` on training data learns the fill value (e.g., the mean) from that data; applying the *same* fitted imputer's `transform()` to test data (not re-fitting) avoids leaking test-set statistics into the imputation, which is a widely documented data leakage concern in ML preprocessing.

```python
num_imputer.fit(X_train[["age", "income"]])
X_train[["age", "income"]] = num_imputer.transform(X_train[["age", "income"]])
X_test[["age", "income"]] = num_imputer.transform(X_test[["age", "income"]])
```

### Group-Based Imputation

Filling missing values based on group membership often preserves more structure than a single global statistic:

```python
df["income"] = df.groupby("region")["income"].transform(
    lambda x: x.fillna(x.mean())
)
```

This fills missing `income` values using the mean *within each region*, rather than the overall dataset mean.

[Inference] Group-based imputation is commonly considered more accurate than global imputation when the feature's distribution genuinely differs across groups, since it uses more locally relevant information — this is a general statistical rationale, not a claim tested on a specific dataset here.

### K-Nearest Neighbors Imputation

```python
from sklearn.impute import KNNImputer

knn_imputer = KNNImputer(n_neighbors=5)
df_imputed = pd.DataFrame(
    knn_imputer.fit_transform(df[["age", "income", "score"]]),
    columns=["age", "income", "score"]
)
```

`KNNImputer` fills missing values using the average of the `n_neighbors` most similar rows, based on distance computed over the other available features.

**Key Points**
- Requires numerical input; categorical columns typically need encoding first.
- [Unverified] The exact distance metric and handling of missing values *within* the distance calculation itself (i.e., how the algorithm handles a neighbor that also has a missing value in a relevant feature) is implementation detail I do not have a confirmed, current description of without checking documentation for the specific scikit-learn version in use.

### Iterative (Model-Based) Imputation

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

iter_imputer = IterativeImputer(random_state=0)
df_imputed = pd.DataFrame(
    iter_imputer.fit_transform(df[["age", "income", "score"]]),
    columns=["age", "income", "score"]
)
```

`IterativeImputer` models each feature with missing values as a function of the other features, iterating until estimates stabilize — conceptually similar to Multiple Imputation by Chained Equations (MICE).

**Key Points**
- The `sklearn.experimental` import requirement reflects this class's status as an experimental API. [Unverified] Whether it remains marked experimental in the current scikit-learn release is not something I can confirm without checking documentation for that specific version.
- Model-based imputation captures relationships between features that simple mean/median imputation cannot, since it explicitly conditions on other columns rather than treating each column independently.

### Flagging Imputed Values

A widely used complementary practice is adding a binary indicator column marking which values were imputed, so the information "this value was originally missing" is not silently discarded:

```python
df["income_was_missing"] = df["income"].isna().astype(int)
df["income"] = df["income"].fillna(df["income"].median())
```

[Inference] This pattern is commonly recommended in ML preprocessing guidance on the reasoning that missingness itself can carry predictive signal that a filled value alone would erase — this reflects general preprocessing guidance rather than a claim about any specific dataset's target relationship.

### Comparison of Strategies

| Strategy | Data type | Sensitivity to outliers | Preserves feature relationships |
|---|---|---|---|
| Mean | Numerical | High | No |
| Median | Numerical | Low | No |
| Mode | Categorical | N/A | No |
| Constant/"Missing" label | Either | N/A | No (but preserves missingness signal) |
| Group-based | Either | Depends on group homogeneity | Partial |
| KNN | Numerical (mainly) | Moderate | Yes (local) |
| Iterative/model-based | Numerical (mainly) | Depends on underlying model | Yes (global) |

[Inference] This comparison reflects commonly cited tradeoffs in general ML preprocessing literature; actual performance impact of any strategy depends on the specific dataset, missingness mechanism, and downstream model, which I have not tested here.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| Data leakage | Fitting imputer statistics on the full dataset before train/test split |
| Distorted distributions | Mean imputation on heavily skewed or outlier-prone numerical data |
| Lost missingness signal | Imputing without an accompanying "was missing" indicator when missingness is informative |
| Categorical imputation bias | Mode imputation artificially inflating the already-most-common category, especially with high missingness rates |

### Diagram: Imputation Strategy Selection

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 280">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Imputation Strategy by Data Type (svg_diagram)</text>

  <rect x="300" y="45" width="160" height="45" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="380" y="72" text-anchor="middle" font-size="12">Missing value</text>

  <line x1="330" y1="90" x2="180" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow7)" />
  <line x1="430" y1="90" x2="580" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow7)" />

  <rect x="80" y="135" width="200" height="40" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="180" y="160" text-anchor="middle" font-size="11">Numerical</text>

  <rect x="480" y="135" width="200" height="40" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="580" y="160" text-anchor="middle" font-size="11">Categorical</text>

  <line x1="180" y1="175" x2="180" y2="200" stroke="#333" stroke-width="1" />
  <text x="180" y="215" text-anchor="middle" font-size="10" fill="#555">mean / median /</text>
  <text x="180" y="230" text-anchor="middle" font-size="10" fill="#555">KNN / iterative</text>

  <line x1="580" y1="175" x2="580" y2="200" stroke="#333" stroke-width="1" />
  <text x="580" y="215" text-anchor="middle" font-size="10" fill="#555">mode / constant</text>
  <text x="580" y="230" text-anchor="middle" font-size="10" fill="#555">label ("Missing")</text>

  </svg>

### Related Topics

- Multiple Imputation by Chained Equations (MICE) in depth
- Handling missing data specifically for time series (interpolation vs. imputation)
- Missing data mechanisms (MCAR/MAR/MNAR) and how they affect strategy choice
- Building imputation into a scikit-learn `Pipeline` to prevent train/test leakage automatically
- Evaluating imputation quality (e.g., via masked-value recovery experiments)
- Categorical encoding strategies after imputation (one-hot, target encoding)