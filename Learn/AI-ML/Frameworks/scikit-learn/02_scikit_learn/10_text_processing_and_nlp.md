## Text Processing and NLP


### Feature Extraction from Text

```python
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.feature_extraction.text import HashingVectorizer

# Bag of Words
count_vectorizer = CountVectorizer(
    max_features=1000,
    stop_words='english',
    ngram_range=(1, 2)
)
X_counts = count_vectorizer.fit_transform(text_data)

# TF-IDF
tfidf_vectorizer = TfidfVectorizer(
    max_features=1000,
    stop_words='english',
    ngram_range=(1, 2),
    min_df=2,
    max_df=0.8
)
X_tfidf = tfidf_vectorizer.fit_transform(text_data)
```

### Text Classification Pipeline

```python
# Complete text classification pipeline
text_pipeline = Pipeline([
    ('tfidf', TfidfVectorizer(stop_words='english')),
    ('classifier', MultinomialNB())
])

text_pipeline.fit(text_train, y_train)
predictions = text_pipeline.predict(text_test)
```

