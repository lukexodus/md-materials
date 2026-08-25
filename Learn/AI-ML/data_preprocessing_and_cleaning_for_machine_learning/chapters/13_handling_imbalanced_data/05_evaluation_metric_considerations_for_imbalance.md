## Evaluation Metric Considerations for Imbalance

### Overview

Selecting appropriate evaluation metrics is one of the most consequential decisions when working with imbalanced classification problems. Metrics that behave reasonably on balanced datasets can become misleading or uninformative under imbalance, and choosing the wrong metric can cause a practitioner to select a poorly performing model while believing it performs well. This topic consolidates metric selection guidance referenced across the class imbalance and resampling topics into a dedicated treatment.

### Why Accuracy Fails Under Imbalance

As established in the class imbalance identification topic, overall accuracy is computed as:

$$\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN}$$

Under severe imbalance, a model that predicts only the majority class for every observation can achieve a high accuracy score while providing zero practical value for identifying the minority class. This is a direct mathematical consequence of how accuracy weights all correct predictions equally, regardless of class, rather than a hypothetical concern specific to certain datasets.

### Confusion Matrix as the Foundation

Before selecting summary metrics, examining the full confusion matrix — true positives (TP), true negatives (TN), false positives (FP), and false negatives (FN) — broken down per class provides the most complete picture of model behavior on imbalanced data.

===MERMAID_DIAGRAM===

flowchart TD

A[Model predictions on test set] --> B[Build confusion matrix]

B --> C[True Positives]

B --> D[False Positives]

B --> E[True Negatives]

B --> F[False Negatives]

C --> G[Derive precision, recall, F1 per class]

D --> G

E --> G

F --> G

Every summary metric discussed below is ultimately derived from these four quantities, so understanding the confusion matrix directly is a useful diagnostic step even before computing any single summary number.

### Precision, Recall, and F1-Score

**Precision** measures, out of all instances predicted positive, how many were actually positive:

$$\text{Precision} = \frac{TP}{TP + FP}$$

**Recall** (also called sensitivity) measures, out of all instances that were actually positive, how many were correctly identified:

$$\text{Recall} = \frac{TP}{TP + FN}$$

**F1-score** is the harmonic mean of precision and recall:

$$F1 = 2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$$

These three metrics, computed per class rather than as a single aggregate figure, are commonly used together to evaluate imbalanced classification performance, since they directly reveal how the model performs specifically on the minority class rather than being dominated by majority class performance, as aggregate accuracy is.

```python
from sklearn.metrics import classification_report

print(classification_report(y_test, y_pred))
```

`classification_report` is a documented scikit-learn function that outputs precision, recall, and F1-score broken down by class, along with macro and weighted averages.

### Macro, Micro, and Weighted Averaging

When summarizing per-class metrics into a single number (e.g., for model comparison or hyperparameter tuning), the choice of averaging method matters significantly under imbalance:

- **Macro average:** Computes the metric independently for each class, then takes the unweighted average across classes. This treats all classes as equally important regardless of their frequency, which can be useful specifically because it prevents the majority class from dominating the summary score.
- **Micro average:** Aggregates the contributions of all classes (summing TP, FP, FN across classes) before computing the metric. [Inference] This tends to be dominated by the majority class's performance in imbalanced settings, since the majority class contributes far more to the summed totals, making micro-averaged scores behave more similarly to accuracy than macro-averaged scores do. This is a reasoned mathematical consequence of how the aggregation is computed, not a benchmarked comparison across specific datasets.
- **Weighted average:** Computes the metric per class, then averages with weights proportional to each class's frequency (support). This still reflects overall performance but weights classes by their prevalence, meaning majority class performance still has more influence than minority class performance on the final weighted number.

[Inference] Macro averaging is generally recommended over micro or weighted averaging specifically when minority class performance is the primary concern, since it does not allow the majority class's typically stronger performance to mask minority class weaknesses. This is a widely repeated practitioner guideline, though I do not have a single authoritative source establishing this as a formally universal rule applicable to every imbalanced use case.

### ROC-AUC and Its Limitations Under Imbalance

The Receiver Operating Characteristic (ROC) curve plots the true positive rate against the false positive rate across classification thresholds, and the Area Under the Curve (AUC) summarizes this into a single number.

$$\text{True Positive Rate} = \frac{TP}{TP + FN}, \quad \text{False Positive Rate} = \frac{FP}{FP + TN}$$

- **Limitation under severe imbalance:** [Inference] Because the false positive rate is calculated relative to the (typically very large) number of true negatives, ROC-AUC can remain deceptively high even when precision on the minority class is poor, since a large number of false positives may represent only a small fraction of the total negative class. This is a commonly cited mathematical property of the ROC-AUC formula under class imbalance, rather than a benchmarked finding specific to one dataset.
- I cannot verify the exact degree to which ROC-AUC becomes misleading for any specific dataset without direct comparison against Precision-Recall-based metrics on that same data, since the magnitude of this effect depends on the specific imbalance ratio and the model's error distribution.

### Precision-Recall Curve and PR-AUC

The Precision-Recall (PR) curve plots precision against recall across classification thresholds, and PR-AUC (or Average Precision) summarizes this into a single number.

