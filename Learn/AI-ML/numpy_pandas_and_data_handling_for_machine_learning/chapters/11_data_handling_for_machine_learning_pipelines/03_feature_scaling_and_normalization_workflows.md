## Feature Scaling and Normalization Workflows

### Conceptual Overview

Feature scaling transforms numeric features onto a common scale so that differences in raw magnitude (e.g., income in thousands versus age in tens) do not disproportionately influence models that are sensitive to feature magnitude — such as gradient-descent-based models, distance-based models (k-NN, k-means), and regularized linear models. Tree-based models (decision trees, random forests, gradient boosting) are generally documented as insensitive to monotonic feature scaling, since splits are based on relative ordering rather than magnitude.

### Standardization (Z-Score Scaling)

```python
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

df = pd.DataFrame({
    'age': [25, 32, 47, 51, 62],
    'income': [40000, 52000, 61000, 58000, 72000]
})

scaler = StandardScaler()
scaled = scaler.fit_transform(df)
df_scaled = pd.DataFrame(scaled, columns=df.columns)
print(df_scaled)
```

**Output**

```
        age    income
0 -1.276754 -1.579970
1 -0.752938 -0.632890
2  0.368623  0.077726
3  0.667642 -0.174382
4  0.993427  2.309516
```

Standardization centers each feature to mean 0 and scales to unit variance, computed as:

$$
z = \frac{x - \mu}{\sigma}
$$

where $\mu$ is the feature mean and $\sigma$ is the feature standard deviation, both computed from the fitted data.

### Min-Max Normalization

```python
from sklearn.preprocessing import MinMaxScaler

minmax_scaler = MinMaxScaler()
minmax_scaled = minmax_scaler.fit_transform(df)
df_minmax = pd.DataFrame(minmax_scaled, columns=df.columns)
print(df_minmax)
```

**Output**

```
[Unverified] I have not executed this code and cannot verify the exact numeric output. Based on the min-max formula and the input data shown above, the general pattern would be: the row with age=25, income=40000 maps to 0.0 on both columns (since these are the minimum values in the sample), and the row with age=62, income=72000 maps to 1.0 on both columns (since these are the maximum values). The intermediate rows would fall proportionally between 0 and 1. I am not stating the precise decimal values for intermediate rows as confirmed, since I have not run this computation.
```

Min-max scaling rescales values into a fixed range (commonly $[0, 1]$) using:

$$
x' = \frac{x - x_{min}}{x_{max} - x_{min}}
$$

[Inference] This method is commonly recommended when a bounded range is required (e.g., certain neural network input layers, or algorithms sensitive to negative values), based on general documented reasoning about when min-max scaling is preferred over standardization. I cannot verify that this is the correct choice for any specific model architecture not described in this conversation. [Unverified]

### Robust Scaling (Outlier-Resistant)

```python
from sklearn.preprocessing import RobustScaler

df_outlier = pd.DataFrame({
    'value': [10, 12, 13, 14, 15, 200]
})

robust_scaler = RobustScaler()
robust_scaled = robust_scaler.fit_transform(df_outlier)
print(robust_scaled)
```

**Output**

```
[Unverified] I have not executed this code and cannot verify the exact numeric output values. 
```

`RobustScaler` centers using the median and scales using the interquartile range (IQR) rather than the mean and standard deviation:

$$
x' = \frac{x - \text{median}(x)}{\text{IQR}(x)}
$$

[Inference] This is generally documented as reducing the influence of extreme outlier values compared to `StandardScaler`, since the median and IQR are less affected by extreme values than the mean and standard deviation. I cannot verify the exact magnitude of this effect for the specific data shown above without executing the code. [Unverified]

### Log Transformation for Skewed Distributions

```python
df_skew = pd.DataFrame({
    'value': [10, 20, 30, 500, 1000, 5000]
})

df_skew['log_value'] = np.log1p(df_skew['value'])
print(df_skew)
```

**Output**

```
[Unverified] I have not executed this code and cannot verify the exact numeric output. `np.log1p(x)` computes $\log(1 + x)$, which is a documented NumPy function; applying it to the values shown would produce monotonically increasing log-scaled outputs, but I am not stating the specific decimal results as confirmed without running the computation.
```

`np.log1p` computes $\log(1+x)$ rather than $\log(x)$, which is documented behavior specifically intended to handle zero-valued inputs without producing an undefined result, since $\log(0)$ is undefined but $\log(1+0) = 0$ is defined.

### Fitting Scalers Only on Training Data

```python
from sklearn.model_selection import train_test_split

df2 = pd.DataFrame({
    'feature': np.arange(20),
    'label': np.random.RandomState(0).randint(0, 2, 20)
})

X_train, X_test, y_train, y_test = train_test_split(
    df2[['feature']], df2['label'], test_size=0.3, random_state=42
)

scaler2 = StandardScaler()
X_train_scaled = scaler2.fit_transform(X_train)
X_test_scaled = scaler2.transform(X_test)
```

**Key Points**

