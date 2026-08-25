## Query DSL – Joining Queries: `nested` Query

### Overview

The `nested` query is used to search within **nested objects** — a special field type in Elasticsearch that indexes arrays of objects as separate hidden documents, preserving the relationship between fields within each object. Without the `nested` type and query, object arrays are flattened during indexing, causing cross-object field correlations to break.

It is the primary mechanism for querying structured sub-documents that belong to a parent document, where field relationships within each sub-document must be maintained.

---

### The Problem: Object Array Flattening

By default, Elasticsearch flattens arrays of objects into parallel arrays of values, losing the per-object field associations.

**Example — indexed document:**

```json
{
  "title": "Elasticsearch Guide",
  "authors": [
    { "name": "alice", "age": 30 },
    { "name": "bob",   "age": 45 }
  ]
}
```

**After flattening (internal representation):**

```json
{
  "authors.name": ["alice", "bob"],
  "authors.age":  [30, 45]
}
```

A query for `authors.name = "alice" AND authors.age = 45` would **incorrectly match** this document, because field values from different objects are mixed into the same arrays. Alice and Bob's values are no longer associated with each other.

**The `nested` type solves this** by indexing each array element as a separate hidden Lucene document, preserving the internal field relationships.

---

### Mapping Requirement

A field must be explicitly mapped as `nested` before the `nested` query can be used against it. Using the `nested` query against a non-nested field produces an error.

```json
PUT /books
{
  "mappings": {
    "properties": {
      "title": { "type": "text" },
      "authors": {
        "type": "nested",
        "properties": {
          "name": { "type": "keyword" },
          "age":  { "type": "integer" }
        }
      }
    }
  }
}
```

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "nested": {
      "path":        "<nested_field_name>",
      "query":       { <query_on_nested_fields> },
      "score_mode":  "avg",
      "ignore_unmapped": false
    }
  }
}
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `path` | ✅ Yes | Dot-notation path to the nested field. |
| `query` | ✅ Yes | Query executed against the nested documents at `path`. |
| `score_mode` | ❌ No | How scores from matching nested documents contribute to the parent score. Default: `avg`. |
| `ignore_unmapped` | ❌ No | If `true`, silently ignores the query when `path` is not mapped as `nested`. Default: `false`. |

---

### `score_mode` Options

When multiple nested documents within a single parent match the query, `score_mode` determines how those scores combine into the parent document's score.

| `score_mode` | Behavior |
|-------------|----------|
| `avg` (default) | Average of all matching nested document scores |
| `sum` | Sum of all matching nested document scores |
| `min` | Lowest score among matching nested documents |
| `max` | Highest score among matching nested documents |
| `none` | Parent receives a score of `0`; nested scores ignored |

---

### Basic Example: Querying Nested Authors

**Index documents:**

```json
POST /books/_bulk
{ "index": { "_id": "1" } }
{ "title": "Distributed Systems", "authors": [{ "name": "alice", "age": 30 }, { "name": "bob", "age": 45 }] }
{ "index": { "_id": "2" } }
{ "title": "Search Engines", "authors": [{ "name": "carol", "age": 38 }, { "name": "dave", "age": 29 }] }
{ "index": { "_id": "3" } }
{ "title": "Data Engineering", "authors": [{ "name": "alice", "age": 41 }] }
```

**Query:** Find books where at least one author is named "alice" and is older than 35:

```json
GET /books/_search
{
  "query": {
    "nested": {
      "path": "authors",
      "query": {
        "bool": {
          "must": [
            { "term":  { "authors.name": "alice" } },
            { "range": { "authors.age":  { "gt": 35 } } }
          ]
        }
      }
    }
  }
}
```

**Output:**

| Doc | Title | Authors | Matches? |
|-----|-------|---------|----------|
| 1 | Distributed Systems | alice (30), bob (45) | ❌ No — alice's age is 30, not > 35 |
| 2 | Search Engines | carol (38), dave (29) | ❌ No — no author named alice |
| 3 | Data Engineering | alice (41) | ✅ Yes — alice is 41 |