- **Why it is often preferred under imbalance:** Because precision directly incorporates false positives relative to the total predicted positives (not relative to the large number of true negatives), PR curves are generally considered more sensitive to poor minority-class performance than ROC curves under severe imbalance. [Inference] This is a widely cited practitioner and academic guideline in imbalanced classification literature, though the precise degree of advantage over ROC-AUC depends on the specific dataset's imbalance ratio and error characteristics, and I do not have a single authoritative universal source confirming an exact quantitative advantage.

```python
from sklearn.metrics import precision_recall_curve, average_precision_score

precision, recall, thresholds = precision_recall_curve(y_test, y_scores)
ap_score = average_precision_score(y_test, y_scores)
```

`precision_recall_curve` and `average_precision_score` are documented scikit-learn functions for computing these metrics directly.

### Matthews Correlation Coefficient (MCC)

MCC is a single summary metric that incorporates all four confusion matrix quantities symmetrically:

$$\text{MCC} = \frac{TP \cdot TN - FP \cdot FN}{\sqrt{(TP+FP)(TP+FN)(TN+FP)(TN+FN)}}$$

producing a value between -1 (total disagreement) and +1 (perfect prediction), with 0 indicating performance equivalent to random guessing.

- [Inference] MCC is sometimes recommended as a single robust summary metric for imbalanced binary classification specifically because it accounts for all four confusion matrix quantities in a balanced way, rather than emphasizing only positive-class-related quantities as precision, recall, and F1 do individually. This is a commonly cited property in metric-comparison literature, though I do not have a single authoritative source confirming it as a universally superior choice over all other metrics for every imbalanced scenario.

### Metric Selection Framework

===MERMAID_DIAGRAM===

flowchart TD

A[Imbalanced classification problem] --> B{Primary concern}

B -->|Overall correctness across all classes equally| C[Macro-averaged F1 or Macro-averaged precision/recall]

B -->|Minimizing false negatives specifically e.g. disease detection| D[Recall, prioritized alongside precision]

B -->|Minimizing false positives specifically e.g. spam flagging cost| E[Precision, prioritized alongside recall]

B -->|Ranking/threshold-independent comparison| F{Severity of imbalance}

F -->|Moderate| G[ROC-AUC acceptable]

F -->|Severe| H[Precision-Recall AUC preferred]

B -->|Single balanced summary statistic desired| I[Matthews Correlation Coefficient]

### Threshold Selection and Its Interaction with Metrics

Many classifiers output a probability or score rather than a direct class label, requiring a decision threshold (commonly defaulted to 0.5) to convert scores into predicted classes.

- Under imbalance, [Inference] the default 0.5 threshold is often not optimal, since it was not chosen with the specific class distribution or misclassification cost structure of the problem in mind. Adjusting the threshold based on the precision-recall tradeoff relevant to the specific use case (e.g., lowering the threshold to increase recall for a disease screening application) is a commonly used practical technique, though the optimal threshold for any specific application depends on domain-specific cost considerations that I cannot generalize without that information.
- Precision-recall curves and F1-score-versus-threshold plots are commonly used tools to identify a more suitable threshold than the naive 0.5 default for a specific imbalanced problem.

### Business Cost Considerations

[Inference] Ultimately, the "correct" metric to prioritize is often not a purely statistical decision but depends on the relative real-world cost of false positives versus false negatives for the specific application (e.g., in fraud detection, a false negative allowing fraud to proceed may be considered more costly than a false positive flagging a legitimate transaction for review). This is a reasoned framing commonly used in applied machine learning practice, not a claim I can verify as universally correct without the specific business context of a given problem.

### Common Pitfalls

- Relying on overall accuracy as the primary or sole evaluation metric for an imbalanced classification problem.
- Using micro-averaged metrics when the goal is specifically to evaluate minority class performance, since micro-averaging can be dominated by majority class results.
- Relying solely on ROC-AUC under severe imbalance without also examining precision-recall-based metrics, potentially overestimating real-world model usefulness.
- Using the default 0.5 classification threshold without evaluating whether a different threshold better serves the specific cost tradeoffs of the problem.
- Selecting a single metric without considering the actual business or domain cost asymmetry between false positives and false negatives.

### Key Points

- Accuracy is an unreliable primary metric under class imbalance, since it can be dominated by majority class performance and can mask complete failure to identify minority class instances.
- Per-class precision, recall, and F1-score, along with the choice of macro, micro, or weighted averaging, provide more informative evaluation than a single aggregate accuracy figure.
- [Inference] Precision-Recall curves and PR-AUC are generally considered more informative than ROC-AUC specifically under severe class imbalance, based on commonly cited practitioner and academic guidance, though the precise magnitude of this advantage is dataset-dependent and not benchmarked here.
- Matthews Correlation Coefficient is sometimes used as a single balanced summary statistic that accounts for all four confusion matrix quantities symmetrically.
- [Inference] Threshold selection and metric prioritization ultimately depend on the specific real-world cost asymmetry between false positives and false negatives for a given application, which is a domain-specific judgment rather than a purely statistical determination.

I cannot verify a single universally correct metric or threshold choice applicable to every imbalanced classification problem; the appropriate choice depends on the specific dataset, imbalance severity, and business cost context, and should be validated empirically for the problem at hand.

**Related Topics**

- Threshold tuning and cost-sensitive decision-making
- Class weighting and resampling techniques as complementary approaches to metric selection
- Calibration of predicted probabilities under class imbalance
- Multiclass and multilabel evaluation metric extensions
- Statistical significance testing for comparing model performance on imbalanced data