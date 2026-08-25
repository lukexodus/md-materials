## Data Representation and Preprocessing


### Data Loading and Datasets

Scikit-learn provides built-in datasets for learning and experimentation:

```python
from sklearn import datasets
from sklearn.datasets import make_classification, make_regression

# Built-in datasets
iris = datasets.load_iris()
boston = datasets.load_boston()  # Deprecated
california = datasets.fetch_california_housing()

# Synthetic datasets
X, y = make_classification(n_samples=1000, n_features=20, n_classes=2)
X_reg, y_reg = make_regression(n_samples=1000, n_features=10)
```

### Feature Scaling and Normalization

```python
from sklearn.preprocessing import StandardScaler, MinMaxScaler, RobustScaler
from sklearn.preprocessing import Normalizer, QuantileTransformer

# Standardization (z-score normalization)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Min-Max scaling
minmax_scaler = MinMaxScaler(feature_range=(0, 1))
X_minmax = minmax_scaler.fit_transform(X)

# Robust scaling (median and IQR)
robust_scaler = RobustScaler()
X_robust = robust_scaler.fit_transform(X)
```

### Feature Engineering and Selection

```python
from sklearn.feature_selection import SelectKBest, f_classif, RFE
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import PolynomialFeatures

# Univariate feature selection
selector = SelectKBest(score_func=f_classif, k=10)
X_selected = selector.fit_transform(X, y)

# Recursive feature elimination
from sklearn.linear_model import LogisticRegression
estimator = LogisticRegression()
rfe = RFE(estimator, n_features_to_select=5)
X_rfe = rfe.fit_transform(X, y)

# Polynomial features
poly = PolynomialFeatures(degree=2, include_bias=False)
X_poly = poly.fit_transform(X)
```

### Handling Categorical Data

```python
from sklearn.preprocessing import LabelEncoder, OneHotEncoder, OrdinalEncoder
from sklearn.compose import ColumnTransformer

# Label encoding for target variables
label_encoder = LabelEncoder()
y_encoded = label_encoder.fit_transform(y)

# One-hot encoding
onehot_encoder = OneHotEncoder(sparse=False, drop='first')
X_categorical_encoded = onehot_encoder.fit_transform(X_categorical)

# Column transformer for mixed data types
preprocessor = ColumnTransformer([
    ('num', StandardScaler(), numeric_features),
    ('cat', OneHotEncoder(), categorical_features)
])
```

