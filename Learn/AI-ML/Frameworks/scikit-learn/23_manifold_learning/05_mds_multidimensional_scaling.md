## MDS Multidimensional Scaling


Multidimensional Scaling (MDS) finds a low-dimensional representation that preserves pairwise distances as closely as possible. Classical MDS (also called Principal Coordinates Analysis) provides a closed-form solution, while metric MDS iteratively minimizes stress (distance distortion).

Classical MDS double-centers the distance matrix and performs eigendecomposition, making it equivalent to PCA when using Euclidean distances. Metric MDS minimizes the stress function using iterative algorithms like SMACOF (Scaling by MAjorizing a COmplicated Function), allowing for different distance metrics and better handling of missing data.

Scikit-learn implements MDS through the `MDS` class with options for classical or metric MDS, different distance metrics, initialization methods, and convergence criteria. The method provides both the embedding coordinates and the stress value indicating how well distances are preserved.

**Key points**: Classical MDS has a closed-form solution but assumes Euclidean distances; metric MDS is more flexible but computationally intensive; both preserve global structure better than local structure; MDS works well when pairwise distances are meaningful; it can handle incomplete distance matrices in metric form.

**Example**: For analyzing city distances, MDS can create a 2D map that approximately preserves travel distances, though the resulting map might not match geographic coordinates due to non-Euclidean travel patterns.## UMAP Integration Patterns

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.manifold import MDS
from sklearn.datasets import load_digits, make_swiss_roll
from sklearn.metrics import pairwise_distances
from sklearn.preprocessing import StandardScaler
import pandas as pd

# Example 1: Classical vs Metric MDS comparison
n_samples = 300
X_swiss, color_swiss = make_swiss_roll(n_samples, noise=0.1, random_state=42)

# Apply different MDS variants
mds_methods = {
    'Classical MDS': {'metric': True, 'dissimilarity': 'euclidean'},
    'Metric MDS': {'metric': True, 'dissimilarity': 'precomputed'},
    'Non-metric MDS': {'metric': False, 'dissimilarity': 'precomputed'}
}

# Precompute distance matrix for precomputed methods
dist_matrix = pairwise_distances(X_swiss)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes = axes.ravel()

# Plot original 3D data
ax = fig.add_subplot(221, projection='3d')
ax.scatter(X_swiss[:, 0], X_swiss[:, 1], X_swiss[:, 2], c=color_swiss, cmap='viridis')
ax.set_title('Original 3D Swiss Roll')
ax.view_init(azim=-66, elev=12)

# Apply MDS methods
for i, (name, params) in enumerate(mds_methods.items()):
    ax_idx = i + 1
    
    try:
        if params['dissimilarity'] == 'precomputed':
            mds = MDS(n_components=2, random_state=42, **params)
            embedding = mds.fit_transform(dist_matrix)
        else:
            mds = MDS(n_components=2, random_state=42, **params)
            embedding = mds.fit_transform(X_swiss)
        
        scatter = axes[ax_idx].scatter(embedding[:, 0], embedding[:, 1], 
                                     c=color_swiss, cmap='viridis')
        axes[ax_idx].set_title(f'{name}\nStress: {mds.stress_:.2f}')
        axes[ax_idx].set_xlabel('MDS 1')
        axes[ax_idx].set_ylabel('MDS 2')
        
    except Exception as e:
        axes[ax_idx].text(0.5, 0.5, f'{name}\nFailed: {str(e)[:30]}...', 
                         transform=axes[ax_idx].transAxes, ha='center', va='center')
        axes[ax_idx].set_title(name)

plt.tight_layout()
plt.show()

