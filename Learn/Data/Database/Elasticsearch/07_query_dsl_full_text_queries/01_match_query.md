## Elasticsearch match Query

The `match` query is the standard, go-to query for full-text search in Elasticsearch. It analyzes the input text before searching, making it suitable for searching human-readable content like descriptions, articles, and messages.

---

### How It Works

When a `match` query is executed, Elasticsearch passes the search term through the same analyzer applied to the field at index time. The resulting tokens are then used to find matching documents.

**Key Points:**
- The query string is analyzed before matching
- By default, analyzed tokens are combined with `OR` logic
- It operates on `text` fields primarily, but can work on other types
- It is not suitable for exact matching on `keyword` fields (use `term` for that)

---

### Basic Syntax

```json
GET /index_name/_search
{
  "query": {
    "match": {
      "field_name": "search text here"
    }
  }
}
```

The shorthand form above is the most common usage. An expanded form allows additional parameters:

```json
GET /index_name/_search
{
  "query": {
    "match": {
      "field_name": {
        "query": "search text here"
      }
    }
  }
}
```

---

### Practical Example

Assume an index called `articles` with a `content` field mapped as `text`.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": "elasticsearch full text search"
    }
  }
}
```

**What happens internally:**
1. The query string `"elasticsearch full text search"` is analyzed
2. Tokens produced: `elasticsearch`, `full`, `text`, `search`
3. Documents containing **any** of these tokens are returned (default `OR`)
4. Results are ranked by relevance score

**Output:**
Documents containing one or more of the tokens in the `content` field, ordered by `_score` descending.

---

### The `operator` Parameter

By default, tokens are combined with `OR`. Use the `operator` parameter to require **all** tokens to be present.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": {
        "query": "elasticsearch full text search",
        "operator": "and"
      }
    }
  }
}
```

| Operator | Behavior |
|---|---|
| `or` (default) | At least one token must match |
| `and` | All tokens must match |

**Key Points:**
- `and` produces fewer but more precise results
- `or` produces broader results with higher recall

---

### The `minimum_should_match` Parameter

For finer control between `or` and `and`, use `minimum_should_match` to specify how many tokens must match.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": {
        "query": "elasticsearch full text search",
        "minimum_should_match": 3
      }
    }
  }
}
```

Accepted value formats:

| Format | Example | Meaning |
|---|---|---|
| Integer | `2` | At least 2 tokens must match |
| Percentage | `"75%"` | At least 75% of tokens must match |
| Combination | `"2<75%"` | Rules vary by token count |

---

### The `fuzziness` Parameter

`fuzziness` allows the query to match terms that are similar but not identical to the search token, using edit distance (Levenshtein distance).

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": {
        "query": "elasticsaerch",
        "fuzziness": "AUTO"
      }
    }
  }
}
```

**Key Points:**
- `"AUTO"` is the recommended value — it adjusts allowed edits based on term length
- `0`, `1`, `2` are valid integer values for fixed edit distances
- `fuzziness` applies **after** analysis, per token
- [Inference] Higher fuzziness may reduce precision and increase recall; behavior may vary depending on the analyzer and index configuration

| Value | Behavior |
|---|---|
| `0` | Exact match only |
| `1` | One character difference allowed |
| `2` | Two character differences allowed |
| `AUTO` | Automatically determined by token length |

---

### The `prefix_length` Parameter

Used with `fuzziness`, `prefix_length` specifies the number of leading characters that must match exactly. This can improve performance and precision.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": {
        "query": "elasticsaerch",
        "fuzziness": "AUTO",
        "prefix_length": 3
      }
    }
  }
}
```

**Key Points:**
- A `prefix_length` of `3` means the first 3 characters must match exactly before fuzziness is applied
- [Inference] Higher values may improve query performance by reducing the fuzzy candidate set; not guaranteed

---

### The `analyzer` Parameter

By default, the analyzer assigned to the field at mapping time is used. You can override this per query.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": {
        "query": "Running Faster",
        "analyzer": "english"
      }
    }
  }
}
```

