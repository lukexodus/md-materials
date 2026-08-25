## Dynamic vs Explicit Mappings in Elasticsearch

---

### What Are Mappings?

Mappings define how documents and their fields are stored and indexed in Elasticsearch. A mapping specifies the data type of each field, how it should be indexed, and how it should be analyzed for search. Without a mapping, Elasticsearch must make decisions on your behalf — this is where dynamic mapping enters.

---

### Dynamic Mapping

When you index a document without a pre-defined mapping, Elasticsearch inspects the incoming field values and automatically assigns data types. This behavior is called **dynamic mapping**.

**How it works:**

When a new field is encountered, Elasticsearch applies a set of detection rules based on the JSON value type:

| JSON Value | Inferred Elasticsearch Type |
|---|---|
| `true` / `false` | `boolean` |
| Integer number | `long` |
| Floating point number | `float` |
| String matching a date pattern | `date` |
| String (general) | `text` + `keyword` sub-field |
| Object `{}` | `object` |
| Array | Depends on first non-null element |

**Example:**

Indexing the following document with no prior mapping:

```json
PUT /employees/_doc/1
{
  "name": "Maria Santos",
  "age": 34,
  "active": true,
  "hire_date": "2021-06-15",
  "salary": 75000.50
}
```

Elasticsearch will automatically infer:

```json
{
  "mappings": {
    "properties": {
      "name":      { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "age":       { "type": "long" },
      "active":    { "type": "boolean" },
      "hire_date": { "type": "date" },
      "salary":    { "type": "float" }
    }
  }
}
```

> [Inference] Elasticsearch's type inference is based on the first document indexed containing a given field. Subsequent documents with the same field in a different format may cause indexing errors. Behavior may vary across versions.

---

### Dynamic Mapping Modes

Dynamic mapping behavior is controlled by the `dynamic` parameter, which can be set at the index or object level.

| Mode | Behavior |
|---|---|
| `true` (default) | New fields are detected and added to the mapping automatically |
| `false` | New fields are ignored — not indexed, not searchable, but stored in `_source` |
| `strict` | New fields cause the indexing request to fail with an error |
| `runtime` | New fields are added as runtime fields instead of indexed fields |

**Example — setting strict mode:**

```json
PUT /employees
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "name": { "type": "text" },
      "age":  { "type": "integer" }
    }
  }
}
```

Indexing a document with an unmapped field like `"department": "Engineering"` will now return a mapping exception.

---

### Explicit Mapping

Explicit mapping means you define the fields, their types, and their indexing behavior yourself — before or at index creation time. This gives you full control over how data is stored and searched.

**Example — creating an explicit mapping:**

```json
PUT /employees
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "name": {
        "type": "text",
        "analyzer": "standard",
        "fields": {
          "keyword": { "type": "keyword" }
        }
      },
      "age": {
        "type": "integer"
      },
      "active": {
        "type": "boolean"
      },
      "hire_date": {
        "type": "date",
        "format": "yyyy-MM-dd"
      },
      "salary": {
        "type": "scaled_float",
        "scaling_factor": 100
      },
      "department": {
        "type": "keyword"
      }
    }
  }
}
```

---

### Adding Fields to an Explicit Mapping

Elasticsearch mappings are **append-only** — you can add new fields to an existing mapping, but you cannot change the type of an already-mapped field without reindexing.

**Adding a new field:**

```json
PUT /employees/_mapping
{
  "properties": {
    "location": {
      "type": "geo_point"
    }
  }
}
```

**Attempting to change an existing field type:**

This is not supported directly. Changing a field type requires:

1. Creating a new index with the corrected mapping
2. Using the `_reindex` API to copy documents over
3. Optionally using an alias to switch traffic to the new index

---

### Dynamic Templates

Dynamic templates extend dynamic mapping by letting you define custom rules for how automatically detected fields are mapped. They are applied when a new field is encountered that matches the template's conditions.

**Example — map all string fields ending in `_id` as `keyword`:**

```json
PUT /orders
{
  "mappings": {
    "dynamic_templates": [
      {
        "ids_as_keyword": {
          "match_pattern": "regex",
          "match": ".*_id$",
          "mapping": {
            "type": "keyword"
          }
        }
      }
    ]
  }
}
```

**Example — map all fields inside a `metrics` object as `float`:**

```json
{
  "dynamic_templates": [
    {
      "metrics_as_float": {
        "path_match": "metrics.*",
        "mapping": {
          "type": "float"
        }
      }
    }
  ]
}
```

Dynamic templates are evaluated in order — the first matching template wins.

---

### Mapping Explosion

When dynamic mapping is enabled with no constraints, ingesting documents with many unique or unpredictable fields can cause the mapping to grow unboundedly. This is known as **mapping explosion**.

**Symptoms:**
- Cluster state grows excessively large
- Performance degradation on mapping updates
- Potential heap pressure on master nodes

**Mitigation strategies:**

- Set `dynamic: false` or `dynamic: strict` to control unmapped fields
- Use the `index.mapping.total_fields.limit` setting (default: 1000) to cap field count
- Flatten deeply nested structures where possible
- Use `flattened` field type for objects with highly variable keys

```json
PUT /logs
{
  "settings": {
    "index.mapping.total_fields.limit": 500
  },
  "mappings": {
    "dynamic": false
  }
}
```

---

### Dynamic vs Explicit — Comparison

| Consideration | Dynamic Mapping | Explicit Mapping |
|---|---|---|
| Setup effort | Low | Higher |
| Type accuracy | [Inference] May not match intent | Precise and intentional |
| Prototyping | Well-suited | Less convenient |
| Production use | Risky without constraints | Recommended |
| Schema enforcement | None by default | Fully enforceable with `strict` |
| Mapping explosion risk | Higher | Lower |
| Reindexing required to fix types | Yes | Yes (same constraint applies) |

---

### Runtime Fields as an Alternative

Runtime fields are computed at query time and do not affect the stored mapping. They offer a flexible middle ground — you can define field behavior without committing to an indexed type.

```json
PUT /employees/_mapping
{
  "runtime": {
    "full_name": {
      "type": "keyword",
      "script": {
        "source": "emit(doc['first_name'].value + ' ' + doc['last_name'].value)"
      }
    }
  }
}
```

> [Inference] Runtime fields trade indexing flexibility for query-time performance cost. They are not physically stored in the inverted index. Query performance impact depends on dataset size and query frequency. Behavior may vary.

---

### Retrieving a Mapping

To inspect the current mapping of an index:

```json
GET /employees/_mapping
```

To inspect a specific field:

```json
GET /employees/_mapping/field/hire_date
```

---

### Best Practices

- **Use explicit mappings in production.** Dynamic mapping is convenient for prototyping but introduces risk when field types are inferred incorrectly.
- **Set `dynamic: strict` for critical indices** to prevent unmapped fields from silently bypassing your schema.
- **Use dynamic templates** when you need controlled flexibility — rules-based inference rather than fully open-ended detection.
- **Plan for reindexing.** Since field types cannot be changed in place, designing mappings carefully upfront reduces operational burden later.
- **Monitor total field count** using the `_mapping` API and set `total_fields.limit` appropriate to your use case.
- **Prefer `keyword` over `text`** for fields used only in filtering, aggregations, or sorting — it avoids unnecessary analysis overhead.

---