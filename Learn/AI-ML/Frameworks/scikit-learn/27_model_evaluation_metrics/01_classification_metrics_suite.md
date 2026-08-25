## Classification Metrics Suite


### Accuracy-Based Metrics

**Accuracy** represents the fraction of correct predictions over total predictions. While intuitive, accuracy can be misleading with imbalanced datasets where a naive classifier might achieve high accuracy by predicting only the majority class.

```python
from sklearn.metrics import accuracy_score, balanced_accuracy_score
accuracy = accuracy_score(y_true, y_pred)
balanced_acc = balanced_accuracy_score(y_true, y_pred)
```

**Balanced accuracy** addresses class imbalance by averaging recall scores for each class, providing a more reliable metric when dealing with skewed distributions.

### Precision, Recall, and F-Score Family

**Precision** measures the proportion of positive identifications that were actually correct, answering "Of all positive predictions, how many were right?" This metric is crucial when false positives are costly.

**Recall (Sensitivity)** quantifies the proportion of actual positives correctly identified, addressing "Of all actual positives, how many did we find?" High recall is essential when missing positive cases has severe consequences.

**F1-score** harmonically averages precision and recall, providing a single metric that balances both concerns. The harmonic mean ensures that extremely low values in either precision or recall significantly impact the F1-score.

```python
from sklearn.metrics import precision_score, recall_score, f1_score, fbeta_score
precision = precision_score(y_true, y_pred, average='weighted')
recall = recall_score(y_true, y_pred, average='macro')
f1 = f1_score(y_true, y_pred, average='binary')
fbeta = fbeta_score(y_true, y_pred, beta=2.0)  # Emphasizes recall more than precision
```

**F-beta scores** generalize F1 by allowing different weightings between precision and recall through the beta parameter. Beta > 1 emphasizes recall, while beta < 1 emphasizes precision.

### ROC and AUC Analysis

**ROC (Receiver Operating Characteristic) curves** plot True Positive Rate against False Positive Rate across various threshold values, visualizing the trade-off between sensitivity and specificity.

**AUC (Area Under Curve)** summarizes ROC curve performance in a single number. AUC = 0.5 indicates random guessing, while AUC = 1.0 represents perfect classification. AUC is threshold-independent and provides insight into model discriminative ability.

```python
from sklearn.metrics import roc_curve, roc_auc_score, auc
fpr, tpr, thresholds = roc_curve(y_true, y_scores)
auc_score = roc_auc_score(y_true, y_scores)
```

### Precision-Recall Curves

**Precision-Recall curves** are particularly valuable for imbalanced datasets, plotting precision against recall for different thresholds. Unlike ROC curves, PR curves focus on positive class performance and can reveal model weaknesses that ROC curves might mask in highly skewed datasets.

```python
from sklearn.metrics import precision_recall_curve, average_precision_score
precision, recall, thresholds = precision_recall_curve(y_true, y_scores)
ap_score = average_precision_score(y_true, y_scores)
```

### Confusion Matrix Analysis

**Confusion matrices** provide detailed breakdowns of classification results, showing true positives, true negatives, false positives, and false negatives. This granular view enables identification of specific classification errors and class-wise performance patterns.

```python
from sklearn.metrics import confusion_matrix, classification_report
cm = confusion_matrix(y_true, y_pred)
report = classification_report(y_true, y_pred, target_names=class_names)
```

### Multi-Class and Multi-Label Metrics

**Macro averaging** computes metrics independently for each class and averages results, treating all classes equally regardless of support. **Micro averaging** aggregates contributions across all classes, giving more weight to frequent classes. **Weighted averaging** accounts for class imbalance by weighting metrics by class support.

```python
from sklearn.metrics import jaccard_score, hamming_loss
# Multi-label specific metrics
jaccard = jaccard_score(y_true, y_pred, average='samples')
hamming = hamming_loss(y_true, y_pred)
```

**Hamming loss** measures the fraction of incorrectly predicted labels, while **Jaccard similarity** computes intersection over union for label sets.

