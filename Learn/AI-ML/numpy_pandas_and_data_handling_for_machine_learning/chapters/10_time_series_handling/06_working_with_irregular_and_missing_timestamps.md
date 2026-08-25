## Handling Irregular and Missing Timestamps

### Conceptual Overview

Irregular time series occur when observations are not spaced at a fixed, predictable interval — for example, sensor readings that fire only on events, financial trades that occur at arbitrary times, or logs with gaps due to outages. This differs from a "missing value" problem in a regular series (where the timestamp slot exists but the value is `NaN`); here, the *timestamp itself* may not exist in the record at all. Distinguishing these two cases is a foundational step before applying most time-series ML techniques, since resampling, lagging, and windowing functions generally assume an evenly spaced index unless explicitly told otherwise.

### Detecting Irregularity

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    'timestamp': pd.to_datetime([
        '2024-01-01 00:00', '2024-01-01 01:00',
        '2024-01-01 04:00', '2024-01-01 05:00',
        '2024-01-01 05:30'
    ]),
    'value': [10, 12, 15, 14, 13]
}).set_index('timestamp')

diffs = df.index.to_series().diff()
print(diffs)
```

**Output**

```
timestamp
2024-01-01 00:00:00              NaT
2024-01-01 01:00:00    0 days 01:00:00
2024-01-01 04:00:00    0 days 03:00:00
2024-01-01 05:00:00    0 days 01:00:00
2024-01-01 05:30:00    0 days 00:30:00
Name: timestamp, dtype: timedelta64[ns]
```

Inspecting the distribution of consecutive timestamp differences (`.diff()` on the index) reveals whether spacing is constant. A single dominant interval with occasional outliers suggests mostly-regular data with gaps; a wide spread of differing intervals suggests genuinely irregular/event-driven data. `df.index.inferred_freq` can also be checked, but it returns `None` whenever the spacing isn't perfectly uniform, which is common in real-world irregular data.

### Reindexing to a Regular Frequency

`.asfreq()` or `.resample()` can impose a fixed frequency grid onto an irregular index, exposing missing slots explicitly as `NaN` rather than silently omitting them.

```python
regular = df.asfreq('H')
print(regular)
```

**Output**

```
                     value
timestamp
2024-01-01 00:00:00   10.0
2024-01-01 01:00:00   12.0
2024-01-01 02:00:00    NaN
2024-01-01 03:00:00    NaN
2024-01-01 04:00:00   15.0
2024-01-01 05:00:00   14.0
```

Note that `.asfreq('H')` drops the `05:30` observation entirely, since it does not align with the hourly grid. [Inference] Whether this loss of the off-grid observation is acceptable depends on the downstream use case — for hourly aggregate modeling it may be intended, but for point-event data it likely represents information loss. This is a judgment call specific to the dataset and task, not something the library determines automatically.

### Distinguishing Missing Timestamps from Missing Values

- **Missing timestamp**: the row itself is absent from the raw data (as with the `02:00`/`03:00` gap above before reindexing).
- **Missing value**: the timestamp exists as a row, but the value field is `NaN` (e.g., a sensor logged a heartbeat but failed to record a reading).

```python
df2 = pd.DataFrame({
    'timestamp': pd.date_range('2024-01-01', periods=5, freq='H'),
    'value': [10, np.nan, 15, np.nan, 13]
})
print(df2)
```

**Output**

```
            timestamp  value
0 2024-01-01 00:00:00   10.0
1 2024-01-01 01:00:00    NaN
2 2024-01-01 02:00:00   15.0
3 2024-01-01 03:00:00    NaN
4 2024-01-01 04:00:00   13.0
```

**Key Points**

- Reindexing (via `asfreq`/`resample`) converts "missing timestamp" problems into "missing value" problems, at which point standard imputation techniques (`fillna`, `interpolate`) apply.
- Treating the two cases identically without first reindexing can misrepresent the true sampling gaps in the data, since a naive `.shift()` or rolling window over an un-reindexed irregular series computes "k rows back," not "k time units back."

### Imputation Strategies for Missing Values

```python
df2['ffill'] = df2['value'].ffill()
df2['bfill'] = df2['value'].bfill()
df2['linear_interp'] = df2['value'].interpolate(method='linear')
df2['time_interp'] = df2.set_index('timestamp')['value'].interpolate(method='time').values
print(df2)
```

**Output**

```
            timestamp  value  ffill  bfill  linear_interp  time_interp
