## Pipelines and Model Composition


### Building Pipelines

```python
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.compose import ColumnTransformer, make_column_transformer

# Basic pipeline
pipe = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', LogisticRegression())
])

# Fitting and predicting with pipeline
pipe.fit(X_train, y_train)
y_pred = pipe.predict(X_test)

# Pipeline with feature selection
feature_selection_pipe = Pipeline([
    ('scaler', StandardScaler()),
    ('feature_selection', SelectKBest(k=10)),
    ('classifier', SVC())
])
```

### Column Transformer

```python
# Preprocessing different column types
numeric_features = ['age', 'fare']
categorical_features = ['sex', 'embarked']

preprocessor = ColumnTransformer([
    ('num', StandardScaler(), numeric_features),
    ('cat', OneHotEncoder(drop='first'), categorical_features)
])

# Complete pipeline
full_pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier())
])
```

### Feature Unions

```python
from sklearn.pipeline import FeatureUnion
from sklearn.decomposition import PCA
from sklearn.feature_selection import SelectKBest

# Combining multiple feature transformations
feature_union = FeatureUnion([
    ('pca', PCA(n_components=10)),
    ('selection', SelectKBest(k=5))
])

combined_pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('features', feature_union),
    ('classifier', LogisticRegression())
])
```

