## Aggregations — top\_hits

### Overview

`top_hits` is a metric aggregation that returns the top matching documents within each bucket of a parent bucket aggregation. Unlike most metric aggregations that reduce a bucket to a single numeric value, `top_hits` returns actual document source, fields, or highlights — making it the standard tool for *"show me representative documents per group"* queries.

It is always used as a **sub-aggregation**. Using `top_hits` at the top level without a parent bucket aggregation is technically valid but equivalent to a regular search with `size`, and offers no practical advantage over that.

---

### Basic Syntax

```json
GET /index/_search
{
  "size": 0,
  "aggs": {
    "by_category": {
      "terms": {
        "field": "category.keyword",
        "size": 5
      },
      "aggs": {
        "top_docs": {
          "top_hits": {
            "size": 3
          }
        }
      }
    }
  }
}
```

**Output:** For each of the top 5 categories, returns the 3 highest-scoring documents in that bucket, including their full `_source`.

---

### Parameters

#### size

Controls how many documents to return per bucket. Default is `3`. Maximum is `100`.

```json
"top_hits": {
  "size": 5
}
```

#### from

Offset within the bucket's hits. Useful for pagination within a group, though this is an uncommon pattern.

```json
"top_hits": {
  "from": 0,
  "size": 5
}
```

#### sort

Overrides the default relevance-score ordering for documents within each bucket.

```json
"top_hits": {
  "size": 3,
  "sort": [
    { "timestamp": { "order": "desc" } }
  ]
}
```

This is the most common customization — fetching the most *recent* documents per group rather than the highest-scoring ones.

#### \_source

Controls which fields are returned in the source. Accepts `true`, `false`, or a list of field patterns.

```json
"top_hits": {
  "size": 3,
  "_source": ["title", "timestamp", "status"]
}
```

Restricting `_source` reduces response payload size, which matters when `top_hits` is nested inside a high-cardinality `terms` aggregation.

#### fields

Returns specific field values using the `fields` fetch mechanism (respects field mappings, formats, and multi-fields) instead of raw `_source` extraction.

```json
"top_hits": {
  "size": 3,
  "fields": ["title", "timestamp"],
  "_source": false
}
```

#### highlight

Applies hit highlighting within each returned document, scoped to the bucket context.

```json
"top_hits": {
  "size": 3,
  "highlight": {
    "fields": {
      "body": {}
    }
  }
}
```

#### explain

Returns score explanation per document in the bucket, useful for debugging scoring behavior within groups.

```json
"top_hits": {
  "size": 3,
  "explain": true
}
```

#### version and seq\_no\_primary\_term

```json
"top_hits": {
  "size": 3,
  "version": true,
  "seq_no_primary_term": true
}
```

Returns document version and sequence number metadata alongside hits — useful when results feed into optimistic concurrency update workflows.

---

### Response Structure

```json
"aggregations": {
  "by_category": {
    "buckets": [
      {
        "key": "electronics",
        "doc_count": 1482,
        "top_docs": {
          "hits": {
            "total": { "value": 1482, "relation": "eq" },
            "max_score": 1.0,
            "hits": [
              {
                "_index": "products",
                "_id": "abc123",
                "_score": 1.0,
                "_source": {
                  "title": "Wireless Headphones",
                  "timestamp": "2024-11-01T10:00:00Z",
                  "status": "active"
                }
              }
            ]
          }
        }
      }
    ]
  }
}
```

The structure inside each bucket mirrors a standard search `hits` object, including `total`, `max_score`, and the hits array.

---

### Common Patterns

#### Latest Document Per Group

Retrieve the most recent event per user session:

```json
GET /events/_search
{
  "size": 0,
  "aggs": {
    "by_session": {
      "terms": {
        "field": "session_id.keyword",
        "size": 100
      },
      "aggs": {
        "latest_event": {
          "top_hits": {
            "size": 1,
            "sort": [{ "timestamp": { "order": "desc" } }],
            "_source": ["event_type", "timestamp", "user_id"]
          }
        }
      }
    }
  }
}
```

This is the canonical `top_hits` pattern — equivalent to a `GROUP BY session_id ORDER BY timestamp DESC LIMIT 1` in SQL terms, approximated per bucket.

#### Deduplication by Field

When multiple documents share a logical identity (e.g., duplicate ingestion), `top_hits` with `size: 1` inside a `terms` aggregation on the identifying field returns one representative document per unique value:

