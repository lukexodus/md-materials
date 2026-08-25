## Inference Processor

The `inference` processor runs a trained machine learning model against a document's fields during ingestion, adding the model's prediction — a classification, regression value, embedding vector, or NLP annotation — to the document before it's indexed. The model itself is either uploaded/trained inside Elasticsearch's machine learning module or deployed via an external service integration.

### How It Fits Into an Ingest Pipeline

```mermaid
flowchart LR
    A[Raw document<br/>text field] --> B[Ingest pipeline]
    B --> C[inference processor]
    C --> D[Trained ML model<br/>deployed in cluster]
    D --> E[Prediction written<br/>to target_field]
    E --> F[Indexed into Elasticsearch]
```

### Prerequisites

Before an `inference` processor can run, a trained model must already exist and typically be deployed (started) in the cluster:

- A model trained via Elasticsearch's own data frame analytics (classification, regression, outlier detection).
- A model imported via Eland (e.g. a Hugging Face transformer for NLP tasks like NER, text classification, or embeddings).
- A model backed by an external inference service configured through the `_inference` API (e.g. a hosted LLM or embedding provider), referenced by its inference endpoint ID.

```json
GET _ml/trained_models/my_model/_stats
```

confirms the model is present and, for models requiring allocation, that it has been deployed and has active allocations.

### Basic Syntax

```json
PUT _ingest/pipeline/classify_reviews
{
  "description": "Classify review sentiment using a trained model",
  "processors": [
    {
      "inference": {
        "model_id": "sentiment_model",
        "target_field": "ml.sentiment",
        "field_map": {
          "review_text": "text_field"
        }
      }
    }
  ]
}
```

- `model_id` — ID of the trained model or inference endpoint to invoke. Required.
- `target_field` — where the prediction results are written. Defaults to `ml.inference.<model_id>` if not specified.
- `field_map` — maps document field names to the field names the model expects as input. Required when the document's field names don't match the model's expected input names.

### Testing the Pipeline

```json
POST _ingest/pipeline/classify_reviews/_simulate
{
  "docs": [
    {
      "_source": {
        "review_text": "The battery life on this laptop is disappointing."
      }
    }
  ]
}
```

**Output**

```json
{
  "docs": [
    {
      "doc": {
        "_source": {
          "review_text": "The battery life on this laptop is disappointing.",
          "ml": {
            "sentiment": {
              "predicted_value": "negative",
              "prediction_probability": 0.91
            }
          }
        }
      }
    }
  ]
}
```

Exact output shape depends heavily on model type — classification models return `predicted_value` and class probabilities, regression models return a numeric `predicted_value`, and NLP/embedding models return task-specific structures (e.g. `predicted_value` arrays for text embeddings). [Unverified] — field names in output vary by model task type and Elasticsearch version.

### Model Types and Output Shapes

| Model Task | Typical Output |
| --- | --- |
| Classification | `predicted_value`, `prediction_probability`, top classes |
| Regression | Single numeric `predicted_value` |
| Text embedding | Dense vector array (used with `dense_vector` fields) |
| NER (named entity recognition) | List of entities with type, start/end offsets |
| Text classification (NLP) | Label and confidence score |
| Zero-shot classification | Label and score against candidate labels |
| Fill-mask / other transformer tasks | Task-specific structured output |

### Handling Multiple Input Fields

Models trained on multiple features require `field_map` to align every expected input:

```json
{
  "inference": {
    "model_id": "churn_predictor",
    "target_field": "ml.churn",
    "field_map": {
      "customer.tenure_months": "tenure",
      "customer.monthly_charges": "monthly_charges",
      "customer.contract_type": "contract_type"
    }
  }
}
```

Fields not present in `field_map` but required by the model will cause inference to fail for that document, unless the model was trained to tolerate missing features (dependent on the training configuration). [Inference]

### Chaining with Text Embedding for Semantic Search

A very common pattern: use `inference` to generate a `dense_vector` embedding from text at ingest time, then query that vector field with `knn` search.

