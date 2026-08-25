## avg, sum, min, max, value_count

### Overview

These five aggregations are the foundational metric aggregations in Elasticsearch. Each is a **single-value aggregation** — it returns exactly one numeric result per bucket. They are exact (not approximate), straightforward to configure, and serve as the building blocks for most analytical queries.

---

### Shared Behavior

All five aggregations share a common set of parameters and behavioral rules. Understanding them once applies to all.

#### Common Parameters

| Parameter | Required | Description |
|---|---|---|
| `field` | Yes (or `script`) | The numeric field to aggregate over |
| `script` | No | Compute values dynamically instead of or alongside `field` |
| `missing` | No | Default value for documents missing the field |

#### Field Type Requirements

All five aggregations require the target field to be a **numeric type** in the mapping:

- `integer`, `long`, `short`, `byte`
- `float`, `double`, `half_float`, `scaled_float`
- `unsigned_long`

Applying these aggregations to non-numeric fields (e.g., `keyword`, `text`) will return an error or no result. [Inference] Behavior on unsupported types may vary by Elasticsearch version.

#### Missing Values

By default, documents without a value for the specified field are **excluded** from the computation. The `missing` parameter overrides this, substituting a default value for those documents.

```json
"avg": {
  "field": "rating",
  "missing": 0
}
```

#### Script Support

Any of the five aggregations can use a `script` in place of or combined with `field`:

```json
"sum": {
  "script": {
    "source": "doc['price'].value * doc['quantity'].value"
  }
}
```

Or with `_value` to transform a field:

```json
"avg": {
  "field": "price",
  "script": {
    "source": "_value * 1.18"
  }
}
```

[Inference] Script-based aggregations are generally slower than doc-value-based ones. Performance impact depends on script complexity and document volume. Behavior may vary.

---

### avg

Computes the **arithmetic mean** of all numeric values for the specified field across documents in scope.

**Formula**

```
avg = sum of all values / count of documents with a value
```

**Example**

Average order amount:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "avg_amount": {
      "avg": { "field": "amount" }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "avg_amount": { "value": 84.30 }
  }
}
```

If no documents have a value for `amount`, the result is `null`.

**Common Use Cases**
- Average order value, session duration, response time
- Per-bucket averages inside `terms` or `date_histogram` aggregations

---

### sum

Computes the **total sum** of all numeric values for the specified field.

**Example**

Total revenue across all orders:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "total_revenue": {
      "sum": { "field": "amount" }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "total_revenue": { "value": 1042300.50 }
  }
}
```

**Key Points**
- Returns `0` (not `null`) when no documents match, unlike `avg`, `min`, and `max`
- Useful in pipeline aggregations as a denominator or running total

**Common Use Cases**
- Total sales, total inventory, total bytes transferred
- Summing computed values via script (e.g., `price * quantity`)

---

### min

Returns the **lowest value** found for the specified field across all documents in scope.

**Example**

