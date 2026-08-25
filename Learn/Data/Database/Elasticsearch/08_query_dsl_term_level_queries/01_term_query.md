## Query DSL – Term-Level Queries: `term` Query

---

### Overview

The `term` query finds documents that contain an **exact value** in a specified field. It is a **term-level query**, meaning it operates directly on the inverted index without analyzing the input value.

Unlike full-text queries (such as `match`), the `term` query does **not** pass the search value through an analyzer. The value is used as-is and matched against the indexed terms exactly.

---

### When to Use `term`

Use `term` when:
- Searching **keyword**, **numeric**, **boolean**, **date**, or **IP** fields
- You need **exact match** semantics — no tokenization, stemming, or normalization
- Filtering on structured data such as status codes, IDs, categories, or flags

Avoid using `term` on fields mapped as `text`. Because `text` fields are analyzed at index time (e.g., lowercased, tokenized), the indexed terms may not match the value you provide. Use `match` for `text` fields instead.

---

### Basic Syntax

```json
GET /products/_search
{
  "query": {
    "term": {
      "status": {
        "value": "published"
      }
    }
  }
}
```

This returns documents where the `status` field contains exactly the term `published`.

#### Shorthand Syntax

```json
GET /products/_search
{
  "query": {
    "term": {
      "status": "published"
    }
  }
}
```

Both forms are equivalent. The shorthand is commonly used when no additional parameters are needed.

---

### Parameters

#### `value` *(required)*

The exact term to search for. Accepts `string`, `number`, `boolean`, or `date` depending on the field mapping.

---

#### `boost`

A floating-point multiplier applied to the relevance score of matching documents. Defaults to `1.0`.

```json
GET /orders/_search
{
  "query": {
    "term": {
      "state": {
        "value": "pending",
        "boost": 2.0
      }
    }
  }
}
```

**Key Points:**
- `boost` values greater than `1` increase the score contribution of this clause.
- Values between `0` and `1` decrease it.
- When used inside a `filter` context, `boost` has no scoring effect since filter clauses do not contribute to `_score`.

---

#### `case_insensitive` *(added in 7.10.0)*

When `true`, the match is performed case-insensitively. Defaults to `false`.

```json
GET /users/_search
{
  "query": {
    "term": {
      "username": {
        "value": "JohnDoe",
        "case_insensitive": true
      }
    }
  }
}
```

**Key Points:**
- This matches `johndoe`, `JOHNDOE`, `JohnDoe`, and any other case variation.
- [Inference] This is particularly useful for `keyword` fields that store values in their original casing without normalization. Disclaimer: Behavior may vary across versions; verify availability in your deployment.
- This parameter was introduced in version **7.10.0**. It is not available in earlier versions.

---

### Using `term` in a `filter` Context

For exact-value matching where relevance scoring is not needed, `term` should be placed inside a `filter` clause of a `bool` query. This avoids unnecessary score computation and allows Elasticsearch to cache the result.

```json
GET /orders/_search
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "status": "shipped" } },
        { "term": { "region": "asia-pacific" } }
      ]
    }
  }
}
```

**Key Points:**
- `filter` context is score-free. Documents either match or they do not.
- Filter results are eligible for **query caching**, which can improve performance on repeated queries.
- [Inference] Using `term` in `filter` context is generally preferred over `must` when scoring is not relevant to the use case. Disclaimer: Caching behavior depends on Elasticsearch configuration and is not guaranteed.

---

### Field Type Considerations

#### `keyword` Fields

`term` queries work as expected on `keyword` fields. The value is matched exactly against the stored term.

```json
{ "term": { "category.keyword": "Electronics" } }
```

**Key Points:**
- If a field is mapped as both `text` and `keyword` (the default dynamic mapping for strings), always use the `.keyword` sub-field for `term` queries.
- Matching `"Electronics"` against a `text` field would likely fail because the analyzed form may be `"electronics"` (lowercased).

---

#### Numeric Fields

```json
GET /inventory/_search
{
  "query": {
    "term": {
      "quantity": {
        "value": 100
      }
    }
  }
}
```

---

#### Boolean Fields

```json
GET /users/_search
{
  "query": {
    "term": {
      "is_active": true
    }
  }
}
```

---

#### Date Fields

```json
GET /events/_search
{
  "query": {
    "term": {
      "event_date": "2025-06-01"
    }
  }
}
```

**Key Points:**
- Date values must be provided in a format recognized by the field's `format` mapping.
- [Inference] For date fields, `range` queries are more commonly used than `term` because exact timestamp matching may miss documents depending on how dates are stored. Disclaimer: Date matching behavior depends on the field's format configuration.

---

#### `text` Fields — Common Mistake

```json
GET /articles/_search
{
  "query": {
    "term": {
      "title": "Elasticsearch Guide"
    }
  }
}
```

This query may return **no results** even if documents with that title exist, because the `title` field (mapped as `text`) is analyzed at index time. The indexed terms are likely `["elasticsearch", "guide"]`, not `"Elasticsearch Guide"` as a single term.

**To search `text` fields**, use `match`:
```json
{ "match": { "title": "Elasticsearch Guide" } }
```

**To exact-match the original string**, use the `.keyword` sub-field:
```json
{ "term": { "title.keyword": "Elasticsearch Guide" } }
```

---

### Performance Characteristics

- `term` queries are among the most efficient query types in Elasticsearch because they involve direct index lookups with no analysis overhead.
- When used in `filter` context, they benefit from the **filter cache**, further improving repeated query performance.
- [Inference] For high-cardinality `keyword` fields (such as UUIDs or user IDs), `term` filters are typically fast because the inverted index lookup is O(1) for a single term. Disclaimer: Actual performance depends on index size, shard configuration, and hardware.

---

### `term` vs `match`

| Aspect | `term` | `match` |
|---|---|---|
| Input analysis | None — value used as-is | Yes — analyzed before matching |
| Suitable field types | `keyword`, numeric, boolean, date, IP | `text` |
| Use case | Exact structured values | Natural language / full-text |
| Case sensitivity | Case-sensitive by default | Depends on analyzer |
| Score computation | Optional (use in `filter` to skip) | Yes |

---

### Full Example

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "description": "wireless headphones"
          }
        }
      ],
      "filter": [
        {
          "term": {
            "brand.keyword": "Sony"
          }
        },
        {
          "term": {
            "in_stock": true
          }
        }
      ]
    }
  }
}
```

**Output (representative structure):**

```json
{
  "hits": {
    "hits": [
      {
        "_index": "products",
        "_id": "88",
        "_score": 4.21,
        "_source": {
          "description": "Sony wireless headphones with 30-hour battery",
          "brand": "Sony",
          "in_stock": true
        }
      }
    ]
  }
}
```

The full-text `match` clause drives relevance scoring, while the `term` filters narrow results to Sony products that are in stock without affecting the score.

---

**Conclusion:**

The `term` query is the standard mechanism for exact-value lookups in Elasticsearch. Its efficiency, simplicity, and compatibility with filter caching make it a foundational building block for structured queries. The most important constraint to understand is that it must be used against non-analyzed field types — primarily `keyword`, numeric, boolean, date, and IP fields. Using `term` against `text` fields is a frequent source of unexpected empty results.