**Key Points:**
- The `english` analyzer applies stemming, so `"Running"` becomes `"run"`
- Overriding the analyzer at query time can produce unexpected results if it differs significantly from the index-time analyzer
- [Inference] Mismatched analyzers between index time and query time may reduce match quality; behavior depends on the specific analyzer configurations used

---

### The `zero_terms_query` Parameter

If the analyzer removes all tokens from the query string (e.g., stop words only), the behavior is controlled by `zero_terms_query`.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "content": {
        "query": "to be or not to be",
        "zero_terms_query": "all"
      }
    }
  }
}
```

| Value | Behavior |
|---|---|
| `none` (default) | No documents returned if all tokens removed |
| `all` | All documents returned if all tokens removed |

---

### The `lenient` Parameter

When `lenient` is set to `true`, format-based errors (e.g., querying a numeric field with a text string) are silently ignored rather than returning an error.

```json
GET /articles/_search
{
  "query": {
    "match": {
      "view_count": {
        "query": "not a number",
        "lenient": true
      }
    }
  }
}
```

**Key Points:**
- Useful when querying across multiple fields with varied types
- [Inference] Silently ignoring errors may make debugging harder; use with caution in production

---

### Relevance Scoring

The `match` query produces a `_score` for each matching document using the BM25 algorithm by default.

**Factors that influence score:**
- **Term frequency (TF):** How often the term appears in the document
- **Inverse document frequency (IDF):** How rare the term is across all documents
- **Field length normalization:** Shorter fields with the match score higher

[Inference] Score values are relative within a result set and are not guaranteed to be consistent across different queries, index configurations, or Elasticsearch versions.

---

### match vs Other Query Types

| Query | Use Case |
|---|---|
| `match` | Standard full-text search with analysis |
| `match_phrase` | Exact phrase matching, preserving word order |
| `match_phrase_prefix` | Phrase matching with prefix on last term |
| `multi_match` | `match` across multiple fields |
| `term` | Exact, unanalyzed value matching |

---

### Common Mistakes

**Querying a `keyword` field with `match`:**
```json
{
  "query": {
    "match": {
      "status.keyword": "Active"
    }
  }
}
```
[Inference] While this may work in some cases since `match` can operate on `keyword` fields, it bypasses analysis logic that is irrelevant for `keyword` types. Using `term` is the more appropriate and explicit choice.

---

**Using `match` when exact matching is intended:**
```json
{
  "query": {
    "match": {
      "username": "John_Doe"
    }
  }
}
```
If `username` is a `text` field, the analyzer may split or normalize the value. Use a `keyword` mapping with a `term` query for exact matching.

---

### Summary of Parameters

| Parameter | Type | Default | Purpose |
|---|---|---|---|
| `query` | string | *(required)* | The text to search for |
| `operator` | string | `or` | How multiple tokens are combined |
| `minimum_should_match` | int/string | — | Minimum number of tokens that must match |
| `fuzziness` | string/int | `0` | Allowed edit distance per token |
| `prefix_length` | int | `0` | Characters that must match exactly before fuzziness |
| `analyzer` | string | Field default | Analyzer to apply at query time |
| `zero_terms_query` | string | `none` | Behavior when all tokens are removed by analyzer |
| `lenient` | boolean | `false` | Ignore format-based errors |

---

**Conclusion:**
The `match` query is the foundation of full-text search in Elasticsearch. Understanding how analysis, operators, fuzziness, and scoring interact is essential for building effective search experiences. Most full-text search use cases begin with `match` before being refined with more specialized query types.

**Next Steps:**
- `match_phrase` — for word-order-sensitive phrase matching
- `multi_match` — for searching across multiple fields simultaneously
- `match_phrase_prefix` — for search-as-you-type functionality