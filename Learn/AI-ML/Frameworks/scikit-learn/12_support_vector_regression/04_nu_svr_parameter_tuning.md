## Nu-SVR Parameter Tuning


Nu-SVR provides an alternative formulation of SVR that replaces the epsilon parameter with nu, offering different interpretations and potential advantages in parameter selection and model interpretation.

### Nu Parameter Interpretation

**Fraction of Support Vectors**: The nu parameter directly controls the fraction of training examples that become support vectors. Nu must be between 0 and 1, where higher values typically result in more support vectors and potentially more complex models.

**Error Tolerance**: Nu also serves as an upper bound on the fraction of training errors and a lower bound on the fraction of support vectors. This dual interpretation provides intuitive guidance for parameter selection.

**Relationship to Epsilon**: While Nu-SVR doesn't explicitly use epsilon, the optimization automatically determines an appropriate epsilon value based on the nu parameter and data characteristics. This can simplify hyperparameter tuning by reducing the parameter space.

### Advantages and Trade-offs

**Parameter Intuition**: The nu parameter often provides more intuitive interpretation than epsilon, as it directly relates to the fraction of the dataset that defines the model complexity.

**Automatic Epsilon Selection**: Nu-SVR automatically determines the epsilon tube width, potentially reducing the need for manual epsilon tuning and providing more robust performance across different datasets.

**Computational Considerations**: Nu-SVR may require more iterations to converge compared to standard SVR, particularly for extreme nu values close to 0 or 1.

### Tuning Strategies

**Validation-Based Selection**: Use cross-validation to select nu values that optimize predictive performance while maintaining appropriate model complexity.

**Support Vector Analysis**: Monitor the relationship between nu values and the actual fraction of support vectors to ensure the parameter choice aligns with desired model characteristics.

**Robustness Assessment**: Evaluate model stability across different nu values to identify parameter ranges that provide consistent performance.

**Key points**:

- Nu parameter provides intuitive control over model complexity
- Automatically determines appropriate epsilon values
- Direct relationship between nu and fraction of support vectors
- May require more computational resources for convergence
- Useful when epsilon selection is challenging or unclear

**Example**:

