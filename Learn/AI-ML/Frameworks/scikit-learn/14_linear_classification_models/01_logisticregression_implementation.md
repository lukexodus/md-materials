## LogisticRegression Implementation


Logistic regression uses the logistic function to model the probability of class membership, making it one of the most interpretable classification algorithms.

**Key points:**

- Uses maximum likelihood estimation with gradient descent optimization
- Outputs probabilities through the sigmoid function: p = 1/(1 + e^(-z))
- Supports binary and multiclass classification through one-vs-rest or multinomial approaches
- Includes built-in regularization (L1, L2, or Elastic Net) to prevent overfitting

```python
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

# Generate sample data
X, y = make_classification(n_samples=1000, n_features=20, n_classes=2, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Initialize with different regularization options
lr_l2 = LogisticRegression(penalty='l2', C=1.0, solver='lbfgs')
lr_l1 = LogisticRegression(penalty='l1', C=1.0, solver='liblinear')
lr_elastic = LogisticRegression(penalty='elasticnet', C=1.0, solver='saga', l1_ratio=0.5)

# Fit and predict
lr_l2.fit(X_train, y_train)
probabilities = lr_l2.predict_proba(X_test)
predictions = lr_l2.predict(X_test)
```

**Important parameters:**

- `C`: Inverse regularization strength (smaller values = stronger regularization)
- `penalty`: Regularization type ('l1', 'l2', 'elasticnet', 'none')
- `solver`: Algorithm for optimization ('lbfgs', 'liblinear', 'saga', 'sag', 'newton-cg')
- `max_iter`: Maximum iterations for convergence
- `multi_class`: Strategy for multiclass problems ('auto', 'ovr', 'multinomial')

