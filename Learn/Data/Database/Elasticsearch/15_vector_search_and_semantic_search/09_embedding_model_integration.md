## Embedding Model Integration

### Overview

Embedding model integration in Elasticsearch refers to the mechanisms by which text (or other data) is converted into dense or sparse vector representations directly within the Elasticsearch/Elastic Stack ecosystem, rather than requiring a fully separate external pipeline. Elasticsearch supports this primarily through two complementary paths: the **inference API** with third-party or hosted models, and **Eland-deployed** models running natively on ML nodes. This allows embedding generation to happen at ingest time and at query time without the application layer needing to manage a separate model-serving service.

### Why Integration Matters

Without native integration, a typical vector search pipeline requires:

- A separate embedding service (e.g., a Python microservice wrapping a sentence-transformer model)
- Custom application code to call that service before every index and every search request
- Manual synchronization of model versions between indexing and querying
- Separate scaling and monitoring for the embedding service

Native integration collapses much of this into the Elasticsearch cluster itself, using the `_inference` API and the `semantic_text` field type to abstract away vectorization.

### Core Integration Pathways

#### 1. Elastic's `_inference` API

The `_inference` API provides a unified interface for calling embedding (and other NLP) models, regardless of whether they run on the Elasticsearch ML nodes or on a remote third-party service.

**Key Points**
- Defines an **inference endpoint**, which pairs a task type (`text_embedding`, `sparse_embedding`, `rerank`, `completion`, etc.) with a specific model and service configuration.
- Endpoints are created once via `PUT _inference/<task_type>/<endpoint_id>` and then referenced by ID elsewhere (in `semantic_text` fields or direct `_inference` calls).
- Supports both **third-party hosted services** and **models deployed on Elasticsearch's own ML nodes**.

#### 2. Supported Service Integrations

Elasticsearch's inference API supports a growing set of first-party service integrations. As of recent versions, these include (non-exhaustive):

