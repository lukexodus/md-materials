## Aggregations — derivative and cumulative\_sum

### Overview

`derivative` and `cumulative_sum` are both **parent pipeline aggregations** — defined inside a bucket aggregation, operating on the ordered sequence of buckets it produces, and writing a new value back into each bucket. Both require the parent bucket aggregation to produce a meaningful ordered sequence, and both consume a single metric aggregation's output via `buckets_path`.

They are complementary: `derivative` measures *rate of change* between consecutive buckets; `cumulative_sum` measures *running total* across buckets from the first up to the current one.

---

### Shared Requirements

Both aggregations require:

1. A parent bucket aggregation that produces **ordered buckets** — `date_histogram` and `histogram` are the natural choices
2. A sibling metric aggregation within the same bucket aggregation, whose output they consume
3. The `buckets_path` parameter pointing to that metric

Neither aggregation can operate on raw documents directly, and neither produces meaningful results when the parent bucket aggregation has no natural ordering.

---

### derivative

#### What It Computes

For each bucket, `derivative` computes the difference between the current bucket's metric value and the immediately preceding bucket's metric value:

```
derivative[n] = value[n] - value[n-1]
```

The first bucket always produces no derivative value, since there is no prior bucket to subtract from.

#### Basic Syntax

```json
GET /metrics/_search
{
  "size": 0,
  "aggs": {
    "requests_per_hour": {
      "date_histogram": {
        "field": "timestamp",
        "calendar_interval": "hour"
      },
      "aggs": {
        "total_requests": {
          "sum": { "field": "request_count" }
        },
        "request_rate_change": {
          "derivative": {
            "buckets_path": "total_requests"
          }
        }
      }
    }
  }
}
```

**Output:** Each hourly bucket gains a `request_rate_change` value representing how much `total_requests` changed from the previous hour. The first bucket has no `request_rate_change` value.

#### Example Response

```json
"buckets": [
  {
    "key_as_string": "2024-11-01T00:00:00",
    "doc_count": 412,
    "total_requests": { "value": 8200 },
  },
  {
    "key_as_string": "2024-11-01T01:00:00",
    "doc_count": 489,
    "total_requests": { "value": 9800 },
    "request_rate_change": { "value": 1600.0 }
  },
  {
    "key_as_string": "2024-11-01T02:00:00",
    "doc_count": 301,
    "total_requests": { "value": 6100 },
    "request_rate_change": { "value": -3700.0 }
  }
]
```

A positive value indicates growth from the prior bucket; a negative value indicates decline.

#### Unit Normalization with unit

When the parent is a `date_histogram`, the `unit` parameter normalizes the derivative to a per-unit-time rate rather than a raw bucket-to-bucket difference.

```json
"request_rate_change": {
  "derivative": {
    "buckets_path": "total_requests",
    "unit": "day"
  }
}
```

Valid unit values follow standard Elasticsearch time unit notation: `second`, `minute`, `hour`, `day`, `week`, `month`, `quarter`, `year`.

**Output:** If the parent bucket interval is `hour` and `unit` is `day`, the derivative value is scaled by 24 to express the implied daily rate — not just the hourly difference.

[Inference] Unit normalization is useful for making cross-interval comparisons consistent, but the scaled value is a projection, not an observed measurement — interpret accordingly.

#### Second-Order Derivative

A `derivative` can reference another `derivative` via `buckets_path`, producing a second-order derivative (rate of change of the rate of change):

```json
"aggs": {
  "total_revenue": {
    "sum": { "field": "revenue" }
  },
  "revenue_change": {
    "derivative": {
      "buckets_path": "total_revenue"
    }
  },
  "revenue_acceleration": {
    "derivative": {
      "buckets_path": "revenue_change"
    }
  }
}
```

The second-order derivative loses two buckets rather than one — the first bucket has no first derivative, and the second bucket has no second derivative.

#### gap\_policy

