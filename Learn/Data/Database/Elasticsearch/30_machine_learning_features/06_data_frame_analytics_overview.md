## Data Frame Analytics Overview

### Overview

Data frame analytics is Elasticsearch's framework for running batch machine learning analyses — outlier detection, regression, and classification — over a data frame constructed from one or more source indices. Unlike anomaly detection jobs, which operate continuously over time-ordered data via a datafeed, data frame analytics jobs run once (or on demand) over a bounded dataset, producing a destination index containing the original data enriched with analysis results.

The term "data frame" here refers to a tabular, row-per-entity structure analogous to a pandas or R data frame — each row typically represents an entity (a document, a user, a session) with a fixed set of feature columns, rather than a raw time-ordered event stream.

### Analysis Types

| Type | Purpose | Output |
|---|---|---|
| **Outlier detection** | Unsupervised identification of anomalous data points within a static dataset | An outlier score per document |
| **Regression** | Supervised prediction of a continuous numeric value | A predicted numeric value per document |
| **Classification** | Supervised prediction of a categorical label | A predicted class (and often class probabilities) per document |

Regression and classification are **supervised** — they require a training dataset with a known target field (the value being predicted) so the model can learn the relationship between features and the target before being applied to unseen data. Outlier detection is **unsupervised** — no labeled target is required; it identifies points that are statistically dissimilar from the bulk of the dataset.

### Job Configuration Structure

A data frame analytics job configuration includes:

