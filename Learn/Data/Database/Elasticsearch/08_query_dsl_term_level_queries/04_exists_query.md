## Query DSL – Term-Level Queries: `exists` Query

---

### Overview

The `exists` query returns documents where a specified field **contains any indexed value**. It is the Elasticsearch equivalent of a non-null, non-empty field check — matching documents where the field exists and has a value that was indexed.

It is a simple, single-parameter query with no analysis and no scoring complexity.

---

### Basic Syntax

```json
GET /products/_search
{
  "query": {
    "exists": {
      "field": "description"
    }
  }
}
```

Returns all documents in the `products` index where the `description` field has an indexed value.

---

### Parameters

#### `field` *(required)*

The name of the field to check. Accepts dot notation for nested field paths.

```json
{ "exists": { "field": "metadata.author" } }
```

---

### What "Exists" Means in Elasticsearch

A field is considered to **exist** (i.e., the `exists` query matches) when the document contains that field and its value was successfully indexed. A field is considered to **not exist** when any of the following are true:

| Condition | `exists` matches? |
|---|---|
| Field has a non-null, non-empty value | Yes |
| Field is absent from the document entirely | No |
| Field value is `null` | No |
| Field value is an empty array `[]` | No |
| Field value is an array of all nulls `[null, null]` | No |
| Field is mapped but has `index: false` | No |
| Field value exceeds `ignore_above` limit (keyword) | No |
| Field value is malformed and `ignore_malformed: true` is set | No |

**Key Points:**
- `exists` checks for the presence of **indexed terms**, not simply whether the field key appears in the source document `_source`.
- A field can be present in `_source` but still not match `exists` if its value was not indexed (e.g., `index: false`, `null`, or ignored due to mapping constraints).
- [Inference] This distinction is important when `_source` contains fields that are intentionally excluded from indexing. Disclaimer: Indexing behavior depends on mapping configuration and is not guaranteed to be uniform across field types.

---

### Inverting with `bool` `must_not`

To find documents where a field is **absent or null**, wrap `exists` in a `must_not` clause.

```json
GET /users/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "exists": { "field": "phone_number" } }
      ]
    }
  }
}
```

Returns all users where `phone_number` has no indexed value.

**Key Points:**
- There is no `not_exists` query type. The `bool` + `must_not` pattern is the standard approach.
- This pattern is commonly used for finding incomplete records, detecting missing required fields, or identifying documents that predate a schema change.

---

### Using `exists` in `filter` Context

