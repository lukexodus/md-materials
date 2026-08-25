## Hyperparameter Optimization


Hyperparameter optimization for SVR involves systematic search across multiple parameter spaces to find optimal configurations that balance predictive performance, model complexity, and computational efficiency.

### Parameter Space Exploration

**Grid Search Methodology**: Exhaustive search across predefined parameter grids provides comprehensive coverage but can be computationally expensive. Effective grid search requires intelligent parameter range selection based on theoretical understanding and empirical observations.

**Random Search Advantages**: Random sampling from parameter distributions often finds good solutions more efficiently than grid search, particularly for high-dimensional parameter spaces where only a subset of parameters significantly impacts performance.

**Bayesian Optimization**: Advanced optimization techniques that build probabilistic models of the objective function and use acquisition functions to guide parameter selection toward promising regions.

### Multi-Objective Optimization

**Performance vs Complexity Trade-offs**: Simultaneous optimization of prediction accuracy and model complexity (number of support vectors) using Pareto optimization or weighted objective functions.

**Speed vs Accuracy Balance**: Consider both training time and prediction accuracy, particularly important for real-time applications or large-scale deployments.

**Robustness Optimization**: Optimize for consistent performance across different data splits or noise levels, not just peak performance on validation sets.

### Advanced Optimization Strategies

**Nested Cross-Validation**: Proper evaluation of hyperparameter optimization results using nested CV to avoid optimistic bias from parameter tuning on validation sets.

**Early Stopping Criteria**: Implement convergence detection to terminate optimization when improvements plateau, saving computational resources.

**Population-Based Methods**: Genetic algorithms, evolutionary strategies, and swarm optimization for complex parameter landscapes where gradient information is unavailable.

### Practical Implementation Considerations

**Computational Budget Management**: Balance optimization thoroughness with available computational resources through adaptive budget allocation and parallel processing.

**Parameter Coupling Effects**: Recognize interactions between parameters (e.g., C and gamma in RBF kernels) and design search strategies that account for these dependencies.

**Cross-Validation Strategies**: Choose appropriate CV schemes that reflect the intended use case while providing reliable parameter selection guidance.

**Key points**:

- Systematic approach prevents suboptimal parameter selection
- Consider multiple objectives beyond prediction accuracy
- Nested cross-validation provides unbiased performance estimates
- Bayesian optimization offers efficient exploration of parameter spaces
- Account for parameter interactions and coupling effects

**Example**:

