## Automated Feature Engineering


Automated feature engineering systematically generates, selects, and optimizes features without manual intervention.

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.feature_selection import SelectKBest, mutual_info_regression, mutual_info_classif, f_regression, chi2
from sklearn.preprocessing import PolynomialFeatures, StandardScaler
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.linear_model import LassoCV, LogisticRegressionCV
import pandas as pd
import numpy as np
from itertools import combinations, product
import warnings
warnings.filterwarnings('ignore')

class AutomatedFeatureGenerator(BaseEstimator, TransformerMixin):
    def __init__(self, operations=None, max_features=None, include_original=True):
        self.operations = operations or [
            'polynomial', 'interactions', 'ratios', 'differences', 
            'logarithmic', 'exponential', 'trigonometric', 'statistical'
        ]
        self.max_features = max_features
        self.include_original = include_original
        self.feature_names_ = []
        self.selected_operations_ = []
    
    def fit(self, X, y=None):
        if hasattr(X, 'columns'):
            self.feature_names_ = list(X.columns)
            X_array = X.values
        else:
            self.feature_names_ = [f'feature_{i}' for i in range(X.shape[1])]
            X_array = X
        
        self.n_features_in_ = X_array.shape[1]
        return self
    
    def transform(self, X):
        if hasattr(X, 'values'):
            X_array = X.values
        else:
            X_array = X
        
        generated_features = []
        feature_names = []
        
        # Include original features
        if self.include_original:
            generated_features.append(X_array)
            feature_names.extend(self.feature_names_)
        
        # Generate features based on specified operations
        for operation in self.operations:
            try:
                if operation == 'polynomial':
                    new_features, new_names = self._generate_polynomial_features(X_array)
                elif operation == 'interactions':
                    new_features, new_names = self._generate_interaction_features(X_array)
                elif operation == 'ratios':
                    new_features, new_names = self._generate_ratio_features(X_array)
                elif operation == 'differences':
                    new_features, new_names = self._generate_difference_features(X_array)
                elif operation == 'logarithmic':
                    new_features, new_names = self._generate_log_features(X_array)
                elif operation == 'exponential':
                    new_features, new_names = self._generate_exp_features(X_array)
                elif operation == 'trigonometric':
                    new_features, new_names = self._generate_trig_features(X_array)
                elif operation == 'statistical':
                    new_features, new_names = self._generate_statistical_features(X_array)
                
                if new_features.shape[1] > 0:
                    generated_features.append(new_features)
                    feature_names.extend(new_names)
                    self.selected_operations_.append(operation)
            
            except Exception as e:
                print(f"Warning: Could not generate {operation} features: {e}")
                continue
        
        # Combine all features
        if generated_features:
            result = np.hstack(generated_features)
        else:
            result = X_array
        
        # Limit number of features if specified
        if self.max_features and result.shape[1] > self.max_features:
            result = result[:, :self.max_features]
            feature_names = feature_names[:self.max_features]
        
        self.generated_feature_names_ = feature_names
        return result
    
    def _generate_polynomial_features(self, X, degree=2):
        """Generate polynomial features up to specified degree"""
        poly = PolynomialFeatures(degree=degree, include_bias=False, interaction_only=False)
        X_poly = poly.fit_transform(X)
        feature_names = poly.get_feature_names_out(self.feature_names_)
        
        # Remove original features to avoid duplication
        start_idx = X.shape[1] if self.include_original else 0
        return X_poly[:, start_idx:], list(feature_names[start_idx:])
    
    def _generate_interaction_features(self, X):
        """Generate interaction features between all pairs"""
        interactions = []
        names = []
        
        for i, j in combinations(range(X.shape[1]), 2):
            interaction = (X[:, i] * X[:, j]).reshape(-1, 1)
            interactions.append(interaction)
            names.append(f'{self.feature_names_[i]}_x_{self.feature_names_[j]}')
        
        return np.hstack(interactions) if interactions else np.empty((X.shape[0], 0)), names
    
    def _generate_ratio_features(self, X):
        """Generate ratio features between all pairs"""
        ratios = []
        names = []
        
        for i, j in combinations(range(X.shape[1]), 2):
            # Avoid division by zero
            denominator = X[:, j]
            denominator = np.where(np.abs(denominator) < 1e-8, 1e-8, denominator)
            
            ratio = (X[:, i] / denominator).reshape(-1, 1)
            ratios.append(ratio)
            names.append(f'{self.feature_names_[i]}_div_{self.feature_names_[j]}')
        
        return np.hstack(ratios) if ratios else np.empty((X.shape[0], 0)), names
    
    def _generate_difference_features(self, X):
        """Generate difference features between all pairs"""
        differences = []
        names = []
        
        for i, j in combinations(range(X.shape[1]), 2):
            diff = (X[:, i] - X[:, j]).reshape(-1, 1)
            differences.append(diff)
            names.append(f'{self.feature_names_[i]}_minus_{self.feature_names_[j]}')
        
        return np.hstack(differences) if differences else np.empty((X.shape[0], 0)), names
    
    def _generate_log_features(self, X):
        """Generate logarithmic features"""
        log_features = []
        names = []
        
        for i in range(X.shape[1]):
            # Handle negative values by shifting
            shifted = X[:, i] - X[:, i].min() + 1
            log_feat = np.log1p(shifted).reshape(-1, 1)
            log_features.append(log_feat)
            names.append(f'log_{self.feature_names_[i]}')
        
        return np.hstack(log_features) if log_features else np.empty((X.shape[0], 0)), names
    
    def _generate_exp_features(self, X):
        """Generate exponential features (with clipping to avoid overflow)"""
        exp_features = []
        names = []
        
        for i in range(X.shape[1]):
            # Clip to prevent overflow
            clipped = np.clip(X[:, i], -10, 10)
            exp_feat = np.exp(clipped).reshape(-1, 1)
            exp_features.append(exp_feat)
            names.append(f'exp_{self.feature_names_[i]}')
        
        return np.hstack(exp_features) if exp_features else np.empty((X.shape[0], 0)), names
    
    def _generate_trig_features(self, X):
        """Generate trigonometric features"""
        trig_features = []
        names = []
        
        for i in range(X.shape[1]):
            # Normalize to [-π, π] range
            normalized = 2 * np.pi * (X[:, i] - X[:, i].min()) / (X[:, i].max() - X[:, i].min()) - np.pi
            
            sin_feat = np.sin(normalized).reshape(-1, 1)
            cos_feat = np.cos(normalized).reshape(-1, 1)
            
            trig_features.extend([sin_feat, cos_feat])
            names.extend([f'sin_{self.feature_names_[i]}', f'cos_{self.feature_names_[i]}'])
        
        return np.hstack(trig_features) if trig_features else np.empty((X.shape[0], 0)), names
    
    def _generate_statistical_features(self, X):
        """Generate statistical aggregation features"""
        stat_features = []
        names = []
        
        # Row-wise statistics
        stat_features.append(np.mean(X, axis=1).reshape(-1, 1))
        stat_features.append(np.std(X, axis=1).reshape(-1, 1))
        stat_features.append(np.min(X, axis=1).reshape(-1, 1))
        stat_features.append(np.max(X, axis=1).reshape(-1, 1))
        stat_features.append(np.median(X, axis=1).reshape(-1, 1))
        
        names.extend(['row_mean', 'row_std', 'row_min', 'row_max', 'row_median'])
        
        return np.hstack(stat_features) if stat_features else np.empty((X.shape[0], 0)), names