0 2024-01-01 00:00:00   10.0   10.0   10.0           10.0         10.0
1 2024-01-01 01:00:00    NaN   10.0   15.0           12.5         12.5
2 2024-01-01 02:00:00   15.0   15.0   15.0           15.0         15.0
3 2024-01-01 03:00:00    NaN   15.0   13.0           14.0         14.0
4 2024-01-01 04:00:00   13.0   13.0   13.0           13.0         13.0
```

- `ffill`/`bfill` carry the last/next known value forward or backward — appropriate for slow-changing or state-like variables (e.g., a status flag), but can misrepresent trends for continuously changing quantities.
- `interpolate(method='linear')` assumes equal spacing between index positions, regardless of actual elapsed time.
- `interpolate(method='time')` weights the interpolation by the actual elapsed time between known points, which matters when the underlying timestamps are unevenly spaced. In this example the two methods coincide because the index is already hourly, but they would diverge on a genuinely irregular index.

[Inference] Choosing between these strategies is dependent on the semantics of the specific variable (whether it behaves as a step function, a smoothly varying quantity, a cumulative count, etc.), and no single default is correct for all cases. I cannot verify which strategy is appropriate for any dataset not shown here, since that depends on domain knowledge outside this content.

### Rolling and Lag Operations on Irregular Data

Pandas rolling windows can operate on a **time-based** window rather than a fixed row count, which is directly relevant to irregular series.

```python
irregular = pd.DataFrame({
    'timestamp': pd.to_datetime([
        '2024-01-01 00:00', '2024-01-01 00:10',
        '2024-01-01 00:45', '2024-01-01 01:00',
        '2024-01-01 01:05'
    ]),
    'value': [1, 2, 3, 4, 5]
}).set_index('timestamp')

irregular['rolling_30min'] = irregular['value'].rolling('30min').mean()
print(irregular)
```

**Output**

```
                     value  rolling_30min
timestamp
2024-01-01 00:00:00      1            1.0
2024-01-01 00:10:00      2            1.5
2024-01-01 00:45:00      3            3.0
2024-01-01 01:00:00      4            3.5
2024-01-01 01:05:00      5            4.0
```

A time-based rolling window (`'30min'`) includes only the rows whose timestamps fall within the trailing 30-minute span of the current row, regardless of how many rows that represents — this differs from an integer window like `rolling(3)`, which always includes exactly 3 rows regardless of the actual time elapsed. This distinction matters directly for irregular data, where a fixed row-count window can silently span very different real-world durations depending on local data density.

### Handling Duplicate or Out-of-Order Timestamps

Real-world irregular data sometimes contains duplicate timestamps (multiple events logged at the same instant) or out-of-order records (data arriving/ingested non-chronologically).

```python
messy = pd.DataFrame({
    'timestamp': pd.to_datetime([
        '2024-01-01 00:05', '2024-01-01 00:02',
        '2024-01-01 00:02', '2024-01-01 00:10'
    ]),
    'value': [5, 2, 3, 10]
})

messy_sorted = messy.sort_values('timestamp')
messy_dedup = messy_sorted.drop_duplicates(subset='timestamp', keep='first')
print(messy_sorted)
print(messy_dedup)
```

**Output**

```
            timestamp  value
1 2024-01-01 00:02:00      2
2 2024-01-01 00:02:00      3
0 2024-01-01 00:05:00      5
3 2024-01-01 00:10:00     10

            timestamp  value
