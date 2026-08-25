## Comprehensive Dimensionality Reduction Pipeline


Integrating multiple dimensionality reduction techniques provides robust data preprocessing and analysis capabilities for complex datasets.

```python
def comprehensive_dimensionality_reduction(X, y, test_size=0.2):
    """
    Compare multiple dimensionality reduction techniques
    """
    from sklearn.manifold import TSNE
    from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
    from sklearn.model_selection import cross_val_score
    
    # Prepare data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=42)
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    results = {}
    
    # 1. PCA
    pca = PCA(n_components=10)
    X_train_pca = pca.fit_transform(X_train_scaled)
    X_test_pca = pca.transform(X_test_scaled)
    results['PCA'] = {
        'train': X_train_pca,
        'test': X_test_pca,
        'variance_explained': np.sum(pca.explained_variance_ratio_),
        'transformer': pca
    }
    
    # 2. ICA
    ica = FastICA(n_components=10, random_state=42)
    X_train_ica = ica.fit_transform(X_train_scaled)
    X_test_ica = ica.transform(X_test_scaled)
    results['ICA'] = {
        'train': X_train_ica,
        'test': X_test_ica,
        'transformer': ica
    }
    
    # 3. NMF (requires non-negative data)
    X_train_nonneg = X_train_scaled - X_train_scaled.min() + 0.01
    X_test_nonneg = X_test_scaled - X_train_scaled.min() + 0.01  # Use train min
    
    nmf = NMF(n_components=10, random_state=42, max_iter=200)
    X_train_nmf = nmf.fit_transform(X_train_nonneg)
    X_test_nmf = nmf.transform(X_test_nonneg)
    results['NMF'] = {
        'train': X_train_nmf,
        'test': X_test_nmf,
        'reconstruction_error': nmf.reconstruction_err_,
        'transformer': nmf
    }
    
    # 4. Dictionary Learning
    dict_learner = DictionaryLearning(n_components=10, alpha=1, max_iter=50, random_state=42)
    X_train_dict = dict_learner.fit_transform(X_train_scaled)
    X_test_dict = dict_learner.transform(X_test_scaled)
    results['Dictionary'] = {
        'train': X_train_dict,
        'test': X_test_dict,
        'transformer': dict_learner
    }
    
    # Evaluate each method with classification
    classifier = RandomForestClassifier(random_state=42)
    
    for method, data in results.items():
        scores = cross_val_score(classifier, data['train'], y_train, cv=5)
        results[method]['cv_score'] = scores.mean()
        results[method]['cv_std'] = scores.std()
        
        # Fit and evaluate on test set
        classifier.fit(data['train'], y_train)
        test_score = classifier.score(data['test'], y_test)
        results[method]['test_score'] = test_score
    
    return results

# Apply to breast cancer dataset
X, y = load_breast_cancer(return_X_y=True)
comparison_results = comprehensive_dimensionality_reduction(X, y)

print("Dimensionality Reduction Method Comparison:")
print("=" * 60)
for method, metrics in comparison_results.items():
    print(f"\n{method}:")
    print(f"  Cross-validation score: {metrics['cv_score']:.4f} (+/- {metrics['cv_std']:.4f})")
    print(f"  Test score: {metrics['test_score']:.4f}")
    
    if 'variance_explained' in metrics:
        print(f"  Variance explained: {metrics['variance_explained']:.4f}")
    if 'reconstruction_error' in metrics:
        print(f"  Reconstruction error: {metrics['reconstruction_error']:.6f}")

# Visualize dimensionality reduction results
def visualize_reduction_results(X, y, methods_data, method_names):
    """Visualize first two components of each reduction method"""
    n_methods = len(methods_data)
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    axes = axes.ravel()
    
    colors = plt.cm.Set1(np.linspace(0, 1, len(np.unique(y))))
    
    for i, (method_data, method_name) in enumerate(zip(methods_data, method_names)):
        if i < 4:  # Only plot first 4 methods
            scatter = axes[i].scatter(method_data[:, 0], method_data[:, 1], 
                                    c=y, cmap='Set1', alpha=0.7, s=30)
            axes[i].set_title(f'{method_name} - First Two Components')
            axes[i].set_xlabel('Component 1')
            axes[i].set_ylabel('Component 2')
            axes[i].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()

# Extract data for visualization
viz_methods = ['PCA', 'ICA', 'NMF', 'Dictionary']
viz_data = [comparison_results[method]['train'] for method in viz_methods]
visualize_reduction_results(X, y, viz_data, viz_methods)
```

