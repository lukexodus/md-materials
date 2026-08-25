## Sequential Feature Selection


Sequential Feature Selection builds feature subsets by iteratively adding (forward selection) or removing (backward elimination) features based on cross-validated performance improvements. This approach directly optimizes for model performance rather than relying on feature importance proxies.

Forward selection starts with an empty feature set and gradually adds features that provide the greatest performance improvement, while backward elimination begins with all features and removes those whose absence least impacts performance.

```python
from sklearn.feature_selection import SequentialFeatureSelector
from sklearn.model_selection import cross_val_score
from sklearn.base import clone

class SequentialFeatureSelector:
    def __init__(self, estimator, direction='forward', cv=5, scoring='accuracy'):
        self.estimator = estimator
        self.direction = direction
        self.cv = cv
        self.scoring = scoring
        self.selected_features_ = None
        self.selection_history_ = []
        
    def select_features(self, X, y, n_features_to_select=None, 
                       floating=False, max_features=None):
        if n_features_to_select is None:
            n_features_to_select = min(10, X.shape[1] // 2)
        
        if self.direction == 'forward':
            return self._forward_selection(X, y, n_features_to_select, floating)
        else:
            return self._backward_elimination(X, y, n_features_to_select, floating)
    
    def _forward_selection(self, X, y, n_features_to_select, floating):
        n_features = X.shape[1]
        selected_features = set()
        feature_scores = {}
        
        for step in range(n_features_to_select):
            best_score = -np.inf
            best_feature = None
            
            # Test each remaining feature
            remaining_features = set(range(n_features)) - selected_features
            
            for feature in remaining_features:
                current_features = list(selected_features) + [feature]
                
                # Evaluate feature subset
                score = self._evaluate_feature_subset(
                    X[:, current_features], y
                )
                
                if score > best_score:
                    best_score = score
                    best_feature = feature
            
            # Add best feature
            if best_feature is not None:
                selected_features.add(best_feature)
                feature_scores[step] = best_score
                
                self.selection_history_.append({
                    'step': step,
                    'action': 'add',
                    'feature': best_feature,
                    'score': best_score,
                    'selected_features': selected_features.copy()
                })
                
                # Floating: try removing previously added features
                if floating and len(selected_features) > 1:
                    self._floating_removal(X, y, selected_features, feature_scores)
        
        self.selected_features_ = np.zeros(n_features, dtype=bool)
        self.selected_features_[list(selected_features)] = True
        
        return X[:, self.selected_features_], self.selected_features_
    
    def _floating_removal(self, X, y, selected_features, feature_scores):
        """Conditional exclusion for floating selection"""
        improved = True
        
        while improved and len(selected_features) > 1:
            improved = False
            best_score = -np.inf
            worst_feature = None
            
            for feature in selected_features:
                test_features = selected_features - {feature}
                score = self._evaluate_feature_subset(
                    X[:, list(test_features)], y
                )
                
                if score > best_score:
                    best_score = score
                    worst_feature = feature
            
            # Remove feature if improvement is significant
            current_score = self._evaluate_feature_subset(
                X[:, list(selected_features)], y
            )
            
            if best_score > current_score:
                selected_features.remove(worst_feature)
                improved = True
                
                self.selection_history_.append({
                    'step': len(self.selection_history_),
                    'action': 'remove',
                    'feature': worst_feature,
                    'score': best_score,
                    'selected_features': selected_features.copy()
                })
    
    def _evaluate_feature_subset(self, X_subset, y):
        """Evaluate feature subset using cross-validation"""
        scores = cross_val_score(
            self.estimator, X_subset, y,
            cv=self.cv, scoring=self.scoring
        )
        return scores.mean()
```

Bidirectional sequential selection combines forward and backward strategies, allowing for more thorough exploration of the feature space.

```python
class BidirectionalSequentialSelector:
    def __init__(self, estimator, cv=5, scoring='accuracy'):
        self.estimator = estimator
        self.cv = cv
        self.scoring = scoring
        
    def bidirectional_selection(self, X, y, max_features=None, tolerance=0.001):
        if max_features is None:
            max_features = min(20, X.shape[1])
        
        # Initialize with forward selection
        forward_selector = SequentialFeatureSelector(
            clone(self.estimator), 'forward', self.cv, self.scoring
        )
        
        X_forward, selected_forward = forward_selector.select_features(
            X, y, max_features // 2
        )
        
        # Refine with backward elimination on selected features
        backward_selector = SequentialFeatureSelector(
            clone(self.estimator), 'backward', self.cv, self.scoring
        )
        
        X_final, selected_final = backward_selector.select_features(
            X_forward, y, max_features // 3
        )
        
        # Map back to original feature indices
        forward_indices = np.where(selected_forward)[0]
        final_indices = forward_indices[selected_final]
        
        original_selected = np.zeros(X.shape[1], dtype=bool)
        original_selected[final_indices] = True
        
        return X[:, original_selected], original_selected
```

Sequential feature selection with early stopping prevents overfitting by monitoring validation performance and stopping when no significant improvement is observed.

```python
class EarlyStoppingSequentialSelector:
    def __init__(self, estimator, patience=3, min_improvement=0.001):
        self.estimator = estimator
        self.patience = patience
        self.min_improvement = min_improvement
        
    def select_with_early_stopping(self, X, y, cv=5):
        n_features = X.shape[1]
        selected_features = set()
        best_score = -np.inf
        patience_counter = 0
        
        for step in range(n_features):
            step_best_score = -np.inf
            step_best_feature = None
            
            remaining_features = set(range(n_features)) - selected_features
            
            if not remaining_features:
                break
                
            for feature in remaining_features:
                current_features = list(selected_features) + [feature]
                scores = cross_val_score(
                    self.estimator, X[:, current_features], y, cv=cv
                )
                score = scores.mean()
                
                if score > step_best_score:
                    step_best_score = score
                    step_best_feature = feature
            
            # Check for improvement
            if step_best_score > best_score + self.min_improvement:
                selected_features.add(step_best_feature)
                best_score = step_best_score
                patience_counter = 0
            else:
                patience_counter += 1
                
                if patience_counter >= self.patience:
                    break
        
        final_selection = np.zeros(n_features, dtype=bool)
        final_selection[list(selected_features)] = True
        
        return X[:, final_selection], final_selection, best_score
```

**Key points**: Sequential feature selection directly optimizes for model performance, naturally handles feature interactions, and provides interpretable selection paths but requires significant computational resources for large feature sets.

**Output**: Model-based feature selection techniques provide sophisticated approaches to dimensionality reduction that consider the actual predictive value of features within the context of specific machine learning algorithms, resulting in more targeted and effective feature subsets.

**Conclusion**: Model-based feature selection represents the most sophisticated approach to feature selection, leveraging the intrinsic properties of machine learning algorithms to identify truly relevant features. The combination of SelectFromModel's flexibility, L1 regularization's automatic sparsity, tree-based importance measures, RFE's systematic approach, and sequential selection's performance optimization creates a comprehensive toolkit for addressing diverse feature selection challenges across different domains and dataset characteristics.

**Next steps**: Advanced model-based feature selection topics include multi-objective feature selection, stability-based selection methods, feature selection for deep learning architectures, and ensemble-based selection strategies that combine multiple model-based approaches for enhanced robustness and performance.

---

