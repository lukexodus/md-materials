## Pipeline Class Usage


The Pipeline class serves as the backbone for creating sequential transformation and modeling workflows. It ensures that all steps are applied in the correct order and that the same transformations used during training are automatically applied during prediction.

**Key points:**

- Chains multiple transformers with a final estimator in sequence
- Prevents data leakage by applying transformations consistently
- Enables hyperparameter optimization across entire workflow
- Supports cross-validation at the pipeline level
- Automatically handles fit/transform logic for each step
- Provides unified interface for complex workflows

**Example:**

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.datasets import make_classification
from sklearn.metrics import classification_report
import pandas as pd
import numpy as np

# Generate sample data
X, y = make_classification(n_samples=1000, n_features=20, n_informative=10, 
                         n_redundant=5, random_state=42)
feature_names = [f'feature_{i}' for i in range(X.shape[1])]
X = pd.DataFrame(X, columns=feature_names)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Create comprehensive pipeline
preprocessing_pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('feature_selection', SelectKBest(score_func=f_classif, k=10)),
    ('classifier', RandomForestClassifier(random_state=42))
])

# Fit the entire pipeline
preprocessing_pipeline.fit(X_train, y_train)

# Make predictions
y_pred = preprocessing_pipeline.predict(X_test)
print("Pipeline Performance:")
print(classification_report(y_test, y_pred))

# Access individual pipeline steps
print(f"\nSelected features: {X.columns[preprocessing_pipeline.named_steps['feature_selection'].get_support()].tolist()}")
print(f"Feature selection scores: {preprocessing_pipeline.named_steps['feature_selection'].scores_}")

# Hyperparameter optimization across pipeline
param_grid = {
    'feature_selection__k': [5, 10, 15],
    'classifier__n_estimators': [100, 200],
    'classifier__max_depth': [3, 5, None]
}

grid_search = GridSearchCV(preprocessing_pipeline, param_grid, cv=5, scoring='accuracy')
grid_search.fit(X_train, y_train)

print(f"\nBest pipeline parameters: {grid_search.best_params_}")
print(f"Best cross-validation score: {grid_search.best_score_:.4f}")
```

**Advanced Pipeline Usage:**

```python
from sklearn.pipeline import make_pipeline
from sklearn.decomposition import PCA
from sklearn.preprocessing import PolynomialFeatures

# Using make_pipeline for automatic naming
auto_pipeline = make_pipeline(
    StandardScaler(),
    PCA(n_components=10),
    PolynomialFeatures(degree=2),
    RandomForestClassifier(random_state=42)
)

# Pipeline with intermediate results access
class PipelineWithIntermediateResults(Pipeline):
    def fit(self, X, y=None, **fit_params):
        super().fit(X, y, **fit_params)
        return self
    
    def get_intermediate_results(self, X):
        """Get results after each transformation step"""
        results = {}
        X_transformed = X.copy()
        
        for name, transformer in self.steps[:-1]:
            X_transformed = transformer.transform(X_transformed)
            results[name] = X_transformed.copy()
            
        return results

# Custom pipeline with intermediate access
diagnostic_pipeline = PipelineWithIntermediateResults([
    ('scaler', StandardScaler()),
    ('pca', PCA(n_components=5)),
    ('classifier', RandomForestClassifier(random_state=42))
])

diagnostic_pipeline.fit(X_train, y_train)
intermediate_results = diagnostic_pipeline.get_intermediate_results(X_test[:5])

for step_name, result in intermediate_results.items():
    print(f"After {step_name}: shape {result.shape}")
```

Pipeline class provides the foundation for all other pipeline constructs and ensures reproducible, maintainable machine learning workflows.

