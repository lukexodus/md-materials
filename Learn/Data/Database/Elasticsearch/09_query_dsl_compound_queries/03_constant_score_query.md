## Query DSL – Compound Queries: `constant_score` Query

### Overview

The `constant_score` query wraps a **filter clause** and assigns a **fixed relevance score** to every document that matches, instead of computing a score based on term frequency, field length, or any other similarity metric. All matching documents receive the same `_score`, determined by the optional `boost` parameter.

It is used when you need documents to match based on structured criteria but do not want relevance ranking to vary between results — or when you want to assign a specific score contribution to a filter clause within a larger compound query.

---

### Core Concepts

| Parameter | Required | Description |
|-----------|----------|-------------|
| `filter` | ✅ Yes | The query to execute in filter context. Must match for a document to be returned. |
| `boost` | ❌ No | The constant score assigned to all matching documents. Defaults to `1.0`. |

**Key characteristics:**
- The inner query always executes in **filter context** — no relevance score is computed from it.
- All matching documents receive exactly the `boost` value as their `_score`.
- Because the inner query runs in filter context, it is [Inference] eligible for query caching, which may improve performance on repeated queries. Actual caching behavior depends on Elasticsearch's internal heuristics.

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "constant_score": {
      "filter": {
        <query>
      },
      "boost": 1.5
    }
  }
}
```

---

### How Scoring Works

Without `constant_score`, a `term` or `match` query computes a relevance score per document based on BM25 (by default). With `constant_score`, that computation is bypassed entirely.

**Score comparison:**

| Query Type | Document A Score | Document B Score | Document C Score |
|------------|-----------------|-----------------|-----------------|
| `term` query (query context) | 1.82 | 0.94 | 2.31 |
| `constant_score` with `boost: 1.0` | 1.0 | 1.0 | 1.0 |
| `constant_score` with `boost: 3.5` | 3.5 | 3.5 | 3.5 |

> [Inference] Score values from term queries are illustrative. Actual values depend on BM25 parameters, index statistics, and field mappings.

---

### Example: Category Filtering with Fixed Score

**Scenario:** Return all products in the "laptops" category. Relevance ranking within the category is not meaningful — all matches are equally relevant.

```json
GET /products/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "category": "laptops"
        }
      },
      "boost": 1.0
    }
  }
}
```

All matching documents receive a `_score` of `1.0`. The order of results is determined by document order or an explicit `sort`, not by relevance.

---

### Example: Date Range Filter with Fixed Score

**Scenario:** Retrieve all events occurring in a specific date range, without relevance scoring.

```json
GET /events/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "range": {
          "event_date": {
            "gte": "2025-01-01",
            "lte": "2025-12-31"
          }
        }
      },
      "boost": 1.0
    }
  }
}
```

---

### Using `boost` for Score Contribution in Compound Queries

The more nuanced use of `constant_score` is inside a `bool` query, where you want a filter clause to contribute a **specific, fixed amount** to the total score — rather than being scored dynamically or contributing nothing (as a plain `filter` clause would).

**Example:** Score documents based on category membership, with electronics worth more than accessories:

```json
GET /products/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "constant_score": {
            "filter": { "term": { "category": "electronics" } },
            "boost": 3.0
          }
        },
        {
          "constant_score": {
            "filter": { "term": { "category": "accessories" } },
            "boost": 1.0
          }
        }
      ]
    }
  }
}
```

**Output behavior:**
- Electronics documents receive a score contribution of `3.0` from this clause.
- Accessories documents receive a score contribution of `1.0`.
- Documents in neither category receive `0` from these clauses.
- If other `should` or `must` clauses exist, their scores are added on top.

**Key Points**
- This pattern allows **tier-based scoring** using filter-context queries.
- Each `constant_score` block executes its filter without computing similarity — the score is purely the `boost` value.
- [Inference] This approach may be more predictable for score tuning than relying on BM25 outputs, since the score contribution is explicit. Actual behavior in combined queries depends on Elasticsearch's score combination logic.

---

### Example: Multi-Tier Relevance with `constant_score`

**Scenario:** A content platform ranks articles by topic priority. Feature articles score highest, news scores mid, opinion scores lowest. All must be published.

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
          "constant_score": {
            "filter": { "term": { "type": "feature" } },
            "boost": 5.0
          }
        },
        {
          "constant_score": {
            "filter": { "term": { "type": "news" } },
            "boost": 3.0
          }
        },
        {
          "constant_score": {
            "filter": { "term": { "type": "opinion" } },
            "boost": 1.0
          }
        }
      ]
    }
  }
}
```

**Output behavior:**

| Document | Type | Status | Score Contribution |
|----------|------|--------|-------------------|
| Article A | feature | published | 5.0 + `must` score |
| Article B | news | published | 3.0 + `must` score |
| Article C | opinion | published | 1.0 + `must` score |
| Article D | feature | draft | Not returned (`must` fails) |

---

### `constant_score` vs Alternatives

| Approach | Scores Dynamically? | Filter Cached? | Score Controllable? |
|----------|--------------------|-----------------|--------------------|
| `term` in query context | ✅ Yes (BM25) | ❌ No | ❌ No |
| `term` in `filter` clause | ❌ No (0 contribution) | ✅ [Inference] Yes | ❌ No |
| `constant_score` | ❌ No (fixed) | ✅ [Inference] Yes | ✅ Yes |
| `function_score` | ✅ Customizable | ❌ No | ✅ Yes (complex) |

**When to choose `constant_score`:**
- You need filter-context performance but want a non-zero score contribution.
- You are building tiered or categorical scoring where the score value should be explicit and predictable.
- You want to avoid BM25 score variance for structured fields.
- You are replacing a query-context `term` query where scoring is irrelevant.

---

### Nesting Complex Filters

The `filter` inside `constant_score` accepts any query, including `bool`:

```json
GET /products/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "bool": {
          "must": [
            { "term":  { "in_stock": true } },
            { "range": { "price": { "lte": 1000 } } }
          ],
          "must_not": [
            { "term": { "condition": "refurbished" } }
          ]
        }
      },
      "boost": 2.0
    }
  }
}
```

All documents passing the nested `bool` filter receive a score of `2.0`. The complexity of the inner filter does not affect the output score.

---

### Limitations and Considerations

- `constant_score` only accepts a `filter` parameter — not `must`, `should`, or `must_not` directly. Complex logic must be expressed via a nested `bool` inside the `filter`.
- The query inside `filter` always runs in filter context. Queries that depend on scoring (e.g., `function_score`, `script_score`) [Inference] may not behave as expected when nested inside `constant_score`.
- When used as a standalone query (not inside `bool`), all results have identical scores. If order matters, an explicit `sort` clause should be used alongside it.
- The `boost` value must be a positive float. [Unverified] Behavior with `boost: 0.0` or negative values should be tested against your target Elasticsearch version.

---

**Conclusion**

The `constant_score` query is a precise, lightweight tool for converting any filter into a fixed score contributor. It bridges the gap between pure filter-context queries (which contribute nothing to scoring) and full query-context execution (which introduces BM25 variance). Its most powerful application is inside `bool` + `should` structures, where it enables explicit, tiered relevance scoring based on categorical or structured document attributes.