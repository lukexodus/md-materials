## Query DSL – Term-Level Queries: `range` Query

---

### Overview

The `range` query finds documents where a field's value falls within a specified **upper and/or lower bound**. It supports numeric, date, and string fields, and is one of the most commonly used term-level queries for structured data filtering.

Like other term-level queries, `range` does not analyze its parameters. Values are matched directly against indexed terms.

---

### Basic Syntax

```json
GET /products/_search
{
  "query": {
    "range": {
      "price": {
        "gte": 100,
        "lte": 500
      }
    }
  }
}
```

This returns documents where `price` is between 100 and 500, inclusive.

---

### Range Operators

| Parameter | Meaning |
|---|---|
| `gte` | Greater than or equal to |
| `gt` | Greater than |
| `lte` | Less than or equal to |
| `lt` | Less than |

All four parameters are optional. Any combination is valid. Omitting both bounds on one side creates an open-ended range.

**Key Points:**
- At least one bound (`gt`, `gte`, `lt`, or `lte`) must be provided.
- Upper and lower bounds can be mixed: `gt` with `lte`, `gte` with `lt`, and so on.
- Providing both `gt` and `gte` simultaneously, or both `lt` and `lte`, is not recommended. [Inference] Behavior in that case is undefined and may vary across versions. Disclaimer: Results are not guaranteed to be consistent.

---

### Numeric Range

```json
GET /employees/_search
{
  "query": {
    "range": {
      "age": {
        "gte": 25,
        "lt": 40
      }
    }
  }
}
```

Returns employees aged 25 up to (but not including) 40.

---

### Date Range

Date fields support flexible value expressions including **date math**.

#### Absolute Dates

```json
GET /events/_search
{
  "query": {
    "range": {
      "event_date": {
        "gte": "2025-01-01",
        "lte": "2025-12-31"
      }
    }
  }
}
```

---

#### Date Math

Elasticsearch supports date math expressions that are evaluated relative to a reference point.

| Expression | Meaning |
|---|---|
| `now` | Current timestamp at query time |
| `now-1d` | 24 hours ago |
| `now+1w` | One week from now |
| `now/d` | Start of the current day (rounds down) |
| `now-1M/M` | Start of last month |
| `2025-01-01\|\|+1y` | 2025-01-01 plus one year |

**Supported date math units:**

| Unit | Meaning |
|---|---|
| `y` | Year |
| `M` | Month |
| `w` | Week |
| `d` | Day |
| `h` or `H` | Hour |
| `m` | Minute |
| `s` | Second |

---

#### Date Math Example

```json
GET /logs/_search
{
  "query": {
    "range": {
      "timestamp": {
        "gte": "now-7d/d",
        "lte": "now/d"
      }
    }
  }
}
```

Returns log entries from the start of the day 7 days ago to the start of today.

**Key Points:**
- `now` is resolved at query execution time on each shard.
- [Inference] Queries using `now` without rounding (e.g., `now-1h`) are unlikely to benefit from the filter cache because the value changes every millisecond. Using `now/d` or `now/h` rounds to a fixed boundary, making caching more effective. Disclaimer: Caching behavior is not guaranteed and depends on Elasticsearch internals.

---

### Additional Parameters

#### `format`

Specifies the date format for parsing the range values when they differ from the field's mapped format.

```json
GET /sales/_search
{
  "query": {
    "range": {
      "sale_date": {
        "gte": "01/01/2025",
        "lte": "31/12/2025",
        "format": "dd/MM/yyyy"
      }
    }
  }
}
```

**Key Points:**
- The `format` parameter applies only to the range values in the query, not to the indexed data.
- If omitted, values must match the field's mapped date format.

---

#### `time_zone`

Specifies a UTC offset or IANA timezone identifier used when converting date values for comparison.

```json
GET /appointments/_search
{
  "query": {
    "range": {
      "scheduled_at": {
        "gte": "2025-06-01T00:00:00",
        "lte": "2025-06-30T23:59:59",
        "time_zone": "Asia/Manila"
      }
    }
  }
}
```

**Key Points:**
- Dates stored in Elasticsearch are always stored in UTC internally.
- The `time_zone` parameter shifts the provided range values to UTC before comparison.
- Accepts IANA timezone names (e.g., `Asia/Tokyo`, `America/New_York`) or UTC offset strings (e.g., `+08:00`).
- `now` is always UTC. Timezone offset applies only to the literal date values, not to `now`. [Unverified: confirm this behavior for your specific version.]

---

#### `boost`

A floating-point multiplier applied to the relevance score of matching documents. Defaults to `1.0`.

```json
GET /products/_search
{
  "query": {
    "range": {
      "rating": {
        "gte": 4.5,
        "lte": 5.0,
        "boost": 2.0
      }
    }
  }
}
```

**Key Points:**
- Has no effect when used in `filter` context.

---

#### `relation` (for Range Fields)

When the target field is mapped as a `range` type (e.g., `integer_range`, `date_range`), the `relation` parameter controls how the query range interacts with the stored range.

| Value | Meaning |
|---|---|
| `INTERSECTS` | Query range overlaps with the stored range (default) |
| `CONTAINS` | Stored range fully contains the query range |
| `WITHIN` | Stored range is fully within the query range |

