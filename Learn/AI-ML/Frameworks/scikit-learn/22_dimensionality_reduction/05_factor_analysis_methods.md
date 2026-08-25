## Factor Analysis Methods


Factor Analysis models observed variables as linear combinations of unobserved latent factors plus noise, providing probabilistic dimensionality reduction with explicit noise modeling.

**Key points:**

- Probabilistic model with explicit noise terms
- Assumes observed variables are linear combinations of latent factors
- Provides uncertainty quantification for reduced dimensions
- Useful for understanding underlying structure in data

```python
from sklearn.decomposition import FactorAnalysis
from sklearn.datasets import load_iris
import numpy as np

# Load dataset
iris = load_iris()
X = iris.data
X_scaled = StandardScaler().fit_transform(X)

# Basic Factor Analysis
fa = FactorAnalysis(n_components=2, random_state=42)
X_fa = fa.fit_transform(X_scaled)

print(f"Factor loadings shape: {fa.components_.shape}")
print(f"Noise variances: {fa.noise_variances_}")
print(f"Log-likelihood: {fa.score(X_scaled)}")

# Compare with PCA
pca_comp = PCA(n_components=2)
X_pca_comp = pca_comp.fit_transform(X_scaled)

plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.scatter(X_fa[:, 0], X_fa[:, 1], c=iris.target, cmap='viridis')
plt.title('Factor Analysis')
plt.xlabel('Factor 1')
plt.ylabel('Factor 2')

plt.subplot(1, 2, 2)
plt.scatter(X_pca_comp[:, 0], X_pca_comp[:, 1], c=iris.target, cmap='viridis')
plt.title('PCA')
plt.xlabel('PC 1')
plt.ylabel('PC 2')
```

**Model selection and comparison:**

```python
# Compare different numbers of factors
n_factors_range = range(1, X_scaled.shape[1] + 1)
log_likelihoods = []
aic_scores = []
bic_scores = []

for n_factors in n_factors_range:
    fa_temp = FactorAnalysis(n_components=n_factors, random_state=42)
    fa_temp.fit(X_scaled)
    
    ll = fa_temp.score(X_scaled)
    log_likelihoods.append(ll)
    
    # Calculate AIC and BIC
    n_params = n_factors * X_scaled.shape[1] + X_scaled.shape[1]  # Simplified
    aic = -2 * ll + 2 * n_params
    bic = -2 * ll + n_params * np.log(X_scaled.shape[0])
    
    aic_scores.append(aic)
    bic_scores.append(bic)

# Plot model selection criteria
plt.figure(figsize=(15, 5))

plt.subplot(1, 3, 1)
plt.plot(n_factors_range, log_likelihoods, 'bo-')
plt.xlabel('Number of Factors')
plt.ylabel('Log-Likelihood')
plt.title('Factor Analysis Log-Likelihood')
plt.grid(True)

plt.subplot(1, 3, 2)
plt.plot(n_factors_range, aic_scores, 'ro-', label='AIC')
plt.plot(n_factors_range, bic_scores, 'go-', label='BIC')
plt.xlabel('Number of Factors')
plt.ylabel('Information Criterion')
plt.title('Model Selection Criteria')
plt.legend()
plt.grid(True)

plt.subplot(1, 3, 3)
optimal_aic = n_factors_range[np.argmin(aic_scores)]
optimal_bic = n_factors_range[np.argmin(bic_scores)]
plt.axvline(optimal_aic, color='red', linestyle='--', label=f'Optimal AIC: {optimal_aic}')
plt.axvline(optimal_bic, color='green', linestyle='--', label=f'Optimal BIC: {optimal_bic}')
plt.plot(n_factors_range, aic_scores, 'ro-', alpha=0.7)
plt.plot(n_factors_range, bic_scores, 'go-', alpha=0.7)
plt.xlabel('Number of Factors')
plt.ylabel('Information Criterion')
plt.title('Optimal Number of Factors')
plt.legend()
plt.grid(True)

plt.tight_layout()
```

