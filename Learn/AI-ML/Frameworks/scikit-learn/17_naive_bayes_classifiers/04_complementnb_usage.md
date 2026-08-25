## ComplementNB Usage


ComplementNB implements the Complement Naive Bayes algorithm, designed to correct imbalanced dataset issues in standard Multinomial Naive Bayes by using complement class information.

### Algorithmic Innovation

Instead of estimating P(x_i|y) for each class y, ComplementNB estimates parameters from the complement of each class (all samples not belonging to class y). This approach reduces bias toward frequent classes in imbalanced datasets.

### Weight Normalization

ComplementNB applies weight normalization to prevent longer documents from dominating classification decisions. The algorithm normalizes feature weights by document length, improving performance on variable-length texts.

**Example:**

```python
from sklearn.naive_bayes import ComplementNB
from sklearn.datasets import fetch_20newsgroups
from sklearn.feature_extraction.text import TfidfVectorizer

# Imbalanced text classification
categories = ['alt.atheism', 'comp.graphics', 'sci.space']
newsgroups = fetch_20newsgroups(subset='train', categories=categories)

# Create imbalanced dataset
X_text = newsgroups.data
y_text = newsgroups.target

vectorizer = TfidfVectorizer(stop_words='english', max_features=10000)
X_tfidf = vectorizer.fit_transform(X_text)

# Complement Naive Bayes
cnb = ComplementNB(alpha=1.0, norm=True)
cnb.fit(X_tfidf, y_text)

# Compare with standard MultinomialNB
mnb = MultinomialNB(alpha=1.0)
mnb.fit(X_tfidf, y_text)
```

### Performance Benefits

ComplementNB typically outperforms MultinomialNB on imbalanced text classification tasks. The algorithm shows improved stability and reduced variance in class probability estimates. The `norm` parameter enables weight normalization, which often improves performance.

### Parameter Configuration

The `alpha` parameter provides smoothing similar to MultinomialNB. The `norm` parameter controls weight normalization, typically improving performance when enabled. The algorithm works exclusively with non-negative features.

