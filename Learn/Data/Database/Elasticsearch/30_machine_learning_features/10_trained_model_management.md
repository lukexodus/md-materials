## Trained Model Management

### Overview

Trained model management covers how Elasticsearch stores, deploys, and serves machine learning models for inference — whether those models were trained internally via data frame analytics, or imported from external sources such as PyTorch (via the eland library) for NLP tasks. A trained model is a reusable artifact that can be applied to new documents at index time (via an ingest pipeline processor) or on demand (via the `_infer` API), separate from the one-time batch process that originally produced it.

### Sources of Trained Models

- **Internally trained models** — the output of a completed data frame analytics regression or classification job. These are automatically stored as trained model artifacts and can be reused independently of the original job.
- **Imported models** — models trained outside Elasticsearch (commonly transformer-based NLP models from Hugging Face) uploaded via the `eland` Python client, which handles the conversion into a format Elasticsearch can serve.
- **Built-in/preconfigured models** — certain models, such as a language identification model, are shipped with Elasticsearch and available without any import step.

### The Trained Model Registry

Trained models are stored as documents in internal system indices and managed through the trained model APIs:

- **`PUT _ml/trained_models/<model_id>`** — creates/imports a trained model.
- **`GET _ml/trained_models`** — lists available trained models and their metadata.
- **`GET _ml/trained_models/<model_id>/_stats`** — retrieves usage and deployment statistics.
- **`DELETE _ml/trained_models/<model_id>`** — removes a trained model, provided it is not currently deployed or referenced by an active pipeline.

Each trained model has a `model_id`, an associated `model_type` (e.g., `tree_ensemble` for data frame analytics outputs, `pytorch` for imported NLP models), and input/output field mappings describing what the model expects and produces.

### Deploying a Model

For models that require active inference serving (notably NLP/PyTorch models, which are computationally heavier), a **deployment** step allocates the model into memory across ML nodes before it can serve inference requests efficiently:

```
POST _ml/trained_models/my-ner-model/deployment/_start
{
  "number_of_allocations": 2,
  "threads_per_allocation": 1
}
```

- **`number_of_allocations`** — how many independent copies of the model are deployed, effectively controlling inference throughput/concurrency.
- **`threads_per_allocation`** — threading used per allocation, affecting per-request latency versus resource consumption tradeoffs.

