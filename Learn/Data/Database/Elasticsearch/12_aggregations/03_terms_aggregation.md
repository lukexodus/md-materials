## Terms Aggregation

The `terms` aggregation is a bucket aggregation that dynamically creates one bucket per unique value found in a specified field. It is one of the most commonly used aggregations in Elasticsearch and is the primary tool for grouping documents by a categorical field value.

---

### Basic Syntax

```json
GET /my-index/_search
{
  "size": 0,
  "aggs": {
    "by_status": {
      "terms": {
        "field": "status.keyword"
      }
    }
  }
}
```

**Output** (simplified):

```json
"aggregations": {
  "by_status": {
    "doc_count_error_upper_bound": 0,
    "sum_other_doc_count": 14,
    "buckets": [
      { "key": "completed", "doc_count": 300 },
      { "key": "pending",   "doc_count": 120 },
      { "key": "cancelled", "doc_count": 56 }
    ]
  }
}
```

---

### Field Types

The `terms` aggregation works on fields that are not analyzed (i.e., not tokenized). Suitable field types include:

| Field Type | Notes |
|---|---|
| `keyword` | Most common. Use `.keyword` sub-field for `text` fields. |
| `boolean` | Returns `true` / `false` buckets. |
| `numeric` (integer, long, etc.) | Groups by exact numeric value. |
| `ip` | Groups by IP address value. |

Using a `text` field directly is not supported and [Inference] will likely produce an error or unexpected results unless `fielddata` is explicitly enabled, which is generally discouraged due to memory cost.

---

### Key Parameters

#### `size`

Controls how many buckets are returned. Defaults to `10`.

```json
"terms": {
  "field": "category.keyword",
  "size": 20
}
```

Increasing `size` returns more buckets but [Inference] may increase memory and CPU usage on the coordinating node; actual impact varies by cluster configuration.

#### `shard_size`

Controls how many candidate buckets each shard returns to the coordinating node before final reduction. Defaults to `size * 1.5 + 10`.

A higher `shard_size` improves accuracy of `doc_count` and bucket selection at the cost of increased data transfer and memory use.

```json
"terms": {
  "field": "category.keyword",
  "size": 10,
  "shard_size": 50
}
```

#### `min_doc_count`

Excludes buckets with fewer than this many documents. Defaults to `1`.

```json
"terms": {
  "field": "category.keyword",
  "min_doc_count": 5
}
```

Setting `min_doc_count: 0` includes buckets for values that exist in the index but have no matching documents in the current query scope. [Inference] This may produce unexpected bucket entries if not intentional.

#### `order`

Controls how buckets are sorted. Defaults to descending `_count`.

```json
"terms": {
  "field": "category.keyword",
  "order": { "_count": "asc" }
}
```

Other valid sort targets:

| Sort Target | Description |
|---|---|
| `_count` | By document count |
| `_key` | Alphabetically or numerically by bucket key |
| `<sub_agg_name>` | By a single-value metric sub-aggregation |

**Example** — sort by sub-aggregation:

```json
"aggs": {
  "by_category": {
    "terms": {
      "field": "category.keyword",
      "order": { "avg_price": "desc" }
    },
    "aggs": {
      "avg_price": {
        "avg": { "field": "price" }
      }
    }
  }
}
```

[Inference] Sorting by sub-aggregation on high-cardinality fields may increase query cost; performance impact may vary.

#### `include` and `exclude`

Filter which values are included in or excluded from bucketing. Accepts a string, array of strings, or a regular expression.

```json
"terms": {
  "field": "status.keyword",
  "include": ["completed", "pending"]
}
```

```json
"terms": {
  "field": "category.keyword",
  "exclude": ".*_test"
}
```

`include` and `exclude` are applied after bucket collection. [Inference] They do not reduce the cost of the initial aggregation pass.

#### `missing`

Defines a default bucket key for documents where the field is absent.

```json
"terms": {
  "field": "category.keyword",
  "missing": "uncategorized"
}
```

Documents without a `category` field are grouped into a bucket with key `"uncategorized"`.

#### `show_term_doc_count_error`

When set to `true`, each bucket includes a `doc_count_error_upper_bound` field representing the maximum error for that bucket's count specifically.

