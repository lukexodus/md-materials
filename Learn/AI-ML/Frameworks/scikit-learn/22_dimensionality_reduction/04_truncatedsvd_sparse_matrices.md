## TruncatedSVD Sparse Matrices


TruncatedSVD performs dimensionality reduction on sparse matrices efficiently, commonly used in text processing and recommender systems where standard PCA is computationally prohibitive.

**Key points:**

- Efficient for sparse matrices (doesn't require dense conversion)
- Uses randomized SVD algorithms for scalability
- Doesn't center data (preserves sparsity)
- Excellent for text data and collaborative filtering

```python
from sklearn.decomposition import TruncatedSVD
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.datasets import fetch_20newsgroups
import scipy.sparse as sp

# Load text dataset
newsgroups = fetch_20newsgroups(subset='train', categories=[
    'alt.atheism', 'talk.religion.misc', 'comp.graphics', 'sci.space'
])

# Create sparse TF-IDF matrix
vectorizer = TfidfVectorizer(max_features=10000, stop_words='english', max_df=0.95, min_df=2)
X_sparse = vectorizer.fit_transform(newsgroups.data)

print(f"Sparse matrix shape: {X_sparse.shape}")
print(f"Sparsity: {(1 - X_sparse.nnz / (X_sparse.shape[0] * X_sparse.shape[1])):.3%}")

# Apply TruncatedSVD
tsvd = TruncatedSVD(n_components=100, algorithm='randomized', random_state=42)
X_tsvd = tsvd.fit_transform(X_sparse)

print(f"Explained variance ratio (first 10): {tsvd.explained_variance_ratio_[:10]}")
print(f"Total variance explained: {tsvd.explained_variance_ratio_.sum():.3f}")

# Analyze components
feature_names = vectorizer.get_feature_names_out()

def display_topics(model, feature_names, n_top_words=10):
    """Display top words for each component"""
    for topic_idx, topic in enumerate(model.components_[:5]):  # Show first 5 topics
        top_words_idx = topic.argsort()[-n_top_words:][::-1]
        top_words = [feature_names[i] for i in top_words_idx]
        print(f"Topic {topic_idx}: {' '.join(top_words)}")

display_topics(tsvd, feature_names)
```

**Comparison with different SVD algorithms:**

```python
import time

# Compare different algorithms
algorithms = ['randomized', 'arpack']
results = {}

for algorithm in algorithms:
    print(f"\nTesting {algorithm} algorithm:")
    
    start_time = time.time()
    tsvd_alg = TruncatedSVD(n_components=50, algorithm=algorithm, random_state=42)
    X_transformed = tsvd_alg.fit_transform(X_sparse)
    fit_time = time.time() - start_time
    
    results[algorithm] = {
        'fit_time': fit_time,
        'explained_variance': tsvd_alg.explained_variance_ratio_.sum(),
        'model': tsvd_alg
    }
    
    print(f"Fit time: {fit_time:.3f}s")
    print(f"Explained variance: {tsvd_alg.explained_variance_ratio_.sum():.3f}")

# Visualize results
plt.figure(figsize=(15, 5))

# Explained variance comparison
plt.subplot(1, 3, 1)
for alg in algorithms:
    var_ratios = results[alg]['model'].explained_variance_ratio_
    plt.plot(np.cumsum(var_ratios), label=f'{alg} (total: {var_ratios.sum():.3f})')
plt.xlabel('Component')
plt.ylabel('Cumulative Explained Variance')
plt.legend()
plt.title('SVD Algorithm Comparison')

# Performance comparison
plt.subplot(1, 3, 2)
algs = list(results.keys())
times = [results[alg]['fit_time'] for alg in algs]
plt.bar(algs, times)
plt.ylabel('Fit Time (seconds)')
plt.title('Algorithm Performance')

# Component analysis
plt.subplot(1, 3, 3)
plt.plot(results['randomized']['model'].singular_values_[:20], 'bo-', label='Singular Values')
plt.xlabel('Component')
plt.ylabel('Singular Value')
plt.title('Singular Values (Randomized SVD)')
plt.yscale('log')
plt.grid(True)

plt.tight_layout()
```

**LSA (Latent Semantic Analysis) implementation:**

```python
def perform_lsa(documents, n_components=100, max_features=10000):
    """Perform Latent Semantic Analysis"""
    
    # Vectorize documents
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        stop_words='english',
        max_df=0.95,
        min_df=2,
        use_idf=True
    )
    
    doc_term_matrix = vectorizer.fit_transform(documents)
    
    # Apply TruncatedSVD
    lsa_model = TruncatedSVD(n_components=n_components, random_state=42)
    doc_topic_matrix = lsa_model.fit_transform(doc_term_matrix)
    
    return {
        'vectorizer': vectorizer,
        'lsa_model': lsa_model,
        'doc_term_matrix': doc_term_matrix,
        'doc_topic_matrix': doc_topic_matrix,
        'feature_names': vectorizer.get_feature_names_out()
    }

# Document similarity using LSA
lsa_results = perform_lsa(newsgroups.data, n_components=50)

# Calculate document similarities in reduced space
from sklearn.metrics.pairwise import cosine_similarity

doc_similarities = cosine_similarity(lsa_results['doc_topic_matrix'][:100])

# Find most similar documents
def find_similar_documents(doc_index, similarities, documents, n_similar=3):
    """Find most similar documents to a given document"""
    sim_scores = list(enumerate(similarities[doc_index]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)
    
    print(f"Original document {doc_index}:")
    print(documents[doc_index][:200] + "...\n")
    
    print("Most similar documents:")
    for i, (doc_idx, score) in enumerate(sim_scores[1:n_similar+1]):
        print(f"{i+1}. Document {doc_idx} (similarity: {score:.3f}):")
        print(documents[doc_idx][:200] + "...\n")

find_similar_documents(0, doc_similarities, newsgroups.data)
```

**Incremental TruncatedSVD for streaming data:**

```python
class IncrementalTruncatedSVD:
    def __init__(self, n_components, chunk_size=1000):
        self.n_components = n_components
        self.chunk_size = chunk_size
        self.components_ = None
        self.mean_ = None
        self.n_samples_seen_ = 0
    
    def partial_fit(self, X):
        """Incrementally fit SVD model"""
        if self.components_ is None:
            # Initialize with first chunk
            tsvd = TruncatedSVD(n_components=self.n_components)
            self.components_ = tsvd.fit(X).components_
            self.n_samples_seen_ = X.shape[0]
        else:
            # Update with new data (simplified approach)
            # In practice, you'd use more sophisticated online SVD algorithms
            X_combined = sp.vstack([self._reconstruct_data(), X])
            tsvd = TruncatedSVD(n_components=self.n_components)
            self.components_ = tsvd.fit(X_combined).components_
            self.n_samples_seen_ += X.shape[0]
    
    def _reconstruct_data(self):
        # Simplified reconstruction for demonstration
        # Real implementation would maintain sufficient statistics
        return sp.random(self.n_samples_seen_, self.components_.shape[1], density=0.1)
    
    def transform(self, X):
        """Transform data using learned components"""
        if self.components_ is None:
            raise ValueError("Model not fitted yet")
        return X @ self.components_.T

# **Example** usage (conceptual)
# incremental_tsvd = IncrementalTruncatedSVD(n_components=50)
# for chunk in data_chunks:
#     incremental_tsvd.partial_fit(chunk)
```