```json
"derivative": {
  "buckets_path": "total_requests",
  "gap_policy": "skip"
}
```

| Value | Behavior |
|---|---|
| `skip` | No derivative output for the gap bucket; the next bucket computes against the last non-empty bucket |
| `insert_zeros` | Treats the missing bucket's metric as zero before computing the difference |

The appropriate policy depends on whether a missing bucket represents zero activity or an absence of data.

---

### cumulative\_sum

#### What It Computes

For each bucket, `cumulative_sum` adds the current bucket's metric value to the running total of all preceding buckets:

```
cumulative_sum[n] = value[0] + value[1] + ... + value[n]
```

Every bucket receives a value — including the first, whose cumulative sum equals its own metric value.

#### Basic Syntax

```json
GET /sales/_search
{
  "size": 0,
  "aggs": {
    "monthly_sales": {
      "date_histogram": {
        "field": "sale_date",
        "calendar_interval": "month"
      },
      "aggs": {
        "revenue": {
          "sum": { "field": "amount" }
        },
        "cumulative_revenue": {
          "cumulative_sum": {
            "buckets_path": "revenue"
          }
        }
      }
    }
  }
}
```

#### Example Response

```json
"buckets": [
  {
    "key_as_string": "2024-01-01",
    "revenue": { "value": 42000.0 },
    "cumulative_revenue": { "value": 42000.0 }
  },
  {
    "key_as_string": "2024-02-01",
    "revenue": { "value": 38500.0 },
    "cumulative_revenue": { "value": 80500.0 }
  },
  {
    "key_as_string": "2024-03-01",
    "revenue": { "value": 51200.0 },
    "cumulative_revenue": { "value": 131700.0 }
  }
]
```

Each bucket's `cumulative_revenue` value is the year-to-date total through that month.

#### format Parameter

```json
"cumulative_revenue": {
  "cumulative_sum": {
    "buckets_path": "revenue",
    "format": "#,##0.00"
  }
}
```

Applies a Java `DecimalFormat` pattern. The numeric `value` field is unchanged; a `value_as_string` field is added with the formatted representation.

#### cumulative\_sum Has No gap\_policy

Unlike `derivative`, `cumulative_sum` does not expose a `gap_policy` parameter. [Inference] Empty buckets produced by the parent with `min_doc_count: 0` will contribute a zero to the running total if the metric aggregation returns zero; buckets absent entirely (when `min_doc_count` is greater than zero) are simply skipped in the sequence — behavior may vary depending on whether the parent bucket aggregation emits an empty bucket or omits it entirely.

To ensure contiguous buckets for `cumulative_sum`, set `min_doc_count: 0` on the parent `date_histogram` or `histogram`.

---

### Using Both Together

`derivative` and `cumulative_sum` can coexist as siblings inside the same bucket aggregation, consuming the same or different metric outputs:

```json
GET /events/_search
{
  "size": 0,
  "aggs": {
    "daily": {
      "date_histogram": {
        "field": "event_time",
        "calendar_interval": "day",
        "min_doc_count": 0
      },
      "aggs": {
        "signups": {
          "sum": { "field": "signup_count" }
        },
        "daily_change": {
          "derivative": {
            "buckets_path": "signups",
            "gap_policy": "insert_zeros"
          }
        },
        "total_signups": {
          "cumulative_sum": {
            "buckets_path": "signups"
          }
        }
      }
    }
  }
}
```

**Output:** Each daily bucket contains three values — the day's signup count, the day-over-day change, and the running total of all signups to date.

---

### Behavioral Diagram

The following illustrates how `derivative` and `cumulative_sum` read from and write back into the bucket sequence:

