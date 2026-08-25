## Query DSL – Compound Queries: `bool` Query

### Overview

The `bool` query is Elasticsearch's primary **compound query** — it combines multiple query clauses into a single query using boolean logic. Each clause belongs to one of four typed contexts, each governing how it affects matching and scoring.

It is one of the most frequently used query types in Elasticsearch, as it enables precise control over both **which documents match** and **how relevance scores are calculated**.

---

### The Four Clause Types

| Clause | Contributes to Score? | Must Match? | Behavior |
|---|---|---|---|
| `must` | ✅ Yes | ✅ Yes | Document must match; score is included |
| `should` | ✅ Yes | ⚠️ Conditional | Boosts score; may or may not be required |
| `must_not` | ❌ No | ✅ Yes (inverted) | Document must NOT match; executed in filter context |
| `filter` | ❌ No | ✅ Yes | Document must match; no scoring; cacheable |

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "bool": {
      "must": [ ... ],
      "should": [ ... ],
      "must_not": [ ... ],
      "filter": [ ... ]
    }
  }
}
```

All four clauses are optional. A `bool` query with no clauses matches all documents (equivalent to `match_all`).

Each clause accepts either a **single query object** or an **array of query objects**.

---

### `must` Clause

Documents must satisfy **all** queries listed under `must`. Each matching clause contributes to the relevance score.

**Example:** Find articles that are about "elasticsearch" AND published by "alice":

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "content": "elasticsearch" } },
        { "term":  { "author": "alice" } }
      ]
    }
  }
}
```

**Key Points**
- Equivalent to logical AND across all listed clauses.
- All clauses must match for a document to be returned.
- Each matching clause adds to the `_score`.

---

### `filter` Clause

Documents must satisfy **all** queries listed under `filter`, but matching does **not** affect relevance scoring. Filter clauses execute in **filter context**, making them eligible for query caching.

**Example:** Find products in the "electronics" category priced under 500:

```json
GET /products/_search
{
  "query": {
    "bool": {
      "filter": [
        { "term":  { "category": "electronics" } },
        { "range": { "price": { "lt": 500 } } }
      ]
    }
  }
}
```

**Key Points**
- Equivalent to logical AND, same as `must`, but without scoring.
- Preferred over `must` for structured, non-text conditions (dates, ranges, keywords) where relevance is not needed.
- [Inference] Frequently used filter clauses may benefit from caching, potentially improving repeated query performance. Actual caching behavior depends on Elasticsearch's internal heuristics and may vary.

---

### `should` Clause

Documents that match `should` clauses receive a **higher relevance score**, but matching is not always required. The behavior of `should` depends on context:

#### When `should` is the only clause (no `must` or `filter`):

At least one `should` clause must match by default. The `minimum_should_match` parameter controls this threshold.

#### When `should` is combined with `must` or `filter`:

No `should` clause is required to match. They only influence the score if they do match.

**Example:** Find documents about "elasticsearch" and boost those that also mention "performance":

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "content": "elasticsearch" } }
      ],
      "should": [
        { "match": { "content": "performance" } },
        { "match": { "content": "optimization" } }
      ]
    }
  }
}
```

Documents mentioning "performance" or "optimization" score higher, but all documents matching `must` are returned regardless.

**Key Points**
- Equivalent to a soft OR — it influences ranking without hard filtering.
- Multiple `should` clauses each contribute independently to the score.
- Use `minimum_should_match` to enforce how many must match.

---

### `must_not` Clause

Documents matching any query under `must_not` are **excluded** from results. Like `filter`, this clause runs in filter context and does not affect scoring.

**Example:** Find articles about "elasticsearch" that were NOT written by "bob":

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "content": "elasticsearch" } }
      ],
      "must_not": [
        { "term": { "author": "bob" } }
      ]
    }
  }
}
```

**Key Points**
- Equivalent to logical NOT.
- Executed in filter context — results are excluded, not penalized in score.
- [Inference] Like `filter`, `must_not` clauses may benefit from caching. Behavior depends on internal heuristics.

---

### `minimum_should_match`

