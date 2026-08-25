## Query DSL – Compound Queries: `function_score` Query

### Overview

The `function_score` query allows you to **modify the relevance scores** of documents returned by a base query using one or more scoring functions. It wraps an existing query and applies mathematical transformations to the scores it produces — based on field values, document metadata, geographic distance, randomness, or custom scripts.

It is used when the default BM25 relevance score alone is insufficient and business logic, recency, popularity, location proximity, or other signals need to influence ranking.

---

### Core Structure

```json
GET /index/_search
{
  "query": {
    "function_score": {
      "query": { <base_query> },
      "functions": [
        { <scoring_function_1> },
        { <scoring_function_2> }
      ],
      "score_mode": "multiply",
      "boost_mode": "multiply",
      "boost": 1.0,
      "min_score": 0.5
    }
  }
}
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | ❌ No | Base query whose results are scored. Defaults to `match_all`. |
| `functions` | ❌ No | Array of scoring functions to apply. |
| `score_mode` | ❌ No | How multiple function scores are combined. Default: `multiply`. |
| `boost_mode` | ❌ No | How the combined function score interacts with the query score. Default: `multiply`. |
| `boost` | ❌ No | Global boost applied to the entire query. Default: `1.0`. |
| `min_score` | ❌ No | Minimum final score threshold. Documents scoring below are excluded. |

---

### Available Scoring Functions

| Function | Description |
|----------|-------------|
| `weight` | Applies a fixed multiplier to matching documents |
| `field_value_factor` | Uses a numeric field value to influence the score |
| `gauss` / `linear` / `exp` | Decay functions — score decreases with distance from an origin |
| `random_score` | Assigns a consistent random score per document |
| `script_score` | Computes a custom score using a Painless script |

---

### Function Filters

Each function in the `functions` array can include an optional `filter`. When present, the function only applies to documents matching that filter. Documents not matching the filter receive a function score of `1` (neutral for multiplication) or `0` (neutral for addition), depending on `score_mode`.

```json
"functions": [
  {
    "filter": { "term": { "category": "featured" } },
    "weight": 3.0
  },
  {
    "filter": { "range": { "rating": { "gte": 4.5 } } },
    "weight": 2.0
  }
]
```

---

### Scoring Function Details

#### `weight`

Applies a flat numeric multiplier to matching documents. The simplest function — no field computation involved.

```json
{
  "filter": { "term": { "sponsored": true } },
  "weight": 5.0
}
```

All documents where `sponsored` is `true` have their function score set to `5.0`.

---

#### `field_value_factor`

Uses the value of a numeric field to compute the function score. Supports optional mathematical modifiers.

```json
{
  "field_value_factor": {
    "field":    "popularity",
    "factor":   1.5,
    "modifier": "log1p",
    "missing":  1.0
  }
}
```

| Parameter | Description |
|-----------|-------------|
| `field` | Numeric field to read from |
| `factor` | Multiplied against the field value before applying modifier. Default: `1.0` |
| `modifier` | Mathematical function applied to `factor × field_value` |
| `missing` | Value used when the field is absent from a document |

**Available modifiers:**

| Modifier | Formula |
|----------|---------|
| `none` | `factor × value` |
| `log` | `log(factor × value)` |
| `log1p` | `log(1 + factor × value)` |
| `log2p` | `log(2 + factor × value)` |
| `ln` | `ln(factor × value)` |
| `ln1p` | `ln(1 + factor × value)` |
| `ln2p` | `ln(2 + factor × value)` |
| `square` | `(factor × value)²` |
| `sqrt` | `√(factor × value)` |
| `reciprocal` | `1 / (factor × value)` |

> [Inference] `log1p` and `ln1p` are commonly used to smooth large field value ranges (e.g., view counts) so that very high values do not dominate scoring disproportionately. Actual score impact depends on your data distribution.

**Example:** Boost articles by view count, smoothed with `log1p`:

```json
GET /articles/_search
{
  "query": {
    "function_score": {
      "query": { "match": { "content": "elasticsearch" } },
      "functions": [
        {
          "field_value_factor": {
            "field":    "view_count",
            "factor":   1.2,
            "modifier": "log1p",
            "missing":  1
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

---

#### Decay Functions: `gauss`, `linear`, `exp`

Decay functions reduce a document's score as a numeric value, date, or geo point moves away from a specified **origin**. They are commonly used for recency boosting, proximity ranking, and price preference.

**Common parameters:**

| Parameter | Description |
|-----------|-------------|
| `origin` | The ideal value. Documents at this value receive the highest score. |
| `scale` | Distance from `origin` at which the score reaches `decay` value. |
| `offset` | Range around `origin` within which no decay is applied. Default: `0`. |
| `decay` | Score factor at `scale` distance from `origin`. Default: `0.5`. |

**Decay curve shapes:**

| Function | Curve Shape | Decay Behavior |
|----------|-------------|----------------|
| `gauss` | Bell curve | Gradual decay near origin, faster further out |
| `linear` | Straight line | Uniform decay rate; reaches 0 at `scale + offset` |
| `exp` | Exponential | Faster initial decay, long tail |

**Example:** Boost recently published articles, with scores decaying over 30 days:

```json
GET /articles/_search
{
  "query": {
    "function_score": {
      "query": { "match": { "content": "elasticsearch" } },
      "functions": [
        {
          "gauss": {
            "publish_date": {
              "origin": "now",
              "scale":  "30d",
              "offset": "7d",
              "decay":  0.5
            }
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

**Behavior:**
- Articles published within the last 7 days (`offset`) receive no decay.
- Articles published 30 days ago (`scale`) receive a score multiplier of `0.5`.
- Articles published beyond 30 days decay further depending on the curve.

**Example: Geo-distance decay** — boost restaurants closer to a location:

```json
GET /restaurants/_search
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "functions": [
        {
          "gauss": {
            "location": {
              "origin": { "lat": 14.5995, "lon": 120.9842 },
              "scale":  "5km",
              "offset": "1km",
              "decay":  0.5
            }
          }
        }
      ],
      "boost_mode": "replace"
    }
  }
}
```

Restaurants within 1km receive no decay. Those at 5km receive a score multiplier of `0.5`.

---

#### `random_score`

Assigns a random but **consistent** score to each document. Given the same `seed` and `field`, the same document always receives the same random score — useful for randomized but reproducible result ordering.

```json
{
  "random_score": {
    "seed": 42,
    "field": "_seq_no"
  }
}
```

| Parameter | Description |
|-----------|-------------|
| `seed` | Integer seed for the random number generator |
| `field` | Field used to generate per-document randomness. `_seq_no` is recommended. |

> [Inference] Using `_seq_no` as the `field` is recommended in Elasticsearch documentation because it provides stable per-document values. Using `_id` may produce less uniformly distributed scores in some versions. Behavior may vary.

**Use case:** Randomized product carousels, shuffled recommendations, or A/B testing with stable per-session ordering (by seeding with a session ID).

---

#### `script_score`

Computes a fully custom function score using a Painless script. Provides maximum flexibility at the cost of [Inference] potentially higher computational overhead compared to built-in functions.

```json
{
  "script_score": {
    "script": {
      "source": "Math.log(2 + doc['likes'].value + doc['shares'].value * 2)"
    }
  }
}
```

**Key Points**
- The script must return a non-negative value. [Unverified] Negative return values may produce errors or undefined behavior depending on Elasticsearch version.
- Access document fields via `doc['field_name'].value`.
- Custom `params` can be passed to avoid recompilation on parameter changes:

```json
{
  "script_score": {
    "script": {
      "source": "doc['likes'].value * params.like_weight + doc['shares'].value * params.share_weight",
      "params": {
        "like_weight":  1.0,
        "share_weight": 2.5
      }
    }
  }
}
```

---

### `score_mode`: Combining Multiple Function Scores

When multiple functions are present, `score_mode` determines how their individual scores are combined into a single function score.

| `score_mode` | Behavior |
|-------------|----------|
| `multiply` (default) | Multiplies all function scores together |
| `sum` | Sums all function scores |
| `avg` | Averages all function scores |
| `first` | Uses the score of the first matching function |
| `max` | Takes the highest function score |
| `min` | Takes the lowest function score |

---

### `boost_mode`: Combining Function Score with Query Score

After function scores are combined via `score_mode`, `boost_mode` controls how the result interacts with the original query `_score`.

| `boost_mode` | Behavior |
|-------------|----------|
| `multiply` (default) | `query_score × function_score` |
| `replace` | `function_score` only; query score discarded |
| `sum` | `query_score + function_score` |
| `avg` | `(query_score + function_score) / 2` |
| `max` | `max(query_score, function_score)` |
| `min` | `min(query_score, function_score)` |

**Choosing `boost_mode`:**
- Use `multiply` when both query relevance and function signal should reinforce each other.
- Use `replace` when only the function score matters (e.g., pure geo or recency ranking).
- Use `sum` when both signals should contribute additively.

---

### `min_score`

Excludes documents whose final score falls below a specified threshold:

```json
"min_score": 1.5
```

> [Inference] `min_score` is applied after all score computation is complete. It is not a filter-context operation and does not benefit from query caching. It may also affect pagination behavior since low-scoring documents are excluded post-scoring. Behavior should be verified against your Elasticsearch version.

---

### Comprehensive Example: E-Commerce Product Ranking

**Scenario:** Search for "running shoes" and rank results by combining:
- Full-text relevance (base query)
- Popularity via `sales_count` (field value factor)
- Recency boost for newly listed products (decay)
- Extra boost for featured products (weight + filter)

```json
GET /products/_search
{
  "query": {
    "function_score": {
      "query": {
        "match": { "name": "running shoes" }
      },
      "functions": [
        {
          "field_value_factor": {
            "field":    "sales_count",
            "factor":   0.1,
            "modifier": "log1p",
            "missing":  0
          }
        },
        {
          "gauss": {
            "listed_date": {
              "origin": "now",
              "scale":  "14d",
              "offset": "3d",
              "decay":  0.5
            }
          }
        },
        {
          "filter": { "term": { "featured": true } },
          "weight": 3.0
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply",
      "min_score":  0.5
    }
  }
}
```

**Score construction per document:**
1. Base query score from BM25 match on "running shoes".
2. Function score = `log1p(sales_count × 0.1)` + gauss decay on `listed_date` + `3.0` if featured (summed via `score_mode: sum`).
3. Final score = `base_query_score × combined_function_score` (via `boost_mode: multiply`).
4. Documents with final score below `0.5` are excluded.

---

### `function_score` vs Other Scoring Approaches

| Approach | Flexibility | Complexity | Filter Caching | Use Case |
|----------|-------------|------------|---------------|----------|
| `bool` + `should` boost | Low | Low | ✅ Partial | Simple categorical boosting |
| `constant_score` | Low | Low | ✅ Yes | Fixed-score tier assignment |
| `boosting` query | Low | Low | ❌ No | Score demotion only |
| `function_score` | High | Medium–High | ❌ No | Multi-signal relevance tuning |
| `script_score` query | Very High | High | ❌ No | Fully custom scoring logic |

---

### Limitations and Considerations

- `function_score` always executes in **query context** — it computes scores and is not cacheable as a filter. [Inference] This may have performance implications on large indices or high-query-volume scenarios compared to filter-only alternatives.
- Scripts in `script_score` function are compiled and cached by Elasticsearch, but [Inference] frequent changes to script source may impact performance. Use `params` to avoid recompilation when only values change.
- Decay functions require the target field to be mapped as a numeric type, date, or `geo_point`. Applying them to incompatible field types produces errors.
- When no `functions` are specified, `function_score` behaves identically to its inner `query`. [Inference] This is valid but provides no benefit over using the inner query directly.
- `min_score` interacts with pagination — if many documents are excluded by `min_score`, the effective result set shrinks and [Inference] `from`/`size` pagination may behave unexpectedly. Behavior should be tested.

---

**Conclusion**

The `function_score` query is Elasticsearch's most comprehensive tool for custom relevance engineering. By combining a base query with one or more scoring functions — each targeting a different signal such as popularity, recency, proximity, or business rules — it enables fine-grained control over how documents are ranked. Understanding the interplay between `score_mode` and `boost_mode` is essential for predictable results, and careful function selection balances scoring precision against query performance.