<svg viewBox="0 0 700 370" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="700" height="370" fill="#0f1117"/>

  <!-- Bucket column headers -->
  <text x="90" y="30" fill="#565f89" font-size="11" text-anchor="middle">Jan</text>
  <text x="230" y="30" fill="#565f89" font-size="11" text-anchor="middle">Feb</text>
  <text x="370" y="30" fill="#565f89" font-size="11" text-anchor="middle">Mar</text>
  <text x="510" y="30" fill="#565f89" font-size="11" text-anchor="middle">Apr</text>

  <!-- Metric row label -->
  <text x="20" y="75" fill="#e0af68" font-size="11">metric</text>

  <!-- Metric boxes -->
  <rect x="50" y="55" width="80" height="35" rx="4" fill="#1e2130" stroke="#e0af68" stroke-width="1.5"/>
  <text x="90" y="77" fill="#e0af68" text-anchor="middle">100</text>

  <rect x="190" y="55" width="80" height="35" rx="4" fill="#1e2130" stroke="#e0af68" stroke-width="1.5"/>
  <text x="230" y="77" fill="#e0af68" text-anchor="middle">150</text>

  <rect x="330" y="55" width="80" height="35" rx="4" fill="#1e2130" stroke="#e0af68" stroke-width="1.5"/>
  <text x="370" y="77" fill="#e0af68" text-anchor="middle">120</text>

  <rect x="470" y="55" width="80" height="35" rx="4" fill="#1e2130" stroke="#e0af68" stroke-width="1.5"/>
  <text x="510" y="77" fill="#e0af68" text-anchor="middle">180</text>

  <!-- Derivative row label -->
  <text x="20" y="155" fill="#f7768e" font-size="11">deriv</text>

  <!-- Derivative boxes -->
  <rect x="50" y="135" width="80" height="35" rx="4" fill="#1a1520" stroke="#f7768e" stroke-width="1.5" stroke-dasharray="4,2"/>
  <text x="90" y="157" fill="#565f89" text-anchor="middle">—</text>

  <rect x="190" y="135" width="80" height="35" rx="4" fill="#1a1520" stroke="#f7768e" stroke-width="1.5"/>
  <text x="230" y="157" fill="#f7768e" text-anchor="middle">+50</text>

  <rect x="330" y="135" width="80" height="35" rx="4" fill="#1a1520" stroke="#f7768e" stroke-width="1.5"/>
  <text x="370" y="157" fill="#f7768e" text-anchor="middle">−30</text>

  <rect x="470" y="135" width="80" height="35" rx="4" fill="#1a1520" stroke="#f7768e" stroke-width="1.5"/>
  <text x="510" y="157" fill="#f7768e" text-anchor="middle">+60</text>

  <!-- Derivative arrows (metric[n-1] to derivative[n]) -->
  <line x1="130" y1="72" x2="190" y2="152" stroke="#f7768e" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#arrRed)"/>
  <line x1="270" y1="72" x2="330" y2="152" stroke="#f7768e" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#arrRed)"/>
  <line x1="410" y1="72" x2="470" y2="152" stroke="#f7768e" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#arrRed)"/>

  <!-- Cumulative sum row label -->
  <text x="20" y="245" fill="#7dcfff" font-size="11">cumul</text>

  <!-- Cumulative sum boxes -->
  <rect x="50" y="225" width="80" height="35" rx="4" fill="#0f1a24" stroke="#7dcfff" stroke-width="1.5"/>
  <text x="90" y="247" fill="#7dcfff" text-anchor="middle">100</text>

  <rect x="190" y="225" width="80" height="35" rx="4" fill="#0f1a24" stroke="#7dcfff" stroke-width="1.5"/>
  <text x="230" y="247" fill="#7dcfff" text-anchor="middle">250</text>

  <rect x="330" y="225" width="80" height="35" rx="4" fill="#0f1a24" stroke="#7dcfff" stroke-width="1.5"/>
  <text x="370" y="247" fill="#7dcfff" text-anchor="middle">370</text>

  <rect x="470" y="225" width="80" height="35" rx="4" fill="#0f1a24" stroke="#7dcfff" stroke-width="1.5"/>
  <text x="510" y="247" fill="#7dcfff" text-anchor="middle">550</text>

  <!-- Cumulative arrows (running total) -->
  <line x1="130" y1="242" x2="190" y2="242" stroke="#7dcfff" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#arrBlue)"/>
  <line x1="270" y1="242" x2="330" y2="242" stroke="#7dcfff" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#arrBlue)"/>
  <line x1="410" y1="242" x2="470" y2="242" stroke="#7dcfff" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#arrBlue)"/>

  <!-- Metric to cumulative arrows -->
  <line x1="90" y1="90" x2="90" y2="225" stroke="#7dcfff" stroke-width="0.8" stroke-dasharray="2,3"/>
  <line x1="230" y1="90" x2="230" y2="225" stroke="#7dcfff" stroke-width="0.8" stroke-dasharray="2,3"/>
  <line x1="370" y1="90" x2="370" y2="225" stroke="#7dcfff" stroke-width="0.8" stroke-dasharray="2,3"/>
  <line x1="510" y1="90" x2="510" y2="225" stroke="#7dcfff" stroke-width="0.8" stroke-dasharray="2,3"/>

  <!-- Legend -->
  <rect x="50" y="305" width="12" height="12" fill="#1e2130" stroke="#e0af68" stroke-width="1.5"/>
  <text x="68" y="316" fill="#e0af68" font-size="11">metric (input)</text>

  <rect x="200" y="305" width="12" height="12" fill="#1a1520" stroke="#f7768e" stroke-width="1.5"/>
  <text x="218" y="316" fill="#f7768e" font-size="11">derivative output</text>

  <rect x="370" y="305" width="12" height="12" fill="#0f1a24" stroke="#7dcfff" stroke-width="1.5"/>
  <text x="388" y="316" fill="#7dcfff" font-size="11">cumulative_sum output</text>

  <defs>
    <marker id="arrRed" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#f7768e"/>
    </marker>
    <marker id="arrBlue" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#7dcfff"/>
    </marker>
  </defs>
