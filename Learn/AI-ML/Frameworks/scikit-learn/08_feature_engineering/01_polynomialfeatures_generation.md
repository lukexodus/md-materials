## PolynomialFeatures Generation


PolynomialFeatures creates polynomial and interaction features from existing features, enabling linear models to capture non-linear relationships.

```python
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import numpy as np
import pandas as pd

# Generate sample data
np.random.seed(42)
X = np.random.randn(1000, 3)
y = 2*X[:, 0]**2 + 3*X[:, 1] + X[:, 0]*X[:, 2] + np.random.randn(1000)*0.1

# Basic polynomial features
poly = PolynomialFeatures(degree=2, include_bias=False)
X_poly = poly.fit_transform(X)

print("Original features shape:", X.shape)
print("Polynomial features shape:", X_poly.shape)
print("Feature names:", poly.get_feature_names_out(['x1', 'x2', 'x3']))

# Different polynomial configurations
configs = {
    'degree_2_no_interaction': PolynomialFeatures(degree=2, interaction_only=False, include_bias=False),
    'degree_2_interaction_only': PolynomialFeatures(degree=2, interaction_only=True, include_bias=False),
    'degree_3_with_bias': PolynomialFeatures(degree=3, include_bias=True),
    'degree_2_specific_features': PolynomialFeatures(degree=2, include_bias=False)
}

# Compare performance with different polynomial degrees
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

results = {}
for name, poly_transformer in configs.items():
    # Create pipeline
    pipeline = Pipeline([
        ('poly', poly_transformer),
        ('linear', LinearRegression())
    ])
    
    pipeline.fit(X_train, y_train)
    y_pred = pipeline.predict(X_test)
    score = r2_score(y_test, y_pred)
    
    results[name] = {
        'r2_score': score,
        'n_features': poly_transformer.fit_transform(X_train).shape[1]
    }

print("\nPerformance comparison:")
for name, metrics in results.items():
    print(f"{name}: R² = {metrics['r2_score']:.4f}, Features = {metrics['n_features']}")

# Advanced: Custom degree limits per feature
from itertools import combinations_with_replacement

def custom_polynomial_features(X, max_degrees):
    """Create polynomial features with different max degrees per feature"""
    n_samples, n_features = X.shape
    feature_combinations = []
    
    # Generate all valid combinations
    for total_degree in range(1, max(max_degrees) + 1):
        for combo in combinations_with_replacement(range(n_features), total_degree):
            if all(combo.count(i) <= max_degrees[i] for i in range(n_features)):
                feature_combinations.append(combo)
    
    # Create polynomial features
    X_poly = np.ones((n_samples, len(feature_combinations)))
    for i, combo in enumerate(feature_combinations):
        for j in combo:
            X_poly[:, i] *= X[:, j]
    
    return X_poly, feature_combinations

# Example: x1 max degree 3, x2 max degree 2, x3 max degree 1
X_custom, combinations = custom_polynomial_features(X, [3, 2, 1])
print(f"\nCustom polynomial features shape: {X_custom.shape}")
print(f"Feature combinations: {combinations[:10]}...")  # Show first 10
```

**Key points:**

- PolynomialFeatures generates all polynomial combinations up to specified degree
- `interaction_only=True` creates only interaction terms without pure powers
- `include_bias=False` excludes constant term for most use cases
- Feature explosion occurs rapidly with higher degrees and more input features

**Example:** With 3 features and degree 2, you get 9 polynomial features: x₁², x₂², x₃², x₁x₂, x₁x₃, x₂x₃, x₁, x₂, x₃