**Factor rotation and interpretation:**

```python
from scipy.linalg import orthogonal_procrustes
from sklearn.preprocessing import normalize

def varimax_rotation(loadings, max_iter=1000, tol=1e-6):
    """Perform Varimax rotation to simplify factor structure"""
    n_vars, n_factors = loadings.shape
    rotation_matrix = np.eye(n_factors)
    
    for _ in range(max_iter):
        # Compute gradient
        loadings_rot = loadings @ rotation_matrix
        u, s, vh = np.linalg.svd(loadings.T @ (loadings_rot**3 - 
                                             loadings_rot @ np.diag(np.sum(loadings_rot**2, axis=0)) / n_vars))
        rotation_update = u @ vh
        
        # Check convergence
        if np.allclose(rotation_matrix, rotation_update, atol=tol):
            break
            
        rotation_matrix = rotation_update
    
    return loadings @ rotation_matrix, rotation_matrix

# Apply Factor Analysis with rotation
fa_detailed = FactorAnalysis(n_components=3, random_state=42)
fa_detailed.fit(X_scaled)

# Original loadings
loadings_original = fa_detailed.components_.T

# Rotated loadings
loadings_rotated, rotation_matrix = varimax_rotation(loadings_original)

print("Original Factor Loadings:")
print(loadings_original)
print("\nRotated Factor Loadings:")
print(loadings_rotated)

# Visualize factor loadings
fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Heatmap of original loadings
im1 = axes[0].imshow(loadings_original.T, cmap='RdBu', aspect='auto', vmin=-1, vmax=1)
axes[0].set_title('Original Factor Loadings')
axes[0].set_xlabel('Variables')
axes[0].set_ylabel('Factors')
axes[0].set_xticks(range(len(iris.feature_names)))
axes[0].set_xticklabels(iris.feature_names, rotation=45)
plt.colorbar(im1, ax=axes[0])

# Heatmap of rotated loadings
im2 = axes[1].imshow(loadings_rotated.T, cmap='RdBu', aspect='auto', vmin=-1, vmax=1)
axes[1].set_title('Rotated Factor Loadings (Varimax)')
axes[1].set_xlabel('Variables')
axes[1].set_ylabel('Factors')
axes[1].set_xticks(range(len(iris.feature_names)))
axes[1].set_xticklabels(iris.feature_names, rotation=45)
plt.colorbar(im2, ax=axes[1])

plt.tight_layout()
```

**Bayesian Factor Analysis:**

