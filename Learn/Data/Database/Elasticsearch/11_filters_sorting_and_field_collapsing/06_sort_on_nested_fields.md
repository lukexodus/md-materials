## Query DSL – Sort on Nested Fields

### Overview

Sorting on fields inside `nested` objects requires explicit configuration because nested objects are stored as hidden separate documents in Lucene, not as flat fields on the parent document. Elasticsearch must be told which nested path to navigate and, optionally, which nested objects to consider when multiple exist per parent document.

Without the `nested` sort parameter, attempting to sort on a nested field produces incorrect results or an error.

---

### Why Nested Fields Require Special Handling

A `nested` field mapping stores each nested object as an independent Lucene document internally. When sorting, Elasticsearch must:

1. Identify which nested objects belong to the parent document.
2. Select a single value from potentially many nested objects (via `mode`).
3. Optionally restrict which nested objects participate (via `nested.filter`).

A flat (non-nested) `object` field does not have this complexity — its values are merged into the parent document at index time. Sorting on flat object sub-fields works without a `nested` parameter.

---

### Mapping Example

```json
PUT /products
{
  "mappings": {
    "properties": {
      "name": { "type": "keyword" },
      "reviews": {
        "type": "nested",
        "properties": {
          "score": { "type": "float" },
          "verified": { "type": "boolean" },
          "date": { "type": "date" }
        }
      }
    }
  }
}
```

`reviews` is a `nested` field. Each product document may contain multiple review objects.

---

### Basic Nested Sort Syntax

```json
GET /products/_search
{
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "nested": {
          "path": "reviews"
        }
      }
    }
  ],
  "query": {
    "match_all": {}
  }
}
```

| Parameter | Required | Description |
|---|---|---|
| `nested.path` | Yes | The nested field path containing the sort field |
| `nested.filter` | No | Restricts which nested objects contribute to sort value selection |
| `nested.nested` | No | For multi-level nesting; specifies inner nested path |
| `mode` | No | Selects which value among multiple nested objects to use |

---

### The `mode` Parameter

A parent document may have many nested objects, each with its own value for the sort field. `mode` determines which single value is used to represent the parent document in the sort:

| Mode | Description |
|---|---|
| `min` | Use the lowest value across all matching nested objects |
| `max` | Use the highest value |
| `avg` | Use the arithmetic mean |
| `sum` | Use the sum of all values (numeric fields only) |
| `median` | Use the median value (numeric fields only) |

```json
{
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "mode": "avg",
        "nested": {
          "path": "reviews"
        }
      }
    }
  ]
}
```

Sorts products by their average review score, descending.

**Key point:** `mode` is required when a document has multiple nested objects with values in the sort field. Without it, Elasticsearch defaults to `min` for `asc` order and `max` for `desc` order.

---

### Filtering Nested Objects with `nested.filter`

`nested.filter` restricts which nested objects are considered during sort value selection. Only nested objects that match the filter contribute to the `mode` calculation.

```json
{
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "mode": "avg",
        "nested": {
          "path": "reviews",
          "filter": {
            "term": { "reviews.verified": true }
          }
        }
      }
    }
  ]
}
```

Only verified reviews contribute to the average score used for sorting. Unverified reviews are ignored in the sort computation.

[Inference] `nested.filter` applies only to the sort value selection — it does not filter which parent documents are returned. A parent document with no nested objects matching the filter may still appear in results, but with no effective sort value, which triggers `missing` value behavior. Behavior may vary.

---

### Missing Values for Nested Sort

When no nested objects match the `nested.filter`, or when the nested field has no values, the parent document has no sort value. Placement is controlled by `missing`:

```json
{
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "mode": "avg",
        "missing": "_last",
        "nested": {
          "path": "reviews",
          "filter": {
            "term": { "reviews.verified": true }
          }
        }
      }
    }
  ]
}
```

| `missing` value | Behavior |
|---|---|
| `"_last"` | Documents with no qualifying nested objects appear last |
| `"_first"` | They appear first |
| Literal value | Treated as if that value was present |

---

### Multi-Level Nested Sort

When nested objects contain further nested objects (nested within nested), the `nested.nested` parameter specifies the inner nesting level:

#### Mapping

```json
PUT /catalog
{
  "mappings": {
    "properties": {
      "categories": {
        "type": "nested",
        "properties": {
          "name": { "type": "keyword" },
          "items": {
            "type": "nested",
            "properties": {
              "price": { "type": "float" },
              "in_stock": { "type": "boolean" }
            }
          }
        }
      }
    }
  }
}
```

#### Sort on inner nested field

