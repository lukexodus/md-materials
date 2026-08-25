## Elasticsearch multi_match Query

The `multi_match` query extends `match` to operate across **multiple fields simultaneously**. Instead of targeting a single field, it allows a single query string to be searched across several fields, with flexible control over how field scores are combined.

---

### How It Works

Internally, `multi_match` builds one or more `match` queries — one per field — and combines their results according to a specified `type`. The query string is analyzed per field using each field's assigned analyzer unless overridden.

**Key Points:**
- Analyzes the query string against each field independently
- Each field can be weighted using a boost modifier
- The `type` parameter determines how scores from multiple fields are combined
- Wildcard field patterns are supported (e.g., `"fields": ["title*"]`)
- At least one field must match for a document to be returned (by default)

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "multi_match": {
      "query": "search text here",
      "fields": ["field_one", "field_two", "field_three"]
    }
  }
}
```

---

### Practical Example

Assume an index called `articles` with fields `title`, `summary`, and `content`.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch performance tuning",
      "fields": ["title", "summary", "content"]
    }
  }
}
```

**What happens internally:**
1. The query string is analyzed per field
2. A `match` query is executed against each field
3. Documents matching in any field are returned
4. Scores are combined according to the default `type` (`best_fields`)

**Output:**
Documents matching the query in any of the three fields, scored and ranked by relevance.

---

### Field Boosting

Individual fields can be boosted using the `^` operator to increase their influence on the final score.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch performance tuning",
      "fields": ["title^3", "summary^2", "content"]
    }
  }
}
```

**Key Points:**
- `^3` multiplies the field's score contribution by 3
- Boosting does not filter results — it only shifts scoring weight
- [Inference] Boost values are multipliers on the computed score, not absolute score adders; exact impact depends on BM25 scoring and document content

---

### Wildcard Field Patterns

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "tuning",
      "fields": ["title*"]
    }
  }
}
```

This matches all fields whose names begin with `title`, such as `title`, `title.raw`, `title_en`, etc.

**Key Points:**
- Useful when working with multi-language mappings or dynamic field naming conventions
- [Inference] Wildcard patterns resolve at query time against the index mapping; fields added after the query is constructed will be included if they match the pattern

---

### The `type` Parameter

The `type` parameter is the most important control in `multi_match`. It determines how the per-field match queries are constructed and how their scores are combined.

---

### type: best_fields (Default)

Finds documents that match the query in **any** field, and uses the score from the **best-matching field** as the document score. A `tie_breaker` can incorporate scores from other matching fields.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch tuning",
      "fields": ["title", "summary", "content"],
      "type": "best_fields",
      "tie_breaker": 0.3
    }
  }
}
```

**Key Points:**
- Default `type` when `type` is not specified
- Best for fields that are competing — where the most relevant field should dominate
- `tie_breaker` (range: `0.0`–`1.0`) adds a fraction of other matching fields' scores to the best field score
- `tie_breaker: 0.0` means only the best field score counts; `tie_breaker: 1.0` sums all field scores

| tie_breaker | Effect |
|---|---|
| `0.0` | Only best field score used |
| `0.3` | Best score + 30% of others |
| `1.0` | All field scores summed |

---

### type: most_fields

Finds documents matching in any field and **sums the scores** from all matching fields. Rewards documents that match across multiple fields.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch tuning",
      "fields": ["title", "summary", "content"],
      "type": "most_fields"
    }
  }
}
```

**Key Points:**
- Best when multiple fields contain variations of the same content (e.g., stemmed and unstemmed versions)
- A document matching in all three fields scores higher than one matching in only one
- [Inference] `most_fields` can over-reward documents that repeat the same content across many fields; results may require tuning

---

### type: cross_fields

Treats all specified fields as if they were **one combined field**. Tokens from the query must appear across the combined field set, not necessarily all within a single field.

```json
GET /contacts/_search
{
  "query": {
    "multi_match": {
      "query": "John Smith",
      "fields": ["first_name", "last_name"],
      "type": "cross_fields"
    }
  }
}
```

**What this means:**
- `"John"` can match in `first_name` and `"Smith"` can match in `last_name`
- A document with `first_name: John` and `last_name: Smith` would match
- A `match` with `type: best_fields` would not reliably handle this case

**Key Points:**
- Best for structured data split across fields (names, addresses)
- Requires all fields to use the **same analyzer**
- `operator: and` can be used to require all tokens to appear somewhere across the fields
- [Inference] If fields use different analyzers, `cross_fields` behavior may be unpredictable; behavior is not guaranteed across all configurations

```json
GET /contacts/_search
{
  "query": {
    "multi_match": {
      "query": "John Smith",
      "fields": ["first_name", "last_name"],
      "type": "cross_fields",
      "operator": "and"
    }
  }
}
```

---

### type: phrase

Runs a `match_phrase` query on each field and uses the best field score.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "quick brown fox",
      "fields": ["title", "content"],
      "type": "phrase"
    }
  }
}
```

**Key Points:**
- Enforces phrase order and adjacency per field
- `slop` is supported
- Combines per-field phrase scores using `best_fields` logic by default

---

### type: phrase_prefix

Runs a `match_phrase_prefix` query on each field and uses the best field score.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "quick brown fo",
      "fields": ["title", "content"],
      "type": "phrase_prefix"
    }
  }
}
```

**Key Points:**
- Last token treated as a prefix across all specified fields
- `max_expansions` applies and limits prefix expansion per field
- Suitable for multi-field search-as-you-type scenarios

---

### type: bool_prefix