```python
from sklearn.decomposition import FactorAnalysis
from scipy import linalg
import warnings

class BayesianFactorAnalysis:
    """Bayesian Factor Analysis with automatic relevance determination"""
    
    def __init__(self, n_components, max_iter=100, tol=1e-6, alpha_prior=1e-3, beta_prior=1e-3):
        self.n_components = n_components
        self.max_iter = max_iter
        self.tol = tol
        self.alpha_prior = alpha_prior
        self.beta_prior = beta_prior
    
    def fit(self, X):
        n_samples, n_features = X.shape
        
        # Initialize parameters
        W = np.random.randn(n_features, self.n_components) * 0.1
        tau = np.ones(n_features)  # Noise precision
        alpha = np.ones(self.n_components)  # Factor precision
        
        log_likelihood_history = []
        
        for iteration in range(self.max_iter):
            # E-step: Update posterior over factors
            Lambda = np.diag(alpha) + W.T @ np.diag(tau) @ W
            Lambda_inv = linalg.inv(Lambda)
            
            # M-step: Update parameters
            # Update W
            for i in range(n_features):
                w_i = tau[i] * Lambda_inv @ W.T @ np.diag(np.eye(n_features)[i]) @ X.T
                W[i] = w_i.mean(axis=1)
            
            # Update tau (noise precision)
            for i in range(n_features):
                residual = X[:, i] - X @ W @ Lambda_inv @ W[i]
                tau[i] = (self.beta_prior + 0.5 * n_samples) / (self.alpha_prior + 0.5 * np.sum(residual**2))
            
            # Update alpha (factor precision) - ARD
            for j in range(self.n_components):
                alpha[j] = (self.beta_prior + 0.5 * n_features) / (self.alpha_prior + 0.5 * np.sum(W[:, j]**2))
            
            # Compute log-likelihood
            log_likelihood = self._compute_log_likelihood(X, W, tau, alpha)
            log_likelihood_history.append(log_likelihood)
            
            # Check convergence
            if iteration > 0 and abs(log_likelihood_history[-1] - log_likelihood_history[-2]) < self.tol:
                break
        
        self.components_ = W.T
        self.noise_variances_ = 1.0 / tau
        self.factor_precisions_ = alpha
        self.log_likelihood_history_ = log_likelihood_history
        
        return self
    
    def _compute_log_likelihood(self, X, W, tau, alpha):
        """Compute approximate log-likelihood"""
        n_samples, n_features = X.shape
        
        # Simplified log-likelihood computation
        residuals = X - X @ W @ W.T
        data_term = -0.5 * np.sum(tau[:, np.newaxis] * residuals**2)
        complexity_term = -0.5 * np.sum(alpha * np.sum(W**2, axis=0))
        
        return data_term + complexity_term
    
    def transform(self, X):
        """Transform data to factor space"""
        Lambda = np.diag(self.factor_precisions_) + self.components_ @ np.diag(1.0/self.noise_variances_) @ self.components_.T
        return X @ self.components_.T @ linalg.inv(Lambda)

# **Example** usage
bfa = BayesianFactorAnalysis(n_components=4)
bfa.fit(X_scaled)

print("Bayesian FA Components shape:", bfa.components_.shape)
print("Factor precisions (higher = less relevant):", bfa.factor_precisions_)
print("Relevant factors (precision < 1.0):", np.sum(bfa.factor_precisions_ < 1.0))

# Plot learning curve
plt.figure(figsize=(10, 6))
plt.plot(bfa.log_likelihood_history_)
plt.xlabel('Iteration')
plt.ylabel('Log-Likelihood')
plt.title('Bayesian Factor Analysis Convergence')
plt.grid(True)
```

**Factor Analysis for mixed data types:**

```python
from sklearn.preprocessing import LabelEncoder

def mixed_factor_analysis(X_continuous, X_categorical, n_components=2):
    """Factor analysis for mixed continuous and categorical data"""
    
    # Encode categorical variables
    encoders = {}
    X_cat_encoded = np.zeros((X_categorical.shape[0], 0))
    
    for i, col in enumerate(X_categorical.T):
        encoder = LabelEncoder()
        encoded = encoder.fit_transform(col)
        # One-hot encode
        n_categories = len(encoder.classes_)
        one_hot = np.eye(n_categories)[encoded]
        X_cat_encoded = np.hstack([X_cat_encoded, one_hot])
        encoders[i] = encoder
    
    # Combine continuous and encoded categorical
    X_combined = np.hstack([X_continuous, X_cat_encoded])
    X_combined_scaled = StandardScaler().fit_transform(X_combined)
    
    # Apply Factor Analysis
    fa = FactorAnalysis(n_components=n_components, random_state=42)
    X_fa = fa.fit_transform(X_combined_scaled)
    
    return {
        'transformed': X_fa,
        'model': fa,
        'encoders': encoders,
        'continuous_indices': list(range(X_continuous.shape[1])),
        'categorical_indices': list(range(X_continuous.shape[1], X_combined.shape[1]))
    }

# **Example** with iris data (treating species as categorical)
X_cont = iris.data
X_cat = iris.target.reshape(-1, 1)

mixed_results = mixed_factor_analysis(X_cont, X_cat, n_components=2)
print("Mixed data factor analysis completed")
print("Transformed shape:", mixed_results['transformed'].shape)
```

