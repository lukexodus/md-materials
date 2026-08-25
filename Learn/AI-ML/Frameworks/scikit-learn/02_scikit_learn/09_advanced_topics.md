## Advanced Topics


### Custom Transformers and Estimators

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.base import ClassifierMixin

class CustomScaler(BaseEstimator, TransformerMixin):
    def __init__(self, method='standard'):
        self.method = method
    
    def fit(self, X, y=None):
        if self.method == 'standard':
            self.mean_ = np.mean(X, axis=0)
            self.std_ = np.std(X, axis=0)
        return self
    
    def transform(self, X):
        if self.method == 'standard':
            return (X - self.mean_) / self.std_
        return X
```

### Multiclass and Multilabel Classification

```python
from sklearn.multiclass import OneVsRestClassifier, OneVsOneClassifier
from sklearn.multioutput import MultiOutputClassifier

# One-vs-Rest for multiclass
ovr_clf = OneVsRestClassifier(SVC())

# Multi-output classification
multi_clf = MultiOutputClassifier(RandomForestClassifier())
```

### Imbalanced Datasets

```python
from sklearn.utils.class_weight import compute_class_weight
from sklearn.metrics import balanced_accuracy_score

# Class weights for imbalanced data
class_weights = compute_class_weight('balanced', classes=np.unique(y), y=y)
weighted_clf = LogisticRegression(class_weight='balanced')

# Balanced accuracy
balanced_acc = balanced_accuracy_score(y_true, y_pred)
```

### Model Persistence

```python
import joblib
import pickle

# Save model with joblib (recommended)
joblib.dump(model, 'model.joblib')
loaded_model = joblib.load('model.joblib')

# Save with pickle
with open('model.pkl', 'wb') as file:
    pickle.dump(model, file)

with open('model.pkl', 'rb') as file:
    loaded_model = pickle.load(file)
```

### Partial Fit for Online Learning

```python
from sklearn.linear_model import SGDClassifier, PassiveAggressiveClassifier

# Online learning with partial_fit
online_clf = SGDClassifier()

# Simulate streaming data
for batch_X, batch_y in data_batches:
    online_clf.partial_fit(batch_X, batch_y)
```