1 2024-01-01 00:02:00      2
3 2024-01-01 00:10:00     10
```

[Unverified] Whether `keep='first'` is the correct deduplication strategy versus averaging duplicate values, keeping the last, or treating duplicates as distinct sub-events depends entirely on what the duplicate timestamps represent in the source system, which is not something I can determine without additional information about the specific data source.

Most time-series functions (`asfreq`, `resample`, `rolling` with time offsets) require the index to be sorted and generally require unique timestamps; failing to sort or deduplicate first can produce errors or silently incorrect results depending on the operation and Pandas version. [Inference] This is based on general knowledge of how these functions are documented to require a monotonic index, not on having tested every version-specific edge case.

### Diagram: Irregular Timestamps Reindexed to a Regular Grid

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 260" font-family="sans-serif">
  <text x="360" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Irregular Timestamps vs. Reindexed Regular Grid (svg_diagram)</text>

  <text x="40" y="70" font-size="12" fill="#333">Raw (irregular)</text>
  <line x1="150" y1="70" x2="660" y2="70" stroke="#888" stroke-width="2" />
  <circle cx="180" cy="70" r="7" fill="#4C72B0" />
  <circle cx="230" cy="70" r="7" fill="#4C72B0" />
  <circle cx="420" cy="70" r="7" fill="#4C72B0" />
  <circle cx="470" cy="70" r="7" fill="#4C72B0" />
  <circle cx="500" cy="70" r="7" fill="#4C72B0" />

  <text x="40" y="160" font-size="12" fill="#333">Reindexed (regular)</text>
  <line x1="150" y1="160" x2="660" y2="160" stroke="#888" stroke-width="2" />
  <circle cx="180" cy="160" r="7" fill="#55A868" />
  <circle cx="230" cy="160" r="7" fill="#55A868" />
  <circle cx="280" cy="160" r="6" fill="#C44E52" />
  <circle cx="330" cy="160" r="6" fill="#C44E52" />
  <circle cx="380" cy="160" r="6" fill="#C44E52" />
  <circle cx="420" cy="160" r="7" fill="#55A868" />
  <circle cx="470" cy="160" r="7" fill="#55A868" />

  <line x1="180" y1="77" x2="180" y2="153" stroke="#ccc" stroke-dasharray="3,3" />
  <line x1="230" y1="77" x2="230" y2="153" stroke="#ccc" stroke-dasharray="3,3" />
  <line x1="420" y1="77" x2="420" y2="153" stroke="#ccc" stroke-dasharray="3,3" />
  <line x1="470" y1="77" x2="470" y2="153" stroke="#ccc" stroke-dasharray="3,3" />

  <rect x="60" y="200" width="14" height="14" fill="#4C72B0" />
  <text x="80" y="212" font-size="12" fill="#333">Original observed timestamp</text>

  <rect x="60" y="222" width="14" height="14" fill="#55A868" />
  <text x="80" y="234" font-size="12" fill="#333">Grid slot with observed value</text>

  <rect x="380" y="200" width="14" height="14" fill="#C44E52" />
  <text x="400" y="212" font-size="12" fill="#333">Grid slot filled as NaN (no original observation)</text>
</svg>

### Practical Pitfalls Summary

- Applying `.shift()` or integer-window `.rolling()` directly on an irregular index computes offsets in terms of row count, not elapsed time — this can silently produce lag/lead or rolling features that do not correspond to the intended real-world interval.
- Using `asfreq()` without considering the target frequency's granularity relative to source data density can either discard genuine off-grid observations or generate excessive `NaN` padding.
- Deduplication and sorting are prerequisites for most time-aware operations; skipping them can produce errors or incorrect results depending on the function and Pandas version. [Unverified] I do not have a version-by-version account of exactly which functions error out versus silently misbehave on unsorted or duplicate indices, so this should be checked against the Pandas version in use.
- Choosing an imputation method without regard to the variable's underlying behavior (state-like vs. continuously varying vs. cumulative) can introduce systematic bias into downstream ML features.

**Related Topics**

- Resampling and frequency conversion (`resample`, `asfreq`) for aggregation and downsampling
- Time-based rolling and expanding windows in downstream feature engineering
- Shifting, lagging, and lead features (interaction with irregular indices)
- Time zone handling and timestamp normalization
- Interpolation methods in depth (`polynomial`, `spline`, `time`, `index`)
- Detecting and handling outages, sensor dropout, and censored intervals in time series

**Note on this response:** The technical descriptions of Pandas/NumPy API behavior above (function outputs, parameter effects) reflect standard, documented library behavior and are not flagged as uncertain. Statements about which strategy is "correct" for a given real-world dataset are explicitly labeled [Inference] or [Unverified] where they depend on information not available in this conversation, per your stated preferences.