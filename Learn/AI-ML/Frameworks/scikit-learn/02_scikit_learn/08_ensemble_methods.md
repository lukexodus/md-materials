## Ensemble Methods


### Voting Classifiers

```python
from sklearn.ensemble import VotingClassifier, VotingRegressor

# Hard voting
voting_clf_hard = VotingClassifier([
    ('lr', LogisticRegression()),
    ('rf', RandomForestClassifier()),
    ('svc', SVC())
], voting='hard')

# Soft voting (requires probability estimates)
voting_clf_soft = VotingClassifier([
    ('lr', LogisticRegression()),
    ('rf', RandomForestClassifier()),
    ('svc', SVC(probability=True))
], voting='soft')
```

### Bagging and Boosting

```python
from sklearn.ensemble import BaggingClassifier, AdaBoostClassifier
from sklearn.ensemble import GradientBoostingClassifier

# Bagging
bagging_clf = BaggingClassifier(
    base_estimator=DecisionTreeClassifier(),
    n_estimators=10,
    random_state=42
)

# AdaBoost
ada_clf = AdaBoostClassifier(
    base_estimator=DecisionTreeClassifier(max_depth=1),
    n_estimators=50,
    random_state=42
)

# Gradient Boosting
gb_clf = GradientBoostingClassifier(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=3
)
```

### Stacking

```python
from sklearn.ensemble import StackingClassifier, StackingRegressor

# Stacking classifier
base_models = [
    ('rf', RandomForestClassifier()),
    ('svc', SVC(probability=True)),
    ('nb', GaussianNB())
]

stacking_clf = StackingClassifier(
    estimators=base_models,
    final_estimator=LogisticRegression(),
    cv=5
)
```