Since `exists` carries no relevance scoring value, it should almost always be used in `filter` context.

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "body": "machine learning" } }
      ],
      "filter": [
        { "exists": { "field": "published_at" } },
        { "exists": { "field": "author.name" } }
      ]
    }
  }
}
```

**Key Points:**
- The `match` clause drives relevance scoring.
- The `exists` filters restrict results to documents with both `published_at` and `author.name` indexed, without affecting the score.
- [Inference] `exists` in filter context is eligible for query caching. Disclaimer: Caching behavior depends on Elasticsearch configuration and is not guaranteed.

---

### `exists` on Nested Fields

For fields inside a `nested` object, the query must be wrapped in a `nested` query.

```json
GET /orders/_search
{
  "query": {
    "nested": {
      "path": "items",
      "query": {
        "exists": {
          "field": "items.discount_code"
        }
      }
    }
  }
}
```

Returns orders that contain at least one line item with a `discount_code` value.

---

### `exists` on Object Fields

When used against an **object** field (not `nested`), `exists` matches if **any sub-field** of that object has an indexed value.

```json
GET /profiles/_search
{
  "query": {
    "exists": {
      "field": "address"
    }
  }
}
```

This matches documents where any sub-field under `address` (e.g., `address.city`, `address.postcode`) has an indexed value.

**Key Points:**
- Elasticsearch does not index object fields themselves — only their leaf sub-fields are indexed.
- [Inference] Using `exists` on an object field is equivalent to checking whether at least one of its sub-fields has an indexed value. Disclaimer: This behavior depends on the mapping structure and may not apply uniformly across all object configurations.

---

### `exists` and `null_value` Mapping

When a field mapping defines a `null_value`, documents with `null` in that field are indexed using the substituted value. In this case, `exists` **will match** those documents because the substituted value is indexed.

**Mapping:**
```json
PUT /employees
{
  "mappings": {
    "properties": {
      "middle_name": {
        "type": "keyword",
        "null_value": "N/A"
      }
    }
  }
}
```

**Document:**
```json
{ "middle_name": null }
```

In this case, `exists` on `middle_name` **will match** this document because `"N/A"` is indexed as the substituted value.

**Key Points:**
- `null_value` only affects how `null` is indexed — it does not affect `_source`. The original `null` remains in `_source`.
- This behavior applies only to field types that support `null_value` (e.g., `keyword`, `numeric`, `boolean`, `date`).
- [Unverified: confirm `null_value` support for your target field type and Elasticsearch version.]

---

### `exists` and `index: false`

Fields mapped with `"index": false` are stored in `_source` but not added to the inverted index. The `exists` query will **never match** such fields, regardless of their value.

```json
PUT /logs
{
  "mappings": {
    "properties": {
      "raw_payload": {
        "type": "text",
        "index": false
      }
    }
  }
}
```

```json
{ "exists": { "field": "raw_payload" } }
```

This query returns no results, even if `raw_payload` is present and populated in every document.

---

### `exists` and `ignore_malformed`

When `ignore_malformed: true` is set on a field and a document contains a malformed value (e.g., a string in a numeric field), the malformed value is excluded from the index. The `exists` query will not match that field for that document.

```json
PUT /metrics
{
  "mappings": {
    "properties": {
      "temperature": {
        "type": "float",
        "ignore_malformed": true
      }
    }
  }
}
```

If a document contains `"temperature": "hot"`, the value is ignored at index time. `exists` on `temperature` will **not match** that document.

---

### `exists` and `ignore_above`

For `keyword` fields with `ignore_above` set, values exceeding the character limit are not indexed. `exists` will not match those documents for that field.

```json
PUT /tags_index
{
  "mappings": {
    "properties": {
      "tag": {
        "type": "keyword",
        "ignore_above": 256
      }
    }
  }
}
```

A document with a `tag` value of 300 characters will not have that field indexed. `exists` on `tag` will not match it.

---

### Combining `exists` with Other Filters

```json
GET /leads/_search
{
  "query": {
    "bool": {
      "filter": [
        { "exists": { "field": "email" } },
        { "term":  { "status": "qualified" } },
        {
          "range": {
            "last_contact": { "gte": "now-30d/d" }
          }
        }
      ],
      "must_not": [
        { "exists": { "field": "unsubscribed_at" } }
      ]
    }
  }
}
```

This retrieves qualified leads who:
- Have an indexed `email` value
- Were contacted within the last 30 days
- Have not been marked as unsubscribed

---

### Performance Characteristics

- `exists` is implemented using the field's **doc values** or **norms** metadata, making it efficient regardless of the number of distinct values in the field.
- [Inference] It is generally one of the cheaper query types to execute because it does not involve term dictionary lookups or scoring computation. Disclaimer: Performance depends on index size, shard configuration, and field type.
- As with all term-level queries, placing `exists` in `filter` context allows it to benefit from caching.

---

### `exists` vs Related Approaches

| Approach | Use Case |
|---|---|
| `exists` | Field has any indexed value |
| `bool` `must_not` + `exists` | Field is absent, null, or not indexed |
| `term` with `null_value` | Match documents where null was substituted |
| `range` with `gte: 1` | Numeric field has a value of at least 1 (not just present) |
| `wildcard: *` | Field matches any string (less efficient than `exists`) |

**Key Points:**
- Using `wildcard: { "field": "*" }` to simulate existence checking is [inference] significantly less efficient than `exists` and should be avoided. Disclaimer: Performance characteristics are not guaranteed and may vary.

---

### Full Example

```json
GET /job_postings/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "data engineer" } }
      ],
      "filter": [
        { "exists": { "field": "salary_range" } },
        { "exists": { "field": "remote_policy" } },
        { "term":  { "employment_type": "full_time" } }
      ],
      "must_not": [
        { "exists": { "field": "closed_at" } }
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
        "_index": "job_postings",
        "_id": "JP-9021",
        "_score": 3.15,
        "_source": {
          "title": "Senior Data Engineer",
          "salary_range": "90000-120000",
          "remote_policy": "hybrid",
          "employment_type": "full_time",
          "closed_at": null
        }
      }
    ]
  }
}
```

**Key Points:**
- Despite `closed_at` being present in `_source` with a value of `null`, the `must_not exists` clause matches it because `null` is not indexed.
- The document is returned because `closed_at` has no indexed value.

---

**Conclusion:**

The `exists` query is a precise, efficient mechanism for checking whether a field has an indexed value. Its behavior is governed by indexing rules rather than `_source` presence, which makes understanding mapping configuration — particularly `index: false`, `null_value`, `ignore_malformed`, and `ignore_above` — essential to using it correctly. The `bool` `must_not` + `exists` pattern covers the inverse case. For most use cases, `exists` belongs in `filter` context where it avoids scoring overhead and benefits from caching.