# Example 2: City distances example
city_distances = np.array([
    [0,    587,  1212, 701,  1936, 604,  748,  2139, 2182, 543],
    [587,  0,    920,  940,  1745, 1188, 713,  1858, 1737, 597],
    [1212, 920,  0,    879,  831,  1726, 1631, 949,  1021, 1494],
    [701,  940,  879,  0,    1374, 968,  1420, 1645, 1891, 1220],
    [1936, 1745, 831,  1374, 0,    2339, 2451, 347,  959,  2300],
    [604,  1188, 1726, 968,  2339, 0,    1092, 2594, 2734, 923],
    [748,  713,  1631, 1420, 2451, 1092, 0,    2571, 2408, 205],
    [2139, 1858, 949,  1645, 347,  2594, 2571, 0,    678,  2442],
    [2182, 1737, 1021, 1891, 959,  2734, 2408, 678,  0,    2329],
    [543,  597,  1494, 1220, 2300, 923,  205,  2442, 2329, 0]
])

city_names = ['Atlanta', 'Chicago', 'Denver', 'Houston', 'Los Angeles', 
              'Miami', 'New York', 'San Francisco', 'Seattle', 'Washington DC']

# Apply MDS to city distances
mds_cities = MDS(n_components=2, dissimilarity='precomputed', random_state=42)
city_coords = mds_cities.fit_transform(city_distances)

# Plot city map
plt.figure(figsize=(12, 8))
plt.scatter(city_coords[:, 0], city_coords[:, 1], s=100, c='red', alpha=0.7)

# Add city labels
for i, name in enumerate(city_names):
    plt.annotate(name, (city_coords[i, 0], city_coords[i, 1]), 
                xytext=(5, 5), textcoords='offset points', fontsize=10)

plt.title(f'MDS City Map from Distance Matrix\nStress: {mds_cities.stress_:.2f}')
plt.xlabel('MDS Dimension 1')
plt.ylabel('MDS Dimension 2')
plt.grid(True, alpha=0.3)
plt.show()

print(f"City distances MDS stress: {mds_cities.stress_:.2f}")
print("Lower stress indicates better distance preservation")

# Example 3: Stress analysis and optimization
def analyze_mds_stress(X, max_components=10, n_runs=5):
    """Analyze MDS stress for different numbers of components"""
    stress_results = {}
    
    # Precompute distance matrix
    distances = pairwise_distances(X)
    
    for n_comp in range(1, max_components + 1):
        stresses = []
        
        for run in range(n_runs):
            mds = MDS(n_components=n_comp, dissimilarity='precomputed', 
                     random_state=run, max_iter=1000)
            try:
                mds.fit(distances)
                stresses.append(mds.stress_)
            except:
                continue
        
        if stresses:
            stress_results[n_comp] = {
                'mean': np.mean(stresses),
                'std': np.std(stresses),
                'min': np.min(stresses),
                'max': np.max(stresses)
            }
    
    return stress_results

# Analyze stress for digits dataset
digits = load_digits()
X_digits_sample = digits.data[:200]  # Use subset for speed

stress_analysis = analyze_mds_stress(X_digits_sample, max_components=8, n_runs=3)

# Plot stress vs components
components = list(stress_analysis.keys())
mean_stress = [stress_analysis[c]['mean'] for c in components]
std_stress = [stress_analysis[c]['std'] for c in components]

plt.figure(figsize=(10, 6))
plt.errorbar(components, mean_stress, yerr=std_stress, 
            marker='o', capsize=5, linewidth=2, markersize=8)
plt.xlabel('Number of Components')
plt.ylabel('Stress')
plt.title('MDS Stress vs. Number of Components')
plt.grid(True, alpha=0.3)
plt.xticks(components)

# Add elbow detection
if len(components) >= 3:
    # Find elbow point using second derivative
    second_derivatives = []
    for i in range(1, len(mean_stress) - 1):
        second_deriv = mean_stress[i-1] - 2*mean_stress[i] + mean_stress[i+1]
        second_derivatives.append((components[i], second_deriv))
    
    if second_derivatives:
        elbow_point = max(second_derivatives, key=lambda x: x[1])[0]
        plt.axvline(x=elbow_point, color='red', linestyle='--', 
                   label=f'Suggested components: {elbow_point}')
        plt.legend()

