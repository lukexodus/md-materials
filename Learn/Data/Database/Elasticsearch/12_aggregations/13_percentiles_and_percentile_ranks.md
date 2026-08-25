## Aggregations — Percentiles and Percentile\_Ranks

### Overview

Percentile aggregations are metric aggregations that compute the distribution of numeric values across documents. Rather than returning a single summary statistic like an average, they answer questions like *"What value is 95% of requests faster than?"* or *"What percentage of responses finished within 200ms?"*

Elasticsearch provides two complementary aggregations:

- `percentiles` — given a field, return the value at specified percentile thresholds
- `percentile_ranks` — given a field and specific values, return what percentile rank those values fall at

Both use approximate algorithms by default, trading a small, bounded error margin for dramatically reduced memory usage at scale.

---

### percentiles Aggregation

#### Syntax

```json
GET /index/_search
{
  "size": 0,
  "aggs": {
    "response_time_percentiles": {
      "percentiles": {
        "field": "response_time_ms"
      }
    }
  }
}
```

By default, Elasticsearch computes percentiles at: `1, 5, 25, 50, 75, 95, 99`.

#### Custom Percentile Thresholds

```json
"percentiles": {
  "field": "response_time_ms",
  "percents": [50, 90, 95, 99, 99.9]
}
```

#### Example Response

```json
"aggregations": {
  "response_time_percentiles": {
    "values": {
      "50.0": 142.3,
      "90.0": 380.7,
      "95.0": 520.1,
      "99.0": 1024.5,
      "99.9": 3200.0
    }
  }
}
```

**Output interpretation:** 99% of requests completed within approximately 1024.5ms. The value at `99.9` reveals the tail latency behavior.

---

### percentile\_ranks Aggregation

Instead of asking *"what value sits at percentile X?"*, `percentile_ranks` asks *"what percentile does value X sit at?"*

#### Syntax

```json
GET /index/_search
{
  "size": 0,
  "aggs": {
    "sla_compliance": {
      "percentile_ranks": {
        "field": "response_time_ms",
        "values": [200, 500, 1000]
      }
    }
  }
}
```

#### Example Response

```json
"aggregations": {
  "sla_compliance": {
    "values": {
      "200.0": 61.3,
      "500.0": 87.9,
      "1000.0": 98.2
    }
  }
}
```

**Output interpretation:** Approximately 61.3% of requests completed within 200ms; 98.2% completed within 1000ms. This directly answers SLA compliance questions.

---

### The TDigest Algorithm

By default, both aggregations use **TDigest**, a sketch-based algorithm that maintains a compressed representation of the distribution.

#### How it works

TDigest clusters values into centroids. Centroids near the extreme ends of the distribution (very low and very high percentiles) are kept smaller and more precise, while centroids in the middle are larger and less precise. This is intentional: tail accuracy is more operationally valuable than median accuracy in most use cases.

#### Controlling Compression

```json
"percentiles": {
  "field": "response_time_ms",
  "tdigest": {
    "compression": 200
  }
}
```

- `compression` controls the trade-off between memory usage and accuracy.
- Default is `100`. Higher values increase accuracy and memory consumption.
- [Inference] Setting `compression` very high on high-cardinality fields or large shards may noticeably increase heap pressure — behavior may vary by cluster configuration and data shape.

#### Error Characteristics

Elasticsearch documents that TDigest percentile results are **approximate**. The relative error is typically small but is not zero and is not guaranteed to be within a fixed bound in all cases. Errors are generally larger at extreme percentiles (e.g., `99.9`) and smaller near the median.

---

### The HDR Histogram Algorithm

An alternative to TDigest is **HDR Histogram** (High Dynamic Range Histogram). It trades higher memory usage for more consistent accuracy across all percentile values.

```json
"percentiles": {
  "field": "response_time_ms",
  "hdr": {
    "number_of_significant_value_digits": 3
  }
}
```

