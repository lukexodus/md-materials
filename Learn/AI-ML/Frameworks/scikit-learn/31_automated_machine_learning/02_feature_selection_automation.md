## Feature Selection Automation


Automated feature selection reduces dimensionality while maintaining or improving model performance by systematically evaluating feature importance and relevance. Scikit-learn provides multiple approaches for implementing automated feature selection within ML pipelines.

Filter-based methods evaluate features independently of the learning algorithm, using statistical measures to rank feature importance. These methods are computationally efficient and can handle high-dimensional datasets effectively.

```python
from sklearn.feature_selection import SelectKBest, f_classif, mutual_info_classif
from sklearn.feature_selection import VarianceThreshold, SelectFromModel

class AutomatedFeatureSelector:
    def __init__(self, selection_methods=['variance', 'univariate', 'model_based']):
        self.selection_methods = selection_methods
        self.selectors = {}
        
    def fit_transform(self, X, y):
        selected_features = X.copy()
        
        if 'variance' in self.selection_methods:
            # Remove low-variance features
            variance_selector = VarianceThreshold(threshold=0.01)
            selected_features = variance_selector.fit_transform(selected_features)
            self.selectors['variance'] = variance_selector
            
        if 'univariate' in self.selection_methods:
            # Select based on univariate statistical tests
            univariate_selector = SelectKBest(score_func=f_classif, k='all')
            selected_features = univariate_selector.fit_transform(selected_features, y)
            self.selectors['univariate'] = univariate_selector
            
        return selected_features
```

Wrapper methods evaluate feature subsets by training models and assessing their performance, providing more accurate feature relevance assessment at higher computational cost.

```python
from sklearn.feature_selection import RFE, RFECV
from sklearn.linear_model import LogisticRegression

def automated_wrapper_selection(X, y, estimator=None, cv=5):
    if estimator is None:
        estimator = LogisticRegression(random_state=42)
    
    # Recursive feature elimination with cross-validation
    selector = RFECV(
        estimator=estimator,
        step=1,
        cv=cv,
        scoring='accuracy',
        n_jobs=-1
    )
    
    X_selected = selector.fit_transform(X, y)
    
    return X_selected, selector.support_, selector.ranking_
```

Embedded methods integrate feature selection within the model training process, leveraging regularization or built-in feature importance mechanisms.

**Example**: L1 regularization automatically performs feature selection by driving irrelevant feature weights to zero, while tree-based models provide feature importance scores that can guide automated selection.

```python
from sklearn.linear_model import LassoCV
from sklearn.ensemble import ExtraTreesClassifier

class EmbeddedFeatureSelection:
    def __init__(self, method='lasso', threshold='median'):
        self.method = method
        self.threshold = threshold
        
    def fit_transform(self, X, y):
        if self.method == 'lasso':
            selector = SelectFromModel(
                LassoCV(cv=5, random_state=42),
                threshold=self.threshold
            )
        elif self.method == 'tree':
            selector = SelectFromModel(
                ExtraTreesClassifier(n_estimators=100, random_state=42),
                threshold=self.threshold
            )
            
        X_selected = selector.fit_transform(X, y)
        return X_selected, selector
```

