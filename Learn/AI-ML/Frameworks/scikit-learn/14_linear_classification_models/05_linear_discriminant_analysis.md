## Linear Discriminant Analysis


Linear Discriminant Analysis (LDA) combines dimensionality reduction with classification, finding linear combinations of features that best separate classes.

**Key points:**

- Assumes Gaussian distributions with equal covariance matrices
- Maximizes between-class scatter while minimizing within-class scatter
- Provides both classification and dimensionality reduction
- Can handle multiclass problems naturally

```python
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.datasets import load_iris

# Load multi-class dataset
iris = load_iris()
X, y = iris.data, iris.target

# Basic LDA
lda = LinearDiscriminantAnalysis()
lda.fit(X, y)

# Dimensionality reduction + classification
X_lda = lda.transform(X)  # Reduced dimensionality
predictions = lda.predict(X)
probabilities = lda.predict_proba(X)

# Access discriminant components
print(f"Components shape: {lda.scalings_.shape}")
print(f"Explained variance ratio: {lda.explained_variance_ratio_}")
```

**Mathematical foundation:**

- Between-class scatter matrix: S_B = Σ n_i(μ_i - μ)(μ_i - μ)ᵀ
- Within-class scatter matrix: S_W = Σ Σ (x - μ_i)(x - μ_i)ᵀ
- Optimization objective: maximize |W^T S_B W| / |W^T S_W W|

**Advanced LDA usage:**

```python
# LDA with different solvers
lda_svd = LinearDiscriminantAnalysis(solver='svd')  # For small datasets
lda_lsqr = LinearDiscriminantAnalysis(solver='lsqr')  # For large datasets
lda_eigen = LinearDiscriminantAnalysis(solver='eigen')  # For dimensionality reduction

# Regularized LDA for high-dimensional data
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
qda = QuadraticDiscriminantAnalysis(reg_param=0.01)

# Custom priors
lda_custom = LinearDiscriminantAnalysis(priors=[0.3, 0.3, 0.4])
```

**Comparison with QDA:**

```python
# When to use LDA vs QDA
lda_comparison = LinearDiscriminantAnalysis()
qda_comparison = QuadraticDiscriminantAnalysis()

# LDA assumes equal covariance matrices
# QDA allows different covariance matrices per class
# Trade-off: LDA (bias) vs QDA (variance)
```

**Output** interpretation for LDA:

- **Coefficients**: Linear discriminant directions
- **Intercept**: Decision boundary offsets
- **Class priors**: Estimated or specified class probabilities
- **Means**: Class centroids in original feature space

**Conclusion:** Linear classification models in scikit-learn offer diverse approaches for different scenarios: LogisticRegression for interpretable probabilistic classification, SGDClassifier for large-scale problems, Perceptron for educational purposes and simple binary classification, PassiveAggressiveClassifier for online learning, and LinearDiscriminantAnalysis for combined classification and dimensionality reduction. Each model has specific strengths in terms of computational efficiency, theoretical foundations, and practical applications.

**Next steps:**

- **Model selection**: Use cross-validation to compare different linear classifiers
- **Feature engineering**: Apply polynomial features or interactions for non-linear patterns
- **Ensemble methods**: Combine linear classifiers with voting or stacking
- **Hyperparameter tuning**: Optimize regularization parameters and solver choices
- **Performance evaluation**: Implement comprehensive metrics including precision, recall, F1-score, and ROC curves

Related topics include support vector machines, neural networks, ensemble methods, and advanced optimization techniques for large-scale machine learning.

---