```json
"aggs": {
  "deduplicated": {
    "terms": {
      "field": "canonical_id.keyword",
      "size": 1000
    },
    "aggs": {
      "best_doc": {
        "top_hits": {
          "size": 1,
          "sort": [{ "ingested_at": { "order": "desc" } }]
        }
      }
    }
  }
}
```

[Inference] This does not perform true deduplication at the index level — it returns one document per bucket in the response, but all duplicates remain in the index. Behavior depends on `terms` bucket size limits and shard-level approximation.

#### Combining with Other Metric Aggregations

`top_hits` composes freely with sibling metric aggregations inside the same bucket:

```json
"aggs": {
  "by_product": {
    "terms": { "field": "product_id.keyword", "size": 10 },
    "aggs": {
      "avg_price": { "avg": { "field": "price" } },
      "max_price": { "max": { "field": "price" } },
      "sample_docs": {
        "top_hits": {
          "size": 2,
          "_source": ["title", "price", "sku"]
        }
      }
    }
  }
}
```

This returns statistical summaries alongside representative documents in a single request.

---

### Nested Documents and top\_hits

`top_hits` is particularly useful with **nested** field types, where inner objects are indexed as separate hidden documents. To surface nested hits, combine with a `nested` aggregation:

```json
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_order": {
      "terms": { "field": "order_id.keyword", "size": 10 },
      "aggs": {
        "line_items": {
          "nested": { "path": "items" },
          "aggs": {
            "top_items": {
              "top_hits": {
                "size": 3,
                "_source": ["items.sku", "items.quantity"]
              }
            }
          }
        }
      }
    }
  }
}
```

When used inside a `nested` aggregation context, `top_hits` returns the inner nested documents, not the root documents.

---

### Performance Considerations

`top_hits` is one of the more memory- and CPU-intensive metric aggregations because it must retain and rank actual document data per bucket, not just accumulate numeric values.

Key factors affecting performance:

- **High bucket count + large `size`:** A `terms` aggregation with `size: 1000` and `top_hits` with `size: 10` means up to 10,000 documents are fetched and held in memory across shards before merging. [Inference] This may cause significant heap pressure on large clusters — behavior depends on document size, field count, and JVM configuration.
- **`_source` size:** Large `_source` documents amplify memory usage. Restrict `_source` to only required fields.
- **Sorting:** Sorting within `top_hits` requires maintaining a per-bucket priority queue during collection.

**Mitigation strategies:**
- Always restrict `_source` or use `fields` to limit payload
- Keep `size` as small as the use case allows
- Prefer lower-cardinality grouping fields
- Consider whether a follow-up search (collapse + inner\_hits, or separate queries) might be more efficient for very high cardinality cases

---

### top\_hits vs Field Collapsing

Elasticsearch's `collapse` parameter on a search request provides similar "one result per group" behavior with a different mechanism:

| Property | `top_hits` in aggregation | `collapse` on search |
|---|---|---|
| Use context | Sub-aggregation only | Top-level search parameter |
| Returns multiple per group | Yes (up to 100) | Yes (via `inner_hits`) |
| Combines with other aggs | Yes | Limited |
| Pagination support | Limited | Standard `from`/`size` |
| Total hit count | Per-bucket total | Global total (collapsed) |

[Inference] For pure "latest document per group" with standard pagination needs, `collapse` with `inner_hits` may be preferable; `top_hits` is more appropriate when the grouped result set is itself part of a larger aggregation pipeline. Behavior and suitability depend on the specific query structure.

---

### Limitations

- Maximum `size` per bucket is `100`. There is no way to return more than 100 documents per bucket via `top_hits`.
- `top_hits` does not support `search_after` or pit-based pagination within buckets.
- Results within each bucket are ranked by score or the specified `sort` — there is no way to apply a different ranking per bucket dynamically within a single request.
- [Inference] In very high cardinality `terms` aggregations, the shard-level approximation of which buckets surface to the coordinating node may cause some groups to be missing from results entirely — this is a property of `terms` aggregation behavior, not `top_hits` specifically.

---

**Conclusion:** `top_hits` bridges the gap between aggregation summaries and actual document retrieval. Its primary role is returning representative or ranked documents within each bucket of a parent aggregation — enabling patterns like latest-per-group, sample-per-category, and deduplication. It is powerful but carries a higher resource cost than scalar metric aggregations, and its performance profile should be evaluated carefully when used inside high-cardinality bucket aggregations.