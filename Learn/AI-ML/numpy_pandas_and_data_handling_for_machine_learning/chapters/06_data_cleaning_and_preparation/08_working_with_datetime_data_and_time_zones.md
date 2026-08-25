## Working with Datetime Data and Time Zones

### Overview

Pandas represents datetime values using the `Timestamp` type (for scalars) and `datetime64[ns]` dtype (for Series/columns), built on NumPy's `datetime64` with nanosecond precision. Time zone handling adds a further layer of complexity, since a timestamp can be "naive" (no time zone information) or "aware" (explicitly tied to a time zone), and operations between the two are not directly compatible.

### Converting to Datetime

```python
import pandas as pd

df = pd.DataFrame({"date_str": ["2024-01-15", "2024-02-20", "2024-03-10"]})
df["date"] = pd.to_datetime(df["date_str"])
```

`pd.to_datetime()` parses strings (or other date-like inputs) into `Timestamp`/`datetime64[ns]` values.

```python
df["date"] = pd.to_datetime(df["date_str"], format="%Y-%m-%d")
```

Specifying `format` explicitly avoids Pandas' automatic format inference, which can be ambiguous for certain string patterns (e.g., distinguishing `01/02/2024` as January 2nd versus February 1st depending on locale convention) and is generally faster on large datasets since no per-row format guessing is needed.

**Key Points**
- `errors="coerce"` converts unparseable values to `NaT` (Not a Time) instead of raising an exception:

```python
df["date"] = pd.to_datetime(df["date_str"], errors="coerce")
```

- `errors="raise"` (default) stops on the first unparseable value; `errors="ignore"` [Unverified] — I do not have a confirmed, current description of this option's exact behavior across Pandas versions, since handling of invalid parsing has changed in some releases.

### Extracting Date Components

```python
df["year"] = df["date"].dt.year
df["month"] = df["date"].dt.month
df["day"] = df["date"].dt.day
df["day_of_week"] = df["date"].dt.dayofweek
df["day_name"] = df["date"].dt.day_name()
df["quarter"] = df["date"].dt.quarter
```

The `.dt` accessor exposes datetime component attributes and methods, analogous to how `.str` exposes string operations — both require the underlying Series to be of the corresponding dtype.

**Key Points**
- `dayofweek` returns an integer where Monday is `0` and Sunday is `6`, matching Python's own `datetime.weekday()` convention.

### Date Arithmetic

```python
df["days_since"] = (pd.Timestamp("2024-06-01") - df["date"]).dt.days
```

Subtracting two `Timestamp`/`datetime64` values produces a `Timedelta`, representing a duration; `.dt.days` extracts the integer day count from that duration.

```python
df["next_week"] = df["date"] + pd.Timedelta(days=7)
df["next_month"] = df["date"] + pd.DateOffset(months=1)
```

**Key Points**
- `Timedelta` represents a fixed duration (e.g., exactly 7×24 hours).
- `DateOffset` represents calendar-aware durations (e.g., "one month," which varies in actual day length) — the distinction matters specifically around month/year boundaries and daylight saving transitions.

### Setting a Datetime Index

```python
df = df.set_index("date")
df.sort_index(inplace=True)
```

A `DatetimeIndex` enables date-based slicing and resampling operations that a plain integer index does not support directly:

```python
df["2024-01"]                          # all rows in January 2024
df["2024-01-15":"2024-02-15"]          # date range slice
```

### Resampling Time Series Data

```python
monthly = df.resample("M").mean()
daily_sum = df.resample("D").sum()
```

`resample()` groups datetime-indexed data into fixed time buckets and applies an aggregation function, conceptually similar to `groupby()` but based on time intervals rather than categorical values.

**Key Points**
- Common frequency strings include `"D"` (day), `"W"` (week), `"M"` (month end), `"MS"` (month start), `"Q"` (quarter end), `"Y"` (year end), and `"H"` (hour). [Unverified] The complete, current list of valid frequency aliases, and whether any have been renamed or deprecated, depends on the specific Pandas version in use — I do not have a confirmed, version-specific reference to cite here.

### Rolling Windows on Time Series

```python
df["rolling_avg"] = df["value"].rolling(window="7D").mean()
```

A string window like `"7D"` uses the `DatetimeIndex` to define the window in actual calendar time, rather than a fixed number of rows — relevant when data isn't evenly spaced (e.g., missing days).

### Working with Time Zones: Localizing Naive Timestamps

A naive `Timestamp` has no associated time zone information at all — it's just a date and time with no context about which zone it refers to.

```python
df["date_utc"] = df["date"].dt.tz_localize("UTC")
```