```python
from sklearn.svm import NuSVR
from sklearn.datasets import make_regression
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score, validation_curve
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np
import matplotlib.pyplot as plt

# Generate synthetic regression dataset
np.random.seed(42)
X, y = make_regression(n_samples=1000, n_features=10, noise=5, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Standardize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Nu-SVR parameter exploration
nu_values = np.linspace(0.1, 0.9, 9)
C_values = np.logspace(-1, 2, 4)

# Comprehensive parameter tuning
results = []
for nu in nu_values:
    for C in C_values:
        model = NuSVR(nu=nu, C=C, kernel='rbf', gamma='scale')
        
        # Cross-validation performance
        cv_scores = cross_val_score(model, X_train_scaled, y_train, 
                                  cv=5, scoring='neg_mean_squared_error')
        
        # Fit model to get support vector information
        model.fit(X_train_scaled, y_train)
        y_pred = model.predict(X_test_scaled)
        
        results.append({
            'nu': nu,
            'C': C,
            'cv_mse': -cv_scores.mean(),
            'cv_std': cv_scores.std(),
            'test_mse': mean_squared_error(y_test, y_pred),
            'test_r2': r2_score(y_test, y_pred),
            'n_support_vectors': len(model.support_),
            'support_vector_fraction': len(model.support_) / len(X_train)
        })

results_df = pd.DataFrame(results)

# Find best parameters based on cross-validation
best_idx = results_df['cv_mse'].idxmin()
best_params = results_df.iloc[best_idx]

print("Best Nu-SVR Parameters:")
print(f"Nu: {best_params['nu']:.2f}")
print(f"C: {best_params['C']:.2f}")
print(f"CV MSE: {best_params['cv_mse']:.4f} ± {best_params['cv_std']:.4f}")
print(f"Test MSE: {best_params['test_mse']:.4f}")
print(f"Test R²: {best_params['test_r2']:.4f}")
print(f"Support Vector Fraction: {best_params['support_vector_fraction']:.3f}")

# Visualize parameter relationships
fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# Nu vs Support Vector Fraction
for C_val in C_values:
    subset = results_df[results_df['C'] == C_val]
    axes[0, 0].plot(subset['nu'], subset['support_vector_fraction'], 
                   'o-', label=f'C={C_val:.1f}')
axes[0, 0].plot([0, 1], [0, 1], 'k--', alpha=0.5, label='y=x (theoretical)')
axes[0, 0].set_xlabel('Nu Parameter')
axes[0, 0].set_ylabel('Actual Support Vector Fraction')
axes[0, 0].set_title('Nu vs Support Vector Fraction')
axes[0, 0].legend()
axes[0, 0].grid(True)

# Nu vs Cross-Validation MSE
for C_val in C_values:
    subset = results_df[results_df['C'] == C_val]
    axes[0, 1].plot(subset['nu'], subset['cv_mse'], 'o-', label=f'C={C_val:.1f}')
axes[0, 1].set_xlabel('Nu Parameter')
axes[0, 1].set_ylabel('Cross-Validation MSE')
axes[0, 1].set_title('Nu vs Cross-Validation Performance')
axes[0, 1].legend()
axes[0, 1].grid(True)

# C vs Performance for different Nu values
selected_nus = [0.1, 0.3, 0.5, 0.7]
for nu_val in selected_nus:
    subset = results_df[results_df['nu'] == nu_val]
    axes[1, 0].semilogx(subset['C'], subset['cv_mse'], 'o-', label=f'ν={nu_val:.1f}')
axes[1, 0].set_xlabel('C Parameter')
axes[1, 0].set_ylabel('Cross-Validation MSE')
axes[1, 0].set_title('C vs Performance for Different Nu Values')
axes[1, 0].legend()
axes[1, 0].grid(True)

# Bias-Variance Analysis
nu_range = np.linspace(0.1, 0.8, 8)
train_scores, val_scores = validation_curve(
    NuSVR(C=1.0, kernel='rbf', gamma='scale'),
    X_train_scaled, y_train,
    param_name='nu', param_range=nu_range,
    cv=5, scoring='neg_mean_squared_error', n_jobs=-1
)

axes[1, 1].plot(nu_range, -train_scores.mean(axis=1), 'o-', label='Training MSE')
axes[1, 1].plot(nu_range, -val_scores.mean(axis=1), 'o-', label='Validation MSE')
axes[1, 1].fill_between(nu_range, 
                       -val_scores.mean(axis=1) - val_scores.std(axis=1),
                       -val_scores.mean(axis=1) + val_scores.std(axis=1), 
                       alpha=0.1)
axes[1, 1].set_xlabel('Nu Parameter')
axes[1, 1].set_ylabel('Mean Squared Error')
axes[1, 1].set_title('Bias-Variance Tradeoff')
axes[1, 1].legend()
axes[1, 1].grid(True)

plt.tight_layout()
plt.show()

# Compare Nu-SVR with standard SVR
comparison_models = {
    'Nu-SVR (optimized)': NuSVR(nu=best_params['nu'], C=best_params['C'], 
                               kernel='rbf', gamma='scale'),
    'Standard SVR': SVR(epsilon=0.1, C=1.0, kernel='rbf', gamma='scale'),
    'Linear SVR': LinearSVR(epsilon=0.1, C=1.0)
}

print("\nModel Comparison:")
for name, model in comparison_models.items():
    model.fit(X_train_scaled, y_train)
    y_pred = model.predict(X_test_scaled)
    
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    if hasattr(model, 'support_'):
        n_sv = len(model.support_) if hasattr(model, 'support_') else 'N/A'
        print(f"{name}: MSE={mse:.4f}, R²={r2:.4f}, SVs={n_sv}")
    else:
        print(f"{name}: MSE={mse:.4f}, R²={r2:.4f}")
```

