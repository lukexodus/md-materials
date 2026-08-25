## Nested Pipeline Structures


### Hierarchical Pipeline Architecture

Nested pipelines create hierarchical transformation structures where pipelines become components within larger pipelines. This architecture enables modular design, allowing complex workflows to be broken down into manageable, reusable components.

```python
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.decomposition import PCA
from sklearn.feature_selection import SelectKBest
from sklearn.ensemble import RandomForestClassifier

# Numerical processing sub-pipeline
numerical_pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('feature_selection', SelectKBest(k=10)),
    ('pca', PCA(n_components=5))
])

# Categorical processing sub-pipeline
categorical_pipeline = Pipeline([
    ('onehot', OneHotEncoder(drop='first', sparse_output=False)),
    ('feature_selection', SelectKBest(k=8))
])

# Main preprocessing pipeline
preprocessing_pipeline = ColumnTransformer([
    ('numerical', numerical_pipeline, ['age', 'income', 'score']),
    ('categorical', categorical_pipeline, ['category', 'region'])
], remainder='drop')

# Full nested pipeline
full_pipeline = Pipeline([
    ('preprocessing', preprocessing_pipeline),
    ('classifier', RandomForestClassifier())
])
```

### Multi-Level Feature Engineering

Complex feature engineering often requires multiple transformation levels, where earlier transformations create intermediate features that subsequent steps further refine. Nested structures accommodate these dependencies while maintaining pipeline integrity.

```python
# First level: basic transformations
level1_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

# Second level: interaction features
level2_pipeline = Pipeline([
    ('poly_features', PolynomialFeatures(degree=2, include_bias=False)),
    ('feature_selection', SelectKBest(f_regression, k=20))
])

# Combined multi-level pipeline
multi_level_pipeline = Pipeline([
    ('level1', level1_pipeline),
    ('level2', level2_pipeline),
    ('regressor', ElasticNet())
])
```

### Pipeline Composition Strategies

Advanced composition strategies combine multiple nested pipelines through feature unions, voting ensembles, or stacking architectures. These patterns enable sophisticated model architectures that leverage different transformation pathways.

```python
from sklearn.ensemble import VotingClassifier

# Multiple processing paths
path1 = Pipeline([
    ('scaler', StandardScaler()),
    ('svm', SVC(probability=True))
])

path2 = Pipeline([
    ('robust_scaler', RobustScaler()),
    ('rf', RandomForestClassifier())
])

path3 = Pipeline([
    ('normalizer', Normalizer()),
    ('gb', GradientBoostingClassifier())
])

# Ensemble of nested pipelines
ensemble_pipeline = VotingClassifier([
    ('path1', path1),
    ('path2', path2),
    ('path3', path3)
], voting='soft')
```

