## Pipeline Integration


**Example** of combining scalers in machine learning pipelines:

```python
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report

# Create pipeline with scaling
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', LogisticRegression())
])

# Alternative pipelines for comparison
pipelines = {
    'StandardScaler': Pipeline([('scaler', StandardScaler()), ('clf', LogisticRegression())]),
    'MinMaxScaler': Pipeline([('scaler', MinMaxScaler()), ('clf', LogisticRegression())]),
    'RobustScaler': Pipeline([('scaler', RobustScaler()), ('clf', LogisticRegression())]),
    'QuantileTransformer': Pipeline([('scaler', QuantileTransformer()), ('clf', LogisticRegression())])
}
```

