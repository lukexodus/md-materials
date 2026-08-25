## Filter and Filters Aggregation

### Overview

Elasticsearch provides two closely related but distinct aggregations for scoping data: the **`filter` aggregation** (singular) and the **`filters` aggregation** (plural). Both allow you to narrow down documents before computing sub-aggregations, but they differ in how many buckets they produce and how they are used.

---

### filter Aggregation

The `filter` aggregation defines a **single bucket** containing only the documents that match a given query. Any sub-aggregations nested inside it operate exclusively on that subset.

**Key Points**
- Accepts any standard Elasticsearch query (term, range, bool, etc.)
- Produces exactly one bucket
- Useful when you want to isolate a segment and compute metrics on it

**Example**

Compute the average price of products in the `electronics` category:

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "electronics_only": {
      "filter": { "term": { "category": "electronics" } },
      "aggs": {
        "avg_price": { "avg": { "field": "price" } }
      }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "electronics_only": {
      "doc_count": 142,
      "avg_price": { "value": 389.50 }
    }
  }
}
```

The `doc_count` reflects how many documents matched the filter. The `avg_price` is computed only over those 142 documents.

---

### filters Aggregation

The `filters` aggregation defines **multiple named (or anonymous) buckets**, each corresponding to its own query. Documents are routed into whichever bucket(s) their queries match.

**Key Points**
- Accepts a map of named filters or an array of anonymous filters
- Produces one bucket per filter defined
- Documents can match more than one bucket if multiple filter conditions overlap
- An optional `other_bucket` can collect documents that match none of the defined filters

---

### Named Filters

Each bucket is given an explicit name, which appears as the key in the response.

**Example**

Separate orders by status:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_status": {
      "filters": {
        "filters": {
          "pending":   { "term": { "status": "pending" } },
          "shipped":   { "term": { "status": "shipped" } },
          "delivered": { "term": { "status": "delivered" } }
        }
      }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "by_status": {
      "buckets": {
        "pending":   { "doc_count": 83 },
        "shipped":   { "doc_count": 210 },
        "delivered": { "doc_count": 594 }
      }
    }
  }
}
```

---

### Anonymous Filters

When bucket names are not needed, filters can be provided as an array. The response returns buckets in the same positional order.

**Example**

```json
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "severity_buckets": {
      "filters": {
        "filters": [
          { "term": { "level": "warn" } },
          { "term": { "level": "error" } }
        ]
      }
    }
  }
}
```

**Output**

```json
{
  "aggregations": {
    "severity_buckets": {
      "buckets": [
        { "doc_count": 321 },
        { "doc_count": 47 }
      ]
    }
  }
}
```

---

### other_bucket and other_bucket_key

The `filters` aggregation supports an optional catch-all bucket for documents not matched by any defined filter.

| Parameter | Type | Default | Purpose |
|---|---|---|---|
| `other_bucket` | boolean | `false` | Enables the catch-all bucket |
| `other_bucket_key` | string | `"_other_"` | Sets the name of that bucket |

**Example**

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_status": {
      "filters": {
        "other_bucket": true,
        "other_bucket_key": "other_statuses",
        "filters": {
          "pending":   { "term": { "status": "pending" } },
          "shipped":   { "term": { "status": "shipped" } }
        }
      }
    }
  }
}
```

Any order with a status other than `pending` or `shipped` (e.g., `cancelled`, `returned`) appears in `other_statuses`.

---

### Sub-aggregations Inside filters

Like the singular `filter`, the `filters` aggregation supports nested sub-aggregations. Each sub-aggregation runs independently within its own bucket.

**Example**

Average price per order status:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_status": {
      "filters": {
        "filters": {
          "pending":   { "term": { "status": "pending" } },
          "shipped":   { "term": { "status": "shipped" } },
          "delivered": { "term": { "status": "delivered" } }
        }
      },
      "aggs": {
        "avg_order_value": { "avg": { "field": "total" } }
      }
    }
  }
}
```

---

### filter vs. filters: Comparison

| Aspect | `filter` | `filters` |
|---|---|---|
| Number of buckets | Always 1 | One per defined filter |
| Query input | Single query object | Map or array of query objects |
| Named buckets | Not applicable | Supported (named mode) |
| `other_bucket` support | No | Yes |
| Typical use case | Scoped metric on one segment | Side-by-side comparison of segments |

---

### filter Aggregation vs. query-level filter

It is worth distinguishing the `filter` aggregation from a top-level `query` or `post_filter`:

- A **top-level `query`** narrows the documents returned in hits **and** passed to all aggregations.
- A **`post_filter`** narrows hits **after** aggregations have run, leaving aggregation counts unaffected.
- A **`filter` aggregation** scopes only its own bucket and nested sub-aggregations, without affecting the overall hit count or sibling aggregations.

[Inference] This distinction matters when you need one aggregation to operate on a subset while other sibling aggregations still see the full document set. Behavior may vary depending on query context and Elasticsearch version.

---

### Performance Considerations

- The `filter` and `filters` aggregations benefit from **Elasticsearch's filter caching**. Queries that do not score (such as `term`, `range`, and `bool` filters without scoring clauses) are typically cached at the shard level and reused across requests. Actual cache behavior depends on cluster configuration and shard state.
- [Inference] Using `filters` with multiple named buckets is generally more efficient than running separate search requests for each segment, as all buckets are resolved in a single pass. Actual performance depends on index size, hardware, and query complexity.
- Avoid placing expensive, high-cardinality sub-aggregations inside each bucket unnecessarily, as they multiply in cost.

---

### Common Patterns

**Pattern 1 — Funnel Analysis**

Track documents through stages by defining one filter per stage. Sub-aggregations compute metrics per stage independently.

**Pattern 2 — Anomaly Scoping**

Use `filter` to isolate a known anomalous segment (e.g., a specific host or time window), then run `stats` or `percentiles` sub-aggregations to characterize it.

**Pattern 3 — Catch-all Audit**

Enable `other_bucket` on a `filters` aggregation to verify that all expected categories are accounted for. A non-zero `_other_` count signals an uncategorized segment.

---

**Conclusion**

The `filter` aggregation is the right tool when you need to scope a single sub-aggregation pipeline to a specific document subset. The `filters` aggregation extends this to multiple segments simultaneously, enabling efficient side-by-side comparisons without multiple round trips. Both benefit from filter caching and compose naturally with any metric or pipeline aggregation.

**Next Steps**
- Explore `global` aggregation to break out of the current query context entirely
- Combine `filters` with `date_histogram` for time-series segmentation
- Use `filter` aggregation alongside `scripted_metric` for custom scoped computations