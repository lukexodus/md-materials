## Shifting, Lagging, and Lead Features

### Conceptual Overview

Shifting moves values in a time series forward or backward along the time axis without changing their order. In machine learning, this operation is the primary mechanism for constructing **lag features** (past values used to predict the present) and **lead features** (future values, typically used as prediction targets rather than inputs). These constructs allow tabular/ML models — which have no inherent sense of time order — to access temporal context explicitly.

The general form in Pandas is `.shift(periods)`, where a positive integer shifts data forward (creating lag features) and a negative integer shifts data backward (creating lead features).

### Shifting Fundamentals

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    'date': pd.date_range('2024-01-01', periods=6, freq='D'),
    'value': [10, 12, 15, 14, 18, 20]
})
df.set_index('date', inplace=True)

df['shift_pos1'] = df['value'].shift(1)   # lag by 1
df['shift_neg1'] = df['value'].shift(-1)  # lead by 1
print(df)
```

**Output**

```
            value  shift_pos1  shift_neg1
date
2024-01-01     10         NaN        12.0
2024-01-02     12        10.0        15.0
2024-01-03     15        12.0        14.0
2024-01-04     14        15.0        18.0
2024-01-05     18        14.0        20.0
2024-01-06     20        18.0         NaN
```

Shifting introduces `NaN` values at the boundaries — at the start for positive shifts, at the end for negative shifts — because there is no data to pull from outside the series range. Handling these `NaN`s (via dropping, imputing, or leaving them for a model that tolerates missing values) is a required downstream step.

### Lag Features

A lag feature represents a value from $t - k$ time steps ago, used as a predictor for the value at time $t$. Lag features are foundational in autoregressive-style ML models (e.g., tree-based models, linear regression with engineered features) that don't natively model sequence dependence the way RNNs or ARIMA do.

```python
for lag in [1, 2, 3]:
    df[f'lag_{lag}'] = df['value'].shift(lag)

print(df[['value', 'lag_1', 'lag_2', 'lag_3']])
```

**Output**

```
            value  lag_1  lag_2  lag_3
date
2024-01-01     10    NaN    NaN    NaN
2024-01-02     12   10.0    NaN    NaN
2024-01-03     15   12.0   10.0    NaN
2024-01-04     14   15.0   12.0   10.0
2024-01-05     18   14.0   15.0   12.0
2024-01-06     20   18.0   14.0   15.0
```

Multiple lag features at once (lag_1, lag_2, lag_3, ...) let a model implicitly learn short-term trend, momentum, or seasonality patterns, depending on the lag depth chosen relative to the data's periodicity.

### Lead Features

A lead feature represents a value from $t + k$ time steps in the future relative to the current row. Lead features are most commonly used to construct the **target variable** in supervised time series forecasting setups — i.e., "given features at time $t$, predict value at $t+k$."

```python
df['target_lead_1'] = df['value'].shift(-1)
print(df[['value', 'target_lead_1']])
```

**Output**

```
            value  target_lead_1
date
2024-01-01     10           12.0
2024-01-02     12           15.0
2024-01-03     15           14.0
2024-01-04     14           18.0
2024-01-05     18           20.0
2024-01-06     20            NaN
```

[Inference] Using lead features as prediction targets is a common convention in supervised forecasting frameworks, but the exact construction (single-step vs. multi-step horizon, direct vs. recursive strategy) varies by problem design and is not dictated by Pandas itself — Pandas only provides the shifting mechanism, not the forecasting methodology.

### Group-Wise Shifting

For panel/multi-entity time series (e.g., multiple stores, sensors, or users each with their own time axis), shifting must be scoped per group to avoid leaking values across entities. `groupby().shift()` handles this correctly.

```python
df2 = pd.DataFrame({
    'entity': ['A','A','A','B','B','B'],
    'date': pd.date_range('2024-01-01', periods=3).tolist() * 2,
    'value': [10, 12, 14, 100, 105, 108]
})

