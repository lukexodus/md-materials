## Query DSL – Compound Queries: `boosting` Query

### Overview

The `boosting` query is a compound query that returns documents matching a **positive** query, while **reducing the relevance score** of documents that also match a **negative** query. Unlike `must_not` in a `bool` query — which fully excludes matching documents — the `boosting` query keeps those documents in the results but demotes them in ranking.

This makes it useful when you want to **deprioritize** certain documents rather than eliminate them entirely.

---

### Core Concepts

The `boosting` query has three required components:

| Parameter | Required | Description |
|-----------|----------|-------------|
| `positive` | ✅ Yes | The primary query. All returned documents must match this. |
| `negative` | ✅ Yes | Documents matching this query have their score reduced. |
| `negative_boost` | ✅ Yes | A multiplier (between `0.0` and `1.0`) applied to the score of documents that match the `negative` query. |

**Key distinction from `must_not`:**

| Behavior | `bool` + `must_not` | `boosting` |
|----------|---------------------|------------|
| Documents matching negative query | Excluded entirely | Included but demoted |
| Effect on score | No effect (excluded) | Score multiplied by `negative_boost` |
| Use case | Hard exclusion | Soft demotion |

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "boosting": {
      "positive": {
        <query>
      },
      "negative": {
        <query>
      },
      "negative_boost": 0.5
    }
  }
}
```

---

### How Scoring Works

1. A document is first evaluated against the `positive` query. If it does not match, it is not returned — regardless of the `negative` query.
2. If the document also matches the `negative` query, its score from the `positive` query is **multiplied by** `negative_boost`.
3. If the document matches only the `positive` query, its score is unchanged.

**Example score behavior:**

| Document | Matches `positive`? | Matches `negative`? | Score Calculation |
|----------|--------------------|--------------------|-------------------|
| A | ✅ | ❌ | Original score (e.g., 2.4) |
| B | ✅ | ✅ | Original score × `negative_boost` (e.g., 2.4 × 0.3 = 0.72) |
| C | ❌ | ✅ | Not returned |
| D | ❌ | ❌ | Not returned |

> [Inference] The exact score values depend on Elasticsearch's BM25 similarity model and index statistics. Scores shown above are illustrative only.

---

### Example: Recipe Search with Ingredient Demotion

**Scenario:** A recipe search application. Return all recipes mentioning "chocolate", but demote those that also contain "nuts" (for users with nut sensitivity who still want to see alternatives).

```json
GET /recipes/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "ingredients": "chocolate"
        }
      },
      "negative": {
        "match": {
          "ingredients": "nuts"
        }
      },
      "negative_boost": 0.2
    }
  }
}
```

**Output behavior:**
- All chocolate recipes are returned.
- Recipes containing nuts are ranked significantly lower due to the `0.2` multiplier.
- Nut-free chocolate recipes appear at the top of results.

---

### Example: News Article Search with Source Demotion

**Scenario:** Search for articles about "climate change" but deprioritize articles from a source flagged as low-quality.

```json
GET /news/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "body": "climate change"
        }
      },
      "negative": {
        "term": {
          "source": "unreliable-daily"
        }
      },
      "negative_boost": 0.1
    }
  }
}
```

Articles from `unreliable-daily` are retained in results but pushed toward the bottom of the ranking.

---

### `negative_boost` Value Guidelines

The `negative_boost` value must be between `0.0` and `1.0` exclusive of `1.0`. Values outside this range produce [Unverified] undefined or unexpected behavior depending on Elasticsearch version.

| Value | Effect |
|-------|--------|
| `0.1` | Aggressive demotion — strongly pushes matched documents down |
| `0.5` | Moderate demotion — halves the score |
| `0.9` | Mild demotion — slight ranking reduction |
| `1.0` | [Inference] Effectively no demotion; behavior may vary |
| `0.0` | [Unverified] May reduce score to zero; behavior should be tested |

---

### Combining `boosting` with Other Queries

The `positive` and `negative` fields accept any valid query, including `bool` queries, enabling complex logic.

**Example:** Search for tech job postings, demote those that are remote-only AND entry-level:

```json
GET /job_postings/_search
{
  "query": {
    "boosting": {
      "positive": {
        "bool": {
          "must": [
            { "match": { "description": "software engineer" } }
          ],
          "filter": [
            { "term": { "status": "open" } }
          ]
        }
      },
      "negative": {
        "bool": {
          "must": [
            { "term": { "work_type": "remote" } },
            { "term": { "level": "entry" } }
          ]
        }
      },
      "negative_boost": 0.3
    }
  }
}
```

**Key Points**
- The `positive` query uses a `bool` to combine a full-text match with a filter.
- The `negative` query uses a `bool` to express a compound demotion condition.
- Only open software engineer postings are returned; remote entry-level ones are demoted.

---

### Nesting `boosting` Inside a `bool` Query

A `boosting` query can itself be placed inside a `bool` clause:

```json
GET /articles/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "boosting": {
            "positive": { "match": { "content": "elasticsearch" } },
            "negative": { "term":  { "category": "deprecated" } },
            "negative_boost": 0.25
          }
        }
      ],
      "filter": [
        { "term": { "published": true } }
      ]
    }
  }
}
```

[Inference] Nesting `boosting` inside `bool` is valid in Elasticsearch's query DSL, as compound queries are composable. Behavior should be verified against your target Elasticsearch version.

---

### `boosting` vs `bool` Clause Comparison

| Scenario | Recommended Approach |
|----------|---------------------|
| Fully exclude unwanted documents | `bool` + `must_not` |
| Demote but retain unwanted documents | `boosting` query |
| Boost preferred documents upward | `bool` + `should` with higher `boost` |
| Demote specific documents downward | `boosting` with low `negative_boost` |

---

### Limitations and Considerations

- The `boosting` query **only demotes** — it cannot boost documents that match the `negative` query above their original `positive` score. For upward boosting of specific documents, use `should` clauses or `function_score`.
- Documents not matching `positive` are **never returned**, even if they match `negative`. The `negative` clause acts only on the subset that already passed `positive`.
- The `boosting` query does not support a `filter` context directly — it always operates in query context and [Inference] always computes scores. This may have performance implications on large datasets compared to pure filter queries.
- `negative_boost` applies as a **flat multiplier** to the entire score from the `positive` query. It does not selectively reduce individual clause contributions.

---

**Conclusion**

The `boosting` query fills an important gap between hard exclusion (`must_not`) and full inclusion with no differentiation. By preserving demoted documents in results while pushing them down in ranking, it supports nuanced relevance tuning — particularly in recommendation, content moderation, and preference-aware search scenarios. The `negative_boost` multiplier gives direct, predictable control over how aggressively matching documents are demoted.