## Comprehensive Feature Selection Pipeline


Combining multiple univariate methods provides robust feature selection by leveraging different statistical assumptions and capturing various types of relationships.

```python
from sklearn.feature_selection import SelectKBest, chi2, f_classif, mutual_info_classif
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline
import pandas as pd

def comprehensive_feature_selection(X, y, k=10):
    """
    Apply multiple univariate feature selection methods and combine results
    """
    results = {}
    
    # Prepare data for chi-square (requires non-negative values)
    scaler_minmax = MinMaxScaler()
    X_scaled = scaler_minmax.fit_transform(X)
    
    # Chi-square test
    chi2_scores, chi2_pvals = chi2(X_scaled, y)
    chi2_selector = SelectKBest(chi2, k=k)
    chi2_selector.fit(X_scaled, y)
    results['chi2'] = {
        'scores': chi2_scores,
        'selected_features': chi2_selector.get_support(indices=True),
        'selector': chi2_selector
    }
    
    # ANOVA F-test
    f_scores, f_pvals = f_classif(X, y)
    f_selector = SelectKBest(f_classif, k=k)
    f_selector.fit(X, y)
    results['f_test'] = {
        'scores': f_scores,
        'selected_features': f_selector.get_support(indices=True),
        'selector': f_selector
    }
    
    # Mutual Information
    mi_scores = mutual_info_classif(X, y, random_state=42)
    mi_selector = SelectKBest(mutual_info_classif, k=k)
    mi_selector.fit(X, y)
    results['mutual_info'] = {
        'scores': mi_scores,
        'selected_features': mi_selector.get_support(indices=True),
        'selector': mi_selector
    }
    
    return results

# Apply to breast cancer dataset
X, y = load_breast_cancer(return_X_y=True)
feature_names = load_breast_cancer().feature_names

results = comprehensive_feature_selection(X, y, k=10)

# Analyze feature overlap
chi2_features = set(results['chi2']['selected_features'])
f_test_features = set(results['f_test']['selected_features'])
mi_features = set(results['mutual_info']['selected_features'])

common_features = chi2_features & f_test_features & mi_features
print(f"Features selected by all methods: {len(common_features)}")
print(f"Feature names: {[feature_names[i] for i in common_features]}")

# Evaluate each method's performance
for method_name, method_data in results.items():
    X_selected = method_data['selector'].transform(X)
    
    # Create pipeline with selected features
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('classifier', RandomForestClassifier(random_state=42))
    ])
    
    scores = cross_val_score(pipeline, X_selected, y, cv=5)
    print(f"{method_name.upper()}: CV Score = {scores.mean():.4f} (+/- {scores.std() * 2:.4f})")
```