**Advanced Applications and Use Cases:**

```python
# Denoising with Dictionary Learning
def denoise_with_dictionary_learning(noisy_image, noise_std=0.1):
    """Denoise image using dictionary learning"""
    
    # Add noise to clean image
    clean_image = faces.data[0].reshape(64, 64)
    noisy_image = clean_image + noise_std * np.random.randn(*clean_image.shape)
    
    # Extract patches from noisy image
    patch_size = (8, 8)
    noisy_patches = extract_patches_2d(noisy_image, patch_size, max_patches=500, random_state=42)
    noisy_patches = noisy_patches.reshape(noisy_patches.shape[0], -1)
    
    # Learn dictionary on noisy patches
    dict_learner = DictionaryLearning(
        n_components=64,
        alpha=0.1,  # Lower alpha for less sparsity (better reconstruction)
        max_iter=100,
        random_state=42
    )
    dict_learner.fit(noisy_patches)
    
    # Reconstruct with learned dictionary
    sparse_codes = dict_learner.transform(noisy_patches)
    reconstructed_patches = dict_learner.components_.T @ sparse_codes.T
    reconstructed_patches = reconstructed_patches.T
    
    # Reconstruct full image
    patch_shape = patch_size + (reconstructed_patches.shape[0],)
    reconstructed_patches_2d = reconstructed_patches.reshape(-1, *patch_size)
    
    # Simple averaging for overlapping patches (simplified reconstruction)
    denoised_image = np.zeros_like(noisy_image)
    patch_count = np.zeros_like(noisy_image)
    
    idx = 0
    for i in range(0, noisy_image.shape[0] - patch_size[0] + 1, 4):
        for j in range(0, noisy_image.shape[1] - patch_size[1] + 1, 4):
            if idx < len(reconstructed_patches_2d):
                denoised_image[i:i+patch_size[0], j:j+patch_size[1]] += reconstructed_patches_2d[idx]
                patch_count[i:i+patch_size[0], j:j+patch_size[1]] += 1
                idx += 1
    
    # Average overlapping regions
    denoised_image = np.divide(denoised_image, patch_count, 
                              out=np.zeros_like(denoised_image), where=patch_count!=0)
    
    # Calculate denoising metrics
    mse_noisy = np.mean((clean_image - noisy_image) ** 2)
    mse_denoised = np.mean((clean_image - denoised_image) ** 2)
    
    return clean_image, noisy_image, denoised_image, mse_noisy, mse_denoised

clean, noisy, denoised, mse_noisy, mse_denoised = denoise_with_dictionary_learning()

# Visualize denoising results
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
axes[0].imshow(clean, cmap='gray')
axes[0].set_title('Original Clean Image')
axes[0].axis('off')

axes[1].imshow(noisy, cmap='gray')
axes[1].set_title(f'Noisy Image (MSE: {mse_noisy:.4f})')
axes[1].axis('off')

axes[2].imshow(denoised, cmap='gray')
axes[2].set_title(f'Denoised Image (MSE: {mse_denoised:.4f})')
axes[2].axis('off')

plt.tight_layout()
plt.show()

print(f"Denoising improvement: {((mse_noisy - mse_denoised) / mse_noisy * 100):.2f}% reduction in MSE")
```

**Feature Learning for Transfer Learning:**

