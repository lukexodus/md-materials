## Query DSL – Sorting by Score

### Overview

Relevance score (`_score`) is Elasticsearch's primary ranking signal. When no explicit `sort` is specified, results are ordered by `_score` descending — highest scoring documents first. Score-based sorting can also be combined with field value sorts, manipulated via boosting, or replaced entirely with custom scoring functions.

Understanding score-based sorting requires understanding how scores are computed, what affects them, and how to control or inspect them.

---

### Default Behavior

Without a `sort` parameter, Elasticsearch implicitly applies:

```json
{
  "sort": [
    { "_score": { "order": "desc" } }
  ]
}
```

This is the default and does not need to be stated explicitly. All scoring queries contribute to `_score`; filter context clauses do not.

---

### Explicit Score Sort

`_score` can be declared explicitly in the `sort` array, which is necessary when combining score with other sort fields:

```json
{
  "sort": [
    { "publish_date": { "order": "desc" } },
    { "_score": { "order": "desc" } }
  ],
  "query": {
    "match": { "body": "sharding strategies" }
  }
}
```

Here, documents are sorted by date first. Among documents sharing the same date, `_score` breaks ties.

---

### How `_score` Is Computed

Elasticsearch uses **BM25** (Best Match 25) as the default similarity algorithm. BM25 is a probabilistic ranking function based on term frequency, inverse document frequency, and field length normalization.

#### BM25 components

| Component | Description |
|---|---|
| **TF (Term Frequency)** | How often a query term appears in the field. More occurrences increase score, with diminishing returns. |
| **IDF (Inverse Document Frequency)** | How rare the term is across the index. Rare terms score higher than common terms. |
| **Field length norm** | Shorter fields score higher for the same term match than longer fields, assuming the term is proportionally more significant. |

#### BM25 parameters

Configurable per field in the mapping:

```json
PUT /articles
{
  "mappings": {
    "properties": {
      "body": {
        "type": "text",
        "similarity": "BM25"
      }
    }
  }
}
```

Custom BM25 parameters via a custom similarity setting:

```json
PUT /articles
{
  "settings": {
    "similarity": {
      "custom_bm25": {
        "type": "BM25",
        "k1": 1.5,
        "b": 0.75
      }
    }
  },
  "mappings": {
    "properties": {
      "body": {
        "type": "text",
        "similarity": "custom_bm25"
      }
    }
  }
}
```

| BM25 parameter | Effect |
|---|---|
| `k1` | Controls term frequency saturation. Higher values give more weight to repeated terms. Default: `1.2`. |
| `b` | Controls field length normalization. `0` disables normalization; `1` applies full normalization. Default: `0.75`. |

---

### Score in the Response

Each hit includes a `_score` field:

```json
"hits": [
  {
    "_id": "42",
    "_score": 3.7281,
    "_source": { ... }
  }
]
```

`_score` is `null` when:
- The query runs entirely in filter context (no scoring query).
- A non-score field sort is applied without `track_scores: true`.

---

### Score Explanation

To inspect how a score was computed, use the `explain` parameter:

```json
GET /articles/_search
{
  "explain": true,
  "query": {
    "match": { "body": "distributed consensus" }
  }
}
```

Each hit includes an `_explanation` block detailing the scoring tree:

```json
"_explanation": {
  "value": 3.7281,
  "description": "sum of:",
  "details": [
    {
      "value": 2.1,
      "description": "weight(body:distributed in 0) [PerFieldSimilarity], result of:",
      "details": [ ... ]
    }
  ]
}
```

Alternatively, use the Explain API for a single document:

```json
GET /articles/_explain/42
{
  "query": {
    "match": { "body": "distributed consensus" }
  }
}
```

[Inference] Score explanations can be verbose for complex queries. They are intended for debugging and tuning, not production query paths. The explanation reflects per-shard statistics, which may differ from final merged scores in a multi-shard index. Behavior may vary.

---

### Score and Shard Statistics

BM25 IDF is computed **per shard**, not globally across the index. This means a term's rarity is judged relative to the documents on each shard, not the entire index.

In a multi-shard index, the same document may receive a different score depending on which shard it resides on, because IDF is computed locally.

#### Mitigation: DFS Query Then Fetch

The `search_type=dfs_query_then_fetch` parameter forces a global term statistics collection phase before scoring:

```
GET /articles/_search?search_type=dfs_query_then_fetch
```

With DFS (Distributed Frequency Search), term frequencies are gathered from all shards first, then scoring is performed using global statistics. This produces more consistent scores across shards.

[Inference] DFS adds a pre-query network round-trip across all shards, which increases latency. It is generally not necessary for large, well-distributed indices where per-shard statistics approximate global statistics closely. Behavior and score consistency depend on index size, shard count, and document distribution.

---

### Boosting Score

Score can be influenced at query time through boosting mechanisms.

#### `boost` parameter on a query clause

```json
{
  "query": {
    "bool": {
      "should": [
        { "match": { "title": { "query": "elasticsearch", "boost": 3.0 } } },
        { "match": { "body": { "query": "elasticsearch", "boost": 1.0 } } }
      ]
    }
  }
}
```

Matches in `title` contribute three times as much to `_score` as matches in `body`.

#### `boosting` query

Reduces the score of documents matching a `negative` clause:

```json
{
  "query": {
    "boosting": {
      "positive": {
        "match": { "body": "elasticsearch performance" }
      },
      "negative": {
        "term": { "category": "deprecated" }
      },
      "negative_boost": 0.2
    }
  }
}
```

Documents matching `negative` have their score multiplied by `negative_boost`. They are not excluded — only demoted.

#### Index-level `boost` (deprecated)

