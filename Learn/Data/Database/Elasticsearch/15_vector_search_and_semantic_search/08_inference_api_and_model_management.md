## Inference API and Model Management

### Overview

The `_inference` API is Elasticsearch's unified interface for deploying, managing, and invoking machine learning models — both Elastic's own (ELSER, E5) and third-party services (OpenAI, Cohere, Azure AI Studio, Hugging Face, Google Vertex AI, Amazon Bedrock, and others). It replaces the older pattern of manually managing trained models via `_ml/trained_models` for most semantic search and NLP use cases, centralizing inference behind a consistent endpoint abstraction usable in ingest pipelines, search queries, and reranking.

### Core Concepts

**Key Points**
- An **inference endpoint** is a named, configured connection to a specific model and service — created once, then referenced by ID everywhere inference is needed (ingest pipelines, `sparse_vector`/`semantic_text`/`text_embedding` queries, rerankers).
- Endpoints encapsulate a **task type** (`sparse_embedding`, `text_embedding`, `rerank`, `completion`, `chat_completion`), a **service** (e.g., `elser`, `openai`, `cohere`, `elasticsearch`), and **service_settings** specific to that provider.
- For third-party services, credentials (API keys) are stored securely in the endpoint configuration rather than passed per-request.
- The API abstracts away provider-specific request/response shapes, so switching providers generally means changing the endpoint definition, not application code.

### Creating an Inference Endpoint

**Example**

ELSER (Elastic-hosted, no external API key needed):

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

Third-party dense embedding model (OpenAI):

```
PUT _inference/text_embedding/my-openai-endpoint
{
  "service": "openai",
  "service_settings": {
    "api_key": "<api_key>",
    "model_id": "text-embedding-3-small"
  }
}
```

Cohere reranker:

```
PUT _inference/rerank/my-cohere-rerank
{
  "service": "cohere",
  "service_settings": {
    "api_key": "<api_key>",
    "model_id": "rerank-english-v3.0"
  }
}
```

Elastic's own E5 multilingual dense model, hosted within the cluster (no external key):

```
PUT _inference/text_embedding/my-e5-endpoint
{
  "service": "elasticsearch",
  "service_settings": {
    "num_allocations": 1,
    "num_threads": 1,
    "model_id": ".multilingual-e5-small"
  }
}
```

### Task Types

| Task Type | Purpose | Example Services |
|---|---|---|
| `sparse_embedding` | Produces sparse term-weight vectors | `elser` |
| `text_embedding` | Produces dense float vectors | `openai`, `cohere`, `azureopenai`, `elasticsearch` (E5), `huggingface` |
| `rerank` | Reorders a candidate document list by relevance to a query | `cohere`, `elasticsearch` |
| `completion` | Single-turn text generation | `openai`, `azureopenai`, `amazonbedrock` |
| `chat_completion` | Multi-turn conversational generation | `openai`, `anthropic` (via compatible services) |

[Unverified] The exact roster of supported services and task-type combinations expands frequently with new Elasticsearch releases; current availability should be checked against the live service list in Elastic's documentation for the deployed version.

### Invoking Inference Directly

Outside of ingest/query integration, the `_inference` endpoint can be called directly for ad hoc inference:

```
POST _inference/text_embedding/my-openai-endpoint
{
  "input": "What is a distributed search engine?"
}
```

This returns the raw embedding vector(s), useful for debugging, offline batch processing, or building custom application logic outside Elasticsearch's built-in query types.

### Managing Endpoints

**Example**

List all configured endpoints:

```
GET _inference/
```

List endpoints of a specific task type:

```
GET _inference/text_embedding/
```

Retrieve a specific endpoint's configuration:

```
GET _inference/text_embedding/my-openai-endpoint
```

Delete an endpoint:

```
DELETE _inference/text_embedding/my-openai-endpoint
```

[Inference] Deleting an endpoint that is still referenced by an active ingest pipeline or a `semantic_text` field mapping likely causes indexing/query failures referencing that endpoint; the exact error behavior should be verified against the deployed version, as validation strictness has evolved across releases.

### The `semantic_text` Field Type

`semantic_text` is a higher-level field type that wraps inference endpoint usage, removing the need to manually manage a separate `sparse_vector`/`dense_vector` field plus a custom ingest pipeline:

```
PUT my-index
{
  "mappings": {
    "properties": {
      "content": {
        "type": "semantic_text",
        "inference_id": "my-elser-endpoint"
      }
    }
  }
}
```

Indexing a document automatically triggers inference on the `content` field at write time — no explicit pipeline required:

```
PUT my-index/_doc/1
{
  "content": "Elasticsearch integrates inference directly into indexing and search."
}
```

Querying uses the standard `semantic_text`-compatible `match` query rather than a dedicated `sparse_vector`/`text_expansion` syntax:

```
GET my-index/_search
{
  "query": {
    "match": {
      "content": "how are models integrated into indexing"
    }
  }
}
```

[Inference] `semantic_text` internally selects sparse or dense storage/query mechanics depending on the referenced endpoint's task type, so the same query DSL pattern works regardless of whether the backing model is ELSER or a dense embedding model — this abstraction is the field type's primary value proposition, though the precise internal storage layout is an implementation detail not required for typical usage.

### ML Node Resource Management