- **`source`** — the index or indices providing input data, optionally filtered by a query.
- **`dest`** — the destination index where results are written (created automatically if it doesn't exist).
- **`analysis`** — the analysis type and its type-specific parameters (e.g., `dependent_variable` for regression/classification).
- **`analyzed_fields`** — which fields to include or exclude from the analysis, often used to exclude identifier fields or the target field from being treated as a feature.
- **`model_memory_limit`** — a cap on memory usage during training, similar in spirit to the equivalent setting on anomaly detection jobs.

### Example: Regression Job

```
PUT _ml/data_frame/analytics/house-price-regression
{
  "source": {
    "index": "housing-data"
  },
  "dest": {
    "index": "housing-data-predictions"
  },
  "analysis": {
    "regression": {
      "dependent_variable": "sale_price",
      "training_percent": 80
    }
  }
}
```

This job trains on 80% of the `housing-data` index (holding out 20% for validation), learning to predict `sale_price` from the other available fields, and writes predictions alongside original data into `housing-data-predictions`.

### Example: Outlier Detection Job

```
PUT _ml/data_frame/analytics/transaction-outliers
{
  "source": {
    "index": "transactions"
  },
  "dest": {
    "index": "transactions-outliers"
  },
  "analysis": {
    "outlier_detection": {
      "n_neighbors": 20,
      "method": "lof"
    }
  }
}
```

No `dependent_variable` is needed here, since outlier detection does not predict a labeled target — it scores each document by how dissimilar it is from its neighbors in feature space.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 260">
  <text x="400" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Data Frame Analytics Job Flow (svg_diagram)</text>

  <rect x="40" y="70" width="180" height="60" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="130" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">Source index</text>
  <text x="130" y="112" text-anchor="middle" font-size="11" fill="#555">(feature fields)</text>

  <line x1="220" y1="100" x2="290" y2="100" stroke="#999" stroke-width="1.5" marker-end="url(#arr6)" />

  <rect x="295" y="55" width="210" height="90" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="400" y="80" text-anchor="middle" font-size="12" fill="#333">Data frame analytics job</text>
  <text x="400" y="98" text-anchor="middle" font-size="10" fill="#777">outlier detection /</text>
  <text x="400" y="113" text-anchor="middle" font-size="10" fill="#777">regression / classification</text>
  <text x="400" y="128" text-anchor="middle" font-size="10" fill="#777">runs once, batch mode</text>

  <line x1="505" y1="100" x2="575" y2="100" stroke="#999" stroke-width="1.5" marker-end="url(#arr6)" />

  <rect x="580" y="70" width="190" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="675" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">Destination index</text>
  <text x="675" y="112" text-anchor="middle" font-size="11" fill="#555">original + predictions/scores</text>

  <text x="400" y="185" text-anchor="middle" font-size="12" fill="#555">Unlike anomaly detection, no datafeed is involved —</text>
  <text x="400" y="203" text-anchor="middle" font-size="12" fill="#555">the job reads a bounded source dataset once and writes</text>
  <text x="400" y="221" text-anchor="middle" font-size="12" fill="#555">enriched results to a new destination index.</text>
</svg>

### Feature Engineering and Field Selection

Data frame analytics automatically infers which fields are usable as features based on their mapped type (numeric, boolean, and certain text/keyword fields are generally eligible), but `analyzed_fields` allows explicit control:

```
"analyzed_fields": {
  "includes": ["sqft", "bedrooms", "bathrooms", "zip_code"],
  "excludes": ["listing_id", "agent_notes"]
}
```

Excluding identifier fields (like `listing_id`) prevents the model from spuriously treating an arbitrary ID as a predictive feature, which would not generalize to new data.

### Training, Validation, and `training_percent`

For supervised analyses (regression, classification), `training_percent` controls what fraction of the source data is used to train the model, with the remainder held out for validation. Documents used only for validation still receive predictions in the destination index but are flagged (via an internal field) as not having contributed to training, allowing evaluation of model accuracy against known-but-withheld ground truth.

### Evaluating Model Performance

The `_evaluate` API can be run against a data frame analytics job's results to compute standard performance metrics appropriate to the analysis type:

- **Regression** — metrics such as mean squared error and R-squared.
- **Classification** — metrics such as accuracy, precision, recall, and confusion matrix values, typically computed per class.
- **Outlier detection** — if ground-truth labels exist for evaluation purposes (unusual for a genuinely unsupervised use case, but possible in benchmarking scenarios), precision/recall-style metrics against known outliers can be computed.

### Feature Importance

Regression and classification jobs can optionally compute feature importance values (based on SHAP — SHapley Additive exPlanations) for each prediction, indicating which input fields contributed most to a given document's predicted value. This is configured via `num_top_feature_importance_values` in the analysis configuration and adds interpretability to otherwise opaque model output.

### Job Lifecycle

Data frame analytics jobs move through states: `stopped` → `starting` → `started`/`reindexing`/`analyzing` → `stopped` (on completion), tracked via the job's `_stats` endpoint. Unlike anomaly detection jobs, there is no persistent "open" state consuming ongoing resources between runs — once complete, the job's results live in the destination index and the job itself is idle until manually restarted (e.g., against refreshed source data).

### Data Frame Analytics vs. Anomaly Detection

| Aspect | Anomaly Detection | Data Frame Analytics |
|---|---|---|
| Execution mode | Continuous, via datafeed | Batch, run once (or re-run manually) |
| Data shape | Time-ordered event stream | Bounded, row-per-entity dataset |
| Typical question | "Is this different from the recent past/peers?" | "What is the predicted value/class/outlier score for this row?" |
| Output location | Job results (anomaly records/buckets) | A new destination index |

### Key Points

- Data frame analytics runs batch ML jobs (outlier detection, regression, classification) over a bounded, row-per-entity dataset.
- Regression and classification are supervised and require a `dependent_variable`; outlier detection is unsupervised.
- Results are written to a destination index alongside the original document data.
- `_evaluate` computes standard performance metrics; feature importance (SHAP-based) adds prediction interpretability.
- Distinct from anomaly detection jobs, which run continuously over time-series data via a datafeed.

### Related Topics

- Outlier detection algorithms: LOF and DBSCAN-based methods
- Regression and classification model evaluation metrics
- Feature importance and SHAP values in Elasticsearch ML
- Anomaly detection jobs and datafeeds
- Inference processors and using trained models in ingest pipelines
- Model deployment and the `_infer` API