</svg>

---

### Practical Use Cases

| Use Case | Aggregation | Pattern |
|---|---|---|
| Day-over-day traffic change | `derivative` | `date_histogram` + `sum` → `derivative` |
| Revenue growth rate | `derivative` | `date_histogram` + `sum` → `derivative` with `unit: month` |
| Detect acceleration in signups | `derivative` (2nd order) | `derivative` → `derivative` |
| Year-to-date sales total | `cumulative_sum` | `date_histogram` + `sum` → `cumulative_sum` |
| Running event count | `cumulative_sum` | `date_histogram` + `value_count` → `cumulative_sum` |
| Combined growth + total view | Both | Same metric, two pipeline aggs side by side |

---

### Limitations and Caveats

- The first bucket always lacks a `derivative` value. The second bucket lacks a second-order derivative value.
- Both aggregations are sensitive to the parent bucket aggregation emitting sparse or non-contiguous buckets. Use `min_doc_count: 0` on the parent when contiguity is required.
- `cumulative_sum` does not support `gap_policy`. [Inference] The handling of absent buckets depends on the parent aggregation's behavior — results may not reflect zero-filling unless the parent is configured to emit empty buckets.
- Neither aggregation supports scripted inputs directly; they consume metric aggregation outputs only.
- [Inference] Using `derivative` on a `terms` aggregation produces values that are computed but likely semantically meaningless, since bucket order in `terms` is by document count or alphabetical, not by any natural sequence — interpret with caution.

---

**Conclusion:** `derivative` and `cumulative_sum` are the foundational sequential pipeline aggregations in Elasticsearch. `derivative` exposes change and rate, making it suitable for trend detection and anomaly identification. `cumulative_sum` exposes accumulation, making it suitable for running totals and progress-toward-goal tracking. Both depend on ordered bucket sequences and a properly configured parent aggregation to produce meaningful results, and both write their output directly into each bucket alongside the metrics they consume.