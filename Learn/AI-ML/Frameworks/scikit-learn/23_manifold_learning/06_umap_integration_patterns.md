## UMAP Integration Patterns


While UMAP (Uniform Manifold Approximation and Projection) isn't part of scikit-learn core, it's commonly integrated into scikit-learn workflows. UMAP combines topological data analysis with optimization techniques to preserve both local and global structure more effectively than t-SNE.

UMAP constructs fuzzy topological representations of data in high-dimensional and low-dimensional spaces, then optimizes the layout to minimize cross-entropy between these representations. It uses concepts from algebraic topology and Riemannian geometry to better preserve the manifold structure.

Integration patterns include using UMAP as a preprocessing step for scikit-learn classifiers, combining it with clustering algorithms, or using it within pipeline workflows. The `umap-learn` package provides a scikit-learn compatible interface with fit, transform, and fit_transform methods.

**Key points**: UMAP often preserves global structure better than t-SNE; it's faster and scales better to larger datasets; hyperparameters include n_neighbors (local vs global balance) and min_dist (clustering tightness); it supports supervised and semi-supervised variants; reproducible results require setting random state.

Common integration patterns involve dimensionality reduction pipelines where UMAP reduces high-dimensional features before classification, clustering workflows where UMAP visualization guides cluster analysis, and ensemble methods where multiple UMAP embeddings with different parameters provide robust representations.

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import load_digits, make_classification, load_wine
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.cluster import KMeans
from sklearn.metrics import classification_report, adjusted_rand_score
from sklearn.pipeline import Pipeline
from sklearn.manifold import TSNE

# Note: UMAP requires separate installation: pip install umap-learn
try:
    import umap.umap_ as umap
    UMAP_AVAILABLE = True
except ImportError:
    print("UMAP not available. Install with: pip install umap-learn")
    UMAP_AVAILABLE = False
    # Create mock UMAP class for demonstration
    class MockUMAP:
        def __init__(self, **kwargs):
            self.params = kwargs
        def fit_transform(self, X):
            return np.random.randn(X.shape[0], 2)
        def transform(self, X):
            return np.random.randn(X.shape[0], 2)
    umap.UMAP = MockUMAP

# Example 1: UMAP vs t-SNE comparison
if UMAP_AVAILABLE:
    # Load digits dataset
    digits = load_digits()
    X_digits, y_digits = digits.data, digits.target
    
    # Standardize data
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_digits)
    
    # Apply UMAP and t-SNE
    print("Applying UMAP...")
    umap_reducer = umap.UMAP(n_neighbors=15, min_dist=0.1, random_state=42)
    X_umap = umap_reducer.fit_transform(X_scaled)
    
    print("Applying t-SNE...")
    tsne = TSNE(n_components=2, random_state=42, perplexity=30)
    X_tsne = tsne.fit_transform(X_scaled)
    
    # Visualize comparison
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
    
    # UMAP plot
    scatter1 = ax1.scatter(X_umap[:, 0], X_umap[:, 1], c=y_digits, 
                          cmap='tab10', alpha=0.6, s=20)
    ax1.set_title('UMAP Embedding of Digits')
    ax1.set_xlabel('UMAP 1')
    ax1.set_ylabel('UMAP 2')
    
    # t-SNE plot
    scatter2 = ax2.scatter(X_tsne[:, 0], X_tsne[:, 1], c=y_digits, 
                          cmap='tab10', alpha=0.6, s=20)
    ax2.set_title('t-SNE Embedding of Digits')
    ax2.set_xlabel('t-SNE 1')
    ax2.set_ylabel('t-SNE 2')
    
    plt.tight_layout()
    plt.show()

# Example 2: UMAP as preprocessing for classification
if UMAP_AVAILABLE:
    # Create high-dimensional classification dataset
    X_class, y_class = make_classification(n_samples=2000, n_features=100, 
                                          n_informative=20, n_redundant=10,
                                          n_classes=3, random_state=42)
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X_class, y_class, test_size=0.3, random_state=42, stratify=y_class)
    
    # Define different preprocessing pipelines
    pipelines = {
        'No Reduction': Pipeline([
            ('scaler', StandardScaler()),
            ('classifier', LogisticRegression(random_state=42, max_iter=1000))
        ]),
        
        'UMAP + LogReg': Pipeline([
            ('scaler', StandardScaler()),
            ('umap', umap.UMAP(n_components=10, random_state=42)),
            ('classifier', LogisticRegression(random_state=42, max_iter=1000))
        ]),
        
        'UMAP + RandomForest': Pipeline([
            ('scaler', StandardScaler()),
            ('umap', umap.UMAP(n_components=15, random_state=42)),
            ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
        ])
    }
    
    # Train and evaluate pipelines
    results = {}
    for name, pipeline in pipelines.items():
        print(f"Training {name}...")
        pipeline.fit(X_train, y_train)
        
        train_score = pipeline.score(X_train, y_train)
        test_score = pipeline.score(X_test, y_test)
        
        y_pred = pipeline.predict(X_test)
        
        results[name] = {
            'train_score': train_score,
            'test_score': test_score,
            'predictions': y_pred
        }
    
    # Display results
    print("\nClassification Results:")
    print("=" * 60)
    for name, result in results.items():
        print(f"{name:20s}: Train={result['train_score']:.3f}, Test={result['test_score']:.3f}")
    
    # Detailed classification report for best method
    best_method = max(results.keys(), key=lambda k: results[k]['test_score'])
    print(f"\nDetailed results for {best_method}:")
    print(classification_report(y_test, results[best_method]['predictions']))

