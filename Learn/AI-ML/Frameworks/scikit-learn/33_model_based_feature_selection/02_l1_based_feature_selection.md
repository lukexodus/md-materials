## L1-based Feature Selection


L1 regularization performs automatic feature selection by adding a penalty term proportional to the absolute value of coefficients, effectively driving irrelevant feature weights to zero. This sparsity-inducing property makes L1-regularized models particularly effective for high-dimensional datasets with many irrelevant features.

Lasso regression exemplifies L1-based feature selection, where the regularization parameter alpha controls the sparsity level. Higher alpha values result in more aggressive feature selection but may eliminate relevant features if set too high.

```python
from sklearn.linear_model import Lasso, LassoCV, ElasticNet
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import matplotlib.pyplot as plt

class L1FeatureSelector:
    def __init__(self, alpha_range=None, cv=5):
        self.alpha_range = alpha_range or np.logspace(-4, 1, 50)
        self.cv = cv
        self.optimal_alpha = None
        self.selected_features = None
        
    def select_features_lasso(self, X, y, normalize=True):
        if normalize:
            X = StandardScaler().fit_transform(X)
            
        # Use cross-validation to find optimal alpha
        lasso_cv = LassoCV(alphas=self.alpha_range, cv=self.cv, random_state=42)
        lasso_cv.fit(X, y)
        self.optimal_alpha = lasso_cv.alpha_
        
        # Fit final model with optimal alpha
        lasso = Lasso(alpha=self.optimal_alpha, random_state=42)
        lasso.fit(X, y)
        
        # Identify selected features (non-zero coefficients)
        self.selected_features = np.abs(lasso.coef_) > 1e-6
        
        return X[:, self.selected_features], self.selected_features, lasso.coef_
    
    def plot_regularization_path(self, X, y):
        # Compute regularization path
        alphas, coefs, _ = lasso_path(X, y, alphas=self.alpha_range)
        
        plt.figure(figsize=(12, 8))
        for i in range(coefs.shape[0]):
            plt.plot(alphas, coefs[i, :])
        plt.xscale('log')
        plt.xlabel('Alpha (Regularization Strength)')
        plt.ylabel('Coefficients')
        plt.title('Lasso Regularization Path')
        plt.axvline(self.optimal_alpha, color='red', linestyle='--', 
                   label=f'Optimal Alpha: {self.optimal_alpha:.4f}')
        plt.legend()
        plt.show()
```

ElasticNet combines L1 and L2 regularization, providing a balanced approach that maintains feature selection capabilities while handling correlated features more effectively than pure Lasso.

```python
from sklearn.linear_model import ElasticNetCV

def elastic_net_selection(X, y, l1_ratios=None):
    if l1_ratios is None:
        l1_ratios = [0.1, 0.5, 0.7, 0.9, 0.95, 1.0]
    
    # Cross-validation for both alpha and l1_ratio
    elastic_cv = ElasticNetCV(
        l1_ratio=l1_ratios,
        alphas=np.logspace(-4, 1, 50),
        cv=5,
        random_state=42
    )
    
    elastic_cv.fit(StandardScaler().fit_transform(X), y)
    
    # Extract selected features
    selected_features = np.abs(elastic_cv.coef_) > 1e-6
    
    return {
        'selected_features': selected_features,
        'coefficients': elastic_cv.coef_,
        'optimal_alpha': elastic_cv.alpha_,
        'optimal_l1_ratio': elastic_cv.l1_ratio_,
        'n_selected': np.sum(selected_features)
    }
```

L1-based feature selection can be integrated with SelectFromModel for consistent interface usage across different selection methods.

```python
def l1_selectfrommodel_pipeline(X, y):
    # Create L1-based selector
    lasso = LassoCV(cv=5, random_state=42)
    selector = SelectFromModel(lasso, threshold=1e-6)
    
    # Create complete pipeline
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('selector', selector),
        ('estimator', LogisticRegression(random_state=42))
    ])
    
    # Evaluate pipeline performance
    scores = cross_val_score(pipeline, X, y, cv=5, scoring='accuracy')
    
    # Fit to get selected features
    pipeline.fit(X, y)
    selected_features = pipeline.named_steps['selector'].get_support()
    
    return {
        'cv_scores': scores,
        'mean_score': scores.mean(),
        'selected_features': selected_features,
        'n_selected': np.sum(selected_features)
    }
```

**Example**: In genomics applications, L1-based feature selection effectively identifies relevant genes from thousands of candidates, automatically handling the high-dimensional nature of gene expression data while providing interpretable results through sparse coefficient patterns.

