## GaussianMixture Model-based Clustering


GaussianMixture implements probabilistic clustering using Gaussian Mixture Models (GMM), representing data as a mixture of multivariate Gaussian distributions with cluster membership probabilities.

### Probabilistic Foundation

GMM assumes data originates from K Gaussian components, each characterized by mean μₖ, covariance matrix Σₖ, and mixture weight πₖ. The Expectation-Maximization (EM) algorithm iteratively estimates these parameters by maximizing data likelihood.

### Parameter Configuration

The `n_components` parameter specifies the number of Gaussian components. The `covariance_type` parameter controls covariance matrix structure: 'full' (complete covariance), 'tied' (shared across components), 'diag' (diagonal), or 'spherical' (scalar). Different types balance model flexibility with computational complexity.

**Example:**

```python
from sklearn.mixture import GaussianMixture
from sklearn.datasets import make_blobs
import matplotlib.pyplot as plt
import numpy as np

# Generate multi-modal data
X, y_true = make_blobs(n_samples=300, centers=4, cluster_std=0.6, 
                       center_box=(-10.0, 10.0), random_state=42)

# Gaussian Mixture Model
gmm = GaussianMixture(
    n_components=4,
    covariance_type='full',
    max_iter=100,
    random_state=42,
    init_params='kmeans'
)

gmm.fit(X)
cluster_labels = gmm.predict(X)
probabilities = gmm.predict_proba(X)

# Model parameters
print(f"Converged: {gmm.converged_}")
print(f"Log likelihood: {gmm.lower_bound_}")
print(f"AIC: {gmm.aic(X)}")
print(f"BIC: {gmm.bic(X)}")
```

### Model Selection

Information criteria help determine optimal component numbers. Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC) balance model fit with complexity. Lower values indicate better models, with BIC penalizing complexity more heavily than AIC.

### Advanced Features

The `weights_init`, `means_init`, and `precisions_init` parameters enable custom initialization strategies. The `warm_start` parameter allows incremental fitting for large datasets. Regularization through `reg_covar` prevents singular covariance matrices in high-dimensional spaces.

### Density Estimation

GMM provides probability density estimation through the `score_samples` method, enabling outlier detection and probability density visualization. The `sample` method generates new data points following the learned distribution.