- **elasticsearch** (self-hosted models via Eland, including ELSER and E5)
- **elser** (Elastic's own sparse embedding model, shorthand service)
- **openai** (OpenAI embedding models, e.g., `text-embedding-3-small`)
- **cohere** (Cohere embedding and rerank models)
- **azureopenai**
- **azureaistudio**
- **googlevertexai**
- **amazonbedrock**
- **hugging_face** (via Hugging Face Inference Endpoints)
- **mistral**
- **anthropic** (chat completion, not embeddings)
- **jinaai**
- **watsonxai**

[Unverified] The exact list and configuration options vary by Elasticsearch version, as Elastic actively adds new provider integrations; consult the current documentation for the definitive set at any given version.

**Example** — creating an OpenAI text-embedding inference endpoint:

```
PUT _inference/text_embedding/my-openai-embeddings
{
  "service": "openai",
  "service_settings": {
    "api_key": "<OPENAI_API_KEY>",
    "model_id": "text-embedding-3-small"
  }
}
```

**Example** — creating a Cohere embedding endpoint:

```
PUT _inference/text_embedding/my-cohere-embeddings
{
  "service": "cohere",
  "service_settings": {
    "api_key": "<COHERE_API_KEY>",
    "model_id": "embed-english-v3.0",
    "embedding_type": "float"
  }
}
```

#### 3. Self-Hosted Models via Eland

For models not covered by a first-party service integration, Elastic provides the **Eland** Python client to upload PyTorch-based transformer models (in TorchScript format) directly into Elasticsearch, where they run on dedicated ML nodes.

**Key Points**
- Eland uses `eland_import_hub_model` to pull a model from the Hugging Face Hub and import it.
- The model must be traceable to TorchScript; not all Hugging Face architectures are compatible out of the box — Elastic maintains a list of tested/supported architectures (e.g., BERT, RoBERTa, MPNet-based sentence-transformers, DPR).
- Once imported, the model is deployed via the trained models API and can then be wrapped in an `elasticsearch`-service inference endpoint.

**Example** — importing a sentence-transformer model with Eland:

```
eland_import_hub_model \
  --url https://<cluster-url> \
  --hub-model-id sentence-transformers/all-MiniLM-L6-v2 \
  --task-type text_embedding \
  --start
```

**Example** — wrapping the deployed model in an inference endpoint:

```
PUT _inference/text_embedding/my-minilm-embeddings
{
  "service": "elasticsearch",
  "service_settings": {
    "model_id": "sentence-transformers__all-minilm-l6-v2",
    "num_allocations": 1,
    "num_threads": 1
  }
}
```

### The `semantic_text` Field Type

The `semantic_text` field type is the highest-level abstraction for embedding integration. It ties an inference endpoint to a field, so that embedding generation happens automatically on document ingest and on query, without the application manually computing vectors.

**Key Points**
- Declared in the mapping with a reference to an `inference_id`.
- Elasticsearch automatically chunks long text, generates embeddings via the referenced endpoint, and stores the resulting vectors (dense or sparse depending on the model).
- Querying uses the `semantic` query type, which internally re-uses the same inference endpoint to embed the query text before performing the vector similarity search.
- Abstracts away whether the underlying model produces dense vectors (stored typically as `dense_vector`) or sparse vectors (as with ELSER, stored as `sparse_vector`/rank features).

**Example** — mapping with `semantic_text`:

```
PUT my-index
{
  "mappings": {
    "properties": {
      "content": {
        "type": "semantic_text",
        "inference_id": "my-openai-embeddings"
      }
    }
  }
}
```

**Example** — indexing a document (embedding happens automatically):

```
POST my-index/_doc
{
  "content": "Elasticsearch integrates embedding models directly at the storage layer."
}
```

**Example** — querying with the `semantic` query:

```
GET my-index/_search
{
  "query": {
    "semantic": {
      "field": "content",
      "query": "How does Elasticsearch generate vectors automatically?"
    }
  }
}
```

### Manual Embedding Path (Explicit `dense_vector` Fields)

Before `semantic_text` existed, and still relevant for cases requiring fine-grained control, embeddings can be computed explicitly via the `_inference` API and stored in a manually defined `dense_vector` field.

**Key Points**
- Requires calling `_inference` at index time to get the embedding, then including that vector in the document body.
- Requires calling `_inference` again at query time (or computing the vector application-side) to run a `knn` query.
- Gives full control over field mapping options (`dims`, `similarity`, `index_options`) that `semantic_text` manages implicitly.

**Example** — computing an embedding directly:

```
POST _inference/text_embedding/my-openai-embeddings
{
  "input": "Elasticsearch integrates embedding models directly at the storage layer."
}
```

**Example** — mapping a manual `dense_vector` field:

```
PUT my-manual-index
{
  "mappings": {
    "properties": {
      "content": { "type": "text" },
      "content_embedding": {
        "type": "dense_vector",
        "dims": 1536,
        "index": true,
        "similarity": "cosine"
      }
    }
  }
}
```

### Chunking Behavior

Embedding models have fixed maximum input token limits (e.g., 512 tokens for many BERT-derived models). Since documents often exceed this, `semantic_text` handles chunking automatically.

**Key Points**
- Long field values are split into passages/chunks before embedding.
- Each chunk gets its own embedding, and query-time semantic search matches against the best-scoring chunk(s), with the parent document returned.
- Chunking strategy (e.g., `sentence`, `word`-based) and chunk size can be configured via `chunking_settings` in more recent versions rather than relying solely on defaults. [Unverified] Exact default chunk sizes and configurable parameters differ across Elasticsearch versions.

**Example** — custom chunking settings:

```
PUT my-index
{
  "mappings": {
    "properties": {
      "content": {
        "type": "semantic_text",
        "inference_id": "my-openai-embeddings",
        "chunking_settings": {
          "strategy": "sentence",
          "max_chunk_size": 250,
          "sentence_overlap": 1
        }
      }
    }
  }
}
```

### Integration Flow Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 480">
  <text x="450" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Embedding Model Integration Flow (svg_diagram)</text>

  <rect x="40" y="70" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="140" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Raw Document</text>
  <text x="140" y="113" text-anchor="middle" font-size="11" fill="#555">(text field)</text>

  <rect x="340" y="70" width="220" height="60" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="2" />
  <text x="450" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">semantic_text field</text>
  <text x="450" y="113" text-anchor="middle" font-size="11" fill="#555">triggers inference_id</text>

  <rect x="660" y="70" width="200" height="60" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="760" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Inference Endpoint</text>
  <text x="760" y="113" text-anchor="middle" font-size="11" fill="#555">(OpenAI / ELSER / Eland...)</text>

  <line x1="240" y1="100" x2="335" y2="100" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />
  <line x1="560" y1="100" x2="655" y2="100" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="660" y="180" width="200" height="60" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="2" />
  <text x="760" y="205" text-anchor="middle" font-size="13" fill="#1a1a1a">Model Execution</text>
  <text x="760" y="223" text-anchor="middle" font-size="11" fill="#555">on ML node or remote API</text>

  <line x1="760" y1="130" x2="760" y2="175" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="340" y="180" width="220" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="450" y="205" text-anchor="middle" font-size="13" fill="#1a1a1a">Chunking</text>
  <text x="450" y="223" text-anchor="middle" font-size="11" fill="#555">splits long text into passages</text>

  <line x1="655" y1="210" x2="565" y2="210" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="40" y="180" width="200" height="60" rx="8" fill="#f3e8fd" stroke="#a142f4" stroke-width="2" />
  <text x="140" y="205" text-anchor="middle" font-size="13" fill="#1a1a1a">Vector Output</text>
  <text x="140" y="223" text-anchor="middle" font-size="11" fill="#555">dense_vector or sparse_vector</text>

  <line x1="335" y1="210" x2="245" y2="210" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="40" y="290" width="820" height="60" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="450" y="315" text-anchor="middle" font-size="13" fill="#1a1a1a">Stored in Lucene index (HNSW graph for dense, rank features for sparse)</text>
  <text x="450" y="333" text-anchor="middle" font-size="11" fill="#555">alongside original text field</text>

  <line x1="140" y1="240" x2="140" y2="285" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />

  <rect x="200" y="390" width="500" height="60" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="2" />
  <text x="450" y="415" text-anchor="middle" font-size="13" fill="#1a1a1a">Query time: semantic query re-embeds query text</text>
  <text x="450" y="433" text-anchor="middle" font-size="11" fill="#555">via same inference_id, performs ANN/similarity search</text>

  <line x1="450" y1="350" x2="450" y2="385" stroke="#666" stroke-width="2" marker-end="url(#arrow)" />

  </svg>

### Task Types Supported by `_inference`

| Task Type | Purpose | Typical Field Storage |
|---|---|---|
| `text_embedding` | Dense vector generation | `dense_vector` |
| `sparse_embedding` | Sparse vector generation (e.g., ELSER) | `sparse_vector` |
| `rerank` | Reordering candidate results by relevance | N/A (scoring only) |
| `completion` | Text generation / chat completion | N/A |
| `chat_completion` | Streaming conversational completion | N/A |

### Choosing Between Approaches

**Key Points**
- **`semantic_text`** is recommended for most use cases: simpler mappings, automatic chunking, no manual embedding calls in application code.
- **Manual `dense_vector` + explicit `_inference` calls** suit cases needing precise control over chunking logic, custom vector post-processing, hybrid scoring formulas, or when embeddings are generated by a pipeline entirely outside Elasticsearch (e.g., bulk-precomputed offline).
- **Eland-deployed models** are appropriate when data residency, licensing, or cost constraints rule out calling an external hosted embedding API — the model runs entirely inside the cluster's ML nodes.
- **Hosted third-party services** (OpenAI, Cohere, etc.) are appropriate when the team wants to avoid managing ML node capacity for embedding inference, at the cost of per-call API latency and cost, and sending data to a third party.

### Operational Considerations

**Key Points**
- ML nodes running self-hosted models consume dedicated CPU/memory resources; `num_allocations` and `num_threads` in the trained model deployment control throughput and must be sized against expected indexing/query load. [Inference] Under-provisioning allocations is a common cause of inference queueing under load, based on how the trained models API documents allocation/thread scaling.
- Third-party API-based endpoints introduce network latency and are subject to the provider's own rate limits; bulk ingestion of large corpora can hit these limits and may require throttling or batching indexing requests.
- Changing the `inference_id` referenced by an existing `semantic_text` field does not retroactively re-embed already-indexed documents; a reindex is required to apply a new model to existing data.
- API keys and credentials configured in `service_settings` for hosted providers are stored within Elasticsearch's secure settings; rotating keys requires updating the inference endpoint configuration.

### Common Pitfalls

**Key Points**
- Mixing documents embedded with different model versions or different models entirely in the same field/index, which breaks the geometric consistency vector similarity depends on.
- Forgetting that `semantic_text` requires an ML node (or valid third-party credentials) to be available at index time; ingestion fails or queues if the inference endpoint is unhealthy.
- Assuming Hugging Face models are automatically compatible with Eland import — architecture must be among Elastic's tested/supported list, or import can fail or produce a broken deployment.
- Not accounting for chunk-level scoring semantics: a document can be returned as relevant because of a single strong-matching chunk, even if most of the document is unrelated to the query.

**Related Topics**
- Vector Search and Semantic Search — Dense vector (`dense_vector`) field configuration and HNSW parameters
- Vector Search and Semantic Search — ELSER sparse embeddings and rank features
- Vector Search and Semantic Search — Hybrid search (combining `semantic` and lexical `match` queries with RRF)
- Vector Search and Semantic Search — Reranking with the `rerank` inference task type
- Vector Search and Semantic Search — `knn` query vs. `semantic_text`-based semantic query
- Machine Learning — Trained models API and ML node resource planning
- Machine Learning — Eland model compatibility and TorchScript tracing details