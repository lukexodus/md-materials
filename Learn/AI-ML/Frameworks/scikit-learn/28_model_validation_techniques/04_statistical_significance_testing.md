## Statistical Significance Testing


Statistical significance testing determines whether observed differences in model performance are statistically meaningful or could be due to random variation. This is crucial for comparing models and making confident decisions about model selection.

Common statistical tests include the paired t-test for comparing two models, McNemar's test for classification problems, and the Wilcoxon signed-rank test for non-parametric comparisons. These tests account for the correlation between cross-validation folds and provide p-values for significance decisions.

**Key points:**

- Determines if performance differences are statistically meaningful
- Accounts for cross-validation correlation and multiple comparisons
- Provides confidence intervals for performance estimates
- Guides model selection with statistical rigor

**Example:**

```python
from scipy import stats
from sklearn.model_selection import cross_validate
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import numpy as np

def statistical_comparison(models, X, y, cv=5, alpha=0.05):
    """
    Compare multiple models using statistical significance testing.
    """
    model_names = list(models.keys())
    n_models = len(models)
    
    # Store cross-validation scores for each model
    cv_results = {}
    
    print("Cross-validation results:")
    print("-" * 50)
    
    for name, model in models.items():
        cv_scores = cross_validate(
            model, X, y, cv=cv, scoring='accuracy', 
            return_train_score=False, n_jobs=-1
        )['test_score']
        
        cv_results[name] = cv_scores
        mean_score = np.mean(cv_scores)
        std_score = np.std(cv_scores)
        
        print(f"{name}:")
        print(f"  Mean CV score: {mean_score:.4f} (+/- {std_score:.4f})")
        print(f"  Individual scores: {cv_scores}")
        print()
    
    # Pairwise statistical comparisons
    print("Pairwise statistical comparisons (paired t-test):")
    print("-" * 60)
    
    comparison_results = {}
    
    for i, model1 in enumerate(model_names):
        comparison_results[model1] = {}
        for j, model2 in enumerate(model_names):
            if i >= j:
                continue
                
            scores1 = cv_results[model1]
            scores2 = cv_results[model2]
            
            # Paired t-test
            t_stat, p_value = stats.ttest_rel(scores1, scores2)
            
            # Effect size (Cohen's d)
            pooled_std = np.sqrt((np.std(scores1)**2 + np.std(scores2)**2) / 2)
            cohens_d = (np.mean(scores1) - np.mean(scores2)) / pooled_std
            
            comparison_results[model1][model2] = {
                't_statistic': t_stat,
                'p_value': p_value,
                'significant': p_value < alpha,
                'cohens_d': cohens_d
            }
            
            print(f"{model1} vs {model2}:")
            print(f"  t-statistic: {t_stat:.4f}")
            print(f"  p-value: {p_value:.4f}")
            print(f"  Significant (α={alpha}): {p_value < alpha}")
            print(f"  Cohen's d: {cohens_d:.4f}")
            print()
    
    return cv_results, comparison_results

def corrected_resampled_ttest(scores1, scores2, n_train, n_test, alpha=0.05):
    """
    Corrected resampled t-test that accounts for cross-validation correlation.
    """
    # Calculate the corrected variance
    rho = 1 / n_test  # Approximate correlation between CV folds
    
    mean_diff = np.mean(scores1 - scores2)
    var_diff = np.var(scores1 - scores2, ddof=1)
    
    # Correction for cross-validation correlation
    corrected_var = var_diff * (1 + (n_test - 1) * rho) / n_test
    corrected_se = np.sqrt(corrected_var)
    
    t_stat = mean_diff / corrected_se
    df = len(scores1) - 1
    p_value = 2 * (1 - stats.t.cdf(abs(t_stat), df))
    
    return t_stat, p_value

# Compare multiple models
models = {
    'Random Forest': RandomForestClassifier(n_estimators=100, random_state=42),
    'Gradient Boosting': GradientBoostingClassifier(n_estimators=100, random_state=42),
    'Logistic Regression': LogisticRegression(random_state=42, max_iter=1000)
}

cv_results, comparison_results = statistical_comparison(models, X, y, cv=5)

# Multiple comparison correction (Bonferroni)
n_comparisons = len(models) * (len(models) - 1) // 2
corrected_alpha = 0.05 / n_comparisons

print(f"Bonferroni corrected significance level: {corrected_alpha:.4f}")
print("\nSignificant differences after Bonferroni correction:")
for model1, comparisons in comparison_results.items():
    for model2, results in comparisons.items():
        if results['p_value'] < corrected_alpha:
            print(f"{model1} significantly outperforms {model2} (p={results['p_value']:.4f})")
```

Statistical testing should always include multiple comparison corrections when comparing many models, and effect sizes should be reported alongside significance to assess practical importance.

