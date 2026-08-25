### Range Aggregation

The `range` aggregation is a bucket aggregation that groups documents into user-defined numeric ranges. Unlike `histogram`, which computes uniform intervals automatically, `range` accepts explicit boundary definitions — making it appropriate when meaningful thresholds are domain-specific rather than mathematically uniform.

---

#### Basic Syntax

json

```
GET /my-index/_search
{
  "size": 0,
  "aggs": {
    "price_ranges": {
      "range": {
        "field": "price",
        "ranges": [
          { "to": 50 },
          { "from": 50, "to": 100 },
          { "from": 100, "to": 200 },
          { "from": 200 }
        ]
      }
    }
  }
}
```

**Output** (simplified):

json

```
"aggregations": {
  "price_ranges": {
    "buckets": [
      { "key": "*-50.0",     "to": 50.0,  "doc_count": 24 },
      { "key": "50.0-100.0", "from": 50.0,  "to": 100.0, "doc_count": 62 },
      { "key": "100.0-200.0","from": 100.0, "to": 200.0, "doc_count": 41 },
      { "key": "200.0-*",    "from": 200.0, "doc_count": 18 }
    ]
  }
}
```

---

#### Bucket Boundary Rules

Each range entry may specify `from`, `to`, or both. Boundaries follow these rules:

- `from` is **inclusive**: a document with exactly `from` value falls into this bucket.
- `to` is **exclusive**: a document with exactly `to` value falls into the next bucket.
- Omitting `from` creates an open lower bound (matches everything below `to`).
- Omitting `to` creates an open upper bound (matches everything from `from` upward).

| Range Definition | Matches |
| --- | --- |
| `{ "to": 50 }` | `value < 50` |
| `{ "from": 50, "to": 100 }` | `50 <= value < 100` |
| `{ "from": 100 }` | `value >= 100` |

---

#### A Document Belongs to At Most One Bucket

Unlike `filters`, range buckets are mutually exclusive by default when defined without overlap. A document with `price: 50` falls into `[50, 100)`, not `[0, 50)`.

If ranges are defined with overlapping boundaries, a document may be counted in multiple buckets. [Inference] Overlapping ranges are permitted by Elasticsearch but may produce unexpected `doc_count` totals if not intentional.

---

#### Custom Bucket Keys

By default, bucket keys are auto-generated as `"from-to"` strings (e.g., `"50.0-100.0"`). Custom keys can be assigned using the `key` property on each range entry.

json

```
"ranges": [
  { "key": "budget",   "to": 50 },
  { "key": "mid-range","from": 50, "to": 200 },
  { "key": "premium",  "from": 200 }
]
```

**Output**:

json

```
"buckets": [
  { "key": "budget",    "to": 50.0,   "doc_count": 24 },
  { "key": "mid-range", "from": 50.0, "to": 200.0, "doc_count": 103 },
  { "key": "premium",   "from": 200.0,"doc_count": 18 }
]
```

Custom keys improve readability in responses and [Inference] simplify downstream parsing in application code.

---

#### `keyed` Response Format

Setting `"keyed": true` returns buckets as a named object map instead of an array, using the bucket key as the object property name.

json

```
"range": {
  "field": "price",
  "keyed": true,
  "ranges": [
    { "key": "budget",    "to": 50 },
    { "key": "mid-range", "from": 50, "to": 200 },
    { "key": "premium",   "from": 200 }
  ]
}
```

**Output**:

json

```
"price_ranges": {
  "buckets": {
    "budget":    { "to": 50.0,   "doc_count": 24  },
    "mid-range": { "from": 50.0, "to": 200.0, "doc_count": 103 },
    "premium":   { "from": 200.0,"doc_count": 18  }
  }
}
```

---

#### Sub-Aggregations

json

```
"aggs": {
  "price_ranges": {
    "range": {
      "field": "price",
      "ranges": [
        { "key": "budget",   "to": 50 },
        { "key": "standard", "from": 50, "to": 200 },
        { "key": "premium",  "from": 200 }
      ]
    },
    "aggs": {
      "avg_rating": {
        "avg": { "field": "rating" }
      },
      "top_categories": {
        "terms": {
          "field": "category.keyword",
          "size": 3
        }
      }
    }
  }
}
```

**Output** (simplified):

json

```
"price_ranges": {
  "buckets": [
    {
      "key": "budget",
      "to": 50.0,
      "doc_count": 24,
      "avg_rating": { "value": 3.8 },
      "top_categories": {
        "buckets": [
          { "key": "accessories", "doc_count": 10 },
          { "key": "clothing",    "doc_count": 8  }
        ]
      }
    },
    {
      "key": "premium",
      "from": 200.0,
      "doc_count": 18,
      "avg_rating": { "value": 4.6 },
      "top_categories": {
        "buckets": [
          { "key": "electronics", "doc_count": 12 }
        ]
      }
    }
  ]
}
```

