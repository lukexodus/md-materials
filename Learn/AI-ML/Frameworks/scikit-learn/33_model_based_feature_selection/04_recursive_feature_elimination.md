## Recursive Feature Elimination


Recursive Feature Elimination (RFE) systematically removes features by fitting the model, ranking features by importance, eliminating the least important features, and repeating the process until the desired number of features remains. This approach provides precise control over the final feature set size.

RFE works with any estimator that provides feature importance or coefficients, making it versatile across different algorithm types. The recursive nature ensures that feature interactions are considered as the feature set evolves.

```python
from sklearn.feature_selection import RFE, RFECV
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier

class RecursiveFeatureEliminator:
    def __init__(self, estimator=None, cv=5):
        self.estimator = estimator or LogisticRegression(random_state=42)
        self.cv = cv
        self.selected_features_ = None
        self.ranking_ = None
        
    def eliminate_to_n_features(self, X, y, n_features_to_select):
        """Select exactly n features using RFE"""
        rfe = RFE(
            estimator=self.estimator,
            n_features_to_select=n_features_to_select,
            step=1
        )
        
        X_selected = rfe.fit_transform(X, y)
        self.selected_features_ = rfe.support_
        self.ranking_ = rfe.ranking_
        
        return X_selected, rfe.support_, rfe.ranking_
    
    def eliminate_with_cv(self, X, y, step=1, min_features_to_select=1):
        """Use cross-validation to find optimal number of features"""
        rfecv = RFECV(
            estimator=self.estimator,
            step=step,
            cv=self.cv,
            scoring='accuracy',
            min_features_to_select=min_features_to_select,
            n_jobs=-1
        )
        
        X_selected = rfecv.fit_transform(X, y)
        
        return {
            'X_selected': X_selected,
            'selected_features': rfecv.support_,
            'ranking': rfecv.ranking_,
            'n_features': rfecv.n_features_,
            'cv_scores': rfecv.cv_results_['mean_test_score'],
            'optimal_n_features': rfecv.n_features_
        }
```

Advanced RFE implementations incorporate different elimination strategies and step sizes for computational efficiency while maintaining selection quality.

```python
class AdaptiveRFE:
    def __init__(self, estimator, initial_step_fraction=0.1, min_step=1):
        self.estimator = estimator
        self.initial_step_fraction = initial_step_fraction
        self.min_step = min_step
        
    def adaptive_elimination(self, X, y, target_features=None):
        n_features = X.shape[1]
        current_features = np.arange(n_features)
        
        if target_features is None:
            target_features = max(int(n_features * 0.1), 5)
        
        elimination_history = []
        
        while len(current_features) > target_features:
            # Adaptive step size
            remaining_to_eliminate = len(current_features) - target_features
            step_size = max(
                int(len(current_features) * self.initial_step_fraction),
                min(self.min_step, remaining_to_eliminate)
            )
            
            # Perform RFE step
            rfe = RFE(
                estimator=self.estimator,
                n_features_to_select=len(current_features) - step_size,
                step=step_size
            )
            
            rfe.fit(X[:, current_features], y)
            
            # Update current features
            selected_mask = rfe.support_
            current_features = current_features[selected_mask]
            
            elimination_history.append({
                'n_features': len(current_features),
                'eliminated': step_size,
                'features': current_features.copy()
            })
        
        return current_features, elimination_history
```

RFE can be combined with different base estimators to leverage their specific strengths for feature ranking and selection.

```python
def compare_rfe_estimators(X, y, cv=5):
    estimators = {
        'LogisticRegression': LogisticRegression(random_state=42),
        'SVC': SVC(kernel='linear', random_state=42),
        'RandomForest': RandomForestClassifier(n_estimators=50, random_state=42)
    }
    
    results = {}
    
    for name, estimator in estimators.items():
        rfecv = RFECV(
            estimator=estimator,
            step=1,
            cv=cv,
            scoring='accuracy',
            n_jobs=-1
        )
        
        rfecv.fit(X, y)
        
        results[name] = {
            'n_features_selected': rfecv.n_features_,
            'selected_features': rfecv.support_,
            'cv_scores': rfecv.cv_results_['mean_test_score'],
            'best_score': np.max(rfecv.cv_results_['mean_test_score'])
        }
    
    return results
```

**Example**: In medical diagnosis applications, RFE systematically reduces complex biomarker panels to the most diagnostically relevant subset, ensuring that the final feature set maintains high predictive power while being clinically interpretable and cost-effective to measure.