```json
"terms": {
  "field": "category.keyword",
  "show_term_doc_count_error": true
}
```

---

### `doc_count` Approximation

The `terms` aggregation is **distributed**. Each shard independently computes its top-N buckets and returns them to the coordinating node, which merges the results. Because shards only return their local top-N, buckets that rank highly globally may be missed or undercounted if they do not rank in the top-N on every shard.

The response includes two accuracy indicators:

- `doc_count_error_upper_bound` — the worst-case undercount across all buckets returned
- `sum_other_doc_count` — total document count for values not represented in the returned buckets

```json
"by_status": {
  "doc_count_error_upper_bound": 25,
  "sum_other_doc_count": 140,
  "buckets": [ ... ]
}
```

**To improve accuracy:**
- Increase `shard_size` relative to `size`
- Reduce the number of shards (fewer shards means less approximation)
- If the index has only one shard, counts are exact

---

### Execution Order and Scope

The `terms` aggregation collects buckets from documents matched by the enclosing query or parent bucket scope. Sub-aggregations then run within each resulting bucket.

```
Query Scope
└── terms: by_category
    ├── bucket: "electronics"  →  sub-aggs run here
    ├── bucket: "clothing"     →  sub-aggs run here
    └── bucket: "furniture"    →  sub-aggs run here
```

---

### Nested Sub-Aggregations

```json
"aggs": {
  "by_country": {
    "terms": {
      "field": "country.keyword",
      "size": 5
    },
    "aggs": {
      "total_sales": {
        "sum": { "field": "amount" }
      },
      "by_status": {
        "terms": {
          "field": "status.keyword",
          "size": 3
        }
      }
    }
  }
}
```

**Output** (simplified):

```json
"by_country": {
  "buckets": [
    {
      "key": "US",
      "doc_count": 500,
      "total_sales": { "value": 48200.0 },
      "by_status": {
        "buckets": [
          { "key": "completed", "doc_count": 310 },
          { "key": "pending",   "doc_count": 120 }
        ]
      }
    }
  ]
}
```

---

### Numeric Field Example

```json
"aggs": {
  "by_rating": {
    "terms": {
      "field": "rating"
    }
  }
}
```

**Output** (simplified):

```json
"by_rating": {
  "buckets": [
    { "key": 1, "doc_count": 40 },
    { "key": 2, "doc_count": 85 },
    { "key": 3, "doc_count": 210 }
  ]
}
```

---

### Multi-Terms Aggregation

When bucketing by a combination of multiple fields simultaneously, use `multi_terms` instead of `terms`.

```json
"aggs": {
  "by_country_and_status": {
    "multi_terms": {
      "terms": [
        { "field": "country.keyword" },
        { "field": "status.keyword" }
      ]
    }
  }
}
```

**Output** (simplified):

```json
"by_country_and_status": {
  "buckets": [
    { "key": ["US", "completed"], "key_as_string": "US|completed", "doc_count": 310 },
    { "key": ["US", "pending"],   "key_as_string": "US|pending",   "doc_count": 120 }
  ]
}
```

[Inference] `multi_terms` is generally more expensive than a single `terms` aggregation; performance impact may vary depending on field cardinality and data volume.

---

### High-Cardinality Considerations

Using `terms` on fields with very high cardinality (e.g., user IDs, UUIDs, free-text keywords) can be resource-intensive. Common mitigations include:

- Using `size` to limit returned buckets
- Using `include` to restrict to known values of interest
- Considering `cardinality` (a metric aggregation) if only a count of unique values is needed
- Using `rare_terms` if the goal is finding the least frequent values

---

### Relationship to `rare_terms` and `significant_terms`

| Aggregation | Purpose |
|---|---|
| `terms` | Most frequent values by document count |
| `rare_terms` | Least frequent values (below a max doc count) |
| `significant_terms` | Values statistically over-represented in the foreground set vs. a background set |

---

**Conclusion**

The `terms` aggregation is the standard approach for grouping documents by field value in Elasticsearch. Its behavior — including `doc_count` approximation, the role of `shard_size`, and bucket sorting — requires deliberate configuration when accuracy or ordering matters. For multi-field grouping, `multi_terms` extends the same pattern. Understanding `terms` deeply is prerequisite to working with more specialized bucket aggregations.