Cheapest product price:

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "cheapest": {
      "min": { "field": "price" }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "cheapest": { "value": 4.99 }
  }
}
```

**Key Points**
- Returns `null` when no documents have a value for the field
- Also works on `date` fields, returning the earliest timestamp as a numeric epoch value; set `format` to receive a human-readable string

**Date field example**

```json
GET /events/_search
{
  "size": 0,
  "aggs": {
    "earliest_event": {
      "min": {
        "field": "event_date",
        "format": "yyyy-MM-dd"
      }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "earliest_event": {
      "value": 1704067200000,
      "value_as_string": "2024-01-01"
    }
  }
}
```

---

### max

Returns the **highest value** found for the specified field across all documents in scope.

**Example**

Most expensive product:

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "most_expensive": {
      "max": { "field": "price" }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "most_expensive": { "value": 2499.00 }
  }
}
```

**Key Points**
- Returns `null` when no documents have a value for the field
- Supports `date` fields with `format`, identical to `min`
- Commonly used with pipeline aggregations (e.g., `max_bucket`) to find the bucket with the highest metric value

**Common Use Cases**
- Peak response time, highest sale amount, latest recorded timestamp
- Bounding the range of a dataset before deciding on histogram intervals

---

### value_count

Counts the **number of values** extracted for the specified field. This is not the same as the document count (`doc_count`): it counts values, not documents. For single-value fields these are usually equal, but for multi-value fields they can differ.

**Example**

Count how many orders have an `amount` field:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "orders_with_amount": {
      "value_count": { "field": "amount" }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "orders_with_amount": { "value": 3820 }
  }
}
```

**Key Points**
- Returns `0` (not `null`) when no documents have a value for the field
- On a multi-value field, counts each value individually (one document with 3 tags contributes 3 to the count)
- Works on any field type, not limited to numeric fields
- Often used to verify data completeness or as a denominator in custom ratio calculations

**doc_count vs. value_count**

| Scenario | `doc_count` | `value_count` |
|---|---|---|
| 100 docs, each with one value | 100 | 100 |
| 100 docs, each with 3 values | 100 | 300 |
| 100 docs, 10 missing the field | 100 | 90 |

---

### Using Multiple Metrics Together

All five can be requested in the same aggregation block:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_region": {
      "terms": { "field": "region" },
      "aggs": {
        "avg_amount":   { "avg":         { "field": "amount" } },
        "total_amount": { "sum":         { "field": "amount" } },
        "min_amount":   { "min":         { "field": "amount" } },
        "max_amount":   { "max":         { "field": "amount" } },
        "order_count":  { "value_count": { "field": "amount" } }
      }
    }
  }
}
```

**Output (one bucket shown)**

```json
{
  "key": "APAC",
  "doc_count": 940,
  "avg_amount":   { "value": 91.20 },
  "total_amount": { "value": 85728.00 },
  "min_amount":   { "value": 5.00 },
  "max_amount":   { "value": 1200.00 },
  "order_count":  { "value": 940 }
}
```

[Inference] Running all five individually is less efficient than using `stats`, which computes `min`, `max`, `avg`, `sum`, and `count` in a single pass. For most cases where all five values are needed, `stats` is preferable. Behavior may vary by version.

---

### Null Behavior Summary

| Aggregation | No documents with field value |
|---|---|
| `avg` | `null` |
| `sum` | `0` |
| `min` | `null` |
| `max` | `null` |
| `value_count` | `0` |

---

### Pipeline Aggregation Compatibility

All five are single-value metrics and can be referenced directly by pipeline aggregations using `buckets_path`.

**Example — find the region with the highest total revenue**

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_region": {
      "terms": { "field": "region" },
      "aggs": {
        "total_revenue": { "sum": { "field": "amount" } }
      }
    },
    "top_region": {
      "max_bucket": {
        "buckets_path": "by_region>total_revenue"
      }
    }
  }
}
```

---

### Comparison Summary

| Aggregation | Returns | Null when empty | Works on dates | Works on non-numeric |
|---|---|---|---|---|
| `avg` | Mean | Yes | No | No |
| `sum` | Total | No (`0`) | No | No |
| `min` | Lowest value | Yes | Yes | No |
| `max` | Highest value | Yes | Yes | No |
| `value_count` | Count of values | No (`0`) | Yes | Yes |

---

**Conclusion**

`avg`, `sum`, `min`, `max`, and `value_count` are the most commonly used metric aggregations. They are exact, efficient, and broadly compatible with pipeline aggregations. Their shared parameters — `field`, `script`, and `missing` — apply consistently across all five. When all of `avg`, `sum`, `min`, `max`, and count are needed simultaneously, the `stats` aggregation computes them in a single pass and is generally the more efficient choice.

**Next Steps**
- Use `stats` or `extended_stats` when multiple of these metrics are needed in one request
- Explore `weighted_avg` when documents should contribute unequally to an average
- Apply `missing` deliberately to control how incomplete data affects results