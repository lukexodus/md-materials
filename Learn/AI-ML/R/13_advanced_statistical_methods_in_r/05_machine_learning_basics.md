## Machine Learning Basics


Machine learning in R encompasses supervised and unsupervised learning algorithms for prediction, classification, and pattern discovery. The ecosystem includes both traditional statistical learning and modern deep learning approaches.

**Key points:**

- Supervised learning requires labeled training data for prediction tasks
- Unsupervised learning finds patterns in data without outcome variables
- Feature engineering and preprocessing significantly impact model performance
- The bias-variance tradeoff guides model complexity decisions

Classification algorithms include logistic regression, random forests (`randomForest`), support vector machines (`e1071`), and neural networks (`nnet`). Regression extends these approaches to continuous outcomes, with additional methods like ridge regression (`glmnet`) and gradient boosting (`gbm`).

The `caret` package provides a unified interface for model training, tuning, and evaluation across numerous algorithms. It standardizes preprocessing, cross-validation, and performance metrics. `tidymodels` offers a newer, tidy approach to machine learning workflows.

Feature preprocessing includes scaling, centering, dummy variable creation, and handling missing values. The `recipes` package (part of tidymodels) provides a grammar for preprocessing specifications. Principal component analysis via `prcomp()` reduces dimensionality while preserving variance.

Unsupervised learning includes clustering through `kmeans()`, hierarchical clustering via `hclust()`, and dimensionality reduction using PCA or t-SNE (`Rtsne`). Association rule mining uses `arules` and `arulesViz` packages.

Model interpretation increasingly relies on post-hoc explanation methods. The `lime` package provides local interpretable model-agnostic explanations, while `DALEX` offers comprehensive model exploration tools.

