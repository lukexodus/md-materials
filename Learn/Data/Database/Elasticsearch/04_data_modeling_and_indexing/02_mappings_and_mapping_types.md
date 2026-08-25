## Mappings and Mapping Types

---

### What Is a Mapping?

A **mapping** is the definition of how documents and their fields are stored and indexed in Elasticsearch. It specifies the data type of each field, how fields are analyzed, and various indexing behaviors.

Mappings serve two primary purposes:

1. **Type definition** — What kind of data each field holds (text, number, date, etc.)
2. **Indexing behavior** — How Elasticsearch processes and stores each field's value

Every index has exactly one mapping definition. If no mapping is explicitly provided, Elasticsearch creates one automatically through dynamic mapping.

---

### Mapping Types: A Historical Note

In versions prior to Elasticsearch 7.x, a single index could contain multiple **mapping types** (also called document types), similar to tables within a database. Each type had its own set of field definitions.

**Example (pre-7.x, now removed):**
```http
PUT /store/_doc/product/1   ← "product" was a type
PUT /store/_doc/order/1     ← "order" was a separate type
```

**Key Points:**
- Mapping types were **deprecated in Elasticsearch 7.0** and **removed in Elasticsearch 8.0**
- The removal was motivated by the fact that fields with the same name across types in one index shared the same underlying Lucene field — causing confusion and potential conflicts
- From Elasticsearch 7.x onward, each index has a single implicit type called `_doc`
- If you encounter `_doc` in API paths (e.g., `PUT /products/_doc/1`), it is a fixed endpoint identifier, not a user-defined type

> [Unverified] Some legacy systems or third-party tools may still reference mapping types in their documentation or configuration. Verify compatibility with your specific Elasticsearch version.

---

### Types of Mapping

There are two broad approaches to defining mappings in Elasticsearch:

#### Dynamic Mapping
#### Explicit Mapping

These are not mutually exclusive — an index can have an explicit mapping for known fields while still allowing dynamic mapping for new, unexpected fields.

---

### Dynamic Mapping

When dynamic mapping is enabled (the default), Elasticsearch automatically detects and adds new fields to the mapping when a document containing those fields is indexed for the first time.

#### Default Type Detection Rules

| JSON Input | Elasticsearch Type Assigned |
|---|---|
| `"2024-06-01"` (date-like string) | `date` |
| Any other string | `text` with `keyword` sub-field |
| Integer number | `long` |
| Decimal number | `float` |
| `true` / `false` | `boolean` |
| JSON object `{}` | `object` |
| JSON array | Determined by the first non-null element |
| `null` | No field added (ignored until a non-null value arrives) |

**Key Points:**
- String fields detected dynamically are mapped as both `text` AND a `keyword` sub-field by default
- This dual mapping allows the same field to be used for full-text search (`field`) and exact match or aggregation (`field.keyword`)
- [Inference] Dynamic mapping is generally acceptable for exploratory or development use; in production, unexpected fields or misdetected types can cause mapping conflicts or performance issues — actual behavior depends on data shape and Elasticsearch version

#### Controlling Dynamic Mapping

The `dynamic` parameter can be set at the index or object level with three values:

| Value | Behavior |
|---|---|
| `true` | New fields are added to the mapping automatically (default) |
| `false` | New fields are ignored — not indexed, not searchable, but stored in `_source` |
| `"strict"` | New fields cause an indexing error and the document is rejected |

**Example:** Setting strict dynamic mapping

```http
PUT /products
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "name": { "type": "text" },
      "price": { "type": "float" }
    }
  }
}
```

With `"strict"`, attempting to index a document with an unmapped field (e.g., `"discount"`) will return an error.

**Example:** Disabling dynamic mapping at the object level only

```http
PUT /orders
{
  "mappings": {
    "dynamic": true,
    "properties": {
      "metadata": {
        "type": "object",
        "dynamic": false
      }
    }
  }
}
```

Here, top-level new fields are still auto-mapped, but fields inside `metadata` are not indexed if not explicitly defined.

---

### Explicit Mapping

Explicit mapping gives you full control over field definitions. It is defined at index creation time or added later for new fields.

#### Defining Mapping at Index Creation

```http
PUT /articles
{
  "mappings": {
    "properties": {
      "title": { "type": "text" },
      "slug": { "type": "keyword" },
      "body": { "type": "text" },
      "author_id": { "type": "integer" },
      "published_at": { "type": "date" },
      "is_published": { "type": "boolean" },
      "view_count": { "type": "long" },
      "tags": { "type": "keyword" }
    }
  }
}
```

#### Adding Fields to an Existing Mapping

New fields can be added to an existing mapping using the `_mapping` API.

```http
PUT /articles/_mapping
{
  "properties": {
    "reading_time_minutes": { "type": "short" }
  }
}
```

