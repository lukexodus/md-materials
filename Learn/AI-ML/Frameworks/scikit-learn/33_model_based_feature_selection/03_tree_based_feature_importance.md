## Tree-based Feature Importance


Tree-based algorithms naturally provide feature importance measures through their splitting criteria, making them excellent choices for feature selection. These importance scores reflect how much each feature contributes to decreasing node impurity across all trees in ensemble methods.

Random Forest and Extra Trees calculate feature importance based on the average impurity decrease caused by splits on each feature, weighted by the number of samples reaching each node. This approach considers feature interactions and provides robust importance estimates.

```python
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier, GradientBoostingClassifier
from sklearn.tree import DecisionTreeClassifier
import pandas as pd

class TreeBasedFeatureSelector:
    def __init__(self, estimator_type='random_forest', n_estimators=100):
        self.estimator_type = estimator_type
        self.n_estimators = n_estimators
        self.feature_importances_ = None
        self.selected_features_ = None
        
    def fit_transform(self, X, y, threshold='median', feature_names=None):
        # Initialize appropriate tree-based estimator
        estimators = {
            'random_forest': RandomForestClassifier(
                n_estimators=self.n_estimators, random_state=42
            ),
            'extra_trees': ExtraTreesClassifier(
                n_estimators=self.n_estimators, random_state=42
            ),
            'gradient_boosting': GradientBoostingClassifier(
                n_estimators=self.n_estimators, random_state=42
            )
        }
        
        estimator = estimators[self.estimator_type]
        
        # Fit estimator and extract feature importances
        estimator.fit(X, y)
        self.feature_importances_ = estimator.feature_importances_
        
        # Apply SelectFromModel with specified threshold
        selector = SelectFromModel(estimator, threshold=threshold, prefit=True)
        X_selected = selector.transform(X)
        self.selected_features_ = selector.get_support()
        
        # Create importance summary
        if feature_names is not None:
            importance_df = pd.DataFrame({
                'feature': feature_names,
                'importance': self.feature_importances_,
                'selected': self.selected_features_
            }).sort_values('importance', ascending=False)
            
            return X_selected, importance_df
        
        return X_selected, self.selected_features_
```

Permutation importance provides an alternative tree-based importance measure that assesses feature relevance by measuring the decrease in model performance when feature values are randomly permuted.

```python
from sklearn.inspection import permutation_importance

class PermutationBasedSelector:
    def __init__(self, estimator, scoring='accuracy', n_repeats=10):
        self.estimator = estimator
        self.scoring = scoring
        self.n_repeats = n_repeats
        
    def get_permutation_importance(self, X, y):
        # Fit the estimator
        self.estimator.fit(X, y)
        
        # Calculate permutation importance
        perm_importance = permutation_importance(
            self.estimator, X, y,
            scoring=self.scoring,
            n_repeats=self.n_repeats,
            random_state=42
        )
        
        return {
            'importances_mean': perm_importance.importances_mean,
            'importances_std': perm_importance.importances_std,
            'importances': perm_importance.importances
        }
    
    def select_features(self, X, y, threshold_percentile=75):
        importance_data = self.get_permutation_importance(X, y)
        
        # Select features above threshold percentile
        threshold_value = np.percentile(
            importance_data['importances_mean'], threshold_percentile
        )
        
        selected_features = importance_data['importances_mean'] >= threshold_value
        
        return X[:, selected_features], selected_features
```

Ensemble-based importance aggregation combines multiple tree-based estimators to create more robust feature importance estimates, reducing variance in importance scores.

```python
class EnsembleImportanceSelector:
    def __init__(self, estimators=None):
        if estimators is None:
            self.estimators = {
                'rf': RandomForestClassifier(n_estimators=100, random_state=42),
                'et': ExtraTreesClassifier(n_estimators=100, random_state=42),
                'gb': GradientBoostingClassifier(n_estimators=100, random_state=42)
            }
        else:
            self.estimators = estimators
            
    def aggregate_importance(self, X, y, aggregation='mean'):
        importance_matrix = []
        
        for name, estimator in self.estimators.items():
            estimator.fit(X, y)
            importance_matrix.append(estimator.feature_importances_)
        
        importance_matrix = np.array(importance_matrix)
        
        if aggregation == 'mean':
            aggregated_importance = np.mean(importance_matrix, axis=0)
        elif aggregation == 'median':
            aggregated_importance = np.median(importance_matrix, axis=0)
        elif aggregation == 'max':
            aggregated_importance = np.max(importance_matrix, axis=0)
        
        return aggregated_importance, importance_matrix
```

**Key points**: Tree-based feature importance considers feature interactions naturally, provides interpretable results, and scales well to high-dimensional datasets while being robust to outliers and non-linear relationships.