---

#### `missing`

Assigns documents where the field is absent to a virtual value, which is then evaluated against the defined ranges.

json

```
"range": {
  "field": "price",
  "missing": 0,
  "ranges": [
    { "to": 50 },
    { "from": 50 }
  ]
}
```

Documents without a `price` field are treated as if `price: 0` and routed to the appropriate bucket.

---

#### Script-Based Range Aggregation

When the bucketing value is computed rather than stored, a `script` can replace `field`.

json

```
"aggs": {
  "discounted_price_ranges": {
    "range": {
      "script": {
        "source": "doc['price'].value * params.discount",
        "lang": "painless",
        "params": {
          "discount": 0.8
        }
      },
      "ranges": [
        { "key": "under_40",  "to": 40 },
        { "key": "40_to_100", "from": 40, "to": 100 },
        { "key": "over_100",  "from": 100 }
      ]
    }
  }
}
```

[Inference] Script-based aggregations are generally more expensive than field-based ones; performance impact may vary depending on document count and script complexity.

---

#### `date_range` Aggregation

For date fields, Elasticsearch provides a dedicated `date_range` aggregation that accepts date values and date math expressions as boundary values.

json

```
"aggs": {
  "order_date_ranges": {
    "date_range": {
      "field": "order_date",
      "format": "yyyy-MM-dd",
      "ranges": [
        { "key": "older",        "to": "now-1y" },
        { "key": "last_year",    "from": "now-1y", "to": "now-30d" },
        { "key": "last_30_days", "from": "now-30d" }
      ]
    }
  }
}
```

**Output** (simplified):

json

```
"order_date_ranges": {
  "buckets": [
    { "key": "older",        "to_as_string": "2023-06-03", "doc_count": 540 },
    { "key": "last_year",    "from_as_string": "2023-06-03", "to_as_string": "2024-05-04", "doc_count": 312 },
    { "key": "last_30_days", "from_as_string": "2024-05-04", "doc_count": 87  }
  ]
}
```

**Key Points**

- `date_range` accepts ISO 8601 strings, epoch milliseconds, and date math.
- `format` controls how `from_as_string` and `to_as_string` are rendered.
- `time_zone` is supported to shift boundary evaluation to a local time zone.
- `keyed: true` is supported.
- Like `range`, boundaries are inclusive-from, exclusive-to.

---

#### `ip_range` Aggregation

For IP address fields, Elasticsearch provides `ip_range`, which supports both explicit ranges and CIDR notation.

json

```
"aggs": {
  "ip_segments": {
    "ip_range": {
      "field": "client_ip",
      "ranges": [
        { "key": "private_a", "mask": "10.0.0.0/8"    },
        { "key": "private_b", "mask": "172.16.0.0/12" },
        { "key": "private_c", "mask": "192.168.0.0/16" }
      ]
    }
  }
}
```

Or using explicit `from` / `to`:

json

```
"ranges": [
  { "from": "10.0.0.1", "to": "10.0.0.255" }
]
```

---

#### Comparison: `range` vs. `histogram`

| Aspect | `range` | `histogram` |
| --- | --- | --- |
| Bucket boundaries | User-defined, variable width | Computed, uniform width |
| Number of buckets | Fixed (as defined) | Dynamic (depends on data) |
| Empty bucket handling | Not applicable | Supported via `min_doc_count` |
| Domain alignment | High — thresholds are explicit | Lower — depends on interval fit |
| Use case | Known thresholds (SLA tiers, price bands) | Distribution analysis |

---

#### Comparison: `range`, `date_range`, and `ip_range`

| Aggregation | Field Type | Boundary Format |
| --- | --- | --- |
| `range` | Numeric | Numbers |
| `date_range` | Date / date_nanos | ISO 8601, epoch ms, date math |
| `ip_range` | IP | IP strings, CIDR notation |

All three share the same structural pattern and support `keyed`, `missing`, custom `key` labels, and sub-aggregations.

---

#### When to Use `range`

`range` is appropriate when:

- Bucket thresholds have semantic meaning (e.g., pricing tiers, age groups, score bands, SLA categories)
- The number of buckets is known and fixed in advance
- Intervals are unequal by design
- A `histogram` would require a non-intuitive interval to align with domain boundaries

---

**Conclusion**

The `range` aggregation provides explicit control over bucket boundaries, making it the right choice when grouping criteria are domain-defined rather than mathematically derived. Its variants — `date_range` and `ip_range` — extend the same pattern to date and IP field types respectively. Combined with custom keys, `keyed` responses, and sub-aggregations, the range family covers a wide class of threshold-based segmentation use cases.