## Supervised vs Unsupervised Learning


**Supervised learning** uses labeled training data to learn a mapping function from input features to target outputs. The algorithm learns from examples where both the input and correct output are provided. In scikit-learn, supervised learning is implemented through estimators that have both `fit(X, y)` and `predict(X)` methods, where `X` represents features and `y` represents target labels.

**Unsupervised learning** finds hidden patterns in data without labeled examples. The algorithm discovers structure in input data without knowing the correct outputs. Scikit-learn implements unsupervised learning through estimators that only require `fit(X)` and typically provide methods like `transform(X)` or `predict(X)` for pattern discovery.

**Key Points:**

- Supervised: `sklearn.ensemble.RandomForestClassifier`, `sklearn.linear_model.LinearRegression`
- Unsupervised: `sklearn.cluster.KMeans`, `sklearn.decomposition.PCA`
- Semi-supervised methods combine both approaches: `sklearn.semi_supervised.LabelPropagation`

