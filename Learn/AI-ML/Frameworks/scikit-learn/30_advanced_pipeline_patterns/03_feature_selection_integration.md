## Feature Selection Integration


### Multi-Stage Feature Selection

Sophisticated feature selection combines multiple techniques sequentially, leveraging different selection criteria to create robust feature subsets. Early stages remove obviously irrelevant features, while later stages fine-tune selections based on model performance.

```python
from sklearn.feature_selection import VarianceThreshold, mutual_info_classif
from sklearn.feature_selection import RFECV, SelectFromModel

class MultiStageFeatureSelector(BaseEstimator, TransformerMixin):
    def __init__(self, variance_threshold=0.01, mutual_info_percentile=50, 
                 final_k_features=10):
        self.variance_threshold = variance_threshold
        self.mutual_info_percentile = mutual_info_percentile
        self.final_k_features = final_k_features
        
        self.stage1_selector = None
        self.stage2_selector = None
        self.stage3_selector = None
        self.selected_features_ = None
    
    def fit(self, X, y=None):
        # Stage 1: Remove low variance features
        self.stage1_selector = VarianceThreshold(threshold=self.variance_threshold)
        X_stage1 = self.stage1_selector.fit_transform(X)
        
        # Stage 2: Mutual information based selection
        mutual_info_scores = mutual_info_classif(X_stage1, y)
        threshold = np.percentile(mutual_info_scores, self.mutual_info_percentile)
        self.stage2_selector = SelectKBest(
            lambda X, y: mutual_info_classif(X, y), 
            k=min(len(mutual_info_scores[mutual_info_scores >= threshold]), 
                  X_stage1.shape[1])
        )
        X_stage2 = self.stage2_selector.fit_transform(X_stage1, y)
        
        # Stage 3: Model-based recursive elimination
        base_estimator = RandomForestClassifier(n_estimators=50, random_state=42)
        self.stage3_selector = RFECV(
            base_estimator, 
            min_features_to_select=min(self.final_k_features, X_stage2.shape[1]),
            cv=3
        )
        self.stage3_selector.fit(X_stage2, y)
        
        return self
    
    def transform(self, X):
        X_stage1 = self.stage1_selector.transform(X)
        X_stage2 = self.stage2_selector.transform(X_stage1)
        X_stage3 = self.stage3_selector.transform(X_stage2)
        return X_stage3
    
    def get_selected_features(self, feature_names):
        # Map selected features back to original names
        stage1_mask = self.stage1_selector.get_support()
        stage1_features = np.array(feature_names)[stage1_mask]
        
        stage2_mask = self.stage2_selector.get_support()
        stage2_features = stage1_features[stage2_mask]
        
        stage3_mask = self.stage3_selector.get_support()
        final_features = stage2_features[stage3_mask]
        
        return final_features.tolist()

# Integration in pipeline
multi_stage_pipeline = Pipeline([
    ('preprocessing', StandardScaler()),
    ('feature_selection', MultiStageFeatureSelector(final_k_features=15)),
    ('classifier', LogisticRegression())
])
```

### Ensemble Feature Selection

Ensemble approaches combine multiple feature selection methods, using voting or consensus mechanisms to identify robust feature subsets that perform well across different selection criteria.

```python
class EnsembleFeatureSelector(BaseEstimator, TransformerMixin):
    def __init__(self, n_features_to_select=10, consensus_threshold=0.6):
        self.n_features_to_select = n_features_to_select
        self.consensus_threshold = consensus_threshold
        self.selectors = []
        self.final_mask_ = None
    
    def fit(self, X, y=None):
        # Initialize multiple selector types
        self.selectors = [
            SelectKBest(f_classif, k=self.n_features_to_select),
            SelectKBest(mutual_info_classif, k=self.n_features_to_select),
            SelectFromModel(RandomForestClassifier(n_estimators=50), 
                          max_features=self.n_features_to_select),
            RFECV(LogisticRegression(max_iter=1000), 
                  min_features_to_select=self.n_features_to_select, cv=3)
        ]
        
        # Fit all selectors and collect selections
        selection_masks = []
        for selector in self.selectors:
            try:
                selector.fit(X, y)
                mask = selector.get_support()
                selection_masks.append(mask)
            except Exception as e:
                print(f"Selector failed: {e}")
                continue
        
        # Consensus voting
        if selection_masks:
            vote_counts = np.sum(selection_masks, axis=0)
            consensus_threshold_count = len(selection_masks) * self.consensus_threshold
            self.final_mask_ = vote_counts >= consensus_threshold_count
            
            # Ensure we have at least some features
            if np.sum(self.final_mask_) < self.n_features_to_select:
                top_voted_indices = np.argsort(vote_counts)[-self.n_features_to_select:]
                self.final_mask_ = np.zeros(len(vote_counts), dtype=bool)
                self.final_mask_[top_voted_indices] = True
        
        return self
    
    def transform(self, X):
        if hasattr(X, 'iloc'):
            return X.iloc[:, self.final_mask_]
        else:
            return X[:, self.final_mask_]
```

### Dynamic Feature Selection

Dynamic feature selection adapts selection criteria based on model performance feedback, iteratively refining feature subsets through performance evaluation loops.

```python
class DynamicFeatureSelector(BaseEstimator, TransformerMixin):
    def __init__(self, base_estimator=None, scoring='accuracy', cv=3, 
                 max_iterations=5, improvement_threshold=0.01):
        self.base_estimator = base_estimator or LogisticRegression()
        self.scoring = scoring
        self.cv = cv
        self.max_iterations = max_iterations
        self.improvement_threshold = improvement_threshold
        self.selected_features_ = None
        self.performance_history_ = []
    
    def fit(self, X, y=None):
        from sklearn.model_selection import cross_val_score
        
        current_features = np.arange(X.shape[1])
        best_score = -np.inf
        best_features = current_features.copy()
        
        for iteration in range(self.max_iterations):
            # Evaluate current feature set
            X_current = X[:, current_features] if not hasattr(X, 'iloc') else X.iloc[:, current_features]
            scores = cross_val_score(self.base_estimator, X_current, y, 
                                   cv=self.cv, scoring=self.scoring)
            current_score = np.mean(scores)
            self.performance_history_.append(current_score)
            
            if current_score > best_score + self.improvement_threshold:
                best_score = current_score
                best_features = current_features.copy()
            else:
                break  # No significant improvement
            
            # Feature elimination step
            if len(current_features) > 1:
                feature_importance = self._get_feature_importance(X_current, y)
                # Remove least important feature
                least_important = np.argmin(feature_importance)
                current_features = np.delete(current_features, least_important)
        
        self.selected_features_ = best_features
        return self
    
    def transform(self, X):
        if hasattr(X, 'iloc'):
            return X.iloc[:, self.selected_features_]
        else:
            return X[:, self.selected_features_]
    
    def _get_feature_importance(self, X, y):
        # Fit model to get feature importance
        self.base_estimator.fit(X, y)
        if hasattr(self.base_estimator, 'feature_importances_'):
            return self.base_estimator.feature_importances_
        elif hasattr(self.base_estimator, 'coef_'):
            return np.abs(self.base_estimator.coef_[0])
        else:
            # Fallback: permutation importance
            from sklearn.inspection import permutation_importance
            perm_importance = permutation_importance(self.base_estimator, X, y, 
                                                   n_repeats=3, random_state=42)
            return perm_importance.importances_mean
```

