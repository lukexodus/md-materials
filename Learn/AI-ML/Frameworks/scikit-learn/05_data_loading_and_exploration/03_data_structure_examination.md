## Data Structure Examination


### Basic Data Inspection

```python
def examine_data_structure(dataset, name="Dataset"):
    """Comprehensive data structure examination"""
    print(f"=== {name} Structure Analysis ===")
    
    # Basic information
    if hasattr(dataset, 'data'):
        X, y = dataset.data, dataset.target
        feature_names = getattr(dataset, 'feature_names', None)
        target_names = getattr(dataset, 'target_names', None)
    else:
        X, y = dataset
        feature_names = None
        target_names = None
    
    print(f"Data shape: {X.shape}")
    print(f"Target shape: {y.shape}")
    print(f"Data type: {X.dtype}")
    print(f"Target type: {y.dtype}")
    
    # Memory usage
    print(f"Memory usage: {X.nbytes / 1024**2:.2f} MB")
    
    # Feature information
    if feature_names:
        print(f"Features: {feature_names[:5]}...")
        print(f"Total features: {len(feature_names)}")
    
    # Target information
    if target_names:
        print(f"Target classes: {target_names}")
    
    unique_targets = np.unique(y)
    print(f"Unique target values: {unique_targets}")
    print(f"Target distribution: {dict(zip(*np.unique(y, return_counts=True)))}")
    
    return X, y

# Usage
X, y = examine_data_structure(iris, "Iris Dataset")
```

### Array Properties and Characteristics

```python
def analyze_array_properties(X, y, feature_names=None):
    """Analyze array properties and characteristics"""
    print("=== Array Properties ===")
    
    # Shape and dimensions
    print(f"Data dimensions: {X.ndim}")
    print(f"Data shape: {X.shape}")
    print(f"Is data C-contiguous: {X.flags.c_contiguous}")
    print(f"Is data F-contiguous: {X.flags.f_contiguous}")
    
    # Data types and ranges
    print(f"Data dtype: {X.dtype}")
    print(f"Data range: [{X.min():.3f}, {X.max():.3f}]")
    print(f"Data mean: {X.mean():.3f}")
    print(f"Data std: {X.std():.3f}")
    
    # Sparsity check
    zero_count = np.count_nonzero(X == 0)
    sparsity = zero_count / X.size
    print(f"Sparsity: {sparsity:.3f} ({zero_count}/{X.size} zeros)")
    
    # Feature-wise analysis
    if X.ndim == 2:
        print(f"Features with zero variance: {np.sum(X.var(axis=0) == 0)}")
        print(f"Features with constant values: {np.sum(X.max(axis=0) == X.min(axis=0))}")
        
        # Correlation analysis
        if X.shape[1] <= 50:  # Only for reasonable number of features
            corr_matrix = np.corrcoef(X.T)
            high_corr = np.where(np.abs(corr_matrix) > 0.9)
            high_corr_pairs = [(i, j) for i, j in zip(high_corr[0], high_corr[1]) if i != j and i < j]
            print(f"Highly correlated feature pairs (>0.9): {len(high_corr_pairs)}")
```

### Target Variable Analysis

```python
def analyze_target_variable(y, target_names=None):
    """Comprehensive target variable analysis"""
    print("=== Target Variable Analysis ===")
    
    unique_values, counts = np.unique(y, return_counts=True)
    print(f"Unique values: {unique_values}")
    print(f"Value counts: {counts}")
    
    # Classification vs Regression detection
    if len(unique_values) <= 20 and y.dtype in ['int32', 'int64'] or y.dtype == 'object':
        print("Type: Classification")
        
        # Class balance analysis
        class_ratios = counts / len(y)
        print(f"Class distribution: {dict(zip(unique_values, class_ratios))}")
        
        # Imbalance detection
        min_ratio = class_ratios.min()
        max_ratio = class_ratios.max()
        imbalance_ratio = max_ratio / min_ratio
        print(f"Imbalance ratio: {imbalance_ratio:.2f}")
        
        if imbalance_ratio > 5:
            print("WARNING: Significant class imbalance detected")
            
        # Map to names if available
        if target_names is not None:
            class_mapping = dict(zip(unique_values, target_names))
            print(f"Class mapping: {class_mapping}")
            
    else:
        print("Type: Regression")
        print(f"Target range: [{y.min():.3f}, {y.max():.3f}]")
        print(f"Target mean: {y.mean():.3f}")
        print(f"Target std: {y.std():.3f}")
        print(f"Target skewness: {((y - y.mean()) ** 3).mean() / (y.std() ** 3):.3f}")
```