```python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV, cross_val_score
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_regression
from sklearn.metrics import make_scorer, mean_squared_error
from skopt import BayesSearchCV
from skopt.space import Real, Integer, Categorical
import numpy as np
import matplotlib.pyplot as plt
import time
from scipy.stats import uniform, loguniform

class SVRHyperparameterOptimizer:
    """Comprehensive hyperparameter optimization for SVR models."""
    
    def __init__(self, X, y, test_size=0.2, random_state=42):
        from sklearn.model_selection import train_test_split
        
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            X, y, test_size=test_size, random_state=random_state
        )
        
        # Standardize features
        self.scaler = StandardScaler()
        self.X_train_scaled = self.scaler.fit_transform(self.X_train)
        self.X_test_scaled = self.scaler.transform(self.X_test)
        
        self.optimization_results = {}
    
    def grid_search_optimization(self, kernel_type='rbf', cv=5):
        """Comprehensive grid search optimization."""
        if kernel_type == 'rbf':
            param_grid = {
                'C': [0.01, 0.1, 1, 10, 100],
                'gamma': ['scale', 'auto', 0.001, 0.01, 0.1, 1, 10],
                'epsilon': [0.01, 0.1, 0.2, 0.5]
            }
        elif kernel_type == 'poly':
            param_grid = {
                'C': [0.01, 0.1, 1, 10, 100],
                'degree': [2, 3, 4, 5],
                'coef0': [0, 0.1, 1, 10],
                'epsilon': [0.01, 0.1, 0.2, 0.5]
            }
        elif kernel_type == 'linear':
            param_grid = {
                'C': [0.01, 0.1, 1, 10, 100],
                'epsilon': [0.01, 0.1, 0.2, 0.5]
            }
        
        start_time = time.time()
        grid_search = GridSearchCV(
            SVR(kernel=kernel_type),
            param_grid=param_grid,
            cv=cv,
            scoring='neg_mean_squared_error',
            n_jobs=-1,
            verbose=1
        )
        
        grid_search.fit(self.X_train_scaled, self.y_train)
        optimization_time = time.time() - start_time
        
        # Test performance
        y_pred = grid_search.predict(self.X_test_scaled)
        test_mse = mean_squared_error(self.y_test, y_pred)
        
        self.optimization_results[f'grid_search_{kernel_type}'] = {
            'best_params': grid_search.best_params_,
            'best_cv_score': -grid_search.best_score_,
            'test_mse': test_mse,
            'optimization_time': optimization_time,
            'n_evaluations': len(grid_search.cv_results_['params']),
            'cv_results': grid_search.cv_results_
        }
        
        return grid_search
    
    def random_search_optimization(self, kernel_type='rbf', n_iter=100, cv=5):
        """Random search optimization with distributions."""
        if kernel_type == 'rbf':
            param_distributions = {
                'C': loguniform(0.01, 100),
                'gamma': loguniform(1e-4, 10),
                'epsilon': uniform(0.01, 0.5)
            }
        elif kernel_type == 'poly':
            param_distributions = {
                'C': loguniform(0.01, 100),
                'degree': [2, 3, 4, 5],
                'coef0': uniform(0, 10),
                'epsilon': uniform(0.01, 0.5)
            }
        elif kernel_type == 'linear':
            param_distributions = {
                'C': loguniform(0.01, 100),
                'epsilon': uniform(0.01, 0.5)
            }
        
        start_time = time.time()
        random_search = RandomizedSearchCV(
            SVR(kernel=kernel_type),
            param_distributions=param_distributions,
            n_iter=n_iter,
            cv=cv,
            scoring='neg_mean_squared_error',
            n_jobs=-1,
            random_state=42
        )
        
        random_search.fit(self.X_train_scaled, self.y_train)
        optimization_time = time.time() - start_time
        
        # Test performance
        y_pred = random_search.predict(self.X_test_scaled)
        test_mse = mean_squared_error(self.y_test, y_pred)
        
        self.optimization_results[f'random_search_{kernel_type}'] = {
            'best_params': random_search.best_params_,
            'best_cv_score': -random_search.best_score_,
            'test_mse': test_mse,
            'optimization_time': optimization_time,
            'n_evaluations': n_iter,
            'cv_results': random_search.cv_results_
        }
        
        return random_search
    
    def bayesian_optimization(self, kernel_type='rbf', n_calls=50, cv=5):
        """Bayesian optimization using scikit-optimize."""
        if kernel_type == 'rbf':
            search_spaces = {
                'C': Real(0.01, 100, prior='log-uniform'),
                'gamma': Real(1e-4, 10, prior='log-uniform'),
                'epsilon': Real(0.01, 0.5)
            }
        elif kernel_type == 'poly':
            search_spaces = {
                'C': Real(0.01, 100, prior='log-uniform'),
                'degree': Integer(2, 5),
                'coef0': Real(0, 10),
                'epsilon': Real(0.01, 0.5)
            }
        elif kernel_type == 'linear':
            search_spaces = {
                'C': Real(0.01, 100, prior='log-uniform'),
                'epsilon': Real(0.01, 0.5)
            }
        
        start_time = time.time()
        bayes_search = BayesSearchCV(
            SVR(kernel=kernel_type),
            search_spaces,
            n_iter=n_calls,
            cv=cv,
            scoring='neg_mean_squared_error',
            n_jobs=-1,
            random_state=42
        )
        
        bayes_search.fit(self.X_train_scaled, self.y_train)
        optimization_time = time.time() - start_time
        
        # Test performance
        y_pred = bayes_search.predict(self.X_test_scaled)
        test_mse = mean_squared_error(self.y_test, y_pred)
        
        self.optimization_results[f'bayesian_{kernel_type}'] = {
            'best_params': bayes_search.best_params_,
            'best_cv_score': -bayes_search.best_score_,
            'test_mse': test_mse,
            'optimization_time': optimization_time,
            'n_evaluations': n_calls
        }
        
        return bayes_search
    
    def nested_cross_validation(self, kernel_type='rbf', inner_cv=3, outer_cv=5):
        """Nested cross-validation for unbiased performance estimation."""
        from sklearn.model_selection import cross_validate
        
        # Define parameter search strategy
        if kernel_type == 'rbf':
            param_grid = {
                'C': [0.1, 1, 10],
                'gamma': ['scale', 0.01, 0.1, 1],
                'epsilon': [0.01, 0.1, 0.2]
            }
        else:
            param_grid = {'C': [0.1, 1, 10], 'epsilon': [0.01, 0.1, 0.2]}
        
        # Inner loop: hyperparameter optimization
        inner_cv_search = GridSearchCV(
            SVR(kernel=kernel_type),
            param_grid,
            cv=inner_cv,
            scoring='neg_mean_squared_error'
        )
        
        # Outer loop: performance evaluation
        nested_scores = cross_validate(
            inner_cv_search,
            self.X_train_scaled, self.y_train,
            cv=outer_cv,
            scoring='neg_mean_squared_error',
            return_train_score=True
        )
        
        self.optimization_results[f'nested_cv_{kernel_type}'] = {
            'test_scores': -nested_scores['test_score'],
            'train_scores': -nested_scores['train_score'],
            'mean_test_score': -nested_scores['test_score'].mean(),
            'std_test_score': nested_scores['test_score'].std(),
            'mean_train_score': -nested_scores['train_score'].mean(),
            'std_train_score': nested_scores['train_score'].std()
        }
        
        return nested_scores
    
    def compare_optimization_methods(self):
        """Compare different optimization strategies."""
        comparison_results = {}
        
        for method_name, results in self.optimization_results.items():
            if 'nested_cv' in method_name:
                comparison_results[method_name] = {
                    'performance': results['mean_test_score'],
                    'std': results['std_test_score'],
                    'method_type': 'nested_cv'
                }
            else:
                comparison_results[method_name] = {
                    'cv_performance': results['best_cv_score'],
                    'test_performance': results['test_mse'],
                    'optimization_time': results['optimization_time'],
                    'n_evaluations': results['n_evaluations'],
                    'efficiency': results['best_cv_score'] / results['optimization_time'],
                    'method_type': 'single_split'
                }
        
        return comparison_results

# Comprehensive optimization example
np.random.seed(42)
X, y = make_regression(n_samples=1000, n_features=10, noise=5, random_state=42)

# Initialize optimizer
optimizer = SVRHyperparameterOptimizer(X, y)

# Run different optimization strategies
print("Running Grid Search Optimization...")
grid_rbf = optimizer.grid_search_optimization('rbf')

print("Running Random Search Optimization...")
random_rbf = optimizer.random_search_optimization('rbf', n_iter=100)

print("Running Bayesian Optimization...")
bayes_rbf = optimizer.bayesian_optimization('rbf', n_calls=50)

print("Running Nested Cross-Validation...")
nested_scores = optimizer.nested_cross_validation('rbf')

# Compare results
comparison = optimizer.compare_optimization_methods()

print("\nOptimization Method Comparison:")
print("-" * 60)
for method, results in comparison.items():
    if results['method_type'] == 'nested_cv':
        print(f"{method}:")
        print(f"  Unbiased Performance: {results['performance']:.4f} ± {results['std']:.4f}")
    else:
        print(f"{method}:")
        print(f"  CV Performance: {results['cv_performance']:.4f}")
        print(f"  Test Performance: {results['test_performance']:.4f}")
        print(f"  Optimization Time: {results['optimization_time']:.2f}s")
        print(f"  Evaluations: {results['n_evaluations']}")
        print(f"  Efficiency: {results['efficiency']:.6f} (score/second)")
    print()

# Visualize optimization convergence
fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# Grid search results visualization
grid_results = optimizer.optimization_results['grid_search_rbf']['cv_results']
C_values = [params['C'] for params in grid_results['params']]
gamma_values = [params['gamma'] for params in grid_results['params'] if isinstance(params['gamma'], (int, float))]
scores = -grid_results['mean_test_score']

# Parameter space exploration
axes[0, 0].scatter(C_values, scores, alpha=0.6)
axes[0, 0].set_xscale('log')
axes[0, 0].set_xlabel('C Parameter')
axes[0, 0].set_ylabel('Cross-Validation MSE')
axes[0, 0].set_title('Grid Search: C vs Performance')
axes[0, 0].grid(True)

# Optimization method comparison
methods = ['Grid Search', 'Random Search', 'Bayesian Opt']
cv_scores = [
    optimizer.optimization_results['grid_search_rbf']['best_cv_score'],
    optimizer.optimization_results['random_search_rbf']['best_cv_score'],
    optimizer.optimization_results['bayesian_rbf']['best_cv_score']
]
times = [
    optimizer.optimization_results['grid_search_rbf']['optimization_time'],
    optimizer.optimization_results['random_search_rbf']['optimization_time'],
    optimizer.optimization_results['bayesian_rbf']['optimization_time']
]

axes[0, 1].bar(methods, cv_scores, color=['skyblue', 'lightcoral', 'lightgreen'])
axes[0, 1].set_ylabel('Best CV Score (MSE)')
axes[0, 1].set_title('Optimization Method Performance')
axes[0, 1].tick_params(axis='x', rotation=45)

# Optimization efficiency
axes[1, 0].bar(methods, times, color=['skyblue', 'lightcoral', 'lightgreen'])
axes[1, 0].set_ylabel('Optimization Time (seconds)')
axes[1, 0].set_title('Optimization Method Efficiency')
axes[1, 0].tick_params(axis='x', rotation=45)

# Nested CV results
nested_results = optimizer.optimization_results['nested_cv_rbf']
axes[1, 1].boxplot([nested_results['train_scores'], nested_results['test_scores']], 
                   labels=['Train', 'Validation'])
axes[1, 1].set_ylabel('MSE Score')
axes[1, 1].set_title('Nested Cross-Validation Results')
axes[1, 1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

# Print best parameters from each method
print("Best Parameters from Each Method:")
print("-" * 40)
for method_name, results in optimizer.optimization_results.items():
    if 'best_params' in results:
        print(f"{method_name}: {results['best_params']}")
```

**Conclusion**: Support Vector Regression in scikit-learn provides a robust framework for non-linear regression through kernel methods, offering flexibility in capturing complex relationships while maintaining theoretical guarantees. The choice between SVR variants depends on data characteristics, computational constraints, and interpretability requirements. Linear SVR excels in high-dimensional scenarios with computational efficiency, while kernel methods provide expressiveness for non-linear patterns. Nu-SVR offers intuitive parameterization through direct control of support vector fractions. Effective kernel selection requires systematic evaluation considering data properties, performance requirements, and computational constraints. Comprehensive hyperparameter optimization through grid search, random search, or Bayesian optimization ensures optimal model configuration, with nested cross-validation providing unbiased performance estimates.

**Next steps**: Explore ensemble methods combining multiple SVR models with different kernels, investigate online learning variants for streaming data applications, implement multi-output SVR for simultaneous prediction of multiple targets, and develop domain-specific kernel functions for specialized applications.

---

