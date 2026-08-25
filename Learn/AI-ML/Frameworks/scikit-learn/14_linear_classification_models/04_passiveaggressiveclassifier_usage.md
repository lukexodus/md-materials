## PassiveAggressiveClassifier Usage


Passive-Aggressive algorithms are online learning algorithms that remain passive for correct classifications but become aggressive when encountering mistakes.

**Key points:**

- Designed for online learning with potentially adversarial data
- Maintains large margins while being conservative with updates
- Three variants: PA, PA-I (with slack), PA-II (with squared slack penalty)
- Excellent for text classification and streaming data

```python
from sklearn.linear_model import PassiveAggressiveClassifier

# Different PA variants
pa = PassiveAggressiveClassifier(C=1.0)  # PA-I
pa_ii = PassiveAggressiveClassifier(C=1.0, loss='squared_hinge')  # PA-II

# Typical usage for text classification
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.datasets import fetch_20newsgroups

# Load text data
newsgroups_train = fetch_20newsgroups(subset='train', categories=['alt.atheism', 'talk.religion.misc'])
newsgroups_test = fetch_20newsgroups(subset='test', categories=['alt.atheism', 'talk.religion.misc'])

# Vectorize text
vectorizer = TfidfVectorizer(max_features=10000, stop_words='english')
X_train_text = vectorizer.fit_transform(newsgroups_train.data)
X_test_text = vectorizer.transform(newsgroups_test.data)

# Train PA classifier
pa_text = PassiveAggressiveClassifier(max_iter=1000, random_state=42)
pa_text.fit(X_train_text, newsgroups_train.target)
```

**Update rules:**

- **PA**: τ = min(C, loss/||x||²)
- **PA-I**: τ = min(C, loss/(||x||² + 1/(2C)))
- **PA-II**: τ = loss/(||x||² + 1/(2C))

**Advanced applications:**

```python
# Online learning with concept drift
pa_online = PassiveAggressiveClassifier(max_iter=1)
for X_batch, y_batch in data_stream:
    pa_online.partial_fit(X_batch, y_batch)
    if should_evaluate:
        accuracy = pa_online.score(X_validation, y_validation)
```