Index-level boosts applied at index time via mapping are deprecated and should not be used. Query-time boosting is the supported approach.

---

### `function_score` Query

`function_score` wraps an existing query and modifies document scores using one or more mathematical functions:

```json
{
  "query": {
    "function_score": {
      "query": {
        "match": { "body": "search relevance" }
      },
      "functions": [
        {
          "filter": { "term": { "featured": true } },
          "weight": 2.0
        },
        {
          "field_value_factor": {
            "field": "view_count",
            "factor": 0.001,
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

#### Available functions

| Function | Description |
|---|---|
| `weight` | Multiplies score by a fixed value for documents matching a filter |
| `field_value_factor` | Incorporates a numeric field value into the score |
| `random_score` | Assigns a consistent random score (useful for randomized ranking) |
| `script_score` | Computes score via a Painless script |
| `gauss` / `linear` / `exp` | Decay functions — reduce score based on distance from an ideal value |

#### `score_mode`

Controls how multiple function scores are combined:

| Value | Description |
|---|---|
| `multiply` | Multiply function scores together (default) |
| `sum` | Sum all function scores |
| `avg` | Average of function scores |
| `first` | Use first matching function's score |
| `max` | Use highest function score |
| `min` | Use lowest function score |

#### `boost_mode`

Controls how the combined function score interacts with the original query score:

| Value | Description |
|---|---|
| `multiply` | Multiply query score by function score (default) |
| `replace` | Discard query score; use function score only |
| `sum` | Add function score to query score |
| `avg` | Average of query score and function score |
| `max` | Use the higher of the two |
| `min` | Use the lower of the two |

---

### `script_score` Query

Computes score entirely from a Painless script, replacing the original query score:

```json
{
  "query": {
    "script_score": {
      "query": {
        "match": { "body": "indexing performance" }
      },
      "script": {
        "source": "_score * Math.log(1 + doc['view_count'].value)"
      }
    }
  }
}
```

The `_score` variable inside the script refers to the score produced by the inner `query`.

[Inference] `script_score` executes the script per matched document and does not benefit from caching. On large result sets or complex scripts, this adds significant computation time. Behavior and performance may vary.

---

### `constant_score` Query

Replaces relevance scoring with a fixed score for all matching documents:

```json
{
  "query": {
    "constant_score": {
      "filter": {
        "term": { "status": "published" }
      },
      "boost": 1.5
    }
  }
}
```

All matching documents receive `_score = 1.5`. Used when relative ranking among results is not needed, or when combining with other scored clauses where this clause should contribute a uniform weight.

---

### Decay Functions

Decay functions reduce score based on how far a field value is from an ideal point. They are applied within `function_score`:

```json
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "functions": [
        {
          "gauss": {
            "publish_date": {
              "origin": "now",
              "scale": "30d",
              "offset": "7d",
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
| `origin` | The ideal value (peak score) |
| `scale` | Distance from `origin` at which score is reduced by `decay` factor |
| `offset` | Range around `origin` within which score is not reduced |
| `decay` | Score multiplier at the `scale` distance from `origin` |

| Function | Curve shape |
|---|---|
| `gauss` | Bell curve; gradual decay near origin, faster further out |
| `linear` | Linear decay; uniform reduction with distance |
| `exp` | Exponential decay; sharp reduction near origin, slower further out |

---

### Minimum Score Threshold

The `min_score` parameter excludes documents whose `_score` falls below a specified value:

```json
{
  "min_score": 1.5,
  "query": {
    "match": { "body": "lucene internals" }
  }
}
```

[Inference] `min_score` is applied after scoring, not as a pre-filter. All matched documents are scored first; those below the threshold are then excluded. This does not reduce scoring computation. The appropriate threshold value is dataset and query dependent — scores are not normalized to a fixed scale and vary with index composition. Behavior may vary.

---

### Tracking Scores Alongside Field Sort

When sorting by a field other than `_score`, scores are not computed by default. Use `track_scores: true` to compute and return scores without affecting sort order:

```json
{
  "sort": [{ "publish_date": "desc" }],
  "track_scores": true,
  "query": {
    "match": { "body": "segment merging" }
  }
}
```

`_score` is populated in results but does not influence document order.

---

### Score Normalization

Elasticsearch does not normalize scores to a fixed range (e.g., 0–1) by default. Scores are absolute values dependent on:

- Query structure and number of clauses
- Term statistics in the index
- BM25 parameters
- Boost values applied

[Inference] Comparing `_score` values across different queries, indices, or time periods is generally not meaningful without accounting for these variables. Score values are best interpreted relatively within a single query's result set, not as absolute measures of relevance. Behavior may vary.

---

### Limitations

| Limitation | Detail |
|---|---|
| Per-shard IDF | Score inconsistency across shards without DFS |
| No fixed scale | Scores are not normalized; absolute values are not portable |
| `min_score` cost | Does not skip scoring; only filters after the fact |
| Script score | No caching; per-document execution cost |
| `explain` overhead | Adds significant response size and computation; not for production |
| `track_scores` cost | Forces scoring even when sort does not require it |

---

### Summary

| Aspect | Detail |
|---|---|
| Default sort | `_score` descending |
| Scoring algorithm | BM25 (configurable per field) |
| Score visibility | `_score` in each hit; `null` when unscored |
| Score inspection | `explain: true` or Explain API |
| Shard consistency | Use `dfs_query_then_fetch` for global term statistics |
| Boosting | `boost` parameter, `boosting` query, `function_score`, `script_score` |
| Fixed score | `constant_score` |
| Score threshold | `min_score` (post-scoring filter) |
| Score with field sort | `track_scores: true` |
| Decay functions | `gauss`, `linear`, `exp` inside `function_score` |