**Sparse Factor Analysis:**

```python
from sklearn.linear_model import Lasso

class SparseFactor Analysis:
    """Factor Analysis with sparsity constraints on loadings"""
    
    def __init__(self, n_components, alpha=0.1, max_iter=100):
        self.n_components = n_components
        self.alpha = alpha
        self.max_iter = max_iter
    
    def fit(self, X):
        n_samples, n_features = X.shape
        
        # Initialize with standard Factor Analysis
        fa_init = FactorAnalysis(n_components=self.n_components)
        fa_init.fit(X)
        
        # Use sparse regression to find loadings
        factors = fa_init.transform(X)
        sparse_loadings = np.zeros((n_features, self.n_components))
        
        for i in range(n_features):
            lasso = Lasso(alpha=self.alpha, max_iter=1000)
            lasso.fit(factors, X[:, i])
            sparse_loadings[i] = lasso.coef_
        
        self.components_ = sparse_loadings.T
        self.noise_variances_ = fa_init.noise_variances_
        
        # Compute sparsity metrics
        self.sparsity_ = np.mean(self.components_ == 0)
        
        return self
    
    def transform(self, X):
        """Transform using sparse loadings"""
        # Solve for factors given sparse loadings
        factors = []
        for sample in X:
            # Simplified - in practice would use proper inference
            factor = np.linalg.lstsq(self.components_.T, sample, rcond=None)[0]
            factors.append(factor)
        return np.array(factors)

# Apply sparse factor analysis
sparse_fa = SparseFactorAnalysis(n_components=3, alpha=0.1)
sparse_fa.fit(X_scaled)

print(f"Sparsity level: {sparse_fa.sparsity_:.2%}")
print("Sparse loadings:")
print(sparse_fa.components_)

# Compare sparsity levels
alpha_values = [0.01, 0.05, 0.1, 0.2, 0.5]
sparsity_levels = []

for alpha in alpha_values:
    sparse_fa_temp = SparseFactorAnalysis(n_components=2, alpha=alpha)
    sparse_fa_temp.fit(X_scaled)
    sparsity_levels.append(sparse_fa_temp.sparsity_)

plt.figure(figsize=(10, 6))
plt.plot(alpha_values, sparsity_levels, 'bo-')
plt.xlabel('Regularization Parameter (alpha)')
plt.ylabel('Sparsity Level')
plt.title('Sparsity vs Regularization in Sparse Factor Analysis')
plt.grid(True)
```

**Cross-validation for dimensionality reduction:**

```python
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier

def evaluate_dim_reduction_methods(X, y, methods_dict, cv=5):
    """Compare different dimensionality reduction methods using downstream task performance"""
    
    results = {}
    
    for method_name, (reducer, params_grid) in methods_dict.items():
        best_score = 0
        best_params = None
        
        for params in params_grid:
            # Create pipeline
            if params:
                reducer_instance = reducer(**params)
            else:
                reducer_instance = reducer()
            
            pipeline = Pipeline([
                ('scaler', StandardScaler()),
                ('reducer', reducer_instance),
                ('classifier', RandomForestClassifier(n_estimators=50, random_state=42))
            ])
            
            # Cross-validation
            scores = cross_val_score(pipeline, X, y, cv=cv, scoring='accuracy')
            mean_score = scores.mean()
            
            if mean_score > best_score:
                best_score = mean_score
                best_params = params
        
        results[method_name] = {
            'best_score': best_score,
            'best_params': best_params,
            'std': scores.std()
        }
    
    return results

# Define methods and parameter grids
methods = {
    'PCA': (PCA, [
        {'n_components': 2}, {'n_components': 5}, {'n_components': 10}
    ]),
    'Kernel_PCA_RBF': (KernelPCA, [
        {'n_components': 2, 'kernel': 'rbf', 'gamma': 0.1},
        {'n_components': 5, 'kernel': 'rbf', 'gamma': 0.1}
    ]),
    'Factor_Analysis': (FactorAnalysis, [
        {'n_components': 2}, {'n_components': 5}
    ]),
    'Truncated_SVD': (TruncatedSVD, [
        {'n_components': 2}, {'n_components': 5}
    ])
}

# Evaluate methods (using a subset for faster computation)
X_subset = X[:500]
y_subset = iris.target[:500]

evaluation_results = evaluate_dim_reduction_methods(X_subset, y_subset, methods)

# Display results
print("Dimensionality Reduction Method Comparison:")
print("-" * 50)
for method, results in evaluation_results.items():
    print(f"{method}:")
    print(f"  Best Score: {results['best_score']:.4f} ± {results['std']:.4f}")
    print(f"  Best Params: {results['best_params']}")
    print()
```