plt.show()

print("\nStress Analysis Results:")
for comp, stats in stress_analysis.items():
    print(f"{comp} components: {stats['mean']:.3f} ± {stats['std']:.3f} "
          f"(range: {stats['min']:.3f} - {stats['max']:.3f})")

# Example 4: Different distance metrics comparison
from sklearn.metrics import pairwise_distances

# Generate clustered data for distance metric comparison
np.random.seed(42)
cluster1 = np.random.normal([2, 2], 0.5, (50, 2))
cluster2 = np.random.normal([-2, -2], 0.5, (50, 2))
cluster3 = np.random.normal([2, -2], 0.5, (50, 2))
X_clusters = np.vstack([cluster1, cluster2, cluster3])
y_clusters = np.array([0]*50 + [1]*50 + [2]*50)

# Test different distance metrics
distance_metrics = ['euclidean', 'manhattan', 'cosine', 'chebyshev']

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes = axes.ravel()

for i, metric in enumerate(distance_metrics):
    try:
        # Compute distance matrix
        dist_matrix = pairwise_distances(X_clusters, metric=metric)
        
        # Apply MDS
        mds = MDS(n_components=2, dissimilarity='precomputed', random_state=42)
        embedding = mds.fit_transform(dist_matrix)
        
        scatter = axes[i].scatter(embedding[:, 0], embedding[:, 1], 
                                c=y_clusters, cmap='viridis', alpha=0.7)
        axes[i].set_title(f'MDS with {metric.capitalize()} Distance\nStress: {mds.stress_:.2f}')
        axes[i].set_xlabel('MDS 1')
        axes[i].set_ylabel('MDS 2')
        
    except Exception as e:
        axes[i].text(0.5, 0.5, f'{metric}\nFailed: {str(e)[:30]}...', 
                    transform=axes[i].transAxes, ha='center', va='center')
        axes[i].set_title(f'{metric.capitalize()} Distance')

plt.tight_layout()
plt.show()

# Example 5: MDS with missing data
def create_incomplete_distance_matrix(X, missing_ratio=0.3):
    """Create distance matrix with missing entries"""
    distances = pairwise_distances(X)
    n = distances.shape[0]
    
    # Create mask for missing entries (symmetric)
    mask = np.random.random((n, n)) < missing_ratio
    mask = np.triu(mask, k=1)  # Upper triangle
    mask = mask + mask.T  # Make symmetric
    
    # Set missing entries to NaN
    incomplete_distances = distances.copy()
    incomplete_distances[mask] = np.nan
    
    return incomplete_distances, mask

# Generate test data
X_test = X_swiss[:100]
incomplete_dist, missing_mask = create_incomplete_distance_matrix(X_test, missing_ratio=0.2)

print(f"Missing entries: {np.sum(missing_mask) / 2} out of {X_test.shape[0] * (X_test.shape[0] - 1) / 2}")
print(f"Missing ratio: {np.sum(missing_mask) / (X_test.shape[0] * (X_test.shape[0] - 1)):.1%}")

# Handle missing data by using complete cases only
def handle_missing_distances(dist_matrix):
    """Handle missing distances by removing rows/columns with too many missing values"""
    n = dist_matrix.shape[0]
    valid_mask = ~np.isnan(dist_matrix)
    
    # Count valid entries per row
    valid_counts = np.sum(valid_mask, axis=1)
    
    # Keep points with enough valid distances
    threshold = n * 0.5  # At least 50% valid distances
    keep_indices = valid_counts >= threshold
    
    if np.sum(keep_indices) < 10:  # Need minimum points
        print("Too much missing data for reliable MDS")
        return None, None
    
    # Extract submatrix
    reduced_dist = dist_matrix[keep_indices][:, keep_indices]
    
    # For remaining missing values, use mean imputation
    if np.any(np.isnan(reduced_dist)):
        mean_dist = np.nanmean(reduced_dist[reduced_dist > 0])
        reduced_dist[np.isnan(reduced_dist)] = mean_dist
    
    return reduced_dist, keep_indices

