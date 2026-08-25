## Query DSL – Term-Level Queries: `terms` Query

---

### Overview

The `terms` query finds documents that contain **one or more exact values** in a specified field. It is the multi-value equivalent of the `term` query — where `term` matches a single value, `terms` matches any value from a provided list.

Like `term`, it is a **term-level query**: the values are not analyzed before matching. It operates directly against the inverted index.

---

### Basic Syntax

```json
GET /products/_search
{
  "query": {
    "terms": {
      "status": ["published", "featured", "archived"]
    }
  }
}
```

This returns documents where the `status` field contains **any one** of the listed values. The relationship between values is implicitly **OR**.

---

### Parameters

#### `value array` *(required)*

The list of exact values to match against. The field name is the key; the array of values is the value.

```json
"terms": {
  "category.keyword": ["Electronics", "Accessories", "Wearables"]
}
```

**Key Points:**
- By default, Elasticsearch allows up to **65,536 terms** per `terms` query. This limit is controlled by `index.max_terms_count`.
- All values in the array are treated as OR conditions — a document matches if its field contains **at least one** of the listed values.
- Values are not analyzed. The same rules as `term` apply: use `.keyword` sub-fields for string matching.

---

#### `boost`

A floating-point multiplier applied to the relevance score of matching documents.

```json
GET /articles/_search
{
  "query": {
    "terms": {
      "tags": ["elasticsearch", "search"],
      "boost": 1.5
    }
  }
}
```

**Key Points:**
- As with `term`, `boost` has no effect when the query is used in a `filter` context.
- Defaults to `1.0`.

---

### Using `terms` in a `filter` Context

For structured filtering without scoring, place `terms` inside a `filter` clause.

```json
GET /orders/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "terms": {
            "order_status": ["processing", "shipped", "delivered"]
          }
        }
      ]
    }
  }
}
```

**Key Points:**
- Filter context skips score computation and enables query result caching.
- [Inference] For repeated queries filtering on a fixed set of values (such as status codes or region identifiers), `terms` in `filter` context is likely to benefit from the filter cache. Disclaimer: Caching behavior depends on configuration and is not guaranteed.

---

### Field Type Considerations

The same rules as `term` apply:

| Field Type | Behavior |
|---|---|
| `keyword` | Works as expected — exact match |
| `text` | Unreliable — analyzed tokens may not match |
| `numeric` | Works as expected |
| `boolean` | Works as expected |
| `date` | Works — values must match the field's date format |
| `ip` | Works as expected |

For string fields with dynamic mapping, always target the `.keyword` sub-field:

```json
{ "terms": { "category.keyword": ["Laptops", "Tablets"] } }
```

---

### Terms Lookup

The **terms lookup** mechanism allows the values for a `terms` query to be **fetched dynamically from a document in another index**, rather than provided inline. This is useful when the list of values is large, frequently changing, or stored as data in Elasticsearch itself.

#### Structure

```json
GET /products/_search
{
  "query": {
    "terms": {
      "category_id": {
        "index": "user_preferences",
        "id": "user_42",
        "path": "preferred_categories"
      }
    }
  }
}
```

Elasticsearch fetches the document with ID `user_42` from the `user_preferences` index, extracts the value at the `preferred_categories` field, and uses those values as the terms list.

---

#### Terms Lookup Parameters

| Parameter | Required | Description |
|---|---|---|
| `index` | Yes | The index containing the lookup document |
| `id` | Yes | The ID of the lookup document |
| `path` | Yes | The field in the lookup document whose values are used as terms |
| `routing` | No | Custom routing value for the lookup document |

---

#### Terms Lookup Example — User-Specific Filtering

Suppose you store a list of followed author IDs per user:

```json
PUT /user_follows/_doc/user_99
{
  "followed_authors": ["author_1", "author_5", "author_12"]
}
```

You can then query articles written by any followed author:

```json
GET /articles/_search
{
  "query": {
    "terms": {
      "author_id": {
        "index": "user_follows",
        "id": "user_99",
        "path": "followed_authors"
      }
    }
  }
}
```

