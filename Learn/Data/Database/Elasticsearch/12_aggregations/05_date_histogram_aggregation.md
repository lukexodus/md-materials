## Date Histogram Aggregation

The `date_histogram` aggregation is a bucket aggregation that groups documents by date field values into time-based intervals. It extends the concept of the `histogram` aggregation with calendar awareness — accounting for variable-length months, leap years, and daylight saving time (DST) transitions. It is the standard tool for time-series analysis in Elasticsearch.

---

### Basic Syntax

```json
GET /my-index/_search
{
  "size": 0,
  "aggs": {
    "sales_over_time": {
      "date_histogram": {
        "field": "order_date",
        "calendar_interval": "month"
      }
    }
  }
}
```

**Output** (simplified):

```json
"aggregations": {
  "sales_over_time": {
    "buckets": [
      { "key_as_string": "2024-01-01T00:00:00.000Z", "key": 1704067200000, "doc_count": 142 },
      { "key_as_string": "2024-02-01T00:00:00.000Z", "key": 1706745600000, "doc_count": 98  },
      { "key_as_string": "2024-03-01T00:00:00.000Z", "key": 1709251200000, "doc_count": 175 }
    ]
  }
}
```

**Key Points**
- `key` is the bucket boundary expressed as a Unix timestamp in milliseconds.
- `key_as_string` is the human-readable formatted version of `key`.
- Both values represent the **start** of the interval.

---

### Interval Types

`date_histogram` supports two mutually exclusive interval parameters: `calendar_interval` and `fixed_interval`. Only one may be used per aggregation.

---

### `calendar_interval`

Calendar intervals respect the irregularities of the calendar — months have different lengths, years have leap days, and DST shifts clock time.

| Value | Description |
|---|---|
| `minute` / `1m` | One calendar minute |
| `hour` / `1h` | One calendar hour |
| `day` / `1d` | One calendar day (DST-aware) |
| `week` / `1w` | One calendar week (Monday start) |
| `month` / `1M` | One calendar month |
| `quarter` / `1q` | One calendar quarter |
| `year` / `1y` | One calendar year |

```json
"date_histogram": {
  "field": "event_date",
  "calendar_interval": "week"
}
```

**Key Points**
- Calendar interval values are case-sensitive. `1M` means month; `1m` means minute.
- Multiples of calendar intervals (e.g., `2M`, `3w`) are not supported. Use `fixed_interval` for multiples.

---

### `fixed_interval`

Fixed intervals use an exact, constant duration regardless of calendar irregularities. Expressed as a number and a time unit.

| Unit | Suffix |
|---|---|
| Milliseconds | `ms` |
| Seconds | `s` |
| Minutes | `m` |
| Hours | `h` |
| Days | `d` |

```json
"date_histogram": {
  "field": "event_date",
  "fixed_interval": "7d"
}
```

```json
"date_histogram": {
  "field": "event_date",
  "fixed_interval": "12h"
}
```

**Key Points**
- `fixed_interval` supports arbitrary multiples (e.g., `2h`, `15m`, `30d`).
- A `fixed_interval` of `1d` is exactly 86,400,000 milliseconds and does not adjust for DST. Use `calendar_interval: day` when DST correction is required.
- `month`, `quarter`, and `year` are not available as fixed intervals because their lengths vary.

---

### `calendar_interval` vs. `fixed_interval`

| Aspect | `calendar_interval` | `fixed_interval` |
|---|---|---|
| DST-aware | Yes | No |
| Leap year / month length aware | Yes | No |
| Supports multiples | No | Yes |
| Supports month / quarter / year | Yes | No |
| Bucket width consistency | Variable (by design) | Constant |

---

### `format`

Controls how `key_as_string` is rendered. Uses Java date format patterns.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "format": "yyyy-MM"
}
```

**Output**:

```json
{ "key_as_string": "2024-01", "key": 1704067200000, "doc_count": 142 }
```

Common format patterns:

| Pattern | Example Output |
|---|---|
| `yyyy-MM-dd` | `2024-03-15` |
| `yyyy-MM` | `2024-03` |
| `yyyy` | `2024` |
| `dd/MM/yyyy` | `15/03/2024` |
| `epoch_millis` | `1710460800000` |

---

### `time_zone`

Shifts bucket boundaries to align with a specific time zone. Affects both where bucket boundaries fall and how `key_as_string` is formatted. Accepts IANA time zone IDs or UTC offset strings.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "day",
  "time_zone": "America/New_York"
}
```

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "day",
  "time_zone": "+05:30"
}
```

**Key Points**
- Without `time_zone`, all buckets align to UTC boundaries.
- With `time_zone`, a bucket labeled `2024-03-15` covers midnight-to-midnight in the specified zone, not in UTC.
- `key` (the millisecond timestamp) always represents the UTC epoch of the bucket start, regardless of `time_zone`.
- DST transitions may cause a day bucket to be 23 or 25 hours long when using `calendar_interval: day` with a DST-observing time zone.

---

### `offset`

Shifts all bucket boundaries by a fixed duration. Useful when buckets need to align with domain-specific time boundaries (e.g., a business day starting at 06:00 rather than 00:00).

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "day",
  "time_zone": "America/Chicago",
  "offset": "+6h"
}
```

Accepts positive or negative duration strings (e.g., `+1h`, `-30m`).

---

### `min_doc_count` and Empty Buckets

