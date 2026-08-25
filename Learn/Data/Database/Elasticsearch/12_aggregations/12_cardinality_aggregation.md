## Cardinality Aggregation

### Overview

The cardinality aggregation computes the **approximate** count of distinct values in a field. It is a metric aggregation that answers the question: *how many unique values exist for this field across the matched documents?*

This is analogous to `COUNT(DISTINCT field)` in SQL.

---

### How It Works

Elasticsearch uses the **HyperLogLog++ (HLL++)** algorithm to estimate cardinality. Rather than tracking every unique value exactly, HLL++ uses a probabilistic data structure that trades a small amount of accuracy for significantly reduced memory usage.

**Key Points:**
- Results are approximate, not exact
- Memory usage is bounded regardless of dataset size
- Accuracy is tunable via the `precision_threshold` parameter

---

### Basic Syntax

```json
GET /index/_search
{
  "size": 0,
  "aggs": {
    "unique_users": {
      "cardinality": {
        "field": "user_id"
      }
    }
  }
}
```

**Output:**
```json
{
  "aggregations": {
    "unique_users": {
      "value": 15240
    }
  }
}
```

The result is a single numeric value representing the estimated distinct count.

---

### The `precision_threshold` Parameter

The `precision_threshold` parameter controls the trade-off between accuracy and memory.

```json
"cardinality": {
  "field": "user_id",
  "precision_threshold": 40000
}
```

**Key Points:**
- Accepts values between `1` and `40000`
- Default value is `3000`
- When the true cardinality is **below** the threshold, accuracy is very high (close to exact)
- When the true cardinality **exceeds** the threshold, results become increasingly approximate
- Higher values consume more memory — approximately `precision_threshold * 8` bytes per aggregation per shard

> [Inference] Setting `precision_threshold` equal to or greater than your expected distinct count will generally yield more accurate results, though exact accuracy is not guaranteed as behavior depends on data distribution and HLL++ internals.

---

### Supported Field Types

Cardinality aggregation works on most field types, including:

- `keyword`
- `integer`, `long`, `short`, `byte`
- `double`, `float`
- `date`
- `ip`
- `boolean`

It does **not** work directly on `text` fields unless a `keyword` sub-field or `fielddata` is enabled.

**Example** — using a sub-field:

```json
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "unique_hosts": {
      "cardinality": {
        "field": "host.keyword"
      }
    }
  }
}
```

---

### Using a Script

When a field does not exist or you need to derive a value, a script can be used.

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "unique_skus": {
      "cardinality": {
        "script": {
          "source": "doc['product_id'].value + '_' + doc['warehouse_id'].value"
        }
      }
    }
  }
}
```

> [Inference] Script-based cardinality is expected to be slower than field-based cardinality due to per-document script execution overhead. Behavior and performance may vary based on cluster configuration and data volume.

---

### Combining with Other Aggregations

Cardinality is commonly nested inside bucket aggregations to compute distinct counts per bucket.

**Example** — unique users per country:

```json
GET /events/_search
{
  "size": 0,
  "aggs": {
    "by_country": {
      "terms": {
        "field": "country.keyword"
      },
      "aggs": {
        "unique_users": {
          "cardinality": {
            "field": "user_id"
          }
        }
      }
    }
  }
}
```

**Output:**
```json
{
  "aggregations": {
    "by_country": {
      "buckets": [
        { "key": "US", "doc_count": 50000, "unique_users": { "value": 12400 } },
        { "key": "DE", "doc_count": 18000, "unique_users": { "value": 4300 } }
      ]
    }
  }
}
```

---

### Missing Values

The `missing` parameter defines a default value for documents where the target field is absent. Those documents will be counted using this substitute value.

```json
"cardinality": {
  "field": "session_id",
  "missing": "NO_SESSION"
}
```

Without `missing`, documents lacking the field are ignored entirely.

---

### Performance Considerations

| Factor | Impact |
|---|---|
| High `precision_threshold` | Higher memory per shard, better accuracy |
| Low `precision_threshold` | Lower memory, reduced accuracy |
| Script usage | Increased CPU cost per document |
| High-cardinality fields | Results more approximate past the threshold |
| Number of shards | Each shard runs HLL++ independently; results are merged |

> [Inference] Cardinality aggregation on very high-cardinality fields (e.g., UUIDs in the hundreds of millions) with a low `precision_threshold` may produce results with noticeable deviation from the true count. Actual deviation depends on data distribution and is not guaranteed to fall within any specific range.

---

### Accuracy Characteristics

The HLL++ algorithm has a theoretical standard error of approximately:

```
error ≈ 1.04 / sqrt(precision_threshold)
```

**Example** — at the default `precision_threshold` of `3000`:

```
1.04 / sqrt(3000) ≈ 0.019  →  ~1.9% error
```

At `precision_threshold: 40000`:

```
1.04 / sqrt(40000) ≈ 0.0052  →  ~0.52% error
```

> These are theoretical approximations based on the HLL++ algorithm design. Actual error in practice may differ and is not guaranteed to match these figures.

---

### When to Use Cardinality Aggregation

Use cardinality aggregation when:

- You need an approximate distinct count at scale
- Exact counts are not strictly required
- You are working with high-volume data where exact `value_count` on deduplicated data would be prohibitively expensive

Avoid it when:

- Exact distinct counts are a hard requirement (consider application-level computation or using a `terms` aggregation with care)
- The field has very low cardinality — in those cases, a `terms` aggregation with `size` set appropriately may give exact counts at comparable cost

---

**Conclusion:**
The cardinality aggregation is a memory-efficient, scalable way to estimate distinct value counts in Elasticsearch. Its accuracy is controlled through `precision_threshold`, and understanding the HLL++ approximation model is important for interpreting results correctly. It integrates naturally into bucket aggregation pipelines for per-group distinct counting.