**Reconstruction quality assessment:**

```python
def assess_reconstruction_quality(X, methods_list, n_components_range):
    """Assess reconstruction quality for different dimensionality reduction methods"""
    
    results = {}
    X_scaled = StandardScaler().fit_transform(X)
    
    for method_name, method_class in methods_list.items():
        reconstruction_errors = []
        explained_variances = []
        
        for n_comp in n_components_range:
            if method_name == 'KernelPCA':
                # Kernel PCA requires special handling for reconstruction
                method = method_class(n_components=n_comp, kernel='rbf', gamma=0.1)
                X_transformed = method.fit_transform(X_scaled)
                
                # Approximate reconstruction using inverse mapping
                # (simplified - real kernel PCA reconstruction is more complex)
                reconstructed = np.zeros_like(X_scaled)
                reconstruction_error = float('inf')
            else:
                method = method_class(n_components=n_comp)
                X_transformed = method.fit_transform(X_scaled)
                
                if hasattr(method, 'inverse_transform'):
                    X_reconstructed = method.inverse_transform(X_transformed)
                    reconstruction_error = np.mean((X_scaled - X_reconstructed) ** 2)
                else:
                    reconstruction_error = float('inf')
            
            reconstruction_errors.append(reconstruction_error)
            
            # Explained variance (if available)
            if hasattr(method, 'explained_variance_ratio_'):
                explained_var = method.explained_variance_ratio_.sum()
            else:
                explained_var = 0
            
            explained_variances.append(explained_var)
        
        results[method_name] = {
            'reconstruction_errors': reconstruction_errors,
            'explained_variances': explained_variances
        }
    
    return results

# Assess reconstruction quality
reconstruction_methods = {
    'PCA': PCA,
    'Factor_Analysis': FactorAnalysis,
    'Truncated_SVD': TruncatedSVD
}

n_comp_range = range(1, min(11, X.shape[1]))
reconstruction_results = assess_reconstruction_quality(X, reconstruction_methods, n_comp_range)

# Plot results
fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Reconstruction error
axes[0].set_title('Reconstruction Error vs Number of Components')
for method, results in reconstruction_results.items():
    if not all(np.isinf(results['reconstruction_errors'])):
        axes[0].plot(n_comp_range, results['reconstruction_errors'], 'o-', label=method)
axes[0].set_xlabel('Number of Components')
axes[0].set_ylabel('Mean Squared Reconstruction Error')
axes[0].legend()
axes[0].grid(True)
axes[0].set_yscale('log')

# Explained variance
axes[1].set_title('Explained Variance vs Number of Components')
for method, results in reconstruction_results.items():
    if not all(np.array(results['explained_variances']) == 0):
        axes[1].plot(n_comp_range, results['explained_variances'], 's-', label=method)
axes[1].set_xlabel('Number of Components')
axes[1].set_ylabel('Explained Variance Ratio')
axes[1].legend()
axes[1].grid(True)

plt.tight_layout()
```

