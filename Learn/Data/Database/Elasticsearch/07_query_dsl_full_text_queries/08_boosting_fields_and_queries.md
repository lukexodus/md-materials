## Query DSL – Boosting Fields and Queries

---

### Overview

Boosting in Elasticsearch allows you to influence the **relevance score** of documents by increasing or decreasing the weight of specific fields, terms, or entire query clauses. Boosting does not filter documents — it affects how documents are ranked relative to each other in the results.

Elasticsearch supports boosting at multiple levels: field level, query level, and through dedicated query types.

---

### How Relevance Scoring Works (Brief Context)

Elasticsearch uses a scoring algorithm (BM25 by default) to compute a `_score` for each matching document. Boost values act as **multipliers** applied at various points in score computation.

[Inference] The exact interaction between boost values and BM25 scoring depends on the similarity configuration and index settings. Disclaimer: Score values and rankings are not guaranteed to be consistent across versions or configurations.

---

### Field-Level Boosting

#### At Query Time

Field-level boosts can be applied directly in queries that accept a `fields` parameter, using the `^N` syntax.

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "elasticsearch performance",
      "fields": ["title^4", "summary^2", "body"]
    }
  }
}
```

**Key Points:**
- `title^4` means matches in `title` contribute 4× more to the score than an unbosted field.
- `body` has no explicit boost, so it defaults to `1`.
- Supported in `multi_match`, `query_string`, and `simple_query_string`.

---

#### At Index Time (Mapping-Level Boost)

Elasticsearch historically supported index-time field boosts in mappings, but **this feature was deprecated and removed in Elasticsearch 5.0**. All boosting should now be applied at query time.

[Unverified: confirm removal for your specific version if working with legacy indices.]

---

### Query-Level Boosting

Every query clause in Elasticsearch accepts a `boost` parameter. This scales the score contribution of that clause.

```json
GET /products/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "match": {
            "name": {
              "query": "mechanical keyboard",
              "boost": 3
            }
          }
        },
        {
          "match": {
            "description": {
              "query": "mechanical keyboard",
              "boost": 1
            }
          }
        }
      ]
    }
  }
}
```

**Key Points:**
- The `boost` parameter accepts a floating-point value. Values greater than `1` increase the clause's score contribution; values between `0` and `1` decrease it.
- Negative boost values are not supported directly — use the `boosting` query for score suppression.
- A `boost` of `1` is the default (no change).

---

### `bool` Query Boosting

Within a `bool` query, individual clauses (`must`, `should`, `must_not`, `filter`) can each carry their own `boost`.

```json
GET /jobs/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": {
              "query": "software engineer",
              "boost": 2
            }
          }
        }
      ],
      "should": [
        {
          "match": {
            "skills": {
              "query": "elasticsearch",
              "boost": 1.5
            }
          }
        },
        {
          "match": {
            "skills": {
              "query": "kibana",
              "boost": 1
            }
          }
        }
      ]
    }
  }
}
```

**Key Points:**
- `must` clauses affect the score. `filter` clauses do **not** — they are executed in a no-score context regardless of any `boost` value assigned to them.
- [Inference] Assigning a `boost` to a `filter` clause has no scoring effect. Disclaimer: Behavior may vary; verify against your version's documentation.

---

### The `boosting` Query

The `boosting` query is a dedicated query type that allows you to **promote** documents matching one condition while **demoting** (but not excluding) documents matching another.

#### Structure

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

#### Parameters

| Parameter | Required | Description |
|---|---|---|
| `positive` | Yes | Query that must match. Documents not matching this are excluded. |
| `negative` | Yes | Query used to reduce scores. Documents matching this are **not excluded**. |
| `negative_boost` | Yes | Multiplier applied to documents that also match `negative`. Must be between `0` and `1`. |

**Key Points:**
- Only documents matching `positive` are returned.
- Documents matching both `positive` and `negative` are returned but with a reduced score (multiplied by `negative_boost`).
- `negative_boost` of `0.5` means the document scores half as much as it otherwise would.
- This is the correct mechanism for **soft exclusion** — downranking without filtering.

---

#### `boosting` Query Example with Context

```json
GET /news/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "category": "technology"
        }
      },
      "negative": {
        "term": {
          "source": "tabloid"
        }
      },
      "negative_boost": 0.3
    }
  }
}
```

Technology articles from tabloid sources are still returned but ranked significantly lower than those from other sources.

---

### `constant_score` Query

The `constant_score` query wraps a filter and assigns a **fixed score** to all matching documents, ignoring any relevance calculation.

```json
GET /products/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "in_stock": true
        }
      },
      "boost": 1.5
    }
  }
}
```

**Key Points:**
- All matching documents receive a score equal to the `boost` value.
- Useful when you want to rank a set of documents uniformly above or below others, without BM25 influence.
- The wrapped query runs as a filter (no scoring overhead), making it efficient.

---

### `function_score` Query

The `function_score` query provides the most flexible boosting mechanism. It allows you to combine the base relevance score with custom scoring functions.

#### Basic Structure

```json
GET /hotels/_search
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "description": "beachfront resort"
        }
      },
      "functions": [
        {
          "filter": { "term": { "star_rating": 5 } },
          "weight": 3
        },
        {
          "field_value_factor": {
            "field": "review_count",
            "factor": 0.1,
            "modifier": "log1p",
            "missing": 1
          }
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
```

---

#### Available Scoring Functions

| Function | Description |
|---|---|
| `weight` | Applies a flat multiplier to matching documents |
| `field_value_factor` | Uses a numeric field value to influence the score |
| `random_score` | Assigns a random but consistent score (useful for randomized ordering) |
| `script_score` | Uses a Painless script for fully custom scoring |
| `decay functions` | Reduces score based on distance from a numeric, date, or geo origin (`linear`, `exp`, `gauss`) |

---

#### `score_mode`

Controls how multiple function scores are **combined** with each other.

| Value | Behavior |
|---|---|
| `multiply` | Multiply all function scores together (default) |
| `sum` | Sum all function scores |
| `avg` | Average of all function scores |
| `first` | Use the score from the first matching function |
| `max` | Use the highest function score |
| `min` | Use the lowest function score |

---

#### `boost_mode`

Controls how the combined function score interacts with the **base query score**.

| Value | Behavior |
|---|---|
| `multiply` | Multiply base score by function score (default) |
| `replace` | Discard base score; use function score only |
| `sum` | Add function score to base score |
| `avg` | Average of base and function scores |
| `max` | Use the higher of base or function score |
| `min` | Use the lower of base or function score |

---

#### `field_value_factor` Example

```json
GET /posts/_search
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "field_value_factor": {
        "field": "likes",
        "factor": 1.2,
        "modifier": "sqrt",
        "missing": 1
      },
      "boost_mode": "multiply"
    }
  }
}
```

**Key Points:**
- `factor` scales the field value before the modifier is applied.
- `modifier` options include: `none`, `log`, `log1p`, `log2p`, `ln`, `ln1p`, `ln2p`, `square`, `sqrt`, `reciprocal`.
- `missing` defines the value used when the field is absent in a document.
- [Inference] Using `log1p` or `sqrt` helps prevent documents with very high field values from dominating scores disproportionately. Disclaimer: Scoring outcomes depend on data distribution and are not guaranteed.

---

#### Decay Functions

Decay functions reduce scores for documents whose field values are further from a defined origin.

```json
GET /events/_search
{
  "query": {
    "function_score": {
      "query": { "match": { "name": "concert" } },
      "functions": [
        {
          "gauss": {
            "event_date": {
              "origin": "2025-06-01",
              "scale": "7d",
              "offset": "1d",
              "decay": 0.5
            }
          }
        }
      ]
    }
  }
}
```

| Parameter | Description |
|---|---|
| `origin` | The center point (best score) |
| `scale` | Distance from origin at which the score equals `decay` |
| `offset` | Range around origin where no decay is applied |
| `decay` | Score multiplier at the `scale` distance (default `0.5`) |

| Decay Type | Shape |
|---|---|
| `gauss` | Bell curve — gradual decay near origin, faster further out |
| `linear` | Straight-line decay to zero at `scale + offset` |
| `exp` | Exponential — fast initial decay, slower further out |

---

#### `script_score` Example

```json
GET /products/_search
{
  "query": {
    "function_score": {
      "query": { "match": { "category": "electronics" } },
      "script_score": {
        "script": {
          "source": "Math.log(2 + doc['sales_count'].value) * params.boost_factor",
          "params": {
            "boost_factor": 1.5
          }
        }
      },
      "boost_mode": "replace"
    }
  }
}
```

**Key Points:**
- Scripts run in the Painless scripting language.
- `script_score` must return a non-negative value. Negative scores will cause an error.
- [Inference] Script-based scoring can significantly increase query latency at scale. Disclaimer: Performance impact is not guaranteed and depends on script complexity, document count, and hardware.

---

### `dis_max` Query with Boosting

The `dis_max` (disjunction max) query returns documents matching any of its sub-queries, using the **highest score** among matching clauses as the document score.

```json
GET /articles/_search
{
  "query": {
    "dis_max": {
      "queries": [
        { "match": { "title": { "query": "apache kafka", "boost": 3 } } },
        { "match": { "body":  { "query": "apache kafka", "boost": 1 } } }
      ],
      "tie_breaker": 0.3
    }
  }
}
```

**Key Points:**
- Without `tie_breaker`, only the single highest-scoring clause contributes.
- `tie_breaker` (between `0` and `1`) adds a fraction of the other matching clauses' scores, rewarding documents that match in multiple fields.
- `multi_match` with `type: best_fields` is implemented internally using `dis_max`. [Inference]

---

### Combining Boosting Strategies

These approaches are composable. A `bool` query can contain a `boosting` query as a clause, or a `function_score` can wrap a `bool` query.

```json
GET /listings/_search
{
  "query": {
    "function_score": {
      "query": {
        "bool": {
          "must": [
            { "match": { "title": { "query": "apartment", "boost": 2 } } }
          ],
          "should": [
            { "term": { "verified": true } }
          ]
        }
      },
      "functions": [
        {
          "gauss": {
            "location": {
              "origin": "14.5995,120.9842",
              "scale": "5km"
            }
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

---

### Summary of Boosting Mechanisms

| Mechanism | Level | Use Case |
|---|---|---|
| `field^N` syntax | Field | Promote matches in specific fields |
| `boost` parameter | Query clause | Adjust weight of individual clauses |
| `boosting` query | Query | Demote (not exclude) unwanted results |
| `constant_score` | Query | Assign uniform score to a filter result |
| `function_score` | Query | Complex, multi-factor custom scoring |
| `dis_max` + `tie_breaker` | Query | Best-field matching across multiple fields |

---

**Conclusion:**

Elasticsearch provides a layered system for influencing relevance scores. Field-level boosts and clause-level `boost` parameters handle straightforward weighting needs. The `boosting` query enables soft demotion without exclusion. The `function_score` query covers advanced scenarios including numeric field influence, decay-based proximity scoring, and fully custom Painless scripts. These mechanisms can be combined to build sophisticated ranking strategies, though the interaction between multiple boost layers can make score behavior complex to reason about. Disclaimer: Score outcomes depend on index configuration, data distribution, similarity settings, and Elasticsearch version, and are not guaranteed to be consistent across environments.