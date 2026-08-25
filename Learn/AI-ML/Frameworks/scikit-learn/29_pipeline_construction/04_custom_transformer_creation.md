## Custom Transformer Creation


Creating custom transformers extends scikit-learn's preprocessing capabilities to handle domain-specific requirements and novel feature engineering approaches. Custom transformers integrate seamlessly with existing pipeline infrastructure.

**Key points:**

- Implements fit, transform, and optionally fit_transform methods
- Inherits from BaseEstimator and TransformerMixin for full compatibility
- Supports hyperparameter optimization and cross-validation
- Enables domain-specific feature engineering
- Maintains scikit-learn interface conventions
- Can store learned parameters during fitting

**Example:**

```python
from sklearn.base import BaseEstimator, TransformerMixin
from scipy import stats
import pandas as pd

# Basic custom transformer
class OutlierRemover(BaseEstimator, TransformerMixin):
    def __init__(self, method='iqr', threshold=1.5):
        self.method = method
        self.threshold = threshold
        
    def fit(self, X, y=None):
        """Learn outlier boundaries"""
        if self.method == 'iqr':
            self.lower_bounds_ = np.percentile(X, 25, axis=0) - self.threshold * (
                np.percentile(X, 75, axis=0) - np.percentile(X, 25, axis=0))
            self.upper_bounds_ = np.percentile(X, 75, axis=0) + self.threshold * (
                np.percentile(X, 75, axis=0) - np.percentile(X, 25, axis=0))
        elif self.method == 'zscore':
            self.means_ = np.mean(X, axis=0)
            self.stds_ = np.std(X, axis=0)
            
        return self
    
    def transform(self, X):
        """Remove or clip outliers"""
        X_transformed = X.copy()
        
        if self.method == 'iqr':
            for i in range(X_transformed.shape[1]):
                mask = (X_transformed[:, i] < self.lower_bounds_[i]) | (X_transformed[:, i] > self.upper_bounds_[i])
                X_transformed[mask, i] = np.median(X_transformed[~mask, i])
        elif self.method == 'zscore':
            z_scores = np.abs((X_transformed - self.means_) / self.stds_)
            mask = z_scores > self.threshold
            for i in range(X_transformed.shape[1]):
                X_transformed[mask[:, i], i] = self.means_[i]
                
        return X_transformed
    
    def get_feature_names_out(self, input_features=None):
        """Return feature names for output features"""
        if input_features is None:
            return np.array([f'x{i}' for i in range(self.n_features_in_)])
        return input_features

# Advanced custom transformer with multiple functionalities
class AdvancedFeatureEngineer(BaseEstimator, TransformerMixin):
    def __init__(self, create_interactions=True, create_ratios=True, 
                 create_logs=True, create_bins=False, n_bins=5):
        self.create_interactions = create_interactions
        self.create_ratios = create_ratios
        self.create_logs = create_logs
        self.create_bins = create_bins
        self.n_bins = n_bins
        
    def fit(self, X, y=None):
        """Learn feature engineering parameters"""
        self.n_features_in_ = X.shape[1]
        self.feature_names_in_ = getattr(X, 'columns', [f'x{i}' for i in range(self.n_features_in_)])
        
        # Store statistics for binning
        if self.create_bins:
            self.bin_edges_ = {}
            for i, col in enumerate(self.feature_names_in_):
                self.bin_edges_[col] = np.percentile(X[:, i], np.linspace(0, 100, self.n_bins + 1))
        
        # Find positive features for log transformation
        if self.create_logs:
            self.log_features_ = []
            for i in range(self.n_features_in_):
                if np.all(X[:, i] > 0):
                    self.log_features_.append(i)
        
        return self
    
    def transform(self, X):
        """Apply feature engineering"""
        features = [X]
        feature_names = list(self.feature_names_in_)
        
        # Create interaction features
        if self.create_interactions:
            interactions = []
            interaction_names = []
            for i in range(self.n_features_in_):
                for j in range(i + 1, self.n_features_in_):
                    interactions.append((X[:, i] * X[:, j]).reshape(-1, 1))
                    interaction_names.append(f'{self.feature_names_in_[i]}*{self.feature_names_in_[j]}')
            
            if interactions:
                features.append(np.column_stack(interactions))
                feature_names.extend(interaction_names)
        
        # Create ratio features
        if self.create_ratios:
            ratios = []
            ratio_names = []
            for i in range(self.n_features_in_):
                for j in range(self.n_features_in_):
                    if i != j and not np.any(X[:, j] == 0):  # Avoid division by zero
                        ratios.append((X[:, i] / X[:, j]).reshape(-1, 1))
                        ratio_names.append(f'{self.feature_names_in_[i]}/{self.feature_names_in_[j]}')
            
            if ratios:
                features.append(np.column_stack(ratios))
                feature_names.extend(ratio_names)
        
        # Create log features
        if self.create_logs and hasattr(self, 'log_features_'):
            logs = []
            log_names = []
            for i in self.log_features_:
                logs.append(np.log1p(X[:, i]).reshape(-1, 1))
                log_names.append(f'log_{self.feature_names_in_[i]}')
            
            if logs:
                features.append(np.column_stack(logs))
                feature_names.extend(log_names)
        
        # Create binned features
        if self.create_bins:
            bins = []
            bin_names = []
            for i, col in enumerate(self.feature_names_in_):
                binned = np.digitize(X[:, i], self.bin_edges_[col]) - 1
                binned = np.clip(binned, 0, self.n_bins - 1)  # Ensure valid bin indices
                bins.append(binned.reshape(-1, 1))
                bin_names.append(f'{col}_binned')
            
            if bins:
                features.append(np.column_stack(bins))
                feature_names.extend(bin_names)
        
        self.output_feature_names_ = feature_names
        return np.column_stack(features)
    
    def get_feature_names_out(self, input_features=None):
        """Return names of output features"""
        return np.array(self.output_feature_names_)

# Custom transformer for time series features
class TimeSeriesFeatures(BaseEstimator, TransformerMixin):
    def __init__(self, window_sizes=[3, 5, 7], create_lags=True, create_rolling=True):
        self.window_sizes = window_sizes
        self.create_lags = create_lags
        self.create_rolling = create_rolling
        
    def fit(self, X, y=None):
        self.n_features_in_ = X.shape[1]
        return self
    
    def transform(self, X):
        """Create time series features"""
        features = [X]
        
        if self.create_lags:
            # Create lagged features
            for lag in [1, 2, 3]:
                lagged = np.roll(X, lag, axis=0)
                lagged[:lag] = 0  # Fill initial values with 0
                features.append(lagged)
        
        if self.create_rolling:
            # Create rolling window features
            for window in self.window_sizes:
                rolling_mean = np.array([
                    np.convolve(X[:, i], np.ones(window)/window, mode='same') 
                    for i in range(X.shape[1])
                ]).T
                rolling_std = np.array([
                    pd.Series(X[:, i]).rolling(window=window, center=True).std().fillna(0) 
                    for i in range(X.shape[1])
                ]).T
                features.extend([rolling_mean, rolling_std])
        
        return np.column_stack(features)

# Usage example with custom transformers
X_sample, y_sample = make_classification(n_samples=500, n_features=5, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X_sample, y_sample, test_size=0.2, random_state=42)

# Pipeline with custom transformers
custom_pipeline = Pipeline([
    ('outlier_removal', OutlierRemover(method='iqr', threshold=2.0)),
    ('feature_engineering', AdvancedFeatureEngineer(
        create_interactions=True, 
        create_ratios=False,  # Disable ratios to prevent too many features
        create_logs=True,
        create_bins=True,
        n_bins=3
    )),
    ('feature_selection', SelectKBest(f_classif, k=20)),
    ('scaler', StandardScaler()),
    ('classifier', RandomForestClassifier(random_state=42))
])

# Fit and evaluate custom pipeline
custom_pipeline.fit(X_train, y_train)
custom_score = custom_pipeline.score(X_test, y_test)
print(f"Custom Pipeline Accuracy: {custom_score:.4f}")

# Analyze feature engineering results
feature_engineer = AdvancedFeatureEngineer(create_interactions=True, create_logs=True)
X_engineered = feature_engineer.fit_transform(X_train)
print(f"Original features: {X_train.shape[1]}")
print(f"Engineered features: {X_engineered.shape[1]}")
print(f"Feature names: {feature_engineer.get_feature_names_out()[:10]}")  # Show first 10
```

