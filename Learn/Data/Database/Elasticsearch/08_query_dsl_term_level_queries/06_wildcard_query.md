## Query DSL – Term Level Queries: Wildcard Query

### Overview

The **wildcard query** is a term-level query that matches documents containing terms conforming to a pattern defined using wildcard characters. Like other term-level queries, it operates directly against the values stored in the inverted index — the query string is **not analyzed**.

---

### Wildcard Characters

| Character | Meaning |
|---|---|
| `*` | Matches zero or more characters |
| `?` | Matches exactly one character |

These can appear anywhere in the pattern — at the start, middle, or end of the string.

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "wildcard": {
      "field_name": {
        "value": "pattern*"
      }
    }
  }
}
```

**Shorthand form:**

```json
GET /index_name/_search
{
  "query": {
    "wildcard": {
      "field_name": "pattern*"
    }
  }
}
```

---

### Parameters

| Parameter | Required | Description |
|---|---|---|
| `value` | Yes | The wildcard pattern to match against indexed terms. |
| `boost` | No | Floating-point score multiplier. Defaults to `1.0`. |
| `rewrite` | No | Controls internal query rewriting. Same options as `prefix` query. |
| `case_insensitive` | No | When `true`, matching ignores letter casing. Added in Elasticsearch 7.10. Defaults to `false`. |

---

### Practical Example

**Index mapping:**

```json
PUT /employees
{
  "mappings": {
    "properties": {
      "username": { "type": "keyword" },
      "email":    { "type": "keyword" }
    }
  }
}
```

**Sample documents:**

```json
{ "username": "john_doe",    "email": "john.doe@example.com" }
{ "username": "jane_doe",    "email": "jane.doe@example.com" }
{ "username": "john_smith",  "email": "john.smith@company.org" }
{ "username": "alice_jones", "email": "alice@example.com" }
```

---

#### Matching with `*`

Find all usernames that start with `john`:

```json
GET /employees/_search
{
  "query": {
    "wildcard": {
      "username": {
        "value": "john*"
      }
    }
  }
}
```

**Output:**

```json
{
  "hits": {
    "total": { "value": 2 },
    "hits": [
      { "_source": { "username": "john_doe" } },
      { "_source": { "username": "john_smith" } }
    ]
  }
}
```

---

#### Matching with `?`

Find usernames where the first four characters are `john` followed by exactly one character then `doe`:

```json
GET /employees/_search
{
  "query": {
    "wildcard": {
      "username": {
        "value": "j?hn_doe"
      }
    }
  }
}
```

**Output:**

```json
{
  "hits": {
    "total": { "value": 1 },
    "hits": [
      { "_source": { "username": "john_doe" } }
    ]
  }
}
```

---

#### Matching in the Middle of a Term

Find all emails containing `doe` anywhere in the address:

```json
GET /employees/_search
{
  "query": {
    "wildcard": {
      "email": {
        "value": "*doe*"
      }
    }
  }
}
```

**Output:**

```json
{
  "hits": {
    "total": { "value": 2 },
    "hits": [
      { "_source": { "email": "john.doe@example.com" } },
      { "_source": { "email": "jane.doe@example.com" } }
    ]
  }
}
```

---

### Case-Insensitive Matching

Available from Elasticsearch **7.10+**:

```json
GET /employees/_search
{
  "query": {
    "wildcard": {
      "username": {
        "value": "JOHN*",
        "case_insensitive": true
      }
    }
  }
}
```

Without `case_insensitive: true`, this would return zero results because the indexed terms are lowercase.

**Key Points:**
- [Inference] Case-insensitive wildcard matching likely carries a higher per-query cost than using a normalizer at index time, since it cannot rely on pre-normalized tokens. Behavior may vary across Elasticsearch versions and hardware.
- A `keyword` field with a `lowercase` normalizer is an alternative approach that shifts the cost to index time.

---

### Using a Normalizer as an Alternative

Rather than relying on `case_insensitive` at query time, you can define a normalizer on the field:

```json
PUT /employees
{
  "settings": {
    "analysis": {
      "normalizer": {
        "lowercase_normalizer": {
          "type": "custom",
          "filter": ["lowercase"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "username": {
        "type": "keyword",
        "normalizer": "lowercase_normalizer"
      }
    }
  }
}
```

With this mapping, all indexed values are stored in lowercase. Your wildcard query must then also use lowercase input:

```json
GET /employees/_search
{
  "query": {
    "wildcard": {
      "username": {
        "value": "john*"
      }
    }
  }
}
```

---

### Performance Considerations

Wildcard queries are among the most resource-intensive term-level queries. Key factors:

#### Leading Wildcards

Patterns beginning with `*` or `?` — such as `*smith` or `?ohn` — require Elasticsearch to scan **every term** in the inverted index for the field. This is because there is no anchored starting point to narrow the candidate term list.

```json
{
  "query": {
    "wildcard": {
      "username": { "value": "*smith" }
    }
  }
}
```

[Inference] Leading wildcard patterns are likely to cause significant performance degradation on high-cardinality fields, especially at scale. This is not guaranteed and depends on index size, shard configuration, and hardware. Behavior may vary.

**Mitigation strategies:**
- Avoid leading wildcards where possible.
- Store a reversed copy of the field value and use a trailing wildcard on the reversed field instead.
- Consider using `ngram` tokenizers on a `text` field for substring search, which shifts the cost to index time.

#### Pattern Selectivity

More specific patterns (longer literal prefix before the wildcard) narrow the candidate term set and execute faster. A pattern like `john_d*` is faster than `j*` on the same field.

#### Field Cardinality

Higher cardinality (more unique terms) means more terms to evaluate for any wildcard pattern. On very high-cardinality `keyword` fields, even trailing wildcards can be slow.

---

### `wildcard` Field Type

For use cases where wildcard queries are frequent and performance is critical, Elasticsearch provides a dedicated **`wildcard` field type** (introduced in **7.9**). It stores data in a structure optimized for wildcard and `regexp` queries, trading some index storage for faster query execution.

**Mapping:**

```json
PUT /logs
{
  "mappings": {
    "properties": {
      "message": { "type": "wildcard" }
    }
  }
}
```

**Query (same syntax as against `keyword`):**

```json
GET /logs/_search
{
  "query": {
    "wildcard": {
      "message": {
        "value": "*error*timeout*"
      }
    }
  }
}
```

**Key Points:**
- The `wildcard` field type is optimized for arbitrary pattern matching including leading wildcards.
- It uses a trigram-based internal structure to accelerate pattern matching.
- [Inference] For log analysis and similar use cases with frequent substring search, the `wildcard` field type is likely more performant than using a `keyword` field with wildcard queries. Actual performance depends on data distribution and query patterns. Behavior is not guaranteed.
- It does not support aggregations or sorting in the same way `keyword` fields do.

---

### Comparison: `wildcard` Query vs. Related Queries

| Query | Pattern Support | Analysis | Leading Wildcard Cost |
|---|---|---|---|
| `wildcard` | `*`, `?` anywhere | No | High on `keyword`; lower on `wildcard` field type |
| `prefix` | Start-anchored only | No | N/A — always leading-anchored forward |
| `regexp` | Full regular expressions | No | Depends on pattern complexity |
| `match` | Full-text token matching | Yes | N/A |
| `match_phrase_prefix` | Analyzed phrase with trailing prefix | Yes | N/A |

---

### Common Pitfalls

- **Leading wildcards on `keyword` fields** — causes full index term enumeration. Avoid unless the field uses the `wildcard` field type.
- **Querying `text` fields** — the query runs against analyzed tokens, not the original string. A pattern like `*Wireless*` against a `text` field storing `"Wireless Keyboard"` may not match because the token is `"wireless"` (lowercased). Use `field.keyword` or `case_insensitive: true` accordingly.
- **Case mismatch** — without `case_insensitive: true` or a normalizer, patterns must exactly match the case of indexed terms.
- **Assuming relevance ranking** — wildcard queries default to `constant_score`, so all matching documents receive the same score unless `rewrite` is adjusted.
- **Overuse in production** — wildcard queries with non-selective patterns on large indices can cause query latency spikes. Consider whether an `ngram` or `wildcard` field type approach better fits the access pattern.

---

### Summary

The wildcard query provides flexible pattern-based term matching using `*` and `?` characters. It is most reliable and predictable on `keyword` fields with sufficiently selective patterns. Leading wildcards carry a significant performance cost on standard `keyword` fields — for use cases requiring arbitrary substring search at scale, the dedicated `wildcard` field type or an `ngram`-based approach is worth evaluating. As with all term-level queries, the query string is not analyzed, so the pattern must align with the form of the indexed tokens.