df2['lag_1'] = df2.groupby('entity')['value'].shift(1)
print(df2)
```

**Output**

```
  entity       date  value  lag_1
0      A 2024-01-01     10    NaN
1      A 2024-01-02     12   10.0
2      A 2024-01-03     14   12.0
3      B 2024-01-01    100    NaN
4      B 2024-01-02    105  100.0
5      B 2024-01-03    108  105.0
```

Without grouping, a naive `.shift(1)` on the concatenated frame would incorrectly pull entity B's first row from entity A's last row. This is a frequent and consequential bug in multi-entity time series pipelines.

### Shifting with Explicit Frequency (`freq` parameter)

When the index is a `DatetimeIndex`, `.shift()` accepts a `freq` argument that shifts the **index labels themselves** rather than the data values — effectively moving timestamps rather than reordering values relative to fixed positions.

```python
df3 = df[['value']].copy()
shifted_by_freq = df3.shift(1, freq='D')
print(shifted_by_freq)
```

**Output**

```
            value
date
2024-01-02     10
2024-01-03     12
2024-01-04     15
2024-01-05     14
2024-01-06     18
2024-01-07     20
```

Here no `NaN`s are introduced — the values are untouched, and only the date labels move forward by one day. This is distinct from positional shifting and is useful when re-aligning a series to a different reporting convention (e.g., converting "value recorded at start of period" to "value recorded at end of period").

### Lag/Lead with Irregular Time Series

For series with irregular or missing timestamps, a plain positional `.shift(k)` does not correspond to "k time units ago" — it corresponds to "k rows ago," which can be misleading if rows are unevenly spaced.

```python
irregular = pd.DataFrame({
    'date': pd.to_datetime(['2024-01-01','2024-01-02','2024-01-05','2024-01-06']),
    'value': [10, 12, 20, 22]
}).set_index('date')

irregular['lag_1_positional'] = irregular['value'].shift(1)
irregular_resampled = irregular['value'].asfreq('D').shift(1)
print(irregular['lag_1_positional'])
print(irregular_resampled)
```

**Output**

```
date
2024-01-01     NaN
2024-01-02    10.0
2024-01-05    12.0
2024-01-06    20.0
Name: lag_1_positional, dtype: float64

date
2024-01-01     NaN
2024-01-02    10.0
2024-01-03     NaN
2024-01-04     NaN
2024-01-05     NaN
2024-01-06    20.0
Freq: 2024-01-06    20.0
Freq: D, Name: value, dtype: float64
```

**Key Points**

- Reindexing to a regular frequency with `.asfreq()` before shifting exposes gaps honestly (as `NaN`), whereas positional shifting on irregular data silently conflates "1 day ago" with "3 days ago."
- [Inference] For most supervised ML feature pipelines, resampling to a fixed frequency prior to lagging is the safer default, though the correct choice depends on whether the modeling task requires calendar-accurate lags or simply "previous observed value," which is a domain-specific judgment call not fixed by any single library behavior.

### Diff as a Related Operation

`.diff()` is implemented internally using shift-based subtraction and is commonly paired with lag features to construct rate-of-change or momentum features.

$$
\text{diff}_t = x_t - x_{t-k}
$$

```python
df['diff_1'] = df['value'].diff(1)  # equivalent to df['value'] - df['value'].shift(1)
print(df[['value','diff_1']])
```

**Output**

```
            value  diff_1