**Key Points:**
- You can add new fields to an existing mapping
- You **cannot change** the type of an existing field
- You **cannot delete** a field from a mapping directly
- To change a field type or remove a field, you must create a new index with the desired mapping and reindex your data into it

---

### Field Mapping Parameters

Beyond specifying a data type, each field can accept additional **mapping parameters** that control indexing and storage behavior.

#### `index`

Controls whether a field is searchable.

```json
"internal_notes": {
  "type": "text",
  "index": false
}
```

- `true` (default): The field is indexed and searchable
- `false`: The field is stored in `_source` but cannot be queried

---

#### `store`

Controls whether the field value is stored separately from `_source`.

```json
"title": {
  "type": "text",
  "store": true
}
```

- By default, `store` is `false` — values are retrieved from `_source`
- Setting `store: true` stores the field independently, allowing retrieval without loading the entire `_source`
- [Inference] This may be useful when `_source` is disabled or the document is very large and only specific fields are regularly retrieved — actual performance impact varies

---

#### `doc_values`

Controls whether the field uses a columnar data structure for aggregations and sorting.

```json
"price": {
  "type": "float",
  "doc_values": false
}
```

- Enabled by default for most field types except `text` and `annotated_text`
- Disabling `doc_values` saves disk space but removes the ability to sort or aggregate on that field
- Cannot be changed after indexing without reindexing

---

#### `null_value`

Replaces `null` values with a substitute that can be indexed and searched.

```json
"status": {
  "type": "keyword",
  "null_value": "UNKNOWN"
}
```

**Key Points:**
- The actual `_source` still stores `null`; only the indexed value is replaced
- The substitute must be the same type as the field

---

#### `ignore_above`

For `keyword` fields, skips indexing strings longer than the specified character count.

```json
"tag": {
  "type": "keyword",
  "ignore_above": 256
}
```

- Values exceeding the limit are still stored in `_source` but are not indexed or searchable
- [Inference] Useful for preventing unexpectedly long strings from bloating the index

---

#### `ignore_malformed`

Allows documents with incorrectly typed field values to be indexed without error.

```json
"price": {
  "type": "float",
  "ignore_malformed": true
}
```

- When `true`, malformed values (e.g., a string in a `float` field) are stored in `_source` but not indexed
- When `false` (default), malformed values cause the entire document to be rejected

---

#### `copy_to`

Copies the field's value into another field during indexing.

```json
"first_name": {
  "type": "text",
  "copy_to": "full_name"
},
"last_name": {
  "type": "text",
  "copy_to": "full_name"
},
"full_name": {
  "type": "text"
}
```

**Key Points:**
- The target field (`full_name`) does not appear in `_source`; it exists only in the index
- Useful for creating a combined search field without duplicating data in `_source`
- The target field must be explicitly mapped

---

#### `fields` (Multi-Fields)

Maps a single field under multiple types simultaneously.

```json
"title": {
  "type": "text",
  "fields": {
    "keyword": {
      "type": "keyword",
      "ignore_above": 256
    }
  }
}
```

- `title` → full-text search
- `title.keyword` → exact match, sorting, aggregations

---

#### `analyzer`, `search_analyzer`, `search_quote_analyzer`

Controls text analysis behavior for `text` fields.

| Parameter | Description |
|---|---|
| `analyzer` | Analyzer used at index time |
| `search_analyzer` | Analyzer used at query time (defaults to `analyzer` if not set) |
| `search_quote_analyzer` | Analyzer used for phrase queries specifically |

```json
"body": {
  "type": "text",
  "analyzer": "english",
  "search_analyzer": "standard"
}
```

---

#### `format` (for `date` fields)

Defines accepted date formats.

```json
"published_at": {
  "type": "date",
  "format": "yyyy-MM-dd||epoch_millis"
}
```

- Multiple formats can be specified with `||` as a separator
- Elasticsearch attempts each format in order

---

#### `enabled`

Applies only to `object` fields. When set to `false`, the object and all its contents are stored in `_source` but not indexed in any way.

```json
"raw_payload": {
  "type": "object",
  "enabled": false
}
```

---

### Mapping for Nested and Object Types

#### Object Mapping

Object fields are mapped automatically when a JSON object is encountered. Fields within the object are accessible via dot notation.

```http
PUT /employees
{
  "mappings": {
    "properties": {
      "name": { "type": "text" },
      "address": {
        "properties": {
          "street": { "type": "text" },
          "city": { "type": "keyword" },
          "zip": { "type": "keyword" }
        }
      }
    }
  }
}
```

Internally, `address.city` and `address.zip` are flattened Lucene fields.

#### Nested Mapping

`nested` fields index each element of an object array as a separate hidden document, preserving relationships between fields within each element.

```http
PUT /products
{
  "mappings": {
    "properties": {
      "reviews": {
        "type": "nested",
        "properties": {
          "user": { "type": "keyword" },
          "rating": { "type": "byte" },
          "comment": { "type": "text" }
        }
      }
    }
  }
}
```