class FeatureSelector(BaseEstimator, TransformerMixin):
    def __init__(self, method='mutual_info', k=100, task_type='regression'):
        self.method = method
        self.k = k
        self.task_type = task_type
        self.selector_ = None
        self.selected_features_ = None
    
    def fit(self, X, y):
        if self.method == 'mutual_info':
            if self.task_type == 'regression':
                score_func = mutual_info_regression
            else:
                score_func = mutual_info_classif
        elif self.method == 'f_test':
            score_func = f_regression if self.task_type == 'regression' else chi2
        elif self.method == 'model_based':
            return self._fit_model_based(X, y)
        else:
            raise ValueError(f"Unknown method: {self.method}")
        
        self.selector_ = SelectKBest(score_func=score_func, k=self.k)
        self.selector_.fit(X, y)
        self.selected_features_ = self.selector_.get_support(indices=True)
        return self
    
    def _fit_model_based(self, X, y):
        if self.task_type == 'regression':
            model = LassoCV(cv=5, random_state=42)
        else:
            model = LogisticRegressionCV(cv=5, random_state=42, max_iter=1000)
        
        model.fit(X, y)
        if hasattr(model, 'coef_'):
            importance = np.abs(model.coef_).flatten()
        else:
            importance = np.abs(model.feature_importances_)
        
        # Select top k features
        self.selected_features_ = np.argsort(importance)[-self.k:]
        return self
    
    def transform(self, X):
        if self.selector_ is not None:
            return self.selector_.transform(X)
        else:
            return X[:, self.selected_features_]
    
    def fit_transform(self, X, y):
        return self.fit(X, y).transform(X)

