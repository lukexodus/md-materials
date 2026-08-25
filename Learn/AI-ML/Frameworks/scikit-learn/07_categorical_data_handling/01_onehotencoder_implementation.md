## OneHotEncoder Implementation


OneHotEncoder creates binary columns for each category, producing a sparse representation where each category becomes a separate feature. This approach maintains independence between categories and prevents artificial ordering assumptions.

### Basic Implementation

```python
from sklearn.preprocessing import OneHotEncoder
import numpy as np
import pandas as pd

# Initialize encoder
encoder = OneHotEncoder()

# Sample categorical data
categories = [['red', 'blue'], ['small', 'medium', 'large']]
data = [['red', 'small'], ['blue', 'large'], ['red', 'medium']]

# Fit and transform
encoded = encoder.fit_transform(data)
print(encoded.toarray())
```

### Advanced Configuration Options

The OneHotEncoder offers sophisticated parameters for handling various scenarios:

**drop parameter**: Controls which category to drop to avoid multicollinearity

- `drop='first'`: Removes first category of each feature
- `drop='if_binary'`: Drops only for binary features
- `drop=array`: Specifies exact categories to drop

```python
# Drop first category to avoid dummy variable trap
encoder = OneHotEncoder(drop='first', sparse_output=False)
encoded = encoder.fit_transform(data)
```

**handle_unknown parameter**: Manages unseen categories during transformation

- `'error'`: Raises error for unknown categories (default)
- `'ignore'`: Creates zero vector for unknown categories
- `'infrequent_if_exist'`: Maps to infrequent category if configured

```python
# Handle unknown categories gracefully
encoder = OneHotEncoder(handle_unknown='ignore', sparse_output=False)
encoder.fit([['red'], ['blue']])
result = encoder.transform([['green']])  # Unknown category
```

**min_frequency parameter**: Groups infrequent categories together

```python
# Group categories appearing less than 3 times
encoder = OneHotEncoder(min_frequency=3, sparse_output=False)
```

### Integration with Pipelines

OneHotEncoder integrates seamlessly with scikit-learn pipelines for preprocessing workflows:

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LogisticRegression

# Define preprocessing for different column types
preprocessor = ColumnTransformer(
    transformers=[
        ('cat', OneHotEncoder(drop='first'), ['category_col']),
        ('num', 'passthrough', ['numeric_col'])
    ]
)

# Create pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', LogisticRegression())
])
```

**Key Points**:

- Creates sparse matrices by default for memory efficiency
- Produces interpretable features with clear category mapping
- Handles high cardinality poorly due to dimensionality explosion
- May cause multicollinearity without proper dropping strategy