Tree-based models from data frame analytics jobs are generally lightweight enough to be used directly via an ingest pipeline without requiring an explicit deployment step, whereas transformer-based NLP models typically require deployment due to their resource footprint. [Inference: exact deployment requirements per model type can shift across versions as serving infrastructure evolves — verify current behavior before assuming a given model type doesn't need deployment.]

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 280">
  <text x="400" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Trained Model Lifecycle (svg_diagram)</text>

  <rect x="30" y="60" width="160" height="55" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="110" y="83" text-anchor="middle" font-size="11" fill="#1a1a1a">Data frame analytics</text>
  <text x="110" y="98" text-anchor="middle" font-size="11" fill="#1a1a1a">job (trained)</text>

  <rect x="30" y="130" width="160" height="55" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="110" y="153" text-anchor="middle" font-size="11" fill="#1a1a1a">Imported NLP model</text>
  <text x="110" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">(via eland)</text>

  <line x1="190" y1="87" x2="250" y2="120" stroke="#999" stroke-width="1.5" marker-end="url(#arr7)" />
  <line x1="190" y1="157" x2="250" y2="125" stroke="#999" stroke-width="1.5" marker-end="url(#arr7)" />

  <rect x="255" y="95" width="170" height="55" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="340" y="118" text-anchor="middle" font-size="11" fill="#333">Trained model registry</text>
  <text x="340" y="135" text-anchor="middle" font-size="10" fill="#777">(model_id, model_type)</text>

  <line x1="425" y1="122" x2="490" y2="122" stroke="#999" stroke-width="1.5" marker-end="url(#arr7)" />

  <rect x="495" y="60" width="140" height="55" rx="6" fill="#fff8e1" stroke="#f9a825" stroke-width="2" />
  <text x="565" y="83" text-anchor="middle" font-size="11" fill="#1a1a1a">Deployment</text>
  <text x="565" y="98" text-anchor="middle" font-size="10" fill="#777">(NLP/pytorch models)</text>

  <rect x="495" y="130" width="140" height="55" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="565" y="153" text-anchor="middle" font-size="11" fill="#1a1a1a">Direct pipeline use</text>
  <text x="565" y="168" text-anchor="middle" font-size="10" fill="#777">(tree ensemble models)</text>

  <line x1="635" y1="87" x2="695" y2="122" stroke="#999" stroke-width="1.5" marker-end="url(#arr7)" />
  <line x1="635" y1="157" x2="695" y2="125" stroke="#999" stroke-width="1.5" marker-end="url(#arr7)" />

  <rect x="700" y="95" width="80" height="55" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="2" />
  <text x="740" y="118" text-anchor="middle" font-size="10" fill="#1a1a1a">Inference</text>
  <text x="740" y="133" text-anchor="middle" font-size="10" fill="#1a1a1a">results</text>

  </svg>

### Using a Trained Model in an Ingest Pipeline

The `inference` processor applies a trained model to documents as they are indexed:

```
PUT _ingest/pipeline/classify-support-tickets
{
  "processors": [
    {
      "inference": {
        "model_id": "churn-classification-model",
        "target_field": "ml.churn_prediction",
        "field_map": {
          "customer_tenure_days": "tenure",
          "monthly_spend": "spend"
        }
      }
    }
  ]
}
```

The `field_map` allows renaming source document fields to match the field names the model was trained on, useful when the ingest-time document schema differs from the original training data schema.

### On-Demand Inference via `_infer`

Rather than embedding inference into the indexing pipeline, the `_infer` API allows ad hoc, synchronous inference requests against a deployed model:

```
POST _ml/trained_models/my-ner-model/_infer
{
  "docs": [
    { "text_field": "Elasticsearch was founded in Amsterdam." }
  ]
}
```

This pattern is common for NLP use cases such as named entity recognition, text classification, or generating embeddings for semantic search, where inference is triggered by application logic rather than automatically during document ingestion.

### Model Aliases

A **model alias** provides an indirection layer, allowing a pipeline or application to reference a stable name (e.g., `production-churn-model`) that can be repointed to a newer model version without modifying every pipeline or query that references it:

```
POST _ml/trained_models/churn-model-v2/model_aliases/production-churn-model
```

This supports common MLOps patterns such as blue-green model rollout, where a new model version is validated before the alias is atomically switched over.

### Resource Considerations

- Deployed NLP models consume dedicated memory on ML nodes for the duration of their deployment; multiple concurrent deployments compete for available ML node capacity.
- `number_of_allocations` and `threads_per_allocation` should be tuned based on expected inference throughput and available hardware, particularly CPU core count. [Inference: precise tuning guidance is hardware- and model-size-dependent, and generally requires load testing for a specific deployment.]
- Stopping a deployment (`_stop`) frees its allocated resources but does not delete the underlying trained model artifact, which remains available for redeployment.

### Model Compatibility and Versioning

Imported models must be converted into a format compatible with Elasticsearch's inference runtime (typically via `eland`), and not all model architectures are supported — primarily transformer-based architectures for common NLP tasks (text classification, NER, text embedding, question answering) have documented support. [Inference: the specific list of supported architectures expands over time — check current documentation before attempting to import an unfamiliar model type.]

### Key Points

- Trained models can originate from internal data frame analytics jobs or be imported externally (typically NLP models via `eland`).
- Tree-based models are generally usable directly in ingest pipelines; NLP/pytorch models typically require an explicit deployment step.
- The `inference` ingest processor applies models at index time; the `_infer` API supports on-demand inference.
- Model aliases decouple a stable reference name from a specific model version, supporting safe rollout of updated models.
- Deployment resource settings (`number_of_allocations`, `threads_per_allocation`) govern inference throughput and resource consumption.

### Related Topics

- The `inference` ingest processor and `field_map` configuration
- Importing NLP models with `eland`
- Semantic search using text embedding models
- Data frame analytics regression/classification job output
- ML node sizing and resource planning
- Model aliases and blue-green deployment patterns