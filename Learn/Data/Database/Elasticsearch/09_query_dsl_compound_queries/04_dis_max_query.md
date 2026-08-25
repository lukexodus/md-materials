## Query DSL – Compound Queries: `dis_max` Query

### Overview

The `dis_max` query (short for **Disjunction Max**) executes multiple query clauses and returns documents that match **at least one** of them. Unlike a `bool` + `should` query — which sums the scores of all matching clauses — `dis_max` assigns each document the score of its **single best-matching clause**, with an optional small addition from other matching clauses controlled by the `tie_breaker` parameter.

This makes it particularly well-suited for **multi-field searches**, where a match in any one field should determine the document's relevance rather than accumulating scores across all fields.

---

### Core Concepts

| Parameter | Required | Description |
|-----------|----------|-------------|
| `queries` | ✅ Yes | Array of query clauses. A document must match at least one. |
| `tie_breaker` | ❌ No | A multiplier (`0.0`–`1.0`) applied to scores of non-best matching clauses, then added to the best score. Defaults to `0.0`. |

---

### The Problem It Solves

Consider a search for "quick brown fox" across two fields: `title` and `body`. Using `bool` + `should`:

```json
{
  "bool": {
    "should": [
      { "match": { "title": "quick brown fox" } },
      { "match": { "body":  "quick brown fox" } }
    ]
  }
}
```

A document matching in **both** `title` and `body` receives the **sum** of both clause scores. This can cause a document with mediocre matches in both fields to outscore a document with an excellent match in just one field — an undesirable outcome for multi-field relevance.

`dis_max` addresses this by taking only the **highest clause score**, so a strong single-field match is not diluted or unfairly outranked by weaker multi-field matches.

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "dis_max": {
      "queries": [
        { <query_clause_1> },
        { <query_clause_2> },
        { <query_clause_3> }
      ],
      "tie_breaker": 0.0
    }
  }
}
```

---

### Scoring Behavior

#### Without `tie_breaker` (default: `0.0`)

The document's score equals the score of its single best-matching clause. Scores from all other matching clauses are ignored entirely.

```
final_score = max(clause_scores)
```

#### With `tie_breaker`

Scores from all non-best clauses are multiplied by `tie_breaker` and added to the best clause score:

```
final_score = max(clause_scores) + (tie_breaker × sum(all_other_matching_clause_scores))
```

This allows documents matching in multiple clauses to score slightly higher than documents matching in only the best clause — without fully summing all clause scores as `bool` + `should` would.

> [Inference] Score values are computed based on BM25 similarity by default. Exact values depend on index statistics, field mappings, and Elasticsearch version. The formulas above reflect documented behavior but actual computation may vary.

---

### Score Comparison: `bool` vs `dis_max`

**Setup:** Two documents, two fields (`title`, `body`), searching for "elasticsearch performance".

| Document | Title Score | Body Score | `bool` should Score (sum) | `dis_max` Score (max, tie_breaker=0.0) |
|----------|------------|-----------|--------------------------|---------------------------------------|
| A | 3.5 | 3.4 | 6.9 | 3.5 |
| B | 0.0 | 4.8 | 4.8 | 4.8 |

With `bool` + `should`, Document A ranks higher due to score accumulation across both fields. With `dis_max`, Document B ranks higher because it has a stronger single-field match — which is often the more relevant result.

> [Inference] Scores are illustrative. Actual BM25 scores depend on term frequency, inverse document frequency, and field length normalization.

---

### Example: Multi-Field Product Search

**Scenario:** Search for "wireless headphones" across `name`, `description`, and `tags`. A strong match in any single field should surface the document.

```json
GET /products/_search
{
  "query": {
    "dis_max": {
      "queries": [
        { "match": { "name":        "wireless headphones" } },
        { "match": { "description": "wireless headphones" } },
        { "match": { "tags":        "wireless headphones" } }
      ],
      "tie_breaker": 0.3
    }
  }
}
```

**Output behavior:**
- A product with an excellent match in `name` ranks at the top, regardless of how it scores in `description` or `tags`.
- A product with moderate matches across all three fields receives a small additional score from the `tie_breaker`, but does not outrank the strong single-field match.

---

### Understanding `tie_breaker`

The `tie_breaker` value controls how much influence secondary matching clauses have on the final score.

| `tie_breaker` | Behavior |
|---------------|----------|
| `0.0` (default) | Only the best clause score counts. Secondary matches ignored entirely. |
| `0.3` | Common practical value. Secondary matches contribute a small amount. |
| `1.0` | All clause scores are fully summed — equivalent to `bool` + `should`. |

**Example with `tie_breaker: 0.3`:**

A document scores 4.0 in `title` and 2.0 in `body`:

```
final_score = 4.0 + (0.3 × 2.0) = 4.6
```

A document scores 4.0 in `title` only:

```
final_score = 4.0
```

The first document scores slightly higher because it also matched in `body`, but the `title` match still dominates.

> [Inference] This formula reflects documented Elasticsearch behavior. Actual score computation may vary depending on version and similarity configuration.

---

### Example: Article Search Across Title and Content

```json
GET /articles/_search
{
  "query": {
    "dis_max": {
      "queries": [
        {
          "match": {
            "title": {
              "query": "machine learning",
              "boost": 2.0
            }
          }
        },
        {
          "match": {
            "content": {
              "query": "machine learning"
            }
          }
        }
      ],
      "tie_breaker": 0.3
    }
  }
}
```

**Key Points**
- A title match is boosted 2× relative to a content match.
- `dis_max` still takes the best clause score, so a boosted title match dominates.
- `tie_breaker` allows a content match to contribute modestly when the title also matches.

---

### `dis_max` vs `bool` + `should`

| Characteristic | `bool` + `should` | `dis_max` |
|---------------|------------------|-----------|
| Score calculation | Sum of all matching clause scores | Best clause score (+ tie_breaker contribution) |
| Multi-field match behavior | Rewards matching in multiple fields | Rewards strongest single-field match |
| Tie-breaking for multi-match | Not applicable | Controlled via `tie_breaker` |
| Equivalent when `tie_breaker: 1.0` | ✅ Yes | — |
| Best for | Queries where multiple signals reinforce relevance | Multi-field search where one strong match suffices |

---

### Combining `dis_max` Inside a `bool` Query

`dis_max` can be nested inside `bool` clauses for more complex query structures:

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        { "term": { "status": "published" } }
      ],
      "should": [
        {
          "dis_max": {
            "queries": [
              { "match": { "title":   "deep learning" } },
              { "match": { "summary": "deep learning" } }
            ],
            "tie_breaker": 0.3
          }
        }
      ]
    }
  }
}
```