- `number_of_significant_value_digits` controls precision. Valid values: `1–5`.
- HDR Histogram is appropriate when the field contains **integer values with a known bounded range** (e.g., latencies in microseconds).
- HDR Histogram is **not suitable** for floating-point fields or fields with very large value ranges, as memory usage grows with the range of values.

#### TDigest vs HDR Histogram

| Property | TDigest | HDR Histogram |
|---|---|---|
| Memory usage | Low (adaptive) | Higher (range-dependent) |
| Accuracy at extremes | Good but variable | Consistent |
| Floating-point support | Yes | No (integers only) |
| Default | Yes | No |

---

### Keyed Response Format

Both aggregations support a `keyed` parameter that changes the response structure from a flat object to a named key format — useful when parsing responses programmatically.

```json
"percentiles": {
  "field": "response_time_ms",
  "keyed": false
}
```

With `keyed: false`, the response returns an array of `{ key, value }` objects instead of a plain object. Default is `true` (plain object).

---

### Missing Values

Use `missing` to specify a default value for documents that do not have the target field:

```json
"percentiles": {
  "field": "response_time_ms",
  "missing": 0
}
```

Documents missing `response_time_ms` will be treated as if they had the value `0`. Without this, such documents are excluded from the computation.

---

### Script-Based Percentiles

A runtime value or transformation can be used in place of a field:

```json
"percentiles": {
  "script": {
    "source": "doc['response_time_ms'].value * 1.1"
  },
  "percents": [50, 95, 99]
}
```

This applies a 10% overhead adjustment before computing percentiles. Scripted aggregations carry a performance cost and should be used with awareness of their impact at scale.

---

### Nesting Inside Bucket Aggregations

Percentile aggregations are frequently nested inside bucket aggregations to compute per-group distributions.

```json
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "by_service": {
      "terms": {
        "field": "service.keyword",
        "size": 10
      },
      "aggs": {
        "latency_percentiles": {
          "percentiles": {
            "field": "response_time_ms",
            "percents": [50, 95, 99]
          }
        }
      }
    }
  }
}
```

**Output:** For each of the top 10 services, returns p50, p95, and p99 latency. This is a common pattern for SLA monitoring dashboards.

---

### Combining percentiles and percentile\_ranks

The two aggregations can be run together to cross-validate distribution understanding:

```json
"aggs": {
  "latency_pcts": {
    "percentiles": {
      "field": "response_time_ms",
      "percents": [95, 99]
    }
  },
  "sla_ranks": {
    "percentile_ranks": {
      "field": "response_time_ms",
      "values": [500, 1000]
    }
  }
}
```

Running both in one request costs minimal overhead beyond a single aggregation, since the underlying data pass is shared.

---

### Approximate Nature — Important Caveats

- Results are **not deterministic across shards** in all configurations. [Inference] Shard-level merging of TDigest sketches introduces additional approximation error whose magnitude depends on data distribution and shard count — behavior may vary.
- Results should not be used where exact values are required (e.g., billing calculations, legal thresholds).
- For exact percentiles on small datasets, consider fetching raw values and computing client-side, or using `sort` + `from`/`size` to find specific ranked documents.

---

### Practical Use Cases

| Use Case | Aggregation | Notes |
|---|---|---|
| Latency p95/p99 monitoring | `percentiles` | Standard SRE/ops pattern |
| SLA compliance reporting | `percentile_ranks` | "What % of requests met the SLA?" |
| Outlier detection threshold setting | `percentiles` | Use p99 or p99.9 as anomaly floor |
| Histogram shape exploration | `percentiles` with many percents | Approximate CDF reconstruction |
| A/B test distribution comparison | Both, nested under `terms` | Compare distributions per variant |

---

**Conclusion:** `percentiles` and `percentile_ranks` are complementary tools for understanding value distributions at scale. `percentiles` answers threshold questions; `percentile_ranks` answers compliance questions. Both rely on approximate algorithms — TDigest by default, HDR Histogram as an opt-in alternative — and their results should be interpreted with awareness that they are estimates, not exact values. Nesting either inside bucket aggregations is the standard pattern for per-segment or per-group distribution analysis.