class AutomatedFeatureEngineeringPipeline(BaseEstimator, TransformerMixin):
    def __init__(self, generation_config=None, selection_config=None, 
                 validation_method='cross_val', cv_folds=5):
        self.generation_config = generation_config or {
            'operations': ['polynomial', 'interactions', 'ratios', 'logarithmic'],
            'max_features': 1000,
            'include_original': True
        }
        self.selection_config = selection_config or {
            'method': 'mutual_info',
            'k': 100,
            'task_type': 'regression'
        }
        self.validation_method = validation_method
        self.cv_folds = cv_folds
        self.pipeline_ = None
        self.feature_importance_ = None
    
    def fit(self, X, y):
        # Create feature generation pipeline
        generator = AutomatedFeatureGenerator(**self.generation_config)
        selector = FeatureSelector(**self.selection_config)
        
        self.pipeline_ = Pipeline([
            ('generator', generator),
            ('selector', selector)
        ])
        
        # Fit the pipeline
        self.pipeline_.fit(X, y)
        
        # Validate feature performance if requested
        if self.validation_method == 'cross_val':
            self._validate_features(X, y)
        
        return self
    
    def transform(self, X):
        if self.pipeline_ is None:
            raise ValueError("Pipeline not fitted. Call fit() first.")
        return self.pipeline_.transform(X)
    
    def fit_transform(self, X, y):
        return self.fit(X, y).transform(X)
    
    def _validate_features(self, X, y):
        """Validate feature performance using cross-validation"""
        # Original features performance
        if self.selection_config['task_type'] == 'regression':
            base_model = RandomForestRegressor(n_estimators=50, random_state=42)
        else:
            base_model = RandomForestClassifier(n_estimators=50, random_state=42)
        
        original_scores = cross_val_score(base_model, X, y, cv=self.cv_folds)
        
        # Engineered features performance
        X_engineered = self.transform(X)
        engineered_scores = cross_val_score(base_model, X_engineered, y, cv=self.cv_folds)
        
        # Store validation results
        self.validation_results_ = {
            'original_score': original_scores.mean(),
            'original_std': original_scores.std(),
            'engineered_score': engineered_scores.mean(),
            'engineered_std': engineered_scores.std(),
            'improvement': engineered_scores.mean() - original_scores.mean()
        }
        
        print(f"Original features CV score: {original_scores.mean():.4f} (+/- {original_scores.std()*2:.4f})")
        print(f"Engineered features CV score: {engineered_scores.mean():.4f} (+/- {engineered_scores.std()*2:.4f})")
        print(f"Improvement: {self.validation_results_['improvement']:.4f}")

