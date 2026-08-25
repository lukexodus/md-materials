## MultinomialNB Text Classification


MultinomialNB implements Naive Bayes for multinomial distributed data, primarily designed for text classification with discrete feature counts.

### Mathematical Model

The algorithm models feature counts as multinomial distributions. For text data, features represent word frequencies or TF-IDF values. The likelihood P(x_i|y) follows a multinomial distribution with parameters estimated from training data.

### Smoothing Parameters

The `alpha` parameter implements additive (Laplace) smoothing to handle zero probabilities for unseen features. Higher alpha values increase smoothing, while alpha=0 disables smoothing. The `fit_prior` parameter controls whether class priors are learned from data or assumed uniform.

**Example:**

```python
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.pipeline import Pipeline

# Text classification pipeline
text_data = [
    "This movie is excellent and entertaining",
    "Terrible film with poor acting",
    "Outstanding performance by the lead actor",
    "Boring and predictable plot"
]
labels = [1, 0, 1, 0]  # 1: positive, 0: negative

# Count vectorization approach
count_pipeline = Pipeline([
    ('vectorizer', CountVectorizer(stop_words='english')),
    ('classifier', MultinomialNB(alpha=1.0))
])

# TF-IDF approach
tfidf_pipeline = Pipeline([
    ('vectorizer', TfidfVectorizer(stop_words='english')),
    ('classifier', MultinomialNB(alpha=1.0))
])

count_pipeline.fit(text_data, labels)
tfidf_pipeline.fit(text_data, labels)
```

### Feature Engineering Considerations

MultinomialNB works best with non-negative feature values representing counts or frequencies. TF-IDF vectorization requires careful handling since TF-IDF can produce negative values with certain configurations. The algorithm naturally handles sparse matrices efficiently.

### Performance Optimization

The algorithm's computational complexity scales linearly with feature dimensions and training samples. Memory usage remains efficient even with high-dimensional sparse features. The `class_log_prior_` and `feature_log_prob_` attributes store learned parameters for inspection.

