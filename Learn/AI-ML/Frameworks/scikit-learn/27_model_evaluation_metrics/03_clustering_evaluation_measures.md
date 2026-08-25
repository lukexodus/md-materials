## Clustering Evaluation Measures


### External Validation Metrics

**Adjusted Rand Index (ARI)** measures similarity between true and predicted clusterings, adjusted for chance. ARI ranges from -1 to 1, where 1 indicates perfect clustering and 0 represents random labeling.

**Normalized Mutual Information (NMI)** quantifies information shared between true and predicted clusters, normalized to account for different numbers of clusters.

```python
from sklearn.metrics import adjusted_rand_score, normalized_mutual_info_score
from sklearn.metrics import fowlkes_mallows_score, homogeneity_completeness_v_measure

ari = adjusted_rand_score(true_labels, predicted_labels)
nmi = normalized_mutual_info_score(true_labels, predicted_labels)
fm = fowlkes_mallows_score(true_labels, predicted_labels)
homogeneity, completeness, v_measure = homogeneity_completeness_v_measure(true_labels, predicted_labels)
```

**Fowlkes-Mallows Index** measures similarity using geometric mean of precision and recall computed on pairs of samples. **V-measure** harmonically averages homogeneity and completeness, where homogeneity ensures clusters contain only members of single classes, and completeness ensures class members are assigned to single clusters.

### Internal Validation Metrics

**Silhouette analysis** evaluates clustering quality by measuring how similar objects are to their own cluster compared to other clusters. Silhouette scores range from -1 to 1, where high values indicate well-separated clusters.

**Calinski-Harabasz Index** computes the ratio of between-cluster dispersion to within-cluster dispersion. Higher values generally indicate better clustering.

**Davies-Bouldin Index** measures average similarity between each cluster and its most similar cluster. Lower values indicate better clustering with well-separated, compact clusters.

```python
from sklearn.metrics import silhouette_score, silhouette_samples
from sklearn.metrics import calinski_harabasz_score, davies_bouldin_score

silhouette_avg = silhouette_score(X, cluster_labels)
silhouette_samples = silhouette_samples(X, cluster_labels)
ch_score = calinski_harabasz_score(X, cluster_labels)
db_score = davies_bouldin_score(X, cluster_labels)
```

### Distance-Based Metrics

**Contingency matrices** provide detailed breakdowns of clustering assignments against true labels, enabling calculation of various similarity measures. These matrices form the foundation for computing most external clustering validation metrics.

```python
from sklearn.metrics.cluster import contingency_matrix
contingency = contingency_matrix(true_labels, predicted_labels)
```

