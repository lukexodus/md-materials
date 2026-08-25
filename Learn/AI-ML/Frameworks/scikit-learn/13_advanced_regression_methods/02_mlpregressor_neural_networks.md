## MLPRegressor Neural Networks


MLPRegressor implements multi-layer perceptron neural networks for regression tasks, utilizing backpropagation for training feed-forward networks with multiple hidden layers.

### Architecture Configuration

The `hidden_layer_sizes` parameter defines network architecture as tuples specifying neurons per layer. Single values create one hidden layer, while tuples create multiple layers. The `activation` function choices include 'relu', 'tanh', 'logistic', and 'identity'.

### Training Parameters

The `solver` parameter offers optimization algorithms: 'lbfgs' (small datasets), 'sgd' (stochastic gradient descent), and 'adam' (adaptive moment estimation). Learning rate control through `learning_rate_init` and `learning_rate` (constant, invscaling, adaptive) affects convergence.

Regularization prevents overfitting through `alpha` (L2 penalty), `early_stopping` (validation-based), and `max_iter` (iteration limits). The `batch_size` parameter controls mini-batch sizes for SGD and Adam solvers.

**Example:**

```python
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

# Multi-layer neural network
mlp = MLPRegressor(
    hidden_layer_sizes=(100, 50, 25),
    activation='relu',
    solver='adam',
    alpha=0.001,
    learning_rate_init=0.01,
    max_iter=1000,
    early_stopping=True,
    validation_fraction=0.1
)

# Pipeline with scaling
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('mlp', mlp)
])
pipeline.fit(X_train, y_train)
```

### Advanced Features

MLPRegressor supports warm starts for incremental learning, multiple random initializations, and adaptive learning rates. The `partial_fit` method enables online learning for large datasets. Network weights and biases are accessible through `coefs_` and `intercepts_` attributes.