# Example 3: UMAP parameter exploration
if UMAP_AVAILABLE:
    # Use wine dataset for parameter exploration
    wine = load_wine()
    X_wine, y_wine = wine.data, wine.target
    X_wine_scaled = StandardScaler().fit_transform(X_wine)
    
    # Parameter combinations to test
    n_neighbors_values = [5, 15, 50]
    min_dist_values = [0.01, 0.1, 0.5]
    
    fig, axes = plt.subplots(len(n_neighbors_values), len(min_dist_values), 
                            figsize=(15, 12))
    
    for i, n_neighbors in enumerate(n_neighbors_values):
        for j, min_dist in enumerate(min_dist_values):
            reducer = umap.UMAP(n_neighbors=n_neighbors, min_dist=min_dist, 
                              random_state=42)
            embedding = reducer.fit_transform(X_wine_scaled)
            
            scatter = axes[i, j].scatter(embedding[:, 0], embedding[:, 1], 
                                       c=y_wine, cmap='viridis', alpha=0.7)
            axes[i, j].set_title(f'n_neighbors={n_neighbors}, min_dist={min_dist}')
            axes[i, j].set_xlabel('UMAP 1')
            axes[i, j].set_ylabel('UMAP 2')
    
    plt.suptitle('UMAP Parameter Exploration on Wine Dataset')
    plt.tight_layout()
    plt.show()

# Example 4: UMAP-guided clustering
if UMAP_AVAILABLE:
    # Generate complex clustering dataset
    np.random.seed(42)
    
    # Create multiple clusters with different densities
    cluster1 = np.random.normal([0, 0], 0.5, (100, 2))
    cluster2 = np.random.normal([3, 3], 0.8, (150, 2))
    cluster3 = np.random.normal([-2, 3], 0.3, (80, 2))
    cluster4 = np.random.normal([2, -2], 0.6, (120, 2))
    
    # Add some high-dimensional noise features
    X_clusters_2d = np.vstack([cluster1, cluster2, cluster3, cluster4])
    noise_features = np.random.normal(0, 0.1, (X_clusters_2d.shape[0], 20))
    X_clusters_hd = np.hstack([X_clusters_2d, noise_features])
    
    true_labels = np.array([0]*100 + [1]*150 + [2]*80 + [3]*120)
    
    # Apply UMAP for visualization and clustering guidance
    umap_viz = umap.UMAP(n_neighbors=15, min_dist=0.1, random_state=42)
    X_umap_viz = umap_viz.fit_transform(X_clusters_hd)
    
    # Apply clustering in original space vs UMAP space
    kmeans_original = KMeans(n_clusters=4, random_state=42, n_init=10)
    labels_original = kmeans_original.fit_predict(X_clusters_hd)
    
    kmeans_umap = KMeans(n_clusters=4, random_state=42, n_init=10)
    labels_umap = kmeans_umap.fit_predict(X_umap_viz)
    
    # Evaluate clustering quality
    ari_original = adjusted_rand_score(true_labels, labels_original)
    ari_umap = adjusted_rand_score(true_labels, labels_umap)
    
    # Visualize results
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # Original 2D data (for reference)
    scatter1 = axes[0, 0].scatter(X_clusters_2d[:, 0], X_clusters_2d[:, 1], 
                                 c=true_labels, cmap='tab10', alpha=0.7)
    axes[0, 0].set_title('Original 2D Data (True Labels)')
    
    # UMAP visualization
    scatter2 = axes[0, 1].scatter(X_umap_viz[:, 0], X_umap_viz[:, 1], 
                                 c=true_labels, cmap='tab10', alpha=0.7)
    axes[0, 1].set_title('UMAP Embedding (True Labels)')
    
    # Clustering in original high-D space
    scatter3 = axes[1, 0].scatter(X_umap_viz[:, 0], X_umap_viz[:, 1], 
                                 c=labels_original, cmap='tab10', alpha=0.7)
    axes[1, 0].set_title(f'K-Means on Original Data (ARI: {ari_original:.3f})')
    
    # Clustering in UMAP space
    scatter4 = axes[1, 1].scatter(X_umap_viz[:, 0], X_umap_viz[:, 1], 
                                 c=labels_umap, cmap='tab10', alpha=0.7)
    axes[1, 1].set_title(f'K-Means on UMAP Embedding (ARI: {ari_umap:.3f})')
    
    for ax in axes.flat:
        ax.set_xlabel('Dimension 1')
        ax.set_ylabel('Dimension 2')
    
    plt.tight_layout()
    plt.show()
    
    print(f"\nClustering Comparison:")
    print(f"K-Means on original high-D data: ARI = {ari_original:.3f}")
    print(f"K-Means on UMAP embedding: ARI = {ari_umap:.3f}")
    print("Higher ARI indicates better clustering quality")