# Process incomplete distance matrix
processed_dist, valid_indices = handle_missing_distances(incomplete_dist)

if processed_dist is not None:
    # Apply MDS to processed data
    mds_incomplete = MDS(n_components=2, dissimilarity='precomputed', random_state=42)
    embedding_incomplete = mds_incomplete.fit_transform(processed_dist)
    
    # Compare with complete data MDS
    complete_dist = pairwise_distances(X_test)
    mds_complete = MDS(n_components=2, dissimilarity='precomputed', random_state=42)
    embedding_complete = mds_complete.fit_transform(complete_dist)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Complete data embedding
    scatter1 = ax1.scatter(embedding_complete[:, 0], embedding_complete[:, 1], 
                          c=color_swiss[:100], cmap='viridis', alpha=0.7)
    ax1.set_title(f'MDS with Complete Data\nStress: {mds_complete.stress_:.2f}')
    ax1.set_xlabel('MDS 1')
    ax1.set_ylabel('MDS 2')
    
    # Incomplete data embedding
    valid_colors = color_swiss[:100][valid_indices]
    scatter2 = ax2.scatter(embedding_incomplete[:, 0], embedding_incomplete[:, 1], 
                          c=valid_colors, cmap='viridis', alpha=0.7)
    ax2.set_title(f'MDS with {np.sum(~valid_indices)} Missing Points\nStress: {mds_incomplete.stress_:.2f}')
    ax2.set_xlabel('MDS 1')
    ax2.set_ylabel('MDS 2')
    
    plt.tight_layout()
    plt.show()
    
    print(f"\nMDS Comparison:")
    print(f"Complete data stress: {mds_complete.stress_:.3f}")
    print(f"Incomplete data stress: {mds_incomplete.stress_:.3f}")
    print(f"Points used: {np.sum(valid_indices)} out of {X_test.shape[0]}")

# Example 6: Shepard diagram for stress visualization
def plot_shepard_diagram(original_distances, embedded_distances, title="Shepard Diagram"):
    """Create Shepard diagram showing distance preservation"""
    # Flatten upper triangle (avoid duplicate pairs and self-distances)
    n = int(np.sqrt(len(original_distances)))
    mask = np.triu(np.ones((n, n)), k=1).astype(bool)
    
    orig_flat = original_distances.reshape(n, n)[mask]
    embed_flat = embedded_distances.reshape(n, n)[mask]
    
    plt.figure(figsize=(8, 6))
    plt.scatter(orig_flat, embed_flat, alpha=0.6, s=20)
    
    # Add perfect preservation line
    max_dist = max(orig_flat.max(), embed_flat.max())
    min_dist = min(orig_flat.min(), embed_flat.min())
    plt.plot([min_dist, max_dist], [min_dist, max_dist], 'r--', linewidth=2, 
             label='Perfect preservation')
    
    plt.xlabel('Original Distances')
    plt.ylabel('Embedded Distances')
    plt.title(title)
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    # Calculate correlation
    correlation = np.corrcoef(orig_flat, embed_flat)[0, 1]
    plt.text(0.05, 0.95, f'Correlation: {correlation:.3f}', 
             transform=plt.gca().transAxes, bbox=dict(boxstyle="round,pad=0.3", 
             facecolor="white", alpha=0.8))
    
    plt.show()
    return correlation

# Create Shepard diagram for city distances example
embedded_city_distances = pairwise_distances(city_coords)
corr = plot_shepard_diagram(city_distances, embedded_city_distances, 
                           "Shepard Diagram - City Distances")

print(f"Distance preservation correlation: {corr:.3f}")
print("Values closer to 1.0 indicate better distance preservation")
```

