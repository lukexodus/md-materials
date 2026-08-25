## Learning to Rank (LTR)

### Overview

Learning to Rank applies machine learning models — trained on historical relevance judgments — to reorder search results at query time, rather than relying solely on hand-tuned relevance formulas like BM25 combined with manual boosts. In the Elasticsearch ecosystem, this is implemented through the **Elasticsearch Learning to Rank plugin** (an OpenSource Connections–originated plugin, not a core-shipped feature in earlier versions) and, in more recent versions, native LTR capability integrated directly into the platform. A trained ranking model is uploaded, then invoked as a rescoring step or query component that reorders an initial candidate set based on learned feature weights.

**Key Points**

- LTR operates as a **rescoring** stage on top of an initial retrieval query — it reorders a candidate set already retrieved by a standard query, rather than replacing first-stage retrieval entirely.
- Requires a **feature set** (query-time and document-time signals fed into the model) and a **trained model** (commonly gradient-boosted trees such as LambdaMART, or linear models) produced outside Elasticsearch using training data and then uploaded.
- [Unverified] The exact plugin architecture, API endpoints, and whether LTR ships as a first-party feature versus a separately installed plugin has evolved across Elasticsearch versions — implementation details here should be confirmed against the specific version in use.

### Why Rescoring Rather Than First-Stage Retrieval

Running a complex ML model against every document in a potentially massive index is computationally prohibitive at query time. LTR addresses this with a two-stage pattern:

1. **First-stage retrieval**: a standard, cheap query (BM25-based `match`/`bool` query) retrieves a candidate set — typically the top few hundred documents by conventional relevance score.
2. **Rescoring**: the trained model is applied only to this much smaller candidate set, computing a learned score per document and reordering (typically) the top N of them.

This keeps the expensive model evaluation bounded to a small window rather than the full index, making LTR tractable at production query volumes. [Inference] The size of the rescore window represents a direct tradeoff between result quality (a larger window gives the model more candidates to potentially promote into top positions) and query latency (evaluating the model against more documents costs more time) — the appropriate window size is workload-dependent rather than fixed.

===MERMAID_DIAGRAM===

flowchart LR

A[Query] --> B[First-stage retrieval: BM25 / bool query]

B --> C[Candidate set, e.g. top 200 by base score]

C --> D[LTR rescore: apply trained model]

D --> E[Reordered top N results]

E --> F[Returned to client]

### Feature Sets

A feature set defines the inputs the model was trained on — a named collection of query templates, each producing one numeric feature value per candidate document at scoring time.

**Example — defining a feature set**

```json
PUT _ltr/_featureset/article_features
{
  "featureset": {
    "features": [
      {
        "name": "title_bm25",
        "template_language": "mustache",
        "template": {
          "match": { "title": "{{query_string}}" }
        }
      },
      {
        "name": "content_bm25",
        "template_language": "mustache",
        "template": {
          "match": { "content": "{{query_string}}" }
        }
      },
      {
        "name": "pagerank",
        "template_language": "mustache",
        "template": {
          "function_score": {
            "query": { "match_all": {} },
            "field_value_factor": { "field": "pagerank" }
          }
        }
      }
    ]
  }
}
```

Each feature is itself expressed as a query (via Mustache templating, echoing the search template pattern), whose resulting score becomes one input dimension to the model. This means arbitrary relevance signals — text match scores, `rank_feature` values, recency decay, click-through rate — can all be exposed as model features simply by expressing them as scoreable queries.

### Training Data and Judgment Lists

Before a model can be trained, historical relevance judgments must be collected — typically triplets of (query, document, relevance grade), where the grade reflects how relevant that document was for that query, sourced from human annotation, click-through data, or conversion signals.

- **Log-based collection**: the feature set is used to compute feature vectors for documents that appeared in past search results, logged via the `_ltr/_featureset/{name}/_addfeaturesfromset` or similar logging query mechanism, producing training rows without needing to re-derive features separately outside Elasticsearch.
- **Judgment sourcing**: grades commonly come from either explicit human relevance labeling (accurate but expensive to scale) or implicit signals like click-through rate and conversion rate (cheaper and higher volume, but noisier and subject to position bias).
- [Speculation] The relative reliability of click-based versus human-labeled judgments for a given application depends heavily on traffic volume, click behavior patterns, and how much position bias correction is applied during data processing — this is a data science consideration outside Elasticsearch itself and varies significantly by domain.