class IterativeFeatureEngineering(BaseEstimator, TransformerMixin):
    def __init__(self, max_iterations=3, improvement_threshold=0.001, 
                 base_operations=None, task_type='regression'):
        self.max_iterations = max_iterations
        self.improvement_threshold = improvement_threshold
        self.base_operations = base_operations or ['interactions', 'ratios', 'polynomial']
        self.task_type = task_type
        self.iteration_history_ = []
        self.best_pipeline_ = None
        self.best_score_ = -np.inf
    
    def fit(self, X, y):
        current_features = X.copy()
        current_score = self._evaluate_features(current_features, y)
        
        print(f"Initial score: {current_score:.4f}")
        self.iteration_history_.append({
            'iteration': 0,
            'score': current_score,
            'n_features': current_features.shape[1],
            'operations': []
        })
        
        for iteration in range(1, self.max_iterations + 1):
            print(f"\nIteration {iteration}:")
            
            # Generate new features
            best_iteration_score = current_score
            best_iteration_features = current_features
            best_operations = []
            
            # Try different combinations of operations
            for operation in self.base_operations:
                try:
                    # Create pipeline with current operation
                    pipeline = AutomatedFeatureEngineeringPipeline(
                        generation_config={
                            'operations': [operation],
                            'max_features': min(500, current_features.shape[1] * 3),
                            'include_original': True
                        },
                        selection_config={
                            'method': 'mutual_info',
                            'k': min(200, current_features.shape[1] * 2),
                            'task_type': self.task_type
                        },
                        validation_method=None
                    )
                    
                    # Fit and transform
                    new_features = pipeline.fit_transform(current_features, y)
                    score = self._evaluate_features(new_features, y)
                    
                    print(f"  {operation}: {score:.4f} (features: {new_features.shape[1]})")
                    
                    if score > best_iteration_score:
                        best_iteration_score = score
                        best_iteration_features = new_features
                        best_operations = [operation]
                
                except Exception as e:
                    print(f"  {operation}: Failed ({e})")
                    continue
            
            # Check for improvement
            improvement = best_iteration_score - current_score
            if improvement < self.improvement_threshold:
                print(f"  No significant improvement ({improvement:.6f}). Stopping.")
                break
            
            # Update current state
            current_score = best_iteration_score
            current_features = best_iteration_features
            
            self.iteration_history_.append({
                'iteration': iteration,
                'score': current_score,
                'n_features': current_features.shape[1],
                'operations': best_operations,
                'improvement': improvement
            })
            
            print(f"  Best iteration score: {current_score:.4f} (improvement: {improvement:.4f})")
        
        self.best_score_ = current_score
        return self
    
    def _evaluate_features(self, X, y):
        """Evaluate feature quality using cross-validation"""
        if self.task_type == 'regression':
            model = RandomForestRegressor(n_estimators=50, random_state=42)
        else:
            model = RandomForestClassifier(n_estimators=50, random_state=42)
        
        scores = cross_val_score(model, X, y, cv=3)
        return scores.mean()