```python
def feature_learning_pipeline(source_data, target_data, n_components=50):
    """
    Use dimensionality reduction for feature learning and transfer
    """
    
    # Learn features on source data
    pca_source = PCA(n_components=n_components)
    ica_source = FastICA(n_components=n_components, random_state=42)
    
    # Standardize source data
    scaler_source = StandardScaler()
    source_scaled = scaler_source.fit_transform(source_data)
    
    # Fit feature extractors
    pca_features = pca_source.fit_transform(source_scaled)
    ica_features = ica_source.fit_transform(source_scaled)
    
    # Apply learned features to target data
    target_scaled = scaler_source.transform(target_data)  # Use source scaler
    target_pca = pca_source.transform(target_scaled)
    target_ica = ica_source.transform(target_scaled)
    
    return {
        'source_pca': pca_features,
        'source_ica': ica_features,
        'target_pca': target_pca,
        'target_ica': target_ica,
        'pca_model': pca_source,
        'ica_model': ica_source
    }

# Example: Transfer learning between different digit subsets
digits = load_digits()
X_digits, y_digits = digits.data, digits.target

# Split into source (digits 0-4) and target (digits 5-9)
source_mask = y_digits <= 4
target_mask = y_digits >= 5

X_source = X_digits[source_mask]
y_source = y_digits[source_mask]
X_target = X_digits[target_mask]
y_target = y_digits[target_mask] - 5  # Relabel 5-9 as 0-4

transfer_results = feature_learning_pipeline(X_source, X_target, n_components=30)

print("Feature Learning Transfer Results:")
print(f"Source PCA features shape: {transfer_results['source_pca'].shape}")
print(f"Target PCA features shape: {transfer_results['target_pca'].shape}")
print(f"Source ICA features shape: {transfer_results['source_ica'].shape}")
print(f"Target ICA features shape: {transfer_results['target_ica'].shape}")

# Evaluate transfer learning effectiveness
from sklearn.svm import SVC

# Train on source features, test on target
svm_pca = SVC(random_state=42)
svm_ica = SVC(random_state=42)

svm_pca.fit(transfer_results['source_pca'], y_source)
svm_ica.fit(transfer_results['source_ica'], y_source)

pca_transfer_score = svm_pca.score(transfer_results['target_pca'], y_target)
ica_transfer_score = svm_ica.score(transfer_results['target_ica'], y_target)

print(f"\nTransfer Learning Performance:")
print(f"PCA features transfer accuracy: {pca_transfer_score:.4f}")
print(f"ICA features transfer accuracy: {ica_transfer_score:.4f}")
```

**Multi-modal Data Integration:**

```python
def multimodal_dimensionality_reduction():
    """
    Demonstrate dimensionality reduction on multi-modal data
    """
    
    # Simulate multi-modal data (e.g., text + image features)
    np.random.seed(42)
    n_samples = 500
    
    # Modal 1: Text features (sparse, high-dimensional)
    text_features = np.random.exponential(0.5, (n_samples, 1000))
    text_features[text_features < 0.1] = 0  # Make sparse
    
    # Modal 2: Image features (dense, medium-dimensional)
    image_features = np.random.randn(n_samples, 100)
    
    # Modal 3: Audio features (structured, low-dimensional)
    t = np.linspace(0, 2*np.pi, 20)
    audio_base = np.sin(t[:, None] * np.arange(1, n_samples+1) / 100).T
    audio_features = audio_base + 0.1 * np.random.randn(n_samples, 20)
    
    # Combine modalities
    combined_features = np.hstack([text_features, image_features, audio_features])
    
    print(f"Multi-modal data shape: {combined_features.shape}")
    print(f"Text features: {text_features.shape[1]} dims")
    print(f"Image features: {image_features.shape[1]} dims") 
    print(f"Audio features: {audio_features.shape[1]} dims")
    
    # Apply different reduction techniques
    scaler = StandardScaler()
    combined_scaled = scaler.fit_transform(combined_features)
    
    # PCA for overall structure
    pca_multimodal = PCA(n_components=50)
    combined_pca = pca_multimodal.fit_transform(combined_scaled)
    
    # ICA for source separation
    ica_multimodal = FastICA(n_components=50, random_state=42)
    combined_ica = ica_multimodal.fit_transform(combined_scaled)
    
    # NMF for parts-based analysis (after making non-negative)
    combined_nonneg = combined_scaled - combined_scaled.min() + 0.01
    nmf_multimodal = NMF(n_components=50, random_state=42, max_iter=100)
    combined_nmf = nmf_multimodal.fit_transform(combined_nonneg)
    
    # Analyze component contributions by modality
    def analyze_modality_contributions(components, modality_ranges):
        """Analyze how much each component focuses on each modality"""
        contributions = {}
        for modality, (start, end) in modality_ranges.items():
            modality_weights = np.abs(components[:, start:end])
            contributions[modality] = np.mean(modality_weights, axis=1)
        return contributions
    
    modality_ranges = {
        'text': (0, 1000),
        'image': (1000, 1100),
        'audio': (1100, 1120)
    }
    
    pca_contributions = analyze_modality_contributions(pca_multimodal.components_, modality_ranges)
    
    # Visualize component focus
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    for i, (modality, contributions) in enumerate(pca_contributions.items()):
        axes[i].bar(range(len(contributions)), contributions)
        axes[i].set_title(f'PCA Component Focus on {modality.capitalize()} Features')
        axes[i].set_xlabel('Component')
        axes[i].set_ylabel('Average Weight')
        axes[i].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()
    
    return {
        'combined_pca': combined_pca,
        'combined_ica': combined_ica,
        'combined_nmf': combined_nmf,
        'modality_contributions': pca_contributions
    }

multimodal_results = multimodal_dimensionality_reduction()
```

