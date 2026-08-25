## Identifying Class Imbalance

### Overview

Class imbalance occurs when the categories of a classification target variable are not represented equally in the dataset, with one or more classes (majority classes) occurring far more frequently than others (minority classes). Identifying the presence and severity of class imbalance is a necessary first step before deciding whether resampling, cost-sensitive learning, or other corrective techniques are warranted.

### Basic Detection: Class Distribution

The most direct way to identify class imbalance is to examine the frequency count or proportion of each class in the target variable.

```python
df['target'].value_counts()
df['target'].value_counts(normalize=True)
```

`value_counts()` and `value_counts(normalize=True)` are documented pandas methods that return raw counts and relative proportions of each unique value, respectively.

**Example:**

| Class | Count | Proportion |
| --- | --- | --- |
| Not fraud (0) | 9,850 | 98.5% |
| Fraud (1) | 150 | 1.5% |

This distribution reflects a substantial imbalance, with the minority class ("fraud") representing a very small fraction of total observations.

### Quantifying Imbalance: Imbalance Ratio

A common way to express the degree of imbalance numerically is the **imbalance ratio**, typically defined as the ratio of majority class count to minority class count:

$$\text{Imbalance Ratio} = \frac{n_{\text{majority}}}{n_{\text{minority}}}$$

For the fraud example above:

$$\text{Imbalance Ratio} = \frac{9850}{150} \approx 65.7$$

This indicates the majority class occurs roughly 66 times more often than the minority class.

- There is no single universally agreed-upon numeric threshold at which a dataset is officially classified as "imbalanced" versus "balanced." [Inference] Commonly cited informal thresholds in practitioner literature suggest ratios above roughly 3:1 or 4:1 may already warrant attention, with ratios in the hundreds or thousands (as seen in fraud detection or rare disease diagnosis) considered severely imbalanced. This is a generalization drawn from commonly repeated practitioner guidance rather than a fixed, formally standardized rule I can cite to a specific authoritative source.

### Visual Identification

Bar charts or histograms of class frequency are commonly used to visually communicate class imbalance, particularly for stakeholders less familiar with reading raw numeric tables.

Below is an illustrative example of what a class imbalance bar chart typically looks like:

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320">
<text x="250" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Class Distribution (svg_diagram)</text>
<line x1="60" y1="270" x2="460" y2="270" stroke="#333" stroke-width="2" />
<line x1="60" y1="270" x2="60" y2="50" stroke="#333" stroke-width="2" />
<rect x="120" y="70" width="100" height="200" fill="#4C72B0" />
<text x="170" y="290" text-anchor="middle" font-size="13" fill="#333">Not Fraud (0)</text>
<text x="170" y="60" text-anchor="middle" font-size="13" fill="#333">9,850</text>
<rect x="320" y="262" width="100" height="8" fill="#DD8452" />
<text x="370" y="290" text-anchor="middle" font-size="13" fill="#333">Fraud (1)</text>
<text x="370" y="255" text-anchor="middle" font-size="13" fill="#333">150</text>
<text x="20" y="60" font-size="11" fill="#666" transform="rotate(0)">Count</text>
</svg>

The disproportionate bar heights in such a chart visually communicate the same imbalance reflected numerically in the value counts above.

### Why Accuracy Alone Fails to Reveal Imbalance Effects

A critical reason to explicitly check for class imbalance, rather than relying solely on overall accuracy, is that accuracy can be highly misleading on imbalanced datasets.

**Example:** For the fraud dataset above, a model that predicts "not fraud" for every single observation would achieve:

$$\text{Accuracy} = \frac{9850}{10000} = 98.5\%$$

despite never correctly identifying a single fraud case. This is a direct mathematical consequence of how accuracy is computed, not a hypothetical edge case — it demonstrates why accuracy alone is an unreliable signal for detecting or evaluating imbalance-related issues.

### Additional Diagnostic Metrics Beyond Raw Counts

Beyond raw class counts, several metrics help characterize the practical impact of imbalance on model evaluation:

