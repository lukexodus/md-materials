## Feature Importance

### Overview

Feature importance quantifies how much each input field contributed to a specific prediction made by a trained regression or classification model. Unlike a single global "this field matters most overall" ranking, Elasticsearch's implementation computes **per-document** feature importance — meaning the same field can have a different importance value for different rows, since its influence depends on that row's specific feature values relative to what the model learned.

### Why Per-Document Rather Than Global

A global feature importance ranking (common in simpler model explainability approaches) answers "which fields matter most across the whole dataset on average." Per-document feature importance answers a more granular question: "for *this specific prediction*, which fields pushed the output up or down, and by how much." This is generally more useful for:

- Explaining individual predictions to stakeholders or end users ("this customer was predicted to churn primarily because of X and Y")
- Debugging unexpected predictions on specific rows
- Detecting when a model relies heavily on a field for certain rows but not others, which can reveal interaction effects or data quality issues localized to a subset of the data

Global patterns can still be derived by aggregating per-document feature importance values across many rows, but the underlying computation is row-specific.

### Enabling Feature Importance

Feature importance is requested via `num_top_feature_importance_values` in the analysis configuration for regression or classification jobs.

```json
PUT /_ml/data_frame/analytics/churn-classification
{
  "source": { "index": "customer-data" },
  "dest": { "index": "customer-data-predictions" },
  "analysis": {
    "classification": {
      "dependent_variable": "churned",
      "num_top_feature_importance_values": 5
    }
  }
}
```

Setting this to `0` (or omitting it) disables feature importance computation, which reduces job runtime and destination index size when the explainability information isn't needed. `num_top_feature_importance_values` caps how many of the most influential fields are included per document — the model may have considered more fields than that, but only the top N (by absolute importance) are stored per row.

### Result Structure

```json
{
  "tenure_months": 4,
  "monthly_charges": 95.00,
  "contract_type": "month-to-month",
  "ml": {
    "churned_prediction": "true",
    "prediction_probability": 0.87,
    "feature_importance": [
      { "feature_name": "contract_type", "importance": 0.41 },
      { "feature_name": "tenure_months", "importance": -0.28 },
      { "feature_name": "monthly_charges", "importance": 0.15 }
    ]
  }
}
```

- **Sign matters**: a positive importance value indicates the field pushed the prediction toward the predicted class/higher value; a negative value indicates it pushed away from it
- **Magnitude matters**: larger absolute values indicate stronger influence on this specific row's prediction
- In this example, `contract_type` being "month-to-month" pushed toward predicting churn, while `tenure_months` (a relatively short 4 months) pushed *against* churn in this particular computation — the exact directionality depends on how the model has learned the relationship, which isn't always intuitive without inspection

### Underlying Method

Elasticsearch's feature importance computation is based on **SHAP** (SHapley Additive exPlanations) values, a game-theoretic approach that attributes a prediction's deviation from a baseline (average) prediction across the contributing features in a mathematically consistent way [Unverified — exact SHAP variant/approximation method used should be confirmed against current documentation for the deployed version, as implementation details can differ from the original SHAP formulation].

The general property SHAP-based methods provide is that the sum of all features' importance values (across the full set, not just the top N returned) approximately reconstructs the difference between this row's prediction and the model's average/baseline prediction — giving the importance values a principled, additive interpretation rather than being an arbitrary heuristic ranking.

### Regression vs. Classification Feature Importance

The structure is the same across both job types, but interpretation differs slightly:

| Aspect | Regression | Classification |
| --- | --- | --- |
| What importance affects | The predicted numeric value | The predicted class probability |
| Positive importance means | Pushed the prediction higher | Pushed toward the predicted class |
| Negative importance means | Pushed the prediction lower | Pushed away from the predicted class |

### Aggregating Feature Importance Across Rows

Since feature importance is stored per-document in the destination index, standard aggregations can be used to summarize patterns across many predictions — for instance, computing the average absolute importance of each feature across all rows to approximate a global ranking, or filtering to rows where a specific feature had unusually high importance to investigate localized patterns.

