## OrdinalEncoder Usage


OrdinalEncoder assigns integer values to categories, preserving or imposing ordinal relationships. This encoding is memory-efficient and suitable when categorical variables have natural ordering or when tree-based algorithms can handle arbitrary numeric assignments.

### Basic Implementation

```python
from sklearn.preprocessing import OrdinalEncoder

# Initialize with custom category order
categories = [['small', 'medium', 'large'], ['low', 'medium', 'high']]
encoder = OrdinalEncoder(categories=categories)

data = [['small', 'low'], ['large', 'high'], ['medium', 'medium']]
encoded = encoder.fit_transform(data)
print(encoded)  # [[0, 0], [2, 2], [1, 1]]
```

### Advanced Configuration

**categories parameter**: Explicitly defines category ordering and expected values

```python
# Automatic category detection
encoder = OrdinalEncoder()  # Auto-detects from data

# Manual category specification with ordering
encoder = OrdinalEncoder(categories=[['poor', 'fair', 'good', 'excellent']])
```

**handle_unknown parameter**: Manages unseen categories during encoding

```python
# Use -1 for unknown categories
encoder = OrdinalEncoder(handle_unknown='use_encoded_value', unknown_value=-1)
```

**encoded_missing_value parameter**: Handles missing values explicitly

```python
# Assign specific value to missing data
encoder = OrdinalEncoder(encoded_missing_value=-999)
```

### Strategic Applications

OrdinalEncoder excels in specific scenarios:

**Ordinal Variables**: Natural ordering exists (education levels, ratings, sizes)

```python
education_data = [['High School'], ['Bachelor'], ['Master'], ['PhD']]
education_encoder = OrdinalEncoder(
    categories=[['High School', 'Bachelor', 'Master', 'PhD']]
)
```

**Tree-based Algorithms**: Random forests and gradient boosting can handle arbitrary ordinal assignments effectively

```python
from sklearn.ensemble import RandomForestClassifier

# Tree algorithms handle ordinal encoding well
pipeline = Pipeline([
    ('encoder', OrdinalEncoder()),
    ('classifier', RandomForestClassifier())
])
```

**High Cardinality Features**: More memory-efficient than one-hot encoding for many categories

```python
# Efficient for features with many unique values
zip_encoder = OrdinalEncoder()  # For ZIP codes, product IDs, etc.
```

**Key Points**:

- Memory efficient for high cardinality features
- Preserves ordinal relationships when specified
- May introduce artificial ordering assumptions
- Requires careful consideration of category relationships

