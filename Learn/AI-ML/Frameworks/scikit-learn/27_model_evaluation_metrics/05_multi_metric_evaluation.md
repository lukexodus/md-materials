## Multi-Metric Evaluation


### Simultaneous Multiple Metrics

Multi-metric evaluation enables comprehensive model assessment by computing multiple metrics simultaneously, providing holistic performance views and reducing computational overhead compared to separate evaluations.

```python
from sklearn.model_selection import cross_validate

scoring = ['accuracy', 'precision_macro', 'recall_macro', 'f1_macro', 'roc_auc']
cv_results = cross_validate(model, X, y, scoring=scoring, cv=5, return_train_score=True)

# Access individual metric results
accuracy_scores = cv_results['test_accuracy']
precision_scores = cv_results['test_precision_macro']
```

### Custom Multi-Metric Dictionaries

Complex evaluation scenarios benefit from custom scoring dictionaries that combine built-in and custom metrics, enabling tailored evaluation suites for specific applications.

```python
custom_scoring = {
    'accuracy': 'accuracy',
    'balanced_acc': make_scorer(balanced_accuracy_score),
    'precision': 'precision_weighted',
    'recall': 'recall_weighted',
    'f1': 'f1_weighted',
    'auc': 'roc_auc',
    'custom_business': custom_scorer
}

results = cross_validate(model, X, y, scoring=custom_scoring, cv=5)
```

### Metric Aggregation and Analysis

Multi-metric evaluation generates rich result sets requiring systematic analysis approaches. Statistical summaries, correlation analysis between metrics, and performance trade-off visualization help identify optimal models and understand evaluation consistency.

```python
import pandas as pd
import numpy as np

# Convert results to DataFrame for analysis
results_df = pd.DataFrame({
    metric: scores for metric, scores in results.items()
    if metric.startswith('test_')
})

# Statistical summary
summary_stats = results_df.describe()

# Metric correlations
correlation_matrix = results_df.corr()

# Performance trade-offs
mean_scores = results_df.mean()
std_scores = results_df.std()
```

### Evaluation Strategy Selection

Choosing appropriate metrics depends on problem characteristics, data distribution, business requirements, and model deployment constraints. Classification problems with balanced classes might emphasize accuracy, while imbalanced scenarios require precision-recall analysis. Regression tasks benefit from multiple error metrics to understand prediction quality across different scales and ranges.

**Example** evaluation strategies:
- **Binary classification with balanced data**: Accuracy, F1-score, AUC-ROC
- **Binary classification with imbalanced data**: Precision, Recall, F1-score, AUC-PR
- **Multi-class classification**: Macro/micro/weighted averages of precision, recall, F1
- **Regression with outliers**: MAE, median absolute error, robust R²
- **Regression requiring interpretability**: R², MAPE, residual analysis

**Output** interpretation requires understanding metric relationships, limitations, and business implications. Combining multiple complementary metrics provides comprehensive model evaluation, revealing different aspects of prediction performance and guiding informed model selection decisions.

**Next steps** in model evaluation include establishing baseline comparisons, implementing cross-validation strategies, conducting statistical significance testing, and developing monitoring systems for production model performance tracking.

---

