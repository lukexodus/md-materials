## Custom Scoring Functions


### Creating Custom Scorers

Scikit-learn's `make_scorer` function transforms any metric function into a scorer compatible with cross-validation and hyperparameter tuning. Custom scorers enable domain-specific evaluation criteria and business-relevant metrics.

```python
from sklearn.metrics import make_scorer
from sklearn.model_selection import cross_val_score

def custom_metric(y_true, y_pred, sample_weight=None):
    # Custom logic here
    return score

custom_scorer = make_scorer(custom_metric, greater_is_better=True, needs_proba=False)
scores = cross_val_score(model, X, y, scoring=custom_scorer)
```

**Key points** for custom scorer creation:
- `greater_is_better` parameter determines whether higher scores indicate better performance
- `needs_proba` specifies whether the scorer requires probability estimates rather than hard predictions
- `needs_threshold` indicates if the scorer needs decision function values
- Sample weights can be incorporated through the `sample_weight` parameter

### Advanced Scorer Configurations

Custom scorers can accept additional parameters through partial functions or lambda expressions, enabling flexible metric configurations for specific use cases.

```python
from functools import partial

def weighted_f1_custom(y_true, y_pred, pos_weight=1.0):
    # Custom weighted F1 implementation
    return score

weighted_scorer = make_scorer(partial(weighted_f1_custom, pos_weight=2.0))
```

### Scorer Functions for Specific Domains

Business applications often require specialized metrics that combine multiple evaluation criteria. Custom scorers can implement cost-sensitive evaluation, incorporating differential misclassification costs or profit optimization.

```python
def business_metric(y_true, y_pred, cost_matrix):
    cm = confusion_matrix(y_true, y_pred)
    total_cost = np.sum(cm * cost_matrix)
    return -total_cost  # Negative because we want to minimize cost

cost_sensitive_scorer = make_scorer(
    lambda y_true, y_pred: business_metric(y_true, y_pred, cost_matrix),
    greater_is_better=True
)
```

