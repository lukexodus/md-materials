## Advanced Usage Patterns


**Example: Dynamic feature selection based on dataset size**

```python
def adaptive_feature_selection(X, y, method='auto'):
    """
    Adapt feature selection method based on dataset characteristics
    """
    n_samples, n_features = X.shape
    
    if method == 'auto':
        if n_features > 10000:  # High-dimensional data
            method = 'chi2'  # Fastest method
        elif n_samples < 500:   # Small sample size
            method = 'f_test'   # More stable with small samples
        else:
            method = 'mutual_info'  # Best for capturing complex relationships
    
    # Select percentage based on sample size
    if n_samples < 100:
        percentile = 50
    elif n_samples < 1000:
        percentile = 25
    else:
        percentile = 10
    
    method_map = {
        'chi2': chi2,
        'f_test': f_classif,
        'mutual_info': mutual_info_classif
    }
    
    selector = SelectPercentile(score_func=method_map[method], percentile=percentile)
    
    if method == 'chi2':
        # Ensure non-negative values for chi-square
        scaler = MinMaxScaler()
        X_processed = scaler.fit_transform(X)
        X_selected = selector.fit_transform(X_processed, y)
    else:
        X_selected = selector.fit_transform(X, y)
    
    return X_selected, selector, method
```

**Output interpretation guidelines:**

- Compare p-values against significance thresholds (typically 0.05)
- Higher scores generally indicate more relevant features
- Consider multiple methods for robust selection
- Validate selected features using cross-validation
- Monitor for overfitting with very small feature sets

**Conclusion:** Univariate feature selection provides an efficient first step in dimensionality reduction, with each method offering unique strengths. Chi-square excels with categorical data, ANOVA F-tests handle continuous features well, and mutual information captures complex non-linear relationships. Combining multiple methods often yields the most robust feature selection results.

**Next steps:** Consider multivariate feature selection methods (RFE, feature importance from tree-based models) and wrapper methods (forward/backward selection) for more sophisticated feature interactions, and always validate feature selection choices through proper cross-validation procedures.

---

