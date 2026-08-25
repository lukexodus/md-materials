## Module 5: Cross-Validation


### 5.1 Cross-Validation Fundamentals

- Train-test split limitations
- Cross-validation rationale and benefits
- Bias-variance tradeoff in evaluation
- Computational considerations

### 5.2 K-Fold Cross-Validation

- Standard k-fold methodology
- Choosing k: theoretical and practical considerations
- Stratified k-fold for classification
- Repeated k-fold cross-validation

### 5.3 Specialized Cross-Validation Techniques

- Leave-One-Out Cross-Validation (LOOCV)
- Leave-P-Out Cross-Validation
- Monte Carlo cross-validation (shuffle-split)
- Hold-out validation strategies

### 5.4 Time Series Cross-Validation

- Forward chaining (rolling origin)
- Expanding window validation
- Sliding window validation
- Time series split strategies
- Gap considerations to prevent leakage

### 5.5 Group-Based Cross-Validation

- Group k-fold (for correlated samples)
- Patient-level or session-level splits
- Hierarchical data considerations
- Cluster-based validation

### 5.6 Nested Cross-Validation

- Outer loop for model evaluation
- Inner loop for hyperparameter tuning
- Avoiding selection bias
- Computational cost management

### 5.7 Cross-Validation for Imbalanced Data

- Stratification strategies
- Maintaining class distributions
- Combining with resampling techniques

### 5.8 Statistical Analysis of CV Results

- Mean and variance of CV scores
- Confidence intervals for performance estimates
- Comparing models using CV results
- Detecting overfitting through CV

### 5.9 Cross-Validation Best Practices

- Reproducibility (random seeds, data ordering)
- Parallelization strategies
- Memory-efficient implementations
- When to use which CV strategy
- Common pitfalls and how to avoid them

---

