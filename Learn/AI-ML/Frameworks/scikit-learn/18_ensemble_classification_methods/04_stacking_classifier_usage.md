## Stacking Classifier Usage


Stacking trains a meta-classifier to combine predictions from multiple base classifiers, learning optimal combination strategies rather than using simple averaging.

**Key points:**

- Two-level architecture: base classifiers and meta-classifier
- Meta-classifier learns from base classifier predictions
- Uses cross-validation to prevent overfitting in meta-classifier training
- Can capture complex interaction patterns between base classifiers

```python
from sklearn.ensemble import StackingClassifier
from sklearn.linear_model import LogisticRegression, RidgeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC

# Define diverse base classifiers
base_classifiers = [
    ('rf', RandomForestClassifier(n_estimators=100, random_state=42)),
    ('svc', SVC(probability=True, random_state=42)),
    ('lr', LogisticRegression(random_state=42)),
    ('knn', KNeighborsClassifier(n_neighbors=5))
]

# Simple stacking with logistic regression meta-classifier
stacking = StackingClassifier(
    estimators=base_classifiers,
    final_estimator=LogisticRegression(random_state=42),
    cv=5,  # Cross-validation folds for meta-features
    n_jobs=-1
)

stacking.fit(X_train, y_train)
stacking_score = stacking.score(X_test, y_test)

# Advanced stacking with different meta-classifiers
meta_classifiers = [
    LogisticRegression(random_state=42),
    RandomForestClassifier(n_estimators=50, random_state=42),
    SVC(probability=True, random_state=42),
    GradientBoostingClassifier(random_state=42)
]

stacking_results = {}
for name, meta_clf in [('lr', meta_classifiers[0]), ('rf', meta_classifiers[1]), 
                      ('svc', meta_classifiers[2]), ('gb', meta_classifiers[3])]:
    stacking_clf = StackingClassifier(
        estimators=base_classifiers,
        final_estimator=meta_clf,
        cv=5
    )
    stacking_clf.fit(X_train, y_train)
    stacking_results[name] = stacking_clf.score(X_test, y_test)
```

**Multi-level stacking:**

```python
# Create a three-level stacking ensemble
from sklearn.ensemble import GradientBoostingClassifier

# Level 1: Diverse base classifiers
level1_classifiers = [
    ('rf', RandomForestClassifier(n_estimators=100)),
    ('svc', SVC(probability=True)),
    ('lr', LogisticRegression()),
    ('nb', GaussianNB())
]

# Level 2: Intermediate meta-classifiers
level2_rf = StackingClassifier(estimators=level1_classifiers[:2], 
                              final_estimator=LogisticRegression(), cv=3)
level2_svc = StackingClassifier(estimators=level1_classifiers[2:], 
                               final_estimator=LogisticRegression(), cv=3)

level2_classifiers = [
    ('stack_rf', level2_rf),
    ('stack_svc', level2_svc),
    ('gb', GradientBoostingClassifier())
]

# Level 3: Final meta-classifier
final_stacking = StackingClassifier(
    estimators=level2_classifiers,
    final_estimator=LogisticRegression(),
    cv=3
)

final_stacking.fit(X_train, y_train)
```

**Stacking with feature selection:**

```python
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.pipeline import Pipeline

# Create pipelines with feature selection for base classifiers
rf_pipe = Pipeline([
    ('selector', SelectKBest(f_classif, k=15)),
    ('rf', RandomForestClassifier(n_estimators=100))
])

svc_pipe = Pipeline([
    ('selector', SelectKBest(f_classif, k=10)),
    ('svc', SVC(probability=True))
])

# Stacking with feature-selected base classifiers
stacking_fs = StackingClassifier(
    estimators=[
        ('rf_fs', rf_pipe),
        ('svc_fs', svc_pipe),
        ('lr', LogisticRegression())
    ],
    final_estimator=LogisticRegression(),
    cv=5,
    passthrough=True  # Include original features in meta-classifier
)
```

