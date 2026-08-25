## Target Encoding Strategies


Target encoding creates numerical representations based on the relationship between categorical values and the target variable. This approach leverages statistical properties of categories relative to the target, potentially improving model performance while requiring careful implementation to avoid data leakage.

### Basic Target Encoding Implementation

```python
import pandas as pd
import numpy as np
from sklearn.model_selection import KFold

def target_encode(X_train, y_train, X_val, column, smoothing=1.0):
    """
    Implement target encoding with smoothing
    """
    # Calculate global mean
    global_mean = y_train.mean()
    
    # Calculate category statistics
    category_stats = X_train.groupby(column).agg({
        column: 'count'
    }).rename(columns={column: 'count'})
    
    category_means = X_train.groupby(column)[y_train.name].mean()
    
    # Apply smoothing
    smoothed_means = (
        (category_means * category_stats['count'] + global_mean * smoothing) /
        (category_stats['count'] + smoothing)
    )
    
    # Map to validation set
    return X_val[column].map(smoothed_means).fillna(global_mean)
```

### Cross-validation Target Encoding

Proper target encoding requires cross-validation to prevent overfitting:

```python
def cv_target_encode(X, y, column, cv=5, smoothing=1.0):
    """
    Cross-validated target encoding
    """
    kf = KFold(n_splits=cv, shuffle=True, random_state=42)
    encoded_values = np.zeros(len(X))
    
    for train_idx, val_idx in kf.split(X):
        X_train, X_val = X.iloc[train_idx], X.iloc[val_idx]
        y_train = y.iloc[train_idx]
        
        encoded_values[val_idx] = target_encode(
            X_train, y_train, X_val, column, smoothing
        )
    
    return encoded_values

# Usage example
df = pd.DataFrame({
    'category': ['A', 'B', 'A', 'C', 'B', 'A', 'C'],
    'target': [1, 0, 1, 1, 0, 1, 0]
})

encoded = cv_target_encode(df[['category']], df['target'], 'category')
```

### Advanced Target Encoding Techniques

**Bayesian Target Encoding**: Incorporates prior beliefs about category distributions

```python
def bayesian_target_encode(X_train, y_train, X_val, column, alpha=1, beta=1):
    """
    Bayesian approach with beta prior
    """
    category_stats = X_train.groupby(column).agg({
        y_train.name: ['sum', 'count']
    }).droplevel(0, axis=1)
    
    # Beta distribution parameters
    alpha_post = category_stats['sum'] + alpha
    beta_post = category_stats['count'] - category_stats['sum'] + beta
    
    # Posterior mean
    posterior_means = alpha_post / (alpha_post + beta_post)
    
    return X_val[column].map(posterior_means).fillna(0.5)
```

**Leave-one-out Encoding**: Excludes current observation from calculation

```python
def loo_target_encode(X, y, column):
    """
    Leave-one-out target encoding
    """
    encoded_values = np.zeros(len(X))
    
    for i in range(len(X)):
        category = X.iloc[i][column]
        mask = (X[column] == category) & (X.index != i)
        
        if mask.sum() > 0:
            encoded_values[i] = y[mask].mean()
        else:
            encoded_values[i] = y.mean()  # Global mean for single occurrence
    
    return encoded_values
```

### Regularization and Smoothing

Smoothing parameters control the balance between category-specific statistics and global trends:

```python
# High smoothing: more conservative, closer to global mean
conservative_encoding = target_encode(X_train, y_train, X_val, 'category', smoothing=100)

# Low smoothing: more aggressive, closer to category means
aggressive_encoding = target_encode(X_train, y_train, X_val, 'category', smoothing=0.1)
```

**Key Points**:

- Leverages target-category relationships for encoding
- Requires cross-validation to prevent data leakage
- Smoothing parameters balance specificity and generalization
- Effective for high-cardinality categorical features

