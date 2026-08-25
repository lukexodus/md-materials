## Gaussian Mixture Models


Gaussian Mixture Models (GMMs) represent data as a weighted combination of multiple Gaussian distributions, providing flexible parametric density estimation. GMMs can model complex, multimodal distributions and perform soft clustering where points belong probabilistically to multiple clusters.

**Key Points:**

- Models data as linear combination of K Gaussian components with means, covariances, and mixing weights
- Expectation-Maximization (EM) algorithm iteratively optimizes parameters to maximize likelihood
- Supports various covariance types: full, tied, diagonal, spherical for different complexity-efficiency trade-offs
- Provides both density estimation and probabilistic clustering capabilities
- Model selection through information criteria (AIC, BIC) or cross-validation
- Handles missing data naturally through marginalization properties
- Generates new samples by sampling from component distributions

The algorithm alternates between E-step (computing posterior probabilities) and M-step (updating parameters) until convergence. Covariance type selection affects model flexibility - full covariance captures correlations but requires more parameters, while diagonal assumes feature independence.

**Example:**

```python
from sklearn.mixture import GaussianMixture
from sklearn.datasets import make_blobs
from sklearn.model_selection import GridSearchCV
import numpy as np
import matplotlib.pyplot as plt

# Generate multimodal dataset
X, y_true = make_blobs(n_samples=1000, centers=3, n_features=2, 
                       cluster_std=1.5, random_state=42)

# Basic GMM with different component counts
n_components_range = range(1, 8)
models = []
aic_scores = []
bic_scores = []

for n_components in n_components_range:
    gmm = GaussianMixture(n_components=n_components, random_state=42)
    gmm.fit(X)
    models.append(gmm)
    aic_scores.append(gmm.aic(X))
    bic_scores.append(gmm.bic(X))

# Optimal model selection
best_aic = np.argmin(aic_scores) + 1
best_bic = np.argmin(bic_scores) + 1
print(f"Optimal components (AIC): {best_aic}")
print(f"Optimal components (BIC): {best_bic}")

# Fit best model
gmm_best = GaussianMixture(n_components=best_bic, random_state=42)
gmm_best.fit(X)

# Extract model parameters
print(f"Mixing weights: {gmm_best.weights_}")
print(f"Component means shape: {gmm_best.means_.shape}")
print(f"Covariances shape: {gmm_best.covariances_.shape}")

# Probability density estimation
log_likelihood = gmm_best.score_samples(X)
probability_density = np.exp(log_likelihood)

# Probabilistic clustering
cluster_proba = gmm_best.predict_proba(X)
hard_assignments = gmm_best.predict(X)

# Generate new samples
n_samples_generate = 100
new_samples, component_labels = gmm_best.sample(n_samples_generate)

# Different covariance types comparison
covariance_types = ['full', 'tied', 'diag', 'spherical']
covariance_results = {}

for cov_type in covariance_types:
    gmm_cov = GaussianMixture(n_components=3, covariance_type=cov_type, random_state=42)
    gmm_cov.fit(X)
    covariance_results[cov_type] = {
        'aic': gmm_cov.aic(X),
        'bic': gmm_cov.bic(X),
        'log_likelihood': gmm_cov.score(X)
    }

for cov_type, results in covariance_results.items():
    print(f"{cov_type}: AIC={results['aic']:.2f}, BIC={results['bic']:.2f}")
```

GMMs excel at capturing complex probability distributions and provide interpretable parameters. Model selection balances fit quality against overfitting, with BIC typically preferring simpler models than AIC.

