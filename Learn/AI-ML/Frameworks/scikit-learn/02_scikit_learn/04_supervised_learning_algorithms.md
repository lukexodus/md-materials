## Supervised Learning Algorithms


### Classification Algorithms

#### Linear Models

```python
from sklearn.linear_model import LogisticRegression, SGDClassifier
from sklearn.linear_model import RidgeClassifier, PassiveAggressiveClassifier

# Logistic Regression
log_reg = LogisticRegression(penalty='l2', C=1.0, solver='lbfgs')
log_reg.fit(X_train, y_train)

# Stochastic Gradient Descent
sgd_clf = SGDClassifier(loss='hinge', alpha=0.01, random_state=42)
sgd_clf.fit(X_train, y_train)
```

#### Tree-Based Models

```python
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier
from sklearn.ensemble import GradientBoostingClassifier

# Decision Tree
dt_clf = DecisionTreeClassifier(max_depth=5, random_state=42)
dt_clf.fit(X_train, y_train)

# Random Forest
rf_clf = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42)
rf_clf.fit(X_train, y_train)

# Gradient Boosting
gb_clf = GradientBoostingClassifier(n_estimators=100, learning_rate=0.1)
gb_clf.fit(X_train, y_train)
```

#### Support Vector Machines

```python
from sklearn.svm import SVC, LinearSVC, NuSVC

# Support Vector Classifier
svm_clf = SVC(kernel='rbf', C=1.0, gamma='scale')
svm_clf.fit(X_train, y_train)

# Linear SVM (faster for large datasets)
linear_svm = LinearSVC(C=1.0, random_state=42)
linear_svm.fit(X_train, y_train)
```

#### Naive Bayes

```python
from sklearn.naive_bayes import GaussianNB, MultinomialNB, BernoulliNB

# Gaussian Naive Bayes
gnb = GaussianNB()
gnb.fit(X_train, y_train)

# Multinomial Naive Bayes (for discrete features)
mnb = MultinomialNB(alpha=1.0)
mnb.fit(X_train, y_train)
```

#### K-Nearest Neighbors

```python
from sklearn.neighbors import KNeighborsClassifier, RadiusNeighborsClassifier

# K-Nearest Neighbors
knn_clf = KNeighborsClassifier(n_neighbors=5, weights='uniform')
knn_clf.fit(X_train, y_train)
```

### Regression Algorithms

#### Linear Regression

```python
from sklearn.linear_model import LinearRegression, Ridge, Lasso, ElasticNet
from sklearn.linear_model import SGDRegressor, BayesianRidge

# Ordinary Least Squares
linear_reg = LinearRegression()
linear_reg.fit(X_train, y_train)

# Ridge Regression (L2 regularization)
ridge_reg = Ridge(alpha=1.0)
ridge_reg.fit(X_train, y_train)

# Lasso Regression (L1 regularization)
lasso_reg = Lasso(alpha=0.1)
lasso_reg.fit(X_train, y_train)

# Elastic Net (L1 + L2)
elastic_net = ElasticNet(alpha=0.1, l1_ratio=0.7)
elastic_net.fit(X_train, y_train)
```

#### Tree-Based Regression

```python
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.ensemble import ExtraTreesRegressor

# Random Forest Regressor
rf_reg = RandomForestRegressor(n_estimators=100, random_state=42)
rf_reg.fit(X_train, y_train)

# Gradient Boosting Regressor
gb_reg = GradientBoostingRegressor(n_estimators=100, learning_rate=0.1)
gb_reg.fit(X_train, y_train)
```

#### Support Vector Regression

```python
from sklearn.svm import SVR, LinearSVR

# Support Vector Regression
svr = SVR(kernel='rbf', C=1.0, epsilon=0.1)
svr.fit(X_train, y_train)
```