# Example 5: Supervised UMAP
if UMAP_AVAILABLE:
    # Demonstrate supervised UMAP for better class separation
    digits_subset = load_digits()
    X_digits_sub = digits_subset.data[:1000]
    y_digits_sub = digits_subset.target[:1000]
    
    X_digits_scaled = StandardScaler().fit_transform(X_digits_sub)
    
    # Compare unsupervised vs supervised UMAP
    umap_unsup = umap.UMAP(n_neighbors=15, min_dist=0.1, random_state=42)
    X_umap_unsup = umap_unsup.fit_transform(X_digits_scaled)
    
    umap_sup = umap.UMAP(n_neighbors=15, min_dist=0.1, random_state=42)
    X_umap_sup = umap_sup.fit_transform(X_digits_scaled, y=y_digits_sub)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
    
    # Unsupervised UMAP
    scatter1 = ax1.scatter(X_umap_unsup[:, 0], X_umap_unsup[:, 1], 
                          c=y_digits_sub, cmap='tab10', alpha=0.6, s=20)
    ax1.set_title('Unsupervised UMAP')
    ax1.set_xlabel('UMAP 1')
    ax1.set_ylabel('UMAP 2')
    
    # Supervised UMAP
    scatter2 = ax2.scatter(X_umap_sup[:, 0], X_umap_sup[:, 1], 
                          c=y_digits_sub, cmap='tab10', alpha=0.6, s=20)
    ax2.set_title('Supervised UMAP')
    ax2.set_xlabel('UMAP 1')
    ax2.set_ylabel('UMAP 2')
    
    plt.tight_layout()
    plt.show()
    
    # Evaluate class separation quality
    def calculate_class_separation(embedding, labels):
        """Calculate average within-class vs between-class distances"""
        from sklearn.metrics.pairwise import euclidean_distances
        
        distances = euclidean_distances(embedding)
        n_samples = len(labels)
        
        within_class_dists = []
        between_class_dists = []
        
        for i in range(n_samples):
            for j in range(i+1, n_samples):
                if labels[i] == labels[j]:
                    within_class_dists.append(distances[i, j])
                else:
                    between_class_dists.append(distances[i, j])
        
        within_mean = np.mean(within_class_dists)
        between_mean = np.mean(between_class_dists)
        separation_ratio = between_mean / within_mean
        
        return within_mean, between_mean, separation_ratio
    
    within_unsup, between_unsup, ratio_unsup = calculate_class_separation(X_umap_unsup, y_digits_sub)
    within_sup, between_sup, ratio_sup = calculate_class_separation(X_umap_sup, y_digits_sub)
    
    print(f"\nClass Separation Analysis:")
    print(f"Unsupervised UMAP - Within: {within_unsup:.2f}, Between: {between_unsup:.2f}, Ratio: {ratio_unsup:.2f}")
    print(f"Supervised UMAP   - Within: {within_sup:.2f}, Between: {between_sup:.2f}, Ratio: {ratio_sup:.2f}")
    print("Higher ratio indicates better class separation")