```json
PUT _ingest/pipeline/generate_embeddings
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

The destination index must map the resulting vector field as `dense_vector` with a dimension count matching the model's output:

```json
PUT _index_template/semantic_docs_template
{
  "index_patterns": ["semantic-docs-*"],
  "template": {
    "mappings": {
      "properties": {
        "text_embedding": {
          "properties": {
            "predicted_value": {
              "type": "dense_vector",
              "dims": 384
            }
          }
        }
      }
    }
  }
}
```

Dimension count (384 above) is model-specific and must match exactly, or indexing will fail. [Unverified] — confirm the exact output path and dimensionality for the specific model version in use, since target field structure has changed across Elasticsearch releases.

### Using `semantic_text` as a Simpler Alternative

For many text-embedding use cases, the `semantic_text` field type paired with an inference endpoint abstracts away manual `inference` processor configuration, chunking, and dimension mapping — Elasticsearch handles embedding generation internally at index time. The `inference` processor remains the lower-level, more configurable option when explicit control over the pipeline step, custom field mapping, or non-text model types is needed.

### Conditional Execution

Run inference only when relevant, to avoid unnecessary compute on documents that don't need it:

```json
{
  "inference": {
    "model_id": "sentiment_model",
    "target_field": "ml.sentiment",
    "field_map": {
      "review_text": "text_field"
    },
    "if": "ctx.review_text != null && ctx.review_text.length() > 0"
  }
}
```

### Error Handling

Inference failures (missing model, model not deployed, malformed input, allocation exhausted) can be caught with `on_failure` rather than rejecting the whole document:

```json
{
  "inference": {
    "model_id": "sentiment_model",
    "target_field": "ml.sentiment",
    "field_map": {
      "review_text": "text_field"
    },
    "on_failure": [
      {
        "set": {
          "field": "ml.sentiment_error",
          "value": "{{_ingest.on_failure_message}}"
        }
      }
    ]
  }
}
```

- `ignore_failure` — alternative simpler option to silently skip the processor on error without custom handling.

### Performance and Capacity Notes

- Unlike `geoip`, which is a pure local lookup, `inference` invokes a deployed model that consumes allocated ML node resources (CPU/memory, and threads per allocation); high-throughput ingestion through an `inference` processor can become a bottleneck if the model isn't scaled with sufficient allocations and threads.
- Increasing `number_of_allocations` and `threads_per_allocation` on the model deployment can improve throughput, at the cost of more ML node resource consumption. [Unverified] — exact scaling behavior and defaults vary by version and node sizing.
- For models backed by external inference services (rather than in-cluster deployment), latency and rate limits are governed by the external provider rather than local cluster resources.
- Batch/bulk ingestion through pipelines with `inference` processors should be load-tested before production rollout, since per-document model invocation cost is typically much higher than processors like `grok` or `set`. [Inference]

### Diagram: Inference Processor in a Semantic Search Pipeline (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260">
<text x="380" y="24" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="bold" fill="#1a1a1a">Inference Processor in a Semantic Search Pipeline (svg_diagram)</text>
<rect x="20" y="70" width="180" height="80" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
<text x="110" y="100" text-anchor="middle" font-family="sans-serif" font-size="13" fill="#1a1a1a">content</text>
<text x="110" y="120" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#333">"battery life is..."</text>
<line x1="200" y1="110" x2="270" y2="110" stroke="#666" stroke-width="1.5" marker-end="url(#arrow2)" />
<rect x="270" y="60" width="180" height="100" rx="8" fill="#fef7e0" stroke="#f9a825" stroke-width="1.5" />
<text x="360" y="88" text-anchor="middle" font-family="sans-serif" font-size="13" fill="#1a1a1a">inference</text>
<text x="360" y="106" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#333">processor</text>
<text x="360" y="124" text-anchor="middle" font-family="monospace" font-size="10" fill="#555">model_id: minilm-l6-v2</text>
<text x="360" y="140" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#555">(ML node allocation)</text>
<line x1="450" y1="110" x2="520" y2="110" stroke="#666" stroke-width="1.5" marker-end="url(#arrow2)" />
<rect x="520" y="60" width="220" height="100" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
<text x="630" y="85" text-anchor="middle" font-family="sans-serif" font-size="13" font-weight="bold" fill="#1a1a1a">text_embedding</text>
<text x="630" y="105" text-anchor="middle" font-family="monospace" font-size="10" fill="#333">dense_vector[384]</text>
<text x="630" y="122" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#555">indexed for knn search</text>
</svg>

### Common Pitfalls

- **Model not deployed** — a trained model that exists but hasn't been started (allocated) will cause every inference call to fail; check `_ml/trained_models/<id>/_stats` before troubleshooting the pipeline itself.
- **Mismatched `field_map`** — omitting a field the model expects, or mapping to the wrong internal name, silently produces bad predictions or outright failures depending on model tolerance.
- **Dimension mismatch on `dense_vector`** — mapping the target field with the wrong `dims` value causes indexing failures after inference has already run, wasting the compute cost.
- **Under-provisioned allocations** — a single-allocation model deployment can become a severe throughput bottleneck under bulk ingestion; this is easy to miss in testing with small document counts and only surfaces at production volume. [Inference]
- **Treating `inference` and `semantic_text` as interchangeable** — they solve overlapping problems but manage chunking, storage, and query-time behavior differently; mixing approaches inconsistently across indices complicates later query logic.

**Related Topics**

- Machine Learning — Trained model deployment and allocation scaling
- Ingest Pipelines — `semantic_text` field type vs. manual `inference` processor
- Vector search — `dense_vector` fields and `knn` queries
- Machine Learning — Data frame analytics (classification/regression training)
- Eland — Importing Hugging Face transformer models
- Ingest Pipelines — `on_failure` and `ignore_failure` error handling
- `_inference` API — external inference endpoint configuration