Defaults to `0`, meaning empty time intervals are included in the output by default. This is important for time-series visualizations where gaps must be explicitly represented.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "min_doc_count": 0
}
```

Setting `min_doc_count: 1` suppresses months with no matching documents.

---

### `extended_bounds`

Forces bucket generation across a full date range even when no documents exist within some intervals. Requires `min_doc_count: 0`.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "min_doc_count": 0,
  "extended_bounds": {
    "min": "2024-01-01",
    "max": "2024-12-31"
  }
}
```

Without `extended_bounds`, the histogram only generates buckets from the earliest to the latest matching document date. With it, all twelve months are always present in the output regardless of data.

`min` and `max` accept:
- ISO 8601 date strings
- Unix timestamps in milliseconds
- Date math expressions (e.g., `now-1y/y`)

---

### `hard_bounds`

Restricts bucket generation to a specified date range. Documents outside this range are excluded from all buckets.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "hard_bounds": {
    "min": "2024-01-01",
    "max": "2024-06-30"
  }
}
```

[Inference] `hard_bounds` restricts bucket output, not the underlying query match; documents outside the range are excluded from the aggregation but may still be counted in the query `hits.total`.

---

### Sub-Aggregations

```json
"aggs": {
  "orders_by_month": {
    "date_histogram": {
      "field": "order_date",
      "calendar_interval": "month",
      "format": "yyyy-MM"
    },
    "aggs": {
      "total_revenue": {
        "sum": { "field": "amount" }
      },
      "avg_order_value": {
        "avg": { "field": "amount" }
      }
    }
  }
}
```

**Output** (simplified):

```json
"orders_by_month": {
  "buckets": [
    {
      "key_as_string": "2024-01",
      "key": 1704067200000,
      "doc_count": 142,
      "total_revenue":   { "value": 18450.0 },
      "avg_order_value": { "value": 129.9   }
    },
    {
      "key_as_string": "2024-02",
      "key": 1706745600000,
      "doc_count": 98,
      "total_revenue":   { "value": 11200.0 },
      "avg_order_value": { "value": 114.3   }
    }
  ]
}
```

---

### `keyed` Response Format

Returns buckets as a named object map using `key_as_string` as the key, instead of an array.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "format": "yyyy-MM",
  "keyed": true
}
```

**Output**:

```json
"orders_by_month": {
  "buckets": {
    "2024-01": { "key_as_string": "2024-01", "key": 1704067200000, "doc_count": 142 },
    "2024-02": { "key_as_string": "2024-02", "key": 1706745600000, "doc_count": 98  }
  }
}
```

---

### `order`

Controls how buckets are sorted. Defaults to ascending `_key`.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "order": { "_count": "desc" }
}
```

[Inference] Sorting by `_count` or sub-aggregation rather than `_key` breaks chronological ordering, which may be undesirable for time-series rendering.

---

### `missing`

Assigns documents with a missing date field to a specific bucket.

```json
"date_histogram": {
  "field": "order_date",
  "calendar_interval": "month",
  "missing": "2024-01-01"
}
```

---

### `auto_date_histogram`

A related aggregation that automatically selects an appropriate interval to produce a target number of buckets. Useful when the time range is not known in advance.

```json
"aggs": {
  "dynamic_timeline": {
    "auto_date_histogram": {
      "field": "order_date",
      "buckets": 10
    }
  }
}
```

Elasticsearch selects the coarsest interval that produces no more than the requested number of buckets. The chosen interval is returned in the response under `interval`.

| Aspect | `date_histogram` | `auto_date_histogram` |
|---|---|---|
| Interval | Explicitly specified | Automatically chosen |
| Bucket count | Variable | Approximately fixed |
| Predictability | High | Lower — interval may change as data changes |

---

### Date Math in Bounds

`extended_bounds`, `hard_bounds`, and `missing` values support Elasticsearch date math expressions:

| Expression | Meaning |
|---|---|
| `now` | Current timestamp |
| `now/d` | Start of current day |
| `now-1y/y` | Start of previous year |
| `now-30d` | 30 days ago |

```json
"extended_bounds": {
  "min": "now-1y/y",
  "max": "now/y"
}
```

---

### Common Time-Series Pattern

A complete pattern for a time-series dashboard query:

```json
GET /logs/_search
{
  "size": 0,
  "query": {
    "range": {
      "timestamp": {
        "gte": "now-30d",
        "lte": "now"
      }
    }
  },
  "aggs": {
    "events_per_day": {
      "date_histogram": {
        "field": "timestamp",
        "calendar_interval": "day",
        "time_zone": "America/New_York",
        "format": "yyyy-MM-dd",
        "min_doc_count": 0,
        "extended_bounds": {
          "min": "now-30d/d",
          "max": "now/d"
        }
      },
      "aggs": {
        "error_count": {
          "filter": { "term": { "level": "error" } }
        }
      }
    }
  }
}
```

This produces a 30-day timeline with one bucket per day in New York time, zero-filled for days with no events, and a per-day error count sub-aggregation.

---

**Conclusion**

The `date_histogram` aggregation is the foundational tool for time-series analysis in Elasticsearch. The choice between `calendar_interval` and `fixed_interval` governs whether bucket boundaries follow human calendar conventions or exact durations. Combined with `time_zone`, `extended_bounds`, and sub-aggregations, it supports the full range of time-based analytical and visualization use cases. For dynamic interval selection, `auto_date_histogram` provides an alternative when the time range is not predetermined.