**Output** summary for comprehensive analysis:

```python
def dimensionality_reduction_summary(X, y=None):
    """Comprehensive summary of dimensionality reduction analysis"""
    
    print("DIMENSIONALITY REDUCTION ANALYSIS SUMMARY")
    print("=" * 50)
    print(f"Dataset shape: {X.shape}")
    print(f"Features: {X.shape[1]}, Samples: {X.shape[0]}")
    
    X_scaled = StandardScaler().fit_transform(X)
    
    # 1. PCA Analysis
    pca_full = PCA()
    pca_full.fit(X_scaled)
    cumvar = np.cumsum(pca_full.explained_variance_ratio_)
    
    print(f"\nPCA ANALYSIS:")
    print(f"- Components for 90% variance: {np.argmax(cumvar >= 0.90) + 1}")
    print(f"- Components for 95% variance: {np.argmax(cumvar >= 0.95) + 1}")
    print(f"- Components for 99% variance: {np.argmax(cumvar >= 0.99) + 1}")
    
    # 2. Intrinsic dimensionality estimation
    eigenvals = pca_full.explained_variance_
    effective_rank = np.sum(eigenvals)**2 / np.sum(eigenvals**2)
    print(f"- Effective rank (participation ratio): {effective_rank:.2f}")
    
    # 3. Factor Analysis comparison
    if X.shape[0] > X.shape[1]:  # More samples than features
        fa = FactorAnalysis(n_components=min(10, X.shape[1]))
        fa.fit(X_scaled)
        fa_ll = fa.score(X_scaled)
        
        pca_comp = PCA(n_components=min(10, X.shape[1]))
        pca_comp.fit(X_scaled)
        
        print(f"\nFACTOR ANALYSIS vs PCA:")
        print(f"- FA log-likelihood: {fa_ll:.3f}")
        print(f"- FA noise variances (avg): {fa.noise_variances_.mean():.6f}")
    
    # 4. Recommendations
    print(f"\nRECOMMENDATIONS:")
    
    if X.shape[1] > 1000:
        print("- Use TruncatedSVD for sparse/high-dimensional data")
        print("- Consider IncrementalPCA for memory efficiency")
    
    if effective_rank < X.shape[1] * 0.5:
        print("- Data has significant redundancy - dimensionality reduction beneficial")
    else:
        print("- Data is relatively low-rank - careful reduction needed")
    
    if y is not None and len(np.unique(y)) > 1:
        print("- Consider supervised methods (LDA) for classification tasks")
    
    sparsity = np.mean(X == 0) if hasattr(X, 'toarray') else np.mean(X == 0)
    if sparsity > 0.5:
        print("- Data is sparse - TruncatedSVD recommended over PCA")

# **Example** usage
dimensionality_reduction_summary(X, iris.target)
```

**Conclusion:** Dimensionality reduction techniques in scikit-learn offer diverse approaches for different data characteristics and requirements. PCA provides optimal linear dimensionality reduction for dense data, IncrementalPCA enables memory-efficient processing of large datasets, KernelPCA captures nonlinear relationships through kernel methods, TruncatedSVD efficiently handles sparse matrices, and Factor Analysis provides probabilistic modeling with explicit noise terms. The choice of method depends on data properties, computational constraints, and specific analysis objectives.

**Next steps:**

- **Manifold learning**: Explore t-SNE, UMAP, and other nonlinear methods for complex data structures
- **Supervised dimensionality reduction**: Apply LDA, CCA, and other supervised techniques
- **Deep autoencoders**: Investigate neural network approaches for nonlinear dimensionality reduction
- **Feature selection**: Combine with univariate and multivariate feature selection methods
- **Streaming algorithms**: Implement online dimensionality reduction for real-time applications

Related topics include manifold learning techniques, autoencoders and variational autoencoders, compressed sensing, and high-dimensional data visualization methods.

---