**Key Points**
- Elastic-hosted models (ELSER, E5) run as deployments on dedicated ML nodes, consuming memory proportional to model size × `num_allocations`.
- `num_allocations` and `num_threads` can be adjusted post-deployment via the trained model deployment update API without redeploying:

```
POST _ml/trained_models/.elser_model_2/deployment/_update
{
  "number_of_allocations": 2
}
```

- Autoscaling (on Elastic Cloud / Elastic Cloud Serverless) can adjust ML node capacity based on inference load, subject to deployment tier limits. [Unverified — availability and behavior of autoscaling differ across Cloud, self-managed, and serverless deployment models.]
- Third-party service endpoints (OpenAI, Cohere, etc.) do not consume Elasticsearch ML node capacity — inference runs on the provider's infrastructure, and Elasticsearch only manages the API call and credentials.

### Rate Limiting and Retries

- Third-party inference endpoints are subject to the external provider's own rate limits; Elasticsearch surfaces provider errors (e.g., HTTP 429) back through the API rather than silently retrying indefinitely.
- Some services expose a `rate_limit` setting in `service_settings` to throttle outbound request rate from Elasticsearch's side, reducing the likelihood of hitting provider-side limits during bulk ingest.
- Bulk ingestion against a `semantic_text` field backed by a rate-limited third-party service can become a throughput bottleneck; batching and backoff strategies are recommended for large corpora. [Inference — the specific throughput ceiling depends on the provider's plan tier and Elasticsearch's internal batching behavior for the given version.]

### Architecture Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 380">
  <text x="400" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Inference API Endpoint Architecture (svg_diagram)</text>

  <rect x="300" y="60" width="200" height="55" rx="6" fill="#e8f0fe" stroke="#4a86e8" stroke-width="2" />
  <text x="400" y="83" text-anchor="middle" font-size="13" fill="#1a1a1a">_inference API</text>
  <text x="400" y="101" text-anchor="middle" font-size="11" fill="#555">unified endpoint registry</text>

  <line x1="360" y1="115" x2="180" y2="175" stroke="#888" stroke-width="2" marker-end="url(#arrow2)" />
  <line x1="400" y1="115" x2="400" y2="175" stroke="#888" stroke-width="2" marker-end="url(#arrow2)" />
  <line x1="440" y1="115" x2="620" y2="175" stroke="#888" stroke-width="2" marker-end="url(#arrow2)" />

  <rect x="60" y="175" width="240" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="180" y="200" text-anchor="middle" font-size="13" fill="#1a1a1a">Elastic-hosted (ELSER, E5)</text>
  <text x="180" y="218" text-anchor="middle" font-size="11" fill="#555">runs on local ML node</text>

  <rect x="280" y="175" width="240" height="60" rx="6" fill="#fef3e0" stroke="#e69138" stroke-width="2" />
  <text x="400" y="200" text-anchor="middle" font-size="13" fill="#1a1a1a">Elasticsearch service</text>
  <text x="400" y="218" text-anchor="middle" font-size="11" fill="#555">e.g. E5 via ML node</text>

  <rect x="500" y="175" width="240" height="60" rx="6" fill="#f3e8fd" stroke="#8e44ad" stroke-width="2" />
  <text x="620" y="200" text-anchor="middle" font-size="13" fill="#1a1a1a">Third-party (OpenAI, Cohere)</text>
  <text x="620" y="218" text-anchor="middle" font-size="11" fill="#555">external API call</text>

  <line x1="180" y1="235" x2="180" y2="290" stroke="#888" stroke-width="2" marker-end="url(#arrow2)" />
  <line x1="620" y1="235" x2="620" y2="290" stroke="#888" stroke-width="2" marker-end="url(#arrow2)" />

  <rect x="60" y="290" width="240" height="55" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="2" />
  <text x="180" y="313" text-anchor="middle" font-size="13" fill="#1a1a1a">semantic_text / sparse_vector</text>
  <text x="180" y="331" text-anchor="middle" font-size="11" fill="#555">stored in index</text>

  <rect x="500" y="290" width="240" height="55" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="2" />
  <text x="620" y="313" text-anchor="middle" font-size="13" fill="#1a1a1a">Credentials + rate limit</text>
  <text x="620" y="331" text-anchor="middle" font-size="11" fill="#555">managed per endpoint</text>

  </svg>

### Common Pitfalls

- Hardcoding API keys directly in application code instead of relying on the endpoint's stored credentials — defeats the centralization benefit of the API.
- Deleting or renaming an inference endpoint still referenced by live index mappings or ingest pipelines, breaking indexing/search without an obvious error trail.
- Assuming all task types are supported by all services — not every provider integration supports `rerank` or `chat_completion`, for instance.
- Under-provisioning `num_allocations` for Elastic-hosted models under concurrent load, causing request queuing and elevated latency.
- Mixing dimensions/models on the same `dense_vector` field across re-indexing operations without accounting for embedding incompatibility between model versions.

### Next Steps

- Reranking with the `rerank` task type and `text_similarity_reranker` retriever
- Building multi-stage retrieval pipelines (retrieve → rerank → generate)
- Cost and latency tradeoffs: self-hosted (ELSER/E5) vs. third-party API-based embeddings
- Managing model versioning and re-embedding strategies during migrations
- Monitoring inference endpoint usage and errors via cluster stats APIs