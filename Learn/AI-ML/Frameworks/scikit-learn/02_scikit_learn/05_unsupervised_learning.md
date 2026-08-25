## Unsupervised Learning


### Clustering Algorithms

#### K-Means and Variants

```python
from sklearn.cluster import KMeans, MiniBatchKMeans, BisectingKMeans

# K-Means clustering
kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
cluster_labels = kmeans.fit_predict(X)

# Mini-batch K-Means for large datasets
mb_kmeans = MiniBatchKMeans(n_clusters=3, batch_size=100)
mb_cluster_labels = mb_kmeans.fit_predict(X)
```

#### Hierarchical Clustering

```python
from sklearn.cluster import AgglomerativeClustering
from scipy.cluster.hierarchy import dendrogram, linkage
import matplotlib.pyplot as plt

# Agglomerative clustering
agg_clustering = AgglomerativeClustering(n_clusters=3, linkage='ward')
agg_labels = agg_clustering.fit_predict(X)

# Dendrogram visualization
linkage_matrix = linkage(X, method='ward')
dendrogram(linkage_matrix)
plt.show()
```

#### Density-Based Clustering

```python
from sklearn.cluster import DBSCAN, OPTICS
from sklearn.cluster import MeanShift, estimate_bandwidth

# DBSCAN
dbscan = DBSCAN(eps=0.3, min_samples=10)
dbscan_labels = dbscan.fit_predict(X)

# OPTICS
optics = OPTICS(min_samples=10, xi=0.05)
optics_labels = optics.fit_predict(X)

# Mean Shift
bandwidth = estimate_bandwidth(X, quantile=0.2)
ms = MeanShift(bandwidth=bandwidth)
ms_labels = ms.fit_predict(X)
```

### Dimensionality Reduction

#### Principal Component Analysis

```python
from sklearn.decomposition import PCA, IncrementalPCA, SparsePCA
from sklearn.decomposition import TruncatedSVD

# Standard PCA
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)

# Explained variance ratio
print("Explained variance ratio:", pca.explained_variance_ratio_)

# Incremental PCA for large datasets
inc_pca = IncrementalPCA(n_components=2, batch_size=100)
X_inc_pca = inc_pca.fit_transform(X)
```

#### Manifold Learning

```python
from sklearn.manifold import TSNE, Isomap, LocallyLinearEmbedding
from sklearn.manifold import MDS, SpectralEmbedding

# t-SNE
tsne = TSNE(n_components=2, perplexity=30, random_state=42)
X_tsne = tsne.fit_transform(X)

# Isomap
isomap = Isomap(n_components=2, n_neighbors=10)
X_isomap = isomap.fit_transform(X)

# Locally Linear Embedding
lle = LocallyLinearEmbedding(n_components=2, n_neighbors=10)
X_lle = lle.fit_transform(X)
```

#### Matrix Factorization

```python
from sklearn.decomposition import NMF, FactorAnalysis, FastICA

# Non-negative Matrix Factorization
nmf = NMF(n_components=10, random_state=42)
W = nmf.fit_transform(X)
H = nmf.components_

# Independent Component Analysis
ica = FastICA(n_components=10, random_state=42)
X_ica = ica.fit_transform(X)
```