date
2024-01-01     10     NaN
2024-01-02     12     2.0
2024-01-03     15     3.0
2024-01-04     14    -1.0
2024-01-05     18     4.0
2024-01-06     20     2.0
```

### Data Leakage Considerations

Constructing lag/lead features carelessly is one of the most common sources of **target leakage** in time series ML pipelines:

- Using `shift(-k)` (a lead feature) as an *input* feature rather than a target directly exposes future information to the model, producing inflated validation metrics that do not hold at inference time.
- Computing rolling statistics (mean, std) on a window that includes the current or future row before shifting also leaks information; the shift should generally be applied before or in conjunction with the rolling window, not after, depending on the intended feature definition.
- Train/test splitting for time series must respect chronological order; shifted features computed across a split boundary using future fold data constitute leakage even if the shift itself is correctly directioned.

[Unverified] The specific numerical impact of leakage on any given model's performance (e.g., how much validation accuracy is inflated) is dataset- and model-dependent and cannot be stated as a general quantity.

### Diagram: Lag/Lead Relationship to Present Time Step

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 260" font-family="sans-serif">
  <text x="360" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Lag and Lead Features Relative to Time t (svg_diagram)</text>

  <line x1="60" y1="140" x2="660" y2="140" stroke="#888" stroke-width="2" />
  <polygon points="660,140 650,134 650,146" fill="#888" />

  <circle cx="150" cy="140" r="8" fill="#4C72B0" />
  <circle cx="270" cy="140" r="8" fill="#4C72B0" />
  <circle cx="390" cy="140" r="10" fill="#C44E52" />
  <circle cx="510" cy="140" r="8" fill="#55A868" />
  <circle cx="630" cy="140" r="8" fill="#55A868" />

  <text x="150" y="170" text-anchor="middle" font-size="12" fill="#333">t-2</text>
  <text x="270" y="170" text-anchor="middle" font-size="12" fill="#333">t-1</text>
  <text x="390" y="175" text-anchor="middle" font-size="13" font-weight="bold" fill="#333">t (present)</text>
  <text x="510" y="170" text-anchor="middle" font-size="12" fill="#333">t+1</text>
  <text x="630" y="170" text-anchor="middle" font-size="12" fill="#333">t+2</text>

  <text x="150" y="115" text-anchor="middle" font-size="11" fill="#4C72B0">lag_2</text>
  <text x="270" y="115" text-anchor="middle" font-size="11" fill="#4C72B0">lag_1</text>
  <text x="510" y="115" text-anchor="middle" font-size="11" fill="#55A868">lead_1</text>
  <text x="630" y="115" text-anchor="middle" font-size="11" fill="#55A868">lead_2</text>

  <rect x="60" y="200" width="14" height="14" fill="#4C72B0" />
  <text x="80" y="212" font-size="12" fill="#333">Lag features (shift positive) — inputs</text>

  <rect x="60" y="222" width="14" height="14" fill="#C44E52" />
  <text x="80" y="234" font-size="12" fill="#333">Current observation (t)</text>

  <rect x="380" y="200" width="14" height="14" fill="#55A868" />
  <text x="400" y="212" font-size="12" fill="#333">Lead features (shift negative) — typically targets</text>
</svg>

### Common Pitfalls Summary

- Forgetting to group before shifting on panel/multi-entity data, causing cross-entity leakage.
- Using lead-shifted columns as model inputs instead of as targets, causing look-ahead bias.
- Applying positional `.shift()` on irregular timestamps without first resampling, producing lags that don't correspond to a fixed real-world time interval.
- Leaving boundary `NaN`s unhandled, which can silently reduce the effective training set size or cause errors in models that don't accept missing values.
- Not accounting for shifted-column `NaN`s when doing a chronological train/test split, since the first `k` rows of any lagged feature set are systematically incomplete.

**Related Topics**

- Rolling and expanding window statistics (rolling mean, rolling std) combined with lag features
- Resampling and frequency conversion (`asfreq`, `resample`) for irregular time series
- Time-based train/test splitting and walk-forward validation
- Seasonal decomposition and differencing for stationarity
- Autocorrelation (ACF) and partial autocorrelation (PACF) for choosing lag depth
- Feature engineering for multi-horizon forecasting (direct vs. recursive strategies)
- Handling missing timestamps and irregular sampling intervals in Pandas