Only document 3 is returned. The query correctly evaluates conditions within each nested object independently.

**Key Points**
- Without `nested` mapping and query, document 1 would incorrectly match because `alice` and `45` (Bob's age) both appear in the flattened arrays.
- The `nested` query evaluates conditions jointly within each nested document.

---

### Field Path Qualification

All field references inside the `nested` query must use the **full dot-notation path** including the nested field name as prefix:

```json
// Correct
{ "term": { "authors.name": "alice" } }

// Incorrect — missing path prefix
{ "term": { "name": "alice" } }
```

---

### Combining `nested` with `bool`

`nested` queries can be combined with regular queries inside `bool` clauses:

```json
GET /books/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "systems" } }
      ],
      "filter": [
        {
          "nested": {
            "path": "authors",
            "query": {
              "term": { "authors.name": "alice" }
            }
          }
        }
      ]
    }
  }
}
```

Returns books where the title contains "systems" AND at least one author is named "alice". The `nested` clause in `filter` context does not affect scoring.

---

### Nested Query in Filter Context

Placing the `nested` query inside a `filter` clause executes it in filter context — no score is computed for the nested match, and the result is [Inference] eligible for caching:

```json
GET /books/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "nested": {
            "path":       "authors",
            "query":      { "term": { "authors.name": "bob" } },
            "score_mode": "none"
          }
        }
      ]
    }
  }
}
```

Using `score_mode: none` is appropriate here since scoring is not needed in filter context.

---

### Multi-Level Nested Queries

Nested fields can themselves contain nested fields. Querying deeply nested structures requires nesting `nested` queries.

**Mapping:**

```json
PUT /companies
{
  "mappings": {
    "properties": {
      "name": { "type": "keyword" },
      "departments": {
        "type": "nested",
        "properties": {
          "dept_name": { "type": "keyword" },
          "employees": {
            "type": "nested",
            "properties": {
              "emp_name": { "type": "keyword" },
              "salary":   { "type": "integer" }
            }
          }
        }
      }
    }
  }
}
```

**Query:** Find companies with a department named "engineering" that has an employee earning more than 100,000:

```json
GET /companies/_search
{
  "query": {
    "nested": {
      "path": "departments",
      "query": {
        "bool": {
          "must": [
            { "term": { "departments.dept_name": "engineering" } },
            {
              "nested": {
                "path": "departments.employees",
                "query": {
                  "range": {
                    "departments.employees.salary": { "gt": 100000 }
                  }
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

**Key Points**
- The outer `nested` query targets the `departments` path.
- The inner `nested` query targets `departments.employees` — the full dot-notation path from root.
- Both conditions must hold within the same nested department object.
- [Inference] Multi-level nesting increases indexing overhead and query complexity. The number of nested levels and nested documents per parent affects performance. Behavior and limits may vary by Elasticsearch version.

---

### `ignore_unmapped`

When querying across multiple indices with different mappings, a nested path may not exist in all indices. Setting `ignore_unmapped: true` prevents errors in those cases:

```json
GET /index_a,index_b/_search
{
  "query": {
    "nested": {
      "path":             "authors",
      "query":            { "term": { "authors.name": "alice" } },
      "ignore_unmapped":  true
    }
  }
}
```

If `authors` is not mapped as `nested` in `index_b`, that index is silently skipped rather than returning an error.

---

### Inner Hits

The `inner_hits` parameter returns the specific nested documents that matched the query, alongside the parent document. This is useful for identifying which nested object triggered the match.

```json
GET /books/_search
{
  "query": {
    "nested": {
      "path":  "authors",
      "query": {
        "bool": {
          "must": [
            { "term":  { "authors.name": "alice" } },
            { "range": { "authors.age":  { "gt": 35 } } }
          ]
        }
      },
      "inner_hits": {
        "name":    "matching_authors",
        "size":    5,
        "_source": ["authors.name", "authors.age"]
      }
    }
  }
}
```

**Sample response structure:**

```json
{
  "hits": {
    "hits": [
      {
        "_id": "3",
        "_source": { "title": "Data Engineering", ... },
        "inner_hits": {
          "matching_authors": {
            "hits": {
              "hits": [
                {
                  "_nested": { "field": "authors", "offset": 0 },
                  "_source": { "name": "alice", "age": 41 }
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

| `inner_hits` Parameter | Description |
|------------------------|-------------|
| `name` | Label for the inner hits block in the response |
| `size` | Maximum number of matching nested documents to return per parent |
| `_source` | Fields to include from the nested document |
| `highlight` | Highlighting configuration for nested fields |
| `sort` | Sort order for inner hits |

---

### Nested Aggregations

To aggregate on nested fields, the `nested` aggregation must wrap the metric or bucket aggregation. This is a separate but closely related concept — the `nested` query handles filtering, while the `nested` aggregation handles grouping and metrics.

```json
GET /books/_search
{
  "size": 0,
  "aggs": {
    "authors_agg": {
      "nested": { "path": "authors" },
      "aggs": {
        "avg_age": {
          "avg": { "field": "authors.age" }
        }
      }
    }
  }
}
```

> Nested aggregations are a broader topic covered separately under Aggregations.

---

### `nested` vs `object` Type

| Characteristic | `object` | `nested` |
|----------------|----------|----------|
| Internal representation | Flattened into parent document | Separate hidden Lucene documents |
| Field correlation within array elements | ❌ Lost after flattening | ✅ Preserved |
| Query type required | Standard queries | `nested` query |
| Storage overhead | Lower | Higher (one hidden doc per nested object) |
| Indexing performance | [Inference] Faster | [Inference] Slower due to additional documents |
| Use case | Single objects or when cross-field correlation is not needed | Arrays of objects requiring per-element field correlation |

---

### Performance Considerations

- [Inference] Each nested object is stored as a separate hidden Lucene document. A parent document with 100 nested objects contributes 101 documents to the index (1 parent + 100 nested). This affects index size, indexing throughput, and query performance. Behavior and limits depend on hardware and cluster configuration.
- Elasticsearch enforces a default limit on the number of nested documents per index via the `index.mapping.nested_objects.limit` setting (default: 10,000). [Inference] Exceeding this limit during indexing produces an error. The limit is configurable but increasing it has memory and performance implications.
- Prefer placing `nested` queries in `filter` context when scoring on nested fields is not needed — this reduces score computation and [Inference] may improve caching.
- Avoid deeply nested structures (nested inside nested inside nested) where simpler data modeling alternatives exist. [Inference] Each additional nesting level multiplies query complexity and indexing overhead.

---

### Common Mistakes

| Mistake | Consequence | Solution |
|---------|-------------|----------|
| Using `object` type instead of `nested` | Cross-object field correlations break | Remap field as `nested`; reindex |
| Omitting path prefix in field names inside `nested` | Query targets root fields, not nested fields | Use full dot-notation path |
| Using a `nested` query on a non-nested field | Runtime error | Check mapping; use `ignore_unmapped: true` for cross-index queries |
| Not using `inner_hits` when needed | Cannot identify which nested object matched | Add `inner_hits` to the `nested` query |
| Deeply nesting without considering index size | Index bloat and performance degradation | Evaluate data model; consider `join` field type for large hierarchies |

---

**Conclusion**

The `nested` query is essential whenever documents contain arrays of objects where field relationships within each object must be preserved during search. It works in tandem with the `nested` mapping type, and supports the full range of Elasticsearch query clauses within its `query` parameter. Features like `inner_hits`, `score_mode`, and multi-level nesting make it a powerful tool for structured sub-document search — though its storage and performance implications require careful consideration during index design.