### Model Training (External to Elasticsearch)

Model training itself happens **outside** Elasticsearch, using a machine learning framework capable of learning-to-rank objectives.

- **LambdaMART** (a gradient-boosted decision tree ranking algorithm) is a commonly used model type for this style of ranking problem, implemented in libraries such as XGBoost or RankLib.
- The training process consumes the (query, document, feature vector, relevance grade) rows extracted via the feature-logging step and produces a serialized model file.
- Once trained, the model is uploaded back into Elasticsearch under the associated feature set.

**Example — uploading a trained model**

```json
PUT _ltr/_featureset/article_features/_createmodel
{
  "model": {
    "name": "article_ranking_model_v1",
    "model": {
      "type": "model/xgboost+json",
      "definition": "{ ... serialized model JSON ... }"
    }
  }
}
```

[Unverified] Exact upload endpoint paths, supported model formats, and serialization requirements vary across LTR plugin versions and should be checked against current documentation for the specific version deployed.

### Applying the Model at Query Time

Once uploaded, the model is invoked via a `rescore` (or, in some implementations, a dedicated `sltr` query) referencing the model by name and supplying query-time parameters the feature templates expect (like `query_string`).

**Example**

```json
GET /articles/_search
{
  "query": {
    "match": { "title": "distributed systems" }
  },
  "rescore": {
    "window_size": 200,
    "query": {
      "rescore_query": {
        "sltr": {
          "params": {
            "query_string": "distributed systems"
          },
          "model": "article_ranking_model_v1"
        }
      }
    }
  }
}
```

`window_size` controls how many top documents from the first-stage query are passed to the model for rescoring — directly implementing the two-stage pattern described above.

### Evaluating Model Quality

Standard information retrieval evaluation metrics are used to judge whether the trained model actually improves ranking quality over the baseline:

- **NDCG (Normalized Discounted Cumulative Gain)**: rewards placing highly relevant documents near the top of results, with logarithmic discounting for lower positions.
- **MAP (Mean Average Precision)**: averages precision at each point a relevant document is found, across queries.
- **Precision@k**: fraction of the top $k$ results that are relevant.

$$\text{DCG}_p = \sum_{i=1}^{p} \frac{2^{rel_i} - 1}{\log_2(i+1)}$$

Where $rel_i$ is the relevance grade of the document at position $i$. NDCG normalizes this against the ideal (best possible) ordering's DCG to produce a score comparable across queries with different numbers of relevant documents. Elasticsearch's Ranking Evaluation API (`_rank_eval`) can compute these metrics against a set of judged queries, providing a way to compare baseline BM25 ranking against LTR-rescored ranking on held-out judgment data.

### Practical Considerations

- **Feature engineering effort**: the quality of an LTR model is bounded by the quality and relevance of its feature set — a model trained on a small or poorly chosen feature set will not outperform a well-tuned traditional relevance formula, regardless of the sophistication of the training algorithm itself.
- **Cold-start problem**: LTR requires sufficient historical judgment data (human-labeled or click-derived) before it can be trained meaningfully, which makes it generally unsuitable for brand-new search applications without existing usage history or labeling investment.
- **Maintenance overhead**: unlike hand-tuned relevance formulas, LTR introduces an ongoing ML lifecycle — retraining as content and user behavior evolve, monitoring for model drift, and revalidating feature templates against schema changes — which is a meaningfully different operational commitment than adjusting a `function_score` boost.
- [Inference] LTR is generally most worthwhile for search applications with substantial query volume, meaningful business impact from relevance improvements, and existing infrastructure/expertise for the ML training and evaluation lifecycle — for smaller-scale or lower-stakes search use cases, the setup and maintenance cost likely exceeds the relevance gains relative to careful manual query tuning, though this threshold is organization-specific rather than a fixed rule.

### Related Topics

- `_rank_eval` API for ranking quality evaluation independent of LTR specifically
- `rank_feature`/`rank_features` fields as a lighter-weight alternative signal-boosting mechanism
- `function_score` and manual relevance tuning as the non-ML baseline approach
- Search template Mustache syntax (shared templating mechanism with LTR feature definitions)
- Click-through data collection and position bias correction techniques
- Vector search / dense retrieval as a complementary (not competing) relevance approach