**Performance Optimization and Scalability:**

```python
def scalability_comparison():
    """Compare scalability of different dimensionality reduction methods"""
    import time
    
    # Test different data sizes
    data_sizes = [100, 500, 1000, 2000]
    n_features = 200
    n_components = 50
    
    results = {
        'PCA': [],
        'ICA': [],
        'NMF': [],
        'Dictionary': [],
        'Incremental_PCA': []
    }
    
    for n_samples in data_sizes:
        print(f"\nTesting with {n_samples} samples...")
        
        # Generate test data
        X_test = np.random.randn(n_samples, n_features)
        X_test_nonneg = np.abs(X_test)  # For NMF
        
        # PCA
        start_time = time.time()
        pca = PCA(n_components=n_components)
        pca.fit_transform(X_test)
        results['PCA'].append(time.time() - start_time)
        
        # ICA
        start_time = time.time()
        ica = FastICA(n_components=n_components, random_state=42, max_iter=100)
        ica.fit_transform(X_test)
        results['ICA'].append(time.time() - start_time)
        
        # NMF
        start_time = time.time()
        nmf = NMF(n_components=n_components, random_state=42, max_iter=50)
        nmf.fit_transform(X_test_nonneg)
        results['NMF'].append(time.time() - start_time)
        
        # Dictionary Learning
        start_time = time.time()
        dict_learner = DictionaryLearning(n_components=n_components, alpha=1, max_iter=20, random_state=42)
        dict_learner.fit_transform(X_test)
        results['Dictionary'].append(time.time() - start_time)
        
        # Incremental PCA
        start_time = time.time()
        ipca = IncrementalPCA(n_components=n_components, batch_size=min(50, n_samples//2))
        ipca.fit_transform(X_test)
        results['Incremental_PCA'].append(time.time() - start_time)
    
    # Plot scalability results
    plt.figure(figsize=(12, 8))
    for method, times in results.items():
        plt.plot(data_sizes, times, marker='o', label=method, linewidth=2)
    
    plt.xlabel('Number of Samples')
    plt.ylabel('Computation Time (seconds)')
    plt.title('Scalability Comparison of Dimensionality Reduction Methods')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.yscale('log')
    plt.show()
    
    return results

# Run scalability test
scalability_results = scalability_comparison()

# Print summary
print("\nScalability Summary (time for largest dataset):")
for method, times in scalability_results.items():
    print(f"{method}: {times[-1]:.3f} seconds")
```

**Best Practices and Guidelines:**

