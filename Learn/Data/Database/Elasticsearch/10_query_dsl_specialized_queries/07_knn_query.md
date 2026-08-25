## Query DSL – Specialized Queries: `knn` Query

### Overview

The `knn` query performs **k-nearest neighbor** search over dense vector fields, returning the `k` documents whose stored vectors are closest to a given query vector. Proximity is measured by a configured similarity metric defined in the field mapping.

It is used for semantic search, recommendation, image similarity, anomaly detection, and any retrieval task where meaning or relationship is encoded as a vector rather than as discrete terms.

---

### Prerequisites

#### Field mapping

The target field must be mapped as `dense_vector` with indexing enabled:

```json
PUT /articles
{
  "mappings": {
    "properties": {
      "embedding": {
        "type": "dense_vector",
        "dims": 768,
        "index": true,
        "similarity": "cosine"
      }
    }
  }
}
```

| Mapping parameter | Description |
|---|---|
| `dims` | Number of dimensions; must match query vector exactly |
| `index` | Must be `true` to enable ANN search |
| `similarity` | Distance metric: `cosine`, `dot_product`, `l2_norm`, `max_inner_product` |

---

### Basic Syntax

```json
GET /articles/_search
{
  "knn": {
    "field": "embedding",
    "query_vector": [0.12, 0.45, 0.78, ...],
    "k": 10,
    "num_candidates": 100
  }
}
```

**Key point:** The top-level `knn` key is a sibling of `query`, not nested inside it. This is the standard form for a pure knn search request.

---

### Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `field` | string | Yes | The `dense_vector` field to search |
| `query_vector` | array of floats | Yes (or `query_vector_builder`) | The vector to find neighbors for |
| `query_vector_builder` | object | Yes (or `query_vector`) | Generates the query vector at search time via a model |
| `k` | integer | Yes | Number of nearest neighbors to return |
| `num_candidates` | integer | Yes | Number of candidates collected per shard before final selection |
| `filter` | query object | No | Pre-filters documents before ANN search |
| `boost` | float | No | Score multiplier applied to knn results |
| `similarity` | float | No | Minimum similarity threshold; documents below this are excluded |
| `inner_hits` | object | No | Used with nested vectors to retrieve matching inner hits |

---

### `k` vs `num_candidates`

These two parameters are distinct and both required:

- **`k`** — the final number of results returned to the caller.
- **`num_candidates`** — the number of approximate nearest neighbor candidates each shard collects internally before the coordinating node merges and selects the top `k`.

`num_candidates` must be ≥ `k`. Higher values improve recall (more accurate nearest neighbor results) at the cost of latency and compute.

[Inference] Setting `num_candidates` too close to `k` may produce less accurate results because fewer candidates are available for the final selection step, especially on large shards. Optimal values depend on index size, shard count, and acceptable latency. Behavior may vary.

---

### Approximate vs Exact Search

Elasticsearch uses **Approximate Nearest Neighbor (ANN)** search by default when `index: true` is set on the field. This uses HNSW (Hierarchical Navigable Small World) graphs internally.

**Exact knn** (brute-force) is performed when:
- The field has `index: false`, or
- The `knn` query is used inside a `script_score` query using `cosineSimilarity`, `dotProduct`, or similar functions.

[Inference] Exact search scans all documents and is accurate but does not scale to large indices. ANN trades a small amount of recall for significantly better performance at scale. Behavior and accuracy trade-offs depend on HNSW index parameters (`ef_construction`, `m`) set at mapping time.

---

### Similarity Metrics

Defined in the field mapping, not at query time:

| Metric | Description | Common Use |
|---|---|---|
| `cosine` | Angle between vectors; magnitude-invariant | Text embeddings (normalized) |
| `dot_product` | Raw dot product; requires unit-length vectors | Optimized cosine on pre-normalized vectors |
| `l2_norm` | Euclidean distance | Geometric/spatial similarity |
| `max_inner_product` | Dot product without normalization requirement | Recommendation systems |