```json
{
  "sort": [
    {
      "categories.items.price": {
        "order": "asc",
        "mode": "min",
        "nested": {
          "path": "categories",
          "filter": {
            "term": { "categories.name": "electronics" }
          },
          "nested": {
            "path": "categories.items",
            "filter": {
              "term": { "categories.items.in_stock": true }
            }
          }
        }
      }
    }
  ]
}
```

- Outer `nested.path`: `categories` — restricts to the electronics category.
- Inner `nested.nested.path`: `categories.items` — restricts to in-stock items within those categories.
- `mode: min` — uses the lowest price among qualifying items.

[Inference] Multi-level nested sort increases query complexity and execution cost proportionally. Each level requires traversal of its own nested document set. Behavior and performance may vary with nesting depth and document count.

---

### Combining Nested Sort with Other Sort Clauses

Nested sort participates in multi-clause sort chains normally:

```json
{
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "mode": "avg",
        "nested": {
          "path": "reviews",
          "filter": { "term": { "reviews.verified": true } }
        }
      }
    },
    { "name": { "order": "asc" } },
    { "_score": { "order": "desc" } }
  ]
}
```

Primary sort: average verified review score. Tie-break: product name alphabetically. Final tie-break: relevance score.

---

### Nested Sort vs Flat Object Sort

| Aspect | `nested` field | Flat `object` field |
|---|---|---|
| Internal storage | Separate hidden Lucene documents | Merged into parent document |
| Sort parameter required | Yes — `nested.path` mandatory | No — sort on sub-field directly |
| Multi-value handling | Explicit `mode` required | Values collapsed at index time |
| Filter on sub-objects | Supported via `nested.filter` | Not applicable |
| Array integrity | Preserved per object | Lost — cross-object field mixing |

**Key point:** The fundamental reason `nested` is used instead of `object` is to preserve the relationship between fields within each array element. A flat `object` array merges all values from all array elements into a single field, which loses which values belong together. Nested maintains this integrity — at the cost of sort complexity.

---

### Example: Full Query with Nested Sort and Filter

Retrieve products in the "storage" category, sorted by their highest verified review score descending, with unrated products last:

```json
GET /products/_search
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "storage" } },
        {
          "nested": {
            "path": "reviews",
            "query": {
              "term": { "reviews.verified": true }
            }
          }
        }
      ]
    }
  },
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "mode": "max",
        "missing": "_last",
        "nested": {
          "path": "reviews",
          "filter": {
            "term": { "reviews.verified": true }
          }
        }
      }
    }
  ]
}
```

[Inference] The `nested` query in the `filter` context and the `nested.filter` in the sort clause are independent. The query filter restricts which parent documents are returned; the sort filter restricts which nested objects contribute to the sort value. They should be consistent to produce intuitive results, but Elasticsearch does not enforce this. Behavior may vary.

---

### Performance Considerations

- Nested sort requires traversal of nested document sets per parent document, which is more expensive than flat field sort.
- Adding a `nested.filter` reduces the number of nested objects evaluated and can improve sort performance when the filter is selective.
- `mode: avg` and `mode: median` require aggregating values across multiple nested objects, which is more expensive than `mode: min` or `mode: max`.
- [Inference] Multi-level nested sort compounds traversal cost at each level. Deep nesting with large arrays of nested objects may produce significant sort overhead. Behavior and performance depend on document structure and index size.

---

### Common Errors

| Error | Cause | Fix |
|---|---|---|
| `[nested] failed to find nested object` | `nested.path` points to a non-nested field | Verify field is mapped as `nested` |
| Sort returns unexpected values | Missing `nested.path` on nested field | Always specify `nested.path` for nested fields |
| All documents sort equally | `nested.filter` excludes all nested objects | Check filter logic; use `missing` to handle no-match cases |
| Error on multi-level sort | Missing inner `nested.nested` parameter | Specify `nested.nested` for each nesting level |

---

### Summary

| Aspect | Detail |
|---|---|
| Required parameter | `nested.path` — always required for nested field sort |
| Value selection | `mode`: `min`, `max`, `avg`, `sum`, `median` |
| Object filtering | `nested.filter` — restricts contributing nested objects |
| Missing value handling | `missing`: `_first`, `_last`, or literal |
| Multi-level nesting | `nested.nested` for each additional nesting level |
| Flat object fields | Do not require `nested` parameter; sort directly |
| Performance | More expensive than flat sort; use selective `nested.filter` to reduce cost |
| Independence of filters | Query-level nested filter and sort-level `nested.filter` are separate; keep consistent manually |