## Module 7: Model Evaluation Metrics


### 7.1 Evaluation Framework

- Training, validation, and test set roles
- Metric selection based on business objectives
- Single metric vs multi-metric evaluation
- Evaluation in production vs offline

### 7.2 Classification Metrics: Binary

- Confusion matrix components (TP, TN, FP, FN)
- Accuracy and its limitations
- Precision (Positive Predictive Value)
- Recall (Sensitivity, True Positive Rate)
- Specificity (True Negative Rate)
- F1 Score and Fβ scores
- Matthews Correlation Coefficient (MCC)

### 7.3 Classification Metrics: Probabilistic

- ROC curve and AUC-ROC
- Precision-Recall curve and AUC-PR
- Log loss (cross-entropy)
- Brier score
- Calibration curves and metrics
- When to use which curve

### 7.4 Classification Metrics: Multiclass

- Macro, micro, and weighted averaging
- One-vs-rest and one-vs-one evaluation
- Cohen's Kappa
- Multiclass log loss
- Top-k accuracy
- Confusion matrices for multiclass

### 7.5 Regression Metrics

- Mean Absolute Error (MAE)
- Mean Squared Error (MSE) and Root MSE (RMSE)
- Mean Absolute Percentage Error (MAPE)
- R-squared and Adjusted R-squared
- Median Absolute Error
- Huber loss
- Quantile losses

### 7.6 Ranking and Recommendation Metrics

- Precision@K and Recall@K
- Mean Average Precision (MAP)
- Normalized Discounted Cumulative Gain (NDCG)
- Mean Reciprocal Rank (MRR)
- Hit Rate
- Coverage and diversity metrics

### 7.7 Clustering Metrics

- Internal metrics (Silhouette, Davies-Bouldin, Calinski-Harabasz)
- External metrics (Adjusted Rand Index, Normalized Mutual Information)
- Purity and V-measure
- Gap statistic

### 7.8 Imbalanced Learning Metrics

- Why accuracy fails for imbalanced data
- Balanced accuracy
- G-mean (geometric mean of recall)
- Area Under Precision-Recall Curve
- Cost-sensitive evaluation
- Per-class performance analysis

### 7.9 Business and Domain-Specific Metrics

- Cost-benefit analysis
- Expected value frameworks
- Time-to-detection in anomaly detection
- Clinical metrics (sensitivity/specificity thresholds)
- A/B testing metrics
- Operational metrics (latency, throughput)

### 7.10 Statistical Significance and Confidence

- Confidence intervals for metrics
- Hypothesis testing for model comparison
- Permutation tests
- Bootstrap confidence intervals
- Multiple testing corrections
- Power analysis for evaluation

### 7.11 Metric Selection Guidelines

- Aligning metrics with business goals
- Primary vs secondary metrics
- Guardrail metrics
- Trade-offs between metrics
- Metric stability and variance

### 7.12 Evaluation Best Practices

- Holdout test set protocol
- Avoiding data leakage in evaluation
- Temporal validation for time series
- Subgroup analysis (fairness considerations)
- Error analysis and failure mode identification
- Documentation and reporting standards

---

