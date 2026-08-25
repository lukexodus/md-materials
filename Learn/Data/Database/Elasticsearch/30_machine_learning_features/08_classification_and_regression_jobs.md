## Classification and Regression Jobs

### Overview

Classification and regression are the two supervised analysis types available within Elasticsearch's data frame analytics framework. Both learn a predictive relationship between a set of feature fields and a known target field (the `dependent_variable`) using a training dataset, then apply that learned relationship to generate predictions across the full dataset, including rows held out from training for validation.

The core distinction between them is the nature of the target being predicted: **regression** predicts a continuous numeric value; **classification** predicts a discrete categorical label.

### Regression Jobs

Regression is used when the `dependent_variable` is numeric and continuous — price, duration, temperature, a count, or any value where the difference between two predictions has meaningful magnitude (predicting 105 when the actual is 100 is a smaller error than predicting 200).

**Example configuration:**

```
PUT _ml/data_frame/analytics/sales-forecast-regression
{
  "source": { "index": "sales-history" },
  "dest": { "index": "sales-history-predicted" },
  "analysis": {
    "regression": {
      "dependent_variable": "units_sold",
      "training_percent": 80,
      "num_top_feature_importance_values": 5
    }
  }
}
```

Key regression-specific parameters:

- **`dependent_variable`** — the numeric field being predicted.
- **`prediction_field_name`** — optional override for the name of the output prediction field in the destination index (defaults to `<dependent_variable>_prediction`).
- **`loss_function`** — the function minimized during training (e.g., mean squared error), influencing how the model penalizes prediction errors.

**Regression evaluation metrics** (via `_evaluate`):

- **Mean squared error (MSE)** — average of squared differences between predicted and actual values; penalizes large errors more heavily.
- **R-squared** — proportion of variance in the target explained by the model; closer to 1 indicates a better fit.
- **Mean absolute error / Huber loss** — alternative error measures, less sensitive to outliers than MSE. [Inference: exact set of available metrics has been extended across versions — confirm against current documentation.]

### Classification Jobs

Classification is used when the `dependent_variable` is a discrete category — a label such as `churned`/`retained`, a fraud classification (`fraudulent`/`legitimate`), or a multi-class label such as a product category.

**Example configuration:**

```
PUT _ml/data_frame/analytics/churn-classification
{
  "source": { "index": "customer-data" },
  "dest": { "index": "customer-data-predicted" },
  "analysis": {
    "classification": {
      "dependent_variable": "churned",
      "training_percent": 75,
      "num_top_classes": 2
    }
  }
}
```

Key classification-specific parameters:

- **`dependent_variable`** — the categorical field being predicted. Elasticsearch infers the set of distinct classes from the training data.
- **`num_top_classes`** — how many top predicted class probabilities to include per document in the output (useful for multi-class problems where more than the single top prediction is informative).
- **`class_assignment_objective`** — controls whether the model optimizes for overall accuracy or for balanced performance across classes (relevant for imbalanced datasets, e.g., rare fraud cases among mostly legitimate transactions).

**Classification evaluation metrics** (via `_evaluate`):

