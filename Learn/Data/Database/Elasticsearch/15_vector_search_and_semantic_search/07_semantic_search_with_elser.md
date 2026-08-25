## Semantic Search with ELSER

### Overview

ELSER (Elastic Learned Sparse EncodeR) is Elastic's proprietary sparse vector model for semantic search. Unlike dense vector embeddings, ELSER expands text into a weighted set of terms drawn from the model's learned vocabulary, combining the interpretability of lexical search with semantic understanding — retrieving documents that are conceptually relevant even when they don't share exact keywords with the query.

### How ELSER Differs from Dense Vectors

**Key Points**
- Dense vectors (e.g., from `e5` or `all-mpnet-base-v2`) encode text into fixed-length arrays of floats representing a position in continuous embedding space, compared via cosine similarity or dot product.
- Sparse vectors from ELSER map text onto a large vocabulary of "expansion terms," each with a learned weight — most entries are zero, hence "sparse."
- Sparse representations are stored and queried using Elasticsearch's inverted index machinery (via `rank_features`), so no dedicated vector index or ANN algorithm is required for retrieval.
- ELSER weights double as a form of query expansion: a query for "car" may activate terms like "automobile," "vehicle," and "engine" with varying weights, without an explicit synonym list.

[Inference] Because ELSER retrieval piggybacks on inverted-index scoring rather than approximate nearest-neighbor search, its latency characteristics at very large scale can differ from `dense_vector` + HNSW, though actual performance depends on hardware, shard count, and field cardinality.

### ELSER Model Versions

- **`.elser_model_2`** — the general-availability version, English-only, distributed as a linux-x86_64 optimized build and a platform-agnostic build.
- Elastic also provides **`.elser_model_2_linux-x86_64`**, which uses PyTorch's optimized inference on compatible hardware for better throughput.
- Both versions are deployed via Elastic's model management APIs and run inside Elasticsearch's ML nodes — no external inference service is required.

### Prerequisites

- A machine learning node (or nodes) with sufficient memory allocated — ELSER model deployment requires dedicated ML node capacity, typically at least 2GB+ per allocation.
- Elasticsearch 8.8+ for the fully managed built-in ELSER experience via the `_inference` API; earlier 8.x versions required manual model download and deployment via Eland.
- Appropriate licensing — ELSER is available on Elastic's free tier for evaluation but production use of trained models generally requires a paid subscription tier. [Unverified — exact licensing terms change over time and should be checked against current Elastic pricing documentation.]

### Deploying ELSER

**Example**

```
PUT _inference/sparse_embedding/my-elser-endpoint
{
  "service": "elser",
  "service_settings": {
    "num_allocations": 1,
    "num_threads": 1
  }
}
```

This single call downloads (if needed), deploys, and starts the model, exposing it as a named inference endpoint usable across ingest pipelines and query-time inference.

Legacy/manual approach (pre-inference-API):

```
POST _ml/trained_models/.elser_model_2/deployment/_start
{
  "number_of_allocations": 1,
  "threads_per_allocation": 1
}
```

### Indexing with ELSER

An index mapping for ELSER output uses the `sparse_vector` field type (introduced 8.11+, replacing the earlier `rank_features` pattern for this use case):

```
PUT my-index
{
  "mappings": {
    "properties": {
      "content": { "type": "text" },
      "content_embedding": { "type": "sparse_vector" }
    }
  }
}
```

An ingest pipeline computes the ELSER expansion at index time:

```
PUT _ingest/pipeline/elser-pipeline
{
  "processors": [
    {
      "inference": {
        "model_id": "my-elser-endpoint",
        "input_output": [
          {
            "input_field": "content",
            "output_field": "content_embedding"
          }
        ]
      }
    }
  ]
}
```

Documents are then indexed through this pipeline:

```
PUT my-index/_doc/1?pipeline=elser-pipeline
{
  "content": "Elasticsearch is a distributed search and analytics engine."
}
```

### Querying with ELSER

**Example**

The `sparse_vector` query (successor to the deprecated `text_expansion` query) runs the query text through the same model at search time and scores documents via the learned term overlap:

```
GET my-index/_search
{
  "query": {
    "sparse_vector": {
      "field": "content_embedding",
      "inference_id": "my-elser-endpoint",
      "query": "how does distributed search work"
    }
  }
}
```

[Unverified] `text_expansion` remains functional in recent 8.x releases for backward compatibility but is marked deprecated in favor of `sparse_vector`; exact removal timelines should be checked against current Elastic version documentation.

### Combining ELSER with Lexical Search (Hybrid)

ELSER is commonly combined with traditional BM25 lexical queries via `bool` `should` clauses or via Reciprocal Rank Fusion (RRF):

```
GET my-index/_search
{
  "retriever": {
    "rrf": {
      "retrievers": [
        {
          "standard": {
            "query": {
              "match": { "content": "distributed search architecture" }
            }
          }
        },
        {
          "standard": {
            "query": {
              "sparse_vector": {
                "field": "content_embedding",
                "inference_id": "my-elser-endpoint",
                "query": "distributed search architecture"
              }
            }
          }
        }
      ]
    }
  }
}
```