```json
GET /customer-data-predictions/_search
{
  "size": 0,
  "aggs": {
    "by_feature": {
      "nested": {
        "path": "ml.feature_importance"
      },
      "aggs": {
        "features": {
          "terms": { "field": "ml.feature_importance.feature_name" },
          "aggs": {
            "avg_importance": {
              "avg": { "field": "ml.feature_importance.importance" }
            }
          }
        }
      }
    }
  }
}
```

[Unverified — exact field mapping type (`nested` vs. `object`) for `feature_importance` in the destination index, and therefore the exact aggregation syntax required, should be confirmed against the deployed version's actual generated mapping.]

### Using Feature Importance for Model Debugging

Common diagnostic uses beyond explaining individual predictions:

- **Detecting leakage** — if one field dominates importance scores nearly universally with implausibly high magnitude, it may be a field that leaks target information rather than a genuinely predictive feature
- **Spotting data quality issues** — a field with erratic, inconsistent importance across similar rows may indicate noisy or inconsistently populated source data
- **Validating domain expectations** — comparing which fields the model considers important against what domain experts would expect can surface either confirmation the model learned sensible patterns, or a signal that something is off

### Performance Considerations

Computing feature importance adds computational overhead during job training, roughly proportional to `num_top_feature_importance_values` and the total number of analyzed fields, since SHAP-based computation is inherently more expensive than producing a bare prediction alone [Unverified — exact overhead magnitude is dataset- and configuration-dependent]. For very large datasets or field counts, disabling feature importance (or requesting fewer top values) can meaningfully reduce job runtime when explainability isn't required for that particular use case.

### Common Pitfalls

- Interpreting feature importance as *causal* rather than *associative* — a high importance value indicates the model relied heavily on that field for this prediction, not that the field necessarily causes the outcome in the real world
- Assuming the sign of importance is universally intuitive — a field can have a counter-directional importance for a specific row due to interaction effects with other fields, even if its overall trend across the dataset points the other way
- Comparing raw importance magnitudes across completely different models or datasets as if they were on a standardized, universally comparable scale
- Forgetting that only the top N fields (per `num_top_feature_importance_values`) are stored per row — a field with genuine but modest influence may simply not appear in a given row's stored list

### Diagram: Per-Document Feature Importance

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 300">
\<style\>
.title { font: bold 14px sans-serif; fill: #1a1a1a; }
.label { font: 12px sans-serif; fill: #1a1a1a; }
.sub { font: 11px sans-serif; fill: #555; }
.barPos { fill: #4a9a5a; }
.barNeg { fill: #a54a4a; }
\</style\>

<text x="20" y="25" class="title">Feature Importance for One Prediction (svg_diagram)</text>

<line x1="370" y1="50" x2="370" y2="230" stroke="#999" stroke-width="1" />
<text x="370" y="245" class="sub" text-anchor="middle">baseline (avg prediction)</text>
<rect x="370" y="65" width="180" height="30" class="barPos" />
<text x="560" y="85" class="label">contract_type (+0.41)</text>
<rect x="230" y="105" width="140" height="30" class="barNeg" />
<text x="215" y="125" class="label" text-anchor="end">tenure_months (-0.28)</text>
<rect x="370" y="145" width="65" height="30" class="barPos" />
<text x="445" y="165" class="label">monthly_charges (+0.15)</text>

<text x="30" y="270" class="sub">Green bars push the prediction above baseline; red bars pull it below</text>

<text x="30" y="288" class="sub">Sum of all feature contributions ≈ this row's prediction minus baseline</text>

</svg>

**Related Topics**

- Classification and regression jobs — where feature importance is configured
- Data frame analytics overview — supervised vs. unsupervised analysis types
- Model evaluation metrics (`_evaluate` API)
- Inference processors and real-time model deployment
- Detecting and preventing data leakage in training data
- SHAP values and model explainability concepts more broadly