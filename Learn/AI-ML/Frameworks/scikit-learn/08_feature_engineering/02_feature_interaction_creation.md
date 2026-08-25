## Feature Interaction Creation


Beyond polynomial features, scikit-learn enables sophisticated interaction feature creation through various approaches.

```python
from sklearn.preprocessing import FunctionTransformer, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline, FeatureUnion
import numpy as np
import pandas as pd
from itertools import combinations

# Sample dataset with different feature types
np.random.seed(42)
data = pd.DataFrame({
    'numerical_1': np.random.randn(1000),
    'numerical_2': np.random.randn(1000),
    'categorical_1': np.random.choice(['A', 'B', 'C'], 1000),
    'categorical_2': np.random.choice(['X', 'Y'], 1000),
    'binary_feature': np.random.choice([0, 1], 1000),
    'continuous_feature': np.random.exponential(2, 1000)
})

# 1. Multiplicative interactions
def create_multiplicative_interactions(X):
    """Create all pairwise multiplicative interactions"""
    if hasattr(X, 'columns'):
        feature_names = X.columns
        X_array = X.values
    else:
        X_array = X
        feature_names = [f'feature_{i}' for i in range(X.shape[1])]
    
    interactions = []
    interaction_names = []
    
    for i, j in combinations(range(X_array.shape[1]), 2):
        interactions.append((X_array[:, i] * X_array[:, j]).reshape(-1, 1))
        interaction_names.append(f'{feature_names[i]}_x_{feature_names[j]}')
    
    if interactions:
        return np.hstack(interactions), interaction_names
    return np.array([]).reshape(X_array.shape[0], 0), []

# 2. Ratio-based interactions
def create_ratio_interactions(X):
    """Create ratio-based interactions for numerical features"""
    if hasattr(X, 'columns'):
        X_array = X.values
        feature_names = X.columns
    else:
        X_array = X
        feature_names = [f'feature_{i}' for i in range(X.shape[1])]
    
    ratios = []
    ratio_names = []
    
    for i, j in combinations(range(X_array.shape[1]), 2):
        # Avoid division by zero
        denominator = X_array[:, j]
        denominator = np.where(np.abs(denominator) < 1e-8, 1e-8, denominator)
        ratio = (X_array[:, i] / denominator).reshape(-1, 1)
        ratios.append(ratio)
        ratio_names.append(f'{feature_names[i]}_div_{feature_names[j]}')
    
    if ratios:
        return np.hstack(ratios), ratio_names
    return np.array([]).reshape(X_array.shape[0], 0), []

# 3. Statistical interactions
def create_statistical_interactions(X):
    """Create statistical interaction features"""
    if hasattr(X, 'columns'):
        X_array = X.values
    else:
        X_array = X
    
    interactions = []
    
    # Mean-centered products
    X_centered = X_array - np.mean(X_array, axis=0)
    for i, j in combinations(range(X_array.shape[1]), 2):
        interactions.append((X_centered[:, i] * X_centered[:, j]).reshape(-1, 1))
    
    # Difference features
    for i, j in combinations(range(X_array.shape[1]), 2):
        interactions.append((X_array[:, i] - X_array[:, j]).reshape(-1, 1))
    
    # Sum features
    for i, j in combinations(range(X_array.shape[1]), 2):
        interactions.append((X_array[:, i] + X_array[:, j]).reshape(-1, 1))
    
    if interactions:
        return np.hstack(interactions)
    return np.array([]).reshape(X_array.shape[0], 0)

# 4. Conditional interactions
def create_conditional_interactions(X_num, X_cat):
    """Create interactions conditioned on categorical features"""
    interactions = []
    
    # For each categorical feature, create conditional numerical interactions
    for cat_col in range(X_cat.shape[1]):
        unique_values = np.unique(X_cat[:, cat_col])
        for value in unique_values:
            mask = X_cat[:, cat_col] == value
            # Create interaction only for samples with this categorical value
            conditional_feature = np.zeros(X_num.shape[0])
            if np.sum(mask) > 0:  # If this category exists
                conditional_feature[mask] = X_num[mask, 0] * X_num[mask, 1] if X_num.shape[1] > 1 else X_num[mask, 0]
            interactions.append(conditional_feature.reshape(-1, 1))
    
    return np.hstack(interactions) if interactions else np.array([]).reshape(X_num.shape[0], 0)

# Apply interaction creation
numerical_features = ['numerical_1', 'numerical_2', 'continuous_feature']
X_numerical = data[numerical_features]

# Create different types of interactions
mult_interactions, mult_names = create_multiplicative_interactions(X_numerical)
ratio_interactions, ratio_names = create_ratio_interactions(X_numerical)
stat_interactions = create_statistical_interactions(X_numerical)

print("Original numerical features:", X_numerical.shape[1])
print("Multiplicative interactions:", mult_interactions.shape[1])
print("Ratio interactions:", ratio_interactions.shape[1])
print("Statistical interactions:", stat_interactions.shape[1])

# 5. Custom interaction transformers
class InteractionTransformer:
    def __init__(self, interaction_type='multiplicative'):
        self.interaction_type = interaction_type
        self.feature_names_ = None
    
    def fit(self, X, y=None):
        if hasattr(X, 'columns'):
            self.feature_names_ = X.columns.tolist()
        else:
            self.feature_names_ = [f'feature_{i}' for i in range(X.shape[1])]
        return self
    
    def transform(self, X):
        if self.interaction_type == 'multiplicative':
            interactions, _ = create_multiplicative_interactions(X)
        elif self.interaction_type == 'ratio':
            interactions, _ = create_ratio_interactions(X)
        elif self.interaction_type == 'statistical':
            interactions = create_statistical_interactions(X)
        else:
            raise ValueError(f"Unknown interaction type: {self.interaction_type}")
        
        return interactions
    
    def fit_transform(self, X, y=None):
        return self.fit(X, y).transform(X)

# Pipeline with multiple interaction types
interaction_pipeline = FeatureUnion([
    ('multiplicative', FunctionTransformer(
        func=lambda X: create_multiplicative_interactions(X)[0],
        validate=False
    )),
    ('ratio', FunctionTransformer(
        func=lambda X: create_ratio_interactions(X)[0],
        validate=False
    )),
    ('original', FunctionTransformer(
        func=lambda X: X.values if hasattr(X, 'values') else X,
        validate=False
    ))
])

# Apply the pipeline
X_with_interactions = interaction_pipeline.fit_transform(X_numerical)
print(f"\nFinal feature matrix shape: {X_with_interactions.shape}")

# Domain-specific interaction example: Financial ratios
def create_financial_interactions(data):
    """Create domain-specific financial ratio interactions"""
    interactions = pd.DataFrame()
    
    # Assuming financial features like revenue, cost, assets, liabilities
    if all(col in data.columns for col in ['revenue', 'cost', 'assets', 'liabilities']):
        interactions['profit_margin'] = (data['revenue'] - data['cost']) / data['revenue']
        interactions['debt_ratio'] = data['liabilities'] / data['assets']
        interactions['roa'] = (data['revenue'] - data['cost']) / data['assets']
        interactions['leverage_profit'] = interactions['debt_ratio'] * interactions['profit_margin']
    
    return interactions
```

**Key points:**

- Multiplicative interactions capture synergistic effects between features
- Ratio interactions reveal relative relationships and scaling effects
- Conditional interactions enable category-specific feature behaviors
- Statistical interactions include differences, sums, and centered products

