## SelectFromModel Usage


SelectFromModel provides a unified interface for feature selection based on importance weights derived from any estimator that exposes feature importance or coefficients. This meta-transformer automatically selects features based on configurable importance thresholds, making it adaptable across different machine learning algorithms.

The transformer works by fitting the provided estimator, extracting feature importance values, and selecting features that meet the specified threshold criteria. The threshold can be defined as a numeric value, statistical measure, or automatic selection based on feature importance distribution.

```python
from sklearn.feature_selection import SelectFromModel
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier
from sklearn.linear_model import LogisticRegression, Lasso
from sklearn.datasets import make_classification
import numpy as np

# Generate sample dataset
X, y = make_classification(n_samples=1000, n_features=50, n_informative=10, 
                          n_redundant=10, n_clusters_per_class=1, random_state=42)

class SelectFromModelDemo:
    def __init__(self):
        self.selectors = {}
        
    def demonstrate_threshold_options(self, X, y):
        estimator = RandomForestClassifier(n_estimators=100, random_state=42)
        
        # Different threshold strategies
        thresholds = {
            'mean': SelectFromModel(estimator, threshold='mean'),
            'median': SelectFromModel(estimator, threshold='median'),
            '0.1*mean': SelectFromModel(estimator, threshold='0.1*mean'),
            'fixed': SelectFromModel(estimator, threshold=0.01),
            'top_k': SelectFromModel(estimator, max_features=10)
        }
        
        results = {}
        for name, selector in thresholds.items():
            X_selected = selector.fit_transform(X, y)
            results[name] = {
                'n_features': X_selected.shape[1],
                'selected_features': selector.get_support(),
                'feature_importances': selector.estimator_.feature_importances_,
                'threshold_value': selector.threshold_
            }
            
        return results
```

SelectFromModel supports prefit estimators for cases where the model has already been trained, enabling feature selection without refitting the estimator.

```python
def prefit_selection_example(X, y):
    # Train the estimator separately
    estimator = RandomForestClassifier(n_estimators=100, random_state=42)
    estimator.fit(X, y)
    
    # Use prefit estimator for feature selection
    selector = SelectFromModel(estimator, prefit=True, threshold='median')
    X_selected = selector.transform(X)
    
    return X_selected, selector.get_support()
```

Advanced SelectFromModel usage includes dynamic threshold adjustment and feature selection validation through cross-validation integration.

```python
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline

class AdaptiveSelectFromModel:
    def __init__(self, estimator, cv=5):
        self.estimator = estimator
        self.cv = cv
        self.best_threshold = None
        self.best_score = 0
        
    def find_optimal_threshold(self, X, y, threshold_range=None):
        if threshold_range is None:
            # Generate threshold range based on feature importance distribution
            temp_estimator = self.estimator.__class__(**self.estimator.get_params())
            temp_estimator.fit(X, y)
            importances = temp_estimator.feature_importances_
            threshold_range = np.linspace(0.001, np.max(importances), 20)
        
        best_threshold = None
        best_score = 0
        
        for threshold in threshold_range:
            selector = SelectFromModel(self.estimator, threshold=threshold)
            pipeline = Pipeline([
                ('selector', selector),
                ('estimator', self.estimator.__class__(**self.estimator.get_params()))
            ])
            
            scores = cross_val_score(pipeline, X, y, cv=self.cv)
            mean_score = scores.mean()
            
            if mean_score > best_score:
                best_score = mean_score
                best_threshold = threshold
                
        self.best_threshold = best_threshold
        self.best_score = best_score
        
        return best_threshold, best_score
```

**Key points**: SelectFromModel provides flexibility in threshold specification, supports various estimator types, and can be seamlessly integrated into scikit-learn pipelines while maintaining proper cross-validation practices.

