## Query DSL – Compound Queries: `script_score` Query

### Overview

The `script_score` query wraps a base query and replaces or augments document scores using a **Painless script**. It provides maximum flexibility for custom scoring logic — any computation expressible in Painless can determine a document's relevance score, including arithmetic on field values, conditional logic, vector dot products, and external parameters.

It is the dedicated top-level query for script-based scoring, distinguished from the `script_score` function inside `function_score` by being a standalone query type introduced in Elasticsearch 7.0.

---

### Core Structure

```json
GET /index/_search
{
  "query": {
    "script_score": {
      "query": { <base_query> },
      "script": {
        "source": "<painless_expression>",
        "params": { }
      },
      "min_score": <float>
    }
  }
}
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | ✅ Yes | Base query that filters candidate documents. Only matching documents are scored by the script. |
| `script` | ✅ Yes | Painless script that computes the score for each matching document. |
| `script.source` | ✅ Yes | The script body. Must return a non-negative float. |
| `script.params` | ❌ No | Named parameters passed into the script. Preferred over hardcoded values to avoid recompilation. |
| `min_score` | ❌ No | Excludes documents whose computed score falls below this threshold. |

---

### How It Works

1. The `query` clause is evaluated first. Documents not matching are excluded entirely — the script is never executed for them.
2. For each matching document, the script is executed and must return a **non-negative numeric value**.
3. That returned value becomes the document's `_score` directly.
4. Documents are ranked by this score descending.

> The base query score is **not automatically included** in the final score. If you want to incorporate it, you must explicitly reference it in the script via `_score`.

---

### Accessing Data in Scripts

#### Document Field Values

```painless
doc['field_name'].value
```

- Works with numeric, keyword, boolean, and date fields.
- For fields that may be missing, check with `doc['field_name'].size() == 0` before accessing `.value`.
- [Inference] Text fields analyzed at index time are generally not accessible via `doc['field']` and require the field to have a `keyword` sub-field or be mapped as `keyword`. Behavior may vary.

#### The Base Query Score

```painless
_score
```

Available as a built-in variable representing the BM25 score from the base `query` clause.

#### Script Parameters

```painless
params.my_param
```

Values passed in via the `params` block — preferred over literals to avoid script recompilation on value changes.

#### Document Metadata

```painless
doc['_id']         // Document ID (as keyword)
doc['_index']      // Index name
```

> [Inference] Not all metadata fields are accessible via `doc[]` in script context. Available fields depend on Elasticsearch version and index configuration. Verify against your target version.

---

### Basic Syntax Examples

#### Return a Field Value as the Score

```json
GET /products/_search
{
  "query": {
    "script_score": {
      "query": { "match_all": {} },
      "script": {
        "source": "doc['popularity'].value"
      }
    }
  }
}
```

Every document is scored by its `popularity` field value directly.

---

#### Incorporate the Base Query Score

```json
GET /articles/_search
{
  "query": {
    "script_score": {
      "query": {
        "match": { "content": "elasticsearch" }
      },
      "script": {
        "source": "_score * Math.log1p(doc['view_count'].value)"
      }
    }
  }
}
```

The final score combines BM25 text relevance with a log-smoothed view count. Documents relevant to the query AND frequently viewed rank highest.

---

#### Using `params` for Configurable Weights

```json
GET /articles/_search
{
  "query": {
    "script_score": {
      "query": { "match": { "content": "elasticsearch" } },
      "script": {
        "source": """
          double text_score  = _score * params.text_weight;
          double pop_score   = Math.log1p(doc['view_count'].value) * params.pop_weight;
          return text_score + pop_score;
        """,
        "params": {
          "text_weight": 1.5,
          "pop_weight":  0.8
        }
      }
    }
  }
}
```

**Key Points**
- Using `params` avoids recompiling the script when only weight values change.
- [Inference] Elasticsearch compiles scripts and caches them. Changing `source` triggers recompilation; changing only `params` does not. This behavior is documented but may vary across versions.

---

### Handling Missing Field Values

Accessing a field that is absent from a document causes a runtime error. Always guard with a size check:

```json
{
  "script": {
    "source": """
      if (doc['rating'].size() == 0) {
        return 1.0;
      }
      return doc['rating'].value;
    """
  }
}
```

Alternatively, use a default value pattern:

```json
{
  "script": {
    "source": "doc['rating'].size() > 0 ? doc['rating'].value : params.default_score",
    "params": { "default_score": 1.0 }
  }
}
```

---

### Conditional Scoring Logic

Painless supports full conditional logic, enabling document-type-aware scoring:

```json
GET /content/_search
{
  "query": {
    "script_score": {
      "query": { "match": { "body": "machine learning" } },
      "script": {
        "source": """
          double base     = _score;
          double type_mul = 1.0;

          if (doc['content_type'].value == 'tutorial') {
            type_mul = 2.0;
          } else if (doc['content_type'].value == 'reference') {
            type_mul = 1.5;
          } else if (doc['content_type'].value == 'forum_post') {
            type_mul = 0.5;
          }

          return base * type_mul;
        """
      }
    }
  }
}
```

Tutorials rank highest, followed by reference material, then forum posts — all weighted on top of BM25 relevance.

---

### Vector Similarity Scoring

The `script_score` query is the primary mechanism for **dense vector search** using dot product, cosine similarity, or L2 distance when using `dense_vector` fields without an ANN index.

#### Dot Product

```json
GET /documents/_search
{
  "query": {
    "script_score": {
      "query": { "match_all": {} },
      "script": {
        "source": "dotProduct(params.query_vector, 'embedding') + 1.0",
        "params": {
          "query_vector": [0.12, 0.85, 0.34, 0.67]
        }
      }
    }
  }
}
```

#### Cosine Similarity

```json
{
  "script": {
    "source": "cosineSimilarity(params.query_vector, 'embedding') + 1.0",
    "params": {
      "query_vector": [0.12, 0.85, 0.34, 0.67]
    }
  }
}
```

#### L2 (Euclidean) Distance

```json
{
  "script": {
    "source": "1 / (1 + l2norm(params.query_vector, 'embedding'))",
    "params": {
      "query_vector": [0.12, 0.85, 0.34, 0.67]
    }
  }
}
```

**Key Points**
- Adding `1.0` to dot product and cosine similarity results is necessary because `script_score` requires non-negative scores, and these functions can return negative values.
- [Inference] For large-scale vector search, Elasticsearch's native `knn` query using ANN (approximate nearest neighbor) indexing is likely more performant than `script_score` with exact vector computation, as `script_score` performs exact brute-force comparison across all matching documents. Performance impact depends on corpus size and vector dimensionality.
- The `dense_vector` field must have `index: false` or the script must reference it appropriately depending on Elasticsearch version. Verify mapping requirements for your version.

---

### `min_score` Threshold

Excludes documents whose script-computed score falls below the threshold:

```json
GET /products/_search
{
  "query": {
    "script_score": {
      "query": { "match_all": {} },
      "script": {
        "source": "doc['rating'].value * doc['review_count'].value"
      },
      "min_score": 50.0
    }
  }
}
```

Only products where `rating × review_count ≥ 50` are returned.

> [Inference] `min_score` is applied after script execution, not before. All matching documents from the base `query` are scored first, then filtered by threshold. This means the script runs on all base-query matches regardless of the `min_score` value. Behavior may vary by version.

---

### Comprehensive Example: Job Ranking System

**Scenario:** Rank job postings by combining:
- Text relevance for "data engineer"
- Salary preference (higher is better, log-smoothed)
- Recency (posted within 30 days preferred)
- Seniority multiplier (senior roles ranked higher)

```json
GET /job_postings/_search
{
  "query": {
    "script_score": {
      "query": {
        "bool": {
          "must": [
            { "match": { "description": "data engineer" } }
          ],
          "filter": [
            { "term": { "status": "open" } }
          ]
        }
      },
      "script": {
        "source": """
          double text_score   = _score;
          double salary_score = 0.0;
          double recency_score = 0.0;
          double seniority_mul = 1.0;

          if (doc['salary_max'].size() > 0) {
            salary_score = Math.log1p(doc['salary_max'].value) * params.salary_weight;
          }

          long now_ms    = System.currentTimeMillis();
          long posted_ms = doc['posted_date'].value.toInstant().toEpochMilli();
          long days_old  = (now_ms - posted_ms) / 86400000;

          if (days_old <= 7) {
            recency_score = 3.0;
          } else if (days_old <= 30) {
            recency_score = 1.0;
          }

          if (doc['level'].value == 'senior') {
            seniority_mul = 1.5;
          } else if (doc['level'].value == 'lead') {
            seniority_mul = 2.0;
          }

          return (text_score + salary_score + recency_score) * seniority_mul;
        """,
        "params": {
          "salary_weight": 0.3
        }
      },
      "min_score": 1.0
    }
  }
}
```

**Score construction:**
- `text_score` — BM25 relevance for "data engineer".
- `salary_score` — log-smoothed salary, weighted by `0.3`.
- `recency_score` — fixed bonus based on how recently the job was posted.
- `seniority_mul` — multiplier based on seniority level.
- Posts scoring below `1.0` are excluded.

---

### `script_score` Query vs `script_score` Function in `function_score`

| Characteristic | `script_score` Query | `script_score` in `function_score` |
|----------------|---------------------|-------------------------------------|
| Introduced | Elasticsearch 7.0 | Earlier versions |
| Standalone query | ✅ Yes | ❌ No (nested inside `function_score`) |
| Combine with other functions | ❌ Not directly | ✅ Yes (via `functions` array) |
| Access to `_score` | ✅ Yes | ✅ Yes |
| Complexity | Simpler for pure script scoring | Better for mixed function scoring |
| Recommended for pure script use | ✅ Yes | ❌ Prefer `script_score` query |

---

### Performance Considerations

- [Inference] Scripts execute per document for every matching result from the base `query`. A broad base query (e.g., `match_all`) on a large index means the script runs on every document — this may significantly affect query latency. Narrowing the base query reduces the script execution surface.
- Use `params` consistently to benefit from script compilation caching.
- Avoid accessing many fields in a single script where simpler alternatives (e.g., `field_value_factor`, decay functions in `function_score`) would suffice — [Inference] built-in functions are likely more optimized than equivalent Painless implementations.
- [Inference] Vector similarity computations (`dotProduct`, `cosineSimilarity`, `l2norm`) in `script_score` are exact and scale linearly with the number of matching documents. For large corpora, consider `knn` queries with ANN indexing instead.

---

### Script Return Value Requirements

| Condition | Behavior |
|-----------|----------|
| Returns a positive float | Used as `_score` |
| Returns `0` | Document included with zero score |
| Returns a negative value | [Unverified] May throw an error depending on Elasticsearch version |
| Throws a runtime exception | Document may be excluded or query may fail depending on error handling configuration |

---

**Conclusion**

The `script_score` query is Elasticsearch's most flexible scoring mechanism, enabling arbitrary Painless-based computation as a document's relevance score. It is best suited for cases where built-in scoring functions cannot express the required logic — such as composite multi-signal ranking, conditional scoring by document type, or dense vector similarity search. The key to using it effectively is keeping the base `query` as selective as possible to limit script execution scope, using `params` for value injection, and guarding against missing fields to avoid runtime errors.