**Key Points:**
- The lookup document is fetched via a **GET request** at query time. [Inference] This introduces a small additional latency compared to inline terms. Disclaimer: Latency impact is not guaranteed and depends on cluster topology and document size.
- The values fetched from the lookup document are subject to the same `index.max_terms_count` limit as inline terms.
- The lookup document field must contain a single value or an array of values compatible with the target field's type.
- If the lookup document does not exist or the field is empty, the `terms` query matches **no documents**.
- [Inference] Terms lookup is commonly used in access control patterns, personalization, and dynamic allow-list filtering. Disclaimer: Suitability depends on your specific data model and performance requirements.

---

#### Terms Lookup with Routing

If the lookup document uses custom routing:

```json
"terms": {
  "product_id": {
    "index": "user_cart",
    "id": "session_abc",
    "path": "cart_items",
    "routing": "user_segment_3"
  }
}
```

---

### `terms` vs `term`

| Aspect | `term` | `terms` |
|---|---|---|
| Number of values | Single value | Multiple values (array) |
| Match logic | Exact single match | OR across all provided values |
| Terms lookup | Not supported | Supported |
| Use case | Single exact filter | Multi-value filter or dynamic lookup |
| `boost` support | Yes | Yes |

---

### `terms` vs `bool` with Multiple `term` Clauses

The following two queries are functionally equivalent:

**Using `terms`:**
```json
{
  "query": {
    "terms": {
      "status": ["active", "pending", "review"]
    }
  }
}
```

**Using `bool` + multiple `term`:**
```json
{
  "query": {
    "bool": {
      "should": [
        { "term": { "status": "active" } },
        { "term": { "status": "pending" } },
        { "term": { "status": "review" } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

**Key Points:**
- `terms` is more concise and [inference] likely more efficient for this pattern, as it is optimized internally as a single multi-term lookup. Disclaimer: Internal optimization behavior is not guaranteed and may vary across versions.
- The `bool` approach offers more flexibility if you need per-value boosting or different `minimum_should_match` logic.

---

### `terms_set` Query (Related)

When you need a document to match **a minimum number** of the provided terms (not just one), use the `terms_set` query instead of `terms`.

```json
GET /applicants/_search
{
  "query": {
    "terms_set": {
      "skills": {
        "terms": ["elasticsearch", "kibana", "logstash", "beats"],
        "minimum_should_match_field": "required_skill_count"
      }
    }
  }
}
```

**Key Points:**
- `terms` always uses OR logic (match any one).
- `terms_set` allows you to specify that at least N of the provided terms must match.
- The minimum can be specified as a fixed number, a field value, or a script.

---

### Checking How Many Terms Matched

The `terms` query itself does not return a count of how many provided values matched per document. To retrieve that information, use an **aggregation** alongside the query, or use `terms_set` for threshold-based matching.

---

### Full Example

```json
GET /inventory/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "description": "portable speaker"
          }
        }
      ],
      "filter": [
        {
          "terms": {
            "brand.keyword": ["JBL", "Bose", "Sony", "Anker"]
          }
        },
        {
          "terms": {
            "availability": ["in_stock", "preorder"]
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
        "_index": "inventory",
        "_id": "201",
        "_score": 3.87,
        "_source": {
          "description": "JBL portable speaker with 12-hour battery",
          "brand": "JBL",
          "availability": "in_stock"
        }
      },
      {
        "_index": "inventory",
        "_id": "214",
        "_score": 3.54,
        "_source": {
          "description": "Bose portable speaker, water resistant",
          "brand": "Bose",
          "availability": "preorder"
        }
      }
    ]
  }
}
```

The `match` clause drives scoring while both `terms` filters restrict results to the specified brands and availability states.

---

### Terms Lookup Full Example

```json
PUT /user_wishlist/_doc/user_7
{
  "wishlisted_skus": ["SKU-001", "SKU-045", "SKU-112"]
}

GET /products/_search
{
  "query": {
    "terms": {
      "sku": {
        "index": "user_wishlist",
        "id": "user_7",
        "path": "wishlisted_skus"
      }
    }
  }
}
```

This retrieves all products whose `sku` field appears in the wishlist of `user_7`, without needing to pass the SKU list in the application layer.

---

**Conclusion:**

The `terms` query is the natural extension of `term` for multi-value exact matching. Its OR semantics, broad field type support, and terms lookup capability make it one of the most practical term-level queries in Elasticsearch. For performance-sensitive workloads, placing `terms` inside a `filter` context is the standard approach. When match-count thresholds are needed instead of simple OR logic, `terms_set` provides that capability.