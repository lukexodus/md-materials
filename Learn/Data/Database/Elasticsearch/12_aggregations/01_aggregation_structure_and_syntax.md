## Aggregation Structure and Syntax

Aggregations in Elasticsearch allow you to summarize, group, and analyze data beyond simple search results. Understanding how aggregations are structured and written is foundational before working with any specific aggregation type.

---

### What an Aggregation Does

An aggregation processes documents matched by a query and computes summaries or groupings over those documents. Results are returned alongside — but separate from — the search hits.

---

### Top-Level Structure

Aggregations are defined inside the `aggs` (or `aggregations`) key at the top level of a search request body.

```json
GET /my-index/_search
{
  "query": { ... },
  "aggs": {
    "<aggregation_name>": {
      "<aggregation_type>": {
        <aggregation_body>
      }
    }
  }
}
```

**Key Points**
- `aggs` and `aggregations` are interchangeable aliases.
- `<aggregation_name>` is a user-defined label for the result. It has no effect on computation.
- `<aggregation_type>` is the Elasticsearch-defined type (e.g., `terms`, `avg`, `date_histogram`).
- `<aggregation_body>` contains the configuration specific to that type.

---

### Anatomy of a Single Aggregation

```json
"aggs": {
  "average_price": {
    "avg": {
      "field": "price"
    }
  }
}
```

- `average_price` — user-defined name, appears as the key in the response.
- `avg` — the aggregation type.
- `"field": "price"` — the field to aggregate on.

**Output** (simplified):

```json
"aggregations": {
  "average_price": {
    "value": 42.5
  }
}
```

---

### Multiple Aggregations at the Same Level

Multiple aggregations can be declared as siblings within the same `aggs` block. Each runs independently over the same set of matched documents.

```json
"aggs": {
  "average_price": {
    "avg": { "field": "price" }
  },
  "max_price": {
    "max": { "field": "price" }
  },
  "min_price": {
    "min": { "field": "price" }
  }
}
```

**Output** (simplified):

```json
"aggregations": {
  "average_price": { "value": 42.5 },
  "max_price":     { "value": 99.0 },
  "min_price":     { "value": 5.0 }
}
```

---

### Nested Aggregations (Sub-Aggregations)

Bucket aggregations (which group documents into buckets) can contain sub-aggregations. Sub-aggregations run within the context of each bucket.

```json
"aggs": {
  "by_category": {
    "terms": {
      "field": "category.keyword"
    },
    "aggs": {
      "average_price": {
        "avg": { "field": "price" }
      }
    }
  }
}
```

Here, `average_price` is computed separately for each category bucket.

**Output** (simplified):

```json
"aggregations": {
  "by_category": {
    "buckets": [
      { "key": "electronics", "doc_count": 120, "average_price": { "value": 299.5 } },
      { "key": "clothing",    "doc_count": 85,  "average_price": { "value": 45.2 } }
    ]
  }
}
```

Sub-aggregations can be nested multiple levels deep. [Inference] Deep nesting may increase query cost proportionally to the number of buckets at each level; behavior may vary depending on data volume and cluster configuration.

---

### Aggregation Types Overview

Elasticsearch aggregations fall into three main categories:

| Category | Purpose | Examples |
|---|---|---|
| **Metric** | Compute a value from a set of documents | `avg`, `sum`, `min`, `max`, `cardinality` |
| **Bucket** | Group documents into buckets | `terms`, `range`, `date_histogram`, `filters` |
| **Pipeline** | Operate on the output of other aggregations | `avg_bucket`, `derivative`, `cumulative_sum` |

---

### Relationship Between Query and Aggregations

By default, aggregations run on the documents matched by the `query` block. If no `query` is specified, aggregations run over all documents in the index (equivalent to `match_all`).

```json
GET /orders/_search
{
  "query": {
    "term": { "status": "completed" }
  },
  "aggs": {
    "total_revenue": {
      "sum": { "field": "amount" }
    }
  }
}
```

The `total_revenue` aggregation here computes only over documents where `status` is `completed`.

---

### Suppressing Search Hits

When only aggregation results are needed, set `"size": 0` to avoid returning document hits. This reduces response payload size and [Inference] may reduce processing overhead, though actual performance impact may vary.

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

---

### Scope and Document Context

Each aggregation operates within a **scope** — the set of documents it sees. The default scope is the query result. Sub-aggregations inherit the scope of their parent bucket.

```
Query Result (scope: all matched docs)
└── Bucket Agg: by_category (creates per-category scopes)
    └── Metric Agg: average_price (runs within each category scope)
```

This scoping behavior is central to how nested aggregations produce per-group metrics.

---

### `meta` Field in Aggregations

Aggregations support an optional `meta` object for attaching arbitrary metadata to an aggregation definition. This metadata is returned as-is in the response and has no effect on computation.

```json
"aggs": {
  "average_price": {
    "avg": { "field": "price" },
    "meta": { "purpose": "dashboard-widget-3" }
  }
}
```

**Output**:

```json
"average_price": {
  "meta": { "purpose": "dashboard-widget-3" },
  "value": 42.5
}
```

---

### Response Structure

A standard aggregation response is nested under the `aggregations` key (never `aggs`) in the response body.

```json
{
  "took": 5,
  "hits": { ... },
  "aggregations": {
    "<aggregation_name>": {
      <aggregation_result>
    }
  }
}
```

Metric aggregations return a single computed value. Bucket aggregations return a `buckets` array. Pipeline aggregations return results in the context of the aggregation they reference.

---

**Conclusion**

The aggregation structure follows a consistent pattern: a user-defined name wraps a typed aggregation body, optionally containing sub-aggregations. Mastering this structure — including scope inheritance, sibling aggregations, and the query-aggregation relationship — is prerequisite knowledge for working with any specific aggregation type.