**Key Points:**
- Querying `nested` fields requires a `nested` query clause
- Each `nested` object is stored as a separate Lucene document internally — [Inference] large arrays of nested objects may increase index size and query cost noticeably, though actual impact depends on data volume and query patterns

---

### Dynamic Templates

Dynamic templates allow you to define custom mapping rules for fields that are detected dynamically, based on field name patterns, data types, or path patterns.

```http
PUT /logs
{
  "mappings": {
    "dynamic_templates": [
      {
        "strings_as_keywords": {
          "match_mapping_type": "string",
          "mapping": {
            "type": "keyword"
          }
        }
      }
    ]
  }
}
```

This template maps all dynamically detected string fields as `keyword` instead of the default `text` + `keyword` pair.

#### Template Match Conditions

| Parameter | Description |
|---|---|
| `match_mapping_type` | Matches by JSON-detected type (`string`, `long`, `double`, etc.) |
| `match` | Matches field names using a wildcard pattern |
| `unmatch` | Excludes field names matching a pattern |
| `path_match` | Matches by full dot-notation path |
| `path_unmatch` | Excludes by full dot-notation path |

**Example:** Map all fields ending in `_text` as `text`:

```json
{
  "text_fields": {
    "match": "*_text",
    "mapping": {
      "type": "text",
      "analyzer": "english"
    }
  }
}
```

---

### Retrieving and Inspecting Mappings

**Get full mapping for an index:**
```http
GET /products/_mapping
```

**Get mapping for a specific field:**
```http
GET /products/_mapping/field/price
```

**Get mapping across multiple indices:**
```http
GET /products,orders/_mapping
```

**Get mapping across all indices:**
```http
GET /_mapping
```

---

### Mapping Limits and Index-Level Controls

Elasticsearch provides index-level settings to limit mapping growth:

| Setting | Description |
|---|---|
| `index.mapping.total_fields.limit` | Maximum number of fields in an index (default: 1000) |
| `index.mapping.depth.limit` | Maximum depth of nested objects (default: 20) |
| `index.mapping.nested_fields.limit` | Maximum number of distinct `nested` field mappings (default: 50) |
| `index.mapping.nested_objects.limit` | Maximum number of nested JSON objects across all fields per document (default: 10000) |
| `index.mapping.field_name_length.limit` | Maximum character length for field names (default: no limit) |

**Key Points:**
- Exceeding `total_fields.limit` causes new field additions to be rejected
- [Inference] These limits exist to prevent unbounded mapping growth, which may degrade cluster performance — actual thresholds appropriate for your use case depend on hardware, data volume, and query patterns
- Limits can be updated on a live index via the `_settings` API, but increasing them beyond reasonable bounds is generally discouraged

---

### Runtime Fields

Runtime fields are a mapping type introduced in Elasticsearch 7.11 that are computed **at query time** rather than at index time. They do not exist in the stored index data.

```http
PUT /orders/_mapping
{
  "runtime": {
    "total_with_tax": {
      "type": "double",
      "script": {
        "source": "emit(doc['price'].value * 1.1)"
      }
    }
  }
}
```

**Key Points:**
- Runtime fields can be added to an existing mapping without reindexing
- They are slower to query than indexed fields because values are computed on the fly — [Inference] suitable for fields needed temporarily or for schema exploration, less suitable for high-frequency production queries; actual performance varies by script complexity and data volume
- Supported types: `boolean`, `date`, `double`, `geo_point`, `ip`, `keyword`, `long`, `lookup`

---

### Summary Table

| Concept | Description |
|---|---|
| Mapping | Schema defining fields, types, and indexing behavior |
| Dynamic mapping | Auto-detection and addition of new fields |
| Explicit mapping | Manually defined field types at index creation |
| `dynamic: true` | New fields auto-added (default) |
| `dynamic: false` | New fields ignored (not indexed) |
| `dynamic: "strict"` | New fields cause indexing error |
| `index: false` | Field stored but not searchable |
| `doc_values: false` | Field not usable for sort or aggregation |
| `copy_to` | Combines field values into a target field |
| Multi-fields | One field mapped under multiple types |
| Dynamic templates | Custom rules for dynamically detected fields |
| Runtime fields | Computed at query time; no reindexing required |
| Nested mapping | Array objects indexed independently |

---

**Conclusion:**
Mappings are one of the most consequential configuration decisions in Elasticsearch. Incorrect or uncontrolled mappings can cause type conflicts, poor search quality, and performance degradation. Understanding when to use dynamic versus explicit mapping, how to apply field parameters, and how to handle schema evolution prepares you to design indices that are both flexible and production-ready.

**Next Steps:**
- Analyzers, tokenizers, and token filters
- Reindexing strategies for mapping changes
- Index templates and component templates
- Runtime fields in search queries