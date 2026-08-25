## Query DSL – Term Level Queries: Prefix Query

### Overview

The **prefix query** is a term-level query in Elasticsearch that matches documents containing terms beginning with a specified prefix in a given field. Because it operates at the term level, it works against the exact values stored in the inverted index — no analysis is applied to the query input.

---

### How It Works

When you execute a prefix query, Elasticsearch scans the inverted index for the target field and collects every term that starts with the given prefix string. All documents containing any of those matching terms are returned.

Because the query string is **not analyzed**, the prefix you provide must match the form of the tokens as they were indexed. For a `keyword` field, this is the raw value. For a `text` field, tokens are in their analyzed (typically lowercased) form.

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "prefix": {
      "field_name": {
        "value": "prefix_string"
      }
    }
  }
}
```

**Shorthand form** (without parameters):

```json
GET /index_name/_search
{
  "query": {
    "prefix": {
      "field_name": "prefix_string"
    }
  }
}
```

---

### Parameters

| Parameter | Required | Description |
|---|---|---|
| `value` | Yes | The prefix string to match against indexed terms. |
| `rewrite` | No | Controls how the query is rewritten internally. Affects scoring and performance. Common values: `constant_score` (default), `scoring_boolean`, `top_terms_N`. |
| `case_insensitive` | No | When `true`, matching is case-insensitive. Added in Elasticsearch 7.10. Defaults to `false`. |
| `boost` | No | Floating-point multiplier applied to the relevance score of matching documents. Defaults to `1.0`. |

---

### Practical Example

**Index mapping:**

```json
PUT /products
{
  "mappings": {
    "properties": {
      "sku": { "type": "keyword" },
      "name": { "type": "text" }
    }
  }
}
```

**Sample documents:**

```json
{ "sku": "ELEC-001", "name": "Wireless Keyboard" }
{ "sku": "ELEC-002", "name": "Wireless Mouse" }
{ "sku": "FURN-001", "name": "Office Chair" }
{ "sku": "ELEC-003", "name": "USB-C Hub" }
```

**Query — find all SKUs beginning with `ELEC`:**

```json
GET /products/_search
{
  "query": {
    "prefix": {
      "sku": {
        "value": "ELEC"
      }
    }
  }
}
```

**Output:**

```json
{
  "hits": {
    "total": { "value": 3 },
    "hits": [
      { "_source": { "sku": "ELEC-001", "name": "Wireless Keyboard" } },
      { "_source": { "sku": "ELEC-002", "name": "Wireless Mouse" } },
      { "_source": { "sku": "ELEC-003", "name": "USB-C Hub" } }
    ]
  }
}
```

---

### Case-Insensitive Matching

Available from Elasticsearch **7.10+**, the `case_insensitive` parameter allows matching regardless of letter casing without requiring a custom normalizer on the field.

```json
GET /products/_search
{
  "query": {
    "prefix": {
      "sku": {
        "value": "elec",
        "case_insensitive": true
      }
    }
  }
}
```

This returns the same three documents even though the indexed values are uppercase.

**Key Points:**
- Without `case_insensitive: true`, the query `"elec"` would return zero results against uppercase `"ELEC"` terms.
- [Inference] Using `case_insensitive: true` likely has a higher query cost than a normalizer-based approach because it cannot rely on a pre-normalized index structure. Behavior may vary depending on cluster version and shard conditions.

---

### Using `rewrite` for Performance and Scoring Control

The `rewrite` parameter controls how Elasticsearch internally rewrites the prefix query before execution. This affects both scoring behavior and performance.

```json
GET /products/_search
{
  "query": {
    "prefix": {
      "sku": {
        "value": "ELEC",
        "rewrite": "constant_score"
      }
    }
  }
}
```

**Common `rewrite` values:**

| Value | Behavior |
|---|---|
| `constant_score` | Default. Assigns a constant score to all matching docs. Most performant for large term sets. |
| `constant_score_boolean` | Same constant score, but uses a boolean query internally. |
| `scoring_boolean` | Scores each matching term. Can be expensive with many matching terms. |
| `top_terms_N` | Only considers the top N matching terms by document frequency. |
| `top_terms_boost_N` | Like `top_terms_N` but assigns individual boost values per term. |
| `top_terms_blended_freqs_N` | Blends frequencies across shards for more accurate scoring. |

---

### Prefix Query on `text` Fields

While technically supported, prefix queries on `text` fields operate against analyzed tokens, which may produce unexpected results.

**Example:**

If `name` is a `text` field and the document contains `"Wireless Keyboard"`, the inverted index stores tokens like `"wireless"` and `"keyboard"`. A prefix query for `"Wire"` would **not** match because the token is `"wireless"` (lowercased) and `"Wire"` (capital W) does not match `"wireless"`.

```json
GET /products/_search
{
  "query": {
    "prefix": {
      "name": {
        "value": "wire"
      }
    }
  }
}
```

This would match documents containing the token `"wireless"` because `"wireless"` begins with `"wire"`.

**Key Points:**
- For predictable prefix matching on string fields, use `keyword` type or a `keyword` sub-field (e.g., `name.keyword`).
- Prefix queries on `text` fields are sensitive to the analyzer used at index time.

---

### `index_prefixes` — Accelerating Prefix Queries

Elasticsearch provides a mapping-level optimization for prefix queries called `index_prefixes`. When enabled on a `text` field, Elasticsearch indexes additional prefix tokens at index time, allowing prefix queries to run as term lookups instead of full index scans.

**Mapping configuration:**

```json
PUT /products
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text",
        "index_prefixes": {
          "min_chars": 2,
          "max_chars": 5
        }
      }
    }
  }
}
```

| Option | Default | Description |
|---|---|---|
| `min_chars` | `2` | Minimum prefix length to index. |
| `max_chars` | `5` | Maximum prefix length to index. |

**Key Points:**
- `index_prefixes` increases index size in exchange for faster prefix query execution.
- It applies only to `text` fields, not `keyword` fields.
- [Inference] Prefix queries within the configured `min_chars`–`max_chars` range are likely resolved as term queries against the prefix index, making them substantially faster on large indices. This behavior is not guaranteed and may vary across versions.

---

### Performance Considerations

Prefix queries can be expensive depending on field cardinality and prefix length:

- **Short prefixes** (e.g., a single character) match a large number of terms in the inverted index, requiring Elasticsearch to union many term posting lists. This is slower and more memory-intensive.
- **Longer prefixes** narrow the candidate term set significantly, resulting in faster execution.
- On `keyword` fields with high cardinality, short prefix queries may scan a large portion of the index.
- Using `index_prefixes` on `text` fields or designing a dedicated `keyword` field for prefix lookups are common mitigation strategies.

[Inference] In search-as-you-type scenarios, very short prefixes (1–2 characters) may cause noticeable latency on large indices without structural optimizations such as `index_prefixes` or a dedicated `search_as_you_type` field type. Behavior may vary based on hardware, shard count, and data volume.

---

### Comparison with Related Queries

| Query Type | Use Case | Analysis Applied |
|---|---|---|
| `prefix` | Terms starting with a string | No |
| `wildcard` | Pattern matching with `*` and `?` | No |
| `match_phrase_prefix` | Analyzed prefix on the last term of a phrase | Yes (analyzer) |
| `search_as_you_type` field | Optimized incremental search | Yes (specialized) |

- Use `prefix` when you know the exact start of a term and the field is `keyword` or you want raw token matching.
- Use `match_phrase_prefix` when working with natural language text and you want the analyzer to handle the prefix.
- Use the `search_as_you_type` field type for high-performance autocomplete use cases.

---

### Common Pitfalls

- **Querying analyzed `text` fields with capitalized input** — the indexed tokens are typically lowercased; the prefix must match the token form exactly (unless `case_insensitive: true` is used).
- **Very short prefixes on high-cardinality fields** — can cause slow queries due to large term enumeration.
- **Expecting relevance scoring** — by default, prefix queries use `constant_score`, meaning all matching documents receive the same score. Use `rewrite: scoring_boolean` if ranked results are needed, keeping performance trade-offs in mind.
- **Forgetting sub-fields** — if a field is mapped as `text`, remember to target `field.keyword` for raw prefix matching.

---

### Summary

The prefix query is a straightforward but potentially resource-intensive way to match documents where a field's term starts with a given string. It is best suited for `keyword` fields with reasonably selective prefixes. For text fields, consider the impact of analysis. For high-traffic autocomplete scenarios, structural alternatives like `index_prefixes` or the `search_as_you_type` field type provide better performance characteristics.