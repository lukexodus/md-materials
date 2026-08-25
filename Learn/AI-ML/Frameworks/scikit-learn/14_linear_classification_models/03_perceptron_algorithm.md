## Perceptron Algorithm


The perceptron is the simplest linear classifier, forming the building block for neural networks and serving as an excellent educational tool for understanding linear separation.

**Key points:**

- Binary linear classifier using the perceptron learning rule
- Updates weights only when misclassification occurs
- Guaranteed to converge for linearly separable data
- No probabilistic output, only hard classifications

```python
from sklearn.linear_model import Perceptron

# Basic perceptron implementation
perceptron = Perceptron(alpha=0.01, max_iter=1000, tol=1e-3)
perceptron.fit(X_train_scaled, y_train)

# Access learned parameters
weights = perceptron.coef_
bias = perceptron.intercept_
n_updates = perceptron.n_iter_
```

**Mathematical foundation:**

- Weight update rule: w = w + α(y - ŷ)x
- Decision function: f(x) = sign(w·x + b)
- Margin-based learning with simple error correction

**Example** of perceptron decision boundary visualization:

```python
import matplotlib.pyplot as plt
import numpy as np

def plot_perceptron_boundary(perceptron, X, y):
    h = 0.01
    x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
    y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                         np.arange(y_min, y_max, h))
    
    Z = perceptron.predict(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)
    
    plt.contourf(xx, yy, Z, alpha=0.8)
    scatter = plt.scatter(X[:, 0], X[:, 1], c=y, edgecolors='black')
    plt.xlabel('Feature 1')
    plt.ylabel('Feature 2')
    plt.title('Perceptron Decision Boundary')
```

