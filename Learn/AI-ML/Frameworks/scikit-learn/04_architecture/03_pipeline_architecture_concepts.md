## Pipeline Architecture Concepts


**Pipeline** chains multiple estimators in sequence, where each step except the last must be a transformer (implement `fit()` and `transform()`), and the final step can be any estimator. The pipeline presents a unified estimator interface, automatically managing data flow between steps.

Pipelines enable complex workflows to be treated as single estimators, supporting hyperparameter tuning, cross-validation, and model selection across the entire processing chain. Each pipeline step receives the transformed output from the previous step.

**Key Points:**

- `sklearn.pipeline.Pipeline` constructs linear sequences
- `sklearn.pipeline.FeatureUnion` combines multiple transformers in parallel
- `sklearn.compose.ColumnTransformer` applies different transformers to different feature subsets
- Pipeline parameters accessed via `stepname__parameter` syntax
- `make_pipeline()` creates pipelines with auto-generated step names

**Example:**

```python
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier

# Explicit pipeline construction
pipe = Pipeline([
    ('scaler', StandardScaler()),
    ('pca', PCA(n_components=2)),
    ('classifier', RandomForestClassifier())
])

# Auto-generated step names
pipe_auto = make_pipeline(
    StandardScaler(),
    PCA(n_components=2),
    RandomForestClassifier()
)

# Pipeline acts as single estimator
pipe.fit(X, y)
predictions = pipe.predict(X)

# Access nested parameters
pipe.set_params(pca__n_components=3, classifier__n_estimators=200)
```