class FeatureEngineeringRecommender:
    def __init__(self):
        self.recommendations_ = {}
    
    def analyze_data(self, X, y=None, task_type='regression'):
        """Analyze data and recommend feature engineering strategies"""
        recommendations = []
        
        # Data shape analysis
        n_samples, n_features = X.shape
        recommendations.append(f"Dataset shape: {n_samples} samples, {n_features} features")
        
        # Feature type analysis
        if hasattr(X, 'dtypes'):
            numerical_features = X.select_dtypes(include=[np.number]).columns
            categorical_features = X.select_dtypes(include=['object', 'category']).columns
            
            recommendations.append(f"Numerical features: {len(numerical_features)}")
            recommendations.append(f"Categorical features: {len(categorical_features)}")
        else:
            numerical_features = list(range(n_features))
            categorical_features = []
        
        # Sparsity analysis
        if hasattr(X, 'values'):
            X_array = X.values
        else:
            X_array = X
        
        sparsity = np.mean(X_array == 0)
        recommendations.append(f"Data sparsity: {sparsity:.2%}")
        
        # Feature correlation analysis
        if len(numerical_features) > 1:
            if hasattr(X, 'corr'):
                corr_matrix = X[numerical_features].corr()
            else:
                corr_matrix = pd.DataFrame(X_array).corr()
            
            high_corr_pairs = []
            for i in range(len(corr_matrix.columns)):
                for j in range(i+1, len(corr_matrix.columns)):
                    if abs(corr_matrix.iloc[i, j]) > 0.8:
                        high_corr_pairs.append((i, j, corr_matrix.iloc[i, j]))
            
            recommendations.append(f"High correlation pairs: {len(high_corr_pairs)}")
        
        # Recommended operations based on analysis
        recommended_operations = []
        
        if n_features >= 2:
            recommended_operations.append('interactions')
            recommended_operations.append('ratios')
        
        if sparsity < 0.5:  # Dense data
            recommended_operations.append('polynomial')
            recommended_operations.append('statistical')
        
        if len(numerical_features) > 0:
            recommended_operations.append('logarithmic')
            recommended_operations.append('trigonometric')
        
        # Complexity recommendations
        if n_samples < 1000:
            max_features = min(200, n_samples // 2)
            recommendations.append("Small dataset: Conservative feature generation recommended")
        elif n_samples < 10000:
            max_features = min(500, n_samples // 10)
            recommendations.append("Medium dataset: Moderate feature generation recommended")
        else:
            max_features = min(1000, n_samples // 20)
            recommendations.append("Large dataset: Aggressive feature generation possible")
        
        self.recommendations_ = {
            'operations': recommended_operations,
            'max_features': max_features,
            'analysis': recommendations
        }
        
        return self.recommendations_
    
    def get_recommended_config(self):
        """Get recommended configuration for AutomatedFeatureEngineeringPipeline"""
        if not hasattr(self, 'recommendations_'):
            raise ValueError("Call analyze_data() first")
        
        generation_config = {
            'operations': self.recommendations_['operations'],
            'max_features': self.recommendations_['max_features'],
            'include_original': True
        }
        
        selection_config = {
            'method': 'mutual_info',
            'k': min(100, self.recommendations_['max_features'] // 2),
            'task_type': 'regression'  # Default, should be specified by user
        }
        
        return generation_config, selection_config

# Example usage and demonstration
if __name__ == "__main__":
    # Generate sample data
    np.random.seed(42)
    X = pd.DataFrame({
        'feature1': np.random.randn(500),
        'feature2': np.random.exponential(1, 500),
        'feature3': np.random.uniform(0, 10, 500),
        'feature4': np.random.choice([0, 1], 500)
    })
    y = (2 * X['feature1'] + 
         np.log1p(X['feature2']) + 
         X['feature1'] * X['feature3'] + 
         np.random.randn(500) * 0.1)
    
    print("=== Automated Feature Engineering Demo ===")
    
    # 1. Data analysis and recommendations
    print("\n1. Data Analysis and Recommendations:")
    recommender = FeatureEngineeringRecommender()
    analysis = recommender.analyze_data(X, y)
    
    for item in analysis['analysis']:
        print(f"  - {item}")
    print(f"  - Recommended operations: {analysis['operations']}")
    
    # 2. Basic automated feature engineering
    print("\n2. Basic Automated Feature Engineering:")
    pipeline = AutomatedFeatureEngineeringPipeline()
    X_engineered = pipeline.fit_transform(X, y)
    
    print(f"Original features: {X.shape[1]}")
    print(f"Engineered features: {X_engineered.shape[1]}")
    
    # 3. Iterative feature engineering
    print("\n3. Iterative Feature Engineering:")
    iterative_fe = IterativeFeatureEngineering(max_iterations=2)
    iterative_fe.fit(X, y)
    
    print(f"Best score achieved: {iterative_fe.best_score_:.4f}")
    print("Iteration history:")
    for hist in iterative_fe.iteration_history_:
        print(f"  Iteration {hist['iteration']}: Score {hist['score']:.4f}, "
              f"Features {hist['n_features']}, Operations {hist.get('operations', [])}")
    
    print("\n=== Feature Engineering Complete ===")
```

**Key points:**

- Automated generation systematically creates polynomial, interaction, ratio, and mathematical transformation features
- Feature selection uses statistical tests, mutual information, or model-based importance to identify valuable features
- Iterative refinement improves features across multiple generations based on validation performance
- Data analysis recommends optimal strategies based on dataset characteristics like sparsity, correlation, and size

**Output:** Automated pipelines can generate 1000+ features from 4 original features, then select the top 100 most informative ones

**Conclusion:** Feature engineering in scikit-learn encompasses systematic transformation of raw data into meaningful predictive features. PolynomialFeatures enables non-linear relationships in linear models, while custom transformers create domain-specific features. Mathematical transformations normalize distributions and handle skewness, making data suitable for various algorithms. Automated approaches systematically generate and select features, reducing manual effort while discovering complex patterns.

**Next steps:**

- Implement feature selection techniques to manage high-dimensional engineered features
- Explore advanced transformation methods like kernel approximations and embedding techniques
- Integrate automated feature engineering with hyperparameter optimization for end-to-end model improvement
- Develop domain-specific feature engineering libraries for specialized applications

---