- **Accuracy** — proportion of correct predictions overall.
- **Precision / Recall** — computed per class; precision measures how many predicted-positive cases were actually positive, recall measures how many actual-positive cases were correctly identified.
- **Confusion matrix** — a full breakdown of predicted vs. actual class combinations, useful for spotting systematic misclassification patterns.
- **AUC-ROC** — area under the receiver operating characteristic curve, applicable primarily to binary classification, summarizing the tradeoff between true positive and false positive rates across thresholds.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 280">
  <text x="400" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Regression vs Classification Output (svg_diagram)</text>

  <text x="200" y="55" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Regression</text>
  <line x1="60" y1="160" x2="340" y2="160" stroke="#999" stroke-width="1" />
  <line x1="60" y1="160" x2="60" y2="80" stroke="#999" stroke-width="1" />
  <circle cx="100" cy="140" r="4" fill="#4285f4" />
  <circle cx="140" cy="120" r="4" fill="#4285f4" />
  <circle cx="180" cy="130" r="4" fill="#4285f4" />
  <circle cx="220" cy="100" r="4" fill="#4285f4" />
  <circle cx="260" cy="110" r="4" fill="#4285f4" />
  <circle cx="300" cy="90" r="4" fill="#4285f4" />
  <path d="M 90 145 L 310 85" stroke="#34a853" stroke-width="2" fill="none" stroke-dasharray="4,3" />
  <text x="200" y="180" text-anchor="middle" font-size="10" fill="#555">Predicts a continuous value along a range</text>

  <text x="600" y="55" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Classification</text>
  <rect x="480" y="75" width="100" height="85" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="530" y="122" text-anchor="middle" font-size="11" fill="#1a1a1a">Class A</text>
  <rect x="600" y="75" width="140" height="85" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="670" y="122" text-anchor="middle" font-size="11" fill="#1a1a1a">Class B</text>
  <text x="600" y="180" text-anchor="middle" font-size="10" fill="#555">Assigns each row to one of a fixed set of labels</text>

  <text x="400" y="230" text-anchor="middle" font-size="12" fill="#555">Both use the same underlying gradient-boosted decision tree</text>
  <text x="400" y="248" text-anchor="middle" font-size="12" fill="#555">approach, differing in target type and loss function.</text>
</svg>

### Underlying Algorithm

Both regression and classification in Elasticsearch's data frame analytics use gradient-boosted decision trees as the underlying model family. This approach builds an ensemble of decision trees sequentially, where each new tree corrects errors made by the previous ensemble, producing strong predictive performance on structured/tabular data without requiring manual feature scaling in most cases. [Inference: specific hyperparameter defaults and tree-building details are implementation specifics that may be refined across versions.]

### Handling Class Imbalance (Classification)

Real-world classification targets are often imbalanced — fraud, churn, and failure-prediction problems typically have far fewer positive cases than negative ones. Elasticsearch addresses this partly through `class_assignment_objective`, which can be set to prioritize balanced accuracy across classes rather than raw overall accuracy (which can be misleadingly high on imbalanced data by simply predicting the majority class every time).

### Missing Values and Field Requirements

- Documents with a missing value in the `dependent_variable` field are excluded from training but still receive predictions in the destination index if they have sufficient feature data.
- Fields with a high proportion of missing values across the dataset may be automatically excluded or handled with imputation-like strategies internally. [Inference: exact missing-value handling strategy is an internal implementation detail — behavior should be validated empirically for datasets with significant missingness.]
- Categorical feature fields (not just the target) are supported and are encoded internally for use by the tree-based model.

### Choosing Between Regression and Classification

The choice is generally dictated directly by the nature of the target field rather than being a judgment call:

- If the answer to "what am I predicting" is a number on a continuous scale → regression.
- If the answer is "which of a fixed set of categories" → classification.
- Edge cases like predicting a small number of discrete integer outcomes (e.g., a 1–5 rating) can sometimes be framed as either, depending on whether the ordinal relationship between values matters more than treating them as MSE-comparable numbers, or as distinct classes.

### Practical Workflow

1. Prepare a source index with feature fields and a known target field for a representative historical dataset.
2. Configure `analyzed_fields` to exclude identifiers or leakage-prone fields (fields that indirectly encode the target and wouldn't be available at prediction time).
3. Set an appropriate `training_percent`, balancing enough training data against a meaningful validation holdout.
4. Run the job and review `_evaluate` metrics against the validation split.
5. Iterate on feature selection or configuration if performance is inadequate, then apply the trained model to new data via inference (either by re-running the job or deploying the trained model for real-time inference in an ingest pipeline).

### Key Points

- Regression predicts continuous numeric values; classification predicts discrete category labels.
- Both are supervised, requiring a `dependent_variable` and a `training_percent` split for validation.
- Both use gradient-boosted decision trees as the underlying model.
- Evaluation metrics differ by type: MSE/R-squared for regression; accuracy/precision/recall/confusion matrix/AUC-ROC for classification.
- Class imbalance in classification can be addressed via `class_assignment_objective`.

### Related Topics

- Data frame analytics job configuration and lifecycle
- Feature importance (SHAP values) and prediction interpretability
- The `_evaluate` API and metric selection
- Deploying trained models for real-time inference
- Feature engineering and `analyzed_fields` selection
- Outlier detection as an unsupervised alternative