```json
GET /reservations/_search
{
  "query": {
    "range": {
      "stay_period": {
        "gte": "2025-07-01",
        "lte": "2025-07-10",
        "relation": "INTERSECTS"
      }
    }
  }
}
```

**Key Points:**
- `relation` is only applicable when the field is mapped as a **range data type** (e.g., `date_range`, `integer_range`, `ip_range`).
- For standard scalar fields, `relation` is ignored.

---

### String Range

`range` can be applied to `keyword` fields, matching terms in **lexicographic order**.

```json
GET /products/_search
{
  "query": {
    "range": {
      "sku.keyword": {
        "gte": "SKU-100",
        "lte": "SKU-200"
      }
    }
  }
}
```

**Key Points:**
- Lexicographic ordering is used, not numeric ordering. `"SKU-100"` comes before `"SKU-20"` lexicographically because `"1"` < `"2"` as characters.
- [Inference] String range queries are less common in practice and require careful consideration of sort order. Disclaimer: Results depend entirely on the lexicographic ordering of the indexed terms.
- Avoid using `range` on `text` fields. Results are unreliable because the analyzed tokens may not reflect the original string ordering.

---

### Using `range` in a `filter` Context

As with other term-level queries, `range` is most commonly used in `filter` context when scoring is not required.

```json
GET /transactions/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "refund request" } }
      ],
      "filter": [
        {
          "range": {
            "amount": {
              "gte": 50,
              "lte": 1000
            }
          }
        },
        {
          "range": {
            "created_at": {
              "gte": "now-30d/d"
            }
          }
        }
      ]
    }
  }
}
```

**Key Points:**
- The `match` clause contributes to relevance scoring.
- Both `range` filters restrict results without affecting the score.
- [Inference] Date range filters using rounded `now` expressions (e.g., `now-30d/d`) are more likely to be served from the filter cache than unrounded ones. Disclaimer: Cache behavior is not guaranteed.

---

### Open-Ended Ranges

Either bound can be omitted to create a one-sided range.

**Greater than or equal to only:**
```json
{ "range": { "stock_count": { "gte": 1 } } }
```

**Less than only:**
```json
{ "range": { "price": { "lt": 50 } } }
```

**Key Points:**
- Open-ended ranges are valid and commonly used for existence-style filtering (e.g., "any document with at least one item in stock").
- This is distinct from the `exists` query — `range` with a lower bound of `gte: 1` on a numeric field excludes documents with a value of `0`, whereas `exists` only checks for field presence.

---

### `range` on Nested Fields

When the range field is inside a `nested` object, the query must be wrapped in a `nested` query.

```json
GET /orders/_search
{
  "query": {
    "nested": {
      "path": "items",
      "query": {
        "range": {
          "items.quantity": {
            "gte": 5
          }
        }
      }
    }
  }
}
```

---

### Performance Considerations

- `range` queries on **numeric fields** are generally efficient due to Elasticsearch's use of BKD tree data structures for numeric indexing.
- `range` queries on **date fields** benefit from the same BKD-based structure.
- `range` queries on **keyword fields** involve term dictionary traversal and may be less efficient for wide ranges.
- [Inference] For date range queries in high-frequency dashboards (e.g., log monitoring), using rounded `now` expressions improves filter cache hit rates compared to unrounded timestamps. Disclaimer: Performance outcomes depend on cluster configuration and are not guaranteed.

---

### `range` vs Other Queries for Bounds Checking

| Approach | Use Case |
|---|---|
| `range` | Value falls within numeric, date, or lexicographic bounds |
| `exists` | Field is present (non-null) |
| `term` | Exact single value match |
| `terms` | Match any of a fixed set of values |
| `terms_set` | At least N of a set of values match |

---

### Full Example

```json
GET /flights/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "destination": "Tokyo"
          }
        }
      ],
      "filter": [
        {
          "range": {
            "departure_time": {
              "gte": "now+1d/d",
              "lte": "now+7d/d",
              "time_zone": "Asia/Tokyo"
            }
          }
        },
        {
          "range": {
            "price_usd": {
              "gte": 300,
              "lte": 900
            }
          }
        },
        {
          "range": {
            "available_seats": {
              "gte": 1
            }
          }
        }
      ]
    }
  }
}
```

**Output (representative structure):**

```json
{
  "hits": {
    "hits": [
      {
        "_index": "flights",
        "_id": "FL-4421",
        "_score": 2.94,
        "_source": {
          "destination": "Tokyo",
          "departure_time": "2025-06-05T09:30:00Z",
          "price_usd": 620,
          "available_seats": 4
        }
      }
    ]
  }
}
```

---

**Conclusion:**

The `range` query is the standard mechanism for bounded value filtering in Elasticsearch, covering numeric, date, and string fields. Its date math support makes it particularly powerful for time-based queries such as log analysis, event filtering, and dashboard-driven searches. For best performance, `range` should be placed in `filter` context when scoring is not needed, and date expressions should use rounding where possible to improve filter cache effectiveness. When working with fields mapped as range types, the `relation` parameter provides additional control over how query and stored ranges are compared.