```python
def dimensionality_reduction_guidelines():
    """
    Provide practical guidelines for choosing dimensionality reduction methods
    """
    
    guidelines = {
        'PCA': {
            'best_for': ['Data visualization', 'Noise reduction', 'Feature decorrelation'],
            'assumptions': ['Linear relationships', 'Gaussian-like distributions', 'Variance-based importance'],
            'when_to_use': 'Default choice for most applications, especially when interpretability is secondary',
            'preprocessing': 'Always standardize features',
            'hyperparameters': 'n_components (use explained variance ratio to decide)'
        },
        
        'ICA': {
            'best_for': ['Signal separation', 'Source separation', 'Non-Gaussian data'],
            'assumptions': ['Statistical independence', 'Non-Gaussian sources', 'Linear mixing'],
            'when_to_use': 'When you need to separate mixed signals or find independent factors',
            'preprocessing': 'Center data, may benefit from whitening',
            'hyperparameters': 'n_components, algorithm (deflation vs parallel), max_iter'
        },
        
        'NMF': {
            'best_for': ['Parts-based decomposition', 'Topic modeling', 'Image analysis'],
            'assumptions': ['Non-negative data', 'Additive combinations', 'Sparse representations'],
            'when_to_use': 'When data is naturally non-negative and you want interpretable parts',
            'preprocessing': 'Ensure non-negative values, consider normalization',
            'hyperparameters': 'n_components, alpha (regularization), solver, max_iter'
        },
        
        'Dictionary Learning': {
            'best_for': ['Feature learning', 'Denoising', 'Sparse coding'],
            'assumptions': ['Sparse representations exist', 'Overcomplete dictionaries useful'],
            'when_to_use': 'When you need adaptive, data-specific feature representations',
            'preprocessing': 'Standardize or normalize features',
            'hyperparameters': 'n_components, alpha (sparsity), max_iter'
        }
    }
    
    return guidelines

guidelines = dimensionality_reduction_guidelines()

# Print decision tree for method selection
print("DIMENSIONALITY REDUCTION METHOD SELECTION GUIDE")
print("=" * 60)

decision_tree = """
START HERE: What is your primary goal?

1. DATA VISUALIZATION (2D/3D plots)
   → Use PCA or t-SNE
   → PCA for linear structure, t-SNE for non-linear clustering

2. NOISE REDUCTION / COMPRESSION
   → Use PCA (most common)
   → Consider Incremental PCA for large datasets

3. FEATURE EXTRACTION / REPRESENTATION LEARNING
   → Non-negative data? → Use NMF
   → Need sparse features? → Use Dictionary Learning
   → Mixed signals? → Use ICA
   → General purpose? → Use PCA

4. PREPROCESSING FOR ML MODELS
   → Use PCA (fastest and most reliable)
   → Consider feature selection methods first

5. SIGNAL/SOURCE SEPARATION
   → Use ICA (blind source separation)
   → Consider NMF for parts-based separation

6. INTERPRETABILITY IS CRUCIAL
   → Avoid: PCA (components are linear combinations)
   → Use: NMF (parts-based), Dictionary Learning (sparse), or Feature Selection

Data Size Considerations:
- Small datasets (< 1000 samples): Any method works
- Medium datasets (1000-10000): Standard implementations
- Large datasets (> 10000): Use Incremental/MiniBatch versions
- Very large datasets: Consider approximate methods or sampling
"""

print(decision_tree)
```

**Conclusion:**
Dimensionality reduction techniques serve different purposes and make varying assumptions about data structure. PCA excels at variance preservation and computational efficiency, ICA separates independent sources, NMF provides interpretable parts-based decompositions, and dictionary learning offers adaptive sparse representations. Success depends on matching the method's assumptions to your data characteristics and analysis goals.

**Next steps:** Explore manifold learning techniques (t-SNE, UMAP, Isomap) for non-linear dimensionality reduction, investigate autoencoders for deep learning-based feature extraction, and consider ensemble approaches that combine multiple dimensionality reduction methods for robust feature engineering.

---

