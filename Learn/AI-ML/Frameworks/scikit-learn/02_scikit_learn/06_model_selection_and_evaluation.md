## Model Selection and Evaluation


### Cross-Validation

```python
from sklearn.model_selection import cross_val_score, cross_validate
from sklearn.model_selection import KFold, StratifiedKFold, TimeSeriesSplit
from sklearn.model_selection import LeaveOneOut, LeavePOut

# Basic cross-validation
scores = cross_val_score(estimator, X, y, cv=5, scoring='accuracy')

# Detailed cross-validation with multiple metrics
scoring = ['precision', 'recall', 'f1', 'accuracy']
cv_results = cross_validate(estimator, X, y, cv=5, scoring=scoring)

# Custom cross-validation strategies
kfold = KFold(n_splits=5, shuffle=True, random_state=42)
stratified_kfold = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
```

### Hyperparameter Tuning

#### Grid Search

```python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.model_selection import HalvingGridSearchCV

# Grid Search
param_grid = {
    'C': [0.1, 1, 10, 100],
    'kernel': ['linear', 'rbf', 'poly'],
    'gamma': ['scale', 'auto', 0.001, 0.01, 0.1, 1]
}

grid_search = GridSearchCV(
    estimator=SVC(),
    param_grid=param_grid,
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    verbose=1
)
grid_search.fit(X_train, y_train)
```

#### Randomized Search

```python
from scipy.stats import uniform, randint

# Randomized Search
param_distributions = {
    'C': uniform(0.1, 100),
    'kernel': ['linear', 'rbf', 'poly'],
    'gamma': uniform(0.001, 1)
}

random_search = RandomizedSearchCV(
    estimator=SVC(),
    param_distributions=param_distributions,
    n_iter=100,
    cv=5,
    scoring='accuracy',
    random_state=42
)
```

#### Successive Halving

```python
from sklearn.model_selection import HalvingRandomSearchCV

# Halving Random Search (faster for large parameter spaces)
halving_search = HalvingRandomSearchCV(
    estimator=SVC(),
    param_distributions=param_distributions,
    factor=2,
    random_state=42
)
```

### Performance Metrics

#### Classification Metrics

```python
from sklearn.metrics import accuracy_score, precision_score, recall_score
from sklearn.metrics import f1_score, roc_auc_score, confusion_matrix
from sklearn.metrics import classification_report, roc_curve, precision_recall_curve

# Basic metrics
accuracy = accuracy_score(y_true, y_pred)
precision = precision_score(y_true, y_pred, average='macro')
recall = recall_score(y_true, y_pred, average='macro')
f1 = f1_score(y_true, y_pred, average='macro')

# ROC AUC
roc_auc = roc_auc_score(y_true, y_pred_proba)

# Confusion Matrix
cm = confusion_matrix(y_true, y_pred)

# Comprehensive report
report = classification_report(y_true, y_pred)
```

#### Regression Metrics

```python
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.metrics import explained_variance_score, median_absolute_error

# Regression metrics
mse = mean_squared_error(y_true, y_pred)
rmse = mean_squared_error(y_true, y_pred, squared=False)
mae = mean_absolute_error(y_true, y_pred)
r2 = r2_score(y_true, y_pred)
```

