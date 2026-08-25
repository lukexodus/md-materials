## MLPClassifier Implementation


The MLPClassifier implements a multi-layer perceptron using backpropagation for training. It supports multiple hidden layers, various activation functions, and different solvers for optimization, making it suitable for complex classification problems where linear methods fail.

**Key points:**

- Implements feedforward neural networks with backpropagation
- Supports multiple hidden layers with configurable sizes
- Offers various solvers: lbfgs, sgd, and adam
- Handles both binary and multi-class classification
- Provides probability estimates for prediction confidence

```python
from sklearn.neural_network import MLPClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np
import matplotlib.pyplot as plt

# Generate sample data
X, y = make_classification(
    n_samples=2000, 
    n_features=20, 
    n_classes=3, 
    n_informative=15,
    n_redundant=5,
    random_state=42
)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42, stratify=y
)

# Feature scaling is crucial for neural networks
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Basic MLPClassifier implementation
mlp_basic = MLPClassifier(
    hidden_layer_sizes=(100,),    # single hidden layer with 100 neurons
    activation='relu',            # rectified linear unit activation
    solver='adam',                # adam optimizer
    alpha=0.0001,                # L2 regularization parameter
    batch_size='auto',           # automatic batch size selection
    learning_rate='constant',     # constant learning rate
    learning_rate_init=0.001,    # initial learning rate
    max_iter=200,                # maximum iterations
    random_state=42,
    early_stopping=False         # early stopping based on validation loss
)

mlp_basic.fit(X_train_scaled, y_train)
y_pred_basic = mlp_basic.predict(X_test_scaled)

print("Basic MLP Results:")
print(f"Training Score: {mlp_basic.score(X_train_scaled, y_train):.4f}")
print(f"Test Score: {mlp_basic.score(X_test_scaled, y_test):.4f}")
print(f"Number of iterations: {mlp_basic.n_iter_}")
```

The MLPClassifier requires proper data preprocessing, particularly feature scaling, as neural networks are sensitive to feature magnitudes. The solver choice significantly impacts performance: 'lbfgs' works well for small datasets, 'sgd' for large datasets with online learning, and 'adam' provides robust performance across various scenarios.

**Example** of advanced configuration with monitoring:

```python
# Advanced MLP with comprehensive monitoring
mlp_advanced = MLPClassifier(
    hidden_layer_sizes=(200, 100, 50),  # three hidden layers
    activation='tanh',                   # hyperbolic tangent activation
    solver='adam',
    alpha=0.001,                        # increased regularization
    batch_size=32,                      # mini-batch size
    learning_rate='adaptive',           # adaptive learning rate
    learning_rate_init=0.01,
    max_iter=500,
    validation_fraction=0.1,            # fraction for early stopping
    beta_1=0.9,                        # exponential decay rate for adam
    beta_2=0.999,                      # exponential decay rate for adam
    epsilon=1e-8,                      # numerical stability
    n_iter_no_change=10,               # patience for early stopping
    early_stopping=True,
    random_state=42
)

mlp_advanced.fit(X_train_scaled, y_train)

# Access training history
loss_curve = mlp_advanced.loss_curve_
validation_scores = mlp_advanced.validation_scores_

plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.plot(loss_curve, label='Training Loss')
plt.xlabel('Iterations')
plt.ylabel('Loss')
plt.title('Training Loss Curve')
plt.legend()

plt.subplot(1, 2, 2)
if validation_scores is not None:
    plt.plot(validation_scores, label='Validation Score')
    plt.xlabel('Iterations')
    plt.ylabel('Accuracy')
    plt.title('Validation Score Curve')
    plt.legend()
plt.tight_layout()
plt.show()
```