**Custom Transformer with State:**

```python
class AdaptiveScaler(BaseEstimator, TransformerMixin):
    def __init__(self, adaptation_rate=0.1):
        self.adaptation_rate = adaptation_rate
        
    def fit(self, X, y=None):
        """Initial fit"""
        self.mean_ = np.mean(X, axis=0)
        self.std_ = np.std(X, axis=0)
        self.n_samples_seen_ = X.shape[0]
        return self
    
    def partial_fit(self, X, y=None):
        """Update statistics incrementally"""
        if not hasattr(self, 'mean_'):
            return self.fit(X, y)
        
        n_samples = X.shape[0]
        total_samples = self.n_samples_seen_ + n_samples
        
        # Update mean incrementally
        new_mean = np.mean(X, axis=0)
        self.mean_ = (self.n_samples_seen_ * self.mean_ + n_samples * new_mean) / total_samples
        
        # Update std incrementally (simplified)
        new_std = np.std(X, axis=0)
        self.std_ = (1 - self.adaptation_rate) * self.std_ + self.adaptation_rate * new_std
        
        self.n_samples_seen_ = total_samples
        return self
    
    def transform(self, X):
        """Scale using current statistics"""
        return (X - self.mean_) / (self.std_ + 1e-8)  # Add small constant for numerical stability
```

Custom transformers provide unlimited flexibility for domain-specific preprocessing while maintaining full compatibility with scikit-learn's ecosystem and pipeline infrastructure.

