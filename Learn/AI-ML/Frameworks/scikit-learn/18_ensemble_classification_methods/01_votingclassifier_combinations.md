## VotingClassifier Combinations


VotingClassifier aggregates predictions from multiple diverse classifiers using either hard voting (majority class) or soft voting (average probabilities) to make final predictions.

**Key points:**

- Hard voting: Uses predicted class labels from each classifier
- Soft voting: Averages predicted probabilities (generally more effective)
- Works best when base classifiers have similar performance but different biases
- Requires diverse base classifiers to maximize ensemble benefits

```python
from sklearn.ensemble import VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split, cross_val_score

# Create diverse dataset
X, y = make_classification(n_samples=1000, n_features=20, n_informative=15, 
                          n_redundant=5, n_classes=3, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Define diverse base classifiers
lr = LogisticRegression(random_state=42)
svm = SVC(probability=True, random_state=42)  # Enable probability for soft voting
dt = DecisionTreeClassifier(random_state=42)
knn = KNeighborsClassifier(n_neighbors=5)
nb = GaussianNB()

# Hard voting classifier
voting_hard = VotingClassifier(
    estimators=[('lr', lr), ('svm', svm), ('dt', dt), ('knn', knn), ('nb', nb)],
    voting='hard'
)

# Soft voting classifier (usually performs better)
voting_soft = VotingClassifier(
    estimators=[('lr', lr), ('svm', svm), ('dt', dt), ('knn', knn), ('nb', nb)],
    voting='soft'
)

# Train and evaluate
voting_soft.fit(X_train, y_train)
soft_score = voting_soft.score(X_test, y_test)

# Compare individual classifiers vs ensemble
for name, clf in voting_soft.named_estimators_.items():
    individual_score = clf.score(X_test, y_test)
    print(f"{name}: {individual_score:.4f}")
print(f"Soft Voting Ensemble: {soft_score:.4f}")
```

**Advanced VotingClassifier techniques:**

```python
# Weighted voting based on individual performance
weights = []
for name, clf in [('lr', lr), ('svm', svm), ('dt', dt), ('knn', knn), ('nb', nb)]:
    cv_scores = cross_val_score(clf, X_train, y_train, cv=5)
    weights.append(cv_scores.mean())

# Create weighted ensemble
voting_weighted = VotingClassifier(
    estimators=[('lr', lr), ('svm', svm), ('dt', dt), ('knn', knn), ('nb', nb)],
    voting='soft',
    weights=weights
)

# Dynamic classifier selection
from sklearn.base import BaseEstimator, ClassifierMixin
class SelectiveBestVoting(BaseEstimator, ClassifierMixin):
    def __init__(self, estimators, threshold=0.1):
        self.estimators = estimators
        self.threshold = threshold
        
    def fit(self, X, y):
        self.classifiers_ = []
        self.performances_ = []
        
        for name, clf in self.estimators:
            clf.fit(X, y)
            score = cross_val_score(clf, X, y, cv=3).mean()
            if score >= max([cross_val_score(c, X, y, cv=3).mean() 
                           for _, c in self.estimators]) - self.threshold:
                self.classifiers_.append(clf)
                self.performances_.append(score)
        return self
    
    def predict_proba(self, X):
        probas = np.array([clf.predict_proba(X) for clf in self.classifiers_])
        weights = np.array(self.performances_)
        return np.average(probas, axis=0, weights=weights)
    
    def predict(self, X):
        return np.argmax(self.predict_proba(X), axis=1)
```

