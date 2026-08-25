## Query DSL – Filter Context vs Query Context

### Overview

Every query clause in Elasticsearch executes in one of two contexts: **query context** or **filter context**. The context determines whether a clause contributes a relevance score to matched documents, or merely decides inclusion or exclusion without scoring.

This distinction affects result ranking, performance, and caching behavior.

---

### Core Distinction

| | Query Context | Filter Context |
|---|---|---|
| Question asked | *How well does this document match?* | *Does this document match? Yes or no.* |
| Relevance score | Computed and contributed to `_score` | Not computed; `_score` unaffected |
| Caching | Not cached | Cached by Elasticsearch automatically |
| Performance | Higher cost (scoring) | Lower cost (bitset lookup) |
| Use for | Full-text search, ranking | Exact matches, ranges, term filters |

---

### Query Context

A clause runs in query context when it appears under the `query` key of a search request, or inside a `must` / `should` clause of a `bool` query.

Elasticsearch computes a relevance score for each matching document using the configured similarity algorithm (BM25 by default). This score contributes to the document's `_score` field.

**Example:**

```json
GET /articles/_search
{
  "query": {
    "match": {
      "body": "distributed systems"
    }
  }
}
```

Every matching document receives a `_score` reflecting how well its `body` field matches the phrase `distributed systems`.

---

### Filter Context

A clause runs in filter context when it appears inside a `filter` or `must_not` clause of a `bool` query, or inside a `filter` parameter of queries that support it (e.g., `constant_score`, `knn`).

Elasticsearch evaluates the clause as a binary decision. No score is computed. The document either passes or it does not.

**Example:**

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "filter": {
        "term": { "status": "published" }
      }
    }
  }
}
```

All documents with `status: published` are returned with `_score: 0`. No ranking is applied.

---

### How Context Is Determined

Context is not a property of the query clause type — it is determined by **where the clause appears** in the query tree.

The same clause type can run in either context:

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "elasticsearch" } }
      ],
      "filter": [
        { "match": { "title": "elasticsearch" } }
      ]
    }
  }
}
```

- The `match` under `must` → query context → contributes to `_score`.
- The `match` under `filter` → filter context → binary inclusion only, no score contribution.

[Inference] Using `match` in filter context is valid but atypical. `match` performs analysis and is generally used for full-text scoring. In filter context its scoring benefit is discarded. `term` or `terms` are more appropriate for exact filter matching. Behavior may vary based on analyzer configuration.

---

### The `bool` Query as Context Distributor

The `bool` query is the primary mechanism for mixing contexts. Each of its clauses runs in a defined context:

| `bool` clause | Context | Scoring | Must match? |
|---|---|---|---|
| `must` | Query | Yes — contributes to `_score` | Yes |
| `should` | Query | Yes — contributes to `_score` | Conditional |
| `filter` | Filter | No | Yes |
| `must_not` | Filter | No | Must not match |

**Example combining both contexts:**

```json
{
  "query": {
    "bool": {
      "must": {
        "match": { "body": "sharding strategies" }
      },
      "filter": [
        { "term": { "status": "published" } },
        { "range": { "date": { "gte": "2023-01-01" } } }
      ]
    }
  }
}
```

- `match` in `must` → scored; drives relevance ranking.
- `term` and `range` in `filter` → unscored; restrict the result set without affecting `_score`.

---

### Caching

Filter context clauses are eligible for the **filter cache** (also called the node query cache). Elasticsearch caches the result of filter clauses as bitsets — one bit per document indicating match or no-match. Subsequent queries using the same filter clause can reuse the cached bitset without re-evaluating.

Query context clauses are not cached in this way because their output (a score per document) is not reusable across different queries.

[Inference] Not all filter clauses are cached automatically. Elasticsearch applies heuristics based on clause frequency and cost. Rarely used filters may not be cached even in filter context. Caching behavior is not guaranteed and may vary across versions and cluster configurations.

---

### Score Impact of Filter Context