- **Confusion matrix breakdown:** Examining true positives, false positives, true negatives, and false negatives separately for each class reveals imbalance-driven blind spots that a single aggregate accuracy score would hide.
- **Per-class precision, recall, and F1-score:** These metrics, computed separately for each class, reveal whether a model is systematically failing to identify minority class instances, even when overall accuracy appears high.
- **Precision-Recall curves (as opposed to ROC curves):** [Inference] Precision-Recall curves are generally considered more informative than ROC curves specifically for imbalanced datasets, since ROC curves can appear overly optimistic when the negative class vastly outnumbers the positive class. This is a commonly cited practitioner guideline in imbalanced classification literature, though the degree of difference depends on the specific severity of imbalance and dataset characteristics, and I do not have a single authoritative source to cite confirming this as a universally formalized rule.

### Imbalance in Multiclass Settings

Class imbalance is not limited to binary classification. In multiclass problems, imbalance can exist between any subset of classes, and the imbalance ratio calculation becomes more nuanced, since there may be multiple minority classes with different frequencies relative to the majority class or to each other.

```python
df['target'].value_counts(normalize=True).plot(kind='bar')
```

Visualizing all class proportions together is a straightforward way to identify which specific classes are underrepresented in a multiclass setting, extending the same basic detection approach used for binary classification.

### Imbalance in Target Variables vs. Imbalance in Features

It is worth explicitly distinguishing class imbalance (an imbalance in the **target variable's** distribution) from an imbalanced distribution within a categorical **feature** (e.g., a `country` feature where one country dominates the dataset). The detection method (value counts, proportions) is mechanically similar for both, but the downstream implications differ:

- Target class imbalance primarily affects model training objectives and evaluation metric selection.
- Feature-level imbalance (e.g., rare categories within a feature) primarily affects encoding strategy decisions, as discussed in the frequency encoding and high-cardinality encoding topics.

### Common Pitfalls

- Relying solely on overall accuracy to evaluate a model without first checking the underlying class distribution, which can mask poor minority-class performance entirely.
- Assuming a fixed numeric threshold (e.g., "imbalance ratio above 10") universally defines a dataset as problematically imbalanced, when the practical impact depends on the specific problem, cost of misclassification, and modeling approach used. [Unverified] I do not have a single authoritative, universally agreed-upon threshold to cite for this determination.
- Checking class distribution only on the full dataset and not verifying that train/validation/test splits preserve a similar class distribution (addressed further under stratified sampling).
- Conflating imbalance in the target variable with imbalance in an unrelated categorical feature, leading to the wrong mitigation strategy being applied.

### Key Points

- Class imbalance is identified primarily through class frequency counts and proportions in the target variable, most directly via methods like pandas' `value_counts()`.
- The imbalance ratio (majority count divided by minority count) provides a simple numeric summary of imbalance severity, though no single formally standardized threshold universally defines "imbalanced" versus "balanced."
- Accuracy alone can be severely misleading on imbalanced datasets, since a naive majority-class-only prediction can achieve high accuracy while providing no practical predictive value for the minority class.
- Per-class precision, recall, F1-score, and confusion matrix analysis provide more informative diagnostics than aggregate accuracy alone.
- [Inference] Precision-Recall curves are generally considered more informative than ROC curves for imbalanced settings, based on commonly cited practitioner guidance, though I do not have a single authoritative source confirming this as a formally universal rule, and the practical difference depends on dataset-specific severity of imbalance.

I cannot verify a single universally standardized numeric threshold for what constitutes "severe" class imbalance across all domains and use cases; such judgments are typically context-dependent and should be evaluated relative to the specific problem's cost of misclassification.

**Related Topics**

- Resampling techniques: oversampling, undersampling, and SMOTE
- Stratified sampling for train/test/validation splits
- Cost-sensitive learning and class weighting
- Choosing evaluation metrics for imbalanced classification problems
- Anomaly detection approaches as an alternative to classification for extreme imbalance