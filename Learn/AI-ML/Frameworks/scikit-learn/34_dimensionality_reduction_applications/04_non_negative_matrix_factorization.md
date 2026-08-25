## Non-negative Matrix Factorization


Non-negative Matrix Factorization (NMF) decomposes data into non-negative factors, making it particularly suitable for data where negative values don't make sense, such as images, text, and audio signals.

**Key points:**

- Constrains all factors to be non-negative
- Often produces more interpretable results than PCA
- Natural for sparse, parts-based representations
- Excellent for topic modeling and image analysis
- Cannot handle negative input values

```python
from sklearn.decomposition import NMF
from sklearn.datasets import fetch_20newsgroups
from sklearn.feature_extraction.text import TfidfVectorizer
import numpy as np

# Text Analysis with NMF
# Load subset of 20 newsgroups dataset
categories = ['alt.atheism', 'sci.space', 'comp.graphics', 'rec.sport.baseball']
newsgroups = fetch_20newsgroups(subset='train', categories=categories, 
                               remove=('headers', 'footers', 'quotes'))

# Vectorize text data
vectorizer = TfidfVectorizer(max_features=1000, stop_words='english', 
                           max_df=0.8, min_df=5)
X_text = vectorizer.fit_transform(newsgroups.data)
feature_names = vectorizer.get_feature_names_out()

# Apply NMF for topic modeling
n_topics = 4
nmf = NMF(n_components=n_topics, random_state=42, max_iter=100)
W = nmf.fit_transform(X_text)  # Document-topic matrix
H = nmf.components_  # Topic-word matrix

def display_topics(H, feature_names, n_top_words=10):
    """Display top words for each topic"""
    for topic_idx, topic in enumerate(H):
        top_words_idx = topic.argsort()[-n_top_words:][::-1]
        top_words = [feature_names[i] for i in top_words_idx]
        top_weights = topic[top_words_idx]
        
        print(f"\nTopic {topic_idx + 1}:")
        for word, weight in zip(top_words, top_weights):
            print(f"  {word}: {weight:.4f}")

display_topics(H, feature_names)

# Document-topic distribution analysis
print(f"\nDocument-topic distributions shape: {W.shape}")
print(f"Average topic concentration per document: {np.mean(W, axis=0)}")

# Compare with PCA on same text data
pca_text = PCA(n_components=n_topics)
X_text_dense = X_text.toarray()  # PCA needs dense matrix
W_pca = pca_text.fit_transform(X_text_dense)

print(f"\nNMF vs PCA on text data:")
print(f"NMF - All values non-negative: {np.all(W >= 0)}")
print(f"PCA - Contains negative values: {np.any(W_pca < 0)}")
```

**Image analysis with NMF:**

```python
# Apply NMF to face images for parts-based decomposition
faces = fetch_olivetti_faces(shuffle=True, random_state=42)
X_faces = faces.data

# NMF requires non-negative data
X_faces_normalized = (X_faces - X_faces.min()) / (X_faces.max() - X_faces.min())

# Apply NMF
nmf_faces = NMF(n_components=25, random_state=42, max_iter=200)
W_faces = nmf_faces.fit_transform(X_faces_normalized)
H_faces = nmf_faces.components_

# Visualize NMF components (facial parts)
fig, axes = plt.subplots(5, 5, figsize=(12, 12))
for i, ax in enumerate(axes.flat):
    if i < 25:
        ax.imshow(H_faces[i].reshape(64, 64), cmap='gray')
        ax.set_title(f'Component {i+1}')
    ax.axis('off')
plt.suptitle('NMF Components: Facial Parts')
plt.tight_layout()
plt.show()

# Reconstruct faces using NMF components
def reconstruct_face(face_idx, W, H):
    """Reconstruct a face using NMF factorization"""
    return np.dot(W[face_idx:face_idx+1], H).reshape(64, 64)

# Show original vs reconstructed faces
fig, axes = plt.subplots(2, 5, figsize=(15, 6))
for i in range(5):
    # Original
    axes[0, i].imshow(X_faces_normalized[i].reshape(64, 64), cmap='gray')
    axes[0, i].set_title(f'Original {i+1}')
    axes[0, i].axis('off')
    
    # Reconstructed
    reconstructed = reconstruct_face(i, W_faces, H_faces)
    axes[1, i].imshow(reconstructed, cmap='gray')
    axes[1, i].set_title(f'Reconstructed {i+1}')
    axes[1, i].axis('off')

plt.tight_layout()
plt.show()

# Analyze component sparsity
sparsity = np.mean(H_faces == 0)
print(f"Sparsity of NMF components: {sparsity:.4f}")
print(f"Reconstruction error: {nmf_faces.reconstruction_err_:.6f}")
```