Analyzes the query string and constructs a `bool` query. All tokens except the last use `match`; the last token uses `match_phrase_prefix`.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch full tex",
      "fields": ["title", "summary"],
      "type": "bool_prefix"
    }
  }
}
```

**Key Points:**
- Unlike `phrase_prefix`, tokens do not need to appear in order
- Each non-final token is an independent `match` clause
- Final token is a prefix match
- [Inference] `bool_prefix` may return more results than `phrase_prefix` because order is not enforced; suitable when word order is less critical

---

### Type Comparison Summary

| Type | Order Enforced | Score Strategy | Best For |
|---|---|---|---|
| `best_fields` | No | Best field score (+ tie_breaker) | Competing fields, general search |
| `most_fields` | No | Sum of all matching field scores | Fields with content variations |
| `cross_fields` | No | Unified field scoring | Structured data split across fields |
| `phrase` | Yes | Best field phrase score | Exact phrase across fields |
| `phrase_prefix` | Yes | Best field prefix phrase score | Multi-field autocomplete (phrase) |
| `bool_prefix` | No | Bool scoring with prefix on last token | Multi-field autocomplete (flexible) |

---

### The `operator` Parameter

Controls how analyzed tokens are combined within each field query.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch performance tuning",
      "fields": ["title", "content"],
      "operator": "and"
    }
  }
}
```

| Value | Behavior |
|---|---|
| `or` (default) | At least one token must match per field |
| `and` | All tokens must match per field (or across fields for `cross_fields`) |

---

### The `minimum_should_match` Parameter

Applies the same way as in `match`. Specifies how many tokens must match.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch performance tuning guide",
      "fields": ["title", "content"],
      "minimum_should_match": "75%"
    }
  }
}
```

**Key Points:**
- Applies to `best_fields` and `most_fields` types
- Not applicable to `cross_fields`, `phrase`, or `phrase_prefix` types

---

### The `fuzziness` Parameter

Applies fuzzy matching to tokens, same as in `match`.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsaerch performanc",
      "fields": ["title", "content"],
      "fuzziness": "AUTO"
    }
  }
}
```

**Key Points:**
- Applies to `best_fields`, `most_fields`, and `cross_fields` types
- Not supported for `phrase` or `phrase_prefix` types
- [Inference] Fuzziness increases recall at the cost of precision; behavior depends on token length and edit distance configuration

---

### The `analyzer` Parameter

Overrides the query-time analyzer for all fields in the query.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "Running Faster",
      "fields": ["title", "content"],
      "analyzer": "english"
    }
  }
}
```

**Key Points:**
- A single analyzer is applied to all fields
- [Inference] If fields were indexed with different analyzers, applying one query-time analyzer may cause mismatches; behavior is not guaranteed to be consistent

---

### The `zero_terms_query` Parameter

Same behavior as in `match` and `match_phrase`.

| Value | Behavior |
|---|---|
| `none` (default) | No documents returned when all tokens removed |
| `all` | All documents returned when all tokens removed |

---

### The `tie_breaker` Parameter

Only relevant for `best_fields` type (and implicitly for `phrase` and `phrase_prefix`).

```json
{
  "multi_match": {
    "query": "tuning guide",
    "fields": ["title", "summary", "content"],
    "type": "best_fields",
    "tie_breaker": 0.3
  }
}
```

**Score formula with tie_breaker:**
```
final_score = best_field_score + (tie_breaker × score_of_each_other_matching_field)
```

[Inference] The exact contribution of `tie_breaker` depends on the individual field scores computed by BM25; results may vary by index configuration and document distribution.

---

### Common Mistakes

**Using `most_fields` when fields are independent:**

If `title` and `content` are semantically distinct, `most_fields` may over-reward documents that happen to mention the term in both. `best_fields` is usually more appropriate for independent fields.

---

**Using `cross_fields` with mismatched analyzers:**

`cross_fields` blends IDF across fields. If fields use different analyzers, the IDF blending produces unreliable scores.

---

**Forgetting that boosting affects score, not filtering:**

```json
"fields": ["title^10", "content"]
```

A document matching only in `content` can still outscore a document matching in `title` if the content match is significantly stronger. Boosting shifts weight; it does not guarantee field priority.

---

### Summary of Parameters

| Parameter | Type | Default | Purpose |
|---|---|---|---|
| `query` | string | *(required)* | The search text |
| `fields` | array | *(required)* | Fields to search; supports `^` boosting and wildcards |
| `type` | string | `best_fields` | Score combination strategy |
| `operator` | string | `or` | Token combination logic |
| `minimum_should_match` | int/string | — | Minimum token match threshold |
| `fuzziness` | string/int | `0` | Edit distance for fuzzy matching |
| `analyzer` | string | Field default | Query-time analyzer override |
| `tie_breaker` | float | `0.0` | Weight given to non-best field scores |
| `zero_terms_query` | string | `none` | Behavior when analyzer removes all tokens |
| `max_expansions` | integer | `50` | Prefix expansion limit (`phrase_prefix`, `bool_prefix`) |
| `slop` | integer | `0` | Positional flexibility (`phrase`, `phrase_prefix`) |

---

**Conclusion:**
`multi_match` is one of the most versatile queries in Elasticsearch, offering six distinct scoring strategies through the `type` parameter. Choosing the right type is critical: `best_fields` suits independent fields, `cross_fields` suits structured data split across fields, and `phrase`/`phrase_prefix`/`bool_prefix` suit order-sensitive or autocomplete use cases. Field boosting and `tie_breaker` provide further scoring control without requiring custom scripting.

**Next Steps:**
- `query_string` query — powerful but strict syntax-aware full-text query
- `simple_query_string` — user-facing, fault-tolerant alternative to `query_string`
- `combined_fields` query — a newer alternative to `cross_fields` with improved IDF handling