## Activation Function Selection


Activation functions introduce non-linearity into neural networks, enabling them to learn complex patterns. Different activation functions have distinct characteristics affecting training dynamics, gradient flow, and representational capacity.

**Key points:**

- Activation functions determine the network's non-linear transformations
- Choice affects gradient flow and training stability
- Different functions suit different problem types and network depths
- Modern activations like ReLU address vanishing gradient problems
- Output layer activation depends on the classification task

### Activation Function Comparison

```python
# Compare different activation functions
activations = ['identity', 'logistic', 'tanh', 'relu']

activation_results = {}
for activation in activations:
    mlp = MLPClassifier(
        hidden_layer_sizes=(100, 50),
        activation=activation,
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
    
    activation_results[activation] = {
        'train_score': train_score,
        'test_score': test_score,
        'n_iter': mlp.n_iter_,
        'loss': mlp.loss_
    }
    
    print(f"{activation:10} - Train: {train_score:.4f}, Test: {test_score:.4f}, "
          f"Iterations: {mlp.n_iter_:3d}, Final Loss: {mlp.loss_:.6f}")
```

### Custom Activation Analysis

```python
def plot_activation_functions():
    """Visualize different activation functions and their derivatives."""
    x = np.linspace(-5, 5, 1000)
    
    # Define activation functions
    def identity(x): return x
    def logistic(x): return 1 / (1 + np.exp(-np.clip(x, -500, 500)))
    def tanh(x): return np.tanh(x)
    def relu(x): return np.maximum(0, x)
    
    # Define derivatives
    def d_identity(x): return np.ones_like(x)
    def d_logistic(x): 
        s = logistic(x)
        return s * (1 - s)
    def d_tanh(x): return 1 - np.tanh(x)**2
    def d_relu(x): return (x > 0).astype(float)
    
    functions = {
        'Identity': (identity, d_identity),
        'Logistic': (logistic, d_logistic),
        'Tanh': (tanh, d_tanh),
        'ReLU': (relu, d_relu)
    }
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    fig.suptitle('Activation Functions and Their Derivatives')
    
    for i, (name, (func, dfunc)) in enumerate(functions.items()):
        row, col = i // 2, i % 2
        
        # Plot function
        axes[row, col].plot(x, func(x), 'b-', linewidth=2, label=f'{name}')
        axes[row, col].plot(x, dfunc(x), 'r--', linewidth=2, label=f"{name}'")
        axes[row, col].set_title(name)
        axes[row, col].grid(True, alpha=0.3)
        axes[row, col].legend()
        axes[row, col].set_ylim(-2, 2)
    
    plt.tight_layout()
    plt.show()

plot_activation_functions()
```

**Example** of activation function impact on deep networks:

```python
# Test activation functions with different network depths
depths = [1, 2, 4, 6]
activations = ['logistic', 'tanh', 'relu']

depth_activation_results = {}
for depth in depths:
    depth_activation_results[depth] = {}
    hidden_layers = tuple([100] * depth)
    
    for activation in activations:
        mlp = MLPClassifier(
            hidden_layer_sizes=hidden_layers,
            activation=activation,
            solver='adam',
            alpha=0.0001,
            max_iter=200,
            random_state=42
        )
        
        try:
            mlp.fit(X_train_scaled, y_train)
            test_score = mlp.score(X_test_scaled, y_test)
            depth_activation_results[depth][activation] = test_score
        except:
            depth_activation_results[depth][activation] = 0.0
        
        print(f"Depth {depth}, {activation:10}: {depth_activation_results[depth][activation]:.4f}")

# Visualize results
plt.figure(figsize=(10, 6))
for activation in activations:
    scores = [depth_activation_results[d][activation] for d in depths]
    plt.plot(depths, scores, marker='o', label=activation, linewidth=2)

plt.xlabel('Network Depth (Hidden Layers)')
plt.ylabel('Test Accuracy')
plt.title('Activation Function Performance vs Network Depth')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