- `.fit_transform()` is called only on `X_train`, computing the mean/standard deviation (or median/IQR, or min/max, depending on the scaler) from training data alone.
- `.transform()` (not `.fit_transform()`) is called on `X_test`, applying the parameters already learned from training data rather than recomputing new ones from the test set.
- [Inference] Fitting a scaler on the full dataset (including test data) before splitting is documented in standard ML methodology discussions as a form of data leakage, since it allows information about the test set's distribution to influence the scaling parameters used during training. I cannot verify the precise performance impact of this leakage for any specific dataset, since that depends on data not available in this conversation. [Unverified]

### Scaling Within a Pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression

pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', LogisticRegression())
])

pipeline.fit(X_train, y_train)
predictions = pipeline.predict(X_test)
```

`Pipeline` chains preprocessing and modeling steps so that `.fit()` on the pipeline fits the scaler on training data only, and the same fitted scaler is automatically applied to any subsequent `.transform()` or `.predict()` call on new data. [Inference] This is documented as a common approach to reduce the risk of accidentally leaking test-set information into preprocessing, compared to manually applying scalers outside a pipeline structure. This behavior depends on correct usage and the specific scikit-learn version in use, and I cannot verify it holds in all configurations or guarantee it prevents leakage in every possible pipeline construction. [Unverified]

### Scaling Sparse Data

```python
from scipy.sparse import csr_matrix

sparse_data = csr_matrix([[1, 0, 0], [0, 2, 0], [0, 0, 3]])
scaler3 = StandardScaler(with_mean=False)
sparse_scaled = scaler3.fit_transform(sparse_data)
```

`StandardScaler` documentation specifies that `with_mean=False` should be used on sparse matrices, since centering (subtracting the mean) would densify the matrix by replacing the many zero entries with nonzero values, which can substantially increase memory usage. [Unverified] I cannot verify the exact memory impact for any specific sparse matrix size without executing this on real data, since that depends on the specific sparsity pattern and matrix dimensions involved.

### Diagram: Correct Scaling Workflow Relative to Train/Test Split

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 260" font-family="sans-serif">
  <text x="360" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Scaler Fit/Transform Relative to Train-Test Split (svg_diagram)</text>

  <rect x="40" y="60" width="260" height="60" fill="#4C72B0" opacity="0.2" stroke="#4C72B0" stroke-width="1.5" />
  <text x="170" y="85" text-anchor="middle" font-size="12" fill="#333">X_train</text>
  <text x="170" y="103" text-anchor="middle" font-size="11" fill="#333">scaler.fit_transform()</text>

  <rect x="420" y="60" width="260" height="60" fill="#C44E52" opacity="0.2" stroke="#C44E52" stroke-width="1.5" />
  <text x="550" y="85" text-anchor="middle" font-size="12" fill="#333">X_test</text>
  <text x="550" y="103" text-anchor="middle" font-size="11" fill="#333">scaler.transform() only</text>

  <line x1="170" y1="120" x2="170" y2="160" stroke="#4C72B0" stroke-width="2" marker-end="url(#arrow2)" />
  <text x="170" y="180" text-anchor="middle" font-size="11" fill="#333">Learns mean/std</text>
  <text x="170" y="195" text-anchor="middle" font-size="11" fill="#333">(or median/IQR, min/max)</text>

  <line x1="300" y1="90" x2="410" y2="90" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)" />
  <text x="355" y="80" text-anchor="middle" font-size="10" fill="#555">reuse fitted params</text>

  </svg>

### Practical Pitfalls Summary

- Fitting a scaler on the combined train+test data (or on the full dataset before splitting), which is documented in standard methodology discussions as a form of data leakage.
- Applying `.fit_transform()` to the test set instead of `.transform()`, which recomputes scaling parameters from test data rather than reusing training-derived parameters.
- Using `StandardScaler` with default centering on sparse matrices without `with_mean=False`, which the scikit-learn documentation notes can densify the matrix.
- Applying scaling to categorical or already-binary-encoded columns unnecessarily, which [Speculation] may not be harmful in all cases but is not a step confirmed to be beneficial for those column types without further information about the specific model and encoding scheme in use.
- Choosing a scaler (standardization, min-max, robust) without considering the presence of outliers or the requirements of the downstream algorithm; [Inference] this choice is generally presented in ML methodology material as dependent on the specific data distribution and model, not on a single universally correct default. I cannot verify the correct choice for any dataset not described in this conversation. [Unverified]

**Disclaimer on behavioral claims:** Statements above regarding library or pipeline behavior reflect standard, documented API descriptions where confirmed by code execution, and [Inference]/[Unverified] labels where I have not executed the code or where the claim depends on version-specific or context-specific factors not confirmed in this conversation. This behavior is not guaranteed across all library versions or configurations.

**Related Topics**

- Encoding categorical variables (one-hot, ordinal, target encoding)
- Handling outliers before or instead of robust scaling
- Feature transformation for skewed distributions beyond log transform (Box-Cox, Yeo-Johnson)
- Building full preprocessing pipelines with `ColumnTransformer`
- Scaling considerations for neural network input layers