[Inference] `dot_product` and `cosine` produce equivalent rankings when vectors are unit-normalized. Using `dot_product` on non-normalized vectors may produce unexpected results. Behavior depends on how embeddings were generated.

---

### Filtering

The `filter` parameter restricts the candidate document set before ANN search is performed. This is referred to as **pre-filtering**.

```json
{
  "knn": {
    "field": "embedding",
    "query_vector": [0.12, 0.45, 0.78],
    "k": 5,
    "num_candidates": 50,
    "filter": {
      "term": { "category": "technology" }
    }
  }
}
```

[Inference] Aggressive filtering (very few documents pass the filter) can degrade ANN recall because the HNSW graph traversal operates on the full index and the filter is applied afterward at the candidate level. In extreme cases, fewer than `k` results may be returned. Behavior may vary by index size and filter selectivity.

---

### `query_vector_builder` (Model-Generated Vectors)

Instead of supplying a pre-computed vector, you can instruct Elasticsearch to generate the query vector at search time using a deployed model:

```json
{
  "knn": {
    "field": "embedding",
    "query_vector_builder": {
      "text_embedding": {
        "model_id": "sentence-transformers__all-minilm-l6-v2",
        "model_text": "what is distributed consensus"
      }
    },
    "k": 10,
    "num_candidates": 100
  }
}
```

The model must be deployed via the Elasticsearch ML nodes. The `text_embedding` task type applies the model to `model_text` and produces a vector of the appropriate dimensionality.

[Inference] The model used at index time and query time must produce vectors of the same dimensionality and be trained with the same similarity assumption. Mismatched models produce semantically meaningless results. Behavior is not guaranteed to be consistent across model versions.

---

### Minimum Similarity Threshold

The `similarity` parameter excludes documents whose vector similarity to the query falls below a specified value. The scale depends on the mapping's similarity metric.

```json
{
  "knn": {
    "field": "embedding",
    "query_vector": [0.1, 0.2, 0.3],
    "k": 10,
    "num_candidates": 100,
    "similarity": 0.8
  }
}
```

| Metric | Similarity range |
|---|---|
| `cosine` | `[-1, 1]` (higher = more similar) |
| `dot_product` | Unbounded; depends on vector magnitude |
| `l2_norm` | `[0, 1]` after internal transformation |
| `max_inner_product` | Unbounded |

[Inference] The internal score transformation Elasticsearch applies to convert distances into scores varies by metric. The value passed to `similarity` is compared against the transformed score, not the raw distance. Consult current Elasticsearch documentation for exact transformation formulas per metric, as these may change between versions.

---

### Using `knn` Inside the `query` Context

The `knn` clause can appear inside the top-level `query` parameter when combining with other query types. In this position it behaves as a query clause and participates in score combination.

```json
{
  "query": {
    "knn": {
      "field": "embedding",
      "query_vector": [0.12, 0.45, 0.78],
      "num_candidates": 100,
      "k": 10
    }
  }
}
```

**Key point:** When used inside `query`, `k` controls how many knn results are contributed to the overall result set before merging with other clauses.

---

### Hybrid Search: Combining `knn` with `query`

Hybrid search merges keyword and vector results by combining their scores. Both `knn` and `query` are specified as top-level siblings:

```json
{
  "query": {
    "match": {
      "body": "distributed consensus"
    }
  },
  "knn": {
    "field": "embedding",
    "query_vector": [0.12, 0.45, 0.78],
    "k": 10,
    "num_candidates": 100
  },
  "size": 10
}
```

Scores from both sources are combined. By default, Elasticsearch sums the scores. Reciprocal Rank Fusion (RRF) is available as an alternative ranking strategy via the `rank` parameter.

---

### Reciprocal Rank Fusion (RRF)

RRF combines rankings from multiple result sets without requiring score normalization:

```json
{
  "query": {
    "match": { "body": "distributed consensus" }
  },
  "knn": {
    "field": "embedding",
    "query_vector": [0.12, 0.45, 0.78],
    "k": 10,
    "num_candidates": 100
  },
  "rank": {
    "rrf": {
      "window_size": 100,
      "rank_constant": 60
    }
  }
}
```

