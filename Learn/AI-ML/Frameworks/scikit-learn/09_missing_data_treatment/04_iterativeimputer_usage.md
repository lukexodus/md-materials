## IterativeImputer Usage


The `IterativeImputer` implements a sophisticated multivariate imputation strategy based on the MICE (Multiple Imputation by Chained Equations) algorithm. This approach models each feature with missing values as a function of other features and uses this model to predict missing values iteratively.

### Algorithmic Framework

**Round-Robin Modeling**: The algorithm cycles through each feature with missing values, using all other features as predictors to build a regression model for the current target feature.

**Iterative Refinement**: The process repeats multiple times, with each iteration using the imputed values from previous rounds as inputs for subsequent models. This iterative process allows the imputations to converge to stable values.

**Model Selection**: The underlying estimator can be any scikit-learn regressor for numerical features or classifier for categorical features. Common choices include BayesianRidge, RandomForestRegressor, or ExtraTreesRegressor.

### Advanced Features

**Initial Imputation**: The algorithm begins with simple imputation (typically mean/mode) and iteratively refines these values through the modeling process.

**Convergence Criteria**: The iteration continues until the imputed values stabilize (convergence) or a maximum number of iterations is reached.

**Order Strategies**: The sequence in which features are imputed can be randomized, ordered by missing data amounts, or following other strategic approaches to improve convergence and final imputation quality.

**Multiple Imputation Support**: While scikit-learn's implementation focuses on single imputation, the framework can be extended for multiple imputation scenarios where uncertainty quantification is important.

### Practical Implementation

**Estimator Selection**: The choice of underlying estimator significantly impacts performance. Linear models work well for linear relationships, while tree-based models can capture non-linear patterns and interactions.

**Convergence Monitoring**: Tracking the change in imputed values across iterations helps determine optimal stopping criteria and detect convergence issues.

**Feature Engineering**: The approach benefits from appropriate feature preprocessing, scaling, and encoding to ensure the underlying models perform optimally.

**Key points**:

- Models complex multivariate relationships between features
- Can capture non-linear patterns through appropriate estimator selection
- Requires multiple passes through the data, increasing computational cost
- Performance heavily depends on the underlying estimator choice
- May struggle with high-dimensional data or complex missing patterns
- Provides more sophisticated imputations than univariate methods

**Example**:

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import BayesianRidge
import numpy as np

# Create complex dataset with correlated features
np.random.seed(42)
n_samples, n_features = 1000, 5
X_complete = np.random.randn(n_samples, n_features)
# Create correlations between features
X_complete[:, 1] = X_complete[:, 0] + 0.5 * np.random.randn(n_samples)
X_complete[:, 2] = X_complete[:, 0] * X_complete[:, 1] + np.random.randn(n_samples)

# Introduce missing values with specific patterns
X_missing = X_complete.copy()
missing_rate = 0.2
for i in range(n_features):
    missing_idx = np.random.choice(n_samples, int(missing_rate * n_samples), replace=False)
    X_missing[missing_idx, i] = np.nan

# Iterative imputation with different estimators
# Linear estimator for linear relationships
linear_imputer = IterativeImputer(
    estimator=BayesianRidge(),
    max_iter=10,
    random_state=42
)
linear_imputed = linear_imputer.fit_transform(X_missing)

# Tree-based estimator for non-linear relationships
rf_imputer = IterativeImputer(
    estimator=RandomForestRegressor(n_estimators=10, random_state=42),
    max_iter=10,
    random_state=42
)
rf_imputed = rf_imputer.fit_transform(X_missing)

# Custom convergence monitoring
class ConvergenceMonitoringImputer(IterativeImputer):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.convergence_history = []
    
    def _get_neighbor_feat_idx(self, n_features, feat_idx, abs_corr_mat):
        # Override to track convergence
        return super()._get_neighbor_feat_idx(n_features, feat_idx, abs_corr_mat)
```

