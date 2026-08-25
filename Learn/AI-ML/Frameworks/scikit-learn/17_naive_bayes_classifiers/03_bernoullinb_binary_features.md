## BernoulliNB Binary Features


BernoulliNB implements Naive Bayes for binary/boolean features, modeling each feature as a Bernoulli distribution indicating feature presence or absence.

### Binary Feature Modeling

The algorithm models P(x_i|y) as Bernoulli distributions with class-specific parameters p_iy representing the probability of feature i being present in class y. Features are binarized using a threshold, typically 0.0.

### Binarization Process

The `binarize` parameter controls the threshold for converting continuous values to binary features. Features above the threshold become 1, while features below become 0. Setting `binarize=None` assumes input features are already binary.

**Example:**

```python
from sklearn.naive_bayes import BernoulliNB
import numpy as np

# Binary feature data
X_binary = np.array([
    [1, 0, 1, 1, 0],
    [0, 1, 1, 0, 1],
    [1, 1, 0, 1, 1],
    [0, 0, 1, 0, 0]
])
y_binary = np.array([1, 0, 1, 0])

# Bernoulli Naive Bayes
bnb = BernoulliNB(alpha=1.0, binarize=0.0)
bnb.fit(X_binary, y_binary)

# For continuous features requiring binarization
X_continuous = np.random.rand(100, 5)
y_continuous = np.random.randint(0, 2, 100)

bnb_continuous = BernoulliNB(alpha=1.0, binarize=0.5)
bnb_continuous.fit(X_continuous, y_continuous)
```

### Text Classification Applications

BernoulliNB excels in document classification when focusing on word presence rather than frequency. This approach works well for short texts, spam detection, and sentiment analysis where word occurrence matters more than count.

### Comparison with MultinomialNB

BernoulliNB considers feature absence explicitly in probability calculations, while MultinomialNB focuses on feature counts. For text classification, BernoulliNB often performs better on shorter documents, while MultinomialNB excels with longer texts where word frequency provides valuable information.

