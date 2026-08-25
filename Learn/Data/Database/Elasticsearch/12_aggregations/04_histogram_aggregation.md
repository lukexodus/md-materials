## Histogram Aggregation

The `histogram` aggregation is a bucket aggregation that groups numeric field values into fixed-width intervals. Each bucket represents a range of values of equal width, determined by an `interval` parameter. It is the primary tool for building value-distribution analyses over numeric data.

---

### Basic Syntax

```json
GET /my-index/_search
{
  "size": 0,
  "aggs": {
    "price_distribution": {
      "histogram": {
        "field": "price",
        "interval": 50
      }
    }
  }
}
```

**Output** (simplified):

```json
"aggregations": {
  "price_distribution": {
    "buckets": [
      { "key": 0,   "doc_count": 12 },
      { "key": 50,  "doc_count": 45 },
      { "key": 100, "doc_count": 28 },
      { "key": 150, "doc_count": 9  }
    ]
  }
}
```

Each bucket `key` is the lower bound of the interval. A document with `price: 73` falls into the bucket with `key: 50` (the interval `[50, 100)`).

---

### How Bucket Boundaries Are Computed

For a given `interval` value, Elasticsearch computes bucket keys using the formula:

```
bucket_key = floor(field_value / interval) * interval
```

**Example** — with `interval: 50`:

| Field Value | Calculation | Bucket Key |
|---|---|---|
| `23` | `floor(23/50) * 50` | `0` |
| `50` | `floor(50/50) * 50` | `50` |
| `74` | `floor(74/50) * 50` | `50` |
| `100` | `floor(100/50) * 50` | `100` |
| `149` | `floor(149/50) * 50` | `100` |

Buckets are left-inclusive and right-exclusive: `[key, key + interval)`.

---

### Key Parameters

#### `interval`

Required. Defines the fixed width of each bucket. Must be a positive value.

```json
"histogram": {
  "field": "age",
  "interval": 10
}
```

Choosing an appropriate interval depends on the data range and the desired granularity. [Inference] Very small intervals on high-range fields may produce a large number of buckets, which may increase memory usage; actual impact varies by cluster configuration.

#### `min_doc_count`

Excludes buckets with fewer than this many documents. Defaults to `0`, meaning empty buckets between the min and max observed values are included by default.

```json
"histogram": {
  "field": "price",
  "interval": 50,
  "min_doc_count": 1
}
```

Setting `min_doc_count: 1` suppresses empty buckets. Setting it to `0` (default) retains them — useful for visualizing gaps in distributions.

#### `extended_bounds`

Forces the aggregation to generate buckets across a specified range even if no documents fall within some intervals. Requires `min_doc_count: 0`.

```json
"histogram": {
  "field": "price",
  "interval": 50,
  "min_doc_count": 0,
  "extended_bounds": {
    "min": 0,
    "max": 500
  }
}
```

Without `extended_bounds`, the histogram only generates buckets between the minimum and maximum values observed in matching documents. With it, the full range is always represented.

#### `hard_bounds`

Restricts bucket generation to a specified range, excluding documents outside it. Unlike `extended_bounds`, this does not add empty buckets — it clips the output.

```json
"histogram": {
  "field": "price",
  "interval": 50,
  "hard_bounds": {
    "min": 100,
    "max": 400
  }
}
```

Documents with `price < 100` or `price > 400` are excluded from all buckets. [Inference] `hard_bounds` does not filter the underlying query — it only restricts which buckets are generated.

#### `offset`

Shifts bucket boundaries by a fixed amount. Defaults to `0`.

```json
"histogram": {
  "field": "price",
  "interval": 100,
  "offset": 25
}
```

With `offset: 25` and `interval: 100`, buckets become `[25, 125)`, `[125, 225)`, `[225, 325)` instead of `[0, 100)`, `[100, 200)`, etc.

**Key Points**
- `offset` must be in the range `[0, interval)`.
- Useful when bucket boundaries need to align with domain-specific breakpoints (e.g., fiscal quarters, custom scoring tiers).

#### `order`

Controls how buckets are sorted in the response. Defaults to ascending `_key`.

```json
"histogram": {
  "field": "price",
  "interval": 50,
  "order": { "_count": "desc" }
}
```

| Sort Target | Description |
|---|---|
| `_key` | By bucket key (numeric order) |
| `_count` | By document count |
| `<sub_agg_name>` | By a single-value metric sub-aggregation |

#### `missing`

Assigns documents with a missing field value to a specific bucket key.

```json
"histogram": {
  "field": "price",
  "interval": 50,
  "missing": 0
}
```