# Example 6: UMAP in ensemble methods
if UMAP_AVAILABLE:
    # Create ensemble of UMAP embeddings with different parameters
    def create_umap_ensemble(X, n_estimators=5, **base_params):
        """Create ensemble of UMAP embeddings with parameter variations"""
        embeddings = []
        parameters = []
        
        for i in range(n_estimators):
            # Vary parameters slightly
            params = base_params.copy()
            params['n_neighbors'] = max(5, base_params.get('n_neighbors', 15) + np.random.randint(-3, 4))
            params['min_dist'] = max(0.001, base_params.get('min_dist', 0.1) * np.random.uniform(0.5, 2.0))
            params['random_state'] = i
            
            reducer = umap.UMAP(**params)
            embedding = reducer.fit_transform(X)
            
            embeddings.append(embedding)
            parameters.append(params)
        
        return embeddings, parameters
    
    # Apply ensemble to digits data
    X_sample = X_digits_scaled[:500]
    y_sample = y_digits[:500]
    
    embeddings, params_list = create_umap_ensemble(
        X_sample, n_estimators=6, 
        n_neighbors=15, min_dist=0.1, n_components=2
    )
    
    # Visualize ensemble results
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    axes = axes.ravel()
    
    for i, (embedding, params) in enumerate(zip(embeddings, params_list)):
        scatter = axes[i].scatter(embedding[:, 0], embedding[:, 1], 
                                c=y_sample, cmap='tab10', alpha=0.6, s=15)
        axes[i].set_title(f'UMAP {i+1}\nn_neighbors={params["n_neighbors"]}, '
                         f'min_dist={params["min_dist"]:.3f}')
        axes[i].set_xlabel('UMAP 1')
        axes[i].set_ylabel('UMAP 2')
    
    plt.suptitle('UMAP Ensemble - Different Parameter Settings')
    plt.tight_layout()
    plt.show()
    
    # Compute ensemble consensus (average embedding)
    ensemble_embedding = np.mean(embeddings, axis=0)
    
    plt.figure(figsize=(10, 8))
    scatter = plt.scatter(ensemble_embedding[:, 0], ensemble_embedding[:, 1], 
                         c=y_sample, cmap='tab10', alpha=0.7, s=30)
    plt.title('UMAP Ensemble Consensus (Average Embedding)')
    plt.xlabel('Consensus UMAP 1')
    plt.ylabel('Consensus UMAP 2')
    plt.colorbar(scatter, label='Digit Class')
    plt.show()

# Example 7: Integration with scikit-learn's Pipeline and GridSearchCV
if UMAP_AVAILABLE:
    from sklearn.model_selection import GridSearchCV
    from sklearn.svm import SVC
    
    # Create a pipeline with UMAP preprocessing
    umap_pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('umap', umap.UMAP(random_state=42)),
        ('svm', SVC(random_state=42))
    ])
    
    # Define parameter grid for hyperparameter tuning
    param_grid = {
        'umap__n_neighbors': [10, 15, 30],
        'umap__min_dist': [0.01, 0.1, 0.3],
        'umap__n_components': [2, 5, 10],
        'svm__C': [0.1, 1, 10],
        'svm__kernel': ['rbf', 'linear']
    }
    
    # Use subset for faster computation
    X_grid = X_digits[:300]
    y_grid = y_digits[:300]
    
    print("Performing grid search with UMAP preprocessing...")
    
    # Perform grid search (reduced for demo)
    grid_search = GridSearchCV(
        umap_pipeline, 
        param_grid, 
        cv=3,  # Reduced for demo
        scoring='accuracy',
        n_jobs=1,  # Use 1 for reproducibility
        verbose=1
    )
    
    try:
        grid_search.fit(X_grid, y_grid)
        
        print(f"\nBest parameters: {grid_search.best_params_}")
        print(f"Best cross-validation score: {grid_search.best_score_:.3f}")
        
        # Show top 5 parameter combinations
        results_df = pd.DataFrame(grid_search.cv_results_)
        top_results = results_df.nlargest(5, 'mean_test_score')[
            ['params', 'mean_test_score', 'std_test_score']
        ]
        
        print("\nTop 5 parameter combinations:")
        for idx, row in top_results.iterrows():
            print(f"Score: {row['mean_test_score']:.3f} (±{row['std_test_score']:.3f}) - {row['params']}")
    
    except Exception as e:
        print(f"Grid search failed: {e}")
        print("This might be due to computational constraints or UMAP installation issues")

print("\n" + "="*60)
print("UMAP Integration Examples Complete!")
print("="*60)

if not UMAP_AVAILABLE:
    print("\nNOTE: UMAP was not available, so mock results were shown.")
    print("To run with actual UMAP, install: pip install umap-learn")
else:
    print("\nKey takeaways:")
    print("1. UMAP often preserves both local and global structure better than t-SNE")
    print("2. UMAP can be effectively integrated into scikit-learn pipelines")
    print("3. Supervised UMAP can improve class separation for classification tasks")
    print("4. Parameter tuning significantly affects UMAP results")
    print("5. UMAP preprocessing can improve downstream ML model performance")
```

