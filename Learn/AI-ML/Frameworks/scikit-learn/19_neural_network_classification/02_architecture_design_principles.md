## Architecture Design Principles


Neural network architecture design involves determining the number of hidden layers, neurons per layer, and connectivity patterns. The architecture significantly impacts the model's capacity to learn complex patterns and generalize to new data.

**Key points:**

- Layer depth affects the model's ability to learn hierarchical features
- Layer width determines the representational capacity at each level
- Architecture should match problem complexity
- Deeper networks can capture more abstract features
- Wider networks can model more complex decision boundaries

### Layer Configuration Strategies

```python
# Different architecture patterns for various problem types
architectures = {
    'shallow_wide': (500,),                    # single wide layer
    'deep_narrow': (50, 50, 50, 50),          # multiple narrow layers
    'pyramid': (200, 100, 50, 25),           # decreasing layer sizes
    'diamond': (50, 100, 200, 100, 50),      # expanding then contracting
    'uniform': (100, 100, 100),              # consistent layer sizes
}

results_architecture = {}
for name, layers in architectures.items():
    mlp = MLPClassifier(
        hidden_layer_sizes=layers,
        activation='relu',
        solver='adam',
        alpha=0.0001,
        max_iter=300,
        early_stopping=True,
        validation_fraction=0.1,
        random_state=42
    )
    
    mlp.fit(X_train_scaled, y_train)
    train_score = mlp.score(X_train_scaled, y_train)
    test_score = mlp.score(X_test_scaled, y_test)
    
    results_architecture[name] = {
        'train_score': train_score,
        'test_score': test_score,
        'n_parameters': sum([layer * next_layer for layer, next_layer in 
                            zip([X_train_scaled.shape[1]] + list(layers), 
                                list(layers) + [len(np.unique(y_train))])])
    }
    
    print(f"{name:15} - Train: {train_score:.4f}, Test: {test_score:.4f}, "
          f"Parameters: {results_architecture[name]['n_parameters']}")
```

### Capacity and Complexity Analysis

```python
def analyze_network_capacity(hidden_layers, n_features, n_classes):
    """Calculate network parameters and theoretical capacity."""
    layers = [n_features] + list(hidden_layers) + [n_classes]
    
    # Calculate weights and biases
    total_weights = sum(layers[i] * layers[i+1] for i in range(len(layers)-1))
    total_biases = sum(layers[1:])
    total_parameters = total_weights + total_biases
    
    # Estimate representational capacity
    capacity_score = np.log(total_parameters) * len(hidden_layers)
    
    return {
        'total_parameters': total_parameters,
        'total_weights': total_weights,
        'total_biases': total_biases,
        'depth': len(hidden_layers),
        'capacity_score': capacity_score
    }

# Analyze different architectures
for name, layers in architectures.items():
    capacity = analyze_network_capacity(layers, X_train_scaled.shape[1], len(np.unique(y_train)))
    print(f"{name:15} - Parameters: {capacity['total_parameters']:5d}, "
          f"Depth: {capacity['depth']}, Capacity: {capacity['capacity_score']:.2f}")
```

**Example** of adaptive architecture selection:

```python
from sklearn.model_selection import validation_curve

# Systematic architecture exploration
layer_configs = [
    (50,), (100,), (200,),
    (50, 50), (100, 100), (200, 200),
    (100, 50, 25), (200, 100, 50)
]

def evaluate_architecture(config):
    """Evaluate a specific layer configuration."""
    mlp = MLPClassifier(
        hidden_layer_sizes=config,
        activation='relu',
        solver='adam',
        alpha=0.001,
        max_iter=200,
        early_stopping=True,
        validation_fraction=0.15,
        random_state=42
    )
    
    # Use cross-validation for robust evaluation
    from sklearn.model_selection import cross_val_score
    scores = cross_val_score(mlp, X_train_scaled, y_train, cv=3, scoring='accuracy')
    return np.mean(scores), np.std(scores)

architecture_results = {}
for config in layer_configs:
    mean_score, std_score = evaluate_architecture(config)
    architecture_results[str(config)] = {'mean': mean_score, 'std': std_score}
    print(f"Architecture {str(config):20} - Mean: {mean_score:.4f} ± {std_score:.4f}")
```