Documents without a `price` field are treated as if they have `price: 0`.

---

### Empty Buckets and `extended_bounds`

By default (`min_doc_count: 0`), the histogram generates empty buckets between observed values. This is different from `terms`, which defaults to excluding empty buckets.

**Example** — documents only have prices in ranges `[0,50)` and `[150,200)`:

Without `extended_bounds`:

```json
"buckets": [
  { "key": 0,   "doc_count": 12 },
  { "key": 150, "doc_count": 8  }
]
```

With `min_doc_count: 0` (default) and no `extended_bounds`:

```json
"buckets": [
  { "key": 0,   "doc_count": 12 },
  { "key": 50,  "doc_count": 0  },
  { "key": 100, "doc_count": 0  },
  { "key": 150, "doc_count": 8  }
]
```

With `extended_bounds: { "min": 0, "max": 200 }`:

```json
"buckets": [
  { "key": 0,   "doc_count": 12 },
  { "key": 50,  "doc_count": 0  },
  { "key": 100, "doc_count": 0  },
  { "key": 150, "doc_count": 8  },
  { "key": 200, "doc_count": 0  }
]
```

---

### Sub-Aggregations Within Histogram Buckets

```json
"aggs": {
  "price_distribution": {
    "histogram": {
      "field": "price",
      "interval": 50
    },
    "aggs": {
      "avg_quantity": {
        "avg": { "field": "quantity" }
      }
    }
  }
}
```

**Output** (simplified):

```json
"price_distribution": {
  "buckets": [
    { "key": 0,   "doc_count": 12, "avg_quantity": { "value": 3.2 } },
    { "key": 50,  "doc_count": 45, "avg_quantity": { "value": 1.8 } },
    { "key": 100, "doc_count": 28, "avg_quantity": { "value": 2.5 } }
  ]
}
```

---

### Comparison: `histogram` vs. `range`

Both aggregate over numeric fields but differ in how bucket boundaries are defined:

| Aspect | `histogram` | `range` |
|---|---|---|
| Bucket widths | Uniform (fixed `interval`) | Variable (user-defined per range) |
| Boundary definition | Computed automatically | Specified explicitly |
| Empty bucket handling | Supported via `min_doc_count` | Not applicable |
| Use case | Distribution analysis | Custom threshold grouping |

---

### Comparison: `histogram` vs. `date_histogram`

| Aspect | `histogram` | `date_histogram` |
|---|---|---|
| Field type | Numeric | Date / date_nanos |
| Interval unit | Numeric value | Calendar or fixed interval |
| Supports calendar awareness | No | Yes (DST, leap years) |
| Empty bucket fill | `extended_bounds` | `extended_bounds` |

---

### Visualizing Score or Value Distributions

A common use case is analyzing how documents are distributed across a computed or stored numeric field.

```json
GET /exam-results/_search
{
  "size": 0,
  "aggs": {
    "score_bands": {
      "histogram": {
        "field": "score",
        "interval": 10,
        "min_doc_count": 0,
        "extended_bounds": {
          "min": 0,
          "max": 100
        }
      }
    }
  }
}
```

This produces ten buckets covering `[0,10)` through `[90,100]`, with zero-count buckets filled in where no scores exist — suitable for rendering a complete distribution chart.

---

### Scripted Histogram

When the target value is not a direct field but a computed expression, a `script` can be used in place of `field`.

```json
"aggs": {
  "discounted_price_distribution": {
    "histogram": {
      "script": {
        "source": "doc['price'].value * 0.9",
        "lang": "painless"
      },
      "interval": 50
    }
  }
}
```

[Inference] Script-based aggregations are generally more expensive than field-based ones; performance impact may vary depending on document count and script complexity.

---

### `keyed` Response Format

Setting `"keyed": true` returns buckets as a named object map instead of an array, using the bucket key as the object key.

```json
"histogram": {
  "field": "price",
  "interval": 50,
  "keyed": true
}
```

**Output**:

```json
"price_distribution": {
  "buckets": {
    "0":   { "key": 0,   "doc_count": 12 },
    "50":  { "key": 50,  "doc_count": 45 },
    "100": { "key": 100, "doc_count": 28 }
  }
}
```

This format [Inference] may simplify client-side lookup by key in some use cases.

---

**Conclusion**

The `histogram` aggregation distributes numeric documents into equal-width intervals, making it well-suited for distribution analysis, frequency charts, and binning continuous data. Its behavior around empty buckets, boundary computation, and offset makes it flexible for both analytical and visualization-oriented use cases. For time-based data, `date_histogram` extends the same model with calendar awareness.