Only published articles are returned. Among them, those with strong matches for "deep learning" in either `title` or `summary` rank higher, with `dis_max` controlling how multi-field matches contribute.

---

### Relationship to `multi_match` Query

The `multi_match` query with `type: best_fields` is [Inference] functionally similar to `dis_max` with a `tie_breaker`, and is documented as being built on `dis_max` internally. However, `dis_max` offers more explicit control — each clause can be a completely different query type, not just variations of the same query across fields.

| Feature | `multi_match` (best_fields) | `dis_max` |
|---------|----------------------------|-----------|
| Multi-field same query | ✅ Concise | ✅ Verbose |
| Different query types per clause | ❌ No | ✅ Yes |
| `tie_breaker` support | ✅ Yes | ✅ Yes |
| Mixed query types (term + match + range) | ❌ No | ✅ Yes |

---

### Limitations and Considerations

- `dis_max` always operates in **query context** — all clauses are scored. It does not support filter context natively. For filter-only logic, use `bool` + `filter`.
- With `tie_breaker: 0.0`, secondary clause matches have **no effect** on ranking. Documents that match in only one clause and documents that match in all clauses may have identical scores if their best-clause scores are equal.
- [Inference] Performance characteristics of `dis_max` are similar to `bool` + `should` since both evaluate multiple clauses. Actual performance depends on clause complexity, index size, and query cache state.
- The `queries` array must contain at least one clause. An empty `queries` array produces [Unverified] undefined behavior that may vary by Elasticsearch version.

---

**Conclusion**

The `dis_max` query is the right tool when searching across multiple fields and the strongest single-field match should determine a document's relevance. By taking the maximum clause score rather than summing all scores, it avoids the score inflation that `bool` + `should` can produce in multi-field scenarios. The `tie_breaker` parameter adds nuance — allowing secondary matches to contribute slightly without overriding the primacy of the best match. Together with `multi_match`, it forms the foundation of effective multi-field search in Elasticsearch.