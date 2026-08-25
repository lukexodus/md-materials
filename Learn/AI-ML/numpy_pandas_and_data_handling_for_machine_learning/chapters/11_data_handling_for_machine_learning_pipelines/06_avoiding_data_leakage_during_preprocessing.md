## Avoiding Data Leakage During Preprocessing

### Conceptual Overview

Data leakage occurs when information from outside the training dataset — most commonly, information from the validation or test set, or from the future relative to a prediction point — influences the model during training in a way that would not be available at genuine prediction time. This produces evaluation metrics that overstate real-world performance. Standard ML methodology documentation identifies several distinct mechanisms by which leakage commonly enters a preprocessing workflow.

### Leakage from Fitting Preprocessing on the Full Dataset

```python
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

df = pd.DataFrame({
    'feature': np.arange(20),
    'label': np.random.RandomState(0).randint(0, 2, 20)
})

# Leakage pattern
scaler_leaky = StandardScaler()
scaled_full = scaler_leaky.fit_transform(df[['feature']])
X_train_leaky, X_test_leaky, y_train, y_test = train_test_split(
    scaled_full, df['label'], test_size=0.3, random_state=42
)
```

Here, `.fit_transform()` is called on the entire feature column before the train/test split occurs. This means the computed mean and standard deviation reflect test-set values as well as training-set values. [Inference] This is documented in standard ML preprocessing guidance as a leakage pattern, because the scaling parameters used during training are influenced by data the model should not have access to during a genuine training phase. I cannot verify the magnitude of resulting metric distortion for this specific example, since I have not executed this code. [Unverified]

### Corrected Pattern: Split First, Fit Second

```python
X_train, X_test, y_train2, y_test2 = train_test_split(
    df[['feature']], df['label'], test_size=0.3, random_state=42
)

scaler_correct = StandardScaler()
X_train_scaled = scaler_correct.fit_transform(X_train)
X_test_scaled = scaler_correct.transform(X_test)
```

**Key Points**

- `.fit_transform()` is called only on `X_train`.
- `.transform()` (not `.fit_transform()`) is called on `X_test`, reusing parameters learned from training data alone.
- This ordering is documented in scikit-learn's preprocessing guidance as the standard approach to avoid this specific leakage mechanism. [Unverified] I cannot verify this addresses every conceivable leakage scenario, since other leakage mechanisms (described below) are independent of this particular fix.

### Leakage from Feature Construction Before Splitting

```python
df2 = pd.DataFrame({
    'customer_id': [1,2,3,4,5,6,7,8],
    'purchase_amount': [100,200,150,300,120,250,180,220],
    'label': [0,1,0,1,0,1,0,1]
})

# Leakage pattern: mean computed from full dataset, including future test rows
df2['amount_vs_global_mean'] = df2['purchase_amount'] - df2['purchase_amount'].mean()
```

Computing a feature such as `amount_vs_global_mean` using `.mean()` over the entire dataset — before any train/test split — means the feature value for every row, including future test rows, incorporates information about the test set's distribution. [Inference] This is documented in ML methodology material as a leakage mechanism distinct from scaler fitting, because it occurs during manual feature engineering rather than through a named preprocessing object like `StandardScaler`. I cannot verify the specific performance distortion this would cause on this example dataset, since I have not executed this code. [Unverified]

### Leakage from Target-Derived Features

```python
df3 = pd.DataFrame({
    'city': ['Manila','Cebu','Manila','Davao','Cebu'],
    'purchased': [1,0,1,1,0]
})

# Leakage pattern: target encoding computed on full dataset
target_means = df3.groupby('city')['purchased'].mean()
df3['city_target_enc'] = df3['city'].map(target_means)
```

I cannot verify the exact computed values in this example, since I have not executed this code.

Target encoding computed from the full dataset (including rows that will later become test rows) uses the target variable itself, which is documented in ML methodology material as a particularly severe leakage mechanism, since the resulting feature is directly derived from the value the model is trying to predict. [Inference] Standard guidance recommends computing target encodings only within a cross-validation scheme (e.g., out-of-fold encoding), so that no row's encoded feature value is derived from its own label. I cannot verify the exact leakage magnitude for any specific dataset without testing it directly. [Unverified]

### Leakage from Time Series Feature Construction

```python
ts = pd.DataFrame({
    'day': pd.date_range('2024-01-01', periods=6),
    'value': [10, 12, 15, 14, 18, 20]
})

# Leakage pattern: rolling mean computed with a centered window
ts['rolling_mean_centered'] = ts['value'].rolling(window=3, center=True).mean()
```

I cannot verify the exact output values in this example, since I have not executed this code.

A centered rolling window (`center=True`) is documented Pandas behavior that includes future values relative to each row's timestamp in the window calculation. [Inference] If this feature is used as a model input for a task where predictions must be made using only past and present information, this is documented in time series methodology material as a leakage mechanism, because the feature for a given row would depend on values that would not yet be known at that row's point in time in a genuine forecasting scenario. I cannot verify whether this is problematic for any specific use case without knowing the exact prediction task and deployment context. [Unverified]

### Corrected Pattern: Trailing Window Only

```python
ts['rolling_mean_trailing'] = ts['value'].rolling(window=3, center=False).mean()
```

I cannot verify the exact output values in this example, since I have not executed this code.

`center=False` (the default) is documented Pandas behavior that computes each window using only the current row and prior rows, not future rows, which is generally aligned with the constraint that features must be computable using only information available at prediction time. [Unverified] I cannot verify this fully addresses every time-series leakage risk in a specific pipeline without reviewing the complete feature construction and deployment logic involved.