When all clauses are in filter context (e.g., a `bool` query with only `filter` and `must_not`), all matching documents receive `_score: 0.0`. Results are returned in an arbitrary order unless a `sort` is specified.

```json
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "infrastructure" } },
        { "range": { "views": { "gte": 1000 } } }
      ]
    }
  }
}
```

All matching documents: `_score: 0.0`. To impose order, add an explicit `sort`.

To assign a fixed non-zero score to filter results, wrap in `constant_score`:

```json
{
  "query": {
    "constant_score": {
      "filter": {
        "term": { "category": "infrastructure" }
      },
      "boost": 1.5
    }
  }
}
```

---

### `constant_score` as an Explicit Filter Context Wrapper

`constant_score` forces its inner clause into filter context and assigns all matching documents a uniform score equal to `boost`:

```json
{
  "query": {
    "constant_score": {
      "filter": {
        "range": { "priority": { "gte": 8 } }
      },
      "boost": 2.0
    }
  }
}
```

This is useful when you want filter-context caching benefits but need results to carry a non-zero score — for example, when combining with other scored clauses in a `bool` query.

---

### Practical Guidance: When to Use Each Context

**Use query context when:**
- Relevance ranking matters — full-text search, ranked recommendations.
- You need documents ordered by how well they match.
- The clause uses analysis-dependent matching (`match`, `match_phrase`, `multi_match`).

**Use filter context when:**
- The condition is binary — a document either qualifies or it does not.
- The field contains structured data: keyword terms, dates, numbers, booleans.
- The same condition will be reused across many queries (caching benefit).
- You want to restrict results without affecting ranking.

**Common filter-context candidates:**

| Query type | Reason |
|---|---|
| `term` / `terms` | Exact keyword match |
| `range` | Numeric or date bounds |
| `exists` | Field presence check |
| `ids` | Specific document selection |
| `geo_bounding_box` | Geographic restriction |
| `prefix` / `wildcard` | Structural string matching (not analysis-driven) |

---

### Anti-Pattern: Scoring What Should Be Filtered

Placing structured, binary conditions in `must` instead of `filter` wastes scoring computation and bypasses caching:

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "body": "replication" } },
        { "term": { "status": "published" } },
        { "range": { "date": { "gte": "2024-01-01" } } }
      ]
    }
  }
}
```

The `term` and `range` clauses contribute to `_score` but add no ranking value — they are binary conditions. The correct form:

```json
{
  "query": {
    "bool": {
      "must": {
        "match": { "body": "replication" }
      },
      "filter": [
        { "term": { "status": "published" } },
        { "range": { "date": { "gte": "2024-01-01" } } }
      ]
    }
  }
}
```

[Inference] Moving binary conditions from `must` to `filter` may improve query performance due to caching and reduced scoring overhead, particularly when the same conditions recur across many queries. Actual performance gains depend on cluster configuration, index size, and query patterns. Behavior may vary.

---

### Nested Context Example: Full Breakdown

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "elasticsearch query" } }     ← query context
      ],
      "should": [
        { "match": { "tags": "performance" } }              ← query context
      ],
      "filter": [
        { "term": { "published": true } },                  ← filter context
        { "range": { "date": { "gte": "2023-06-01" } } }   ← filter context
      ],
      "must_not": [
        { "term": { "archived": true } }                    ← filter context
      ]
    }
  }
}
```

`_score` reflects only `must` and `should` contributions. `filter` and `must_not` restrict documents silently.

---

### Summary

| Aspect | Query Context | Filter Context |
|---|---|---|
| Activated by | `must`, `should`, top-level `query` | `filter`, `must_not`, `constant_score.filter` |
| Scores documents | Yes | No (`_score: 0` or unchanged) |
| Cached | No | Yes (bitset cache, heuristic) |
| Best for | Relevance ranking, full-text | Structured conditions, binary inclusion |
| Clause types suited | `match`, `multi_match`, `match_phrase` | `term`, `range`, `exists`, `ids`, geo queries |
| Performance | Higher (scoring overhead) | Lower (bitset evaluation) |