## DecisionTreeRegressor Usage


DecisionTreeRegressor creates a single decision tree that predicts target values by learning simple decision rules inferred from data features. The algorithm recursively splits the dataset based on feature values that minimize impurity, typically measured by mean squared error for regression tasks.

### Core Implementation and Parameters

```python
from sklearn.tree import DecisionTreeRegressor
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
import numpy as np
import matplotlib.pyplot as plt

# Generate sample regression data
X, y = make_regression(n_samples=1000, n_features=10, noise=0.1, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Basic decision tree regressor
dt_regressor = DecisionTreeRegressor(
    criterion='squared_error',  # Split quality measure
    max_depth=10,              # Maximum tree depth
    min_samples_split=20,      # Minimum samples to split internal node
    min_samples_leaf=10,       # Minimum samples in leaf node
    max_features='sqrt',       # Number of features for best split
    random_state=42
)

# Fit the model
dt_regressor.fit(X_train, y_train)

# Make predictions
y_pred = dt_regressor.predict(X_test)
```

### Advanced Parameter Configuration

The DecisionTreeRegressor offers sophisticated control over tree construction through various hyperparameters:

**Splitting Criteria**: Different methods for evaluating split quality

```python
# Mean squared error (default)
dt_mse = DecisionTreeRegressor(criterion='squared_error')

# Mean absolute error (more robust to outliers)
dt_mae = DecisionTreeRegressor(criterion='absolute_error')

# Friedman MSE (modified MSE with Friedman's improvement)
dt_friedman = DecisionTreeRegressor(criterion='friedman_mse')

# Poisson criterion (for count data)
dt_poisson = DecisionTreeRegressor(criterion='poisson')
```

**Tree Structure Control**: Parameters governing tree complexity

```python
# Comprehensive tree structure configuration
structured_tree = DecisionTreeRegressor(
    max_depth=15,                    # Maximum depth of tree
    min_samples_split=50,            # Minimum samples to consider split
    min_samples_leaf=20,             # Minimum samples in leaf
    min_weight_fraction_leaf=0.01,   # Minimum weighted fraction in leaf
    max_leaf_nodes=100,              # Maximum number of leaf nodes
    min_impurity_decrease=0.001,     # Minimum impurity decrease for split
    max_features=0.8,                # Fraction of features for best split
    random_state=42
)
```

**Cost-Complexity Pruning**: Post-pruning to reduce overfitting

```python
# Pre-pruning with complexity parameter
dt_pruned = DecisionTreeRegressor(
    ccp_alpha=0.01,  # Complexity parameter for minimal cost-complexity pruning
    random_state=42
)

# Find optimal alpha through cross-validation
path = dt_regressor.cost_complexity_pruning_path(X_train, y_train)
ccp_alphas = path.ccp_alphas
impurities = path.impurities

# Plot pruning path
plt.figure(figsize=(10, 6))
plt.plot(ccp_alphas[:-1], impurities[:-1], marker='o')
plt.xlabel('Effective Alpha')
plt.ylabel('Total Impurity')
plt.title('Cost Complexity Pruning Path')
```

### Tree Visualization and Interpretation

Decision trees provide excellent interpretability through visualization:

```python
from sklearn.tree import export_text, plot_tree
import matplotlib.pyplot as plt

# Text-based tree visualization
tree_rules = export_text(dt_regressor, 
                        feature_names=[f'feature_{i}' for i in range(X.shape[1])],
                        max_depth=3)
print(tree_rules)

# Graphical tree visualization
plt.figure(figsize=(20, 10))
plot_tree(dt_regressor, 
          feature_names=[f'feature_{i}' for i in range(X.shape[1])],
          filled=True, 
          max_depth=3,
          fontsize=10)
plt.title('Decision Tree Structure')
plt.show()
```

### Performance Analysis and Diagnostics

Comprehensive evaluation of decision tree performance:

```python
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error

def evaluate_tree_performance(model, X_train, X_test, y_train, y_test):
    """Comprehensive tree performance evaluation"""
    
    # Training predictions
    train_pred = model.predict(X_train)
    test_pred = model.predict(X_test)
    
    # Performance metrics
    metrics = {
        'train_rmse': np.sqrt(mean_squared_error(y_train, train_pred)),
        'test_rmse': np.sqrt(mean_squared_error(y_test, test_pred)),
        'train_r2': r2_score(y_train, train_pred),
        'test_r2': r2_score(y_test, test_pred),
        'train_mae': mean_absolute_error(y_train, train_pred),
        'test_mae': mean_absolute_error(y_test, test_pred),
        'tree_depth': model.get_depth(),
        'n_leaves': model.get_n_leaves(),
        'n_nodes': model.tree_.node_count
    }
    
    # Overfitting assessment
    metrics['overfitting_ratio'] = metrics['train_rmse'] / metrics['test_rmse']
    
    return metrics

# Evaluate model
performance = evaluate_tree_performance(dt_regressor, X_train, X_test, y_train, y_test)
```

**Key Points**:

- Highly interpretable with clear decision rules
- Prone to overfitting without proper regularization
- Handles missing values and mixed data types naturally
- Non-parametric approach captures complex relationships

