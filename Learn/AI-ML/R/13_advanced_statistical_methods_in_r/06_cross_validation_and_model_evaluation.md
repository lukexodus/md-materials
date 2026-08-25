## Cross-Validation and Model Evaluation


Cross-validation provides robust estimates of model performance by training on subsets of data and testing on held-out portions. R offers extensive support for validation strategies and performance metrics.

**Key points:**

- K-fold cross-validation balances bias and variance in performance estimates
- Stratified sampling maintains outcome distribution across folds
- Performance metrics should align with the business or scientific objective
- Nested cross-validation properly evaluates hyperparameter tuning

The `caret` package implements various cross-validation schemes through `trainControl()`. K-fold cross-validation divides data into k equally-sized folds, training on k-1 and testing on the remaining fold. Leave-one-out cross-validation represents the extreme case where k equals the sample size.

Stratified cross-validation maintains the distribution of outcome variables across folds, particularly important for imbalanced classification problems. Time series cross-validation respects temporal ordering through rolling or expanding windows.

Classification metrics include accuracy, sensitivity, specificity, and area under the ROC curve. The `pROC` package provides comprehensive ROC analysis. Precision, recall, and F1-scores address class imbalance issues. Confusion matrices visualize classification performance across all classes.

Regression metrics include mean squared error, root mean squared error, mean absolute error, and R-squared. The choice depends on the loss function's alignment with the problem context and outlier sensitivity preferences.

Nested cross-validation separates hyperparameter tuning from performance estimation. The outer loop provides unbiased performance estimates, while inner loops optimize hyperparameters. This prevents overly optimistic performance estimates from hyperparameter overfitting.

Bootstrap validation offers an alternative to cross-validation, particularly useful for small datasets or when cross-validation folds would be too small for reliable estimation.

