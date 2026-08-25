## Bucket Aggregations Overview

Bucket aggregations group documents into collections called **buckets** based on a criterion. Unlike metric aggregations, which return a single computed value, bucket aggregations return a set of buckets — each containing a subset of documents and a document count. Sub-aggregations can then run within each bucket's scope.

---

### How Bucket Aggregations Work

When a bucket aggregation executes, Elasticsearch evaluates each document against the bucketing criterion and places it into one or more matching buckets. Each bucket in the result contains:

- `key` — the value that defines the bucket (e.g., a term, a range boundary, a date interval)
- `doc_count` — the number of documents that fall into that bucket
- Any sub-aggregation results scoped to that bucket

---

### General Response Shape

```json
"aggregations": {
  "<bucket_agg_name>": {
    "buckets": [
      {
        "key": "<bucket_key>",
        "doc_count": <n>,
        "<sub_agg_name>": { ... }
      },
      ...
    ]
  }
}
```

Some bucket aggregations return buckets as an array (e.g., `terms`, `date_histogram`). Others return buckets as a named object (e.g., `filters`). The shape depends on the aggregation type.

---

### Categories of Bucket Aggregations

Bucket aggregations can be grouped by the nature of their bucketing criterion:

| Category | Description | Examples |
|---|---|---|
| **Value-based** | Buckets based on field values | `terms`, `rare_terms`, `significant_terms` |
| **Range-based** | Buckets defined by explicit ranges | `range`, `date_range`, `ip_range` |
| **Interval-based** | Buckets defined by fixed intervals | `histogram`, `date_histogram`, `auto_date_histogram` |
| **Filter-based** | Buckets defined by query conditions | `filter`, `filters` |
| **Geo-based** | Buckets based on geographic data | `geo_distance`, `geohash_grid`, `geotile_grid` |
| **Nesting / join** | Buckets based on document structure | `nested`, `reverse_nested`, `parent`, `children` |
| **Adjacency / matrix** | Buckets from intersections of filters | `adjacency_matrix` |
| **Sampled** | Buckets over a sampled subset | `sampler`, `diversified_sampler` |

---

### A Document Can Belong to Multiple Buckets

Unlike SQL `GROUP BY`, a single document can fall into more than one bucket depending on the aggregation type. For example, a `filters` aggregation with overlapping filter conditions may count the same document in multiple buckets.

[Inference] Whether a document lands in one bucket or many depends entirely on the aggregation type and configuration; behavior should be verified against the specific aggregation's documentation.

---

### Bucket Aggregations vs. Metric Aggregations

| Aspect | Bucket | Metric |
|---|---|---|
| Output | Set of buckets | Single computed value |
| Can contain sub-aggs | Yes | No |
| Defines a new scope | Yes, per bucket | No |
| Returns `doc_count` | Yes | No |

---

### Sub-Aggregations Within Buckets

Any aggregation — metric or bucket — can be nested inside a bucket aggregation. The sub-aggregation runs independently within each bucket's document scope.

```json
"aggs": {
  "by_status": {
    "terms": {
      "field": "status.keyword"
    },
    "aggs": {
      "avg_amount": {
        "avg": { "field": "amount" }
      }
    }
  }
}
```

**Output** (simplified):

```json
"by_status": {
  "buckets": [
    { "key": "completed", "doc_count": 300, "avg_amount": { "value": 74.2 } },
    { "key": "pending",   "doc_count": 120, "avg_amount": { "value": 38.1 } }
  ]
}
```

---

### `doc_count` Accuracy

For most bucket aggregations, `doc_count` is exact. However, for distributed aggregations across shards — particularly `terms` — `doc_count` may be an approximation due to how results are reduced across shards.

Where approximation applies, Elasticsearch returns additional fields in the response:

- `doc_count_error_upper_bound` — the maximum possible error in `doc_count` for any bucket
- `sum_other_doc_count` — the total count of documents not represented in the returned buckets

[Inference] The degree of approximation scales with the number of shards and the distribution of data; the exact impact may vary per cluster configuration.

---

### Controlling Bucket Count

Some bucket aggregations produce a potentially unbounded number of buckets (e.g., `terms` over a high-cardinality field). Elasticsearch provides mechanisms to control this:

- **`size`** — limits the number of buckets returned (default varies by type)
- **`min_doc_count`** — excludes buckets with fewer than this many documents
- **`shard_size`** — controls how many candidate buckets are gathered per shard before final reduction

```json
"aggs": {
  "top_products": {
    "terms": {
      "field": "product_id.keyword",
      "size": 10,
      "min_doc_count": 5
    }
  }
}
```

---

### Empty Buckets

By default, most bucket aggregations omit buckets with zero documents. Some interval-based aggregations (e.g., `date_histogram`, `histogram`) support a `min_doc_count: 0` setting to include empty buckets, which is useful for time-series visualizations where gaps must be represented.

```json
"aggs": {
  "sales_over_time": {
    "date_histogram": {
      "field": "order_date",
      "calendar_interval": "month",
      "min_doc_count": 0
    }
  }
}
```

---

### Order of Buckets

Bucket aggregations support an `order` parameter to control how buckets are sorted in the response. Common options include sorting by `_count`, `_key`, or by a sub-aggregation value.

```json
"aggs": {
  "by_category": {
    "terms": {
      "field": "category.keyword",
      "order": { "_count": "desc" }
    }
  }
}
```

[Inference] Sorting by sub-aggregation value may increase query cost on high-cardinality fields; behavior and performance impact may vary.

---

### Execution Scope Inheritance

Bucket aggregations inherit their document scope from the parent context:

```
Query Scope
└── Bucket Agg A  (scope: query results)
    └── Metric Agg B  (scope: documents in each bucket of A)
    └── Bucket Agg C  (scope: documents in each bucket of A)
        └── Metric Agg D  (scope: documents in each bucket of C, within A)
```

This hierarchical scoping is what makes nested aggregations powerful for multi-dimensional analysis.

---

### When to Use Bucket Aggregations

Bucket aggregations are appropriate when the goal is to:

- Group documents by a categorical value (e.g., status, country, product type)
- Distribute documents across numeric or date ranges
- Analyze trends over time using fixed or calendar intervals
- Filter documents into named groups for further sub-analysis
- Perform geographic clustering

---

**Conclusion**

Bucket aggregations are the primary mechanism in Elasticsearch for grouping and segmenting documents. They define scopes within which metric and other bucket aggregations can operate, enabling multi-level analytical queries. Understanding bucket behavior — including document assignment, `doc_count` approximation, and scope inheritance — is essential before working with individual bucket aggregation types.