Controls how many `should` clauses must match. Accepts an integer or percentage.

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "should": [
        { "term": { "tags": "java" } },
        { "term": { "tags": "python" } },
        { "term": { "tags": "scala" } }
      ],
      "minimum_should_match": 2
    }
  }
}
```

Documents must match at least 2 of the 3 `should` clauses to be returned.

**Common values:**

| Value | Meaning |
|-------|---------|
| `1` | At least 1 must match (default when no `must`/`filter`) |
| `2` | At least 2 must match |
| `"75%"` | At least 75% of clauses must match |
| `"-1"` | All but one must match |

> When `must` or `filter` is present alongside `should`, the default `minimum_should_match` is `0` — no `should` clause is required to match.

---

### Combining All Four Clauses

**Scenario:** Search a job postings index for:
- Must mention "machine learning" in the description
- Must be in the "engineering" department
- Should mention "python" or "tensorflow" (for ranking boost)
- Must not be marked as "closed"

```json
GET /job_postings/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "machine learning" } }
      ],
      "filter": [
        { "term": { "department": "engineering" } }
      ],
      "should": [
        { "term": { "skills": "python" } },
        { "term": { "skills": "tensorflow" } }
      ],
      "must_not": [
        { "term": { "status": "closed" } }
      ]
    }
  }
}
```

**Output behavior:**
- Only engineering jobs with "machine learning" in the description are returned.
- Closed jobs are excluded entirely.
- Jobs also mentioning "python" or "tensorflow" rank higher.
- The `filter` and `must_not` clauses do not affect scoring.

---

### Nested `bool` Queries

`bool` queries can be nested inside one another to build complex logic.

**Example:** Find documents where:
- The author is "alice" OR "carol"
- AND the topic is "elasticsearch"

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "topic": "elasticsearch" } },
        {
          "bool": {
            "should": [
              { "term": { "author": "alice" } },
              { "term": { "author": "carol" } }
            ],
            "minimum_should_match": 1
          }
        }
      ]
    }
  }
}
```

**Key Points**
- Nesting allows you to express grouped OR logic within an AND structure.
- Each nested `bool` is scored independently and its score contributes to the parent.
- Nesting depth has no hard-coded limit, but [Inference] deeply nested queries may affect query planning and performance. Actual impact may vary by cluster configuration and data size.

---

### Scoring Behavior in Detail

Understanding how scoring works across clause types is important for relevance tuning:

- **`must`** — Each matching clause's score is summed into the total `_score`.
- **`should`** — Each matching clause adds to the total `_score`. Non-matching clauses have no penalty.
- **`filter`** — No contribution to `_score`. Document either passes or does not.
- **`must_not`** — No contribution to `_score`. Document either passes or is excluded.

When only `filter` and/or `must_not` clauses are present (no `must` or `should`), all matching documents receive a `_score` of `1.0` by default.

---

### `boost` Parameter

Individual clauses can be boosted to increase their influence on the score:

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "title":   { "query": "elasticsearch", "boost": 3.0 } } },
        { "match": { "content": { "query": "elasticsearch", "boost": 1.0 } } }
      ]
    }
  }
}
```

A match in `title` contributes 3× more to the score than a match in `content`. [Inference] Boost values are relative and affect score proportionally within Elasticsearch's scoring model; exact score values depend on the similarity algorithm in use (default: BM25) and may vary.

---

### Performance Considerations

- Prefer `filter` over `must` for **structured, non-text conditions** — it avoids score computation and [Inference] may enable caching.
- Use `must_not` instead of a `must` with a negated query — it is executed in filter context.
- Avoid placing high-cost queries (e.g., `wildcard`, `script`) in `must` if they can be placed in `filter` after a cheaper pre-filter narrows results.
- [Inference] Caching of filter/must_not clauses is managed internally by Elasticsearch's query cache and is not guaranteed for every clause or query pattern.

---

### Common Patterns Summary

| Goal | Recommended Clause |
|------|--------------------|
| Must match, affects score | `must` |
| Must match, no score needed | `filter` |
| Exclude documents | `must_not` |
| Boost matching documents | `should` |
| Enforce OR with minimum | `should` + `minimum_should_match` |
| Combine AND + OR logic | Nested `bool` |

---

**Conclusion**

The `bool` query is the cornerstone of query composition in Elasticsearch. By combining `must`, `filter`, `should`, and `must_not`, you can express virtually any search requirement — from simple keyword filtering to complex multi-criteria relevance ranking. Understanding the scoring implications of each clause type, and when to use `filter` versus `must`, is essential for building both accurate and performant searches.