| RRF parameter | Description |
|---|---|
| `window_size` | Number of top results from each source considered for fusion |
| `rank_constant` | Controls rank smoothing; higher values reduce the impact of top ranks |

[Inference] RRF is generally more robust than raw score addition for hybrid search because it does not require BM25 and vector scores to be on the same scale. Optimal `rank_constant` and `window_size` values depend on the dataset and relevance requirements. Behavior may vary.

---

### Multiple `knn` Clauses

Multiple `knn` clauses can be provided as an array for multi-vector or multi-field search:

```json
{
  "knn": [
    {
      "field": "title_embedding",
      "query_vector": [0.1, 0.2, 0.3],
      "k": 5,
      "num_candidates": 50,
      "boost": 1.5
    },
    {
      "field": "body_embedding",
      "query_vector": [0.4, 0.5, 0.6],
      "k": 5,
      "num_candidates": 50
    }
  ]
}
```

Results from each clause are merged and scored independently before combination.

---

### Nested Dense Vectors

For documents containing arrays of vectors (e.g., multi-passage embeddings), the field can be nested and queried with `inner_hits` to identify which nested vector matched:

```json
{
  "knn": {
    "field": "passages.embedding",
    "query_vector": [0.1, 0.2, 0.3],
    "k": 5,
    "num_candidates": 50,
    "inner_hits": { "size": 1, "_source": false }
  }
}
```

[Inference] Nested knn requires the vector field to be within a `nested` mapping type. Each nested object is treated as a separate vector candidate. This approach supports passage-level retrieval within documents. Behavior and performance characteristics differ from top-level vector fields.

---

### Performance Considerations

- **`num_candidates`** is the primary recall-vs-latency trade-off lever. Start at `k * 10` and tune from there.
- **HNSW index parameters** (`m`, `ef_construction`) set at mapping time affect both index build cost and query recall. Higher values improve recall but increase memory and indexing time.
- **Filtering** reduces the candidate pool and can lower recall in ANN mode. For highly selective filters, consider exact search or over-fetching with a larger `num_candidates`.
- **Shard count** affects knn behavior: each shard runs independently and returns `num_candidates` results; the coordinating node selects the final `k`. More shards generally requires a higher `num_candidates` to maintain recall.
- [Inference] Quantization options (available from Elasticsearch 8.x onward) can reduce memory footprint of vector indices at the cost of some accuracy. Behavior depends on quantization type and dataset characteristics.

---

### Limitations

| Limitation | Detail |
|---|---|
| Requires `index: true` on field | Non-indexed dense vector fields fall back to exact search only |
| `dims` must match exactly | Query vector dimensionality must equal field mapping dimensionality |
| Not a term-based query | Does not interact with analyzers, tokenization, or inverted index |
| ANN is approximate | Results are not guaranteed to be the true k nearest neighbors |
| Filter + ANN interaction | Aggressive filters can reduce result count below `k` |
| Model consistency required | `query_vector_builder` model must match indexing model |

---

### Comparison with Related Approaches

| Approach | Mechanism | Use Case |
|---|---|---|
| `knn` query (ANN) | HNSW graph traversal | Scalable semantic / vector search |
| `script_score` + vector functions | Exact brute-force scoring | Small indices, precise scoring |
| `more_like_this` | Term frequency statistics | Term-based document similarity |
| Hybrid (`knn` + `match`) | Combined vector + keyword scoring | Balanced semantic and lexical retrieval |

---

### Summary

| Aspect | Detail |
|---|---|
| Field type required | `dense_vector` with `index: true` |
| Search method | Approximate nearest neighbor (HNSW) |
| Core parameters | `field`, `query_vector` or `query_vector_builder`, `k`, `num_candidates` |
| Filtering | Pre-filter via `filter`; may reduce recall |
| Hybrid search | Combine with `query` and optionally `rank.rrf` |
| Similarity threshold | `similarity` parameter; metric-dependent scale |
| Recall tuning | `num_candidates`, HNSW mapping params |
| Not suitable for | Term/keyword matching, small result guarantees under heavy filtering |