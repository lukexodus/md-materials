## Nested Objects and the Nested Type

---

### The Object Type and Its Flattening Behavior

Before understanding `nested`, it is necessary to understand how Elasticsearch handles plain `object` fields — and where that behavior breaks down.

Elasticsearch is built on Apache Lucene, which has no native concept of objects or arrays of objects. When an `object` field is indexed, Elasticsearch flattens its inner fields into a set of key-value pairs using dot notation.

**Example document:**

```json
{
  "product": "Laptop",
  "tags": [
    { "name": "electronics", "score": 10 },
    { "name": "portable",    "score": 4  }
  ]
}
```

After flattening, Lucene sees:

```
tags.name:  ["electronics", "portable"]
tags.score: [10, 4]
```

The association between `"electronics"` and `10`, and between `"portable"` and `4`, is **completely lost**. All values for each leaf field are merged into a single array, with no record of which values belonged to the same original object.

---

### The Flattening Problem in Queries

Because the pairings between inner fields are lost, queries that assume cross-field correlation within a single array element will produce incorrect results.

**Query intent:** Find documents where a tag has `name = "electronics"` AND `score >= 8`.

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "term":  { "tags.name":  "electronics" } },
        { "range": { "tags.score": { "gte": 8 } } }
      ]
    }
  }
}
```

With an `object` mapping, this query **matches the document** — because `electronics` exists in `tags.name` and `10` exists in `tags.score`. But the query's intent was to find a single tag where both conditions are true simultaneously. In this document, that condition is satisfied, but consider:

```json
{
  "tags": [
    { "name": "electronics", "score": 2 },
    { "name": "portable",    "score": 10 }
  ]
}
```

This document would also match — even though no single tag has both `name = "electronics"` and `score >= 8`. The flattened representation makes this indistinguishable from the previous case.

---

### The nested Type

The `nested` type solves this problem by indexing each object in an array as a **separate hidden Lucene document**. These hidden documents are stored in the same shard as the parent document but are invisible in normal search results. The parent-child relationship is maintained, allowing queries to enforce that conditions apply within the same object instance.

**Mapping:**

```json
PUT /products
{
  "mappings": {
    "properties": {
      "product": { "type": "keyword" },
      "tags": {
        "type": "nested",
        "properties": {
          "name":  { "type": "keyword" },
          "score": { "type": "integer" }
        }
      }
    }
  }
}
```

**Indexing a document:**

```json
PUT /products/_doc/1
{
  "product": "Laptop",
  "tags": [
    { "name": "electronics", "score": 10 },
    { "name": "portable",    "score": 4  }
  ]
}
```

Internally, Elasticsearch creates three Lucene documents:

1. A hidden document for `{ "name": "electronics", "score": 10 }`
2. A hidden document for `{ "name": "portable", "score": 4 }`
3. The parent document for the top-level fields

---

### Querying nested Fields

Standard queries do not reach into nested documents. You must use the `nested` query, which specifies the path to the nested field and contains an inner query that runs against the hidden nested documents.

**Correct query — find a tag where name is "electronics" AND score >= 8:**

```json
GET /products/_search
{
  "query": {
    "nested": {
      "path": "tags",
      "query": {
        "bool": {
          "must": [
            { "term":  { "tags.name":  "electronics" } },
            { "range": { "tags.score": { "gte": 8    } } }
          ]
        }
      }
    }
  }
}
```

This matches only documents where a **single nested object** satisfies both conditions. The document with `{ "name": "electronics", "score": 2 }` would not match.

---

### score_mode in nested Queries

When multiple nested objects in a single document match the inner query, `score_mode` controls how their relevance scores are combined into a single score for the parent document.

| Value | Behavior |
|---|---|
| `avg` | Average score of matching nested documents (default) |
| `max` | Highest score among matching nested documents |
| `min` | Lowest score among matching nested documents |
| `sum` | Sum of scores of all matching nested documents |
| `none` | Nested match contributes 0 to parent score |

```json
{
  "nested": {
    "path": "tags",
    "score_mode": "max",
    "query": {
      "match": { "tags.name": "electronics" }
    }
  }
}
```

---

### Aggregations on nested Fields

Standard aggregations do not cross the nested document boundary. To aggregate on nested fields, you must use the `nested` aggregation to first change the context to the nested documents, then apply sub-aggregations.

**Example — average score per tag name:**

```json
GET /products/_search
{
  "aggs": {
    "tag_context": {
      "nested": {
        "path": "tags"
      },
      "aggs": {
        "by_name": {
          "terms": {
            "field": "tags.name"
          },
          "aggs": {
            "avg_score": {
              "avg": {
                "field": "tags.score"
              }
            }
          }
        }
      }
    }
  }
}
```

#### reverse_nested Aggregation

To return from nested context back to the parent document within an aggregation pipeline, use `reverse_nested`.

**Example — count distinct products per tag name:**

```json
GET /products/_search
{
  "aggs": {
    "tag_context": {
      "nested": { "path": "tags" },
      "aggs": {
        "by_tag": {
          "terms": { "field": "tags.name" },
          "aggs": {
            "back_to_product": {
              "reverse_nested": {},
              "aggs": {
                "product_count": {
                  "cardinality": { "field": "product" }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

---

### Sorting by nested Fields

Sorting on nested fields requires a `nested` context block inside the sort definition.

```json
GET /products/_search
{
  "sort": [
    {
      "tags.score": {
        "order": "desc",
        "nested": {
          "path": "tags",
          "filter": {
            "term": { "tags.name": "electronics" }
          }
        }
      }
    }
  ]
}
```

The `filter` within the nested sort context restricts which nested objects contribute to the sort value, preventing unintended values from other array elements from influencing the order.

---

### Highlighting nested Fields

The `highlight` API supports nested fields. The response includes highlight fragments associated with the matched nested object.

```json
GET /products/_search
{
  "query": {
    "nested": {
      "path": "tags",
      "query": {
        "match": { "tags.name": "electronics" }
      },
      "inner_hits": {}
    }
  },
  "highlight": {
    "fields": {
      "tags.name": {}
    }
  }
}
```

---

### inner_hits

The `inner_hits` parameter causes Elasticsearch to return the specific nested objects that matched the query, alongside the parent document. This is useful for identifying which array elements triggered the match.

```json
GET /products/_search
{
  "query": {
    "nested": {
      "path": "tags",
      "query": {
        "bool": {
          "must": [
            { "term":  { "tags.name":  "electronics" } },
            { "range": { "tags.score": { "gte": 8 } } }
          ]
        }
      },
      "inner_hits": {
        "name": "matched_tags",
        "size": 5
      }
    }
  }
}
```

**Response structure (abbreviated):**

```json
{
  "hits": {
    "hits": [
      {
        "_source": { "product": "Laptop", "tags": [...] },
        "inner_hits": {
          "matched_tags": {
            "hits": {
              "hits": [
                {
                  "_source": { "name": "electronics", "score": 10 },
                  "_nested": { "field": "tags", "offset": 0 }
                }
              ]
            }
          }
        }
      }
    ]
  }
}
```

The `_nested.offset` indicates the position of the matching object within the original array.

---

### Updating nested Documents

Elasticsearch documents are immutable at the Lucene level. Updating a document — including its nested objects — requires reindexing the entire parent document. There is no mechanism to update a single nested object in isolation.

**Partial update using the update API still rewrites the full document internally:**

```json
POST /products/_update/1
{
  "doc": {
    "tags": [
      { "name": "electronics", "score": 9 },
      { "name": "portable",    "score": 4 }
    ]
  }
}
```

> [Inference] For use cases with high-frequency updates to individual nested objects, the full-document rewrite cost may become significant at scale. The actual performance impact depends on document size, shard configuration, and update rate. Behavior may vary.

---

### Index Overhead of nested Documents

Each nested object is stored as a hidden Lucene document. This has measurable implications:

- The total Lucene document count in a shard includes all nested documents, not just the visible parent documents
- Index size increases proportionally with the number of nested objects per parent
- The `index.mapping.nested_fields.limit` setting (default: 50) caps the number of distinct `nested` field definitions per index
- The `index.mapping.nested_objects.limit` setting (default: 10,000) caps the total number of nested objects across all nested fields in a single document

**Checking and adjusting limits:**

```json
PUT /products/_settings
{
  "index.mapping.nested_objects.limit": 5000
}
```

> [Inference] Exceeding `nested_objects.limit` will cause the indexing request to fail. If documents have many nested objects by design, adjust this limit explicitly and monitor heap usage on data nodes. Behavior may vary.

---

### Deeply Nested Structures

`nested` fields can themselves contain `nested` fields. Each level of nesting creates its own hidden documents and requires its own `nested` query context.

**Example mapping:**

```json
"orders": {
  "type": "nested",
  "properties": {
    "order_id": { "type": "keyword" },
    "items": {
      "type": "nested",
      "properties": {
        "sku":      { "type": "keyword" },
        "quantity": { "type": "integer" }
      }
    }
  }
}
```

**Query with two levels of nested context:**

```json
{
  "query": {
    "nested": {
      "path": "orders",
      "query": {
        "nested": {
          "path": "orders.items",
          "query": {
            "bool": {
              "must": [
                { "term":  { "orders.items.sku":      "SKU-001" } },
                { "range": { "orders.items.quantity": { "gte": 2 } } }
              ]
            }
          }
        }
      }
    }
  }
}
```

> [Inference] Deeply nested structures multiply the hidden document count and query complexity. Each additional nesting level compounds overhead. Flatter data models should be considered where the query correctness trade-off permits. Behavior may vary.

---

### object vs nested — Decision Reference

| Factor | object | nested |
|---|---|---|
| Inner field correlation preserved | No | Yes |
| Requires nested query syntax | No | Yes |
| Storage overhead | Lower | Higher (hidden docs per object) |
| Aggregation complexity | Standard | Requires nested aggregation context |
| Sort complexity | Standard | Requires nested sort context |
| Update cost | Full document rewrite | Full document rewrite |
| Suitable for arrays of independent objects | Yes | Not necessary |
| Suitable for arrays requiring cross-field accuracy | No | Yes |

---

### Best Practices

- **Use `object` by default for embedded sub-documents.** Only upgrade to `nested` when query correctness across array element fields is a confirmed requirement.
- **Keep nested arrays bounded in size.** Unbounded growth in nested object count per document increases both index size and the risk of hitting `nested_objects.limit`.
- **Use `inner_hits` during development** to verify that the correct nested objects are matching your queries.
- **Avoid deeply nested structures** where possible. More than two levels of nesting produces significant complexity and overhead with limited practical benefit in most use cases.
- **Prefer denormalization over deep nesting** for read-heavy workloads — duplicating data at index time is often less costly than multi-level nested queries at search time.
- **Monitor shard-level Lucene document counts** (`_cat/shards` or `_cat/indices`) in indices with large nested arrays — the visible document count can significantly understate the actual Lucene document count.

---