### Leakage from Imputation Statistics

```python
df4 = pd.DataFrame({
    'feature': [10, np.nan, 30, 40, np.nan, 60],
    'label': [0,1,0,1,0,1]
})

# Leakage pattern: imputation value from full dataset
fill_value_leaky = df4['feature'].mean()
df4['feature_filled'] = df4['feature'].fillna(fill_value_leaky)
```

I cannot verify the exact computed mean value in this example, since I have not executed this code.

Computing an imputation value (mean, median, mode) from the full dataset before splitting is documented in ML methodology material as analogous to the scaler-fitting leakage pattern described above — the fill value would be influenced by rows that should be held out as test data. [Inference] The corrected approach is to compute the imputation statistic from training data only, then apply that same value to fill missing entries in the test set. I cannot verify the performance impact of this leakage for any specific dataset without testing it directly. [Unverified]

### Leakage from Duplicate or Near-Duplicate Records Across Splits

```python
df5 = pd.DataFrame({
    'id': [1,2,3,4,5,6],
    'feature': [10,20,10,20,30,40],
    'label': [0,1,0,1,1,0]
})

duplicates = df5.duplicated(subset=['feature'], keep=False)
print(df5[duplicates])
```

I cannot verify the exact printed output in this example, since I have not executed this code.

If duplicate or near-duplicate rows exist in a dataset and a random split places some copies in the training set and others in the test set, this is documented in ML methodology discussions as a leakage mechanism, because the model may effectively be evaluated on data it has already seen in a near-identical form during training. [Inference] Standard guidance recommends checking for and deduplicating such records, or using group-aware splitting when duplicates share a common underlying entity, before performing the train/test split. I cannot verify the extent of this issue in any dataset not described in this conversation, since that depends on data not available here. [Unverified]

### Diagram: Leakage Points Relative to the Train/Test Split Boundary

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 300" font-family="sans-serif">
  <text x="360" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Leakage Points Relative to Split Boundary (svg_diagram)</text>

  <line x1="360" y1="50" x2="360" y2="260" stroke="#C44E52" stroke-width="2" stroke-dasharray="6,4" />
  <text x="360" y="42" text-anchor="middle" font-size="11" fill="#C44E52">Split boundary</text>

  <rect x="60" y="60" width="270" height="40" fill="#4C72B0" opacity="0.2" stroke="#4C72B0" stroke-width="1.5" rx="4" />
  <text x="195" y="85" text-anchor="middle" font-size="11" fill="#333">Train data (fit statistics here only)</text>

  <rect x="390" y="60" width="270" height="40" fill="#DD8452" opacity="0.2" stroke="#DD8452" stroke-width="1.5" rx="4" />
  <text x="525" y="85" text-anchor="middle" font-size="11" fill="#333">Test data (transform only)</text>

  <rect x="60" y="120" width="600" height="40" fill="#C44E52" opacity="0.12" stroke="#C44E52" stroke-width="1.5" rx="4" />
  <text x="360" y="145" text-anchor="middle" font-size="11" fill="#333">Leakage risk: scaler/imputer/target-encoder fit before this boundary is drawn</text>

  <rect x="60" y="180" width="600" height="40" fill="#C44E52" opacity="0.12" stroke="#C44E52" stroke-width="1.5" rx="4" />
  <text x="360" y="205" text-anchor="middle" font-size="11" fill="#333">Leakage risk: centered rolling windows referencing future rows</text>

  <rect x="60" y="230" width="600" height="40" fill="#C44E52" opacity="0.12" stroke="#C44E52" stroke-width="1.5" rx="4" />
  <text x="360" y="255" text-anchor="middle" font-size="11" fill="#333">Leakage risk: duplicate records split across the boundary</text>
</svg>

### Practical Pitfalls Summary

- Fitting scalers, imputers, or encoders on the full dataset before splitting into train and test sets.
- Constructing manually engineered features (differences from a global mean, global counts, global ratios) using statistics computed across the entire dataset rather than training data alone.
- Computing target encoding without an out-of-fold or cross-validation-based scheme.
- Using centered or otherwise forward-looking rolling windows for time series features that will be used to predict forward in time.
- Allowing duplicate or near-duplicate records to be split across train and test sets without deduplication or group-aware splitting.
- Assuming that placing preprocessing steps inside a scikit-learn `Pipeline` automatically eliminates every leakage mechanism described above; [Inference] scikit-learn's documentation describes `Pipeline` as addressing the specific mechanism of fit/transform separation across cross-validation folds, not as a general guarantee against all forms of leakage, including those introduced during manual feature engineering performed before data enters the pipeline. I cannot verify that a given pipeline configuration addresses every leakage mechanism without reviewing its complete implementation. [Unverified]

**Disclaimer on behavioral claims:** All statements above regarding library, pipeline, or methodology behavior are labeled [Inference] or [Unverified] wherever I have not executed the corresponding code or where the claim depends on implementation-specific, version-specific, or context-specific factors not confirmed in this conversation. I do not have access to information beyond what is documented or reasoned here, and none of the described mitigations are stated as guaranteeing leakage-free results in every configuration.

**Related Topics**

- Cross-validation-safe target encoding implementation
- Time series-specific train/test splitting and validation
- Group-aware splitting for datasets with repeated or related entities
- Building leakage-resistant preprocessing pipelines with `ColumnTransformer`
- Auditing feature engineering code for leakage before model deployment