This hybrid pattern typically outperforms either method alone: lexical search anchors exact term/entity matches (product codes, names), while ELSER captures conceptual/paraphrase matches.

### Performance and Tuning Considerations

- **`num_allocations`** — increases parallel throughput for concurrent inference requests; scale with available ML node vCPUs.
- **`num_threads`** — threads per allocation, affecting single-request latency; tune based on document/query length and node core count.
- Pruning tokens: ELSER expansions can include tens to hundreds of nonzero weighted terms per document, meaningfully increasing index size compared to raw text; Elasticsearch 8.13+ introduced token pruning options to reduce this footprint at some retrieval-quality tradeoff. [Inference — the precise recall impact of pruning depends on the specific corpus and query set and is best validated empirically.]
- Batch inference at ingest time (via `_bulk` combined with the ingest pipeline) is recommended for large corpora rather than per-document calls.

### ELSER vs. Dense Vector Models — When to Choose Which

| Consideration | ELSER (sparse) | Dense vector (e.g., E5, custom) |
|---|---|---|
| Interpretability | High — expansion terms are human-readable | Low — embeddings are opaque |
| Language support | English-only (as of ELSER v2) | Often multilingual, model-dependent |
| Infra requirements | ML node deployment inside Elasticsearch | `dense_vector` field + optional HNSW index |
| Query cost model | Inverted index scoring | ANN search (HNSW) or exact brute-force |
| Out-of-the-box tuning | Minimal — designed to work well by default | Often needs domain-specific fine-tuning |

### Architecture Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 420">
  <text x="400" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">ELSER Semantic Search Pipeline (svg_diagram)</text>

  <rect x="40" y="70" width="180" height="60" rx="6" fill="#e8f0fe" stroke="#4a86e8" stroke-width="2" />
  <text x="130" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Raw Document</text>
  <text x="130" y="113" text-anchor="middle" font-size="11" fill="#555">"content" field</text>

  <rect x="290" y="70" width="200" height="60" rx="6" fill="#fef3e0" stroke="#e69138" stroke-width="2" />
  <text x="390" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Ingest Pipeline</text>
  <text x="390" y="113" text-anchor="middle" font-size="11" fill="#555">inference processor</text>

  <rect x="560" y="70" width="200" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="660" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">ELSER Model</text>
  <text x="660" y="113" text-anchor="middle" font-size="11" fill="#555">ML node deployment</text>

  <line x1="220" y1="100" x2="285" y2="100" stroke="#888" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="490" y1="100" x2="555" y2="100" stroke="#888" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="290" y="180" width="200" height="60" rx="6" fill="#f3e8fd" stroke="#8e44ad" stroke-width="2" />
  <text x="390" y="205" text-anchor="middle" font-size="13" fill="#1a1a1a">sparse_vector field</text>
  <text x="390" y="223" text-anchor="middle" font-size="11" fill="#555">token: weight pairs</text>

  <line x1="660" y1="130" x2="660" y2="210" stroke="#888" stroke-width="2" />
  <line x1="660" y1="210" x2="495" y2="210" stroke="#888" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="40" y="300" width="180" height="60" rx="6" fill="#e8f0fe" stroke="#4a86e8" stroke-width="2" />
  <text x="130" y="325" text-anchor="middle" font-size="13" fill="#1a1a1a">User Query</text>
  <text x="130" y="343" text-anchor="middle" font-size="11" fill="#555">natural language</text>

  <rect x="290" y="300" width="200" height="60" rx="6" fill="#fef3e0" stroke="#e69138" stroke-width="2" />
  <text x="390" y="325" text-anchor="middle" font-size="13" fill="#1a1a1a">sparse_vector query</text>
  <text x="390" y="343" text-anchor="middle" font-size="11" fill="#555">runtime inference</text>

  <rect x="560" y="300" width="200" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="660" y="325" text-anchor="middle" font-size="13" fill="#1a1a1a">Ranked Results</text>
  <text x="660" y="343" text-anchor="middle" font-size="11" fill="#555">inverted-index scoring</text>

  <line x1="220" y1="330" x2="285" y2="330" stroke="#888" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="490" y1="330" x2="555" y2="330" stroke="#888" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="390" y1="240" x2="390" y2="295" stroke="#888" stroke-width="2" stroke-dasharray="4,3" marker-end="url(#arrow)" />

  </svg>

### Common Pitfalls

- Forgetting to allocate sufficient ML node memory, causing model deployment to fail or queue indefinitely.
- Applying `sparse_vector` queries against a field that wasn't populated through the matching inference pipeline (field/model mismatch causes empty or degraded scores).
- Treating ELSER as a drop-in replacement for BM25 rather than a complement — pure semantic search can underperform on exact-match-critical queries (SKUs, IDs, precise terminology).
- Not accounting for the larger on-disk footprint of sparse vector expansions when capacity planning.

### Next Steps

- Dense vector search with `dense_vector` fields and HNSW-based kNN
- Hybrid retrieval strategies: RRF vs. linear combination scoring
- Custom text embedding models via the `_inference` API (third-party providers)
- Token pruning and `sparse_vector` query performance tuning
- Reranking with cross-encoder models atop initial ELSER/BM25 retrieval