`tz_localize()` attaches a time zone to a naive timestamp without changing the underlying clock time — it declares what zone the existing values were already in.

**Key Points**
- Calling `tz_localize()` on a timestamp that is already time zone-aware raises an error; it is intended only for the naive-to-aware transition.
- Localizing across a daylight saving time transition can raise an error or require explicit handling (`ambiguous=` and `nonexistent=` parameters) for timestamps that fall in an ambiguous or nonexistent local time window. [Unverified] The complete, exact set of accepted values and default behavior for `ambiguous`/`nonexistent` parameters is not something I can state comprehensively here without checking documentation for the specific Pandas version in use.

### Converting Between Time Zones

```python
df["date_manila"] = df["date_utc"].dt.tz_convert("Asia/Manila")
```

`tz_convert()` changes the displayed time zone of an already time zone-aware timestamp, adjusting the clock time to represent the same instant in a different zone — unlike `tz_localize()`, which does not shift the clock time.

### Removing Time Zone Information

```python
df["date_naive"] = df["date_utc"].dt.tz_localize(None)
```

Calling `tz_localize(None)` on an aware timestamp strips the time zone information, leaving the clock-time value as-is but making it naive again.

### Common Time Zone Pitfalls

```python
naive_ts = pd.Timestamp("2024-01-01")
aware_ts = pd.Timestamp("2024-01-01", tz="UTC")

naive_ts - aware_ts
```

Subtracting a naive timestamp from an aware one (or vice versa) raises a `TypeError` — Pandas does not assume a default time zone for naive values in this comparison, since doing so silently could introduce incorrect time-shift assumptions.

**Key Points**
- Mixing naive and aware timestamps within the same column, or across columns being compared/joined, is a common source of subtle bugs when data originates from multiple sources with different time zone handling conventions.

### Time Zone Considerations for Machine Learning Features

When time-based features (hour of day, day of week) are derived from timestamps that were recorded in different original time zones but stored inconsistently (some converted to UTC, some not), the derived features can be misleading — e.g., "hour of day" computed on a mix of local and UTC timestamps doesn't represent a consistent real-world quantity.

[Inference] Standardizing all timestamps to a single time zone (commonly UTC) before deriving time-based features is a widely documented practice for avoiding this inconsistency, based on this being a common recommendation in data engineering and ML preprocessing guidance generally — whether it's the right choice for a specific application (versus preserving local time deliberately, e.g., for modeling local behavioral patterns) depends on what the feature is meant to represent, which requires knowing the specific use case.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| `TypeError` comparing timestamps | Mixing naive and time zone-aware `Timestamp`/`datetime64` values |
| Wrong parsed date (month/day swapped) | Ambiguous date string format without explicit `format` argument |
| Incorrect elapsed time calculations | Using `DateOffset` where a fixed `Timedelta` was intended, or vice versa, across a DST transition |
| Misleading time-based features | Time-of-day/day-of-week features derived from inconsistently time-zoned source timestamps |

### Diagram: Naive vs. Aware Timestamp Handling

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 240">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Naive to Timezone-Aware Timestamp Flow (svg_diagram)</text>

  <rect x="30" y="70" width="180" height="50" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="120" y="100" text-anchor="middle" font-size="11">Naive Timestamp</text>

  <line x1="210" y1="95" x2="270" y2="95" stroke="#333" stroke-width="2" marker-end="url(#arrow13)" />
  <text x="240" y="85" text-anchor="middle" font-size="9" fill="#555">tz_localize()</text>

  <rect x="280" y="70" width="200" height="50" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="380" y="100" text-anchor="middle" font-size="11">Aware (UTC)</text>

  <line x1="480" y1="95" x2="540" y2="95" stroke="#333" stroke-width="2" marker-end="url(#arrow13)" />
  <text x="510" y="85" text-anchor="middle" font-size="9" fill="#555">tz_convert()</text>

  <rect x="550" y="70" width="180" height="50" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="640" y="100" text-anchor="middle" font-size="11">Aware (local zone)</text>

  <line x1="380" y1="120" x2="380" y2="160" stroke="#333" stroke-width="1.5" marker-end="url(#arrow13)" />
  <text x="380" y="180" text-anchor="middle" font-size="10" fill="#555">tz_localize(None) strips info, returns to naive</text>

  </svg>

### Related Topics

- Business day and holiday-aware date offsets (`pd.offsets.BDay`, custom calendars)
- Time series resampling with custom aggregation and gap-filling strategies
- Period vs. Timestamp representations (`PeriodIndex`) for fixed calendar intervals
- Handling irregular/unevenly spaced time series data
- Cyclical encoding of time features (sine/cosine transforms) for ML models
- Daylight saving time edge cases in scheduled/recurring event data