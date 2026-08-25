## NLP Model Deployment

### Overview

NLP model deployment covers importing pretrained natural language processing models (typically PyTorch-based transformer models such as BERT variants) into Elasticsearch and serving them for inference — tasks like text classification, named entity recognition (NER), text embedding generation, question answering, and zero-shot classification. Unlike data-frame-analytics-produced models (structured/tabular data), NLP models operate on raw text fields and generally require more deliberate resource planning due to their size and computational cost.

### Supported NLP Task Types

| Task Type | Purpose |
| --- | --- |
| `text_classification` | Assigns a label to a text input (e.g., sentiment analysis) |
| `zero_shot_classification` | Classifies text against arbitrary candidate labels not seen during training |
| `ner` | Named entity recognition — identifies entities (people, organizations, locations) within text |
| `text_embedding` | Produces a dense vector representation of text, used for semantic search and similarity |
| `fill_mask` | Predicts masked/missing tokens within text (typically used as a pretraining task, less common as an end-use case) |
| `question_answering` | Extracts an answer span from a context passage given a question |
| `text_expansion` / sparse embedding models | Produces sparse vector representations for use with learned sparse retrieval (e.g., ELSER) |

[Unverified — exact task type list and naming may have additions/changes across versions; consult current documentation for the deployed version's complete NLP task type reference.]

### Importing a Model

External PyTorch models are imported using **Eland**, a Python client library, since Elasticsearch's model import process requires converting the model into a supported format (TorchScript) and uploading its configuration and vocabulary alongside the model weights.

```bash
eland_import_hub_model \
  --url https://my-elasticsearch-cluster:9200 \
  --hub-model-id sentence-transformers/all-MiniLM-L6-v2 \
  --task-type text_embedding \
  --start
```

This example pulls a sentence-embedding model from the Hugging Face Hub, imports it with the appropriate task type, and starts its deployment immediately via the `--start` flag. Authentication and TLS configuration flags are typically also required for secured clusters [Unverified — exact required flags depend on the deployed version's Eland client and cluster security configuration].

### Preconfigured Models

Some deployments provide built-in access to specific preconfigured models without requiring manual import — most notably **ELSER** (Elastic Learned Sparse EncodeR), Elastic's own sparse retrieval model designed for semantic search without requiring a separately hosted dense embedding model.

```json
PUT _ml/trained_models/.elser_model_2
{
  "input": {
    "field_names": ["text_field"]
  }
}
```

```json
POST _ml/trained_models/.elser_model_2/deployment/_start
{
  "number_of_allocations": 1,
  "threads_per_allocation": 1
}
```

[Unverified — exact model ID string (`.elser_model_2` or similar) and availability depend on the deployed version; consult current documentation for the correct identifier.]

### Deployment Configuration

NLP models, being generally larger and more computationally intensive than data-frame-analytics-produced tabular models, are deployed with explicit resource allocation.

```json
POST _ml/trained_models/sentence-transformers__all-minilm-l6-v2/deployment/_start
{
  "number_of_allocations": 2,
  "threads_per_allocation": 2,
  "queue_capacity": 1000
}
```

| Parameter | Purpose |
| --- | --- |
| `number_of_allocations` | Number of parallel model copies, increasing throughput for concurrent requests |
| `threads_per_allocation` | Threads used per allocation for a single inference computation, affecting per-request latency |
| `queue_capacity` | Maximum number of inference requests queued before additional requests are rejected, guarding against unbounded memory growth under load |

Increasing `number_of_allocations` generally improves throughput for concurrent request volume, while increasing `threads_per_allocation` generally reduces latency for individual requests — the appropriate balance depends on whether the workload is latency-sensitive (few large requests) or throughput-sensitive (many concurrent smaller requests) [Unverified — exact tuning guidance/trade-off behavior should be validated against the deployed version's documentation and the specific model/hardware combination].

### Using an NLP Model via Inference Processor

Once deployed, an NLP model is used the same way as a data-frame-analytics model — through an inference processor in an ingest pipeline.

```json
PUT _ingest/pipeline/generate-embeddings
{
  "processors": [
    {
      "inference": {
        "model_id": "sentence-transformers__all-minilm-l6-v2",
        "target_field": "text_embedding",
        "field_map": {
          "content": "text_field"
        }
      }
    }
  ]
}
```

```json
PUT /articles/_doc/1?pipeline=generate-embeddings
{
  "content": "Elasticsearch is a distributed search and analytics engine."
}
```

The resulting document gains a `text_embedding` field containing the model's dense vector output, which can then be indexed into a `dense_vector` field for k-NN/semantic search.

### Using an NLP Model at Query Time

Some NLP task types (notably `text_expansion`/sparse embedding models like ELSER, and dense embedding models via query-time vectorization) can also be invoked directly within a search query, rather than only at ingest time — allowing free-text queries to be embedded on the fly and compared against pre-indexed document embeddings.

```json
GET /articles/_search
{
  "query": {
    "sparse_vector": {
      "field": "text_expansion_field",
      "inference_id": ".elser_model_2",
      "query": "how does distributed search work"
    }
  }
}
```

[Unverified — exact query clause name (`sparse_vector`, `text_expansion`, or similar) and required parameters have evolved across versions; consult current documentation for the deployed version's correct syntax.]

### Zero-Shot Classification Example

```json
POST _ml/trained_models/facebook__bart-large-mnli/_infer
{
  "docs": [
    { "text_field": "The new smartphone features a faster processor and improved battery life." }
  ],
  "inference_config": {
    "zero_shot_classification": {
      "labels": ["technology", "sports", "politics", "entertainment"]
    }
  }
}
```

Zero-shot classification is notable for not requiring the model to have been trained on the specific candidate labels in advance — the model reasons about label fit based on general language understanding, making it flexible for classification tasks where labeled training data isn't readily available.

### Resource Considerations

NLP models, particularly transformer-based ones, are substantially more resource-intensive than typical tabular data frame analytics models:

- Memory footprint scales with model size (parameter count) and `number_of_allocations`
- Inference latency is generally higher per request than tabular model inference, especially for larger models
- Dedicated ML nodes (or sufficient allocated ML resources on general nodes) are commonly required for production NLP deployments, rather than relying on default/shared resource pools
- Batch inference (via the `_infer` API directly, or bulk ingest through a pipeline) is generally more resource-efficient than many small individual real-time requests, where feasible for the use case

### Common Pitfalls

- Underestimating the memory/compute requirements of transformer-based NLP models relative to lighter tabular models, leading to resource exhaustion or deployment failures
- Not setting `queue_capacity` appropriately, causing either excessive request rejection under load (too low) or unbounded memory growth (too high/unset in some configurations)
- Mismatched `field_map` entries causing the model to receive an empty or incorrectly named input field, producing degraded or nonsensical inference results
- Assuming all NLP task types support both ingest-time and query-time invocation — availability differs by task type and should be confirmed for the specific model/task combination in use
- Not monitoring deployment stats, missing early signs of latency degradation or allocation saturation under growing production load

### Diagram: NLP Model Deployment and Usage

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
\<style\>
.title { font: bold 14px sans-serif; fill: #1a1a1a; }
.label { font: 12px sans-serif; fill: #1a1a1a; }
.sub { font: 11px sans-serif; fill: #555; }
.box { fill: #eef3fb; stroke: #4a6fa5; stroke-width: 1.5; }
.boxDep { fill: #eefbee; stroke: #4a9a5a; stroke-width: 1.5; }
.arrow { stroke: #333; stroke-width: 1.5; marker-end: url(#arrow10); }
\</style\>
<text x="20" y="25" class="title">NLP Model Import, Deployment, and Usage (svg_diagram)</text>

<rect x="30" y="55" width="180" height="45" rx="4" class="box" />
<text x="120" y="82" class="label" text-anchor="middle">Hugging Face Hub model</text>
<rect x="260" y="55" width="180" height="45" rx="4" class="box" />
<text x="350" y="75" class="label" text-anchor="middle">Eland import</text>
<text x="350" y="90" class="sub" text-anchor="middle">(TorchScript conversion)</text>
<rect x="490" y="55" width="220" height="45" rx="4" class="boxDep" />
<text x="600" y="75" class="label" text-anchor="middle">Deployed model</text>
<text x="600" y="90" class="sub" text-anchor="middle">allocations + threads</text>
<line x1="210" y1="77" x2="260" y2="77" class="arrow" />
<line x1="440" y1="77" x2="490" y2="77" class="arrow" />
<rect x="130" y="160" width="220" height="55" rx="4" class="box" />
<text x="240" y="182" class="label" text-anchor="middle">Ingest-time usage</text>
<text x="240" y="198" class="sub" text-anchor="middle">inference processor in pipeline</text>
<rect x="410" y="160" width="220" height="55" rx="4" class="box" />
<text x="520" y="182" class="label" text-anchor="middle">Query-time usage</text>
<text x="520" y="198" class="sub" text-anchor="middle">sparse_vector / semantic query</text>
<line x1="600" y1="100" x2="240" y2="160" class="arrow" />
<line x1="600" y1="100" x2="520" y2="160" class="arrow" />

<text x="30" y="260" class="sub">number_of_allocations → parallel throughput</text>

<text x="30" y="280" class="sub">threads_per_allocation → per-request latency</text>

<text x="30" y="300" class="sub">queue_capacity → backpressure under load</text>

</svg>

**Related Topics**

- Trained model management — deployment lifecycle, aliases, and monitoring shared with NLP models
- Semantic search and dense/sparse vector fields
- ELSER and learned sparse retrieval concepts
- Inference processors and ingest pipeline design
- Resource planning and dedicated ML node sizing
- Hybrid search combining lexical and semantic (vector) queries